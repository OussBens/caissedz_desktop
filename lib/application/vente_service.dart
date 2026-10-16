import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/journal_fiscal_repository.dart';
import '../data/parametre_repository.dart';
import '../data/stock_repository.dart';
import '../data/tiers_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/fiscalite.dart';
import '../domain/models/caisse.dart';
import '../domain/models/journal_fiscal.dart';
import '../domain/models/panier.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/retour.dart';
import '../domain/models/stock.dart';
import '../domain/models/vente.dart';
import '../domain/referentiel/referentiel.dart';
import '../domain/scellement.dart';
import 'caisse_service.dart';
import 'facture_service.dart';
import 'stock_service.dart';
import 'versement_service.dart';

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
  motifObligatoire,
  montantPayeInferieur,
  retourLie,
  nombreObligatoire,
  plafondCredit,

  /// Monnaie rendue supérieure aux espèces reçues (une carte ou des points ne rendent pas de monnaie).
  monnaieSansEspeces,
}

class VenteException implements Exception {
  const VenteException(this.erreur, [this.detail]);
  final ErreurVente erreur;
  final String? detail;
  @override
  String toString() => 'VenteException($erreur${detail == null ? '' : ', $detail'})';
}

/// Vérifie qu'une date n'appartient pas à une période clôturée (fourni par le lot 7).
/// Vrai si [date] est dans une période clôturée (de [caisseCode] et des clôtures globales ; toutes caisses si nul).
typedef VerificateurCloture = Future<bool> Function(Transaction txn, DateTime date, {String? caisseCode});

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
    bool depassementPlafond = false,
    DateTime? date,
  }) async {
    if (!session.estOuverte) throw const VenteException(ErreurVente.sessionRequise);
    if (panier.estVide) throw const VenteException(ErreurVente.panierVide);
    if (panier.lignes.any((l) => l.quantite <= 0)) throw const VenteException(ErreurVente.quantiteInvalide);
    for (final l in panier.lignes) {
      if (l.nombreStock <= 0 && l.produit.exigeNombre(global: parametres.nombreActif)) {
        throw VenteException(ErreurVente.nombreObligatoire, l.produit.code);
      }
    }
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
    // Monnaie rendue : seulement sur les espèces reçues (m9).
    final especes = panier.paiements.where((p) => p.mode == 'Espèces').fold(0.0, (s, p) => s + p.montant);
    final monnaie = panier.verse - panier.totalNet;
    if (monnaie > especes + 0.004) throw VenteException(ErreurVente.monnaieSansEspeces, '$monnaie');
    // Points gagnés sur le montant réellement encaissé, hors points et hors crédit (m12).
    final horsPoints = panier.paiements.where((p) => p.mode != 'Points').fold(0.0, (s, p) => s + p.montant);
    final encaisse = (horsPoints - (monnaie > 0 ? monnaie : 0)).clamp(0.0, panier.totalNet);
    final pointsGagnes = Fidelite.pointsGagnes(
      encaisse,
      active: parametres.fideliteActive,
      pointsParDinar: parametres.pointsParDinar,
      clientCode: panier.clientCode,
    );
    final d = date ?? DateTime.now();

    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final sessionDb = await repo.session(session.code);
      if (sessionDb == null || !sessionDb.estOuverte) throw const VenteException(ErreurVente.sessionRequise);
      // Magasin de la vente : celui de la caisse ouverte, sinon celui proposé par l'écran (m11).
      final caisseMagasin = await txn.query(
        'caisse',
        columns: ['magasin_code'],
        where: 'code = ?',
        whereArgs: [session.caisseCode],
      );
      final magasin = (caisseMagasin.firstOrNull?['magasin_code'] as String?) ?? magasinCode;
      if (pointsUtilises > 0) {
        if (panier.clientCode == CodeGenerator.systeme(CodeGenerator.client)) {
          throw const VenteException(ErreurVente.pointsInsuffisants);
        }
        final solde = await repo.pointsClient(panier.clientCode);
        if (solde < pointsUtilises) throw VenteException(ErreurVente.pointsInsuffisants, '$solde < $pointsUtilises');
      }
      // Plafond de crédit (> 0) : solde actuel + reste de cette vente, sauf permission de dépassement.
      if (reste > 0.004 && !depassementPlafond) {
        await _controlerPlafond(txn, panier.clientCode, reste);
      }
      final code = await repo.prochainCode('vente', CodeGenerator.vente);
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      // Mouvements de stock (garde de stock) — un pack est déjà éclaté en lignes produit ; services exclus.
      try {
        for (final l in panier.lignes) {
          await stock.sortirDansTransaction(
            txn,
            produitCode: l.produit.code,
            magasinCode: magasin,
            quantite: l.unitesStock,
            nombre: l.nombreStock,
            type: TypesMouvement.vente,
            referenceType: 'vente',
            referenceCode: code,
            date: d,
          );
        }
      } on StockException catch (e) {
        throw VenteException(ErreurVente.stockInsuffisant, e.detail);
      }
      // Coût d'achat figé (§7.4) : unités de stock × prix d'achat du produit ; vente au nombre (pièces) :
      // pièces × prix d'achat / pièces par unité.
      final codesCout = {for (final l in panier.lignes) l.produit.code};
      final fiches = {
        for (final r in await txn.query(
          'produit',
          columns: ['code', 'prix_achat', 'nombre_par_unite'],
          where: 'code IN (${List.filled(codesCout.length, '?').join(',')})',
          whereArgs: codesCout.toList(),
        ))
          r['code'] as String: (
            pa: ((r['prix_achat'] as num?) ?? 0).toDouble(),
            npu: ((r['nombre_par_unite'] as num?) ?? 0).toDouble(),
          ),
      };
      double coutLigne(PanierLigne l) {
        final f = fiches[l.produit.code];
        if (f == null) return 0;
        if (l.uniteVente == UniteVente.nombre) {
          return f.npu <= 0 ? 0 : CalculsPrix.arrondir(f.pa / f.npu * l.quantite);
        }
        return CalculsPrix.arrondir(f.pa * l.unitesStock);
      }

      // TVA figée par ligne (prix TTC) selon le régime fiscal (IFU : sans TVA).
      final regime = await ParametreRepository(txn).lire(Fiscalite.cleRegime) ?? RegimesFiscaux.reel;
      final brutes = [
        for (final (i, l) in panier.lignes.indexed)
          _avecTva(
            VenteLigne(
              ordre: i,
              produitCode: l.produit.code,
              colisCode: l.colis?.code,
              packCode: l.pack?.code,
              composantPack: l.pack != null,
              designation: l.designation,
              quantite: l.quantite,
              nombre: l.nombreStock,
              uniteVente: l.uniteVente == UniteVente.nombre ? 'Nombre' : 'Unité',
              prixUnitaire: l.prixUnitaire,
              remise: CalculsPrix.arrondir(
                l.remise + (panier.remiseGlobalePct > 0 ? l.total * panier.remiseGlobalePct / 100 : 0),
              ),
              total: CalculsPrix.arrondir(l.total * (1 - panier.remiseGlobalePct / 100)),
              prixAchat: l.quantite == 0 ? 0 : CalculsPrix.arrondir(coutLigne(l) / l.quantite),
              totalAchat: coutLigne(l),
              unites: l.unitesStock,
            ),
            Fiscalite.taux(l.produit.tvaPct, regime),
          ),
      ];
      // Remise globale : l'écart d'arrondi entre Σ lignes et le net du ticket va sur la dernière ligne (m6).
      final ecartArrondi = CalculsPrix.arrondir(panier.totalNet - brutes.fold(0.0, (t, l) => t + l.total));
      final lignes = ecartArrondi.abs() < 0.005 || brutes.isEmpty
          ? brutes
          : [
              ...brutes.take(brutes.length - 1),
              _avecTva(
                VenteLigne.depuisLigne({
                  ...brutes.last.versLigne(''),
                  'total': CalculsPrix.arrondir(brutes.last.total + ecartArrondi),
                  'remise': CalculsPrix.arrondir(brutes.last.remise - ecartArrondi),
                }),
                brutes.last.tauxTva,
              ),
            ];
      final hashPrecedent = await repo.dernierHash() ?? Scellement.genese;
      var vente = Vente(
        code: code,
        date: d,
        sessionCode: session.code,
        caisseCode: session.caisseCode,
        magasinCode: magasin,
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
      await JournalFiscalRepository(txn).ajouter(
        type: TypesEvenementFiscal.vente,
        referenceCode: code,
        caisseCode: session.caisseCode,
        utilisateurCode: utilisateurCode,
        montant: vente.totalNet,
        details: {'hash': hash, 'client': vente.clientCode},
        date: d,
      );
      // Journal de caisse : une entrée par paiement (hors points), espèces nettes de la monnaie rendue.
      var monnaie = vente.monnaie;
      for (final p in panier.paiements) {
        if (p.mode == 'Points') continue;
        var montant = p.montant;
        if (p.mode == 'Espèces' && monnaie > 0) {
          final m = monnaie > montant ? montant : monnaie;
          montant -= m;
          monnaie -= m;
        }
        await CaisseService.journaliser(
          txn,
          caisseCode: session.caisseCode,
          type: TypesMouvementCaisse.vente,
          sens: SensMouvementCaisse.entree,
          montant: montant,
          mode: p.mode,
          referenceType: 'vente',
          referenceCode: code,
          utilisateurCode: utilisateurCode,
          date: d,
        );
      }
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

  static VenteLigne _avecTva(VenteLigne l, double taux) {
    final v = Fiscalite.ventiler(l.total, taux);
    return VenteLigne.depuisLigne({...l.versLigne(''), 'taux_tva': taux, 'montant_ht': v.ht, 'montant_tva': v.tva});
  }

  static Future<void> _controlerPlafond(Transaction txn, String clientCode, double reste) async {
    final r = await txn.query('client', columns: ['plafond_credit'], where: 'code = ?', whereArgs: [clientCode]);
    final plafond = r.isEmpty ? 0.0 : ((r.first['plafond_credit'] as num?) ?? 0).toDouble();
    if (plafond <= 0) return;
    final solde = await TiersRepository(txn).soldeClient(clientCode);
    if (solde + reste > plafond + 0.004) {
      throw VenteException(
        ErreurVente.plafondCredit,
        '${CalculsPrix.arrondir(plafond)}|${CalculsPrix.arrondir(solde > 0 ? solde : 0)}',
      );
    }
  }

  /// Modifie un panier (§9.2) sans toucher au ticket scellé : le complément payé devient un versement
  /// imputé d'abord sur ce panier (mode et caisse choisis), l'observation est mise à jour.
  /// Le montant payé ne peut pas baisser (utiliser un retour) ; client et lignes restent ceux du ticket.
  Future<Vente> modifier(
    String code, {
    required double montantPaye,
    required String mode,
    String? caisseCode,
    String? commentaire,
  }) async {
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final v = await repo.vente(code);
      if (v == null) throw const VenteException(ErreurVente.venteInconnue);
      if (v.statut == StatutsVente.annulee) throw const VenteException(ErreurVente.dejaAnnulee);
      if (periodeCloturee != null && await periodeCloturee!(txn, v.date, caisseCode: v.caisseCode)) {
        throw const VenteException(ErreurVente.periodeCloturee);
      }
      final impute = await TiersRepository(txn).imputeSur('vente', code);
      final payeActuel = CalculsPrix.arrondir(v.totalNet - v.reste + impute);
      final complement = CalculsPrix.arrondir(montantPaye - payeActuel);
      if (complement < -0.004) throw VenteException(ErreurVente.montantPayeInferieur, '$payeActuel');
      if (complement > 0.004) {
        if (v.clientCode == CodeGenerator.systeme(CodeGenerator.client)) {
          throw const VenteException(ErreurVente.creditNonAutorise);
        }
        // Le complément encaissé est un versement : session de caisse ouverte exigée (§8.4, m10).
        if (await repo.sessionOuverte(utilisateurCode: utilisateurCode) == null) {
          throw const VenteException(ErreurVente.sessionRequise);
        }
        try {
          await VersementService(txn.database, utilisateurCode: utilisateurCode).imputerDansTransaction(
            txn,
            tiersType: TypesTiers.client,
            tiersCode: v.clientCode,
            montant: complement,
            mode: mode,
            caisseCode: caisseCode,
            reference: code,
            documentCible: code,
          );
        } on VersementException {
          throw const VenteException(ErreurVente.modePaiementInvalide);
        }
      }
      final note = commentaire?.trim();
      if ((note ?? '') != (v.commentaire ?? '')) {
        await txn.update(
          'vente',
          {'commentaire': (note?.isEmpty ?? true) ? null : note},
          where: 'code = ?',
          whereArgs: [code],
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'vente',
        entiteCode: code,
        detail: complement > 0.004 ? 'versement $complement $mode' : null,
      );
      return (await repo.vente(code))!;
    });
  }

  /// Annule une vente (motif obligatoire, refusée si un retour y est lié) : stock restitué, points repris, versements imputés uniquement
  /// sur ce panier annulés (les autres libèrent leur imputation), statut Annulée (le ticket scellé est
  /// conservé). Refusée si la vente est dans une période clôturée (lot 7).
  Future<Vente> annuler(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const VenteException(ErreurVente.motifObligatoire);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final v = await repo.vente(code);
      if (v == null) throw const VenteException(ErreurVente.venteInconnue);
      if (v.statut == StatutsVente.annulee) throw const VenteException(ErreurVente.dejaAnnulee);
      if (periodeCloturee != null && await periodeCloturee!(txn, v.date, caisseCode: v.caisseCode)) {
        throw const VenteException(ErreurVente.periodeCloturee);
      }
      final retours = await txn.rawQuery(
        "SELECT COUNT(*) n FROM retour WHERE document_code = ? AND type = 'Client' AND etat = 1",
        [code],
      );
      if ((retours.first['n']! as int) > 0) throw const VenteException(ErreurVente.retourLie);
      // Stock rétabli d'après les mouvements réels de la vente (et non la définition actuelle des colis / packs).
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      final net = await txn.rawQuery(
        '''
        SELECT produit_code p, magasin_code m, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock
        WHERE reference_type = 'vente' AND reference_code = ? GROUP BY produit_code, magasin_code
        ''',
        [code],
      );
      for (final m in net) {
        final q = -(m['q']! as num).toDouble();
        final n = -(m['n']! as num).toDouble();
        if (q.abs() < 1e-9 && n.abs() < 1e-9) continue;
        await stock.entrerDansTransaction(
          txn,
          produitCode: m['p']! as String,
          magasinCode: m['m']! as String,
          quantite: q,
          nombre: n,
          type: TypesMouvement.annulation,
          referenceType: 'annulation',
          referenceCode: code,
        );
      }
      if (v.pointsGagnes - v.pointsUtilises != 0) {
        await repo.ajusterPoints(v.clientCode, -(v.pointsGagnes - v.pointsUtilises));
      }
      // Journal de caisse : sortie égale aux entrées de la vente (remboursement au client).
      for (final m in await CaisseRepository(txn).mouvements(referenceType: 'vente', referenceCode: code)) {
        if (m.sens != SensMouvementCaisse.entree) continue;
        await CaisseService.journaliser(
          txn,
          caisseCode: m.caisseCode,
          type: TypesMouvementCaisse.annulation,
          sens: SensMouvementCaisse.sortie,
          montant: m.montant,
          mode: m.mode,
          referenceType: 'annulation',
          referenceCode: code,
          utilisateurCode: utilisateurCode,
        );
      }
      // Versements liés (§9.2) : annulés s'ils ne portent que sur ce panier, sinon imputation libérée.
      final tiers = TiersRepository(txn);
      final lies = await txn.rawQuery(
        '''
        SELECT DISTINCT i.versement_code c,
          (SELECT COUNT(*) FROM versement_imputation j WHERE j.versement_code = i.versement_code
            AND NOT (j.document_type = 'vente' AND j.document_code = ?)) autres
        FROM versement_imputation i JOIN versement ve ON ve.code = i.versement_code
        WHERE i.document_type = 'vente' AND i.document_code = ? AND ve.etat = 1
        ''',
        [code, code],
      );
      for (final l in lies) {
        final vc = l['c']! as String;
        if ((l['autres']! as int) == 0) {
          await tiers.annulerVersement(vc, par: utilisateurCode, motif: motif.trim());
          await CaisseRepository(txn).contrePasserReference(
            'versement',
            vc,
            utilisateurCode: utilisateurCode,
            commentaire: 'Annulation $code : ${motif.trim()}',
          );
        } else {
          await txn.delete(
            'versement_imputation',
            where: "versement_code = ? AND document_type = 'vente' AND document_code = ?",
            whereArgs: [vc, code],
          );
        }
      }
      // Événement fiscal chaîné AVANT le changement de statut (le déclencheur v30 l'exige).
      await JournalFiscalRepository(txn).ajouter(
        type: TypesEvenementFiscal.annulationVente,
        referenceCode: code,
        caisseCode: v.caisseCode,
        utilisateurCode: utilisateurCode,
        montant: -v.totalNet,
        details: {'hash': v.hash, 'motif': motif.trim()},
      );
      await repo.annulerVente(code, par: utilisateurCode, le: DateTime.now());
      // Vente facturée : la facture reste, un avoir total l'annule.
      await FactureService.avoirPourAnnulation(txn, code, motif: motif.trim(), utilisateurCode: utilisateurCode);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'vente',
        entiteCode: code,
        detail: motif.trim(),
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
