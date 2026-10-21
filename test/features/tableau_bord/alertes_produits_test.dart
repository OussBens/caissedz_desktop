import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/alertes_produits.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/tableau_bord/alertes_produits_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

/// Un produit en stock sans code-barres ni photo, rangé dans Divers : alerte « Fiche produit incomplète ».
Future<void> _produitIncomplet(ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  final p = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
    const Produit(
      code: '',
      designation: 'Yaourt nature',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 30,
      prixVente: 40,
    ),
  );
  await StockService(
    db,
    utilisateurCode: 'USR0000',
  ).entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: 5);
}

void main() {
  testWidgets('alertes produits : point rouge, carte du tableau de bord, Situation, action', (tester) async {
    final c = await pumpApp(tester, taille: _taille);
    await _produitIncomplet(c);
    await c.read(alertesProduitsProvider.notifier).actualiser();
    await tester.pumpAndSettle();
    expect(c.read(alertesProduitsProvider).de(TypeAlerteProduit.ficheIncomplete), hasLength(1));
    // Pas encore consultées : point rouge sur le Tableau de bord depuis la Caisse.
    expect(_cle('point_/tableau-de-bord'), findsOneWidget);

    await clic(tester, find.text('Tableau de bord').first);
    final tuile = _cle('carte_alerte_ficheIncomplete');
    expect(tuile, findsOneWidget);
    expect(find.descendant(of: tuile, matching: find.text('Fiche produit incomplète')), findsOneWidget);
    expect(
      find.descendant(of: tuile, matching: find.byType(DsPoint)),
      findsOneWidget,
      reason: 'nouvelle',
    );

    // La tuile ouvre Situation › Alertes produits sur ce type : la ligne, son détail et son action.
    await clic(tester, tuile);
    expect(find.text('Yaourt nature'), findsOneWidget);
    expect(find.textContaining('sans code-barres'), findsOneWidget);
    expect(find.textContaining('catégorie Divers'), findsOneWidget);
    // Consultées : le point s'éteint.
    expect(c.read(alertesProduitsNouvellesProvider), isNot(contains(TypeAlerteProduit.ficheIncomplete)));
    await clic(tester, find.text('Compléter la fiche'));
    expect(find.byKey(const ValueKey('produit_designation')), findsOneWidget, reason: 'fiche produit ouverte');
  });

  testWidgets('Paramètres › Alertes : alerte désactivée et seuil enregistrés', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/parametres', taille: _taille);
    await clic(tester, _cle('param_nav_alertes'));
    expect(find.text('Alertes produits'), findsWidgets);
    await tester.enterText(_champ('param_${SeuilsAlertesProduits.cleDormant}'), '90');
    await tester.scrollUntilVisible(
      _cle('param_alerte_ficheIncomplete'),
      300,
      scrollable: find.ancestor(of: _cle('param_alerte_ficheIncomplete'), matching: find.byType(Scrollable)).first,
    );
    await tester.tap(_cle('param_alerte_ficheIncomplete'));
    await tester.pumpAndSettle();
    await clic(tester, _cle('param_enregistrer'));
    final seuils = SeuilsAlertesProduits.depuisCles(
      await ParametreRepository(c.read(appDatabaseProvider).db).lirePlusieurs(SeuilsAlertesProduits.cles),
    );
    expect(seuils.dormantJours, 90);
    expect(seuils.active(TypeAlerteProduit.ficheIncomplete), isFalse);
    await tester.pump(const Duration(seconds: 5)); // fin du toast
  });
}
