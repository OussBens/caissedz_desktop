import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/cloture_service.dart';
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
      expect(banque.code, 'CS0001');
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
      expect((await s.caisses(actives: true)).map((c) => c.code), ['CIS0000', 'CIS0001', 'CS0001']);
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
      // Désactivation refusée tant que le solde n'est pas nul ; une caisse inactive ne reçoit rien.
      await expectLater(
        s.modifier(banque.copyWith(actif: false)),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.soldeNonNul)),
      );
      await s.transferer(caisseSource: banque.code, caisseDestination: 'CIS0000', montant: 3000);
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
      await VersementService(db, utilisateurCode: 'USR0000').annuler(ver.code, motif: 'Erreur');
      expect((await caisse.solde('CIS0000')).especes, 1300);
      // Annulation de la vente espèces → sortie 300.
      await ventes.annuler(v1.code, motif: 'test');
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
      // Session suivante : l'attendu suit tout le tiroir (versement encaissé, dépense, carte exclue), pas
      // seulement les ventes ; la session précédente n'est pas recomptée.
      final s2 = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 500);
      await VersementService(
        db,
        utilisateurCode: 'USR0000',
      ).imputer(tiersType: TypesTiers.client, tiersCode: client.code, montant: 100, mode: 'Espèces');
      await caisse.mouvementManuel(caisseCode: 'CIS0000', apport: false, montant: 250, commentaire: 'Fournitures');
      await caisse.mouvementManuel(caisseCode: 'CIS0000', apport: true, montant: 70, mode: 'Carte');
      expect(await sessions.especesAttendues(s2.code), 500 + 100 - 250);
      final f2 = await sessions.fermer(montantCompte: 350);
      expect(f2.ecart, 0);
      expect((await caisse.solde('CIS0000')).especes, 0);
    });

    test('journal en ajout seul : contre-passation après la Z, période close, suppression interdite', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final client = await TiersService(
        db,
        utilisateurCode: 'USR0000',
      ).creerClient(const Client(code: '', nom: 'Amina'));
      final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
      await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      final versements = VersementService(db, utilisateurCode: 'USR0000');
      final ver = await versements.imputer(
        tiersType: TypesTiers.client,
        tiersCode: client.code,
        montant: 20000,
        mode: 'Espèces',
      );
      await sessions.fermer(montantCompte: 20000);
      final z = await ClotureService(db, utilisateurCode: 'USR0000').cloturer(caisseCode: 'CIS0000');
      final repo = CaisseRepository(db);
      final avant = await repo.totauxPeriode(z.debut, z.fin, caisseCode: 'CIS0000');
      // Le lendemain : modifier le versement (période close) est refusé, l'annuler le contre-passe.
      await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 20000);
      await expectLater(
        versements.modifier(ver.code, montant: 15000, mode: 'Espèces', date: ver.date),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.periodeCloturee)),
      );
      await expectLater(
        versements.imputer(
          tiersType: TypesTiers.client,
          tiersCode: client.code,
          montant: 10,
          mode: 'Espèces',
          date: ver.date,
        ),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.periodeCloturee)),
      );
      await versements.annuler(ver.code, motif: 'Chèque rejeté');
      final lignes = await repo.mouvements(referenceType: 'versement', referenceCode: ver.code);
      expect(lignes.map((m) => (m.sens, m.montant, m.type)), [
        (SensMouvementCaisse.sortie, 20000.0, TypesMouvementCaisse.annulation),
        (SensMouvementCaisse.entree, 20000.0, TypesMouvementCaisse.encaissement),
      ]);
      expect(lignes.first.date.isAfter(z.fin), isTrue, reason: 'contre-écriture datée du jour');
      final apres = await repo.totauxPeriode(z.debut, z.fin, caisseCode: 'CIS0000');
      expect((apres.entrees, apres.sorties), (avant.entrees, avant.sorties), reason: 'la Z reste égale au grand-livre');
      expect(await sessions.especesAttendues((await sessions.courante())!.code), 0);
      // Le journal refuse suppressions et réécritures des montants.
      await expectLater(db.delete('mouvement_caisse'), throwsA(anything));
      await expectLater(db.update('mouvement_caisse', {'montant': 1}), throwsA(anything));
      expect(
        (await repo.mouvements(caisseCode: 'CIS0000')).length,
        4,
        reason: 'versement, retrait, fond, contre-écriture',
      );
      // La clôture d'une caisse ne ferme pas la période d'une autre.
      final coffre = await CaisseService(db, utilisateurCode: 'USR0000').creer(nom: 'Coffre');
      expect(await repo.periodeCloturee(ver.date, caisseCode: 'CIS0000'), isTrue);
      expect(await repo.periodeCloturee(ver.date, caisseCode: coffre.code), isFalse);
    });

    test('DS v2.2 : solde initial, observation, désactivation en lot bloquée, annulation de transferts', () async {
      final base = await ouvrirBaseDeTest();
      final s = CaisseService(base.db, utilisateurCode: 'USR0000');
      expect(await s.prochainCode(), 'CS0001');
      final c1 = await s.creer(nom: 'Caisse 1', soldeInitial: 3000, observation: '  Comptoir  ');
      expect(c1.soldeInitial, 3000);
      expect(c1.observation, 'Comptoir');
      await expectLater(
        s.creer(nom: 'X', soldeInitial: -1),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.montantInvalide)),
      );
      final coffre = await s.creer(nom: 'Coffre');
      final relue = (await s.caisses()).firstWhere((c) => c.code == c1.code);
      expect(relue.soldeInitial, 3000);
      expect(relue.observation, 'Comptoir');
      // Session ouverte → désactivation bloquée.
      final sessions = SessionCaisseService(base.db, utilisateurCode: 'USR0000');
      await sessions.ouvrir(caisseCode: c1.code, fondInitial: 3000);
      expect(await s.blocageDesactivation(c1), ErreurCaisse.sessionOuverte);
      expect(await s.blocageDesactivation(coffre), isNull);
      final principale = (await s.caisses()).firstWhere((c) => c.systeme);
      expect(await s.blocageDesactivation(principale), ErreurCaisse.caisseSysteme);
      await expectLater(
        s.desactiver([coffre.code, c1.code]),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.sessionOuverte)),
      );
      expect((await s.caisses(actives: true)).map((c) => c.code), contains(coffre.code), reason: 'tout ou rien');
      // Transfert vers le coffre puis annulation : mouvements contre-passés, transfert conservé avec son motif.
      final t = await s.transferer(caisseSource: c1.code, caisseDestination: coffre.code, montant: 2000);
      expect((await s.solde(coffre.code)).especes, 2000);
      expect(await s.blocageDesactivation(coffre), ErreurCaisse.soldeNonNul);
      await expectLater(
        s.annulerTransferts([t.code], motif: ' '),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.motifObligatoire)),
      );
      // Le coffre a dépensé une partie : l'annulation ne peut plus reprendre le montant.
      await s.mouvementManuel(caisseCode: coffre.code, apport: false, montant: 500);
      expect(await s.blocageAnnulationTransfert(t), ErreurCaisse.soldeInsuffisant);
      await s.mouvementManuel(caisseCode: coffre.code, apport: true, montant: 500);
      await s.annulerTransferts([t.code], motif: 'Erreur de caisse');
      expect((await s.solde(coffre.code)).especes, 0);
      expect((await s.solde(c1.code)).especes, 3000);
      final mvts = await CaisseRepository(base.db).mouvements(referenceType: 'transfert_caisse', referenceCode: t.code);
      expect(mvts.length, 4);
      expect(mvts.every((m) => m.type == TypesMouvementCaisse.transfert), isTrue, reason: 'hors totaux de la Z');
      final annule = (await s.transferts()).single;
      expect(annule.actif, isFalse);
      expect(annule.motifAnnulation, 'Erreur de caisse');
      expect(annule.annulePar, 'USR0000');
      expect(await s.blocageAnnulationTransfert(annule), ErreurCaisse.dejaAnnule);
      await expectLater(
        s.annulerTransferts([t.code], motif: 'x'),
        throwsA(isA<CaisseException>().having((e) => e.erreur, 'e', ErreurCaisse.dejaAnnule)),
      );
      await s.desactiver([coffre.code]);
      expect((await s.caisses(actives: true)).map((c) => c.code), isNot(contains(coffre.code)));
    });
  });
}
