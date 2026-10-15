import 'package:flutter/foundation.dart';

import 'calculs_prix.dart';

/// Calcul de la zakat (§9.15) :
/// capital = stock + liquidités + créances − dettes ;
/// obligatoire = nissab > 0 ET capital ≥ nissab ; montant = obligatoire ? capital × taux : 0.
class CalculZakat {
  const CalculZakat._();

  /// Taux par défaut (2,5 %).
  static const double tauxDefautPct = 2.5;

  /// Grammes d'or du nissab (aide à la saisie : nissab = 85 g × cours du jour).
  static const double grammesNissab = 85;

  /// Durée du hawl (année lunaire) : échéance = début + 354 jours.
  static const int joursHawl = 354;

  static double capital({
    required double stock,
    required double liquidites,
    required double creances,
    required double dettes,
  }) => CalculsPrix.arrondir(stock + liquidites + creances - dettes);

  static bool obligatoire(double capital, double nissab) => nissab > 0 && capital >= nissab;

  static double montant(double capital, double nissab, double tauxPct) =>
      obligatoire(capital, nissab) ? CalculsPrix.arrondir(capital * tauxPct / 100) : 0;

  static DateTime echeance(DateTime debutHawl) => debutHawl.add(const Duration(days: joursHawl));
}

/// Valeurs reprises automatiquement pour un calcul (stock au prix d'achat, soldes des caisses, crédits).
@immutable
class PatrimoineZakat {
  const PatrimoineZakat({this.stock = 0, this.liquidites = 0, this.creances = 0, this.dettes = 0});
  final double stock;
  final double liquidites;
  final double creances;
  final double dettes;

  double get capital => CalculZakat.capital(stock: stock, liquidites: liquidites, creances: creances, dettes: dettes);
}

/// Statuts stockés (référentiel `statutZakat`, valeur FR).
class StatutsZakat {
  const StatutsZakat._();
  static const String brouillon = 'Brouillon';
  static const String nonPaye = 'Non payé';
  static const String payee = 'Payée';
}

/// Calcul de zakat enregistré (table `zakat`, codes `ZKT`).
@immutable
class Zakat {
  const Zakat({
    required this.code,
    required this.annee,
    required this.debutHawl,
    required this.dateDue,
    required this.stock,
    required this.liquidites,
    required this.creances,
    required this.dettes,
    required this.nissab,
    this.tauxPct = CalculZakat.tauxDefautPct,
    this.statut = StatutsZakat.brouillon,
    this.datePaiement,
    this.observation = '',
    this.actif = true,
    this.motifAnnulation,
    this.creePar,
    this.creeLe,
    this.modifiePar,
  });

  final String code;
  final int annee;
  final DateTime debutHawl;
  final DateTime dateDue;
  final double stock;
  final double liquidites;
  final double creances;
  final double dettes;
  final double nissab;
  final double tauxPct;
  final String statut;
  final DateTime? datePaiement;
  final String observation;

  /// `false` = calcul annulé (annulation douce avec motif).
  final bool actif;
  final String? motifAnnulation;
  final String? creePar;
  final DateTime? creeLe;
  final String? modifiePar;

  double get capital => CalculZakat.capital(stock: stock, liquidites: liquidites, creances: creances, dettes: dettes);
  bool get obligatoire => CalculZakat.obligatoire(capital, nissab);
  double get montant => CalculZakat.montant(capital, nissab, tauxPct);
  bool get estPayee => statut == StatutsZakat.payee;

  static String _jour(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, Object?> versLigne() => {
    'code': code,
    'annee': annee,
    'date_debut_hawl': _jour(debutHawl),
    'date_zakat_due': _jour(dateDue),
    'stock': stock,
    'liquidites': liquidites,
    'creances': creances,
    'dettes': dettes,
    'capital_total': capital,
    'nissab': nissab,
    'taux': tauxPct,
    'obligatoire': obligatoire ? 1 : 0,
    'montant_zakat': montant,
    'statut': statut,
    'date_paiement': datePaiement == null ? null : _jour(datePaiement!),
    'observation': observation,
  };

  factory Zakat.depuisLigne(Map<String, Object?> r) => Zakat(
    code: r['code'] as String,
    annee: r['annee'] as int,
    debutHawl: DateTime.parse(r['date_debut_hawl'] as String),
    dateDue: DateTime.parse(r['date_zakat_due'] as String),
    stock: (r['stock'] as num).toDouble(),
    liquidites: (r['liquidites'] as num).toDouble(),
    creances: (r['creances'] as num).toDouble(),
    dettes: (r['dettes'] as num).toDouble(),
    nissab: (r['nissab'] as num).toDouble(),
    tauxPct: (r['taux'] as num).toDouble(),
    statut: r['statut'] as String,
    datePaiement: DateTime.tryParse((r['date_paiement'] as String?) ?? ''),
    observation: (r['observation'] as String?) ?? '',
    actif: (r['actif'] as int) == 1,
    motifAnnulation: r['motif_annulation'] as String?,
    creePar: r['cree_par'] as String?,
    creeLe: DateTime.tryParse((r['cree_le'] as String?) ?? '')?.toLocal(),
    modifiePar: r['modifie_par'] as String?,
  );
}
