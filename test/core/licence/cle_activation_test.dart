import 'package:caissedz_desktop/core/licence/cle_activation.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleActivation', () {
    const v = CleActivation();

    test('format : 64 caractères hexadécimaux exactement', () {
      expect(CleActivation.formatValide('a' * 64), isTrue);
      expect(CleActivation.formatValide('A' * 64), isTrue);
      expect(CleActivation.formatValide(' ${'0' * 64} '), isTrue);
      expect(CleActivation.formatValide('a' * 63), isFalse);
      expect(CleActivation.formatValide('a' * 65), isFalse);
      expect(CleActivation.formatValide('g' * 64), isFalse);
    });

    test('résout Basic et Avancé pour la machine, refuse les autres', () {
      final basic = CleActivation.cleAttendue(NiveauLicence.basic, 'POSTE-1');
      final avance = CleActivation.cleAttendue(NiveauLicence.avance, 'POSTE-1');
      expect(basic.length, 64);
      expect(v.resoudre(basic, 'POSTE-1'), NiveauLicence.basic);
      expect(v.resoudre(avance.toUpperCase(), 'POSTE-1'), NiveauLicence.avance);
      expect(v.resoudre(basic, 'POSTE-2'), isNull);
      expect(v.resoudre('f' * 64, 'POSTE-1'), isNull);
      expect(v.resoudre('court', 'POSTE-1'), isNull);
    });

    test('Avancé couvre Basic, pas l’inverse', () {
      expect(NiveauLicence.avance.couvre(NiveauLicence.basic), isTrue);
      expect(NiveauLicence.basic.couvre(NiveauLicence.avance), isFalse);
      expect(NiveauLicence.parValeur('Avancé'), NiveauLicence.avance);
      expect(NiveauLicence.parValeur('x'), isNull);
    });
  });
}
