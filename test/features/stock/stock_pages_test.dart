import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Future<(Produit, Produit)> _donnees(ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  final cat = CatalogueService(db, utilisateurCode: 'USR0000');
  final lait = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Lait 1 L',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
    ),
  );
  final eau = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Eau 1,5 L',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 20,
      prixVente: 30,
    ),
  );
  final stock = StockService(db, utilisateurCode: 'USR0000');
  await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 12, type: TypesMouvement.initial);
  await stock.creerMagasin('Dépôt');
  return (lait, eau);
}

Future<void> rafraichir(WidgetTester tester, ProviderContainer c) async {
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.read(stockVersionProvider.notifier).incrementer();
  await tester.pumpAndSettle();
}

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle).last, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Stock', () {
    testWidgets('niveaux (sous seuil en rouge), journal, entrée manuelle', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/stock', taille: const Size(1400, 900));
      await _donnees(c);
      await rafraichir(tester, c);
      expect(find.text('Lait 1 L'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
      await clic(tester, find.text('Entrée manuelle').first);
      await tester.enterText(_champ('Quantité'), '8');
      await clic(tester, find.text('Enregistrer'));
      expect(
        (await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0002', 'MAG0000')).quantite,
        8,
      ); // Eau (premier par désignation)
      await clic(tester, find.text('Journal des mouvements'));
      expect(find.text('Stock initial'), findsOneWidget);
      expect(find.text('Entrée'), findsOneWidget);
    });

    testWidgets('sortie refusée par la garde de stock, puis acceptée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: const Size(1400, 900));
      await _donnees(c);
      await rafraichir(tester, c);
      await clic(tester, find.text('Nouvelle sortie'));
      await clic(tester, find.text('Ajouter un produit'));
      await clic(tester, find.text('Lait 1 L').last);
      await clic(tester, find.text('Choisir'));
      await tester.enterText(find.byKey(const ValueKey('qte_PRD0001')), '50');
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('Stock insuffisant'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.text('Nouvelle sortie'));
      await clic(tester, find.text('Ajouter un produit'));
      await clic(tester, find.text('Lait 1 L').last);
      await clic(tester, find.text('Choisir'));
      await tester.enterText(find.byKey(const ValueKey('qte_PRD0001')), '2');
      await clic(tester, find.text('Valider'));
      expect(find.text('SOR0001'), findsOneWidget);
      expect(find.text('Casse'), findsOneWidget);
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 10);
    });

    testWidgets('transfert TRM entre magasins', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/transferts', taille: const Size(1400, 900));
      await _donnees(c);
      await rafraichir(tester, c);
      await clic(tester, find.text('Nouveau transfert'));
      await clic(tester, find.text('Ajouter un produit'));
      await clic(tester, find.text('Lait 1 L').last);
      await clic(tester, find.text('Choisir'));
      await tester.enterText(find.byKey(const ValueKey('qte_PRD0001')), '5');
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('TRM0001'), findsWidgets);
      await clic(tester, find.text('Fermer').last);
      final repo = StockRepository(c.read(appDatabaseProvider).db);
      expect((await repo.niveau('PRD0001', 'MAG0000')).quantite, 7);
      expect((await repo.niveau('PRD0001', 'MAG0001')).quantite, 5);
    });

    testWidgets('besoins : génération sous seuil et changement de statut', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/besoins', taille: const Size(1400, 900));
      await _donnees(c);
      await rafraichir(tester, c);
      await clic(tester, find.text('Générer sous seuil'));
      expect(find.text('1 besoin(s) généré(s).'), findsOneWidget); // l'eau est à 0
      await clic(tester, find.text('Fermer').last);
      expect(find.text('BES0001'), findsOneWidget);
      expect(find.text('En attente'), findsWidgets);
    });

    testWidgets('magasins : création et magasin principal', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/magasins', taille: const Size(1400, 900));
      expect(find.text('Magasin principal'), findsWidgets);
      await clic(tester, find.text('Nouveau magasin'));
      await tester.enterText(_champ('Nom'), 'Entrepôt');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Entrepôt'), findsOneWidget);
      expect(find.text('MAG0001'), findsOneWidget);
      expect(
        await StockService(c.read(appDatabaseProvider).db, utilisateurCode: 'USR0000').magasinPrincipal('USR0000'),
        'MAG0000',
      );
    });
  });
}
