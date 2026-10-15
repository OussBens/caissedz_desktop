import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/cloture_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
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
    test('clôtures Z chaînées, totaux, session ouverte refusée, rien à clôturer', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      final clotures = ClotureService(base.db, utilisateurCode: 'USR0000');
      await expectLater(
        clotures.cloturer(),
        throwsA(isA<ClotureException>().having((e) => e.erreur, 'e', ErreurCloture.rienACloturer)),
      );
      await ctx.journee(3);
      final apercu = await clotures.apercu();
      expect(apercu.nbVentes, 3);
      expect(apercu.totalVentes, 300);
      final z1 = await clotures.cloturer();
      expect(z1.code, 'CLZ0001');
      expect(z1.hashPrecedent, Scellement.genese);
      expect(z1.nbVentes, 3);
      expect(z1.totalEncaissements, 300);
      expect(z1.totalDecaissements, 300); // retrait de fermeture
      expect(z1.encaissementsParMode['Espèces'], 300);
      expect(z1.derniereVente, 'VTE0003');
      expect(z1.hashDerniereVente, ctx.tickets.last.hash);
      expect(z1.soldesCaisses['CIS0000'], 0);
      expect(z1.hash, Scellement.hacher(z1.versCanonique(), Scellement.genese));
      // Session ouverte → refus.
      final s = await ctx.sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      await ctx.ventes.encaisser(
        const Panier(id: 9)
            .ajouter(PanierLigne(produit: ctx.lait, quantite: 2, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Carte', montant: 200)),
        session: s,
        magasinCode: 'MAG0000',
      );
      await expectLater(
        clotures.cloturer(),
        throwsA(isA<ClotureException>().having((e) => e.erreur, 'e', ErreurCloture.sessionOuverte)),
      );
      await ctx.sessions.fermer(montantCompte: 0);
      final z2 = await clotures.cloturer();
      expect(z2.code, 'CLZ0002');
      expect(z2.hashPrecedent, z1.hash);
      expect(z2.debut, z1.fin);
      expect(z2.nbVentes, 1);
      expect(z2.totalVentes, 200);
      expect(z2.encaissementsParMode, {'Carte': 200});
      expect(await clotures.verifierChaine(), isNull);
      expect((await clotures.clotures()).map((c) => c.code), ['CLZ0002', 'CLZ0001']);
    });

    test('immuabilité : UPDATE et DELETE refusés par le moteur ; altération détectée', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      await ctx.journee(1);
      final clotures = ClotureService(base.db, utilisateurCode: 'USR0000');
      final z = await clotures.cloturer();
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

    test('période clôturée : annulation de vente, retour et annulation d’achat refusés', () async {
      final base = await ouvrirBaseDeTest();
      final ctx = _Ctx(base.db);
      await ctx.preparer();
      await ctx.journee(2);
      final achats = AchatService(base.db, utilisateurCode: 'USR0000', periodeCloturee: ClotureService.periodeCloturee);
      final a = await achats.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: ctx.lait.code, quantite: 1, prixAchat: 80)],
      );
      await ClotureService(base.db, utilisateurCode: 'USR0000').cloturer();
      await expectLater(
        ctx.ventes.annuler(ctx.tickets.first.code, motif: 'test'),
        throwsA(isA<VenteException>().having((e) => e.erreur, 'e', ErreurVente.periodeCloturee)),
      );
      final retours = RetourService(
        base.db,
        utilisateurCode: 'USR0000',
        periodeCloturee: ClotureService.periodeCloturee,
      );
      await expectLater(
        retours.creer(
          venteCode: ctx.tickets.first.code,
          lignes: [DemandeRetourLigne(produitCode: ctx.lait.code, quantite: 1)],
        ),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.periodeCloturee)),
      );
      await expectLater(
        achats.annuler(a.code),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.periodeCloturee)),
      );
      // Une vente postérieure à la clôture reste annulable.
      await ctx.journee(1);
      final v = await ctx.ventes.annuler(ctx.tickets.last.code, motif: 'test');
      expect(v.statut, StatutsVente.annulee);
    });
  });
}
