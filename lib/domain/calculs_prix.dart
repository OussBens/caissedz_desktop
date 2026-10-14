/// Calculs de prix et de marge (§8).
///
/// Marge exprimée en pourcentage du prix d'achat : PV = PA × (1 + marge/100).
class CalculsPrix {
  const CalculsPrix._();

  static double prixVenteDepuisMarge(double prixAchat, double margePct) => arrondir(prixAchat * (1 + margePct / 100));

  static double margeDepuisPrix(double prixAchat, double prixVente) =>
      prixAchat <= 0 ? 0 : arrondir((prixVente - prixAchat) / prixAchat * 100);

  /// Arrondi monétaire à 2 décimales (demi vers le haut).
  static double arrondir(double v) => v.sign * ((v.abs() * 100 + 1e-9).roundToDouble()) / 100;

  static double remise(double montant, {required String type, required double valeur}) {
    final r = type == 'Pourcentage' ? montant * valeur / 100 : valeur;
    return arrondir(r.clamp(0, montant));
  }
}
