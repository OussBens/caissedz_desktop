import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/parametres_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

Matcher _stock(ErreurStock e) => throwsA(isA<StockException>().having((x) => x.erreur, 'erreur', e));

void main() {
  group('2ᵉ stock « nombre » (§8.1)', () {
    test('exigé par le produit ou par le paramètre global, jamais pour un service', () {
      const p = Produit(code: 'P', designation: 'P', categorieCode: 'CATE0000', sousCategorieCode: 'SC0000');
      expect(p.exigeNombre(global: false), isFalse);
      expect(p.exigeNombre(global: true), isTrue);
      expect(p.copyWith(suiviNombre: true).exigeNombre(global: false), isTrue);
      expect(p.copyWith(service: true).exigeNombre(global: true), isFalse);
      const v = ParametresVente(nombreActif: true);
      expect(ParametresVente.depuisCles(v.versCles()).nombreActif, isTrue);
      expect(ParametresVente.depuisCles(const ParametresVente().versCles()).nombreActif, isFalse);
    });

    test('paramètre global : entrée, sortie, transfert et achat refusés sans nombre (> 0)', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final viande = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Viande hachée',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 900,
          prixVente: 1200,
          unite: 'kg',
        ),
      );
      final s = StockService(db, utilisateurCode: 'USR0000');
      // Paramètre inactif : quantité seule acceptée.
      await s.entrerStock(produitCode: viande.code, magasinCode: 'MAG0000', quantite: 5);
      final parametres = ParametresService(db, utilisateurCode: 'USR0000');
      await parametres.enregistrerVente((await parametres.lireVente()).copyWith(nombreActif: true));
      expect(await StockService.nombreGlobalActif(db), isTrue);

      await expectLater(
        s.entrerStock(produitCode: viande.code, magasinCode: 'MAG0000', quantite: 2),
        _stock(ErreurStock.nombreObligatoire),
      );
      await s.entrerStock(produitCode: viande.code, magasinCode: 'MAG0000', quantite: 2, nombre: 4);
      await expectLater(
        s.sortir(
          magasinCode: 'MAG0000',
          motif: 'Casse',
          lignes: [LigneStock(produitCode: viande.code, quantite: 1)],
        ),
        _stock(ErreurStock.nombreObligatoire),
      );
      await s.sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: [LigneStock(produitCode: viande.code, quantite: 1, nombre: 1)],
      );
      final depot = await s.creerMagasin('Dépôt');
      await expectLater(
        s.transferer(
          magasinSource: 'MAG0000',
          magasinDestination: depot.code,
          lignes: [LigneStock(produitCode: viande.code, quantite: 1)],
        ),
        _stock(ErreurStock.nombreObligatoire),
      );
      await s.transferer(
        magasinSource: 'MAG0000',
        magasinDestination: depot.code,
        lignes: [LigneStock(produitCode: viande.code, quantite: 1, nombre: 2)],
      );
      final repo = StockRepository(db);
      final principal = await repo.niveau(viande.code, 'MAG0000');
      expect((principal.quantite, principal.nombre), (5.0, 1.0)); // 5 + 2 − 1 − 1 ; 4 − 1 − 2
      expect((await repo.niveau(viande.code, depot.code)).nombre, 2);

      final f = await TiersService(
        db,
        utilisateurCode: 'USR0000',
      ).creerFournisseur(const Fournisseur(code: '', nom: 'Abattoir'));
      await ouvrirSessionDeTest(db);
      final achats = AchatService(db, utilisateurCode: 'USR0000');
      await expectLater(
        achats.enregistrer(
          fournisseurCode: f.code,
          magasinCode: 'MAG0000',
          lignes: [DemandeAchatLigne(produitCode: viande.code, quantite: 3, prixAchat: 900)],
        ),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.nombreObligatoire)),
      );
      // Répartition multi-magasin : le nombre suit la quantité au prorata.
      await achats.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [
          DemandeAchatLigne(
            produitCode: viande.code,
            quantite: 4,
            nombre: 8,
            prixAchat: 900,
            repartition: {'MAG0000': 3, depot.code: 1},
          ),
        ],
      );
      expect((await repo.niveau(viande.code, 'MAG0000')).nombre, 7); // 1 + 6
      expect((await repo.niveau(viande.code, depot.code)).nombre, 4); // 2 + 2
    });

    test('vente : la vente à l\'unité sort aussi les pièces ; refusée sans nombre', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final poulet = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Poulet',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 300,
          prixVente: 400,
          suiviNombre: true,
          nombreParUnite: 2,
        ),
      );
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: poulet.code, magasinCode: 'MAG0000', quantite: 10, nombre: 20);
      final session = await SessionCaisseService(
        db,
        utilisateurCode: 'USR0000',
      ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
      Panier panier({required bool exige}) =>
          const Panier(id: 1)
              .ajouter(PanierLigne(produit: poulet, quantite: 3, prixUnitaire: 400, nombreExige: exige))
              .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 1200));
      await expectLater(
        ventes.encaisser(panier(exige: false), session: session, magasinCode: 'MAG0000'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.nombreObligatoire)),
      );
      final v = await ventes.encaisser(panier(exige: true), session: session, magasinCode: 'MAG0000');
      expect(v.lignes.single.nombre, 6);
      final n = await StockRepository(db).niveau(poulet.code, 'MAG0000');
      expect((n.quantite, n.nombre), (7.0, 14.0));
    });
  });
}
