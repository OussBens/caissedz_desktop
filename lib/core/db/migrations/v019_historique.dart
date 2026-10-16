import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 19 : écran Historique du DS v2.2 (§9.17).
/// - `historique.poste` : machine qui a écrit la ligne (colonne « Poste » et filtre du DS).
/// - Index sur l'utilisateur pour le filtre « Utilisateur ».
class MigrationV019Historique extends Migration {
  const MigrationV019Historique();

  @override
  int get version => 19;

  @override
  String get description => 'Historique DS : poste de travail';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE historique ADD COLUMN poste TEXT');
    await txn.execute('CREATE INDEX idx_historique_utilisateur ON historique(utilisateur_code)');
  }
}
