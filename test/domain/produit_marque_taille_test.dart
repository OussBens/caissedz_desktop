import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Produit p({String? marque, String? taille}) => Produit(
    code: 'PRD0001',
    designation: 'Lait',
    categorieCode: 'CATE0000',
    sousCategorieCode: 'SC0000',
    marque: marque,
    taille: taille,
  );

  test('marqueTaille : marque et taille séparées par « · »', () {
    expect(p(marque: 'Candia', taille: '1 L').marqueTaille, 'Candia · 1 L');
  });

  test('marqueTaille : une seule des deux, sans séparateur', () {
    expect(p(marque: 'Candia').marqueTaille, 'Candia');
    expect(p(taille: ' 1 L ').marqueTaille, '1 L');
    expect(p(marque: '  ', taille: 'XL').marqueTaille, 'XL');
  });

  test('marqueTaille : null si ni marque ni taille', () {
    expect(p().marqueTaille, isNull);
    expect(p(marque: '', taille: ' ').marqueTaille, isNull);
  });
}
