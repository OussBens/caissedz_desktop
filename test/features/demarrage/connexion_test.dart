import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Connexion', () {
    testWidgets('mauvais mot de passe puis connexion réussie, puis déconnexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      expect(find.byType(ConnexionPage), findsOneWidget);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'gerant');
      await tester.enterText(champs.at(1), 'faux');
      await clic(tester, find.text('Se connecter'));
      expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
      await tester.enterText(champs.at(1), 'azerty');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Karim'), findsOneWidget); // menu utilisateur
      expect(find.byKey(const ValueKey('bandeau_demo')), findsNothing);

      c.read(sessionProvider.notifier).deconnecter();
      await tester.pumpAndSettle();
      expect(find.byType(ConnexionPage), findsOneWidget);
    });

    testWidgets('demo/demo refusé hors mode démo, accepté en mode démo avec bandeau', (tester) async {
      await pumpApp(tester, etat: EtatApp.configuree);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'demo');
      await tester.enterText(champs.at(1), 'demo');
      await clic(tester, find.text('Se connecter'));
      expect(find.text("Le compte demo/demo n'est disponible qu'en mode démo."), findsOneWidget);
    });

    testWidgets('mode démo : indice affiché, connexion demo/demo, bandeau', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.connecteeDemo);
      expect(c.read(sessionProvider)!.demo, isTrue);
      expect(find.byKey(const ValueKey('bandeau_demo')), findsOneWidget);
      expect(find.text('Démonstration'), findsOneWidget);
    });
  });
}
