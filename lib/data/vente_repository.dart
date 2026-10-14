import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/panier.dart';
import '../domain/models/vente.dart';

/// Accès SQL aux sessions de caisse et aux ventes.
class VenteRepository {
  const VenteRepository(this.db);

  final DatabaseExecutor db;

  Future<String> prochainCode(String table, String prefixe) async {
    final rows = await db.query(
      table,
      columns: ['code'],
      where: 'code LIKE ?',
      whereArgs: ['$prefixe%'],
      orderBy: 'code DESC',
      limit: 1,
    );
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  // ---- Sessions ----
  Future<SessionCaisse?> sessionOuverte({String? utilisateurCode, String? caisseCode}) async {
    final where = ['statut = ?'];
    final args = <Object>['Ouverte'];
    if (utilisateurCode != null) {
      where.add('utilisateur_code = ?');
      args.add(utilisateurCode);
    }
    if (caisseCode != null) {
      where.add('caisse_code = ?');
      args.add(caisseCode);
    }
    final rows = await db.query(
      'session_caisse',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'ouverte_le DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : SessionCaisse.depuisLigne(rows.first);
  }

  Future<SessionCaisse?> session(String code) async {
    final rows = await db.query('session_caisse', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : SessionCaisse.depuisLigne(rows.first);
  }

  Future<List<SessionCaisse>> sessions({int limite = 200}) async => (await db.query(
    'session_caisse',
    orderBy: 'ouverte_le DESC',
    limit: limite,
  )).map(SessionCaisse.depuisLigne).toList();

  Future<void> insererSession(SessionCaisse s) => db.insert('session_caisse', {
    'code': s.code,
    'caisse_code': s.caisseCode,
    'utilisateur_code': s.utilisateurCode,
    'ouverte_le': s.ouverteLe.toUtc().toIso8601String(),
    'fond_initial': s.fondInitial,
    'statut': s.statut,
  });

  Future<void> fermerSession(
    String code, {
    required DateTime fermeeLe,
    required double montant,
    required double ecart,
  }) => db.update(
    'session_caisse',
    {'fermee_le': fermeeLe.toUtc().toIso8601String(), 'montant_fermeture': montant, 'ecart': ecart, 'statut': 'Fermée'},
    where: 'code = ?',
    whereArgs: [code],
  );

  /// Total encaissé (ventes validées) par mode sur une session.
  Future<Map<String, double>> encaissementsSession(String sessionCode) async {
    final rows = await db.rawQuery(
      'SELECT p.mode mode, SUM(p.montant) m FROM vente_paiement p JOIN vente v ON v.code = p.vente_code WHERE v.session_code = ? AND v.statut = ? GROUP BY p.mode',
      [sessionCode, 'Validée'],
    );
    return {for (final r in rows) r['mode'] as String: (r['m'] as num).toDouble()};
  }

  /// Monnaie rendue (versé − net quand positif) sur les ventes validées d'une session.
  Future<double> monnaieRendueSession(String sessionCode) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(CASE WHEN verse > total_net THEN verse - total_net ELSE 0 END), 0) m FROM vente WHERE session_code = ? AND statut = ?',
      [sessionCode, 'Validée'],
    );
    return (rows.first['m'] as num).toDouble();
  }

  // ---- Ventes ----
  Future<String?> dernierHash() async {
    final rows = await db.query('vente', columns: ['hash'], orderBy: 'code DESC', limit: 1);
    return rows.isEmpty ? null : rows.first['hash'] as String;
  }

  Future<void> insererVente(Vente v) async {
    await db.insert('vente', v.versLigne());
    for (final l in v.lignes) {
      await db.insert('vente_ligne', l.versLigne(v.code));
    }
    for (final (i, p) in v.paiements.indexed) {
      await db.insert('vente_paiement', {
        'vente_code': v.code,
        'ordre': i,
        'mode': p.mode,
        'montant': p.montant,
        'reference': p.reference,
      });
    }
  }

  Future<Vente?> vente(String code) async {
    final rows = await db.query('vente', where: 'code = ?', whereArgs: [code]);
    if (rows.isEmpty) return null;
    return _charger(rows.first);
  }

  Future<Vente> _charger(Map<String, Object?> r) async {
    final code = r['code'] as String;
    final lignes = (await db.query(
      'vente_ligne',
      where: 'vente_code = ?',
      whereArgs: [code],
      orderBy: 'ordre',
    )).map(VenteLigne.depuisLigne).toList();
    final paiements = (await db.query('vente_paiement', where: 'vente_code = ?', whereArgs: [code], orderBy: 'ordre'))
        .map(
          (p) => Paiement(
            mode: p['mode'] as String,
            montant: (p['montant'] as num).toDouble(),
            reference: p['reference'] as String?,
          ),
        )
        .toList();
    return Vente.depuisLigne(r, lignes: lignes, paiements: paiements);
  }

  Future<List<Vente>> ventes({
    DateTime? depuis,
    DateTime? jusqua,
    String? clientCode,
    String? statut,
    int limite = 500,
    bool avecLignes = false,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (depuis != null) {
      where.add('date >= ?');
      args.add(depuis.toUtc().toIso8601String());
    }
    if (jusqua != null) {
      where.add('date <= ?');
      args.add(jusqua.toUtc().toIso8601String());
    }
    if (clientCode != null) {
      where.add('client_code = ?');
      args.add(clientCode);
    }
    if (statut != null) {
      where.add('statut = ?');
      args.add(statut);
    }
    final rows = await db.query(
      'vente',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
      limit: limite,
    );
    if (!avecLignes) return rows.map((r) => Vente.depuisLigne(r)).toList();
    return [for (final r in rows) await _charger(r)];
  }

  /// Toutes les ventes dans l'ordre de la chaîne (par code), avec lignes et paiements.
  Future<List<Vente>> chaine() async {
    final rows = await db.query('vente', orderBy: 'code');
    return [for (final r in rows) await _charger(r)];
  }

  Future<void> annulerVente(String code, {required String par, required DateTime le}) => db.update(
    'vente',
    {'statut': 'Annulée', 'annulee_le': le.toUtc().toIso8601String(), 'annulee_par': par},
    where: 'code = ?',
    whereArgs: [code],
  );

  // ---- Clients (points) ----
  Future<int> pointsClient(String code) async {
    final rows = await db.query('client', columns: ['points'], where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? 0 : (rows.first['points'] as int? ?? 0);
  }

  Future<void> ajusterPoints(String code, int delta) =>
      db.rawUpdate('UPDATE client SET points = points + ? WHERE code = ?', [delta, code]);
}
