import 'package:flutter/foundation.dart';

import 'audit.dart';

/// Types de mouvement de stock (valeur stockée FR, §13).
class TypesMouvement {
  const TypesMouvement._();
  static const String entree = 'Entrée';
  static const String sortie = 'Sortie';
  static const String vente = 'Vente';
  static const String retour = 'Retour';
  static const String transfert = 'Transfert';
  static const String inventaire = 'Inventaire';
  static const String initial = 'Stock initial';
}

/// Ligne du journal des mouvements (table `mouvement_stock`).
/// Le stock d'un produit dans un magasin est TOUJOURS la somme de ses mouvements.
@immutable
class MouvementStock {
  const MouvementStock({
    this.audit = Audit.vide,
    this.id,
    required this.date,
    required this.produitCode,
    required this.magasinCode,
    required this.type,
    required this.quantite,
    this.nombre = 0,
    this.referenceType,
    this.referenceCode,
    this.motif,
    required this.utilisateurCode,
    this.commentaire,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;

  final int? id;
  final DateTime date;
  final String produitCode;
  final String magasinCode;
  final String type;

  /// Signée : positive = entrée, négative = sortie (unités).
  final double quantite;

  /// Signée, 2ᵉ stock « nombre » (pièces).
  final double nombre;
  final String? referenceType;
  final String? referenceCode;
  final String? motif;
  final String utilisateurCode;
  final String? commentaire;

  Map<String, Object?> versLigne() => {
    'date': date.toUtc().toIso8601String(),
    'produit_code': produitCode,
    'magasin_code': magasinCode,
    'type': type,
    'quantite': quantite,
    'nombre': nombre,
    'reference_type': referenceType,
    'reference_code': referenceCode,
    'motif': motif,
    'utilisateur_code': utilisateurCode,
    'commentaire': commentaire,
  };

  factory MouvementStock.depuisLigne(Map<String, Object?> r) => MouvementStock(
    audit: Audit.depuisLigne(r),
    id: r['id'] as int?,
    date: DateTime.parse(r['date'] as String).toLocal(),
    produitCode: r['produit_code'] as String,
    magasinCode: r['magasin_code'] as String,
    type: r['type'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    nombre: (r['nombre'] as num).toDouble(),
    referenceType: r['reference_type'] as String?,
    referenceCode: r['reference_code'] as String?,
    motif: r['motif'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    commentaire: r['commentaire'] as String?,
  );
}

/// Niveau de stock d'un produit dans un magasin (calculé).
@immutable
class NiveauStock {
  const NiveauStock({
    required this.produitCode,
    required this.magasinCode,
    required this.quantite,
    required this.nombre,
  });
  final String produitCode;
  final String magasinCode;
  final double quantite;
  final double nombre;
}

@immutable
class Magasin {
  const Magasin({
    this.audit = Audit.vide,
    required this.code,
    required this.nom,
    this.actif = true,
    this.systeme = false,
    this.adresse = '',
    this.telephone = '',
    this.responsableCode,
    this.observation = '',
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String nom;
  final bool actif;
  final bool systeme;
  final String adresse;
  final String telephone;
  final String? responsableCode;
  final String observation;

  Magasin copyWith({
    String? nom,
    bool? actif,
    String? adresse,
    String? telephone,
    String? Function()? responsableCode,
    String? observation,
  }) => Magasin(
    audit: audit,
    code: code,
    nom: nom ?? this.nom,
    actif: actif ?? this.actif,
    systeme: systeme,
    adresse: adresse ?? this.adresse,
    telephone: telephone ?? this.telephone,
    responsableCode: responsableCode == null ? this.responsableCode : responsableCode(),
    observation: observation ?? this.observation,
  );

  factory Magasin.depuisLigne(Map<String, Object?> r) => Magasin(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    nom: r['nom'] as String,
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    adresse: (r['adresse'] as String?) ?? '',
    telephone: (r['telephone'] as String?) ?? '',
    responsableCode: r['responsable_code'] as String?,
    observation: (r['observation'] as String?) ?? '',
  );
  @override
  bool operator ==(Object other) =>
      other is Magasin &&
      other.code == code &&
      other.nom == nom &&
      other.actif == actif &&
      other.adresse == adresse &&
      other.telephone == telephone &&
      other.responsableCode == responsableCode &&
      other.observation == observation;
  @override
  int get hashCode => Object.hash(code, nom, actif, adresse, telephone, responsableCode, observation);
}

/// Annulation douce d'un document (état, auteur, motif, date).
@immutable
class Annulation {
  const Annulation({required this.par, required this.motif, required this.date});
  final String par;
  final String motif;
  final DateTime date;

  static Annulation? depuisLigne(Map<String, Object?> r) => (r['actif'] as int? ?? 1) == 1
      ? null
      : Annulation(
          par: (r['annule_par'] as String?) ?? '',
          motif: (r['motif_annulation'] as String?) ?? '',
          date: DateTime.tryParse((r['date_annulation'] as String?) ?? '')?.toLocal() ?? DateTime(2000),
        );
}

/// Ligne de document de stock (transfert, sortie, inventaire).
@immutable
class LigneStock {
  const LigneStock({required this.produitCode, required this.quantite, this.nombre = 0, this.prix = 0});
  final String produitCode;
  final double quantite;
  final double nombre;

  /// Prix unitaire figé (prix d'achat pour une sortie, prix estimé pour une liste de besoins).
  final double prix;
  double get montant => quantite * prix;
  @override
  bool operator ==(Object other) =>
      other is LigneStock &&
      other.produitCode == produitCode &&
      other.quantite == quantite &&
      other.nombre == nombre &&
      other.prix == prix;
  @override
  int get hashCode => Object.hash(produitCode, quantite, nombre, prix);
}

/// Transfert entre magasins (TRM).
@immutable
class TransfertStock {
  const TransfertStock({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    required this.magasinSource,
    required this.magasinDestination,
    required this.utilisateurCode,
    this.commentaire,
    this.lignes = const [],
    this.annulation,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final DateTime date;
  final String magasinSource;
  final String magasinDestination;
  final String utilisateurCode;
  final String? commentaire;
  final List<LigneStock> lignes;
  final Annulation? annulation;
  bool get actif => annulation == null;
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);
}

/// Statuts de besoin (valeur stockée FR, §13).
class StatutsBesoin {
  const StatutsBesoin._();
  static const String enAttente = 'En Attente';
  static const String commande = 'Commande';
  static const String disponible = 'Disponible';
  static const List<String> tous = [enAttente, commande, disponible];
}

/// Liste de besoins (`BL…`) : bon de commande fournisseur, ses lignes (produit, quantité, prix estimé).
@immutable
class Besoin {
  const Besoin({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    required this.fournisseurCode,
    required this.utilisateurCode,
    this.statut = StatutsBesoin.enAttente,
    this.dateLivraison,
    this.observation,
    this.lignes = const [],
    this.annulation,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final DateTime date;
  final String fournisseurCode;
  final String utilisateurCode;
  final String statut;
  final DateTime? dateLivraison;
  final String? observation;
  final List<LigneStock> lignes;
  final Annulation? annulation;
  bool get actif => annulation == null;
  double get montant => lignes.fold(0.0, (s, l) => s + l.montant);
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);

  Besoin copyWith({String? statut}) => Besoin(
    audit: audit,
    code: code,
    date: date,
    fournisseurCode: fournisseurCode,
    utilisateurCode: utilisateurCode,
    statut: statut ?? this.statut,
    dateLivraison: dateLivraison,
    observation: observation,
    lignes: lignes,
    annulation: annulation,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'fournisseur_code': fournisseurCode,
    'statut': statut,
    'date_livraison': dateLivraison?.toIso8601String(),
    'observation': observation,
    'utilisateur_code': utilisateurCode,
  };
  factory Besoin.depuisLigne(Map<String, Object?> r, List<LigneStock> lignes) => Besoin(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    fournisseurCode: r['fournisseur_code'] as String,
    statut: r['statut'] as String,
    dateLivraison: DateTime.tryParse((r['date_livraison'] as String?) ?? ''),
    observation: r['observation'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    lignes: lignes,
    annulation: Annulation.depuisLigne(r),
  );
}

/// Sortie de stock hors vente (motifs §13 : Casse, Périmé, Perte/vol, Consommation interne, Don, Échantillon).
@immutable
class SortieStock {
  const SortieStock({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    required this.magasinCode,
    required this.motif,
    required this.utilisateurCode,
    this.commentaire,
    this.lignes = const [],
    this.annulation,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final DateTime date;
  final String magasinCode;
  final String motif;
  final String utilisateurCode;
  final String? commentaire;
  final List<LigneStock> lignes;
  final Annulation? annulation;
  bool get actif => annulation == null;
  double get valeur => lignes.fold(0.0, (s, l) => s + l.montant);
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);
}
