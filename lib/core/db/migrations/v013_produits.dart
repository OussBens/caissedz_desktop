import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 13 : fiche produit complète (§7.2 et formulaire `ProduitFormDialog` du DS v2.2) — marque,
/// description, fournisseur, date d'expiration, service, taille, couleur, observation, suivi par n° de série,
/// remise « Par Produit » ; codes-barres secondaires (`produit_code_detail`) ; description et état des
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
    for (final table in ['categorie', 'sous_categorie']) {
      await txn.execute('ALTER TABLE $table ADD COLUMN description TEXT');
      await txn.execute('ALTER TABLE $table ADD COLUMN actif INTEGER NOT NULL DEFAULT 1');
    }
    await txn.execute('ALTER TABLE pack ADD COLUMN description TEXT');
    await txn.execute('ALTER TABLE remise ADD COLUMN cumulable INTEGER NOT NULL DEFAULT 0');
    await txn.execute('ALTER TABLE remise ADD COLUMN observation TEXT');
  }
}
