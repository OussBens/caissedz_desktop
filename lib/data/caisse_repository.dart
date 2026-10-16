import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';

/// Accès SQL aux caisses, au journal des mouvements, aux transferts TRF et aux clôtures Z.
class CaisseRepository {
  const CaisseRepository(this.db);
  final DatabaseExecutor db;

  Future<String> prochainCode(String table, String prefixe) async {
    final rows = await db.query(
      table,
      columns: ['code'],
      where: 'code LIKE ?',
      whereArgs: ['$prefixe%'],
      orderBy: CodeGenerator.ordreDecroissant,
      limit: 1,
    );
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  // ---- Caisses ----
  Future<List<Caisse>> caisses({bool actives = false}) async {
    final rows = await db.query('caisse', where: actives ? 'actif = 1' : null, orderBy: 'code');
    return rows.map(Caisse.depuisLigne).toList();
  }

  Future<Caisse?> caisse(String code) async {
    final rows = await db.query('caisse', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Caisse.depuisLigne(rows.first);
  }

  Future<void> insererCaisse(Caisse c) => db.insert('caisse', c.versLigne());

  Future<void> mettreAJourCaisse(Caisse c) =>
      db.update('caisse', c.versLigne()..remove('code'), where: 'code = ?', whereArgs: [c.code]);

  /// Caisse d'imputation par défaut : caisse de la session ouverte de l'utilisateur, sinon `CIS0000`.
  Future<String> caisseParDefaut(String utilisateurCode) async {
    final rows = await db.query(
      'session_caisse',
      columns: ['caisse_code'],
      where: 'statut = ? AND utilisateur_code = ?',
      whereArgs: ['Ouverte', utilisateurCode],
      limit: 1,
    );
    return rows.isEmpty ? CodeGenerator.systeme(CodeGenerator.caisseSysteme) : rows.first['caisse_code'] as String;
  }

  // ---- Mouvements ----
  Future<int> insererMouvement(MouvementCaisse m) => db.insert('mouvement_caisse', m.versLigne());

  Future<List<MouvementCaisse>> mouvements({
    String? caisseCode,
    DateTime? debut,
    DateTime? fin,
    String? referenceType,
    String? referenceCode,
    int limite = 1000,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (caisseCode != null) {
      where.add('caisse_code = ?');
      args.add(caisseCode);
    }
    if (debut != null) {
      where.add('date > ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('date <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    if (referenceType != null) {
      where.add('reference_type = ?');
      args.add(referenceType);
    }
    if (referenceCode != null) {
      where.add('reference_code = ?');
      args.add(referenceCode);
    }
    final rows = await db.query(
      'mouvement_caisse',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
      limit: limite,
    );
    return rows.map(MouvementCaisse.depuisLigne).toList();
  }

  Future<int> supprimerMouvementsReference(String referenceType, String referenceCode) => db.delete(
    'mouvement_caisse',
    where: 'reference_type = ? AND reference_code = ?',
    whereArgs: [referenceType, referenceCode],
  );

  /// Espèces attendues dans le tiroir pour la session [sessionCode] : solde Espèces du grand-livre de la caisse
  /// depuis la fermeture précédente (fond initial, ventes nettes de la monnaie, versements, paiements d'entrées,
  /// remboursements, dépenses, transferts…). Une seule source : le journal de caisse.
  Future<double> especesSession(String caisseCode, String sessionCode) async {
    final r = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(CASE WHEN sens = 'Entrée' THEN montant ELSE -montant END), 0) s
      FROM mouvement_caisse
      WHERE caisse_code = ?1 AND mode = 'Espèces' AND id > COALESCE((
        SELECT MAX(id) FROM mouvement_caisse
        WHERE caisse_code = ?1 AND reference_type = 'session_caisse' AND type = ?2 AND reference_code <> ?3
      ), 0)
      ''',
      [caisseCode, TypesMouvementCaisse.retrait, sessionCode],
    );
    return CalculsPrix.arrondir((r.first['s'] as num).toDouble());
  }

  /// Solde d'une caisse par mode (Σ entrées − Σ sorties) jusqu'à [fin] inclus.
  Future<SoldeCaisse> solde(String caisseCode, {DateTime? fin}) async {
    final rows = await db.rawQuery(
      '''
      SELECT mode, COALESCE(SUM(CASE WHEN sens = 'Entrée' THEN montant ELSE -montant END), 0) s
      FROM mouvement_caisse WHERE caisse_code = ? ${fin == null ? '' : 'AND date <= ?'} GROUP BY mode
      ''',
      [caisseCode, if (fin != null) fin.toUtc().toIso8601String()],
    );
    return SoldeCaisse(
      caisseCode: caisseCode,
      parMode: {for (final r in rows) r['mode'] as String: (r['s'] as num).toDouble()},
    );
  }

  /// Totaux entrées / sorties de la période (transferts internes exclus), toutes caisses ou une seule.
  Future<({double entrees, double sorties, Map<String, double> parMode})> totauxPeriode(
    DateTime debut,
    DateTime fin, {
    String? caisseCode,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT sens, mode, COALESCE(SUM(montant), 0) m FROM mouvement_caisse
      WHERE date > ? AND date <= ? AND type <> 'Transfert' ${caisseCode == null ? '' : 'AND caisse_code = ?'}
      GROUP BY sens, mode
      ''',
      [debut.toUtc().toIso8601String(), fin.toUtc().toIso8601String(), ?caisseCode],
    );
    var entrees = 0.0;
    var sorties = 0.0;
    final parMode = <String, double>{};
    for (final r in rows) {
      final m = (r['m'] as num).toDouble();
      if (r['sens'] == SensMouvementCaisse.entree) {
        entrees += m;
        parMode[r['mode'] as String] = (parMode[r['mode'] as String] ?? 0) + m;
      } else {
        sorties += m;
      }
    }
    return (entrees: entrees, sorties: sorties, parMode: parMode);
  }

  // ---- Transferts TRF ----
  Future<void> insererTransfert(TransfertCaisse t) => db.insert('transfert_caisse', t.versLigne());

  Future<List<TransfertCaisse>> transferts({int limite = 500}) async {
    final rows = await db.query('transfert_caisse', orderBy: 'date DESC, code DESC', limit: limite);
    return rows.map(TransfertCaisse.depuisLigne).toList();
  }

  Future<TransfertCaisse?> transfert(String code) async {
    final rows = await db.query('transfert_caisse', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : TransfertCaisse.depuisLigne(rows.first);
  }

  /// Annulation douce d'un transfert (la ligne reste, marquée inactive avec son motif).
  Future<void> annulerTransfert(String code, {required String par, required String motif, required DateTime le}) =>
      db.update(
        'transfert_caisse',
        {'actif': 0, 'annule_par': par, 'motif_annulation': motif, 'date_annulation': le.toUtc().toIso8601String()},
        where: 'code = ?',
        whereArgs: [code],
      );

  // ---- Clôtures Z ----
  Future<void> insererCloture(Cloture c) => db.insert('cloture', c.versLigne());

  /// Clôtures (plus récentes d'abord, ou ordre de chaînage si [croissant]), d'une caisse si [caisseCode].
  Future<List<Cloture>> clotures({DateTime? debut, DateTime? fin, bool croissant = false, String? caisseCode}) async {
    final where = <String>[];
    final args = <Object>[];
    if (debut != null) {
      where.add('fin > ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('fin <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    if (caisseCode != null) {
      where.add('caisse_code = ?');
      args.add(caisseCode);
    }
    final rows = await db.query(
      'cloture',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: croissant ? 'fin, code' : 'fin DESC, code DESC',
    );
    return rows.map(Cloture.depuisLigne).toList();
  }

  /// Dernière clôture d'une caisse ; sans [caisseCode], dernière clôture globale (antérieure à la v16).
  Future<Cloture?> derniereCloture({String? caisseCode}) async {
    final rows = await db.query(
      'cloture',
      where: caisseCode == null ? 'caisse_code IS NULL' : 'caisse_code = ?',
      whereArgs: caisseCode == null ? null : [caisseCode],
      orderBy: 'fin DESC, code DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : Cloture.depuisLigne(rows.first);
  }

  /// Vrai si [date] appartient à une période déjà clôturée (≤ fin de la dernière clôture).
  Future<bool> periodeCloturee(DateTime date) async {
    final rows = await db.query(
      'cloture',
      columns: ['code'],
      where: 'fin >= ?',
      whereArgs: [date.toUtc().toIso8601String()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
