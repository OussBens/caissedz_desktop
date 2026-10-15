import 'package:flutter/foundation.dart';

/// Paramètres métier fixés lors de la configuration initiale (table `parametre`).
///
/// ⚠️ PROVISOIRE : la liste exacte (§8) sera alignée au lot 8 (Paramètres complets).
@immutable
class ParametresVente {
  const ParametresVente({
    this.margeDefautPct = 20,
    this.seuilStockGlobal = 5,
    this.fideliteActive = false,
    this.pointsParDinar = 0.01,
    this.devise = 'DA',
    this.decimalesQuantite = 2,
  });

  static const String cleMarge = 'marge_defaut_pct';
  static const String cleSeuil = 'seuil_stock_global';
  static const String cleFidelite = 'fidelite_active';
  static const String clePoints = 'fidelite_points_par_dinar';
  static const String cleDevise = 'devise';
  static const String cleDecimales = 'decimales_quantite';
  static const List<String> cles = [cleMarge, cleSeuil, cleFidelite, clePoints, cleDevise, cleDecimales];

  final double margeDefautPct;
  final int seuilStockGlobal;
  final bool fideliteActive;
  final double pointsParDinar;
  final String devise;

  /// Décimales des quantités (0 à 3 ; 3 pour la vente au poids).
  final int decimalesQuantite;

  ParametresVente copyWith({
    double? margeDefautPct,
    int? seuilStockGlobal,
    bool? fideliteActive,
    double? pointsParDinar,
    String? devise,
    int? decimalesQuantite,
  }) => ParametresVente(
    margeDefautPct: margeDefautPct ?? this.margeDefautPct,
    seuilStockGlobal: seuilStockGlobal ?? this.seuilStockGlobal,
    fideliteActive: fideliteActive ?? this.fideliteActive,
    pointsParDinar: pointsParDinar ?? this.pointsParDinar,
    devise: devise ?? this.devise,
    decimalesQuantite: decimalesQuantite ?? this.decimalesQuantite,
  );

  Map<String, String> versCles() => {
    cleMarge: margeDefautPct.toString(),
    cleSeuil: seuilStockGlobal.toString(),
    cleFidelite: fideliteActive ? '1' : '0',
    clePoints: pointsParDinar.toString(),
    cleDevise: devise,
    cleDecimales: decimalesQuantite.toString(),
  };

  factory ParametresVente.depuisCles(Map<String, String?> m) => ParametresVente(
    margeDefautPct: double.tryParse(m[cleMarge] ?? '') ?? 20,
    seuilStockGlobal: int.tryParse(m[cleSeuil] ?? '') ?? 5,
    fideliteActive: m[cleFidelite] == '1',
    pointsParDinar: double.tryParse(m[clePoints] ?? '') ?? 0.01,
    devise: m[cleDevise] ?? 'DA',
    decimalesQuantite: (int.tryParse(m[cleDecimales] ?? '') ?? 2).clamp(0, 3),
  );

  @override
  bool operator ==(Object other) =>
      other is ParametresVente &&
      other.margeDefautPct == margeDefautPct &&
      other.seuilStockGlobal == seuilStockGlobal &&
      other.fideliteActive == fideliteActive &&
      other.pointsParDinar == pointsParDinar &&
      other.devise == devise &&
      other.decimalesQuantite == decimalesQuantite;
  @override
  int get hashCode =>
      Object.hash(margeDefautPct, seuilStockGlobal, fideliteActive, pointsParDinar, devise, decimalesQuantite);
}
