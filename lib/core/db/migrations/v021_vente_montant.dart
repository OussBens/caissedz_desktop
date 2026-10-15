import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 21 : produit système `PRD0000` « Vente au montant » (service, sans stock).
/// Porte la ligne de montant libre de la caisse (balance, articles non codifiés : 200 + 500 = 700 DA), afin que
/// la vente, le ticket scellé et la recette restent rattachés à un code produit (relations par code).
/// Masqué des listes du catalogue, des ruptures et de l'inventaire.
///
/// Ajoute aussi `vente_ligne.composant_pack` : un pack vendu en caisse est éclaté en une ligne par produit
/// (quantité en unités du produit, `pack_code` renseigné) ; les anciennes lignes de pack (quantité = nombre de
/// packs) gardent 0 et restent annulées composant par composant.
class MigrationV021VenteMontant extends Migration {
  const MigrationV021VenteMontant();

  static const String code = 'PRD0000'; // = PanierLigne.codeMontant

  @override
  int get version => 21;

  @override
  String get description => 'Produit système « Vente au montant », lignes de pack éclatées';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.rawInsert(
      '''
      INSERT OR IGNORE INTO produit (code, designation, categorie_code, sous_categorie_code, prix_achat, prix_vente,
        unite, service, actif, source)
      VALUES (?, 'Vente au montant', 'CATE0000', 'SC0000', 0, 0, 'Pièce', 1, 1, 'Manuel')
      ''',
      [code],
    );
    await txn.execute('ALTER TABLE vente_ligne ADD COLUMN composant_pack INTEGER NOT NULL DEFAULT 0');
  }
}
