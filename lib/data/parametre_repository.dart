import 'package:sqflite_common/sqlite_api.dart';

/// Paramètres métier (table `parametre`, clé/valeur).
class ParametreRepository {
  const ParametreRepository(this.db);

  final DatabaseExecutor db;

  static const String cleConfigurationTerminee = 'configuration_terminee';

  Future<String?> lire(String cle) async {
    final rows = await db.query('parametre', columns: ['valeur'], where: 'cle = ?', whereArgs: [cle]);
    return rows.isEmpty ? null : rows.first['valeur'] as String?;
  }

  Future<Map<String, String?>> lirePlusieurs(Iterable<String> cles) async {
    final liste = cles.toList();
    if (liste.isEmpty) return {};
    final rows = await db.query(
      'parametre',
      where: 'cle IN (${List.filled(liste.length, '?').join(',')})',
      whereArgs: liste,
    );
    return {for (final r in rows) r['cle'] as String: r['valeur'] as String?};
  }

  Future<void> ecrire(String cle, String? valeur) => db.insert('parametre', {
    'cle': cle,
    'valeur': valeur,
    'modifie_le': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> ecrirePlusieurs(Map<String, String?> valeurs) async {
    for (final e in valeurs.entries) {
      await ecrire(e.key, e.value);
    }
  }
}
