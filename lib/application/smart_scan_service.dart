import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Ligne reconnue sur une facture fournisseur par Smart Scan IA.
class LigneSmartScan {
  const LigneSmartScan({
    required this.designation,
    this.codeBarres,
    required this.quantite,
    required this.prixAchat,
    this.produitCode,
    this.confiance,
  });
  final String designation;
  final String? codeBarres;
  final double quantite;
  final double prixAchat;

  /// Produit local rapproché (par code-barres ou désignation), s'il existe.
  final String? produitCode;

  /// Confiance de la lecture (0–100), si le serveur la renvoie.
  final double? confiance;

  LigneSmartScan copyWith({String? produitCode, double? quantite, double? prixAchat}) => LigneSmartScan(
    designation: designation,
    codeBarres: codeBarres,
    quantite: quantite ?? this.quantite,
    prixAchat: prixAchat ?? this.prixAchat,
    produitCode: produitCode ?? this.produitCode,
    confiance: confiance,
  );
}

/// Un lot de Smart Scans : ceux inclus dans la formule (ou l'essai), ou un pack, valable jusqu'à [finLe].
class LotSmartScan {
  const LotSmartScan({required this.pack, required this.scans, required this.restant, this.finLe});

  final bool pack;
  final int scans;
  final int restant;
  final DateTime? finLe;

  factory LotSmartScan.fromJson(Map j) => LotSmartScan(
    pack: j['kind'] == 'pack',
    scans: (j['scans'] as num?)?.toInt() ?? 0,
    restant: (j['remaining'] as num?)?.toInt() ?? 0,
    finLe: DateTime.tryParse('${j['endsOn'] ?? ''}'),
  );
}

/// Smart Scans du compte (serveur) : comptés par scans, chaque lot avec sa date de fin.
class QuotaSmartScan {
  const QuotaSmartScan({
    required this.utilise,
    required this.total,
    this.lots = const [],
    this.expirentBientot = const [],
  });
  final int utilise;
  final int total;

  /// Dans l'ordre où ils sont dépensés (inclus d'abord, puis le pack qui expire le plus tôt).
  final List<LotSmartScan> lots;

  /// Lots avec des scans restants qui expirent dans les 30 jours (rappel avant l'expiration).
  final List<LotSmartScan> expirentBientot;

  int get restant => (total - utilise).clamp(0, total);
  bool get atteint => restant <= 0;

  factory QuotaSmartScan.fromJson(Map j) {
    final total = ((j['limit'] ?? j['monthly_limit']) as num?)?.toInt() ?? 0;
    final restant = (j['remaining'] as num?)?.toInt();
    return QuotaSmartScan(
      utilise: restant != null ? total - restant : ((j['used'] as num?)?.toInt() ?? 0),
      total: total,
      lots: [for (final b in j['buckets'] as List? ?? const []) LotSmartScan.fromJson(b as Map)],
      expirentBientot: [for (final b in j['expiring_soon'] as List? ?? const []) LotSmartScan.fromJson(b as Map)],
    );
  }
}

enum ErreurSmartScan {
  nonConfigure,
  quotaAtteint,
  reseau,
  serveur,
  fichierInvalide,

  /// Licence du poste refusée par le serveur (absente, expirée, d'un autre poste).
  licence,
}

class SmartScanException implements Exception {
  const SmartScanException(this.erreur, [this.detail]);
  final ErreurSmartScan erreur;
  final String? detail;
  @override
  String toString() => 'SmartScanException($erreur)';
}

/// Résultat d'une analyse.
class ResultatSmartScan {
  const ResultatSmartScan({required this.lignes, required this.quota, this.fournisseur, this.reference, this.total});
  final List<LigneSmartScan> lignes;
  final QuotaSmartScan quota;
  final String? fournisseur;
  final String? reference;
  final double? total;
}

/// L'identité du poste pour Smart Scan : son identifiant brut (X-Device-Id) et sa licence BENS signée
/// (X-License-Key), celle que le serveur vérifie comme l'application.
typedef IdentiteSmartScan = ({String machine, String? cle});

/// Smart Scan IA (catalog-api.bensds.com/smartscan/*) : la photo de la facture, lue par OCR (un scan
/// compté seulement si du texte est lu), puis ses lignes extraites (gratuit : le scan est déjà compté).
/// Les scans sont ceux du compte BENS : inclus dans la formule, puis les packs.
class SmartScanService {
  const SmartScanService({required this.client, this.baseUrl = urlParDefaut, required this.identite, this.entreprise});

  /// Le serveur Smart Scan de BENS.
  static const String urlParDefaut = 'https://catalog-api.bensds.com';

  static const String modeleExtraction = 'mistral-small-latest';

  final http.Client client;
  final String baseUrl;
  final Future<IdentiteSmartScan> Function() identite;

  /// Nom du commerce (X-Entreprise), facultatif.
  final String? entreprise;

  bool get configure => baseUrl.isNotEmpty;

  Future<Map<String, dynamic>> _envoyer(
    String methode,
    String chemin, {
    Map<String, Object?>? corps,
    Duration delai = const Duration(seconds: 20),
  }) async {
    if (!configure) throw const SmartScanException(ErreurSmartScan.nonConfigure);
    final id = await identite();
    final cle = id.cle;
    if (cle == null || cle.isEmpty) throw const SmartScanException(ErreurSmartScan.licence);
    final http.Response r;
    try {
      final req = http.Request(methode, Uri.parse('$baseUrl/smartscan/$chemin'))
        ..headers.addAll({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Device-Id': id.machine,
          'X-License-Key': cle,
          if (entreprise != null && entreprise!.trim().isNotEmpty)
            'X-Entreprise': Uri.encodeComponent(entreprise!.trim()),
        });
      if (corps != null) req.body = jsonEncode(corps);
      r = await http.Response.fromStream(await client.send(req).timeout(delai));
    } on Object catch (e) {
      throw SmartScanException(ErreurSmartScan.reseau, e.toString());
    }
    Map<String, dynamic> j;
    try {
      j = (jsonDecode(utf8.decode(r.bodyBytes)) as Map).cast<String, dynamic>();
    } on Object {
      throw SmartScanException(ErreurSmartScan.serveur, 'HTTP ${r.statusCode}');
    }
    if (r.statusCode == 200) return j;
    final code = j['error'] is String ? j['error'] as String : '';
    final message = j['message'] as String?;
    throw SmartScanException(switch ((r.statusCode, code)) {
      (429, 'SCAN_QUOTA_EXCEEDED') => ErreurSmartScan.quotaAtteint,
      (401, _) || (403, 'DEVICE_BLOCKED') => ErreurSmartScan.licence,
      (400 || 413, 'INVALID_IMAGE' || 'IMAGE_TOO_LARGE') => ErreurSmartScan.fichierInvalide,
      (503, 'SERVER_NOT_CONFIGURED') => ErreurSmartScan.nonConfigure,
      _ => ErreurSmartScan.serveur,
    }, message ?? code);
  }

  Future<QuotaSmartScan> quota() async => QuotaSmartScan.fromJson((await _envoyer('GET', 'quota'))['quota'] as Map);

  /// Le type d'image d'après le nom du fichier (le serveur lit JPG, PNG, WEBP).
  static String? typeImage(String nomFichier) => switch (nomFichier.split('.').last.toLowerCase()) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => null,
  };

  /// OCR de la facture puis extraction de ses lignes.
  Future<ResultatSmartScan> analyser(Uint8List fichier, {required String nomFichier}) async {
    final type = typeImage(nomFichier);
    if (fichier.isEmpty || type == null) throw const SmartScanException(ErreurSmartScan.fichierInvalide);
    final scan = await _envoyer(
      'POST',
      'scan',
      corps: {'image': 'data:$type;base64,${base64Encode(fichier)}'},
      delai: const Duration(seconds: 100),
    );
    final quota = QuotaSmartScan.fromJson(scan['quota'] as Map);
    final extraction = await _envoyer(
      'POST',
      'extract',
      corps: {
        'scan_id': (scan['scan_id'] as num).toInt(),
        'model': modeleExtraction,
        'temperature': 0,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': consigneExtraction},
          {'role': 'user', 'content': scan['text'] as String? ?? ''},
        ],
      },
      delai: const Duration(seconds: 60),
    );
    final message = ((extraction['choices'] as List).first as Map)['message'] as Map;
    final lu = lireFacture(message['content'] as String? ?? '');
    return ResultatSmartScan(lignes: lu.lignes, quota: quota, fournisseur: lu.fournisseur, reference: lu.reference);
  }

  /// La consigne d'extraction (la même que CaisseDZ Mobile, avec la référence du bon).
  static const String consigneExtraction = '''
Tu lis le texte OCR d'une facture ou d'un bon de livraison d'un fournisseur algérien (français, arabe ou les deux).
Réponds uniquement avec un objet JSON de cette forme :
{"fournisseur": "nom du fournisseur ou null", "reference": "numéro de la facture ou du bon, ou null",
 "lignes": [{"designation": "nom du produit tel qu'écrit", "code_barres": "code EAN s'il est écrit, sinon null",
             "quantite": nombre d'unités livrées, "prix_unitaire": prix d'achat d'une unité en DA ou null}]}
Ignore les totaux, la TVA, les remises, les frais de livraison et les lignes qui ne sont pas des produits.
Si la quantité est en cartons ou en fardeaux et que le nombre d'unités par carton est écrit, donne le nombre d'unités.''';

  /// Lit le JSON du modèle ; accepte les nombres écrits en texte (« 12 », « 1 250,00 »).
  static ({List<LigneSmartScan> lignes, String? fournisseur, String? reference}) lireFacture(String contenu) {
    final debut = contenu.indexOf('{');
    final fin = contenu.lastIndexOf('}');
    if (debut < 0 || fin < debut) throw const SmartScanException(ErreurSmartScan.serveur, 'EXTRACTION_FAILED');
    final Map j;
    try {
      j = jsonDecode(contenu.substring(debut, fin + 1)) as Map;
    } on Object {
      throw const SmartScanException(ErreurSmartScan.serveur, 'EXTRACTION_FAILED');
    }
    double? nombre(Object? v) => switch (v) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s.replaceAll(RegExp(r'[\s ]'), '').replaceAll(',', '.')),
      _ => null,
    };
    String? texte(Object? v) => v is String && v.trim().isNotEmpty && v.trim() != 'null' ? v.trim() : null;
    final lignes = <LigneSmartScan>[];
    for (final l in (j['lignes'] as List?) ?? const []) {
      if (l is! Map) continue;
      final designation = texte(l['designation']);
      final quantite = nombre(l['quantite']) ?? 0;
      if (designation == null || quantite <= 0) continue;
      final prix = nombre(l['prix_unitaire'] ?? l['prix_achat']);
      final code = texte(l['code_barres'])?.replaceAll(RegExp(r'\s'), '');
      lignes.add(
        LigneSmartScan(
          designation: designation,
          codeBarres: code != null && RegExp(r'^\d{8,14}$').hasMatch(code) ? code : null,
          quantite: quantite,
          prixAchat: prix == null || prix <= 0 ? 0 : prix,
          confiance: nombre(l['confiance']),
        ),
      );
    }
    return (lignes: lignes, fournisseur: texte(j['fournisseur']), reference: texte(j['reference']));
  }
}
