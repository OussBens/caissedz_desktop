import 'package:flutter/foundation.dart';

import '../calculs_prix.dart';
import 'audit.dart';
import 'stock.dart';

/// Types de documents commerciaux clients (valeur stockée FR).
abstract final class TypesDocumentClient {
  /// Devis (DEV) : offre de prix, sans effet sur le stock ni sur le solde.
  static const String devis = 'Devis';

  /// Facture proforma (PRO) : même forme qu'une facture, sans valeur comptable.
  static const String proforma = 'Proforma';

  /// Bon de commande client (BCC) : livré en une ou plusieurs fois par des bons de livraison.
  static const String commande = 'Commande';
  static const List<String> tous = [devis, proforma, commande];
}

/// Statuts d'un document client. `En cours`, `Accepté`, `Refusé` et `Transformé` sont stockés ; pour une commande,
/// `Partiellement livrée` / `Livrée` sont calculés d'après ses bons de livraison ; `Expiré` (devis / proforma en
/// cours après la date de validité) et `Annulé` sont calculés.
abstract final class StatutsDocumentClient {
  static const String enCours = 'En cours';
  static const String accepte = 'Accepté';
  static const String refuse = 'Refusé';
  static const String transforme = 'Transformé';
  static const String expire = 'Expiré';
  static const String partielle = 'Partiellement livrée';
  static const String livree = 'Livrée';
  static const String annule = 'Annulé';
}

/// Statuts d'une commande fournisseur (tous calculés sauf `Soldée`, stockée).
abstract final class StatutsCommandeFournisseur {
  static const String enCours = 'En cours';
  static const String partielle = 'Partiellement reçue';
  static const String recue = 'Reçue';
  static const String soldee = 'Soldée';
  static const String annulee = 'Annulée';
}

/// Ligne d'un devis, d'une proforma ou d'une commande client : prix TTC, TVA figée à la saisie.
@immutable
class DocumentLigne {
  const DocumentLigne({
    this.ordre = 0,
    required this.produitCode,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    this.tauxTva = 0,
    this.montantHt = 0,
    this.montantTva = 0,
    required this.total,
    this.livre = 0,
  });

  final int ordre;
  final String produitCode;
  final String designation;
  final double quantite;

  /// Prix unitaire TTC.
  final double prixUnitaire;
  final double tauxTva;
  final double montantHt;
  final double montantTva;
  final double total;

  /// Quantité déjà livrée (commande, calculée d'après les bons de livraison dont la vente est valide).
  final double livre;

  double get reste => (quantite - livre) < 1e-9 ? 0 : CalculsPrix.arrondir(quantite - livre);

  DocumentLigne copyWith({double? livre}) => DocumentLigne(
    ordre: ordre,
    produitCode: produitCode,
    designation: designation,
    quantite: quantite,
    prixUnitaire: prixUnitaire,
    tauxTva: tauxTva,
    montantHt: montantHt,
    montantTva: montantTva,
    total: total,
    livre: livre ?? this.livre,
  );

  factory DocumentLigne.depuisLigne(Map<String, Object?> r) => DocumentLigne(
    ordre: r['ordre'] as int,
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    prixUnitaire: (r['prix_unitaire'] as num).toDouble(),
    tauxTva: (r['taux_tva'] as num).toDouble(),
    montantHt: (r['montant_ht'] as num).toDouble(),
    montantTva: (r['montant_tva'] as num).toDouble(),
    total: (r['total'] as num).toDouble(),
  );
}

/// Devis (DEV), facture proforma (PRO) ou bon de commande client (BCC).
@immutable
class DocumentClient {
  const DocumentClient({
    this.audit = Audit.vide,
    required this.code,
    required this.type,
    required this.date,
    required this.clientCode,
    this.validite,
    this.statutStocke = StatutsDocumentClient.enCours,
    this.origineCode,
    this.observation,
    required this.utilisateurCode,
    this.annulation,
    this.lignes = const [],
    this.livraisons = const [],
  });

  final Audit audit;
  final String code;
  final String type;
  final DateTime date;
  final String clientCode;

  /// Date de validité d'un devis / d'une proforma.
  final DateTime? validite;
  final String statutStocke;

  /// Devis ou proforma transformé en cette commande.
  final String? origineCode;
  final String? observation;
  final String utilisateurCode;
  final Annulation? annulation;
  final List<DocumentLigne> lignes;

  /// Bons de livraison actifs d'une commande.
  final List<String> livraisons;

  bool get actif => annulation == null;
  bool get estCommande => type == TypesDocumentClient.commande;
  double get total => lignes.fold(0.0, (s, l) => s + l.total);
  double get totalHt => lignes.fold(0.0, (s, l) => s + l.montantHt);
  double get totalTva => lignes.fold(0.0, (s, l) => s + l.montantTva);
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);
  bool get dejaLivree => lignes.any((l) => l.livre > 1e-9);
  bool get toutLivre => lignes.isNotEmpty && lignes.every((l) => l.reste <= 1e-9);

  /// Statut affiché.
  String get statut {
    if (!actif) return StatutsDocumentClient.annule;
    if (estCommande) {
      if (toutLivre) return StatutsDocumentClient.livree;
      if (dejaLivree) return StatutsDocumentClient.partielle;
      return StatutsDocumentClient.enCours;
    }
    final v = validite;
    if (statutStocke == StatutsDocumentClient.enCours && v != null) {
      final aujourdhui = DateTime.now();
      if (DateTime(v.year, v.month, v.day).isBefore(DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day))) {
        return StatutsDocumentClient.expire;
      }
    }
    return statutStocke;
  }

  /// Modifiable : actif, en cours (ou expiré), et pour une commande rien de livré.
  bool get modifiable =>
      actif &&
      (statutStocke == StatutsDocumentClient.enCours || statutStocke == StatutsDocumentClient.accepte) &&
      !dejaLivree;

  DocumentClient copyWith({List<DocumentLigne>? lignes, List<String>? livraisons}) => DocumentClient(
    audit: audit,
    code: code,
    type: type,
    date: date,
    clientCode: clientCode,
    validite: validite,
    statutStocke: statutStocke,
    origineCode: origineCode,
    observation: observation,
    utilisateurCode: utilisateurCode,
    annulation: annulation,
    lignes: lignes ?? this.lignes,
    livraisons: livraisons ?? this.livraisons,
  );

  factory DocumentClient.depuisLigne(Map<String, Object?> r) => DocumentClient(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    type: r['type'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    clientCode: r['client_code'] as String,
    validite: DateTime.tryParse((r['validite'] as String?) ?? '')?.toLocal(),
    statutStocke: r['statut'] as String,
    origineCode: r['origine_code'] as String?,
    observation: r['observation'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    annulation: Annulation.depuisLigne(r),
  );
}

/// Ligne d'un bon de livraison.
@immutable
class BonLivraisonLigne {
  const BonLivraisonLigne({
    this.ordre = 0,
    this.ordreCommande,
    required this.produitCode,
    required this.designation,
    required this.quantite,
  });
  final int ordre;

  /// Ligne de la commande livrée (`null` pour le BL d'une vente de caisse).
  final int? ordreCommande;
  final String produitCode;
  final String designation;
  final double quantite;

  factory BonLivraisonLigne.depuisLigne(Map<String, Object?> r) => BonLivraisonLigne(
    ordre: r['ordre'] as int,
    ordreCommande: r['ordre_commande'] as int?,
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
  );
}

/// Bon de livraison (LIV), distinct du ticket : il accompagne la marchandise. Le stock et le solde sont portés par
/// la vente liée ; un BL est annulé avec sa vente.
@immutable
class BonLivraison {
  const BonLivraison({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    this.commandeCode,
    required this.venteCode,
    required this.clientCode,
    required this.magasinCode,
    required this.utilisateurCode,
    this.observation,
    this.lignes = const [],
    this.venteAnnulee = false,
    this.total = 0,
  });

  final Audit audit;
  final String code;
  final DateTime date;
  final String? commandeCode;
  final String venteCode;
  final String clientCode;
  final String magasinCode;
  final String utilisateurCode;
  final String? observation;
  final List<BonLivraisonLigne> lignes;
  final bool venteAnnulee;

  /// Total TTC de la vente liée.
  final double total;

  bool get actif => !venteAnnulee;
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);

  factory BonLivraison.depuisLigne(Map<String, Object?> r, [List<BonLivraisonLigne> lignes = const []]) => BonLivraison(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    commandeCode: r['commande_code'] as String?,
    venteCode: r['vente_code'] as String,
    clientCode: r['client_code'] as String,
    magasinCode: r['magasin_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    observation: r['observation'] as String?,
    lignes: lignes,
    venteAnnulee: r['vente_statut'] == 'Annulée',
    total: ((r['vente_total'] as num?) ?? 0).toDouble(),
  );
}

/// Ligne d'une commande fournisseur.
@immutable
class CommandeFournisseurLigne {
  const CommandeFournisseurLigne({
    this.ordre = 0,
    required this.produitCode,
    required this.designation,
    required this.quantite,
    this.prix = 0,
    this.recu = 0,
  });
  final int ordre;
  final String produitCode;
  final String designation;
  final double quantite;

  /// Prix d'achat unitaire prévu.
  final double prix;

  /// Quantité déjà reçue (calculée d'après les entrées valides liées à la commande).
  final double recu;

  double get montant => CalculsPrix.arrondir(quantite * prix);
  double get reste => (quantite - recu) < 1e-9 ? 0 : CalculsPrix.arrondir(quantite - recu);

  CommandeFournisseurLigne copyWith({double? recu}) => CommandeFournisseurLigne(
    ordre: ordre,
    produitCode: produitCode,
    designation: designation,
    quantite: quantite,
    prix: prix,
    recu: recu ?? this.recu,
  );

  factory CommandeFournisseurLigne.depuisLigne(Map<String, Object?> r) => CommandeFournisseurLigne(
    ordre: r['ordre'] as int,
    produitCode: r['produit_code'] as String,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    prix: (r['prix'] as num).toDouble(),
  );
}

/// Bon de commande fournisseur (BCF), réceptionné en une ou plusieurs entrées (ENT).
@immutable
class CommandeFournisseur {
  const CommandeFournisseur({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    required this.fournisseurCode,
    required this.magasinCode,
    this.dateLivraison,
    this.besoinCode,
    this.soldee = false,
    this.observation,
    required this.utilisateurCode,
    this.annulation,
    this.lignes = const [],
    this.receptions = const [],
  });

  final Audit audit;
  final String code;
  final DateTime date;
  final String fournisseurCode;
  final String magasinCode;

  /// Date de livraison prévue.
  final DateTime? dateLivraison;
  final String? besoinCode;

  /// Reliquat abandonné : la commande n'attend plus rien.
  final bool soldee;
  final String? observation;
  final String utilisateurCode;
  final Annulation? annulation;
  final List<CommandeFournisseurLigne> lignes;

  /// Entrées valides qui ont réceptionné cette commande.
  final List<String> receptions;

  bool get actif => annulation == null;
  double get total => lignes.fold(0.0, (s, l) => s + l.montant);
  double get quantite => lignes.fold(0.0, (s, l) => s + l.quantite);
  double get recu => lignes.fold(0.0, (s, l) => s + l.recu);
  bool get dejaRecue => lignes.any((l) => l.recu > 1e-9);
  bool get toutRecu => lignes.isNotEmpty && lignes.every((l) => l.reste <= 1e-9);

  /// Peut encore être réceptionnée.
  bool get ouverte => actif && !soldee && !toutRecu;

  String get statut {
    if (!actif) return StatutsCommandeFournisseur.annulee;
    if (toutRecu) return StatutsCommandeFournisseur.recue;
    if (soldee) return StatutsCommandeFournisseur.soldee;
    if (dejaRecue) return StatutsCommandeFournisseur.partielle;
    return StatutsCommandeFournisseur.enCours;
  }

  CommandeFournisseur copyWith({List<CommandeFournisseurLigne>? lignes, List<String>? receptions}) =>
      CommandeFournisseur(
        audit: audit,
        code: code,
        date: date,
        fournisseurCode: fournisseurCode,
        magasinCode: magasinCode,
        dateLivraison: dateLivraison,
        besoinCode: besoinCode,
        soldee: soldee,
        observation: observation,
        utilisateurCode: utilisateurCode,
        annulation: annulation,
        lignes: lignes ?? this.lignes,
        receptions: receptions ?? this.receptions,
      );

  factory CommandeFournisseur.depuisLigne(Map<String, Object?> r) => CommandeFournisseur(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    fournisseurCode: r['fournisseur_code'] as String,
    magasinCode: r['magasin_code'] as String,
    dateLivraison: DateTime.tryParse((r['date_livraison'] as String?) ?? '')?.toLocal(),
    besoinCode: r['besoin_code'] as String?,
    soldee: (r['soldee'] as int? ?? 0) == 1,
    observation: r['observation'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    annulation: Annulation.depuisLigne(r),
  );
}
