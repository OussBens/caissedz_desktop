import 'dart:convert';

import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tendance_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/catalogue_rayons_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

/// Le serveur des tests : garde chaque envoi ; [code] HTTP de la réponse.
class _Serveur {
  final List<http.Request> envois = [];
  int code = 200;

  List<Map<String, Object?>> corps(int i) => [(jsonDecode(envois[i].body) as Map).cast<String, Object?>()];

  http.Client get client => MockClient((r) async {
    envois.add(r);
    if (code != 200) return http.Response('{"success":false,"error":"Licence"}', code);
    final j = jsonDecode(r.body) as Map;
    return http.Response(
      jsonEncode({
        'success': true,
        'data': {'ventes': (j['ventes'] as List).length, 'inconnus': 0, 'crees': (j['produits'] as List).length, 'completes': 0},
      }),
      200,
    );
  });
}

Produit _p(String designation, {String? cb, String? ar}) => Produit(
  code: '',
  designation: designation,
  designationAr: ar,
  codeBarres: cb,
  categorieCode: 'CATE0000',
  sousCategorieCode: 'SC0000',
  prixVente: 100,
);

/// Lait (EAN, nom arabe saisi), Eau (EAN), un code interne CDZ, un produit sans code-barres, et des ventes
/// sur plusieurs jours (dont une annulée et une trop ancienne).
Future<void> _jeu(Database db) async {
  final cat = CatalogueService(db, utilisateurCode: 'USR0000');
  final lait = await cat.creerProduit(_p('Lait', cb: '6130001000011', ar: 'حليب'));
  final eau = await cat.creerProduit(_p('Eau', cb: '3000000000002'));
  final interne = await cat.creerProduit(_p('Pain maison', cb: 'CDZ2610210001'));
  final vrac = await cat.creerProduit(_p('Olives vrac'));
  final stock = StockService(db, utilisateurCode: 'USR0000');
  for (final p in [lait, eau, interne, vrac]) {
    await stock.entrerStock(produitCode: p.code, magasinCode: 'MAG0000', quantite: 50);
  }
  final s = await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  var id = 0;
  Future<String> vendre(DateTime date, List<Produit> produits) async {
    var panier = Panier(id: ++id);
    for (final p in produits) {
      panier = panier.ajouter(PanierLigne(produit: p, quantite: 1, prixUnitaire: 100));
    }
    final v = await ventes.encaisser(
      panier.ajouterPaiement(Paiement(mode: 'Espèces', montant: 100.0 * produits.length)),
      session: s,
      magasinCode: 'MAG0000',
      date: date,
    );
    return v.code;
  }

  await vendre(DateTime(2026, 8, 1, 9), [lait]); // hors des 30 jours
  await vendre(DateTime(2026, 10, 19, 9), [lait, lait, eau]); // Lait deux fois sur le ticket : 1 ticket
  await vendre(DateTime(2026, 10, 19, 17), [lait, vrac]);
  await vendre(DateTime(2026, 10, 20, 10), [lait, interne]);
  final annulee = await vendre(DateTime(2026, 10, 20, 11), [eau]);
  await ventes.annuler(annulee, motif: 'Erreur');
}

TendanceService _service(Database db, _Serveur serveur, {String? cle = 'CLE-SIGNEE'}) => TendanceService(
  db,
  client: serveur.client,
  baseUrl: 'https://catalogue.test',
  identite: () async => (machine: 'machine-test', cle: cle),
);

void main() {
  group('TendanceService', () {
    test('tickets par jour et par code-barres, ventes validées, codes EAN seulement, licence du poste', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final serveur = _Serveur();
      final r = await _service(base.db, serveur).envoyer(maintenant: DateTime(2026, 10, 21, 12));
      expect(r, (ventes: 3, inconnus: 0, crees: 2, completes: 0));
      final envoi = serveur.envois.single;
      expect(envoi.url.toString(), 'https://catalogue.test/tendance');
      expect([envoi.headers['X-Device-Id'], envoi.headers['X-License-Key']], ['machine-test', 'CLE-SIGNEE']);
      final corps = serveur.corps(0).single;
      expect(corps['ventes'], [
        {'jour': '2026-10-19', 'code_barres': '3000000000002', 'tickets': 1},
        {'jour': '2026-10-19', 'code_barres': '6130001000011', 'tickets': 2},
        {'jour': '2026-10-20', 'code_barres': '6130001000011', 'tickets': 1},
      ]);
      // Fiches de la boutique (codes EAN seulement ; catégorie système non envoyée), avant les ventes.
      expect(corps['produits'], [
        {
          'code_barres': '3000000000002',
          'codes_barres': ['3000000000002'],
          'nom': 'Eau',
        },
        {
          'code_barres': '6130001000011',
          'codes_barres': ['6130001000011'],
          'nom': 'Lait',
          'nom_ar': 'حليب',
        },
      ]);
      expect(corps.keys, {'produits', 'confirmations', 'ventes'});
      expect(corps['confirmations'], isEmpty);
      for (final v in corps['ventes']! as List) {
        expect((v as Map).keys, {'jour', 'code_barres', 'tickets'}, reason: 'ni prix, ni quantités, ni clients');
      }
      expect(await ParametreRepository(base.db).lire(TendanceService.cleJour), '2026-10-21');
    });

    test('envoi suivant : depuis le dernier jour envoyé (compris), noms arabes modifiés seulement', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final serveur = _Serveur();
      final s = _service(base.db, serveur);
      await s.envoyer(maintenant: DateTime(2026, 10, 20, 8));
      expect((serveur.corps(0).single['ventes']! as List).map((v) => (v as Map)['jour']).toSet(), {
        '2026-10-19',
        '2026-10-20',
      });

      // Le 20 est renvoyé (il était peut-être incomplet) ; rien d'autre de neuf, le nom arabe déjà envoyé.
      await s.envoyer(maintenant: DateTime(2026, 10, 21, 12));
      final second = serveur.corps(1).single;
      expect(second['ventes'], [
        {'jour': '2026-10-20', 'code_barres': '6130001000011', 'tickets': 1},
      ]);
      expect(second['produits'], isEmpty, reason: 'fiches déjà envoyées');

      // Un nom arabe modifié repart ; rien à envoyer : aucune requête.
      final lait = (await base.db.query('produit', where: 'code_barres = ?', whereArgs: ['6130001000011'])).single;
      await base.db.update('produit', {'designation_ar': 'حليب كامل'}, where: 'code = ?', whereArgs: [lait['code']]);
      await s.envoyer(maintenant: DateTime(2026, 10, 25, 12));
      expect(serveur.corps(2).single['produits'], [
        {
          'code_barres': '6130001000011',
          'codes_barres': ['6130001000011'],
          'nom': 'Lait',
          'nom_ar': 'حليب كامل',
        },
      ]);
      expect(await s.envoyer(maintenant: DateTime(2026, 10, 25, 13)), (ventes: 0, inconnus: 0, crees: 0, completes: 0));
      expect(serveur.envois, hasLength(3));
    });

    test('fiche complète : marque, catégorie de la boutique, codes-barres secondaires EAN', () async {
      final base = await ouvrirBaseDeTest();
      final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final laitiers = await cat.creerCategorie('Laitiers');
      final sc = (await base.db.query('sous_categorie', where: 'categorie_code = ?', whereArgs: [laitiers.code])).first;
      await cat.creerProduit(
        Produit(
          code: '',
          designation: 'Lben Soummam 1L',
          designationAr: 'لبن الصومام',
          marque: 'Soummam',
          codeBarres: '6130003000019',
          categorieCode: laitiers.code,
          sousCategorieCode: sc['code']! as String,
        ),
        codesSecondaires: ['6130003000026', 'INT-42'],
      );
      await cat.creerProduit(
        const Produit(
          code: '',
          designation: 'Réparation',
          codeBarres: '6130009999999',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          service: true,
        ),
      );
      final serveur = _Serveur();
      await _service(base.db, serveur).envoyer(maintenant: DateTime(2026, 10, 21));
      expect(serveur.corps(0).single['produits'], [
        {
          'code_barres': '6130003000019',
          'codes_barres': ['6130003000019', '6130003000026'],
          'nom': 'Lben Soummam 1L',
          'nom_ar': 'لبن الصومام',
          'marque': 'Soummam',
          'categorie': 'Laitiers',
        },
      ], reason: 'le service et le code interne ne partent pas');
    });

    test('fiches venues du catalogue : pas renvoyées', () async {
      final base = await ouvrirBaseDeTest();
      await CatalogueRayonsRepository(base.db).insererProduits([
        (
          const Produit(
            code: 'PRD0100',
            designation: 'Selecto 1L',
            designationAr: 'سليكتو',
            codeBarres: '6130009000010',
            categorieCode: 'CATE0000',
            sousCategorieCode: 'SC0000',
            source: Produit.sourceCatalogue,
          ),
          const <String>[],
        ),
      ]);
      final serveur = _Serveur();
      expect(await _service(base.db, serveur).envoyer(maintenant: DateTime(2026, 10, 21)), isNotNull);
      expect(serveur.envois, isEmpty);
    });

    test('vote de confirmation : envoyé tout de suite ; hors ligne, gardé puis envoyé avec le rapport', () async {
      final base = await ouvrirBaseDeTest();
      final serveur = _Serveur();
      final s = _service(base.db, serveur);
      expect(await s.voter('6130007000015', 1), isTrue);
      expect(serveur.corps(0).single['confirmations'], [
        {'code_barres': '6130007000015', 'vote': 1},
      ]);
      expect(await ParametreRepository(base.db).lire(TendanceService.cleVotes), isNull, reason: 'reçu : plus en attente');
      expect(await s.voter('CDZ2610210001', 1), isFalse, reason: 'code interne');
      expect(await s.voter('6130007000015', 2), isFalse);
      expect(serveur.envois, hasLength(1));

      // Hors ligne : gardés (le dernier vote d'un code remplace le précédent).
      serveur.code = 503;
      expect(await s.voter('6130008000014', 1), isFalse);
      expect(await s.voter('6130008000014', -1), isFalse);
      expect(await s.voter('6130009000013', 1), isFalse);
      serveur.code = 200;
      await s.envoyer(maintenant: DateTime(2026, 10, 21));
      expect(serveur.corps(serveur.envois.length - 1).single['confirmations'], [
        {'code_barres': '6130008000014', 'vote': -1},
        {'code_barres': '6130009000013', 'vote': 1},
      ]);
      expect(await ParametreRepository(base.db).lire(TendanceService.cleVotes), isNull);
      expect(await _service(base.db, serveur, cle: null).voter('6130007000015', 1), isFalse, reason: 'sans licence : gardé');
      expect(await ParametreRepository(base.db).lire(TendanceService.cleVotes), isNotNull);
    });

    test('sans licence, refusé ou hors ligne : rien de marqué envoyé, tout repart la fois suivante', () async {
      final base = await ouvrirBaseDeTest();
      await _jeu(base.db);
      final serveur = _Serveur();
      expect(await _service(base.db, serveur, cle: null).envoyer(maintenant: DateTime(2026, 10, 21)), isNull);
      expect(serveur.envois, isEmpty);

      serveur.code = 401;
      expect(await _service(base.db, serveur).envoyer(maintenant: DateTime(2026, 10, 21)), isNull);
      expect(await ParametreRepository(base.db).lire(TendanceService.cleJour), isNull);

      final horsLigne = TendanceService(
        base.db,
        client: MockClient((_) async => throw http.ClientException('hors ligne')),
        identite: () async => (machine: 'machine-test', cle: 'CLE'),
      );
      expect(await horsLigne.envoyer(maintenant: DateTime(2026, 10, 21)), isNull);

      serveur.code = 200;
      await _service(base.db, serveur).envoyer(maintenant: DateTime(2026, 10, 21));
      expect((serveur.corps(serveur.envois.length - 1).single['ventes']! as List), hasLength(3));
    });
  });
}
