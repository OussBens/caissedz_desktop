import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart' show CryptoUtils, ECPrivateKey, ECPublicKey, X509Utils;
import 'package:crypto/crypto.dart';

/// Certificat TLS du serveur mobile : auto-signé, créé une fois par poste et gardé dans la base chiffrée.
///
/// Aucune autorité de certification : le téléphone ne reconnaît le poste qu'à l'empreinte du certificat, lue dans
/// le QR code d'appairage (scanné sur place). Un autre appareil du réseau ne peut ni lire les échanges ni se faire
/// passer pour le poste.
class CertificatMobile {
  const CertificatMobile({required this.certificatPem, required this.clePem});

  final String certificatPem;
  final String clePem;

  /// Clé EC P-256 et certificat valable 30 ans (le téléphone ne regarde que son empreinte).
  static CertificatMobile generer() {
    final paire = CryptoUtils.generateEcKeyPair();
    final privee = paire.privateKey as ECPrivateKey;
    final csr = X509Utils.generateEccCsrPem({'CN': 'CaisseDZ'}, privee, paire.publicKey as ECPublicKey);
    return CertificatMobile(
      certificatPem: X509Utils.generateSelfSignedCertificate(privee, csr, 365 * 30),
      clePem: CryptoUtils.encodeEcPrivateKeyToPem(privee),
    );
  }

  /// Le certificat en DER (ce que le téléphone reçoit à la connexion).
  List<int> get der => base64.decode(certificatPem.replaceAll(RegExp(r'-----[^-]+-----|\s'), ''));

  /// Ce que porte le QR code : voir [empreinteDe].
  String get empreinte => empreinteDe(der);

  /// SHA-256 d'un certificat DER, en base64url sans remplissage (43 caractères).
  static String empreinteDe(List<int> der) => base64Url.encode(sha256.convert(der).bytes).replaceAll('=', '');

  SecurityContext contexte() => SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificatPem))
    ..usePrivateKeyBytes(utf8.encode(clePem));
}
