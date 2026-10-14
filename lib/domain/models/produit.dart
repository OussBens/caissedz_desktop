import 'package:flutter/foundation.dart';

/// Produit du catalogue (table `produit`).
///
/// ⚠️ PROVISOIRE : colonnes à aligner sur la spec 06. `suiviNombre` active le
/// 2ᵉ stock « nombre » (pièces par unité, ex. carton de 12).
@immutable
class Produit {
  const Produit({
    required this.code,
    required this.designation,
    this.codeBarres,
    required this.categorieCode,
    required this.sousCategorieCode,
    this.prixAchat = 0,
    this.prixVente = 0,
    this.margePct = 0,
    this.unite = 'Pièce',
    this.tvaPct = 19,
    this.seuilStock,
    this.suiviNombre = false,
    this.nombreParUnite = 1,
    this.source = 'Manuel',
    this.actif = true,
    this.image,
  });

  final String code;
  final String designation;
  final String? codeBarres;
  final String categorieCode;
  final String sousCategorieCode;
  final double prixAchat;
  final double prixVente;
  final double margePct;
  final String unite;
  final double tvaPct;

  /// Seuil d'alerte propre au produit ; `null` = seuil global des paramètres.
  final int? seuilStock;
  final bool suiviNombre;
  final int nombreParUnite;

  /// `Manuel` ou `IA` (valeur stockée FR).
  final String source;
  final bool actif;
  final String? image;

  Produit copyWith({
    String? designation,
    String? codeBarres,
    bool effacerCodeBarres = false,
    String? categorieCode,
    String? sousCategorieCode,
    double? prixAchat,
    double? prixVente,
    double? margePct,
    String? unite,
    double? tvaPct,
    int? seuilStock,
    bool effacerSeuil = false,
    bool? suiviNombre,
    int? nombreParUnite,
    String? source,
    bool? actif,
    String? image,
  }) => Produit(
    code: code,
    designation: designation ?? this.designation,
    codeBarres: effacerCodeBarres ? null : (codeBarres ?? this.codeBarres),
    categorieCode: categorieCode ?? this.categorieCode,
    sousCategorieCode: sousCategorieCode ?? this.sousCategorieCode,
    prixAchat: prixAchat ?? this.prixAchat,
    prixVente: prixVente ?? this.prixVente,
    margePct: margePct ?? this.margePct,
    unite: unite ?? this.unite,
    tvaPct: tvaPct ?? this.tvaPct,
    seuilStock: effacerSeuil ? null : (seuilStock ?? this.seuilStock),
    suiviNombre: suiviNombre ?? this.suiviNombre,
    nombreParUnite: nombreParUnite ?? this.nombreParUnite,
    source: source ?? this.source,
    actif: actif ?? this.actif,
    image: image ?? this.image,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'designation': designation,
    'code_barres': codeBarres,
    'categorie_code': categorieCode,
    'sous_categorie_code': sousCategorieCode,
    'prix_achat': prixAchat,
    'prix_vente': prixVente,
    'marge_pct': margePct,
    'unite': unite,
    'tva_pct': tvaPct,
    'seuil_stock': seuilStock,
    'suivi_nombre': suiviNombre ? 1 : 0,
    'nombre_par_unite': nombreParUnite,
    'source': source,
    'actif': actif ? 1 : 0,
    'image': image,
  };

  factory Produit.depuisLigne(Map<String, Object?> r) => Produit(
    code: r['code'] as String,
    designation: r['designation'] as String,
    codeBarres: r['code_barres'] as String?,
    categorieCode: r['categorie_code'] as String,
    sousCategorieCode: r['sous_categorie_code'] as String,
    prixAchat: (r['prix_achat'] as num).toDouble(),
    prixVente: (r['prix_vente'] as num).toDouble(),
    margePct: (r['marge_pct'] as num).toDouble(),
    unite: r['unite'] as String,
    tvaPct: (r['tva_pct'] as num).toDouble(),
    seuilStock: r['seuil_stock'] as int?,
    suiviNombre: (r['suivi_nombre'] as int) == 1,
    nombreParUnite: r['nombre_par_unite'] as int,
    source: r['source'] as String,
    actif: (r['actif'] as int) == 1,
    image: r['image'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is Produit &&
      other.code == code &&
      other.designation == designation &&
      other.codeBarres == codeBarres &&
      other.prixAchat == prixAchat &&
      other.prixVente == prixVente &&
      other.categorieCode == categorieCode &&
      other.sousCategorieCode == sousCategorieCode &&
      other.suiviNombre == suiviNombre &&
      other.nombreParUnite == nombreParUnite &&
      other.actif == actif;
  @override
  int get hashCode => Object.hash(
    code,
    designation,
    codeBarres,
    prixAchat,
    prixVente,
    categorieCode,
    sousCategorieCode,
    suiviNombre,
    nombreParUnite,
    actif,
  );
}

/// Catégorie / sous-catégorie.
@immutable
class Categorie {
  const Categorie({required this.code, required this.nom, this.systeme = false});
  final String code;
  final String nom;
  final bool systeme;
  factory Categorie.depuisLigne(Map<String, Object?> r) =>
      Categorie(code: r['code'] as String, nom: r['nom'] as String, systeme: (r['systeme'] as int) == 1);
  @override
  bool operator ==(Object other) => other is Categorie && other.code == code && other.nom == nom;
  @override
  int get hashCode => Object.hash(code, nom);
}

@immutable
class SousCategorie {
  const SousCategorie({required this.code, required this.categorieCode, required this.nom, this.systeme = false});
  final String code;
  final String categorieCode;
  final String nom;
  final bool systeme;
  factory SousCategorie.depuisLigne(Map<String, Object?> r) => SousCategorie(
    code: r['code'] as String,
    categorieCode: r['categorie_code'] as String,
    nom: r['nom'] as String,
    systeme: (r['systeme'] as int) == 1,
  );
  @override
  bool operator ==(Object other) =>
      other is SousCategorie && other.code == code && other.nom == nom && other.categorieCode == categorieCode;
  @override
  int get hashCode => Object.hash(code, nom, categorieCode);
}

/// Colis : conditionnement de N unités d'un produit, avec son propre code-barres et prix.
@immutable
class Colis {
  const Colis({
    required this.code,
    required this.produitCode,
    required this.designation,
    required this.quantite,
    this.codeBarres,
    required this.prixVente,
    this.actif = true,
  });
  final String code;
  final String produitCode;
  final String designation;
  final int quantite;
  final String? codeBarres;
  final double prixVente;
  final bool actif;
  Map<String, Object?> versLigne() => {
    'code': code,
    'produit_code': produitCode,
    'designation': designation,
    'quantite': quantite,
    'code_barres': codeBarres,
    'prix_vente': prixVente,
    'actif': actif ? 1 : 0,
  };
  factory Colis.depuisLigne(Map<String, Object?> r) => Colis(
    code: r['code'] as String,
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: r['quantite'] as int,
    codeBarres: r['code_barres'] as String?,
    prixVente: (r['prix_vente'] as num).toDouble(),
    actif: (r['actif'] as int) == 1,
  );
  @override
  bool operator ==(Object other) =>
      other is Colis &&
      other.code == code &&
      other.produitCode == produitCode &&
      other.quantite == quantite &&
      other.prixVente == prixVente;
  @override
  int get hashCode => Object.hash(code, produitCode, quantite, prixVente);
}

/// Pack : lot de plusieurs produits vendu à un prix global.
@immutable
class Pack {
  const Pack({
    required this.code,
    required this.designation,
    this.codeBarres,
    required this.prixVente,
    this.actif = true,
    this.lignes = const [],
  });
  final String code;
  final String designation;
  final String? codeBarres;
  final double prixVente;
  final bool actif;
  final List<PackLigne> lignes;
  Pack copyWith({List<PackLigne>? lignes}) => Pack(
    code: code,
    designation: designation,
    codeBarres: codeBarres,
    prixVente: prixVente,
    actif: actif,
    lignes: lignes ?? this.lignes,
  );
  Map<String, Object?> versLigne() => {
    'code': code,
    'designation': designation,
    'code_barres': codeBarres,
    'prix_vente': prixVente,
    'actif': actif ? 1 : 0,
  };
  factory Pack.depuisLigne(Map<String, Object?> r, [List<PackLigne> lignes = const []]) => Pack(
    code: r['code'] as String,
    designation: r['designation'] as String,
    codeBarres: r['code_barres'] as String?,
    prixVente: (r['prix_vente'] as num).toDouble(),
    actif: (r['actif'] as int) == 1,
    lignes: lignes,
  );
}

@immutable
class PackLigne {
  const PackLigne({required this.produitCode, required this.quantite});
  final String produitCode;
  final int quantite;
  @override
  bool operator ==(Object other) =>
      other is PackLigne && other.produitCode == produitCode && other.quantite == quantite;
  @override
  int get hashCode => Object.hash(produitCode, quantite);
}

/// Remise : pourcentage ou montant, sur un produit, une catégorie ou globale, avec période.
@immutable
class Remise {
  const Remise({
    required this.code,
    required this.designation,
    required this.type,
    required this.valeur,
    this.produitCode,
    this.categorieCode,
    this.dateDebut,
    this.dateFin,
    this.actif = true,
  });
  final String code;
  final String designation;

  /// `Pourcentage` ou `Montant` (valeur stockée FR).
  final String type;
  final double valeur;
  final String? produitCode;
  final String? categorieCode;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final bool actif;

  bool estApplicable(DateTime date, {required String produitCode, required String categorieCode}) {
    if (!actif) return false;
    if (dateDebut != null && date.isBefore(dateDebut!)) return false;
    if (dateFin != null && date.isAfter(dateFin!)) return false;
    if (this.produitCode != null) return this.produitCode == produitCode;
    if (this.categorieCode != null) return this.categorieCode == categorieCode;
    return true;
  }

  Map<String, Object?> versLigne() => {
    'code': code,
    'designation': designation,
    'type': type,
    'valeur': valeur,
    'produit_code': produitCode,
    'categorie_code': categorieCode,
    'date_debut': dateDebut?.toIso8601String(),
    'date_fin': dateFin?.toIso8601String(),
    'actif': actif ? 1 : 0,
  };
  factory Remise.depuisLigne(Map<String, Object?> r) => Remise(
    code: r['code'] as String,
    designation: r['designation'] as String,
    type: r['type'] as String,
    valeur: (r['valeur'] as num).toDouble(),
    produitCode: r['produit_code'] as String?,
    categorieCode: r['categorie_code'] as String?,
    dateDebut: DateTime.tryParse((r['date_debut'] as String?) ?? ''),
    dateFin: DateTime.tryParse((r['date_fin'] as String?) ?? ''),
    actif: (r['actif'] as int) == 1,
  );
}
