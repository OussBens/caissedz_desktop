import 'package:flutter/foundation.dart';

/// Téléphone appairé à ce poste (application CaisseDZ Scan, table `appareil_mobile`).
@immutable
class AppareilMobile {
  const AppareilMobile({
    required this.code,
    required this.nom,
    this.plateforme = '',
    this.utilisateurCode,
    required this.creeLe,
    this.dernierAcces,
    this.dernierUtilisateur,
  });

  final String code;
  final String nom;

  /// `android` ou `ios`.
  final String plateforme;

  /// Utilisateur dont le QR code a été scanné : le téléphone se connecte avec ce compte.
  final String? utilisateurCode;
  final DateTime creeLe;
  final DateTime? dernierAcces;

  /// Code du dernier utilisateur connecté depuis ce téléphone.
  final String? dernierUtilisateur;

  static DateTime? _date(Object? v) => DateTime.tryParse((v as String?) ?? '')?.toLocal();

  factory AppareilMobile.depuisLigne(Map<String, Object?> r) => AppareilMobile(
    code: r['code']! as String,
    nom: r['nom']! as String,
    plateforme: (r['plateforme'] as String?) ?? '',
    utilisateurCode: r['utilisateur_code'] as String?,
    creeLe: _date(r['cree_le']) ?? DateTime.now(),
    dernierAcces: _date(r['dernier_acces']),
    dernierUtilisateur: r['dernier_utilisateur'] as String?,
  );
}
