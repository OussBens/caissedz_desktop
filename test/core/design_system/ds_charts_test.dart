import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('DsDonutChart : survol du centre et de la section sans RangeError', (tester) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 420,
        child: DsDonutChart(
          donnees: [DsDonnee(libelle: 'Espèces', valeur: 500)],
          libelleCentre: 'Paiements',
          valeurCentre: '500',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final centre = tester.getCenter(find.byType(PieChart));
    final souris = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await souris.addPointer(location: Offset.zero);
    addTearDown(souris.removePointer);
    // Centre de l'anneau : fl_chart renvoie l'index −1.
    await souris.moveTo(centre);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Paiements'), findsOneWidget);
    // Sur l'anneau : la section survolée s'affiche au centre.
    await souris.moveTo(centre + const Offset(0, -80));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('100 %'), findsWidgets);
    await souris.moveTo(centre);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
