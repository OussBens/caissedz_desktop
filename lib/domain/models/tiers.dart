import 'package:flutter/foundation.dart';

/// Client (table `client`).
@immutable
class Client {
  const Client({
    required this.code,
    required this.nom,
    this.telephone = '',
    this.adresse = '',
    this.email = '',
    this.points = 0,
    this.plafondCredit = 0,
    this.actif = true,
    this.systeme = false,
  });
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final int points;

  /// Plafond de crédit autorisé (0 = pas de vente à crédit).
  final double plafondCredit;
  final bool actif;
  final bool systeme;

  bool get estDePassage => code == 'CLN0000';

  Client copyWith({
    String? nom,
    String? telephone,
    String? adresse,
    String? email,
    int? points,
    double? plafondCredit,
    bool? actif,
  }) => Client(
    code: code,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    adresse: adresse ?? this.adresse,
    email: email ?? this.email,
    points: points ?? this.points,
    plafondCredit: plafondCredit ?? this.plafondCredit,
    actif: actif ?? this.actif,
    systeme: systeme,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'telephone': telephone,
    'adresse': adresse,
    'email': email,
    'points': points,
    'plafond_credit': plafondCredit,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
  };

  factory Client.depuisLigne(Map<String, Object?> r) => Client(
    code: r['code'] as String,
    nom: r['nom'] as String,
    telephone: (r['telephone'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    points: (r['points'] as int?) ?? 0,
    plafondCredit: ((r['plafond_credit'] as num?) ?? 0).toDouble(),
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
  );

  @override
  bool operator ==(Object other) => other is Client && other.code == code && other.nom == nom && other.points == points;
  @override
  int get hashCode => Object.hash(code, nom, points);
}

/// Fournisseur (table `fournisseur`).
@immutable
class Fournisseur {
  const Fournisseur({
    required this.code,
    required this.nom,
    this.telephone = '',
    this.adresse = '',
    this.email = '',
    this.actif = true,
    this.systeme = false,
  });
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final bool actif;
  final bool systeme;

  Fournisseur copyWith({String? nom, String? telephone, String? adresse, String? email, bool? actif}) => Fournisseur(
    code: code,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    adresse: adresse ?? this.adresse,
    email: email ?? this.email,
    actif: actif ?? this.actif,
    systeme: systeme,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'telephone': telephone,
    'adresse': adresse,
    'email': email,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
  };
  factory Fournisseur.depuisLigne(Map<String, Object?> r) => Fournisseur(
    code: r['code'] as String,
    nom: r['nom'] as String,
    telephone: (r['telephone'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
  );
}
