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
  });

  static const String cleMarge = 'marge_defaut_pct';
  static const String cleSeuil = 'seuil_stock_global';
  static const String cleFidelite = 'fidelite_active';
  static const String clePoints = 'fidelite_points_par_dinar';
  static const String cleDevise = 'devise';

  final double margeDefautPct;
  final int seuilStockGlobal;
  final bool fideliteActive;
  final double pointsParDinar;
  final String devise;

  ParametresVente copyWith({
    double? margeDefautPct,
    int? seuilStockGlobal,
    bool? fideliteActive,
    double? pointsParDinar,
    String? devise,
  }) => ParametresVente(
    margeDefautPct: margeDefautPct ?? this.margeDefautPct,
    seuilStockGlobal: seuilStockGlobal ?? this.seuilStockGlobal,
    fideliteActive: fideliteActive ?? this.fideliteActive,
    pointsParDinar: pointsParDinar ?? this.pointsParDinar,
    devise: devise ?? this.devise,
  );

  Map<String, String> versCles() => {
    cleMarge: margeDefautPct.toString(),
    cleSeuil: seuilStockGlobal.toString(),
    cleFidelite: fideliteActive ? '1' : '0',
    clePoints: pointsParDinar.toString(),
    cleDevise: devise,
  };

  factory ParametresVente.depuisCles(Map<String, String?> m) => ParametresVente(
    margeDefautPct: double.tryParse(m[cleMarge] ?? '') ?? 20,
    seuilStockGlobal: int.tryParse(m[cleSeuil] ?? '') ?? 5,
    fideliteActive: m[cleFidelite] == '1',
    pointsParDinar: double.tryParse(m[clePoints] ?? '') ?? 0.01,
    devise: m[cleDevise] ?? 'DA',
  );

  @override
  bool operator ==(Object other) =>
      other is ParametresVente &&
      other.margeDefautPct == margeDefautPct &&
      other.seuilStockGlobal == seuilStockGlobal &&
      other.fideliteActive == fideliteActive &&
      other.pointsParDinar == pointsParDinar &&
      other.devise == devise;
  @override
  int get hashCode => Object.hash(margeDefautPct, seuilStockGlobal, fideliteActive, pointsParDinar, devise);
}
