import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/print/documents_pdf.dart';
import 'package:caissedz_desktop/core/print/imprimante.dart';
import 'package:caissedz_desktop/core/print/ticket_escpos.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/vente.dart';
import 'package:caissedz_desktop/domain/scellement.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

const _params = ParametresVente(margeDefautPct: 20, fideliteActive: true, pointsParDinar: 0.1);

class _Ctx {
  _Ctx(this.db);
  final dynamic db;
  late Produit lait;
  late Produit eau;
  late SessionCaisse session;
  late VenteService ventes;
  late SessionCaisseService sessions;

  Future<void> preparer() async {
    final cat = CatalogueService(db, utilisateurCode: 'USR0000');
    lait = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
      ),
    );
    eau = await cat.creerProduit(
      const Produit(
        code: '',
        designation: 'Eau',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 20,
        prixVente: 30,
        suiviNombre: true,
        nombreParUnite: 6,
      ),
    );
    final stock = StockService(db, utilisateurCode: 'USR0000');
    await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
    await stock.entrerStock(produitCode: eau.code, magasinCode: 'MAG0000', quantite: 5, nombre: 30);
    await db.insert('client', {'code': 'CLN0001', 'nom': 'Amina', 'points': 20});
    sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
    session = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 1000);
    ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: _params);
  }
}

void main() {
  group('SessionCaisseService', () {
    test('ouverture obligatoire, unique par utilisateur et par caisse, fermeture avec écart', () async {
      final base = await ouvrirBaseDeTest();
      final s = SessionCaisseService(base.db, utilisateurCode: 'USR0000');
      expect(await s.courante(), isNull);
      await expectLater(
        s.ouvrir(caisseCode: 'CIS9999', fondInitial: 0),
        throwsA(isA<SessionException>().having((e) => e.erreur, 'e', ErreurSession.caisseInconnue)),
      );
      final ouverte = await s.ouvrir(caisseCode: 'CIS0000', fondInitial: 500);
      expect(ouverte.code, 'SES0001');
      await expectLater(
        s.ouvrir(caisseCode: 'CIS0000', fondInitial: 0),
        throwsA(isA<SessionException>().having((e) => e.erreur, 'e', ErreurSession.dejaOuverte)),
      );
      await expectLater(
        SessionCaisseService(base.db, utilisateurCode: 'USR0001').ouvrir(caisseCode: 'CIS0000', fondInitial: 0),
        throwsA(isA<SessionException>()),
      );
      final fermee = await s.fermer(montantCompte: 480);
      expect(fermee.statut, 'Fermée');
      expect(fermee.ecart, -20);
      expect(await s.courante(), isNull);
      await expectLater(
        s.fermer(montantCompte: 0),
        throwsA(isA<SessionException>().having((e) => e.erreur, 'e', ErreurSession.aucuneOuverte)),
      );
    });
  });

  group('VenteService.encaisser', () {
    test('une transaction : vente, lignes, paiements, stock, points, scellement', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final panier = const Panier(id: 1, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: c.lait, quantite: 3, prixUnitaire: 100))
          .ajouter(PanierLigne(produit: c.eau, quantite: 6, uniteVente: UniteVente.nombre, prixUnitaire: 5))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 400));
      expect(panier.totalNet, 330);
      final v = await c.ventes.encaisser(panier, session: c.session, magasinCode: 'MAG0000');
      expect(v.code, 'VTE0001');
      expect(v.verse, 400);
      expect(v.reste, 0);
      expect(v.monnaie, 70);
      expect(v.pointsGagnes, 33);
      expect(v.hashPrecedent, Scellement.genese);
      expect(v.hash.length, 64);
      final repo = StockRepository(base.db);
      expect((await repo.niveau(c.lait.code, 'MAG0000')).quantite, 7);
      final nEau = await repo.niveau(c.eau.code, 'MAG0000');
      expect(nEau.quantite, 5);
      expect(nEau.nombre, 24);
      expect(await VenteRepository(base.db).pointsClient('CLN0001'), 53);
      final relue = (await VenteRepository(base.db).vente('VTE0001'))!;
      expect(relue.lignes.length, 2);
      expect(relue.paiements.single.mode, 'Espèces');
      expect(await c.ventes.verifierChaine(), isNull);
      expect((await c.sessions.especesAttendues(c.session.code)), 1330); // 1000 + 400 − 70 de monnaie
    });

    test(
      'refus : session fermée, panier vide, paiement insuffisant sans crédit, stock insuffisant → rien n’est écrit',
      () async {
        final base = await ouvrirBaseDeTest();
        final c = _Ctx(base.db);
        await c.preparer();
        final panier = const Panier(id: 1).ajouter(PanierLigne(produit: c.lait, quantite: 2, prixUnitaire: 100));
        await expectLater(
          c.ventes.encaisser(const Panier(id: 1), session: c.session, magasinCode: 'MAG0000'),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.panierVide)),
        );
        await expectLater(
          c.ventes.encaisser(panier, session: c.session, magasinCode: 'MAG0000'),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.paiementInsuffisant)),
        );
        await expectLater(
          c.ventes.encaisser(
            panier.copyWith(clientCode: 'CLN0001'),
            session: c.session,
            magasinCode: 'MAG0000',
          ),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.paiementInsuffisant)),
        );
        final trop = const Panier(id: 2)
            .ajouter(PanierLigne(produit: c.lait, quantite: 50, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 5000));
        await expectLater(
          c.ventes.encaisser(trop, session: c.session, magasinCode: 'MAG0000'),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.stockInsuffisant)),
        );
        expect((await VenteRepository(base.db).ventes()).isEmpty, isTrue);
        expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 10);
        await c.sessions.fermer(montantCompte: 1000);
        await expectLater(
          c.ventes.encaisser(
            panier.ajouterPaiement(const Paiement(mode: 'Carte', montant: 200)),
            session: c.session,
            magasinCode: 'MAG0000',
          ),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.sessionRequise)),
        );
      },
    );

    test('vente à crédit (reste dû) pour un client identifié, paiement par points', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final credit = const Panier(id: 1, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: c.lait, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Chèque', montant: 50));
      final v = await c.ventes.encaisser(credit, session: c.session, magasinCode: 'MAG0000', creditAutorise: true);
      expect(v.reste, 150);
      final points = const Panier(id: 2, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Points', montant: 20))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 80));
      final v2 = await c.ventes.encaisser(points, session: c.session, magasinCode: 'MAG0000');
      expect(v2.pointsUtilises, 20);
      expect(v2.pointsGagnes, 10);
      // 20 + 20 (vente 1) - 20 + 10 = 30
      expect(await VenteRepository(base.db).pointsClient('CLN0001'), 30);
      final trop = const Panier(id: 3, clientCode: 'CLN0001')
          .ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Points', montant: 100));
      await expectLater(
        c.ventes.encaisser(trop, session: c.session, magasinCode: 'MAG0000'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.pointsInsuffisants)),
      );
      expect(v2.hashPrecedent, v.hash);
      expect(await c.ventes.verifierChaine(), isNull);
    });

    test(
      'annulation : stock et points restitués, ticket conservé, chaîne intacte ; refus en période clôturée',
      () async {
        final base = await ouvrirBaseDeTest();
        final c = _Ctx(base.db);
        await c.preparer();
        final panier = const Panier(id: 1, clientCode: 'CLN0001')
            .ajouter(PanierLigne(produit: c.lait, quantite: 2, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 200));
        final v = await c.ventes.encaisser(panier, session: c.session, magasinCode: 'MAG0000');
        expect(await VenteRepository(base.db).pointsClient('CLN0001'), 40);
        final a = await c.ventes.annuler(v.code, motif: 'Erreur de saisie');
        expect(a.statut, 'Annulée');
        expect((await StockRepository(base.db).niveau(c.lait.code, 'MAG0000')).quantite, 10);
        expect(await VenteRepository(base.db).pointsClient('CLN0001'), 20);
        expect(await c.ventes.verifierChaine(), isNull);
        await expectLater(
          c.ventes.annuler(v.code, motif: 'test'),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.dejaAnnulee)),
        );
        final v2 = await c.ventes.encaisser(panier.copyWith(id: 2), session: c.session, magasinCode: 'MAG0000');
        final verrouille = VenteService(
          base.db,
          utilisateurCode: 'USR0000',
          parametres: _params,
          periodeCloturee: (_, _, {caisseCode}) async => true,
        );
        await expectLater(
          verrouille.annuler(v2.code, motif: 'test'),
          throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.periodeCloturee)),
        );
      },
    );

    test('altération d’un ticket détectée par verifierChaine', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final panier = const Panier(id: 1)
          .ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100));
      await c.ventes.encaisser(panier, session: c.session, magasinCode: 'MAG0000');
      await c.ventes.encaisser(panier.copyWith(id: 2), session: c.session, magasinCode: 'MAG0000');
      await base.db.update('vente', {'total_net': 1}, where: 'code = ?', whereArgs: ['VTE0001']);
      expect(await c.ventes.verifierChaine(), 'VTE0001');
    });
  });

  group('VenteService — écran Ventes (§9.2)', () {
    test('modifier : complément en versement imputé, observation, refus si baisse ou client de passage', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final credit = await c.ventes.encaisser(
        const Panier(id: 1, clientCode: 'CLN0001')
            .ajouter(PanierLigne(produit: c.lait, quantite: 3, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: c.session,
        magasinCode: 'MAG0000',
        creditAutorise: true,
      );
      expect(credit.reste, 200);
      await expectLater(
        c.ventes.modifier(credit.code, montantPaye: 50, mode: 'Espèces'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.montantPayeInferieur)),
      );
      final m = await c.ventes.modifier(
        credit.code,
        montantPaye: 250,
        mode: 'Chèque',
        caisseCode: 'CIS0000',
        commentaire: 'Chèque n° 12',
      );
      expect(m.commentaire, 'Chèque n° 12');
      expect(m.hash, credit.hash); // ticket scellé intact
      expect(await c.ventes.verifierChaine(), isNull);
      final panier = (await VenteRepository(base.db).paniers()).single;
      expect(panier.paye, 250);
      expect(panier.resteActuel, 50);
      expect(panier.nbVersements, 1);
      expect(panier.statut, 'credit');
      expect(panier.totalAchat, 240);
      expect(panier.marge, 60);

      final passage = await c.ventes.encaisser(
        const Panier(id: 2)
            .ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: c.session,
        magasinCode: 'MAG0000',
      );
      await expectLater(
        c.ventes.modifier(passage.code, montantPaye: 150, mode: 'Espèces'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.creditNonAutorise)),
      );
      expect((await c.ventes.modifier(passage.code, montantPaye: 100, mode: 'Espèces')).statut, 'Validée');
    });

    test('annuler : motif obligatoire, versement lié annulé, refus si un retour est lié', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      Future<Vente> aCredit(int id) => c.ventes.encaisser(
        Panier(id: id, clientCode: 'CLN0001').ajouter(PanierLigne(produit: c.lait, quantite: 1, prixUnitaire: 100)),
        session: c.session,
        magasinCode: 'MAG0000',
        creditAutorise: true,
      );
      final v = await aCredit(1);
      await c.ventes.modifier(v.code, montantPaye: 100, mode: 'Espèces', caisseCode: 'CIS0000');
      await expectLater(
        c.ventes.annuler(v.code, motif: '  '),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.motifObligatoire)),
      );
      await c.ventes.annuler(v.code, motif: 'Erreur client');
      final versement = (await base.db.query('versement')).single;
      expect(versement['etat'], 0);
      expect(await base.db.query('versement_imputation'), isEmpty);
      final p = (await VenteRepository(base.db).paniers()).single;
      expect(p.statut, 'annule');
      expect(p.motifAnnulation, 'Erreur client');
      expect(p.annuleeLe, isNotNull);

      final v2 = await aCredit(2);
      await base.db.insert('retour', {
        'code': 'RET0001',
        'date': DateTime.now().toUtc().toIso8601String(),
        'document_code': v2.code,
        'client_code': 'CLN0001',
        'magasin_code': 'MAG0000',
        'utilisateur_code': 'USR0000',
        'total': 100,
      });
      await expectLater(
        c.ventes.annuler(v2.code, motif: 'test'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.retourLie)),
      );
      expect((await VenteRepository(base.db).paniers()).first.statut, 'retourne');
    });
  });

  group('Impression', () {
    test('ticket ESC/POS 58 et 80 mm FR/AR, PDF ticket et facture', () async {
      final base = await ouvrirBaseDeTest();
      final c = _Ctx(base.db);
      await c.preparer();
      final panier = const Panier(id: 1)
          .ajouter(PanierLigne(produit: c.lait, quantite: 2, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 500));
      final v = await c.ventes.encaisser(panier, session: c.session, magasinCode: 'MAG0000');
      const boutique = Boutique(nom: 'Superette El Baraka', adresse: 'Alger', telephone: '0550 00 00 00');
      final fr58 = const TicketEscPos(
        largeur: LargeurTicket.mm58,
        libelles: LibellesTicket.fr,
      ).generer(v, boutique: boutique, ouvrirTiroir: true);
      final ar80 = const TicketEscPos(
        largeur: LargeurTicket.mm80,
        libelles: LibellesTicket.ar,
      ).generer(v, boutique: boutique);
      expect(fr58.take(2).toList(), [0x1B, 0x40]);
      expect(String.fromCharCodes(fr58).contains('NET A PAYER'), isTrue);
      expect(String.fromCharCodes(fr58).contains('VTE0001'), isTrue);
      expect(fr58.last, 0x00); // coupe GS V 0
      expect(ar80.length, greaterThan(100));
      expect(ar80[4], 22); // page de codes CP1256
      final imp = ImprimanteMemoire();
      await imp.envoyer(fr58);
      expect(imp.envoyes.single.length, fr58.length);
      const pdf = DocumentsPdf(libelles: LibellesTicket.fr);
      final t = await pdf.ticket(v, boutique: boutique, largeur: LargeurTicket.mm80);
      final f = await pdf.factureA4(v, boutique: boutique, nomClient: 'Client de passage');
      expect(String.fromCharCodes(t.take(5)), '%PDF-');
      expect(f.length, greaterThan(1500));
      await expectLater(
        const ImprimanteReseau('127.0.0.1', port: 1, delai: Duration(milliseconds: 300)).envoyer(fr58),
        throwsA(isA<ImpressionException>()),
      );
    });
  });
}
