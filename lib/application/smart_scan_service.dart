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
  });
  final String designation;
  final String? codeBarres;
  final double quantite;
  final double prixAchat;

  /// Produit local rapproché (par code-barres ou désignation), s'il existe.
  final String? produitCode;

  LigneSmartScan copyWith({String? produitCode, double? quantite, double? prixAchat}) => LigneSmartScan(
    designation: designation,
    codeBarres: codeBarres,
    quantite: quantite ?? this.quantite,
    prixAchat: prixAchat ?? this.prixAchat,
    produitCode: produitCode ?? this.produitCode,
  );
}

/// Quota Smart Scan du serveur.
class QuotaSmartScan {
  const QuotaSmartScan({required this.utilise, required this.total});
  final int utilise;
  final int total;
  int get restant => (total - utilise).clamp(0, total);
  bool get atteint => restant <= 0;
}

enum ErreurSmartScan { nonConfigure, quotaAtteint, reseau, serveur, fichierInvalide }

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

/// Smart Scan IA : envoi d'une photo / PDF de facture au serveur CaisseDZ qui renvoie les lignes.
///
/// ⚠️ PROVISOIRE : protocole hypothétique.
/// - `GET  <base>/smart-scan/quota` → `{ "utilise": n, "total": m }`
/// - `POST <base>/smart-scan/analyser` (multipart `fichier`) → `{ "lignes": [...], "quota": {...}, ... }` ;
///   HTTP 429 = quota atteint.
/// - `POST <base>/smart-scan/demande-offre` `{ "email", "message" }` → 200.
class SmartScanService {
  const SmartScanService({required this.client, required this.baseUrl, this.cleApi});

  final http.Client client;
  final String baseUrl;
  final String? cleApi;

  bool get configure => baseUrl.isNotEmpty;

  Map<String, String> get _entetes => {if (cleApi != null) 'Authorization': 'Bearer $cleApi'};

  Future<QuotaSmartScan> quota() async {
    if (!configure) throw const SmartScanException(ErreurSmartScan.nonConfigure);
    try {
      final r = await client
          .get(Uri.parse('$baseUrl/smart-scan/quota'), headers: _entetes)
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) throw SmartScanException(ErreurSmartScan.serveur, 'HTTP ${r.statusCode}');
      final j = jsonDecode(r.body) as Map;
      return QuotaSmartScan(utilise: (j['utilise'] as num).toInt(), total: (j['total'] as num).toInt());
    } on SmartScanException {
      rethrow;
    } on Object catch (e) {
      throw SmartScanException(ErreurSmartScan.reseau, e.toString());
    }
  }

  Future<ResultatSmartScan> analyser(Uint8List fichier, {required String nomFichier}) async {
    if (!configure) throw const SmartScanException(ErreurSmartScan.nonConfigure);
    if (fichier.isEmpty) throw const SmartScanException(ErreurSmartScan.fichierInvalide);
    http.StreamedResponse reponse;
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/smart-scan/analyser'))
        ..headers.addAll(_entetes)
        ..files.add(http.MultipartFile.fromBytes('fichier', fichier, filename: nomFichier));
      reponse = await client.send(req).timeout(const Duration(seconds: 60));
    } on Object catch (e) {
      throw SmartScanException(ErreurSmartScan.reseau, e.toString());
    }
    final corps = await reponse.stream.bytesToString();
    if (reponse.statusCode == 429) throw const SmartScanException(ErreurSmartScan.quotaAtteint);
    if (reponse.statusCode != 200) throw SmartScanException(ErreurSmartScan.serveur, 'HTTP ${reponse.statusCode}');
    final j = jsonDecode(corps) as Map;
    final q = j['quota'] as Map?;
    return ResultatSmartScan(
      lignes: [
        for (final l in (j['lignes'] as List? ?? const []).cast<Map>())
          LigneSmartScan(
            designation: (l['designation'] ?? '').toString(),
            codeBarres: l['code_barres']?.toString(),
            quantite: ((l['quantite'] as num?) ?? 1).toDouble(),
            prixAchat: ((l['prix_achat'] as num?) ?? 0).toDouble(),
          ),
      ],
      quota: QuotaSmartScan(
        utilise: ((q?['utilise'] as num?) ?? 0).toInt(),
        total: ((q?['total'] as num?) ?? 0).toInt(),
      ),
      fournisseur: j['fournisseur']?.toString(),
      reference: j['reference']?.toString(),
      total: (j['total'] as num?)?.toDouble(),
    );
  }

  Future<void> demanderOffre({required String email, required String message}) async {
    if (!configure) throw const SmartScanException(ErreurSmartScan.nonConfigure);
    try {
      final r = await client
          .post(
            Uri.parse('$baseUrl/smart-scan/demande-offre'),
            headers: {..._entetes, 'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'message': message}),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) throw SmartScanException(ErreurSmartScan.serveur, 'HTTP ${r.statusCode}');
    } on SmartScanException {
      rethrow;
    } on Object catch (e) {
      throw SmartScanException(ErreurSmartScan.reseau, e.toString());
    }
  }
}
