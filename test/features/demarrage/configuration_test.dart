import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/data/boutique_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/models/parametres_paiement.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  const dialog = ValueKey('dialog_configuration');
  const suivant = ValueKey('config_suivant');

  Future<void> connecterAdmin(WidgetTester tester) async {
    await choisirCompte(tester, motDePasseAdmin);
    await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
  }

  group('Configuration initiale (4 étapes, après la 1ʳᵉ connexion admin)', () {
    testWidgets('parcours complet puis la Caisse', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.activeeBasic, sequence: true);
      await connecterAdmin(tester);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(dialog), findsOneWidget);
      expect(find.text('Bienvenue dans CaisseDZ'), findsOneWidget);

      // Étape 1 : langue, devise, décimales
      await clic(tester, find.byKey(suivant));
      // Étape 2 : nom obligatoire (Suivant désactivé tant qu'il est vide)
      await tester.enterText(find.byKey(const ValueKey('config_nom')), '');
      await tester.pump();
      await clic(tester, find.byKey(suivant));
      expect(find.byKey(const ValueKey('config_nom')), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('config_nom')), 'Superette El Baraka');
      await tester.pump();
      await clic(tester, find.byKey(suivant));
      // Étape 3 : paiements
      expect(find.byKey(const ValueKey('paiement_Chèque')), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('paiement_Chèque')));
      await clic(tester, find.byKey(suivant));
      // Étape 4 : marge hors limites puis valide
      await tester.enterText(find.byKey(const ValueKey('config_marge')), '2000');
      await clic(tester, find.byKey(const ValueKey('config_terminer')));
      expect(find.text('Valeur entre 0 et 1000.'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('config_marge')), '30');
      await clic(tester, find.byKey(const ValueKey('config_terminer')));

      expect(find.byKey(dialog), findsNothing);
      expect(c.read(configurationTermineeProvider), isTrue);
      // Plus de menu des modules par-dessus : on arrive sur la Caisse.
      expect(find.byKey(const ValueKey('menu_modules')), findsNothing);
      expect(routeCourante(c), '/caisse');

      final db = c.read(appDatabaseProvider).db;
      expect((await BoutiqueRepository(db).lire())!.nom, 'Superette El Baraka');
      final parametres = ParametreRepository(db);
      expect(ParametresVente.depuisCles(await parametres.lirePlusieurs(ParametresVente.cles)).margeDefautPct, 30);
      final paiements = ParametresPaiement.depuisCles(await parametres.lirePlusieurs(ParametresPaiement.cles));
      expect(paiements.cheque, isTrue);
      expect(paiements.carte, isTrue);
    });

    testWidgets('« Plus tard » : rien n’est enregistré, la Caisse s’ouvre', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.activeeBasic, sequence: true);
      await connecterAdmin(tester);
      expect(find.byKey(dialog), findsOneWidget);
      await clic(tester, find.text('Plus tard'));
      expect(find.byKey(dialog), findsNothing);
      expect(c.read(configurationTermineeProvider), isFalse);
      // Plus de menu des modules par-dessus : on arrive sur la Caisse.
      expect(find.byKey(const ValueKey('menu_modules')), findsNothing);
      expect(routeCourante(c), '/caisse');
    });

    testWidgets('configuration déjà faite : pas de dialogue, la Caisse directement', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree, sequence: true);
      await connecterAdmin(tester);
      expect(find.byKey(dialog), findsNothing);
      // Plus de menu des modules par-dessus : on arrive sur la Caisse.
      expect(find.byKey(const ValueKey('menu_modules')), findsNothing);
      expect(routeCourante(c), '/caisse');
    });
  });
}
