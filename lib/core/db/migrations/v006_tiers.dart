import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 6 : retours, versements et imputations (lot 5) ; achats (lot 6).
class MigrationV006Tiers extends Migration {
  const MigrationV006Tiers();

  @override
  int get version => 6;

  @override
  String get description => 'Tiers : retours, versements imputés, achats';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute("ALTER TABLE fournisseur ADD COLUMN adresse TEXT NOT NULL DEFAULT ''");
    await txn.execute("ALTER TABLE fournisseur ADD COLUMN email TEXT NOT NULL DEFAULT ''");
    await txn.execute('''
      CREATE TABLE retour (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        vente_code        TEXT NOT NULL REFERENCES vente(code),
        client_code       TEXT NOT NULL REFERENCES client(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        utilisateur_code  TEXT NOT NULL,
        total             REAL NOT NULL,
        rembourse         REAL NOT NULL DEFAULT 0,
        motif             TEXT,
        versement_code    TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE retour_ligne (
        retour_code    TEXT NOT NULL REFERENCES retour(code) ON DELETE CASCADE,
        ordre          INTEGER NOT NULL,
        produit_code   TEXT NOT NULL REFERENCES produit(code),
        designation    TEXT NOT NULL,
        quantite       REAL NOT NULL,
        nombre         REAL NOT NULL DEFAULT 0,
        prix_unitaire  REAL NOT NULL,
        total          REAL NOT NULL,
        PRIMARY KEY (retour_code, ordre)
      )
    ''');
    await txn.execute('''
      CREATE TABLE achat (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        fournisseur_code  TEXT NOT NULL REFERENCES fournisseur(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        utilisateur_code  TEXT NOT NULL,
        reference         TEXT,
        total             REAL NOT NULL,
        verse             REAL NOT NULL DEFAULT 0,
        reste             REAL NOT NULL DEFAULT 0,
        statut            TEXT NOT NULL DEFAULT 'Validé',
        source            TEXT NOT NULL DEFAULT 'Manuel',
        commentaire       TEXT
      )
    ''');
    await txn.execute('CREATE INDEX idx_achat_fournisseur ON achat(fournisseur_code)');
    await txn.execute('''
      CREATE TABLE achat_ligne (
        achat_code     TEXT NOT NULL REFERENCES achat(code) ON DELETE CASCADE,
        ordre          INTEGER NOT NULL,
        produit_code   TEXT NOT NULL REFERENCES produit(code),
        designation    TEXT NOT NULL,
        quantite       REAL NOT NULL,
        nombre         REAL NOT NULL DEFAULT 0,
        prix_achat     REAL NOT NULL,
        total          REAL NOT NULL,
        PRIMARY KEY (achat_code, ordre)
      )
    ''');
    await txn.execute('''
      CREATE TABLE versement (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        tiers_type        TEXT NOT NULL,
        tiers_code        TEXT NOT NULL,
        sens              TEXT NOT NULL,
        montant           REAL NOT NULL,
        mode              TEXT NOT NULL,
        utilisateur_code  TEXT NOT NULL,
        caisse_code       TEXT REFERENCES caisse(code),
        reference         TEXT,
        commentaire       TEXT,
        retour_code       TEXT REFERENCES retour(code),
        verrouille        INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('CREATE INDEX idx_versement_tiers ON versement(tiers_type, tiers_code)');
    await txn.execute('''
      CREATE TABLE versement_imputation (
        versement_code  TEXT NOT NULL REFERENCES versement(code) ON DELETE CASCADE,
        document_type   TEXT NOT NULL,
        document_code   TEXT NOT NULL,
        montant         REAL NOT NULL,
        PRIMARY KEY (versement_code, document_type, document_code)
      )
    ''');
  }
}
