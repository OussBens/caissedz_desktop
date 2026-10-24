import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/domain/models/licence.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/compte_bens/compte_bens_pages.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:caissedz_desktop/features/offres/offres_page.dart';
import 'package:caissedz_desktop/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  group('Connexion', () {
    testWidgets('mauvais mot de passe, connexion de l’administrateur (Rester connecté), puis déconnexion', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.text('Choisissez votre compte'), findsOneWidget);
      await choisirCompte(tester, 'faux');
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('connexion_mot_de_passe')), motDePasseAdmin);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
      expect(routeCourante(c), '/caisse');
      expect(find.text('Administrateur'), findsWidgets);
      expect(find.byKey(const ValueKey('bandeau_essai')), findsNothing);

      final parametres = c.read(parametresAppRepositoryProvider);
      expect(await parametres.lire(SessionNotifier.cleSessionMemorisee), 'USR0000');

      await clic(tester, find.byKey(const ValueKey('bouton_deconnexion')));
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
      expect(await parametres.lire(SessionNotifier.cleSessionMemorisee), anyOf(isNull, isEmpty));
      // Déconnecté : le compte est proposé, on n'a qu'à le cliquer.
      expect(find.byKey(const ValueKey('compte_$identifiantAdmin')), findsOneWidget);
    });

    testWidgets('comptes du poste : choisir, changer, ou « Autre compte » avec l’identifiant', (tester) async {
      await pumpApp(tester, etat: EtatApp.configuree);
      await clic(tester, find.byKey(const ValueKey('compte_$identifiantAdmin')));
      expect(find.byKey(const ValueKey('connexion_identifiant')), findsNothing, reason: 'le compte est choisi');
      await clic(tester, find.byKey(const ValueKey('connexion_changer_compte')));
      expect(find.text('Choisissez votre compte'), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('compte_autre')));
      await tester.enterText(find.byKey(const ValueKey('connexion_identifiant')), identifiantAdmin);
      await tester.enterText(find.byKey(const ValueKey('connexion_mot_de_passe')), motDePasseAdmin);
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('le numéro du compte BENS désigne l’administrateur, un autre numéro non', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      final auth = c.read(authServiceProvider);
      final s = await auth.connecter('0555 11 22 33', motDePasseAdmin, telephoneCompte: '+213555112233');
      expect(s.utilisateur.identifiant, identifiantAdmin);
      await expectLater(
        auth.connecter('0555 99 99 99', motDePasseAdmin, telephoneCompte: '+213555112233'),
        throwsA(isA<ConnexionException>()),
      );
      await expectLater(
        auth.connecter('0555 11 22 33', motDePasseAdmin),
        throwsA(isA<ConnexionException>()),
        reason: 'sans compte BENS sur ce poste',
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Rester connecté : la session mémorisée est reprise au démarrage', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      final session = c.read(sessionProvider.notifier);
      await session.connecter(identifiantAdmin, motDePasseAdmin, resterConnecte: true);
      await tester.pumpAndSettle();
      c.invalidate(sessionProvider);
      expect(c.read(sessionProvider), isNull);
      expect(await c.read(sessionProvider.notifier).reprendre(), isTrue);
      expect(c.read(sessionProvider)!.utilisateur.identifiant, identifiantAdmin);
      await tester.pumpAndSettle();
    });

    testWidgets('sans Rester connecté : rien n’est mémorisé', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree);
      await c.read(sessionProvider.notifier).connecter(identifiantAdmin, motDePasseAdmin);
      await tester.pumpAndSettle();
      c.invalidate(sessionProvider);
      expect(await c.read(sessionProvider.notifier).reprendre(), isFalse);
      await tester.pumpAndSettle();
    });

    testWidgets('essai en cours : l’encart de la connexion et le bandeau du shell, vers les formules', (tester) async {
      await pumpApp(tester, etat: EtatApp.essai);
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.byKey(const ValueKey('encart_essai')), findsOneWidget);
      expect(find.textContaining('Essai Avancé'), findsWidgets);
      await choisirCompte(tester, motDePasseAdmin);
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const ValueKey('bandeau_essai')), findsOneWidget);
      await clic(tester, find.text('Choisir une formule'));
      expect(find.byType(OffresPage), findsOneWidget);
    });

    testWidgets('essai terminé : la connexion s’ouvre en lecture seule, sur le tableau de bord', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.lectureSeule);
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.byKey(const ValueKey('encart_lecture_seule')), findsOneWidget);
      await choisirCompte(tester, motDePasseAdmin);
      await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
      expect(find.byType(AppShell), findsOneWidget);
      expect(routeCourante(c), '/tableau-de-bord');
    });

    testWidgets('sans licence valable : la connexion est refusée', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      expect(find.byType(OffresPage), findsOneWidget);
      await expectLater(
        c.read(sessionProvider.notifier).connecter(identifiantAdmin, motDePasseAdmin),
        throwsA(isA<ConnexionException>()),
      );
      expect(c.read(sessionProvider), isNull);
    });

    testWidgets('« Voir les formules » ouvre les offres depuis la connexion, « Fermer » y revient', (tester) async {
      await pumpApp(tester, etat: EtatApp.configuree, taille: const Size(1440, 900));
      await clic(tester, find.byKey(const ValueKey('connexion_offres')));
      expect(find.byType(OffresPage), findsOneWidget);
      await clic(tester, find.text('Fermer'));
      expect(find.byType(ConnexionPage), findsOneWidget);
    });

    testWidgets('« Mot de passe oublié » (compte BENS) ouvre la réinitialisation avec le numéro du compte', (
      tester,
    ) async {
      final c = await pumpApp(tester, etat: EtatApp.configuree, taille: const Size(1440, 900));
      await LicenceRepository(c.read(appDatabaseProvider).db)
          .enregistrerCompte(const CompteBens(telephone: '+213555112233'), 'jeton');
      await c.read(licenceProvider.notifier).charger();
      await tester.pumpAndSettle();
      await clic(tester, find.byKey(const ValueKey('compte_admin')));
      await clic(tester, find.byKey(const ValueKey('connexion_oubli')));
      expect(find.byType(MotDePasseOubliePage), findsOneWidget);
      final champ = find.byKey(const ValueKey('oubli_telephone'));
      final saisie = tester.widget<TextField>(find.descendant(of: champ, matching: find.byType(TextField)));
      expect(saisie.controller!.text, '0555112233');
    });
    });

  group('Compte BENS : l’administrateur prend son mot de passe (pas de admin / admin)', () {
    testWidgets('essai refusé, formule payée ensuite : l’administrateur a déjà le mot de passe du compte', (
      tester,
    ) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      final auth = c.read(authServiceProvider);
      await expectLater(auth.connecter(identifiantAdmin, 'admin'), throwsA(isA<ConnexionException>()));

      // Inscription sans essai (déjà utilisé sur ce poste) : pas de licence, les formules suivent.
      expect(await c.read(sessionProvider.notifier).apresCompteBens(nom: 'Karim', motDePasse: 'secret BENS 1'), isFalse);
      expect(c.read(sessionProvider), isNull);

      // Payé auprès de BENS : la licence arrive (Actualiser), puis la connexion avec le compte.
      await c.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.basic));
      await expectLater(
        c.read(sessionProvider.notifier).connecter(identifiantAdmin, 'admin'),
        throwsA(isA<ConnexionException>()),
      );
      final s = await c.read(sessionProvider.notifier).connecter(identifiantAdmin, 'secret BENS 1');
      expect((s.estAdmin, s.utilisateur.nom), (true, 'Karim'));
      await tester.pumpAndSettle();
    });

    testWidgets('licence valable : la session de l’administrateur s’ouvre tout de suite', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge);
      await c.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.basic));
      expect(await c.read(sessionProvider.notifier).apresCompteBens(nom: '', motDePasse: 'secret BENS 1'), isTrue);
      expect(c.read(sessionProvider)!.estAdmin, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('aucun administrateur avec mot de passe : la connexion propose de créer le compte BENS', (
      tester,
    ) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge, taille: const Size(1440, 900));
      await c.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.basic));
      c.read(routerProvider).go(ConnexionPage.route);
      await tester.pumpAndSettle();
      expect(find.byType(ConnexionPage), findsOneWidget);
      expect(find.byKey(const ValueKey('compte_$identifiantAdmin')), findsNothing);
      expect(find.byKey(const ValueKey('encart_sans_admin')), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('connexion_creer_compte')));
      expect(find.byType(InscriptionPage), findsOneWidget);
    });

    testWidgets('administrateur configuré : pas d’encart', (tester) async {
      await pumpApp(tester, etat: EtatApp.configuree);
      expect(find.byKey(const ValueKey('encart_sans_admin')), findsNothing);
    });
});
}
