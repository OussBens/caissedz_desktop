import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/permissions_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

void main() {
  group('Utilisateurs (DS v2.2)', () {
    testWidgets('création d’un caissier : identifiant unique, jauge de force, rôle hors Admin, détail', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/utilisateurs', taille: _taille);
      expect(find.text('Utilisateurs'), findsWidgets);
      expect(find.text('Rôles'), findsWidgets);
      await ouvrirChiffres(tester);
      expect(find.text('Utilisateurs actifs'), findsOneWidget);
      expect(find.text('Administrateur'), findsWidgets);
      expect(find.text('@demo'), findsNothing, reason: 'compte de démonstration masqué');
      await clic(tester, _cle('usr_nouveau'));
      expect(find.text('USR0002'), findsNothing, reason: 'pas de champ Code à la création');
      expect(tester.widget<DsButton>(_cle('usr_enregistrer')).onPressed, isNull);
      await tester.enterText(_champ('usr_identifiant'), 'admin');
      await tester.pump();
      expect(find.text('Identifiant déjà utilisé'), findsOneWidget);
      await tester.enterText(_champ('usr_identifiant'), 'amina');
      await tester.enterText(_champ('usr_mdp'), 'abc');
      await tester.pump();
      expect(find.text('Très faible'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('usr_enregistrer')).onPressed, isNull, reason: 'force minimale 2');
      await tester.enterText(_champ('usr_mdp'), 'Amina2026');
      await tester.enterText(_champ('usr_prenom'), 'Amina');
      await tester.enterText(_champ('usr_nom'), 'Kaci');
      await tester.enterText(_champ('usr_telephone'), '0661 20 30 40');
      // Confirmation différente : enregistrement bloqué tant que les deux mots de passe ne concordent pas.
      await tester.enterText(_champ('usr_mdp_confirme'), 'Amina2025');
      await tester.pump();
      expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('usr_enregistrer')).onPressed, isNull, reason: 'confirmation différente');
      await tester.enterText(_champ('usr_mdp_confirme'), 'Amina2026');
      await tester.pump();
      expect(find.text('Bon'), findsOneWidget);
      // Le rôle Admin n'est pas proposé (admin unique, non assignable).
      final avant = find.text('Admin').evaluate().length;
      await clic(tester, _cle('usr_role'));
      expect(find.text('Admin').evaluate().length, avant);
      await clic(tester, find.text('Caissier').last);
      await clic(tester, _cle('usr_enregistrer'));
      expect(find.text('Utilisateur créé'), findsOneWidget);
      final db = c.read(appDatabaseProvider).db;
      final u = (await UtilisateurRepository(db).parCode('USR0002'))!;
      expect(u.roleCode, Roles.caissier);
      expect(await CaisseRepository(db).caissesUtilisateur('USR0002'), [
        'CIS0000',
      ], reason: 'première caisse par défaut');
      expect(await StockRepository(db).magasinsUtilisateur('USR0002'), ['MAG0000']);
      // Détail : informations, permissions du rôle.
      await doubleClic(tester, find.text('Amina Kaci').first);
      expect(find.text('@amina · USR0002'), findsOneWidget);
      expect(find.text('Permissions du rôle'), findsOneWidget);
      // Caisses et magasins attribués, le premier de chaque liste par défaut.
      expect(find.text('Caisses attribuées'), findsOneWidget);
      expect(find.text('Magasins attribués'), findsOneWidget);
      expect(find.text('Par défaut'), findsNWidgets(2));
      await clic(tester, find.text('Fermer').last);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('désactivation : administrateur principal bloqué ; réinitialisation du mot de passe', (tester) async {
      await pumpApp(tester, routeInitiale: '/utilisateurs', taille: _taille);
      await clic(tester, find.text('USR0000'));
      await clic(tester, _cle('usr_desactiver'));
      expect(find.text('Compte administrateur principal'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, _cle('usr_reinitialiser'));
      expect(find.text('Mot de passe réinitialisé'), findsOneWidget);
      expect(find.textContaining('Communiquez ce mot de passe temporaire à @admin'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('rôles : Admin non modifiable, nouveau rôle en 3 étapes, rôle désactivable', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/utilisateurs', taille: _taille);
      await clic(tester, find.text('Rôles').first);
      expect(find.text('ROL0000'), findsOneWidget);
      expect(find.text('Système'), findsOneWidget);
      await clic(tester, find.text('ROL0000'));
      await clic(tester, _cle('roles_modifier'));
      expect(find.text('Modification impossible'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.text('ROL0000'));
      // Assistant : nom unique, modules, permissions spéciales.
      await clic(tester, _cle('role_nouveau'));
      expect(find.text('ROL0003'), findsNothing, reason: 'pas de champ Code à la création');
      await tester.enterText(_champ('role_nom'), 'caissier');
      await tester.pump();
      expect(find.text('Ce nom de rôle existe déjà'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('role_suivant')).onPressed, isNull);
      await tester.enterText(_champ('role_nom'), 'Superviseur');
      await tester.pump();
      await clic(tester, _cle('role_suivant'));
      expect(find.textContaining('Modules accessibles'), findsOneWidget);
      await clic(tester, _cle('role_module_ventes'));
      await clic(tester, _cle('role_suivant'));
      await clic(tester, _cle('role_perm_annulerOperations'));
      await clic(tester, _cle('role_enregistrer'));
      expect(find.text('Rôle enregistré'), findsOneWidget);
      final r = (await PermissionsRepository(c.read(appDatabaseProvider).db).role('ROL0003'))!;
      expect(r.nom, 'Superviseur');
      expect(r.modules, {'tableau_bord', 'caisse', 'ventes'});
      expect(r.permissions, {Permission.annulerOperations});
      // Désactivation : Magasinier sans utilisateur.
      await clic(tester, find.text('ROL0002'));
      await clic(tester, _cle('roles_desactiver'));
      await clic(tester, find.text('Désactiver (1)'));
      expect(find.text('Rôles désactivés'), findsOneWidget);
      expect((await PermissionsRepository(c.read(appDatabaseProvider).db).role('ROL0002'))!.actif, isFalse);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('offre Basic : ni caisses ni magasins à choisir (une caisse, un magasin)', (tester) async {
      await pumpApp(tester, etat: EtatApp.connecteeAdminBasic, routeInitiale: '/utilisateurs', taille: _taille);
      await clic(tester, _cle('usr_nouveau'));
      expect(_cle('usr_caisses'), findsNothing);
      expect(_cle('usr_magasins'), findsNothing);
    });

    testWidgets('Ultra : caisses et magasins à choisir (plusieurs, le premier par défaut)', (tester) async {
      await pumpApp(tester, routeInitiale: '/utilisateurs', taille: _taille);
      await clic(tester, _cle('usr_nouveau'));
      expect(_cle('usr_caisses'), findsOneWidget);
      expect(_cle('usr_magasins'), findsOneWidget);
    });

    testWidgets('arabe : écran Utilisateurs en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/utilisateurs', locale: const Locale('ar'), taille: _taille);
      final bouton = _cle('usr_nouveau');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
