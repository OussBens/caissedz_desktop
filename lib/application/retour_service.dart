import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/achat.dart';
import '../domain/models/caisse.dart';
import '../domain/models/retour.dart';
import '../domain/models/stock.dart';
import '../domain/models/vente.dart';
import 'achat_service.dart';
import 'session_caisse_service.dart';
import 'stock_service.dart';
import 'vente_service.dart';
import 'versement_service.dart';

enum ErreurRetour {
  documentInconnu,
  documentAnnule,
  produitAbsent,
  quantiteInvalide,
  quantiteDepasse,
  periodeCloturee,
  reglementInvalide,
  stockInsuffisant,
  retourInconnu,
  dejaAnnule,
  motifObligatoire,
  sessionRequise,
}

class RetourException implements Exception {
  const RetourException(this.erreur, [this.detail]);
  final ErreurRetour erreur;
  final String? detail;
  @override
  String toString() => 'RetourException($erreur)';
}

/// Retours clients et fournisseurs (§9.3), un produit de la pièce d'origine par retour.
///
/// - Client (depuis un panier) : stock réintégré dans le magasin de la vente (ou sortie « Casse » si le
///   produit n'est pas revendable), remboursement Espèces / Carte (versement verrouillé, sortie de caisse)
///   ou avoir imputé sur les documents ouverts du client (le panier d'origine d'abord).
/// - Fournisseur (depuis une entrée) : sortie du stock du magasin de l'entrée, déduit de la dette
///   (avoir imputé, l'entrée d'origine d'abord) ou remboursé en espèces (entrée de caisse).
///
/// Chaque écriture se fait en UNE transaction ; modifier et annuler défont d'abord les effets
/// (mouvements de stock inverses, versements liés annulés).
class RetourService {
  const RetourService(this.db, {required this.utilisateurCode, this.periodeCloturee});

  final Database db;
  final String utilisateurCode;
  final VerificateurCloture? periodeCloturee;

  Future<Retour> creer({
    required String type,
    required String documentCode,
    required String produitCode,
    required double quantite,
    String reglement = ReglementsRetour.especes,
    bool remiseEnStock = true,
    String? numeroSerie,
    String? observation,
    String? caisseCode,
    DateTime? date,
  }) => db.transaction((txn) async {
    if (!await SessionCaisseService.sessionOuverte(txn, utilisateurCode)) {
      throw const RetourException(ErreurRetour.sessionRequise);
    }
    final code = await TiersRepository(txn).prochainCode('retour', CodeGenerator.retour);
    final r = await _appliquer(
      txn,
      code: code,
      type: type,
      documentCode: documentCode,
      produitCode: produitCode,
      quantite: quantite,
      reglement: reglement,
      remiseEnStock: remiseEnStock,
      numeroSerie: numeroSerie,
      observation: observation,
      caisseCode: caisseCode,
      date: date ?? DateTime.now(),
      nouveau: true,
    );
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Retour',
      entite: 'retour',
      entiteCode: code,
      detail: '$type $documentCode $produitCode × $quantite, total ${r.total}',
    );
    return r;
  });

  /// Modifie un retour actif : effets défaits puis réappliqués (même code, même pièce d'origine,
  /// même produit) avec la nouvelle quantité, le règlement, la remise en stock et l'observation.
  Future<Retour> modifier(
    String code, {
    required double quantite,
    required String reglement,
    bool remiseEnStock = true,
    String? numeroSerie,
    String? observation,
    String? caisseCode,
    DateTime? date,
  }) => db.transaction((txn) async {
    final ancien = await _charger(txn, code);
    await _defaire(txn, ancien, motif: 'Modification du retour');
    final r = await _appliquer(
      txn,
      code: code,
      type: ancien.type,
      documentCode: ancien.documentCode,
      produitCode: ancien.ligne?.produitCode ?? '',
      quantite: quantite,
      reglement: reglement,
      remiseEnStock: remiseEnStock,
      numeroSerie: numeroSerie,
      observation: observation,
      caisseCode: caisseCode,
      date: date ?? ancien.date,
      nouveau: false,
    );
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Modification',
      entite: 'retour',
      entiteCode: code,
      detail: 'quantité ${ancien.quantite} → $quantite, total ${r.total}',
    );
    return r;
  });

  /// Annule un retour (motif obligatoire) : stock rétabli (contrôlé), versements liés annulés.
  Future<Retour> annuler(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const RetourException(ErreurRetour.motifObligatoire);
    return db.transaction((txn) async {
      final r = await _charger(txn, code);
      await _defaire(txn, r, motif: motif.trim());
      await TiersRepository(txn).annulerRetour(code, par: utilisateurCode, motif: motif.trim());
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'retour',
        entiteCode: code,
        detail: motif.trim(),
      );
      return (await TiersRepository(txn).retour(code))!;
    });
  }

  Future<Retour> _charger(Transaction txn, String code) async {
    final r = await TiersRepository(txn).retour(code);
    if (r == null) throw const RetourException(ErreurRetour.retourInconnu);
    if (!r.actif) throw const RetourException(ErreurRetour.dejaAnnule);
    if (periodeCloturee != null && await periodeCloturee!(txn, r.date)) {
      throw const RetourException(ErreurRetour.periodeCloturee);
    }
    return r;
  }

  /// Défait les effets d'un retour : mouvements de stock inverses du net déjà passé, versements liés annulés.
  Future<void> _defaire(Transaction txn, Retour r, {required String motif}) async {
    final net = await txn.rawQuery(
      '''
      SELECT produit_code p, magasin_code m, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock
      WHERE reference_type = 'retour' AND reference_code = ? GROUP BY produit_code, magasin_code
      ''',
      [r.code],
    );
    final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
    try {
      for (final m in net) {
        final q = (m['q']! as num).toDouble();
        final n = (m['n']! as num).toDouble();
        if (q.abs() < 1e-9 && n.abs() < 1e-9) continue;
        if (q > 0 || n > 0) {
          await stock.sortirDansTransaction(
            txn,
            produitCode: m['p']! as String,
            magasinCode: m['m']! as String,
            quantite: q,
            nombre: n,
            type: TypesMouvement.retour,
            referenceType: 'retour',
            referenceCode: r.code,
            motif: motif,
          );
        } else {
          await stock.entrerDansTransaction(
            txn,
            produitCode: m['p']! as String,
            magasinCode: m['m']! as String,
            quantite: -q,
            nombre: -n,
            type: TypesMouvement.retour,
            referenceType: 'retour',
            referenceCode: r.code,
            motif: motif,
          );
        }
      }
    } on StockException catch (e) {
      throw RetourException(ErreurRetour.stockInsuffisant, e.detail);
    }
    final tiers = TiersRepository(txn);
    final lies = await txn.query(
      'versement',
      columns: ['code'],
      where: 'retour_code = ? AND etat = 1',
      whereArgs: [r.code],
    );
    for (final v in lies) {
      final vc = v['code']! as String;
      await tiers.annulerVersement(vc, par: utilisateurCode, motif: motif);
      await CaisseRepository(txn).supprimerMouvementsReference('versement', vc);
    }
    await tiers.lierVersementRetour(r.code, null);
  }

  Future<Retour> _appliquer(
    Transaction txn, {
    required String code,
    required String type,
    required String documentCode,
    required String produitCode,
    required double quantite,
    required String reglement,
    required bool remiseEnStock,
    required String? numeroSerie,
    required String? observation,
    required String? caisseCode,
    required DateTime date,
    required bool nouveau,
  }) async {
    if (quantite <= 0) throw const RetourException(ErreurRetour.quantiteInvalide);
    final client = type == TypesTiers.client;
    if (!(client ? ReglementsRetour.client : ReglementsRetour.fournisseur).contains(reglement)) {
      throw const RetourException(ErreurRetour.reglementInvalide);
    }
    final repo = TiersRepository(txn);
    final deja = (await repo.quantitesRetournees(documentCode, sauf: code))[produitCode] ?? 0;
    final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
    final obs = (observation?.trim().isEmpty ?? true) ? null : observation!.trim();
    final serie = (numeroSerie?.trim().isEmpty ?? true) ? null : numeroSerie!.trim();
    late final Retour retour;

    if (client) {
      final v = await VenteRepository(txn).vente(documentCode);
      if (v == null) throw const RetourException(ErreurRetour.documentInconnu);
      if (v.statut == StatutsVente.annulee) throw const RetourException(ErreurRetour.documentAnnule);
      if (periodeCloturee != null && await periodeCloturee!(txn, v.date)) {
        throw const RetourException(ErreurRetour.periodeCloturee);
      }
      if (reglement == ReglementsRetour.avoir && v.clientCode == CodeGenerator.systeme(CodeGenerator.client)) {
        throw const RetourException(ErreurRetour.reglementInvalide);
      }
      final vl = v.lignes.where((l) => l.produitCode == produitCode && l.packCode == null).firstOrNull;
      if (vl == null) throw RetourException(ErreurRetour.produitAbsent, produitCode);
      _verifierPlafond(vl.quantite, deja, quantite);
      final prixNet = vl.quantite == 0 ? 0.0 : CalculsPrix.arrondir(vl.total / vl.quantite);
      final total = CalculsPrix.arrondir(prixNet * quantite);
      final parNombre = vl.uniteVente == 'Nombre';
      final unites = parNombre ? 0.0 : quantite * (vl.colisCode == null ? 1 : await _quantiteColis(txn, vl.colisCode!));
      await stock.entrerDansTransaction(
        txn,
        produitCode: produitCode,
        magasinCode: v.magasinCode,
        quantite: unites,
        nombre: parNombre ? quantite : 0,
        type: TypesMouvement.retour,
        referenceType: 'retour',
        referenceCode: code,
        date: date,
      );
      if (!remiseEnStock) {
        // DS : « Non — défectueux, sortie « Casse » » : le produit revenu ressort aussitôt du stock.
        await stock.sortirDansTransaction(
          txn,
          produitCode: produitCode,
          magasinCode: v.magasinCode,
          quantite: unites,
          nombre: parNombre ? quantite : 0,
          type: TypesMouvement.sortie,
          referenceType: 'retour',
          referenceCode: code,
          motif: 'Casse',
          date: date,
        );
      }
      retour = Retour(
        code: code,
        date: date,
        documentCode: documentCode,
        clientCode: v.clientCode,
        magasinCode: v.magasinCode,
        utilisateurCode: utilisateurCode,
        total: total,
        rembourse: reglement == ReglementsRetour.avoir ? 0 : total,
        reglement: reglement,
        remiseEnStock: remiseEnStock,
        numeroSerie: serie,
        motif: obs,
        lignes: [
          RetourLigne(
            produitCode: produitCode,
            designation: vl.designation,
            quantite: quantite,
            nombre: parNombre ? quantite : 0,
            prixUnitaire: prixNet,
            total: total,
            prixAchat: vl.prixAchat,
          ),
        ],
      );
    } else {
      final a = await AchatService(txn.database, utilisateurCode: utilisateurCode).achat(documentCode, txn);
      if (a == null) throw const RetourException(ErreurRetour.documentInconnu);
      if (a.statut == StatutsAchat.annule) throw const RetourException(ErreurRetour.documentAnnule);
      if (periodeCloturee != null && await periodeCloturee!(txn, a.date)) {
        throw const RetourException(ErreurRetour.periodeCloturee);
      }
      final lignesProduit = a.lignes.where((l) => l.produitCode == produitCode).toList();
      if (lignesProduit.isEmpty) throw RetourException(ErreurRetour.produitAbsent, produitCode);
      final recue = lignesProduit.fold(0.0, (s, l) => s + l.quantite);
      final nombreRecu = lignesProduit.fold(0.0, (s, l) => s + l.nombre);
      _verifierPlafond(recue, deja, quantite);
      final montantRecu = lignesProduit.fold(0.0, (s, l) => s + l.total);
      final prix = recue == 0 ? 0.0 : CalculsPrix.arrondir(montantRecu / recue);
      final total = CalculsPrix.arrondir(prix * quantite);
      final nombre = recue == 0 ? 0.0 : nombreRecu / recue * quantite;
      try {
        await stock.sortirDansTransaction(
          txn,
          produitCode: produitCode,
          magasinCode: a.magasinCode,
          quantite: quantite,
          nombre: nombre,
          type: TypesMouvement.retour,
          referenceType: 'retour',
          referenceCode: code,
          date: date,
        );
      } on StockException catch (e) {
        throw RetourException(ErreurRetour.stockInsuffisant, e.detail);
      }
      retour = Retour(
        code: code,
        date: date,
        type: TypesTiers.fournisseur,
        documentCode: documentCode,
        fournisseurCode: a.fournisseurCode,
        magasinCode: a.magasinCode,
        utilisateurCode: utilisateurCode,
        total: total,
        rembourse: reglement == ReglementsRetour.avoir ? 0 : total,
        reglement: reglement,
        remiseEnStock: false,
        numeroSerie: serie,
        motif: obs,
        lignes: [
          RetourLigne(
            produitCode: produitCode,
            designation: lignesProduit.first.designation,
            quantite: quantite,
            nombre: nombre,
            prixUnitaire: prix,
            total: total,
            prixAchat: prix,
          ),
        ],
      );
    }

    if (nouveau) {
      await repo.insererRetour(retour);
    } else {
      await repo.remplacerRetour(retour);
    }
    final versement = await _regler(txn, retour, caisseCode: caisseCode);
    if (versement != null) await repo.lierVersementRetour(code, versement.code);
    return (await repo.retour(code))!;
  }

  void _verifierPlafond(double origine, double deja, double quantite) {
    final max = origine - deja;
    if (quantite > max + 1e-9) {
      throw RetourException(ErreurRetour.quantiteDepasse, CalculsPrix.arrondir(max).toString());
    }
  }

  /// Règlement : remboursement (versement verrouillé, journal de caisse) ou avoir imputé sur les documents
  /// ouverts du tiers, la pièce d'origine d'abord (non imputé = avance).
  Future<Versement?> _regler(Transaction txn, Retour r, {String? caisseCode}) async {
    if (r.total <= 0) return null;
    final repo = TiersRepository(txn);
    final client = r.estClient;
    final code = await repo.prochainCode('versement', CodeGenerator.versement);
    if (r.reglement == ReglementsRetour.avoir) {
      final docs = client
          ? await repo.documentsOuvertsClient(r.tiersCode)
          : await repo.documentsOuvertsFournisseur(r.tiersCode);
      docs.sort((a, b) => (a.code == r.documentCode ? 0 : 1).compareTo(b.code == r.documentCode ? 0 : 1));
      final v = Versement(
        code: code,
        date: r.date,
        tiersType: r.type,
        tiersCode: r.tiersCode,
        sens: client ? SensVersement.encaissement : SensVersement.decaissement,
        montant: r.total,
        mode: 'Avoir',
        utilisateurCode: utilisateurCode,
        commentaire: 'Avoir ${r.code}',
        retourCode: r.code,
        verrouille: true,
        imputations: VersementService.repartir(code, r.total, docs),
      );
      await repo.insererVersement(v);
      return v;
    }
    final v = Versement(
      code: code,
      date: r.date,
      tiersType: r.type,
      tiersCode: r.tiersCode,
      sens: client ? SensVersement.decaissement : SensVersement.encaissement,
      montant: r.total,
      mode: r.reglement,
      utilisateurCode: utilisateurCode,
      caisseCode: caisseCode ?? await CaisseRepository(txn).caisseParDefaut(utilisateurCode),
      commentaire: 'Remboursement ${r.code}',
      retourCode: r.code,
      verrouille: true,
      type: TypesVersement.remboursement,
    );
    await repo.insererVersement(v);
    await VersementService.journaliserVersement(txn, v, type: TypesMouvementCaisse.remboursement);
    return v;
  }

  Future<double> _quantiteColis(Transaction txn, String colisCode) async {
    final rows = await txn.query('colis', columns: ['quantite'], where: 'code = ?', whereArgs: [colisCode]);
    return rows.isEmpty ? 1 : (rows.first['quantite'] as num).toDouble();
  }
}
