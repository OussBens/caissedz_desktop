import 'package:caissedz_desktop/domain/quantite_produit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantiteProduit.separer', () {
    test('le nom perd sa quantité, la quantité du catalogue vient à part', () {
      final s = QuantiteProduit.separer('Eau Hayat 50cl', quantite: '50 cl');
      expect([s.nom, s.quantite, s.type], ['Eau Hayat', '500 ml', 'Contenance']);
    });

    test('sans quantité du catalogue, celle lue dans le nom', () {
      expect(QuantiteProduit.separer('Rouiba Orange 1L').quantite, '1 L');
      expect(QuantiteProduit.separer('Couscous Mama 1kg').nom, 'Couscous Mama');
      final s = QuantiteProduit.separer('Lait Candia (1,5 L)');
      expect([s.nom, s.quantite, s.type], ['Lait Candia', '1,5 L', 'Contenance']);
    });

    test('la quantité du catalogue l’emporte, sans contrôle de cohérence avec le nom', () {
      final s = QuantiteProduit.separer('Eau Ifri 33cl', quantite: '0,5 L');
      expect([s.nom, s.quantite], ['Eau Ifri', '500 ml']);
    });

    test('sans quantité : nom inchangé ; quantité sans unité gardée telle quelle', () {
      final s = QuantiteProduit.separer("L'Eau d'Ifri");
      expect([s.nom, s.quantite, s.type], ["L'Eau d'Ifri", null, null]);
      final b = QuantiteProduit.separer('Eau ELkantara 250', quantite: '250');
      expect([b.nom, b.quantite, b.type], ['Eau ELkantara 250', '250', null]);
    });

    test('un lot (6x1,5L) ou un code collé n’est pas une quantité ; le nom n’est jamais vidé', () {
      expect(QuantiteProduit.separer('Pack 6x1,5L').nom, 'Pack 6x1,5L');
      expect(QuantiteProduit.separer('Biscuit B52g').nom, 'Biscuit B52g');
      expect(QuantiteProduit.separer('500 g').nom, '500 g');
    });

    test('séparateurs laissés en bout de nom retirés', () {
      expect(QuantiteProduit.separer('Huile Elio - 5L').nom, 'Huile Elio');
      expect(QuantiteProduit.separer('Sucre, 1 kg, blanc').nom, 'Sucre, blanc');
    });
  });

  test('normaliser : écrit comme les tailles de la fiche', () {
    String? n(String v) => QuantiteProduit.normaliser(v)?.texte;
    expect(
      [n('50cl'), n('0.5l'), n('1500 ml'), n('250 gr'), n('1000 g'), n('2 Kg')],
      ['500 ml', '500 ml', '1,5 L', '250 g', '1 kg', '2 kg'],
    );
    expect(n('250'), isNull);
    expect(QuantiteProduit.typeCommun(['750 ml', '1 L']), 'Contenance');
    expect(QuantiteProduit.typeCommun(['750 ml', '1 kg']), isNull);
  });
}
