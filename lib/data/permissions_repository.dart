import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';

/// Rôles (`role`) et leurs droits (`role_permission`, `role_module`), reliés par code.
class PermissionsRepository {
  const PermissionsRepository(this.db);

  final DatabaseExecutor db;

  Future<Set<Permission>> permissionsDe(String roleCode) async {
    final rows = await db.query(
      'role_permission',
      columns: ['permission'],
      where: 'role_code = ?',
      whereArgs: [roleCode],
    );
    return rows.map((r) => Permission.parCode(r['permission'] as String)).whereType<Permission>().toSet();
  }

  Future<Set<String>> modulesDe(String roleCode) async {
    final rows = await db.query('role_module', columns: ['module_id'], where: 'role_code = ?', whereArgs: [roleCode]);
    return rows.map((r) => r['module_id'] as String).toSet();
  }

  Future<void> remplacerPermissions(String roleCode, Set<Permission> permissions) async {
    await db.delete('role_permission', where: 'role_code = ?', whereArgs: [roleCode]);
    for (final p in permissions) {
      await db.insert('role_permission', {'role_code': roleCode, 'permission': p.code});
    }
  }

  Future<void> remplacerModules(String roleCode, Set<String> modules) async {
    await db.delete('role_module', where: 'role_code = ?', whereArgs: [roleCode]);
    for (final m in modules) {
      await db.insert('role_module', {'role_code': roleCode, 'module_id': m});
    }
  }

  /// Tous les rôles avec leurs droits et le nombre d'utilisateurs rattachés.
  Future<List<Role>> roles() async {
    final rows = await db.rawQuery('''
      SELECT r.*, (SELECT COUNT(*) FROM utilisateur u WHERE u.role_code = r.code) nb FROM role r ORDER BY r.code
    ''');
    return [for (final r in rows) await _role(r)];
  }

  Future<Role?> role(String code) async {
    final rows = await db.rawQuery(
      'SELECT r.*, (SELECT COUNT(*) FROM utilisateur u WHERE u.role_code = r.code) nb FROM role r WHERE r.code = ?',
      [code],
    );
    return rows.isEmpty ? null : _role(rows.first);
  }

  Future<Role> _role(Map<String, Object?> r) async {
    final code = r['code'] as String;
    DateTime? date(Object? v) => DateTime.tryParse((v as String?) ?? '')?.toLocal();
    return Role(
      code: code,
      nom: r['nom'] as String,
      observation: (r['observation'] as String?) ?? '',
      actif: (r['actif'] as int) == 1,
      systeme: (r['systeme'] as int) == 1,
      permissions: await permissionsDe(code),
      modules: await modulesDe(code),
      nbUtilisateurs: r['nb'] as int,
      creeLe: date(r['cree_le']),
      creePar: r['cree_par'] as String?,
      modifieLe: date(r['modifie_le']),
      modifiePar: r['modifie_par'] as String?,
    );
  }

  Future<bool> nomDisponible(String nom, {String? saufCode}) async {
    final rows = await db.query('role', columns: ['code'], where: 'nom = ? COLLATE NOCASE', whereArgs: [nom.trim()]);
    return rows.isEmpty || (saufCode != null && rows.first['code'] == saufCode);
  }

  Future<String> prochainCode() async {
    final rows = await db.query('role', columns: ['code'], orderBy: 'code DESC', limit: 1);
    return CodeGenerator.suivant(CodeGenerator.role, rows.isEmpty ? null : rows.first['code'] as String);
  }

  Future<void> inserer(Role r, {String? par}) => db.insert('role', {
    'code': r.code,
    'nom': r.nom.trim(),
    'observation': r.observation,
    'actif': r.actif ? 1 : 0,
    'cree_par': par,
  });

  Future<void> mettreAJour(String code, Map<String, Object?> valeurs) => db.update(
    'role',
    {...valeurs, 'modifie_le': DateTime.now().toUtc().toIso8601String()},
    where: 'code = ?',
    whereArgs: [code],
  );
}
