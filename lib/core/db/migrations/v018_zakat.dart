import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 18 : écran Zakat du DS v2.2 (§9.15).
/// - Table `zakat` (codes `ZKT`) : année, hawl (début, échéance), stock, liquidités, créances, dettes, capital,
///   nissab, taux, obligatoire, montant, statut (`Brouillon` / `Non payé` / `Payée`), date de paiement,
///   observation, annulation douce (motif, par, date) et audit.
/// - Paramètres zakat (`zakatParam`) : nissab (DA) et taux (%). L'ancien « prix du gramme d'or » devient le nissab
///   (85 g × prix).
class MigrationV018Zakat extends Migration {
  const MigrationV018Zakat();

  @override
  int get version => 18;

  @override
  String get description => 'Zakat DS : calculs enregistrés (ZKT), paramètres nissab et taux';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE zakat (
        code              TEXT PRIMARY KEY NOT NULL,
        annee             INTEGER NOT NULL,
        date_debut_hawl   TEXT NOT NULL,
        date_zakat_due    TEXT NOT NULL,
        stock             REAL NOT NULL DEFAULT 0,
        liquidites        REAL NOT NULL DEFAULT 0,
        creances          REAL NOT NULL DEFAULT 0,
        dettes            REAL NOT NULL DEFAULT 0,
        capital_total     REAL NOT NULL DEFAULT 0,
        nissab            REAL NOT NULL DEFAULT 0,
        taux              REAL NOT NULL DEFAULT 2.5,
        obligatoire       INTEGER NOT NULL DEFAULT 0,
        montant_zakat     REAL NOT NULL DEFAULT 0,
        statut            TEXT NOT NULL DEFAULT 'Brouillon',
        date_paiement     TEXT,
        observation       TEXT,
        actif             INTEGER NOT NULL DEFAULT 1,
        motif_annulation  TEXT,
        annule_par        TEXT,
        date_annulation   TEXT,
        cree_par          TEXT,
        cree_le           TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        modifie_par       TEXT,
        modifie_le        TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await txn.execute('CREATE INDEX idx_zakat_annee ON zakat(annee)');
    final prix = await txn.query('parametre', where: 'cle = ?', whereArgs: ['zakat_prix_gramme_or']);
    final p = prix.isEmpty ? 0.0 : double.tryParse(prix.first['valeur'] as String? ?? '') ?? 0.0;
    if (p > 0) {
      await txn.insert('parametre', {'cle': 'zakat_nissab', 'valeur': (p * 85).toString()});
    }
    await txn.delete('parametre', where: 'cle = ?', whereArgs: ['zakat_prix_gramme_or']);
  }
}
