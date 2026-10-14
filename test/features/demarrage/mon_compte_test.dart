import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/features/compte/mon_compte_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Mon compte', () {
    testWidgets('changement d’identifiant : mot de passe exigé, puis session mise à jour', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.connecteeAdmin, routeInitiale: MonComptePage.route, taille: const Size(1400, 900));
      expect(find.text('Identifiant actuel : gerant'), findsOneWidget);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'karim.b');
      await tester.enterText(champs.at(1), 'faux');
      await clic(tester, find.text("Changer l'identifiant").last);
      expect(find.text('Mot de passe actuel incorrect.'), findsOneWidget);
      await tester.enterText(champs.at(1), 'azerty');
      await clic(tester, find.text("Changer l'identifiant").last);
      expect(find.textContaining('connectez-vous désormais avec « karim.b »'), findsOneWidget);
      await clic(tester, find.text('OK'));
      expect(c.read(sessionProvider)!.utilisateur.identifiant, 'karim.b');
      expect(find.text('Identifiant actuel : karim.b'), findsOneWidget);
    });

    testWidgets('compte démo : modification impossible', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeDemo, routeInitiale: MonComptePage.route);
      expect(find.text('Le compte de démonstration ne peut pas être modifié.'), findsOneWidget);
      expect(find.text("Changer l'identifiant"), findsNothing);
    });
  });
}
