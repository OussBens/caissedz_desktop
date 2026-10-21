import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 38 : rayons du catalogue BENS téléchargés.
///
/// À l'accueil, l'administrateur choisit des rayons du catalogue (catalog-api.bensds.com, `GET /rayons`) ;
/// leurs produits les mieux classés entrent dans `produit` (source `Catalogue`, sans prix). Chaque rayon
/// est rattaché à UNE catégorie locale (et sa sous-catégorie) : un nouveau téléchargement du même rayon
/// la réutilise et n'ajoute que les produits absents.
class MigrationV038CatalogueRayons extends Migration {
  const MigrationV038CatalogueRayons();

  @override
  int get version => 38;

  @override
  String get description => 'Rayons du catalogue BENS téléchargés';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE catalogue_rayon (
        rayon_code           TEXT PRIMARY KEY NOT NULL,
        nom                  TEXT NOT NULL,
        categorie_code       TEXT NOT NULL REFERENCES categorie(code),
        sous_categorie_code  TEXT NOT NULL REFERENCES sous_categorie(code),
        disponibles          INTEGER NOT NULL DEFAULT 0,
        telecharges          INTEGER NOT NULL DEFAULT 0,
        importe_le           TEXT NOT NULL
      )
    ''');
    await txn.execute('CREATE INDEX idx_produit_source ON produit(source)');
  }
}
