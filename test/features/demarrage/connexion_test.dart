import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Connexion', () {
    testWidgets('mauvais mot de passe, connexion admin/admin (Rester connecté), puis déconnexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.text('Bon retour'), findsOneWidget);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), identifiantAdmin);
      await tester.enterText(champs.at(1), 'faux');
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
      await tester.enterText(champs.at(1), motDePasseAdmin);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
      expect(routeCourante(c), '/caisse');
      expect(find.text('Administrateur'), findsWidgets);
      expect(find.byKey(const ValueKey('bandeau_demo')), findsNothing);

      final parametres = c.read(parametresAppRepositoryProvider);
      expect(await parametres.lire(SessionNotifier.cleSessionMemorisee), 'USR0000');

      await clic(tester, find.byKey(const ValueKey('bouton_deconnexion')));
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
      expect(await parametres.lire(SessionNotifier.cleSessionMemorisee), anyOf(isNull, isEmpty));
    });

    testWidgets('Rester connecté : la session mémorisée est reprise au démarrage', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      final session = c.read(sessionProvider.notifier);
      await session.connecter(identifiantAdmin, motDePasseAdmin, resterConnecte: true);
      await tester.pumpAndSettle();
      c.invalidate(sessionProvider);
      expect(c.read(sessionProvider), isNull);
      expect(await c.read(sessionProvider.notifier).reprendre(), isTrue);
      expect(c.read(sessionProvider)!.utilisateur.identifiant, identifiantAdmin);
      await tester.pumpAndSettle();
    });

    testWidgets('sans Rester connecté : rien n’est mémorisé', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      await c.read(sessionProvider.notifier).connecter(identifiantAdmin, motDePasseAdmin);
      await tester.pumpAndSettle();
      c.invalidate(sessionProvider);
      expect(await c.read(sessionProvider.notifier).reprendre(), isFalse);
      await tester.pumpAndSettle();
    });

    testWidgets('demo/demo refusé quand l’application est activée', (tester) async {
      await pumpApp(tester, etat: EtatApp.configuree);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'demo');
      await tester.enterText(champs.at(1), 'demo');
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.text("Le compte demo/demo n'est disponible qu'en mode démo."), findsOneWidget);
    });

    testWidgets('application non activée : admin refusé, demo/demo active le mode démo', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      expect(find.byType(ActivationPage), findsOneWidget);
      await clic(tester, find.text('Connexion'));
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.byKey(const ValueKey('encart_demo')), findsOneWidget);

      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), identifiantAdmin);
      await tester.enterText(champs.at(1), motDePasseAdmin);
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.text('Application non activée : seul le compte demo / demo est disponible.'), findsOneWidget);

      await tester.enterText(champs.at(0), 'demo');
      await tester.enterText(champs.at(1), 'demo');
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(c.read(licenceProvider).demo, isTrue);
      expect(c.read(sessionProvider)!.demo, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const ValueKey('bandeau_demo')), findsOneWidget);
    });
  });
}
