import 'package:flutter/foundation.dart';

/// Ligne de retour client.
@immutable
class RetourLigne {
  const RetourLigne({
    required this.produitCode,
    required this.designation,
    required this.quantite,
    this.nombre = 0,
    required this.prixUnitaire,
    required this.total,
  });
  final String produitCode;
  final String designation;
  final double quantite;
  final double nombre;
  final double prixUnitaire;
  final double total;

  factory RetourLigne.depuisLigne(Map<String, Object?> r) => RetourLigne(
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    nombre: (r['nombre'] as num).toDouble(),
    prixUnitaire: (r['prix_unitaire'] as num).toDouble(),
    total: (r['total'] as num).toDouble(),
  );
}

/// Retour client (RET) : lié à une vente, restitue le stock, crée un avoir
/// réglé par un versement verrouillé (remboursement) ou imputé.
@immutable
class Retour {
  const Retour({
    required this.code,
    required this.date,
    required this.venteCode,
    required this.clientCode,
    required this.magasinCode,
    required this.utilisateurCode,
    required this.total,
    this.rembourse = 0,
    this.motif,
    this.versementCode,
    this.lignes = const [],
  });
  final String code;
  final DateTime date;
  final String venteCode;
  final String clientCode;
  final String magasinCode;
  final String utilisateurCode;
  final double total;

  /// Montant remboursé en espèces (versement verrouillé lié).
  final double rembourse;
  final String? motif;
  final String? versementCode;
  final List<RetourLigne> lignes;

  factory Retour.depuisLigne(Map<String, Object?> r, [List<RetourLigne> lignes = const []]) => Retour(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    venteCode: r['vente_code'] as String,
    clientCode: r['client_code'] as String,
    magasinCode: r['magasin_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    total: (r['total'] as num).toDouble(),
    rembourse: (r['rembourse'] as num).toDouble(),
    motif: r['motif'] as String?,
    versementCode: r['versement_code'] as String?,
    lignes: lignes,
  );
}

/// Types de tiers d'un versement (valeur stockée FR).
class TypesTiers {
  const TypesTiers._();
  static const String client = 'Client';
  static const String fournisseur = 'Fournisseur';
}

/// Sens d'un versement : encaissement (client paie) ou décaissement (on paie / rembourse).
class SensVersement {
  const SensVersement._();
  static const String encaissement = 'Encaissement';
  static const String decaissement = 'Décaissement';
}

/// Versement (VER) : paiement d'un tiers imputé aux documents ouverts (plus ancien d'abord).
@immutable
class Versement {
  const Versement({
    required this.code,
    required this.date,
    required this.tiersType,
    required this.tiersCode,
    required this.sens,
    required this.montant,
    required this.mode,
    required this.utilisateurCode,
    this.caisseCode,
    this.reference,
    this.commentaire,
    this.retourCode,
    this.verrouille = false,
    this.imputations = const [],
  });
  final String code;
  final DateTime date;
  final String tiersType;
  final String tiersCode;
  final String sens;
  final double montant;
  final String mode;
  final String utilisateurCode;
  final String? caisseCode;
  final String? reference;
  final String? commentaire;

  /// Retour à l'origine du versement (remboursement) : le versement est alors verrouillé.
  final String? retourCode;
  final bool verrouille;
  final List<Imputation> imputations;

  double get impute => imputations.fold(0.0, (s, i) => s + i.montant);
  double get nonImpute => montant - impute;

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'tiers_type': tiersType,
    'tiers_code': tiersCode,
    'sens': sens,
    'montant': montant,
    'mode': mode,
    'utilisateur_code': utilisateurCode,
    'caisse_code': caisseCode,
    'reference': reference,
    'commentaire': commentaire,
    'retour_code': retourCode,
    'verrouille': verrouille ? 1 : 0,
  };

  factory Versement.depuisLigne(Map<String, Object?> r, [List<Imputation> imputations = const []]) => Versement(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    tiersType: r['tiers_type'] as String,
    tiersCode: r['tiers_code'] as String,
    sens: r['sens'] as String,
    montant: (r['montant'] as num).toDouble(),
    mode: r['mode'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    caisseCode: r['caisse_code'] as String?,
    reference: r['reference'] as String?,
    commentaire: r['commentaire'] as String?,
    retourCode: r['retour_code'] as String?,
    verrouille: (r['verrouille'] as int) == 1,
    imputations: imputations,
  );
}

/// Imputation d'un versement sur un document (vente ou achat).
@immutable
class Imputation {
  const Imputation({
    required this.versementCode,
    required this.documentType,
    required this.documentCode,
    required this.montant,
  });
  final String versementCode;

  /// `vente` ou `achat`.
  final String documentType;
  final String documentCode;
  final double montant;
}

/// Document ouvert d'un tiers (reste à payer > 0).
@immutable
class DocumentOuvert {
  const DocumentOuvert({
    required this.type,
    required this.code,
    required this.date,
    required this.total,
    required this.reste,
  });
  final String type;
  final String code;
  final DateTime date;
  final double total;
  final double reste;
}
