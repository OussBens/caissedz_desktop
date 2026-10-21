import 'dart:math';

import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/role_service.dart';
import 'package:caissedz_desktop/application/utilisateur_service.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/permissions_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';
import '../helpers/licence_test_helper.dart';

const _hachage = MotDePasse(iterations: 500);

Matcher _erreurU(ErreurUtilisateur e) => throwsA(isA<UtilisateurException>().having((x) => x.erreur, 'erreur', e));
Matcher _erreurR(ErreurRole e) => throwsA(isA<RoleException>().having((x) => x.erreur, 'erreur', e));

void main() {
  group('UtilisateurService', () {
    test('force du mot de passe (0 à 4) et seuil de création', () {
      expect(UtilisateurService.force(''), 0);
      expect(UtilisateurService.force('abcdefgh'), 1);
      expect(UtilisateurService.force('Abcd1'), 2);
      expect(UtilisateurService.force('Abcdefg1'), 3);
      expect(UtilisateurService.force('Abcdefg1!'), 4);
      expect(UtilisateurService.motDePasseAcceptable('abcd'), isFalse);
      expect(UtilisateurService.motDePasseAcceptable('abc1'), isFalse, reason: 'force 1');
      expect(UtilisateurService.motDePasseAcceptable('Abc1'), isTrue);
    });

    test('création : code USR, rôle assignable, caisse attachée, magasins ordonnés, connexion', () async {
      final base = await ouvrirBaseDeTest();
      final s = UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: _hachage);
      expect(await s.prochainCode(), 'USR0002');
      Future<void> creer({
        String identifiant = 'amina',
        String motDePasse = 'Amina2026',
        String telephone = '0661 20 30 40',
        String role = Roles.caissier,
        List<String> magasins = const ['MAG0000'],
      }) => s.creer(
        identifiant: identifiant,
        motDePasse: motDePasse,
        prenom: 'Amina',
        nom: 'Kaci',
        telephone: telephone,
        roleCode: role,
        caisseCode: 'CIS0000',
        magasins: magasins,
      );
      await expectLater(creer(identifiant: 'a'), _erreurU(ErreurUtilisateur.identifiantInvalide));
      await expectLater(creer(identifiant: 'ADMIN'), _erreurU(ErreurUtilisateur.identifiantPris));
      await expectLater(creer(motDePasse: 'abcd'), _erreurU(ErreurUtilisateur.motDePasseFaible));
      await expectLater(creer(telephone: ' '), _erreurU(ErreurUtilisateur.telephoneObligatoire));
      await expectLater(creer(telephone: '0552'), _erreurU(ErreurUtilisateur.telephoneInvalide));
      await expectLater(creer(telephone: '0852112233'), _erreurU(ErreurUtilisateur.telephoneInvalide));
      await expectLater(creer(role: Roles.admin), _erreurU(ErreurUtilisateur.roleInvalide), reason: 'admin unique');
      await expectLater(creer(magasins: []), _erreurU(ErreurUtilisateur.magasinsObligatoires));
      await creer();
      final u = (await UtilisateurRepository(base.db).parCode('USR0002'))!;
      expect(u.nomComplet, 'Amina Kaci');
      expect(u.roleNom, 'Caissier');
      expect(u.caisseCode, 'CIS0000');
      expect(u.creePar, 'USR0000');
      expect(await StockRepository(base.db).magasinsUtilisateur('USR0002'), ['MAG0000']);
      final historique = await base.db.query('historique', where: "entite = 'utilisateur' AND action = 'Création'");
      expect(historique.single['entite_code'], 'USR0002');

      // Connexion avec le rôle Caissier.
      await (await licenceServiceTest(base)).activer(await cleTest(NiveauLicence.basic));
      final session = await AuthService(base.db, hachage: _hachage).connecter('amina', 'Amina2026');
      expect(session.estAdmin, isFalse);
      expect(session.peutAcceder('caisse'), isTrue);
      expect(session.peutAcceder('utilisateurs'), isFalse);
    });

    test('modification : mot de passe optionnel, rôle de l’Admin figé, admin sans caisse', () async {
      final base = await ouvrirBaseDeTest();
      final s = UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: _hachage);
      final u = await s.creer(
        identifiant: 'karim',
        motDePasse: 'Karim2026',
        telephone: '0552112233',
        roleCode: Roles.magasinier,
        magasins: const ['MAG0000'],
      );
      final m = await s.modifier(
        u.code,
        identifiant: 'karim.s',
        nouveauMotDePasse: '',
        prenom: 'Karim',
        nom: 'Saadi',
        telephone: '0552 77 88 99',
        roleCode: Roles.caissier,
        caisseCode: 'CIS0000',
        magasins: const ['MAG0000'],
      );
      expect(m.identifiant, 'karim.s');
      expect(m.roleCode, Roles.caissier);
      final empreinte = await UtilisateurRepository(base.db).empreinte(u.code);
      expect(MotDePasse.verifier('Karim2026', empreinte!), isTrue, reason: 'mot de passe inchangé');
      await expectLater(
        s.modifier(
          'USR0000',
          identifiant: 'admin',
          telephone: '0550112233',
          roleCode: Roles.caissier,
          magasins: const ['MAG0000'],
        ),
        _erreurU(ErreurUtilisateur.roleInvalide),
      );
      final admin = await s.modifier(
        'USR0000',
        identifiant: 'admin',
        telephone: '0550112233',
        roleCode: Roles.admin,
        caisseCode: 'CIS0000',
        magasins: const ['MAG0000'],
      );
      expect(admin.caisseCode, isNull, reason: 'l’admin choisit sa caisse librement');
    });

    test('désactivation bloquée (admin principal, compte courant), mot de passe temporaire', () async {
      final base = await ouvrirBaseDeTest();
      final s = UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: _hachage);
      final u = await s.creer(
        identifiant: 'nadia',
        motDePasse: 'Nadia2026',
        telephone: '0663112233',
        roleCode: Roles.caissier,
        magasins: const ['MAG0000'],
      );
      final repo = UtilisateurRepository(base.db);
      expect(s.blocageDesactivation((await repo.parCode('USR0000'))!), ErreurUtilisateur.compteAdministrateur);
      expect(
        UtilisateurService(base.db, utilisateurCode: u.code).blocageDesactivation(u),
        ErreurUtilisateur.compteCourant,
      );
      await expectLater(s.desactiver(['USR0000']), _erreurU(ErreurUtilisateur.compteAdministrateur));
      await s.desactiver([u.code]);
      expect((await repo.parCode(u.code))!.actif, isFalse);
      expect(s.blocageDesactivation((await repo.parCode(u.code))!), ErreurUtilisateur.dejaInactif);

      final temporaire = await s.reinitialiserMotDePasse(u.code, alea: Random(1));
      expect(UtilisateurService.motDePasseAcceptable(temporaire), isTrue);
      expect(MotDePasse.verifier(temporaire, (await repo.empreinte(u.code))!), isTrue);
    });
  });

  group('RoleService', () {
    test('création (ROL0003), nom unique, au moins un module, permissions appliquées', () async {
      final base = await ouvrirBaseDeTest();
      final s = RoleService(base.db, utilisateurCode: 'USR0000');
      expect(await s.prochainCode(), 'ROL0003');
      await expectLater(
        s.creer(nom: 'caissier', modules: const {'caisse'}, permissions: const {}),
        _erreurR(ErreurRole.nomPris),
      );
      await expectLater(
        s.creer(nom: 'Superviseur', modules: const {}, permissions: const {}),
        _erreurR(ErreurRole.aucunModule),
      );
      final r = await s.creer(
        nom: 'Superviseur',
        observation: 'Lecture + annulations',
        modules: const {'tableau_bord', 'ventes'},
        permissions: const {Permission.annulerOperations, Permission.voirMarge},
      );
      expect(r.code, 'ROL0003');
      expect(r.modules, {'tableau_bord', 'ventes'});
      expect(r.permissions, {Permission.annulerOperations, Permission.voirMarge});
      expect(r.creePar, 'USR0000');
    });

    test('modification refusée pour Admin, désactivation bloquée si des utilisateurs ont le rôle', () async {
      final base = await ouvrirBaseDeTest();
      final s = RoleService(base.db, utilisateurCode: 'USR0000');
      await expectLater(
        s.modifier(Roles.admin, nom: 'Admin', modules: const {'caisse'}, permissions: const {}),
        _erreurR(ErreurRole.roleSysteme),
      );
      await UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: _hachage).creer(
        identifiant: 'amina',
        motDePasse: 'Amina2026',
        telephone: '0661112233',
        roleCode: Roles.caissier,
        magasins: const ['MAG0000'],
      );
      final roles = {for (final r in await s.roles()) r.code: r};
      expect(roles[Roles.caissier]!.nbUtilisateurs, 1);
      expect(s.blocageDesactivation(roles[Roles.admin]!), ErreurRole.roleSysteme);
      expect(s.blocageDesactivation(roles[Roles.caissier]!), ErreurRole.utilisateursRattaches);
      expect(s.blocageDesactivation(roles[Roles.magasinier]!), isNull);
      await s.desactiver([Roles.magasinier]);
      expect((await PermissionsRepository(base.db).role(Roles.magasinier))!.actif, isFalse);
      // Un rôle inactif n'est plus assignable.
      await expectLater(
        UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: _hachage).creer(
          identifiant: 'karim',
          motDePasse: 'Karim2026',
          telephone: '0552112233',
          roleCode: Roles.magasinier,
          magasins: const ['MAG0000'],
        ),
        _erreurU(ErreurUtilisateur.roleInvalide),
      );
      final m = await s.modifier(
        Roles.caissier,
        nom: 'Caissier',
        modules: const {'caisse'},
        permissions: const {Permission.modifierPrixVente, Permission.changerCaisseMagasin},
      );
      expect(m.modules, {'caisse'});
      expect(m.permissions, {Permission.modifierPrixVente, Permission.changerCaisseMagasin});
    });
  });
}
