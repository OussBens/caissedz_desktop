import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 9 : écrans de modules du DS v2.2 (phase D).
///
/// - Tiers (§7.6) : wilaya, type, activité, fax, NIF / NIS / N° RC, banque, RIB, observation.
/// - Versements (§7.7) : type (référentiel `typeVersement`), annulation douce (`etat`, date, auteur, motif).
/// - Référentiel (`donnees/ref.js`) : valeurs stockées « Perte / vol » et « En Attente ».
class MigrationV009EcransDs extends Migration {
  const MigrationV009EcransDs();

  static const List<String> colonnesTiers = [
    'wilaya',
    'type',
    'activite',
    'fax',
    'nif',
    'nis',
    'nrc',
    'banque',
    'rib',
    'observation',
  ];

  @override
  int get version => 9;

  @override
  String get description => 'Écrans DS v2.2 : fiches tiers complètes, valeurs du référentiel';

  @override
  Future<void> appliquer(Transaction txn) async {
    for (final table in ['client', 'fournisseur']) {
      for (final colonne in colonnesTiers) {
        await txn.execute("ALTER TABLE $table ADD COLUMN $colonne TEXT NOT NULL DEFAULT ''");
      }
    }
    await txn.execute("ALTER TABLE versement ADD COLUMN type TEXT NOT NULL DEFAULT 'Paiement'");
    await txn.execute('ALTER TABLE versement ADD COLUMN etat INTEGER NOT NULL DEFAULT 1');
    for (final colonne in ['annule_le', 'annule_par', 'motif_annulation']) {
      await txn.execute('ALTER TABLE versement ADD COLUMN $colonne TEXT');
    }
    await txn.update('versement', {'type': 'Remboursement'}, where: 'retour_code IS NOT NULL');
    await txn.update('client', {'type': 'Consommateur'});
    await txn.update('fournisseur', {'type': 'Grossiste'});
    await txn.update('sortie_stock', {'motif': 'Perte / vol'}, where: 'motif = ?', whereArgs: ['Perte/vol']);
    await txn.update('besoin', {'statut': 'En Attente'}, where: 'statut = ?', whereArgs: ['En attente']);
  }
}
