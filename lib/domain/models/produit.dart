import 'package:flutter/foundation.dart';

import 'audit.dart';

/// Produit du catalogue (table `produit`).
///
/// ⚠️ PROVISOIRE : colonnes à aligner sur la spec 06. `suiviNombre` active le
/// 2ᵉ stock « nombre » (pièces par unité, ex. carton de 12).
@immutable
class Produit {
  const Produit({
    this.audit = Audit.vide,
    required this.code,
    required this.designation,
    this.designationAr,
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
    this.marque,
    this.description,
    this.fournisseurCode,
    this.dateExpiration,
    this.service = false,
    this.taille,
    this.couleur,
    this.observation,
    this.suiviSerie = false,
    this.remiseCode,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;

  final String code;
  final String designation;

  /// Nom arabe (facultatif) : cherché comme la désignation, imprimé sur les tickets et documents en arabe.
  final String? designationAr;

  /// Le nom dans la langue d'affichage : l'arabe s'il est renseigné, la désignation sinon.
  String nom(String langue) =>
      langue == 'ar' && designationAr != null && designationAr!.trim().isNotEmpty ? designationAr!.trim() : designation;

  /// Ce qu'une recherche par nom compare : la désignation et le nom arabe.
  String get texteRecherche => designationAr == null ? designation : '$designation $designationAr';
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

  /// 2ᵉ stock « nombre » obligatoire (> 0) à la saisie (§8.1) : paramètre global [global] ou propre au produit.
  bool exigeNombre({required bool global}) => !service && (global || suiviNombre);

  /// `Manuel`, `IA` ou `Catalogue` (valeur stockée FR).
  final String source;

  /// Produit téléchargé depuis le catalogue BENS (rayons choisis à l'accueil), sans prix au départ.
  static const String sourceCatalogue = 'Catalogue';

  bool get duCatalogue => source == sourceCatalogue;
  final bool actif;
  final String? image;
  final String? marque;
  final String? description;

  /// Fournisseur habituel (code).
  final String? fournisseurCode;
  final DateTime? dateExpiration;

  /// Produit-service (réparation, livraison…) : aucun stock.
  final bool service;
  final String? taille;
  final String? couleur;
  final String? observation;

  /// Saisie du n° de série obligatoire à la vente.
  final bool suiviSerie;

  /// Remise « Par Produit » affectée (code).
  final String? remiseCode;

  Produit copyWith({
    String? designation,
    String? designationAr,
    bool effacerDesignationAr = false,
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
    String? marque,
    String? description,
    String? fournisseurCode,
    DateTime? dateExpiration,
    bool effacerExpiration = false,
    bool? service,
    String? taille,
    String? couleur,
    String? observation,
    bool? suiviSerie,
    String? remiseCode,
    bool effacerRemise = false,
  }) => Produit(
    audit: audit,
    code: code,
    designation: designation ?? this.designation,
    designationAr: effacerDesignationAr ? null : (designationAr ?? this.designationAr),
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
    marque: marque ?? this.marque,
    description: description ?? this.description,
    fournisseurCode: fournisseurCode ?? this.fournisseurCode,
    dateExpiration: effacerExpiration ? null : (dateExpiration ?? this.dateExpiration),
    service: service ?? this.service,
    taille: taille ?? this.taille,
    couleur: couleur ?? this.couleur,
    observation: observation ?? this.observation,
    suiviSerie: suiviSerie ?? this.suiviSerie,
    remiseCode: effacerRemise ? null : (remiseCode ?? this.remiseCode),
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'designation': designation,
    'designation_ar': _vide(designationAr),
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
    'marque': _vide(marque),
    'description': _vide(description),
    'fournisseur_code': fournisseurCode,
    'date_expiration': dateExpiration?.toIso8601String(),
    'service': service ? 1 : 0,
    'taille': _vide(taille),
    'couleur': _vide(couleur),
    'observation': _vide(observation),
    'suivi_serie': suiviSerie ? 1 : 0,
    'remise_code': remiseCode,
  };

  static String? _vide(String? s) => s == null || s.trim().isEmpty ? null : s.trim();

  factory Produit.depuisLigne(Map<String, Object?> r) => Produit(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    designation: r['designation'] as String,
    designationAr: r['designation_ar'] as String?,
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
    marque: r['marque'] as String?,
    description: r['description'] as String?,
    fournisseurCode: r['fournisseur_code'] as String?,
    dateExpiration: DateTime.tryParse((r['date_expiration'] as String?) ?? ''),
    service: (r['service'] as int? ?? 0) == 1,
    taille: r['taille'] as String?,
    couleur: r['couleur'] as String?,
    observation: r['observation'] as String?,
    suiviSerie: (r['suivi_serie'] as int? ?? 0) == 1,
    remiseCode: r['remise_code'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is Produit &&
      other.code == code &&
      other.designation == designation &&
      other.designationAr == designationAr &&
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
  const Categorie({
    this.audit = Audit.vide,
    required this.code,
    required this.nom,
    this.systeme = false,
    this.description,
    this.actif = true,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String nom;
  final bool systeme;
  final String? description;

  /// Visible en caisse et dans les listes de choix.
  final bool actif;
  factory Categorie.depuisLigne(Map<String, Object?> r) => Categorie(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    nom: r['nom'] as String,
    systeme: (r['systeme'] as int) == 1,
    description: r['description'] as String?,
    actif: (r['actif'] as int? ?? 1) == 1,
  );
  @override
  bool operator ==(Object other) => other is Categorie && other.code == code && other.nom == nom;
  @override
  int get hashCode => Object.hash(code, nom);
}

@immutable
class SousCategorie {
  const SousCategorie({
    this.audit = Audit.vide,
    required this.code,
    required this.categorieCode,
    required this.nom,
    this.systeme = false,
    this.description,
    this.actif = true,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String categorieCode;
  final String nom;
  final bool systeme;
  final String? description;
  final bool actif;
  factory SousCategorie.depuisLigne(Map<String, Object?> r) => SousCategorie(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    categorieCode: r['categorie_code'] as String,
    nom: r['nom'] as String,
    systeme: (r['systeme'] as int) == 1,
    description: r['description'] as String?,
    actif: (r['actif'] as int? ?? 1) == 1,
  );
  @override
  bool operator ==(Object other) =>
      other is SousCategorie && other.code == code && other.nom == nom && other.categorieCode == categorieCode;
  @override
  int get hashCode => Object.hash(code, nom, categorieCode);
}

/// Emballage saisi dans la fiche produit (§7.2 `emballage1/emballageP1` = petit colis, `emballage2` = grand
/// colis) ; enregistré comme [Colis] du produit.
@immutable
class EmballageProduit {
  const EmballageProduit({required this.quantite, required this.prixVente, this.codeBarres});
  final int quantite;
  final double prixVente;
  final String? codeBarres;
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
    this.audit = Audit.vide,
    required this.code,
    required this.designation,
    this.codeBarres,
    required this.prixVente,
    this.actif = true,
    this.lignes = const [],
    this.description,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String designation;
  final String? codeBarres;
  final double prixVente;
  final bool actif;
  final List<PackLigne> lignes;
  final String? description;
  Pack copyWith({List<PackLigne>? lignes, bool? actif}) => Pack(
    audit: audit,
    code: code,
    designation: designation,
    codeBarres: codeBarres,
    prixVente: prixVente,
    actif: actif ?? this.actif,
    lignes: lignes ?? this.lignes,
    description: description,
  );
  Map<String, Object?> versLigne() => {
    'code': code,
    'designation': designation,
    'code_barres': codeBarres,
    'prix_vente': prixVente,
    'actif': actif ? 1 : 0,
    'description': description,
  };
  factory Pack.depuisLigne(Map<String, Object?> r, [List<PackLigne> lignes = const []]) => Pack(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    designation: r['designation'] as String,
    codeBarres: r['code_barres'] as String?,
    prixVente: (r['prix_vente'] as num).toDouble(),
    actif: (r['actif'] as int) == 1,
    lignes: lignes,
    description: r['description'] as String?,
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
    this.audit = Audit.vide,
    required this.code,
    required this.designation,
    required this.type,
    required this.valeur,
    this.produitCode,
    this.categorieCode,
    this.dateDebut,
    this.dateFin,
    this.actif = true,
    this.cumulable = false,
    this.observation,
    this.portee = porteeProduit,
    this.seuil = 0,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String designation;

  /// Type de taux (`taux_type` du §7) : `Pourcentage` ou `Montant` (valeur stockée FR).
  final String type;
  final double valeur;
  final String? produitCode;
  final String? categorieCode;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final bool actif;

  /// Cumulable avec la remise ticket.
  final bool cumulable;
  final String? observation;

  /// Type de remise (§8.9) : [porteeProduit] (assignée aux produits) ou [porteeMontant] (choisie sur le
  /// panier, active seulement si le sous-total atteint [seuil]).
  final String portee;
  final double seuil;

  static const porteeProduit = 'Par Produit';
  static const porteeMontant = 'Par Montant';

  bool get estPourcentage => type == 'Pourcentage';
  bool get parMontant => portee == porteeMontant;

  Remise copyWith({String? code, bool? actif}) => Remise(
    audit: audit,
    code: code ?? this.code,
    designation: designation,
    type: type,
    valeur: valeur,
    produitCode: produitCode,
    categorieCode: categorieCode,
    dateDebut: dateDebut,
    dateFin: dateFin,
    actif: actif ?? this.actif,
    cumulable: cumulable,
    observation: observation,
    portee: portee,
    seuil: seuil,
  );

  /// Vrai si [date] (à la journée) est dans la période Du / Au, bornes incluses.
  bool dansPeriode(DateTime date) {
    final jour = DateTime(date.year, date.month, date.day);
    if (dateDebut != null && jour.isBefore(DateTime(dateDebut!.year, dateDebut!.month, dateDebut!.day))) return false;
    if (dateFin != null && jour.isAfter(DateTime(dateFin!.year, dateFin!.month, dateFin!.day))) return false;
    return true;
  }

  /// Active à [date] : non annulée et [date] dans la période. Une remise inactive n'est ni proposée (listes,
  /// dialogs de sélection, caisse) ni appliquée aux produits.
  bool estActive(DateTime date) => actif && dansPeriode(date);

  /// Statut d'affichage : `actif` ou `inactif` selon la période, `annule` si la remise a été annulée.
  String statut(DateTime date) => !actif ? 'annule' : (dansPeriode(date) ? 'actif' : 'inactif');

  /// Prix remisé d'un prix de base.
  double appliquer(double prix) =>
      (estPourcentage ? prix * (1 - valeur / 100) : prix - valeur).clamp(0, double.infinity).toDouble();

  bool estApplicable(DateTime date, {required String produitCode, required String categorieCode}) {
    if (parMontant || !estActive(date)) return false;
    if (this.produitCode != null) return this.produitCode == produitCode;
    if (this.categorieCode != null) return this.categorieCode == categorieCode;
    return false;
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
    'cumulable': cumulable ? 1 : 0,
    'observation': observation,
    'portee': portee,
    'seuil': seuil,
  };
  factory Remise.depuisLigne(Map<String, Object?> r) => Remise(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    designation: r['designation'] as String,
    type: r['type'] as String,
    valeur: (r['valeur'] as num).toDouble(),
    produitCode: r['produit_code'] as String?,
    categorieCode: r['categorie_code'] as String?,
    dateDebut: DateTime.tryParse((r['date_debut'] as String?) ?? ''),
    dateFin: DateTime.tryParse((r['date_fin'] as String?) ?? ''),
    actif: (r['actif'] as int) == 1,
    cumulable: (r['cumulable'] as int? ?? 0) == 1,
    observation: r['observation'] as String?,
    portee: r['portee'] as String? ?? porteeProduit,
    seuil: (r['seuil'] as num? ?? 0).toDouble(),
  );
}
