import 'dart:convert';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle), matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Module Produits', () {
    testWidgets('état vide, création détaillée avec marge, liste et prix d’achat visible (admin)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1400, 900));
      expect(find.text('Aucun produit. Créez-en un ou importez un fichier Excel.'), findsOneWidget);
      await clic(tester, find.text('Nouveau produit').first);
      await tester.enterText(_champ('Désignation'), 'Lait 1 L');
      await tester.enterText(_champ("Prix d'achat"), '80');
      await tester.enterText(_champ('Marge (%)'), '25');
      await tester.pump();
      expect(tester.widget<TextField>(_champ('Prix de vente')).controller!.text, '100.0');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Lait 1 L'), findsOneWidget);
      expect(find.text('PRD0001'), findsOneWidget);
      expect(find.text("PRIX D'ACHAT"), findsOneWidget); // colonne visible pour l'admin
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001');
      expect(p!.prixVente, 100);
      expect(p.margePct, 25);
    });

    testWidgets('caissier : accès refusé au module Produits ; magasinier : prix d’achat masqué sans la permission', (
      tester,
    ) async {
      await pumpApp(tester, etat: EtatApp.connecteeCaissier, routeInitiale: '/produits');
      expect(find.text('Accès refusé'), findsOneWidget);
    });

    testWidgets('mode IA : fiche trouvée via Open Food Facts puis création', (tester) async {
      final client = MockClient((req) async {
        if (req.url.host == 'world.openfoodfacts.org') {
          return http.Response(
            jsonEncode({
              'status': 1,
              'product': {'product_name_fr': 'Eau minérale 1,5 L', 'brands': 'Ifri'},
            }),
            200,
          );
        }
        return http.Response('{"status":0}', 200);
      });
      await pumpApp(
        tester,
        routeInitiale: '/produits',
        taille: const Size(1400, 900),
        overrides: [httpClientProvider.overrideWithValue(client)],
      );
      await clic(tester, find.text('Mode IA'));
      await tester.enterText(find.byType(TextField).last, '6130000000015');
      await clic(tester, find.text('Rechercher'));
      expect(find.text('Fiche trouvée via Open Food Facts'), findsOneWidget);
      expect(find.text('Eau minérale 1,5 L'), findsOneWidget);
      await clic(tester, find.text('Créer le produit'));
      expect(find.text('Nouveau produit'), findsWidgets);
      expect(tester.widget<TextField>(_champ('Désignation')).controller!.text, 'Eau minérale 1,5 L');
      await tester.enterText(_champ('Prix de vente'), '60');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('6130000000015'), findsOneWidget);
    });

    testWidgets('catégories : création, sous-catégorie, suppression système refusée', (tester) async {
      await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1400, 900));
      await clic(tester, find.text('Catégories'));
      expect(find.text('Sans catégorie'), findsOneWidget);
      await clic(tester, find.text('Nouvelle catégorie'));
      await tester.enterText(find.byType(TextField).last, 'Boissons');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Boissons'), findsWidgets);
      expect(find.text('CATE0001'), findsOneWidget);
      expect(find.text('SC0001'), findsOneWidget);
      await clic(tester, find.text('Nouvelle sous-catégorie'));
      await tester.enterText(find.byType(TextField).last, 'Jus');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Jus'), findsOneWidget);
    });

    testWidgets('import Excel : analyse du modèle et import', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits');
      final service = c.read(importProduitsServiceProvider);
      final lignes = await service.analyser(importModele());
      final r = await service.importer(lignes);
      expect(r.importees, 1);
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      expect(find.text('Exemple : Lait 1 L'), findsOneWidget);
    });

    testWidgets('arabe : page Produits en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/produits', locale: const Locale('ar'));
      expect(find.text('المنتجات'), findsWidgets);
      expect(find.text('منتج جديد'), findsWidgets);
      expect(Directionality.of(tester.element(find.text('منتج جديد').first)), TextDirection.rtl);
    });
  });
}
