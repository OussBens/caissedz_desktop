import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/permissions.dart';

/// Validation des clés d'activation (SHA-256, 64 caractères hexadécimaux).
///
/// ⚠️ PROVISOIRE (hypothèse à confirmer avec §8/§9 de la spec) : la clé est liée
/// à la machine. Pour l'identifiant machine `M` affiché sur l'écran d'activation,
/// la clé Basic est `SHA-256("CAISSEDZ|BASIC|M")` et la clé Avancé est
/// `SHA-256("CAISSEDZ|AVANCE|M")`. Toute autre chaîne de 64 hex est refusée.
class CleActivation {
  const CleActivation();

  static final RegExp _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');

  static bool formatValide(String cle) => _hex64.hasMatch(cle.trim());

  static String normaliser(String cle) => cle.trim().toLowerCase();

  /// Clé attendue pour un niveau et un identifiant machine (usage : génération côté éditeur, tests).
  static String cleAttendue(NiveauLicence niveau, String identifiantMachine) {
    final tag = niveau == NiveauLicence.avance ? 'AVANCE' : 'BASIC';
    return sha256.convert(utf8.encode('CAISSEDZ|$tag|$identifiantMachine')).toString();
  }

  /// Niveau de licence correspondant à [cle] pour cette machine, ou `null` si la clé est invalide.
  NiveauLicence? resoudre(String cle, String identifiantMachine) {
    if (!formatValide(cle)) return null;
    final c = normaliser(cle);
    for (final n in NiveauLicence.values) {
      if (cleAttendue(n, identifiantMachine) == c) return n;
    }
    return null;
  }
}
