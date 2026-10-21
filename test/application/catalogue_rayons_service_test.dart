import 'dart:convert';

import 'package:caissedz_desktop/application/catalogue_rayons_service.dart';
import 'package:caissedz_desktop/core/catalogue/catalogue_rayons_api.dart';
import 'package:caissedz_desktop/core/licence/compte_bens_api.dart';
import 'package:caissedz_desktop/data/alertes_repository.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/historique_repository.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/rayon_catalogue.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';
import '../helpers/licence_test_helper.dart';

http.Response _json(Object corps, [int code = 200]) =>
    http.Response(jsonEncode(corps), code, headers: {'content-type': 'application/json; charset=utf-8'});

Map<String, Object?> _p(String cb, String nom, {List<String> autres = const [], String? photo}) => {
  'id': cb.hashCode,
  'code_barres': cb,
  'codes_barres': [cb, ...autres],
  'nom': nom,
  'marque': 'Hamoud',
  'photo': photo,
};

/// Le catalogue des tests : Boissons (3 produits, 2 pages de 2), Laitiers (1 produit).
class _Catalogue {
  final List<Uri> appels = [];
  bool enPanne = false;

  static const rayons = [
    {'code': 'boissons', 'nom_fr': 'Boissons', 'nom_ar': 'المشروبات', 'nom_en': 'Drinks', 'icone': 'cup-soda', 'ordre': 80, 'produits': 3},
    {'code': 'laitiers', 'nom_fr': 'Produits laitiers & œufs', 'nom_ar': 'مشتقات الحليب', 'nom_en': 'Dairy', 'icone': 'milk', 'ordre': 90, 'produits': 1},
  ];

  final pages = <String, List<List<Map<String, Object?>>>>{
    'boissons': [
      [
        _p('6130001000011', 'Selecto 1L', autres: ['6130001000028'], photo: 'https://catalog-api.bensds.com/uploads/photos/1.jpg'),
        _p('6130002000010', 'Hamoud Boualem 2L'),
      ],
      [
        _p('3000000000002', 'Cola 33cl'),
        {'code_barres': '', 'codes_barres': <String>[], 'nom': 'Sans code-barres'},
      ],
    ],
    'laitiers': [
      [_p('6130003000019', 'Lben Soummam 1L')],
    ],
  };

  CatalogueRayonsApi get api => CatalogueRayonsApi(
    baseUrl: 'https://catalogue.test',
    client: MockClient((r) async {
      appels.add(r.url);
      if (enPanne) throw http.ClientException('hors ligne');
      final s = r.url.pathSegments;
      if (s.length == 1 && s[0] == 'rayons') {
        return _json({
          'success': true,
          'data': {'plafond': 2000, 'rayons': rayons},
        });
      }
      if (s.length == 3 && s[0] == 'rayons' && s[2] == 'products') {
        final p = pages[s[1]]!;
        final page = int.parse(r.url.queryParameters['page']!);
        return _json({
          'success': true,
          'data': {
            'rayon': s[1],
            'total': p.fold(0, (n, x) => n + x.length),
            'page': page,
            'limit': 500,
            'total_pages': p.length,
            'products': page <= p.length ? p[page - 1] : const [],
          },
        });
      }
      return _json({'success': false, 'error': 'Route non trouvée'}, 404);
    }),
  );
}

Future<List<Produit>> _produitsCatalogue(DatabaseExecutor db) async =>
    (await CatalogueRepository(db).produits()).where((p) => p.duCatalogue).toList();

void main() {
  group('CatalogueRayonsService', () {
    test('rayons : noms FR/AR/EN, icône, produits proposés', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueRayonsService(base.db, api: _Catalogue().api, utilisateurCode: 'USR0000');
      final rayons = await s.rayons();
      expect(rayons.map((r) => r.code), ['boissons', 'laitiers']);
      expect([rayons.first.nom('ar'), rayons.first.nom('en'), rayons.first.nom('fr')], ['المشروبات', 'Drinks', 'Boissons']);
      expect([rayons.first.icone, rayons.first.produits], ['cup-soda', 3]);
      expect(await s.estPropose(), isFalse);
    });

    test('télécharger : sans prix ni stock, une catégorie par rayon, codes secondaires, bilan et %', () async {
      final base = await ouvrirBaseDeTest();
      final catalogue = _Catalogue();
      final s = CatalogueRayonsService(base.db, api: catalogue.api, utilisateurCode: 'USR0000');
      final progres = <ProgresTelechargement>[];
      final bilan = await s.telecharger(await s.rayons(), onProgres: progres.add);

      // Boissons : 4 reçus (2 pages), 3 ajoutés, 1 sans code-barres ignoré ; Laitiers : 1 sur 1.
      expect(bilan.rayons.map((r) => (r.rayon.code, r.disponibles, r.telecharges, r.ignores)), [
        ('boissons', 4, 3, 1),
        ('laitiers', 1, 1, 0),
      ]);
      expect([bilan.disponibles, bilan.telecharges, bilan.pourcentage], [5, 4, 80]);
      expect(bilan.rayons.first.pourcentage, 75);
      expect(progres.last.recus, 5);
      expect(progres.last.attendus, 4, reason: 'annoncés par les rayons');
      expect(catalogue.appels.where((u) => u.path == '/rayons/boissons/products').map((u) => u.queryParameters['page']), [
        '1',
        '2',
      ]);

      final produits = await _produitsCatalogue(base.db);
      expect(produits.map((p) => p.designation), containsAll(['Selecto 1L', 'Hamoud Boualem 2L', 'Cola 33cl', 'Lben Soummam 1L']));
      final selecto = produits.firstWhere((p) => p.designation == 'Selecto 1L');
      expect([selecto.prixAchat, selecto.prixVente, selecto.codeBarres, selecto.marque], [0, 0, '6130001000011', 'Hamoud']);
      expect(selecto.image, 'https://catalog-api.bensds.com/uploads/photos/1.jpg');
      expect(await CatalogueRepository(base.db).codesSecondaires(selecto.code), ['6130001000028']);
      expect((await CatalogueRepository(base.db).produitParCodeBarres('6130001000028'))!.code, selecto.code);
      expect(produits.map((p) => p.code).toSet().length, 4, reason: 'codes PRD uniques');
      expect(produits.every((p) => CodeGeneratorTest.estProduit(p.code)), isTrue);

      // Une catégorie (et sa sous-catégorie) par rayon, au nom FR du rayon.
      final categories = {for (final c in await CatalogueRepository(base.db).categories()) c.code: c.nom};
      expect(categories[selecto.categorieCode], 'Boissons');
      final lben = produits.firstWhere((p) => p.designation == 'Lben Soummam 1L');
      expect(categories[lben.categorieCode], 'Produits laitiers & œufs');
      expect(
        (await CatalogueRepository(base.db).sousCategories(selecto.categorieCode)).single.code,
        selecto.sousCategorieCode,
      );

      // Aucun stock ; l'écran ne sera plus proposé à la connexion ; le journal le garde.
      expect(await base.db.query('mouvement_stock'), isEmpty);
      expect(await s.estPropose(), isTrue);
      final journal = await HistoriqueRepository(base.db).lire();
      expect(journal.where((h) => h.action == 'Téléchargement catalogue').length, 2);
    });

    test('un second téléchargement : même catégorie, seulement les nouveaux produits ; rien en double', () async {
      final base = await ouvrirBaseDeTest();
      final catalogue = _Catalogue();
      final s = CatalogueRayonsService(base.db, api: catalogue.api, utilisateurCode: 'USR0000');
      final rayons = await s.rayons();
      // Le commerce vendait déjà Cola (code-barres saisi à la main) et avait une catégorie « Boissons ».
      final cat = await CatalogueRepository(base.db).prochainCode('categorie', 'CATE');
      await base.db.insert('categorie', {'code': cat, 'nom': 'boissons', 'systeme': 0});
      await base.db.insert('sous_categorie', {'code': 'SC0042', 'categorie_code': cat, 'nom': 'Sodas', 'systeme': 0});
      await CatalogueRepository(base.db).insererProduit(
        const Produit(
          code: 'PRD0007',
          designation: 'Coca 33',
          codeBarres: '3000000000002',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixVente: 80,
        ),
      );

      final premier = await s.telecharger([rayons.first]);
      expect([premier.rayons.single.telecharges, premier.rayons.single.dejaPresents], [2, 1]);
      final selecto = (await CatalogueRepository(base.db).produitParCodeBarres('6130001000011'))!;
      expect([selecto.categorieCode, selecto.sousCategorieCode], [cat, 'SC0042'], reason: 'la catégorie de même nom');
      expect(selecto.code, 'PRD0008', reason: 'après le dernier code');
      expect((await CatalogueRepository(base.db).produitParCodeBarres('3000000000002'))!.designation, 'Coca 33');

      // Le catalogue a un nouveau produit : seul lui est ajouté, dans la même catégorie.
      catalogue.pages['boissons']!.last.add(_p('6130004000018', 'Ifri 1,5L'));
      final second = await s.telecharger([rayons.first]);
      expect([second.rayons.single.telecharges, second.rayons.single.dejaPresents], [1, 3]);
      expect((await CatalogueRepository(base.db).produitParCodeBarres('6130004000018'))!.categorieCode, cat);
      final lignes = await base.db.query('catalogue_rayon');
      expect([lignes.single['telecharges'], lignes.single['disponibles']], [3, 5]);
      expect((await _produitsCatalogue(base.db)).length, 3);
    });

    test('catalogue injoignable : exception, rien d’écrit', () async {
      final base = await ouvrirBaseDeTest();
      final catalogue = _Catalogue();
      final s = CatalogueRayonsService(base.db, api: catalogue.api, utilisateurCode: 'USR0000');
      final rayons = await s.rayons();
      catalogue.enPanne = true;
      await expectLater(
        s.telecharger(rayons),
        throwsA(isA<CatalogueRayonsException>().having((e) => e.erreur, 'erreur', ErreurCatalogueRayons.reseau)),
      );
      await expectLater(s.rayons(), throwsA(isA<CatalogueRayonsException>()));
      expect(await _produitsCatalogue(base.db), isEmpty);
      expect(await base.db.query('catalogue_rayon'), isEmpty);
      expect(await s.estPropose(), isFalse);
    });

    test('alertes : un produit du catalogue jamais entré en stock n’est pas une rupture', () async {
      final base = await ouvrirBaseDeTest();
      final s = CatalogueRayonsService(base.db, api: _Catalogue().api, utilisateurCode: 'USR0000');
      await s.telecharger(await s.rayons());
      expect(await AlertesRepository(base.db).ruptures(seuilGlobal: 5), isEmpty);
      final selecto = (await CatalogueRepository(base.db).produitParCodeBarres('6130001000011'))!;
      await StockRepository(base.db).insererMouvement(
        MouvementStock(
          date: DateTime(2026, 10, 20),
          produitCode: selecto.code,
          magasinCode: 'MAG0000',
          type: TypesMouvement.entree,
          quantite: 2,
          utilisateurCode: 'USR0000',
        ),
      );
      expect((await AlertesRepository(base.db).ruptures(seuilGlobal: 5)).map((r) => r['code']), [selecto.code]);
    });
  });

  group('LicenceService.signalerChoixCatalogue', () {
    test('envoyé à BENS avec la session ; hors ligne, gardé et renvoyé au check-in suivant', () async {
      final base = await ouvrirBaseDeTest();
      final recus = <Map<String, Object?>>[];
      var horsLigne = true;
      final api = CompteBensApi(
        baseUrl: 'https://bens.test/api',
        client: MockClient((r) async {
          if (horsLigne) throw http.ClientException('hors ligne');
          if (r.url.path.endsWith('/catalog-choice')) {
            expect(r.headers['Authorization'], 'Bearer jeton-1');
            recus.add((jsonDecode(r.body) as Map).cast());
            return _json({'ok': true, 'id': 'x'}, 201);
          }
          return _json({'device': codePosteTest(), 'entitlements': <String, Object?>{}});
        }),
      );
      final s = await licenceServiceTest(base, api: api);
      await LicenceRepository(base.db).ecrireValeur(LicenceRepository.cleJeton, 'jeton-1');
      final choix = [
        {'code': 'boissons', 'name': 'Boissons', 'available': 2000, 'downloaded': 1900},
      ];

      await s.signalerChoixCatalogue(choix);
      expect(recus, isEmpty);
      expect(await LicenceRepository(base.db).lireValeur(LicenceRepository.cleChoixCatalogue), isNotNull);

      horsLigne = false;
      await s.synchroniser();
      expect(recus, [
        {'rayons': choix},
      ]);
      expect(await LicenceRepository(base.db).lireValeur(LicenceRepository.cleChoixCatalogue), isNull);
      await s.synchroniser();
      expect(recus.length, 1, reason: 'envoyé une fois');
    });
  });

  test('ParametreRepository : la proposition est une valeur du commerce', () async {
    final base = await ouvrirBaseDeTest();
    await CatalogueRayonsService(base.db, api: _Catalogue().api, utilisateurCode: 'USR0000').marquerPropose();
    expect(await ParametreRepository(base.db).lire(CatalogueRayonsService.clePropose), '1');
  });
}

/// Codes produits `PRD` + 4 chiffres (§8.10).
class CodeGeneratorTest {
  static bool estProduit(String code) => RegExp(r'^PRD\d{4,}$').hasMatch(code);
}
