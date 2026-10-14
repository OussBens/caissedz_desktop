import 'dart:ui' show Tristate;

import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('DsButton — garde anti double-clic', () {
    testWidgets('ignore un second clic pendant le délai de garde', (tester) async {
      var clics = 0;
      await pumpDs(tester, DsButton(libelle: 'Valider', onPressed: () => clics++));
      await tester.tap(find.text('Valider'));
      await tester.pump();
      await tester.tap(find.text('Valider'));
      await tester.pump();
      expect(clics, 1);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Valider'));
      expect(clics, 2);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('désactive le bouton pendant un onPressed asynchrone', (tester) async {
      var clics = 0;
      await pumpDs(
        tester,
        DsButton(
          libelle: 'Encaisser',
          delaiGarde: Duration.zero,
          onPressed: () async {
            clics++;
            await Future<void>.delayed(const Duration(seconds: 2));
          },
        ),
      );
      await tester.tap(find.text('Encaisser'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Encaisser'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Encaisser'));
      expect(clics, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.text('Encaisser'));
      expect(clics, 2);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('un bouton sans onPressed est inactif', (tester) async {
      await pumpDs(tester, const DsButton(libelle: 'Inactif'));
      final s = tester.getSemantics(find.text('Inactif'));
      expect(s.flagsCollection.isEnabled, isNot(Tristate.isTrue));
    });
  });
}
