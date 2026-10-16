import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 26 : le journal de caisse devient « en ajout seul ». Une opération annulée ou modifiée est
/// contre-passée (écriture inverse datée du jour) au lieu d'être effacée : une Z scellée reste égale au
/// grand-livre. Les déclencheurs interdisent la suppression et la modification des colonnes financières
/// (la référence reste modifiable pour les renommages de codes, l'audit pour les colonnes modifié le / par).
class MigrationV026JournalCaisseImmuable extends Migration {
  const MigrationV026JournalCaisseImmuable();

  @override
  int get version => 26;

  @override
  String get description => 'Journal de caisse en ajout seul (contre-passations, déclencheurs)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TRIGGER mouvement_caisse_sans_suppression BEFORE DELETE ON mouvement_caisse
      BEGIN SELECT RAISE(ABORT, 'Journal de caisse : suppression interdite (contre-passer)'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER mouvement_caisse_sans_modification
      BEFORE UPDATE OF date, caisse_code, type, sens, montant, mode ON mouvement_caisse
      BEGIN SELECT RAISE(ABORT, 'Journal de caisse : modification interdite (contre-passer)'); END
    ''');
  }
}
