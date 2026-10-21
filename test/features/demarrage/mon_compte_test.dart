import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  Future<void> ouvrir(WidgetTester tester) async {
    await clic(tester, find.byKey(const ValueKey('topbar_compte')));
    expect(find.byKey(const ValueKey('dialog_mon_compte')), findsOneWidget);
  }

  group('Mon compte', () {
    testWidgets('changement d’identifiant : mot de passe exigé, puis session mise à jour', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.connecteeAdmin);
      await ouvrir(tester);
      expect(find.byKey(const ValueKey('compte_mdp_identifiant')), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('compte_identifiant')), 'karim.b');
      await tester.pump();
      expect(find.byKey(const ValueKey('compte_mdp_identifiant')), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('compte_mdp_identifiant')), 'faux');
      await clic(tester, find.byKey(const ValueKey('compte_enregistrer')));
      expect(find.text('Mot de passe actuel incorrect.'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('compte_mdp_identifiant')), motDePasseAdmin);
      await clic(tester, find.byKey(const ValueKey('compte_enregistrer')));
      expect(find.textContaining('connectez-vous désormais avec « karim.b »'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect(c.read(sessionProvider)!.utilisateur.identifiant, 'karim.b');
    });

    testWidgets('changement de mot de passe puis reconnexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.connecteeAdmin);
      await ouvrir(tester);
      await clic(tester, find.text('Mot de passe').last);
      await tester.enterText(find.byKey(const ValueKey('compte_mdp_actuel')), motDePasseAdmin);
      await tester.enterText(find.byKey(const ValueKey('compte_mdp_nouveau')), 'nouveau1');
      await tester.enterText(find.byKey(const ValueKey('compte_mdp_confirmation')), 'nouveau1');
      await clic(tester, find.byKey(const ValueKey('compte_enregistrer')));
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.byKey(const ValueKey('compte_deconnexion')));
      expect(find.byType(ConnexionPage), findsOneWidget);
      await c.read(sessionProvider.notifier).connecter(identifiantAdmin, 'nouveau1');
      expect(c.read(sessionProvider), isNotNull);
      await tester.pumpAndSettle();
    });

    testWidgets('pendant l’essai : le compte se modifie comme les autres', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeEssai);
      await ouvrir(tester);
      expect(find.byKey(const ValueKey('compte_enregistrer')), findsOneWidget);
    });
  });
}
