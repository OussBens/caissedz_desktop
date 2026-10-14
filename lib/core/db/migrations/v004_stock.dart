import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 4 : stock (lot 3) — journal des mouvements, magasins des utilisateurs,
/// transferts TRM, besoins, sorties.
class MigrationV004Stock extends Migration {
  const MigrationV004Stock();

  @override
  int get version => 4;

  @override
  String get description => 'Stock : mouvements, magasins utilisateur, transferts, besoins, sorties';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute("ALTER TABLE magasin ADD COLUMN adresse TEXT NOT NULL DEFAULT ''");
    await txn.execute('''
      CREATE TABLE mouvement_stock (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        date              TEXT NOT NULL,
        produit_code      TEXT NOT NULL REFERENCES produit(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        type              TEXT NOT NULL,
        quantite          REAL NOT NULL,
        nombre            REAL NOT NULL DEFAULT 0,
        reference_type    TEXT,
        reference_code    TEXT,
        motif             TEXT,
        utilisateur_code  TEXT NOT NULL,
        commentaire       TEXT
      )
    ''');
    await txn.execute('CREATE INDEX idx_mvt_produit_magasin ON mouvement_stock(produit_code, magasin_code)');
    await txn.execute('CREATE INDEX idx_mvt_date ON mouvement_stock(date)');
    await txn.execute('CREATE INDEX idx_mvt_reference ON mouvement_stock(reference_type, reference_code)');
    await txn.execute('''
      CREATE TABLE utilisateur_magasin (
        utilisateur_code  TEXT NOT NULL REFERENCES utilisateur(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        ordre             INTEGER NOT NULL,
        PRIMARY KEY (utilisateur_code, magasin_code)
      )
    ''');
    await txn.execute('''
      CREATE TABLE transfert_stock (
        code                 TEXT PRIMARY KEY NOT NULL,
        date                 TEXT NOT NULL,
        magasin_source       TEXT NOT NULL REFERENCES magasin(code),
        magasin_destination  TEXT NOT NULL REFERENCES magasin(code),
        utilisateur_code     TEXT NOT NULL,
        commentaire          TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE transfert_stock_ligne (
        transfert_code  TEXT NOT NULL REFERENCES transfert_stock(code) ON DELETE CASCADE,
        produit_code    TEXT NOT NULL REFERENCES produit(code),
        quantite        REAL NOT NULL,
        nombre          REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (transfert_code, produit_code)
      )
    ''');
    await txn.execute('''
      CREATE TABLE besoin (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        produit_code      TEXT NOT NULL REFERENCES produit(code),
        quantite          REAL NOT NULL,
        statut            TEXT NOT NULL DEFAULT 'En attente',
        magasin_code      TEXT REFERENCES magasin(code),
        commentaire       TEXT,
        utilisateur_code  TEXT NOT NULL
      )
    ''');
    await txn.execute('''
      CREATE TABLE sortie_stock (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        motif             TEXT NOT NULL,
        utilisateur_code  TEXT NOT NULL,
        commentaire       TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE sortie_stock_ligne (
        sortie_code   TEXT NOT NULL REFERENCES sortie_stock(code) ON DELETE CASCADE,
        produit_code  TEXT NOT NULL REFERENCES produit(code),
        quantite      REAL NOT NULL,
        nombre        REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (sortie_code, produit_code)
      )
    ''');
    // L'administrateur système a pour magasin principal le magasin système.
    await txn.insert('utilisateur_magasin', {'utilisateur_code': 'USR0000', 'magasin_code': 'MAG0000', 'ordre': 0});
    await txn.insert('utilisateur_magasin', {'utilisateur_code': 'USR0001', 'magasin_code': 'MAG0000', 'ordre': 0});
  }
}
