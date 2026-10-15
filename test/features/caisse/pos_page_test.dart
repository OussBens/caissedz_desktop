import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
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

    testWidgets('arabe : écran caisse en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/caisse', locale: const Locale('ar'));
      expect(find.text('تحصيل'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('تحصيل'))), TextDirection.rtl);
    });
  });
}
