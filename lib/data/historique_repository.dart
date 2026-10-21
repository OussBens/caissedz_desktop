import 'dart:io';

import 'package:sqflite_common/sqlite_api.dart';

import '../domain/historique.dart';

/// Journal d'audit (table `historique`).
class HistoriqueRepository {
  const HistoriqueRepository(this.db);

  final DatabaseExecutor db;

  /// Poste de travail inscrit sur chaque ligne (nom de la machine).
  static String poste = _nomMachine();

  static String _nomMachine() {
    try {
      return Platform.localHostname;
    } on Object {
      return '';
    }
  }

  Future<void> journaliser({
    required String utilisateurCode,
    required String action,
    required String entite,
    String? entiteCode,
    String? detail,
  }) => db.insert('historique', {
    'utilisateur_code': utilisateurCode,
    'action': action,
    'entite': entite,
    'entite_code': entiteCode,
    'detail': detail,
    'poste': poste.isEmpty ? null : poste,
    'date': DateTime.now().toUtc().toIso8601String(),
  });

  /// Lignes d'une période `[depuis, jusqua[` (heure locale), les plus récentes d'abord.
  Future<List<EntreeHistorique>> lire({
    DateTime? depuis,
    DateTime? jusqua,
    String? entite,
    String? utilisateurCode,
    int limite = 5000,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (depuis != null) {
      where.add('date >= ?');
      args.add(depuis.toUtc().toIso8601String());
    }
    if (jusqua != null) {
      where.add('date < ?');
      args.add(jusqua.toUtc().toIso8601String());
    }
    if (entite != null) {
      where.add('entite = ?');
      args.add(entite);
    }
    if (utilisateurCode != null) {
      where.add('utilisateur_code = ?');
      args.add(utilisateurCode);
    }
    final rows = await db.query(
      'historique',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'id DESC',
      limit: limite,
    );
    return rows.map(EntreeHistorique.depuisLigne).toList();
  }

  /// Dernier identifiant du journal (0 s'il est vide).
  Future<int> dernierId() async => ((await db.rawQuery('SELECT MAX(id) m FROM historique')).first['m'] as int?) ?? 0;

  /// Lignes postérieures à [id] pour les points rouges : entité, action, code, type du tiers (retour, versement)
  /// et client (vente, livraison).
  Future<List<({int id, String entite, String action, String? code, String? tiersType, String? clientCode})>>
  activiteDepuis(int id) async => [
    for (final r in await db.rawQuery(
      'SELECT h.id, h.entite, h.action, h.entite_code, COALESCE(r.type, v.tiers_type) tiers_type, '
      'COALESCE(ve.client_code, b.client_code) client_code FROM historique h '
      "LEFT JOIN retour r ON h.entite = 'retour' AND r.code = h.entite_code "
      "LEFT JOIN versement v ON h.entite = 'versement' AND v.code = h.entite_code "
      "LEFT JOIN vente ve ON h.entite = 'vente' AND ve.code = h.entite_code "
      "LEFT JOIN bon_livraison b ON h.entite = 'bon_livraison' AND b.code = h.entite_code "
      'WHERE h.id > ? ORDER BY h.id',
      [id],
    ))
      (
        id: r['id']! as int,
        entite: r['entite']! as String,
        action: r['action']! as String,
        code: r['entite_code'] as String?,
        tiersType: r['tiers_type'] as String?,
        clientCode: r['client_code'] as String?,
      ),
  ];
}
