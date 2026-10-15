import 'package:flutter/foundation.dart';

import 'audit.dart';
import 'panier.dart';

class StatutsVente {
  const StatutsVente._();
  static const String validee = 'Validée';
  static const String annulee = 'Annulée';
}

class StatutsSession {
  const StatutsSession._();
  static const String ouverte = 'Ouverte';
  static const String fermee = 'Fermée';
}

/// Session de caisse (obligatoire pour encaisser).
@immutable
class SessionCaisse {
  const SessionCaisse({
    this.audit = Audit.vide,
    required this.code,
    required this.caisseCode,
    required this.utilisateurCode,
    required this.ouverteLe,
    this.fermeeLe,
    required this.fondInitial,
    this.montantFermeture,
    this.ecart,
    this.statut = StatutsSession.ouverte,
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String caisseCode;
  final String utilisateurCode;
  final DateTime ouverteLe;
  final DateTime? fermeeLe;
  final double fondInitial;
  final double? montantFermeture;
  final double? ecart;
  final String statut;
  bool get estOuverte => statut == StatutsSession.ouverte;

  factory SessionCaisse.depuisLigne(Map<String, Object?> r) => SessionCaisse(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    caisseCode: r['caisse_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    ouverteLe: DateTime.parse(r['ouverte_le'] as String).toLocal(),
    fermeeLe: r['fermee_le'] == null ? null : DateTime.parse(r['fermee_le'] as String).toLocal(),
    fondInitial: (r['fond_initial'] as num).toDouble(),
    montantFermeture: (r['montant_fermeture'] as num?)?.toDouble(),
    ecart: (r['ecart'] as num?)?.toDouble(),
    statut: r['statut'] as String,
  );
}

/// Ligne de vente enregistrée.
@immutable
class VenteLigne {
  const VenteLigne({
    required this.ordre,
    required this.produitCode,
    this.colisCode,
    this.packCode,
    this.composantPack = false,
    required this.designation,
    required this.quantite,
    this.nombre = 0,
    required this.uniteVente,
    required this.prixUnitaire,
    required this.remise,
    required this.total,
    this.prixAchat = 0,
    this.totalAchat = 0,
  });
  final int ordre;
  final String produitCode;
  final String? colisCode;
  final String? packCode;

  /// Ligne d'un produit issu d'un pack éclaté (quantité en unités du produit) ; `false` pour les anciennes
  /// lignes de pack (quantité = nombre de packs, composants déduits du pack).
  final bool composantPack;
  final String designation;
  final double quantite;
  final double nombre;
  final String uniteVente;
  final double prixUnitaire;
  final double remise;
  final double total;

  /// Coût d'achat unitaire figé à la vente et coût total de la ligne (§7.4, marges).
  final double prixAchat;
  final double totalAchat;

  Map<String, Object?> versLigne(String venteCode) => {
    'vente_code': venteCode,
    'ordre': ordre,
    'produit_code': produitCode,
    'colis_code': colisCode,
    'pack_code': packCode,
    'composant_pack': composantPack ? 1 : 0,
    'designation': designation,
    'quantite': quantite,
    'nombre': nombre,
    'unite_vente': uniteVente,
    'prix_unitaire': prixUnitaire,
    'remise': remise,
    'total': total,
    'prix_achat': prixAchat,
    'total_achat': totalAchat,
  };
  factory VenteLigne.depuisLigne(Map<String, Object?> r) => VenteLigne(
    ordre: r['ordre'] as int,
    produitCode: r['produit_code'] as String,
    colisCode: r['colis_code'] as String?,
    packCode: r['pack_code'] as String?,
    composantPack: ((r['composant_pack'] as int?) ?? 0) == 1,
    designation: r['designation'] as String,
    quantite: (r['quantite'] as num).toDouble(),
    nombre: (r['nombre'] as num).toDouble(),
    uniteVente: r['unite_vente'] as String,
    prixUnitaire: (r['prix_unitaire'] as num).toDouble(),
    remise: (r['remise'] as num).toDouble(),
    total: (r['total'] as num).toDouble(),
    prixAchat: ((r['prix_achat'] as num?) ?? 0).toDouble(),
    totalAchat: ((r['total_achat'] as num?) ?? 0).toDouble(),
  );
  Map<String, Object?> versCanonique() => {
    'o': ordre,
    'p': produitCode,
    'q': quantite,
    'n': nombre,
    'pu': prixUnitaire,
    'r': remise,
    't': total,
  };
}

/// Vente enregistrée (ticket scellé).
@immutable
class Vente {
  const Vente({
    this.audit = Audit.vide,
    required this.code,
    required this.date,
    required this.sessionCode,
    required this.caisseCode,
    required this.magasinCode,
    required this.clientCode,
    required this.utilisateurCode,
    required this.totalBrut,
    required this.totalRemise,
    required this.totalNet,
    required this.verse,
    required this.reste,
    this.pointsGagnes = 0,
    this.pointsUtilises = 0,
    this.statut = StatutsVente.validee,
    required this.hash,
    required this.hashPrecedent,
    this.lignes = const [],
    this.paiements = const [],
    this.commentaire,
    this.typePanier = 'Ticket',
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final DateTime date;
  final String sessionCode;
  final String caisseCode;
  final String magasinCode;
  final String clientCode;
  final String utilisateurCode;
  final double totalBrut;
  final double totalRemise;
  final double totalNet;
  final double verse;

  /// Reste dû par le client (vente à crédit) ; 0 si soldée.
  final double reste;
  final int pointsGagnes;
  final int pointsUtilises;
  final String statut;
  final String hash;
  final String hashPrecedent;
  final List<VenteLigne> lignes;
  final List<Paiement> paiements;
  final String? commentaire;

  /// Type de panier (référentiel `typePannier`) ; hors document scellé.
  final String typePanier;

  double get monnaie => (verse - totalNet) > 0 ? verse - totalNet : 0;

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'session_code': sessionCode,
    'caisse_code': caisseCode,
    'magasin_code': magasinCode,
    'client_code': clientCode,
    'utilisateur_code': utilisateurCode,
    'total_brut': totalBrut,
    'total_remise': totalRemise,
    'total_net': totalNet,
    'verse': verse,
    'reste': reste,
    'points_gagnes': pointsGagnes,
    'points_utilises': pointsUtilises,
    'statut': statut,
    'hash': hash,
    'hash_precedent': hashPrecedent,
    'commentaire': commentaire,
    'type_panier': typePanier,
  };

  factory Vente.depuisLigne(
    Map<String, Object?> r, {
    List<VenteLigne> lignes = const [],
    List<Paiement> paiements = const [],
  }) => Vente(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    sessionCode: r['session_code'] as String,
    caisseCode: r['caisse_code'] as String,
    magasinCode: r['magasin_code'] as String,
    clientCode: r['client_code'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    totalBrut: (r['total_brut'] as num).toDouble(),
    totalRemise: (r['total_remise'] as num).toDouble(),
    totalNet: (r['total_net'] as num).toDouble(),
    verse: (r['verse'] as num).toDouble(),
    reste: (r['reste'] as num).toDouble(),
    pointsGagnes: r['points_gagnes'] as int,
    pointsUtilises: r['points_utilises'] as int,
    statut: r['statut'] as String,
    hash: r['hash'] as String,
    hashPrecedent: r['hash_precedent'] as String,
    commentaire: r['commentaire'] as String?,
    typePanier: r['type_panier'] as String? ?? 'Ticket',
    lignes: lignes,
    paiements: paiements,
  );

  /// Document canonique scellé (contenu immuable du ticket).
  Map<String, Object?> versCanonique() => {
    'code': code,
    'date': date,
    'session': sessionCode,
    'caisse': caisseCode,
    'magasin': magasinCode,
    'client': clientCode,
    'utilisateur': utilisateurCode,
    'brut': totalBrut,
    'remise': totalRemise,
    'net': totalNet,
    'verse': verse,
    'reste': reste,
    'points_gagnes': pointsGagnes,
    'points_utilises': pointsUtilises,
    'lignes': lignes.map((l) => l.versCanonique()).toList(),
    'paiements': paiements.map((p) => {'m': p.mode, 'v': p.montant}).toList(),
  };
}

/// Vue d'un panier pour l'écran Ventes (`PaniersScreen` du DS) : la vente scellée et ses agrégats
/// (lignes, coût, versements imputés, retours, caissier, motif d'annulation).
@immutable
class PanierResume {
  const PanierResume({
    required this.vente,
    required this.caissier,
    required this.nbArticles,
    required this.quantite,
    required this.totalAchat,
    required this.impute,
    required this.nbVersements,
    required this.nbRetours,
    required this.modes,
    this.annuleeLe,
    this.annuleePar,
    this.motifAnnulation,
    this.modifieLe,
    this.modifiePar,
  });

  final Vente vente;
  final String caissier;
  final int nbArticles;
  final double quantite;
  final double totalAchat;

  /// Montant des versements imputés sur ce panier après l'encaissement.
  final double impute;
  final int nbVersements;
  final int nbRetours;

  /// Modes de paiement de l'encaissement (valeurs stockées).
  final List<String> modes;
  final DateTime? annuleeLe;
  final String? annuleePar;
  final String? motifAnnulation;

  /// Dernière modification (colonnes d'audit, §3.2) : modification du paiement, annulation…
  final DateTime? modifieLe;
  final String? modifiePar;

  String get code => vente.code;
  bool get annule => vente.statut == StatutsVente.annulee;

  /// Montant payé à ce jour (encaissement + versements imputés).
  double get paye => vente.totalNet - resteActuel;

  /// Reste dû à ce jour.
  double get resteActuel {
    final r = vente.reste - impute;
    return r > 0.004 ? r : 0;
  }

  double get marge => vente.totalNet - totalAchat;

  /// Statut d'affichage (`StatusBadge` du DS) : `annule`, `retourne`, `credit` ou `paye`.
  String get statut => annule
      ? 'annule'
      : nbRetours > 0
      ? 'retourne'
      : resteActuel > 0
      ? 'credit'
      : 'paye';

  /// `ticket` ou `facture` (BL / BL_SC).
  String get type => vente.typePanier == 'Ticket' ? 'ticket' : 'facture';
}
