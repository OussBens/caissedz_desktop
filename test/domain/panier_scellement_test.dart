import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/scellement.dart';
import 'package:flutter_test/flutter_test.dart';

const _lait = Produit(
  code: 'PRD0001',
  designation: 'Lait',
  categorieCode: 'CATE0000',
  sousCategorieCode: 'SC0000',
  prixAchat: 80,
  prixVente: 100,
);
const _eau = Produit(
  code: 'PRD0002',
  designation: 'Eau',
  categorieCode: 'CATE0000',
  sousCategorieCode: 'SC0000',
  prixAchat: 20,
  prixVente: 30,
  suiviNombre: true,
  nombreParUnite: 6,
);

void main() {
  group('Panier — calculs', () {
    test('agrégation, totaux, remises ligne et globale', () {
      var p = const Panier(id: 1);
      p = p.ajouter(const PanierLigne(produit: _lait, quantite: 2, prixUnitaire: 100));
      p = p.ajouter(const PanierLigne(produit: _lait, quantite: 1, prixUnitaire: 100));
      p = p.ajouter(const PanierLigne(produit: _eau, quantite: 4, prixUnitaire: 30, remisePct: 50));
      expect(p.lignes.length, 2);
      expect(p.lignes.first.quantite, 3);
      expect(p.totalBrut, 420);
      expect(p.remiseLignes, 60);
      expect(p.sousTotal, 360);
      p = p.copyWith(remiseGlobalePct: 10);
      expect(p.remiseGlobale, 36);
      expect(p.totalNet, 324);
      expect(p.totalRemise, 96);
      p = p.modifierQuantite(0, 0);
      expect(p.lignes.length, 1);
    });

    test('versé, reste, monnaie', () {
      var p = const Panier(id: 1).ajouter(const PanierLigne(produit: _lait, quantite: 3, prixUnitaire: 100));
      expect(p.reste, 300);
      p = p.ajouterPaiement(const Paiement(mode: 'Carte', montant: 100));
      expect(p.verse, 100);
      expect(p.reste, 200);
      expect(p.estSolde, isFalse);
      p = p.ajouterPaiement(const Paiement(mode: 'Espèces', montant: 250));
      expect(p.reste, 0);
      expect(p.monnaie, 50);
      expect(p.estSolde, isTrue);
      p = p.retirerPaiement(1);
      expect(p.reste, 200);
    });

    test('réservation : unités (colis, packs) et nombre', () {
      const colis = Colis(code: 'COL0001', produitCode: 'PRD0001', designation: 'Pack 6', quantite: 6, prixVente: 550);
      const pack = Pack(
        code: 'PCK0001',
        designation: 'Duo',
        prixVente: 120,
        lignes: [
          PackLigne(produitCode: 'PRD0001', quantite: 1),
          PackLigne(produitCode: 'PRD0002', quantite: 2),
        ],
      );
      final p = const Panier(id: 1)
          .ajouter(const PanierLigne(produit: _lait, quantite: 2, prixUnitaire: 100))
          .ajouter(const PanierLigne(produit: _lait, colis: colis, quantite: 1, prixUnitaire: 550))
          .ajouter(const PanierLigne(produit: _lait, pack: pack, quantite: 3, prixUnitaire: 120))
          .ajouter(const PanierLigne(produit: _eau, quantite: 5, uniteVente: UniteVente.nombre, prixUnitaire: 6));
      expect(p.unitesReservees('PRD0001'), 2 + 6 + 3);
      expect(p.unitesReservees('PRD0002'), 6);
      expect(p.nombreReserve('PRD0002'), 5);
      expect(p.lignes.length, 4);
    });

    test('points de fidélité', () {
      expect(Fidelite.pointsGagnes(1250, active: true, pointsParDinar: 0.01, clientCode: 'CLN0001'), 12);
      expect(Fidelite.pointsGagnes(1250, active: true, pointsParDinar: 0.01, clientCode: 'CLN0000'), 0);
      expect(Fidelite.pointsGagnes(1250, active: false, pointsParDinar: 0.01, clientCode: 'CLN0001'), 0);
      expect(Fidelite.pointsPourMontant(49.5), 50);
    });
  });

  group('Scellement SHA-256 chaîné', () {
    test('déterministe, chaîne vérifiée, altération détectée', () {
      final d1 = {
        'code': 'VTE0001',
        'net': 100.0,
        'lignes': [
          {'p': 'PRD0001', 'q': 1.0},
        ],
      };
      final d2 = {'code': 'VTE0002', 'net': 50.0, 'lignes': <Object>[]};
      final h1 = Scellement.hacher(d1, Scellement.genese);
      final h2 = Scellement.hacher(d2, h1);
      expect(h1.length, 64);
      expect(
        Scellement.hacher({
          'lignes': [
            {'q': 1.0, 'p': 'PRD0001'},
          ],
          'net': 100,
          'code': 'VTE0001',
        }, Scellement.genese),
        h1,
        reason: 'ordre des clés et int/double indifférents',
      );
      expect(
        Scellement.verifier([
          (doc: d1, hashPrecedent: Scellement.genese, hash: h1),
          (doc: d2, hashPrecedent: h1, hash: h2),
        ]),
        isNull,
      );
      expect(
        Scellement.verifier([
          (doc: {...d1, 'net': 101.0}, hashPrecedent: Scellement.genese, hash: h1),
          (doc: d2, hashPrecedent: h1, hash: h2),
        ]),
        0,
      );
      expect(
        Scellement.verifier([
          (doc: d1, hashPrecedent: Scellement.genese, hash: h1),
          (doc: d2, hashPrecedent: Scellement.genese, hash: h2),
        ]),
        1,
        reason: 'rupture de chaîne',
      );
    });
  });
}
