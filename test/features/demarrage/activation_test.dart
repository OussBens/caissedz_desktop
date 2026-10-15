import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  Future<void> saisirCle(WidgetTester tester, String cle) async {
    await tester.enterText(find.byKey(const ValueKey('cle_groupe_0')), cle);
    await tester.pumpAndSettle();
  }

  group('Activation', () {
    testWidgets('application vierge : écran d’activation, identifiant machine affiché', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge);
      expect(find.byType(ActivationPage), findsOneWidget);
      expect(find.text('Activer CaisseDZ'), findsOneWidget);
      expect(find.text(machineTest), findsOneWidget);
    });

    testWidgets('clé incomplète : bouton désactivé ; clé inconnue : message d’erreur', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge);
      await saisirCle(tester, 'abc');
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.byType(ActivationPage), findsOneWidget);
      await saisirCle(tester, 'f' * 64);
      expect(find.text("Clé invalide pour ce poste — vérifiez l'identifiant envoyé."), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.byType(ActivationPage), findsOneWidget);
    });

    testWidgets('clé Avancé valide : palier détecté, activation puis connexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      await saisirCle(tester, cleTest(NiveauLicence.avance));
      expect(find.textContaining('Avancé'), findsWidgets);
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.text('Application activée'), findsOneWidget);
      await clic(tester, find.text('Continuer'));
      expect(c.read(licenceProvider).niveau, NiveauLicence.avance);
      expect(c.read(licenceProvider).demo, isFalse);
      expect(find.byType(ConnexionPage), findsOneWidget);
    });

    testWidgets('arabe : écran d’activation en RTL', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, locale: const Locale('ar'));
      expect(find.text('تفعيل CaisseDZ'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(ActivationPage))), TextDirection.rtl);
    });
  });
}
