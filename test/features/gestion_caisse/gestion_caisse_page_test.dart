import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/domain/models/caisse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle).last, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Gestion de caisse', () {
    testWidgets('caisse Compte sans magasin, apport, dépense, transfert TRF (2 mouvements)', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/gestion-caisse', taille: const Size(1400, 900));
      expect(find.text('Caisse principale'), findsOneWidget);
      // Nouvelle caisse de type Compte, sans magasin.
      await clic(tester, find.text('Nouvelle caisse'));
      await tester.enterText(_champ('Nom'), 'Compte BNA');
      await tester.pump();
      await clic(tester, find.text('Physique').last);
      await clic(tester, find.text('Compte').last);
      await clic(tester, find.text('Enregistrer'));
      expect(find.text('Compte BNA'), findsOneWidget);
      expect(find.text('CIS0001'), findsOneWidget);
      expect(find.text('Sans magasin'), findsOneWidget);
      // Apport puis dépense sur la caisse principale.
      await clic(tester, find.text('Mouvements'));
      expect(find.text('Aucun mouvement.'), findsOneWidget);
      await clic(tester, find.text('Apport'));
      await tester.enterText(_champ('Montant'), '5000');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      await clic(tester, find.text('Dépense'));
      await tester.enterText(_champ('Montant'), '1200');
      await tester.pump();
      await tester.enterText(_champ('Commentaire'), 'Loyer');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      expect(find.text('Loyer'), findsOneWidget);
      expect(find.text('Entrée'), findsOneWidget);
      expect(find.text('Sortie'), findsOneWidget);
      // Transfert TRF vers le compte.
      await clic(tester, find.text('Transferts entre caisses'));
      await clic(tester, find.text('Nouveau transfert'));
      await tester.enterText(_champ('Montant (DA)'), '3000');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      expect(find.textContaining('TRF0001'), findsWidgets);
      await clic(tester, find.text('OK'));
      expect(find.text('TRF0001'), findsOneWidget);
      final repo = CaisseRepository(c.read(appDatabaseProvider).db);
      expect((await repo.mouvements(referenceType: 'transfert_caisse', referenceCode: 'TRF0001')).length, 2);
      expect((await repo.solde('CIS0000')).especes, 800);
      expect((await repo.solde('CIS0001')).especes, 3000);
      // Les soldes s'affichent dans l'onglet Caisses.
      await clic(tester, find.text('Caisses'));
      expect(find.textContaining('3 000'), findsWidgets);
      // Solde insuffisant → message d'erreur.
      await clic(tester, find.text('Transferts entre caisses'));
      await clic(tester, find.text('Nouveau transfert'));
      await tester.enterText(_champ('Montant (DA)'), '99999');
      await tester.pump();
      await clic(tester, find.text('Valider'));
      expect(find.text('Solde insuffisant dans la caisse source.'), findsOneWidget);
      await clic(tester, find.text('OK'));
      expect(
        (await CaisseService(c.read(appDatabaseProvider).db, utilisateurCode: 'USR0000').caisses()).last.type,
        TypesCaisse.compte,
      );
    });
  });
}
