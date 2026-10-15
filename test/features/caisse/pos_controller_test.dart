import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
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
        licenceServiceProvider.overrideWithValue(licenceServiceTest(base)),
        authServiceProvider.overrideWithValue(authServiceTest(base)),
        configurationServiceProvider.overrideWithValue(configurationServiceTest(base)),
      ],
    );
    addTearDown(c.dispose);
    await c.read(licenceProvider.notifier).activerDemo();
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

  test('encaisser depuis le dialog : paiement unique dans le mode du panier, BL / SC, crédit client', () async {
    final ctrl = c.read(posControllerProvider.notifier);
    await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 0);
    await ctrl.ajouter(lait, quantite: 2);
    ctrl.choisirModePaiement('Carte');
    final v = await ctrl.encaisser(montantPaye: 500, typePanier: 'BL_SC');
    expect(v.verse, 200);
    expect(v.monnaie, 0);
    expect(v.typePanier, 'BL_SC');
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

  test('calculatrice : évaluation', () {
    expect(DsCalculator.evaluer('2+3*4'), 14);
    expect(DsCalculator.evaluer('10/4'), 2.5);
    expect(DsCalculator.evaluer('-5+2'), -3);
    expect(DsCalculator.evaluer('7/0'), isNull);
    expect(DsCalculator.evaluer('2+'), isNull);
    expect(DsCalculator.evaluer('1 250,5 × 2'), 2501);
  });
}
