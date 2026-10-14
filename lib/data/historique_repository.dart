import 'package:sqflite_common/sqlite_api.dart';

/// Journal d'audit (table `historique`).
class HistoriqueRepository {
  const HistoriqueRepository(this.db);

  final DatabaseExecutor db;

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
    'date': DateTime.now().toUtc().toIso8601String(),
  });

  Future<List<Map<String, Object?>>> lire({int limite = 500, String? entite, String? utilisateurCode}) {
    final where = <String>[];
    final args = <Object>[];
    if (entite != null) {
      where.add('entite = ?');
      args.add(entite);
    }
    if (utilisateurCode != null) {
      where.add('utilisateur_code = ?');
      args.add(utilisateurCode);
    }
    return db.query(
      'historique',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'id DESC',
      limit: limite,
    );
  }
}
