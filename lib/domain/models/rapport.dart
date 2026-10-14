import 'package:flutter/foundation.dart';

/// Colonne d'un rapport (Situation, exports).
@immutable
class RapportColonne {
  const RapportColonne(this.libelle, {this.numerique = false, this.monetaire = false, this.flex = 1});
  final String libelle;
  final bool numerique;

  /// Montant exprimé dans la devise (format `1 234,00 DA`).
  final bool monetaire;
  final int flex;
}

/// Rapport tabulaire générique : colonnes typées, lignes de valeurs brutes, ligne de totaux optionnelle.
@immutable
class Rapport {
  const Rapport({required this.id, required this.titre, required this.colonnes, required this.lignes, this.totaux});
  final String id;
  final String titre;
  final List<RapportColonne> colonnes;
  final List<List<Object?>> lignes;
  final List<Object?>? totaux;

  bool get estVide => lignes.isEmpty;
}
