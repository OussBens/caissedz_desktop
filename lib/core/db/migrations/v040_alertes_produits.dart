import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 40 : alertes produits.
///
/// `produit.tendance_le` : jour où le catalogue BENS a signalé le produit comme tendance (vendu dans plusieurs
/// boutiques CaisseDZ), repris au téléchargement d'un rayon et à l'actualisation des tendances ; alerte
/// « Tendances du marché que vous n'avez pas ». Les seuils des alertes sont des paramètres (`parametre`).
class MigrationV040AlertesProduits extends Migration {
  const MigrationV040AlertesProduits();

  @override
  int get version => 40;

  @override
  String get description => 'Alertes produits : tendance du catalogue';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE produit ADD COLUMN tendance_le TEXT');
  }
}
