import 'dart:convert';

import 'package:caissedz_desktop/application/catalogue_ia_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/import_produits_service.dart';
import 'package:caissedz_desktop/application/synchro_catalogue_service.dart';
import 'package:caissedz_desktop/core/print/etiquettes_pdf.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/historique_repository.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/bases.dart';

Produit _p({String designation = 'Lait 1 L', String? cb, double pa = 80, double pv = 0, double marge = 0}) => Produit(
  code: '',
  designation: designation,
  codeBarres: cb,
  categorieCode: 'CATE0000',
  sousCategorieCode: 'SC0000',
  prixAchat: pa,
  prixVente: pv,
  margePct: marge,
);

void main() {
  group('CatalogueService — catégories', () {
    test('création avec sous-catégorie par défaut, renommage, suppression protégée', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final c = await s.creerCategorie('Boissons');
      expect(c.code, 'CATE0001');
      final scs = await CatalogueRepository(base.db).sousCategories(c.code);
      expect(scs.single.code, 'SC0001');
      await s.renommerCategorie(c.code, 'Boissons fraîches');
      expect(
        (await CatalogueRepository(base.db).categories()).firstWhere((x) => x.code == c.code).nom,
        'Boissons fraîches',
      );
      await expectLater(
        s.supprimerCategorie('CATE0000'),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.categorieSysteme)),
      );
      final p = await s.creerProduit(_p().copyWith(categorieCode: c.code, sousCategorieCode: 'SC0001'));
      // Suppression : les produits passent dans « Sans catégorie », la sous-catégorie part avec la catégorie.
      expect(await s.supprimerCategories([c.code]), 1);
      final repo = CatalogueRepository(base.db);
      final apres = (await repo.produits()).firstWhere((x) => x.code == p.code);
      expect((apres.categorieCode, apres.sousCategorieCode), ('CATE0000', 'SC0000'));
      expect((await repo.categories()).any((x) => x.code == c.code), isFalse);
      expect(await repo.sousCategories(c.code), isEmpty);
      final c2 = await s.creerCategorie('Vide');
      await s.supprimerCategorie(c2.code);
      expect((await repo.categories()).any((x) => x.code == c2.code), isFalse);
      expect((await HistoriqueRepository(base.db).lire(entite: 'categorie')).length, 4);
    });
  });

  group('CatalogueService — produits', () {
    test('prix de vente calculé depuis la marge (produit puis marge par défaut)', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final p1 = await s.creerProduit(_p(pa: 100, marge: 30));
      expect(p1.code, 'PRD0001');
      expect(p1.prixVente, 130);
      final p2 = await s.creerProduit(_p(designation: 'Eau', pa: 50), margeDefautPct: 20);
      expect(p2.prixVente, 60);
      expect(p2.margePct, 20);
      final p3 = await s.creerProduit(_p(designation: 'Jus', pa: 100, pv: 150));
      expect(p3.margePct, 50);
    });

    test('code-barres : unicité (produit, colis, pack), EAN-13 et interne généré', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final p = await s.creerProduit(_p(cb: '6130000000015'));
      await expectLater(
        s.creerProduit(_p(designation: 'Doublon', cb: '6130000000015')),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.codeBarresDejaUtilise)),
      );
      await expectLater(
        s.creerProduit(_p(designation: 'Court', cb: 'ab')),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.codeBarresInvalide)),
      );
      final sansCode = await s.creerProduit(_p(designation: 'Sans code'));
      expect(sansCode.codeBarres, isNull);
      final g1 = await s.genererCodeBarresInterne(sansCode.code, date: DateTime(2026, 10, 14));
      expect(g1.codeBarres, 'CDZ202610140001');
      final autre = await s.creerProduit(_p(designation: 'Autre'), genererCodeBarres: true);
      expect(autre.codeBarres, startsWith('CDZ'));
      // Modification : garder son propre code-barres est autorisé
      final maj = await s.modifierProduit(p.copyWith(designation: 'Lait entier'));
      expect(maj.designation, 'Lait entier');
      expect(await CatalogueRepository(base.db).produitParCodeBarres('6130000000015'), isNotNull);
      final colis = await s.creerColis(
        Colis(
          code: '',
          produitCode: p.code,
          designation: 'Pack de 6',
          quantite: 6,
          codeBarres: '6130000000022',
          prixVente: 550,
        ),
      );
      expect(colis.code, 'COL0001');
      await expectLater(s.creerProduit(_p(designation: 'X', cb: '6130000000022')), throwsA(isA<CatalogueException>()));
    });

    test('packs et remises', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final lait = await s.creerProduit(_p(pa: 80, pv: 100));
      final eau = await s.creerProduit(_p(designation: 'Eau', pa: 20, pv: 30));
      await expectLater(
        s.creerPack(const Pack(code: '', designation: 'Vide', prixVente: 10)),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.lignesVides)),
      );
      final pack = await s.creerPack(
        Pack(
          code: '',
          designation: 'Petit-déj',
          prixVente: 120,
          lignes: [
            PackLigne(produitCode: lait.code, quantite: 1),
            PackLigne(produitCode: eau.code, quantite: 2),
          ],
        ),
      );
      expect(pack.code, 'PCK0001');
      final relu = (await CatalogueRepository(base.db).packs()).single;
      expect(relu.lignes.length, 2);
      final r = await s.creerRemise(
        const Remise(code: '', designation: '-10 % lait', type: 'Pourcentage', valeur: 10),
        produits: [lait.code],
      );
      expect(r.code, 'REM0001');
      final laitRemise = (await CatalogueRepository(base.db).produitParCode(lait.code))!;
      expect(laitRemise.remiseCode, r.code);
      // Remise « Par Montant » : choisie sur le panier, jamais appliquée automatiquement au produit.
      await s.creerRemise(
        const Remise(code: '', designation: '-5 DA panier', type: 'Montant', valeur: 5, portee: Remise.porteeMontant),
      );
      expect(await s.remiseApplicable(laitRemise, 100), 10);
      expect(await s.remiseApplicable(eau, 30), 0);
      // Modification : la liste des produits remplace l'assignation.
      await s.modifierRemise(r, produits: [eau.code]);
      expect((await CatalogueRepository(base.db).produitParCode(lait.code))!.remiseCode, isNull);
      expect((await CatalogueRepository(base.db).produitParCode(eau.code))!.remiseCode, r.code);
      await s.activerRemise(r.code, false);
      expect(await s.remiseApplicable((await CatalogueRepository(base.db).produitParCode(eau.code))!, 30), 0);
      await expectLater(
        s.creerRemise(const Remise(code: '', designation: 'x', type: 'Pourcentage', valeur: 150)),
        throwsA(isA<CatalogueException>()),
      );
      // Suppression réelle : le produit perd sa remise ; le pack (jamais vendu) part avec ses lignes.
      await s.supprimerRemises([r.code]);
      final repo = CatalogueRepository(base.db);
      expect((await repo.produitParCode(eau.code))!.remiseCode, isNull);
      expect((await repo.remises()).any((x) => x.code == r.code), isFalse);
      expect(await s.packsVendus(), isEmpty);
      await s.supprimerPacks([pack.code]);
      expect(await repo.packs(), isEmpty);
      expect(await base.db.query('pack_ligne'), isEmpty);
    });

    test('sous-catégories supprimées : produits dans « Sans catégorie » ; audit renseigné', () async {
      final base = await ouvrirBaseDeTest();
      await UtilisateurRepository(base.db).definirAuditContexte('USR0000');
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final c = await s.creerCategorie('Boissons');
      final sc = await s.creerSousCategorie(c.code, 'Jus');
      final p = await s.creerProduit(_p().copyWith(categorieCode: c.code, sousCategorieCode: sc.code));
      final lu = (await CatalogueRepository(base.db).produitParCode(p.code))!;
      expect(lu.audit.creePar, 'USR0000');
      expect(lu.audit.creeLe, isNotNull);
      expect(await s.supprimerSousCategories([sc.code, 'SC0000']), 1);
      final apres = (await CatalogueRepository(base.db).produitParCode(p.code))!;
      expect((apres.categorieCode, apres.sousCategorieCode), ('CATE0000', 'SC0000'));
      expect(apres.audit.modifiePar, 'USR0000');
      await expectLater(
        s.supprimerSousCategories(['SC0000']),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.categorieSysteme)),
      );
    });

    test('fiche complète : codes secondaires, emballages, stock initial, affectation, suppression', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final repo = CatalogueRepository(base.db);
      final p = await s.creerProduit(
        _p(cb: '6130000000015', pv: 100).copyWith(marque: 'Soummam', service: false, taille: '1 L'),
        codesSecondaires: ['2000000000015'],
        emballages: const [
          EmballageProduit(quantite: 6, prixVente: 550, codeBarres: '6130000000022'),
          null,
        ],
        stockInitial: 12,
        magasinCode: 'MAG0000',
      );
      expect((await repo.produitParCode(p.code))!.marque, 'Soummam');
      expect(await repo.codesSecondaires(p.code), ['2000000000015']);
      expect((await repo.produitParCodeBarres('2000000000015'))?.code, p.code);
      final emb = await s.emballages(p.code);
      expect(emb.single.quantite, 6);
      expect(emb.single.prixVente, 550);
      final mvt = await base.db.query('mouvement_stock', where: 'produit_code = ?', whereArgs: [p.code]);
      expect(mvt.single['quantite'], 12);
      // Un code secondaire déjà pris par un colis est refusé.
      await expectLater(
        s.creerProduit(_p(designation: 'Autre'), codesSecondaires: ['6130000000022']),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.codeBarresDejaUtilise)),
      );
      // Modification : remplacement des codes secondaires, emballage « Carton » ajouté.
      await s.modifierProduit(
        p,
        codesSecondaires: const [],
        emballages: const [
          EmballageProduit(quantite: 6, prixVente: 540),
          EmballageProduit(quantite: 24, prixVente: 2100),
        ],
      );
      expect(await repo.codesSecondaires(p.code), isEmpty);
      expect((await s.emballages(p.code)).map((c) => c.quantite), [6, 24]);

      final c = await s.creerCategorie('Laitiers', description: 'Lait et dérivés');
      final eau = await s.creerProduit(_p(designation: 'Eau'));
      final rem = await s.creerRemise(const Remise(code: '', designation: '-5 %', type: 'Pourcentage', valeur: 5));
      final sc = (await repo.sousCategories(c.code)).single;
      expect(await s.affecter([eau.code], sousCategorieCode: sc.code), 1);
      expect((await repo.produitParCode(eau.code))!.categorieCode, c.code);
      expect(await s.affecter([eau.code], remiseCode: rem.code), 1);
      expect((await repo.produitParCode(eau.code))!.remiseCode, rem.code);
      // Produit avec stock : suppression refusée ; produit sans mouvement : supprimé.
      await expectLater(
        s.supprimerProduits([p.code]),
        throwsA(isA<CatalogueException>().having((e) => e.erreur, 'e', ErreurCatalogue.produitUtilise)),
      );
      await s.supprimerProduits([eau.code]);
      expect(await repo.produitParCode(eau.code), isNull);
    });
  });

  group('ImportProduitsService', () {
    test('analyse et import depuis le modèle Excel', () async {
      final base = await ouvrirBaseDeTest();
      final catalogue = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final s = ImportProduitsService(base.db, catalogue: catalogue, margeDefautPct: 25);
      final lignes = await s.analyser(ImportProduitsService.modele());
      expect(lignes.length, 1);
      expect(lignes.first.designation, 'Exemple : Lait 1 L');
      expect(lignes.first.valide, isTrue);
      final rapport = await s.importer(lignes);
      expect(rapport.importees, 1);
      final p = await CatalogueRepository(base.db).produitParCodeBarres('6130000000015');
      expect(p!.prixVente, 100);
      expect(p.designationAr, 'حليب 1 ل', reason: 'colonne designation_ar du modèle');
      expect((await CatalogueRepository(base.db).categories()).any((c) => c.nom == 'Boissons'), isTrue);
      // Second import : code-barres déjà utilisé → ligne invalide
      final lignes2 = await s.analyser(ImportProduitsService.modele());
      expect(lignes2.first.erreur, 'code_barres_deja_utilise');
      expect((await s.importer(lignes2)).ignorees, 1);
      final stock = await base.db.query('mouvement_stock', where: 'produit_code = ?', whereArgs: [p.code]);
      expect(stock.single['quantite'], 24);
    });

    test('correspondance des colonnes : détection par en-tête puis choix manuel', () async {
      final base = await ouvrirBaseDeTest();
      final s = ImportProduitsService(base.db, catalogue: CatalogueService(base.db, utilisateurCode: 'USR0000'));
      final octets = ImportProduitsService.modele();
      final entetes = s.entetes(octets);
      expect(entetes.first, 'designation');
      final auto = s.correspondanceAuto(['Désignation', 'Prix de vente', 'Quantité', 'Nom arabe']);
      expect(auto['designation'], 0);
      expect(auto['prix_vente'], 1);
      expect(auto['stock'], 2);
      expect(auto['designation_ar'], 3);
      expect(auto['code_barres'], isNull);
      // Prix de vente ignoré, désignation lue dans la colonne « categorie ».
      final lignes = await s.analyser(octets, correspondance: {'designation': 3, 'prix_vente': null});
      expect(lignes.single.designation, 'Boissons');
      expect(lignes.single.prixVente, isNull);
    });
  });

  group('CatalogueIaService', () {
    test('cascade : première source qui répond, erreurs ignorées', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'caissedz.test') return http.Response('{}', 404);
        if (req.url.host == 'mantouj.test') throw Exception('réseau');
        if (req.url.host == 'world.openfoodfacts.org') {
          return http.Response(
            jsonEncode({
              'status': 1,
              'product': {'product_name_fr': 'Lait demi-écrémé', 'brands': 'Candia', 'categories': 'Boissons, Laits'},
            }),
            200,
          );
        }
        return http.Response('{"status":0}', 200);
      });
      final s = CatalogueIaService.parDefaut(
        client,
        urlCaisseDz: 'https://caissedz.test/p',
        urlMantouj: 'https://mantouj.test/p',
      );
      final f = await s.rechercher('3033490004743');
      expect(f!.designation, 'Lait demi-écrémé');
      expect(f.source, 'Open Food Facts');
      expect(f.categorie, 'Laits');
      final vide = await CatalogueIaService.parDefaut(MockClient((_) async => http.Response('{"status":0}', 200)))
          .rechercher('1');
      expect(vide, isNull);
    });

    test('source CaisseDZ prioritaire', () async {
      final client = MockClient(
        (req) async => http.Response(jsonEncode({'designation': 'Produit CDZ', 'prix_vente': 120}), 200),
      );
      final f = await CatalogueIaService.parDefaut(client, urlCaisseDz: 'https://caissedz.test/p').rechercher('123');
      expect(f!.source, 'CaisseDZ');
      expect(f.prixVente, 120);
    });
  });

  group('SynchroCatalogueService', () {
    test('non configurée puis synchronisation avec mise à jour locale', () async {
      final base = await ouvrirBaseDeTest();
      final catalogue = CatalogueService(base.db, utilisateurCode: 'USR0000');
      await catalogue.creerProduit(_p(cb: '6130000000015', pv: 100));
      final non = SynchroCatalogueService(
        base.db,
        client: MockClient((_) async => http.Response('', 500)),
        baseUrl: '',
      );
      expect((await non.synchroniser()).erreur, 'non_configuree');
      final client = MockClient((req) async {
        final corps = jsonDecode(req.body) as Map;
        expect((corps['produits'] as List).length, 1);
        return http.Response(
          jsonEncode({
            'produits': [
              {'code_barres': '6130000000015', 'designation': 'Lait 1 L (serveur)', 'image': 'https://x/lait.png'},
            ],
          }),
          200,
        );
      });
      final r = await SynchroCatalogueService(base.db, client: client, baseUrl: 'https://api.test').synchroniser();
      expect(r.ok, isTrue);
      expect(r.recus, 1);
      expect(
        (await CatalogueRepository(base.db).produitParCodeBarres('6130000000015'))!.designation,
        'Lait 1 L (serveur)',
      );
    });
  });

  group('EtiquettesPdf', () {
    test('génère un PDF non vide (A4 et rouleau, EAN-13, CODE128, QR)', () async {
      final p1 = _p(cb: '6130000000015', pv: 100).copyWith(designation: 'Lait');
      const p2 = Produit(
        code: 'PRD0002',
        designation: 'Interne',
        codeBarres: 'CDZ202610140001',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixVente: 50,
      );
      const g = EtiquettesPdf();
      final a4 = await g.plancheA4([
        Etiquette(produit: p1, quantite: 3),
        const Etiquette(produit: p2, quantite: 1, qr: true),
      ]);
      final rouleau = await g.rouleau(const [Etiquette(produit: p2, quantite: 2)]);
      expect(a4.length, greaterThan(1000));
      expect(rouleau.length, greaterThan(1000));
      expect(String.fromCharCodes(a4.take(5)), '%PDF-');
      expect(EtiquettesPdf.formaterPrix(1250.5, 'DA'), '1250,50 DA');
    });
  });
}
