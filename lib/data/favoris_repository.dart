import 'package:sqflite_common/sqlite_api.dart';

/// Favoris de la barre latérale, par utilisateur (relation par code).
class FavorisRepository {
  const FavorisRepository(this.db);

  final Database db;

  Future<List<String>> lire(String utilisateurCode) async {
    final rows = await db.query(
      'favori_module',
      columns: ['module_id'],
      where: 'utilisateur_code = ?',
      whereArgs: [utilisateurCode],
      orderBy: 'ordre',
    );
    return rows.map((r) => r['module_id'] as String).toList();
  }

  /// Remplace la liste complète (ordre = position dans la liste).
  Future<void> ecrire(String utilisateurCode, List<String> moduleIds) async {
    await db.transaction((txn) async {
      await txn.delete('favori_module', where: 'utilisateur_code = ?', whereArgs: [utilisateurCode]);
      for (var i = 0; i < moduleIds.length; i++) {
        await txn.insert('favori_module', {
          'utilisateur_code': utilisateurCode,
          'module_id': moduleIds[i],
          'ordre': i,
        });
      }
    });
  }
}
