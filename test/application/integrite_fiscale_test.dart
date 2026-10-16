import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/cloture_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_fiscal.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/journal_fiscal_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/caisse.dart';
import 'package:caissedz_desktop/domain/models/journal_fiscal.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  test('journal fiscal chaîné, immuabilité des tickets et du stock, sceau v2', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final p = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      const Produit(
        code: '',
        designation: 'Café',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 60,
        prixVente: 100,
      ),
    );
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: 50);
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    Future<String> vendre(double q) async => (await ventes.encaisser(
      const Panier(id: 1)
          .ajouter(PanierLigne(produit: p, quantite: q, prixUnitaire: 100))
          .ajouterPaiement(Paiement(mode: 'Espèces', montant: q * 100)),
      session: session,
      magasinCode: 'MAG0000',
    )).code;

    final v1 = await vendre(2);
    final v2 = await vendre(3);
    final lu = (await VenteRepository(db).vente(v1))!;
    expect(lu.versionScellement, 2);
    expect(lu.versCanonique()['v'], 2);
    expect(await ventes.verifierChaine(), isNull);

    // Colonnes scellées, lignes, paiements et journal de stock : refusés par la base elle-même.
    await expectLater(db.update('vente', {'total_net': 1}, where: 'code = ?', whereArgs: [v1]), throwsA(anything));
    await expectLater(
      db.update('vente_ligne', {'total': 1}, where: 'vente_code = ?', whereArgs: [v1]),
      throwsA(anything),
    );
    await expectLater(db.delete('vente_paiement', where: 'vente_code = ?', whereArgs: [v1]), throwsA(anything));
    await expectLater(db.delete('vente', where: 'code = ?', whereArgs: [v1]), throwsA(anything));
    await expectLater(db.update('mouvement_stock', {'quantite': 99}), throwsA(anything));
    await expectLater(db.delete('mouvement_stock'), throwsA(anything));
    // Passage à « Annulée » sans événement fiscal : refusé.
    await expectLater(db.update('vente', {'statut': 'Annulée'}, where: 'code = ?', whereArgs: [v2]), throwsA(anything));

    await ventes.annuler(v2, motif: 'Erreur de saisie');
    await RetourService(
      db,
      utilisateurCode: 'USR0000',
    ).creer(type: TypesTiers.client, documentCode: v1, produitCode: p.code, quantite: 1, ligneOrdre: 0);
    await SessionCaisseService(db, utilisateurCode: 'USR0000').fermer(montantCompte: 400);
    await ClotureService(db, utilisateurCode: 'USR0000').cloturer(caisseCode: 'CIS0000');

    final journal = JournalFiscalRepository(db);
    final evts = await journal.evenements();
    expect(evts.map((e) => e.type).toList(), [
      TypesEvenementFiscal.vente,
      TypesEvenementFiscal.vente,
      TypesEvenementFiscal.annulationVente,
      TypesEvenementFiscal.retour,
      TypesEvenementFiscal.cloture,
    ]);
    expect(evts[2].montant, -300);
    expect(await journal.verifier(), isNull);
    await expectLater(db.update('journal_fiscal', {'montant': 0}), throwsA(anything));
    await expectLater(db.delete('journal_fiscal'), throwsA(anything));

    // Altération hors application (déclencheurs retirés) : détectée par la vérification.
    await db.execute('DROP TRIGGER journal_fiscal_sans_modification');
    await db.update('journal_fiscal', {'montant': 0}, where: 'id = ?', whereArgs: [evts[1].id]);
    await db.update('journal_fiscal', {'contenu': '{}'}, where: 'id = ?', whereArgs: [evts[1].id]);
    expect(await journal.verifier(), evts[1].id);

    // L'export fiscal d'une période qui ne commence pas à la genèse reste vérifiable.
    final export = await ExportFiscal(db).generer(
      debut: DateTime.now().subtract(const Duration(days: 1)),
      fin: DateTime.now().add(const Duration(days: 1)),
      utilisateurCode: 'USR0000',
    );
    final verif = ExportFiscal.verifier(export);
    expect(verif.chaineVentesOk, isTrue);
    expect(verif.nbEvenements, 5);
    expect(verif.chaineJournalOk, isFalse, reason: 'événement altéré');
  });

  test('coffre : dépôt à la fermeture, fond pris à l\'ouverture, Z sans mouvements techniques', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final caisses = CaisseRepository(db);
    expect(await caisses.coffre(), 'CIS0001');
    final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
    await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 1000);
    // Coffre vide : rien n'est pris, le fond est un apport.
    expect((await caisses.solde('CIS0001')).total, 0);
    await sessions.fermer(montantCompte: 1000);
    expect((await caisses.solde('CIS0001')).parMode['Espèces'], 1000);
    expect((await caisses.solde('CIS0000')).total, 0);

    await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 600);
    expect((await caisses.solde('CIS0001')).parMode['Espèces'], 400);
    expect((await caisses.solde('CIS0000')).parMode['Espèces'], 600);
    await expectLater(
      SessionCaisseService(db, utilisateurCode: 'USR9999').ouvrir(caisseCode: 'CIS0001', fondInitial: 0),
      throwsA(isA<SessionException>()),
      reason: 'le coffre n\'ouvre pas de session',
    );
    await sessions.fermer(montantCompte: 600);

    final totaux = await caisses.totauxPeriode(DateTime(2000), DateTime.now().add(const Duration(minutes: 1)));
    expect(totaux.entrees, 0, reason: 'fond, retrait, écart et coffre exclus de la Z');
    expect(totaux.sorties, 0);
    final mvts = await caisses.mouvements(caisseCode: 'CIS0001');
    expect(mvts.every((m) => m.type == TypesMouvementCaisse.coffre), isTrue);
  });
}
