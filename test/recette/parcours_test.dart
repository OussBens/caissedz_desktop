import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/domain/modules.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helper.dart';

/// Recette (lot 9) : parcours de tous les modules FR / AR (RTL) / EN, clair / sombre, Basic / Avancé,
/// rôles Admin / Caissier / Magasinier. Chaque module est monté sur une base neuve ; aucune exception tolérée.
void main() {
  final modules = [...Modules.tous, ...Modules.rattachees];
  const accesRefuse = ValueKey('acces_refuse');
  const taille = Size(1400, 900);

  group('Recette — parcours de tous les modules (admin, licence Avancé)', () {
    for (final (locale, rtl) in [
      (const Locale('fr'), false),
      (const Locale('ar'), true),
      (const Locale('en'), false),
    ]) {
      testWidgets('${locale.languageCode} : ${modules.length} modules sans erreur', (tester) async {
        for (final m in modules) {
          await pumpApp(tester, locale: locale, routeInitiale: m.route, taille: taille);
          expect(tester.takeException(), isNull, reason: m.id);
          expect(find.byKey(accesRefuse), findsNothing, reason: m.id);
          expect(find.byType(AppShell), findsOneWidget, reason: m.id);
          expect(Directionality.of(tester.element(find.byType(AppShell))), rtl ? TextDirection.rtl : TextDirection.ltr);
          // Caisse plein écran (sans en-tête de page).
          if (m.id != 'caisse') expect(find.byType(DsPage), findsOneWidget, reason: m.id);
        }
      });
    }
  });

  group('Recette — thème', () {
    testWidgets('sombre puis clair sur plusieurs modules', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/tableau-de-bord', taille: taille);
      await c.read(themeModeProvider.notifier).changer(ThemeMode.dark);
      await tester.pumpAndSettle();
      for (final route in ['/produits', '/caisse', '/clotures', '/parametres', '/situation']) {
        c.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        final ctx = tester.element(find.byType(AppShell));
        expect(Theme.of(ctx).brightness, Brightness.dark, reason: route);
        expect(ctx.ds.colors.surfaceApp.computeLuminance() < 0.2, isTrue, reason: route);
      }
      await c.read(themeModeProvider.notifier).changer(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(Theme.of(tester.element(find.byType(AppShell))).brightness, Brightness.light);
    });
  });

  group('Recette — licence', () {
    testWidgets('Basic : modules Avancé et Max verrouillés (LicenceGate), modules Basic ouverts', (tester) async {
      for (final m in modules) {
        await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: m.route, taille: taille);
        expect(tester.takeException(), isNull, reason: m.id);
        expect(
          find.text('Disponible avec le palier Avancé'),
          m.niveauRequis == NiveauLicence.avance ? findsOneWidget : findsNothing,
          reason: m.id,
        );
        expect(
          find.text('Disponible avec le palier Max'),
          m.niveauRequis == NiveauLicence.max ? findsOneWidget : findsNothing,
          reason: m.id,
        );
      }
    });
  });

  group('Recette — rôles', () {
    for (final (etat, role, autorises) in [
      (EtatApp.connecteeCaissier, 'Caissier', {'tableau_bord', 'caisse', 'ventes', 'retours', 'clients', 'historique'}),
      (
        EtatApp.connecteeMagasinier,
        'Magasinier',
        {'tableau_bord', 'produits', 'stock', 'magasins', 'entrees', 'besoins', 'sorties', 'fournisseurs'},
      ),
    ]) {
      testWidgets('$role : accès limité aux modules du rôle', (tester) async {
        for (final m in modules) {
          await pumpApp(tester, etat: etat, routeInitiale: m.route, taille: taille);
          expect(tester.takeException(), isNull, reason: m.id);
          expect(
            find.byKey(accesRefuse),
            autorises.contains(m.idAcces) ? findsNothing : findsOneWidget,
            reason: '$role ${m.id}',
          );
        }
      });
    }
  });
}
