import 'dart:convert';

import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/tendance_service.dart';
import 'package:caissedz_desktop/data/catalogue_rayons_repository.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/bases.dart';
import '../helpers/licence_test_helper.dart';

http.Response _json(Object corps) =>
    http.Response(jsonEncode(corps), 200, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  test('au lancement : fiches et ventes envoyées, puis produits devenus tendance ajoutés', () async {
    final base = await ouvrirBaseDeTest();
    final appels = <http.Request>[];
    final client = MockClient((r) async {
      appels.add(r);
      if (r.url.path == '/tendance') {
        return _json({
          'success': true,
          'data': {'ventes': 0, 'inconnus': 0, 'crees': 1, 'completes': 0},
        });
      }
      if (r.url.path == '/rayons/boissons/products') {
        return _json({
          'success': true,
          'data': {
            'rayon': 'boissons',
            'total': 1,
            'page': 1,
            'limit': 500,
            'total_pages': 1,
            'products': [
              {
                'code_barres': '6130005000017',
                'codes_barres': ['6130005000017'],
                'nom': 'Rouiba 1L',
                'nom_ar': 'رويبة',
                'tendance': true,
              },
            ],
          },
        });
      }
      return http.Response('{"success":false}', 404);
    });
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(base),
        licenceServiceProvider.overrideWithValue(await licenceServiceTest(base)),
        httpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(c.dispose);
    final repo = CatalogueRepository(base.db);
    await repo.insererProduit(
      const Produit(
        code: 'PRD0001',
        designation: 'Lait',
        designationAr: 'حليب',
        codeBarres: '6130001000011',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
      ),
    );
    await CatalogueRayonsRepository(base.db).enregistrer(
      rayonCode: 'boissons',
      nom: 'Boissons',
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
      disponibles: 0,
      ajoutes: 0,
      le: DateTime(2026, 10, 20),
    );

    // Sans licence : rien ne part.
    await synchroniserAuLancement(c);
    expect(appels, isEmpty);

    await c.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.basic));
    final version = c.read(catalogueVersionProvider);
    await synchroniserAuLancement(c);
    expect(appels.map((r) => r.url.path), ['/tendance', '/rayons/boissons/products']);
    expect(appels.first.headers['X-Device-Id'], machineTest);
    expect((jsonDecode(appels.first.body) as Map)['produits'], [
      {
        'code_barres': '6130001000011',
        'codes_barres': ['6130001000011'],
        'nom': 'Lait',
        'nom_ar': 'حليب',
      },
    ]);
    expect(appels.last.url.queryParameters['depuis'], '2026-10-20');
    expect((await repo.produitParCodeBarres('6130005000017'))!.designationAr, 'رويبة');
    expect(c.read(catalogueVersionProvider), greaterThan(version), reason: 'listes de produits rafraîchies');
    expect(await ParametreRepository(base.db).lire(TendanceService.cleJour), isNotNull);
  });
}
