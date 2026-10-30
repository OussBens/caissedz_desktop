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

  /// Caisses d'un utilisateur, dans l'ordre ; la première est sa caisse par défaut (l'Admin n'en a aucune : il a
  /// toutes les caisses).
  Future<List<String>> caissesUtilisateur(String utilisateurCode) async => (await db.query(
    'utilisateur_caisse',
    columns: ['caisse_code'],
    where: 'utilisateur_code = ?',
    whereArgs: [utilisateurCode],
    orderBy: 'ordre',
  )).map((r) => r['caisse_code']! as String).toList();

  Future<void> definirCaissesUtilisateur(String utilisateurCode, List<String> codes) async {
    await db.delete('utilisateur_caisse', where: 'utilisateur_code = ?', whereArgs: [utilisateurCode]);
    for (final (i, c) in codes.indexed) {
      await db.insert('utilisateur_caisse', {'utilisateur_code': utilisateurCode, 'caisse_code': c, 'ordre': i});
    }
  }

  /// Caisse choisie par l'utilisateur dans l'écran Caisse, ou `null`.
  Future<String?> caisseCourante(String utilisateurCode) async {
    final rows = await db.query(
      'caisse_courante',
      columns: ['caisse_code'],
      where: 'utilisateur_code = ?',
      whereArgs: [utilisateurCode],
    );
    return rows.isEmpty ? null : rows.first['caisse_code']! as String;
  }

  /// Fixe (ou efface, si [caisseCode] est `null`) la caisse courante de l'utilisateur.
  Future<void> definirCaisseCourante(String utilisateurCode, String? caisseCode) async {
    await db.delete('caisse_courante', where: 'utilisateur_code = ?', whereArgs: [utilisateurCode]);
    if (caisseCode != null) {
      await db.insert('caisse_courante', {'utilisateur_code': utilisateurCode, 'caisse_code': caisseCode});
    }
  }

  /// Caisse d'imputation par défaut : caisse de la session ouverte de l'utilisateur, sinon `CIS0000`.
  Future<String> caisseParDefaut(String utilisateurCode) async {
    // Session de l'utilisateur, sinon celle de sa caisse courante ouverte par un collègue (session partagée).
    final rows = await db.rawQuery(
      '''
      SELECT caisse_code FROM session_caisse
      WHERE statut = 'Ouverte'
        AND (utilisateur_code = ?1 OR caisse_code = (SELECT caisse_code FROM caisse_courante WHERE utilisateur_code = ?1))
      ORDER BY utilisateur_code = ?1 DESC, ouverte_le DESC
      LIMIT 1
      ''',
      [utilisateurCode],
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

  /// Contre-passation (journal en ajout seul) : pour chaque caisse et mode, le solde net des mouvements de la
  /// référence est annulé par un mouvement de sens opposé, daté de [date] (maintenant par défaut), qui garde la
  /// même référence. Les lignes d'origine restent : la Z déjà scellée et l'historique ne changent pas.
  /// Un transfert interne reste typé `Transfert` (exclu des totaux de la Z), le reste est typé `Annulation`.
  /// Retourne le nombre de contre-écritures.
  Future<int> contrePasserReference(
    String referenceType,
    String referenceCode, {
    required String utilisateurCode,
    String? commentaire,
    DateTime? date,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT caisse_code, mode, type = ?3 transfert,
        COALESCE(SUM(CASE WHEN sens = 'Entrée' THEN montant ELSE -montant END), 0) net
      FROM mouvement_caisse WHERE reference_type = ?1 AND reference_code = ?2
      GROUP BY caisse_code, mode, type = ?3
      ''',
      [referenceType, referenceCode, TypesMouvementCaisse.transfert],
    );
    var n = 0;
    final le = date ?? DateTime.now();
    for (final r in rows) {
      final net = CalculsPrix.arrondir((r['net'] as num).toDouble());
      if (net.abs() < 0.005) continue;
      await insererMouvement(
        MouvementCaisse(
          date: le,
          caisseCode: r['caisse_code']! as String,
          type: r['transfert'] == 1 ? TypesMouvementCaisse.transfert : TypesMouvementCaisse.annulation,
          sens: net > 0 ? SensMouvementCaisse.sortie : SensMouvementCaisse.entree,
          montant: net.abs(),
          mode: r['mode']! as String,
          referenceType: referenceType,
          referenceCode: referenceCode,
          utilisateurCode: utilisateurCode,
          commentaire: commentaire ?? 'Contre-passation $referenceCode',
        ),
      );
      n++;
    }
    return n;
  }

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

  /// Détail de [especesSession] par type de mouvement (montants signés : entrées +, sorties −).
  Future<Map<String, double>> especesSessionParType(String caisseCode, String sessionCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT type, COALESCE(SUM(CASE WHEN sens = 'Entrée' THEN montant ELSE -montant END), 0) s
      FROM mouvement_caisse
      WHERE caisse_code = ?1 AND mode = 'Espèces' AND id > COALESCE((
        SELECT MAX(id) FROM mouvement_caisse
        WHERE caisse_code = ?1 AND reference_type = 'session_caisse' AND type = ?2 AND reference_code <> ?3
      ), 0)
      GROUP BY type ORDER BY type
      ''',
      [caisseCode, TypesMouvementCaisse.retrait, sessionCode],
    );
    return {for (final r in rows) r['type']! as String: CalculsPrix.arrondir((r['s']! as num).toDouble())};
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

  /// Caisse « Coffre » active (la première), ou `null`.
  Future<String?> coffre() async {
    final r = await db.query('caisse', columns: ['code'], where: 'coffre = 1 AND actif = 1', orderBy: 'code', limit: 1);
    return r.isEmpty ? null : r.first['code']! as String;
  }

  /// Totaux entrées / sorties de la période, toutes caisses ou une seule. Les mouvements techniques (fond
  /// initial, retrait de fermeture, écart, coffre, transferts internes) sont exclus : la Z ne compte que
  /// les opérations commerciales et les entrées / sorties réelles.
  Future<({double entrees, double sorties, Map<String, double> parMode})> totauxPeriode(
    DateTime debut,
    DateTime fin, {
    String? caisseCode,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT sens, mode, COALESCE(SUM(montant), 0) m FROM mouvement_caisse
      WHERE date > ? AND date <= ? AND type NOT IN (${List.filled(TypesMouvementCaisse.techniques.length, '?').join(',')})
        ${caisseCode == null ? '' : 'AND caisse_code = ?'}
      GROUP BY sens, mode
      ''',
      [debut.toUtc().toIso8601String(), fin.toUtc().toIso8601String(), ...TypesMouvementCaisse.techniques, ?caisseCode],
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

  /// Vrai si [date] appartient à une période déjà clôturée (≤ fin d'une clôture). Avec [caisseCode], seules
  /// les clôtures de cette caisse (et les clôtures globales d'avant la v16) comptent : clôturer la caisse A ne
  /// bloque pas la caisse B.
  Future<bool> periodeCloturee(DateTime date, {String? caisseCode}) async {
    final rows = await db.query(
      'cloture',
      columns: ['code'],
      where: caisseCode == null ? 'fin >= ?' : 'fin >= ? AND (caisse_code = ? OR caisse_code IS NULL)',
      whereArgs: [date.toUtc().toIso8601String(), ?caisseCode],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
