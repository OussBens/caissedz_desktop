import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  const accesRefuse = ValueKey('acces_refuse');

  group('Accès refusé et licence', () {
    testWidgets('caissier : module Clôtures interdit → écran Accès refusé ; Caisse accessible', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: '/clotures');
      expect(find.byKey(accesRefuse), findsOneWidget);
      expect(find.text('Accès refusé'), findsOneWidget);
      await clic(tester, find.text('Retour au tableau de bord'));
      expect(find.byKey(accesRefuse), findsNothing);
      await clic(tester, find.text('Caisse').first);
      expect(find.byKey(const ValueKey('caisse_session')), findsOneWidget);
    });

    testWidgets('caissier : page Utilisateurs interdite (module non attribué au rôle)', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: '/utilisateurs');
      expect(find.byKey(accesRefuse), findsOneWidget);
    });

    testWidgets('licence Basic : Magasins et Transferts verrouillés (palier Max), devis (palier Avancé)', (
      tester,
    ) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: '/magasins');
      expect(find.text('Disponible avec le palier Max'), findsOneWidget);
      expect(find.byType(LicenceGate), findsWidgets);
    });

    testWidgets('licence Basic : Devis & commandes verrouillés (palier Avancé)', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: '/documents');
      expect(find.text('Disponible avec le palier Avancé'), findsOneWidget);
      expect(find.byType(LicenceGate), findsWidgets);
    });

    testWidgets('licence Basic : Retours et Zakat accessibles', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: '/zakat');
      expect(find.text('Disponible avec le palier Avancé'), findsNothing);
    });

    testWidgets('admin Avancé : Zakat accessible', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdmin, routeInitiale: '/zakat');
      expect(find.byKey(const ValueKey('zakat_nouveau')), findsOneWidget);
      expect(find.text('Disponible avec le palier Avancé'), findsNothing);
    });
  });
}
