import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 23 : `sortie_stock.retour_code`. Un retour client non remis en stock (produit cassé, défectueux)
/// crée une vraie sortie « Casse » (document SRT visible dans le module Sorties), liée au retour : elle est
/// annulée avec lui et ne se modifie / n'annule pas seule.
class MigrationV023SortieRetour extends Migration {
  const MigrationV023SortieRetour();

  @override
  int get version => 23;

  @override
  String get description => 'Sortie « Casse » liée au retour client non remis en stock';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE sortie_stock ADD COLUMN retour_code TEXT');
  }
}
