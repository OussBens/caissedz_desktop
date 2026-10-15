import 'package:flutter/foundation.dart';

/// Fiche administrative commune aux clients et fournisseurs (§7.6) : wilaya, type (référentiel
/// `typeClient` / `typeFournisseur`), activité, contact, identifiants fiscaux, banque.
@immutable
class FicheTiers {
  const FicheTiers({
    this.wilaya = '',
    this.type = '',
    this.activite = '',
    this.fax = '',
    this.nif = '',
    this.nis = '',
    this.nrc = '',
    this.banque = '',
    this.rib = '',
    this.observation = '',
  });
  final String wilaya;
  final String type;
  final String activite;
  final String fax;
  final String nif;
  final String nis;
  final String nrc;
  final String banque;
  final String rib;
  final String observation;

  Map<String, Object?> versLigne() => {
    'wilaya': wilaya,
    'type': type,
    'activite': activite,
    'fax': fax,
    'nif': nif,
    'nis': nis,
    'nrc': nrc,
    'banque': banque,
    'rib': rib,
    'observation': observation,
  };

  factory FicheTiers.depuisLigne(Map<String, Object?> r) {
    String s(String k) => (r[k] as String?) ?? '';
    return FicheTiers(
      wilaya: s('wilaya'),
      type: s('type'),
      activite: s('activite'),
      fax: s('fax'),
      nif: s('nif'),
      nis: s('nis'),
      nrc: s('nrc'),
      banque: s('banque'),
      rib: s('rib'),
      observation: s('observation'),
    );
  }
}

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
    this.fiche = const FicheTiers(type: 'Consommateur'),
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
  final FicheTiers fiche;

  bool get estDePassage => code == 'CLN0000';

  Client copyWith({
    String? nom,
    String? telephone,
    String? adresse,
    String? email,
    int? points,
    double? plafondCredit,
    bool? actif,
    FicheTiers? fiche,
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
    fiche: fiche ?? this.fiche,
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
    ...fiche.versLigne(),
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
    fiche: FicheTiers.depuisLigne(r),
  );

  @override
  bool operator ==(Object other) =>
      other is Client && other.code == code && other.nom == nom && other.points == points && other.actif == actif;
  @override
  int get hashCode => Object.hash(code, nom, points, actif);
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
    this.fiche = const FicheTiers(type: 'Grossiste'),
  });
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final bool actif;
  final bool systeme;
  final FicheTiers fiche;

  Fournisseur copyWith({
    String? nom,
    String? telephone,
    String? adresse,
    String? email,
    bool? actif,
    FicheTiers? fiche,
  }) => Fournisseur(
    code: code,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    adresse: adresse ?? this.adresse,
    email: email ?? this.email,
    actif: actif ?? this.actif,
    systeme: systeme,
    fiche: fiche ?? this.fiche,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'telephone': telephone,
    'adresse': adresse,
    'email': email,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
    ...fiche.versLigne(),
  };
  factory Fournisseur.depuisLigne(Map<String, Object?> r) => Fournisseur(
    code: r['code'] as String,
    nom: r['nom'] as String,
    telephone: (r['telephone'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    fiche: FicheTiers.depuisLigne(r),
  );
}
