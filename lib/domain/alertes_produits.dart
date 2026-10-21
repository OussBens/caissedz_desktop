import 'package:flutter/foundation.dart';

/// Familles des alertes produits (navigation de la Situation, carte du tableau de bord).
enum GroupeAlerteProduit { ventes, stock, prix, qualite, marche }

/// Action proposée par une alerte (bouton de la ligne dans Situation › Alertes produits).
enum ActionAlerteProduit {
  creerBesoin,
  creerRemise,
  modifierPrix,
  voirRetours,
  modifierRemise,
  voirMouvements,
  creerPack,
  creerTransfert,
  creerCommande,
  ajusterSeuil,
  modifierProduit,
  completerProduit,
  ajouterFavori,
}

/// Les 20 alertes produits (document « Product alerts and catalogue », partie 1 + 2 alertes du catalogue BENS).
/// Toutes sont des requêtes en lecture seule ; leurs seuils sont des paramètres ([SeuilsAlertesProduits]).
enum TypeAlerteProduit {
  meilleuresVentes(1, GroupeAlerteProduit.ventes, ActionAlerteProduit.creerBesoin),
  stockDormant(2, GroupeAlerteProduit.stock, ActionAlerteProduit.creerRemise),
  candidatsRemise(3, GroupeAlerteProduit.prix, ActionAlerteProduit.creerRemise, cout: true),
  margeFaible(4, GroupeAlerteProduit.prix, ActionAlerteProduit.modifierPrix, cout: true),
  retoursEleves(5, GroupeAlerteProduit.qualite, ActionAlerteProduit.voirRetours),
  enHausse(6, GroupeAlerteProduit.ventes, ActionAlerteProduit.creerBesoin),
  stockLent(7, GroupeAlerteProduit.stock, ActionAlerteProduit.creerRemise),
  jamaisVendus(8, GroupeAlerteProduit.stock, ActionAlerteProduit.creerRemise),
  remisesInefficaces(9, GroupeAlerteProduit.prix, ActionAlerteProduit.modifierRemise),
  stockAnormal(10, GroupeAlerteProduit.qualite, ActionAlerteProduit.voirMouvements),
  hausseFournisseur(11, GroupeAlerteProduit.prix, ActionAlerteProduit.modifierPrix, cout: true),
  achetesEnsemble(12, GroupeAlerteProduit.ventes, ActionAlerteProduit.creerPack),
  stockDesequilibre(13, GroupeAlerteProduit.stock, ActionAlerteProduit.creerTransfert),
  ruptureSansCommande(14, GroupeAlerteProduit.stock, ActionAlerteProduit.creerCommande),
  saisonniers(15, GroupeAlerteProduit.ventes, ActionAlerteProduit.creerBesoin),
  rupturesFrequentes(16, GroupeAlerteProduit.stock, ActionAlerteProduit.ajusterSeuil),
  ficheIncomplete(17, GroupeAlerteProduit.qualite, ActionAlerteProduit.modifierProduit),
  bonneMargePeuVendus(18, GroupeAlerteProduit.ventes, ActionAlerteProduit.ajouterFavori, cout: true),
  nouveautesMarche(19, GroupeAlerteProduit.marche, ActionAlerteProduit.completerProduit),
  tendancesMarche(20, GroupeAlerteProduit.marche, ActionAlerteProduit.creerBesoin);

  const TypeAlerteProduit(this.numero, this.groupe, this.action, {this.cout = false});
  final int numero;
  final GroupeAlerteProduit groupe;
  final ActionAlerteProduit action;

  /// Alerte calculée sur le prix d'achat : visible avec la permission « Voir les prix d'achat ».
  final bool cout;

  static TypeAlerteProduit? parNom(String? nom) => values.where((t) => t.name == nom).firstOrNull;
}

/// Seuils des alertes produits (Paramètres › Alertes › Alertes produits) et alertes désactivées. Valeurs par défaut
/// du document de proposition.
@immutable
class SeuilsAlertesProduits {
  const SeuilsAlertesProduits({
    this.inactives = const {},
    this.periodeJours = 30,
    this.topN = 10,
    this.couvertureJours = 7,
    this.dormantJours = 60,
    this.baisseVentesPct = 30,
    this.margeRemisePct = 15,
    this.margeFaiblePct = 5,
    this.retoursPct = 10,
    this.hausseJours = 14,
    this.haussePct = 50,
    this.lentJours = 90,
    this.jamaisVenduJours = 30,
    this.casseMax = 3,
    this.ecartInventaire = 10,
    this.hausseAchatPct = 5,
    this.ensemblePct = 20,
    this.retardCommandeJours = 7,
    this.saisonJours = 30,
    this.rupturesJours = 5,
    this.bonneMargePct = 25,
    this.nouveautesJours = 30,
  });

  /// Alertes désactivées par l'administrateur.
  final Set<TypeAlerteProduit> inactives;

  /// Période d'analyse des ventes (meilleures ventes, rythme, achetés ensemble, retours, bonne marge…).
  final int periodeJours;
  final int topN;
  final int couvertureJours;
  final int dormantJours;
  final double baisseVentesPct;
  final double margeRemisePct;
  final double margeFaiblePct;
  final double retoursPct;
  final int hausseJours;
  final double haussePct;
  final int lentJours;
  final int jamaisVenduJours;
  final int casseMax;
  final double ecartInventaire;
  final double hausseAchatPct;
  final double ensemblePct;
  final int retardCommandeJours;
  final int saisonJours;
  final int rupturesJours;
  final double bonneMargePct;
  final int nouveautesJours;

  bool active(TypeAlerteProduit t) => !inactives.contains(t);

  static const String _p = 'alertes_produits_';
  static const String cleInactives = '${_p}inactives';
  static const String clePeriode = '${_p}periode_jours';
  static const String cleTopN = '${_p}top_n';
  static const String cleCouverture = '${_p}couverture_jours';
  static const String cleDormant = '${_p}dormant_jours';
  static const String cleBaisse = '${_p}baisse_pct';
  static const String cleMargeRemise = '${_p}marge_remise_pct';
  static const String cleMargeFaible = '${_p}marge_faible_pct';
  static const String cleRetours = '${_p}retours_pct';
  static const String cleHausseJours = '${_p}hausse_jours';
  static const String cleHaussePct = '${_p}hausse_pct';
  static const String cleLent = '${_p}lent_jours';
  static const String cleJamaisVendu = '${_p}jamais_vendu_jours';
  static const String cleCasse = '${_p}casse_max';
  static const String cleEcart = '${_p}ecart_inventaire';
  static const String cleHausseAchat = '${_p}hausse_achat_pct';
  static const String cleEnsemble = '${_p}ensemble_pct';
  static const String cleRetard = '${_p}retard_commande_jours';
  static const String cleSaison = '${_p}saison_jours';
  static const String cleRuptures = '${_p}ruptures_jours';
  static const String cleBonneMarge = '${_p}bonne_marge_pct';
  static const String cleNouveautes = '${_p}nouveautes_jours';

  static const List<String> cles = [
    cleInactives,
    clePeriode,
    cleTopN,
    cleCouverture,
    cleDormant,
    cleBaisse,
    cleMargeRemise,
    cleMargeFaible,
    cleRetours,
    cleHausseJours,
    cleHaussePct,
    cleLent,
    cleJamaisVendu,
    cleCasse,
    cleEcart,
    cleHausseAchat,
    cleEnsemble,
    cleRetard,
    cleSaison,
    cleRuptures,
    cleBonneMarge,
    cleNouveautes,
  ];

  factory SeuilsAlertesProduits.depuisCles(Map<String, String?> m) {
    const d = SeuilsAlertesProduits();
    int e(String cle, int defaut) => (int.tryParse(m[cle] ?? '') ?? defaut).clamp(1, 3650);
    double r(String cle, double defaut) => (double.tryParse(m[cle] ?? '') ?? defaut).clamp(0, 100000).toDouble();
    return SeuilsAlertesProduits(
      inactives: {for (final n in (m[cleInactives] ?? '').split(',')) ?TypeAlerteProduit.parNom(n.trim())},
      periodeJours: e(clePeriode, d.periodeJours),
      topN: e(cleTopN, d.topN),
      couvertureJours: e(cleCouverture, d.couvertureJours),
      dormantJours: e(cleDormant, d.dormantJours),
      baisseVentesPct: r(cleBaisse, d.baisseVentesPct),
      margeRemisePct: r(cleMargeRemise, d.margeRemisePct),
      margeFaiblePct: r(cleMargeFaible, d.margeFaiblePct),
      retoursPct: r(cleRetours, d.retoursPct),
      hausseJours: e(cleHausseJours, d.hausseJours),
      haussePct: r(cleHaussePct, d.haussePct),
      lentJours: e(cleLent, d.lentJours),
      jamaisVenduJours: e(cleJamaisVendu, d.jamaisVenduJours),
      casseMax: e(cleCasse, d.casseMax),
      ecartInventaire: r(cleEcart, d.ecartInventaire),
      hausseAchatPct: r(cleHausseAchat, d.hausseAchatPct),
      ensemblePct: r(cleEnsemble, d.ensemblePct),
      retardCommandeJours: e(cleRetard, d.retardCommandeJours),
      saisonJours: e(cleSaison, d.saisonJours),
      rupturesJours: e(cleRuptures, d.rupturesJours),
      bonneMargePct: r(cleBonneMarge, d.bonneMargePct),
      nouveautesJours: e(cleNouveautes, d.nouveautesJours),
    );
  }

  static String _n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';

  Map<String, String> versCles() => {
    cleInactives: [
      for (final t in TypeAlerteProduit.values)
        if (inactives.contains(t)) t.name,
    ].join(','),
    clePeriode: '$periodeJours',
    cleTopN: '$topN',
    cleCouverture: '$couvertureJours',
    cleDormant: '$dormantJours',
    cleBaisse: _n(baisseVentesPct),
    cleMargeRemise: _n(margeRemisePct),
    cleMargeFaible: _n(margeFaiblePct),
    cleRetours: _n(retoursPct),
    cleHausseJours: '$hausseJours',
    cleHaussePct: _n(haussePct),
    cleLent: '$lentJours',
    cleJamaisVendu: '$jamaisVenduJours',
    cleCasse: '$casseMax',
    cleEcart: _n(ecartInventaire),
    cleHausseAchat: _n(hausseAchatPct),
    cleEnsemble: _n(ensemblePct),
    cleRetard: '$retardCommandeJours',
    cleSaison: '$saisonJours',
    cleRuptures: '$rupturesJours',
    cleBonneMarge: _n(bonneMargePct),
    cleNouveautes: '$nouveautesJours',
  };

  /// Seuil entier (jours, nombre) ou décimal (%, quantité) par clé, pour le formulaire des Paramètres.
  num valeur(String cle) => switch (cle) {
    clePeriode => periodeJours,
    cleTopN => topN,
    cleCouverture => couvertureJours,
    cleDormant => dormantJours,
    cleBaisse => baisseVentesPct,
    cleMargeRemise => margeRemisePct,
    cleMargeFaible => margeFaiblePct,
    cleRetours => retoursPct,
    cleHausseJours => hausseJours,
    cleHaussePct => haussePct,
    cleLent => lentJours,
    cleJamaisVendu => jamaisVenduJours,
    cleCasse => casseMax,
    cleEcart => ecartInventaire,
    cleHausseAchat => hausseAchatPct,
    cleEnsemble => ensemblePct,
    cleRetard => retardCommandeJours,
    cleSaison => saisonJours,
    cleRuptures => rupturesJours,
    cleBonneMarge => bonneMargePct,
    cleNouveautes => nouveautesJours,
    _ => 0,
  };

  /// Seuils propres à chaque alerte (la période d'analyse est commune), dans l'ordre de la règle.
  static List<String> clesDe(TypeAlerteProduit t) => switch (t) {
    TypeAlerteProduit.meilleuresVentes => [cleTopN, cleCouverture],
    TypeAlerteProduit.stockDormant => [cleDormant],
    TypeAlerteProduit.candidatsRemise => [cleBaisse, cleMargeRemise],
    TypeAlerteProduit.margeFaible => [cleMargeFaible],
    TypeAlerteProduit.retoursEleves => [cleRetours],
    TypeAlerteProduit.enHausse => [cleHausseJours, cleHaussePct],
    TypeAlerteProduit.stockLent => [cleLent],
    TypeAlerteProduit.jamaisVendus => [cleJamaisVendu],
    TypeAlerteProduit.remisesInefficaces => const [],
    TypeAlerteProduit.stockAnormal => [cleCasse, cleEcart],
    TypeAlerteProduit.hausseFournisseur => [cleHausseAchat],
    TypeAlerteProduit.achetesEnsemble => [cleEnsemble],
    TypeAlerteProduit.stockDesequilibre => const [],
    TypeAlerteProduit.ruptureSansCommande => [cleRetard],
    TypeAlerteProduit.saisonniers => [cleSaison],
    TypeAlerteProduit.rupturesFrequentes => [cleRuptures],
    TypeAlerteProduit.ficheIncomplete => const [],
    TypeAlerteProduit.bonneMargePeuVendus => [cleBonneMarge],
    TypeAlerteProduit.nouveautesMarche => [cleNouveautes],
    TypeAlerteProduit.tendancesMarche => const [],
  };

  /// Seuils en pourcentage (les autres : jours ou nombre).
  static const Set<String> clesPourcentage = {
    cleBaisse,
    cleMargeRemise,
    cleMargeFaible,
    cleRetours,
    cleHaussePct,
    cleHausseAchat,
    cleEnsemble,
    cleBonneMarge,
  };

  /// Seuils en jours.
  static const Set<String> clesJours = {
    clePeriode,
    cleCouverture,
    cleDormant,
    cleHausseJours,
    cleLent,
    cleJamaisVendu,
    cleRetard,
    cleSaison,
    cleRuptures,
    cleNouveautes,
  };

  /// Copie avec les seuils de [valeurs] (clé → texte saisi ; invalide : valeur actuelle) et [inactives].
  SeuilsAlertesProduits avec(Map<String, String> valeurs, {Set<TypeAlerteProduit>? inactives}) =>
      SeuilsAlertesProduits.depuisCles({
        ...versCles(),
        for (final MapEntry(:key, :value) in valeurs.entries)
          if (double.tryParse(value.replaceAll(',', '.').trim()) != null) key: value.replaceAll(',', '.').trim(),
        if (inactives != null) cleInactives: [for (final t in inactives) t.name].join(','),
      });

  @override
  bool operator ==(Object other) =>
      other is SeuilsAlertesProduits &&
      setEquals(other.inactives, inactives) &&
      mapEquals(other.versCles(), versCles());

  @override
  int get hashCode => Object.hashAll(versCles().values);
}

/// Une alerte sur un produit. Selon le type : [quantite] vendue (ou perdue, retournée, ventes ensemble), [stock],
/// [jours] (couverture, depuis la dernière vente, en rupture, de retard…), [pct] (marge, taux), [montant] (valeur
/// immobilisée, prix d'achat), [suggestion] (remise %, prix conseillé, quantité à transférer ou à commander).
@immutable
class AlerteProduit {
  const AlerteProduit({
    required this.type,
    required this.produitCode,
    required this.designation,
    this.categorie = '',
    this.quantite,
    this.quantite2,
    this.stock,
    this.jours,
    this.pct,
    this.evolution,
    this.montant,
    this.suggestion,
    this.produit2Code,
    this.produit2,
    this.magasin,
    this.magasin2,
    this.remiseCode,
    this.remise,
    this.motifs = const [],
    this.critique = false,
  });

  final TypeAlerteProduit type;
  final String produitCode;
  final String designation;
  final String categorie;
  final double? quantite;

  /// Quantité de comparaison : vendus (retours), période précédente (hausse, remise), écart d'inventaire.
  final double? quantite2;
  final double? stock;
  final double? jours;
  final double? pct;

  /// Évolution en % (hausse des ventes, baisse des ventes, hausse du prix d'achat).
  final double? evolution;
  final double? montant;
  final double? suggestion;

  /// Produits achetés ensemble : le second produit de la paire.
  final String? produit2Code;
  final String? produit2;

  /// Stock déséquilibré : magasin qui manque ([magasin]) et magasin qui en a trop ([magasin2]), par code.
  final String? magasin;
  final String? magasin2;

  /// Remise qui ne marche pas.
  final String? remiseCode;
  final String? remise;

  /// Raisons de l'alerte (stock anormal : `negatif`, `casse`, `inventaire` ; fiche incomplète : `codeBarres`,
  /// `photo`, `categorie`, `prix` ; rupture sans commande : `aucune`, `retard`).
  final List<String> motifs;

  /// À traiter en priorité (rupture, vente à perte, stock qui ne couvre plus…).
  final bool critique;

  /// Identifiant de la ligne (unique dans la liste des alertes).
  String get cle => [type.name, produitCode, ?produit2Code, ?magasin, ?remiseCode].join('|');
}

/// Résultat du calcul : les alertes de chaque type actif et visible (liste vide : aucune).
@immutable
class AlertesProduits {
  const AlertesProduits(this.parType);
  static const AlertesProduits vide = AlertesProduits({});

  final Map<TypeAlerteProduit, List<AlerteProduit>> parType;

  List<AlerteProduit> de(TypeAlerteProduit t) => parType[t] ?? const [];
  int get total => parType.values.fold(0, (s, l) => s + l.length);
  List<AlerteProduit> get toutes => [for (final t in TypeAlerteProduit.values) ...de(t)];

  /// Empreinte stable de chaque type (FNV-1a des codes triés, gardée d'un lancement à l'autre) : un type dont
  /// l'empreinte change a de nouvelles alertes.
  Map<String, int> get empreintes => {
    for (final MapEntry(key: t, value: l) in parType.entries)
      if (l.isNotEmpty) t.name: _fnv(([for (final a in l) a.cle]..sort()).join('\n')),
  };

  static int _fnv(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    return h;
  }
}
