import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 13 : fiche produit complète (§7.2 et formulaire `ProduitFormDialog` du DS v2.2) — marque,
/// description, fournisseur, date d'expiration, service, taille, couleur, observation, suivi par n° de série,
/// remise « Par Produit » ; type de remise et seuil ; codes-barres secondaires (`produit_code_detail`) ; description et état des
/// catégories et sous-catégories ; description des packs ; remise cumulable et observation.
class MigrationV013Produits extends Migration {
  const MigrationV013Produits();

  @override
  int get version => 13;

  @override
  String get description => 'Fiche produit complète, codes-barres secondaires, catégories et remises';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final colonne in [
      'marque TEXT',
      'description TEXT',
      'fournisseur_code TEXT REFERENCES fournisseur(code)',
      'date_expiration TEXT',
      'service INTEGER NOT NULL DEFAULT 0',
      'taille TEXT',
      'couleur TEXT',
      'observation TEXT',
      'suivi_serie INTEGER NOT NULL DEFAULT 0',
      'remise_code TEXT REFERENCES remise(code)',
    ]) {
      await txn.execute('ALTER TABLE produit ADD COLUMN $colonne');
    }
    await txn.execute('''
      CREATE TABLE produit_code_detail (
        produit_code  TEXT NOT NULL REFERENCES produit(code) ON DELETE CASCADE,
        code_barres   TEXT NOT NULL UNIQUE,
        PRIMARY KEY (produit_code, code_barres)
      )
    ''');
    // Photos du produit (4 max) ; la première est aussi recopiée dans `produit.image` (photo principale).
    await txn.execute('''
      CREATE TABLE produit_photo (
        produit_code  TEXT NOT NULL REFERENCES produit(code) ON DELETE CASCADE,
        ordre         INTEGER NOT NULL,
        chemin        TEXT NOT NULL,
        PRIMARY KEY (produit_code, ordre)
      )
    ''');
    for (final table in ['categorie', 'sous_categorie']) {
      await txn.execute('ALTER TABLE $table ADD COLUMN description TEXT');
      await txn.execute('ALTER TABLE $table ADD COLUMN actif INTEGER NOT NULL DEFAULT 1');
    }
    await txn.execute('ALTER TABLE pack ADD COLUMN description TEXT');
    await txn.execute('ALTER TABLE remise ADD COLUMN cumulable INTEGER NOT NULL DEFAULT 0');
    await txn.execute('ALTER TABLE remise ADD COLUMN observation TEXT');
    // §7 : type de remise (`Par Produit` / `Par Montant`) et seuil de la remise conditionnelle.
    await txn.execute("ALTER TABLE remise ADD COLUMN portee TEXT NOT NULL DEFAULT 'Par Produit'");
    await txn.execute('ALTER TABLE remise ADD COLUMN seuil REAL NOT NULL DEFAULT 0');
    // Les remises sans produit ni catégorie servaient de remise panier.
    await txn.execute("UPDATE remise SET portee = 'Par Montant' WHERE produit_code IS NULL AND categorie_code IS NULL");
  }
}
