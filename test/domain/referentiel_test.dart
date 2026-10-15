import 'dart:ui';

import 'package:caissedz_desktop/domain/referentiel/referentiel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Referentiel (§13, donnees/ref.js)', () {
    test('les 14 listes du DS et les listes système sont présentes', () {
      expect(Referentiel.toutes.length, 16);
    });

    test('aucune valeur stockée en double dans une liste', () {
      for (final liste in Referentiel.toutes) {
        expect(liste.valeurs.map((v) => v.stocke).toSet().length, liste.valeurs.length, reason: liste.nom);
      }
    });

    test('libellé par locale et repli sur la valeur stockée', () {
      expect(Referentiel.modesPaiement.libelle('Carte', const Locale('fr')), 'Carte CIB');
      expect(Referentiel.modesPaiement.libelle('Espèces', const Locale('ar')), 'نقدا');
      expect(Referentiel.modesPaiement.libelle('Espèces', const Locale('en')), 'Cash');
      expect(Referentiel.modesPaiement.libelle('Inconnu', const Locale('en')), 'Inconnu');
      expect(Referentiel.motifsSortie.contient('Casse'), isTrue);
      expect(Referentiel.motifsSortie.contient('casse'), isFalse);
      expect(Referentiel.statutsZakat.libelle('Non payé', const Locale('fr')), 'Non payée');
    });

    test('valeurs stockées de ref.js', () {
      expect(Referentiel.modesPaiement.valeurs.map((v) => v.stocke), [
        'Espèces',
        'Carte',
        'Chèque',
        'Virement',
        'Points',
      ]);
      expect(Referentiel.motifsSortie.valeurs.map((v) => v.stocke), [
        'Casse',
        'Périmé',
        'Perte / vol',
        'Consommation interne',
        'Don',
        'Échantillon',
      ]);
      expect(Referentiel.statutsBesoin.valeurs.map((v) => v.stocke), ['En Attente', 'Commande', 'Disponible']);
      expect(Referentiel.typesCaisse.valeurs.map((v) => v.stocke), ['Physique', 'Compte']);
      expect(Referentiel.typesClient.valeurs.first.stocke, 'Consommateur');
      expect(Referentiel.typesFournisseur.valeurs.length, 7);
      expect(Referentiel.typesPanier.valeurs.map((v) => v.stocke), ['Ticket', 'BL', 'BL_SC']);
    });
  });
}
