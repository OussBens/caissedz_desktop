import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/zakat.dart';

class ZakatRepository {
  const ZakatRepository(this.db);

  final DatabaseExecutor db;

  Future<List<Zakat>> tous() async =>
      (await db.query('zakat', orderBy: 'annee DESC, code DESC')).map(Zakat.depuisLigne).toList();

  Future<Zakat?> parCode(String code) async {
    final rows = await db.query('zakat', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Zakat.depuisLigne(rows.first);
  }

  Future<String> prochainCode() async {
    final rows = await db.query('zakat', columns: ['code'], orderBy: CodeGenerator.ordreDecroissant, limit: 1);
    return CodeGenerator.suivant(CodeGenerator.zakat, rows.isEmpty ? null : rows.first['code'] as String);
  }

  Future<void> inserer(Zakat z, {required String par}) => db.insert('zakat', {...z.versLigne(), 'cree_par': par});

  Future<void> mettreAJour(Zakat z, {required String par}) => db.update(
    'zakat',
    {...z.versLigne()..remove('code'), 'modifie_par': par, 'modifie_le': DateTime.now().toUtc().toIso8601String()},
    where: 'code = ?',
    whereArgs: [z.code],
  );

  Future<void> annuler(String code, {required String par, required String motif}) => db.update(
    'zakat',
    {
      'actif': 0,
      'motif_annulation': motif,
      'annule_par': par,
      'date_annulation': DateTime.now().toUtc().toIso8601String(),
      'modifie_par': par,
      'modifie_le': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'code = ?',
    whereArgs: [code],
  );
}
