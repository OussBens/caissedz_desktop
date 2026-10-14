import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/licence.dart';
import '../domain/permissions.dart';

class LicenceRepository {
  const LicenceRepository(this.db);

  final DatabaseExecutor db;

  Future<Licence> lire() async {
    final rows = await db.query('licence', where: 'id = 1');
    if (rows.isEmpty) return Licence.aucune;
    final r = rows.first;
    return Licence(
      niveau: NiveauLicence.parValeur(r['niveau'] as String?),
      cle: r['cle'] as String?,
      demo: (r['demo'] as int) == 1,
      activeeLe: DateTime.tryParse((r['activee_le'] as String?) ?? ''),
    );
  }

  Future<void> ecrire(Licence licence) async {
    await db.insert(
      'licence',
      {
        'id': 1,
        'cle': licence.cle,
        'niveau': licence.niveau!.stocke,
        'demo': licence.demo ? 1 : 0,
        'activee_le': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
