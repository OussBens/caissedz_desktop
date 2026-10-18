import 'package:flutter/foundation.dart';

import '../fiscalite.dart';

/// Paramètres métier de vente et de stock (table `parametre`, `parametre` du §7.9).
@immutable
class ParametresVente {
  const ParametresVente({
    this.margeDefautPct = 20,
    this.seuilStockGlobal = 5,
    this.fideliteActive = false,
    this.pointsParDinar = 0.01,
    this.devise = 'DA',
    this.decimalesQuantite = 2,
    this.typeMarge = typeMargePourcentage,
    this.margeMontant = 50,
    this.seuilStockMax = 0,
    this.venteSousAchat = venteSousAchatAvertir,
    this.nombreActif = false,
    this.regimeFiscal = RegimesFiscaux.reel,
    this.timbreActif = true,
    this.tvaCaisse = true,
    this.tvaDocuments = true,
  });

  static const String cleMarge = 'marge_defaut_pct';
  static const String cleSeuil = 'seuil_stock_global';
  static const String cleFidelite = 'fidelite_active';
  static const String clePoints = 'fidelite_points_par_dinar';
  static const String cleDevise = 'devise';
  static const String cleDecimales = 'decimales_quantite';
  static const String cleTypeMarge = 'marge_type';
  static const String cleMargeMontant = 'marge_montant';
  static const String cleSeuilMax = 'seuil_stock_max';
  static const String cleVenteSousAchat = 'vente_sous_achat';
  static const String cleNombre = 'nombre_actif';
  static const List<String> cles = [
    Fiscalite.cleRegime,
    Fiscalite.cleTimbre,
    Fiscalite.cleTvaCaisse,
    Fiscalite.cleTvaDocuments,
    cleMarge,
    cleSeuil,
    cleFidelite,
    clePoints,
    cleDevise,
    cleDecimales,
    cleTypeMarge,
    cleMargeMontant,
    cleSeuilMax,
    cleVenteSousAchat,
    cleNombre,
  ];

  /// Valeurs stockées du référentiel `typeCalcul`.
  static const String typeMargePourcentage = 'Pourcentage';
  static const String typeMargeMontant = 'Montant';

  /// Valeurs stockées du référentiel `typeVenteSousAchat`.
  static const String venteSousAchatInterdire = 'Interdire';
  static const String venteSousAchatAvertir = 'Avertir';
  static const String venteSousAchatAutoriser = 'Autoriser';

  /// Taux de marge en pourcentage (`taux_marge_percentage`).
  final double margeDefautPct;

  /// Seuil minimum (rupture).
  final int seuilStockGlobal;
  final bool fideliteActive;
  final double pointsParDinar;
  final String devise;

  /// Décimales des quantités (0 à 3 ; 3 pour la vente au poids).
  final int decimalesQuantite;

  /// `Pourcentage` ou `Montant` (`type_marge`).
  final String typeMarge;

  /// Marge fixe en devise (`taux_marge_montant`).
  final double margeMontant;

  /// Seuil maximum (sur-stock) ; 0 = aucun.
  final int seuilStockMax;

  /// `Interdire`, `Avertir` ou `Autoriser` : contrôle d'un prix de vente sous le prix d'achat.
  final String venteSousAchat;

  /// Paramètres › Nombre et quantité (`active_nombre_quantite`, §8.1) : 2ᵉ stock « nombre » exigé pour tous les
  /// produits (sinon seulement pour ceux qui l'activent).
  final bool nombreActif;

  /// Régime fiscal (`Réel` : TVA collectée et déductible ; `IFU` : sans TVA).
  final String regimeFiscal;

  /// Droit de timbre sur la part payée en espèces des factures.
  final bool timbreActif;

  /// Vente en caisse avec TVA : prix TTC (HT + TVA du produit) ; sinon prix HT, sans TVA.
  final bool tvaCaisse;

  /// Même choix pour les devis, proformas, commandes clients et leurs livraisons.
  final bool tvaDocuments;

  bool get margeEnMontant => typeMarge == typeMargeMontant;

  ParametresVente copyWith({
    double? margeDefautPct,
    int? seuilStockGlobal,
    bool? fideliteActive,
    double? pointsParDinar,
    String? devise,
    int? decimalesQuantite,
    String? typeMarge,
    double? margeMontant,
    int? seuilStockMax,
    String? venteSousAchat,
    bool? nombreActif,
    String? regimeFiscal,
    bool? timbreActif,
    bool? tvaCaisse,
    bool? tvaDocuments,
  }) => ParametresVente(
    margeDefautPct: margeDefautPct ?? this.margeDefautPct,
    seuilStockGlobal: seuilStockGlobal ?? this.seuilStockGlobal,
    fideliteActive: fideliteActive ?? this.fideliteActive,
    pointsParDinar: pointsParDinar ?? this.pointsParDinar,
    devise: devise ?? this.devise,
    decimalesQuantite: decimalesQuantite ?? this.decimalesQuantite,
    typeMarge: typeMarge ?? this.typeMarge,
    margeMontant: margeMontant ?? this.margeMontant,
    seuilStockMax: seuilStockMax ?? this.seuilStockMax,
    venteSousAchat: venteSousAchat ?? this.venteSousAchat,
    nombreActif: nombreActif ?? this.nombreActif,
    regimeFiscal: regimeFiscal ?? this.regimeFiscal,
    timbreActif: timbreActif ?? this.timbreActif,
    tvaCaisse: tvaCaisse ?? this.tvaCaisse,
    tvaDocuments: tvaDocuments ?? this.tvaDocuments,
  );

  Map<String, String> versCles() => {
    cleMarge: margeDefautPct.toString(),
    cleSeuil: seuilStockGlobal.toString(),
    cleFidelite: fideliteActive ? '1' : '0',
    clePoints: pointsParDinar.toString(),
    cleDevise: devise,
    cleDecimales: decimalesQuantite.toString(),
    cleTypeMarge: typeMarge,
    cleMargeMontant: margeMontant.toString(),
    cleSeuilMax: seuilStockMax.toString(),
    cleVenteSousAchat: venteSousAchat,
    cleNombre: nombreActif ? '1' : '0',
    Fiscalite.cleRegime: regimeFiscal,
    Fiscalite.cleTimbre: timbreActif ? '1' : '0',
    Fiscalite.cleTvaCaisse: tvaCaisse ? '1' : '0',
    Fiscalite.cleTvaDocuments: tvaDocuments ? '1' : '0',
  };

  factory ParametresVente.depuisCles(Map<String, String?> m) => ParametresVente(
    margeDefautPct: double.tryParse(m[cleMarge] ?? '') ?? 20,
    seuilStockGlobal: int.tryParse(m[cleSeuil] ?? '') ?? 5,
    fideliteActive: m[cleFidelite] == '1',
    pointsParDinar: double.tryParse(m[clePoints] ?? '') ?? 0.01,
    devise: m[cleDevise] ?? 'DA',
    decimalesQuantite: (int.tryParse(m[cleDecimales] ?? '') ?? 2).clamp(0, 3),
    typeMarge: m[cleTypeMarge] == typeMargeMontant ? typeMargeMontant : typeMargePourcentage,
    margeMontant: double.tryParse(m[cleMargeMontant] ?? '') ?? 50,
    seuilStockMax: int.tryParse(m[cleSeuilMax] ?? '') ?? 0,
    venteSousAchat: switch (m[cleVenteSousAchat]) {
      venteSousAchatInterdire => venteSousAchatInterdire,
      venteSousAchatAutoriser => venteSousAchatAutoriser,
      _ => venteSousAchatAvertir,
    },
    nombreActif: m[cleNombre] == '1',
    regimeFiscal: m[Fiscalite.cleRegime] == RegimesFiscaux.ifu ? RegimesFiscaux.ifu : RegimesFiscaux.reel,
    timbreActif: m[Fiscalite.cleTimbre] != '0',
    tvaCaisse: m[Fiscalite.cleTvaCaisse] != '0',
    tvaDocuments: m[Fiscalite.cleTvaDocuments] != '0',
  );

  @override
  bool operator ==(Object other) =>
      other is ParametresVente &&
      other.margeDefautPct == margeDefautPct &&
      other.seuilStockGlobal == seuilStockGlobal &&
      other.fideliteActive == fideliteActive &&
      other.pointsParDinar == pointsParDinar &&
      other.devise == devise &&
      other.decimalesQuantite == decimalesQuantite &&
      other.typeMarge == typeMarge &&
      other.margeMontant == margeMontant &&
      other.seuilStockMax == seuilStockMax &&
      other.venteSousAchat == venteSousAchat &&
      other.nombreActif == nombreActif &&
      other.regimeFiscal == regimeFiscal &&
      other.timbreActif == timbreActif &&
      other.tvaCaisse == tvaCaisse &&
      other.tvaDocuments == tvaDocuments;
  @override
  int get hashCode => Object.hash(
    margeDefautPct,
    seuilStockGlobal,
    fideliteActive,
    pointsParDinar,
    devise,
    decimalesQuantite,
    typeMarge,
    margeMontant,
    seuilStockMax,
    venteSousAchat,
    nombreActif,
    regimeFiscal,
    timbreActif,
    tvaCaisse,
    tvaDocuments,
  );
}
