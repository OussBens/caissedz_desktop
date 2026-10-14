import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 7 : journal des mouvements de caisse, transferts TRF, clôtures Z chaînées immuables (lot 7).
///
/// ⚠️ PROVISOIRE : colonnes déduites de la commande (spec 06 absente) ; la clôture Z est globale
/// (toutes caisses) sur la période écoulée depuis la clôture précédente.
class MigrationV007GestionCaisse extends Migration {
  const MigrationV007GestionCaisse();

  @override
  int get version => 7;

  @override
  String get description => 'Gestion de caisse : mouvements, transferts TRF, clôtures Z';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE mouvement_caisse (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        date              TEXT NOT NULL,
        caisse_code       TEXT NOT NULL REFERENCES caisse(code),
        type              TEXT NOT NULL,
        sens              TEXT NOT NULL,
        montant           REAL NOT NULL,
        mode              TEXT NOT NULL DEFAULT 'Espèces',
        reference_type    TEXT,
        reference_code    TEXT,
        utilisateur_code  TEXT NOT NULL,
        commentaire       TEXT
      )
    ''');
    await txn.execute('CREATE INDEX idx_mvt_caisse_caisse ON mouvement_caisse(caisse_code, date)');
    await txn.execute('CREATE INDEX idx_mvt_caisse_ref ON mouvement_caisse(reference_type, reference_code)');
    await txn.execute('''
      CREATE TABLE transfert_caisse (
        code                TEXT PRIMARY KEY NOT NULL,
        date                TEXT NOT NULL,
        caisse_source       TEXT NOT NULL REFERENCES caisse(code),
        caisse_destination  TEXT NOT NULL REFERENCES caisse(code),
        montant             REAL NOT NULL,
        mode                TEXT NOT NULL DEFAULT 'Espèces',
        utilisateur_code    TEXT NOT NULL,
        commentaire         TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE cloture (
        code                    TEXT PRIMARY KEY NOT NULL,
        date                    TEXT NOT NULL,
        debut                   TEXT NOT NULL,
        fin                     TEXT NOT NULL,
        utilisateur_code        TEXT NOT NULL,
        nb_ventes               INTEGER NOT NULL,
        nb_annulations          INTEGER NOT NULL,
        total_ventes            REAL NOT NULL,
        total_remises           REAL NOT NULL,
        total_retours           REAL NOT NULL,
        total_encaissements     REAL NOT NULL,
        total_decaissements     REAL NOT NULL,
        encaissements_par_mode  TEXT NOT NULL,
        soldes_caisses          TEXT NOT NULL,
        premiere_vente          TEXT,
        derniere_vente          TEXT,
        hash_derniere_vente     TEXT NOT NULL,
        hash_precedent          TEXT NOT NULL,
        hash                    TEXT NOT NULL
      )
    ''');
    // Immuabilité : toute modification ou suppression d'une clôture est refusée par le moteur.
    await txn.execute('''
      CREATE TRIGGER cloture_immuable_update BEFORE UPDATE ON cloture
      BEGIN SELECT RAISE(ABORT, 'cloture immuable'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER cloture_immuable_delete BEFORE DELETE ON cloture
      BEGIN SELECT RAISE(ABORT, 'cloture immuable'); END
    ''');
  }
}
