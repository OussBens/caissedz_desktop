import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/journal_fiscal_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/models/journal_fiscal.dart';
import '../domain/scellement.dart';

enum ErreurCloture { caisseInconnue, rienACloturer }

class ClotureException implements Exception {
  const ClotureException(this.erreur, [this.detail]);
  final ErreurCloture erreur;
  final String? detail;
  @override
  String toString() => 'ClotureException($erreur${detail == null ? '' : ', $detail'})';
}

/// Clôtures Z (§9.13, §12.3) : rapport figé d'UNE caisse depuis sa clôture précédente (ventes validées et
/// annulées, tickets, répartition des paiements), scellé SHA-256 et chaîné par caisse. Une période clôturée
/// interdit toute annulation dans cette caisse (ventes, retours datés de la période, achats) ; un retour reste
/// possible après la Z, daté du jour. Aucune modification ni suppression (déclencheurs SQL).
///
/// Les clôtures globales antérieures à la v16 (`caisse_code` nul) forment leur propre chaîne ; la première
/// clôture d'une caisse part de la fin de la dernière clôture globale.
class ClotureService {
  const ClotureService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  CaisseRepository get _repo => CaisseRepository(db);

  /// Vérificateur à brancher sur `VenteService`, `RetourService`, `AchatService` : une date est « clôturée »
  /// si une clôture de [caisseCode] (ou une clôture globale d'avant la v16) la couvre ; sans caisse (entrées),
  /// dès qu'une clôture de n'importe quelle caisse la couvre.
  static Future<bool> periodeCloturee(DatabaseExecutor ex, DateTime date, {String? caisseCode}) =>
      CaisseRepository(ex).periodeCloturee(date, caisseCode: caisseCode);

  Future<List<Cloture>> clotures({String? caisseCode}) => _repo.clotures(caisseCode: caisseCode);

  Future<Cloture?> derniere(String caisseCode) => _repo.derniereCloture(caisseCode: caisseCode);

  /// Récapitulatif de la période à clôturer pour [caisseCode] (sans écriture).
  Future<Cloture> apercu({required String caisseCode, DateTime? fin}) =>
      db.transaction((txn) => _calculer(txn, caisseCode, fin ?? DateTime.now()));

  /// Clôture Z d'une caisse : calcule, scelle, chaîne et enregistre dans UNE transaction.
  Future<Cloture> cloturer({required String caisseCode, DateTime? fin}) async {
    final f = fin ?? DateTime.now();
    return db.transaction((txn) async {
      final c = await _calculer(txn, caisseCode, f);
      final mouvements = await CaisseRepository(txn)
          .mouvements(caisseCode: caisseCode, debut: c.debut, fin: c.fin, limite: 1);
      if (c.nbVentes == 0 && c.nbAnnulations == 0 && mouvements.isEmpty) {
        throw const ClotureException(ErreurCloture.rienACloturer);
      }
      await CaisseRepository(txn).insererCloture(c);
      await JournalFiscalRepository(txn).ajouter(
        type: TypesEvenementFiscal.cloture,
        referenceCode: c.code,
        caisseCode: caisseCode,
        utilisateurCode: utilisateurCode,
        montant: c.totalVentes,
        details: {'hash': c.hash, 'debut': c.debut, 'fin': c.fin, 'tickets': c.nbVentes},
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Clôture Z',
        entite: 'cloture',
        entiteCode: c.code,
        detail: '$caisseCode · ${c.nbVentes} tickets · ventes ${c.totalVentes}',
      );
      return c;
    });
  }

  Future<Cloture> _calculer(DatabaseExecutor txn, String caisseCode, DateTime fin) async {
    final repo = CaisseRepository(txn);
    if (await repo.caisse(caisseCode) == null) throw const ClotureException(ErreurCloture.caisseInconnue);
    final precedente = await repo.derniereCloture(caisseCode: caisseCode);
    final debut = precedente?.fin ?? (await repo.derniereCloture())?.fin ?? DateTime.utc(1970);
    final dIso = debut.toUtc().toIso8601String();
    final fIso = fin.toUtc().toIso8601String();
    final v = (await txn.rawQuery(
      '''
      SELECT COUNT(CASE WHEN statut = 'Validée' THEN 1 END) nb,
             COUNT(CASE WHEN statut = 'Annulée' THEN 1 END) nba,
             COALESCE(SUM(CASE WHEN statut = 'Validée' THEN total_net END), 0) net,
             COALESCE(SUM(CASE WHEN statut = 'Validée' THEN total_remise END), 0) remise,
             COALESCE(SUM(CASE WHEN statut = 'Annulée' THEN total_net END), 0) annule,
             COALESCE(SUM(CASE WHEN statut = 'Validée' AND verse > total_net THEN verse - total_net END), 0) rendu,
             (SELECT code FROM vente WHERE caisse_code = ?1 AND date > ?2 AND date <= ?3
              ORDER BY ${CodeGenerator.ordreCroissant} LIMIT 1) premiere,
             (SELECT code FROM vente WHERE caisse_code = ?1 AND date > ?2 AND date <= ?3
              ORDER BY ${CodeGenerator.ordreDecroissant} LIMIT 1) derniere
      FROM vente WHERE caisse_code = ?1 AND date > ?2 AND date <= ?3
      ''',
      [caisseCode, dIso, fIso],
    )).first;
    final retours = (await txn.rawQuery(
      '''
      SELECT COALESCE(SUM(r.total), 0) t FROM retour r JOIN vente v ON v.code = r.document_code
      WHERE r.type = 'Client' AND r.etat = 1 AND v.caisse_code = ? AND r.date > ? AND r.date <= ?
      ''',
      [caisseCode, dIso, fIso],
    )).first;
    // Répartition des paiements des tickets validés ; la monnaie rendue est déduite des espèces.
    final paiements = await txn.rawQuery(
      '''
      SELECT p.mode mode, COALESCE(SUM(p.montant), 0) m FROM vente_paiement p JOIN vente v ON v.code = p.vente_code
      WHERE v.caisse_code = ? AND v.statut = 'Validée' AND v.date > ? AND v.date <= ? GROUP BY p.mode
      ''',
      [caisseCode, dIso, fIso],
    );
    final parMode = <String, double>{for (final r in paiements) r['mode'] as String: (r['m'] as num).toDouble()};
    final rendu = (v['rendu'] as num).toDouble();
    if (rendu > 0) parMode['Espèces'] = (parMode['Espèces'] ?? 0) - rendu;
    parMode.removeWhere((_, m) => m.abs() < 0.005);
    final totaux = await repo.totauxPeriode(debut, fin, caisseCode: caisseCode);
    final derniere = v['derniere'] as String?;
    final hashDerniere = derniere == null
        ? (precedente?.hashDerniereVente ?? Scellement.genese)
        : (await txn.query('vente', columns: ['hash'], where: 'code = ?', whereArgs: [derniere])).first['hash']
              as String;
    final code = await repo.prochainCode('cloture', CodeGenerator.cloture);
    final hashPrecedent = precedente?.hash ?? Scellement.genese;
    final c = Cloture(
      code: code,
      date: DateTime.now(),
      debut: debut,
      fin: fin,
      utilisateurCode: utilisateurCode,
      nbVentes: v['nb'] as int,
      nbAnnulations: v['nba'] as int,
      totalVentes: CalculsPrix.arrondir((v['net'] as num).toDouble()),
      totalRemises: CalculsPrix.arrondir((v['remise'] as num).toDouble()),
      totalRetours: CalculsPrix.arrondir((retours['t'] as num).toDouble()),
      totalEncaissements: CalculsPrix.arrondir(totaux.entrees),
      totalDecaissements: CalculsPrix.arrondir(totaux.sorties),
      encaissementsParMode: {for (final e in parMode.entries) e.key: CalculsPrix.arrondir(e.value)},
      soldesCaisses: {caisseCode: CalculsPrix.arrondir((await repo.solde(caisseCode, fin: fin)).total)},
      premiereVente: v['premiere'] as String?,
      derniereVente: derniere,
      hashDerniereVente: hashDerniere,
      hashPrecedent: hashPrecedent,
      hash: '',
      caisseCode: caisseCode,
      totalAnnule: CalculsPrix.arrondir((v['annule'] as num).toDouble()),
    );
    return c.copyWith(hash: Scellement.hacher(c.versCanonique(), hashPrecedent));
  }

  /// Vérifie les chaînes des clôtures (une par caisse) ; `null` = intactes, sinon code de la première altérée.
  Future<String?> verifierChaine() async => Cloture.verifierChaines(await _repo.clotures(croissant: true));
}
