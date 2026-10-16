import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 29 : prix de la fiche produit avant / après chaque ligne d'entrée. Annuler ou modifier une entrée
/// rend au produit les prix qu'il avait avant elle (si aucune entrée ni saisie ne les a changés depuis), et le
/// coût moyen pondéré d'une entrée modifiée repart du prix d'avant. Nuls pour les entrées antérieures.
class MigrationV029PrixEntree extends Migration {
  const MigrationV029PrixEntree();

  @override
  int get version => 29;

  @override
  String get description => 'Prix produit avant / après chaque ligne d\'entrée';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final c in ['prix_achat_avant', 'prix_achat_apres', 'prix_vente_avant', 'prix_vente_apres']) {
      await txn.execute('ALTER TABLE achat_ligne ADD COLUMN $c REAL');
    }
  }
}
