import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/commun/carte_entite.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Future<void> _donnees(ProviderContainer c) async {
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
  await StockService(
    db,
    utilisateurCode: 'USR0000',
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 50);
  final client = await TiersService(
    db,
    utilisateurCode: 'USR0000',
  ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 10000));
  final session = await SessionCaisseService(
    db,
    utilisateurCode: 'USR0000',
  ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  await ventes.encaisser(
    Panier(id: 1, clientCode: client.code).ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100)),
    session: session,
    magasinCode: 'MAG0000',
    creditAutorise: true,
    date: DateTime(2026, 1, 5),
  );
  await ventes.encaisser(
    Panier(id: 2, clientCode: client.code)
        .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
    session: session,
    magasinCode: 'MAG0000',
    date: DateTime(2026, 1, 6),
  );
  c.read(commerceVersionProvider.notifier).incrementer();
}

void main() {
  group('Ventes, retours, clients, versements', () {
    testWidgets('clients : crédit calculé, création avec téléphone valide, détail', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clients', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.text('Amina'), findsOneWidget);
      expect(find.text('300,00 DA'), findsWidgets); // crédit de la ligne et total
      await clic(tester, find.byKey(const ValueKey('client_nouveau')));
      await tester.enterText(find.byKey(const ValueKey('tiers_nom')), 'Sofiane');
      await tester.enterText(find.byKey(const ValueKey('tiers_tel')), '0661');
      await tester.pump();
      expect(find.text('Format attendu : 0X XX XX XX XX'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('tiers_tel')), '0661 12 34 56');
      await clic(tester, find.byKey(const ValueKey('tiers_enregistrer')));
      expect(find.text('Sofiane'), findsOneWidget);
      await doubleClic(tester, find.text('Amina'));
      expect(find.text('Informations générales'), findsOneWidget);
      expect(find.text('VTE0001'), findsOneWidget);
    });

    testWidgets('clients et fournisseurs : affichage liste ou grille', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clients', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      final vue = find.byKey(const ValueKey('module_vue'));
      await clic(tester, find.descendant(of: vue, matching: find.byTooltip('Affichage grille')));
      final carte = find.widgetWithText(CarteEntite, 'Amina');
      expect(carte, findsOneWidget);
      expect(find.descendant(of: carte, matching: find.text('300,00 DA')), findsOneWidget);
      await doubleClic(tester, carte);
      expect(find.text('Informations générales'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.descendant(of: vue, matching: find.byTooltip('Affichage liste')));
      expect(find.byType(CarteEntite), findsNothing);
      expect(find.text('Amina'), findsOneWidget);
    });

    testWidgets('versement client depuis le détail : imputé au plus ancien, onglet Versements', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clients', taille: const Size(1600, 1000));
      await _donnees(c);
      await tester.pumpAndSettle();
      await doubleClic(tester, find.text('Amina'));
      await clic(tester, find.text('Versement').last);
      await tester.enterText(find.byKey(const ValueKey('versement_montant')), '120');
      await tester.pump();
      expect(find.text('Crédit restant après ce versement'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('versement_enregistrer')));
      final repo = TiersRepository(c.read(appDatabaseProvider).db);
      expect(await repo.soldeClient('CLN0001'), 180);
      expect((await repo.versement('VER0001'))!.imputations.single.documentCode, 'VTE0001');
      await clic(tester, find.text('Versements'));
      expect(find.text('VER0001'), findsOneWidget);
    });

    testWidgets('route Versements : onglet Versements des clients', (tester) async {
      await pumpApp(tester, routeInitiale: '/versements', taille: const Size(1600, 1000));
      expect(find.byKey(const ValueKey('versement_nouveau')), findsOneWidget);
      expect(find.text('Versement retour'), findsOneWidget);
    });

    testWidgets('fournisseurs : création', (tester) async {
      await pumpApp(tester, routeInitiale: '/fournisseurs', taille: const Size(1600, 1000));
      expect(find.text('Fournisseur divers'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('fournisseur_nouveau')));
      await tester.enterText(find.byKey(const ValueKey('tiers_nom')), 'Grossiste Sud');
      await tester.enterText(find.byKey(const ValueKey('tiers_tel')), '021 23 45 67');
      await clic(tester, find.byKey(const ValueKey('tiers_enregistrer')));
      expect(find.text('Grossiste Sud'), findsOneWidget);
      expect(find.text('FOR0001'), findsOneWidget);
    });
  });
}
