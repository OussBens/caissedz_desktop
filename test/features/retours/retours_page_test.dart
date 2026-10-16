import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

/// Une vente du jour (VTE0001, 2 laits payés) et une entrée fournisseur (SS0001, 10 laits).
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
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 20);
  final tiers = TiersService(db, utilisateurCode: 'USR0000');
  final client = await tiers.creerClient(const Client(code: '', nom: 'Amina', telephone: '0661 12 34 56'));
  final f = await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Djurdjura', telephone: '021 23 45 67'));
  final session = await SessionCaisseService(
    db,
    utilisateurCode: 'USR0000',
  ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  await VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente()).encaisser(
    Panier(id: 1, clientCode: client.code)
        .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
    session: session,
    magasinCode: 'MAG0000',
  );
  await AchatService(db, utilisateurCode: 'USR0000').enregistrer(
    fournisseurCode: f.code,
    magasinCode: 'MAG0000',
    lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
  );
  c.read(commerceVersionProvider.notifier).incrementer();
}

Future<ProviderContainer> _ouvrir(WidgetTester tester) async {
  final c = await pumpApp(tester, routeInitiale: '/retours', taille: const Size(1500, 1000));
  await _donnees(c);
  await tester.pumpAndSettle();
  return c;
}

void main() {
  group('Retours', () {
    testWidgets('nouveau retour client depuis le ticket : stock réintégré, avoir verrouillé au solde', (tester) async {
      final c = await _ouvrir(tester);
      expect(find.text('Retours clients'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('retour_nouveau')));
      expect(find.text('Nouveau retour client'), findsWidgets);
      expect(find.text('Retour fournisseur'), findsNothing);
      await clic(tester, find.byTooltip('Choisir dans la liste').at(1));
      await clic(tester, find.text('VTE0001').last);
      await clic(tester, find.text('Choisir'));
      expect(find.textContaining('Lait 1 L — 2 vendus'), findsOneWidget);
      expect(find.text('Amina'), findsOneWidget); // client repris du ticket
      expect(find.text('VTE0001'), findsOneWidget);
      expect(find.text('Maximum : 2'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('retour_quantite')), '3');
      await tester.pump();
      expect(find.textContaining('Maximum 2'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('retour_quantite')), '1');
      await tester.pump();
      expect(find.text('Avoir au compte du client'), findsOneWidget);
      expect(find.byKey(const ValueKey('retour_remise_stock')), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('retour_enregistrer')));
      expect(find.text('Retour enregistré'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('RET0001'), findsOneWidget);
      final db = c.read(appDatabaseProvider).db;
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 20 - 2 + 10 + 1);
      final v = (await TiersRepository(db).versement('VER0001'))!;
      expect(v.verrouille, isTrue);
      expect(v.montant, 100);
      expect(v.mode, ReglementsRetour.avoir);
    });

    testWidgets('onglet fournisseurs, détail et annulation avec motif', (tester) async {
      final c = await _ouvrir(tester);
      final db = c.read(appDatabaseProvider).db;
      await RetourService(db, utilisateurCode: 'USR0000').creer(
        type: TypesTiers.fournisseur,
        documentCode: 'SS0001',
        produitCode: 'PRD0001',
        quantite: 2,
        reglement: ReglementsRetour.avoir,
        observation: 'Bouteilles percées',
      );
      c.read(commerceVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      await clic(tester, find.text('Retours fournisseurs'));
      expect(find.text('Djurdjura'), findsOneWidget);
      await doubleClic(tester, find.text('RET0001'));
      expect(find.text('Retour RET0001'), findsOneWidget);
      expect(find.text('Bouteilles percées'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.text('RET0001'));
      await clic(tester, find.text('Annuler').first);
      await tester.enterText(find.byType(TextField).last, 'Doublon');
      await tester.pump();
      await clic(tester, find.text('Annuler (1)'));
      expect(find.text('Retours annulés'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      final r = (await TiersRepository(db).retour('RET0001'))!;
      expect(r.actif, isFalse);
      expect((await StockRepository(db).niveau('PRD0001', 'MAG0000')).quantite, 20 - 2 + 10);
    });
  });
}
