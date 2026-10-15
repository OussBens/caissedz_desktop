import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/client_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/domain/models/vente.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

class _Ctx {
  _Ctx(this.db);
  final dynamic db;
  late Produit lait;
  late Client client;
  late SessionCaisse session;
  late VenteService ventes;
  late TiersService tiers;
  late VersementService versements;
  late RetourService retours;

  Future<void> preparer() async {
    final cat = CatalogueService(db, utilisateurCode: 'USR0000');
    lait = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
      ),
    );
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 100);
    tiers = TiersService(db, utilisateurCode: 'USR0000');
    client = await tiers.creerClient(
      const Client(code: '', nom: 'Amina', telephone: '0550 12 34 56', plafondCredit: 5000),
    );
    session = await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    versements = VersementService(db, utilisateurCode: 'USR0000');
    retours = RetourService(db, utilisateurCode: 'USR0000');
  }

  /// Vente à crédit de [quantite] laits, payée [paye].
  Future<Vente> venteCredit(double quantite, double paye, {DateTime? date}) => ventes.encaisser(
    Panier(id: 1, clientCode: client.code)
        .ajouter(PanierLigne(produit: lait, quantite: quantite, prixUnitaire: 100))
        .copyWith(
          paiements: paye > 0 ? [Paiement(mode: 'Espèces', montant: paye)] : const [],
        ),
    session: session,
    magasinCode: 'MAG0000',
    creditAutorise: true,
    date: date,
  );
}

void main() {
  group('TiersService', () {
    test('clients et fournisseurs : création codée, modification, système protégé', () async {
      final base = await ouvrirBaseDeTest();
      final s = TiersService(base.db, utilisateurCode: 'USR0000');
      final c = await s.creerClient(const Client(code: '', nom: '  Karim  '));
      expect(c.code, 'CLN0001');
      expect(c.nom, 'Karim');
      await s.modifierClient(c.copyWith(telephone: '0661 12 34 56'));
      expect((await ClientRepository(base.db).parCode(c.code))!.telephone, '0661 12 34 56');
      await expectLater(
        s.creerClient(const Client(code: '', nom: ' ')),
        throwsA(isA<TiersException>().having((e) => e.erreur, 'e', ErreurTiers.nomVide)),
      );
      await expectLater(
        s.modifierClient(const Client(code: 'CLN0000', nom: 'x', systeme: true)),
        throwsA(isA<TiersException>().having((e) => e.erreur, 'e', ErreurTiers.systeme)),
      );
      final f = await s.creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
      expect(f.code, 'FOR0001');
      expect((await TiersRepository(base.db).fournisseurs(recherche: 'gross')).single.code, 'FOR0001');
    });
  });

  group('VersementService — imputation plus ancien d’abord', () {
    test('répartition sur les documents ouverts, solde, avance', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v1 = await c.venteCredit(3, 0, date: DateTime(2026, 1, 10)); // reste 300
      final v2 = await c.venteCredit(5, 100, date: DateTime(2026, 2, 10)); // reste 400
      final repo = TiersRepository(base.db);
      expect(await repo.soldeClient(c.client.code), 700);
      final docs = await repo.documentsOuvertsClient(c.client.code);
      expect(docs.map((d) => d.code), [v1.code, v2.code]);
      final ver = await c.versements.imputer(
        tiersType: TypesTiers.client,
        tiersCode: c.client.code,
        montant: 450,
        mode: 'Espèces',
      );
      expect(ver.code, 'VER0001');
      expect(ver.imputations.map((i) => (i.documentCode, i.montant)), [(v1.code, 300.0), (v2.code, 150.0)]);
      expect(ver.nonImpute, 0);
      expect(await repo.soldeClient(c.client.code), 250);
      expect((await repo.documentsOuvertsClient(c.client.code)).single.reste, 250);
      final avance = await c.versements.imputer(
        tiersType: TypesTiers.client,
        tiersCode: c.client.code,
        montant: 300,
        mode: 'Carte',
      );
      expect(avance.impute, 250);
      expect(avance.nonImpute, 50);
      expect(await repo.soldeClient(c.client.code), -50, reason: 'avance de 50 en faveur du client');
      expect(await repo.documentsOuvertsClient(c.client.code), isEmpty);
      await expectLater(
        c.versements.imputer(tiersType: TypesTiers.client, tiersCode: 'CLN0000', montant: 10, mode: 'Espèces'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.tiersSysteme)),
      );
      await expectLater(
        c.versements.imputer(tiersType: TypesTiers.client, tiersCode: c.client.code, montant: 10, mode: 'Points'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.modeInvalide)),
      );
      await expectLater(
        c.versements.imputer(tiersType: TypesTiers.client, tiersCode: c.client.code, montant: 0, mode: 'Espèces'),
        throwsA(isA<VersementException>()),
      );
      await expectLater(
        c.versements.annuler(avance.code, motif: ' '),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.motifObligatoire)),
      );
      await c.versements.annuler(avance.code, motif: 'Montant erroné');
      expect(await repo.soldeClient(c.client.code), 250);
      final annule = (await repo.versement(avance.code))!;
      expect(annule.actif, isFalse);
      expect(annule.motifAnnulation, 'Montant erroné');
      expect(annule.imputations, isEmpty);
      await expectLater(
        c.versements.annuler(avance.code, motif: 'x'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.dejaAnnule)),
      );
    });

    test('modification : imputations recalculées ; versement retour non imputé ; statistiques et relevé', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      await c.venteCredit(3, 0); // reste 300
      final repo = TiersRepository(base.db);
      final v = await c.versements.imputer(
        tiersType: TypesTiers.client,
        tiersCode: c.client.code,
        montant: 100,
        mode: 'Espèces',
      );
      expect(v.impute, 100);
      final m = await c.versements.modifier(v.code, montant: 350, mode: 'Chèque', date: v.date);
      expect(m.impute, 300);
      expect(m.mode, 'Chèque');
      expect(await repo.soldeClient(c.client.code), -50);
      // Argent rendu au client : décaissement non imputé, l'avance disparaît.
      final rendu = await c.versements.imputer(
        tiersType: TypesTiers.client,
        tiersCode: c.client.code,
        montant: 50,
        mode: 'Espèces',
        sens: SensVersement.decaissement,
      );
      expect(rendu.imputations, isEmpty);
      expect(rendu.estRetour, isTrue);
      final stats = (await repo.statistiques(TypesTiers.client))[c.client.code]!;
      expect(stats.achats, 300);
      expect(stats.du, 0);
      expect(stats.solde, 0);
      expect(stats.paye, 300);
      final releve = await repo.releve(TypesTiers.client, c.client.code);
      expect(releve.fold(0.0, (s, l) => s + l.credit - l.debit), 0);
      expect(releve.map((l) => l.nature), contains(NatureReleve.versementRetour));
    });
  });

  group('RetourService', () {
    test('retour partiel : stock restitué, remboursement verrouillé, avoir imputé', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v = await c.venteCredit(4, 400); // soldée
      final v2 = await c.venteCredit(2, 0); // reste 200
      final r = await c.retours.creer(
        venteCode: v.code,
        lignes: [DemandeRetourLigne(produitCode: c.lait.code, quantite: 3)],
        rembourser: 100,
        motif: 'Défectueux',
      );
      expect(r.code, 'RET0001');
      expect(r.total, 300);
      expect(r.rembourse, 100);
      expect(r.versementCode, 'VER0001');
      expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 100 - 6 + 3);
      final repo = TiersRepository(base.db);
      final rembours = (await repo.versement('VER0001'))!;
      expect(rembours.verrouille, isTrue);
      expect(rembours.sens, SensVersement.decaissement);
      expect(rembours.retourCode, r.code);
      await expectLater(
        c.versements.annuler('VER0001', motif: 'Erreur'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.verrouille)),
      );
      // Avoir de 200 imputé sur la vente ouverte v2
      final avoir = (await repo.versement('VER0002'))!;
      expect(avoir.mode, 'Avoir');
      expect(avoir.imputations.single.documentCode, v2.code);
      expect(avoir.imputations.single.montant, 200);
      expect(await repo.soldeClient(c.client.code), 0);
      // Dépassement de quantité refusé, rien écrit
      await expectLater(
        c.retours.creer(
          venteCode: v.code,
          lignes: [DemandeRetourLigne(produitCode: c.lait.code, quantite: 2)],
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.quantiteDepasse)),
      );
      expect((await repo.retours()).length, 1);
      await expectLater(
        c.retours.creer(
          venteCode: 'VTE9999',
          lignes: [DemandeRetourLigne(produitCode: c.lait.code, quantite: 1)],
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.venteInconnue)),
      );
      await expectLater(
        c.retours.creer(venteCode: v.code, lignes: const []),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.lignesVides)),
      );
      final ferme = RetourService(base.db, utilisateurCode: 'USR0000', periodeCloturee: (_, _) async => true);
      await expectLater(
        ferme.creer(
          venteCode: v.code,
          lignes: [DemandeRetourLigne(produitCode: c.lait.code, quantite: 1)],
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.periodeCloturee)),
      );
    });

    test('retour sur vente annulée refusé', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v = await c.venteCredit(1, 100);
      await c.ventes.annuler(v.code, motif: 'test');
      await expectLater(
        c.retours.creer(
          venteCode: v.code,
          lignes: [DemandeRetourLigne(produitCode: c.lait.code, quantite: 1)],
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.venteAnnulee)),
      );
    });
  });
}
