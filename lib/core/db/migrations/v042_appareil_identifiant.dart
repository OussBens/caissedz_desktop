import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 42 : un seul enregistrement par téléphone appairé.
///
/// - `appareil_mobile.identifiant` : identifiant d'installation envoyé par CaisseDZ Scan (stable tant que
///   l'application n'est pas réinstallée) ; un nouvel appairage du même téléphone remplace l'ancien au lieu de
///   l'ajouter. `modele` : modèle envoyé à l'appairage (« SM-A515F »).
/// - Doublons existants (même utilisateur, même nom, même plateforme) : seul le plus récent est gardé, les
///   anciens jetons ne servaient plus (le téléphone ne garde que son dernier appairage).
class MigrationV042AppareilIdentifiant extends Migration {
  const MigrationV042AppareilIdentifiant();

  @override
  int get version => 42;

  @override
  String get description => 'Téléphone appairé unique (identifiant d’installation)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE appareil_mobile ADD COLUMN identifiant TEXT');
    await txn.execute("ALTER TABLE appareil_mobile ADD COLUMN modele TEXT NOT NULL DEFAULT ''");
    await txn.execute('CREATE INDEX idx_appareil_mobile_identifiant ON appareil_mobile(identifiant)');
    await txn.execute('''
      DELETE FROM appareil_mobile
      WHERE EXISTS (
        SELECT 1 FROM appareil_mobile r
        WHERE r.utilisateur_code IS appareil_mobile.utilisateur_code
          AND r.nom = appareil_mobile.nom
          AND r.plateforme = appareil_mobile.plateforme
          AND (COALESCE(r.dernier_acces, r.cree_le), r.cree_le, r.code)
            > (COALESCE(appareil_mobile.dernier_acces, appareil_mobile.cree_le), appareil_mobile.cree_le,
               appareil_mobile.code)
      )
    ''');
  }
}
