import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'stock.dart';

class StatutsAchat {
  const StatutsAchat._();
  static const String valide = 'Validé';
  static const String annule = 'Annulé';
}

/// Origine d'une entrée (valeur stockée FR) : `Smart Scan` (bon manuel scanné, N produits), `Entrée rapide`
/// (1 produit payé intégralement), `Reçu IA` (bon lu par l'IA). `Manuel` : entrées antérieures au DS v2.2.
class SourcesAchat {
  const SourcesAchat._();
  static const String smartScan = 'Smart Scan';
  static const String rapide = 'Entrée rapide';
  static const String ia = 'Reçu IA';
  static const String manuel = 'Manuel';
}

/// Mise à jour du prix d'achat des produits reçus (`Mise à jour prix` du DS).
enum MajPrixAchat { garder, moyenPondere, dernier }

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
    this.annulation,
    this.besoinCode,
    this.nbVersements = 0,
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
  final Annulation? annulation;

  /// Liste de besoins livrée par cette entrée (passée « Disponible »).
  final String? besoinCode;

  /// Versements imputés à l'entrée (calculé).
  final int nbVersements;

  bool get actif => statut != StatutsAchat.annule;
  double get quantite => lignes.fold(0.0, (a, l) => a + l.quantite);

  /// Statut affiché (`StatusBadge`) : `annule`, `paye`, `partiel` ou `credit`.
  String get statutPaiement => !actif
      ? 'annule'
      : reste <= 0.005
      ? 'paye'
      : verse > 0.005
      ? 'partiel'
      : 'credit';

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
    annulation: r['statut'] == StatutsAchat.annule ? Annulation.depuisLigne({...r, 'actif': 0}) : null,
    besoinCode: r['besoin_code'] as String?,
    nbVersements: (r['nb_versements'] as int?) ?? 0,
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
    this.repartition,
  });
  final String produitCode;
  final double quantite;
  final double nombre;
  final double prixAchat;

  /// Nouveau prix de vente à appliquer au produit (facultatif).
  final double? nouveauPrixVente;

  /// Répartition de la quantité entre magasins (code → quantité) ; `null` : tout au magasin de l'entrée.
  final Map<String, double>? repartition;
}

/// Statuts d'un bon de réception (valeur stockée FR).
class StatutsBon {
  const StatutsBon._();
  static const String recu = 'Reçu';
  static const String traite = 'Traité';
  static const String erreur = 'Erreur';
  static const List<String> tous = [recu, traite, erreur];
}

/// Ligne détectée par l'IA sur un bon (conservée en JSON dans `bon_reception.lignes_json`).
@immutable
class LigneDetectee {
  const LigneDetectee({
    required this.designation,
    this.codeBarres,
    required this.quantite,
    required this.prixAchat,
    this.confiance,
  });
  final String designation;
  final String? codeBarres;
  final double quantite;
  final double prixAchat;

  /// Confiance de la lecture (0–100), si le serveur la renvoie.
  final double? confiance;

  Map<String, Object?> versJson() => {
    'designation': designation,
    'code_barres': codeBarres,
    'quantite': quantite,
    'prix_achat': prixAchat,
    'confiance': confiance,
  };

  factory LigneDetectee.depuisJson(Map<dynamic, dynamic> j) => LigneDetectee(
    designation: (j['designation'] ?? '').toString(),
    codeBarres: j['code_barres']?.toString(),
    quantite: ((j['quantite'] as num?) ?? 1).toDouble(),
    prixAchat: ((j['prix_achat'] as num?) ?? 0).toDouble(),
    confiance: (j['confiance'] as num?)?.toDouble(),
  );
}

/// Bon de réception (`BON…`, §7.5) : photo ou PDF d'une facture fournisseur en file d'attente pour l'IA.
@immutable
class BonReception {
  const BonReception({
    required this.code,
    required this.date,
    required this.fichier,
    this.chemin,
    this.fournisseurCode,
    this.fournisseurDetecte,
    this.numBon,
    this.lignes = const [],
    this.statut = StatutsBon.recu,
    this.commentaire,
    required this.utilisateurCode,
    this.traitePar,
    this.achatCode,
  });
  final String code;
  final DateTime date;
  final String fichier;
  final String? chemin;
  final String? fournisseurCode;
  final String? fournisseurDetecte;
  final String? numBon;
  final List<LigneDetectee> lignes;
  final String statut;
  final String? commentaire;
  final String utilisateurCode;
  final String? traitePar;
  final String? achatCode;

  /// Statut affiché (`StatusBadge`) : `recu`, `traite` ou `erreur`.
  String get statutDs => switch (statut) {
    StatutsBon.traite => 'traite',
    StatutsBon.erreur => 'erreur',
    _ => 'recu',
  };

  factory BonReception.depuisLigne(Map<String, Object?> r) {
    final json = r['lignes_json'] as String?;
    return BonReception(
      code: r['code']! as String,
      date: DateTime.parse(r['date_reception']! as String).toLocal(),
      fichier: r['fichier']! as String,
      chemin: r['chemin_photo'] as String?,
      fournisseurCode: r['fournisseur_code'] as String?,
      fournisseurDetecte: r['fournisseur_detecte'] as String?,
      numBon: r['num_bon'] as String?,
      lignes: json == null || json.isEmpty
          ? const []
          : [for (final l in (jsonDecode(json) as List).cast<Map<dynamic, dynamic>>()) LigneDetectee.depuisJson(l)],
      statut: r['statut']! as String,
      commentaire: r['commentaire'] as String?,
      utilisateurCode: r['utilisateur_code']! as String,
      traitePar: r['traite_par_code'] as String?,
      achatCode: r['achat_code'] as String?,
    );
  }
}
