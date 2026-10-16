import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 31 : fiscalité algérienne (audit, point 6).
/// - TVA figée par ligne : `vente_ligne` (taux, HT, TVA collectée) et `achat_ligne` (taux, TVA déductible),
///   prix TTC. Les lignes existantes sont ventilées au taux actuel du produit.
/// - `facture` : factures (FAC) et factures d'avoir (AVO), numérotation continue propre à chaque type, contenu
///   figé (identités fiscales, lignes, récapitulatif TVA, timbre, montant en lettres), scellé et chaîné,
///   jamais modifié ni supprimé.
/// - `ai` (article d'imposition) sur les fiches client et fournisseur.
class MigrationV031Fiscalite extends Migration {
  const MigrationV031Fiscalite();

  @override
  int get version => 31;

  @override
  String get description => 'TVA par ligne, factures et avoirs, article d\'imposition des tiers';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final c in ['taux_tva', 'montant_ht', 'montant_tva']) {
      await txn.execute('ALTER TABLE vente_ligne ADD COLUMN $c REAL NOT NULL DEFAULT 0');
    }
    for (final c in ['taux_tva', 'montant_tva']) {
      await txn.execute('ALTER TABLE achat_ligne ADD COLUMN $c REAL NOT NULL DEFAULT 0');
    }
    // Ventilation des lignes existantes au taux actuel du produit (le contenu scellé v1 n'en dépend pas).
    await txn.execute('DROP TRIGGER IF EXISTS vente_ligne_sans_modification');
    await txn.execute('''
      UPDATE vente_ligne SET taux_tva = COALESCE((SELECT tva_pct FROM produit p WHERE p.code = produit_code), 0)
    ''');
    await txn.execute('''
      UPDATE vente_ligne SET montant_ht = ROUND(total / (1 + taux_tva / 100.0), 2),
        montant_tva = ROUND(total - ROUND(total / (1 + taux_tva / 100.0), 2), 2)
    ''');
    await txn.execute('''
      CREATE TRIGGER vente_ligne_sans_modification BEFORE UPDATE ON vente_ligne
      BEGIN SELECT RAISE(ABORT, 'Ticket scellé : modification interdite'); END
    ''');
    await txn.execute('''
      UPDATE achat_ligne SET taux_tva = COALESCE((SELECT tva_pct FROM produit p WHERE p.code = produit_code), 0)
    ''');
    await txn.execute('UPDATE achat_ligne SET montant_tva = ROUND(total * taux_tva / (100.0 + taux_tva), 2)');

    await txn.execute('''
      CREATE TABLE facture (
        code              TEXT PRIMARY KEY NOT NULL,
        type              TEXT NOT NULL,
        date              TEXT NOT NULL,
        vente_code        TEXT NOT NULL REFERENCES vente(code),
        retour_code       TEXT REFERENCES retour(code),
        facture_origine   TEXT REFERENCES facture(code),
        client_code       TEXT NOT NULL,
        vendeur           TEXT NOT NULL,
        client            TEXT NOT NULL,
        lignes            TEXT NOT NULL,
        total_ht          REAL NOT NULL,
        total_tva         REAL NOT NULL,
        total_ttc         REAL NOT NULL,
        timbre            REAL NOT NULL DEFAULT 0,
        net_a_payer       REAL NOT NULL,
        mode_paiement     TEXT NOT NULL,
        montant_lettres   TEXT NOT NULL,
        utilisateur_code  TEXT NOT NULL,
        motif             TEXT,
        hash              TEXT NOT NULL,
        hash_precedent    TEXT NOT NULL
      )
    ''');
    await txn.execute('CREATE INDEX idx_facture_vente ON facture(vente_code, type)');
    await txn.execute('CREATE INDEX idx_facture_date ON facture(date)');
    await txn.execute('''
      CREATE TRIGGER facture_sans_modification BEFORE UPDATE ON facture
      BEGIN SELECT RAISE(ABORT, 'Facture émise : modification interdite (émettre un avoir)'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER facture_sans_suppression BEFORE DELETE ON facture
      BEGIN SELECT RAISE(ABORT, 'Facture émise : suppression interdite (émettre un avoir)'); END
    ''');

    for (final t in ['client', 'fournisseur']) {
      await txn.execute("ALTER TABLE $t ADD COLUMN ai TEXT NOT NULL DEFAULT ''");
    }
  }
}
