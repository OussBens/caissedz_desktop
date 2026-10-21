import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/document_commercial_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/documents_commerciaux_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/fiscalite.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/document_commercial.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  test('devis → commande → livraisons partielles : stock, solde, statuts ; BL annulé avec sa vente', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    const u = 'USR0000';
    final cafe = await CatalogueService(db, utilisateurCode: u).creerProduit(
      const Produit(
        code: '',
        designation: 'Café',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 60,
        prixVente: 119,
        tvaPct: 19,
      ),
    );
    await StockService(
      db,
      utilisateurCode: u,
    ).entrerStock(produitCode: cafe.code, magasinCode: 'MAG0000', quantite: 50);
    final atlas = await TiersService(db, utilisateurCode: u).creerClient(const Client(code: '', nom: 'SARL Atlas'));
    final session = await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final docs = DocumentClientService(db, utilisateurCode: u);
    final repo = DocumentsCommerciauxRepository(db);
    Future<double> stock() async => (await StockRepository(db).niveau(cafe.code, 'MAG0000')).quantite;
    Future<double> solde() => TiersRepository(db).solde(TypesTiers.client, atlas.code);

    // Devis : aucun effet sur le stock ni le solde ; TVA figée et ventilée.
    final devis = await docs.creer(
      type: TypesDocumentClient.devis,
      clientCode: atlas.code,
      lignes: [DemandeLigneDocument(produitCode: cafe.code, quantite: 10, prix: 119)],
      validite: DateTime.now().add(const Duration(days: 15)),
    );
    expect(devis.code, 'DEV0001');
    expect((devis.total, devis.totalHt, devis.totalTva), (1190.0, 1000.0, 190.0));
    expect(devis.statut, StatutsDocumentClient.enCours);
    expect((await stock(), await solde()), (50.0, 0.0));
    final proforma = await docs.creer(
      type: TypesDocumentClient.proforma,
      clientCode: atlas.code,
      lignes: [DemandeLigneDocument(produitCode: cafe.code, quantite: 1, prix: 119)],
      validite: DateTime.now().subtract(const Duration(days: 1)),
    );
    expect(proforma.code, 'PRO0001');
    expect(proforma.statut, StatutsDocumentClient.expire);

    // Transformation en commande.
    final commande = await docs.transformerEnCommande(devis.code);
    expect(commande.code, 'BCC0001');
    expect(commande.origineCode, 'DEV0001');
    expect((await repo.documentClient('DEV0001'))!.statut, StatutsDocumentClient.transforme);
    await expectLater(docs.transformerEnCommande(devis.code), throwsA(isA<DocumentException>()));

    // 1re livraison : 4 sur 10, payée 200 → vente à crédit du reste.
    final bl1 = await docs.livrer(
      commande.code,
      quantites: {0: 4},
      session: session,
      magasinCode: 'MAG0000',
      paiements: const [Paiement(mode: 'Espèces', montant: 200)],
    );
    expect(bl1.code, 'LIV0001');
    expect(bl1.total, 476);
    expect((await stock(), await solde()), (46.0, 276.0));
    var c = (await repo.documentClient(commande.code))!;
    expect(c.statut, StatutsDocumentClient.partielle);
    expect(c.lignes.single.reste, 6);
    await expectLater(
      docs.livrer(commande.code, quantites: {0: 7}, session: session, magasinCode: 'MAG0000'),
      throwsA(isA<DocumentException>().having((e) => e.erreur, 'e', ErreurDocument.quantiteExcessive)),
    );
    await expectLater(docs.modifier(commande.code, clientCode: atlas.code, lignes: const []), throwsA(anything));
    await expectLater(
      docs.annuler(commande.code, motif: 'x'),
      throwsA(isA<DocumentException>().having((e) => e.erreur, 'e', ErreurDocument.livraisonLiee)),
    );

    // 2e livraison : le reste → commande livrée.
    final bl2 = await docs.livrer(commande.code, quantites: {0: 6}, session: session, magasinCode: 'MAG0000');
    expect(bl2.code, 'LIV0002');
    c = (await repo.documentClient(commande.code))!;
    expect(c.statut, StatutsDocumentClient.livree);
    expect(c.livraisons, ['LIV0001', 'LIV0002']);
    expect((await stock(), await solde()), (40.0, 990.0));

    // Annuler la vente du 2e BL : stock et solde rendus, BL annulé, commande de nouveau partielle.
    await VenteService(db, utilisateurCode: u, parametres: const ParametresVente()).annuler(bl2.venteCode, motif: 'x');
    expect((await repo.livraison('LIV0002'))!.actif, isFalse);
    c = (await repo.documentClient(commande.code))!;
    expect((c.statut, c.lignes.single.reste), (StatutsDocumentClient.partielle, 6.0));
    expect((await stock(), await solde()), (46.0, 276.0));

    // BL d'une vente de caisse : un seul par vente.
    final v = await VenteService(db, utilisateurCode: u, parametres: const ParametresVente()).encaisser(
      Panier(id: 1, clientCode: atlas.code)
          .ajouter(PanierLigne(produit: cafe, quantite: 2, prixUnitaire: 119))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 238)),
      session: session,
      magasinCode: 'MAG0000',
    );
    final bl3 = await docs.bonLivraisonPourVente(v.code);
    expect((bl3.code, bl3.commandeCode, bl3.lignes.single.quantite), ('LIV0003', null, 2.0));
    expect((await docs.bonLivraisonPourVente(v.code)).code, 'LIV0003');
    expect((await stock()), 44, reason: 'le BL ne sort pas de stock une 2e fois');

    // Devis refusé puis non transformable ; annulation avec motif.
    await docs.changerStatut(proforma.code, StatutsDocumentClient.refuse);
    await expectLater(docs.transformerEnCommande(proforma.code), throwsA(isA<DocumentException>()));
    await docs.annuler(proforma.code, motif: 'Client parti');
    expect((await repo.documentClient(proforma.code))!.statut, StatutsDocumentClient.annule);
    await base.fermer();
  });

  test('vente avec ou sans TVA : paramètre de la caisse et paramètre des documents', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    const u = 'USR0000';
    final cafe = await CatalogueService(db, utilisateurCode: u).creerProduit(
      const Produit(
        code: '',
        designation: 'Café',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixVente: 100,
        tvaPct: 19,
        service: true,
      ),
    );
    final atlas = await TiersService(db, utilisateurCode: u).creerClient(const Client(code: '', nom: 'SARL Atlas'));
    final session = await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: u, parametres: const ParametresVente());
    Future<double> tauxCaisse() async => (await ventes.encaisser(
      const Panier(id: 1)
          .ajouter(PanierLigne(produit: cafe, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
      session: session,
      magasinCode: 'MAG0000',
    )).lignes.single.tauxTva;

    // Par défaut : avec TVA.
    expect(await tauxCaisse(), 19);
    // Caisse sans TVA, documents avec TVA.
    await ParametreRepository(db).ecrire(Fiscalite.cleTvaCaisse, '0');
    expect(await tauxCaisse(), 0);
    final docs = DocumentClientService(db, utilisateurCode: u);
    final avec = await docs.creer(
      type: TypesDocumentClient.devis,
      clientCode: atlas.code,
      lignes: [DemandeLigneDocument(produitCode: cafe.code, quantite: 1, prix: 119)],
    );
    expect((avec.totalHt, avec.totalTva), (100.0, 19.0));

    // Documents sans TVA : devis en HT, et la livraison d'une commande vend sans TVA, même si la caisse est avec TVA.
    await ParametreRepository(db).ecrirePlusieurs({Fiscalite.cleTvaCaisse: '1', Fiscalite.cleTvaDocuments: '0'});
    expect(await tauxCaisse(), 19);
    final commande = await docs.creer(
      type: TypesDocumentClient.commande,
      clientCode: atlas.code,
      lignes: [DemandeLigneDocument(produitCode: cafe.code, quantite: 2, prix: 100)],
    );
    expect((commande.totalHt, commande.totalTva, commande.lignes.single.tauxTva), (200.0, 0.0, 0.0));
    final bl = await docs.livrer(commande.code, quantites: {0: 2}, session: session, magasinCode: 'MAG0000');
    final vente = (await VenteRepository(db).vente(bl.venteCode))!;
    expect(vente.lignes.single.tauxTva, 0);
    await base.fermer();
  });

  test('commande fournisseur : réceptions partielles par entrées, solde, annulation', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    const u = 'USR0000';
    Future<Produit> produit(String nom) => CatalogueService(db, utilisateurCode: u).creerProduit(
      Produit(code: '', designation: nom, categorieCode: 'CATE0000', sousCategorieCode: 'SC0000', prixAchat: 50),
    );
    final lait = await produit('Lait');
    final sucre = await produit('Sucre');
    final f = await TiersService(db, utilisateurCode: u).creerFournisseur(const Fournisseur(code: '', nom: 'Cevital'));
    await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final service = CommandeFournisseurService(db, utilisateurCode: u);
    final repo = DocumentsCommerciauxRepository(db);
    final bcf = await service.creer(
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [
        DemandeLigneDocument(produitCode: lait.code, quantite: 10, prix: 50),
        DemandeLigneDocument(produitCode: sucre.code, quantite: 5, prix: 80),
      ],
      dateLivraison: DateTime.now().add(const Duration(days: 3)),
    );
    expect((bcf.code, bcf.total, bcf.statut), ('BCF0001', 900.0, StatutsCommandeFournisseur.enCours));
    expect(await TiersRepository(db).solde(TypesTiers.fournisseur, f.code), 0, reason: 'une commande ne doit rien');

    final achats = AchatService(db, utilisateurCode: u);
    final e1 = await achats.enregistrer(
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 6, prixAchat: 50)],
      commandeCode: bcf.code,
    );
    expect(e1.commandeCode, 'BCF0001');
    var c = (await repo.commandeFournisseur(bcf.code))!;
    expect(c.statut, StatutsCommandeFournisseur.partielle);
    expect([for (final l in c.lignes) l.reste], [4.0, 5.0]);
    await expectLater(
      service.annuler(bcf.code, motif: 'x'),
      throwsA(isA<DocumentException>().having((e) => e.erreur, 'e', ErreurDocument.receptionLiee)),
    );
    await expectLater(
      achats.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 1, prixAchat: 50)],
        commandeCode: bcf.code,
      ),
      throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.commandeInconnue)),
    );
    await achats.enregistrer(
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [
        DemandeAchatLigne(produitCode: lait.code, quantite: 4, prixAchat: 50),
        DemandeAchatLigne(produitCode: sucre.code, quantite: 5, prixAchat: 80),
      ],
      commandeCode: bcf.code,
    );
    c = (await repo.commandeFournisseur(bcf.code))!;
    expect((c.statut, c.receptions.length), (StatutsCommandeFournisseur.recue, 2));

    // Entrée annulée : la quantité redevient attendue.
    await achats.annuler(e1.code, motif: 'Erreur');
    c = (await repo.commandeFournisseur(bcf.code))!;
    expect((c.statut, c.lignes.first.reste), (StatutsCommandeFournisseur.partielle, 6.0));

    // Solder : reliquat abandonné, plus de réception possible.
    await service.solder(bcf.code);
    c = (await repo.commandeFournisseur(bcf.code))!;
    expect(c.statut, StatutsCommandeFournisseur.soldee);
    await expectLater(
      achats.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 1, prixAchat: 50)],
        commandeCode: bcf.code,
      ),
      throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.commandeCloturee)),
    );

    // Commande sans réception : modifiable puis annulable.
    final bcf2 = await service.creer(
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeLigneDocument(produitCode: sucre.code, quantite: 2, prix: 80)],
    );
    await service.modifier(
      bcf2.code,
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeLigneDocument(produitCode: sucre.code, quantite: 3, prix: 80)],
    );
    expect((await repo.commandeFournisseur(bcf2.code))!.total, 240);
    await service.annuler(bcf2.code, motif: 'Plus besoin');
    expect((await repo.commandeFournisseur(bcf2.code))!.statut, StatutsCommandeFournisseur.annulee);
    await base.fermer();
  });
}
