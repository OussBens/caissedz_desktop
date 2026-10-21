import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 39 : nom arabe des produits et tendance du catalogue BENS.
///
/// `produit.designation_ar` : nom arabe facultatif (recherche, tickets et documents en arabe), repris du
/// catalogue BENS au téléchargement d'un rayon. `catalogue_rayon.tendance_le` : jour du dernier ajout des
/// produits devenus tendance dans ce rayon (seuls les nouveaux sont demandés ensuite).
class MigrationV039NomArabeTendance extends Migration {
  const MigrationV039NomArabeTendance();

  @override
  int get version => 39;

  @override
  String get description => 'Nom arabe des produits et tendance du catalogue';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE produit ADD COLUMN designation_ar TEXT');
    await txn.execute('ALTER TABLE catalogue_rayon ADD COLUMN tendance_le TEXT');
  }
}
