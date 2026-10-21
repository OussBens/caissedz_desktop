/// Checking BENS licences in an app: device codes, signed licences, and
/// [LicenseGate], which keeps the app's key and checks it (docs/licences.md).
///
/// ```dart
/// final device = DeviceCode.fromRawId(slug: 'suivi-vidange', prefix: 'SV', rawId: androidId);
/// final verifier = LicenseVerifier(product: 2, publicKey: 'base64…');
/// final result = await verifier.check(savedKey, device: device, lastSeen: lastSeen);
/// ```
library;

export 'src/codec.dart' show clean;
export 'src/device_code.dart';
export 'src/gate.dart';
export 'src/license.dart';
export 'src/verifier.dart';
