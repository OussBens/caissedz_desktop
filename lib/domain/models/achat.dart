import 'package:flutter/foundation.dart';

class StatutsAchat {
  const StatutsAchat._();
  static const String valide = 'Validé';
  static const String annule = 'Annulé';
}

/// Ligne d'achat (entrée fournisseur).
@immutable
class AchatLigne {
  const AchatLigne({
    required this.produitCode,
    required this.designation,
    required this.quantite,
    this.nombre = 0,
    required this.prixAchat,
    required this.total,
  });
  final String produitCode;
  final String designation;
  final double quantite;
  final double nombre;
  final double prixAchat;
  final double total;

  factory AchatLigne.depuisLigne(Map<String, Object?> r) => AchatLigne(
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    nombre: (r['nombre'] as num).toDouble(),
    prixAchat: (r['prix_achat'] as num).toDouble(),
    total: (r['total'] as num).toDouble(),
  );
}

/// Achat / entrée fournisseur (ACH) : alimente le stock, crée une dette fournisseur.
@immutable
class Achat {
  const Achat({
    required this.code,
    required this.date,
    required this.fournisseurCode,
    required this.magasinCode,
    required this.utilisateurCode,
    this.reference,
    required this.total,
    this.verse = 0,
    this.reste = 0,
    this.statut = StatutsAchat.valide,
    this.source = 'Manuel',
    this.commentaire,
    this.lignes = const [],
  });
  final String code;
  final DateTime date;
  final String fournisseurCode;
  final String magasinCode;
  final String utilisateurCode;
  final String? reference;
  final double total;
  final double verse;
  final double reste;
  final String statut;

  /// `Manuel` ou `Smart Scan` (valeur stockée FR).
  final String source;
  final String? commentaire;
  final List<AchatLigne> lignes;

  factory Achat.depuisLigne(Map<String, Object?> r, [List<AchatLigne> lignes = const []]) => Achat(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    fournisseurCode: r['fournisseur_code'] as String,
    magasinCode: r['magasin_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    reference: r['reference'] as String?,
    total: (r['total'] as num).toDouble(),
    verse: (r['verse'] as num).toDouble(),
    reste: (r['reste'] as num).toDouble(),
    statut: r['statut'] as String,
    source: r['source'] as String,
    commentaire: r['commentaire'] as String?,
    lignes: lignes,
  );
}

/// Ligne demandée pour un achat.
@immutable
class DemandeAchatLigne {
  const DemandeAchatLigne({
    required this.produitCode,
    required this.quantite,
    this.nombre = 0,
    required this.prixAchat,
    this.nouveauPrixVente,
  });
  final String produitCode;
  final double quantite;
  final double nombre;
  final double prixAchat;

  /// Nouveau prix de vente à appliquer au produit (facultatif).
  final double? nouveauPrixVente;
}
