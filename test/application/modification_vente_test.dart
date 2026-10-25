import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/journal_fiscal_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/journal_fiscal.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/vente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

/// Modification d'une vente scellée depuis la caisse : la vente est rechargée dans un panier (lignes verrouillées),
/// on change le client ou on ajoute des produits ; à l'encaissement, elle est annulée et remplacée par un nouveau
/// ticket qui reprend ses lignes et ce qui était déjà payé.
void main() {
  late Database db;
  late Produit lait;
  late SessionCaisse session;
  late VenteService ventes;

  setUp(() async {
    db = (await ouvrirBaseDeTest()).db;
    lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
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
    await db.insert('client', {'code': 'CLN0001', 'nom': 'Amina'});
    await db.insert('client', {'code': 'CLN0002', 'nom': 'Karim'});
    session = await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  });

  Future<double> stockLait() async => (await StockRepository(db).niveau(lait.code, 'MAG0000')).quantite;

  /// Panier de la vente [code] rechargé comme le fait la caisse, client [client] (le sien par défaut).
  Future<Panier> recharger(String code, {String? client}) async {
    final m = await ventes.preparerModification(code);
    return Panier(
      id: 1,
      lignes: [for (final l in m.vente.lignes) PanierLigne.reprise(l, lait)],
      clientCode: client ?? m.vente.clientCode,
      remplacement: m.remplacement,
    );
  }

  test('produits ajoutés : la vente est annulée et remplacée, seule la différence entre en caisse', () async {
    // 2 laits payés 250 en espèces : 50 rendus.
    final v1 = await ventes.encaisser(
      const Panier(id: 1)
          .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 250)),
      session: session,
      magasinCode: 'MAG0000',
    );
    expect(await stockLait(), 8);

    var panier = await recharger(v1.code);
    expect([panier.remplacement!.paye, panier.dejaPaye, panier.aPayer], [200, 200, 0]);
    // Les lignes reprises ne se retirent ni ne se modifient ; elles ne réservent pas de stock.
    expect(panier.retirer(0).lignes, hasLength(1));
    expect(panier.modifierQuantite(0, 5).lignes.single.quantite, 2);
    expect(panier.vider().lignes, hasLength(1));
    expect(panier.unitesReservees(lait.code), 0);

    // Un lait de plus, payé 100.
    panier = panier
        .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
        .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100));
    expect([panier.lignes.length, panier.totalNet, panier.aPayer], [2, 300, 100]);
    final v2 = await ventes.encaisser(panier, session: session, magasinCode: 'MAG0000');

    expect([v2.totalNet, v2.verse, v2.reste, v2.monnaie], [300, 300, 0, 0]);
    expect(v2.lignes.map((l) => (l.quantite, l.total, l.totalAchat)), [(2, 200, 160), (1, 100, 80)]);
    expect(v2.paiements.map((p) => (p.mode, p.montant)), [('Espèces', 200), ('Espèces', 100)]);
    expect((await VenteRepository(db).vente(v1.code))!.statut, StatutsVente.annulee);
    expect(await stockLait(), 7, reason: 'le stock de la vente d’origine est ressorti, plus le lait ajouté');

    // Caisse : l'argent de la vente d'origine reste (pas de remboursement), le nouveau ticket n'ajoute que 100.
    final caisse = CaisseRepository(db);
    expect((await caisse.mouvements(referenceType: 'annulation', referenceCode: v1.code)), isEmpty);
    expect((await caisse.mouvements(referenceType: 'vente', referenceCode: v2.code)).map((m) => m.montant), [100]);

    // Journal fiscal : annulation chaînée qui nomme le ticket de remplacement ; la chaîne reste intacte.
    final annulation = (await JournalFiscalRepository(
      db,
    ).evenements(type: TypesEvenementFiscal.annulationVente, referenceCode: v1.code)).single;
    expect(annulation.contenu, contains(v2.code));
    expect(await ventes.verifierChaine(), isNull);

    await expectLater(
      ventes.preparerModification(v1.code),
      throwsA(isA<VenteException>().having((e) => e.erreur, 'erreur', ErreurVente.dejaAnnulee)),
    );
  });

  test('vente à crédit, même client : versements imputés repris par le nouveau ticket', () async {
    final v1 = await ventes.encaisser(
      const Panier(id: 1, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 50)),
      session: session,
      magasinCode: 'MAG0000',
      creditAutorise: true,
    );
    await VersementService(db, utilisateurCode: 'USR0000').imputer(
      tiersType: TypesTiers.client,
      tiersCode: 'CLN0001',
      montant: 100,
      mode: 'Espèces',
      caisseCode: 'CIS0000',
      documentCible: v1.code,
    );
    final panier = (await recharger(v1.code)).ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100));
    expect([panier.remplacement!.paye, panier.remplacement!.impute, panier.aPayer], [50, 100, 150]);
    await expectLater(
      ventes.encaisser(panier, session: session, magasinCode: 'MAG0000'),
      throwsA(isA<VenteException>().having((e) => e.erreur, 'erreur', ErreurVente.paiementInsuffisant)),
      reason: 'le reste dû exige le crédit',
    );
    final v2 = await ventes.encaisser(panier, session: session, magasinCode: 'MAG0000', creditAutorise: true);
    expect([v2.verse, v2.reste], [50, 250]);
    final tiers = TiersRepository(db);
    expect(await tiers.imputeSur('vente', v2.code), 100);
    expect(await tiers.imputeSur('vente', v1.code), 0);
  });

  test('client changé : versements et points restent au client d’origine', () async {
    final v1 = await ventes.encaisser(
      const Panier(id: 1, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 40)),
      session: session,
      magasinCode: 'MAG0000',
      creditAutorise: true,
    );
    await VersementService(db, utilisateurCode: 'USR0000').imputer(
      tiersType: TypesTiers.client,
      tiersCode: 'CLN0001',
      montant: 60,
      mode: 'Espèces',
      caisseCode: 'CIS0000',
      documentCible: v1.code,
    );
    final panier = await recharger(v1.code, client: 'CLN0002');
    expect([panier.dejaPaye, panier.aPayer], [40, 60], reason: 'le versement d’Amina ne paie pas pour Karim');
    final v2 = await ventes.encaisser(
      panier.ajouterPaiement(const Paiement(mode: 'Espèces', montant: 60)),
      session: session,
      magasinCode: 'MAG0000',
    );
    expect([v2.clientCode, v2.totalNet, v2.verse, v2.reste], ['CLN0002', 100, 100, 0]);
    // Le versement d'Amina n'est plus imputé : il reste en avance sur son compte.
    expect(await TiersRepository(db).imputeSur('vente', v1.code), 0);
    expect(await TiersRepository(db).imputeSur('vente', v2.code), 0);
    expect(await stockLait(), 9);
  });
}
