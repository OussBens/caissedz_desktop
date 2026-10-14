import 'package:sqflite_common/sqlite_api.dart';

/// Paramètres applicatifs techniques (clé/valeur), hors paramètres métier.
class ParametresAppRepository {
  const ParametresAppRepository(this.db);

  final DatabaseExecutor db;

  static const String cleLangue = 'langue';
  static const String cleTheme = 'theme';
  static const String cleSidebarReduite = 'sidebar_reduite';

  Future<String?> lire(String cle) async {
    final rows = await db.query('parametre_app', columns: ['valeur'], where: 'cle = ?', whereArgs: [cle]);
    if (rows.isEmpty) return null;
    return rows.first['valeur'] as String?;
  }

  Future<void> ecrire(String cle, String? valeur) async {
    await db.insert(
      'parametre_app',
      {'cle': cle, 'valeur': valeur, 'modifie_le': DateTime.now().toUtc().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
