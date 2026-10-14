import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_excel.dart';
import 'package:caissedz_desktop/core/print/rapport_pdf.dart';
import 'package:caissedz_desktop/data/statistiques_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/domain/zakat.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

Future<void> _jeu(Database db) async {
  final cat = CatalogueService(db, utilisateurCode: 'USR0000');
  final lait = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Lait',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
      seuilStock: 2,
    ),
  );
  final eau = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Eau',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 20,
      prixVente: 30,
    ),
  );
  final stock = StockService(db, utilisateurCode: 'USR0000');
  await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
  await stock.entrerStock(produitCode: eau.code, magasinCode: 'MAG0000', quantite: 3);
  final client = await TiersService(
    db,
    utilisateurCode: 'USR0000',
  ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 10000));
  final f = await TiersService(
    db,
    utilisateurCode: 'USR0000',
  ).creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
  final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
  final s = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 1000);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  // 2 × Lait espèces (200), 1 × Eau carte (30), 3 × Lait à crédit (300, versé 100).
  await ventes.encaisser(
    const Panier(id: 1)
        .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
    session: s,
    magasinCode: 'MAG0000',
  );
  await ventes.encaisser(
    const Panier(id: 2)
        .ajouter(PanierLigne(produit: eau, quantite: 1, prixUnitaire: 30))
        .ajouterPaiement(const Paiement(mode: 'Carte', montant: 30)),
    session: s,
    magasinCode: 'MAG0000',
  );
  await ventes.encaisser(
    Panier(id: 3, clientCode: client.code)
        .ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
    session: s,
    magasinCode: 'MAG0000',
    creditAutorise: true,
  );
  await AchatService(db, utilisateurCode: 'USR0000').enregistrer(
    fournisseurCode: f.code,
    magasinCode: 'MAG0000',
    lignes: [DemandeAchatLigne(produitCode: eau.code, quantite: 10, prixAchat: 20)],
    verse: 50,
  );
}

void main() {
  group('Statistiques', () {
    test('KPI, séries et créances / dettes', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final stats = StatistiquesRepository(base.db);
      final kpi = await stats.kpi(jour: DateTime.now(), seuilGlobal: 5);
      expect(kpi.ticketsJour, 3);
      expect(kpi.caJour, 530);
      expect(kpi.panierMoyen, 176.67);
      expect(kpi.caMois, 530);
      expect(kpi.creancesClients, 200);
      // Lait : 10 − 5 = 5 ≥ seuil 2 ; Eau : 3 − 1 + 10 = 12 ≥ 5 → 0 sous seuil.
      expect(kpi.produitsSousSeuil, 0);
      expect(await stats.dettesFournisseurs(), 150);
      expect(await stats.valeurStockAchat(), 5 * 80.0 + 12 * 20.0);
      expect(await stats.soldeCaisses(), 1000 + 200 + 30 + 100 - 50);
      final jours = await stats.caParJour(DateTime.now().subtract(const Duration(days: 6)), DateTime.now());
      expect(jours.length, 7);
      expect(jours.last.valeur, 530);
      final mois = await stats.caParMois(DateTime.now());
      expect(mois.length, 12);
      expect(mois.last.valeur, 530);
      final modes = await stats.paiementsParMode(DateTime(2000), DateTime.now().add(const Duration(days: 1)));
      expect({for (final m in modes) m.etiquette: m.valeur}, {'Espèces': 300, 'Carte': 30});
      final top = await stats.topProduits(DateTime(2000), DateTime.now().add(const Duration(days: 1)));
      expect(top.first.etiquette, 'Lait');
      expect(top.first.valeur, 500);
      final cats = await stats.ventesParCategorie(DateTime(2000), DateTime.now().add(const Duration(days: 1)));
      expect(cats.single.valeur, 530);
    });

    test('les 10 rapports de Situation, export Excel et PDF', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final stats = StatistiquesRepository(base.db);
      final debut = DateTime(2000);
      final fin = DateTime.now().add(const Duration(days: 1));
      expect(StatistiquesRepository.rapports.length, 10);
      for (final id in StatistiquesRepository.rapports) {
        final r = await stats.rapport(id, debut: debut, fin: fin);
        expect(r.id, id);
        expect(r.colonnes, isNotEmpty);
        for (final l in r.lignes) {
          expect(l.length, r.colonnes.length, reason: id);
        }
        if (r.totaux != null) expect(r.totaux!.length, r.colonnes.length, reason: id);
        final xlsx = ExportExcel.rapport(r, sousTitre: 'test');
        final excel = Excel.decodeBytes(xlsx);
        final feuille = excel.tables.values.single;
        expect(feuille.maxRows, 4 + r.lignes.length + (r.totaux == null ? 0 : 1), reason: id);
        final pdf = await const RapportPdf().generer(r, boutique: 'Test', periode: 'p');
        expect(pdf.length, greaterThan(500), reason: id);
      }
      final jour = await stats.rapport('ventes_jour', debut: debut, fin: fin);
      expect(jour.lignes.single[1], 3);
      expect(jour.lignes.single[4], 530);
      expect(jour.totaux![4], 530);
      final produit = await stats.rapport('ventes_produit', debut: debut, fin: fin);
      expect(produit.lignes.first[1], 'Lait');
      expect(produit.lignes.first[5], 500 - 5 * 80.0); // marge estimée
      final stock = await stats.rapport('etat_stock', debut: debut, fin: fin, seuilGlobal: 5);
      expect(stock.lignes.map((l) => l[5]), everyElement('OK'));
      final cd = await stats.rapport('creances_dettes', debut: debut, fin: fin);
      expect(cd.lignes.map((l) => (l[0], l[3])).toSet(), {('Client', 200.0), ('Fournisseur', 150.0)});
      final rfs = await stats.rapport('achats_fournisseur', debut: debut, fin: fin);
      expect(rfs.lignes.single[5], 150);
    });
  });

  group('Zakat', () {
    test('nissab 85 g, taux 2,5 %, assujettissement', () {
      final r = CalculZakat.calculer(
        stock: 900000,
        caisses: 300000,
        creances: 100000,
        dettes: 200000,
        prixGrammeOr: 12000,
      );
      expect(r.assiette, 1100000);
      expect(r.nissab, 1020000);
      expect(r.assujetti, isTrue);
      expect(r.montant, 27500);
      final sous = CalculZakat.calculer(stock: 100000, caisses: 0, creances: 0, dettes: 0, prixGrammeOr: 12000);
      expect(sous.assujetti, isFalse);
      expect(sous.montant, 0);
      expect(CalculZakat.calculer(stock: 1, caisses: 1, creances: 1, dettes: 0, prixGrammeOr: 0).assujetti, isFalse);
    });
  });
}
