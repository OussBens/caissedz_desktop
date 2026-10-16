import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_excel.dart';
import 'package:caissedz_desktop/core/print/rapport_pdf.dart';
import 'package:caissedz_desktop/data/situation_repository.dart';
import 'package:caissedz_desktop/data/statistiques_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/rapport.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
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
    test('créances, dettes, séries du tableau de bord', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final stats = StatistiquesRepository(base.db);
      final situation = SituationRepository(base.db);
      final auj = DateTime.now();
      expect(await stats.creancesClients(), 200);
      // Lait : 10 − 5 = 5 ≥ seuil 2 ; Eau : 3 − 1 + 10 = 12 ≥ 5 → 0 sous seuil.
      expect(await stats.produitsSousSeuil(5), 0);
      expect(await stats.dettesFournisseurs(), 150);
      expect(await stats.valeurStockAchat(), 5 * 80.0 + 12 * 20.0);
      expect(await stats.soldeCaisses(), 1000 + 200 + 30 + 100 - 50);
      final jours = await stats.caParJour(auj.subtract(const Duration(days: 6)), auj);
      expect(jours.length, 7);
      expect(jours.last.valeur, 530);
      final modes = await stats.paiementsParMode(DateTime(2000), auj.add(const Duration(days: 1)));
      expect({for (final m in modes) m.etiquette: m.valeur}, {'Espèces': 300, 'Carte': 30});
      expect(await situation.totalVentes(auj, auj), 530);
      expect(await situation.totalAchats(auj, auj), 200);
      final top = await situation.topProduits(auj, auj);
      expect((top.first.nom, top.first.quantite, top.first.total), ('Lait', 5.0, 500.0));
      final caissiers = await situation.ventesParCaissier(auj, auj);
      expect((caissiers.single.tickets, caissiers.single.total), (3, 530.0));
      final dernieres = await situation.dernieresVentes();
      expect(dernieres.map((v) => v['statut']), ['partiel', 'paye', 'paye']);
      expect(await situation.ruptures(), isEmpty);
    });

    test('les 10 analyses de la Situation : recettes, marges (coût figé), stock, inventaire', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final s = SituationRepository(base.db);
      final auj = DateTime.now();
      const f = FiltresSituation();
      expect(SituationRepository.analyses.length, 11);

      final rcp = await s.recetteParPanier(auj, auj, f);
      expect(rcp.length, 3);
      final credit = rcp.firstWhere((r) => r['client'] == 'Amina');
      expect((credit['montant'], credit['paye'], credit['reste']), (300.0, 100.0, 200.0));

      final rcpr = await s.recetteParProduit(auj, auj, f);
      expect(
        (rcpr.first['nom'], rcpr.first['quantite'], rcpr.first['prixMoyen'], rcpr.first['recette']),
        ('Lait', 5.0, 100.0, 500.0),
      );

      final mvc = await s.mouvementCaisse(auj, auj, f);
      final entrees = mvc.fold(0.0, (a, r) => a + (r['entrees']! as double));
      final sorties = mvc.fold(0.0, (a, r) => a + (r['sorties']! as double));
      expect(entrees - sorties, 1000 + 200 + 30 + 100 - 50);
      expect((await s.mouvementCaisse(auj, auj, const FiltresSituation(typeMouvement: 'Vente'))).length, 1);

      final mvp = await s.mouvementProduit(auj, auj, f);
      final lait = mvp.firstWhere((r) => r['nom'] == 'Lait');
      expect((lait['initial'], lait['entrees'], lait['sorties'], lait['final']), (0.0, 10.0, 5.0, 5.0));
      final hier = auj.subtract(const Duration(days: 1));
      expect(await s.mouvementProduit(hier, hier, f), isEmpty);

      // Coût figé à la vente : 5 × 80 pour le lait, 1 × 20 pour l'eau.
      final mgp = await s.margeParPanier(auj, auj, f);
      final m = mgp.firstWhere((r) => r['client'] == 'Amina');
      expect((m['montant'], m['cout'], m['marge'], m['taux']), (300.0, 240.0, 60.0, 25.0));
      for (final g in Regroupement.values) {
        final mgper = await s.margeParPeriode(auj, auj, FiltresSituation(regroupement: g));
        expect((mgper.single['montant'], mgper.single['cout']), (530.0, 420.0), reason: g.name);
      }

      final cout = await s.coutProduit(f);
      final eau = cout.firstWhere((r) => r['nom'] == 'Eau');
      expect((eau['dernier'], eau['moyen'], eau['prixVente'], eau['taux']), (20.0, 20.0, 30.0, 50.0));

      final inv = await s.inventaire(const FiltresSituation(magasin: 'MAG0000'));
      expect(inv.firstWhere((r) => r['nom'] == 'Eau')['theorique'], 12.0);
      final n = await StockService(base.db, utilisateurCode: 'USR0000').inventorierLot(
        magasinCode: 'MAG0000',
        quantitesConstatees: {
          inv.first['code']! as String: 3,
          inv.last['code']! as String: inv.last['theorique']! as double,
        },
      );
      expect((n.code, n.ajustes), ('INV0001', 1));
      final apres = await s.inventaire(const FiltresSituation(magasin: 'MAG0000'));
      expect(apres.first['theorique'], 3.0);
    });

    test('export Excel et PDF des rapports', () async {
      const r = Rapport(
        id: 'test',
        titre: 'Test',
        colonnes: [RapportColonne('Nom'), RapportColonne('Montant', numerique: true, monetaire: true)],
        lignes: [
          ['A', 10.0],
          ['B', 20.0],
        ],
        totaux: ['Total', 30.0],
      );
      final excel = Excel.decodeBytes(ExportExcel.rapport(r, sousTitre: 'test'));
      expect(excel.tables.values.single.maxRows, 4 + 2 + 1);
      final pdf = await const RapportPdf().generer(r, boutique: 'Test', periode: 'p');
      expect(pdf.length, greaterThan(500));
    });
  });
}
