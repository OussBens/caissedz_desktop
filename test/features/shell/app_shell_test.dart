import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/domain/alertes_produits.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:caissedz_desktop/features/tableau_bord/alertes_produits_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      await clic(tester, find.byKey(const ValueKey('nav_categorie_2'))); // TIERS, fermé par défaut
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

    testWidgets('CaisseDZ Scan : l’icône du QR personnel suit la permission « Application mobile »', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('topbar_mobile')), findsOneWidget);
    });

    testWidgets('CaisseDZ Scan : un caissier sans la permission n’a pas l’icône', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier);
      expect(find.byKey(const ValueKey('topbar_mobile')), findsNothing);
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

    testWidgets('barre latérale : catégories fermées sauf celle du module actif, repliables', (tester) async {
      await pumpApp(tester);
      final barre = find.byType(DsSidebar);
      Finder dansBarre(String t) => find.descendant(of: barre, matching: find.text(t));
      // Caisse ouverte : GÉNÉRAL déplié, les autres groupes fermés.
      expect(dansBarre('Ventes'), findsOneWidget);
      expect(dansBarre('Produits'), findsNothing);
      await clic(tester, find.byKey(const ValueKey('nav_categorie_1'))); // STOCK
      expect(dansBarre('Produits'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('nav_categorie_0'))); // GÉNÉRAL
      expect(dansBarre('Ventes'), findsNothing);
      expect(dansBarre('Caisse'), findsOneWidget, reason: 'module actif');
      await clic(tester, find.byKey(const ValueKey('nav_categorie_0')));
      expect(dansBarre('Ventes'), findsOneWidget);
    });

    testWidgets('favoris : 5 maximum, persistés, affichés dans la barre supérieure', (tester) async {
      // Assez large pour les libellés (sinon : icônes seules, voir plus bas).
      final container = await pumpApp(tester, taille: const Size(2400, 800));
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

    /// Lait en sachet : en rupture (stock 0, sous le seuil), sans commande, fiche incomplète.
    Future<void> laitEnRupture(ProviderContainer container, WidgetTester tester) async {
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
      await container.read(alertesProduitsProvider.notifier).actualiser();
      await tester.pumpAndSettle();
    }

    testWidgets('alertes : la cloche compte et montre anciennes et nouvelles alertes, rupture une seule fois', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await laitEnRupture(container, tester);
      final produits = container.read(alertesProduitsProvider);
      expect(produits.de(TypeAlerteProduit.ruptureSansCommande).map((a) => a.designation), ['Lait en sachet']);
      final total = container.read(alertesProvider).total + produits.total;
      final cloche = find.byKey(const ValueKey('topbar_alertes'));
      expect(find.descendant(of: cloche, matching: find.text('$total')), findsOneWidget);

      await clic(tester, cloche);
      final dialog = find.byKey(const ValueKey('dialog_alertes'));
      expect(dialog, findsOneWidget);
      expect(find.text('Alertes du jour'), findsOneWidget);
      // Familles du jour (crédits, dettes…) et groupes des alertes produits ; plus de famille « Ruptures et seuils ».
      expect(find.byKey(const ValueKey('famille_clients')), findsOneWidget);
      expect(find.descendant(of: dialog, matching: find.text('Ruptures et seuils')), findsNothing);
      expect(find.descendant(of: dialog, matching: find.text('STOCK')), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('alerte_produit_ruptureSansCommande')));
      expect(find.descendant(of: dialog, matching: find.text('Lait en sachet')), findsOneWidget);
      // Le point rouge du tableau de bord s'éteint pour ce type : il a été consulté.
      expect(container.read(alertesProduitsNouvellesProvider), isNot(contains(TypeAlerteProduit.ruptureSansCommande)));
    });

    testWidgets('alerte produit dans le dialog : action au survol, « Voir l’analyse » ouvre la Situation', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await laitEnRupture(container, tester);
      await clic(tester, find.byKey(const ValueKey('topbar_alertes')));
      await clic(tester, find.byKey(const ValueKey('alerte_produit_ruptureSansCommande')));
      final souris = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(souris.removePointer);
      await souris.moveTo(tester.getCenter(find.text('Lait en sachet')));
      await tester.pumpAndSettle();
      expect(find.text('Commander'), findsOneWidget);

      await clic(tester, find.byKey(const ValueKey('alertes_voir_analyse')));
      expect(find.byKey(const ValueKey('dialog_alertes')), findsNothing);
      expect(routeCourante(container), '/situation');
    });

    testWidgets('menu des modules en Basic : pas de module hors formule ni « Réservé au palier »', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic);
      await clic(tester, find.byKey(const ValueKey('topbar_menu')));
      final menu = find.byKey(const ValueKey('menu_modules'));
      Finder dansMenu(String t) => find.descendant(of: menu, matching: find.textContaining(t));
      for (final absent in ['Besoins', 'Magasins', 'Devis', 'Commandes fournisseurs', 'Réservé au palier']) {
        expect(dansMenu(absent), findsNothing, reason: absent);
      }
      for (final present in ['Caisse', 'Produits', 'Stock', 'Gestion caisse']) {
        expect(dansMenu(present), findsWidgets, reason: present);
      }
    });

    // Police de test plus large que la vraie : la grande fenêtre est plus large qu'en vrai.
    for (final (largeur, libelles) in [(1400.0, false), (2800.0, true)]) {
      testWidgets(
        'favoris à ${largeur.toInt()} px : ${libelles ? 'icônes et libellés' : 'icônes seules, libellé au survol'}',
        (tester) async {
          final c = await pumpApp(tester, taille: Size(largeur, 760));
          for (final id in ['commandes_fournisseurs', 'entrees', 'gestion_caisse', 'tableau_bord', 'fournisseurs']) {
            await c.read(favorisProvider.notifier).basculer(id);
          }
          await tester.pumpAndSettle();
          final barre = find.byKey(const ValueKey('barre_favoris'));
          final entrees = find.descendant(of: barre, matching: find.text('Entrées / Achats'));
          expect(entrees, libelles ? findsOneWidget : findsNothing);
          if (!libelles) {
            final souris = await tester.createGesture(kind: PointerDeviceKind.mouse);
            addTearDown(souris.removePointer);
            await souris.moveTo(tester.getCenter(find.byKey(const ValueKey('favori_/entrees'))));
            await tester.pumpAndSettle();
            expect(entrees, findsOneWidget, reason: 'libellé au survol');
            expect(find.descendant(of: barre, matching: find.text('Fournisseurs')), findsNothing);
            await souris.moveTo(Offset.zero);
            await tester.pumpAndSettle();
            expect(entrees, findsNothing, reason: 'repli à la sortie');
            await tester.pump(const Duration(seconds: 5));
          }
        },
      );
    }

    testWidgets('essai : bandeau avec les jours restants', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeEssai);
      expect(find.byKey(const ValueKey('bandeau_essai')), findsOneWidget);
      expect(find.textContaining('Essai Avancé :'), findsOneWidget);
    });

    testWidgets('palier Basic : devis et multi-magasin verrouillés, avec leur palier', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: '/magasins');
      expect(find.text('Disponible avec le palier Max'), findsOneWidget);
    });

    testWidgets('essai terminé : lecture seule, la caisse en pause, la consultation ouverte', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.connecteeLectureSeule);
      expect(c.read(licenceProvider).lectureSeule, isTrue);
      expect(find.byKey(const ValueKey('bandeau_lecture_seule')), findsOneWidget);
      c.read(routerProvider).go('/caisse');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('gate_lecture_seule')), findsOneWidget);
      c.read(routerProvider).go('/produits');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('gate_lecture_seule')), findsNothing);
      await clic(tester, find.byKey(const ValueKey('bandeau_lecture_seule_formules')));
      expect(find.text('Choisissez votre formule'), findsOneWidget);
      expect(find.byKey(const ValueKey('offres_avis')), findsOneWidget);
    });

    testWidgets('Smart Scan : rappel avant l’expiration de scans non utilisés', (tester) async {
      final c = await pumpApp(tester);
      await LicenceRepository(c.read(appDatabaseProvider).db).ecrireScans({
        'remaining': 12,
        'expiringSoon': [
          {'kind': 'pack', 'remaining': 12, 'endsOn': '2026-11-05'},
        ],
      });
      await c.read(licenceProvider.notifier).charger();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bandeau_scans')), findsOneWidget);
      expect(find.text('12 Smart Scans expirent le 05/11/2026 : utilisez-les ou ajoutez un pack.'), findsOneWidget);
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
