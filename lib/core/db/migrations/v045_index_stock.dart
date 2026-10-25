import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 45 : le stock de chaque produit se lit dans un index.
///
/// Les quantités en stock sont la somme des mouvements ; avec la quantité dans l'index, cette somme pour tout le
/// catalogue (liste des produits du téléphone) ne lit plus la table des mouvements, environ cinq fois plus vite.
class MigrationV045IndexStock extends Migration {
  const MigrationV045IndexStock();

  @override
  int get version => 45;

  @override
  String get description => 'Index des quantités en stock';

  @override
  Future<void> appliquer(Transaction txn) => txn.execute(
    'CREATE INDEX IF NOT EXISTS idx_mvt_produit_magasin_quantite ON mouvement_stock(produit_code, magasin_code, quantite)',
  );
}
