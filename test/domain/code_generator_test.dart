import 'package:caissedz_desktop/domain/code_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeGenerator (§8.10)', () {
    test('codes système', () {
      expect(CodeGenerator.systeme(CodeGenerator.magasin), 'MAG0000');
      expect(CodeGenerator.systeme(CodeGenerator.categorie), 'CATE0000');
      expect(CodeGenerator.systeme(CodeGenerator.sousCategorie), 'SC0000');
    });

    test('code pour un numéro, avec remplissage sur 4 chiffres minimum', () {
      expect(CodeGenerator.pour('CLN', 7), 'CLN0007');
      expect(CodeGenerator.pour('CLN', 12345), 'CLN12345');
      expect(() => CodeGenerator.pour('CLN', -1), throwsArgumentError);
    });

    test('code suivant', () {
      expect(CodeGenerator.suivant('MAG', null), 'MAG0001');
      expect(CodeGenerator.suivant('MAG', 'MAG0000'), 'MAG0001');
      expect(CodeGenerator.suivant('MAG', 'MAG0042'), 'MAG0043');
      expect(CodeGenerator.suivant('MAG', 'MAG9999'), 'MAG10000');
      expect(CodeGenerator.suivant('MAG', 'XXX0042'), 'MAG0001');
    });

    test('numéro et validité', () {
      expect(CodeGenerator.numero('FOR0010', 'FOR'), 10);
      expect(CodeGenerator.numero('FOR0010', 'CLN'), isNull);
      expect(CodeGenerator.numero('for0010', 'FOR'), isNull);
      expect(CodeGenerator.estValide('TRM0001', 'TRM'), isTrue);
      expect(CodeGenerator.estValide('TRM-1', 'TRM'), isFalse);
    });
  });
}
