import 'package:caissedz_desktop/application/archivage_service.dart';
import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/role_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/utilisateur_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/client_repository.dart';
import 'package:caissedz_desktop/data/favoris_caisse_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/archivage.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

Produit _p(String nom) =>
    Produit(code: '', designation: nom, categorieCode: 'CATE0000', sousCategorieCode: 'SC0000', prixVente: 100);

Map<String, IssueSuppression> _parCode(List<IssueSuppression> issues) => {for (final i in issues) i.code: i};

Future<List<String>> _actionsHistorique(Database db, String code) async => [
  for (final r in await db.query('historique', where: 'entite_code = ?', whereArgs: [code], orderBy: 'id'))
    r['action']! as String,
];

void main() {
  group('ArchivageService — produits et packs', () {
    test('sans historique : supprimé ; avec historique : archivé, gardé pour les anciens documents', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final cat = CatalogueService(db, utilisateurCode: 'USR0000');
      final stock = StockService(db, utilisateurCode: 'USR0000');
      final s = ArchivageService(db, utilisateurCode: 'USR0000');
      final pain = await cat.creerProduit(_p('Pain'));
      final lait = await cat.creerProduit(_p('Lait'));
      final sucre = await cat.creerProduit(_p('Sucre'));
      final farine = await cat.creerProduit(_p('Farine'));
      // Lait : entré puis inventorié à zéro (historique, stock nul) ; Sucre : du stock reste.
      await stock.entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      await stock.inventorier(produitCode: lait.code, magasinCode: 'MAG0000', quantiteConstatee: 0);
      await stock.entrerStock(produitCode: sucre.code, magasinCode: 'MAG0000', quantite: 5);
      final pack = await cat.creerPack(
        Pack(
          code: '',
          designation: 'Pâtisserie',
          prixVente: 150,
          lignes: [PackLigne(produitCode: farine.code, quantite: 2)],
        ),
      );
      await FavorisCaisseRepository(db).ajouter([lait.code, pain.code]);

      final issues = _parCode(
        await s.analyser(EntiteArchivable.produit, [pain.code, lait.code, sucre.code, farine.code, 'PRD0000']),
      );
      expect((issues[pain.code]!.archivage, issues[pain.code]!.blocage), (false, null));
      expect((issues[lait.code]!.archivage, issues[lait.code]!.blocage), (true, null));
      expect(issues[sucre.code]!.blocage, BlocageArchivage.stockNonNul);
      expect(issues[farine.code]!.blocage, BlocageArchivage.dansPack);
      expect(issues['PRD0000']!.blocage, BlocageArchivage.systeme);

      expect(await s.supprimer(EntiteArchivable.produit, [pain.code, lait.code]), (supprimes: 1, archives: 1));
      final repo = CatalogueRepository(db);
      expect(await repo.produitParCode(pain.code), isNull);
      final archive = (await repo.produitParCode(lait.code))!;
      expect(archive.actif, isFalse);
      expect(archive.audit.archive, isTrue);
      expect(archive.audit.archivePar, 'USR0000');
      expect(await FavorisCaisseRepository(db).lire(), isEmpty, reason: 'un produit archivé quitte les favoris');
      // Le journal des mouvements reste intact (stock = journal).
      expect(await db.query('mouvement_stock', where: 'produit_code = ?', whereArgs: [lait.code]), hasLength(2));
      expect(await _actionsHistorique(db, lait.code), containsAllInOrder(['Création', 'Archivage']));
      expect(await _actionsHistorique(db, pain.code), contains('Suppression'));

      // Refus global si une fiche est bloquée ; rien n'est écrit.
      await expectLater(
        s.supprimer(EntiteArchivable.produit, [farine.code, sucre.code]),
        throwsA(isA<ArchivageException>().having((e) => e.blocage, 'blocage', BlocageArchivage.dansPack)),
      );
      expect(await repo.produitParCode(farine.code), isNotNull);
      // Déjà archivé : ni supprimé ni archivé de nouveau.
      expect((await s.analyser(EntiteArchivable.produit, [lait.code])).single.blocage, BlocageArchivage.etatInchange);

      // Pack jamais vendu : supprimé avec ses lignes ; la farine devient supprimable.
      expect(await s.supprimer(EntiteArchivable.pack, [pack.code]), (supprimes: 1, archives: 0));
      expect(await db.query('pack_ligne'), isEmpty);
      expect((await s.analyser(EntiteArchivable.produit, [farine.code])).single.blocage, isNull);

      // Restauration : actif, plus archivé ; restaurer une fiche non archivée est refusé.
      expect(await s.analyserRestauration(EntiteArchivable.produit, [lait.code, farine.code]), {
        lait.code: null,
        farine.code: BlocageArchivage.etatInchange,
      });
      expect(await s.restaurer(EntiteArchivable.produit, [lait.code]), 1);
      final restaure = (await repo.produitParCode(lait.code))!;
      expect((restaure.actif, restaure.audit.archive), (true, false));
      expect(await _actionsHistorique(db, lait.code), containsAllInOrder(['Archivage', 'Restauration']));
    });
  });

  group('ArchivageService — clients et fournisseurs', () {
    test('client vendu archivé (solde nul), client à crédit bloqué, client de passage système', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final cat = CatalogueService(db, utilisateurCode: 'USR0000');
      final tiers = TiersService(db, utilisateurCode: 'USR0000');
      final s = ArchivageService(db, utilisateurCode: 'USR0000');
      final lait = await cat.creerProduit(_p('Lait'));
      await StockService(
        db,
        utilisateurCode: 'USR0000',
      ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
      final karim = await tiers.creerClient(const Client(code: '', nom: 'Karim'));
      final sara = await tiers.creerClient(const Client(code: '', nom: 'Sara'));
      final nadia = await tiers.creerClient(const Client(code: '', nom: 'Nadia'));
      final session = await SessionCaisseService(
        db,
        utilisateurCode: 'USR0000',
      ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
      final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
      final payee = await ventes.encaisser(
        Panier(id: 1, clientCode: karim.code)
            .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: session,
        magasinCode: 'MAG0000',
      );
      await ventes.encaisser(
        Panier(id: 2, clientCode: sara.code).ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100)),
        session: session,
        magasinCode: 'MAG0000',
        creditAutorise: true,
      );

      final issues = _parCode(
        await s.analyser(EntiteArchivable.client, [karim.code, sara.code, nadia.code, 'CLN0000']),
      );
      expect((issues[karim.code]!.archivage, issues[karim.code]!.blocage), (true, null));
      expect(issues[sara.code]!.blocage, BlocageArchivage.soldeNonNul);
      expect((issues[nadia.code]!.archivage, issues[nadia.code]!.blocage), (false, null));
      expect(issues['CLN0000']!.blocage, BlocageArchivage.systeme);

      expect(await s.supprimer(EntiteArchivable.client, [karim.code, nadia.code]), (supprimes: 1, archives: 1));
      final clients = ClientRepository(db);
      expect(await clients.parCode(nadia.code), isNull);
      expect((await clients.parCode(karim.code))!.audit.archive, isTrue);
      // La vente garde son client : l'historique et les calculs ne bougent pas.
      final v = (await VenteRepository(db).ventes()).singleWhere((x) => x.code == payee.code);
      expect((v.clientCode, v.totalNet), (karim.code, 100));

      // Fournisseur sans historique : supprimé ; fournisseur système bloqué.
      final f = await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
      expect(await s.supprimer(EntiteArchivable.fournisseur, [f.code]), (supprimes: 1, archives: 0));
      expect((await s.analyser(EntiteArchivable.fournisseur, ['FOR0000'])).single.blocage, BlocageArchivage.systeme);
    });
  });

  group('ArchivageService — magasins, caisses, utilisateurs, rôles', () {
    test('magasin : vide supprimé, avec mouvements archivé, restauration dans la limite du palier', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final stock = StockService(db, utilisateurCode: 'USR0000');
      final cat = CatalogueService(db, utilisateurCode: 'USR0000');
      final vide = await stock.creerMagasin('Dépôt vide');
      final ancien = await stock.creerMagasin('Ancien dépôt');
      final plein = await stock.creerMagasin('Dépôt plein');
      final p = await cat.creerProduit(_p('Huile'));
      await stock.entrerStock(produitCode: p.code, magasinCode: ancien.code, quantite: 3);
      await stock.inventorier(produitCode: p.code, magasinCode: ancien.code, quantiteConstatee: 0);
      await stock.entrerStock(produitCode: p.code, magasinCode: plein.code, quantite: 3);

      final issues = _parCode(
        await ArchivageService(
          db,
          utilisateurCode: 'USR0000',
        ).analyser(EntiteArchivable.magasin, [vide.code, ancien.code, plein.code, 'MAG0000']),
      );
      expect((issues[vide.code]!.archivage, issues[vide.code]!.blocage), (false, null));
      expect((issues[ancien.code]!.archivage, issues[ancien.code]!.blocage), (true, null));
      expect(issues[plein.code]!.blocage, BlocageArchivage.stockNonNul);
      expect(issues['MAG0000']!.blocage, BlocageArchivage.systeme);

      final s = ArchivageService(db, utilisateurCode: 'USR0000', maxMagasins: 3);
      expect(await s.supprimer(EntiteArchivable.magasin, [vide.code, ancien.code]), (supprimes: 1, archives: 1));
      expect(await StockRepository(db).magasin(vide.code), isNull);
      // Actifs : MAG0000 + Dépôt plein = 2 sur 3 → une place ; à 2, plus de place.
      expect(await s.analyserRestauration(EntiteArchivable.magasin, [ancien.code]), {ancien.code: null});
      expect(
        await ArchivageService(
          db,
          utilisateurCode: 'USR0000',
          maxMagasins: 2,
        ).analyserRestauration(EntiteArchivable.magasin, [ancien.code]),
        {ancien.code: BlocageArchivage.limiteLicence},
      );
      await s.restaurer(EntiteArchivable.magasin, [ancien.code]);
      expect((await StockRepository(db).magasin(ancien.code))!.actif, isTrue);
    });

    test('caisse : neuve supprimée, avec mouvements archivée, solde ou session bloquants', () async {
      final base = await ouvrirBaseDeTest();
      final db = base.db;
      final caisses = CaisseService(db, utilisateurCode: 'USR0000');
      final neuve = await caisses.creer(nom: 'Caisse 2');
      final servie = await caisses.creer(nom: 'Caisse 3');
      await caisses.mouvementManuel(caisseCode: servie.code, apport: true, montant: 500);
      await caisses.mouvementManuel(caisseCode: servie.code, apport: false, montant: 500);
      final pleine = await caisses.creer(nom: 'Caisse 4');
      await caisses.mouvementManuel(caisseCode: pleine.code, apport: true, montant: 200);

      final s = ArchivageService(db, utilisateurCode: 'USR0000');
      final issues = _parCode(
        await s.analyser(EntiteArchivable.caisse, [neuve.code, servie.code, pleine.code, 'CIS0000']),
      );
      expect((issues[neuve.code]!.archivage, issues[neuve.code]!.blocage), (false, null));
      expect((issues[servie.code]!.archivage, issues[servie.code]!.blocage), (true, null));
      expect(issues[pleine.code]!.blocage, BlocageArchivage.soldeCaisse);
      expect(issues['CIS0000']!.blocage, BlocageArchivage.systeme);
      expect(await s.supprimer(EntiteArchivable.caisse, [neuve.code, servie.code]), (supprimes: 1, archives: 1));
    });

    test(
      'utilisateur et rôle : sans activité supprimés, sinon archivés ; compte courant et rôle utilisé bloqués',
      () async {
        final base = await ouvrirBaseDeTest();
        final db = base.db;
        final roles = RoleService(db, utilisateurCode: 'USR0000');
        final users = UtilisateurService(db, utilisateurCode: 'USR0000');
        final libre = await roles.creer(nom: 'Stagiaire', modules: {'caisse'}, permissions: const {});
        final vendeur = await roles.creer(nom: 'Vendeur', modules: {'caisse'}, permissions: const {});
        Future<String> compte(String identifiant) async => (await users.creer(
          identifiant: identifiant,
          motDePasse: 'Secret-2026',
          nom: identifiant,
          telephone: '0555123456',
          roleCode: vendeur.code,
          magasins: const ['MAG0000'],
        )).code;
        final nouveau = await compte('nouveau');
        final ancien = await compte('ancien');
        // Une connexion journalisée suffit : le compte apparaît dans l'historique.
        await db.insert('historique', {'utilisateur_code': ancien, 'action': 'Connexion', 'entite': 'session'});

        final s = ArchivageService(db, utilisateurCode: 'USR0000');
        final issues = _parCode(await s.analyser(EntiteArchivable.utilisateur, [nouveau, ancien, 'USR0000']));
        expect((issues[nouveau]!.archivage, issues[nouveau]!.blocage), (false, null));
        expect((issues[ancien]!.archivage, issues[ancien]!.blocage), (true, null));
        expect(issues['USR0000']!.blocage, BlocageArchivage.systeme);
        expect(
          (await ArchivageService(
            db,
            utilisateurCode: ancien,
          ).analyser(EntiteArchivable.utilisateur, [ancien])).single.blocage,
          BlocageArchivage.compteCourant,
        );
        expect(
          (await s.analyser(EntiteArchivable.role, [vendeur.code])).single.blocage,
          BlocageArchivage.utilisateursRattaches,
        );

        expect(await s.supprimer(EntiteArchivable.utilisateur, [nouveau, ancien]), (supprimes: 1, archives: 1));
        expect(await UtilisateurRepository(db).parCode(nouveau), isNull);
        expect(await db.query('utilisateur_magasin', where: 'utilisateur_code = ?', whereArgs: [nouveau]), isEmpty);
        final archive = (await UtilisateurRepository(db).parCode(ancien))!;
        expect((archive.actif, archive.archive), (false, true));

        // Rôle : celui de comptes archivés seulement → archivé ; jamais attribué → supprimé.
        final issuesRoles = _parCode(await s.analyser(EntiteArchivable.role, [vendeur.code, libre.code, 'ROL0000']));
        expect((issuesRoles[vendeur.code]!.archivage, issuesRoles[vendeur.code]!.blocage), (true, null));
        expect((issuesRoles[libre.code]!.archivage, issuesRoles[libre.code]!.blocage), (false, null));
        expect(issuesRoles['ROL0000']!.blocage, BlocageArchivage.systeme);
        expect(await s.supprimer(EntiteArchivable.role, [vendeur.code, libre.code]), (supprimes: 1, archives: 1));
        expect(await db.query('role_module', where: 'role_code = ?', whereArgs: [libre.code]), isEmpty);
      },
    );
  });
}
