import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

class _L {
  const _L(this.code, this.nom, this.qte);
  final String code;
  final String nom;
  final int qte;
}

List<_L> _articles(int n, {String prefixe = 'Article'}) => [
  for (var i = 1; i <= n; i++) _L('C${i.toString().padLeft(4, '0')}', '$prefixe $i', i % 7),
];

final _colonnes = [
  DsColonne<_L>(id: 'code', libelle: 'Code', valeur: (l) => l.code),
  DsColonne<_L>(id: 'nom', libelle: 'Nom', valeur: (l) => l.nom),
  DsColonne<_L>(id: 'qte', libelle: 'Qté', valeur: (l) => l.qte, numerique: true),
];

Widget _table(List<_L> lignes, {bool chargement = false, DsVueModule vue = DsVueModule.grille}) =>
    SingleChildScrollView(
      child: DsModuleTable<_L>(
        entite: 'articles',
        lignes: lignes,
        colonnes: _colonnes,
        cle: (l) => l.code,
        chargement: chargement,
        vueParDefaut: vue,
        carte: (context, l, etat) => DsGridCard(
          etat: etat,
          child: SizedBox(height: 60, child: Text(l.nom, key: ValueKey('carte_${l.code}'))),
        ),
      ),
    );

Finder _cartes() =>
    find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('carte_'));

void main() {
  group('DsModuleTable : grandes listes', () {
    testWidgets('vue grille par pages : 24 cartes construites sur 1 000, puis la page suivante', (tester) async {
      await pumpDs(tester, _table(_articles(1000)), taille: const Size(1400, 900));
      expect(_cartes(), findsNWidgets(24));
      expect(find.byKey(const ValueKey('carte_C0001')), findsOneWidget);
      expect(find.textContaining('1–24', findRichText: true), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Page suivante'));
      await tester.tap(find.byTooltip('Page suivante'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('carte_C0025')), findsOneWidget);
      expect(find.byKey(const ValueKey('carte_C0001')), findsNothing);
    });

    testWidgets('recherche : revient à la 1ʳᵉ page et suit une liste mise à jour', (tester) async {
      final lignes = ValueNotifier(_articles(100));
      await pumpDs(
        tester,
        ValueListenableBuilder(valueListenable: lignes, builder: (_, l, _) => _table(l)),
        taille: const Size(1400, 900),
      );
      await tester.ensureVisible(find.byTooltip('Page suivante'));
      await tester.tap(find.byTooltip('Page suivante'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'article 99');
      await tester.pumpAndSettle();
      expect(_cartes(), findsOneWidget);
      expect(find.byKey(const ValueKey('carte_C0099')), findsOneWidget);
      // Nouvelle liste (renommée) : l'index de recherche est recalculé.
      lignes.value = _articles(100, prefixe: 'Produit');
      await tester.pumpAndSettle();
      expect(_cartes(), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'produit 99');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('carte_C0099')), findsOneWidget);
    });

    testWidgets('chargement : lignes fantômes et « Chargement… » au lieu de « aucun élément »', (tester) async {
      await pumpDs(tester, _table(const [], chargement: true));
      expect(find.byKey(const ValueKey('table_chargement')), findsOneWidget);
      expect(find.text('Chargement…'), findsOneWidget);
      expect(find.text('Aucun élément'), findsNothing);
      // Chargé, sans ligne : le message habituel.
      await pumpDs(tester, _table(const [], vue: DsVueModule.liste));
      expect(find.byKey(const ValueKey('table_chargement')), findsNothing);
    });
  });

  group('DsDataTable : tri gardé en cache', () {
    testWidgets('le tri suit une nouvelle liste (pas de résultat périmé)', (tester) async {
      final lignes = ValueNotifier([const _L('A', 'Zèbre', 1), const _L('B', 'Ane', 2)]);
      await pumpDs(
        tester,
        ValueListenableBuilder(
          valueListenable: lignes,
          builder: (_, l, _) => DsDataTable<_L>(colonnes: _colonnes, lignes: l, cle: (x) => x.code),
        ),
      );
      await tester.tap(find.text('NOM'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Ane')).dy, lessThan(tester.getTopLeft(find.text('Zèbre')).dy));
      lignes.value = [...lignes.value, const _L('C', 'Abeille', 3)];
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Abeille')).dy, lessThan(tester.getTopLeft(find.text('Ane')).dy));
    });
  });

  testWidgets('vue cartes : tri par colonne et sens, gardé en passant à la liste', (tester) async {
    await pumpDs(tester, _table(_articles(100)), taille: const Size(1400, 900));
    expect(find.byKey(const ValueKey('module_tri_sens')), findsNothing, reason: 'ordre par défaut');
    await tester.tap(find.byKey(const ValueKey('module_tri')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tri : Code').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('carte_C0001')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('module_tri_sens')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('carte_C0100')), findsOneWidget);
    expect(find.byKey(const ValueKey('carte_C0001')), findsNothing);
    // La liste reprend le tri choisi sur les cartes.
    await tester.tap(find.byTooltip('Affichage liste'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_tri')), findsNothing);
    expect(find.text('C0100'), findsOneWidget);
    expect(find.text('C0001'), findsNothing);
  });

  testWidgets('raccourcis : puces combinables, tri, période et « Réinitialiser »', (tester) async {
    var periode = DsPeriode.calculer('month');
    var reinitialise = 0;
    await pumpDs(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: DsModuleTable<_L>(
            entite: 'articles',
            lignes: _articles(30),
            colonnes: _colonnes,
            cle: (l) => l.code,
            filtresOuverts: true,
            periode: periode,
            onPeriode: (p) => setState(() => periode = p),
            onReinitialiser: () => reinitialise++,
            raccourcis: [
              const DsRaccourci(id: 'today', libelle: "Aujourd'hui", periode: 'today'),
              DsRaccourci(id: 'pairs', libelle: 'Pairs', filtre: (l) => l.qte.isEven),
              DsRaccourci(id: 'zero', libelle: 'Zéro', filtre: (l) => l.qte == 0),
              const DsRaccourci(id: 'gros', libelle: 'Plus gros', tri: DsTri('qte', ascendant: false)),
            ],
          ),
        ),
      ),
      taille: const Size(1400, 1200),
    );
    Finder puce(String l) =>
        find.descendant(of: find.byKey(const ValueKey('module_raccourcis')), matching: find.text(l));
    // Pairs (qté 0, 2, 4, 6) puis Zéro : les deux filtres se cumulent.
    await tester.tap(puce('Pairs'));
    await tester.pumpAndSettle();
    expect(find.text('Article 2'), findsOneWidget);
    expect(find.text('Article 1'), findsNothing);
    await tester.tap(puce('Zéro'));
    await tester.pumpAndSettle();
    expect(find.text('Article 2'), findsNothing);
    expect(find.text('Article 7'), findsOneWidget);
    expect(find.text('2 actif(s)'), findsOneWidget);
    // Puce de période : elle règle la période du module, et la rétablit quand on la retire.
    await tester.tap(puce("Aujourd'hui"));
    await tester.pumpAndSettle();
    expect(periode.preset, 'today');
    await tester.tap(puce("Aujourd'hui"));
    await tester.pumpAndSettle();
    expect(periode.preset, 'month');
    // « Réinitialiser » retire les puces et appelle celui du module.
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    expect(reinitialise, 1);
    expect(find.text('Article 1'), findsOneWidget);
    // Tri : la plus grosse quantité (6) en tête.
    await tester.tap(puce('Plus gros'));
    await tester.pumpAndSettle();
    final premiere = tester.getTopLeft(find.text('Article 6')).dy;
    expect(premiere, lessThan(tester.getTopLeft(find.text('Article 1')).dy));
  });
}
