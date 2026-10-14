import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/stock_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/panier.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/stock.dart';
import '../domain/models/vente.dart';
import '../domain/referentiel/referentiel.dart';
import '../domain/scellement.dart';
import 'stock_service.dart';

enum ErreurVente {
  sessionRequise,
  panierVide,
  paiementInsuffisant,
  modePaiementInvalide,
  pointsInsuffisants,
  stockInsuffisant,
  creditNonAutorise,
  venteInconnue,
  dejaAnnulee,
  periodeCloturee,
  quantiteInvalide,
}

class VenteException implements Exception {
  const VenteException(this.erreur, [this.detail]);
  final ErreurVente erreur;
  final String? detail;
  @override
  String toString() => 'VenteException($erreur${detail == null ? '' : ', $detail'})';
}

/// Vérifie qu'une date n'appartient pas à une période clôturée (fourni par le lot 7).
typedef VerificateurCloture = Future<bool> Function(Transaction txn, DateTime date);

/// Cas d'usage de la vente : encaissement (UNE transaction : vente + lignes +
/// paiements + mouvements de stock + points + scellement) et annulation.
class VenteService {
  const VenteService(this.db, {required this.utilisateurCode, required this.parametres, this.periodeCloturee});

  final Database db;
  final String utilisateurCode;
  final ParametresVente parametres;
  final VerificateurCloture? periodeCloturee;

  VenteRepository get _repo => VenteRepository(db);

  /// Encaisse le panier. [creditAutorise] permet un reste dû (vente à crédit, client identifié).
  Future<Vente> encaisser(
    Panier panier, {
    required SessionCaisse session,
    required String magasinCode,
    bool creditAutorise = false,
    DateTime? date,
  }) async {
    if (!session.estOuverte) throw const VenteException(ErreurVente.sessionRequise);
    if (panier.estVide) throw const VenteException(ErreurVente.panierVide);
    if (panier.lignes.any((l) => l.quantite <= 0)) throw const VenteException(ErreurVente.quantiteInvalide);
    for (final p in panier.paiements) {
      if (!Referentiel.modesPaiement.contient(p.mode) || p.montant <= 0) {
        throw const VenteException(ErreurVente.modePaiementInvalide);
      }
    }
    final reste = panier.reste;
    if (reste > 0) {
      if (!creditAutorise || panier.clientCode == CodeGenerator.systeme(CodeGenerator.client)) {
        throw VenteException(ErreurVente.paiementInsuffisant, 'reste $reste');
      }
    }
    final pointsUtilises = panier.paiements
        .where((p) => p.mode == 'Points')
        .fold(0, (s, p) => s + Fidelite.pointsPourMontant(p.montant));
    final pointsGagnes = Fidelite.pointsGagnes(
      panier.totalNet,
      active: parametres.fideliteActive,
      pointsParDinar: parametres.pointsParDinar,
      clientCode: panier.clientCode,
    );
    final d = date ?? DateTime.now();

    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final sessionDb = await repo.session(session.code);
      if (sessionDb == null || !sessionDb.estOuverte) throw const VenteException(ErreurVente.sessionRequise);
      if (pointsUtilises > 0) {
        if (panier.clientCode == CodeGenerator.systeme(CodeGenerator.client)) {
          throw const VenteException(ErreurVente.pointsInsuffisants);
        }
        final solde = await repo.pointsClient(panier.clientCode);
        if (solde < pointsUtilises) throw VenteException(ErreurVente.pointsInsuffisants, '$solde < $pointsUtilises');
      }
      final code = await repo.prochainCode('vente', CodeGenerator.vente);
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      // Mouvements de stock (garde de stock) — composants de pack sortis individuellement.
      try {
        for (final l in panier.lignes) {
          if (l.pack != null) {
            for (final c in l.pack!.lignes) {
              await stock.sortirDansTransaction(
                txn,
                produitCode: c.produitCode,
                magasinCode: magasinCode,
                quantite: c.quantite * l.quantite,
                type: TypesMouvement.vente,
                referenceType: 'vente',
                referenceCode: code,
                date: d,
              );
            }
          } else {
            await stock.sortirDansTransaction(
              txn,
              produitCode: l.produit.code,
              magasinCode: magasinCode,
              quantite: l.unitesStock,
              nombre: l.nombreStock,
              type: TypesMouvement.vente,
              referenceType: 'vente',
              referenceCode: code,
              date: d,
            );
          }
        }
      } on StockException catch (e) {
        throw VenteException(ErreurVente.stockInsuffisant, e.detail);
      }
      final lignes = [
        for (final (i, l) in panier.lignes.indexed)
          VenteLigne(
            ordre: i,
            produitCode: l.produit.code,
            colisCode: l.colis?.code,
            packCode: l.pack?.code,
            designation: l.designation,
            quantite: l.quantite,
            nombre: l.nombreStock,
            uniteVente: l.uniteVente == UniteVente.nombre ? 'Nombre' : 'Unité',
            prixUnitaire: l.prixUnitaire,
            remise: CalculsPrix.arrondir(
              l.remise + (panier.remiseGlobalePct > 0 ? l.total * panier.remiseGlobalePct / 100 : 0),
            ),
            total: CalculsPrix.arrondir(l.total * (1 - panier.remiseGlobalePct / 100)),
          ),
      ];
      final hashPrecedent = await repo.dernierHash() ?? Scellement.genese;
      var vente = Vente(
        code: code,
        date: d,
        sessionCode: session.code,
        caisseCode: session.caisseCode,
        magasinCode: magasinCode,
        clientCode: panier.clientCode,
        utilisateurCode: utilisateurCode,
        totalBrut: panier.totalBrut,
        totalRemise: panier.totalRemise,
        totalNet: panier.totalNet,
        verse: panier.verse,
        reste: reste,
        pointsGagnes: pointsGagnes,
        pointsUtilises: pointsUtilises,
        hash: '',
        hashPrecedent: hashPrecedent,
        lignes: lignes,
        paiements: panier.paiements,
        commentaire: panier.commentaire,
      );
      final hash = Scellement.hacher(vente.versCanonique(), hashPrecedent);
      vente = Vente.depuisLigne({...vente.versLigne(), 'hash': hash}, lignes: lignes, paiements: panier.paiements);
      await repo.insererVente(vente);
      if (pointsGagnes - pointsUtilises != 0) {
        await repo.ajusterPoints(panier.clientCode, pointsGagnes - pointsUtilises);
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Encaissement',
        entite: 'vente',
        entiteCode: code,
        detail: 'net ${panier.totalNet}',
      );
      return vente;
    });
  }

  /// Annule une vente : stock restitué, points repris, statut Annulée (le ticket scellé est conservé).
  /// Refusée si la vente est dans une période clôturée (lot 7).
  Future<Vente> annuler(String code, {String? motif}) async {
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final v = await repo.vente(code);
      if (v == null) throw const VenteException(ErreurVente.venteInconnue);
      if (v.statut == StatutsVente.annulee) throw const VenteException(ErreurVente.dejaAnnulee);
      if (periodeCloturee != null && await periodeCloturee!(txn, v.date)) {
        throw const VenteException(ErreurVente.periodeCloturee);
      }
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      final catalogue = CatalogueRepository(txn);
      for (final l in v.lignes) {
        if (l.packCode != null) {
          final pack = (await catalogue.packs()).where((p) => p.code == l.packCode).firstOrNull;
          for (final c in pack?.lignes ?? const []) {
            await stock.entrerDansTransaction(
              txn,
              produitCode: c.produitCode,
              magasinCode: v.magasinCode,
              quantite: c.quantite * l.quantite,
              type: TypesMouvement.retour,
              referenceType: 'annulation',
              referenceCode: code,
            );
          }
        } else {
          final colisQ = l.colisCode == null
              ? 1
              : ((await catalogue.colis()).where((c) => c.code == l.colisCode).firstOrNull?.quantite ?? 1);
          await stock.entrerDansTransaction(
            txn,
            produitCode: l.produitCode,
            magasinCode: v.magasinCode,
            quantite: l.uniteVente == 'Nombre' ? 0 : l.quantite * colisQ,
            nombre: l.nombre,
            type: TypesMouvement.retour,
            referenceType: 'annulation',
            referenceCode: code,
          );
        }
      }
      if (v.pointsGagnes - v.pointsUtilises != 0) {
        await repo.ajusterPoints(v.clientCode, -(v.pointsGagnes - v.pointsUtilises));
      }
      await repo.annulerVente(code, par: utilisateurCode, le: DateTime.now());
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'vente',
        entiteCode: code,
        detail: motif,
      );
      return (await repo.vente(code))!;
    });
  }

  /// Vérifie l'intégrité de la chaîne de tickets ; `null` = intacte, sinon code du premier ticket altéré.
  Future<String?> verifierChaine() async {
    final ventes = await _repo.chaine();
    final i = Scellement.verifier([
      for (final v in ventes) (doc: v.versCanonique(), hashPrecedent: v.hashPrecedent, hash: v.hash),
    ]);
    return i == null ? null : ventes[i].code;
  }

  /// Stock disponible d'un produit dans un magasin (pour la réservation entre paniers).
  Future<NiveauStock> disponible(String produitCode, String magasinCode) =>
      StockRepository(db).niveau(produitCode, magasinCode);
}
