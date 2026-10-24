import 'package:caissedz_desktop/application/alertes_service.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/configuration_initiale_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/db/migrations/v002_demarrage.dart';
import 'package:caissedz_desktop/core/db/migrations/v008_shell_ds.dart';
import 'package:caissedz_desktop/core/db/migrations/v044_admin_sans_mot_de_passe.dart';
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
import '../helpers/licence_test_helper.dart';

const _hachage = MotDePasse(iterations: 500);

const _admin = MigrationV002Demarrage.codeAdmin;

ConfigurationInitiale _config({String nom = 'Superette El Baraka', double marge = 25}) => ConfigurationInitiale(
  boutique: Boutique(nom: nom, rc: '16/00-123456', email: 'contact@baraka.dz', nis: '0012'),
  paiements: const ParametresPaiement(carte: true, cheque: true),
  parametres: ParametresVente(margeDefautPct: marge, seuilStockGlobal: 10, decimalesQuantite: 3),
);

/// Le mot de passe du compte BENS des tests, pris par l'administrateur.
const _mdp = 'secret pass 1';

/// Licence Basic sur le poste des tests (l'application la vérifie avant la connexion, SessionNotifier), et
/// le compte BENS créé : l'administrateur a pris son mot de passe.
Future<void> _activer(AppDatabase base) async {
  await (await licenceServiceTest(base)).activer(await cleTest(NiveauLicence.basic));
  await AuthService(base.db, hachage: _hachage).adminPrendCompteBens(nom: '', motDePasse: _mdp);
}

void main() {
  group('Seed de la migration v2', () {
    test('éléments système, administrateur sans mot de passe, démo, rôles', () async {
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
      // Pas de compte admin / admin : l'administrateur prendra le mot de passe du compte BENS.
      expect(await UtilisateurRepository(base.db).empreinte(admin.code), isNull);
      final caisse = (await base.db.query('caisse', where: 'code = ?', whereArgs: ['CIS0000'])).first;
      expect(caisse['magasin_code'], 'MAG0000');
      final roles = {for (final r in await PermissionsRepository(base.db).roles()) r.code: r};
      expect(roles[Roles.admin]!.systeme, isTrue);
      expect(Permission.values.every(roles[Roles.admin]!.aPermission), isTrue);
      expect(roles[Roles.caissier]!.permissions, {Permission.modifierPrixVente});
      expect(roles[Roles.magasinier]!.modules, contains('stock'));
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
    test('connexion de l’administrateur, session avec tous les droits, journal et dernier accès', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      final session = await auth.connecter('ADMIN', _mdp);
      expect(session.utilisateur.identifiant, 'admin');
      expect(session.estAdmin, isTrue);
      expect(session.modulesAutorises, isNull);
      expect(session.peutAcceder('zakat'), isTrue);
      expect(session.a(Permission.voirPrixAchat), isTrue);
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

    test('le compte demo / demo n’existe plus (l’essai de 14 jours le remplace)', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      await expectLater(
        auth.connecter('demo', 'demo'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.compteInactif)),
      );
    });

    test('poste neuf : l’administrateur prend le mot de passe du compte BENS, une seule fois', () async {
      final base = await ouvrirBaseDeTest();
      await (await licenceServiceTest(base)).activer(await cleTest(NiveauLicence.basic));
      final auth = AuthService(base.db, hachage: _hachage);
      await expectLater(
        auth.connecter('admin', 'admin'),
        throwsA(isA<ConnexionException>().having((e) => e.erreur, 'erreur', ErreurConnexion.motDePasseNonDefini)),
        reason: 'pas de compte admin / admin',
      );
      final u = await auth.adminPrendCompteBens(nom: 'Karim Haddad', motDePasse: 'secret pass 1');
      expect((u!.code, u.nom), (_admin, 'Karim Haddad'));
      await expectLater(auth.connecter('admin', 'admin'), throwsA(isA<ConnexionException>()));
      expect((await auth.connecter('admin', 'secret pass 1')).estAdmin, isTrue);
      expect(
        await auth.adminPrendCompteBens(nom: 'Autre', motDePasse: 'autre pass 2'),
        isNull,
        reason: 'déjà configuré',
      );
      expect((await auth.connecter('admin', 'secret pass 1')).utilisateur.nom, 'Karim Haddad');
    });

    test('mot de passe du compte BENS réinitialisé : l’administrateur le prend, même déjà configuré', () async {
      final base = await ouvrirBaseDeTest();
      await (await licenceServiceTest(base)).activer(await cleTest(NiveauLicence.basic));
      final auth = AuthService(base.db, hachage: _hachage);
      await auth.adminPrendCompteBens(nom: 'Karim Haddad', motDePasse: 'ancien pass 1');
      final u = await auth.adminPrendMotDePasseReinitialise('nouveau pass 2');
      expect((u!.code, u.nom), (_admin, 'Karim Haddad'), reason: 'le nom ne change pas');
      await expectLater(auth.connecter('admin', 'ancien pass 1'), throwsA(isA<ConnexionException>()));
      expect((await auth.connecter('admin', 'nouveau pass 2')).estAdmin, isTrue);

      // Aucun administrateur actif : rien à prendre.
      await UtilisateurRepository(base.db).mettreAJour(_admin, {'actif': 0});
      expect(await auth.adminPrendMotDePasseReinitialise('autre pass 3'), isNull);
    });

    test('migration v44 : le mot de passe admin d’origine est effacé, un autre est gardé', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      Future<String?> apres(String? motDePasse) async {
        await db.update(
          'utilisateur',
          {'mot_de_passe': motDePasse == null ? null : _hachage.hacher(motDePasse)},
          where: 'code = ?',
          whereArgs: [_admin],
        );
        await db.transaction((txn) => const MigrationV044AdminSansMotDePasse().appliquer(txn));
        return UtilisateurRepository(db).empreinte(_admin);
      }

      expect(await apres('admin'), isNull);
      expect(await apres(null), isNull);
      final garde = await apres('secret pass 1');
      expect(MotDePasse.verifier('secret pass 1', garde!), isTrue);
    });

    test('reprise de session (Rester connecté)', () async {
      final base = await ouvrirBaseDeTest();
      final auth = AuthService(base.db, hachage: _hachage);
      await _activer(base);
      expect((await auth.reprendreSession(_admin))!.utilisateur.code, _admin);
      expect(await auth.reprendreSession('USR9999'), isNull);
      await UtilisateurRepository(base.db).mettreAJour(_admin, {'actif': 0});
      expect(await auth.reprendreSession(_admin), isNull);
    });

    test('audit : l’utilisateur connecté signe les créations et modifications', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final auth = AuthService(base.db, hachage: _hachage);
      await auth.connecter('admin', _mdp);
      final tiers = TiersService(base.db, utilisateurCode: _admin);
      final c = await tiers.creerClient(const Client(code: '', nom: 'Amina'));
      var ligne = (await base.db.query('client', where: 'code = ?', whereArgs: [c.code])).single;
      expect((ligne['cree_par'], ligne['modifie_par']), (_admin, null));
      await tiers.modifierClient(c.copyWith(telephone: '0550000000'));
      ligne = (await base.db.query('client', where: 'code = ?', whereArgs: [c.code])).single;
      expect(ligne['modifie_par'], _admin);
      expect(ligne['modifie_le'], isNotNull);
      await auth.deconnecter(_admin);
      expect((await base.db.query('audit_contexte')).single['utilisateur_code'], isNull);
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
        auth.changerIdentifiant(code, 'DEMO', _mdp),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantPris)),
      );
      await expectLater(
        auth.changerIdentifiant(code, 'k', _mdp),
        throwsA(isA<CompteException>().having((e) => e.erreur, 'erreur', ErreurCompte.identifiantInvalide)),
      );
      final u = await auth.changerIdentifiant(code, 'karim.b', _mdp);
      expect(u.identifiant, 'karim.b');
      await auth.changerIdentifiant(code, 'Karim.B', _mdp);
      await auth.changerMotDePasse(code, _mdp, 'nouveau1');
      await expectLater(auth.changerMotDePasse(code, _mdp, 'x'), throwsA(isA<CompteException>()));
      expect((await auth.connecter('karim.b', 'nouveau1')).utilisateur.code, code);
    });
  });

  group('AlertesService', () {
    test('rupture : plus une famille du jour (alerte produit #14), familles selon l’accès, masquage du jour', () async {
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
      final admin = await alertes.calculer(await auth.connecter('admin', _mdp));
      // Lait en rupture : signalé une seule fois, par l'alerte produit « Rupture sans commande ».
      expect(admin.total, 0);
      expect(admin.familles, containsAll([FamilleAlerte.expire, FamilleAlerte.sessions, FamilleAlerte.clients]));

      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', roleCode: Roles.caissier),
        _hachage.hacher('1234'),
      );
      final caissier = await alertes.calculer(await auth.connecter('amina', '1234'));
      expect(caissier.familles, isNot(contains(FamilleAlerte.fournisseurs))); // pas d'accès aux Fournisseurs

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
      final admin = await AuthService(db, hachage: _hachage).connecter('admin', _mdp);
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
      final admin = await AuthService(db, hachage: _hachage).connecter('admin', _mdp);
      expect((await alertes.calculer(admin)).de(FamilleAlerte.clients).single.valeur, 300);
      await ParametreRepository(db).ecrire(AlertesService.cleSeuilCredit, '500');
      expect((await alertes.calculer(admin)).de(FamilleAlerte.clients), isEmpty, reason: '300 DA < seuil 500 DA');
    });
  });

  group('Rôles', () {
    test('l’Admin a toutes les permissions et tous les modules', () async {
      final base = await ouvrirBaseDeTest();
      await _activer(base);
      final s = await AuthService(base.db, hachage: _hachage).connecter('admin', _mdp);
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
