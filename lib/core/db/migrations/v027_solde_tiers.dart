import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 27 : vue `solde_tiers`, source UNIQUE du solde d'un client ou d'un fournisseur (liste, caisse,
/// situation, alertes, tableau de bord, zakat). Positif = dû par le client / au fournisseur, négatif = avance.
///
/// solde = Σ reste à la pièce (ventes validées : total net − payé hors monnaie ; entrées validées : total)
///       − Σ règlements actifs (versements dans le sens du paiement, avoirs de retour compris)
///       + Σ argent rendu hors retour (versements inverses non verrouillés).
/// Un remboursement de retour (versement inverse verrouillé) et son retour se compensent : aucun n'y entre.
/// La vue ne dépend pas des imputations : un trop-payé ou un avoir non imputé est une avance.
class MigrationV027SoldeTiers extends Migration {
  const MigrationV027SoldeTiers();

  @override
  int get version => 27;

  @override
  String get description => 'Vue solde_tiers (solde unique des clients et fournisseurs)';

  @override
  Future<void> appliquer(Transaction txn) async {
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
        SELECT 'Client' tiers_type, client_code tiers_code, total_net documents, reste du, 0 regle, 0 rendu,
          date dernier
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
