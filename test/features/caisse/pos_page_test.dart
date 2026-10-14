import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
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
  await StockService(
    db,
    utilisateurCode: 'USR0000',
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
  c.read(catalogueVersionProvider.notifier).incrementer();
}

Future<void> _touche(WidgetTester tester, LogicalKeyboardKey k) async {
  await tester.sendKeyEvent(k);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  group('Caisse POS', () {
    testWidgets('session obligatoire, ouverture, scan, paiement espèces, encaissement, ticket', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucune session de caisse ouverte'), findsOneWidget);
      await clic(tester, find.text('Ouvrir la session'));
      await tester.enterText(find.byType(TextField).last, '1000');
      await clic(tester, find.text('Ouvrir la session').last);
      expect(find.textContaining('Session SES0001'), findsOneWidget);

      // Scan du code-barres
      await tester.enterText(find.byType(TextField).first, '6130000000015');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Lait 1 L'), findsWidgets);
      expect(find.byKey(const ValueKey('pos_total')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('pos_total'))).data, '100,00 DA');
      // Clic sur la tuile : quantité 2
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const ValueKey('pos_total'))).data, '200,00 DA');
      // Paiement : 500 via le pavé, puis encaisser
      for (final k in ['5', '0', '0']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(tester.widget<Text>(find.byKey(const ValueKey('montant_saisi'))).data, '500');
      await tester.tap(find.byKey(const ValueKey('numpad_ok')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Monnaie à rendre'), findsWidgets);
      await clic(tester, find.text('Encaisser (F12)'));
      expect(find.textContaining('Vente VTE0001 encaissée'), findsOneWidget);
      expect(find.text('Ticket 58 mm'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      final v = (await VenteRepository(c.read(appDatabaseProvider).db).vente('VTE0001'))!;
      expect(v.totalNet, 200);
      expect(v.verse, 500);
      expect(v.hash.length, 64);
    });

    testWidgets('raccourcis : F11 aide, F9 calculatrice, Ctrl+N nouveau panier, F10 vider', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      await _touche(tester, LogicalKeyboardKey.f11);
      expect(find.text('Raccourcis clavier'), findsOneWidget);
      expect(find.text('Encaisser'), findsWidgets);
      await clic(tester, find.text('Fermer'));
      await _touche(tester, LogicalKeyboardKey.f9);
      expect(find.text('Calculatrice'), findsOneWidget);
      final dialogue = find.byType(DsDialog);
      for (final k in ['7', '×', '3']) {
        await tester.tap(find.descendant(of: dialogue, matching: find.text(k)));
        await tester.pump();
      }
      expect(tester.widget<Text>(find.byKey(const ValueKey('calc_resultat'))).data, '21.00');
      await clic(tester, find.text('Utiliser comme montant'));
      expect(tester.widget<Text>(find.byKey(const ValueKey('montant_saisi'))).data, '21.00');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Panier 2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0001')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ligne_0')), findsOneWidget);
      await _touche(tester, LogicalKeyboardKey.f10);
      expect(find.byKey(const ValueKey('ligne_0')), findsNothing);
    });

    testWidgets('stock insuffisant (réservation) signalé', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/caisse', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tuile_PRD0002')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Stock insuffisant'), findsOneWidget);
    });

    testWidgets('arabe : écran caisse en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/caisse', locale: const Locale('ar'));
      expect(find.text('تحصيل (F12)'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('تحصيل (F12)'))), TextDirection.rtl);
    });
  });
}
