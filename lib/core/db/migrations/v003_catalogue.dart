import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 3 : catalogue (lot 2) — produits, colis, packs, remises, journal d'audit.
///
/// ⚠️ PROVISOIRE : colonnes à aligner sur les 45 tables de la spec 06.
class MigrationV003Catalogue extends Migration {
  const MigrationV003Catalogue();

  @override
  int get version => 3;

  @override
  String get description => 'Catalogue : produits, colis, packs, remises, historique';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE produit (
        code                 TEXT PRIMARY KEY NOT NULL,
        designation          TEXT NOT NULL,
        code_barres          TEXT UNIQUE,
        categorie_code       TEXT NOT NULL REFERENCES categorie(code),
        sous_categorie_code  TEXT NOT NULL REFERENCES sous_categorie(code),
        prix_achat           REAL NOT NULL DEFAULT 0,
        prix_vente           REAL NOT NULL DEFAULT 0,
        marge_pct            REAL NOT NULL DEFAULT 0,
        unite                TEXT NOT NULL DEFAULT 'Pièce',
        tva_pct              REAL NOT NULL DEFAULT 19,
        seuil_stock          INTEGER,
        suivi_nombre         INTEGER NOT NULL DEFAULT 0,
        nombre_par_unite     INTEGER NOT NULL DEFAULT 1,
        source               TEXT NOT NULL DEFAULT 'Manuel',
        actif                INTEGER NOT NULL DEFAULT 1,
        image                TEXT,
        cree_le              TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        modifie_le           TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('CREATE INDEX idx_produit_designation ON produit(designation)');
    await txn.execute('''
      CREATE TABLE colis (
        code          TEXT PRIMARY KEY NOT NULL,
        produit_code  TEXT NOT NULL REFERENCES produit(code),
        designation   TEXT NOT NULL,
        quantite      INTEGER NOT NULL CHECK (quantite > 0),
        code_barres   TEXT UNIQUE,
        prix_vente    REAL NOT NULL DEFAULT 0,
        actif         INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await txn.execute('''
      CREATE TABLE pack (
        code         TEXT PRIMARY KEY NOT NULL,
        designation  TEXT NOT NULL,
        code_barres  TEXT UNIQUE,
        prix_vente   REAL NOT NULL DEFAULT 0,
        actif        INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await txn.execute('''
      CREATE TABLE pack_ligne (
        pack_code     TEXT NOT NULL REFERENCES pack(code) ON DELETE CASCADE,
        produit_code  TEXT NOT NULL REFERENCES produit(code),
        quantite      INTEGER NOT NULL CHECK (quantite > 0),
        PRIMARY KEY (pack_code, produit_code)
      )
    ''');
    await txn.execute('''
      CREATE TABLE remise (
        code            TEXT PRIMARY KEY NOT NULL,
        designation     TEXT NOT NULL,
        type            TEXT NOT NULL,
        valeur          REAL NOT NULL,
        produit_code    TEXT REFERENCES produit(code),
        categorie_code  TEXT REFERENCES categorie(code),
        date_debut      TEXT,
        date_fin        TEXT,
        actif           INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await txn.execute('''
      CREATE TABLE historique (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        date              TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        utilisateur_code  TEXT NOT NULL,
        action            TEXT NOT NULL,
        entite            TEXT NOT NULL,
        entite_code       TEXT,
        detail            TEXT
      )
    ''');
    await txn.execute('CREATE INDEX idx_historique_date ON historique(date)');
    await txn.execute('''
      CREATE TABLE sequence_code_barres (
        jour      TEXT PRIMARY KEY NOT NULL,
        dernier   INTEGER NOT NULL
      )
    ''');
  }
}
