import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 33 : solde initial (reprise) des clients et fournisseurs, intégré à la vue `solde_tiers`.
///
/// Positif = dû par le client / au fournisseur, négatif = avance. Il entre dans le solde comme un document
/// ouvert (imputable par les versements, le plus ancien d'abord) : `versement_imputation.document_type =
/// 'solde_initial'`, `document_code` = code du tiers.
class MigrationV033SoldeInitial extends Migration {
  const MigrationV033SoldeInitial();

  @override
  int get version => 33;

  @override
  String get description => 'Solde initial des clients et fournisseurs';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final t in ['client', 'fournisseur']) {
      await txn.execute('ALTER TABLE $t ADD COLUMN solde_initial REAL NOT NULL DEFAULT 0');
    }
    await txn.execute('DROP VIEW IF EXISTS solde_tiers');
    await txn.execute('''
      CREATE VIEW solde_tiers AS
      SELECT tiers_type, tiers_code,
        ROUND(SUM(documents), 2) documents,
        ROUND(SUM(du), 2) du,
        ROUND(SUM(regle), 2) regle,
        ROUND(SUM(rendu), 2) rendu,
        ROUND(SUM(du) - SUM(regle) + SUM(rendu), 2) solde,
        MAX(dernier) dernier
      FROM (
        SELECT 'Client' tiers_type, code tiers_code, 0 documents, solde_initial du, 0 regle, 0 rendu, NULL dernier
        FROM client WHERE solde_initial <> 0
        UNION ALL
        SELECT 'Fournisseur', code, 0, solde_initial, 0, 0, NULL
        FROM fournisseur WHERE solde_initial <> 0
        UNION ALL
        SELECT 'Client', client_code, total_net, reste, 0, 0, date
        FROM vente WHERE statut = 'Validée'
        UNION ALL
        SELECT 'Fournisseur', fournisseur_code, total, total, 0, 0, date
        FROM achat WHERE statut = 'Validé'
        UNION ALL
        SELECT tiers_type, tiers_code, 0, 0,
          CASE WHEN sens = CASE tiers_type WHEN 'Client' THEN 'Encaissement' ELSE 'Décaissement' END
            THEN montant ELSE 0 END,
          CASE WHEN sens <> CASE tiers_type WHEN 'Client' THEN 'Encaissement' ELSE 'Décaissement' END
            AND verrouille = 0 THEN montant ELSE 0 END,
          NULL
        FROM versement WHERE etat = 1
      )
      GROUP BY tiers_type, tiers_code
    ''');
  }
}
