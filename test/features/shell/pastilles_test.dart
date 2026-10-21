import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/domain/pastilles.dart';
import 'package:caissedz_desktop/features/commun/pastilles_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  test('une vente allume Ventes, Mouvements caisse, Mouvements stock et le client (pas le client de passage)', () {
    expect(PastillesModules.cibles(entite: 'vente', action: 'Création', entiteCode: 'VTE0001', clientCode: 'CLN0001'), {
      'ventes#0',
      'gestion_caisse#3',
      'stock#1',
      'clients#0',
    });
    expect(
      PastillesModules.cibles(entite: 'vente', action: 'Création', clientCode: 'CLN0000'),
      isNot(contains('clients#0')),
    );
    expect(PastillesModules.cibles(entite: 'versement', action: 'Versement', tiersType: 'Fournisseur'), {
      'fournisseurs#1',
      'fournisseurs#0',
      'gestion_caisse#3',
    });
    expect(PastillesModules.cibles(entite: 'vente', action: 'Export'), isEmpty);
    expect(PastillesModules.cibles(entite: 'utilisateur', action: 'Connexion'), isEmpty);
  });

  testWidgets('points rouges : barre latérale et onglets, éteints à la consultation', (tester) async {
    final c = await pumpApp(tester, routeInitiale: '/tableau-de-bord', taille: const Size(1500, 950));
    await tester.pumpAndSettle();
    final db = c.read(appDatabaseProvider).db;
    await tester.runAsync(() async {
      await c.read(pastillesProvider.notifier).actualiser(); // base : rien d'allumé au premier lancement
      final lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
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
      ).creerClient(const Client(code: '', nom: 'Amina'));
      final session = await SessionCaisseService(
        db,
        utilisateurCode: 'USR0000',
      ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      // Seule la vente compte : on marque comme vu ce qui précède.
      await c.read(pastillesProvider.notifier).actualiser();
      for (final cible in [...c.read(pastillesProvider)]) {
        await c.read(pastillesProvider.notifier).marquerVu(cible.split('#')[0], int.parse(cible.split('#')[1]));
      }
      await VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente()).encaisser(
        Panier(id: 1, clientCode: client.code)
            .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: session,
        magasinCode: 'MAG0000',
      );
      c.read(commerceVersionProvider.notifier).incrementer();
      await c.read(pastillesProvider.notifier).actualiser();
    });
    await tester.pumpAndSettle();
    expect(c.read(pastillesProvider), {'ventes#0', 'gestion_caisse#3', 'stock#1', 'clients#0'});
    expect(find.byKey(const ValueKey('point_/ventes')), findsOneWidget);
    // Le groupe Tiers est fermé (seul celui du module ouvert est déplié) : le point est sur son en-tête.
    expect(find.byKey(const ValueKey('point_/clients')), findsNothing);
    expect(find.byKey(const ValueKey('point_categorie_Tiers')), findsOneWidget);
    await clic(tester, find.byKey(const ValueKey('nav_categorie_2')));
    expect(find.byKey(const ValueKey('point_/clients')), findsOneWidget);
    expect(find.byKey(const ValueKey('point_categorie_Tiers')), findsNothing);
    expect(find.byKey(const ValueKey('point_/produits')), findsNothing);

    // Gestion caisse : point sur l'onglet Mouvements, éteint quand on l'ouvre.
    c.read(routerProvider).go('/gestion-caisse');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('point_onglet_3')), findsOneWidget);
    await clic(tester, find.text('Mouvements'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('point_onglet_3')), findsNothing);
    expect(c.read(pastillesProvider), isNot(contains('gestion_caisse#3')));
    // Gestion caisse ouverte : GÉNÉRAL est fermé, le point des ventes (pas encore vues) est sur son en-tête.
    expect(find.byKey(const ValueKey('point_categorie_Général')), findsOneWidget, reason: 'ventes pas encore vues');
  });
}
