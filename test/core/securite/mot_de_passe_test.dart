import 'dart:typed_data';

import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MotDePasse (PBKDF2-HMAC-SHA256)', () {
    const h = MotDePasse(iterations: 1000);

    test('vérifie le bon mot de passe et refuse les autres', () {
      final e = h.hacher('secret');
      expect(e.startsWith(r'pbkdf2$1000$'), isTrue);
      expect(MotDePasse.verifier('secret', e), isTrue);
      expect(MotDePasse.verifier('Secret', e), isFalse);
      expect(MotDePasse.verifier('', e), isFalse);
    });

    test('deux empreintes du même mot de passe diffèrent (sel aléatoire)', () {
      expect(h.hacher('secret'), isNot(h.hacher('secret')));
    });

    test('vecteur de test PBKDF2 (RFC 6070 adapté SHA-256)', () {
      // PBKDF2-HMAC-SHA256("password", "salt", 1, 32) =
      // 120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b
      final e = const MotDePasse(iterations: 1).hacher('password', sel: Uint8List.fromList('salt'.codeUnits));
      final hash = e.split(r'$')[3];
      expect(Uri.decodeComponent(hash), 'Eg+2z/z4syxD5yJSVsT4N6hlSMkszDVICAWYfLcL4Xs=');
    });

    test('empreinte mal formée refusée', () {
      expect(MotDePasse.verifier('x', 'n_importe_quoi'), isFalse);
      expect(MotDePasse.verifier('x', r'pbkdf2$abc$AA==$AA=='), isFalse);
    });
  });
}
