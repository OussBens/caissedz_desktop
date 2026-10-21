import 'dart:typed_data';

import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('aperçu d’image : molette pour zoomer, glisser l’image agrandie, boutons et image entière', (
    tester,
  ) async {
    await pumpDs(
      tester,
      Center(
        child: SizedBox(
          width: 600,
          child: DsImageZoom(image: MemoryImage(Uint8List.fromList([1, 2, 3])), hauteur: 400),
        ),
      ),
    );
    final niveau = find.byKey(const ValueKey('image_zoom_niveau'));
    TransformationController transformation() =>
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).transformationController!;
    expect(tester.widget<Text>(niveau).data, '100 %');

    // Molette vers le haut : zoom avant sous le pointeur ; vers le bas : zoom arrière.
    final centre = tester.getCenter(find.byType(InteractiveViewer));
    final souris = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(souris.hover(centre));
    await tester.sendEventToBinding(souris.scroll(const Offset(0, -200)));
    await tester.pump();
    final apresMolette = transformation().value.getMaxScaleOnAxis();
    expect(apresMolette, greaterThan(1));
    await tester.sendEventToBinding(souris.scroll(const Offset(0, 100)));
    await tester.pump();
    expect(transformation().value.getMaxScaleOnAxis(), lessThan(apresMolette));

    // Boutons : zoom avant au centre, puis glisser l'image agrandie.
    await tester.tap(find.byKey(const ValueKey('image_zoom_plus')));
    await tester.pump();
    expect(transformation().value.getMaxScaleOnAxis(), greaterThan(1.4));
    final avant = transformation().value.getTranslation();
    await tester.drag(find.byType(InteractiveViewer), const Offset(80, 40), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(transformation().value.getTranslation(), isNot(avant), reason: 'image déplacée au clic maintenu');

    // Image entière : retour à 100 %.
    await tester.tap(find.byKey(const ValueKey('image_zoom_ajuster')));
    await tester.pump();
    expect(tester.widget<Text>(niveau).data, '100 %');
    expect(tester.widget<DsIconButton>(find.byKey(const ValueKey('image_zoom_moins'))).onPressed, isNull);
  });

  testWidgets('détail : les sections avec un flex côte à côte (photo à gauche, lignes à droite)', (tester) async {
    await pumpDs(
      tester,
      taille: const Size(1440, 900),
      const DsEntityDetailDialog(
        titre: 'BON0001',
        largeur: 1320,
        sections: [
          DsSectionDetail(titre: 'Aperçu', flex: 5, contenu: SizedBox(height: 200)),
          DsSectionDetail(titre: 'Lignes lues', flex: 7, contenu: SizedBox(height: 120)),
          DsSectionDetail(titre: 'Audit', contenu: SizedBox(height: 40)),
        ],
      ),
    );
    final apercu = tester.getTopLeft(find.text('Aperçu'));
    final lignes = tester.getTopLeft(find.text('Lignes lues'));
    final audit = tester.getTopLeft(find.text('Audit'));
    expect(lignes.dy, apercu.dy);
    expect(lignes.dx, greaterThan(apercu.dx));
    expect(audit.dy, greaterThan(apercu.dy));
  });
}
