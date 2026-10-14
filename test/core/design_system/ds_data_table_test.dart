import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

class _L {
  const _L(this.code, this.nom, this.qte);
  final String code;
  final String nom;
  final int qte;
}

final _lignes = [for (var i = 1; i <= 30; i++) _L('C${i.toString().padLeft(3, '0')}', 'Article $i', (i * 7) % 11)];

List<DsColonne<_L>> _colonnes() => [
  DsColonne(id: 'code', libelle: 'Code', valeur: (l) => l.code),
  DsColonne(id: 'nom', libelle: 'Nom', valeur: (l) => l.nom),
  DsColonne(
    id: 'qte',
    libelle: 'Qté',
    valeur: (l) => l.qte,
    numerique: true,
    total: (ls) => '${ls.fold<int>(0, (s, l) => s + l.qte)}',
  ),
];

void main() {
  group('DsDataTable', () {
    testWidgets('pagine, affiche les totaux et navigue entre pages', (tester) async {
      await pumpDs(
        tester,
        DsDataTable<_L>(
          colonnes: _colonnes(),
          lignes: _lignes,
          cle: (l) => l.code,
          taillePage: 10,
          afficherTotaux: true,
        ),
      );
      expect(find.text('C001'), findsOneWidget);
      expect(find.text('C011'), findsNothing);
      expect(find.text('1–10 sur 30'), findsOneWidget);
      expect(find.text('${_lignes.fold<int>(0, (s, l) => s + l.qte)}'), findsOneWidget);
      await tester.tap(find.byTooltip('Page suivante'));
      await tester.pumpAndSettle();
      expect(find.text('C011'), findsOneWidget);
      expect(find.text('11–20 sur 30'), findsOneWidget);
    });

    testWidgets('trie par colonne (asc, desc, puis sans tri)', (tester) async {
      await pumpDs(tester, DsDataTable<_L>(colonnes: _colonnes(), lignes: _lignes, cle: (l) => l.code, taillePage: 5));
      Offset y(String texte) => tester.getTopLeft(find.text(texte));
      await tester.tap(find.text('QTÉ'));
      await tester.pumpAndSettle();
      // Tri ascendant : la plus petite quantité (0 pour i=11, 22) en premier.
      expect(find.text('C011'), findsOneWidget);
      await tester.tap(find.text('QTÉ'));
      await tester.pumpAndSettle();
      // Tri descendant : quantité 10 (i=3, 14, 25) en premier.
      expect(find.text('C003'), findsOneWidget);
      expect(y('C003').dy < y('C014').dy, isTrue);
      await tester.tap(find.text('QTÉ'));
      await tester.pumpAndSettle();
      expect(find.text('C001'), findsOneWidget);
    });

    testWidgets('sélection multiple et « tout sélectionner » sur la page', (tester) async {
      Set<Object> selection = {};
      await pumpDs(
        tester,
        DsDataTable<_L>(
          colonnes: _colonnes(),
          lignes: _lignes,
          cle: (l) => l.code,
          taillePage: 10,
          onSelectionChanged: (s) => selection = s,
        ),
      );
      await tester.tap(find.text('C002'));
      await tester.pumpAndSettle();
      expect(selection, {'C002'});
      expect(find.text('1 sélectionné(s)'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Tout sélectionner'));
      await tester.pumpAndSettle();
      expect(selection.length, 10);
      await tester.tap(find.bySemanticsLabel('Tout sélectionner'));
      await tester.pumpAndSettle();
      expect(selection, isEmpty);
    });

    testWidgets('masque et réaffiche une colonne', (tester) async {
      await pumpDs(tester, DsDataTable<_L>(colonnes: _colonnes(), lignes: _lignes, cle: (l) => l.code, taillePage: 5));
      expect(find.text('Article 1'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('table_colonnes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('colonne_nom')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();
      expect(find.text('Article 1'), findsNothing);
    });

    testWidgets('menu contextuel au clic droit', (tester) async {
      _L? ouverte;
      await pumpDs(
        tester,
        DsDataTable<_L>(
          colonnes: _colonnes(),
          lignes: _lignes,
          cle: (l) => l.code,
          taillePage: 5,
          actionsContextuelles: [DsActionContextuelle(libelle: 'Ouvrir', onSelected: (l) => ouverte = l)],
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('C003')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(ouverte?.code, 'C003');
    });

    testWidgets('message vide', (tester) async {
      await pumpDs(tester, DsDataTable<_L>(colonnes: _colonnes(), lignes: const [], cle: (l) => l.code));
      expect(find.text('Aucun élément'), findsOneWidget);
    });
  });
}
