import 'device_code.dart';
import 'verifier.dart';

/// An app's licence, as it keeps it: the key it was given and the latest
/// date it has seen, in whatever storage the app has ([read] and [write]:
/// shared_preferences, a settings table…). Checked at every launch ([load])
/// and when the customer pastes a key ([activate]). See docs/licences.md.
///
/// ```dart
/// final gate = LicenseGate(
///   verifier: LicenseVerifier(product: licenseProduct, publicKey: licensePublicKey),
///   device: DeviceCode.fromRawId(slug: licenseSlug, prefix: licensePrefix, rawId: rawId),
///   read: (k) async => prefs.getString(k),
///   write: (k, v) async => v == null ? prefs.remove(k) : prefs.setString(k, v),
/// );
/// await gate.load();
/// if (!gate.isActivated) showActivationScreen(gate.device, gate.current?.status);
/// final check = await gate.activate(pasted); // check.status: valid, or why not
/// ```
class LicenseGate {
  LicenseGate({required this.verifier, required this.device, required this.read, required this.write, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final LicenseVerifier verifier;

  /// The code the activation screen shows and the customer sends.
  final DeviceCode device;
  final Future<String?> Function(String name) read;
  final Future<void> Function(String name, String? value) write;
  final DateTime Function() _clock;

  /// Where it keeps the key and the latest date seen (milliseconds).
  static const keyName = 'license_key', seenName = 'license_seen';

  /// The last check: null when no key is stored.
  LicenseCheck? current;

  bool get isActivated => current?.isValid ?? false;

  /// The tier the licence unlocks, when activated.
  int? get tier => isActivated ? current!.license!.tier : null;

  /// The last valid day, or null (never expires, or not activated).
  DateTime? get expiresOn => isActivated ? current!.license!.expiresOn : null;

  /// Checks the stored key (at every launch). An expired licence, a key
  /// copied from another device or a clock turned back leaves [current] not
  /// valid: show the activation screen with its status.
  Future<LicenseCheck?> load() async {
    final key = await read(keyName);
    current = key == null ? null : await _check(key);
    return current;
  }

  /// Stores [key] when it is valid here; returns the check either way (its
  /// status, and the licence when the signature is good: an expired one's
  /// last day).
  Future<LicenseCheck> activate(String key) async {
    final r = await _check(key);
    if (r.isValid) {
      await write(keyName, key.trim());
      current = r;
    }
    return r;
  }

  Future<LicenseCheck> _check(String key) async {
    final now = _clock();
    final seen = int.tryParse(await read(seenName) ?? '');
    final r = await verifier.check(
      key,
      device: device,
      now: now,
      lastSeen: seen == null ? null : DateTime.fromMillisecondsSinceEpoch(seen, isUtc: true),
    );
    if (r.status != LicenseStatus.clockRollback) {
      final ms = now.millisecondsSinceEpoch;
      await write(seenName, '${seen == null || ms > seen ? ms : seen}');
    }
    return r;
  }

  /// A wa.me link that opens WhatsApp to [number] (digits, with the country:
  /// `213770951460`) with the code ready to send.
  Uri whatsAppLink(String number, String appName) =>
      Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent('Bonjour, voici le code de mon appareil pour $appName : $device')}');
}
