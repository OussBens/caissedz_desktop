import 'dart:typed_data';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_fiscal.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/clotures/clotures_page.dart';
import 'package:caissedz_desktop/features/gestion_caisse/gestion_caisse_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Future<SessionCaisseService> _journee(ProviderContainer c, {bool fermer = true}) async {
  final db = c.read(appDatabaseProvider).db;
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
  ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
  final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
  final s = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 500);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  for (var i = 0; i < 2; i++) {
    await ventes.encaisser(
      Panier(id: i)
          .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
          .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
      session: s,
      magasinCode: 'MAG0000',
    );
  }
  if (fermer) await sessions.fermer(montantCompte: 700);
  c.read(caisseVersionProvider.notifier).incrementer();
  return sessions;
}

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle).last, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Clôtures Z', () {
    testWidgets('session ouverte refusée, aperçu puis clôture scellée, détail, chaîne vérifiée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/clotures', taille: const Size(1400, 900));
      expect(find.text('Aucune clôture.'), findsOneWidget);
      final sessions = await _journee(c, fermer: false);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Clôturer (Z)'));
      await clic(tester, find.text('Sceller la clôture'));
      expect(find.text('Fermez toutes les sessions de caisse avant de clôturer.'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await sessions.fermer(montantCompte: 700);
      await clic(tester, find.text('Clôturer (Z)'));
      expect(find.text('Clôture Z — aperçu de la période'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // 2 ventes
      await clic(tester, find.text('Sceller la clôture'));
      expect(find.textContaining('Clôture CLZ0001 scellée'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect(find.text('CLZ0001'), findsWidgets);
      // Détail par menu contextuel.
      await tester.tap(find.text('CLZ0001').last, buttons: 2);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Détail de la clôture'));
      expect(find.text('Encaissements par mode'), findsOneWidget);
      expect(find.text('Soldes des caisses'), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      // Vérification de la chaîne.
      await clic(tester, find.text('Vérifier la chaîne'));
      expect(find.text('Chaîne des clôtures intacte.'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      // Rien de nouveau → refus.
      await clic(tester, find.text('Clôturer (Z)'));
      await clic(tester, find.text('Sceller la clôture'));
      expect(find.text('Rien à clôturer depuis la dernière clôture.'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect((await CaisseRepository(c.read(appDatabaseProvider).db).clotures()).length, 1);
    });

    testWidgets('export fiscal : archive enregistrée et vérifiée', (tester) async {
      Uint8List? ecrit;
      String? cheminEcrit;
      final c = await pumpApp(
        tester,
        routeInitiale: '/clotures',
        taille: const Size(1400, 900),
        overrides: [
          selecteurExportProvider.overrideWithValue((nom) async => '/exports/$nom'),
          ecrivainExportProvider.overrideWithValue((chemin, octets) async {
            cheminEcrit = chemin;
            ecrit = octets;
          }),
        ],
      );
      await _journee(c);
      await tester.pumpAndSettle();
      await clic(tester, find.text('Clôturer (Z)'));
      await clic(tester, find.text('Sceller la clôture'));
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.text('Export fiscal'));
      await tester.enterText(_champ('Du (jj/mm/aaaa)'), '01/01/2000');
      await tester.pump();
      await clic(tester, find.text("Générer l'archive"));
      expect(find.textContaining('Archive enregistrée'), findsOneWidget);
      expect(find.textContaining('2 ventes, 1 clôtures'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      expect(cheminEcrit, startsWith('/exports/export_fiscal_20000101_'));
      final verif = ExportFiscal.verifier(ecrit!);
      expect(verif.valide, isTrue);
      expect(verif.nbVentes, 2);
      expect(verif.nbClotures, 1);
      // Dates invalides.
      await clic(tester, find.text('Export fiscal'));
      await tester.enterText(_champ('Du (jj/mm/aaaa)'), '32/13/2000');
      await tester.pump();
      await clic(tester, find.text("Générer l'archive"));
      expect(find.text('Dates invalides.'), findsOneWidget);
    });
  });
}
