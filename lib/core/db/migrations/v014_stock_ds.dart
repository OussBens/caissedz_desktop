import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 14 : écrans Stock, Sorties, Magasins et Besoins du DS v2.2.
/// - Sorties et transferts : annulation douce (état, par, motif, date) ; prix d'achat figé sur les lignes de sortie.
/// - Magasins : téléphone, responsable, observation.
/// - Besoins : la liste de besoins devient un document fournisseur (§7, `besionList`) avec ses lignes
///   (produit, quantité, prix estimé), une date de livraison souhaitée et une annulation douce. Chaque ancien
///   besoin (un produit) devient une liste d'une ligne rattachée au fournisseur système.
class MigrationV014StockDs extends Migration {
  const MigrationV014StockDs();

  @override
  int get version => 14;

  @override
  String get description => 'Stock DS : annulation des sorties / transferts, magasins, listes de besoins';

  static const _annulation = [
    'actif INTEGER NOT NULL DEFAULT 1',
    'annule_par TEXT',
    'motif_annulation TEXT',
    'date_annulation TEXT',
  ];

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final table in ['sortie_stock', 'transfert_stock']) {
      for (final c in _annulation) {
        await txn.execute('ALTER TABLE $table ADD COLUMN $c');
      }
    }
    await txn.execute('ALTER TABLE sortie_stock_ligne ADD COLUMN prix REAL NOT NULL DEFAULT 0');
    await txn.execute('''
      UPDATE sortie_stock_ligne SET prix = COALESCE(
        (SELECT p.prix_achat FROM produit p WHERE p.code = sortie_stock_ligne.produit_code), 0)
    ''');
    await txn.execute("ALTER TABLE magasin ADD COLUMN telephone TEXT NOT NULL DEFAULT ''");
    await txn.execute('ALTER TABLE magasin ADD COLUMN responsable_code TEXT REFERENCES utilisateur(code)');
    await txn.execute("ALTER TABLE magasin ADD COLUMN observation TEXT NOT NULL DEFAULT ''");

    final anciens = await txn.query('besoin');
    await txn.execute('DROP TABLE besoin');
    await txn.execute('''
      CREATE TABLE besoin (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        fournisseur_code  TEXT NOT NULL REFERENCES fournisseur(code),
        statut            TEXT NOT NULL DEFAULT 'En Attente',
        date_livraison    TEXT,
        observation       TEXT,
        utilisateur_code  TEXT NOT NULL,
        actif             INTEGER NOT NULL DEFAULT 1,
        annule_par        TEXT,
        motif_annulation  TEXT,
        date_annulation   TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE besoin_ligne (
        besoin_code   TEXT NOT NULL REFERENCES besoin(code) ON DELETE CASCADE,
        produit_code  TEXT NOT NULL REFERENCES produit(code),
        quantite      REAL NOT NULL,
        prix          REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (besoin_code, produit_code)
      )
    ''');
    for (final b in anciens) {
      final produit = b['produit_code']! as String;
      final prix = await txn.query('produit', columns: ['prix_achat'], where: 'code = ?', whereArgs: [produit]);
      await txn.insert('besoin', {
        'code': b['code'],
        'date': b['date'],
        'fournisseur_code': 'FOR0000',
        'statut': b['statut'],
        'observation': b['commentaire'],
        'utilisateur_code': b['utilisateur_code'],
      });
      await txn.insert('besoin_ligne', {
        'besoin_code': b['code'],
        'produit_code': produit,
        'quantite': b['quantite'],
        'prix': prix.isEmpty ? 0 : prix.first['prix_achat'],
      });
    }
  }
}
