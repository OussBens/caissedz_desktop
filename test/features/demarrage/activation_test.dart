import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/compte_bens/compte_bens_pages.dart';
import 'package:caissedz_desktop/features/compte_bens/ecran_compte.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:caissedz_desktop/features/offres/offres_page.dart';
import 'package:caissedz_desktop/features/utilisateurs/utilisateurs_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  const grand = Size(1440, 900);

  Future<void> saisirCle(WidgetTester tester, String cle) async {
    await tester.enterText(find.byKey(const ValueKey('cle_activation')), cle);
    await tester.pumpAndSettle();
  }

  group('Premier lancement : les formules', () {
    testWidgets('application vierge : trois formules, chacune avec 14 jours d’essai', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      expect(find.byType(OffresPage), findsOneWidget);
      expect(find.text('Choisissez votre formule'), findsOneWidget);
      for (final code in ['DSK-BASIC', 'DSK-ADV', 'DSK-ULTRA']) {
        expect(find.byKey(ValueKey('formule_$code')), findsOneWidget);
      }
      expect(find.text('14 jours d\'essai gratuit'), findsNWidgets(3));
      expect(find.text('Essayer 14 jours'), findsNWidgets(3));
    });

    testWidgets('choisir une formule ouvre la création du compte pour celle-ci', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      await clic(tester, find.byKey(const ValueKey('choisir_DSK-ULTRA')));
      expect(find.byType(InscriptionPage), findsOneWidget);
      final formule = find.byKey(const ValueKey('inscription_formule'));
      expect(find.descendant(of: formule, matching: find.text('Formule Ultra')), findsOneWidget);
      expect(find.descendant(of: formule, matching: find.text('14 jours d\'essai gratuit')), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('inscription_nom')), 'Karim Haddad');
      await tester.enterText(find.byKey(const ValueKey('inscription_telephone')), '12');
      await clic(tester, find.byKey(const ValueKey('inscription_creer')));
      expect(find.text('Numéro invalide : 10 chiffres commençant par 05, 06 ou 07.'), findsOneWidget);
      expect(find.text('Le mot de passe fait 8 caractères au moins.'), findsOneWidget);
    });

    testWidgets('un clic sur une formule la sélectionne ; elle reste choisie au retour de l’inscription', (
      tester,
    ) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      Icon coche(String code) => tester.widget<Icon>(find.byKey(ValueKey('formule_coche_$code')));
      expect(coche('DSK-ADV').icon, LucideIcons.circleCheck, reason: 'Avancé par défaut');
      expect(coche('DSK-BASIC').icon, LucideIcons.circle);

      await clic(tester, find.byKey(const ValueKey('formule_DSK-BASIC')));
      expect(c.read(offreChoisieProvider), 'DSK-BASIC');
      expect(coche('DSK-BASIC').icon, LucideIcons.circleCheck);
      expect(coche('DSK-ADV').icon, LucideIcons.circle);

      // Mauvais choix : « Changer de formule » ramène aux offres, la formule choisie est cochée.
      await clic(tester, find.byKey(const ValueKey('choisir_DSK-ULTRA')));
      expect(find.byType(InscriptionPage), findsOneWidget);
      await clic(tester, find.text('Changer de formule'));
      expect(find.byType(OffresPage), findsOneWidget);
      expect(coche('DSK-ULTRA').icon, LucideIcons.circleCheck);
    });

    testWidgets('chaque formule ne montre que ce qu’elle a (Desktop — Plans & Pricing)', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      Finder dans(String code, String texte) =>
          find.descendant(of: find.byKey(ValueKey('formule_$code')), matching: find.text(texte));

      // Basic : le socle, 1 magasin, 1 caisse ; rien d'Advanced ni d'Ultra.
      expect(dans('DSK-BASIC', 'Caisse : ventes, scan, tickets, multi-paniers'), findsOneWidget);
      expect(dans('DSK-BASIC', 'Gestion de caisse, clôtures et coffre'), findsOneWidget);
      expect(dans('DSK-BASIC', '1 magasin'), findsOneWidget);
      expect(dans('DSK-BASIC', '1 caisse'), findsOneWidget);
      expect(dans('DSK-BASIC', 'Devis et proformas'), findsNothing);
      expect(dans('DSK-BASIC', 'Transferts entre magasins'), findsNothing);

      // Advanced : « Tout Basic, plus : » devis, commandes, achats, besoins ; 5 caisses.
      expect(dans('DSK-ADV', 'Tout Basic, plus :'), findsOneWidget);
      for (final a in [
        'Devis et proformas',
        'Commandes clients et bons de livraison',
        'Commandes fournisseurs (réception partielle)',
        'Listes de besoins',
        '1 magasin',
        '5 caisses',
      ]) {
        expect(dans('DSK-ADV', a), findsOneWidget, reason: a);
      }
      expect(dans('DSK-ADV', 'Multi-magasin (stock par magasin)'), findsNothing);

      // Ultra : « Tout Advanced, plus : » multi-magasin, transferts, tous les modules ; 15 / 15.
      expect(dans('DSK-ULTRA', 'Tout Avancé, plus :'), findsOneWidget);
      for (final a in [
        'Multi-magasin (stock par magasin)',
        'Transferts entre magasins',
        'Tous les modules',
        '15 magasins',
        '15 caisses',
      ]) {
        expect(dans('DSK-ULTRA', a), findsOneWidget, reason: a);
      }
    });

    test('paliers : caisses et permissions proposées', () {
      expect([for (final n in NiveauLicence.values) (n.magasins, n.caisses)], [(1, 1), (1, 5), (15, 15)]);
      expect(NiveauLicence.basic.transfertsCaisse, isFalse);
      expect(NiveauLicence.avance.transfertsCaisse, isTrue);
      expect(permissionIncluse(Permission.gererTransfertsCaisse, NiveauLicence.basic), isFalse);
      expect(permissionIncluse(Permission.changerCaisseMagasin, NiveauLicence.basic), isFalse);
      expect(permissionIncluse(Permission.changerCaisseMagasin, NiveauLicence.avance), isTrue);
      expect(permissionIncluse(Permission.voirStockTousMagasins, NiveauLicence.avance), isFalse);
      expect(permissionIncluse(Permission.voirStockTousMagasins, NiveauLicence.ultra), isTrue);
      expect(permissionIncluse(Permission.voirMarge, NiveauLicence.basic), isTrue);
    });

    testWidgets('le numéro du compte : 10 chiffres au plus, chiffres seulement', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand, routeInitiale: InscriptionPage.route);
      final champ = find.byKey(const ValueKey('inscription_telephone'));
      await tester.enterText(find.descendant(of: champ, matching: find.byType(TextField)), '05a55 12-34 56 789');
      await tester.pumpAndSettle();
      final saisie = tester.widget<TextField>(find.descendant(of: champ, matching: find.byType(TextField)));
      expect(saisie.controller!.text, '0555123456');
      expect(telephoneValide('0555123456'), isTrue);
      expect(telephoneValide('0455123456'), isFalse);
      expect(telephoneValide('055512345'), isFalse);
      expect(telephoneValide('+213555123456'), isFalse);
    });

    testWidgets('« Se connecter » ouvre la connexion au compte, avec Mot de passe oublié', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      await clic(tester, find.byKey(const ValueKey('offres_se_connecter')));
      expect(find.byType(ConnexionComptePage), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('compte_oubli')));
      expect(find.byType(MotDePasseOubliePage), findsOneWidget);
    });

    testWidgets('la connexion locale renvoie aux formules tant qu’aucune licence n’est valable', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      c.read(routerProvider).go(ConnexionPage.route);
      await tester.pumpAndSettle();
      expect(find.byType(OffresPage), findsOneWidget);
    });

    testWidgets('arabe : les formules en RTL', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, locale: const Locale('ar'), taille: grand);
      expect(find.text('اختر باقتك'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(OffresPage))), TextDirection.rtl);
    });
  });

  group('Activation par clé (secours)', () {
    testWidgets('le code du poste affiché ; clé vide, d’un autre poste ou invalide : refusée', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      await clic(tester, find.byKey(const ValueKey('offres_cle')));
      expect(find.byType(ActivationPage), findsOneWidget);
      expect(find.text(codePosteTest()), findsOneWidget);
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.text('Collez la clé reçue.'), findsOneWidget);
      await saisirCle(tester, await cleTest(NiveauLicence.avance, poste: 'AUTRE-POSTE'));
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.text('Cette clé est pour un autre poste. Envoyez-nous le code ci-dessus.'), findsOneWidget);
      // La forme de l'ancienne clé (64 hexadécimaux) n'active rien.
      await saisirCle(tester, 'f' * 64);
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.text("Clé invalide. Vérifiez qu'elle a été copiée en entier."), findsOneWidget);
    });

    testWidgets('clé Avancé valable sans compte BENS : activée, puis la création du compte', (tester) async {
      final c = await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      await clic(tester, find.byKey(const ValueKey('offres_cle')));
      await saisirCle(tester, await cleTest(NiveauLicence.avance));
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.text('Application activée'), findsOneWidget);
      await clic(tester, find.text('Continuer'));
      expect(c.read(licenceProvider).niveau, NiveauLicence.avance);
      expect(c.read(licenceProvider).essai, isFalse);
      expect(c.read(licenceProvider).expireLe, isNull);
      // Pas de compte admin / admin : l'administrateur prendra le mot de passe du compte créé.
      expect(find.byType(InscriptionPage), findsOneWidget);
      final formule = find.byKey(const ValueKey('inscription_formule'));
      expect(find.descendant(of: formule, matching: find.text('Formule Avancé')), findsOneWidget);
    });

    testWidgets('clé expirée : refusée avec sa date', (tester) async {
      await pumpApp(tester, etat: EtatApp.vierge, taille: grand);
      await clic(tester, find.byKey(const ValueKey('offres_cle')));
      await saisirCle(tester, await cleTest(NiveauLicence.basic, fin: DateTime.utc(2026, 1, 31)));
      await clic(tester, find.byKey(const ValueKey('bouton_activer')));
      expect(find.textContaining('Votre licence a expiré le'), findsOneWidget);
    });
  });
}
