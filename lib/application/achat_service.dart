import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/stock_repository.dart';
import '../data/tiers_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/achat.dart';
import '../domain/models/retour.dart';
import '../domain/models/stock.dart';
import 'session_caisse_service.dart';
import 'stock_service.dart';
import 'vente_service.dart';
import 'versement_service.dart';

enum ErreurAchat {
  lignesVides,
  quantiteInvalide,
  prixInvalide,
  produitInconnu,
  fournisseurInconnu,
  achatInconnu,
  dejaAnnule,
  periodeCloturee,
  stockInsuffisant,
  retourLie,
  motifObligatoire,
  repartitionIncomplete,
  bonInconnu,
  bonTraite,
  sessionRequise,
  nombreObligatoire,
}

class AchatException implements Exception {
  const AchatException(this.erreur, [this.detail]);
  final ErreurAchat erreur;
  final String? detail;
  @override
  String toString() => 'AchatException($erreur)';
}

/// Entrées / bons d'achat (§9.6) : en UNE transaction — entrée, lignes, mouvements d'entrée (répartis entre
/// magasins si demandé), mise à jour du prix d'achat (et de vente si saisi), paiement immédiat imputé,
/// liste de besoins livrée et bon de réception IA traité.
class AchatService {
  const AchatService(this.db, {required this.utilisateurCode, this.periodeCloturee});

  final Database db;
  final String utilisateurCode;
  final VerificateurCloture? periodeCloturee;

  Future<Achat> enregistrer({
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeAchatLigne> lignes,
    String? reference,
    double verse = 0,
    String modePaiement = 'Espèces',
    String? caisseCode,
    String source = SourcesAchat.smartScan,
    String? commentaire,
    DateTime? date,
    MajPrixAchat majPrix = MajPrixAchat.dernier,
    String? besoinCode,
    String? bonCode,
  }) async {
    _verifier(lignes, verse);
    return db.transaction((txn) async {
      if (!await SessionCaisseService.sessionOuverte(txn, utilisateurCode)) {
        throw const AchatException(ErreurAchat.sessionRequise);
      }
      if (await TiersRepository(txn).fournisseur(fournisseurCode) == null) {
        throw const AchatException(ErreurAchat.fournisseurInconnu);
      }
      if (bonCode != null) {
        final bon = await bonReception(bonCode, txn);
        if (bon == null) throw const AchatException(ErreurAchat.bonInconnu);
        if (bon.statut == StatutsBon.traite) throw const AchatException(ErreurAchat.bonTraite);
      }
      final code = await TiersRepository(txn).prochainCode('achat', CodeGenerator.achat);
      final d = date ?? DateTime.now();
      await _ecrire(
        txn,
        code: code,
        date: d,
        creePar: utilisateurCode,
        fournisseurCode: fournisseurCode,
        magasinCode: magasinCode,
        lignes: lignes,
        reference: reference,
        source: source,
        commentaire: commentaire,
        majPrix: majPrix,
        besoinCode: besoinCode,
        nouveau: true,
      );
      final total = await _total(txn, code);
      await _paiement(
        txn,
        code: code,
        fournisseurCode: fournisseurCode,
        montant: verse > total ? total : verse,
        mode: modePaiement,
        caisseCode: caisseCode,
        date: d,
      );
      if (besoinCode != null) await StockRepository(txn).changerStatutBesoin(besoinCode, StatutsBesoin.disponible);
      if (bonCode != null) {
        await txn.update(
          'bon_reception',
          {
            'statut': StatutsBon.traite,
            'achat_code': code,
            'traite_par_code': utilisateurCode,
            'fournisseur_code': fournisseurCode,
          },
          where: 'code = ?',
          whereArgs: [bonCode],
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Achat',
        entite: 'achat',
        entiteCode: code,
        detail: '$fournisseurCode $total',
      );
      return (await achat(code, txn))!;
    });
  }

  /// Modifie une entrée validée : lignes, en-tête, mouvements de stock (défaits puis réécrits) et paiement
  /// immédiat (ajusté, créé ou annulé). Refusé si l'entrée est annulée, clôturée ou liée à un retour, ou si le
  /// stock déjà vendu ne permet plus de retirer les quantités initiales.
  Future<Achat> modifier(
    String code, {
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeAchatLigne> lignes,
    String? reference,
    double verse = 0,
    String modePaiement = 'Espèces',
    String? caisseCode,
    String? commentaire,
    DateTime? date,
    MajPrixAchat majPrix = MajPrixAchat.dernier,
  }) async {
    _verifier(lignes, verse);
    return db.transaction((txn) async {
      final avant = await _modifiable(txn, code);
      if (await TiersRepository(txn).fournisseur(fournisseurCode) == null) {
        throw const AchatException(ErreurAchat.fournisseurInconnu);
      }
      await _defaire(txn, code, 'Modification');
      await txn.delete('achat_ligne', where: 'achat_code = ?', whereArgs: [code]);
      final d = date ?? avant.date;
      await _ecrire(
        txn,
        code: code,
        date: d,
        creePar: avant.utilisateurCode,
        fournisseurCode: fournisseurCode,
        magasinCode: magasinCode,
        lignes: lignes,
        reference: reference,
        source: avant.source,
        commentaire: commentaire,
        majPrix: majPrix,
        besoinCode: avant.besoinCode,
        nouveau: false,
      );
      final total = await _total(txn, code);
      await _paiement(
        txn,
        code: code,
        fournisseurCode: fournisseurCode,
        montant: verse > total ? total : verse,
        mode: modePaiement,
        caisseCode: caisseCode,
        date: d,
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'achat',
        entiteCode: code,
        detail: '${avant.total} → $total',
      );
      return (await achat(code, txn))!;
    });
  }

  /// Annule une entrée (motif obligatoire) : stock retiré, paiement immédiat annulé, statut Annulé.
  Future<Achat> annuler(String code, {required String motif}) async {
    await annulerEntrees([code], motif: motif);
    return (await achat(code))!;
  }

  /// Annulation en lot, en UNE transaction : tout ou rien.
  Future<void> annulerEntrees(List<String> codes, {required String motif}) async {
    if (motif.trim().isEmpty) throw const AchatException(ErreurAchat.motifObligatoire);
    await db.transaction((txn) async {
      for (final code in codes) {
        final a = await _modifiable(txn, code);
        await _defaire(txn, code, 'Annulation');
        final paiement = await _paiementImmediat(txn, code);
        if (paiement != null) {
          await TiersRepository(txn).annulerVersement(paiement, par: utilisateurCode, motif: motif.trim());
          await CaisseRepository(txn).contrePasserReference(
            'versement',
            paiement,
            utilisateurCode: utilisateurCode,
            commentaire: 'Annulation $code : ${motif.trim()}',
          );
        }
        await txn.update(
          'achat',
          {
            'statut': StatutsAchat.annule,
            'reste': 0,
            'annule_par': utilisateurCode,
            'motif_annulation': motif.trim(),
            'date_annulation': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'code = ?',
          whereArgs: [code],
        );
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Annulation',
          entite: 'achat',
          entiteCode: code,
          detail: '${a.total} · ${motif.trim()}',
        );
      }
    });
  }

  /// Raison bloquant l'annulation ou la modification d'une entrée (pour la liste du dialog d'action en lot) :
  /// déjà annulée, période clôturée, retour lié, ou produits déjà vendus / sortis (stock insuffisant).
  Future<ErreurAchat?> blocage(Achat a) async {
    if (!a.actif) return ErreurAchat.dejaAnnule;
    return db.transaction((txn) async {
      if (periodeCloturee != null && await periodeCloturee!(txn, a.date)) return ErreurAchat.periodeCloturee;
      if (await _retourLie(txn, a.code)) return ErreurAchat.retourLie;
      final stock = StockRepository(txn);
      for (final m in await _net(txn, a.code)) {
        final q = (m['q']! as num).toDouble();
        if (q > 0 && (await stock.niveau(m['p']! as String, m['m']! as String)).quantite + 1e-9 < q) {
          return ErreurAchat.stockInsuffisant;
        }
      }
      return null;
    });
  }

  Future<Achat?> achat(String code, [DatabaseExecutor? ex]) async {
    final e = ex ?? db;
    final rows = await e.query('achat', where: 'code = ?', whereArgs: [code]);
    if (rows.isEmpty) return null;
    final lignes = (await e.query(
      'achat_ligne',
      where: 'achat_code = ?',
      whereArgs: [code],
      orderBy: 'ordre',
    )).map(AchatLigne.depuisLigne).toList();
    final r = Map<String, Object?>.of(rows.first);
    final total = (r['total'] as num).toDouble();
    final imputations = await e.rawQuery(
      'SELECT COALESCE(SUM(montant),0) m, COUNT(*) n FROM versement_imputation '
      "WHERE document_type = 'achat' AND document_code = ?",
      [code],
    );
    final impute = (imputations.first['m']! as num).toDouble();
    final annule = r['statut'] == StatutsAchat.annule;
    r['verse'] = annule ? 0.0 : CalculsPrix.arrondir(impute);
    r['reste'] = annule ? 0.0 : CalculsPrix.arrondir(total - impute);
    r['nb_versements'] = imputations.first['n']! as int;
    return Achat.depuisLigne(r, lignes);
  }

  Future<List<Achat>> achats({String? fournisseurCode, int limite = 5000}) async {
    final rows = await db.query(
      'achat',
      columns: ['code'],
      where: fournisseurCode == null ? null : 'fournisseur_code = ?',
      whereArgs: fournisseurCode == null ? null : [fournisseurCode],
      orderBy: 'date DESC, code DESC',
      limit: limite,
    );
    return [for (final r in rows) (await achat(r['code']! as String))!];
  }

  // ———————————————————————— Bons de réception (Mode IA) ————————————————————————

  /// Dépose un bon dans la file (`Reçu` avec ses lignes détectées, ou `Erreur` si la lecture a échoué).
  Future<BonReception> deposerBon({
    required String fichier,
    String? chemin,
    String? fournisseurDetecte,
    String? fournisseurCode,
    String? numBon,
    List<LigneDetectee> lignes = const [],
    bool erreur = false,
    String? commentaire,
    String? code,
  }) async {
    return db.transaction((txn) async {
      final valeurs = {
        'fichier': fichier,
        'chemin_photo': chemin,
        'fournisseur_detecte': fournisseurDetecte,
        'fournisseur_code': fournisseurCode,
        'num_bon': numBon,
        'lignes_json': jsonEncode([for (final l in lignes) l.versJson()]),
        'nb_lignes': lignes.length,
        'statut': erreur ? StatutsBon.erreur : StatutsBon.recu,
        'commentaire': commentaire,
      };
      if (code != null) {
        final bon = await bonReception(code, txn);
        if (bon == null) throw const AchatException(ErreurAchat.bonInconnu);
        if (bon.statut == StatutsBon.traite) throw const AchatException(ErreurAchat.bonTraite);
        await txn.update('bon_reception', valeurs, where: 'code = ?', whereArgs: [code]);
        return (await bonReception(code, txn))!;
      }
      final nouveau = await TiersRepository(txn).prochainCode('bon_reception', CodeGenerator.bonReception);
      await txn.insert('bon_reception', {
        ...valeurs,
        'code': nouveau,
        'date_reception': DateTime.now().toUtc().toIso8601String(),
        'utilisateur_code': utilisateurCode,
      });
      return (await bonReception(nouveau, txn))!;
    });
  }

  Future<BonReception?> bonReception(String code, [DatabaseExecutor? ex]) async {
    final rows = await (ex ?? db).query('bon_reception', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : BonReception.depuisLigne(rows.first);
  }

  Future<List<BonReception>> bonsReception() async => [
    for (final r in await db.query('bon_reception', orderBy: 'date_reception DESC, code DESC'))
      BonReception.depuisLigne(r),
  ];

  /// Retire des bons de la file ; un bon traité (lié à une entrée) est conservé.
  Future<void> supprimerBons(List<String> codes) async {
    await db.transaction((txn) async {
      for (final code in codes) {
        final bon = await bonReception(code, txn);
        if (bon == null) throw const AchatException(ErreurAchat.bonInconnu);
        if (bon.statut == StatutsBon.traite) throw const AchatException(ErreurAchat.bonTraite);
        await txn.delete('bon_reception', where: 'code = ?', whereArgs: [code]);
      }
    });
  }

  // ———————————————————————— Interne ————————————————————————

  void _verifier(List<DemandeAchatLigne> lignes, double verse) {
    if (lignes.isEmpty) throw const AchatException(ErreurAchat.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const AchatException(ErreurAchat.quantiteInvalide);
    if (lignes.any((l) => l.prixAchat < 0) || verse < 0) throw const AchatException(ErreurAchat.prixInvalide);
    for (final l in lignes) {
      final r = l.repartition;
      if (r == null) continue;
      if (r.values.any((q) => q < 0) || (r.values.fold(0.0, (a, q) => a + q) - l.quantite).abs() > 1e-9) {
        throw AchatException(ErreurAchat.repartitionIncomplete, l.produitCode);
      }
    }
  }

  Future<Achat> _modifiable(Transaction txn, String code) async {
    final a = await achat(code, txn);
    if (a == null) throw const AchatException(ErreurAchat.achatInconnu);
    if (!a.actif) throw const AchatException(ErreurAchat.dejaAnnule);
    if (periodeCloturee != null && await periodeCloturee!(txn, a.date)) {
      throw const AchatException(ErreurAchat.periodeCloturee);
    }
    if (await _retourLie(txn, code)) throw const AchatException(ErreurAchat.retourLie);
    return a;
  }

  static Future<bool> _retourLie(DatabaseExecutor e, String code) async {
    final r = await e.rawQuery(
      "SELECT COUNT(*) n FROM retour WHERE document_code = ? AND type = 'Fournisseur' AND etat = 1",
      [code],
    );
    return (r.first['n']! as int) > 0;
  }

  /// Net des mouvements d'une entrée par produit et magasin (y compris ceux des anciennes annulations).
  static Future<List<Map<String, Object?>>> _net(DatabaseExecutor e, String code) => e.rawQuery(
    '''
    SELECT produit_code p, magasin_code m, SUM(quantite) q FROM mouvement_stock
    WHERE reference_type IN ('achat', 'annulation_achat') AND reference_code = ? GROUP BY produit_code, magasin_code
    ''',
    [code],
  );

  Future<void> _defaire(Transaction txn, String code, String motif) async {
    try {
      await StockService(
        txn.database,
        utilisateurCode: utilisateurCode,
      ).defaireDansTransaction(txn, 'achat', code, TypesMouvement.entree, motif: motif);
    } on StockException catch (e) {
      throw AchatException(ErreurAchat.stockInsuffisant, e.detail);
    }
  }

  Future<double> _total(Transaction txn, String code) async {
    final r = await txn.query('achat', columns: ['total'], where: 'code = ?', whereArgs: [code]);
    return (r.first['total']! as num).toDouble();
  }

  /// En-tête, lignes, mouvements d'entrée et prix des produits.
  Future<void> _ecrire(
    Transaction txn, {
    required String code,
    required DateTime date,
    required String creePar,
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeAchatLigne> lignes,
    required String? reference,
    required String source,
    required String? commentaire,
    required MajPrixAchat majPrix,
    required String? besoinCode,
    required bool nouveau,
  }) async {
    final catalogue = CatalogueRepository(txn);
    final stockRepo = StockRepository(txn);
    final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
    final lignesAchat = <AchatLigne>[];
    final nombreGlobal = await StockService.nombreGlobalActif(txn);
    for (final l in lignes) {
      final p = await catalogue.produitParCode(l.produitCode);
      if (p == null) throw AchatException(ErreurAchat.produitInconnu, l.produitCode);
      if (l.nombre <= 0 && p.exigeNombre(global: nombreGlobal)) {
        throw AchatException(ErreurAchat.nombreObligatoire, p.code);
      }
      final stockAvant = (await stockRepo.niveauTotal(p.code)).quantite;
      lignesAchat.add(
        AchatLigne(
          produitCode: p.code,
          designation: p.designation,
          quantite: l.quantite,
          nombre: l.nombre,
          prixAchat: l.prixAchat,
          total: CalculsPrix.arrondir(l.prixAchat * (l.quantite > 0 ? l.quantite : 1)),
        ),
      );
      final repartition = l.repartition ?? {magasinCode: l.quantite};
      for (final MapEntry(key: mag, value: q) in repartition.entries) {
        if (q <= 0 && !(repartition.length == 1 && l.nombre > 0)) continue;
        await stock.entrerDansTransaction(
          txn,
          produitCode: p.code,
          magasinCode: mag,
          quantite: q,
          nombre: l.repartition == null || l.quantite <= 0 ? l.nombre : l.nombre * q / l.quantite,
          type: TypesMouvement.entree,
          referenceType: 'achat',
          referenceCode: code,
          date: date,
        );
      }
      final achatPondere = stockAvant <= 0 || l.quantite <= 0
          ? l.prixAchat
          : CalculsPrix.arrondir((stockAvant * p.prixAchat + l.quantite * l.prixAchat) / (stockAvant + l.quantite));
      final nouvelAchat = switch (majPrix) {
        MajPrixAchat.garder => p.prixAchat,
        MajPrixAchat.moyenPondere => achatPondere,
        MajPrixAchat.dernier => l.prixAchat,
      };
      final vente = l.nouveauPrixVente ?? p.prixVente;
      if (nouvelAchat != p.prixAchat || vente != p.prixVente) {
        await catalogue.mettreAJourProduit(
          p.copyWith(
            prixAchat: nouvelAchat,
            prixVente: vente,
            margePct: CalculsPrix.margeDepuisPrix(nouvelAchat, vente),
          ),
        );
      }
    }
    final total = CalculsPrix.arrondir(lignesAchat.fold(0.0, (s, l) => s + l.total));
    final entete = {
      'date': date.toUtc().toIso8601String(),
      'fournisseur_code': fournisseurCode,
      'magasin_code': magasinCode,
      'reference': reference,
      'total': total,
      'reste': total,
      'commentaire': commentaire,
    };
    if (nouveau) {
      await txn.insert('achat', {
        ...entete,
        'code': code,
        'utilisateur_code': creePar,
        'verse': 0,
        'statut': StatutsAchat.valide,
        'source': source,
        'besoin_code': besoinCode,
      });
    } else {
      await txn.update('achat', entete, where: 'code = ?', whereArgs: [code]);
    }
    for (final (i, l) in lignesAchat.indexed) {
      await txn.insert('achat_ligne', {
        'achat_code': code,
        'ordre': i,
        'produit_code': l.produitCode,
        'designation': l.designation,
        'quantite': l.quantite,
        'nombre': l.nombre,
        'prix_achat': l.prixAchat,
        'total': l.total,
      });
    }
  }

  /// Versement de paiement immédiat d'une entrée (référence = code de l'entrée), s'il est actif.
  Future<String?> _paiementImmediat(Transaction txn, String code) async {
    final r = await txn.query(
      'versement',
      columns: ['code'],
      where: 'reference = ? AND tiers_type = ? AND etat = 1',
      whereArgs: [code, TypesTiers.fournisseur],
      limit: 1,
    );
    return r.isEmpty ? null : r.first['code']! as String;
  }

  /// Paiement immédiat : versement fournisseur imputé à l'entrée (le reste lu = total − imputations).
  /// En modification, le versement existant est ajusté, annulé (montant 0) ou créé.
  Future<void> _paiement(
    Transaction txn, {
    required String code,
    required String fournisseurCode,
    required double montant,
    required String mode,
    required String? caisseCode,
    required DateTime date,
  }) async {
    final paye = CalculsPrix.arrondir(montant);
    final tiers = TiersRepository(txn);
    final existant = await _paiementImmediat(txn, code);
    if (existant != null) {
      await CaisseRepository(txn).contrePasserReference(
        'versement',
        existant,
        utilisateurCode: utilisateurCode,
        commentaire: 'Modification $code',
      );
      if (paye <= 0) {
        await tiers.annulerVersement(existant, par: utilisateurCode, motif: 'Modification $code');
        return;
      }
    }
    if (paye <= 0) return;
    final codeV = existant ?? await tiers.prochainCode('versement', CodeGenerator.versement);
    final v = Versement(
      code: codeV,
      date: date,
      tiersType: TypesTiers.fournisseur,
      tiersCode: fournisseurCode,
      sens: SensVersement.decaissement,
      montant: paye,
      mode: mode,
      utilisateurCode: utilisateurCode,
      caisseCode: caisseCode ?? await CaisseRepository(txn).caisseParDefaut(utilisateurCode),
      reference: code,
      commentaire: 'Paiement $code',
      imputations: [Imputation(versementCode: codeV, documentType: 'achat', documentCode: code, montant: paye)],
    );
    if (existant != null) {
      await tiers.remplacerVersement(v);
    } else {
      await tiers.insererVersement(v);
    }
    await VersementService.journaliserVersement(txn, v);
  }
}
