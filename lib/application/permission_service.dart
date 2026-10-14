import 'package:sqflite_common/sqlite_api.dart';

import '../data/permissions_repository.dart';
import '../domain/permissions.dart';

/// Grille complète rôles × permissions × modules.
class GrilleRoles {
  const GrilleRoles({required this.permissions, required this.modules});

  /// Permissions accordées par rôle.
  final Map<String, Set<Permission>> permissions;

  /// Modules accessibles par rôle (l'Admin n'y figure pas : accès total).
  final Map<String, Set<String>> modules;

  GrilleRoles basculerPermission(String role, Permission p) {
    final copie = {
      for (final e in permissions.entries) e.key: {...e.value},
    };
    final s = copie.putIfAbsent(role, () => {});
    s.contains(p) ? s.remove(p) : s.add(p);
    return GrilleRoles(permissions: copie, modules: modules);
  }

  GrilleRoles basculerModule(String role, String moduleId) {
    final copie = {
      for (final e in modules.entries) e.key: {...e.value},
    };
    final s = copie.putIfAbsent(role, () => {});
    s.contains(moduleId) ? s.remove(moduleId) : s.add(moduleId);
    return GrilleRoles(permissions: permissions, modules: copie);
  }
}

/// Lecture / écriture de la grille des rôles. L'Admin garde toujours tous ses droits.
class PermissionService {
  const PermissionService(this.db);

  final Database db;

  Future<GrilleRoles> lireGrille() async {
    final repo = PermissionsRepository(db);
    final permissions = <String, Set<Permission>>{};
    final modules = <String, Set<String>>{};
    for (final role in Roles.tous) {
      permissions[role] = await repo.permissionsDe(role);
      if (role != Roles.admin) modules[role] = await repo.modulesDe(role);
    }
    return GrilleRoles(permissions: permissions, modules: modules);
  }

  /// Enregistre la grille entière dans UNE transaction. Les droits de l'Admin sont forcés au complet.
  Future<void> enregistrerGrille(GrilleRoles grille) async {
    await db.transaction((txn) async {
      final repo = PermissionsRepository(txn);
      for (final role in Roles.tous) {
        final perms = role == Roles.admin ? Permission.values.toSet() : (grille.permissions[role] ?? {});
        await repo.remplacerPermissions(role, perms);
        if (role != Roles.admin) {
          await repo.remplacerModules(role, grille.modules[role] ?? {});
        }
      }
    });
  }
}
