import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/facture_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_g50.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/fiscalite_repository.dart';
import 'package:caissedz_desktop/data/journal_fiscal_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/situation_repository.dart';
import 'package:caissedz_desktop/domain/fiscalite.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/caisse.dart';
import 'package:caissedz_desktop/domain/models/facture.dart';
import 'package:caissedz_desktop/domain/models/journal_fiscal.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/domain/montant_en_lettres.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  test('montant en lettres', () {
    expect(MontantEnLettres.fr(1250.5), 'mille deux cent cinquante dinars algériens et cinquante centimes');
    expect(MontantEnLettres.nombreFr(80), 'quatre-vingts');
    expect(MontantEnLettres.nombreFr(71), 'soixante et onze');
    expect(MontantEnLettres.nombreFr(97), 'quatre-vingt-dix-sept');
    expect(MontantEnLettres.nombreFr(200), 'deux cents');
    expect(MontantEnLettres.nombreFr(280), 'deux cent quatre-vingts');
    expect(MontantEnLettres.nombreFr(1001), 'mille un');
    expect(MontantEnLettres.nombreFr(300001), 'trois cent mille un');
    expect(MontantEnLettres.nombreFr(2000000), 'deux millions');
    expect(MontantEnLettres.nombreFr(21), 'vingt et un');
  });

  test('ventilation TTC et droit de timbre', () {
    expect(Fiscalite.ventiler(119, 19), (ht: 100.0, tva: 19.0));
    expect(Fiscalite.ventiler(100, 0), (ht: 100.0, tva: 0.0));
    expect(Fiscalite.timbre(300), 0);
    expect(Fiscalite.timbre(400), 5, reason: 'minimum 5 DA');
    expect(Fiscalite.timbre(1190), 12);
    expect(Fiscalite.timbre(50000), 750);
    expect(Fiscalite.timbre(200000), 4000);
  });

  test('TVA figée par ligne, facture, avoirs, timbre, G50', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    Future<Produit> produit(String nom, double tva) => CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      Produit(
        code: '',
        designation: nom,
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 59.5,
        prixVente: 119,
        tvaPct: tva,
      ),
    );
    final cafe = await produit('Café', 19);
    final pain = await produit('Pain', 0);
    for (final p in [cafe, pain]) {
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: 50);
    }
    final client = await TiersService(db, utilisateurCode: 'USR0000').creerClient(
      const Client(
        code: '',
        nom: 'SARL Atlas',
        fiche: FicheTiers(nif: '000116001234567', nis: '000116123456789', nrc: '16/00-1234567B12', ai: '16012345678'),
      ),
    );
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    Future<String> vendre(List<(Produit, double)> lignes) async {
      var panier = Panier(id: 1, clientCode: client.code);
      var total = 0.0;
      for (final (p, q) in lignes) {
        panier = panier.ajouter(PanierLigne(produit: p, quantite: q, prixUnitaire: 119));
        total += q * 119;
      }
      return (await ventes.encaisser(
        panier.ajouterPaiement(Paiement(mode: 'Espèces', montant: total)),
        session: session,
        magasinCode: 'MAG0000',
      )).code;
    }

    final v1 = await vendre([(cafe, 10), (pain, 2)]);
    final factures = FactureService(db, utilisateurCode: 'USR0000');
    final f = await factures.emettre(v1);
    expect(f.code, 'FAC0001');
    expect(f.lignes.first.tauxTva, 19);
    expect(f.lignes.first.montantHt, 1000);
    expect(f.lignes.first.montantTva, 190);
    expect(f.lignes.last.montantTva, 0);
    expect((f.totalHt, f.totalTva, f.totalTtc), (1238.0, 190.0, 1428.0));
    expect(f.timbre, 15, reason: '1 % de 1 428 arrondi au dinar supérieur');
    expect(f.netAPayer, 1443);
    expect(f.client.ai, '16012345678');
    expect(f.montantLettres, 'mille quatre cent quarante-trois dinars algériens');
    expect((await factures.emettre(v1)).code, 'FAC0001', reason: 'réimpression : même facture');
    final timbres = await CaisseRepository(db).mouvements(referenceType: 'facture', referenceCode: 'FAC0001');
    expect(timbres.single.type, TypesMouvementCaisse.timbre);
    expect(timbres.single.montant, 15);
    await expectLater(db.update('facture', {'net_a_payer': 0}), throwsA(anything));
    await expectLater(db.delete('facture'), throwsA(anything));

    // Retour client sur la vente facturée : avoir partiel, retour figé ensuite.
    final retours = RetourService(db, utilisateurCode: 'USR0000');
    final r = await retours.creer(
      type: TypesTiers.client,
      documentCode: v1,
      produitCode: cafe.code,
      quantite: 2,
      ligneOrdre: 0,
    );
    final avoirs = await factures.avoirsDe('FAC0001');
    expect(avoirs.single.code, 'AVO0001');
    expect(avoirs.single.retourCode, r.code);
    expect((avoirs.single.totalHt, avoirs.single.totalTva), (200.0, 38.0));
    await expectLater(
      retours.annuler(r.code, motif: 'x'),
      throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.avoirEmis)),
    );

    // Annulation d'une vente facturée : avoir total ; une seule annulation.
    final v2 = await vendre([(cafe, 1)]);
    await factures.emettre(v2);
    await ventes.annuler(v2, motif: 'Erreur client');
    final a2 = (await factures.avoirsDe('FAC0002')).single;
    expect((a2.code, a2.totalTtc, a2.factureOrigine), ('AVO0002', 119.0, 'FAC0002'));
    await expectLater(factures.emettreAvoir('FAC0002', motif: 'bis'), throwsA(isA<FactureException>()));
    expect((await factures.emettre(v2)).code, 'FAC0002', reason: 'réimpression de la facture émise');
    final v4 = await vendre([(pain, 1)]);
    await ventes.annuler(v4, motif: 'Erreur');
    await expectLater(
      factures.emettre(v4),
      throwsA(isA<FactureException>().having((e) => e.erreur, 'e', ErreurFacture.venteAnnulee)),
    );
    expect(await factures.verifierChaine(), isNull);
    final evts = await JournalFiscalRepository(db).evenements();
    expect(evts.where((e) => e.type == TypesEvenementFiscal.facture).length, 2);
    expect(evts.where((e) => e.type == TypesEvenementFiscal.avoir).length, 2);

    // Entrée : TVA déductible figée.
    await AchatService(db, utilisateurCode: 'USR0000').enregistrer(
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: cafe.code, quantite: 10, prixAchat: 59.5)],
    );

    final g50 = await FiscaliteRepository(db).g50(DateTime(2000), DateTime.now().add(const Duration(minutes: 1)));
    expect(g50.ventes[19.0], (ht: 1000.0, tva: 190.0), reason: 'vente annulée exclue');
    expect(g50.retoursClients[19.0], (ht: 200.0, tva: 38.0));
    expect(g50.tvaCollectee, 152);
    expect(g50.achats[19.0], (ht: 500.0, tva: 95.0));
    expect(g50.tvaNette, 57);
    expect(g50.timbre, 15, reason: 'FAC0002 (119 DA) exonérée de timbre');
    expect(ExportG50.generer(g50, nomBoutique: 'Test').isNotEmpty, isTrue);
    // Même base par caisse (clôture Z) ; une autre caisse n'a rien.
    final parCaisse = await FiscaliteRepository(db)
        .g50(DateTime(2000), DateTime.now().add(const Duration(minutes: 1)), caisseCode: 'CIS0000');
    expect(parCaisse.tvaCollectee, 152);
    final autre = await FiscaliteRepository(db)
        .g50(DateTime(2000), DateTime.now().add(const Duration(minutes: 1)), caisseCode: 'CS9999');
    expect(autre.tvaCollectee, 0);
    // Situation « TVA par taux » : mêmes montants, TVA nette = collectée − déductible.
    final situation = await SituationRepository(db).tva(DateTime(2000), DateTime.now().add(const Duration(minutes: 1)));
    final l19 = situation.firstWhere((l) => l['taux'] == 19.0);
    expect((l19['collectee'], l19['deductible'], l19['nette']), (152.0, 95.0, 57.0));
    expect(l19['baseVentes'], 800.0);

    // Régime IFU : ventes sans TVA.
    await ParametreRepository(db).ecrire(Fiscalite.cleRegime, RegimesFiscaux.ifu);
    final v3 = await vendre([(cafe, 1)]);
    final f3 = await factures.emettre(v3);
    expect((f3.totalTva, f3.lignes.single.tauxTva), (0.0, 0.0));
    expect(f3.type, TypesFacture.facture);
  });
}
