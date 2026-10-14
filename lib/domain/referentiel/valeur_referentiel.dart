import 'dart:ui';

/// Une valeur d'une liste de valeurs (§13) : la valeur STOCKÉE en base est la
/// valeur française [stocke] ; les libellés servent uniquement à l'affichage.
class ValeurReferentiel {
  const ValeurReferentiel({required this.stocke, required this.fr, required this.ar, required this.en});

  final String stocke;
  final String fr;
  final String ar;
  final String en;

  String libelle(Locale locale) => switch (locale.languageCode) {
    'ar' => ar,
    'en' => en,
    _ => fr,
  };

  @override
  bool operator ==(Object other) => other is ValeurReferentiel && other.stocke == stocke;
  @override
  int get hashCode => stocke.hashCode;
  @override
  String toString() => stocke;
}

/// Liste de valeurs nommée.
class ListeReferentiel {
  const ListeReferentiel(this.nom, this.valeurs);

  final String nom;
  final List<ValeurReferentiel> valeurs;

  ValeurReferentiel? parValeurStockee(String stocke) => valeurs.where((v) => v.stocke == stocke).firstOrNull;

  bool contient(String stocke) => parValeurStockee(stocke) != null;

  String libelle(String stocke, Locale locale) => parValeurStockee(stocke)?.libelle(locale) ?? stocke;
}
