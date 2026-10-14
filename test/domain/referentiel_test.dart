import 'dart:ui';

import 'package:caissedz_desktop/domain/referentiel/referentiel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Referentiel (§13)', () {
    test('la valeur stockée est toujours la valeur FR', () {
      for (final liste in Referentiel.toutes) {
        for (final v in liste.valeurs) {
          expect(v.stocke, v.fr, reason: '${liste.nom}/${v.stocke}');
        }
      }
    });

    test('aucune valeur stockée en double dans une liste', () {
      for (final liste in Referentiel.toutes) {
        expect(liste.valeurs.map((v) => v.stocke).toSet().length, liste.valeurs.length, reason: liste.nom);
      }
    });

    test('libellé par locale et repli sur la valeur stockée', () {
      expect(Referentiel.modesPaiement.libelle('Espèces', const Locale('ar')), 'نقدًا');
      expect(Referentiel.modesPaiement.libelle('Espèces', const Locale('en')), 'Cash');
      expect(Referentiel.modesPaiement.libelle('Espèces', const Locale('fr')), 'Espèces');
      expect(Referentiel.modesPaiement.libelle('Inconnu', const Locale('en')), 'Inconnu');
      expect(Referentiel.motifsSortie.contient('Casse'), isTrue);
      expect(Referentiel.motifsSortie.contient('casse'), isFalse);
    });

    test('listes de la commande initiale présentes', () {
      expect(Referentiel.modesPaiement.valeurs.map((v) => v.stocke), ['Espèces', 'Carte', 'Chèque', 'Virement', 'Points']);
      expect(Referentiel.motifsSortie.valeurs.length, 6);
      expect(Referentiel.statutsBesoin.valeurs.map((v) => v.stocke), ['En attente', 'Commande', 'Disponible']);
      expect(Referentiel.typesCaisse.valeurs.map((v) => v.stocke), ['Physique', 'Compte']);
    });
  });
}
