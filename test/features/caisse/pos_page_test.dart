import 'dart:convert';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/favoris_caisse_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/parametres_paiement.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/raccourcis_caisse.dart';
import 'package:caissedz_desktop/features/caisse/pos_controller.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';

Future<void> _donnees(ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  final cat = CatalogueService(db, utilisateurCode: 'USR0000');
  final lait = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Lait 1 L',
      codeBarres: '6130000000015',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
      tvaPct: 0, // exonéré : prix TTC = prix HT
    ),
  );
  await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Eau 1,5 L',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 20,
      prixVente: 30,
      tvaPct: 0, // exonéré : prix TTC = prix HT
    ),
  );
  await cat.creerColis(Colis(code: '', produitCode: lait.code, designation: 'Pack 6', quantite: 6, prixVente: 550));
  await StockService(
    db,
    utilisateurCode: 'USR0000',
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.read(stockVersionProvider.notifier).incrementer();
}

Future<void> _touche(WidgetTester tester, LogicalKeyboardKey k) async {
  await tester.sendKeyEvent(k);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
}

String _total(WidgetTester tester) {
  final textes = tester
      .widgetList<Text>(find.descendant(of: find.byKey(const ValueKey('pos_total')), matching: find.byType(Text)))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '');
  return textes.join(' | ');
}

void main() {
  group('Caisse (DS v2.2)', () {
    testWidgets('produit → quantité et colis (ajout auto), caisse fermée → ouverture, encaisser le ticket', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      // Caisse fermée : la bande ne montre que la caisse et « Ouvrir ».
      expect(
        find.descendant(of: find.byKey(const ValueKey('caisse_session')), matching: find.text('Ouvrir')),
        findsOneWidget,
      );
      expect(find.text('Panier vide'), findsOneWidget);

      // Clic sur la tuile : le dialog « Quantité et colis » ajoute 1 unité au bout de 3 s.
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Quantité et colis'), findsOneWidget);
      expect(find.textContaining('Ajout automatique'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Quantité et colis'), findsNothing);
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      expect(_total(tester), contains('100,00'));
      // Le stock de la tuile tient compte du panier dès l'ajout (avant l'encaissement) : 10 − 1.
      expect(
        find.descendant(of: find.byKey(const ValueKey('tuile_PRD0001')), matching: find.text('9 en stock')),
        findsOneWidget,
      );

      // Clic sur le colis de la ligne : passage au pack de 6 (modification, sans ajout automatique).
      await clic(tester, find.descendant(of: find.byKey(const ValueKey('ligne_0')), matching: find.text('À l\'unité')));
      expect(find.text('Modifier la quantité et le colis'), findsOneWidget);
      await clic(tester, find.textContaining('Pack 6 (6 pièces)'));
      await clic(tester, find.byKey(const ValueKey('selection_valider')));
      expect(_total(tester), contains('550,00'));

      // Encaisser sans session : caisse fermée → ouverture → encaissement.
      await clic(tester, find.byKey(const ValueKey('caisse_encaisser')));
      expect(find.text('Aucune session ouverte'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('caisse_fermee_ouvrir')));
      await tester.enterText(find.byKey(const ValueKey('ouverture_fond')), '1000');
      await clic(tester, find.byKey(const ValueKey('ouverture_valider')));
      expect(find.text('Encaisser le ticket'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('encaisser_valider')));
      // Sans imprimante thermique, le choix d'impression s'ouvre.
      expect(find.text('Ticket 58 mm'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await tester.pump(const Duration(seconds: 5));
      final v = (await VenteRepository(c.read(appDatabaseProvider).db).vente('VTE0001'))!;
      expect(v.totalNet, 550);
      expect(v.verse, 550);
      expect(v.hash.length, 64);
      // Caisse ouverte : plus de bouton « Ouvrir » dans la bande.
      expect(
        find.descendant(of: find.byKey(const ValueKey('caisse_session')), matching: find.text('Ouvrir')),
        findsNothing,
      );
      expect(find.text('Panier vide'), findsOneWidget);
    });

    testWidgets('ventes du jour → Éditer : la vente revient au panier, produit ajouté, ticket remplacé', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      final db = c.read(appDatabaseProvider).db;
      final ctrl = c.read(posControllerProvider.notifier);
      await ctrl.ouvrirSession(caisseCode: 'CIS0000', fondInitial: 0);
      final lait = (await c.read(produitsPosProvider.future)).firstWhere((p) => p.designation == 'Lait 1 L');
      await ctrl.ajouter(lait);
      await ctrl.encaisser(montantPaye: 100);
      await tester.pumpAndSettle();
      // Vente avec TVA : désactivée au départ.
      expect(tester.widget<DsSwitch>(find.byType(DsSwitch)).valeur, isFalse);

      await clic(tester, find.text('Ventes du jour'));
      await clic(tester, find.byKey(const ValueKey('vdj_editer_VTE0001')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('vdj_editer_VTE0001')), findsNothing, reason: 'dialog fermé');
      expect(find.byKey(const ValueKey('panier_modification')), findsOneWidget);
      expect(find.textContaining('VTE0001'), findsWidgets);
      // La ligne reprise est verrouillée : pas de bouton pour la retirer.
      expect(
        find.descendant(of: find.byKey(const ValueKey('ligne_0')), matching: find.byTooltip('Retirer')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_1')), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('caisse_encaisser')));
      expect(find.text('Déjà payé'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('encaisser_valider')));
      await clic(tester, find.text('Fermer').last);
      await tester.pump(const Duration(seconds: 5));
      final repo = VenteRepository(db);
      expect((await repo.vente('VTE0001'))!.statut, 'Annulée');
      final v2 = (await repo.vente('VTE0002'))!;
      expect([v2.totalNet, v2.verse, v2.lignes.length], [200, 200, 2]);
      expect(find.byKey(const ValueKey('panier_modification')), findsNothing);
    });

    testWidgets('quantité au clavier dans le dialog, raccourcis actifs hors du champ de scan', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pump(const Duration(milliseconds: 300));
      // La 1ʳᵉ frappe remplace la quantité proposée (1), la suivante complète ; retour arrière efface.
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad3);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('selection_quantite'))).data, '23');
      expect(find.byType(DsProgressBar), findsNothing, reason: 'la frappe annule l\'ajout auto');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('selection_quantite'))).data, '2');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      expect(_total(tester), contains('200,00'));
      // Focus hors du champ de scan (clic ailleurs) : les touches F restent actives.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await _touche(tester, LogicalKeyboardKey.f1);
      expect(find.text('Raccourcis clavier'), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      await _touche(tester, LogicalKeyboardKey.f10);
      expect(find.byKey(const ValueKey('ligne_0')), findsNothing);
    });

    testWidgets('recherche produit (F3) : filtres catégorie, fourchettes de stock et de prix', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      await _touche(tester, LogicalKeyboardKey.f3);
      final dialog = find.byType(DsPickerDialog<Produit>);
      Finder dans(String t) => find.descendant(of: dialog, matching: find.text(t));
      expect(dans('Lait 1 L'), findsOneWidget);
      expect(dans('Eau 1,5 L'), findsOneWidget);
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('recherche_prix_min')), matching: find.byType(TextField)),
        '50',
      );
      await tester.pump();
      expect(dans('Eau 1,5 L'), findsNothing);
      expect(dans('Lait 1 L'), findsOneWidget);
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('recherche_qte_max')), matching: find.byType(TextField)),
        '5',
      );
      await tester.pump();
      expect(dans('Lait 1 L'), findsNothing);
      await clic(tester, find.byKey(const ValueKey('recherche_reinitialiser')));
      expect(dans('Eau 1,5 L'), findsOneWidget);
      expect(dans('Lait 1 L'), findsOneWidget);
    });

    testWidgets('scan : code-barres → dialog, code inconnu → produit introuvable', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      final champ = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).first;
      await tester.enterText(champ, '6130000000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('selection_quantite')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      expect(_total(tester), contains('100,00'));
      // Produit déjà au panier : le scan augmente sa quantité, sans dialog.
      await tester.enterText(champ, '6130000000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_1')), findsNothing);
      expect(_total(tester), contains('200,00'));
      // Dialog ouvert : une rafale du lecteur (chiffres rapides + Entrée) ajoute 1 au lieu d'être saisie.
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pump(const Duration(milliseconds: 300));
      for (final ch in '6130000000015'.split('')) {
        final touche = LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + int.parse(ch));
        await tester.sendKeyDownEvent(touche, character: ch);
        await tester.sendKeyUpEvent(touche);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('selection_quantite'))).data, '2');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_1')), findsNothing);
      expect(_total(tester), contains('400,00'));
      await tester.enterText(champ, '9999999999999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Produit introuvable'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
    });

    testWidgets('code inconnu trouvé dans le catalogue BENS : le formulaire s’ouvre rempli', (tester) async {
      final client = MockClient((req) async {
        if (req.url.path == '/products/barcode/6130005000017') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'nom': 'Rouiba Orange 1L', 'nom_ar': 'رويبة برتقال', 'brand': 'Rouiba'},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });
      final c = await pumpApp(
        tester,
        routeInitiale: '/caisse',
        taille: const Size(1600, 1000),
        overrides: [httpClientProvider.overrideWithValue(client)],
      );
      await _donnees(c);
      await tester.pumpAndSettle();
      final champ = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).first;
      await tester.enterText(champ, '6130005000017');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Trouvé dans le catalogue BENS'), findsOneWidget);
      expect(find.byKey(const ValueKey('introuvable_fiche_bens')), findsOneWidget);
      expect(find.text('رويبة برتقال'), findsOneWidget);
      expect(find.text('Rouiba Orange'), findsOneWidget, reason: 'nom sans la quantité');
      expect(find.text('Contenance : 1 L'), findsOneWidget, reason: 'quantité à part');
      await clic(tester, find.text('Créer depuis le catalogue'));
      String texte(String cle) => tester
          .widget<TextField>(find.descendant(of: find.byKey(ValueKey(cle)), matching: find.byType(TextField)).first)
          .controller!
          .text;
      expect(
        [texte('produit_designation'), texte('produit_designation_ar'), texte('produit_code_barres')],
        ['Rouiba Orange', 'رويبة برتقال', '6130005000017'],
      );

      // Absent du catalogue : le titre habituel, le formulaire avec le seul code-barres.
      await clic(tester, find.text('Annuler').last);
      expect(find.byKey(const ValueKey('produit_designation')), findsNothing);
      await tester.enterText(champ, '9999999999994');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Produit introuvable'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('introuvable_creer')));
      expect([texte('produit_designation'), texte('produit_code_barres')], ['', '9999999999994']);
    });

    testWidgets('produit du catalogue à confirmer : « c’est bien lui » (+1) ou « ce n’est pas ça » (−1)', (
      tester,
    ) async {
      final votes = <Object?>[];
      final client = MockClient((req) async {
        if (req.url.path.startsWith('/products/barcode/')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'nom': 'Couscous Mama 1kg',
                'nom_ar': 'كسكس ماما',
                'a_confirmer': true,
                'confirmation': 3,
                'confirmation_seuil': 5,
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (req.url.path == '/tendance') {
          votes.addAll((jsonDecode(req.body) as Map)['confirmations'] as List);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'votes': 1},
            }),
            200,
          );
        }
        return http.Response('{"success":false}', 404);
      });
      final c = await pumpApp(
        tester,
        routeInitiale: '/caisse',
        taille: const Size(1600, 1000),
        overrides: [httpClientProvider.overrideWithValue(client)],
      );
      await _donnees(c);
      await tester.pumpAndSettle();
      final champ = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).first;
      String texte(String cle) => tester
          .widget<TextField>(find.descendant(of: find.byKey(ValueKey(cle)), matching: find.byType(TextField)).first)
          .controller!
          .text;

      await tester.enterText(champ, '6130007000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Produit proposé par une boutique'), findsOneWidget);
      expect(find.textContaining('(3 sur 5)'), findsOneWidget);
      expect(find.byKey(const ValueKey('introuvable_creer')), findsNothing, reason: 'oui ou non à la place');
      await clic(tester, find.byKey(const ValueKey('introuvable_confirmer')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(votes, [
        {'code_barres': '6130007000015', 'vote': 1},
      ]);
      expect(texte('produit_designation'), 'Couscous Mama', reason: 'formulaire rempli, sans la quantité');
      await clic(tester, find.text('Annuler').last);

      await tester.enterText(champ, '6130007000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await clic(tester, find.byKey(const ValueKey('introuvable_refuser')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(votes.last, {'code_barres': '6130007000015', 'vote': -1});
      expect(
        [texte('produit_designation'), texte('produit_code_barres')],
        ['', '6130007000015'],
        reason: 'formulaire vide',
      );
    });

    testWidgets('ventes en parallèle, stock insuffisant, raccourcis F1 / F9 / F10 / F11', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      // Lait : 11 unités demandées pour 10 en stock → ajout bloqué dans le dialog.
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.descendant(of: find.byType(DsNumpad), matching: find.text('1')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const ValueKey('selection_quantite'))).data, '11');
      expect(find.textContaining('Stock insuffisant'), findsOneWidget);
      await clic(tester, find.text('Annuler').last);
      expect(find.byKey(const ValueKey('ligne_0')), findsNothing);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Vente 2'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      await _touche(tester, LogicalKeyboardKey.f10);
      expect(find.byKey(const ValueKey('ligne_0')), findsNothing);

      await _touche(tester, LogicalKeyboardKey.f11);
      expect(find.byType(DsProductTile), findsNothing);
      // Produits masqués : panneau d'encaissement à droite (client, remise, total, encaissement).
      final panneau = find.byKey(const ValueKey('panier_encaissement'));
      for (final cle in ['panier_client', 'panier_remise', 'caisse_encaisser']) {
        expect(
          find.descendant(of: panneau, matching: find.byKey(ValueKey(cle))),
          findsOneWidget,
          reason: cle,
        );
      }
      await clic(tester, find.byKey(const ValueKey('caisse_basculer_produits')));
      expect(find.byType(DsProductTile), findsWidgets);

      await _touche(tester, LogicalKeyboardKey.f1);
      expect(find.text('Raccourcis clavier'), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      await _touche(tester, LogicalKeyboardKey.f9);
      expect(find.text('Calculatrice'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets('quantité 0 : « Produit en rupture » au lieu de « Quantité et colis », rien n’est ajouté', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      // Eau : aucun stock, aucun autre magasin.
      await clic(tester, find.byKey(const ValueKey('tuile_PRD0002')));
      final rupture = find.byKey(const ValueKey('dialog_rupture'));
      expect(rupture, findsOneWidget);
      expect(find.descendant(of: rupture, matching: find.text('Produit en rupture')), findsOneWidget);
      expect(find.byKey(const ValueKey('rupture_quantite')), findsOneWidget);
      expect(find.byKey(const ValueKey('selection_valider')), findsNothing);
      expect(find.byKey(const ValueKey('rupture_transferer')), findsNothing, reason: 'aucun autre magasin n’en a');
      expect(find.byKey(const ValueKey('rupture_entree')), findsOneWidget);
      await clic(tester, find.descendant(of: rupture, matching: find.text('Fermer')));
      await tester.pump(const Duration(seconds: 4));
      expect(find.byKey(const ValueKey('dialog_rupture')), findsNothing);
      expect(find.text('Panier vide'), findsOneWidget);
    });

    testWidgets('admin : stock insuffisant ici mais disponible ailleurs → transfert proposé puis ajout', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      final db = c.read(appDatabaseProvider).db;
      final stock = StockService(db, utilisateurCode: 'USR0000');
      final depot = await stock.creerMagasin('Dépôt');
      // Eau : rien dans le magasin de la caisse, 20 au dépôt.
      await stock.entrerStock(produitCode: 'PRD0002', magasinCode: depot.code, quantite: 20);
      c.read(stockVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();

      // Rien ici : « Produit en rupture » (quantité 0) au lieu de « Quantité et colis », le dépôt est indiqué.
      await clic(tester, find.byKey(const ValueKey('tuile_PRD0002')));
      final rupture = find.byKey(const ValueKey('dialog_rupture'));
      expect(rupture, findsOneWidget);
      expect(find.descendant(of: rupture, matching: find.text('Disponible dans « Dépôt » : 20')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rupture_transferer')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.descendant(of: find.byType(DsNumpad), matching: find.text('3')));
      await tester.pumpAndSettle();
      // L'admin peut valider au-delà du stock : la caisse propose le transfert du manque.
      await clic(tester, find.byKey(const ValueKey('selection_valider')));
      expect(find.text('Stock insuffisant dans ce magasin'), findsOneWidget);
      // Schéma : Dépôt (stock 20) → 13 → magasin de la caisse (stock 0, manque 13).
      final schema = find.byKey(const ValueKey('schema_transfert'));
      expect(find.descendant(of: schema, matching: find.text('Dépôt')), findsOneWidget);
      expect(find.descendant(of: schema, matching: find.text('Stock : 20')), findsOneWidget);
      expect(find.descendant(of: schema, matching: find.text('Manque 13')), findsOneWidget);
      await clic(tester, find.text('Transférer et ajouter'));
      await tester.pump(const Duration(seconds: 5));
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);

      final repo = StockRepository(db);
      final transferts = await repo.transferts();
      expect(transferts, hasLength(1));
      expect(transferts.single.magasinSource, depot.code);
      expect(transferts.single.magasinDestination, 'MAG0000');
      // Quantité saisie : 1 puis « 3 » → 13, transférée en entier (rien dans le magasin de la caisse).
      expect(transferts.single.lignes.single.quantite, 13);
      expect((await repo.niveau('PRD0002', 'MAG0000')).quantite, 13);
      expect((await repo.niveau('PRD0002', depot.code)).quantite, 7);
    });

    testWidgets('Paramètres appliqués : moyens de paiement visibles, vente sous achat interdite', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      final repo = ParametreRepository(c.read(appDatabaseProvider).db);
      await repo.ecrirePlusieurs({
        ParametresPaiement.cleCarte: '0',
        ParametresPaiement.cleCheque: '1',
        ParametresVente.cleVenteSousAchat: ParametresVente.venteSousAchatInterdire,
      });
      c
        ..invalidate(parametresPaiementProvider)
        ..invalidate(parametresVenteProvider);
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('panier_mode')), findsNothing, reason: 'le mode se choisit à l\'encaissement');
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pumpAndSettle();
      await doubleClic(tester, find.byKey(const ValueKey('ligne_0')));
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('prix_valeur')), matching: find.byType(TextField)),
        '50',
      );
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('prix_mdp')), matching: find.byType(TextField)),
        motDePasseAdmin,
      );
      await clic(tester, find.byKey(const ValueKey('prix_enregistrer')));
      expect(find.text('Prix inférieur au prix d\'achat : interdit par les paramètres.'), findsOneWidget);
      await clic(tester, find.text('Annuler').last);

      // Dialog d'encaissement : seuls les moyens visibles, choix du chèque.
      await clic(tester, find.byKey(const ValueKey('caisse_encaisser')));
      await clic(tester, find.byKey(const ValueKey('caisse_fermee_ouvrir')));
      await tester.enterText(find.byKey(const ValueKey('ouverture_fond')), '0');
      await clic(tester, find.byKey(const ValueKey('ouverture_valider')));
      final modes = find.byKey(const ValueKey('encaisser_mode'));
      expect(find.descendant(of: modes, matching: find.text('Espèces')), findsOneWidget);
      expect(find.descendant(of: modes, matching: find.text('Chèque')), findsOneWidget);
      expect(find.descendant(of: modes, matching: find.text('Carte CIB')), findsNothing);
      expect(
        find.descendant(of: modes, matching: find.text('Points fidélité')),
        findsNothing,
        reason: 'fidélité off',
      );
      await clic(tester, find.descendant(of: modes, matching: find.text('Chèque')));
      await clic(tester, find.byKey(const ValueKey('encaisser_valider')));
      await clic(tester, find.text('Fermer').last);
      await tester.pump(const Duration(seconds: 5));
      final v = (await VenteRepository(c.read(appDatabaseProvider).db).vente('VTE0001'))!;
      expect(v.paiements.single.mode, 'Chèque');
    });

    testWidgets('montants rapides (une ligne cumulée) et pack éclaté en lignes « Pack »', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.byKey(const ValueKey('montant_200')));
      await clic(tester, find.byKey(const ValueKey('montant_500')));
      expect(find.byKey(const ValueKey('ligne_1')), findsNothing);
      expect(find.text('Vente au montant'), findsOneWidget);
      expect(_total(tester), contains('700'));
      await clic(tester, find.byKey(const ValueKey('montant_autre')));
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('montant_valeur')), matching: find.byType(TextField)),
        '150',
      );
      await clic(tester, find.byKey(const ValueKey('montant_valider')));
      expect(_total(tester), contains('850'));
      // Double-clic : nouveau montant de la ligne.
      await doubleClic(tester, find.byKey(const ValueKey('ligne_0')));
      expect(find.text('Modifier le montant'), findsOneWidget);
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('montant_valeur')), matching: find.byType(TextField)),
        '400',
      );
      await clic(tester, find.byKey(const ValueKey('montant_valider')));
      expect(_total(tester), contains('400'));
      await _touche(tester, LogicalKeyboardKey.f10);

      final db = c.read(appDatabaseProvider).db;
      await CatalogueService(db, utilisateurCode: 'USR0000').creerPack(
        const Pack(
          code: '',
          designation: 'Duo lait',
          prixVente: 180,
          lignes: [PackLigne(produitCode: 'PRD0001', quantite: 2)],
        ),
      );
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      await clic(tester, find.text('Packs'));
      await clic(tester, find.byKey(const ValueKey('tuile_PCK0001')));
      await clic(tester, find.byKey(const ValueKey('tuile_PCK0001')));
      // Une seule ligne produit (2 × 2 laits), colonne colis « Pack ».
      expect(find.byKey(const ValueKey('ligne_1')), findsNothing);
      final ligne = find.byKey(const ValueKey('ligne_0'));
      expect(find.descendant(of: ligne, matching: find.text('Pack')), findsOneWidget);
      expect(find.descendant(of: ligne, matching: find.text('Lait 1 L')), findsOneWidget);
      expect(find.descendant(of: ligne, matching: find.text('4')), findsWidgets);
      expect(_total(tester), contains('360'));
    });

    testWidgets('onglet Favoris : vide au départ, puis seulement les produits favoris', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Favoris'));
      expect(find.textContaining('Aucun favori'), findsOneWidget);

      await FavorisCaisseRepository(c.read(appDatabaseProvider).db).ajouter(['PRD0002']);
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tuile_PRD0002')), findsOneWidget);
      expect(find.byKey(const ValueKey('tuile_PRD0001')), findsNothing);
      await clic(tester, find.text('Produits'));
      expect(find.byKey(const ValueKey('tuile_PRD0001')), findsOneWidget);
    });

    testWidgets('produits par pages (24 par défaut), la recherche revient à la page 1', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      final cat = CatalogueService(c.read(appDatabaseProvider).db, utilisateurCode: 'USR0000');
      for (var i = 1; i <= 30; i++) {
        await cat.creerProduit(
          Produit(
            code: '',
            designation: 'Article $i',
            categorieCode: 'CATE0000',
            sousCategorieCode: 'SC0000',
            prixAchat: 10,
            prixVente: 20,
          ),
        );
      }
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      final pagination = find.byKey(const ValueKey('pos_pagination'));
      expect(find.descendant(of: pagination, matching: find.textContaining('1–24')), findsOneWidget);

      await clic(tester, find.descendant(of: pagination, matching: find.text('2')));
      expect(find.descendant(of: pagination, matching: find.textContaining('25–30')), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'Article');
      await tester.pumpAndSettle();
      expect(find.descendant(of: pagination, matching: find.textContaining('1–24')), findsOneWidget);
    });

    testWidgets('paramètres de la caisse : bouton à côté de la calculatrice (Avancé, Ultra)', (tester) async {
      await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      expect(find.byKey(const ValueKey('caisse_parametres')), findsOneWidget);
    });

    testWidgets('paramètres de la caisse : absents en Basic', (tester) async {
      await pumpApp(
        tester,
        etat: EtatApp.connecteeAdminBasic,
        routeInitiale: '/caisse',
        taille: const Size(1600, 1000),
      );
      expect(find.byKey(const ValueKey('caisse_parametres')), findsNothing);
    });

    testWidgets('arabe : écran caisse en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/caisse', locale: const Locale('ar'));
      expect(find.text('تحصيل'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('تحصيل'))), TextDirection.rtl);
    });

    testWidgets('tri des produits : prix croissant puis décroissant, en grille comme en liste', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      // PRD0001 = Lait (100 DA), PRD0002 = Eau (30 DA).
      bool avant(String a, String b) {
        final pa = tester.getTopLeft(find.byKey(ValueKey('tuile_$a')));
        final pb = tester.getTopLeft(find.byKey(ValueKey('tuile_$b')));
        return pa.dy < pb.dy || (pa.dy == pb.dy && pa.dx < pb.dx);
      }

      await tester.tap(find.byKey(const ValueKey('pos_tri')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tri : Vente HT').last);
      await tester.pumpAndSettle();
      expect(avant('PRD0002', 'PRD0001'), isTrue, reason: 'Eau (30) avant Lait (100)');
      await tester.tap(find.byKey(const ValueKey('pos_tri_sens')));
      await tester.pumpAndSettle();
      expect(avant('PRD0001', 'PRD0002'), isTrue, reason: 'décroissant');
      await tester.tap(find.byTooltip('Affichage liste'));
      await tester.pumpAndSettle();
      expect(avant('PRD0001', 'PRD0002'), isTrue, reason: 'la liste garde le tri');
    });

    testWidgets('panier au clavier : la dernière ligne reste sélectionnée, ↑ / ↓, + / − et Suppr après un scan', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      bool selectionnee(int i) => tester.widget<DsCartLine>(find.byKey(ValueKey('ligne_$i'))).selectionnee;
      double qte(int i) => tester.widget<DsCartLine>(find.byKey(ValueKey('ligne_$i'))).qte;

      // Scan : le produit arrive au panier, sa ligne est sélectionnée et le champ de scan garde le focus.
      final champ = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).first;
      await tester.enterText(champ, '6130000000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(selectionnee(0), isTrue);
      // Champ de scan vide : + agit sur la ligne (et n'est pas saisi dans le champ).
      await _touche(tester, LogicalKeyboardKey.numpadAdd);
      expect(qte(0), 2);
      expect(tester.widget<TextField>(champ).controller!.text, isEmpty);

      // Une 2ᵉ ligne (montant) : c'est elle qui est sélectionnée ; ↑ revient au produit.
      await tester.tap(find.byKey(const ValueKey('montant_200')));
      await tester.pumpAndSettle();
      expect(selectionnee(1), isTrue);
      expect(selectionnee(0), isFalse);
      await _touche(tester, LogicalKeyboardKey.arrowUp);
      expect(selectionnee(0), isTrue);
      await _touche(tester, LogicalKeyboardKey.numpadSubtract);
      expect(qte(0), 1);
      await _touche(tester, LogicalKeyboardKey.arrowDown);
      expect(selectionnee(1), isTrue);

      // Suppr retire la ligne sélectionnée ; la sélection passe à la ligne restante.
      await _touche(tester, LogicalKeyboardKey.delete);
      expect(find.byKey(const ValueKey('ligne_1')), findsNothing);
      expect(selectionnee(0), isTrue);
    });

    testWidgets('raccourcis personnalisés (Paramètres) : la nouvelle touche agit, l’ancienne plus, l’aide suit', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1600, 1000));
      await _donnees(c);
      final touches = RaccourcisCaisse.defaut
          .avec(ActionCaisse.vider, const ToucheRaccourci(LogicalKeyboardKey.f5))
          .avec(ActionCaisse.quantitePlus, const ToucheRaccourci(LogicalKeyboardKey.asterisk));
      await ParametreRepository(c.read(appDatabaseProvider).db).ecrirePlusieurs(touches.versCles());
      c.invalidate(raccourcisCaisseProvider);
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byKey(const ValueKey('caisse_encaisser')), matching: find.text('F4')), findsOne);

      final champ = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).first;
      await tester.enterText(champ, '6130000000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      double qte() => tester.widget<DsCartLine>(find.byKey(const ValueKey('ligne_0'))).qte;
      // * (pavé numérique) : quantité +1 ; + n'agit plus.
      await _touche(tester, LogicalKeyboardKey.numpadMultiply);
      expect(qte(), 2);
      await _touche(tester, LogicalKeyboardKey.numpadAdd);
      expect(qte(), 2);

      await _touche(tester, LogicalKeyboardKey.f10);
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget, reason: 'F10 n’est plus « Vider »');
      await _touche(tester, LogicalKeyboardKey.f1);
      final aide = find.ancestor(of: find.text('Vider le panier'), matching: find.byType(Row)).first;
      expect(find.descendant(of: aide, matching: find.text('F5')), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      await _touche(tester, LogicalKeyboardKey.f5);
      expect(find.byKey(const ValueKey('ligne_0')), findsNothing);
    });
  });
}
