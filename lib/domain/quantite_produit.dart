/// Quantité d'un produit (contenance ou poids), donnée à part par le catalogue ou écrite dans son nom :
/// « Eau Hayat 50cl » → nom « Eau Hayat », quantité « 500 ml » (type « Contenance »).
///
/// Les quantités sont écrites comme les tailles de la fiche produit (« 500 ml », « 1,5 L », « 250 g », « 1 kg »)
/// et typées par les valeurs du référentiel `typesTaille` (« Contenance », « Poids »).
abstract final class QuantiteProduit {
  static const String contenance = 'Contenance';
  static const String poids = 'Poids';

  /// Une quantité dans un texte : nombre puis unité, détachés des lettres et chiffres voisins (« 6x1,5L »,
  /// un lot, n'est pas lu comme une quantité).
  static final RegExp _motif = RegExp(
    r'(?<![\p{L}\d.,])(\d+(?:[.,]\d+)?)\s*(ml|cl|dl|litres?|lt|l|kg|grammes?|grs?|g|mg)\.?(?![\p{L}\d])',
    caseSensitive: false,
    unicode: true,
  );

  static const Map<String, (double, String)> _unites = {
    'ml': (1, contenance),
    'cl': (10, contenance),
    'dl': (100, contenance),
    'l': (1000, contenance),
    'lt': (1000, contenance),
    'litre': (1000, contenance),
    'litres': (1000, contenance),
    'mg': (0.001, poids),
    'g': (1, poids),
    'gr': (1, poids),
    'grs': (1, poids),
    'gramme': (1, poids),
    'grammes': (1, poids),
    'kg': (1000, poids),
  };

  /// [brut] écrit comme une taille de la fiche (« 50cl » → « 500 ml », « 0.5l » → « 500 ml », « 1000 g » →
  /// « 1 kg ») avec son type ; `null` si ce n'est pas une quantité avec unité.
  static ({String texte, String type})? normaliser(String brut) {
    final m = _motif.firstMatch(brut.trim());
    if (m == null || m.start != 0 || m.end != brut.trim().length) return null;
    return _lire(m);
  }

  /// Le type (« Contenance », « Poids ») commun à toutes les [tailles], `null` sinon.
  static String? typeCommun(Iterable<String> tailles) {
    final types = {for (final t in tailles) normaliser(t)?.type};
    return types.length == 1 ? types.single : null;
  }

  /// Sépare le nom et la quantité : la quantité du catalogue ([quantite]) si elle est donnée, sinon celle lue
  /// dans le nom ; le nom est rendu sans les quantités qu'il contient. Le nom n'est jamais vidé : réduit à rien,
  /// il reste tel quel.
  static ({String nom, String? quantite, String? type}) separer(String nom, {String? quantite}) {
    final donnee = quantite?.trim() ?? '';
    final lue = donnee.isEmpty ? null : normaliser(donnee);
    final trouvees = [
      for (final m in _motif.allMatches(nom))
        if (_lire(m) case final q?) (m, q),
    ];
    final q = lue ?? trouvees.firstOrNull?.$2;
    var reste = nom;
    for (final (m, _) in trouvees.reversed) {
      reste = reste.replaceRange(m.start, m.end, ' ');
    }
    reste = _nettoyer(reste);
    return (
      nom: reste.isEmpty ? nom.trim() : reste,
      quantite: q?.texte ?? (donnee.isEmpty ? null : donnee),
      type: q?.type,
    );
  }

  static ({String texte, String type})? _lire(RegExpMatch m) {
    final valeur = double.tryParse(m[1]!.replaceAll(',', '.'));
    final unite = _unites[m[2]!.toLowerCase()];
    if (valeur == null || valeur <= 0 || unite == null) return null;
    final base = valeur * unite.$1;
    final grande = unite.$2 == contenance ? 'L' : 'kg';
    final petite = unite.$2 == contenance ? 'ml' : 'g';
    final texte = base >= 1000 ? '${_nombre(base / 1000)} $grande' : '${_nombre(base)} $petite';
    return (texte: texte, type: unite.$2);
  }

  /// 1.5 → « 1,5 » ; 500.0 → « 500 » (au millième près).
  static String _nombre(double v) {
    final s = v.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
    return s.replaceAll('.', ',');
  }

  /// Espaces doublés, parenthèses vidées et séparateurs laissés en bout de nom.
  static String _nettoyer(String s) => s
      .replaceAll(RegExp(r'\(\s*\)|\[\s*\]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAllMapped(RegExp(r'\s*([,;])(?:\s*[,;])*'), (m) => m[1]!)
      .replaceAll(RegExp(r'^[\s\-–—,;/|:]+|[\s\-–—,;/|:]+$'), '')
      .trim();
}
