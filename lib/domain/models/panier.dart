import 'package:flutter/foundation.dart';

import '../calculs_prix.dart';
import 'produit.dart';
import 'vente.dart';

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
    this.nombreExige = false,
    this.reprise,
  });

  /// Ligne reprise d'une vente modifiée ([Panier.remplacement]) : verrouillée (ni retirée ni modifiée), son
  /// montant, ses unités et sa TVA restent ceux du ticket d'origine.
  factory PanierLigne.reprise(VenteLigne l, Produit produit, {Colis? colis, Pack? pack}) => PanierLigne(
    produit: produit,
    colis: colis,
    pack: pack,
    quantite: l.quantite,
    uniteVente: l.uniteVente == 'Nombre' ? UniteVente.nombre : UniteVente.unite,
    prixUnitaire: l.prixUnitaire,
    reprise: l,
  );

  final Produit produit;

  /// Colis vendu (quantité d'unités = quantite × colis.quantite).
  final Colis? colis;

  /// Pack d'origine : un pack est éclaté en une ligne par produit ([quantite] = quantité du produit dans le pack
  /// × nombre de packs, [prixUnitaire] = part du prix du pack). Une telle ligne reste distincte de la ligne du même
  /// produit ajouté seul.
  final Pack? pack;
  final double quantite;
  final UniteVente uniteVente;
  final double prixUnitaire;
  final double remisePct;

  /// 2ᵉ stock « nombre » actif (§8.1) : une vente à l'unité sort aussi les pièces correspondantes
  /// (unités × `nombreParUnite`). ⚠️ PROVISOIRE : pièces déduites, pas de saisie séparée en caisse.
  final bool nombreExige;

  /// Ligne du ticket d'origine, pour une ligne reprise d'une vente modifiée ; `null` pour une ligne ajoutée.
  final VenteLigne? reprise;

  /// Ligne reprise d'une vente modifiée : ni retirée, ni modifiée.
  bool get verrouillee => reprise != null;

  /// Code du produit système « Vente au montant » (ligne de montant libre de la caisse).
  static const String codeMontant = 'PRD0000';

  /// Ligne de montant libre (balance, article non codifié) : quantité 1, le prix est le montant cumulé.
  bool get estMontant => produit.code == codeMontant;

  String get designation => reprise?.designation ?? colis?.designation ?? produit.designation;

  /// Clé d'agrégation : même pack d'origine / produit / colis / unité ⇒ même ligne. Une ligne reprise reste à part.
  String get cle => reprise != null
      ? 'reprise/${reprise!.ordre}'
      : '${pack == null ? '' : '${pack!.code}/'}${colis?.code ?? produit.code}|${uniteVente.name}';

  double get brut => CalculsPrix.arrondir(prixUnitaire * quantite);
  double get remise =>
      reprise != null ? CalculsPrix.arrondir(brut - reprise!.total) : CalculsPrix.arrondir(brut * remisePct / 100);
  double get total => reprise?.total ?? CalculsPrix.arrondir(brut - remise);

  /// Unités de stock consommées par cette ligne.
  double get unitesStock =>
      reprise?.unites ?? (uniteVente == UniteVente.nombre ? 0 : quantite * (colis?.quantite ?? 1));
  double get nombreStock =>
      reprise?.nombre ??
      (uniteVente == UniteVente.nombre ? quantite : (nombreExige ? unitesStock * produit.nombreParUnite : 0));

  PanierLigne copyWith({double? quantite, double? prixUnitaire, double? remisePct}) => PanierLigne(
    produit: produit,
    colis: colis,
    pack: pack,
    quantite: quantite ?? this.quantite,
    uniteVente: uniteVente,
    prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    remisePct: remisePct ?? this.remisePct,
    nombreExige: nombreExige,
    reprise: reprise,
  );
}

/// Vente modifiée dans un panier de la caisse (ajout de produits, changement de client) : le ticket scellé ne
/// change pas ; à l'encaissement, il est annulé et remplacé par un nouveau ticket qui reprend ses lignes
/// (verrouillées) et ce qui était déjà payé.
@immutable
class RemplacementVente {
  const RemplacementVente({
    required this.code,
    required this.clientCode,
    required this.paye,
    this.points = 0,
    this.impute = 0,
  });

  /// Code de la vente remplacée.
  final String code;

  /// Client de la vente remplacée : ses points et ses versements ne sont repris que s'il ne change pas.
  final String clientCode;

  /// Payé à l'encaissement de la vente d'origine, hors points (espèces nettes de la monnaie rendue).
  final double paye;

  /// Payé en points à l'encaissement de la vente d'origine (montant).
  final double points;

  /// Versements imputés depuis sur la vente d'origine.
  final double impute;

  /// Ce qui est repris si la vente passe au client [client] : les points et les versements restent au client
  /// d'origine quand il change (rendus et libérés à l'annulation).
  double reprisPour(String client) => CalculsPrix.arrondir(paye + (client == clientCode ? points + impute : 0));
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
    this.remplacement,
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

  /// Vente modifiée chargée dans ce panier (ses lignes reprises sont verrouillées), `null` pour une vente neuve.
  final RemplacementVente? remplacement;

  /// Déjà payé sur la vente modifiée et repris par ce panier (0 pour une vente neuve).
  double get dejaPaye => remplacement?.reprisPour(clientCode) ?? 0;

  /// Montant restant à encaisser : le net, moins ce qui est déjà payé sur une vente modifiée.
  double get aPayer => CalculsPrix.arrondir((totalNet - dejaPaye).clamp(0, double.infinity));

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
    remplacement: remplacement,
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
    if (lignes[index].verrouillee) return this;
    if (quantite <= 0) return retirer(index);
    final copie = [...lignes];
    copie[index] = copie[index].copyWith(quantite: quantite);
    return copyWith(lignes: copie);
  }

  Panier modifierLigne(int index, PanierLigne ligne) {
    if (lignes[index].verrouillee) return this;
    final copie = [...lignes];
    copie[index] = ligne;
    return copyWith(lignes: copie);
  }

  /// Retire la ligne ; une ligne issue d'un pack emporte tout le pack (ses produits vont ensemble). Une ligne
  /// reprise d'une vente modifiée ne se retire pas.
  Panier retirer(int index) {
    final ligne = lignes[index];
    if (ligne.verrouillee) return this;
    final pack = ligne.pack;
    if (pack == null) return copyWith(lignes: [...lignes]..removeAt(index));
    return copyWith(
      lignes: [
        for (final l in lignes)
          if (l.pack?.code != pack.code || l.verrouillee) l,
      ],
    );
  }

  /// Quantité d'un produit dans une unité de [pack].
  static double quantiteDansPack(Pack pack, String produitCode) =>
      pack.lignes.where((c) => c.produitCode == produitCode).fold(0.0, (s, c) => s + c.quantite);

  /// Nombre de [pack] dans le panier : toutes ses lignes passent à `quantité dans le pack × nombre`
  /// (≤ 0 : le pack est retiré).
  Panier quantitePack(Pack pack, double nombre) {
    if (nombre <= 0) {
      final i = lignes.indexWhere((l) => l.pack?.code == pack.code && !l.verrouillee);
      return i < 0 ? this : retirer(i);
    }
    return copyWith(
      lignes: [
        for (final l in lignes)
          l.pack?.code == pack.code && !l.verrouillee
              ? l.copyWith(quantite: quantiteDansPack(pack, l.produit.code) * nombre)
              : l,
      ],
    );
  }

  /// Retire les lignes et les paiements ; client, remise et mode sont conservés. Une vente modifiée garde ses
  /// lignes reprises.
  Panier vider() => Panier(
    id: id,
    lignes: [
      for (final l in lignes)
        if (l.verrouillee) l,
    ],
    clientCode: clientCode,
    remiseGlobalePct: remiseGlobalePct,
    remiseCode: remiseCode,
    modePaiement: modePaiement,
    remplacement: remplacement,
  );

  /// Panier neuf (après encaissement) : client comptoir, sans remise, espèces.
  Panier reinitialiser() => Panier(id: id);

  /// Nombre de pièces (unités de stock ou pièces vendues au nombre ; la ligne de montant libre n'en compte pas).
  double get pieces => lignes.fold(
    0.0,
    (s, l) => s + (l.estMontant ? 0 : (l.uniteVente == UniteVente.nombre ? l.quantite : l.unitesStock)),
  );

  Panier ajouterPaiement(Paiement p) => copyWith(paiements: [...paiements, p]);
  Panier retirerPaiement(int index) => copyWith(paiements: [...paiements]..removeAt(index));

  /// Quantité d'unités de stock réservées pour un produit (lignes directes, colis, lignes issues d'un pack). Les
  /// lignes reprises d'une vente modifiée sont déjà sorties du stock : elles ne réservent rien.
  double unitesReservees(String produitCode) =>
      lignes.where((l) => l.produit.code == produitCode && !l.verrouillee).fold(0.0, (s, l) => s + l.unitesStock);

  double nombreReserve(String produitCode) =>
      lignes.where((l) => l.produit.code == produitCode && !l.verrouillee).fold(0.0, (s, l) => s + l.nombreStock);

  /// Prix unitaire de chaque produit dans [pack] : le prix du pack est réparti au prorata du prix de vente des
  /// produits × leur quantité (à défaut, de la quantité), arrondi au centime ; le dernier produit absorbe l'arrondi
  /// pour que le pack complet coûte son prix (au centime près selon les quantités).
  static Map<String, double> prixComposantsPack(Pack pack, Map<String, Produit> produits) {
    final lignes = pack.lignes.where((c) => c.quantite > 0).toList();
    if (lignes.isEmpty) return const {};
    double poids(PackLigne c) => (produits[c.produitCode]?.prixVente ?? 0) * c.quantite;
    final total = lignes.fold(0.0, (s, c) => s + poids(c));
    final quantites = lignes.fold(0.0, (s, c) => s + c.quantite);
    final prix = <String, double>{};
    var reparti = 0.0;
    for (final (i, c) in lignes.indexed) {
      final double unitaire;
      if (i == lignes.length - 1) {
        unitaire = ((pack.prixVente - reparti) / c.quantite).clamp(0, double.infinity).toDouble();
      } else {
        final part = total > 0 ? pack.prixVente * poids(c) / total : pack.prixVente * c.quantite / quantites;
        unitaire = part / c.quantite;
      }
      prix[c.produitCode] = CalculsPrix.arrondir(unitaire);
      reparti += prix[c.produitCode]! * c.quantite;
    }
    return prix;
  }
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
