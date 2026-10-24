import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/domain/fiscalite.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/caisse/pos_controller.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';
import '../../helpers/bases.dart';

void main() {
  late ProviderContainer c;
  late Produit lait;
  late Produit eau;

  setUp(() async {
    final base = await ouvrirBaseDeTest();
    c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(base),
        licenceServiceProvider.overrideWithValue(await licenceServiceTest(base)),
        authServiceProvider.overrideWithValue(authServiceTest(base)),
        configurationServiceProvider.overrideWithValue(configurationServiceTest(base)),
      ],
    );
    addTearDown(c.dispose);
    await donnerMotDePasseAdmin(base);
    await c.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.ultra));
    await c.read(configurationTermineeProvider.notifier).terminer(configurationTest());
    await c.read(sessionProvider.notifier).connecter(identifiantAdmin, motDePasseAdmin);
    final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
    lait = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        codeBarres: '6130000000015',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
        tvaPct: 0, // exonéré : prix TTC = prix HT
      ),
    );
    eau = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Eau',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 20,
        prixVente: 30,
        tvaPct: 0, // exonéré : prix TTC = prix HT
      ),
    );
    await cat.creerColis(
      Colis(
        code: '',
        produitCode: lait.code,
        designation: 'Pack 6 laits',
        quantite: 6,
        codeBarres: '6130000000022',
        prixVente: 550,
      ),
    );
    final stock = StockService(base.db, utilisateurCode: 'USR0000');
    await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
    await c.read(posControllerProvider.notifier).initialiser();
  });

  test('réservation de stock entre paniers : 5 paniers max, disponibilité = stock − réservé', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouter(lait, quantite: 6);
    ctrl.nouveauPanier();
    expect(c.read(posControllerProvider).courant, 1);
    await ctrl.ajouter(lait, quantite: 4);
    await expectLater(
      ctrl.ajouter(lait),
      throwsA(isA<PosException>().having((e) => e.erreur, 'e', ErreurPos.stockInsuffisant)),
    );
    await expectLater(ctrl.modifierQuantite(0, 5), throwsA(isA<PosException>()));
    ctrl.selectionnerPanier(0);
    ctrl.retirerLigne(0);
    ctrl.selectionnerPanier(1);
    await ctrl.modifierQuantite(0, 10);
    expect(c.read(posControllerProvider).panier.lignes.single.quantite, 10);
    for (var i = 0; i < 3; i++) {
      ctrl.nouveauPanier();
    }
    expect(c.read(posControllerProvider).paniers.length, 5);
    expect(ctrl.nouveauPanier, throwsA(isA<PosException>().having((e) => e.erreur, 'e', ErreurPos.maxPaniers)));
    ctrl.panierSuivant();
    expect(c.read(posControllerProvider).courant, 0);
    ctrl.fermerPanier(4);
    expect(c.read(posControllerProvider).paniers.length, 4);
    await expectLater(ctrl.ajouter(eau), throwsA(isA<PosException>()), reason: 'eau : stock 0');
  });

  test('prix de vente HT : la caisse applique le TTC (HT + TVA), sans TVA au régime IFU', () async {
    final db = c.read(appDatabaseProvider).db;
    final cafe = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      const Produit(
        code: '',
        designation: 'Café',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixVente: 100,
        tvaPct: 19,
        service: true,
      ),
    );
    await c.read(parametresVenteProvider.future);
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouter(cafe);
    expect(c.read(posControllerProvider).panier.lignes.single.prixUnitaire, 119);
    ctrl.retirerLigne(0);
    await ParametreRepository(db).ecrire(Fiscalite.cleRegime, RegimesFiscaux.ifu);
    c.invalidate(parametresVenteProvider);
    await c.read(parametresVenteProvider.future);
    await ctrl.ajouter(cafe);
    expect(c.read(posControllerProvider).panier.lignes.single.prixUnitaire, 100);
    // Régime réel mais « vente en caisse avec TVA » désactivée : prix HT.
    ctrl.retirerLigne(0);
    await ParametreRepository(db)
        .ecrirePlusieurs({Fiscalite.cleRegime: RegimesFiscaux.reel, Fiscalite.cleTvaCaisse: '0'});
    c.invalidate(parametresVenteProvider);
    await c.read(parametresVenteProvider.future);
    await ctrl.ajouter(cafe);
    expect(c.read(posControllerProvider).panier.lignes.single.prixUnitaire, 100);
  });

  test('scan : code-barres produit, colis, code produit, QR, inconnu', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    expect(await ctrl.scanner('6130000000015'), isTrue);
    expect(await ctrl.scanner('6130000000022'), isTrue);
    expect(await ctrl.scanner('CDZ:PRD:${lait.code}'), isTrue);
    expect(await ctrl.scanner(lait.code.toLowerCase()), isTrue);
    expect(await ctrl.scanner('0000000000000'), isFalse);
    final p = c.read(posControllerProvider).panier;
    expect(p.lignes.length, 2); // lait ×3 (agrégés) + colis
    expect(p.lignes.first.quantite, 3);
    expect(p.lignes.last.colis!.code, 'COL0001');
    expect(p.totalNet, 300 + 550);
    expect(c.read(posControllerProvider).unitesReservees(lait.code), 9);
  });

  test('encaissement via le contrôleur : session requise, puis vente et panier vidé', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouter(lait, quantite: 2);
    ctrl.ajouterPaiement('Espèces', 500);
    await expectLater(
      ctrl.encaisser(),
      throwsA(isA<PosException>().having((e) => e.erreur, 'e', ErreurPos.sessionRequise)),
    );
    await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 1000);
    final v = await ctrl.encaisser();
    expect(v.code, 'VTE0001');
    expect(v.monnaie, 300);
    expect(await c.read(sessionCaisseServiceProvider).especesAttendues('SES0001'), 1200);
    expect(c.read(posControllerProvider).panier.estVide, isTrue);
    expect(c.read(posControllerProvider).derniereVente?.code, 'VTE0001');
    final s = await ctrl.fermerSession(montantCompte: 1200);
    expect(s.ecart, 0);
    expect(c.read(posControllerProvider).session, isNull);
  });

  test('remise du référentiel : pourcentage, montant recalculé sur le sous-total, aucune', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouter(lait, quantite: 2);
    ctrl.appliquerRemise(const Remise(code: 'REM0001', designation: '10 %', type: 'Pourcentage', valeur: 10));
    expect(c.read(posControllerProvider).panier.totalNet, 180);
    ctrl.appliquerRemise(const Remise(code: 'REM0002', designation: '50 DA', type: 'Montant', valeur: 50));
    expect(c.read(posControllerProvider).panier.totalNet, 150);
    await ctrl.ajouter(lait);
    expect(c.read(posControllerProvider).panier.totalNet, 250);
    expect(c.read(posControllerProvider).panier.remiseCode, 'REM0002');
    ctrl.appliquerRemise(null);
    expect(c.read(posControllerProvider).panier.totalNet, 300);
    // Remise conditionnelle : active seulement à partir du seuil de sous-total.
    ctrl.appliquerRemise(
      const Remise(code: 'REM0003', designation: '-10 % dès 400', type: 'Pourcentage', valeur: 10, seuil: 400),
    );
    expect(c.read(posControllerProvider).panier.totalNet, 300);
    await ctrl.ajouter(lait);
    expect(c.read(posControllerProvider).panier.totalNet, 360);
  });

  test('changement de colis : ligne remplacée, restaurée si le stock manque', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouter(lait, quantite: 2);
    final colis = (await c.read(catalogueRepositoryProvider).colis()).first;
    await ctrl.remplacerLigne(0, lait, colis: colis);
    var p = c.read(posControllerProvider).panier;
    expect(p.lignes.single.colis?.code, colis.code);
    expect(p.totalNet, 550);
    await expectLater(
      ctrl.remplacerLigne(0, lait, colis: colis, quantite: 2),
      throwsA(isA<PosException>().having((e) => e.erreur, 'e', ErreurPos.stockInsuffisant)),
    );
    p = c.read(posControllerProvider).panier;
    expect(p.lignes.single.quantite, 1);
  });

  test('encaisser depuis le dialog : paiement unique dans le mode du panier, crédit client', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 0);
    await ctrl.ajouter(lait, quantite: 2);
    ctrl.choisirModePaiement('Carte');
    final v = await ctrl.encaisser(montantPaye: 500);
    expect(v.verse, 200);
    expect(v.monnaie, 0);
    final p = c.read(posControllerProvider).panier;
    expect(p.estVide, isTrue);
    expect(p.modePaiement, 'Espèces');
    expect(p.clientCode, 'CLN0000');
    await ctrl.ajouter(lait);
    await expectLater(
      ctrl.encaisser(montantPaye: 0, creditAutorise: true),
      throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.paiementInsuffisant)),
    );
  });

  test(
    'pack éclaté : une ligne par produit, tout ou rien, lignes liées, distinct du produit seul, vente et annulation',
    () async {
      final db = c.read(appDatabaseProvider).db;
      final ctrl = c.read(posControllerProvider.notifier);
      final pack = await CatalogueService(db, utilisateurCode: 'USR0000').creerPack(
        Pack(
          code: '',
          designation: 'Petit-déj',
          prixVente: 120,
          lignes: [
            PackLigne(produitCode: lait.code, quantite: 1),
            PackLigne(produitCode: eau.code, quantite: 2),
          ],
        ),
      );
      // Eau sans stock : le pack entier est refusé, aucune ligne ajoutée.
      await expectLater(
        ctrl.ajouterPack(pack),
        throwsA(isA<PosException>().having((e) => e.erreur, 'e', ErreurPos.stockInsuffisant)),
      );
      expect(c.read(posControllerProvider).panier.estVide, isTrue);
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: eau.code, magasinCode: 'MAG0000', quantite: 5);
      await ctrl.ajouter(lait);
      await ctrl.ajouterPack(pack, quantite: 2);
      var p = c.read(posControllerProvider).panier;
      expect(p.lignes.length, 3);
      final lPack = p.lignes[1];
      expect(
        (lPack.produit.code, lPack.pack?.code, lPack.quantite, lPack.prixUnitaire),
        (lait.code, pack.code, 2.0, 75.0),
      );
      expect((p.lignes[2].produit.code, p.lignes[2].quantite, p.lignes[2].prixUnitaire), (eau.code, 4.0, 22.5));
      expect(p.totalNet, 100 + 240);
      // Les lignes d'un pack vont ensemble : la quantité suit un nombre entier de packs sur toutes ses lignes.
      await expectLater(
        ctrl.modifierQuantite(1, 3),
        throwsA(isA<PosException>()),
        reason: '3 packs : 6 eaux, 5 en stock',
      );
      await ctrl.modifierQuantite(2, 3); // baisse : 1,5 pack ⇒ 1 pack
      expect(c.read(posControllerProvider).panier.lignes.map((l) => l.quantite), [1, 1, 2]);
      await ctrl.modifierQuantite(2, 3); // hausse : 1,5 pack ⇒ 2 packs
      await ctrl.ajouter(lait);
      p = c.read(posControllerProvider).panier;
      expect(p.lignes.map((l) => l.quantite), [2, 2, 4]);
      // Un 3ᵉ pack manque d'eau (4 + 2 > 5) : refusé en bloc.
      await expectLater(ctrl.ajouterPack(pack), throwsA(isA<PosException>()));
      expect(c.read(posControllerProvider).panier.lignes.map((l) => l.quantite), [2, 2, 4]);
      // Supprimer un produit du pack retire tout le pack ; le produit seul reste.
      ctrl.retirerLigne(2);
      expect(c.read(posControllerProvider).panier.lignes.map((l) => (l.quantite, l.pack)), [(2.0, null)]);
      await ctrl.ajouterPack(pack, quantite: 2);

      await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 0);
      final v = await ctrl.encaisser(montantPaye: 10000);
      expect(v.lignes.map((l) => (l.produitCode, l.packCode, l.composantPack, l.quantite)), [
        (lait.code, null, false, 2.0),
        (lait.code, pack.code, true, 2.0),
        (eau.code, pack.code, true, 4.0),
      ]);
      final stock = StockRepository(db);
      expect((await stock.niveau(lait.code, 'MAG0000')).quantite, 6);
      expect((await stock.niveau(eau.code, 'MAG0000')).quantite, 1);
      await c.read(venteServiceProvider).annuler(v.code, motif: 'Test');
      expect((await stock.niveau(lait.code, 'MAG0000')).quantite, 10);
      expect((await stock.niveau(eau.code, 'MAG0000')).quantite, 5);
    },
  );

  test('vente au montant : une seule ligne cumulée, sans stock, modifiable', () async {
    final db = c.read(appDatabaseProvider).db;
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ajouterMontant(200);
    await ctrl.ajouter(lait);
    await ctrl.ajouterMontant(500);
    final p = c.read(posControllerProvider).panier;
    expect(p.lignes.length, 2);
    expect((p.lignes.first.estMontant, p.lignes.first.quantite, p.lignes.first.total), (true, 1.0, 700.0));
    expect(p.totalNet, 800);
    expect(p.pieces, 1);
    ctrl.modifierMontant(0, 650);
    expect(c.read(posControllerProvider).panier.totalNet, 750);
    await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 0);
    final v = await ctrl.encaisser(montantPaye: 750);
    expect(v.lignes.first.produitCode, 'PRD0000');
    expect(v.lignes.first.total, 650);
    final mouvements = await db.query('mouvement_stock', where: 'produit_code = ?', whereArgs: ['PRD0000']);
    expect(mouvements, isEmpty);
    // Le produit système reste hors du catalogue.
    expect((await c.read(catalogueRepositoryProvider).produits()).map((x) => x.code), isNot(contains('PRD0000')));
    await ctrl.ajouterMontant(300);
    ctrl.modifierMontant(0, 0);
    expect(c.read(posControllerProvider).panier.estVide, isTrue);
  });

  test('calculatrice : évaluation', () {
    expect(DsCalculator.evaluer('2+3*4'), 14);
    expect(DsCalculator.evaluer('10/4'), 2.5);
    expect(DsCalculator.evaluer('-5+2'), -3);
    expect(DsCalculator.evaluer('7/0'), isNull);
    expect(DsCalculator.evaluer('2+'), isNull);
    expect(DsCalculator.evaluer('1 250,5 × 2'), 2501);
  });
}
