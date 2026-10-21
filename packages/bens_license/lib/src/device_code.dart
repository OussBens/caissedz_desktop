import 'dart:convert';

import 'package:cryptography/dart.dart';

import 'codec.dart';

/// The code a customer sends to get a licence, e.g. `SV-7K3M-QX9D`: the
/// product's [prefix] and 8 base32 characters (40 bits) of
/// SHA-256(`"<slug>:device:<raw id>"`). The raw id (Android ID, Windows
/// MachineGuid, Linux machine-id) never leaves the device.
class DeviceCode {
  const DeviceCode._(this.prefix, this.body);

  /// Product prefix, e.g. `SV`.
  final String prefix;

  /// The 8 base32 characters, without dashes.
  final String body;

  static const bodyLength = 8;

  /// The code for this device. [slug] is the product's (`suivi-vidange`),
  /// [rawId] the platform's device identifier.
  factory DeviceCode.fromRawId({required String slug, required String prefix, required String rawId}) {
    final digest = const DartSha256().hashSync(utf8.encode('$slug:device:$rawId')).bytes;
    return DeviceCode._(prefix.toUpperCase(), encodeBase32(digest.sublist(0, 5)));
  }

  /// The code for the 5 [bytes] a licence holds.
  factory DeviceCode.fromBytes({required String prefix, required List<int> bytes}) {
    if (bytes.length != 5) throw ArgumentError('A device code is 5 bytes');
    return DeviceCode._(prefix.toUpperCase(), encodeBase32(bytes));
  }

  /// Reads a code as typed or pasted (`sv 7k3m qx9d` works). Null when it
  /// isn't [prefix] followed by 8 valid characters.
  static DeviceCode? parse(String input, {required String prefix}) {
    final p = clean(prefix);
    var c = clean(input);
    if (c.length == p.length + bodyLength && c.startsWith(p)) c = c.substring(p.length);
    if (c.length != bodyLength || decodeBase32(c) == null) return null;
    return DeviceCode._(p, c);
  }

  /// The 5 bytes a licence is bound to.
  List<int> get bytes => decodeBase32(body)!;

  @override
  String toString() => '$prefix-${group(body)}';

  @override
  bool operator ==(Object other) => other is DeviceCode && other.prefix == prefix && other.body == body;

  @override
  int get hashCode => Object.hash(prefix, body);
}
