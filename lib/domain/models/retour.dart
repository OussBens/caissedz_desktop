import 'package:flutter/foundation.dart';

/// Ligne d'un retour (le DS v2.2 saisit un produit par retour).
@immutable
class RetourLigne {
  const RetourLigne({
    required this.produitCode,
    required this.designation,
    required this.quantite,
    this.nombre = 0,
    required this.prixUnitaire,
    required this.total,
    this.prixAchat = 0,
  });
  final String produitCode;
  final String designation;
  final double quantite;
  final double nombre;

  /// Prix appliqué au retour : prix de vente net (client) ou prix d'achat (fournisseur).
  final double prixUnitaire;
  final double total;
  final double prixAchat;

  factory RetourLigne.depuisLigne(Map<String, Object?> r) => RetourLigne(
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    nombre: (r['nombre'] as num).toDouble(),
    prixUnitaire: (r['prix_unitaire'] as num).toDouble(),
    total: (r['total'] as num).toDouble(),
    prixAchat: (r['prix_achat'] as num?)?.toDouble() ?? 0,
  );
}

/// Règlements d'un retour (valeur stockée). Client : Espèces / Carte (remboursement) ou Avoir ;
/// fournisseur : Avoir (« Déduit du crédit ») ou Espèces (« Remboursement espèces »).
class ReglementsRetour {
  const ReglementsRetour._();
  static const String especes = 'Espèces';
  static const String carte = 'Carte';
  static const String avoir = 'Avoir';
  static const List<String> client = [especes, avoir, carte];
  static const List<String> fournisseur = [avoir, especes];
}

/// Retour (RET, §7 `retours`, §9.3) : client (depuis un panier, remet en stock et rembourse ou crée un
/// avoir) ou fournisseur (depuis une entrée, sort du stock et déduit la dette ou est remboursé).
@immutable
class Retour {
  const Retour({
    required this.code,
    required this.date,
    this.type = TypesTiers.client,
    required this.documentCode,
    this.clientCode,
    this.fournisseurCode,
    required this.magasinCode,
    required this.utilisateurCode,
    required this.total,
    this.rembourse = 0,
    this.reglement = ReglementsRetour.especes,
    this.remiseEnStock = true,
    this.numeroSerie,
    this.motif,
    this.versementCode,
    this.actif = true,
    this.annuleLe,
    this.annulePar,
    this.motifAnnulation,
    this.lignes = const [],
  });
  final String code;
  final DateTime date;

  /// [TypesTiers.client] ou [TypesTiers.fournisseur].
  final String type;

  /// Pièce d'origine : panier (client) ou entrée (fournisseur).
  final String documentCode;
  final String? clientCode;
  final String? fournisseurCode;
  final String magasinCode;
  final String utilisateurCode;
  final double total;

  /// Montant remboursé (versement verrouillé lié) ; le reste du total est un avoir.
  final double rembourse;
  final String reglement;
  final bool remiseEnStock;
  final String? numeroSerie;

  /// Observation (motif du retour).
  final String? motif;
  final String? versementCode;
  final bool actif;
  final DateTime? annuleLe;
  final String? annulePar;
  final String? motifAnnulation;
  final List<RetourLigne> lignes;

  bool get estClient => type == TypesTiers.client;
  String get tiersCode => (estClient ? clientCode : fournisseurCode) ?? '';
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);
  RetourLigne? get ligne => lignes.firstOrNull;

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'type': type,
    'document_code': documentCode,
    'client_code': clientCode,
    'fournisseur_code': fournisseurCode,
    'magasin_code': magasinCode,
    'utilisateur_code': utilisateurCode,
    'total': total,
    'rembourse': rembourse,
    'reglement': reglement,
    'remise_en_stock': remiseEnStock ? 1 : 0,
    'numero_serie': numeroSerie,
    'motif': motif,
    'versement_code': versementCode,
    'etat': actif ? 1 : 0,
    'annule_le': annuleLe?.toUtc().toIso8601String(),
    'annule_par': annulePar,
    'motif_annulation': motifAnnulation,
  };

  factory Retour.depuisLigne(Map<String, Object?> r, [List<RetourLigne> lignes = const []]) => Retour(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    type: r['type'] as String? ?? TypesTiers.client,
    documentCode: r['document_code'] as String,
    clientCode: r['client_code'] as String?,
    fournisseurCode: r['fournisseur_code'] as String?,
    magasinCode: r['magasin_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    total: (r['total'] as num).toDouble(),
    rembourse: (r['rembourse'] as num).toDouble(),
    reglement: r['reglement'] as String? ?? ReglementsRetour.especes,
    remiseEnStock: (r['remise_en_stock'] as int? ?? 1) == 1,
    numeroSerie: r['numero_serie'] as String?,
    motif: r['motif'] as String?,
    versementCode: r['versement_code'] as String?,
    actif: (r['etat'] as int? ?? 1) == 1,
    annuleLe: r['annule_le'] == null ? null : DateTime.parse(r['annule_le'] as String).toLocal(),
    annulePar: r['annule_par'] as String?,
    motifAnnulation: r['motif_annulation'] as String?,
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

/// Types de versement (valeur stockée FR, référentiel `typeVersement`).
class TypesVersement {
  const TypesVersement._();
  static const String paiement = 'Paiement';
  static const String avancement = 'Avancement';
  static const String acompte = 'Acompte';
  static const String remboursement = 'Remboursement';
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
    this.type = TypesVersement.paiement,
    this.actif = true,
    this.annuleLe,
    this.annulePar,
    this.motifAnnulation,
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

  /// Type de versement (référentiel `typeVersement` : Paiement, Avancement, Remboursement…).
  final String type;

  /// `false` : versement annulé (exclu des soldes et du journal de caisse).
  final bool actif;
  final DateTime? annuleLe;
  final String? annulePar;
  final String? motifAnnulation;

  /// Versement « retour » : sens inverse du paiement habituel du tiers (argent rendu au client,
  /// remboursé par le fournisseur).
  bool get estRetour =>
      tiersType == TypesTiers.client ? sens == SensVersement.decaissement : sens == SensVersement.encaissement;

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
    'type': type,
    'etat': actif ? 1 : 0,
    'annule_le': annuleLe?.toUtc().toIso8601String(),
    'annule_par': annulePar,
    'motif_annulation': motifAnnulation,
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
    type: (r['type'] as String?) ?? TypesVersement.paiement,
    actif: ((r['etat'] as int?) ?? 1) == 1,
    annuleLe: r['annule_le'] == null ? null : DateTime.parse(r['annule_le'] as String).toLocal(),
    annulePar: r['annule_par'] as String?,
    motifAnnulation: r['motif_annulation'] as String?,
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
