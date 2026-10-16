import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 10 : coût d'achat figé sur les lignes de vente (§7.4 `pannierProduit.prix_achat / total_achat`),
/// base des marges de la Situation (marge par panier, par période).
///
/// Les ventes antérieures sont valorisées au prix d'achat actuel du produit (meilleure approximation).
class MigrationV010CoutsVentes extends Migration {
  const MigrationV010CoutsVentes();

  @override
  int get version => 10;

  @override
  String get description => "Coût d'achat des lignes de vente (marges)";

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE vente_ligne ADD COLUMN prix_achat REAL NOT NULL DEFAULT 0');
    await txn.execute('ALTER TABLE vente_ligne ADD COLUMN total_achat REAL NOT NULL DEFAULT 0');
    await txn.execute('''
      UPDATE vente_ligne SET
        prix_achat = COALESCE((SELECT p.prix_achat FROM produit p WHERE p.code = vente_ligne.produit_code), 0),
        total_achat = ROUND(quantite * COALESCE((SELECT p.prix_achat FROM produit p WHERE p.code = vente_ligne.produit_code), 0), 2)
    ''');
  }
}
