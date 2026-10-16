import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/cloture_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/caisse.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/vente.dart';
import 'package:caissedz_desktop/domain/scellement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

class _Ctx {
  _Ctx(this.db);
  final Database db;
  late Produit lait;
  late SessionCaisseService sessions;
  late VenteService ventes;
  final List<Vente> tickets = [];

  Future<void> preparer() async {
    lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
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
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 100);
    sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
    ventes = VenteService(
      db,
      utilisateurCode: 'USR0000',
      parametres: const ParametresVente(),
      periodeCloturee: ClotureService.periodeCloturee,
    );
  }

  /// Ouvre une session, encaisse [n] ventes de 100 DA en espèces, ferme la session.
  Future<void> journee(int n, {DateTime? date}) async {
    final s = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    for (var i = 0; i < n; i++) {
      tickets.add(
        await ventes.encaisser(
          Panier(id: i)
              .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
              .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
          session: s,
          magasinCode: 'MAG0000',
          date: date,
        ),
      );
    }
    await sessions.fermer(montantCompte: 100.0 * n);
  }
}

void main() {
  group('ClotureService', () {
    test('clôtures Z par caisse : chaîne par caisse, totaux, annulés, répartition, rien à clôturer', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      final clotures = ClotureService(base.db, utilisateurCode: 'USR0000');
      await expectLater(
        clotures.cloturer(caisseCode: 'CIS0000'),
        throwsA(isA<ClotureException>().having((e) => e.erreur, 'e', ErreurCloture.rienACloturer)),
      );
      await expectLater(
        clotures.apercu(caisseCode: 'CS9999'),
        throwsA(isA<ClotureException>().having((e) => e.erreur, 'e', ErreurCloture.caisseInconnue)),
      );
      await ctx.journee(3);
      final apercu = await clotures.apercu(caisseCode: 'CIS0000');
      expect(apercu.nbVentes, 3);
      expect(apercu.totalVentes, 300);
      final z1 = await clotures.cloturer(caisseCode: 'CIS0000');
      expect(z1.code, 'CLT0001');
      expect(z1.caisseCode, 'CIS0000');
      expect(z1.hashPrecedent, Scellement.genese);
      expect(z1.nbVentes, 3);
      expect(z1.totalEncaissements, 300);
      expect(z1.totalDecaissements, 300); // retrait de fermeture
      expect(z1.encaissementsParMode, {'Espèces': 300});
      expect(z1.derniereVente, 'VTE0003');
      expect(z1.hashDerniereVente, ctx.tickets.last.hash);
      expect(z1.soldesCaisses, {'CIS0000': 0});
      expect(z1.hash, Scellement.hacher(z1.versCanonique(), Scellement.genese));
      // Seconde caisse, session laissée ouverte : la clôture Z ne l'exige pas.
      final c2 = await CaisseService(base.db, utilisateurCode: 'USR0000').creer(nom: 'Caisse 2');
      final s2 = await ctx.sessions.ouvrir(caisseCode: c2.code, fondInitial: 0);
      Future<Vente> vendre(int id, int qte, Paiement p) => ctx.ventes.encaisser(
        Panier(id: id)
            .ajouter(PanierLigne(produit: ctx.lait, quantite: qte.toDouble(), prixUnitaire: 100))
            .ajouterPaiement(p),
        session: s2,
        magasinCode: 'MAG0000',
      );
      await vendre(10, 2, const Paiement(mode: 'Carte', montant: 200));
      await vendre(11, 1, const Paiement(mode: 'Espèces', montant: 150)); // 50 rendus
      final annulee = await vendre(12, 1, const Paiement(mode: 'Espèces', montant: 100));
      await ctx.ventes.annuler(annulee.code, motif: 'test');
      final z2 = await clotures.cloturer(caisseCode: c2.code);
      expect(z2.code, 'CLT0002');
      expect(z2.caisseCode, c2.code);
      expect(z2.hashPrecedent, Scellement.genese, reason: 'chaîne propre à la caisse');
      expect(z2.debut, DateTime.utc(1970));
      expect(z2.nbVentes, 2);
      expect(z2.nbAnnulations, 1);
      expect(z2.totalVentes, 300);
      expect(z2.totalAnnule, 100);
      expect(z2.encaissementsParMode, {'Carte': 200, 'Espèces': 100});
      // La caisse principale poursuit sa propre chaîne.
      await ctx.sessions.fermer(montantCompte: 100);
      await ctx.journee(1);
      final z3 = await clotures.cloturer(caisseCode: 'CIS0000');
      expect(z3.code, 'CLT0003');
      expect(z3.hashPrecedent, z1.hash);
      expect(z3.debut, z1.fin);
      expect(z3.nbVentes, 1);
      expect(await clotures.verifierChaine(), isNull);
      expect((await clotures.clotures(caisseCode: c2.code)).map((c) => c.code), ['CLT0002']);
      expect((await clotures.derniere('CIS0000'))!.code, 'CLT0003');
    });

    test(
      'une clôture globale antérieure (v15) forme sa propre chaîne et borne la première clôture par caisse',
      () async {
        final base = await ouvrirBaseDeTest();
        final ctx = _Ctx(base.db);
        await ctx.preparer();
        await ctx.journee(1);
        final fin = DateTime.now();
        final legacy = Cloture(
          code: 'CLZ0001',
          date: fin,
          debut: DateTime.utc(1970),
          fin: fin,
          utilisateurCode: 'USR0000',
          nbVentes: 1,
          nbAnnulations: 0,
          totalVentes: 100,
          totalRemises: 0,
          totalRetours: 0,
          totalEncaissements: 100,
          totalDecaissements: 100,
          encaissementsParMode: const {'Espèces': 100},
          soldesCaisses: const {'CIS0000': 0},
          hashDerniereVente: ctx.tickets.last.hash,
          hashPrecedent: Scellement.genese,
          hash: '',
        );
        await CaisseRepository(base.db)
            .insererCloture(legacy.copyWith(hash: Scellement.hacher(legacy.versCanonique(), Scellement.genese)));
        await ctx.journee(2);
        final clotures = ClotureService(base.db, utilisateurCode: 'USR0000');
        final z = await clotures.cloturer(caisseCode: 'CIS0000');
        expect(z.debut, fin);
        expect(z.nbVentes, 2);
        expect(z.hashPrecedent, Scellement.genese);
        expect(await clotures.verifierChaine(), isNull);
      },
    );

    test('immuabilité : UPDATE et DELETE refusés par le moteur ; altération détectée', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      await ctx.journee(1);
      final clotures = ClotureService(base.db, utilisateurCode: 'USR0000');
      final z = await clotures.cloturer(caisseCode: 'CIS0000');
      await expectLater(
        base.db.update('cloture', {'total_ventes': 0}, where: 'code = ?', whereArgs: [z.code]),
        throwsA(anything),
      );
      await expectLater(base.db.delete('cloture', where: 'code = ?', whereArgs: [z.code]), throwsA(anything));
      await expectLater(base.db.rawUpdate('UPDATE cloture SET hash = ?', ['x']), throwsA(anything));
      expect((await clotures.clotures()).single.totalVentes, 100);
      // Altération simulée en recréant la table sans déclencheur : la chaîne la détecte.
      await base.db.execute('DROP TRIGGER cloture_immuable_update');
      await base.db.update('cloture', {'total_ventes': 1}, where: 'code = ?', whereArgs: [z.code]);
      expect(await clotures.verifierChaine(), z.code);
    });

    test('période clôturée : annulation de vente et d’achat refusées, retour daté du jour accepté', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      await ctx.journee(2);
      // Achat et retour exigent une session ouverte (§8.4).
      await ctx.sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      final achats = AchatService(base.db, utilisateurCode: 'USR0000', periodeCloturee: ClotureService.periodeCloturee);
      final a = await achats.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: ctx.lait.code, quantite: 1, prixAchat: 80)],
      );
      final z = await ClotureService(base.db, utilisateurCode: 'USR0000').cloturer(caisseCode: 'CIS0000');
      await expectLater(
        ctx.ventes.annuler(ctx.tickets.first.code, motif: 'test'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.periodeCloturee)),
      );
      final retours = RetourService(
        base.db,
        utilisateurCode: 'USR0000',
        periodeCloturee: ClotureService.periodeCloturee,
      );
      // Un retour antidaté dans la période close est refusé ; daté du jour, il passe après la Z de la vente.
      await expectLater(
        retours.creer(
          type: TypesTiers.client,
          documentCode: ctx.tickets.first.code,
          produitCode: ctx.lait.code,
          quantite: 1,
          date: z.fin.subtract(const Duration(minutes: 1)),
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.periodeCloturee)),
      );
      final r = await retours.creer(
        type: TypesTiers.client,
        documentCode: ctx.tickets.first.code,
        produitCode: ctx.lait.code,
        quantite: 1,
      );
      expect(r.date.isAfter(z.fin), isTrue);
      expect(r.caisseCode, 'CIS0000');
      expect((await retours.annuler(r.code, motif: 'Erreur')).actif, isFalse, reason: 'période du retour ouverte');
      await expectLater(
        achats.annuler(a.code, motif: 'Erreur'),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.periodeCloturee)),
      );
      await ctx.sessions.fermer(montantCompte: 0);
      // Une vente postérieure à la clôture reste annulable.
      await ctx.journee(1);
      final v = await ctx.ventes.annuler(ctx.tickets.last.code, motif: 'test');
      expect(v.statut, StatutsVente.annulee);
    });
  });
}
