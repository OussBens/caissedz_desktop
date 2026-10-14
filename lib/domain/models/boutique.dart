import 'package:flutter/foundation.dart';

/// Identité de la boutique (table `boutique`, ligne unique).
@immutable
class Boutique {
  const Boutique({
    required this.nom,
    this.rc = '',
    this.nif = '',
    this.adresse = '',
    this.telephone = '',
    this.email = '',
  });

  final String nom;
  final String rc;
  final String nif;
  final String adresse;
  final String telephone;
  final String email;

  Boutique copyWith({String? nom, String? rc, String? nif, String? adresse, String? telephone, String? email}) =>
      Boutique(
        nom: nom ?? this.nom,
        rc: rc ?? this.rc,
        nif: nif ?? this.nif,
        adresse: adresse ?? this.adresse,
        telephone: telephone ?? this.telephone,
        email: email ?? this.email,
      );

  Map<String, Object?> versLigne() =>
      {'id': 1, 'nom': nom, 'rc': rc, 'nif': nif, 'adresse': adresse, 'telephone': telephone, 'email': email};

  factory Boutique.depuisLigne(Map<String, Object?> r) => Boutique(
        nom: r['nom'] as String,
        rc: (r['rc'] as String?) ?? '',
        nif: (r['nif'] as String?) ?? '',
        adresse: (r['adresse'] as String?) ?? '',
        telephone: (r['telephone'] as String?) ?? '',
        email: (r['email'] as String?) ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is Boutique &&
      other.nom == nom &&
      other.rc == rc &&
      other.nif == nif &&
      other.adresse == adresse &&
      other.telephone == telephone &&
      other.email == email;
  @override
  int get hashCode => Object.hash(nom, rc, nif, adresse, telephone, email);
}
