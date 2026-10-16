import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/tiers.dart';

/// Accès SQL aux clients.
class ClientRepository {
  const ClientRepository(this.db);

  final DatabaseExecutor db;

  Future<String> prochainCode() async {
    final rows = await db.query('client', columns: ['code'], orderBy: CodeGenerator.ordreDecroissant, limit: 1);
    return CodeGenerator.suivant(CodeGenerator.client, rows.isEmpty ? null : rows.first['code'] as String);
  }

  Future<List<Client>> tous({String? recherche, bool actifsSeulement = false}) async {
    final where = <String>[];
    final args = <Object>[];
    if (recherche != null && recherche.trim().isNotEmpty) {
      where.add('(nom LIKE ? OR code LIKE ? OR telephone LIKE ?)');
      final r = '%${recherche.trim()}%';
      args.addAll([r, r, r]);
    }
    if (actifsSeulement) where.add('actif = 1');
    final rows = await db.query(
      'client',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'code',
    );
    return rows.map(Client.depuisLigne).toList();
  }

  Future<Client?> parCode(String code) async {
    final rows = await db.query('client', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Client.depuisLigne(rows.first);
  }

  Future<void> inserer(Client c) => db.insert('client', c.versLigne());
  Future<void> mettreAJour(Client c) => db.update(
    'client',
    c.versLigne()
      ..remove('code')
      ..remove('systeme'),
    where: 'code = ?',
    whereArgs: [c.code],
  );
}
