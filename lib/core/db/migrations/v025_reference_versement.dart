import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 25 : complément de la v24 (codes `ENT`). Le paiement immédiat d'une entrée est retrouvé par
/// `versement.reference = code de l'entrée` : les références (et commentaires « Paiement SS… ») des versements
/// fournisseurs d'avant la v24 passent aussi en `ENT`, sinon modifier une ancienne entrée créerait un 2ᵉ paiement
/// et l'annuler laisserait le paiement d'origine actif.
class MigrationV025ReferenceVersement extends Migration {
  const MigrationV025ReferenceVersement();

  @override
  int get version => 25;

  @override
  String get description => 'Références des paiements d\'entrées : ENT au lieu de SS';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      UPDATE versement SET reference = 'ENT' || substr(reference, 3)
      WHERE tiers_type = 'Fournisseur' AND reference GLOB 'SS[0-9]*'
    ''');
    await txn.execute('''
      UPDATE versement SET commentaire = 'Paiement ENT' || substr(commentaire, 12)
      WHERE tiers_type = 'Fournisseur' AND commentaire GLOB 'Paiement SS[0-9]*'
    ''');
  }
}
