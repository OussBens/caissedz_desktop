import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 46 : un utilisateur a plusieurs caisses, comme ses magasins.
///
/// - `utilisateur_caisse` : caisses ordonnées d'un compte (la première est sa caisse par défaut). L'Admin n'y a pas
///   de ligne : il a toutes les caisses.
/// - `caisse_courante` : caisse choisie dans l'écran Caisse, parmi les siennes. Elle désigne la session partagée
///   que l'utilisateur continue et la caisse d'imputation par défaut (achats, versements, retours). Table à part :
///   changer de caisse ne modifie pas la fiche du compte (traçabilité).
/// - Reprise : la caisse attachée devient la seule caisse du compte et sa caisse courante ; un compte « libre »
///   (sans caisse attachée) reçoit toutes les caisses actives hors coffre.
/// - `utilisateur.caisse_code` n'est plus lue ni écrite (SQLite ne supprime pas une colonne à clé étrangère) ;
///   ses valeurs sont gardées pour ne pas horodater une modification des comptes.
class MigrationV046CaissesUtilisateur extends Migration {
  const MigrationV046CaissesUtilisateur();

  @override
  int get version => 46;

  @override
  String get description => 'Plusieurs caisses par utilisateur (utilisateur_caisse, caisse_courante)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE utilisateur_caisse (
        utilisateur_code  TEXT NOT NULL REFERENCES utilisateur(code),
        caisse_code       TEXT NOT NULL REFERENCES caisse(code),
        ordre             INTEGER NOT NULL,
        PRIMARY KEY (utilisateur_code, caisse_code)
      )
    ''');
    await txn.execute('''
      CREATE TABLE caisse_courante (
        utilisateur_code  TEXT PRIMARY KEY NOT NULL REFERENCES utilisateur(code),
        caisse_code       TEXT NOT NULL REFERENCES caisse(code)
      )
    ''');
    await txn.execute('''
      INSERT INTO utilisateur_caisse (utilisateur_code, caisse_code, ordre)
      SELECT code, caisse_code, 0 FROM utilisateur WHERE caisse_code IS NOT NULL AND role_code <> 'ROL0000'
    ''');
    await txn.execute('''
      INSERT INTO utilisateur_caisse (utilisateur_code, caisse_code, ordre)
      SELECT u.code, c.code, (SELECT COUNT(*) FROM caisse x WHERE x.actif = 1 AND x.coffre = 0 AND x.code < c.code)
      FROM utilisateur u JOIN caisse c ON c.actif = 1 AND c.coffre = 0
      WHERE u.caisse_code IS NULL AND u.role_code <> 'ROL0000'
    ''');
    await txn.execute('''
      INSERT INTO caisse_courante (utilisateur_code, caisse_code)
      SELECT code, caisse_code FROM utilisateur WHERE caisse_code IS NOT NULL
    ''');
  }
}
