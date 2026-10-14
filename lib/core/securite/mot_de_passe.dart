import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hachage des mots de passe : PBKDF2-HMAC-SHA256, sel aléatoire de 16 octets.
///
/// Format stocké : `pbkdf2$<itérations>$<sel base64>$<hash base64>`.
class MotDePasse {
  const MotDePasse({this.iterations = 60000});

  final int iterations;

  static final Random _alea = Random.secure();

  String hacher(String motDePasse, {Uint8List? sel}) {
    final s = sel ?? Uint8List.fromList(List.generate(16, (_) => _alea.nextInt(256)));
    final h = _pbkdf2(utf8.encode(motDePasse), s, iterations, 32);
    return 'pbkdf2\$$iterations\$${base64.encode(s)}\$${base64.encode(h)}';
  }

  /// Vérifie [motDePasse] contre une empreinte stockée (comparaison à temps constant).
  static bool verifier(String motDePasse, String empreinte) {
    final parts = empreinte.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2') return false;
    final it = int.tryParse(parts[1]);
    if (it == null || it <= 0) return false;
    final sel = base64.decode(parts[2]);
    final attendu = base64.decode(parts[3]);
    final calcule = _pbkdf2(utf8.encode(motDePasse), sel, it, attendu.length);
    var diff = 0;
    for (var i = 0; i < attendu.length; i++) {
      diff |= attendu[i] ^ calcule[i];
    }
    return diff == 0;
  }

  static Uint8List _pbkdf2(List<int> mdp, List<int> sel, int iterations, int longueur) {
    final hmac = Hmac(sha256, mdp);
    final blocs = (longueur / 32).ceil();
    final sortie = BytesBuilder();
    for (var i = 1; i <= blocs; i++) {
      final selBloc = [...sel, (i >> 24) & 0xff, (i >> 16) & 0xff, (i >> 8) & 0xff, i & 0xff];
      var u = Uint8List.fromList(hmac.convert(selBloc).bytes);
      final t = Uint8List.fromList(u);
      for (var j = 1; j < iterations; j++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < t.length; k++) {
          t[k] ^= u[k];
        }
      }
      sortie.add(t);
    }
    return Uint8List.fromList(sortie.toBytes().sublist(0, longueur));
  }
}
