import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  /// Couleur du montant de la ligne (texte « 0,00 »).
  Color? couleurMontant(WidgetTester tester) =>
      tester.widget<Text>(find.text(formaterNombre(0, decimales: 2))).style?.color;

  for (final alerte in [false, true]) {
    testWidgets('ligne du panier ${alerte ? 'avec' : 'sans'} prix en alerte', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          child: DsCartLine(nom: 'Lait 1 L', code: 'PRD0001', prix: 0, colis: 'Unité', pieces: 1, prixEnAlerte: alerte),
        ),
      );
      final danger = tester.element(find.byType(DsCartLine)).ds.colors.dangerFg;
      expect(couleurMontant(tester) == danger, alerte, reason: 'montant en rouge seulement en alerte');
      final sousTitre = tester.widget<RichText>(find.textContaining('PRD0001 · ', findRichText: true)).text;
      TextSpan? prix;
      sousTitre.visitChildren((s) {
        if (s is TextSpan && (s.text?.contains('DA') ?? false)) prix = s;
        return prix == null;
      });
      expect(prix, isNotNull);
      expect(prix!.style?.color == danger, alerte, reason: 'prix du sous-titre en rouge seulement en alerte');
    });
  }
}
