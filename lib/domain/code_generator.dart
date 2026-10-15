/// Codification des entités (§8.10 de la spécification).
///
/// Format : préfixe alphabétique + compteur numérique sur 4 chiffres minimum
/// (`MAG0001`, `CLN0042`, `CATE0003`). Les codes `XXX0000` sont réservés aux
/// éléments système créés par le seed (`MAG0000`, `CIS0000`, `CLN0000`,
/// `FOR0000`, `CATE0000`, `SC0000`).
///
/// ⚠️ PROVISOIRE : la liste exacte des préfixes et le nombre de chiffres par
/// entité seront confirmés avec le §8.10 de la spec.
class CodeGenerator {
  const CodeGenerator._();

  static const int chiffres = 4;

  static const String magasin = 'MAG';
  static const String caisse = 'CS';

  /// Préfixe de la caisse système `CIS0000` (les caisses créées sont en `CS`).
  static const String caisseSysteme = 'CIS';
  static const String client = 'CLN';
  static const String fournisseur = 'FOR';
  static const String categorie = 'CATE';
  static const String sousCategorie = 'SC';
  static const String transfertStock = 'TRM';
  static const String transfertCaisse = 'TRF';
  static const String utilisateur = 'USR';
  static const String produit = 'PRD';
  static const String colis = 'COL';
  static const String pack = 'PCK';
  static const String remise = 'REM';
  static const String besoin = 'BL';
  static const String sortie = 'SRT';
  static const String sessionCaisse = 'SES';
  static const String vente = 'VTE';
  static const String retour = 'RET';
  static const String versement = 'VER';
  static const String achat = 'SS';
  static const String bonReception = 'BON';
  static const String cloture = 'CLT';
  static const String inventaire = 'INV';

  static final RegExp _format = RegExp(r'^([A-Z]+)(\d+)$');

  /// Code système (`PREFIXE0000`).
  static String systeme(String prefixe) => '$prefixe${'0' * chiffres}';

  /// Code pour un numéro donné (`MAG` + 7 → `MAG0007`).
  static String pour(String prefixe, int numero) {
    if (numero < 0) throw ArgumentError.value(numero, 'numero', 'doit être positif');
    return '$prefixe${numero.toString().padLeft(chiffres, '0')}';
  }

  /// Numéro contenu dans un code, ou `null` si le code n'est pas au format attendu.
  static int? numero(String code, String prefixe) {
    final m = _format.firstMatch(code);
    if (m == null || m.group(1) != prefixe) return null;
    return int.parse(m.group(2)!);
  }

  /// Code suivant le dernier code connu (`null` ou code système → `PREFIXE0001`).
  static String suivant(String prefixe, String? dernierCode) {
    final n = dernierCode == null ? 0 : (numero(dernierCode, prefixe) ?? 0);
    return pour(prefixe, n + 1);
  }

  /// Vérifie qu'un code respecte le format `PREFIXE` + chiffres.
  static bool estValide(String code, String prefixe) => numero(code, prefixe) != null;
}
