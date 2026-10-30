import 'dart:convert';
import 'dart:typed_data';

import 'package:caissedz_desktop/app/mobile_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/serveur_mobile.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/caisse/pos_controller.dart';
import 'package:caissedz_desktop/features/entrees/entrees_providers.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';
import '../../helpers/bases.dart';

const _taille = Size(1600, 1000);

Future<void> _donnees(WidgetTester tester, ProviderContainer c, {bool session = true}) async {
  final db = c.read(appDatabaseProvider).db;
  await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
    const Produit(
      code: '',
      designation: 'Lait 1 L',
      codeBarres: '6130000000015',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
    ),
  );
  await TiersService(db, utilisateurCode: 'USR0000').creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
  await ParametreRepository(db).ecrire('serveur_url', 'https://api.test');
  if (session) await ouvrirSessionDeTest(db);
  c.read(commerceVersionProvider.notifier).incrementer();
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.invalidate(serveurCaisseDzProvider);
  await tester.pumpAndSettle();
}

/// Le serveur Smart Scan (catalog-api.bensds.com/smartscan/*) : quota par lots, OCR, extraction.
MockClient _serveur({required bool quotaAtteint}) => MockClient((req) async {
  final quota = {'limit': 10, 'used': quotaAtteint ? 10 : 3, 'remaining': quotaAtteint ? 0 : 7, 'buckets': []};
  if (req.url.path.endsWith('/smartscan/quota')) {
    return http.Response(jsonEncode({'success': true, 'quota': quota}), 200);
  }
  if (req.url.path.endsWith('/smartscan/scan')) {
    if (quotaAtteint) {
      return http.Response(jsonEncode({'success': false, 'error': 'SCAN_QUOTA_EXCEEDED', 'quota': quota}), 429);
    }
    return http.Response(
      jsonEncode({'success': true, 'scan_id': 1, 'text': 'Grossiste F-2026-12 LAIT 1 L', 'quota': quota}),
      200,
    );
  }
  if (req.url.path.endsWith('/smartscan/extract')) {
    final contenu = jsonEncode({
      'fournisseur': 'Grossiste',
      'reference': 'F-2026-12',
      'lignes': [
        {
          'designation': 'LAIT 1 L',
          'code_barres': '6130000000015',
          'quantite': 20,
          'prix_unitaire': 85,
          'confiance': 98,
        },
        {'designation': 'Yaourt nature', 'quantite': 6, 'prix_unitaire': 30, 'confiance': 64},
      ],
    });
    return http.Response(
      jsonEncode({
        'choices': [
          {
            'message': {'content': contenu},
          },
        ],
      }),
      200,
    );
  }
  return http.Response('{}', 404);
});

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

Future<void> _choisir(WidgetTester tester, String cle, String option) async {
  await clic(tester, _cle(cle));
  await clic(tester, find.text(option).last);
}

void main() {
  group('Entrées (DS v2.2)', () {
    testWidgets('Smart Scan : en-tête, scan continu, paiement partiel, puis détail', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      expect(find.text('Aucune entrée.'), findsOneWidget);
      await clic(tester, _cle('entree_nouvelle'));
      expect(find.text('Nouvelle entrée · Smart Scan'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('entree_suivant')).onPressed, isNull, reason: 'fournisseur obligatoire');
      await _choisir(tester, 'entree_fournisseur', 'Grossiste');
      await tester.enterText(_champ('entree_reference'), 'FAC-12');
      await clic(tester, _cle('entree_suivant'));
      final scan = find.descendant(of: find.byType(DsSearchField), matching: find.byType(TextField)).last;
      for (final code in ['PRD0001', '6130000000015']) {
        await tester.enterText(scan, code);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }
      expect(find.text('Lait 1 L · +1'), findsOneWidget);
      final ligne = find.byKey(const ValueKey<Object>('PRD0001'));
      expect(find.descendant(of: ligne, matching: find.text('2')), findsOneWidget);
      // Retour à l'étape 1 : paiement partiel.
      await clic(tester, find.text('Retour'));
      await clic(tester, _cle('paiement_totalite'));
      await tester.enterText(_champ('paiement_montant'), '60');
      await tester.pump();
      await clic(tester, _cle('entree_suivant'));
      await clic(tester, _cle('entree_valider'));
      expect(find.text('ENT0001'), findsWidgets);
      final db = c.read(appDatabaseProvider).db;
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 2);
      expect(await TiersRepository(db).soldeFournisseur('FOR0001'), 100);
      expect(find.text('Partiel'), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('nouvelle entrée : « Manuel » ajoute un produit choisi avec sa quantité et ses prix', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await clic(tester, _cle('entree_nouvelle'));
      await _choisir(tester, 'entree_fournisseur', 'Grossiste');
      await clic(tester, _cle('entree_suivant'));
      await clic(tester, _cle('entree_manuel'));
      expect(find.text('Ajouter un produit'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('manuel_ajouter')).onPressed, isNull, reason: 'produit obligatoire');
      await _choisir(tester, 'manuel_produit', 'Lait 1 L');
      expect(tester.widget<TextField>(_champ('manuel_prix')).controller!.text, '80', reason: 'prix de la fiche');
      await tester.enterText(_champ('manuel_quantite'), '12');
      await tester.enterText(_champ('manuel_prix'), '85');
      await tester.enterText(_champ('manuel_vente'), '110');
      await tester.pump();
      await clic(tester, _cle('manuel_ajouter'));
      final ligne = find.byKey(const ValueKey<Object>('PRD0001'));
      expect(find.descendant(of: ligne, matching: find.text('12')), findsOneWidget);
      // Le même produit une 2ᵉ fois : quantité ajoutée à la ligne existante.
      await clic(tester, _cle('entree_manuel'));
      await _choisir(tester, 'manuel_produit', 'Lait 1 L');
      await tester.enterText(_champ('manuel_quantite'), '3');
      await tester.pump();
      await clic(tester, _cle('manuel_ajouter'));
      expect(find.descendant(of: ligne, matching: find.text('15')), findsOneWidget);
      await clic(tester, _cle('entree_valider'));
      final a = (await c.read(achatServiceProvider).achats()).single;
      expect(a.lignes.single.quantite, 15);
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 15);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('entrée rapide : un produit payé intégralement, au magasin principal', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await clic(tester, _cle('entree_rapide'));
      expect(tester.widget<DsButton>(_cle('rapide_enregistrer')).onPressed, isNull);
      expect(find.text('Répartition (option)'), findsNothing, reason: 'un seul magasin : tout au principal');
      await _choisir(tester, 'rapide_produit', 'Lait 1 L');
      await tester.enterText(_champ('rapide_quantite'), '5');
      await tester.pump();
      await clic(tester, _cle('rapide_enregistrer'));
      final a = (await c.read(achatServiceProvider).achats()).single;
      expect(a.source, SourcesAchat.rapide);
      expect(a.total, 400);
      expect(a.statutPaiement, 'paye');
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 5);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('entrée rapide : prix de vente proposé par la marge, modifiable, appliqué au produit', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await clic(tester, _cle('entree_rapide'));
      await _choisir(tester, 'rapide_produit', 'Lait 1 L');
      TextField vente() => tester.widget<TextField>(_champ('rapide_vente'));
      expect(vente().controller!.text, '100', reason: 'prix de vente actuel du produit');
      // Prix d'achat 120 avec la marge du produit (25 %) : 150.
      await tester.enterText(_champ('rapide_prix'), '120');
      await tester.pump();
      expect(vente().controller!.text, '150');
      // Saisi à la main, le prix de vente ne suit plus le prix d'achat.
      await tester.enterText(_champ('rapide_vente'), '170');
      await tester.pump();
      await tester.enterText(_champ('rapide_prix'), '110');
      await tester.pump();
      expect(vente().controller!.text, '170');
      await tester.enterText(_champ('rapide_quantite'), '2');
      await tester.pump();
      await clic(tester, _cle('rapide_enregistrer'));
      final p = await CatalogueRepository(c.read(appDatabaseProvider).db).produitParCode('PRD0001');
      expect(p!.prixAchat, 110);
      expect(p.prixVente, 170);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('entrée rapide : vente sous achat « Interdire » bloque l’enregistrement', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await ParametreRepository(c.read(appDatabaseProvider).db)
          .ecrirePlusieurs({ParametresVente.cleVenteSousAchat: ParametresVente.venteSousAchatInterdire});
      c.invalidate(parametresVenteProvider);
      await tester.pumpAndSettle();
      await clic(tester, _cle('entree_rapide'));
      await _choisir(tester, 'rapide_produit', 'Lait 1 L');
      await tester.enterText(_champ('rapide_vente'), '70');
      await tester.pump();
      expect(find.text("Prix inférieur au prix d'achat : interdit par les paramètres."), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('rapide_enregistrer')).onPressed, isNull);
      await tester.enterText(_champ('rapide_vente'), '95');
      await tester.pump();
      expect(tester.widget<DsButton>(_cle('rapide_enregistrer')).onPressed, isNotNull);
    });

    testWidgets('entrée rapide : la répartition seulement en Max avec plusieurs magasins', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await StockService(c.read(appDatabaseProvider).db, utilisateurCode: 'USR0000').creerMagasin('Dépôt');
      c.read(stockVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      await clic(tester, _cle('entree_rapide'));
      expect(find.text('Répartition (option)'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('§8.4 : sans session, la caisse fermée propose l’ouverture avant l’entrée rapide', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c, session: false);
      await clic(tester, _cle('entree_rapide'));
      expect(find.text('Aucune session ouverte'), findsOneWidget);
      expect(find.byKey(const ValueKey('rapide_enregistrer')), findsNothing);
      await clic(tester, _cle('caisse_fermee_ouvrir'));
      await clic(tester, _cle('ouverture_valider'));
      expect(await c.read(sessionCaisseServiceProvider).courante(), isNotNull);
      expect(find.byKey(const ValueKey('rapide_enregistrer')), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Mode IA : analyse, rapprochement, création de produit, entrée et bon traité', (tester) async {
      final c = await pumpApp(
        tester,
        routeInitiale: '/entrees',
        taille: _taille,
        overrides: [
          httpClientProvider.overrideWithValue(_serveur(quotaAtteint: false)),
          selecteurFactureProvider.overrideWithValue(
            () async => XFile.fromData(Uint8List.fromList([1, 2, 3]), path: 'facture.jpg'),
          ),
        ],
      );
      await _donnees(tester, c);
      await clic(tester, find.text('Smart Scan').first);
      await clic(tester, _cle('ia_joindre'));
      expect(find.text('Reçu IA · lecture automatique du bon'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('ia_analyser')).onPressed, isNull);
      await clic(tester, _cle('ia_disque'));
      expect(find.byKey(const ValueKey('ia_apercu_facture.jpg')), findsOneWidget, reason: 'aperçu de la photo');
      expect(find.byType(DsImageZoom), findsOneWidget, reason: 'aperçu zoomable');
      await clic(tester, _cle('ia_analyser'));
      expect(find.text('LAIT 1 L'), findsOneWidget);
      expect(find.text('Lait 1 L'), findsOneWidget, reason: 'rapproché par code-barres');
      expect(find.text('98 %'), findsOneWidget);
      expect(find.text('1 ligne(s) à rapprocher'), findsOneWidget);
      // Produit absent du catalogue : le formulaire s'ouvre rempli (désignation, fournisseur, prix d'achat).
      await clic(tester, _cle('ia_creer_produit_1'));
      expect(
        tester
            .widget<TextField>(find.descendant(of: _cle('produit_designation'), matching: find.byType(TextField)))
            .controller!
            .text,
        'Yaourt nature',
      );
      expect(find.descendant(of: _cle('produit_achat'), matching: find.byType(TextField)), findsOneWidget);
      expect(find.text('Grossiste'), findsWidgets, reason: 'fournisseur du bon proposé');
      // Stock initial à 0 : les 6 de la facture entrent avec l'entrée du bon (pas de double comptage).
      expect(find.text("6 entreront en stock avec l'entrée du bon."), findsOneWidget);
      final stockInitial = find.descendant(of: _cle('produit_stock_initial'), matching: find.byType(TextField));
      expect(tester.widget<TextField>(stockInitial).enabled, isFalse);
      await clic(tester, _cle('produit_enregistrer'));
      expect(_cle('produit_enregistrer'), findsNothing);
      expect(find.text('Yaourt nature'), findsWidgets);
      expect(find.text('1 ligne(s) à rapprocher'), findsNothing, reason: 'le produit créé est choisi pour la ligne');
      await clic(tester, _cle('ia_suivant'));
      expect(
        find.descendant(of: _cle('ia_fournisseur'), matching: find.text('Grossiste')),
        findsOneWidget,
        reason: 'fournisseur détecté sur le bon',
      );
      expect(find.text('F-2026-12'), findsOneWidget);
      await clic(tester, _cle('ia_creer'));
      final a = (await c.read(achatServiceProvider).achats()).single;
      expect(a.source, SourcesAchat.ia);
      expect(a.lignes.length, 2);
      expect(a.reference, 'F-2026-12');
      final db = c.read(appDatabaseProvider).db;
      expect((await StockRepository(db).niveau(a.lignes.last.produitCode, 'MAG0000')).quantite, 6);
      final bon = (await c.read(achatServiceProvider).bonsReception()).single;
      expect(bon.statut, StatutsBon.traite);
      expect(bon.achatCode, a.code);
      expect(find.text('Traité'), findsOneWidget);
      expect(bon.lignes.every((l) => l.traitee), isTrue);
      // Détail du bon : chaque ligne lue reprise dans l'entrée est marquée « Traité ».
      await doubleClic(tester, find.text(bon.code));
      expect(_cle('bon_ligne_traitee_0'), findsOneWidget);
      expect(_cle('bon_ligne_traitee_1'), findsOneWidget);
      expect(find.byType(DsImageZoom), findsNothing, reason: 'photo du disque absente : les lignes seules');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Mode IA : quota atteint et demande d’offre', (tester) async {
      final c = await pumpApp(
        tester,
        routeInitiale: '/entrees',
        taille: _taille,
        overrides: [httpClientProvider.overrideWithValue(_serveur(quotaAtteint: true))],
      );
      await _donnees(tester, c);
      await clic(tester, find.text('Smart Scan').first);
      await clic(tester, _cle('ia_joindre'));
      // Un pack se demande depuis le compte BENS du poste (activé ici par une clé collée, sans compte).
      await clic(tester, _cle('ia_offre'));
      expect(
        find.text('Connectez ce poste à votre compte BENS pour acheter des packs (Paramètres › Licence).'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('photo envoyée par le téléphone : pop-up, puis l’onglet Smart Scan', (tester) async {
      final c = await pumpApp(
        tester,
        routeInitiale: '/caisse',
        taille: _taille,
        overrides: [httpClientProvider.overrideWithValue(_serveur(quotaAtteint: false))],
      );
      c.read(factureMobileProvider.notifier).recue(const FactureMobile(bon: 'BON0001', utilisateur: 'Karim'));
      await tester.pumpAndSettle();
      expect(find.text('Facture reçue du téléphone'), findsOneWidget);
      expect(find.text('Karim a envoyé une photo de facture (BON0001).'), findsOneWidget);
      await clic(tester, _cle('facture_mobile_smart_scan'));
      expect(find.text('Facture reçue du téléphone'), findsNothing);
      expect(_cle('ia_joindre'), findsOneWidget, reason: 'Entrées ouvert sur l’onglet Smart Scan');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('arabe : écran Entrées en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/entrees', locale: const Locale('ar'), taille: _taille);
      final bouton = _cle('entree_nouvelle');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
