import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/client_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Finder _cle(String cle) => find.byKey(ValueKey(cle));

const _taille = Size(1600, 1000);

Produit _p(String nom) =>
    Produit(code: '', designation: nom, categorieCode: 'CATE0000', sousCategorieCode: 'SC0000', prixVente: 100);

void main() {
  group('Suppression ou archivage (écrans)', () {
    testWidgets('Produits : sans historique supprimé, avec historique archivé, vue Archives puis restauration', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/produits', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      final pain = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(_p('Pain'));
      final lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(_p('Lait'));
      final stock = StockService(db, utilisateurCode: 'USR0000');
      await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 4);
      await stock.inventorier(produitCode: lait.code, magasinCode: 'MAG0000', quantiteConstatee: 0);
      c.read(catalogueVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();
      expect(find.text('Archives (0)'), findsOneWidget);

      await clic(tester, find.text('Pain'));
      await clic(tester, find.text('Lait'));
      await clic(tester, _cle('produits_supprimer'));
      // Chaque ligne annonce ce qui l'attend ; l'explication de l'archivage est affichée.
      expect(find.text('Sera supprimé'), findsOneWidget);
      expect(find.text('Sera archivé (a un historique)'), findsOneWidget);
      expect(find.textContaining('sont archivés au lieu d\'être supprimés'), findsOneWidget);
      await clic(tester, find.text('Supprimer (2)'));
      expect(find.text('1 supprimé(s), 1 archivé(s)'), findsOneWidget);
      final repo = CatalogueRepository(db);
      expect(await repo.produitParCode(pain.code), isNull);
      expect((await repo.produitParCode(lait.code))!.audit.archive, isTrue);
      expect(find.text('Lait'), findsNothing, reason: 'archivé : hors de la liste');

      // Vue Archives : bandeau, le produit y est ; restauration.
      await clic(tester, _cle('produits_archives_bouton'));
      expect(find.text('Lait'), findsOneWidget);
      expect(find.textContaining("gardés pour l'historique"), findsOneWidget);
      await clic(tester, find.text('Lait'));
      await clic(tester, _cle('archives_restaurer'));
      await clic(tester, find.text('Restaurer (1)'));
      expect(find.text('1 restauré(s)'), findsOneWidget);
      final restaure = (await repo.produitParCode(lait.code))!;
      expect((restaure.actif, restaure.audit.archive), (true, false));
      await clic(tester, find.text('Retour à la liste'));
      expect(find.text('Lait'), findsWidgets);
      await tester.pump(const Duration(seconds: 5)); // fin des toasts
    });

    testWidgets('Clients : client de passage bloqué, client sans historique supprimé', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clients', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      final nadia = await TiersService(
        db,
        utilisateurCode: 'USR0000',
      ).creerClient(const Client(code: '', nom: 'Nadia'));
      c.read(commerceVersionProvider.notifier).incrementer();
      await tester.pumpAndSettle();

      await clic(tester, find.text('CLN0000'));
      await clic(tester, find.text(nadia.code));
      await clic(tester, _cle('tiers_supprimer_Client'));
      expect(find.textContaining('élément système'), findsOneWidget);
      await clic(tester, find.text('Supprimer (1)'));
      expect(await ClientRepository(db).parCode(nadia.code), isNull);
      expect(await ClientRepository(db).parCode('CLN0000'), isNotNull);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
