import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  /// Intensité du rouge par-dessus la tuile (alpha de la bordure ; 0 au repos).
  double rouge(WidgetTester tester) =>
      (tester.widget<DecoratedBox>(find.byKey(const ValueKey('tuile_clignotement'))).decoration as BoxDecoration)
          .border
          ?.top
          .color
          .a ??
      0;

  for (final enLigne in [false, true]) {
    testWidgets('produit en rupture (${enLigne ? 'liste' : 'grille'}) : opacité normale, clic → clignotement rouge', (
      tester,
    ) async {
      var ajouts = 0;
      await pumpDs(
        tester,
        SizedBox(
          width: enLigne ? 700 : 200,
          child: DsProductTile(nom: 'Lait 1 L', prix: 100, stock: 0, enLigne: enLigne, onAjouter: () => ajouts++),
        ),
      );
      expect(
        find.descendant(of: find.byType(DsProductTile), matching: find.byType(Opacity)),
        findsNothing,
        reason: 'plus de tuile grisée en rupture',
      );
      expect(rouge(tester), 0);

      await tester.tap(find.text('Lait 1 L'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(rouge(tester), greaterThan(.5));
      expect(ajouts, 0, reason: 'rien n’est ajouté au panier');

      await tester.pumpAndSettle();
      expect(rouge(tester), 0, reason: 'retour au repos après le clignotement');
    });
  }

  testWidgets('rupture cliquable (admin) : clignote et appelle onAjouter (transfert proposé)', (tester) async {
    var ajouts = 0;
    await pumpDs(
      tester,
      SizedBox(
        width: 200,
        child: DsProductTile(nom: 'Lait 1 L', prix: 100, stock: 0, ruptureCliquable: true, onAjouter: () => ajouts++),
      ),
    );
    await tester.tap(find.text('Lait 1 L'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(rouge(tester), greaterThan(.5));
    expect(ajouts, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('produit en stock : ajouté sans clignotement', (tester) async {
    var ajouts = 0;
    await pumpDs(
      tester,
      SizedBox(
        width: 200,
        child: DsProductTile(nom: 'Lait 1 L', prix: 100, stock: 4, onAjouter: () => ajouts++),
      ),
    );
    await tester.tap(find.text('Lait 1 L'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(rouge(tester), 0);
    expect(ajouts, 1);
  });
}
