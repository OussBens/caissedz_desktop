import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/data/boutique_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/features/configuration/configuration_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

Finder _champ(String libelle) => find
    .descendant(
      of: find.ancestor(of: find.text(libelle), matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    )
    .first;

void main() {
  group('Configuration initiale (4 étapes)', () {
    testWidgets('parcours complet : validations, récapitulatif, enregistrement, puis connexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.activeeBasic);
      expect(find.byType(ConfigurationPage), findsOneWidget);
      expect(find.text('Étape 1 sur 4'), findsOneWidget);

      // Étape 1 : nom obligatoire
      await clic(tester, find.text('Suivant'));
      expect(find.text('Champ obligatoire'), findsOneWidget);
      await tester.enterText(_champ('Nom de la boutique'), 'Superette El Baraka');
      await tester.enterText(_champ('E-mail'), 'contact@baraka.dz');
      await clic(tester, find.text('Suivant'));
      expect(find.text('Étape 2 sur 4'), findsOneWidget);

      // Étape 2 : identifiant, mot de passe, confirmation
      await tester.enterText(_champ('Identifiant'), 'k');
      await tester.enterText(_champ('Mot de passe'), '12');
      await tester.enterText(_champ('Confirmer le mot de passe'), '13');
      await clic(tester, find.text('Suivant'));
      expect(find.text('3 à 32 caractères : lettres, chiffres, point, tiret, tiret bas.'), findsOneWidget);
      expect(find.text('Au moins 4 caractères.'), findsOneWidget);
      expect(find.text('Les mots de passe ne correspondent pas.'), findsOneWidget);
      await tester.enterText(_champ('Identifiant'), 'gerant');
      await tester.enterText(_champ('Nom affiché'), 'Karim');
      await tester.enterText(_champ('Mot de passe'), 'azerty');
      await tester.enterText(_champ('Confirmer le mot de passe'), 'azerty');
      await clic(tester, find.text('Suivant'));
      expect(find.text('Étape 3 sur 4'), findsOneWidget);

      // Étape 3 : marge
      await tester.enterText(_champ('Marge par défaut (%)'), '2000');
      await clic(tester, find.text('Suivant'));
      expect(find.text('Valeur entre 0 et 1000.'), findsOneWidget);
      await tester.enterText(_champ('Marge par défaut (%)'), '30');
      await tester.enterText(_champ("Seuil d'alerte de stock (global)"), '8');
      await clic(tester, find.text('Suivant'));
      expect(find.text('Étape 4 sur 4'), findsOneWidget);

      // Étape 4 : récapitulatif et retour possible
      expect(find.text('Superette El Baraka'), findsOneWidget);
      expect(find.text('30.0 %'), findsOneWidget);
      await clic(tester, find.text('Précédent'));
      expect(find.text('Étape 3 sur 4'), findsOneWidget);
      await clic(tester, find.text('Suivant'));
      await clic(tester, find.text('Terminer'));
      expect(find.textContaining('Configuration terminée'), findsOneWidget);
      await clic(tester, find.text('OK'));

      expect(c.read(configurationTermineeProvider), isTrue);
      expect(find.byType(ConnexionPage), findsOneWidget);
      final db = c.read(appDatabaseProvider).db;
      expect((await BoutiqueRepository(db).lire())!.email, 'contact@baraka.dz');
      final p = ParametresVente.depuisCles(
        await ParametreRepository(db).lirePlusieurs([ParametresVente.cleMarge, ParametresVente.cleSeuil]),
      );
      expect(p.margeDefautPct, 30);
      expect(p.seuilStockGlobal, 8);

      // Connexion avec le compte créé
      await tester.enterText(_champ('Identifiant'), 'gerant');
      await tester.enterText(_champ('Mot de passe'), 'azerty');
      await clic(tester, find.text('Se connecter'));
      expect(c.read(sessionProvider)?.utilisateur.nom, 'Karim');
      expect(find.text('Tableau de bord'), findsWidgets);
    });

    testWidgets('identifiant déjà pris (demo) : retour à l’étape 2 avec message', (tester) async {
      await pumpApp(tester, etat: EtatApp.demo);
      await tester.enterText(_champ('Nom de la boutique'), 'Test');
      await clic(tester, find.text('Suivant'));
      await tester.enterText(_champ('Identifiant'), 'demo');
      await tester.enterText(_champ('Mot de passe'), 'azerty');
      await tester.enterText(_champ('Confirmer le mot de passe'), 'azerty');
      await clic(tester, find.text('Suivant'));
      await clic(tester, find.text('Suivant'));
      await clic(tester, find.text('Terminer'));
      expect(find.text('Étape 2 sur 4'), findsOneWidget);
      expect(find.text('Cet identifiant est déjà utilisé.'), findsOneWidget);
    });
  });
}
