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
      expect(journal.first.referenceCode, 'SRT0001');
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
      final reserve = await s.creerMagasin('Réserve');
      await s.modifierMagasin(Magasin(code: reserve.code, nom: 'Réserve', actif: false));
      await expectLater(
        s.transferer(
          magasinSource: 'MAG0000',
          magasinDestination: reserve.code,
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

  group('StockService — documents (DS v2.2)', () {
    test('sortie : prix d\'achat figé, modification puis annulation avec réintégration', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      final repo = StockRepository(base.db);
      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      final so = await s.sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: [LigneStock(produitCode: lait.code, quantite: 3)],
      );
      expect(so.code, 'SRT0001');
      expect(so.valeur, 240, reason: '3 × 80 (prix d\'achat)');
      await s.modifierSortie(
        so.code,
        magasinCode: 'MAG0000',
        motif: 'Périmé',
        lignes: [LigneStock(produitCode: lait.code, quantite: 5)],
      );
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 5);
      expect((await repo.sortie(so.code))!.motif, 'Périmé');
      await expectLater(
        s.annulerSorties([so.code], motif: ' '),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.motifObligatoire)),
      );
      await s.annulerSorties([so.code], motif: 'Erreur de saisie');
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 10);
      final annulee = (await repo.sortie(so.code))!;
      expect(annulee.actif, isFalse);
      expect(annulee.annulation!.motif, 'Erreur de saisie');
      await expectLater(
        s.annulerSorties([so.code], motif: 'x'),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.dejaAnnule)),
      );
    });

    test('transfert : modification, annulation et distribution (total conservé)', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      final repo = StockRepository(base.db);
      final depot = await s.creerMagasin('Dépôt');
      final boutique = await s.creerMagasin('Boutique');
      await s.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 30);
      final t = await s.transferer(
        magasinSource: 'MAG0000',
        magasinDestination: depot.code,
        lignes: [LigneStock(produitCode: lait.code, quantite: 10)],
      );
      await s.modifierTransfert(
        t.code,
        magasinSource: 'MAG0000',
        magasinDestination: boutique.code,
        lignes: [LigneStock(produitCode: lait.code, quantite: 4)],
      );
      expect((await repo.niveau(lait.code, depot.code)).quantite, 0);
      expect((await repo.niveau(lait.code, boutique.code)).quantite, 4);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 26);
      await s.annulerTransferts([t.code], motif: 'Doublon');
      expect((await repo.niveau(lait.code, boutique.code)).quantite, 0);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 30);
      expect((await repo.transfert(t.code))!.actif, isFalse);

      final crees = await s.distribuer(lait.code, cible: {'MAG0000': 18, depot.code: 9, boutique.code: 3});
      expect(crees.length, 2);
      expect((await repo.niveau(lait.code, 'MAG0000')).quantite, 18);
      expect((await repo.niveau(lait.code, depot.code)).quantite, 9);
      expect((await repo.niveau(lait.code, boutique.code)).quantite, 3);
      expect((await repo.niveauTotal(lait.code)).quantite, 30);
      await expectLater(
        s.distribuer(lait.code, cible: {'MAG0000': 10}),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.quantiteInvalide)),
      );
    });

    test('magasins : nom unique, désactivation bloquée si stock ou magasin principal', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, _) = await _prepare(base);
      final depot = await s.creerMagasin('Dépôt', telephone: '021 00 00 00');
      await expectLater(
        s.creerMagasin('dépôt'),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.nomPris)),
      );
      await s.entrerStock(produitCode: lait.code, magasinCode: depot.code, quantite: 2);
      expect(await s.blocageDesactivation(depot), ErreurStock.stockNonNul);
      expect(
        await s.blocageDesactivation((await StockRepository(base.db).magasin('MAG0000'))!),
        ErreurStock.magasinSysteme,
      );
      await s.transferer(
        magasinSource: depot.code,
        magasinDestination: 'MAG0000',
        lignes: [LigneStock(produitCode: lait.code, quantite: 2)],
      );
      await s.definirMagasinsUtilisateur('USR0001', [depot.code, 'MAG0000']);
      expect(await s.blocageDesactivation(depot), ErreurStock.magasinPrincipal);
      await s.definirMagasinsUtilisateur('USR0001', ['MAG0000', depot.code]);
      await s.changerEtatMagasins([depot.code], actif: false);
      expect((await StockRepository(base.db).magasin(depot.code))!.actif, isFalse);
    });
  });

  group('StockService — listes de besoins', () {
    test('liste fournisseur : lignes, montant, statuts, modification et annulation', () async {
      final base = await ouvrirBaseDeTest();
      final (s, lait, carton) = await _prepare(base);
      final b = await s.creerBesoin(
        fournisseurCode: 'FOR0000',
        lignes: [
          LigneStock(produitCode: lait.code, quantite: 20, prix: 80),
          LigneStock(produitCode: carton.code, quantite: 2, prix: 300),
        ],
      );
      expect(b.code, 'BL0001');
      expect(b.montant, 2200);
      expect(b.statut, StatutsBesoin.enAttente);
      await s.modifierBesoin(
        b.code,
        fournisseurCode: 'FOR0000',
        lignes: [LigneStock(produitCode: lait.code, quantite: 10, prix: 75)],
      );
      expect((await StockRepository(base.db).besoin(b.code))!.montant, 750);
      expect((await s.changerStatutBesoin(b.code, StatutsBesoin.commande)).statut, 'Commande');
      await expectLater(
        s.changerStatutBesoin(b.code, 'Autre'),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.statutInvalide)),
      );
      await s.changerStatutBesoin(b.code, StatutsBesoin.disponible);
      await expectLater(
        s.annulerBesoins([b.code]),
        throwsA(isA<StockException>().having((e) => e.erreur, 'e', ErreurStock.besoinRecu)),
      );
      final b2 = await s.creerBesoin(
        fournisseurCode: 'FOR0000',
        lignes: [LigneStock(produitCode: lait.code, quantite: 1)],
      );
      await s.annulerBesoins([b2.code]);
      expect((await StockRepository(base.db).besoin(b2.code))!.actif, isFalse);
      expect(StockService.suggestion(2, 5), 8);
      expect(StockService.suggestion(20, 5), 1);
    });
  });
}
