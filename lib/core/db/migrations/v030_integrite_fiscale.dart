import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 30 : intégrité fiscale (§12.3, audit M11 / M12).
/// - `journal_fiscal` : événements fiscaux (ventes, annulations, retours, clôtures Z, factures) scellés SHA-256
///   et chaînés, en ajout seul.
/// - `vente.version_scellement` : 2 pour les nouveaux tickets (coût figé et unités scellés, quantités à
///   3 décimales) ; 1 pour les tickets existants, vérifiés avec leur forme d'origine.
/// - Déclencheurs d'immuabilité : colonnes scellées de `vente`, lignes et paiements de vente, journal de stock ;
///   une vente ne passe à « Annulée » qu'avec son événement d'annulation au journal fiscal, et jamais en retour.
/// - Caisse « Coffre » (`CIS0001`, `caisse.coffre`) : reçoit les espèces retirées à la fermeture des sessions et
///   fournit le fond de caisse des ouvertures ; la remise en banque est un transfert vers une caisse Compte.
class MigrationV030IntegriteFiscale extends Migration {
  const MigrationV030IntegriteFiscale();

  @override
  int get version => 30;

  @override
  String get description => 'Journal fiscal chaîné, immuabilité des ventes et du stock, caisse Coffre';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE journal_fiscal (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        date              TEXT NOT NULL,
        type              TEXT NOT NULL,
        reference_code    TEXT NOT NULL,
        caisse_code       TEXT,
        utilisateur_code  TEXT NOT NULL,
        montant           REAL NOT NULL DEFAULT 0,
        contenu           TEXT NOT NULL,
        hash              TEXT NOT NULL,
        hash_precedent    TEXT NOT NULL
      )
    ''');
    await txn.execute('CREATE INDEX idx_journal_fiscal_ref ON journal_fiscal(type, reference_code)');
    await txn.execute('''
      CREATE TRIGGER journal_fiscal_sans_modification BEFORE UPDATE ON journal_fiscal
      BEGIN SELECT RAISE(ABORT, 'Journal fiscal : modification interdite'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER journal_fiscal_sans_suppression BEFORE DELETE ON journal_fiscal
      BEGIN SELECT RAISE(ABORT, 'Journal fiscal : suppression interdite'); END
    ''');

    await txn.execute('ALTER TABLE vente ADD COLUMN version_scellement INTEGER NOT NULL DEFAULT 1');
    await txn.execute('''
      CREATE TRIGGER vente_scellee BEFORE UPDATE OF code, date, session_code, caisse_code, magasin_code,
        client_code, utilisateur_code, total_brut, total_remise, total_net, verse, reste, points_gagnes,
        points_utilises, hash, hash_precedent, version_scellement ON vente
      BEGIN SELECT RAISE(ABORT, 'Ticket scellé : modification interdite'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER vente_statut BEFORE UPDATE OF statut ON vente
      WHEN NEW.statut <> OLD.statut AND (OLD.statut = 'Annulée' OR NOT EXISTS (
        SELECT 1 FROM journal_fiscal WHERE type = 'ANNULATION_VENTE' AND reference_code = NEW.code))
      BEGIN SELECT RAISE(ABORT, 'Ticket scellé : annulation sans événement fiscal'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER vente_sans_suppression BEFORE DELETE ON vente
      BEGIN SELECT RAISE(ABORT, 'Ticket scellé : suppression interdite'); END
    ''');
    for (final t in ['vente_ligne', 'vente_paiement']) {
      await txn.execute('''
        CREATE TRIGGER ${t}_sans_modification BEFORE UPDATE ON $t
        BEGIN SELECT RAISE(ABORT, 'Ticket scellé : modification interdite'); END
      ''');
      await txn.execute('''
        CREATE TRIGGER ${t}_sans_suppression BEFORE DELETE ON $t
        BEGIN SELECT RAISE(ABORT, 'Ticket scellé : suppression interdite'); END
      ''');
    }
    await txn.execute('''
      CREATE TRIGGER mouvement_stock_sans_suppression BEFORE DELETE ON mouvement_stock
      BEGIN SELECT RAISE(ABORT, 'Journal de stock : suppression interdite'); END
    ''');
    await txn.execute('''
      CREATE TRIGGER mouvement_stock_sans_modification
      BEFORE UPDATE OF date, produit_code, magasin_code, type, quantite, nombre ON mouvement_stock
      BEGIN SELECT RAISE(ABORT, 'Journal de stock : modification interdite'); END
    ''');

    await txn.execute('ALTER TABLE caisse ADD COLUMN coffre INTEGER NOT NULL DEFAULT 0');
    await txn.execute('''
      INSERT OR IGNORE INTO caisse (code, nom, type, magasin_code, actif, systeme, coffre)
      VALUES ('CIS0001', 'Coffre', 'Physique', NULL, 1, 0, 1)
    ''');
  }
}
