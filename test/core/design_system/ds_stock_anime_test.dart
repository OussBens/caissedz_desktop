import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('stock de la carte produit : rebond et couleur quand il baisse, puis retour au repos', (tester) async {
    final flashs = <Color?>[];
    final stock = ValueNotifier<double>(10);
    addTearDown(stock.dispose);
    await pumpDs(
      tester,
      ValueListenableBuilder<double>(
        valueListenable: stock,
        builder: (_, v, _) => DsStockAnime(
          stock: v,
          builder: (flash) {
            flashs.add(flash);
            return Text('$v');
          },
        ),
      ),
    );
    expect(flashs.last, isNull);
    stock.value = 9;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(flashs.last, isNotNull, reason: 'couleur primaire pendant l’animation');
    final echelle = tester
        .widget<Transform>(find.descendant(of: find.byType(DsStockAnime), matching: find.byType(Transform)))
        .transform
        .getMaxScaleOnAxis();
    expect(echelle, greaterThan(1));
    await tester.pumpAndSettle();
    expect(flashs.last, isNull);
    // Une hausse (produit retiré du panier) ne déclenche pas l'animation.
    stock.value = 10;
    await tester.pump(const Duration(milliseconds: 100));
    expect(flashs.last, isNull);
  });
}
