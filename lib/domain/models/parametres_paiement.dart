import 'package:flutter/foundation.dart';

/// Moyens de paiement proposés en caisse (`paiement_param`, §7.9). Les espèces sont toujours acceptées.
@immutable
class ParametresPaiement {
  const ParametresPaiement({this.carte = true, this.cheque = false, this.virement = false, this.points = true});

  static const String cleCarte = 'paiement_carte_visible';
  static const String cleCheque = 'paiement_cheque_visible';
  static const String cleVirement = 'paiement_virement_visible';
  static const String clePoints = 'paiement_points_visible';
  static const List<String> cles = [cleCarte, cleCheque, cleVirement, clePoints];

  final bool carte;
  final bool cheque;
  final bool virement;

  /// Paiement en points de fidélité (proposé seulement si le bonus fidélité est actif).
  final bool points;

  /// Valeurs stockées (référentiel `modesPaiement`) des moyens acceptés.
  List<String> get modes => [
    'Espèces',
    if (carte) 'Carte',
    if (cheque) 'Chèque',
    if (virement) 'Virement',
    if (points) 'Points',
  ];

  ParametresPaiement copyWith({bool? carte, bool? cheque, bool? virement, bool? points}) => ParametresPaiement(
    carte: carte ?? this.carte,
    cheque: cheque ?? this.cheque,
    virement: virement ?? this.virement,
    points: points ?? this.points,
  );

  Map<String, String> versCles() => {
    cleCarte: carte ? '1' : '0',
    cleCheque: cheque ? '1' : '0',
    cleVirement: virement ? '1' : '0',
    clePoints: points ? '1' : '0',
  };

  factory ParametresPaiement.depuisCles(Map<String, String?> m) => ParametresPaiement(
    carte: (m[cleCarte] ?? '1') == '1',
    cheque: m[cleCheque] == '1',
    virement: m[cleVirement] == '1',
    points: (m[clePoints] ?? '1') == '1',
  );

  @override
  bool operator ==(Object other) =>
      other is ParametresPaiement &&
      other.carte == carte &&
      other.cheque == cheque &&
      other.virement == virement &&
      other.points == points;
  @override
  int get hashCode => Object.hash(carte, cheque, virement, points);
}
