import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 16 : écran Gestion caisse du DS v2.2 (§7.7, §9.13, §12.3).
/// - Caisses : solde initial (proposé comme fond à l'ouverture) et observation.
/// - Transferts entre caisses : annulation douce (état, par, motif, date).
/// - Clôtures Z par **caisse** (chaînage par caisse) avec le total des tickets annulés. Les clôtures antérieures
///   (globales, sans caisse) restent telles quelles : elles forment leur propre chaîne et ne sont jamais modifiées
///   (`ALTER TABLE … ADD COLUMN` n'écrit aucune ligne, les déclencheurs d'immuabilité restent actifs).
class MigrationV016GestionCaisse extends Migration {
  const MigrationV016GestionCaisse();

  @override
  int get version => 16;

  @override
  String get description => 'Gestion caisse DS : solde initial, annulation des transferts, clôtures Z par caisse';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE caisse ADD COLUMN solde_initial REAL NOT NULL DEFAULT 0');
    await txn.execute('ALTER TABLE caisse ADD COLUMN observation TEXT');
    for (final c in [
      'actif INTEGER NOT NULL DEFAULT 1',
      'annule_par TEXT',
      'motif_annulation TEXT',
      'date_annulation TEXT',
    ]) {
      await txn.execute('ALTER TABLE transfert_caisse ADD COLUMN $c');
    }
    await txn.execute('ALTER TABLE cloture ADD COLUMN caisse_code TEXT REFERENCES caisse(code)');
    await txn.execute('ALTER TABLE cloture ADD COLUMN total_annule REAL NOT NULL DEFAULT 0');
    await txn.execute('CREATE INDEX idx_cloture_caisse ON cloture(caisse_code, fin)');
  }
}
