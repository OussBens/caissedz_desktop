import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/statistiques_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

Future<Produit> _produit(Database db, String nom, {double pa = 60, double pv = 100, int npu = 1, double? stock}) =>
    CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      Produit(
        code: '',
        designation: nom,
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: pa,
        prixVente: pv,
        suiviNombre: npu > 1,
        nombreParUnite: npu,
        seuilStock: 5,
      ),
      magasinCode: stock == null ? null : 'MAG0000',
      stockInitial: stock ?? 0,
    );

void main() {
  test('m3, m13 : retour fournisseur selon la répartition, ligne « pièces seules » au prix à la pièce', () async {
    final db = (await ouvrirBaseDeTest()).db;
    final mag2 = await StockService(db, utilisateurCode: 'USR0000').creerMagasin('Dépôt');
    final p = await _produit(db, 'Huile');
    await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final achats = AchatService(db, utilisateurCode: 'USR0000');
    final e = await achats.enregistrer(
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [
        DemandeAchatLigne(produitCode: p.code, quantite: 10, prixAchat: 60, repartition: {'MAG0000': 4, mag2.code: 6}),
      ],
    );
    await RetourService(
      db,
      utilisateurCode: 'USR0000',
    ).creer(type: TypesTiers.fournisseur, documentCode: e.code, produitCode: p.code, quantite: 7);
    final stock = StockRepository(db);
    expect((await stock.niveau(p.code, 'MAG0000')).quantite, 0);
    expect((await stock.niveau(p.code, mag2.code)).quantite, 3);

    final eau = await _produit(db, 'Eau', pa: 120, npu: 6);
    final pieces = await achats.enregistrer(
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: eau.code, quantite: 0, nombre: 4, prixAchat: 25)],
    );
    expect(pieces.total, 100, reason: '4 pièces × 25');
    // « Dernier prix » : 25 la pièce × 6 pièces par unité = 150 l'unité (et non 25).
    expect((await CatalogueRepository(db).produitParCode(eau.code))!.prixAchat, 150);
  });

  test('m6, m9, m10, m11, m12 : arrondis, monnaie, session, magasin de la caisse, points', () async {
    final db = (await ouvrirBaseDeTest()).db;
    final mag2 = await StockService(db, utilisateurCode: 'USR0000').creerMagasin('Annexe');
    final p = await _produit(db, 'Thé', pv: 33.33, stock: 100);
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: p.code, magasinCode: mag2.code, quantite: 50);
    final caisse = await CaisseService(db, utilisateurCode: 'USR0000').creer(nom: 'Annexe', magasinCode: mag2.code);
    final client = await TiersService(db, utilisateurCode: 'USR0000').creerClient(const Client(code: '', nom: 'Nadia'));
    final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
    var session = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(
      db,
      utilisateurCode: 'USR0000',
      parametres: const ParametresVente(fideliteActive: true, pointsParDinar: 0.1),
    );

    // m6 : remise globale de 10 % sur 3 lignes de 33,33 → Σ lignes = net du ticket.
    final autres = [await _produit(db, 'Café', stock: 10), await _produit(db, 'Sucre', stock: 10)];
    var panier = Panier(
      id: 1,
      clientCode: client.code,
      remiseGlobalePct: 10,
    ).ajouter(PanierLigne(produit: p, quantite: 3, prixUnitaire: 33.33));
    for (final a in autres) {
      panier = panier.ajouter(PanierLigne(produit: a, quantite: 1, prixUnitaire: 33.33));
    }
    final v = await ventes.encaisser(
      panier.ajouterPaiement(Paiement(mode: 'Espèces', montant: panier.totalNet)),
      session: session,
      magasinCode: 'MAG0000',
    );
    expect(v.lignes.fold(0.0, (s, l) => s + l.total), closeTo(v.totalNet, 0.001));
    // Trois retours de 1 sur la ligne de 3 : leur somme = total net exact de la ligne.
    final retours = RetourService(db, utilisateurCode: 'USR0000');
    var rendu = 0.0;
    for (var i = 0; i < 3; i++) {
      rendu += (await retours.creer(
        type: TypesTiers.client,
        documentCode: v.code,
        produitCode: p.code,
        quantite: 1,
        ligneOrdre: 0,
      )).total;
    }
    expect(rendu, closeTo(v.lignes.first.total, 0.001));
    expect((await VenteRepository(db).pointsClient(client.code)) >= 0, isTrue, reason: 'jamais négatif');

    // m9 : pas de monnaie sur une carte.
    final carte = Panier(id: 2)
        .ajouter(PanierLigne(produit: p, quantite: 1, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Carte', montant: 150));
    await expectLater(
      ventes.encaisser(carte, session: session, magasinCode: 'MAG0000'),
      throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.monnaieSansEspeces)),
    );

    // m12 : points sur la part encaissée seulement (100 sur 300, le reste à crédit).
    final credit = await ventes.encaisser(
      Panier(id: 3, clientCode: client.code)
          .ajouter(PanierLigne(produit: p, quantite: 3, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
      session: session,
      magasinCode: 'MAG0000',
      creditAutorise: true,
    );
    expect(credit.pointsGagnes, 10);

    // m10 : complément payé sans session ouverte → refusé.
    await sessions.fermer(montantCompte: 0);
    await expectLater(
      ventes.modifier(credit.code, montantPaye: 300, mode: 'Espèces'),
      throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.sessionRequise)),
    );

    // m11 : la vente sort du magasin de la caisse ouverte.
    session = await sessions.ouvrir(caisseCode: caisse.code, fondInitial: 0);
    final annexe = await ventes.encaisser(
      const Panier(id: 4)
          .ajouter(PanierLigne(produit: p, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
      session: session,
      magasinCode: 'MAG0000',
    );
    expect(annexe.magasinCode, mag2.code);
    expect((await StockRepository(db).niveau(p.code, mag2.code)).quantite, 48);
  });

  test('m5, m8, m14 : seuil ≤, inventaire INV au théorique figé, types dédiés', () async {
    final db = (await ouvrirBaseDeTest()).db;
    final p = await _produit(db, 'Sucre', stock: 5);
    final repo = StockRepository(db);
    final initial = await db.query('mouvement_stock', where: 'produit_code = ?', whereArgs: [p.code]);
    expect(initial.single['type'], TypesMouvement.initial);
    expect(await StatistiquesRepository(db).produitsSousSeuil(5), 1, reason: 'stock = seuil → sous le seuil');

    final s = StockService(db, utilisateurCode: 'USR0000');
    await s.entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: 15);
    // Théorique figé à 20 ; une vente de 2 a lieu pendant le comptage ; 17 comptés → écart −3 (et non −1).
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    final v = await ventes.encaisser(
      const Panier(id: 1)
          .ajouter(PanierLigne(produit: p, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200)),
      session: session,
      magasinCode: 'MAG0000',
    );
    final inv = await s.inventorierLot(
      magasinCode: 'MAG0000',
      quantitesConstatees: {p.code: 17},
      theoriques: {p.code: 20},
    );
    expect(inv.code, 'INV0001');
    expect((await repo.niveau(p.code, 'MAG0000')).quantite, 15);
    expect((await repo.lignesInventaire('INV0001')).single['ecart'], -3);
    await s.annulerInventaire('INV0001', motif: 'Recomptage');
    expect((await repo.niveau(p.code, 'MAG0000')).quantite, 18);
    expect((await repo.inventaire('INV0001'))!['statut'], 'Annulé');

    await ventes.annuler(v.code, motif: 'Erreur');
    final annulation = await db.query('mouvement_stock', where: 'reference_type = ?', whereArgs: ['annulation']);
    expect(annulation.single['type'], TypesMouvement.annulation);
  });
}
