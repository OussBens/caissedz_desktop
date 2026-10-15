import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

/// Deux paniers du jour pour Amina : VTE0001 (300 DA à crédit) et VTE0002 (200 DA payés en espèces).
Future<void> _donnees(ProviderContainer c) async {
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
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 50);
  final client = await TiersService(
    db,
    utilisateurCode: 'USR0000',
  ).creerClient(const Client(code: '', nom: 'Amina', telephone: '0661 12 34 56', plafondCredit: 10000));
  final session = await SessionCaisseService(
    db,
    utilisateurCode: 'USR0000',
  ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  final maintenant = DateTime.now();
  await ventes.encaisser(
    Panier(id: 1, clientCode: client.code).ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100)),
    session: session,
    magasinCode: 'MAG0000',
    creditAutorise: true,
    date: maintenant.subtract(const Duration(minutes: 2)),
  );
  await ventes.encaisser(
    Panier(id: 2, clientCode: client.code)
        .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
    session: session,
    magasinCode: 'MAG0000',
    date: maintenant.subtract(const Duration(minutes: 1)),
  );
  c.read(commerceVersionProvider.notifier).incrementer();
}

Future<ProviderContainer> _ouvrir(WidgetTester tester) async {
  final c = await pumpApp(tester, routeInitiale: '/ventes', taille: const Size(1500, 1000));
  await _donnees(c);
  await tester.pumpAndSettle();
  return c;
}

void main() {
  group('Ventes (paniers)', () {
    testWidgets('liste du jour, KPIs, filtre Crédit, vérification du scellement', (tester) async {
      await _ouvrir(tester);
      expect(find.text('VTE0001'), findsOneWidget);
      expect(find.text('VTE0002'), findsOneWidget);
      expect(find.textContaining('500,00', findRichText: true), findsWidgets); // chiffre d'affaires
      expect(find.text('Nombre de ventes'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('filtre_statut_panier')));
      await clic(tester, find.text('Crédit').last);
      expect(find.text('VTE0001'), findsOneWidget);
      expect(find.text('VTE0002'), findsNothing);
      await clic(tester, find.byKey(const ValueKey('ventes_verifier_chaine')));
      expect(find.text('Chaîne de tickets intacte.'), findsOneWidget);
    });

    testWidgets('détail puis modification : complément payé en versement imputé, statut Payé', (tester) async {
      final c = await _ouvrir(tester);
      await doubleClic(tester, find.text('VTE0001'));
      expect(find.text('Panier VTE0001'), findsOneWidget);
      expect(find.text('Produits du panier'), findsOneWidget);
      expect(find.text('Paiement & marge'), findsOneWidget);
      await clic(tester, find.text('Modifier').last);
      expect(find.text('Modifier le panier'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('panier_montant_paye')), '300');
      await tester.enterText(find.byKey(const ValueKey('panier_observation')), 'Soldé au comptoir');
      await clic(tester, find.byKey(const ValueKey('panier_modifier_enregistrer')));
      expect(find.text('Modifier le panier'), findsNothing);
      final db = c.read(appDatabaseProvider).db;
      final versement = (await TiersRepository(db).versement('VER0001'))!;
      expect(versement.montant, 300);
      expect(versement.imputations.single.documentCode, 'VTE0001');
      expect((await VenteRepository(db).vente('VTE0001'))!.commentaire, 'Soldé au comptoir');
      expect(find.text('Payé'), findsWidgets);
      await tester.pump(const Duration(seconds: 5)); // fin du toast « Panier modifié »
    });

    testWidgets('annulation avec motif : stock réintégré, statut Annulé', (tester) async {
      final c = await _ouvrir(tester);
      await clic(tester, find.text('VTE0002'));
      await clic(tester, find.text('Annuler').first);
      await tester.enterText(find.byType(TextField).last, 'Erreur de saisie');
      await tester.pump();
      await clic(tester, find.text('Annuler (1)'));
      expect(find.text('Paniers annulés'), findsOneWidget);
      final v = (await VenteRepository(c.read(appDatabaseProvider).db).vente('VTE0002'))!;
      expect(v.statut, 'Annulée');
    });

    testWidgets('« Nouvelle vente » ouvre la caisse', (tester) async {
      await pumpApp(tester, routeInitiale: '/ventes', taille: const Size(1500, 1000));
      await clic(tester, find.byKey(const ValueKey('ventes_nouvelle')));
      expect(find.byKey(const ValueKey('ventes_nouvelle')), findsNothing);
    });
  });
}
