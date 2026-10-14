import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/features/shell/modules_menu.dart';
import 'package:caissedz_desktop/features/shell/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Future<ProviderContainer> _pumpApp(WidgetTester tester, {Locale locale = const Locale('fr')}) =>
    pumpApp(tester, locale: locale);

void main() {
  group('AppShell', () {
    testWidgets('affiche les 4 groupes, la barre de titre et le témoin Internet (FR)', (tester) async {
      await _pumpApp(tester);
      expect(find.text('GÉNÉRAL'), findsOneWidget);
      expect(find.text('STOCK'), findsOneWidget);
      expect(find.text('TIERS'), findsOneWidget);
      expect(find.byType(TitleBar), findsOneWidget);
      expect(find.byKey(const ValueKey('internet_off')), findsOneWidget);
      expect(find.text('Tableau de bord'), findsNWidgets(3)); // sidebar + barre de titre + page
      await tester.scrollUntilVisible(find.text('GESTION'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('GESTION'), findsOneWidget);
    });

    testWidgets('navigue vers un module depuis la barre latérale', (tester) async {
      await _pumpApp(tester);
      await tester.scrollUntilVisible(find.text('Clients'), 200, scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(find.text('Clients'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clients'));
      await tester.pumpAndSettle();
      expect(find.text('Module « Clients » : disponible dans un prochain lot.'), findsOneWidget);
    });

    testWidgets('Ctrl+M ouvre le menu des modules, la recherche filtre', (tester) async {
      await _pumpApp(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byType(ModulesMenuDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zak');
      await tester.pumpAndSettle();
      final dansMenu = find.byType(ModulesMenuDialog);
      expect(find.descendant(of: dansMenu, matching: find.text('Zakat')), findsOneWidget);
      expect(find.descendant(of: dansMenu, matching: find.text('Clients')), findsNothing);
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('Aucun module ne correspond.'), findsOneWidget);
    });

    testWidgets('favoris : 7 maximum, persistés', (tester) async {
      final container = await _pumpApp(tester);
      final notifier = container.read(favorisProvider.notifier);
      final ids = ['caisse', 'ventes', 'retours', 'produits', 'stock', 'clients', 'fournisseurs'];
      for (final id in ids) {
        expect(await notifier.ajouter(id), isTrue);
      }
      expect(await notifier.ajouter('zakat'), isFalse);
      expect(container.read(favorisProvider).length, 7);
      await tester.pumpAndSettle();
      expect(find.text('Caisse'), findsNWidgets(2)); // favoris + groupe Général
      await container.read(favorisProvider.notifier).retirer('caisse');
      await tester.pumpAndSettle();
      expect(find.text('Caisse'), findsOneWidget);
      // Persistance : un nouveau chargement relit la base.
      final service = container.read(favorisServiceProvider);
      expect(await service.charger('USR0000'), ids.where((i) => i != 'caisse').toList());
    });

    testWidgets('alertes : badge sur la cloche et panneau', (tester) async {
      final container = await _pumpApp(tester);
      container
          .read(alertesProvider.notifier)
          .publier(const Alerte(id: 'a1', titre: 'Stock sous seuil', critique: true));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byTooltip('Alertes'));
      await tester.pumpAndSettle();
      expect(find.text('Stock sous seuil'), findsOneWidget);
    });

    testWidgets('arabe : RTL et police Cairo', (tester) async {
      await _pumpApp(tester, locale: const Locale('ar'));
      expect(find.text('عام'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(TitleBar))), TextDirection.rtl);
      final texte = tester.widget<Text>(find.text('عام'));
      expect(texte.style?.fontFamily, 'Cairo');
      // La barre latérale est à droite en RTL.
      final sidebarX = tester.getTopLeft(find.text('عام')).dx;
      expect(sidebarX > 1280 / 2, isTrue);
    });

    testWidgets('anglais', (tester) async {
      await _pumpApp(tester, locale: const Locale('en'));
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('Dashboard'), findsNWidgets(3));
    });
  });
}
