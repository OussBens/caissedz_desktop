import 'package:flutter/foundation.dart';

/// Utilisateur de l'application (table `utilisateur`).
@immutable
class Utilisateur {
  const Utilisateur({
    required this.code,
    required this.identifiant,
    required this.nom,
    required this.role,
    this.actif = true,
    this.systeme = false,
  });

  final String code;
  final String identifiant;
  final String nom;

  /// Valeur stockée du référentiel des rôles (`Admin`, `Caissier`, `Magasinier`).
  final String role;
  final bool actif;
  final bool systeme;

  Utilisateur copyWith({String? identifiant, String? nom, String? role, bool? actif}) => Utilisateur(
        code: code,
        identifiant: identifiant ?? this.identifiant,
        nom: nom ?? this.nom,
        role: role ?? this.role,
        actif: actif ?? this.actif,
        systeme: systeme,
      );

  factory Utilisateur.depuisLigne(Map<String, Object?> r) => Utilisateur(
        code: r['code'] as String,
        identifiant: r['identifiant'] as String,
        nom: r['nom'] as String,
        role: r['role'] as String,
        actif: (r['actif'] as int) == 1,
        systeme: (r['systeme'] as int) == 1,
      );

  @override
  bool operator ==(Object other) =>
      other is Utilisateur &&
      other.code == code &&
      other.identifiant == identifiant &&
      other.nom == nom &&
      other.role == role &&
      other.actif == actif &&
      other.systeme == systeme;
  @override
  int get hashCode => Object.hash(code, identifiant, nom, role, actif, systeme);
}
