import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/configuration/configuration_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Activation', () {
    testWidgets('application vierge : écran d’activation, identifiant machine affiché', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge);
      expect(find.byType(ActivationPage), findsOneWidget);
      expect(find.text(machineTest), findsOneWidget);
      expect(find.byType(ConnexionPage), findsNothing);
    });

    testWidgets('clé mal formée puis clé inconnue : messages d’erreur', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge);
      await tester.enterText(find.byType(TextField), 'abc');
      await clic(tester, find.text('Activer'));
      expect(find.text('La clé doit contenir exactement 64 caractères hexadécimaux (0-9, a-f).'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'f' * 64);
      await clic(tester, find.text('Activer'));
      expect(find.textContaining('ne correspond pas à cette machine'), findsOneWidget);
      expect(find.byType(ActivationPage), findsOneWidget);
    });

    testWidgets('clé Avancé valide : licence activée puis configuration initiale', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      await tester.enterText(find.byType(TextField), cleTest(NiveauLicence.avance).toUpperCase());
      await clic(tester, find.text('Activer'));
      expect(find.text('Licence Avancé activée.'), findsOneWidget);
      await clic(tester, find.text('OK'));
      expect(c.read(licenceProvider).niveau, NiveauLicence.avance);
      expect(find.byType(ConfigurationPage), findsOneWidget);
    });

    testWidgets('mode démo : licence Avancé démo, puis configuration', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      await clic(tester, find.text('Essayer en mode démo'));
      expect(c.read(licenceProvider).demo, isTrue);
      expect(find.byType(ConfigurationPage), findsOneWidget);
    });

    testWidgets('arabe : écran d’activation en RTL', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, locale: const Locale('ar'));
      expect(find.text('تفعيل CaisseDZ'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(ActivationPage))), TextDirection.rtl);
    });
  });
}
