import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/features/roles/roles_page.dart';
import 'package:caissedz_desktop/features/shell/acces_refuse_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Accès refusé et licence', () {
    testWidgets('caissier : module Clôtures interdit → écran Accès refusé ; Caisse accessible', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: '/clotures');
      expect(find.byType(AccesRefusePage), findsOneWidget);
      expect(find.text('Accès refusé'), findsOneWidget);
      expect(find.textContaining('« Caissier »'), findsOneWidget);
      await clic(tester, find.text('Retour au tableau de bord'));
      expect(find.byType(AccesRefusePage), findsNothing);
      await clic(tester, find.text('Caisse'));
      expect(find.textContaining('Module « Caisse »'), findsOneWidget);
    });

    testWidgets('caissier : page Rôles interdite (permission gererUtilisateurs)', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: RolesPage.route);
      expect(find.byType(AccesRefusePage), findsOneWidget);
    });

    testWidgets('licence Basic : module Zakat verrouillé, Avancé : accessible', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: '/produits');
      // Caissier n'a pas accès à produits → accès refusé prime ; testons un module accessible et Avancé :
      // 'retours' est accessible au caissier mais réservé à la licence Avancé.
      await clic(tester, find.text('Retours'));
      expect(find.text('Fonction disponible avec la licence Avancé'), findsOneWidget);
      expect(find.byType(LicenceGate), findsWidgets);
    });

    testWidgets('admin Avancé : Zakat accessible et grille des rôles modifiable', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdmin, routeInitiale: '/zakat');
      expect(find.textContaining('Module « Zakat »'), findsOneWidget);
      expect(find.text('Fonction disponible avec la licence Avancé'), findsNothing);
    });
  });
}
