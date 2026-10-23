import 'dart:convert';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/catalogue_rayons_service.dart';
import 'package:caissedz_desktop/core/catalogue/catalogue_rayons_api.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/features/catalogue_rayons/catalogue_rayons_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/app_test_helper.dart';

http.Response _json(Object corps) =>
    http.Response(jsonEncode(corps), 200, headers: {'content-type': 'application/json; charset=utf-8'});

Map<String, Object?> _p(String cb, String nom) => {
  'code_barres': cb,
  'codes_barres': [cb],
  'nom': nom,
};

/// Boissons : 4 proposés, 3 avec code-barres ; Laitiers : 1 ; Papeterie : aucun (« Bientôt »).
CatalogueRayonsApi _api({bool enPanne = false}) => CatalogueRayonsApi(
  baseUrl: 'https://catalogue.test',
  client: MockClient((r) async {
    if (enPanne) throw http.ClientException('hors ligne');
    final s = r.url.pathSegments;
    if (s.length == 1) {
      return _json({
        'success': true,
        'data': {
          'plafond': 2000,
          'rayons': [
            {'code': 'boissons', 'nom_fr': 'Boissons', 'nom_ar': 'المشروبات', 'icone': 'cup-soda', 'produits': 4},
            {'code': 'laitiers', 'nom_fr': 'Produits laitiers & œufs', 'icone': 'milk', 'produits': 1},
            {'code': 'papeterie', 'nom_fr': 'Papeterie & fournitures', 'icone': 'pencil', 'produits': 0},
          ],
        },
      });
    }
    final produits = switch (s[1]) {
      'boissons' => [
        _p('6130001000011', 'Selecto 1L'),
        _p('6130002000010', 'Hamoud 2L'),
        _p('3000000000002', 'Cola 33cl'),
        {'code_barres': '', 'nom': 'Sans code'},
      ],
      _ => [_p('6130003000019', 'Lben 1L')],
    };
    return _json({
      'success': true,
      'data': {'total': produits.length, 'page': 1, 'total_pages': 1, 'products': produits},
    });
  }),
);

void main() {
  const dialog = ValueKey('dialog_catalogue_rayons');
  const appliquer = ValueKey('rayons_appliquer');

  Future<void> connecterAdmin(WidgetTester tester) async {
    await choisirCompte(tester, motDePasseAdmin);
    await clic(tester, find.byKey(const ValueKey('bouton_connexion')));
  }

  String compteur(WidgetTester tester) => tester.widget<Text>(find.byKey(const ValueKey('rayons_compteur'))).data!;

  group('Rayons du catalogue BENS à la première connexion', () {
    testWidgets('choisir, appliquer : le bilan (ajoutés, %), puis la Caisse', (tester) async {
      final c = await pumpApp(
        tester,
        etat: EtatApp.configuree,
        sequence: true,
        catalogueRayons: true,
        taille: const Size(1400, 900),
        overrides: [catalogueRayonsApiProvider.overrideWithValue(_api())],
      );
      await connecterAdmin(tester);
      expect(find.byKey(dialog), findsOneWidget);
      expect(find.text('Choisissez vos rayons'), findsOneWidget);
      expect(find.text('4 produits'), findsOneWidget);
      expect(find.text('Bientôt'), findsOneWidget);
      expect(tester.widget<DsButton>(find.byKey(appliquer)).onPressed, isNull, reason: 'aucun rayon choisi');
      expect(compteur(tester), 'Aucun rayon choisi');

      await clic(tester, find.byKey(const ValueKey('rayon_boissons')));
      expect(compteur(tester), '1 rayon · 4 produits');
      await clic(tester, find.byKey(const ValueKey('rayon_papeterie')));
      expect(compteur(tester), '1 rayon · 4 produits', reason: 'un rayon vide ne se choisit pas');
      await clic(tester, find.byKey(const ValueKey('rayons_tout')));
      expect(compteur(tester), '2 rayons · 5 produits');

      await clic(tester, find.byKey(appliquer));
      expect(find.byKey(const ValueKey('dialog_catalogue_rayons_bilan')), findsOneWidget);
      expect(find.text('4 produits ajoutés à votre catalogue : 80 % des produits des rayons choisis.'), findsOneWidget);
      expect(find.text('3 / 4 · 75 %'), findsOneWidget);
      expect(find.text('1 / 1 · 100 %'), findsOneWidget);

      await clic(tester, find.byKey(const ValueKey('rayons_continuer')));
      expect(find.byKey(const ValueKey('dialog_catalogue_rayons_bilan')), findsNothing);
      expect(routeCourante(c), '/caisse');
      final db = c.read(appDatabaseProvider).db;
      expect((await CatalogueRepository(db).produits()).where((p) => p.duCatalogue).length, 4);
      expect(await ParametreRepository(db).lire(CatalogueRayonsService.clePropose), '1');
    });

    testWidgets('« Plus tard » : rien n’est téléchargé, plus proposé à la connexion', (tester) async {
      final c = await pumpApp(
        tester,
        etat: EtatApp.configuree,
        sequence: true,
        catalogueRayons: true,
        taille: const Size(1400, 900),
        overrides: [catalogueRayonsApiProvider.overrideWithValue(_api())],
      );
      await connecterAdmin(tester);
      await clic(tester, find.byKey(const ValueKey('rayons_plus_tard')));
      expect(find.byKey(dialog), findsNothing);
      expect(routeCourante(c), '/caisse');
      final db = c.read(appDatabaseProvider).db;
      expect(await ParametreRepository(db).lire(CatalogueRayonsService.clePropose), '1');
      expect((await CatalogueRepository(db).produits()).where((p) => p.duCatalogue), isEmpty);
    });

    testWidgets('hors ligne : le message et « Réessayer »', (tester) async {
      await pumpApp(
        tester,
        etat: EtatApp.configuree,
        sequence: true,
        catalogueRayons: true,
        taille: const Size(1400, 900),
        overrides: [catalogueRayonsApiProvider.overrideWithValue(_api(enPanne: true))],
      );
      await connecterAdmin(tester);
      expect(find.byKey(dialog), findsOneWidget);
      expect(find.textContaining('Le catalogue BENS est injoignable'), findsOneWidget);
      expect(find.byKey(const ValueKey('rayons_reessayer')), findsOneWidget);
    });
  });

  testWidgets('plus tard : le catalogue BENS s’ouvre depuis Paramètres, plus depuis Produits', (tester) async {
    final c = await pumpApp(
      tester,
      routeInitiale: '/produits',
      taille: const Size(1600, 1000),
      overrides: [catalogueRayonsApiProvider.overrideWithValue(_api())],
    );
    expect(find.byKey(const ValueKey('produits_catalogue_bens')), findsNothing);
    expect(find.byKey(const ValueKey('produits_importer')), findsNothing);

    c.read(routerProvider).go('/parametres');
    await tester.pumpAndSettle();
    final bouton = find.byKey(const ValueKey('param_catalogue_bens'));
    await tester.ensureVisible(bouton);
    await clic(tester, bouton);
    expect(find.byKey(dialog), findsOneWidget);
    expect(find.text('Choisissez vos rayons'), findsOneWidget);
  });
}
