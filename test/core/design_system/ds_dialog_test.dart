import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('DsDialog : boutons du pied centrés', (tester) async {
    await pumpDs(
      tester,
      DsDialog(
        titre: 'Titre',
        largeur: 600,
        contenu: const SizedBox(height: 40),
        actions: [
          DsButton(key: const ValueKey('a'), libelle: 'Annuler', onPressed: () {}),
          DsButton(key: const ValueKey('b'), libelle: 'Enregistrer', onPressed: () {}),
        ],
      ),
    );
    final dialog = tester.getRect(find.byType(DsDialog));
    final gauche = tester.getRect(find.byKey(const ValueKey('a'))).left;
    final droite = tester.getRect(find.byKey(const ValueKey('b'))).right;
    expect((gauche + droite) / 2, moreOrLessEquals(dialog.center.dx, epsilon: 1));
  });
}
