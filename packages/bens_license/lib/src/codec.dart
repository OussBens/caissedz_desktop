/// Crockford base32: no I, L, O, U, so a key read aloud or retyped survives.
const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Upper case, letters and digits only, O→0 and I/L→1 (the usual typos).
String clean(String input) => input.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '').replaceAll('O', '0').replaceAll(RegExp('[IL]'), '1');

/// [bytes] as base32, most significant bit first; the last character is
/// padded with zero bits.
String encodeBase32(List<int> bytes) {
  final out = StringBuffer();
  var buffer = 0, bits = 0;
  for (final b in bytes) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out.write(alphabet[(buffer >> bits) & 31]);
    }
    buffer &= (1 << bits) - 1;
  }
  if (bits > 0) out.write(alphabet[(buffer << (5 - bits)) & 31]);
  return out.toString();
}

/// The bytes [text] encodes (already [clean]ed), or null if it holds a
/// character outside the alphabet or non-zero padding bits.
List<int>? decodeBase32(String text) {
  final out = <int>[];
  var buffer = 0, bits = 0;
  for (final ch in text.split('')) {
    final v = alphabet.indexOf(ch);
    if (v < 0) return null;
    buffer = (buffer << 5) | v;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      out.add((buffer >> bits) & 0xFF);
    }
    buffer &= (1 << bits) - 1;
  }
  // A canonical encoding pads with zeros only, and never a whole extra char.
  if (buffer != 0 || bits >= 5) return null;
  return out;
}

/// [s] cut into groups of [size] joined by dashes: `ABCD-EFGH-IJ`.
String group(String s, [int size = 4]) {
  final parts = <String>[];
  for (var i = 0; i < s.length; i += size) {
    parts.add(s.substring(i, i + size > s.length ? s.length : i + size));
  }
  return parts.join('-');
}

/// True when [a] and [b] are equal, in time that doesn't depend on where
/// they differ.
bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
