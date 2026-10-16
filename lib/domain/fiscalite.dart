import 'calculs_prix.dart';

/// Régimes fiscaux (valeurs stockées, paramètre `regime_fiscal`).
abstract final class RegimesFiscaux {
  /// Régime du réel : TVA collectée sur les ventes, TVA déductible sur les entrées.
  static const String reel = 'Réel';

  /// Impôt forfaitaire unique : ventes sans TVA, aucune TVA déductible.
  static const String ifu = 'IFU';
  static const List<String> tous = [reel, ifu];
}

/// Fiscalité algérienne : ventilation HT / TVA des prix TTC et droit de timbre des paiements en espèces.
abstract final class Fiscalite {
  static const String cleRegime = 'regime_fiscal';
  static const String cleTimbre = 'timbre_actif';

  /// Taux de TVA d'une ligne selon le régime (IFU : 0).
  static double taux(double tauxProduit, String regime) => regime == RegimesFiscaux.ifu ? 0 : tauxProduit;

  /// Prix TTC ventilé : HT arrondi au centime, TVA = TTC − HT (la somme reste exacte).
  static ({double ht, double tva}) ventiler(double ttc, double tauxPct) {
    if (tauxPct <= 0) return (ht: CalculsPrix.arrondir(ttc), tva: 0);
    final ht = CalculsPrix.arrondir(ttc / (1 + tauxPct / 100));
    return (ht: ht, tva: CalculsPrix.arrondir(ttc - ht));
  }

  /// Droit de timbre sur la part payée en espèces d'une facture (Code du timbre, art. 258, barème LF 2022).
  /// ⚠️ PROVISOIRE : jusqu'à 300 DA exonéré ; 1 % jusqu'à 30 000 DA ; 1,5 % jusqu'à 100 000 DA ; 2 % au-delà ;
  /// minimum 5 DA ; arrondi au dinar supérieur. À confirmer avec la spécification 06 (§12).
  static double timbre(double especes) {
    if (especes <= 300) return 0;
    final taux = especes <= 30000
        ? 1.0
        : especes <= 100000
        ? 1.5
        : 2.0;
    final t = (especes * taux / 100).ceilToDouble();
    return t < 5 ? 5 : t;
  }
}
