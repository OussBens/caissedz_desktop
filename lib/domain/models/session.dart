import 'package:flutter/foundation.dart';

import '../permissions.dart';
import 'utilisateur.dart';

/// Session de l'utilisateur connecté : droits effectifs calculés à la connexion.
@immutable
class Session {
  const Session({
    required this.utilisateur,
    required this.permissions,
    required this.modulesAutorises,
    this.demo = false,
  });

  final Utilisateur utilisateur;
  final Set<Permission> permissions;

  /// `null` = tous les modules (Admin).
  final Set<String>? modulesAutorises;
  final bool demo;

  bool get estAdmin => utilisateur.role == Roles.admin;

  bool a(Permission p) => permissions.contains(p);

  bool peutAcceder(String moduleId) => modulesAutorises == null || modulesAutorises!.contains(moduleId);

  Session copyWith({Utilisateur? utilisateur}) => Session(
    utilisateur: utilisateur ?? this.utilisateur,
    permissions: permissions,
    modulesAutorises: modulesAutorises,
    demo: demo,
  );
}
