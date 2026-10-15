import 'package:caissedz_desktop/application/achat_service.dart';
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
import 'package:caissedz_desktop/domain/models/achat.dart';
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
    test('retour client remboursé : stock restitué, versement verrouillé, plafond de quantité', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v = await c.venteCredit(4, 400); // soldée
      final r = await c.retours.creer(
        type: TypesTiers.client,
        documentCode: v.code,
        produitCode: c.lait.code,
        quantite: 3,
        observation: 'Défectueux',
      );
      expect(r.code, 'RET0001');
      expect(r.total, 300);
      expect(r.rembourse, 300);
      expect(r.versementCode, 'VER0001');
      expect(r.ligne!.prixAchat, 80);
      expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 100 - 4 + 3);
      final repo = TiersRepository(base.db);
      final rembours = (await repo.versement('VER0001'))!;
      expect(rembours.verrouille, isTrue);
      expect(rembours.sens, SensVersement.decaissement);
      expect(rembours.retourCode, r.code);
      await expectLater(
        c.versements.annuler('VER0001', motif: 'Erreur'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.verrouille)),
      );
      // Dépassement de quantité refusé, rien écrit
      await expectLater(
        c.retours.creer(type: TypesTiers.client, documentCode: v.code, produitCode: c.lait.code, quantite: 2),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.quantiteDepasse)),
      );
      expect((await repo.retours()).length, 1);
      await expectLater(
        c.retours.creer(type: TypesTiers.client, documentCode: 'VTE9999', produitCode: c.lait.code, quantite: 1),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.documentInconnu)),
      );
      await expectLater(
        c.retours.creer(type: TypesTiers.client, documentCode: v.code, produitCode: c.lait.code, quantite: 0),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.quantiteInvalide)),
      );
      final ferme = RetourService(base.db, utilisateurCode: 'USR0000', periodeCloturee: (_, _) async => true);
      await expectLater(
        ferme.creer(type: TypesTiers.client, documentCode: v.code, produitCode: c.lait.code, quantite: 1),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.periodeCloturee)),
      );
    });

    test('retour client en avoir imputé d\'abord sur le panier d\'origine ; non revendable = sortie Casse', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v1 = await c.venteCredit(2, 0); // reste 200
      final v2 = await c.venteCredit(3, 0); // reste 300
      final r = await c.retours.creer(
        type: TypesTiers.client,
        documentCode: v2.code,
        produitCode: c.lait.code,
        quantite: 1,
        reglement: ReglementsRetour.avoir,
        remiseEnStock: false,
      );
      expect(r.rembourse, 0);
      final repo = TiersRepository(base.db);
      final avoir = (await repo.versement(r.versementCode!))!;
      expect(avoir.mode, 'Avoir');
      expect(avoir.imputations.single.documentCode, v2.code);
      expect(await repo.soldeClient(c.client.code), 400);
      expect(v1.reste, 200);
      // Entrée Retour puis sortie Casse : le stock ne bouge pas.
      expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 100 - 5);
      // Client de passage : pas d'avoir.
      final passage = await c.ventes.encaisser(
        const Panier(id: 9)
            .ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: c.session,
        magasinCode: 'MAG0000',
      );
      await expectLater(
        c.retours.creer(
          type: TypesTiers.client,
          documentCode: passage.code,
          produitCode: c.lait.code,
          quantite: 1,
          reglement: ReglementsRetour.avoir,
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.reglementInvalide)),
      );
    });

    test('modifier puis annuler : stock et versements recalculés, vente annulable ensuite', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v = await c.venteCredit(4, 400);
      final stock = StockRepository(base.db);
      final r = await c.retours.creer(
        type: TypesTiers.client,
        documentCode: v.code,
        produitCode: c.lait.code,
        quantite: 1,
      );
      final m = await c.retours.modifier(r.code, quantite: 2, reglement: ReglementsRetour.carte);
      expect(m.code, r.code);
      expect(m.total, 200);
      expect(m.reglement, ReglementsRetour.carte);
      expect((await stock.niveau(c.lait.code, 'MAG0000')).quantite, 100 - 4 + 2);
      final repo = TiersRepository(base.db);
      final actifs = (await repo.versements()).where((x) => x.actif && x.retourCode == r.code).toList();
      expect(actifs.single.montant, 200);
      expect(actifs.single.mode, 'Carte');
      await expectLater(
        c.ventes.annuler(v.code, motif: 'test'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.retourLie)),
      );
      await expectLater(
        c.retours.annuler(r.code, motif: ' '),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.motifObligatoire)),
      );
      final a = await c.retours.annuler(r.code, motif: 'Doublon');
      expect(a.actif, isFalse);
      expect(a.motifAnnulation, 'Doublon');
      expect((await stock.niveau(c.lait.code, 'MAG0000')).quantite, 96);
      expect((await repo.versements()).where((x) => x.actif && x.retourCode == r.code), isEmpty);
      await expectLater(
        c.retours.annuler(r.code, motif: 'x'),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.dejaAnnule)),
      );
      expect((await c.ventes.annuler(v.code, motif: 'test')).statut, StatutsVente.annulee);
    });

    test('retour fournisseur : sortie du stock, dette déduite, entrée non annulable', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final f = await c.tiers.creerFournisseur(
        const Fournisseur(code: '', nom: 'Djurdjura', telephone: '021 23 45 67'),
      );
      final achats = AchatService(base.db, utilisateurCode: 'USR0000');
      final a = await achats.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: c.lait.code, quantite: 10, prixAchat: 80)],
      );
      final repo = TiersRepository(base.db);
      expect(await repo.soldeFournisseur(f.code), 800);
      final r = await c.retours.creer(
        type: TypesTiers.fournisseur,
        documentCode: a.code,
        produitCode: c.lait.code,
        quantite: 2,
        reglement: ReglementsRetour.avoir,
      );
      expect(r.type, TypesTiers.fournisseur);
      expect(r.fournisseurCode, f.code);
      expect(r.total, 160);
      expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 100 + 10 - 2);
      expect(await repo.soldeFournisseur(f.code), 640);
      await expectLater(
        achats.annuler(a.code),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.retourLie)),
      );
      await expectLater(
        c.retours.creer(type: TypesTiers.fournisseur, documentCode: a.code, produitCode: c.lait.code, quantite: 9),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.quantiteDepasse)),
      );
      final especes = await c.retours.creer(
        type: TypesTiers.fournisseur,
        documentCode: a.code,
        produitCode: c.lait.code,
        quantite: 1,
      );
      final v = (await repo.versement(especes.versementCode!))!;
      expect(v.sens, SensVersement.encaissement);
      expect(v.montant, 80);
      expect((await repo.statistiques(TypesTiers.fournisseur))[f.code]!.retours, 240);
    });

    test('retour sur vente annulée refusé', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final v = await c.venteCredit(1, 100);
      await c.ventes.annuler(v.code, motif: 'test');
      await expectLater(
        c.retours.creer(type: TypesTiers.client, documentCode: v.code, produitCode: c.lait.code, quantite: 1),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.documentAnnule)),
      );
    });
  });
}
