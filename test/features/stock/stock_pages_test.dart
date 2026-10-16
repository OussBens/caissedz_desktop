import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
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

Future<void> _rafraichir(WidgetTester tester, ProviderContainer c) async {
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.read(stockVersionProvider.notifier).incrementer();
  await tester.pumpAndSettle();
}

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

/// Ajoute un produit aux lignes d'un DocForm via le sélecteur.
Future<void> _ajouterProduit(WidgetTester tester, String designation) async {
  await clic(tester, find.text('Ajouter des produits').last);
  await clic(tester, find.text(designation).last);
  await clic(tester, find.text('Ajouter').last);
}

const _taille = Size(1600, 1000);

void main() {
  group('Stock (DS v2.2)', () {
    testWidgets('stock par magasin puis onglet Mouvements', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/stock', taille: _taille);
      await _donnees(c);
      await _rafraichir(tester, c);
      expect(find.text('Lait 1 L'), findsOneWidget);
      expect(find.text('DÉPÔT'), findsWidgets, reason: 'une colonne par magasin');
      expect(find.text('12'), findsWidgets);
      await clic(tester, _cle('stock_voir_mouvements'));
      expect(find.text('Stock initial'), findsOneWidget);
      expect(find.text('+12'), findsOneWidget);
    });

    testWidgets('sortie : quantité plafonnée au stock, puis enregistrée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: _taille);
      await _donnees(c);
      await _rafraichir(tester, c);
      await clic(tester, _cle('sortie_nouvelle'));
      await _ajouterProduit(tester, 'Lait 1 L');
      final qte = find
          .descendant(of: find.byKey(const ValueKey<Object>('PRD0001')), matching: find.byType(TextField))
          .first;
      await tester.enterText(qte, '50');
      await tester.pump();
      expect(find.text('Stock : 12'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('sortie_enregistrer')).onPressed, isNull);
      await tester.enterText(qte, '2');
      await tester.pump();
      await clic(tester, _cle('sortie_enregistrer'));
      expect(find.text('SRT0001'), findsOneWidget);
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 10);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sortie : tout le stock peut sortir (reste 0)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: _taille);
      await _donnees(c);
      await _rafraichir(tester, c);
      await clic(tester, _cle('sortie_nouvelle'));
      await _ajouterProduit(tester, 'Lait 1 L');
      final qte = find
          .descendant(of: find.byKey(const ValueKey<Object>('PRD0001')), matching: find.byType(TextField))
          .first;
      await tester.enterText(qte, '12');
      await tester.pump();
      expect(tester.widget<DsButton>(_cle('sortie_enregistrer')).onPressed, isNotNull);
      await clic(tester, _cle('sortie_enregistrer'));
      expect(find.text('SRT0001'), findsOneWidget);
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 0);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sortie : 2ᵉ stock « nombre » proposé puis obligatoire (§8.1)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      final poulet = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Poulet',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 300,
          prixVente: 400,
          suiviNombre: true,
          nombreParUnite: 2,
        ),
      );
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: poulet.code, magasinCode: 'MAG0000', quantite: 10, nombre: 20);
      await _rafraichir(tester, c);
      await clic(tester, _cle('sortie_nouvelle'));
      await _ajouterProduit(tester, 'Poulet');
      expect(find.text('NOMBRE'), findsOneWidget);
      final champs = find.descendant(of: find.byKey(ValueKey<Object>(poulet.code)), matching: find.byType(TextField));
      expect(tester.widget<TextField>(champs.at(1)).controller!.text, '2'); // 1 unité × 2 pièces
      await tester.enterText(champs.at(1), '0');
      await tester.pump();
      expect(find.text('Nombre obligatoire'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('sortie_enregistrer')).onPressed, isNull);
      await tester.enterText(champs.at(1), '3');
      await tester.pump();
      await clic(tester, _cle('sortie_enregistrer'));
      final n = await StockRepository(db).niveau(poulet.code, 'MAG0000');
      expect((n.quantite, n.nombre), (9.0, 17.0));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sortie : plus de pièces en stock, la quantité restante sort seule', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      final poulet = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Poulet',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 300,
          prixVente: 400,
          suiviNombre: true,
          nombreParUnite: 2,
        ),
      );
      final stock = StockService(db, utilisateurCode: 'USR0000');
      await stock.entrerStock(produitCode: poulet.code, magasinCode: 'MAG0000', quantite: 4, nombre: 2);
      await stock.sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: [LigneStock(produitCode: poulet.code, quantite: 1, nombre: 2)],
      );
      await _rafraichir(tester, c);
      await clic(tester, _cle('sortie_nouvelle'));
      await _ajouterProduit(tester, 'Poulet');
      final champs = find.descendant(of: find.byKey(ValueKey<Object>(poulet.code)), matching: find.byType(TextField));
      expect(tester.widget<TextField>(champs.at(1)).controller!.text, '0', reason: 'proposition plafonnée à 0 pièce');
      expect(find.text('Nombre obligatoire'), findsNothing);
      await tester.enterText(champs.first, '3');
      await tester.pump();
      await tester.enterText(champs.at(1), '1');
      await tester.pump();
      expect(find.text('Pièces : 0'), findsOneWidget);
      await tester.enterText(champs.at(1), '0');
      await tester.pump();
      await clic(tester, _cle('sortie_enregistrer'));
      final n = await StockRepository(db).niveau(poulet.code, 'MAG0000');
      expect((n.quantite, n.nombre), (0.0, 0.0));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sortie : liste des produits à côté du détail', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/sorties', taille: _taille);
      await _donnees(c);
      await StockService(c.read(appDatabaseProvider).db, utilisateurCode: 'USR0000').sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: const [LigneStock(produitCode: 'PRD0001', quantite: 2)],
      );
      await _rafraichir(tester, c);
      await clic(tester, find.text('SRT0001'));
      await clic(tester, _cle('sorties_liste_produits'));
      expect(_cle('liste_produits'), findsOneWidget);
      expect(find.text('Produits de SRT0001'), findsOneWidget);
      expect(find.descendant(of: _cle('liste_produits'), matching: find.text('Lait 1 L')), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      expect(_cle('liste_produits'), findsNothing);
    });

    testWidgets('transferts : onglet de Magasins, transfert TRM validé', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/transferts', taille: _taille);
      await _donnees(c);
      await _rafraichir(tester, c);
      await clic(tester, _cle('transfert_nouveau'));
      // Sélecteur de produits : quantité dans le magasin de départ à côté du stock total.
      await clic(tester, find.text('Ajouter des produits').last);
      expect(find.text('QTÉ DANS MAGASIN PRINCIPAL'), findsOneWidget);
      await clic(tester, find.text('Lait 1 L').last);
      await clic(tester, find.text('Ajouter').last);
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey<Object>('PRD0001')), matching: find.byType(TextField)).first,
        '5',
      );
      await tester.pump();
      await clic(tester, _cle('transfert_enregistrer'));
      expect(find.text('TRM0001'), findsWidgets);
      final repo = StockRepository(c.read(appDatabaseProvider).db);
      expect((await repo.niveau('PRD0001', 'MAG0000')).quantite, 7);
      expect((await repo.niveau('PRD0001', 'MAG0001')).quantite, 5);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('magasins : création', (tester) async {
      await pumpApp(tester, routeInitiale: '/magasins', taille: _taille);
      await clic(tester, _cle('magasin_nouveau'));
      await tester.enterText(_champ('magasin_nom'), 'Entrepôt');
      await tester.pump();
      await clic(tester, _cle('magasin_enregistrer'));
      expect(find.text('Entrepôt'), findsOneWidget);
      expect(find.text('MAG0001'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('besoins : ruptures & seuils puis listes', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/besoins', taille: _taille);
      await _donnees(c);
      await _rafraichir(tester, c);
      await clic(tester, find.text('Ruptures & seuils'));
      expect(find.text('Eau 1,5 L'), findsOneWidget);
      expect(find.text('Rupture'), findsWidgets);
      await clic(tester, find.text('Listes de besoins'));
      await clic(tester, find.text('Nouvelle liste'));
      await clic(tester, _cle('besoin_ajouter_rupture'));
      expect(find.byKey(const ValueKey<Object>('PRD0002')), findsOneWidget, reason: 'Eau en rupture');
      expect(find.byKey(const ValueKey<Object>('PRD0001')), findsNothing, reason: 'Lait disponible');
      await clic(tester, _cle('besoin_ajouter_rupture'));
      expect(find.text('Aucun nouveau produit à ajouter.'), findsOneWidget);
      await clic(tester, find.text('Annuler').last);
      await clic(tester, find.text('Expirés'));
      expect(find.text("Aucun produit expiré ou proche de l'expiration."), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('arabe : écran Stock en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/stock', locale: const Locale('ar'), taille: _taille);
      final bouton = _cle('stock_voir_mouvements');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
