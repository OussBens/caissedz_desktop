import 'dart:convert';
import 'dart:typed_data';

import 'codec.dart';

/// What a licence grants, as signed. See FORMAT.md for the bytes.
class License {
  License({required this.product, required this.serial, required this.tier, required this.issuedOn, required this.device, this.expiresOn})
    : assert(device.length == 5);

  /// The product's number (1 CaisseDZ Desktop, 2 Suivi Vidange, …).
  final int product;

  /// The licence's number within its product.
  final int serial;

  /// The product's tier number (0 when it has a single tier).
  final int tier;

  /// Day it was issued (UTC midnight).
  final DateTime issuedOn;

  /// Last day it is valid (UTC midnight), or null: never expires.
  final DateTime? expiresOn;

  /// The 5 bytes of the device code it is bound to.
  final List<int> device;

  static const version = 1;
  static const payloadLength = 18;
  static const signatureLength = 64;

  /// Signed before the payload, so a signature over anything else can't
  /// pass for a licence.
  static final domain = utf8.encode('BENS-LICENSE-1');

  static final epoch = DateTime.utc(2020);

  static int _day(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(epoch).inDays;

  static DateTime _date(int day) => epoch.add(Duration(days: day));

  /// The 18 bytes that are signed.
  Uint8List toPayload() {
    final b = ByteData(payloadLength)
      ..setUint8(0, version)
      ..setUint16(1, product)
      ..setUint32(3, serial)
      ..setUint8(7, tier)
      ..setUint16(8, _day(issuedOn))
      ..setUint16(10, expiresOn == null ? 0 : _day(expiresOn!));
    for (var i = 0; i < 5; i++) {
      b.setUint8(12 + i, device[i]);
    }
    b.setUint8(17, 0); // flags, reserved
    return b.buffer.asUint8List();
  }

  /// The licence in [payload], or null if it isn't a version 1 payload.
  static License? fromPayload(List<int> payload) {
    if (payload.length != payloadLength) return null;
    final b = ByteData.sublistView(Uint8List.fromList(payload));
    if (b.getUint8(0) != version || b.getUint8(17) != 0) return null;
    final expires = b.getUint16(10);
    return License(
      product: b.getUint16(1),
      serial: b.getUint32(3),
      tier: b.getUint8(7),
      issuedOn: _date(b.getUint16(8)),
      expiresOn: expires == 0 ? null : _date(expires),
      device: payload.sublist(12, 17),
    );
  }

  /// [domain] + payload: the bytes the signature covers.
  Uint8List signedMessage() => Uint8List.fromList([...domain, ...toPayload()]);

  /// The text sent to the customer: payload and signature in base32, in
  /// groups of four.
  static String encodeKey(List<int> payload, List<int> signature) => group(encodeBase32([...payload, ...signature]));

  /// Splits a key as pasted into payload and signature; null if it can't be one.
  static ({List<int> payload, List<int> signature})? splitKey(String key) {
    final bytes = decodeBase32(clean(key));
    if (bytes == null || bytes.length != payloadLength + signatureLength) return null;
    return (payload: bytes.sublist(0, payloadLength), signature: bytes.sublist(payloadLength));
  }

  /// Reads a key without checking its signature (the dashboard's "Check a
  /// key", support). Apps use [LicenseVerifier] instead.
  static License? peek(String key) {
    final parts = splitKey(key);
    return parts == null ? null : fromPayload(parts.payload);
  }
}
