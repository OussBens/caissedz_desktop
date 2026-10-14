import 'dart:convert';
import 'dart:typed_data';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/achats/smart_scan_dialog.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';

Future<void> _donnees(ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  final cat = CatalogueService(db, utilisateurCode: 'USR0000');
  await cat.creerProduit(
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
  c.read(commerceVersionProvider.notifier).incrementer();
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.invalidate(serveurCaisseDzProvider);
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
          {'designation': 'LAIT 1 L', 'code_barres': '6130000000015', 'quantite': 20, 'prix_achat': 85},
          {'designation': 'Inconnu', 'quantite': 1, 'prix_achat': 10},
        ],
      }),
      200,
    );
  }
  if (req.url.path.endsWith('/demande-offre')) return http.Response('{}', 200);
  return http.Response('', 404);
});

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle).last, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Entrées / Achats', () {
    testWidgets('nouvelle entrée manuelle : stock, prix d’achat, reste fournisseur, puis annulation', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/entrees', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.text('Aucune entrée.'), findsOneWidget);
      await clic(tester, find.text('Nouvelle entrée'));
      await clic(tester, find.text('Fournisseur divers'));
      await clic(tester, find.text('Grossiste').last);
      await clic(tester, find.text('Ajouter un produit'));
      await clic(tester, find.text('Lait 1 L').last);
      await tester.enterText(find.byKey(const ValueKey('aq_PRD0001')), '20');
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('ap_PRD0001')), '85');
      await tester.pump();
      await tester.enterText(_champ('Versé'), '500');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('ACH0001'), findsWidgets);
      await clic(tester, find.text('OK'));
      expect(find.text('ACH0001'), findsOneWidget);
      expect(find.text('Grossiste'), findsOneWidget);
      final db = c.read(appDatabaseProvider).db;
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 20);
      expect((await CatalogueRepository(db).produitParCode('PRD0001'))!.prixAchat, 85);
      expect(await TiersRepository(db).soldeFournisseur('FOR0001'), 1200);
      // Annulation via le menu contextuel.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('ACH0001')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await clic(tester, find.text("Annuler l'entrée"));
      await clic(tester, find.text('Confirmer'));
      expect(find.text('Annulé'), findsOneWidget);
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 0);
    });

    testWidgets('Smart Scan : analyse, rapprochement par code-barres, création de l’entrée', (tester) async {
      final c = await pumpApp(
        tester,
        routeInitiale: '/entrees',
        taille: const Size(1400, 900),
        overrides: [
          httpClientProvider.overrideWithValue(_serveur(quotaAtteint: false)),
          selecteurFactureProvider.overrideWithValue(
            () async => XFile.fromData(Uint8List.fromList([1, 2, 3]), path: 'facture.jpg'),
          ),
        ],
      );
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Smart Scan IA'));
      expect(find.textContaining('7 analyse(s) restante(s) sur 10'), findsOneWidget);
      await clic(tester, find.text('Choisir une facture'));
      expect(find.text('facture.jpg'), findsOneWidget);
      await clic(tester, find.text('Analyser'));
      expect(find.textContaining('6 analyse(s) restante(s)'), findsOneWidget);
      expect(find.text('LAIT 1 L'), findsOneWidget);
      expect(find.text('PRD0001'), findsOneWidget);
      expect(find.text('Non rapprochée'), findsOneWidget);
      await clic(tester, find.text("Créer l'entrée"));
      expect(find.text('Nouvelle entrée'), findsWidgets);
      expect(find.text('F-2026-12'), findsOneWidget);
      await clic(tester, find.text('Fournisseur divers'));
      await clic(tester, find.text('Grossiste').last);
      await clic(tester, find.text('Valider'));
      await clic(tester, find.text('OK'));
      expect(find.text('ACH0001'), findsOneWidget);
      expect(find.text('Smart Scan'), findsOneWidget);
      expect((await StockRepository(c.read(appDatabaseProvider).db).niveau('PRD0001', 'MAG0000')).quantite, 20);
    });

    testWidgets('Smart Scan : quota atteint et demande d’offre', (tester) async {
      final c = await pumpApp(
        tester,
        routeInitiale: '/entrees',
        taille: const Size(1400, 900),
        overrides: [httpClientProvider.overrideWithValue(_serveur(quotaAtteint: true))],
      );
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Smart Scan IA'));
      expect(find.text('Quota Smart Scan atteint'), findsOneWidget);
      await clic(tester, find.text('Demander une offre'));
      await tester.enterText(_champ('Votre e-mail'), 'a@b.dz');
      await tester.pump();
      await clic(tester, find.text('Demander une offre').last);
      expect(find.textContaining('Demande envoyée'), findsOneWidget);
    });
  });
}
