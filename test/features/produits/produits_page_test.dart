import 'dart:convert';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/tendance_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
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
      // Le prix de vente est renseigné automatiquement depuis la marge (champ désormais modifiable).
      expect(tester.widget<TextField>(_champ('produit_vente')).controller!.text, '100,00');
      await clic(tester, _cle('produit_enregistrer'));
      expect(find.text('Lait 1 L'), findsWidgets);
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001');
      expect(p!.prixVente, 100);
      expect(p.margePct, 25);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('saisie rapide : taille libre à côté de la sous-catégorie, ou taille d’un type', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      final repo = CatalogueRepository(c.read(appDatabaseProvider).db);
      await clic(tester, _cle('produit_nouveau'));
      await tester.enterText(_champ('produit_designation'), 'Jus 75 cl');
      await tester.enterText(_champ('produit_achat'), '80');
      await tester.enterText(_champ('produit_marge'), '25');
      // Sans type : saisie libre.
      await tester.enterText(_champ('produit_taille_libre'), '75 cl');
      await tester.pump();
      await clic(tester, _cle('produit_enregistrer'));
      expect((await repo.produitParCode('PRD0001'))!.taille, '75 cl');
      await tester.pump(const Duration(seconds: 5));

      // Avec un type : la taille se choisit dans la liste du type.
      await clic(tester, _cle('produit_nouveau'));
      await tester.enterText(_champ('produit_designation'), 'Basket');
      await tester.enterText(_champ('produit_achat'), '2000');
      await tester.enterText(_champ('produit_marge'), '25');
      await clic(tester, _cle('produit_type_taille'));
      await clic(tester, find.text('Pointure').last);
      expect(_cle('produit_taille_libre'), findsNothing);
      await clic(tester, _cle('produit_taille'));
      await clic(tester, find.text('36').last);
      await clic(tester, _cle('produit_enregistrer'));
      expect((await repo.produitParCode('PRD0002'))!.taille, '36');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('fiche détaillée : code-barres CDZ généré, blocs Identification / Photos / Prix', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await clic(tester, _cle('produit_nouveau'));
      await clic(tester, find.text('Détaillé · 3 étapes'));
      for (final bloc in ['Identification', 'Photos', 'Prix']) {
        expect(find.text(bloc), findsOneWidget);
      }
      await clic(tester, _cle('produit_generer_code'));
      final code = tester.widget<TextField>(_champ('produit_code_barres')).controller!.text;
      expect(code, matches(RegExp(r'^CDZ\d{12}$')));
      await clic(tester, _cle('produit_generer_code'));
      expect(tester.widget<TextField>(_champ('produit_code_barres')).controller!.text, isNot(code), reason: 'séquence');
      await tester.enterText(_champ('produit_designation'), 'Savon');
      await tester.enterText(_champ('produit_achat'), '40');
      await tester.pump();
      await clic(tester, _cle('produit_suivant'));
      expect(find.text('Emballages'), findsOneWidget);
      // Prix d'achat et de vente de l'étape 1 rappelés à droite du titre des emballages.
      final prix = tester.widget<Text>(_cle('produit_emballages_prix')).textSpan!.toPlainText();
      expect(prix, contains('40,00'));
      await clic(tester, _cle('produit_suivant'));
      expect(find.text('Variantes'), findsNWidgets(2), reason: 'étape et bloc');
      expect(find.text('Options'), findsOneWidget);
      // Sans type de taille : saisie libre aussi en détaillé.
      await tester.enterText(_champ('produit_taille_libre'), '250 g');
      await clic(tester, _cle('produit_enregistrer'));
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001');
      expect(p!.codeBarres, startsWith('CDZ'));
      expect(p.taille, '250 g');
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
      // La fiche trouvée est montrée avant de remplir le formulaire : nom, marque, source.
      expect(find.text('Eau minérale'), findsOneWidget);
      expect(find.text('Ifri'), findsOneWidget);
      expect(find.text('Fiche trouvée via Open Food Facts'), findsOneWidget);
      await clic(tester, _cle('ia_fiche_oui'));
      expect(tester.widget<TextField>(_champ('produit_designation')).controller!.text, 'Eau minérale');
      expect(
        await ParametreRepository(c.read(appDatabaseProvider).db).lire(TendanceService.cleVotes),
        isNull,
        reason: 'pas de vote pour une fiche venue d’une autre source que le catalogue BENS',
      );
      await tester.enterText(_champ('produit_achat'), '50');
      await tester.enterText(_champ('produit_marge'), '20');
      await tester.pump();
      await clic(tester, _cle('produit_enregistrer'));
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCodeBarres('6130000000015');
      expect([p!.designation, p.taille], ['Eau minérale', '1,5 L'], reason: 'nom et quantité séparés');
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('nom arabe : saisi de droite à gauche, enregistré, cherché', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await clic(tester, _cle('produit_nouveau'));
      await tester.enterText(_champ('produit_designation'), 'Huile Elio 1 L');
      await tester.enterText(_champ('produit_designation_ar'), 'زيت إليو 1 ل');
      expect(
        Directionality.of(tester.element(_champ('produit_designation_ar'))),
        TextDirection.rtl,
        reason: 'saisi de droite à gauche dans une interface en français',
      );
      await tester.enterText(_champ('produit_achat'), '200');
      await tester.pump();
      await clic(tester, _cle('produit_enregistrer'));
      final repo = CatalogueRepository(c.read(appDatabaseProvider).db);
      final p = (await repo.produits(recherche: 'إليو')).single;
      expect([p.designation, p.designationAr], ['Huile Elio 1 L', 'زيت إليو 1 ل']);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('mode IA : le catalogue BENS d’abord, avec son nom arabe', (tester) async {
      final appels = <Uri>[];
      final client = MockClient((req) async {
        appels.add(req.url);
        if (req.url.host == 'catalog-api.bensds.com' && req.url.path == '/products/barcode/6130005000017') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'nom': 'Rouiba Orange 1L',
                'nom_ar': 'رويبة برتقال',
                'brand': 'Rouiba',
                'photo': null,
                'taille': '100 cl',
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
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
      await tester.enterText(_champ('produit_ia_code'), '6130005000017');
      await clic(tester, _cle('produit_ia_rechercher'));
      expect(appels.map((u) => u.host), [
        'catalog-api.bensds.com',
      ], reason: 'trouvé : les autres sources ne sont pas appelées');
      expect(tester.widget<Text>(_cle('ia_fiche_nom')).data, 'Rouiba Orange');
      await clic(tester, _cle('ia_fiche_oui'));
      expect(jsonDecode((await ParametreRepository(c.read(appDatabaseProvider).db).lire(TendanceService.cleVotes))!), [
        {'code_barres': '6130005000017', 'vote': 1},
      ], reason: '« C’est ça » : vote de confirmation (gardé hors ligne)');
      expect(tester.widget<TextField>(_champ('produit_designation')).controller!.text, 'Rouiba Orange');
      expect(tester.widget<TextField>(_champ('produit_designation_ar')).controller!.text, 'رويبة برتقال');
      await tester.enterText(_champ('produit_achat'), '90');
      await tester.pump();
      await clic(tester, _cle('produit_enregistrer'));
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCodeBarres('6130005000017');
      expect([p!.designation, p.taille, p.designationAr, p.marque], ['Rouiba Orange', '1 L', 'رويبة برتقال', 'Rouiba']);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('mode IA : « Ce n’est pas ça » vote contre et ne remplit pas le formulaire', (tester) async {
      final client = MockClient((req) async {
        if (req.url.host == 'catalog-api.bensds.com' && req.url.path == '/products/barcode/6130005000017') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'nom': 'Rouiba Orange 1L', 'brand': 'Rouiba', 'a_confirmer': true, 'confirmation': 3},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
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
      await tester.enterText(_champ('produit_ia_code'), '6130005000017');
      await clic(tester, _cle('produit_ia_rechercher'));
      expect(_cle('ia_fiche_a_confirmer'), findsOneWidget, reason: 'produit d’une boutique, pas encore confirmé');
      await clic(tester, _cle('ia_fiche_non'));
      expect(jsonDecode((await ParametreRepository(c.read(appDatabaseProvider).db).lire(TendanceService.cleVotes))!), [
        {'code_barres': '6130005000017', 'vote': -1},
      ]);
      expect(_cle('ia_fiche_nom'), findsNothing);
      expect(_cle('produit_ia_code'), findsOneWidget, reason: 'le formulaire reste en mode IA, rien n’est rempli');
      expect(find.text('Rouiba Orange'), findsNothing);
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

    /// Fiche détaillée (achat 80, marge 25 % → vente 100) jusqu'aux emballages : boîte de 6 à 420 (70 / pièce, sous
    /// l'achat), carton de 24 à 2 400 (100 / pièce).
    Future<void> saisirEmballages(WidgetTester tester) async {
      await clic(tester, _cle('produit_nouveau'));
      await clic(tester, find.text('Détaillé · 3 étapes'));
      await tester.enterText(_champ('produit_designation'), 'Yaourt');
      await tester.enterText(_champ('produit_achat'), '80');
      await tester.enterText(_champ('produit_marge'), '25');
      await tester.pump();
      await clic(tester, _cle('produit_suivant'));
      await tester.enterText(_champ('produit_colis_0_q'), '6');
      await tester.enterText(_champ('produit_colis_0_p'), '420');
      await tester.enterText(_champ('produit_colis_1_q'), '24');
      await tester.enterText(_champ('produit_colis_1_p'), '2400');
      await tester.pump();
    }

    testWidgets('emballages : prix par pièce affiché, sous l’achat confirmé (Avertir)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await saisirEmballages(tester);
      expect(find.text('70,00 DA / pièce · Inférieur au prix d\'achat'), findsOneWidget);
      expect(find.text('100,00 DA / pièce'), findsOneWidget);
      await clic(tester, _cle('produit_suivant'));
      await clic(tester, _cle('produit_enregistrer'));
      expect(find.text('Vendre sous le prix d\'achat ?'), findsOneWidget);
      expect(find.textContaining('70,00 DA inférieur au prix d\'achat 80,00 DA', findRichText: true), findsOneWidget);
      await clic(tester, find.text('Enregistrer').last);
      final db = c.read(appDatabaseProvider).db;
      final p = await CatalogueRepository(db).produitParCode('PRD0001');
      expect(p!.designation, 'Yaourt');
      final colis = (await CatalogueRepository(db).colis()).where((x) => x.produitCode == 'PRD0001').toList();
      expect({for (final x in colis) x.quantite: x.prixVente}, {6: 420, 24: 2400});
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('emballages : prix par pièce sous l’achat bloquant (Interdire)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await ParametreRepository(c.read(appDatabaseProvider).db)
          .ecrirePlusieurs({ParametresVente.cleVenteSousAchat: ParametresVente.venteSousAchatInterdire});
      c.invalidate(parametresVenteProvider);
      await tester.pumpAndSettle();
      await saisirEmballages(tester);
      expect(
        find.text('70,00 DA / pièce · Prix inférieur au prix d\'achat : interdit par les paramètres.'),
        findsOneWidget,
      );
      await clic(tester, _cle('produit_suivant'));
      expect(tester.widget<DsButton>(_cle('produit_enregistrer')).onPressed, isNull);
      // Boîte remise au-dessus de l'achat (90 / pièce) : enregistrement possible, sans confirmation.
      await clic(tester, find.text('Retour'));
      await tester.enterText(_champ('produit_colis_0_p'), '540');
      await tester.pump();
      expect(find.text('90,00 DA / pièce'), findsOneWidget);
      await clic(tester, _cle('produit_suivant'));
      await clic(tester, _cle('produit_enregistrer'));
      expect(find.text('Vendre sous le prix d\'achat ?'), findsNothing);
      expect(await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001'), isNotNull);
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('colis personnalisés : nom libre (palette), jusqu’à 5, retrait d’une rangée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: const Size(1600, 1000));
      await saisirEmballages(tester);
      await clic(tester, _cle('produit_colis_ajouter'));
      await tester.enterText(_champ('produit_colis_2_nom'), 'Palette');
      await tester.enterText(_champ('produit_colis_2_q'), '10');
      await tester.enterText(_champ('produit_colis_2_p'), '10000');
      await clic(tester, _cle('produit_colis_ajouter'));
      await clic(tester, _cle('produit_colis_ajouter'));
      expect(
        tester.widget<DsButton>(_cle('produit_colis_ajouter')).onPressed,
        isNull,
        reason: '5 colis au plus par produit',
      );
      // La 1ʳᵉ rangée (boîte de 6) est retirée : boîte vide, carton et palette restent.
      await clic(tester, _cle('produit_colis_0_retirer'));
      expect(tester.widget<DsButton>(_cle('produit_colis_ajouter')).onPressed, isNotNull);
      await tester.enterText(_champ('produit_colis_0_nom'), 'Grand carton');
      await tester.pump();
      await clic(tester, _cle('produit_suivant'));
      await clic(tester, _cle('produit_enregistrer'));
      final colis = (await CatalogueRepository(
        c.read(appDatabaseProvider).db,
      ).colis()).where((x) => x.produitCode == 'PRD0001' && x.actif).toList();
      expect(
        {for (final x in colis) x.designation: (x.quantite, x.prixVente)},
        {'Grand carton': (24, 2400.0), 'Palette': (10, 10000.0)},
      );
      await tester.pump(const Duration(seconds: 5)); // fin du toast
    });

    testWidgets('arabe : page Produits en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/produits', locale: const Locale('ar'), taille: const Size(1600, 1000));
      final bouton = _cle('produit_nouveau');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
