import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';
import 'v020_audit.dart';

/// Version 22 : colonnes d'audit (créé / modifié le / par) et leurs déclencheurs sur les tables qui ne les avaient
/// pas encore (sessions, mouvements de caisse et de stock, bons de réception, zakat) : tous les modèles affichés dans
/// un tableau portent ainsi les quatre champs. Les clôtures, immuables, tirent leur création de `date` et
/// `utilisateur_code` (aucun déclencheur ne peut les mettre à jour).
class MigrationV022AuditComplement extends Migration {
  const MigrationV022AuditComplement();

  static const List<String> tables = [
    'session_caisse',
    'mouvement_caisse',
    'mouvement_stock',
    'bon_reception',
    'zakat',
  ];

  @override
  int get version => 22;

  @override
  String get description => "Colonnes d'audit des sessions, mouvements, bons et zakat";

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final t in tables) {
      await MigrationV020Audit.ajouterAudit(txn, t);
    }
  }
}
