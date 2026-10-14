import 'package:sqflite_common/sqlite_api.dart';

import '../../../domain/code_generator.dart';
import '../../../domain/permissions.dart';
import '../../securite/mot_de_passe.dart';
import 'migration.dart';

/// Version 2 : démarrage (lot 1) — utilisateurs, rôles et permissions, licence,
/// boutique, paramètres métier, et éléments système codés (seed).
///
/// ⚠️ PROVISOIRE : colonnes minimales des tables `magasin`, `caisse`,
/// `categorie`, `sous_categorie`, `client`, `fournisseur` pour porter le seed
/// système ; elles seront complétées par les lots suivants selon les 45 tables
/// de la spec 06.
class MigrationV002Demarrage extends Migration {
  const MigrationV002Demarrage();

  static const String codeAdmin = 'USR0000';
  static const String codeDemo = 'USR0001';
  static const String identifiantDemo = 'demo';
  static const String motDePasseDemo = 'demo';

  @override
  int get version => 2;

  @override
  String get description => 'Démarrage : utilisateurs, rôles, licence, boutique, paramètres, seed système';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE utilisateur (
        code             TEXT PRIMARY KEY NOT NULL,
        identifiant      TEXT NOT NULL UNIQUE COLLATE NOCASE,
        nom              TEXT NOT NULL,
        role             TEXT NOT NULL,
        mot_de_passe     TEXT,
        actif            INTEGER NOT NULL DEFAULT 1,
        systeme          INTEGER NOT NULL DEFAULT 0,
        cree_le          TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        modifie_le       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('''
      CREATE TABLE role_permission (
        role        TEXT NOT NULL,
        permission  TEXT NOT NULL,
        PRIMARY KEY (role, permission)
      )
    ''');
    await txn.execute('''
      CREATE TABLE role_module (
        role       TEXT NOT NULL,
        module_id  TEXT NOT NULL,
        PRIMARY KEY (role, module_id)
      )
    ''');
    await txn.execute('''
      CREATE TABLE licence (
        id          INTEGER PRIMARY KEY CHECK (id = 1),
        cle         TEXT,
        niveau      TEXT NOT NULL,
        demo        INTEGER NOT NULL DEFAULT 0,
        activee_le  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('''
      CREATE TABLE boutique (
        id         INTEGER PRIMARY KEY CHECK (id = 1),
        nom        TEXT NOT NULL,
        rc         TEXT NOT NULL DEFAULT '',
        nif        TEXT NOT NULL DEFAULT '',
        adresse    TEXT NOT NULL DEFAULT '',
        telephone  TEXT NOT NULL DEFAULT '',
        email      TEXT NOT NULL DEFAULT ''
      )
    ''');
    await txn.execute('''
      CREATE TABLE parametre (
        cle         TEXT PRIMARY KEY NOT NULL,
        valeur      TEXT,
        modifie_le  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('''
      CREATE TABLE magasin (
        code     TEXT PRIMARY KEY NOT NULL,
        nom      TEXT NOT NULL,
        actif    INTEGER NOT NULL DEFAULT 1,
        systeme  INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE caisse (
        code          TEXT PRIMARY KEY NOT NULL,
        nom           TEXT NOT NULL,
        type          TEXT NOT NULL DEFAULT 'Physique',
        magasin_code  TEXT REFERENCES magasin(code),
        actif         INTEGER NOT NULL DEFAULT 1,
        systeme       INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE categorie (
        code     TEXT PRIMARY KEY NOT NULL,
        nom      TEXT NOT NULL,
        systeme  INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE sous_categorie (
        code            TEXT PRIMARY KEY NOT NULL,
        categorie_code  TEXT NOT NULL REFERENCES categorie(code),
        nom             TEXT NOT NULL,
        systeme         INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE client (
        code       TEXT PRIMARY KEY NOT NULL,
        nom        TEXT NOT NULL,
        telephone  TEXT NOT NULL DEFAULT '',
        actif      INTEGER NOT NULL DEFAULT 1,
        systeme    INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE fournisseur (
        code       TEXT PRIMARY KEY NOT NULL,
        nom        TEXT NOT NULL,
        telephone  TEXT NOT NULL DEFAULT '',
        actif      INTEGER NOT NULL DEFAULT 1,
        systeme    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed des éléments système (§8.10) — relations toujours par code.
    await txn.insert('magasin', {'code': CodeGenerator.systeme(CodeGenerator.magasin), 'nom': 'Magasin principal', 'systeme': 1});
    await txn.insert('caisse', {
      'code': CodeGenerator.systeme(CodeGenerator.caisse),
      'nom': 'Caisse principale',
      'type': 'Physique',
      'magasin_code': CodeGenerator.systeme(CodeGenerator.magasin),
      'systeme': 1,
    });
    await txn.insert('categorie', {'code': CodeGenerator.systeme(CodeGenerator.categorie), 'nom': 'Sans catégorie', 'systeme': 1});
    await txn.insert('sous_categorie', {
      'code': CodeGenerator.systeme(CodeGenerator.sousCategorie),
      'categorie_code': CodeGenerator.systeme(CodeGenerator.categorie),
      'nom': 'Sans sous-catégorie',
      'systeme': 1,
    });
    await txn.insert('client', {'code': CodeGenerator.systeme(CodeGenerator.client), 'nom': 'Client de passage', 'systeme': 1});
    await txn.insert('fournisseur', {'code': CodeGenerator.systeme(CodeGenerator.fournisseur), 'nom': 'Fournisseur divers', 'systeme': 1});

    // Administrateur système : mot de passe défini lors de la configuration initiale.
    await txn.insert('utilisateur', {
      'code': codeAdmin,
      'identifiant': 'admin',
      'nom': 'Administrateur',
      'role': Roles.admin,
      'mot_de_passe': null,
      'systeme': 1,
    });
    // Compte de démonstration demo/demo (mot de passe public : itérations réduites).
    await txn.insert('utilisateur', {
      'code': codeDemo,
      'identifiant': identifiantDemo,
      'nom': 'Démonstration',
      'role': Roles.admin,
      'mot_de_passe': const MotDePasse(iterations: 1000).hacher(motDePasseDemo),
      'systeme': 1,
    });

    // Permissions et modules par défaut des rôles.
    for (final e in Roles.permissionsParDefaut.entries) {
      for (final p in e.value) {
        await txn.insert('role_permission', {'role': e.key, 'permission': p.code});
      }
    }
    for (final e in Roles.modulesParDefaut.entries) {
      for (final m in e.value) {
        await txn.insert('role_module', {'role': e.key, 'module_id': m});
      }
    }
  }
}
