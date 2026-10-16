import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  mainPicker();
  testWidgets('DsSelect ouvre la liste, choisit une option et se referme', (tester) async {
    String? choix;
    await pumpDs(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 260,
          child: DsSelect<String>(
            titre: 'Entité',
            valeur: choix,
            options: const ['produit', 'vente'],
            libelle: (e) => e,
            placeholder: 'Toutes',
            onChanged: (v) => setState(() => choix = v),
          ),
        ),
      ),
    );
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('produit'), findsNothing);
    await tester.tap(find.text('Toutes'));
    await tester.pumpAndSettle();
    expect(find.text('produit'), findsOneWidget);
    await tester.tap(find.text('produit'));
    await tester.pumpAndSettle();
    expect(choix, 'produit');
    expect(find.text('vente'), findsNothing);
    expect(find.text('produit'), findsOneWidget);
    // Le clic sur le libellé ouvre aussi la liste.
    await tester.tap(find.text('Entité'));
    await tester.pumpAndSettle();
    expect(find.text('vente'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('vente'), findsNothing);
  });
}

class _Item {
  const _Item(this.code, this.nom);
  final String code;
  final String nom;
}

void mainPicker() {
  testWidgets('afficherSelecteur liste les éléments, sélection simple puis « Choisir »', (tester) async {
    _Item? choix;
    await pumpDs(
      tester,
      Builder(
        builder: (context) => DsButton(
          libelle: 'Ajouter un produit',
          onPressed: () async {
            choix = await afficherSelecteur<_Item>(
              context,
              titre: 'Produits',
              elements: const [_Item('PRD0001', 'Lait 1 L'), _Item('PRD0002', 'Eau 1,5 L')],
              libelle: (p) => p.nom,
              sousLibelle: (p) => p.code,
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Ajouter un produit'));
    await tester.pumpAndSettle();
    expect(find.text('Lait 1 L'), findsOneWidget);
    expect(find.text('PRD0002'), findsOneWidget);
    await tester.tap(find.text('Lait 1 L'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir'));
    await tester.pumpAndSettle();
    expect(choix?.code, 'PRD0001');
  });
}
