import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/situation_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  test('retour par ligne de vente : unités figées, pièces, points, CA et marges nets des retours', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final cat = CatalogueService(db, utilisateurCode: 'USR0000');
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
    final eau = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Eau',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 20,
        prixVente: 30,
        suiviNombre: true,
        nombreParUnite: 6,
      ),
    );
    final carton = await cat.creerColis(
      Colis(code: '', produitCode: lait.code, designation: 'Carton de 12', quantite: 12, prixVente: 1100),
    );
    final stock = StockService(db, utilisateurCode: 'USR0000');
    await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 50);
    await stock.entrerStock(produitCode: eau.code, magasinCode: 'MAG0000', quantite: 20, nombre: 120);
    final amina = await TiersService(db, utilisateurCode: 'USR0000').creerClient(const Client(code: '', nom: 'Amina'));
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(
      db,
      utilisateurCode: 'USR0000',
      parametres: const ParametresVente(fideliteActive: true, pointsParDinar: 1),
    );
    Future<String> vendre(List<PanierLigne> lignes) async {
      var p = Panier(id: 1, clientCode: amina.code);
      for (final l in lignes) {
        p = p.ajouter(l);
      }
      return (await ventes.encaisser(
        p.ajouterPaiement(Paiement(mode: 'Espèces', montant: p.totalNet)),
        session: session,
        magasinCode: 'MAG0000',
      )).code;
    }

    // V1 : lait en carton de 12 (ligne 0) et à l'unité (ligne 1), eau à l'unité avec ses pièces (ligne 2).
    final v1 = await vendre([
      PanierLigne(produit: lait, colis: carton, quantite: 1, prixUnitaire: 1100),
      PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100),
      PanierLigne(produit: eau, quantite: 2, prixUnitaire: 30, nombreExige: true),
    ]);
    final v2 = await vendre([PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100)]);
    final v3 = await vendre([PanierLigne(produit: lait, colis: carton, quantite: 1, prixUnitaire: 1100)]);
    final niveaux = StockRepository(db);
    Future<double> qLait() async => (await niveaux.niveau(lait.code, 'MAG0000')).quantite;
    final points = VenteRepository(db);
    expect(await qLait(), 50 - 15 - 1 - 12);
    expect(await points.pointsClient(amina.code), 1460 + 100 + 1100);

    // Le carton passe à 24 : annulation et retours restituent ce qui est réellement sorti (12).
    await db.update('colis', {'quantite': 24}, where: 'code = ?', whereArgs: [carton.code]);
    await ventes.annuler(v3, motif: 'Erreur');
    expect(await qLait(), 22 + 12);
    expect(await points.pointsClient(amina.code), 1560);

    final retours = RetourService(db, utilisateurCode: 'USR0000');
    Future<Retour> retourner(String vente, int ordre, double q, {bool remise = true}) => retours.creer(
      type: TypesTiers.client,
      documentCode: vente,
      produitCode: ordre == 2 ? eau.code : lait.code,
      ligneOrdre: ordre,
      quantite: q,
      reglement: ReglementsRetour.avoir,
      remiseEnStock: remise,
    );
    // Plafond par ligne (3 à l'unité), pas par produit (15 laits vendus).
    await expectLater(
      retourner(v1, 1, 4),
      throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.quantiteDepasse)),
    );
    final r1 = await retourner(v1, 1, 2);
    expect((r1.total, r1.ligne!.ordreOrigine, r1.pointsRepris), (200.0, 1, 200));
    final r0 = await retourner(v1, 0, 1);
    expect(r0.total, 1100, reason: 'prix du carton, pas de l\'unité');
    expect(await qLait(), 34 + 2 + 12, reason: '12 unités figées à la vente, pas 24');
    final re = await retourner(v1, 2, 1);
    final nEau = await niveaux.niveau(eau.code, 'MAG0000');
    expect((nEau.quantite, nEau.nombre), (19.0, 114.0), reason: 'pièces réintégrées au prorata');
    expect(re.ligne!.nombre, 6);
    // Retour « Casse » : le coût reste une perte.
    await retourner(v2, 0, 1, remise: false);
    expect(await qLait(), 48);
    expect(await points.pointsClient(amina.code), 1560 - 200 - 1100 - 30 - 100);
    await retours.annuler(r1.code, motif: 'Erreur');
    expect(await points.pointsClient(amina.code), 330, reason: 'points rendus à l\'annulation du retour');
    expect(await qLait(), 46);

    // CA et marges nets des retours (à leur date) ; la casse reste en coût.
    final s = SituationRepository(db);
    final jour = DateTime.now();
    expect(await s.totalVentes(jour, jour), 1460 + 100 - 1100 - 30 - 100);
    final marge = (await s.margeParPeriode(jour, jour, const FiltresSituation())).single;
    expect(marge['montant'], 330);
    expect(marge['cout'], 1240 + 80 - 960 - 20);
    expect(marge['marge'], 330 - 340);
    expect(marge['retours'], 1230);
    expect(marge['casse'], 80);
    final produits = await s.recetteParProduit(jour, jour, const FiltresSituation());
    final ligneLait = produits.firstWhere((r) => r['code'] == lait.code);
    expect(ligneLait['quantite'], 1 + 3 + 1 - 1 - 1);
    final parPanier = (await s.margeParPanier(jour, jour, const FiltresSituation())).firstWhere((r) => r['code'] == v1);
    expect((parPanier['montant'], parPanier['retours']), (1460 - 1130.0, 1130.0));
  });
}
