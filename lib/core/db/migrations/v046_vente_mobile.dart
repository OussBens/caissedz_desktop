import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 46 : une vente du téléphone n'est enregistrée qu'une fois.
///
/// `vente_mobile` : l'identifiant que CaisseDZ Scan envoie avec le panier encaissé, et la vente qu'il a donnée. Le
/// téléphone qui n'a pas eu la réponse à temps renvoie le même identifiant : la vente déjà enregistrée lui est
/// renvoyée au lieu d'en enregistrer une seconde.
class MigrationV046VenteMobile extends Migration {
  const MigrationV046VenteMobile();

  @override
  int get version => 46;

  @override
  String get description => 'Ventes du téléphone enregistrées une seule fois';

  @override
  Future<void> appliquer(Transaction txn) => txn.execute('''
    CREATE TABLE vente_mobile (
      identifiant  TEXT PRIMARY KEY NOT NULL,
      vente_code   TEXT NOT NULL REFERENCES vente(code),
      cree_le      TEXT NOT NULL
    )
  ''');
}
