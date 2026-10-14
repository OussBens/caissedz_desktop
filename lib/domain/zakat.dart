import 'package:flutter/foundation.dart';

import 'calculs_prix.dart';

/// Résultat du calcul de la zakat sur les biens commerciaux.
@immutable
class ResultatZakat {
  const ResultatZakat({
    required this.stock,
    required this.caisses,
    required this.creances,
    required this.dettes,
    required this.prixGrammeOr,
    required this.grammesNissab,
    required this.tauxPct,
  });
  final double stock;
  final double caisses;
  final double creances;
  final double dettes;
  final double prixGrammeOr;
  final double grammesNissab;
  final double tauxPct;

  /// Assiette = stock (prix d'achat) + caisses + créances clients − dettes fournisseurs.
  double get assiette => CalculsPrix.arrondir(stock + caisses + creances - dettes);
  double get nissab => CalculsPrix.arrondir(grammesNissab * prixGrammeOr);
  bool get assujetti => prixGrammeOr > 0 && assiette >= nissab && assiette > 0;
  double get montant => assujetti ? CalculsPrix.arrondir(assiette * tauxPct / 100) : 0;
}

/// Zakat (§8) : nissab = 85 g d'or au cours saisi, taux 2,5 % de l'assiette.
///
/// ⚠️ PROVISOIRE : règle déduite de la commande (nissab, taux) ; le détail de §8 sera aligné dès réception.
class CalculZakat {
  const CalculZakat._();
  static const double grammesNissabDefaut = 85;
  static const double tauxDefautPct = 2.5;

  static ResultatZakat calculer({
    required double stock,
    required double caisses,
    required double creances,
    required double dettes,
    required double prixGrammeOr,
    double grammesNissab = grammesNissabDefaut,
    double tauxPct = tauxDefautPct,
  }) => ResultatZakat(
    stock: stock,
    caisses: caisses,
    creances: creances,
    dettes: dettes,
    prixGrammeOr: prixGrammeOr,
    grammesNissab: grammesNissab,
    tauxPct: tauxPct,
  );
}
