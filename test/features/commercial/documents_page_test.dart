import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/document_commercial_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/data/documents_commerciaux_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/caisse/pos_dialogs.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Future<void> _donnees(WidgetTester tester, ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  final lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
    const Produit(
      code: '',
      designation: 'Lait 1 L',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
    ),
  );
  await StockService(
    db,
    utilisateurCode: 'USR0000',
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 20);
  await TiersService(db, utilisateurCode: 'USR0000').creerClient(const Client(code: '', nom: 'Amina'));
  await TiersService(db, utilisateurCode: 'USR0000').creerFournisseur(const Fournisseur(code: '', nom: 'Cevital'));
  await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.read(stockVersionProvider.notifier).incrementer();
  c.read(commerceVersionProvider.notifier).incrementer();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('devis saisi au prix de vente, transformé en commande, livré en partie (BL + vente)', (tester) async {
    final c = await pumpApp(
      tester,
      routeInitiale: '/documents',
      taille: _taille,
      overrides: [apercuPdfProvider.overrideWithValue((cle, pdf, nom) => Text(nom, key: cle))],
    );
    await _donnees(tester, c);
    await clic(tester, _cle('doc_nouveau_Devis'));
    await clic(tester, _cle('doc_client'));
    await clic(tester, find.text('Amina').last);
    await clic(tester, find.text('Ajouter des produits').last);
    await clic(tester, find.text('Lait 1 L').last);
    await clic(tester, find.text('Ajouter').last);
    final qte = find
        .descendant(of: find.byKey(const ValueKey<Object>('PRD0001')), matching: find.byType(TextField))
        .first;
    await tester.enterText(qte, '5');
    await tester.pump();
    expect(find.text('595,00 DA'), findsWidgets, reason: '5 × (prix de vente HT 100 + TVA 19 %)');
    await clic(tester, _cle('doc_enregistrer'));
    await tester.pump(const Duration(seconds: 5)); // toast refermé
    await tester.pumpAndSettle();
    expect(find.text('DEV0001'), findsOneWidget);

    await clic(tester, find.text('DEV0001'));
    await clic(tester, _cle('doc_transformer'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Transformé en commande'), findsOneWidget);
    await clic(tester, find.text('Commandes clients'));
    expect(find.text('BCC0001'), findsOneWidget);
    await clic(tester, find.text('BCC0001'));
    await clic(tester, _cle('doc_livrer'));
    expect(find.text('Livrer la commande BCC0001'), findsOneWidget);
    await tester.enterText(find.descendant(of: _cle('livraison_qte_0'), matching: find.byType(TextField)), '2');
    await tester.pump();
    // « Payé en totalité » : le montant payé reprend le total livré (2 × 119), champ verrouillé.
    await clic(tester, _cle('livraison_paye_totalite'));
    expect(_cle('livraison_paye'), findsNothing);
    expect(_cle('livraison_paye_238,00'), findsOneWidget);
    await clic(tester, _cle('livraison_valider'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Partiellement livrée'), findsOneWidget);
    final db = c.read(appDatabaseProvider).db;
    expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 18);
    await clic(tester, find.text('Bons de livraison'));
    expect(find.text('LIV0001'), findsOneWidget);
    expect((await DocumentsCommerciauxRepository(db).livraison('LIV0001'))!.venteCode, 'VTE0001');
    final vente = (await VenteRepository(db).vente('VTE0001'))!;
    expect((vente.totalNet, vente.reste), (238, 0), reason: 'payé en totalité');
    await tester.pump(const Duration(seconds: 5));
    // Aperçu A4 du bon de livraison avant impression.
    await clic(tester, find.text('LIV0001'));
    await clic(tester, _cle('livraison_imprimer'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_cle('apercu_document'), findsOneWidget);
    expect(_cle('apercu_imprimer'), findsOneWidget);
    await clic(tester, _cle('apercu_fermer'));
  });

  testWidgets('commande fournisseur : réception pré-remplie, solde du reliquat', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/commandes-fournisseurs', taille: _taille);
    await _donnees(tester, c);
    final db = c.read(appDatabaseProvider).db;
    await CommandeFournisseurService(db, utilisateurCode: 'USR0000').creer(
      fournisseurCode: 'FOR0001',
      magasinCode: 'MAG0000',
      lignes: [const DemandeLigneDocument(produitCode: 'PRD0001', quantite: 10, prix: 80)],
    );
    c.read(commerceVersionProvider.notifier).incrementer();
    await tester.pumpAndSettle();
    expect(find.text('BCF0001'), findsOneWidget);
    expect(find.text('En cours'), findsWidgets);
    await clic(tester, find.text('BCF0001'));
    await clic(tester, _cle('cmdf_receptionner'));
    expect(find.byKey(const ValueKey('entree_fournisseur')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    if (find.byKey(const ValueKey('entree_fournisseur')).evaluate().isNotEmpty) {
      await clic(tester, find.text('Annuler').last);
    }
    await clic(tester, find.text('BCF0001'));
    await clic(tester, _cle('cmdf_solder'));
    await clic(tester, find.text('Solder').last);
    expect(find.text('Soldée'), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
  });
}
