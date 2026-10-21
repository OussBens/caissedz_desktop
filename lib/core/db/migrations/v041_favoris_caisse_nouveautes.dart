import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 41 : favoris de la caisse et nouveautés du marché.
///
/// - `favori_caisse` : produits épinglés dans l'onglet « Favoris » de la caisse (communs à tous les postes du
///   magasin), ajoutés depuis Produits ou depuis l'alerte « Bonne marge, peu vendus ».
/// - `produit.nouveau_le` : jour où le catalogue BENS a confirmé le produit comme nouveau sur le marché (apporté
///   par une boutique CaisseDZ, confirmé par les autres) ; alerte « Nouveautés du marché ».
class MigrationV041FavorisCaisseNouveautes extends Migration {
  const MigrationV041FavorisCaisseNouveautes();

  @override
  int get version => 41;

  @override
  String get description => 'Favoris de la caisse et nouveautés du marché';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE favori_caisse (
        produit_code TEXT PRIMARY KEY NOT NULL REFERENCES produit(code) ON DELETE CASCADE,
        ordre        INTEGER NOT NULL
      )
    ''');
    await txn.execute('ALTER TABLE produit ADD COLUMN nouveau_le TEXT');
  }
}
