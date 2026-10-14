import 'package:flutter/foundation.dart';

import '../permissions.dart';

/// État de la licence (table `licence`, ligne unique).
@immutable
class Licence {
  const Licence({required this.niveau, this.cle, this.demo = false, this.activeeLe});

  /// Licence absente : application non activée.
  static const Licence aucune = Licence(niveau: null);

  final NiveauLicence? niveau;
  final String? cle;
  final bool demo;
  final DateTime? activeeLe;

  bool get estActivee => niveau != null;

  bool couvre(NiveauLicence requis) => niveau?.couvre(requis) ?? false;

  @override
  bool operator ==(Object other) => other is Licence && other.niveau == niveau && other.cle == cle && other.demo == demo;
  @override
  int get hashCode => Object.hash(niveau, cle, demo);
}
