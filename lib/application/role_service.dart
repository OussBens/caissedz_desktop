import 'package:sqflite_common/sqlite_api.dart';

import '../data/historique_repository.dart';
import '../data/permissions_repository.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';

enum ErreurRole { roleInconnu, nomObligatoire, nomPris, roleSysteme, aucunModule, utilisateursRattaches, dejaInactif }

class RoleException implements Exception {
  const RoleException(this.erreur);
  final ErreurRole erreur;
  @override
  String toString() => 'RoleException($erreur)';
}

/// Rôles (§6.2, §9.12) : nom unique, modules accessibles et permissions spéciales. Le rôle Admin est un rôle
/// système : accès complet, non modifiable, non désactivable.
class RoleService {
  const RoleService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  PermissionsRepository get _repo => PermissionsRepository(db);

  Future<List<Role>> roles() => _repo.roles();

  Future<String> prochainCode() => _repo.prochainCode();

  Future<Role> creer({
    required String nom,
    String observation = '',
    required Set<String> modules,
    required Set<Permission> permissions,
  }) => db.transaction((txn) async {
    final repo = PermissionsRepository(txn);
    await _valider(repo, nom, modules);
    final code = await repo.prochainCode();
    await repo.inserer(
      Role(code: code, nom: nom, observation: observation.trim()),
      par: utilisateurCode,
    );
    await repo.remplacerModules(code, modules);
    await repo.remplacerPermissions(code, permissions);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Création',
      entite: 'role',
      entiteCode: code,
      detail: nom.trim(),
    );
    return (await repo.role(code))!;
  });

  /// Modifie un rôle (les utilisateurs concernés voient leurs accès changer à la prochaine connexion).
  Future<Role> modifier(
    String code, {
    required String nom,
    String observation = '',
    bool actif = true,
    required Set<String> modules,
    required Set<Permission> permissions,
  }) => db.transaction((txn) async {
    final repo = PermissionsRepository(txn);
    final r = await repo.role(code);
    if (r == null) throw const RoleException(ErreurRole.roleInconnu);
    if (r.systeme) throw const RoleException(ErreurRole.roleSysteme);
    await _valider(repo, nom, modules, saufCode: code);
    if (!actif && r.actif && r.nbUtilisateurs > 0) throw const RoleException(ErreurRole.utilisateursRattaches);
    await repo.mettreAJour(code, {
      'nom': nom.trim(),
      'observation': observation.trim(),
      'actif': actif ? 1 : 0,
      'modifie_par': utilisateurCode,
    });
    await repo.remplacerModules(code, modules);
    await repo.remplacerPermissions(code, permissions);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Modification',
      entite: 'role',
      entiteCode: code,
      detail: nom.trim(),
    );
    return (await repo.role(code))!;
  });

  /// Motif de blocage de la désactivation, ou `null`.
  ErreurRole? blocageDesactivation(Role r) {
    if (r.systeme) return ErreurRole.roleSysteme;
    if (!r.actif) return ErreurRole.dejaInactif;
    if (r.nbUtilisateurs > 0) return ErreurRole.utilisateursRattaches;
    return null;
  }

  Future<void> desactiver(List<String> codes) => db.transaction((txn) async {
    final repo = PermissionsRepository(txn);
    for (final code in codes) {
      final r = await repo.role(code);
      if (r == null) throw const RoleException(ErreurRole.roleInconnu);
      final blocage = blocageDesactivation(r);
      if (blocage != null) throw RoleException(blocage);
      await repo.mettreAJour(code, {'actif': 0, 'modifie_par': utilisateurCode});
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Désactivation',
        entite: 'role',
        entiteCode: code,
        detail: r.nom,
      );
    }
  });

  Future<void> _valider(PermissionsRepository repo, String nom, Set<String> modules, {String? saufCode}) async {
    if (nom.trim().isEmpty) throw const RoleException(ErreurRole.nomObligatoire);
    if (!await repo.nomDisponible(nom, saufCode: saufCode)) throw const RoleException(ErreurRole.nomPris);
    if (modules.isEmpty) throw const RoleException(ErreurRole.aucunModule);
  }
}
