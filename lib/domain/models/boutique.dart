import 'package:flutter/foundation.dart';

/// Identité de la boutique (table `boutique`, ligne unique ; `entreprise_param` du §7.9).
@immutable
class Boutique {
  const Boutique({
    required this.nom,
    this.rc = '',
    this.nif = '',
    this.adresse = '',
    this.telephone = '',
    this.email = '',
    this.nis = '',
    this.article = '',
    this.messageTicket = '',
    this.logo = '',
  });

  final String nom;
  final String rc;
  final String nif;
  final String adresse;
  final String telephone;
  final String email;
  final String nis;

  /// Article d'imposition.
  final String article;
  final String messageTicket;

  /// Chemin du logo (PNG), vide si aucun.
  final String logo;

  Boutique copyWith({
    String? nom,
    String? rc,
    String? nif,
    String? adresse,
    String? telephone,
    String? email,
    String? nis,
    String? article,
    String? messageTicket,
    String? logo,
  }) => Boutique(
    nom: nom ?? this.nom,
    rc: rc ?? this.rc,
    nif: nif ?? this.nif,
    adresse: adresse ?? this.adresse,
    telephone: telephone ?? this.telephone,
    email: email ?? this.email,
    nis: nis ?? this.nis,
    article: article ?? this.article,
    messageTicket: messageTicket ?? this.messageTicket,
    logo: logo ?? this.logo,
  );

  Map<String, Object?> versLigne() => {
    'id': 1,
    'nom': nom,
    'rc': rc,
    'nif': nif,
    'adresse': adresse,
    'telephone': telephone,
    'email': email,
    'nis': nis,
    'article': article,
    'message_ticket': messageTicket,
    'logo': logo,
  };

  factory Boutique.depuisLigne(Map<String, Object?> r) => Boutique(
    nom: r['nom'] as String,
    rc: (r['rc'] as String?) ?? '',
    nif: (r['nif'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    telephone: (r['telephone'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    nis: (r['nis'] as String?) ?? '',
    article: (r['article'] as String?) ?? '',
    messageTicket: (r['message_ticket'] as String?) ?? '',
    logo: (r['logo'] as String?) ?? '',
  );

  @override
  bool operator ==(Object other) =>
      other is Boutique &&
      other.nom == nom &&
      other.rc == rc &&
      other.nif == nif &&
      other.adresse == adresse &&
      other.telephone == telephone &&
      other.email == email &&
      other.nis == nis &&
      other.article == article &&
      other.messageTicket == messageTicket &&
      other.logo == logo;
  @override
  int get hashCode => Object.hash(nom, rc, nif, adresse, telephone, email, nis, article, messageTicket, logo);
}
