import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/configuration_initiale_service.dart';
import 'package:caissedz_desktop/application/licence_service.dart';
import 'package:caissedz_desktop/application/permission_service.dart';
import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:caissedz_desktop/core/db/migrations/v002_demarrage.dart';
import 'package:caissedz_desktop/core/licence/cle_activation.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/boutique_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/utilisateur.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

class _Machine implements MachineIdentifiant {
  const _Machine(this.id);
  final String id;
  @override
  Future<String> lire() async => id;
}

const _hachage = MotDePasse(iterations: 500);

ConfigurationInitiale _config({String identifiant = 'gerant', String mdp = 'azerty', double marge = 25}) =>
    ConfigurationInitiale(
      boutique: const Boutique(nom: 'Superette El Baraka', rc: '16/00-123456', email: 'contact@baraka.dz'),
      adminIdentifiant: identifiant,
      adminNom: 'Karim',
      adminMotDePasse: mdp,
      parametres: ParametresVente(margeDefautPct: marge, seuilStockGlobal: 10),
    );

void main() {
  group('Seed de la migration v2', () {
    test('éléments système, admin sans mot de passe, démo, rôles', () async {
      final base = await ouvrirBaseDeTest();
      for (final (table, code) in [
        ('magasin', 'MAG0000'),
        ('caisse', 'CIS0000'),
        ('client', 'CLN0000'),
        ('fournisseur', 'FOR0000'),
        ('categorie', 'CATE0000'),
        ('sous_categorie', 'SC0000'),
      ]) {
        final rows = await base.db.query(table, where: 'code = ? AND systeme = 1', whereArgs: [code]);
        expect(rows.length, 1, reason: '$table/$code');
      }
      final admin = await UtilisateurRepository(base.db).parCode(MigrationV002Demarrage.codeAdmin);
      expect(admin!.role, Roles.admin);
      expect(await UtilisateurRepository(base.db).empreinte(admin.code), isNull);
      final caisse = (await base.db.query('caisse', where: 'code = ?', whereArgs: ['CIS0000'])).first;
      expect(caisse['magasin_code'], 'MAG0000');
      final grille = await PermissionService(base.db).lireGrille();
      expect(grille.permissions[Roles.admin], Permission.values.toSet());
      expect(grille.permissions[Roles.caissier], {Permission.appliquerRemise});
      expect(grille.modules[Roles.magasinier], contains('stock'));
    });
  });

  group('LicenceService', () {
    test('active Basic / Avancé avec une clé liée à la machine, refuse le reste', () async {
      final base = await ouvrirBaseDeTest();
      final s = LicenceService(base.db, identifiant: const _Machine('POSTE-A'));
      expect((await s.lire()).estActivee, isFalse);
      await expectLater(
        s.activer('abc'),
        throwsA(isA<ActivationException>().having((e) => e.erreur, 'erreur', ErreurActivation.formatInvalide)),
      );
      await expectLater(
        s.activer('1' * 64),
        throwsA(isA<ActivationException>().having((e) => e.erreur, 'erreur', ErreurActivation.cleInconnue)),
      );
      await expectLater(
        s.activer(CleActivation.cleAttendue(NiveauLicence.basic, 'POSTE-B')),
        throwsA(isA<ActivationException>()),
      );
      final l = await s.activer(CleActivation.cleAttendue(NiveauLicence.basic, 'POSTE-A').toUpperCase());
      expect(l.niveau, NiveauLicence.basic);
      expect((await s.lire()).niveau, NiveauLicence.basic);
      expect((await s.lire()).demo, isFalse);
      final l2 = await s.activer(CleActivation.cleAttendue(NiveauLicence.avance, 'POSTE-A'));
      expect(l2.niveau, NiveauLicence.avance);
    });

    test('mode démo : licence Avancé sans clé, impossible par-dessus une vraie licence', () async {
      final base = await ouvrirBaseDeTest();
      final s = LicenceService(base.db, identifiant: const _Machine('P'));
      final d = await s.activerDemo();
      expect(d.demo, isTrue);
      expect(d.niveau, NiveauLicence.avance);
      await s.activer(CleActivation.cleAttendue(NiveauLicence.basic, 'P'));
      final apres = await s.activerDemo();
      expect(apres.demo, isFalse);
      expect(apres.niveau, NiveauLicence.basic);
    });
  });

  group('ConfigurationInitialeService', () {
    test('écrit boutique, admin, paramètres et marque la configuration terminée', () async {
      final base = await ouvrirBaseDeTest();
      final s = ConfigurationInitialeService(base.db, hachage: _hachage);
      expect(await s.estTerminee(), isFalse);
      await s.terminer(_config());
      expect(await s.estTerminee(), isTrue);
      expect((await BoutiqueRepository(base.db).lire())!.nom, 'Superette El Baraka');
      final admin = await UtilisateurRepository(base.db).parIdentifiant('gerant');
      expect(admin!.code, MigrationV002Demarrage.codeAdmin);
      expect(admin.nom, 'Karim');
      final p = ParametresVente.depuisCles(
        await ParametreRepository(base.db)
            .lirePlusieurs([ParametresVente.cleMarge, ParametresVente.cleSeuil, ParametresVente.cleDevise]),
      );
      expect(p.margeDefautPct, 25);
      expect(p.seuilStockGlobal, 10);
      expect(p.devise, 'DA');
    });

    test('transaction : un identifiant déjà pris n’écrit rien', () async {
      final base = await ouvrirBaseDeTest();
      final s = ConfigurationInitialeService(base.db, hachage: _hachage);
      await expectLater(
        s.terminer(_config(identifiant: 'demo')),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantPris)),
      );
      expect(await BoutiqueRepository(base.db).lire(), isNull);
      expect(await s.estTerminee(), isFalse);
      expect(await UtilisateurRepository(base.db).empreinte(MigrationV002Demarrage.codeAdmin), isNull);
    });

    test('validations : mot de passe court, marge hors limites', () async {
      final base = await ouvrirBaseDeTest();
      final s = ConfigurationInitialeService(base.db, hachage: _hachage);
      await expectLater(s.terminer(_config(mdp: '12')), throwsA(isA<CompteException>()));
      await expectLater(s.terminer(_config(marge: -1)), throwsArgumentError);
      expect(await s.estTerminee(), isFalse);
    });
  });

  group('AuthService', () {
    test('connexion de l’admin configuré, session avec tous les droits', () async {
      final base = await ouvrirBaseDeTest();
      await ConfigurationInitialeService(base.db, hachage: _hachage).terminer(_config());
      final auth = AuthService(base.db, hachage: _hachage);
      final session = await auth.connecter('GERANT', 'azerty');
      expect(session.utilisateur.identifiant, 'gerant');
      expect(session.estAdmin, isTrue);
      expect(session.modulesAutorises, isNull);
      expect(session.peutAcceder('zakat'), isTrue);
      expect(session.a(Permission.voirPrixAchat), isTrue);
      expect(session.demo, isFalse);
      await expectLater(
        auth.connecter('gerant', 'faux'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.identifiantsInvalides)),
      );
      await expectLater(auth.connecter('inconnu', 'x'), throwsA(isA<ConnexionException>()));
    });

    test('admin non configuré : mot de passe non défini', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await expectLater(
        auth.connecter('admin', ''),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.motDePasseNonDefini)),
      );
    });

    test('demo/demo disponible uniquement en mode démo', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await expectLater(
        auth.connecter('demo', 'demo'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.demoIndisponible)),
      );
      await LicenceService(base.db, identifiant: const _Machine('P')).activerDemo();
      final s = await auth.connecter('demo', 'demo');
      expect(s.demo, isTrue);
      expect(s.estAdmin, isTrue);
      await LicenceService(
        base.db,
        identifiant: const _Machine('P'),
      ).activer(CleActivation.cleAttendue(NiveauLicence.basic, 'P'));
      await expectLater(auth.connecter('demo', 'demo'), throwsA(isA<ConnexionException>()));
    });

    test('rôle Caissier : permissions et modules restreints', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', role: Roles.caissier),
        _hachage.hacher('1234'),
      );
      final s = await auth.connecter('amina', '1234');
      expect(s.a(Permission.voirPrixAchat), isFalse);
      expect(s.a(Permission.appliquerRemise), isTrue);
      expect(s.peutAcceder('caisse'), isTrue);
      expect(s.peutAcceder('clotures'), isFalse);
      await UtilisateurRepository(base.db).mettreAJour('USR0002', {'actif': 0});
      await expectLater(
        auth.connecter('amina', '1234'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.compteInactif)),
      );
    });

    test('Mon compte : changement d’identifiant et de mot de passe', () async {
      final base = await ouvrirBaseDeTest();
      await ConfigurationInitialeService(base.db, hachage: _hachage).terminer(_config());
      final auth = AuthService(base.db, hachage: _hachage);
      const code = MigrationV002Demarrage.codeAdmin;
      await expectLater(
        auth.changerIdentifiant(code, 'karim', 'faux'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.motDePasseActuelIncorrect)),
      );
      await expectLater(
        auth.changerIdentifiant(code, 'DEMO', 'azerty'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantPris)),
      );
      await expectLater(
        auth.changerIdentifiant(code, 'k', 'azerty'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantInvalide)),
      );
      final u = await auth.changerIdentifiant(code, 'karim.b', 'azerty');
      expect(u.identifiant, 'karim.b');
      // Garder son propre identifiant (changement de casse) est autorisé.
      await auth.changerIdentifiant(code, 'Karim.B', 'azerty');
      await auth.changerMotDePasse(code, 'azerty', 'nouveau1');
      await expectLater(auth.changerMotDePasse(code, 'azerty', 'x'), throwsA(isA<CompteException>()));
      expect((await auth.connecter('karim.b', 'nouveau1')).utilisateur.code, code);
    });
  });

  group('PermissionService', () {
    test('la grille est enregistrée en une transaction et l’Admin garde tout', () async {
      final base = await ouvrirBaseDeTest();
      final s = PermissionService(base.db);
      var g = await s.lireGrille();
      g = g
          .basculerPermission(Roles.caissier, Permission.voirPrixAchat)
          .basculerModule(Roles.caissier, 'clotures')
          .basculerPermission(Roles.admin, Permission.voirPrixAchat);
      await s.enregistrerGrille(g);
      final relu = await s.lireGrille();
      expect(relu.permissions[Roles.caissier], {Permission.appliquerRemise, Permission.voirPrixAchat});
      expect(relu.modules[Roles.caissier], contains('clotures'));
      expect(relu.permissions[Roles.admin], Permission.values.toSet());
      final apres = relu.basculerPermission(Roles.caissier, Permission.voirPrixAchat);
      expect(apres.permissions[Roles.caissier], {Permission.appliquerRemise});
    });

    test('prochain code utilisateur', () async {
      final base = await ouvrirBaseDeTest();
      expect(await UtilisateurRepository(base.db).prochainCode(), 'USR0002');
    });
  });
}
