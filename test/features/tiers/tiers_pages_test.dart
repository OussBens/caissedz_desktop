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

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle).last, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Ventes, retours, clients, versements', () {
    testWidgets('liste des ventes, filtre à crédit, vérification de la chaîne, annulation', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/ventes', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.text('VTE0001'), findsOneWidget);
      expect(find.text('VTE0002'), findsOneWidget);
      await clic(tester, find.text('À crédit'));
      expect(find.text('VTE0001'), findsOneWidget);
      expect(find.text('VTE0002'), findsNothing);
      await clic(tester, find.text('Vérifier le scellement'));
      expect(find.text('Chaîne de tickets intacte.'), findsOneWidget);
    });

    testWidgets('retour depuis la liste des ventes : stock restitué, remboursement verrouillé', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/retours', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Nouveau retour'));
      await clic(tester, find.textContaining('VTE0002').last);
      await clic(tester, find.text('Choisir'));
      await tester.enterText(find.byKey(const ValueKey('retour_PRD0001')), '1');
      await tester.enterText(_champ('Montant remboursé'), '100');
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('Retour RET0001 enregistré'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect(find.text('RET0001'), findsOneWidget);
      final v = (await TiersRepository(c.read(appDatabaseProvider).db).versement('VER0001'))!;
      expect(v.verrouille, isTrue);
      expect(v.montant, 100);
    });

    testWidgets('clients : solde dû, versement imputé au plus ancien, fiche', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clients', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      expect(find.text('Amina'), findsOneWidget);
      expect(find.text('300,00 DA'), findsOneWidget); // solde dû
      await clic(tester, find.text('Nouveau client'));
      await tester.enterText(_champ('Nom'), 'Sofiane');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Sofiane'), findsOneWidget);
      // Versement via la page Versements
      final repo = TiersRepository(c.read(appDatabaseProvider).db);
      expect(await repo.soldeClient('CLN0001'), 300);
    });

    testWidgets('versements : création client avec aperçu des imputations, suppression', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/versements', taille: const Size(1400, 900));
      await _donnees(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Nouveau versement'));
      await clic(tester, find.text('Client'));
      await clic(tester, find.text('Amina'));
      await clic(tester, find.text('Choisir'));
      expect(find.text('Imputations (plus ancien d\'abord)'), findsOneWidget);
      expect(find.textContaining('VTE0001'), findsOneWidget);
      await tester.enterText(_champ('Montant'), '120');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('Versement VER0001 enregistré'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect(find.text('VER0001'), findsOneWidget);
      final repo = TiersRepository(c.read(appDatabaseProvider).db);
      expect(await repo.soldeClient('CLN0001'), 180);
      expect((await repo.versement('VER0001'))!.imputations.single.documentCode, 'VTE0001');
    });

    testWidgets('fournisseurs : création', (tester) async {
      await pumpApp(tester, routeInitiale: '/fournisseurs', taille: const Size(1400, 900));
      expect(find.text('Fournisseur divers'), findsOneWidget);
      await clic(tester, find.text('Nouveau fournisseur'));
      await tester.enterText(_champ('Nom'), 'Grossiste Sud');
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Grossiste Sud'), findsOneWidget);
      expect(find.text('FOR0001'), findsOneWidget);
    });
  });
}
