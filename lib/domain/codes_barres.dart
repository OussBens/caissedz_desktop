import 'dart:math';

/// Codes-barres : EAN-13 (contrôle et génération), code interne CAISSEDZ+date, QR.
///
/// ⚠️ PROVISOIRE : le format exact du code interne « CAISSEDZ + date » sera
/// confirmé avec la spec (§8). Ici : `CDZ` + `AAAAMMJJ` + séquence sur 4 chiffres
/// (CODE128), ex. `CDZ202610140001`.
class CodesBarres {
  const CodesBarres._();

  static const String prefixeInterne = 'CDZ';

  static final RegExp _ean13 = RegExp(r'^\d{13}$');
  static final RegExp _interne = RegExp(r'^CDZ\d{8}\d{4,}$');

  /// Chiffre de contrôle EAN-13 des 12 premiers chiffres.
  static int controleEan13(String douzeChiffres) {
    if (!RegExp(r'^\d{12}$').hasMatch(douzeChiffres)) throw ArgumentError('12 chiffres attendus');
    var somme = 0;
    for (var i = 0; i < 12; i++) {
      final d = int.parse(douzeChiffres[i]);
      somme += i.isEven ? d : d * 3;
    }
    return (10 - somme % 10) % 10;
  }

  static bool ean13Valide(String code) =>
      _ean13.hasMatch(code) && controleEan13(code.substring(0, 12)) == int.parse(code[12]);

  /// Génère un EAN-13 interne (préfixe 20–29 réservé à l'usage interne) à partir d'un numéro.
  static String genererEan13Interne(int numero, {String prefixe = '20'}) {
    if (!RegExp(r'^2\d$').hasMatch(prefixe)) throw ArgumentError('préfixe 20 à 29 attendu');
    final corps = (prefixe + numero.toString().padLeft(10, '0')).substring(0, 12);
    return corps + controleEan13(corps).toString();
  }

  /// EAN-13 aléatoire au préfixe GS1 Algérie `613` (bouton « Générer un EAN-13 » du DS) ; l'unicité est
  /// vérifiée à l'enregistrement.
  static String genererEan13({Random? aleatoire, String prefixe = '613'}) {
    final r = aleatoire ?? Random();
    final corps = prefixe + List.generate(12 - prefixe.length, (_) => r.nextInt(10)).join();
    return corps + controleEan13(corps).toString();
  }

  /// Code interne CAISSEDZ + date + séquence (CODE128).
  static String genererInterne(DateTime date, int sequence) {
    final j =
        '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return '$prefixeInterne$j${sequence.toString().padLeft(4, '0')}';
  }

  static bool interneValide(String code) => _interne.hasMatch(code);

  /// Séquence suivante pour une date donnée à partir du dernier code interne du jour.
  static int sequenceSuivante(DateTime date, String? dernierCodeDuJour) {
    if (dernierCodeDuJour == null || !interneValide(dernierCodeDuJour)) return 1;
    return int.parse(dernierCodeDuJour.substring(11)) + 1;
  }

  /// Contenu du QR code d'un produit : `CDZ:PRD:<code>` (lisible par le scan POS).
  static String contenuQr(String codeProduit) => 'CDZ:PRD:$codeProduit';

  static String? codeProduitDepuisQr(String contenu) {
    final m = RegExp(r'^CDZ:PRD:([A-Z]+\d+)$').firstMatch(contenu.trim());
    return m?.group(1);
  }

  /// Type d'un code scanné.
  static TypeCodeBarres typeDe(String code) {
    final c = code.trim();
    if (codeProduitDepuisQr(c) != null) return TypeCodeBarres.qr;
    if (ean13Valide(c)) return TypeCodeBarres.ean13;
    if (interneValide(c)) return TypeCodeBarres.interne;
    return TypeCodeBarres.autre;
  }
}

enum TypeCodeBarres { ean13, interne, qr, autre }
