import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Remise : état selon la période', () {
    final r = Remise(
      code: 'RMS0001',
      designation: 'Fin de série',
      type: 'Pourcentage',
      valeur: 10,
      produitCode: 'PRD0001',
      dateDebut: DateTime(2026, 10, 1),
      dateFin: DateTime(2026, 10, 31),
    );

    test('active du premier au dernier jour inclus, inactive en dehors', () {
      expect(r.statut(DateTime(2026, 9, 30, 23)), 'inactif');
      expect(r.statut(DateTime(2026, 10, 1, 8)), 'actif');
      expect(r.statut(DateTime(2026, 10, 31, 20)), 'actif', reason: 'le dernier jour compte en entier');
      expect(r.statut(DateTime(2026, 11, 1)), 'inactif');
      expect(r.copyWith(actif: false).statut(DateTime(2026, 10, 15)), 'annule');
    });

    test('une remise inactive ne s’applique pas au produit', () {
      bool applicable(DateTime d) => r.estApplicable(d, produitCode: 'PRD0001', categorieCode: 'CATE0000');
      expect(applicable(DateTime(2026, 10, 31, 20)), isTrue);
      expect(applicable(DateTime(2026, 11, 1)), isFalse);
      expect(
        r.copyWith(actif: false).estApplicable(DateTime(2026, 10, 15), produitCode: 'PRD0001', categorieCode: ''),
        isFalse,
      );
    });
  });
}
