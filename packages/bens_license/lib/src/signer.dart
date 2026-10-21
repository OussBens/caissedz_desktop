import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import 'license.dart';

/// Makes licences for one product. Holds the product's private key (its
/// 32-byte seed). Only tests use it: the dashboard's API signs real licences
/// (in PHP, with the same result).
class LicenseSigner {
  LicenseSigner._(this._keyPair, this.publicKey);

  final SimpleKeyPair _keyPair;

  /// Base64 public key, for [LicenseVerifier] in the app.
  final String publicKey;

  static Future<LicenseSigner> fromSeed(List<int> seed) async {
    if (seed.length != 32) throw ArgumentError('An Ed25519 seed is 32 bytes');
    final pair = await DartEd25519().newKeyPairFromSeed(seed);
    final public = await pair.extractPublicKey();
    return LicenseSigner._(pair, base64.encode(public.bytes));
  }

  /// A new random 32-byte seed (a new product's private key).
  static List<int> newSeed() {
    final r = Random.secure();
    return List.generate(32, (_) => r.nextInt(256));
  }

  /// The key to send the customer for [license].
  Future<String> sign(License license) async {
    final payload = license.toPayload();
    final signature = await DartEd25519().sign(license.signedMessage(), keyPair: _keyPair);
    return License.encodeKey(payload, signature.bytes);
  }
}
