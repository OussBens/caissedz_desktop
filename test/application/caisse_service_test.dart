import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/domain/models/caisse.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  group('CaisseService', () {
    test('caisses Physique / Compte, sans magasin, modification, système non désactivable', () async {
      final base = await ouvrirBaseDeTest();
      final s = CaisseService(base.db, utilisateurCode: 'USR0000');
      final banque = await s.creer(nom: 'Compte BNA', type: TypesCaisse.compte);
      expect(banque.code, 'CIS0001');
      expect(banque.magasinCode, isNull);
      final c2 = await s.creer(nom: 'Caisse 2', magasinCode: 'MAG0000');
      expect(c2.magasinCode, 'MAG0000');
      await expectLater(
        s.creer(nom: '', type: TypesCaisse.physique),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.nomVide)),
      );
      await expectLater(
        s.creer(nom: 'X', type: 'Coffre'),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.typeInvalide)),
      );
      await expectLater(
        s.creer(nom: 'X', magasinCode: 'MAG9999'),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.magasinInconnu)),
      );
      final maj = await s.modifier(c2.copyWith(nom: 'Caisse bis', sansMagasin: true, actif: false));
      expect(maj.nom, 'Caisse bis');
      expect(maj.magasinCode, isNull);
      expect(maj.actif, isFalse);
      final principale = (await s.caisses()).firstWhere((c) => c.code == 'CIS0000');
      await expectLater(
        s.modifier(principale.copyWith(actif: false)),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.caisseSysteme)),
      );
      expect((await s.caisses(actives: true)).map((c) => c.code), ['CIS0000', 'CIS0001']);
    });

    test('journal : apport, dépense, transfert TRF = 2 mouvements, solde insuffisant, même caisse', () async {
      final base = await ouvrirBaseDeTest();
      final s = CaisseService(base.db, utilisateurCode: 'USR0000');
      final banque = await s.creer(nom: 'Compte', type: TypesCaisse.compte);
      await s.mouvementManuel(caisseCode: 'CIS0000', apport: true, montant: 5000, commentaire: 'Fond');
      await s.mouvementManuel(caisseCode: 'CIS0000', apport: false, montant: 1200.5, commentaire: 'Loyer');
      expect((await s.solde('CIS0000')).especes, 3799.5);
      await expectLater(
        s.mouvementManuel(caisseCode: 'CIS0000', apport: true, montant: 0),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.montantInvalide)),
      );
      await expectLater(
        s.transferer(caisseSource: 'CIS0000', caisseDestination: 'CIS0000', montant: 10),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.memeCaisse)),
      );
      await expectLater(
        s.transferer(caisseSource: 'CIS0000', caisseDestination: banque.code, montant: 10000),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.soldeInsuffisant)),
      );
      final t = await s.transferer(caisseSource: 'CIS0000', caisseDestination: banque.code, montant: 3000);
      expect(t.code, 'TRF0001');
      final mvts = await CaisseRepository(base.db).mouvements(referenceType: 'transfert_caisse', referenceCode: t.code);
      expect(mvts.length, 2);
      expect(mvts.map((m) => m.sens).toSet(), {SensMouvementCaisse.sortie, SensMouvementCaisse.entree});
      expect((await s.solde('CIS0000')).especes, 799.5);
      expect((await s.solde(banque.code)).especes, 3000);
      expect((await s.transferts()).single.caisseDestination, banque.code);
      // Une caisse inactive ne reçoit rien.
      await s.modifier(banque.copyWith(actif: false));
      await expectLater(
        s.transferer(caisseSource: 'CIS0000', caisseDestination: banque.code, montant: 1),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.caisseInactive)),
      );
    });

    test('journal alimenté par les sessions, ventes, annulations, versements et achats', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 50);
      final client = await TiersService(
        db,
        utilisateurCode: 'USR0000',
      ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 10000));
      final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
      final session = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 1000);
      final caisse = CaisseService(db, utilisateurCode: 'USR0000');
      expect((await caisse.solde('CIS0000')).especes, 1000);
      final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
      // Espèces 500 pour 300 → entrée nette 300 (monnaie 200 rendue).
      final v1 = await ventes.encaisser(
        const Panier(id: 1)
            .ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 500)),
        session: session,
        magasinCode: 'MAG0000',
      );
      // Carte 200.
      await ventes.encaisser(
        const Panier(id: 2)
            .ajouter(PanierLigne(produit: lait, quantite: 2, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Carte', montant: 200)),
        session: session,
        magasinCode: 'MAG0000',
      );
      var solde = await caisse.solde('CIS0000');
      expect(solde.especes, 1300);
      expect(solde.parMode['Carte'], 200);
      // Versement client (encaissement) puis suppression → mouvement retiré.
      final ver = await VersementService(
        db,
        utilisateurCode: 'USR0000',
      ).imputer(tiersType: TypesTiers.client, tiersCode: client.code, montant: 150, mode: 'Espèces');
      expect(ver.caisseCode, 'CIS0000');
      expect((await caisse.solde('CIS0000')).especes, 1450);
      await VersementService(db, utilisateurCode: 'USR0000').supprimer(ver.code);
      expect((await caisse.solde('CIS0000')).especes, 1300);
      // Annulation de la vente espèces → sortie 300.
      await ventes.annuler(v1.code);
      expect((await caisse.solde('CIS0000')).especes, 1000);
      // Fermeture : compté 1050 → écart +50 journalisé, retrait 1050 ; solde espèces = 0.
      final fermee = await sessions.fermer(montantCompte: 1050);
      expect(fermee.ecart, 50);
      solde = await caisse.solde('CIS0000');
      expect(solde.especes, 0);
      expect(solde.parMode['Carte'], 200);
      final types = (await caisse.mouvements(caisseCode: 'CIS0000')).map((m) => m.type).toSet();
      expect(
        types,
        containsAll([
          TypesMouvementCaisse.fondInitial,
          TypesMouvementCaisse.vente,
          TypesMouvementCaisse.annulation,
          TypesMouvementCaisse.ecart,
          TypesMouvementCaisse.retrait,
        ]),
      );
    });
  });
}
