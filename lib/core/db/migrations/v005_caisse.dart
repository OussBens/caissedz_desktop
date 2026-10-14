import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 5 : caisse POS (lot 4) — sessions, ventes scellées, lignes, paiements, points client.
class MigrationV005Caisse extends Migration {
  const MigrationV005Caisse();

  @override
  int get version => 5;

  @override
  String get description => 'Caisse : sessions, ventes, lignes, paiements, points de fidélité';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE client ADD COLUMN points INTEGER NOT NULL DEFAULT 0');
    await txn.execute("ALTER TABLE client ADD COLUMN adresse TEXT NOT NULL DEFAULT ''");
    await txn.execute("ALTER TABLE client ADD COLUMN email TEXT NOT NULL DEFAULT ''");
    await txn.execute('ALTER TABLE client ADD COLUMN plafond_credit REAL NOT NULL DEFAULT 0');
    await txn.execute('''
      CREATE TABLE session_caisse (
        code               TEXT PRIMARY KEY NOT NULL,
        caisse_code        TEXT NOT NULL REFERENCES caisse(code),
        utilisateur_code   TEXT NOT NULL,
        ouverte_le         TEXT NOT NULL,
        fermee_le          TEXT,
        fond_initial       REAL NOT NULL DEFAULT 0,
        montant_fermeture  REAL,
        ecart              REAL,
        statut             TEXT NOT NULL DEFAULT 'Ouverte'
      )
    ''');
    await txn.execute('''
      CREATE TABLE vente (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        session_code      TEXT NOT NULL REFERENCES session_caisse(code),
        caisse_code       TEXT NOT NULL REFERENCES caisse(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        client_code       TEXT NOT NULL REFERENCES client(code),
        utilisateur_code  TEXT NOT NULL,
        total_brut        REAL NOT NULL,
        total_remise      REAL NOT NULL,
        total_net         REAL NOT NULL,
        verse             REAL NOT NULL,
        reste             REAL NOT NULL,
        points_gagnes     INTEGER NOT NULL DEFAULT 0,
        points_utilises   INTEGER NOT NULL DEFAULT 0,
        statut            TEXT NOT NULL DEFAULT 'Validée',
        annulee_le        TEXT,
        annulee_par       TEXT,
        hash              TEXT NOT NULL,
        hash_precedent    TEXT NOT NULL,
        commentaire       TEXT
      )
    ''');
    await txn.execute('CREATE INDEX idx_vente_date ON vente(date)');
    await txn.execute('CREATE INDEX idx_vente_client ON vente(client_code)');
    await txn.execute('''
      CREATE TABLE vente_ligne (
        vente_code     TEXT NOT NULL REFERENCES vente(code) ON DELETE CASCADE,
        ordre          INTEGER NOT NULL,
        produit_code   TEXT NOT NULL REFERENCES produit(code),
        colis_code     TEXT REFERENCES colis(code),
        pack_code      TEXT REFERENCES pack(code),
        designation    TEXT NOT NULL,
        quantite       REAL NOT NULL,
        nombre         REAL NOT NULL DEFAULT 0,
        unite_vente    TEXT NOT NULL DEFAULT 'Unité',
        prix_unitaire  REAL NOT NULL,
        remise         REAL NOT NULL DEFAULT 0,
        total          REAL NOT NULL,
        PRIMARY KEY (vente_code, ordre)
      )
    ''');
    await txn.execute('''
      CREATE TABLE vente_paiement (
        vente_code  TEXT NOT NULL REFERENCES vente(code) ON DELETE CASCADE,
        ordre       INTEGER NOT NULL,
        mode        TEXT NOT NULL,
        montant     REAL NOT NULL,
        reference   TEXT,
        PRIMARY KEY (vente_code, ordre)
      )
    ''');
  }
}
