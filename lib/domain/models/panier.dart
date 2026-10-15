import 'package:flutter/foundation.dart';

import '../calculs_prix.dart';
import 'produit.dart';

/// Unité de vente d'une ligne : à l'unité ou au « nombre » (pièce).
enum UniteVente { unite, nombre }

/// Ligne de panier (immuable).
@immutable
class PanierLigne {
  const PanierLigne({
    required this.produit,
    this.colis,
    this.pack,
    required this.quantite,
    this.uniteVente = UniteVente.unite,
    required this.prixUnitaire,
    this.remisePct = 0,
  });

  final Produit produit;

  /// Colis vendu (quantité d'unités = quantite × colis.quantite).
  final Colis? colis;

  /// Pack vendu (composants sortis du stock individuellement).
  final Pack? pack;
  final double quantite;
  final UniteVente uniteVente;
  final double prixUnitaire;
  final double remisePct;

  String get designation => pack?.designation ?? colis?.designation ?? produit.designation;

  /// Clé d'agrégation : même produit / colis / pack / unité ⇒ même ligne.
  String get cle => '${pack?.code ?? colis?.code ?? produit.code}|${uniteVente.name}';

  double get brut => CalculsPrix.arrondir(prixUnitaire * quantite);
  double get remise => CalculsPrix.arrondir(brut * remisePct / 100);
  double get total => CalculsPrix.arrondir(brut - remise);

  /// Unités de stock consommées par cette ligne (hors pack : voir [composantsPack]).
  double get unitesStock => uniteVente == UniteVente.nombre ? 0 : quantite * (colis?.quantite ?? 1);
  double get nombreStock => uniteVente == UniteVente.nombre ? quantite : 0;

  PanierLigne copyWith({double? quantite, double? prixUnitaire, double? remisePct}) => PanierLigne(
    produit: produit,
    colis: colis,
    pack: pack,
    quantite: quantite ?? this.quantite,
    uniteVente: uniteVente,
    prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    remisePct: remisePct ?? this.remisePct,
  );
}

/// Paiement d'une vente.
@immutable
class Paiement {
  const Paiement({required this.mode, required this.montant, this.reference});

  /// Valeur stockée FR : Espèces, Carte, Chèque, Virement, Points.
  final String mode;
  final double montant;
  final String? reference;
}

/// Panier (vente en cours), immuable : toute modification retourne un nouveau panier.
@immutable
class Panier {
  const Panier({
    required this.id,
    this.lignes = const [],
    this.clientCode = 'CLN0000',
    this.remiseGlobalePct = 0,
    this.paiements = const [],
    this.commentaire,
    this.remiseCode,
    this.modePaiement = 'Espèces',
  });

  final int id;
  final List<PanierLigne> lignes;
  final String clientCode;
  final double remiseGlobalePct;
  final List<Paiement> paiements;
  final String? commentaire;

  /// Remise globale choisie dans le référentiel des remises (code), `null` = aucune.
  final String? remiseCode;

  /// Mode de paiement choisi pour l'encaissement (valeur stockée FR).
  final String modePaiement;

  bool get estVide => lignes.isEmpty;
  double get totalBrut => CalculsPrix.arrondir(lignes.fold(0.0, (s, l) => s + l.brut));
  double get remiseLignes => CalculsPrix.arrondir(lignes.fold(0.0, (s, l) => s + l.remise));
  double get sousTotal => CalculsPrix.arrondir(totalBrut - remiseLignes);
  double get remiseGlobale => CalculsPrix.arrondir(sousTotal * remiseGlobalePct / 100);
  double get totalRemise => CalculsPrix.arrondir(remiseLignes + remiseGlobale);
  double get totalNet => CalculsPrix.arrondir(sousTotal - remiseGlobale);
  double get verse => CalculsPrix.arrondir(paiements.fold(0.0, (s, p) => s + p.montant));

  /// Reste à payer (≥ 0).
  double get reste => CalculsPrix.arrondir((totalNet - verse).clamp(0, double.infinity));

  /// Monnaie à rendre quand le versé dépasse le net (espèces).
  double get monnaie => CalculsPrix.arrondir((verse - totalNet).clamp(0, double.infinity));
  bool get estSolde => reste <= 0.0001;
  int get nbArticles => lignes.length;
  double get quantiteTotale => lignes.fold(0.0, (s, l) => s + l.quantite);

  Panier copyWith({
    int? id,
    List<PanierLigne>? lignes,
    String? clientCode,
    double? remiseGlobalePct,
    List<Paiement>? paiements,
    String? commentaire,
    String? remiseCode,
    bool effacerRemise = false,
    String? modePaiement,
  }) => Panier(
    id: id ?? this.id,
    lignes: lignes ?? this.lignes,
    clientCode: clientCode ?? this.clientCode,
    remiseGlobalePct: remiseGlobalePct ?? this.remiseGlobalePct,
    paiements: paiements ?? this.paiements,
    commentaire: commentaire ?? this.commentaire,
    remiseCode: effacerRemise ? null : (remiseCode ?? this.remiseCode),
    modePaiement: modePaiement ?? this.modePaiement,
  );

  /// Ajoute une ligne (agrège sur la même clé).
  Panier ajouter(PanierLigne ligne) {
    final i = lignes.indexWhere((l) => l.cle == ligne.cle);
    if (i < 0) return copyWith(lignes: [...lignes, ligne]);
    final copie = [...lignes];
    copie[i] = copie[i].copyWith(quantite: copie[i].quantite + ligne.quantite);
    return copyWith(lignes: copie);
  }

  Panier modifierQuantite(int index, double quantite) {
    if (quantite <= 0) return retirer(index);
    final copie = [...lignes];
    copie[index] = copie[index].copyWith(quantite: quantite);
    return copyWith(lignes: copie);
  }

  Panier modifierLigne(int index, PanierLigne ligne) {
    final copie = [...lignes];
    copie[index] = ligne;
    return copyWith(lignes: copie);
  }

  Panier retirer(int index) => copyWith(lignes: [...lignes]..removeAt(index));

  /// Retire les lignes et les paiements ; client, remise et mode sont conservés.
  Panier vider() => Panier(
    id: id,
    clientCode: clientCode,
    remiseGlobalePct: remiseGlobalePct,
    remiseCode: remiseCode,
    modePaiement: modePaiement,
  );

  /// Panier neuf (après encaissement) : client comptoir, sans remise, espèces.
  Panier reinitialiser() => Panier(id: id);

  /// Nombre de pièces (unités de stock ou pièces vendues au nombre).
  double get pieces => lignes.fold(0.0, (s, l) => s + (l.pack != null ? l.quantite : l.unitesStock + l.nombreStock));

  Panier ajouterPaiement(Paiement p) => copyWith(paiements: [...paiements, p]);
  Panier retirerPaiement(int index) => copyWith(paiements: [...paiements]..removeAt(index));

  /// Quantité d'unités de stock réservées pour un produit (lignes directes, colis, composants de packs).
  double unitesReservees(String produitCode) {
    var total = 0.0;
    for (final l in lignes) {
      if (l.pack != null) {
        for (final c in l.pack!.lignes) {
          if (c.produitCode == produitCode) total += c.quantite * l.quantite;
        }
      } else if (l.produit.code == produitCode) {
        total += l.unitesStock;
      }
    }
    return total;
  }

  double nombreReserve(String produitCode) =>
      lignes.where((l) => l.pack == null && l.produit.code == produitCode).fold(0.0, (s, l) => s + l.nombreStock);
}

/// Calcul des points de fidélité (§8). ⚠️ PROVISOIRE : 1 point = 1 DA à l'utilisation.
class Fidelite {
  const Fidelite._();

  static const double valeurPoint = 1;

  static int pointsGagnes(
    double totalNet, {
    required bool active,
    required double pointsParDinar,
    required String clientCode,
  }) {
    if (!active || clientCode == 'CLN0000' || totalNet <= 0) return 0;
    return (totalNet * pointsParDinar).floor();
  }

  static double montantPoints(int points) => points * valeurPoint;
  static int pointsPourMontant(double montant) => (montant / valeurPoint).ceil();
}
