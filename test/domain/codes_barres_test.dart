import 'package:caissedz_desktop/domain/calculs_prix.dart';
import 'package:caissedz_desktop/domain/codes_barres.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodesBarres', () {
    test('contrôle EAN-13', () {
      expect(CodesBarres.controleEan13('400638133393'), 1); // 4006381333931
      expect(CodesBarres.ean13Valide('4006381333931'), isTrue);
      expect(CodesBarres.ean13Valide('4006381333932'), isFalse);
      expect(CodesBarres.ean13Valide('123'), isFalse);
      expect(CodesBarres.ean13Valide('6130000000015'), isTrue);
    });

    test('génération EAN-13 interne préfixe 20', () {
      final c = CodesBarres.genererEan13Interne(42);
      expect(c.length, 13);
      expect(c.startsWith('20'), isTrue);
      expect(CodesBarres.ean13Valide(c), isTrue);
      expect(() => CodesBarres.genererEan13Interne(1, prefixe: '30'), throwsArgumentError);
    });

    test('code interne CAISSEDZ + date + séquence', () {
      final c = CodesBarres.genererInterne(DateTime(2026, 10, 14), 7);
      expect(c, 'CDZ202610140007');
      expect(CodesBarres.interneValide(c), isTrue);
      expect(CodesBarres.sequenceSuivante(DateTime(2026, 10, 14), c), 8);
      expect(CodesBarres.sequenceSuivante(DateTime(2026, 10, 14), null), 1);
      expect(CodesBarres.typeDe(c), TypeCodeBarres.interne);
    });

    test('QR produit', () {
      expect(CodesBarres.contenuQr('PRD0012'), 'CDZ:PRD:PRD0012');
      expect(CodesBarres.codeProduitDepuisQr('CDZ:PRD:PRD0012'), 'PRD0012');
      expect(CodesBarres.codeProduitDepuisQr('autre'), isNull);
      expect(CodesBarres.typeDe('CDZ:PRD:PRD0012'), TypeCodeBarres.qr);
      expect(CodesBarres.typeDe('ABC'), TypeCodeBarres.autre);
    });
  });

  group('CalculsPrix', () {
    test('marge ↔ prix de vente', () {
      expect(CalculsPrix.prixVenteDepuisMarge(100, 25), 125);
      expect(CalculsPrix.prixVenteDepuisMarge(80, 20), 100); // 96 → multiple de 5 DA supérieur (§8.8)
      expect(CalculsPrix.prixVenteDepuisMarge(84, 25), 105);
      expect(CalculsPrix.prixVenteDepuisMarge(0, 25), 0);
      expect(CalculsPrix.prixVenteDepuisMontant(83, 50), 133);
      expect(CalculsPrix.margeDepuisPrix(100, 125), 25);
      expect(CalculsPrix.margeDepuisPrix(0, 125), 0);
      expect(CalculsPrix.arrondir(1.005), 1.01);
    });
    test('remises', () {
      expect(CalculsPrix.remise(200, type: 'Pourcentage', valeur: 10), 20);
      expect(CalculsPrix.remise(200, type: 'Montant', valeur: 50), 50);
      expect(CalculsPrix.remise(30, type: 'Montant', valeur: 50), 30);
    });
  });
}
