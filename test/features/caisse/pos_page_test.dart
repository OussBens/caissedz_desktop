import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/parametres_paiement.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(find.textContaining('Fermée'), findsOneWidget);
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
      expect(v.typePanier, 'Ticket');
      expect(v.hash.length, 64);
      expect(find.textContaining('Ouverte'), findsOneWidget);
      expect(find.text('Panier vide'), findsOneWidget);
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
      await clic(tester, find.descendant(of: dialog, matching: find.text('Réinitialiser')));
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
      expect(find.textContaining('Produit scanné'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      await tester.enterText(champ, '9999999999999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Produit introuvable'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
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
        'admin',
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

    testWidgets('arabe : écran caisse en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/caisse', locale: const Locale('ar'));
      expect(find.text('تحصيل'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('تحصيل'))), TextDirection.rtl);
    });
  });
}
