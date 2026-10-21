import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nbsp = '\u00A0';

  group('Nombres de gauche à droite, même en arabe', () {
    test('milliers séparés par une espace insécable (un seul nombre pour le bidi)', () {
      expect(formaterNombre(20000), '20${nbsp}000');
      expect(formaterMontant(1234567.5), '1${nbsp}234${nbsp}567,50 DA');
      expect(formaterNombre(1234.5, decimales: 1, grouper: false), '1234,5');
    });

    test('négatif : isolé LTR pour garder le signe devant les chiffres', () {
      expect(formaterNombre(-1500), '\u2066-1${nbsp}500\u2069');
      expect(formaterMontant(-12), '\u2066-12,00\u2069 DA');
      expect(isolerLtr('+500'), '\u2066+500\u2069');
    });

    test('relecture : espaces, insécables et marques de direction tolérées', () {
      expect(lireNombre(formaterNombre(-1500)), -1500);
      expect(lireNombre(formaterNombre(1234.5, decimales: 2)), 1234.5);
      expect(lireNombre('1 250,5'), 1250.5);
      expect(DsCalculator.evaluer('${formaterNombre(1250.5, decimales: 1)} × 2'), 2501);
    });
  });
}
