import 'package:flutter/foundation.dart';

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
  const Magasin({required this.code, required this.nom, this.actif = true, this.systeme = false, this.adresse = ''});
  final String code;
  final String nom;
  final bool actif;
  final bool systeme;
  final String adresse;
  factory Magasin.depuisLigne(Map<String, Object?> r) => Magasin(
    code: r['code'] as String,
    nom: r['nom'] as String,
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    adresse: (r['adresse'] as String?) ?? '',
  );
  @override
  bool operator ==(Object other) => other is Magasin && other.code == code && other.nom == nom && other.actif == actif;
  @override
  int get hashCode => Object.hash(code, nom, actif);
}

/// Ligne de document de stock (transfert, sortie, inventaire).
@immutable
class LigneStock {
  const LigneStock({required this.produitCode, required this.quantite, this.nombre = 0});
  final String produitCode;
  final double quantite;
  final double nombre;
  @override
  bool operator ==(Object other) =>
      other is LigneStock && other.produitCode == produitCode && other.quantite == quantite && other.nombre == nombre;
  @override
  int get hashCode => Object.hash(produitCode, quantite, nombre);
}

/// Transfert entre magasins (TRM).
@immutable
class TransfertStock {
  const TransfertStock({
    required this.code,
    required this.date,
    required this.magasinSource,
    required this.magasinDestination,
    required this.utilisateurCode,
    this.commentaire,
    this.lignes = const [],
  });
  final String code;
  final DateTime date;
  final String magasinSource;
  final String magasinDestination;
  final String utilisateurCode;
  final String? commentaire;
  final List<LigneStock> lignes;
}

/// Statuts de besoin (valeur stockée FR, §13).
class StatutsBesoin {
  const StatutsBesoin._();
  static const String enAttente = 'En attente';
  static const String commande = 'Commande';
  static const String disponible = 'Disponible';
  static const List<String> tous = [enAttente, commande, disponible];
}

@immutable
class Besoin {
  const Besoin({
    required this.code,
    required this.date,
    required this.produitCode,
    required this.quantite,
    this.statut = StatutsBesoin.enAttente,
    this.magasinCode,
    this.commentaire,
    required this.utilisateurCode,
  });
  final String code;
  final DateTime date;
  final String produitCode;
  final double quantite;
  final String statut;
  final String? magasinCode;
  final String? commentaire;
  final String utilisateurCode;

  Besoin copyWith({String? statut, double? quantite, String? commentaire}) => Besoin(
    code: code,
    date: date,
    produitCode: produitCode,
    quantite: quantite ?? this.quantite,
    statut: statut ?? this.statut,
    magasinCode: magasinCode,
    commentaire: commentaire ?? this.commentaire,
    utilisateurCode: utilisateurCode,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'produit_code': produitCode,
    'quantite': quantite,
    'statut': statut,
    'magasin_code': magasinCode,
    'commentaire': commentaire,
    'utilisateur_code': utilisateurCode,
  };
  factory Besoin.depuisLigne(Map<String, Object?> r) => Besoin(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    produitCode: r['produit_code'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    statut: r['statut'] as String,
    magasinCode: r['magasin_code'] as String?,
    commentaire: r['commentaire'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
  );
}

/// Sortie de stock hors vente (motifs §13 : Casse, Périmé, Perte/vol, Consommation interne, Don, Échantillon).
@immutable
class SortieStock {
  const SortieStock({
    required this.code,
    required this.date,
    required this.magasinCode,
    required this.motif,
    required this.utilisateurCode,
    this.commentaire,
    this.lignes = const [],
  });
  final String code;
  final DateTime date;
  final String magasinCode;
  final String motif;
  final String utilisateurCode;
  final String? commentaire;
  final List<LigneStock> lignes;
}
