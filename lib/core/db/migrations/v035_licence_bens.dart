import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';
import 'v002_demarrage.dart';

/// Version 35 : licences BENS signées et compte BENS (Desktop — Plans & Pricing).
///
/// L'essai de 14 jours remplace le mode démo : le compte système demo / demo est désactivé (gardé
/// pour l'historique qui le cite) et l'ancienne clé SHA-256 de la table `licence` est effacée. La
/// licence signée, le compte BENS et sa session sont rangés dans `parametre_app` (LicenceRepository).
class MigrationV035LicenceBens extends Migration {
  const MigrationV035LicenceBens();

  @override
  int get version => 35;

  @override
  String get description => 'Licences BENS signées, compte BENS, fin du mode démo';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.update('utilisateur', {'actif': 0}, where: 'code = ?', whereArgs: [MigrationV002Demarrage.codeDemo]);
    await txn.delete('licence');
  }
}
