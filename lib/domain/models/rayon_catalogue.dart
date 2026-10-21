import 'package:flutter/foundation.dart';

/// Rayon du catalogue BENS (catalog-api.bensds.com, `GET /rayons`) proposé à l'accueil : ses noms
/// FR/AR/EN, son icône Lucide et le nombre de produits qu'il propose (ses mieux classés, porc et alcool
/// exclus, au plus [ResultatTelechargement.plafond]).
@immutable
class RayonCatalogue {
  const RayonCatalogue({
    required this.code,
    required this.nomFr,
    this.nomAr = '',
    this.nomEn = '',
    this.icone = 'package',
    this.produits = 0,
    this.tendances = 0,
  });

  final String code;
  final String nomFr;
  final String nomAr;
  final String nomEn;
  final String icone;
  final int produits;

  /// Parmi eux, ceux qui se vendent dans plusieurs boutiques CaisseDZ (tendance).
  final int tendances;

  /// Le nom dans la langue d'affichage (le français à défaut).
  String nom(String langue) => switch (langue) {
    'ar' when nomAr.isNotEmpty => nomAr,
    'en' when nomEn.isNotEmpty => nomEn,
    _ => nomFr,
  };

  factory RayonCatalogue.depuisJson(Map<String, Object?> j) => RayonCatalogue(
    code: j['code']! as String,
    nomFr: j['nom_fr'] as String? ?? j['code']! as String,
    nomAr: j['nom_ar'] as String? ?? '',
    nomEn: j['nom_en'] as String? ?? '',
    icone: j['icone'] as String? ?? 'package',
    produits: (j['produits'] as num?)?.toInt() ?? 0,
    tendances: (j['tendances'] as num?)?.toInt() ?? 0,
  );
}

/// Produit d'un rayon tel que le catalogue l'envoie (sans prix).
@immutable
class ProduitCatalogue {
  const ProduitCatalogue({
    required this.nom,
    required this.codesBarres,
    this.nomAr,
    this.marque,
    this.photo,
    this.tendance = false,
  });

  final String nom;

  /// Nom arabe du catalogue, s'il est connu.
  final String? nomAr;

  /// Se vend dans plusieurs boutiques CaisseDZ.
  final bool tendance;

  /// Le principal d'abord.
  final List<String> codesBarres;
  final String? marque;

  /// Adresse de la photo (https://catalog-api.bensds.com/uploads/…).
  final String? photo;

  factory ProduitCatalogue.depuisJson(Map<String, Object?> j) {
    final principal = (j['code_barres'] as String? ?? '').trim();
    final codes = <String>{
      if (principal.isNotEmpty) principal,
      for (final c in j['codes_barres'] as List? ?? const [])
        if ('$c'.trim().isNotEmpty) '$c'.trim(),
    };
    String? texte(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
    return ProduitCatalogue(
      nom: (j['nom'] as String? ?? '').trim(),
      codesBarres: codes.toList(),
      nomAr: texte(j['nom_ar']),
      marque: texte(j['marque']),
      photo: texte(j['photo']),
      tendance: j['tendance'] == true,
    );
  }
}

/// Ce qu'un rayon a donné : produits proposés, ajoutés, déjà présents (même code-barres) ou ignorés
/// (sans code-barres ni nom).
@immutable
class ResultatRayon {
  const ResultatRayon({
    required this.rayon,
    required this.disponibles,
    required this.telecharges,
    this.dejaPresents = 0,
    this.ignores = 0,
  });

  final RayonCatalogue rayon;
  final int disponibles;
  final int telecharges;
  final int dejaPresents;
  final int ignores;

  /// Part des produits proposés qui ont été ajoutés, en %.
  double get pourcentage => disponibles == 0 ? 0 : telecharges * 100 / disponibles;
}

/// Bilan d'un téléchargement de rayons (« Appliquer »).
@immutable
class ResultatTelechargement {
  const ResultatTelechargement(this.rayons);

  /// Produits proposés au plus par rayon (catalog-api).
  static const int plafond = 5000;

  final List<ResultatRayon> rayons;

  int get disponibles => rayons.fold(0, (n, r) => n + r.disponibles);
  int get telecharges => rayons.fold(0, (n, r) => n + r.telecharges);
  int get dejaPresents => rayons.fold(0, (n, r) => n + r.dejaPresents);

  /// Part des produits des rayons choisis qui ont été ajoutés, en %.
  double get pourcentage => disponibles == 0 ? 0 : telecharges * 100 / disponibles;
}

/// Avancement du téléchargement : rayon [rayon] ([indexRayon] sur [nbRayons]), [recus] produits reçus sur
/// [attendus] en tout.
typedef ProgresTelechargement = ({RayonCatalogue rayon, int indexRayon, int nbRayons, int recus, int attendus});
