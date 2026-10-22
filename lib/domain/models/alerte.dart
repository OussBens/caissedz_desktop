import 'package:flutter/foundation.dart';

/// Familles d'alertes du shell (§5.3, `AlertesDialog` du DS v2.2). Les ruptures n'en font plus partie : l'alerte
/// produit « Rupture sans commande » (#14) les couvre, le dialog ne les montre qu'une fois.
enum FamilleAlerte {
  expire(urgente: true, moduleId: 'sorties'),
  sessions(urgente: true, moduleId: 'gestion_caisse'),
  bientot(urgente: false, moduleId: 'produits'),
  clients(urgente: false, moduleId: 'clients'),
  fournisseurs(urgente: false, moduleId: 'fournisseurs');

  const FamilleAlerte({required this.urgente, required this.moduleId});

  /// Groupe « Urgent » (sinon « À surveiller »).
  final bool urgente;

  /// Module ouvert par « Ouvrir le module » et l'action de la famille.
  final String moduleId;
}

/// Une ligne d'alerte (titre, contexte, mesure, jauge éventuelle).
@immutable
class Alerte {
  const Alerte({
    required this.famille,
    required this.cle,
    required this.titre,
    required this.detail,
    this.valeur,
    this.max,
    this.date,
    this.critique = false,
  });

  final FamilleAlerte famille;

  /// Clé stable (code du produit, du client, de la session…).
  final String cle;
  final String titre;
  final String detail;

  /// Quantité en stock, montant dû, jours restants… (`null` si sans objet).
  final double? valeur;

  /// Seuil d'alerte (jauge des ruptures).
  final double? max;

  /// Ouverture de la session, dernier document du tiers…
  final DateTime? date;

  /// Sévérité « danger » (sinon « warning »).
  final bool critique;
}

/// Alertes du jour, par famille (les familles invisibles pour le rôle sont absentes).
@immutable
class AlertesDuJour {
  const AlertesDuJour(this.parFamille);

  static const AlertesDuJour vide = AlertesDuJour({});

  final Map<FamilleAlerte, List<Alerte>> parFamille;

  Iterable<FamilleAlerte> get familles => FamilleAlerte.values.where(parFamille.containsKey);

  List<Alerte> de(FamilleAlerte f) => parFamille[f] ?? const [];

  int get urgentes => familles.where((f) => f.urgente).fold(0, (n, f) => n + de(f).length);
  int get aSurveiller => familles.where((f) => !f.urgente).fold(0, (n, f) => n + de(f).length);
  int get total => urgentes + aSurveiller;
}
