import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 36 : téléphones appairés à ce poste (application CaisseDZ Scan).
///
/// Un téléphone s'appaire en scannant le QR code du poste (même réseau local) ; il reçoit un jeton
/// d'appareil dont seule l'empreinte SHA-256 est gardée ici. L'administrateur peut le révoquer.
class MigrationV036AppareilsMobiles extends Migration {
  const MigrationV036AppareilsMobiles();

  @override
  int get version => 36;

  @override
  String get description => 'Téléphones appairés (CaisseDZ Scan)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE appareil_mobile (
        code           TEXT PRIMARY KEY NOT NULL,
        nom            TEXT NOT NULL,
        plateforme     TEXT NOT NULL DEFAULT '',
        jeton_hash     TEXT NOT NULL,
        cree_le        TEXT NOT NULL,
        cree_par       TEXT,
        dernier_acces  TEXT,
        dernier_utilisateur TEXT,
        actif          INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }
}
