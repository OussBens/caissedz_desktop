/// Calculs de prix et de marge (§8).
///
/// Marge exprimée en pourcentage du prix d'achat : PV = PA × (1 + marge/100), arrondi au multiple de 5 DA supérieur.
class CalculsPrix {
  const CalculsPrix._();

  /// Marge en pourcentage (§8.8, `PrixVenteCalculator`) : arrondi au multiple de [pasArrondi] DA supérieur.
  static double prixVenteDepuisMarge(double prixAchat, double margePct) =>
      arrondirAuPasSuperieur(prixAchat * (1 + margePct / 100));

  /// Marge en montant fixe : prix exact.
  static double prixVenteDepuisMontant(double prixAchat, double marge) => arrondir(prixAchat + marge);

  static const double pasArrondi = 5;

  /// Plus petit multiple de [pas] supérieur ou égal à [v] (tolérance des flottants).
  static double arrondirAuPasSuperieur(double v, {double pas = pasArrondi}) =>
      v <= 0 ? 0 : ((v - 1e-6) / pas).ceil() * pas;

  static double margeDepuisPrix(double prixAchat, double prixVente) =>
      prixAchat <= 0 ? 0 : arrondir((prixVente - prixAchat) / prixAchat * 100);

  /// Arrondi monétaire à 2 décimales (demi vers le haut).
  static double arrondir(double v) => v.sign * ((v.abs() * 100 + 1e-9).roundToDouble()) / 100;

  static double remise(double montant, {required String type, required double valeur}) {
    final r = type == 'Pourcentage' ? montant * valeur / 100 : valeur;
    return arrondir(r.clamp(0, montant));
  }
}
