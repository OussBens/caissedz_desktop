import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/document_commercial_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/domain/models/document_commercial.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  testWidgets('recherche globale : Ctrl+K, résultat groupé, ouverture du module filtré sur le bon onglet', (
    tester,
  ) async {
    final c = await pumpApp(tester, routeInitiale: '/tableau-de-bord', taille: const Size(1500, 950));
    final db = c.read(appDatabaseProvider).db;
    await tester.runAsync(() async {
      final produit = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(code: '', designation: 'Lait', categorieCode: 'CATE0000', sousCategorieCode: 'SC0000'),
      );
      final client = await TiersService(
        db,
        utilisateurCode: 'USR0000',
      ).creerClient(const Client(code: '', nom: 'Amina Benali', telephone: '0661234567'));
      await TiersService(db, utilisateurCode: 'USR0000').creerClient(const Client(code: '', nom: 'Karim'));
      await DocumentClientService(db, utilisateurCode: 'USR0000').creer(
        type: TypesDocumentClient.proforma,
        clientCode: client.code,
        lignes: [DemandeLigneDocument(produitCode: produit.code, quantite: 2, prix: 100)],
      );
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('topbar_recherche')), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'amina');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('recherche_CLN0001')), findsOneWidget);
    expect(find.byKey(const ValueKey('recherche_PRO0001')), findsOneWidget, reason: 'proforma du client par son nom');
    expect(find.text('Karim'), findsNothing);

    await clic(tester, find.byKey(const ValueKey('recherche_PRO0001')));
    await tester.pumpAndSettle();
    final uri = c.read(routerProvider).routeInformationProvider.value.uri;
    expect(uri.path, '/documents');
    expect(uri.queryParameters, {'q': 'PRO0001', 'onglet': '1'});
    expect(
      tester.widgetList<TextField>(find.byType(TextField)).any((f) => f.controller?.text == 'PRO0001'),
      isTrue,
      reason: 'recherche de la liste pré-remplie',
    );
    expect(find.text('PRO0001'), findsWidgets);
  });
}
