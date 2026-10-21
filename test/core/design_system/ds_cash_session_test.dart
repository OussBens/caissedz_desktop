import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('bande de caisse : la caisse seule, le détail et les boutons au survol', (tester) async {
    var mouvements = 0;
    await pumpDs(
      tester,
      Center(
        child: DsCashSessionCard(
          compact: true,
          ouverte: true,
          caisse: 'Caisse principale',
          ouvertureHeure: '08:12',
          solde: 1500,
          onMouvement: () => mouvements++,
          onCloturer: () {},
        ),
      ),
    );
    expect(find.text('Caisse principale'), findsOneWidget);
    expect(find.text('Mouvement'), findsNothing);
    expect(find.text('Clôturer'), findsNothing);

    final souris = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(souris.removePointer);
    await souris.addPointer(location: Offset.zero);
    await souris.moveTo(tester.getCenter(find.text('Caisse principale')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('caisse_session_details')), findsOneWidget);
    expect(find.textContaining('08:12'), findsOneWidget);
    await tester.tap(find.text('Mouvement'));
    expect(mouvements, 1);
    expect(find.text('Clôturer'), findsOneWidget);

    await souris.moveTo(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(find.text('Mouvement'), findsNothing);
  });

  testWidgets('bande de caisse fermée : « Ouvrir » toujours visible', (tester) async {
    var ouvertures = 0;
    await pumpDs(
      tester,
      Center(
        child: DsCashSessionCard(compact: true, ouverte: false, caisse: 'Caisse 2', onOuvrir: () => ouvertures++),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    expect(ouvertures, 1);
  });
}
