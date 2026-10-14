import 'package:sqflite_common/sqlite_api.dart';

import '../domain/permissions.dart';

class PermissionsRepository {
  const PermissionsRepository(this.db);

  final DatabaseExecutor db;

  Future<Set<Permission>> permissionsDe(String role) async {
    final rows = await db.query('role_permission', columns: ['permission'], where: 'role = ?', whereArgs: [role]);
    return rows.map((r) => Permission.parCode(r['permission'] as String)).whereType<Permission>().toSet();
  }

  Future<Set<String>> modulesDe(String role) async {
    final rows = await db.query('role_module', columns: ['module_id'], where: 'role = ?', whereArgs: [role]);
    return rows.map((r) => r['module_id'] as String).toSet();
  }

  Future<void> remplacerPermissions(String role, Set<Permission> permissions) async {
    await db.delete('role_permission', where: 'role = ?', whereArgs: [role]);
    for (final p in permissions) {
      await db.insert('role_permission', {'role': role, 'permission': p.code});
    }
  }

  Future<void> remplacerModules(String role, Set<String> modules) async {
    await db.delete('role_module', where: 'role = ?', whereArgs: [role]);
    for (final m in modules) {
      await db.insert('role_module', {'role': role, 'module_id': m});
    }
  }
}
