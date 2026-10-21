import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import 'codec.dart';
import 'device_code.dart';
import 'license.dart';

enum LicenseStatus {
  /// Signed for this product and this device, and in date.
  valid,

  /// Not a licence, or not signed with this product's key.
  invalid,

  /// A real licence, for another product.
  wrongProduct,

  /// A real licence, for another device.
  wrongDevice,

  /// Past its last day.
  expired,

  /// The device's clock is earlier than a date the app has already seen.
  clockRollback,
}

class LicenseCheck {
  const LicenseCheck(this.status, [this.license]);

  final LicenseStatus status;

  /// Set when the signature is good (every status but [LicenseStatus.invalid]).
  final License? license;

  bool get isValid => status == LicenseStatus.valid;
}

/// Checks licences in an app. Holds only the product's public key, which
/// can sign nothing: finding it in the app gives nobody a way to make keys.
class LicenseVerifier {
  /// [publicKey] is the product's, from the dashboard's app setup. One that
  /// isn't 32 bytes of base64 (an app setup not pasted yet) makes every key
  /// [LicenseStatus.invalid].
  LicenseVerifier({required this.product, required String publicKey}) : _publicKey = _decode(publicKey);

  static List<int> _decode(String key) {
    try {
      final bytes = base64.decode(key.trim());
      return bytes.length == 32 ? bytes : const [];
    } on FormatException {
      return const [];
    }
  }

  /// False until the product's real public key is in the app.
  bool get isConfigured => _publicKey.length == 32;

  final int product;
  final List<int> _publicKey;

  /// How far the clock may go back before it counts as rolled back (time
  /// zones, a corrected clock).
  static const rollbackTolerance = Duration(days: 2);

  /// Checks [key] for [device] (this device's code). [lastSeen] is the
  /// latest date the app has stored (save `max(lastSeen, now)` after each
  /// check), which stops an expired licence from coming back by turning
  /// the clock back.
  Future<LicenseCheck> check(String key, {required DeviceCode device, DateTime? now, DateTime? lastSeen}) async {
    final parts = License.splitKey(key);
    if (parts == null) return const LicenseCheck(LicenseStatus.invalid);
    final license = License.fromPayload(parts.payload);
    if (license == null || !isConfigured) return const LicenseCheck(LicenseStatus.invalid);
    final ok = await DartEd25519().verify([
      ...License.domain,
      ...parts.payload,
    ], signature: Signature(parts.signature, publicKey: SimplePublicKey(_publicKey, type: KeyPairType.ed25519)));
    if (!ok) return const LicenseCheck(LicenseStatus.invalid);
    if (license.product != product) return LicenseCheck(LicenseStatus.wrongProduct, license);
    if (!constantTimeEquals(license.device, device.bytes)) return LicenseCheck(LicenseStatus.wrongDevice, license);
    final t = (now ?? DateTime.now()).toUtc();
    if (lastSeen != null && t.isBefore(lastSeen.toUtc().subtract(rollbackTolerance))) {
      return LicenseCheck(LicenseStatus.clockRollback, license);
    }
    final expires = license.expiresOn;
    if (expires != null && t.isAfter(expires.add(const Duration(days: 1)))) {
      return LicenseCheck(LicenseStatus.expired, license);
    }
    return LicenseCheck(LicenseStatus.valid, license);
  }
}
