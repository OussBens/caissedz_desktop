import 'package:caissedz_desktop/application/alertes_service.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/configuration_initiale_service.dart';
import 'package:caissedz_desktop/application/licence_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:caissedz_desktop/core/db/migrations/v002_demarrage.dart';
import 'package:caissedz_desktop/core/db/migrations/v008_shell_ds.dart';
import 'package:caissedz_desktop/core/licence/cle_activation.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/boutique_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/permissions_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/models/alerte.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_paiement.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
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

const _admin = MigrationV002Demarrage.codeAdmin;

ConfigurationInitiale _config({String nom = 'Superette El Baraka', double marge = 25}) => ConfigurationInitiale(
  boutique: Boutique(nom: nom, rc: '16/00-123456', email: 'contact@baraka.dz', nis: '0012'),
  paiements: const ParametresPaiement(carte: true, cheque: true),
  parametres: ParametresVente(margeDefautPct: marge, seuilStockGlobal: 10, decimalesQuantite: 3),
);

/// Licence Basic sur le poste « P » (la connexion hors demo exige une application activée, §4.3).
Future<void> _activer(AppDatabase base) => LicenceService(
  base.db,
  identifiant: const _Machine('P'),
).activer(CleActivation.cleAttendue(NiveauLicence.basic, 'P'));

void main() {
  group('Seed de la migration v2', () {
    test('éléments système, admin / admin, démo, rôles', () async {
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
      final admin = await UtilisateurRepository(base.db).parCode(_admin);
      expect(admin!.roleCode, Roles.admin);
      expect(admin.roleNom, 'Admin');
      expect(admin.identifiant, MigrationV008ShellDs.identifiantAdmin);
      // v008 : compte admin / admin provisoire.
      final empreinte = await UtilisateurRepository(base.db).empreinte(admin.code);
      expect(MotDePasse.verifier(MigrationV008ShellDs.motDePasseAdmin, empreinte!), isTrue);
      final caisse = (await base.db.query('caisse', where: 'code = ?', whereArgs: ['CIS0000'])).first;
      expect(caisse['magasin_code'], 'MAG0000');
      final roles = {for (final r in await PermissionsRepository(base.db).roles()) r.code: r};
      expect(roles[Roles.admin]!.systeme, isTrue);
      expect(Permission.values.every(roles[Roles.admin]!.aPermission), isTrue);
      expect(roles[Roles.caissier]!.permissions, {Permission.modifierPrixVente});
      expect(roles[Roles.magasinier]!.modules, contains('stock'));
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
    test('écrit boutique, paramètres, paiements, langue et journalise, en une transaction', () async {
      final base = await ouvrirBaseDeTest();
      final service = ConfigurationInitialeService(base.db);
      expect(await service.estTerminee(), isFalse);
      await service.terminer(_config(), utilisateurCode: _admin);
      expect(await service.estTerminee(), isTrue);
      final boutique = (await BoutiqueRepository(base.db).lire())!;
      expect(boutique.nom, 'Superette El Baraka');
      expect(boutique.nis, '0012');
      final relu = await service.lire();
      expect(relu.parametres.margeDefautPct, 25);
      expect(relu.parametres.seuilStockGlobal, 10);
      expect(relu.parametres.decimalesQuantite, 3);
      expect(relu.parametres.devise, 'DA');
      expect(relu.paiements.cheque, isTrue);
      expect(relu.paiements.virement, isFalse);
      expect(relu.paiements.modes, contains('Espèces'));
      expect(await ParametreRepository(base.db).lire('langue'), 'fr');
      final journal = await base.db.query('historique', where: 'action = ?', whereArgs: ['Configuration initiale']);
      expect(journal.single['utilisateur_code'], _admin);
    });

    test('validations : nom vide, marge hors limites — rien n’est écrit', () async {
      final base = await ouvrirBaseDeTest();
      final s = ConfigurationInitialeService(base.db);
      await expectLater(
        s.terminer(_config(nom: '  '), utilisateurCode: _admin),
        throwsA(isA<ConfigurationException>().having((e) => e.erreur, 'erreur', ErreurConfiguration.nomBoutiqueVide)),
      );
      await expectLater(
        s.terminer(_config(marge: -1), utilisateurCode: _admin),
        throwsA(isA<ConfigurationException>().having((e) => e.erreur, 'erreur', ErreurConfiguration.margeHorsLimites)),
      );
      expect(await s.estTerminee(), isFalse);
      expect(await BoutiqueRepository(base.db).lire(), isNull);
    });
  });

  group('AuthService', () {
    test('connexion admin / admin, session avec tous les droits, journal et dernier accès', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      final session = await auth.connecter('ADMIN', 'admin');
      expect(session.utilisateur.identifiant, 'admin');
      expect(session.estAdmin, isTrue);
      expect(session.modulesAutorises, isNull);
      expect(session.peutAcceder('zakat'), isTrue);
      expect(session.a(Permission.voirPrixAchat), isTrue);
      expect(session.demo, isFalse);
      expect((await UtilisateurRepository(base.db).parCode(_admin))!.dernierAcces, isNotNull);
      await auth.deconnecter(_admin);
      final journal = await base.db.query('historique', where: 'entite = ?', whereArgs: ['utilisateur'], orderBy: 'id');
      expect(journal.map((l) => l['action']), ['Connexion', 'Déconnexion']);
      await expectLater(
        auth.connecter('admin', 'faux'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.identifiantsInvalides)),
      );
      await expectLater(auth.connecter('inconnu', 'x'), throwsA(isA<ConnexionException>()));
    });

    test('application non activée : seul demo / demo est accepté (§4.3)', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await expectLater(
        auth.connecter('admin', 'admin'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.nonActivee)),
      );
      await expectLater(
        auth.connecter('demo', 'demo'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.demoIndisponible)),
      );
    });

    test('demo/demo disponible uniquement en mode démo', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await LicenceService(base.db, identifiant: const _Machine('P')).activerDemo();
      final s = await auth.connecter('demo', 'demo');
      expect(s.demo, isTrue);
      expect(s.estAdmin, isTrue);
      await _activer(base);
      await expectLater(
        auth.connecter('demo', 'demo'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.demoIndisponible)),
      );
    });

    test('reprise de session (Rester connecté)', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      expect(await auth.reprendreSession(_admin), isNull); // non activée
      await _activer(base);
      expect((await auth.reprendreSession(_admin))!.utilisateur.code, _admin);
      expect(await auth.reprendreSession('USR9999'), isNull);
      await UtilisateurRepository(base.db).mettreAJour(_admin, {'actif': 0});
      expect(await auth.reprendreSession(_admin), isNull);
    });

    test('rôle Caissier : permissions et modules restreints', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', roleCode: Roles.caissier),
        _hachage.hacher('1234'),
      );
      final s = await auth.connecter('amina', '1234');
      expect(s.a(Permission.voirPrixAchat), isFalse);
      expect(s.a(Permission.modifierPrixVente), isTrue);
      expect(s.a(Permission.annulerOperations), isFalse);
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
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      const code = _admin;
      await expectLater(
        auth.changerIdentifiant(code, 'karim', 'faux'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.motDePasseActuelIncorrect)),
      );
      await expectLater(
        auth.changerIdentifiant(code, 'DEMO', 'admin'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantPris)),
      );
      await expectLater(
        auth.changerIdentifiant(code, 'k', 'admin'),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantInvalide)),
      );
      final u = await auth.changerIdentifiant(code, 'karim.b', 'admin');
      expect(u.identifiant, 'karim.b');
      await auth.changerIdentifiant(code, 'Karim.B', 'admin');
      await auth.changerMotDePasse(code, 'admin', 'nouveau1');
      await expectLater(auth.changerMotDePasse(code, 'admin', 'x'), throwsA(isA<CompteException>()));
      expect((await auth.connecter('karim.b', 'nouveau1')).utilisateur.code, code);
    });
  });

  group('AlertesService', () {
    test('ruptures visibles selon l’accès au module, masquage du jour', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      await CatalogueService(base.db, utilisateurCode: _admin).creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      final auth = AuthService(base.db, hachage: _hachage);
      final alertes = AlertesService(base.db);
      final admin = await alertes.calculer(await auth.connecter('admin', 'admin'));
      expect(admin.de(FamilleAlerte.rupture).single.titre, 'Lait');
      expect(admin.total, 1);

      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', roleCode: Roles.caissier),
        _hachage.hacher('1234'),
      );
      final caissier = await alertes.calculer(await auth.connecter('amina', '1234'));
      expect(caissier.de(FamilleAlerte.rupture), isEmpty); // pas d'accès au module Besoins

      final jour = DateTime(2026, 10, 15, 9);
      expect(await alertes.estMasqueAujourdhui(_admin, maintenant: jour), isFalse);
      await alertes.masquerAujourdhui(_admin, maintenant: jour);
      expect(await alertes.estMasqueAujourdhui(_admin, maintenant: jour.add(const Duration(hours: 5))), isTrue);
      expect(await alertes.estMasqueAujourdhui(_admin, maintenant: jour.add(const Duration(days: 1))), isFalse);
    });

    test('expirés (date passée) et bientôt expirés (≤ 30 jours), produits en stock seulement', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final db = base.db;
      final catalogue = CatalogueService(db, utilisateurCode: _admin);
      final stock = StockService(db, utilisateurCode: _admin);
      final maintenant = DateTime(2026, 10, 15, 9);
      Future<void> produit(String nom, DateTime? expire, {double quantite = 5}) async {
        final p = await catalogue.creerProduit(
          Produit(
            code: '',
            designation: nom,
            categorieCode: 'CATE0000',
            sousCategorieCode: 'SC0000',
            prixAchat: 80,
            prixVente: 100,
            dateExpiration: expire,
          ),
        );
        if (quantite > 0) await stock.entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: quantite);
      }

      await produit('Yaourt', DateTime(2026, 10, 12));
      await produit('Fromage', DateTime(2026, 10, 25));
      await produit('Conserve', DateTime(2027, 6, 1));
      await produit('Lait vide', DateTime(2026, 10, 1), quantite: 0);
      await produit('Riz', null);
      final admin = await AuthService(db, hachage: _hachage).connecter('admin', 'admin');
      final alertes = await AlertesService(db).calculer(admin, maintenant: maintenant);
      final expire = alertes.de(FamilleAlerte.expire).single;
      expect((expire.titre, expire.valeur, expire.critique), ('Yaourt', -3, true));
      final bientot = alertes.de(FamilleAlerte.bientot).single;
      expect((bientot.titre, bientot.valeur, bientot.critique), ('Fromage', 10, false));
    });

    test('Paramètres › Alertes : ouverture à la connexion, seuil de crédit client', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final db = base.db;
      final alertes = AlertesService(db);
      expect(await alertes.afficherALaConnexion(), isTrue);
      await ParametreRepository(db).ecrire(AlertesService.cleConnexion, '0');
      expect(await alertes.afficherALaConnexion(), isFalse);
      final lait = await CatalogueService(db, utilisateurCode: _admin).creerProduit(
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
        utilisateurCode: _admin,
      ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      final client = await TiersService(
        db,
        utilisateurCode: _admin,
      ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 5000));
      final session = await SessionCaisseService(
        db,
        utilisateurCode: _admin,
      ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      await VenteService(db, utilisateurCode: _admin, parametres: const ParametresVente()).encaisser(
        Panier(id: 1, clientCode: client.code).ajouter(PanierLigne(produit: lait, quantite: 3, prixUnitaire: 100)),
        session: session,
        magasinCode: 'MAG0000',
        creditAutorise: true,
      );
      final admin = await AuthService(db, hachage: _hachage).connecter('admin', 'admin');
      expect((await alertes.calculer(admin)).de(FamilleAlerte.clients).single.valeur, 300);
      await ParametreRepository(db).ecrire(AlertesService.cleSeuilCredit, '500');
      expect((await alertes.calculer(admin)).de(FamilleAlerte.clients), isEmpty, reason: '300 DA < seuil 500 DA');
    });
  });

  group('Rôles', () {
    test('l’Admin a toutes les permissions et tous les modules', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final s = await AuthService(base.db, hachage: _hachage).connecter('admin', 'admin');
      expect(s.estAdmin, isTrue);
      expect(s.permissions, Permission.values.toSet());
      expect(s.peutAcceder('utilisateurs'), isTrue);
    });

    test('prochain code utilisateur', () async {
      final base = await ouvrirBaseDeTest();
      expect(await UtilisateurRepository(base.db).prochainCode(), 'USR0002');
    });
  });
}
