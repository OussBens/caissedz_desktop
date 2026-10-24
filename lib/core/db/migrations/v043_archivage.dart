import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 43 : archivage des fiches qui ont un historique.
///
/// Un produit, pack, client, fournisseur, magasin, caisse, utilisateur ou rôle jamais utilisé est supprimé ;
/// s'il est référencé (ventes, achats, mouvements, versements, journal…), il est archivé à la place : la ligne
/// reste en base (clés étrangères, rapports et anciens documents intacts), désactivée (`actif = 0`) et masquée
/// des listes de gestion et des sélecteurs. `archive_le` / `archive_par` : date et auteur de l'archivage
/// (`NULL` = non archivé) ; une restauration les remet à `NULL`.
class MigrationV043Archivage extends Migration {
  const MigrationV043Archivage();

  /// Tables des fiches archivables.
  static const List<String> tables = [
    'produit',
    'pack',
    'client',
    'fournisseur',
    'magasin',
    'caisse',
    'utilisateur',
    'role',
  ];

  @override
  int get version => 43;

  @override
  String get description => 'Archivage des fiches ayant un historique';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final t in tables) {
      await txn.execute('ALTER TABLE $t ADD COLUMN archive_le TEXT');
      await txn.execute('ALTER TABLE $t ADD COLUMN archive_par TEXT');
    }
  }
}
