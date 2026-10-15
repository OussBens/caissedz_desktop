import 'dart:typed_data';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/domain/historique.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/rapports/rapports_providers.dart';
import 'package:caissedz_desktop/features/zakat/zakat_dialogs.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Future<void> _jeu(ProviderContainer c) async {
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
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
  final client = await TiersService(
    db,
    utilisateurCode: 'USR0000',
  ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 5000));
  final s = await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  await ventes.encaisser(
    const Panier(id: 1)
        .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
    session: s,
    magasinCode: 'MAG0000',
  );
  await ventes.encaisser(
    Panier(id: 2, clientCode: client.code).ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100)),
    session: s,
    magasinCode: 'MAG0000',
    creditAutorise: true,
  );
  c.read(rapportsVersionProvider.notifier).incrementer();
}

Finder _dansCle(String cle) => find.descendant(of: find.byKey(ValueKey(cle)), matching: find.byType(TextField)).first;

void main() {
  testWidgets('tableau de bord : 6 KPI, 5 graphiques, dernières ventes, navigation des KPI', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/tableau-de-bord', taille: const Size(1500, 1000));
    await _jeu(c);
    await tester.pumpAndSettle();
    expect(find.byType(DsStatCard), findsNWidgets(6));
    expect(find.text('Dette fournisseurs'), findsOneWidget);
    expect(find.textContaining('500,00', findRichText: true), findsWidgets); // ventes = net (aucun achat)
    expect(find.byType(DsLineChart), findsOneWidget);
    expect(find.byType(DsBarChart), findsOneWidget);
    expect(find.byType(DsDonutChart), findsOneWidget);
    expect(find.byType(DsRankedBars), findsNWidgets(2));
    expect(find.textContaining('Lait 1 L', findRichText: true), findsWidgets); // top produits
    expect(find.text('VTE0002'), findsOneWidget); // dernières ventes
    await clic(tester, find.text('Jour'));
    expect(find.textContaining('500,00', findRichText: true), findsWidgets);
    await clic(tester, find.byKey(const ValueKey('kpi_credit_clients')));
    expect(find.text('Amina'), findsOneWidget);
  });

  testWidgets('situation : 10 analyses, recette par panier, export Excel', (tester) async {
    Uint8List? ecrit;
    final c = await pumpApp(
      tester,
      routeInitiale: '/situation',
      taille: const Size(1500, 1000),
      overrides: [
        selecteurEnregistrementProvider.overrideWithValue((nom, ext) async => '/exports/$nom'),
        ecrivainFichierProvider.overrideWithValue((chemin, octets) async => ecrit = octets),
      ],
    );
    await _jeu(c);
    await tester.pumpAndSettle();
    for (final id in ['mvc', 'mvp', 'inv', 'cout', 'rcp', 'rcpr', 'mgp', 'mgper', 'scli', 'sfrn']) {
      expect(find.byKey(ValueKey('situation_nav_$id')), findsOneWidget, reason: id);
    }
    expect(find.text('Vente'), findsWidgets); // mouvement de caisse
    await clic(tester, find.byKey(const ValueKey('situation_nav_rcp')));
    expect(find.text('VTE0001'), findsOneWidget);
    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('300,00 DA'), findsWidgets); // reste dû
    await clic(tester, find.text('Excel'));
    expect(find.textContaining('/exports/situation_rcp_'), findsOneWidget);
    await clic(tester, find.text('Fermer').last);
    final excel = Excel.decodeBytes(ecrit!);
    expect(excel.tables.values.single.maxRows, 3 + 2 + 1); // titre, vide, en-têtes, 2 paniers, totaux
    final journal = (await c.read(appDatabaseProvider).db.query('historique', where: "action = 'Export'")).single;
    expect((journal['entite_code'], journal['utilisateur_code']), ('situation_rcp', 'USR0000'));
    expect(ModulesHistorique.module('export', 'Export', 'situation_rcp'), 'situation');
    await clic(tester, find.byKey(const ValueKey('situation_nav_mgp')));
    expect(find.text('25,0 %'), findsWidgets); // (300 − 240) / 240
  });

  testWidgets('zakat : patrimoine repris du stock, des caisses et des créances', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/zakat', taille: const Size(1400, 900));
    await _jeu(c);
    c.read(zakatVersionProvider.notifier).incrementer();
    await tester.pumpAndSettle();
    // Capital = stock 5 × 80 + caisse 200 + créances 300 = 900.
    expect(find.textContaining('900,00'), findsWidgets);
    await clic(tester, find.byKey(const ValueKey('zakat_nouveau')));
    expect(tester.widget<TextField>(_dansCle('zakat_stock')).controller!.text, '400,00');
    expect(tester.widget<TextField>(_dansCle('zakat_liquidites')).controller!.text, '200,00');
    expect(tester.widget<TextField>(_dansCle('zakat_creances')).controller!.text, '300,00');
  });

  testWidgets('historique : journal filtrable par module et par action, détail', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/historique', taille: const Size(1400, 900));
    await _jeu(c);
    c.read(rapportsVersionProvider.notifier).incrementer();
    await tester.pumpAndSettle();
    expect(find.text('Journal de toutes les actions · accès selon le rôle'), findsOneWidget);
    expect(find.text('Encaissement'), findsWidgets);
    await clic(tester, find.byKey(const ValueKey('filtre_module_historique')));
    await clic(tester, find.text('Produits').last);
    expect(find.text('Encaissement'), findsNothing);
    expect(find.text('Création'), findsWidgets);
    await clic(tester, find.byKey(const ValueKey('filtre_action_historique')));
    await clic(tester, find.text('Annulation').last);
    expect(find.text('Création'), findsNothing);
    await clic(tester, find.byKey(const ValueKey('filtre_action_historique')));
    await clic(tester, find.text('Toutes').last);
    await doubleClic(tester, find.text('Lait 1 L').first);
    expect(find.text('Création · Produits'), findsOneWidget);
    expect(find.text('Contexte'), findsOneWidget);
    await clic(tester, find.text('Fermer').last);
  });
}
