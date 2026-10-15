import 'dart:convert';
import 'dart:typed_data';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/caisse/pos_controller.dart';
import 'package:caissedz_desktop/features/entrees/entrees_providers.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
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

MockClient _serveur({required bool quotaAtteint}) => MockClient((req) async {
  if (req.url.path.endsWith('/quota')) {
    return http.Response(jsonEncode({'utilise': quotaAtteint ? 10 : 3, 'total': 10}), 200);
  }
  if (req.url.path.endsWith('/analyser')) {
    if (quotaAtteint) return http.Response('{"erreur":"quota"}', 429);
    return http.Response(
      jsonEncode({
        'fournisseur': 'Grossiste',
        'reference': 'F-2026-12',
        'quota': {'utilise': 4, 'total': 10},
        'lignes': [
          {
            'designation': 'LAIT 1 L',
            'code_barres': '6130000000015',
            'quantite': 20,
            'prix_achat': 85,
            'confiance': 98,
          },
          {'designation': 'Yaourt nature', 'quantite': 6, 'prix_achat': 30, 'confiance': 64},
        ],
      }),
      200,
    );
  }
  if (req.url.path.endsWith('/demande-offre')) return http.Response('{}', 200);
  return http.Response('', 404);
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
      expect(find.text('SS0001'), findsWidgets);
      final db = c.read(appDatabaseProvider).db;
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 2);
      expect(await TiersRepository(db).soldeFournisseur('FOR0001'), 100);
      expect(find.text('Partiel'), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('entrée rapide : un produit payé intégralement, au magasin principal', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: _taille);
      await _donnees(tester, c);
      await clic(tester, _cle('entree_rapide'));
      expect(tester.widget<DsButton>(_cle('rapide_enregistrer')).onPressed, isNull);
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
      await clic(tester, find.text('Mode IA'));
      await clic(tester, _cle('ia_joindre'));
      expect(find.text('Reçu IA · lecture automatique du bon'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('ia_analyser')).onPressed, isNull);
      await clic(tester, _cle('ia_disque'));
      expect(find.text('facture.jpg'), findsOneWidget);
      await clic(tester, _cle('ia_analyser'));
      expect(find.text('LAIT 1 L'), findsOneWidget);
      expect(find.text('Lait 1 L'), findsOneWidget, reason: 'rapproché par code-barres');
      expect(find.text('98 %'), findsOneWidget);
      expect(find.text('1 ligne(s) à rapprocher'), findsOneWidget);
      await _choisir(tester, 'ia_rapprocher_1', '+ Créer « Yaourt nature »');
      expect(find.text('Yaourt nature'), findsWidgets);
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
      final bon = (await c.read(achatServiceProvider).bonsReception()).single;
      expect(bon.statut, StatutsBon.traite);
      expect(bon.achatCode, a.code);
      expect(find.text('Traité'), findsOneWidget);
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
      await clic(tester, find.text('Mode IA'));
      await clic(tester, _cle('ia_joindre'));
      await clic(tester, _cle('ia_offre'));
      await tester.enterText(_champ('offre_email'), 'a@b.dz');
      await tester.pump();
      await clic(tester, _cle('offre_envoyer'));
      expect(find.textContaining('Demande envoyée'), findsOneWidget);
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
