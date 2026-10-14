import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:flutter_test/flutter_test.dart';

class _IdentifiantFixe implements MachineIdentifiant {
  const _IdentifiantFixe(this.valeur);
  final String valeur;
  @override
  Future<String> lire() async => valeur;
}

void main() {
  group('DerivationCle', () {
    test('produit 64 caractères hexadécimaux (SHA-256)', () {
      final cle = DerivationCle.deriver('MACHINE|guid', 'sel');
      expect(cle.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(cle), isTrue);
    });

    test('est déterministe et dépend de l’identifiant et du sel', () {
      expect(DerivationCle.deriver('a', 's'), DerivationCle.deriver('a', 's'));
      expect(DerivationCle.deriver('a', 's'), isNot(DerivationCle.deriver('b', 's')));
      expect(DerivationCle.deriver('a', 's'), isNot(DerivationCle.deriver('a', 't')));
    });

    test('cleHex utilise l’identifiant machine fourni', () async {
      const d = DerivationCle(identifiant: _IdentifiantFixe('poste-1'), sel: 'sel');
      expect(await d.cleHex(), DerivationCle.deriver('poste-1', 'sel'));
    });

    test('l’identifiant système n’est jamais vide', () async {
      expect((await const MachineIdentifiantSysteme().lire()).isNotEmpty, isTrue);
    });
  });
}
