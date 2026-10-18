import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('AppShell', () {
    testWidgets('ouvre sur la Caisse, 4 groupes, barre supérieure et témoin Internet (FR)', (tester) async {
      final c = await pumpApp(tester);
      expect(routeCourante(c), '/caisse');
      expect(find.text('GÉNÉRAL'), findsOneWidget);
      expect(find.text('STOCK'), findsOneWidget);
      expect(find.text('TIERS'), findsOneWidget);
      expect(find.byType(DsTopBar), findsOneWidget);
      expect(find.byKey(const ValueKey('topbar_alertes')), findsOneWidget);
      expect(tester.widget<DsTemoinLigne>(find.byType(DsTemoinLigne)).enLigne, isFalse);
      expect(find.text('Administrateur'), findsWidgets);
      await tester.scrollUntilVisible(find.text('GESTION'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('GESTION'), findsOneWidget);
    });

    testWidgets('navigue vers un module depuis la barre latérale', (tester) async {
      await pumpApp(tester);
      await tester.scrollUntilVisible(find.text('Clients'), 200, scrollable: find.byType(Scrollable).first);
      await clic(tester, find.text('Clients'));
      expect(find.text('Nouveau client'), findsOneWidget);
    });

    testWidgets('caissier : la barre latérale ne montre que ses modules', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier);
      expect(find.text('Caisse'), findsWidgets);
      final barre = find.byType(DsSidebar);
      expect(find.descendant(of: barre, matching: find.text('Produits')), findsNothing);
      expect(find.descendant(of: barre, matching: find.text('Utilisateurs')), findsNothing);
      expect(find.descendant(of: barre, matching: find.text('STOCK')), findsNothing);
    });

    testWidgets('Ctrl+M ouvre le menu des modules, la recherche filtre', (tester) async {
      await pumpApp(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      final menu = find.byKey(const ValueKey('menu_modules'));
      expect(menu, findsOneWidget);
      expect(find.descendant(of: menu, matching: find.byType(DsModuleLauncher)), findsOneWidget);
      await tester.enterText(find.descendant(of: menu, matching: find.byType(TextField)), 'zak');
      await tester.pumpAndSettle();
      expect(find.descendant(of: menu, matching: find.text('Zakat')), findsOneWidget);
      expect(find.descendant(of: menu, matching: find.text('Clients')), findsNothing);
    });

    testWidgets('menu des modules : ouvrir un module ferme le menu', (tester) async {
      final c = await pumpApp(tester);
      await clic(tester, find.byKey(const ValueKey('topbar_menu')));
      final menu = find.byKey(const ValueKey('menu_modules'));
      await clic(tester, find.descendant(of: menu, matching: find.text('Zakat')));
      expect(menu, findsNothing);
      expect(routeCourante(c), '/zakat');
    });

    testWidgets('menu des modules : tuiles alignées, même largeur et même hauteur', (tester) async {
      await pumpApp(tester);
      await clic(tester, find.byKey(const ValueKey('topbar_menu')));
      final menu = find.byKey(const ValueKey('menu_modules'));
      Size tuile(String libelle) => tester.getSize(
        find
            .ancestor(
              of: find.descendant(of: menu, matching: find.text(libelle)),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final reference = tuile('Tableau de bord');
      for (final m in ['Caisse', 'Ventes', 'Retours', 'Produits', 'Entrées / Achats', 'Clients', 'Fournisseurs']) {
        expect(tuile(m), reference, reason: m);
      }
    });

    testWidgets('« + » des favoris : un clic sur un module l\'ajoute ou le retire sans l\'ouvrir', (tester) async {
      final c = await pumpApp(tester);
      await clic(tester, find.byKey(const ValueKey('favoris_ajouter')));
      final menu = find.byKey(const ValueKey('menu_modules'));
      expect(find.descendant(of: menu, matching: find.text('Choisir les favoris')), findsOneWidget);
      await clic(tester, find.descendant(of: menu, matching: find.text('Zakat')));
      expect(menu, findsOneWidget, reason: 'le menu reste ouvert');
      expect(routeCourante(c), '/caisse');
      expect(c.read(favorisProvider), contains('zakat'));
      await clic(tester, find.descendant(of: menu, matching: find.text('Zakat')));
      expect(c.read(favorisProvider), isNot(contains('zakat')));
      await clic(tester, find.descendant(of: menu, matching: find.text('Clients')));
      await clic(tester, find.byKey(const ValueKey('favoris_termine')));
      expect(menu, findsNothing);
      final barre = find.byKey(const ValueKey('barre_favoris'));
      expect(find.descendant(of: barre, matching: find.text('Clients')), findsOneWidget);
    });

    testWidgets('barre latérale : catégories repliables, le module actif reste visible', (tester) async {
      await pumpApp(tester);
      final barre = find.byType(DsSidebar);
      Finder dansBarre(String t) => find.descendant(of: barre, matching: find.text(t));
      expect(dansBarre('Ventes'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('nav_categorie_0'))); // GÉNÉRAL
      expect(dansBarre('Ventes'), findsNothing);
      expect(dansBarre('Caisse'), findsOneWidget, reason: 'module actif');
      await clic(tester, find.byKey(const ValueKey('nav_categorie_1'))); // STOCK
      expect(dansBarre('Produits'), findsNothing);
      await clic(tester, find.byKey(const ValueKey('nav_categorie_0')));
      expect(dansBarre('Ventes'), findsOneWidget);
    });

    testWidgets('favoris : 5 maximum, persistés, affichés dans la barre supérieure', (tester) async {
      final container = await pumpApp(tester);
      final notifier = container.read(favorisProvider.notifier);
      final ids = ['caisse', 'ventes', 'retours', 'produits', 'stock'];
      for (final id in ids) {
        expect(await notifier.ajouter(id), isTrue);
      }
      expect(await notifier.ajouter('zakat'), isFalse);
      expect(container.read(favorisProvider).length, 5);
      await tester.pumpAndSettle();
      final barre = find.byKey(const ValueKey('barre_favoris'));
      expect(find.descendant(of: barre, matching: find.text('Caisse')), findsOneWidget);
      await notifier.retirer('caisse');
      await tester.pumpAndSettle();
      expect(find.descendant(of: barre, matching: find.text('Caisse')), findsNothing);
      final service = container.read(favorisServiceProvider);
      expect(await service.charger('USR0000'), ids.where((i) => i != 'caisse').toList());
    });

    testWidgets('alertes : badge sur la cloche et dialogue des alertes du jour', (tester) async {
      final container = await pumpApp(tester);
      await CatalogueService(container.read(appDatabaseProvider).db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Lait en sachet',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      await container.read(alertesProvider.notifier).charger();
      await tester.pumpAndSettle();
      expect(container.read(alertesProvider).total, 1);
      final cloche = find.byKey(const ValueKey('topbar_alertes'));
      expect(find.descendant(of: cloche, matching: find.text('1')), findsOneWidget);
      await clic(tester, cloche);
      expect(find.byKey(const ValueKey('dialog_alertes')), findsOneWidget);
      expect(find.text('Alertes du jour'), findsOneWidget);
      expect(find.text('Lait en sachet'), findsOneWidget);
    });

    testWidgets('mode démo : bandeau affiché', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeDemo);
      expect(find.byKey(const ValueKey('bandeau_demo')), findsOneWidget);
    });

    testWidgets('arabe : RTL et police Cairo', (tester) async {
      await pumpApp(tester, locale: const Locale('ar'));
      expect(find.text('عام'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(AppShell))), TextDirection.rtl);
      final texte = tester.widget<Text>(find.text('عام'));
      expect(texte.style?.fontFamily, 'Cairo');
      final sidebarX = tester.getTopLeft(find.text('عام')).dx;
      expect(sidebarX > 1280 / 2, isTrue);
    });

    testWidgets('anglais', (tester) async {
      await pumpApp(tester, locale: const Locale('en'));
      expect(find.text('GENERAL'), findsOneWidget);
    });
  });
}
