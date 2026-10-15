import 'dart:convert';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/features/produits/produit_form_dialog.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

void main() {
  group('Module Produits (DS v2.2)', () {
    testWidgets('création rapide avec marge : prix de vente calculé, fiche en base, carte affichée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await clic(tester, _cle('produit_nouveau'));
      await tester.enterText(_champ('produit_designation'), 'Lait 1 L');
      await tester.enterText(_champ('produit_achat'), '80');
      await tester.enterText(_champ('produit_marge'), '25');
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('produit_vente_100'),
        ),
        findsOneWidget,
      );
      await clic(tester, _cle('produit_enregistrer'));
      expect(find.text('Lait 1 L'), findsWidgets);
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001');
      expect(p!.prixVente, 100);
      expect(p.margePct, 25);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('caissier : accès refusé au module Produits', (tester) async {
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
      final c = await pumpApp(
        tester,
        routeInitiale: '/produits',
        taille: const Size(1600, 1000),
        overrides: [httpClientProvider.overrideWithValue(client)],
      );
      await clic(tester, _cle('produit_nouveau'));
      await clic(
        tester,
        find.descendant(of: find.byType(DsSegmentedControl<ModeFormulaireProduit>), matching: find.text('IA')),
      );
      await tester.enterText(_champ('produit_ia_code'), '6130000000015');
      await clic(tester, _cle('produit_ia_rechercher'));
      expect(tester.widget<TextField>(_champ('produit_designation')).controller!.text, 'Eau minérale 1,5 L');
      await tester.enterText(_champ('produit_achat'), '50');
      await tester.enterText(_champ('produit_marge'), '20');
      await tester.pump();
      await clic(tester, _cle('produit_enregistrer'));
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCodeBarres('6130000000015');
      expect(p!.designation, 'Eau minérale 1,5 L');
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('catégories : création d’une catégorie (sous-catégorie par défaut créée)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await clic(tester, find.text('Catégories').first);
      await clic(tester, _cle('categorie_nouvelle'));
      await tester.enterText(_champ('categorie_nom'), 'Boissons');
      await tester.pump();
      await clic(tester, _cle('categorie_enregistrer'));
      expect(find.text('Boissons'), findsWidgets);
      final repo = CatalogueRepository(c.read(appDatabaseProvider).db);
      expect((await repo.categories()).any((x) => x.nom == 'Boissons'), isTrue);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('remise par montant : type en tête, sans produits, enregistrable', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await clic(tester, find.text('Remises').first);
      await clic(tester, _cle('remise_nouvelle'));
      expect(find.text('Ajouter des produits'), findsOneWidget);
      expect(find.text('Cumulable'), findsNothing);
      await clic(tester, find.text('Par montant (panier)'));
      expect(find.text('Ajouter des produits'), findsNothing);
      await tester.enterText(_champ('remise_nom'), 'Gros panier');
      await clic(tester, find.text('Montant fixe'));
      await tester.enterText(_champ('remise_valeur'), '500');
      await tester.enterText(_champ('remise_seuil'), '5000');
      await tester.pump();
      await clic(tester, _cle('remise_enregistrer'));
      expect(find.text('Gros panier'), findsOneWidget);
      final r = (await CatalogueRepository(c.read(appDatabaseProvider).db).remises()).single;
      expect((r.parMontant, r.type, r.valeur, r.seuil), (true, 'Montant', 500.0, 5000.0));
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('import Excel : analyse du modèle et import', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      final service = c.read(importProduitsServiceProvider);
      final lignes = await service.analyser(importModele());
      final r = await service.importer(lignes);
      expect(r.importees, 1);
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      expect(find.text('Exemple : Lait 1 L'), findsWidgets);
    });

    testWidgets('arabe : page Produits en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/produits', locale: const Locale('ar'), taille: const Size(1600, 1000));
      final bouton = _cle('produit_nouveau');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
