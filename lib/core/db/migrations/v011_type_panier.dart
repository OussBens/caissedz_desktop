import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 11 : type de panier (§13 `typePannier` : `Ticket`, `BL`, `BL_SC`) sur la vente, hors scellement
/// (le ticket scellé reste identique). Les ventes existantes sont des tickets.
class MigrationV011TypePanier extends Migration {
  const MigrationV011TypePanier();

  @override
  int get version => 11;

  @override
  String get description => 'Type de panier des ventes';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute("ALTER TABLE vente ADD COLUMN type_panier TEXT NOT NULL DEFAULT 'Ticket'");
  }
}
