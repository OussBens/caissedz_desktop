import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 37 : chaque téléphone appairé appartient à un utilisateur.
///
/// Chaque utilisateur autorisé affiche son propre QR code ; le téléphone qui le scanne est connecté avec
/// ce compte (sans mot de passe sur le réseau) et s'y reconnecte ensuite avec son jeton d'appareil.
/// Les téléphones appairés avant (sans utilisateur) doivent scanner un nouveau QR code.
class MigrationV037AppareilUtilisateur extends Migration {
  const MigrationV037AppareilUtilisateur();

  @override
  int get version => 37;

  @override
  String get description => 'Téléphones appairés par utilisateur (CaisseDZ Scan)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.delete('appareil_mobile');
    await txn.execute('ALTER TABLE appareil_mobile ADD COLUMN utilisateur_code TEXT REFERENCES utilisateur(code)');
  }
}
