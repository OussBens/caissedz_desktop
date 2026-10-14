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
      await db.transaction((txn) async {
        await m.appliquer(txn);
        await txn.insert('journal_migration', {'version': m.version, 'description': m.description});
        await txn.execute('PRAGMA user_version = ${m.version}');
      });
      appliquees.add(m.version);
    }
    return appliquees;
  }

  void _verifierOrdre() {
    for (var i = 0; i < migrations.length; i++) {
      if (migrations[i].version != i + 1) {
        throw StateError('Migrations non contiguës : attendu ${i + 1}, trouvé ${migrations[i].version}');
      }
    }
  }
}
