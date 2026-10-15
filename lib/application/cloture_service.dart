import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/scellement.dart';

enum ErreurCloture { sessionOuverte, rienACloturer }

class ClotureException implements Exception {
  const ClotureException(this.erreur, [this.detail]);
  final ErreurCloture erreur;
  final String? detail;
  @override
  String toString() => 'ClotureException($erreur${detail == null ? '' : ', $detail'})';
}

/// Clôtures Z : récapitulatif immuable de la période écoulée depuis la clôture précédente,
/// scellé SHA-256 et chaîné (§12). Une période clôturée interdit toute annulation (ventes, retours, achats).
///
/// ⚠️ PROVISOIRE : clôture globale (toutes caisses), exige qu'aucune session ne soit ouverte.
class ClotureService {
  const ClotureService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  CaisseRepository get _repo => CaisseRepository(db);

  /// Vérificateur à brancher sur `VenteService`, `RetourService`, `AchatService`.
  static Future<bool> periodeCloturee(DatabaseExecutor ex, DateTime date) => CaisseRepository(ex).periodeCloturee(date);

  Future<List<Cloture>> clotures() => _repo.clotures();

  Future<Cloture?> derniere() => _repo.derniereCloture();

  /// Récapitulatif de la période à clôturer (sans écriture).
  Future<Cloture> apercu({DateTime? fin}) => db.transaction((txn) => _calculer(txn, fin ?? DateTime.now()));

  /// Clôture Z : calcule, scelle, chaîne et enregistre dans UNE transaction.
  Future<Cloture> cloturer({DateTime? fin}) async {
    final f = fin ?? DateTime.now();
    return db.transaction((txn) async {
      final ouvertes = await txn.query(
        'session_caisse',
        columns: ['code'],
        where: 'statut = ?',
        whereArgs: ['Ouverte'],
      );
      if (ouvertes.isNotEmpty) throw const ClotureException(ErreurCloture.sessionOuverte);
      final c = await _calculer(txn, f);
      final mouvements = await CaisseRepository(txn).mouvements(debut: c.debut, fin: c.fin, limite: 1);
      if (c.nbVentes == 0 && c.nbAnnulations == 0 && mouvements.isEmpty) {
        throw const ClotureException(ErreurCloture.rienACloturer);
      }
      await CaisseRepository(txn).insererCloture(c);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Clôture Z',
        entite: 'cloture',
        entiteCode: c.code,
        detail: 'ventes ${c.totalVentes}',
      );
      return c;
    });
  }

  Future<Cloture> _calculer(DatabaseExecutor txn, DateTime fin) async {
    final repo = CaisseRepository(txn);
    final precedente = await repo.derniereCloture();
    final debut = precedente?.fin ?? DateTime.utc(1970);
    final dIso = debut.toUtc().toIso8601String();
    final fIso = fin.toUtc().toIso8601String();
    final v = (await txn.rawQuery(
      '''
      SELECT COUNT(CASE WHEN statut = 'Validée' THEN 1 END) nb,
             COUNT(CASE WHEN statut = 'Annulée' THEN 1 END) nba,
             COALESCE(SUM(CASE WHEN statut = 'Validée' THEN total_net END), 0) net,
             COALESCE(SUM(CASE WHEN statut = 'Validée' THEN total_remise END), 0) remise,
             MIN(code) premiere, MAX(code) derniere
      FROM vente WHERE date > ? AND date <= ?
      ''',
      [dIso, fIso],
    )).first;
    final retours = (await txn.rawQuery(
      "SELECT COALESCE(SUM(total), 0) t FROM retour WHERE type = 'Client' AND etat = 1 AND date > ? AND date <= ?",
      [dIso, fIso],
    )).first;
    final totaux = await repo.totauxPeriode(debut, fin);
    final soldes = <String, double>{
      for (final c in await repo.caisses()) c.code: CalculsPrix.arrondir((await repo.solde(c.code, fin: fin)).total),
    };
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
      encaissementsParMode: {for (final e in totaux.parMode.entries) e.key: CalculsPrix.arrondir(e.value)},
      soldesCaisses: soldes,
      premiereVente: v['premiere'] as String?,
      derniereVente: derniere,
      hashDerniereVente: hashDerniere,
      hashPrecedent: hashPrecedent,
      hash: '',
    );
    return c.copyWith(hash: Scellement.hacher(c.versCanonique(), hashPrecedent));
  }

  /// Vérifie la chaîne des clôtures ; `null` = intacte, sinon code de la première clôture altérée.
  Future<String?> verifierChaine() async {
    final cs = await _repo.clotures(croissant: true);
    final i = Scellement.verifier([
      for (final c in cs) (doc: c.versCanonique(), hashPrecedent: c.hashPrecedent, hash: c.hash),
    ]);
    return i == null ? null : cs[i].code;
  }
}
