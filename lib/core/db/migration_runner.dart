import 'package:sqflite_common/sqlite_api.dart';

import 'migrations/migrations.dart';

/// Applique les migrations manquantes, chacune dans sa propre transaction,
/// en s'appuyant sur `PRAGMA user_version`.
class MigrationRunner {
  const MigrationRunner(this.migrations);

  final List<Migration> migrations;

  int get versionCible => migrations.isEmpty ? 0 : migrations.last.version;

  Future<int> versionCourante(DatabaseExecutor db) async {
    final rows = await db.rawQuery('PRAGMA user_version');
    return (rows.first.values.first as int?) ?? 0;
  }

  /// Retourne la liste des versions appliquées lors de cet appel.
  Future<List<int>> executer(Database db) async {
    _verifierOrdre();
    final courante = await versionCourante(db);
    final appliquees = <int>[];
    for (final m in migrations.where((m) => m.version > courante)) {
      // `PRAGMA foreign_keys` est sans effet dans une transaction : il se règle avant et après.
      final clesActives = m.reconstruitTables && await _clesEtrangeresActives(db);
      if (clesActives) await db.execute('PRAGMA foreign_keys = OFF');
      try {
        await db.transaction((txn) async {
          await m.appliquer(txn);
          if (m.reconstruitTables) {
            final violations = await txn.rawQuery('PRAGMA foreign_key_check');
            if (violations.isNotEmpty) {
              throw StateError('Migration ${m.version} : clés étrangères invalides ${violations.first}');
            }
          }
          await txn.insert('journal_migration', {'version': m.version, 'description': m.description});
          await txn.execute('PRAGMA user_version = ${m.version}');
        });
      } finally {
        if (clesActives) await db.execute('PRAGMA foreign_keys = ON');
      }
      appliquees.add(m.version);
    }
    return appliquees;
  }

  Future<bool> _clesEtrangeresActives(Database db) async =>
      ((await db.rawQuery('PRAGMA foreign_keys')).first.values.first as int? ?? 0) == 1;

  void _verifierOrdre() {
    for (var i = 0; i < migrations.length; i++) {
      if (migrations[i].version != i + 1) {
        throw StateError('Migrations non contiguës : attendu ${i + 1}, trouvé ${migrations[i].version}');
      }
    }
  }
}
