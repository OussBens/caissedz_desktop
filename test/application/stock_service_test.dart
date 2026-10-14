import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

Future<(StockService, Produit, Produit)> _prepare(dynamic base) async {
  final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
  final lait = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Lait',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 80,
      prixVente: 100,
    ),
  );
  final carton = await cat.creerProduit(
    const Produit(
      code: '',
      designation: 'Carton œufs',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      prixAchat: 300,
      prixVente: 360,
      suiviNombre: true,
      nombreParUnite: 30,
    ),
  );
  return (StockService(base.db, utilisateurCode: 'USR0000'), lait, carton);
}

void main() {
  group('StockService — journal', () {
    test('le stock est la somme des mouvements ; garde de stock', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10, type: TypesMouvement.initial);
      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 5);
      final repo = StockRepository(base.db);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 15);
      await s.sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: [LigneStock(produitCode: lait.code, quantite: 4)],
      );
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 11);
      await expectLater(
        s.sortir(
          magasinCode: 'MAG0000',
          motif: 'Don',
          lignes: [LigneStock(produitCode: lait.code, quantite: 12)],
        ),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.stockInsuffisant)),
      );
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 11, reason: 'aucune écriture après refus');
      expect((await repo.sorties()).length, 1);
      await expectLater(
        s.sortir(
          magasinCode: 'MAG0000',
          motif: 'Inconnu',
          lignes: [LigneStock(produitCode: lait.code, quantite: 1)],
        ),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.motifInvalide)),
      );
      await expectLater(
        s.entrerStock(produitCode: 'PRD9999', magasinCode: 'MAG0000', quantite: 1),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.produitInconnu)),
      );
      final journal = await repo.mouvements(produitCode: lait.code);
      expect(journal.length, 3);
      expect(journal.first.type, TypesMouvement.sortie);
      expect(journal.first.motif, 'Casse');
      expect(journal.first.referenceCode, 'SOR0001');
    });

    test('2ᵉ stock « nombre » suivi en parallèle', () async {
      final base = await ouvrirBaseDeTest();
      final (s, _, carton) = await _prepare(base);
      await s.entrerStock(produitCode: carton.code, magasinCode: 'MAG0000', quantite: 2, nombre: 60);
      await s.sortir(
        magasinCode: 'MAG0000',
        motif: 'Échantillon',
        lignes: [LigneStock(produitCode: carton.code, quantite: 0, nombre: 12)],
      );
      final n = await StockRepository(base.db).niveau(carton.code, 'MAG0000');
      expect(n.quantite, 2);
      expect(n.nombre, 48);
      await expectLater(
        s.sortir(
          magasinCode: 'MAG0000',
          motif: 'Casse',
          lignes: [LigneStock(produitCode: carton.code, quantite: 0, nombre: 50)],
        ),
        throwsA(isA<StockException>()),
      );
    });

    test('inventaire : écrit l’écart', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      await s.inventorier(produitCode: lait.code, magasinCode: 'MAG0000', quantiteConstatee: 7);
      await s.inventorier(produitCode: lait.code, magasinCode: 'MAG0000', quantiteConstatee: 7); // sans écart : rien
      final repo = StockRepository(base.db);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 7);
      expect((await repo.mouvements(type: TypesMouvement.inventaire)).single.quantite, -3);
    });
  });

  group('StockService — magasins et transferts', () {
    test('magasin principal = premier magasin de l’utilisateur ; transfert TRM = 2 mouvements', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      final depot = await s.creerMagasin('Dépôt');
      expect(depot.code, 'MAG0001');
      expect(await s.magasinPrincipal('USR0000'), 'MAG0000');
      await s.definirMagasinsUtilisateur('USR0000', [depot.code, 'MAG0000']);
      expect(await s.magasinPrincipal('USR0000'), depot.code);
      expect(await s.magasinPrincipal('USR0042'), 'MAG0000');

      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      final t = await s.transferer(
        magasinSource: 'MAG0000',
        magasinDestination: depot.code,
        lignes: [LigneStock(produitCode: lait.code, quantite: 4)],
      );
      expect(t.code, 'TRM0001');
      final repo = StockRepository(base.db);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 6);
      expect((await repo.niveau(lait.code, depot.code)).quantite, 4);
      final mvts = await repo.mouvements(type: TypesMouvement.transfert);
      expect(mvts.length, 2);
      expect(mvts.map((m) => m.quantite).toSet(), {-4.0, 4.0});
      expect(mvts.every((m) => m.referenceCode == 'TRM0001'), isTrue);
      final rep = await repo.repartition(lait.code);
      expect({for (final r in rep) r.magasinCode: r.quantite}, {'MAG0000': 6.0, depot.code: 4.0});
      expect((await repo.niveauTotal(lait.code)).quantite, 10);

      await expectLater(
        s.transferer(
          magasinSource: 'MAG0000',
          magasinDestination: 'MAG0000',
          lignes: [LigneStock(produitCode: lait.code, quantite: 1)],
        ),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.memeMagasin)),
      );
      await expectLater(
        s.transferer(
          magasinSource: 'MAG0000',
          magasinDestination: depot.code,
          lignes: [LigneStock(produitCode: lait.code, quantite: 50)],
        ),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.stockInsuffisant)),
      );
      expect((await repo.transferts()).length, 1, reason: 'transfert refusé non enregistré');
      await s.modifierMagasin(Magasin(code: depot.code, nom: 'Dépôt', actif: false));
      await expectLater(
        s.transferer(
          magasinSource: 'MAG0000',
          magasinDestination: depot.code,
          lignes: [LigneStock(produitCode: lait.code, quantite: 1)],
        ),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.magasinInactif)),
      );
      await expectLater(
        s.modifierMagasin(const Magasin(code: 'MAG0000', nom: 'x', actif: false, systeme: true)),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.magasinSysteme)),
      );
    });
  });

  group('StockService — besoins', () {
    test('cycle En attente → Commande → Disponible et génération sous seuil', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, carton) = await _prepare(base);
      final b = await s.creerBesoin(produitCode: lait.code, quantite: 20);
      expect(b.code, 'BES0001');
      expect(b.statut, StatutsBesoin.enAttente);
      expect((await s.changerStatutBesoin(b.code, StatutsBesoin.commande)).statut, 'Commande');
      expect((await s.changerStatutBesoin(b.code, StatutsBesoin.disponible)).statut, 'Disponible');
      await expectLater(
        s.changerStatutBesoin(b.code, 'Autre'),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.statutInvalide)),
      );
      // lait : besoin disponible (clos) et stock 0 ≤ seuil 5 → nouveau besoin ; carton : stock 10 > seuil → rien
      await s.entrerStock(produitCode: carton.code, magasinCode: 'MAG0000', quantite: 10);
      final crees = await s.genererBesoinsSousSeuil(seuilGlobal: 5);
      expect(crees.map((x) => x.produitCode), [lait.code]);
      expect(crees.single.quantite, 10);
      expect(await s.genererBesoinsSousSeuil(seuilGlobal: 5), isEmpty, reason: 'besoin déjà ouvert');
      await s.supprimerBesoin(crees.single.code);
      expect((await StockRepository(base.db).besoins()).length, 1);
    });
  });
}
