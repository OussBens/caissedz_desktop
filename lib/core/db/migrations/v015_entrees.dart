import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 15 : écran Entrées du DS v2.2 (§7.5, §9.6).
/// - Entrées (bons d'achat) : annulation douce (par, motif, date) et liste de besoins d'origine.
/// - `bon_reception` : file d'attente des bons (photo ou PDF) lus par l'IA ; statut `Reçu` → `Traité`
///   (entrée créée) ou `Erreur` (lecture impossible), lignes détectées conservées pour le traitement.
class MigrationV015Entrees extends Migration {
  const MigrationV015Entrees();

  @override
  int get version => 15;

  @override
  String get description => 'Entrées DS : annulation douce des entrées, bons de réception IA';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final c in ['annule_par TEXT', 'motif_annulation TEXT', 'date_annulation TEXT', 'besoin_code TEXT']) {
      await txn.execute('ALTER TABLE achat ADD COLUMN $c');
    }
    await txn.execute('''
      CREATE TABLE bon_reception (
        code                 TEXT PRIMARY KEY NOT NULL,
        date_reception       TEXT NOT NULL,
        fichier              TEXT NOT NULL,
        chemin_photo         TEXT,
        fournisseur_code     TEXT REFERENCES fournisseur(code),
        fournisseur_detecte  TEXT,
        num_bon              TEXT,
        lignes_json          TEXT,
        nb_lignes            INTEGER NOT NULL DEFAULT 0,
        statut               TEXT NOT NULL DEFAULT 'Reçu',
        commentaire          TEXT,
        utilisateur_code     TEXT NOT NULL,
        traite_par_code      TEXT,
        achat_code           TEXT REFERENCES achat(code)
      )
    ''');
  }
}
