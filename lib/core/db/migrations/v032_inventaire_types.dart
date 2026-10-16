import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 32 : document d'inventaire et types de mouvements dédiés (audit m8, m14).
/// - `inventaire` (INV) et `inventaire_ligne` : théorique figé au début du comptage, constaté, écart ; les
///   mouvements d'écart portent la référence INV ; annulation par contre-mouvements.
/// - Mouvements existants retypés : annulation de vente (`Annulation`, et non `Retour`), stock initial des
///   fiches produit (`Stock initial`, et non `Entrée`).
class MigrationV032InventaireTypes extends Migration {
  const MigrationV032InventaireTypes();

  @override
  int get version => 32;

  @override
  String get description => 'Document d\'inventaire INV, types de mouvements Annulation et Stock initial';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE inventaire (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        debut_comptage    TEXT NOT NULL,
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        utilisateur_code  TEXT NOT NULL,
        statut            TEXT NOT NULL DEFAULT 'Validé',
        commentaire       TEXT,
        annule_le         TEXT,
        annule_par        TEXT,
        motif_annulation  TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE inventaire_ligne (
        inventaire_code   TEXT NOT NULL REFERENCES inventaire(code),
        produit_code      TEXT NOT NULL REFERENCES produit(code),
        theorique         REAL NOT NULL,
        constate          REAL NOT NULL,
        ecart             REAL NOT NULL,
        theorique_nombre  REAL NOT NULL DEFAULT 0,
        constate_nombre   REAL NOT NULL DEFAULT 0,
        ecart_nombre      REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (inventaire_code, produit_code)
      )
    ''');
    await txn.execute('DROP TRIGGER IF EXISTS mouvement_stock_sans_modification');
    await txn.execute("UPDATE mouvement_stock SET type = 'Annulation' WHERE reference_type = 'annulation'");
    await txn.execute('''
      UPDATE mouvement_stock SET type = 'Stock initial'
      WHERE type = 'Entrée' AND reference_type IS NULL AND commentaire = 'Stock initial'
    ''');
    await txn.execute('''
      CREATE TRIGGER mouvement_stock_sans_modification
      BEFORE UPDATE OF date, produit_code, magasin_code, type, quantite, nombre ON mouvement_stock
      BEGIN SELECT RAISE(ABORT, 'Journal de stock : modification interdite'); END
    ''');
  }
}
