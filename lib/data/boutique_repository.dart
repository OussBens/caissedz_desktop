import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/boutique.dart';

class BoutiqueRepository {
  const BoutiqueRepository(this.db);

  final DatabaseExecutor db;

  Future<Boutique?> lire() async {
    final rows = await db.query('boutique', where: 'id = 1');
    return rows.isEmpty ? null : Boutique.depuisLigne(rows.first);
  }

  Future<void> ecrire(Boutique b) => db.insert('boutique', b.versLigne(), conflictAlgorithm: ConflictAlgorithm.replace);
}
