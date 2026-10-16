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
}
