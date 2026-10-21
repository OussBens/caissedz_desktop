import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';
import 'v020_audit.dart';

/// Version 34 : documents commerciaux.
/// - `document_client` (+ lignes) : devis DEV, facture proforma PRO, bon de commande client BCC ; prix TTC,
///   TVA figée par ligne ; un devis transformé garde le lien `origine_code` sur la commande.
/// - `bon_livraison` (+ lignes) : bon de livraison LIV, distinct du ticket, lié à la vente qui sort le stock
///   (livraison d'une commande, partielle ou totale, ou BL d'une vente de caisse) ; annulé avec sa vente.
/// - `commande_fournisseur` (+ lignes) : bon de commande fournisseur BCF ; réceptions partielles = entrées
///   (`achat.commande_code`), quantités reçues calculées ; reliquat soldé à la main.
class MigrationV034DocumentsCommerciaux extends Migration {
  const MigrationV034DocumentsCommerciaux();

  @override
  int get version => 34;

  @override
  String get description => 'Devis, proforma, commandes clients, bons de livraison, commandes fournisseurs';

  static const String _annulation = '''
        actif             INTEGER NOT NULL DEFAULT 1,
        annule_par        TEXT,
        motif_annulation  TEXT,
        date_annulation   TEXT''';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE document_client (
        code              TEXT PRIMARY KEY NOT NULL,
        type              TEXT NOT NULL,
        date              TEXT NOT NULL,
        client_code       TEXT NOT NULL REFERENCES client(code),
        validite          TEXT,
        statut            TEXT NOT NULL DEFAULT 'En cours',
        origine_code      TEXT REFERENCES document_client(code),
        observation       TEXT,
        utilisateur_code  TEXT NOT NULL,
$_annulation
      )
    ''');
    await txn.execute('''
      CREATE TABLE document_client_ligne (
        document_code  TEXT NOT NULL REFERENCES document_client(code) ON DELETE CASCADE,
        ordre          INTEGER NOT NULL,
        produit_code   TEXT NOT NULL REFERENCES produit(code),
        designation    TEXT NOT NULL,
        quantite       REAL NOT NULL,
        prix_unitaire  REAL NOT NULL,
        taux_tva       REAL NOT NULL DEFAULT 0,
        montant_ht     REAL NOT NULL DEFAULT 0,
        montant_tva    REAL NOT NULL DEFAULT 0,
        total          REAL NOT NULL,
        PRIMARY KEY (document_code, ordre)
      )
    ''');
    await txn.execute('''
      CREATE TABLE bon_livraison (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        commande_code     TEXT REFERENCES document_client(code),
        vente_code        TEXT NOT NULL REFERENCES vente(code),
        client_code       TEXT NOT NULL REFERENCES client(code),
        magasin_code      TEXT NOT NULL,
        utilisateur_code  TEXT NOT NULL,
        observation       TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE bon_livraison_ligne (
        livraison_code  TEXT NOT NULL REFERENCES bon_livraison(code) ON DELETE CASCADE,
        ordre           INTEGER NOT NULL,
        ordre_commande  INTEGER,
        produit_code    TEXT NOT NULL REFERENCES produit(code),
        designation     TEXT NOT NULL,
        quantite        REAL NOT NULL,
        PRIMARY KEY (livraison_code, ordre)
      )
    ''');
    await txn.execute('''
      CREATE TABLE commande_fournisseur (
        code              TEXT PRIMARY KEY NOT NULL,
        date              TEXT NOT NULL,
        fournisseur_code  TEXT NOT NULL REFERENCES fournisseur(code),
        magasin_code      TEXT NOT NULL,
        date_livraison    TEXT,
        besoin_code       TEXT,
        soldee            INTEGER NOT NULL DEFAULT 0,
        observation       TEXT,
        utilisateur_code  TEXT NOT NULL,
$_annulation
      )
    ''');
    await txn.execute('''
      CREATE TABLE commande_fournisseur_ligne (
        commande_code  TEXT NOT NULL REFERENCES commande_fournisseur(code) ON DELETE CASCADE,
        ordre          INTEGER NOT NULL,
        produit_code   TEXT NOT NULL REFERENCES produit(code),
        designation    TEXT NOT NULL,
        quantite       REAL NOT NULL,
        prix           REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (commande_code, ordre)
      )
    ''');
    await txn.execute('ALTER TABLE achat ADD COLUMN commande_code TEXT REFERENCES commande_fournisseur(code)');
    await txn.execute('CREATE INDEX idx_livraison_commande ON bon_livraison(commande_code)');
    await txn.execute('CREATE INDEX idx_livraison_vente ON bon_livraison(vente_code)');
    await txn.execute('CREATE INDEX idx_achat_commande ON achat(commande_code)');
    for (final t in ['document_client', 'bon_livraison', 'commande_fournisseur']) {
      await MigrationV020Audit.ajouterAudit(txn, t);
    }
  }
}
