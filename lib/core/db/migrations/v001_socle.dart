import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 1 : tables techniques du socle.
///
/// ⚠️ PROVISOIRE : les 45 tables métier (spec 06) et le seed système
/// (MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000, admin) seront ajoutés
/// dans des migrations suivantes dès réception de la spécification.
class MigrationV001Socle extends Migration {
  const MigrationV001Socle();

  @override
  int get version => 1;

  @override
  String get description => 'Tables techniques du socle (paramètres applicatifs, favoris, journal des migrations)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE parametre_app (
        cle         TEXT PRIMARY KEY NOT NULL,
        valeur      TEXT,
        modifie_le  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('''
      CREATE TABLE favori_module (
        utilisateur_code TEXT NOT NULL,
        module_id        TEXT NOT NULL,
        ordre            INTEGER NOT NULL,
        PRIMARY KEY (utilisateur_code, module_id)
      )
    ''');
    await txn.execute('''
      CREATE TABLE journal_migration (
        version     INTEGER PRIMARY KEY NOT NULL,
        description TEXT NOT NULL,
        applique_le TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
  }
}
