import 'package:flutter/foundation.dart';

import '../permissions.dart';
import 'audit.dart';

/// Utilisateur de l'application (table `utilisateur`, §9.12) : compte et rôle (par code).
/// Les magasins ordonnés sont dans `utilisateur_magasin` et les caisses dans `utilisateur_caisse` (le premier est
/// celui par défaut) ; l'Admin a toutes les caisses.
@immutable
class Utilisateur {
  const Utilisateur({
    required this.code,
    required this.identifiant,
    required this.nom,
    required this.roleCode,
    this.roleNom,
    this.prenom = '',
    this.telephone = '',
    this.observation = '',
    this.actif = true,
    this.systeme = false,
    this.dernierAcces,
    this.creeLe,
    this.creePar,
    this.modifieLe,
    this.modifiePar,
    this.archiveLe,
    this.archivePar,
  });

  final String code;
  final String identifiant;
  final String nom;
  final String prenom;
  final String telephone;

  /// Rôle (`role.code`) ; [roleNom] est lu par jointure pour l'affichage.
  final String roleCode;
  final String? roleNom;

  final String observation;
  final bool actif;
  final bool systeme;

  /// Dernière connexion réussie (§5.4).
  final DateTime? dernierAcces;
  final DateTime? creeLe;
  final String? creePar;
  final DateTime? modifieLe;
  final String? modifiePar;

  /// Archivage (migration v43) : compte gardé pour l'historique, masqué des listes.
  final DateTime? archiveLe;
  final String? archivePar;
  bool get archive => archiveLe != null;

  bool get estAdmin => roleCode == Roles.admin;

  /// Champs d'audit regroupés (section « Traçabilité » des détails).
  Audit get audit => Audit(
    creeLe: creeLe,
    creePar: creePar,
    modifieLe: modifieLe,
    modifiePar: modifiePar,
    archiveLe: archiveLe,
    archivePar: archivePar,
  );

  /// Prénom + nom (ou le nom seul).
  String get nomComplet => [prenom.trim(), nom.trim()].where((s) => s.isNotEmpty).join(' ');

  Utilisateur copyWith({String? identifiant, String? nom, String? roleCode, bool? actif}) => Utilisateur(
    code: code,
    identifiant: identifiant ?? this.identifiant,
    nom: nom ?? this.nom,
    roleCode: roleCode ?? this.roleCode,
    roleNom: roleCode == null ? roleNom : null,
    prenom: prenom,
    telephone: telephone,
    observation: observation,
    actif: actif ?? this.actif,
    systeme: systeme,
    dernierAcces: dernierAcces,
    creeLe: creeLe,
    creePar: creePar,
    modifieLe: modifieLe,
    modifiePar: modifiePar,
    archiveLe: archiveLe,
    archivePar: archivePar,
  );

  static DateTime? _date(Object? v) => DateTime.tryParse((v as String?) ?? '')?.toLocal();

  factory Utilisateur.depuisLigne(Map<String, Object?> r) => Utilisateur(
    code: r['code'] as String,
    identifiant: r['identifiant'] as String,
    nom: r['nom'] as String,
    prenom: (r['prenom'] as String?) ?? '',
    telephone: (r['telephone'] as String?) ?? '',
    roleCode: r['role_code'] as String,
    roleNom: r['role_nom'] as String?,
    observation: (r['observation'] as String?) ?? '',
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    dernierAcces: _date(r['dernier_acces']),
    creeLe: _date(r['cree_le']),
    creePar: r['cree_par'] as String?,
    modifieLe: _date(r['modifie_le']),
    modifiePar: r['modifie_par'] as String?,
    archiveLe: _date(r['archive_le']),
    archivePar: r['archive_par'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is Utilisateur &&
      other.code == code &&
      other.identifiant == identifiant &&
      other.nom == nom &&
      other.prenom == prenom &&
      other.telephone == telephone &&
      other.roleCode == roleCode &&
      other.actif == actif &&
      other.systeme == systeme;
  @override
  int get hashCode => Object.hash(code, identifiant, nom, prenom, telephone, roleCode, actif, systeme);
}

/// Rôle (table `role` + permissions `role_permission` / `role_module`, §6.2).
@immutable
class Role {
  const Role({
    required this.code,
    required this.nom,
    this.observation = '',
    this.actif = true,
    this.systeme = false,
    this.permissions = const {},
    this.modules = const {},
    this.nbUtilisateurs = 0,
    this.creeLe,
    this.creePar,
    this.modifieLe,
    this.modifiePar,
    this.archiveLe,
    this.archivePar,
  });

  final String code;
  final String nom;
  final String observation;
  final bool actif;

  /// Rôle système (Admin) : accès complet, non modifiable.
  final bool systeme;

  /// Permissions spéciales accordées (l'Admin les a toutes, cf. [aPermission]).
  final Set<Permission> permissions;

  /// Modules accessibles (identifiants de `Modules`) ; l'Admin accède à tout.
  final Set<String> modules;
  final int nbUtilisateurs;
  final DateTime? creeLe;
  final String? creePar;
  final DateTime? modifieLe;
  final String? modifiePar;

  /// Archivage (migration v43) : rôle gardé pour l'historique des comptes, masqué des listes.
  final DateTime? archiveLe;
  final String? archivePar;
  bool get archive => archiveLe != null;

  bool get estAdmin => code == Roles.admin;

  /// Champs d'audit regroupés (section « Traçabilité » des détails).
  Audit get audit => Audit(
    creeLe: creeLe,
    creePar: creePar,
    modifieLe: modifieLe,
    modifiePar: modifiePar,
    archiveLe: archiveLe,
    archivePar: archivePar,
  );
  bool aPermission(Permission p) => estAdmin || permissions.contains(p);
  bool aModule(String id) => estAdmin || modules.contains(id);
}
