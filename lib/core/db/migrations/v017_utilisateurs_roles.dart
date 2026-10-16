import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 17 : écran Utilisateurs du DS v2.2 (§6.2, §9.12).
/// - Table `role` (codes `ROL`, nom unique, observation, état) : Admin `ROL0000` (système), Caissier `ROL0001`,
///   Magasinier `ROL0002`, puis les rôles créés par l'Admin.
/// - `role_permission` / `role_module` reliés au rôle par **code** ; les 7 permissions d'action deviennent celles
///   du §6.2 (`voirPrixAchat`, `voirMarge`, `modifierPrixVente`, `annulerOperations`, `changerCaisseMagasin`,
///   `gererTransfertsCaisse`, `voirStockTousMagasins`). Correspondance des anciennes : modifier le prix / appliquer
///   une remise → `modifierPrixVente` ; annuler une vente / supprimer un document → `annulerOperations` ;
///   gérer les utilisateurs → accès au module Utilisateurs ; exporter → supprimée (l'accès au module suffit).
/// - `utilisateur` : `role_code` (remplace le nom du rôle), prénom, téléphone, caisse attachée, observation, audit.
class MigrationV017UtilisateursRoles extends Migration {
  const MigrationV017UtilisateursRoles();

  @override
  int get version => 17;

  @override
  String get description => 'Utilisateurs DS : table role (ROL), permissions §6.2, caisse attachée, prénom, téléphone';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE role (
        code         TEXT PRIMARY KEY NOT NULL,
        nom          TEXT NOT NULL UNIQUE COLLATE NOCASE,
        observation  TEXT,
        actif        INTEGER NOT NULL DEFAULT 1,
        systeme      INTEGER NOT NULL DEFAULT 0,
        cree_par     TEXT,
        cree_le      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        modifie_par  TEXT,
        modifie_le   TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.insert('role', {'code': 'ROL0000', 'nom': 'Admin', 'observation': 'Accès complet', 'systeme': 1});
    await txn.insert('role', {'code': 'ROL0001', 'nom': 'Caissier', 'observation': 'Caisse, ventes, clients'});
    await txn.insert('role', {'code': 'ROL0002', 'nom': 'Magasinier', 'observation': 'Stock, entrées, sorties'});
    // Rôles éventuels hors référentiel (défensif) : un code chacun.
    final autres = await txn.rawQuery('''
      SELECT DISTINCT nom FROM (
        SELECT role nom FROM utilisateur UNION SELECT role FROM role_permission UNION SELECT role FROM role_module)
      WHERE nom NOT IN (SELECT nom FROM role) ORDER BY nom
    ''');
    for (final (i, r) in autres.indexed) {
      await txn.insert('role', {'code': 'ROL${(i + 3).toString().padLeft(4, '0')}', 'nom': r['nom']});
    }

    await txn.execute('''
      CREATE TABLE role_permission_v17 (
        role_code   TEXT NOT NULL REFERENCES role(code),
        permission  TEXT NOT NULL,
        PRIMARY KEY (role_code, permission)
      )
    ''');
    await txn.execute('''
      INSERT OR IGNORE INTO role_permission_v17 (role_code, permission)
      SELECT r.code, CASE p.permission
               WHEN 'modifierPrix' THEN 'modifierPrixVente'
               WHEN 'appliquerRemise' THEN 'modifierPrixVente'
               WHEN 'annulerVente' THEN 'annulerOperations'
               WHEN 'supprimerDocument' THEN 'annulerOperations'
               ELSE p.permission END
      FROM role_permission p JOIN role r ON r.nom = p.role
      WHERE r.systeme = 0 AND p.permission NOT IN ('exporterDonnees', 'gererUtilisateurs')
    ''');
    await txn.execute('''
      CREATE TABLE role_module_v17 (
        role_code  TEXT NOT NULL REFERENCES role(code),
        module_id  TEXT NOT NULL,
        PRIMARY KEY (role_code, module_id)
      )
    ''');
    await txn.execute('''
      INSERT OR IGNORE INTO role_module_v17 (role_code, module_id)
      SELECT r.code, m.module_id FROM role_module m JOIN role r ON r.nom = m.role WHERE r.systeme = 0
    ''');
    await txn.execute('''
      INSERT OR IGNORE INTO role_module_v17 (role_code, module_id)
      SELECT r.code, 'utilisateurs' FROM role_permission p JOIN role r ON r.nom = p.role
      WHERE r.systeme = 0 AND p.permission = 'gererUtilisateurs'
    ''');
    await txn.execute('DROP TABLE role_permission');
    await txn.execute('DROP TABLE role_module');
    await txn.execute('ALTER TABLE role_permission_v17 RENAME TO role_permission');
    await txn.execute('ALTER TABLE role_module_v17 RENAME TO role_module');

    for (final c in [
      'role_code TEXT REFERENCES role(code)',
      "prenom TEXT NOT NULL DEFAULT ''",
      "telephone TEXT NOT NULL DEFAULT ''",
      'caisse_code TEXT REFERENCES caisse(code)',
      'observation TEXT',
      'cree_par TEXT',
      'modifie_par TEXT',
    ]) {
      await txn.execute('ALTER TABLE utilisateur ADD COLUMN $c');
    }
    await txn.execute('UPDATE utilisateur SET role_code = (SELECT r.code FROM role r WHERE r.nom = utilisateur.role)');
    await txn.execute('ALTER TABLE utilisateur DROP COLUMN role');
    await txn.execute('CREATE INDEX idx_utilisateur_role ON utilisateur(role_code)');
  }
}
