import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/raccourcis_caisse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

String _libelle(WidgetTester tester, ActionCaisse a) =>
    tester.widget<DsButton>(_cle('param_raccourci_${a.name}')).libelle;

Future<void> _presser(WidgetTester tester, LogicalKeyboardKey k, {bool ctrl = false}) async {
  if (ctrl) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(k);
  if (ctrl) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  group('Paramètres › Raccourcis clavier', () {
    testWidgets('une touche par action : touche réservée refusée, touche prise → échange, enregistrement', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/parametres', taille: _taille);
      await clic(tester, _cle('param_nav_raccourcis'));
      expect(_libelle(tester, ActionCaisse.vider), 'F10');
      expect(_cle('param_raccourcis_lecture'), findsNothing, reason: 'administrateur : modifiable');

      // Vider le panier → F5 (libre).
      await clic(tester, _cle('param_raccourci_vider'));
      expect(find.text('En attente d’une touche…'), findsOneWidget);
      await _presser(tester, LogicalKeyboardKey.enter);
      expect(_cle('capture_raccourci_erreur'), findsOneWidget, reason: 'Entrée est réservée');
      expect(tester.widget<DsButton>(_cle('capture_raccourci_valider')).onPressed, isNull);
      await _presser(tester, LogicalKeyboardKey.f5);
      expect(tester.widget<Text>(_cle('capture_raccourci_touche')).data, 'F5');
      await clic(tester, _cle('capture_raccourci_valider'));
      expect(_libelle(tester, ActionCaisse.vider), 'F5');
      expect(_cle('param_modifie'), findsOneWidget);

      // Choisir le client → F4, déjà prise par « Encaisser le ticket » : pas de doublon, on échange.
      await clic(tester, _cle('param_raccourci_client'));
      await _presser(tester, LogicalKeyboardKey.f4);
      expect(find.text('Touche déjà utilisée par « Encaisser le ticket ».'), findsOneWidget);
      expect(_cle('capture_raccourci_valider'), findsNothing);
      await clic(tester, _cle('capture_raccourci_echanger'));
      expect(_libelle(tester, ActionCaisse.client), 'F4');
      expect(_libelle(tester, ActionCaisse.encaisser), 'F7');

      // Nouveau panier → Ctrl+P.
      await clic(tester, _cle('param_raccourci_nouveauPanier'));
      await _presser(tester, LogicalKeyboardKey.keyP, ctrl: true);
      await clic(tester, _cle('capture_raccourci_valider'));
      expect(_libelle(tester, ActionCaisse.nouveauPanier), 'Ctrl+P');

      await clic(tester, _cle('param_enregistrer'));
      final lu = RaccourcisCaisse.depuisCles(
        await ParametreRepository(c.read(appDatabaseProvider).db).lirePlusieurs(RaccourcisCaisse.cles),
      );
      expect(lu.valide, isTrue);
      expect(
        [ActionCaisse.vider, ActionCaisse.client, ActionCaisse.encaisser, ActionCaisse.nouveauPanier].map(lu.libelle),
        ['F5', 'F4', 'F7', 'Ctrl+P'],
      );

      // Retour aux touches par défaut.
      await clic(tester, _cle('param_raccourci_defaut_vider'));
      expect(_libelle(tester, ActionCaisse.vider), 'F10');
      await clic(tester, _cle('param_raccourcis_defaut'));
      expect(_libelle(tester, ActionCaisse.client), 'F7');
      expect(_libelle(tester, ActionCaisse.encaisser), 'F4');
      await tester.pump(const Duration(seconds: 5)); // toast « Paramètres enregistrés »
    });
  });
}
