import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

/// Parcours complets : à chaque création / modification / annulation, le stock, la caisse (espèces) et les
/// soldes client et fournisseur doivent rester cohérents entre eux.
void main() {
  test('retours, sorties, ventes et versements : stock, caisse et soldes cohérents', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    const u = 'USR0000';
    final lait = await CatalogueService(db, utilisateurCode: u).creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
      ),
    );
    final stock = StockService(db, utilisateurCode: u);
    await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 100);
    final tiers = TiersService(db, utilisateurCode: u);
    final amina = await tiers.creerClient(const Client(code: '', nom: 'Amina'));
    final djurdjura = await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Djurdjura'));
    final session = await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: u, parametres: const ParametresVente());
    final versements = VersementService(db, utilisateurCode: u);
    final retours = RetourService(db, utilisateurCode: u);
    final repo = TiersRepository(db);

    Future<void> etat(String etape, {double? stockLait, double? caisse, double? client, double? fournisseur}) async {
      if (stockLait != null) {
        expect((await StockRepository(db).niveau(lait.code, 'MAG0000')).quantite, stockLait, reason: '$etape : stock');
      }
      if (caisse != null) {
        final c = CaisseRepository(db);
        expect((await c.solde('CIS0000')).especes, closeTo(caisse, 0.001), reason: '$etape : caisse');
        expect(await c.especesSession('CIS0000', session.code), closeTo(caisse, 0.001), reason: '$etape : session');
      }
      if (client != null) {
        expect(await repo.solde(TypesTiers.client, amina.code), closeTo(client, 0.001), reason: '$etape : client');
      }
      if (fournisseur != null) {
        expect(
          await repo.solde(TypesTiers.fournisseur, djurdjura.code),
          closeTo(fournisseur, 0.001),
          reason: '$etape : fournisseur',
        );
      }
    }

    Future<String> vendre(double quantite, double paye) async => (await ventes.encaisser(
      Panier(id: 1, clientCode: amina.code)
          .ajouter(PanierLigne(produit: lait, quantite: quantite, prixUnitaire: 100))
          .copyWith(
            paiements: [if (paye > 0) Paiement(mode: 'Espèces', montant: paye)],
          ),
      session: session,
      magasinCode: 'MAG0000',
      creditAutorise: true,
    )).code;

    // ---- Vente : 10 × 100 = 1 000, payée 400 → crédit 600.
    final v1 = await vendre(10, 400);
    await etat('vente', stockLait: 90, caisse: 400, client: 600);

    // ---- Versement client : créer 300, modifier en 500, annuler.
    final vc = await versements.imputer(
      tiersType: TypesTiers.client,
      tiersCode: amina.code,
      montant: 300,
      mode: 'Espèces',
    );
    await etat('versement client', caisse: 700, client: 300);
    await versements.modifier(vc.code, montant: 500, mode: 'Espèces', date: vc.date);
    await etat('versement client modifié', caisse: 900, client: 100);
    expect((await repo.documentsOuvertsClient(amina.code)).single.reste, 100);
    await versements.annuler(vc.code, motif: 'Erreur');
    await etat('versement client annulé', stockLait: 90, caisse: 400, client: 600);
    expect((await repo.documentsOuvertsClient(amina.code)).single.reste, 600, reason: 'imputation libérée');

    // ---- Retour client : créer 2 en avoir, modifier en 3 remboursés en espèces, puis 1 non remis en stock,
    // annuler.
    final r = await retours.creer(
      type: TypesTiers.client,
      documentCode: v1,
      produitCode: lait.code,
      quantite: 2,
      reglement: ReglementsRetour.avoir,
    );
    await etat('retour client avoir', stockLait: 92, caisse: 400, client: 400);
    await retours.modifier(r.code, quantite: 3, reglement: ReglementsRetour.especes);
    await etat('retour client remboursé', stockLait: 93, caisse: 100, client: 600);
    await retours.modifier(r.code, quantite: 1, reglement: ReglementsRetour.avoir, remiseEnStock: false);
    await etat('retour client casse', stockLait: 90, caisse: 400, client: 500);
    final casse = (await StockRepository(db).sorties()).where((s) => s.retourCode == r.code).toList();
    expect(casse.where((s) => s.actif).length, 1, reason: 'une seule sortie Casse active');
    await retours.annuler(r.code, motif: 'Erreur');
    await etat('retour client annulé', stockLait: 90, caisse: 400, client: 600);
    expect(
      (await StockRepository(db).sorties()).where((s) => s.retourCode == r.code && s.actif),
      isEmpty,
      reason: 'sortie Casse annulée avec le retour',
    );

    // ---- Annuler la vente : stock, paiement du ticket et versement imputé sur ce seul panier rendus ;
    // un versement débordant sur une avance reste (avance du client), seule son imputation est libérée.
    await versements.imputer(tiersType: TypesTiers.client, tiersCode: amina.code, montant: 200, mode: 'Espèces');
    await etat('versement imputé au panier', caisse: 600, client: 400);
    await ventes.annuler(v1, motif: 'Erreur');
    await etat('vente annulée', stockLait: 100, caisse: 0, client: 0);
    final v2 = await vendre(5, 0);
    await versements.imputer(tiersType: TypesTiers.client, tiersCode: amina.code, montant: 800, mode: 'Espèces');
    await etat('versement avec avance', stockLait: 95, caisse: 800, client: -300);
    await ventes.annuler(v2, motif: 'Erreur');
    await etat('vente annulée, avance gardée', stockLait: 100, caisse: 800, client: -800);

    // ---- Entrée fournisseur 10 × 80 = 800 non payée, versement fournisseur : créer 500, modifier 600, annuler.
    final achat = await AchatService(db, utilisateurCode: u).enregistrer(
      fournisseurCode: djurdjura.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
    );
    await etat('entrée', stockLait: 110, caisse: 800, fournisseur: 800);
    final vf = await versements.imputer(
      tiersType: TypesTiers.fournisseur,
      tiersCode: djurdjura.code,
      montant: 500,
      mode: 'Espèces',
    );
    await etat('versement fournisseur', caisse: 300, fournisseur: 300);
    await versements.modifier(vf.code, montant: 600, mode: 'Espèces', date: vf.date);
    await etat('versement fournisseur modifié', caisse: 200, fournisseur: 200);
    await versements.annuler(vf.code, motif: 'Erreur');
    await etat('versement fournisseur annulé', caisse: 800, fournisseur: 800);

    // ---- Retour fournisseur : créer 2 en avoir, modifier en 3 remboursés en espèces, annuler.
    final rf = await retours.creer(
      type: TypesTiers.fournisseur,
      documentCode: achat.code,
      produitCode: lait.code,
      quantite: 2,
    );
    await etat('retour fournisseur avoir', stockLait: 108, caisse: 800, fournisseur: 640);
    await retours.modifier(rf.code, quantite: 3, reglement: ReglementsRetour.especes);
    await etat('retour fournisseur remboursé', stockLait: 107, caisse: 1040, fournisseur: 800);
    await retours.annuler(rf.code, motif: 'Erreur');
    await etat('retour fournisseur annulé', stockLait: 110, caisse: 800, fournisseur: 800);

    // ---- Sortie : créer 5, modifier en 3, annuler (ni caisse ni solde touchés).
    final s = await stock.sortir(
      magasinCode: 'MAG0000',
      motif: 'Casse',
      lignes: [LigneStock(produitCode: lait.code, quantite: 5)],
    );
    await etat('sortie', stockLait: 105, caisse: 800, client: -800, fournisseur: 800);
    await stock.modifierSortie(
      s.code,
      magasinCode: 'MAG0000',
      motif: 'Casse',
      lignes: [LigneStock(produitCode: lait.code, quantite: 3)],
    );
    await etat('sortie modifiée', stockLait: 107, caisse: 800, client: -800, fournisseur: 800);
    await stock.annulerSorties([s.code], motif: 'Erreur');
    await etat('sortie annulée', stockLait: 110, caisse: 800, client: -800, fournisseur: 800);

    // ---- Sans session ouverte : modifier ou annuler un versement est refusé (comme la saisie).
    final v3 = await versements.imputer(
      tiersType: TypesTiers.fournisseur,
      tiersCode: djurdjura.code,
      montant: 100,
      mode: 'Espèces',
    );
    final autre = VersementService(db, utilisateurCode: 'USR9999');
    await expectLater(
      autre.annuler(v3.code, motif: 'x'),
      throwsA(isA<VersementException>().having((e) => e.erreur, 'erreur', ErreurVersement.sessionRequise)),
    );
    await expectLater(
      autre.modifier(v3.code, montant: 50, mode: 'Espèces', date: v3.date),
      throwsA(isA<VersementException>().having((e) => e.erreur, 'erreur', ErreurVersement.sessionRequise)),
    );
    await base.fermer();
  });
}
