import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 12 : retours clients ET fournisseurs (§7 `retours`, §9.3).
///
/// La table `retour` est reconstruite : `type` (Client / Fournisseur), pièce d'origine `document_code`
/// (panier ou entrée, `retour_correspond_de`), client OU fournisseur, règlement (Espèces, Carte, Avoir),
/// remise en stock, n° de série, annulation douce (`etat`, date, auteur, motif). Les lignes gardent le
/// prix d'achat (affiché par le DS). Les retours existants sont des retours clients.
class MigrationV012Retours extends Migration {
  const MigrationV012Retours();

  @override
  int get version => 12;

  @override
  String get description => 'Retours clients et fournisseurs';

  @override
  bool get reconstruitTables => true;

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE retour_v12 (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        type              TEXT NOT NULL DEFAULT 'Client',
        document_code     TEXT NOT NULL,
        client_code       TEXT REFERENCES client(code),
        fournisseur_code  TEXT REFERENCES fournisseur(code),
        magasin_code      TEXT NOT NULL REFERENCES magasin(code),
        utilisateur_code  TEXT NOT NULL,
        total             REAL NOT NULL,
        rembourse         REAL NOT NULL DEFAULT 0,
        reglement         TEXT NOT NULL DEFAULT 'Espèces',
        remise_en_stock   INTEGER NOT NULL DEFAULT 1,
        numero_serie      TEXT,
        motif             TEXT,
        versement_code    TEXT,
        etat              INTEGER NOT NULL DEFAULT 1,
        annule_le         TEXT,
        annule_par        TEXT,
        motif_annulation  TEXT,
        CHECK ((type = 'Client' AND client_code IS NOT NULL) OR (type = 'Fournisseur' AND fournisseur_code IS NOT NULL))
      )
    ''');
    await txn.execute('''
      INSERT INTO retour_v12 (code, date, type, document_code, client_code, magasin_code, utilisateur_code, total,
        rembourse, reglement, motif, versement_code)
      SELECT code, date, 'Client', vente_code, client_code, magasin_code, utilisateur_code, total, rembourse,
        CASE WHEN rembourse > 0 THEN 'Espèces' ELSE 'Avoir' END, motif, versement_code
      FROM retour
    ''');
    await txn.execute('DROP TABLE retour');
    await txn.execute('ALTER TABLE retour_v12 RENAME TO retour');
    await txn.execute('CREATE INDEX idx_retour_document ON retour(document_code)');
    await txn.execute('ALTER TABLE retour_ligne ADD COLUMN prix_achat REAL NOT NULL DEFAULT 0');
    await txn.execute('''
      UPDATE retour_ligne SET prix_achat =
        COALESCE((SELECT p.prix_achat FROM produit p WHERE p.code = retour_ligne.produit_code), 0)
    ''');
  }
}
