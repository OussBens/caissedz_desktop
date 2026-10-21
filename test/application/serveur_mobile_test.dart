import 'dart:convert';
import 'dart:io';

import 'package:caissedz_desktop/application/role_service.dart';
import 'package:caissedz_desktop/application/serveur_mobile.dart';
import 'package:caissedz_desktop/application/utilisateur_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/domain/models/licence.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../helpers/bases.dart';

/// Le téléphone vu par les tests : appairé, puis connecté.
class _Telephone {
  _Telephone(this.port);
  final int port;
  String? appareil;
  String? jeton;

  Uri _uri(String chemin) => Uri.parse('http://127.0.0.1:$port/api/v1/$chemin');

  Map<String, String> get _entetes => {
    'content-type': 'application/json',
    ServeurMobile.enteteAppareil: ?appareil,
    if (jeton != null) 'authorization': 'Bearer $jeton',
  };

  Future<(int, Map<String, dynamic>)> get(String chemin) async {
    final r = await http.get(_uri(chemin), headers: _entetes);
    return (r.statusCode, jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<(int, Map<String, dynamic>)> post(String chemin, [Object? corps]) async {
    final r = await http.post(
      _uri(chemin),
      headers: _entetes,
      body: corps is List<int> ? corps : jsonEncode(corps ?? const {}),
    );
    return (r.statusCode, jsonDecode(r.body) as Map<String, dynamic>);
  }
}

void main() {
  late AppDatabase base;
  late ServeurMobile serveur;
  late Directory factures;
  var licence = const Licence(niveau: NiveauLicence.basic);
  final modifications = <DomaineMobile>{};
  final recues = <FactureMobile>[];

  setUp(() async {
    base = await ouvrirBaseDeTest();
    factures = Directory.systemTemp.createTempSync('caissedz_factures_');
    addTearDown(() => factures.deleteSync(recursive: true));
    licence = const Licence(niveau: NiveauLicence.basic);
    modifications.clear();
    recues.clear();
    serveur = ServeurMobile(
      base.db,
      licence: () => licence,
      dossierFactures: factures.path,
      surModification: modifications.addAll,
      surFacture: recues.add,
      portPrefere: 0,
    );
    await serveur.demarrer(adresse: InternetAddress.loopbackIPv4);
    addTearDown(serveur.arreter);
  });

  /// Le téléphone scanne le QR personnel de [utilisateur] : il est appairé et connecté avec ce compte.
  Future<_Telephone> appairer({String utilisateur = 'USR0000'}) async {
    final t = _Telephone(serveur.port!);
    final code = serveur.nouveauCodeAppairage(utilisateur).code;
    final (statut, r) = await t.post('appairer', {'code': code, 'nom': 'Pixel', 'plateforme': 'android'});
    expect(statut, 200, reason: '$r');
    t.appareil = '${r['appareil']}.${r['jeton']}';
    t.jeton = (r['session'] as Map<String, dynamic>)['jeton'] as String;
    return t;
  }

  Future<_Telephone> connecter() => appairer();

  Future<String> creerKarim({Set<Permission> permissions = const {}}) async {
    final role = await RoleService(
      base.db,
      utilisateurCode: 'USR0000',
    ).creer(nom: 'Vendeur', modules: const {'ventes', 'stock'}, permissions: permissions);
    final karim = await UtilisateurService(base.db, utilisateurCode: 'USR0000').creer(
      identifiant: 'karim',
      nom: 'Karim',
      telephone: '0661112233',
      roleCode: role.code,
      magasins: const ['MAG0000'],
      motDePasse: 'Karim2026',
    );
    return karim.code;
  }

  test('adresses du QR : le Wi-Fi d’abord, le partage de connexion en dernier, sans cartes virtuelles', () {
    expect(
      ServeurMobile.ordonnerAdresses(const [
        (interface: 'vEthernet (WSL (Hyper-V firewall))', adresse: '172.18.64.1'),
        (interface: 'Ethernet', adresse: '192.168.137.1'),
        (interface: 'Ethernet 2', adresse: '10.0.0.4'),
        (interface: 'Wi-Fi', adresse: '172.20.10.3'),
        (interface: 'VirtualBox Host-Only Network', adresse: '192.168.56.1'),
        (interface: 'Ethernet 3', adresse: '192.168.1.20'),
        (interface: 'Wi-Fi 2', adresse: '172.20.10.3'),
      ]),
      ['172.20.10.3', '192.168.1.20', '10.0.0.4', '192.168.137.1'],
    );
  });

  test('appairage : le QR personnel connecte le téléphone avec ce compte, une seule fois', () async {
    final t = _Telephone(serveur.port!);
    expect((await t.post('appairer', {'code': 'faux'})).$1, 403);
    expect((await t.post('connexion')).$1, 401);

    final code = serveur.nouveauCodeAppairage('USR0000').code;
    final (statut, r) = await t.post('appairer', {'code': code, 'nom': 'Pixel', 'plateforme': 'android'});
    expect(statut, 200, reason: '$r');
    final session = r['session'] as Map<String, dynamic>;
    expect(session['utilisateur']['code'], 'USR0000');
    t.appareil = '${r['appareil']}.${r['jeton']}';
    t.jeton = session['jeton'] as String;
    expect((await t.get('moi')).$2['utilisateur']['identifiant'], 'admin');
    expect(modifications, contains(DomaineMobile.appareils));
    final ligne = (await base.db.query('appareil_mobile')).single;
    expect(ligne['utilisateur_code'], 'USR0000');
    // Le téléphone vient de répondre : il est affiché « Connecté » sur le poste.
    expect(serveur.appareilsConnectes(), {r['appareil']});
    expect(serveur.appareilsConnectes(delai: Duration.zero), isEmpty);

    // Usage unique : un second téléphone ne peut pas réutiliser le même QR.
    expect((await _Telephone(serveur.port!).post('appairer', {'code': code})).$2['erreur'], 'codeInvalide');
  });

  test('chaque utilisateur a son QR ; un nouveau QR remplace le précédent, la déconnexion l’annule', () async {
    final karim = await creerKarim(permissions: const {Permission.utiliserMobile});
    final admin1 = serveur.nouveauCodeAppairage('USR0000').code;
    final codeKarim = serveur.nouveauCodeAppairage(karim).code;
    final admin2 = serveur.nouveauCodeAppairage('USR0000').code;
    final t = _Telephone(serveur.port!);
    expect((await t.post('appairer', {'code': admin1})).$2['erreur'], 'codeInvalide');
    final (_, r) = await t.post('appairer', {'code': codeKarim});
    expect(r['session']['utilisateur']['code'], karim);
    serveur.annulerCodeAppairage('USR0000');
    expect((await t.post('appairer', {'code': admin2})).$2['erreur'], 'codeInvalide');
  });

  test('QR de l’Admin : l’Admin choisit sur le poste l’utilisateur du téléphone ; refus et autres QR', () async {
    final karim = await creerKarim(permissions: const {Permission.utiliserMobile});
    final demandes = <DemandeAppairage>[];
    String? reponse = karim;
    final avecChoix = ServeurMobile(
      base.db,
      licence: () => licence,
      dossierFactures: factures.path,
      choisirUtilisateur: (d) async {
        demandes.add(d);
        return reponse;
      },
      portPrefere: 0,
    );
    await avecChoix.demarrer(adresse: InternetAddress.loopbackIPv4);
    addTearDown(avecChoix.arreter);
    final t = _Telephone(avecChoix.port!);
    final (statut, r) = await t.post('appairer', {
      'code': avecChoix.nouveauCodeAppairage('USR0000').code,
      'nom': 'Samsung SM-A515F',
      'plateforme': 'android',
      'systeme': 'Android 14',
      'version': '1.2.0',
    });
    expect(statut, 200, reason: '$r');
    expect(r['session']['utilisateur']['code'], karim, reason: 'le téléphone s’ouvre avec le compte choisi');
    final d = demandes.single;
    expect((d.nom, d.systeme, d.version, d.administrateur), ('Samsung SM-A515F', 'Android 14', '1.2.0', 'USR0000'));
    expect(d.adresse, '127.0.0.1');
    final ligne = (await base.db.query('appareil_mobile')).single;
    expect((ligne['utilisateur_code'], ligne['cree_par']), (karim, 'USR0000'));

    // Refusé par l’Admin : aucun appareil de plus.
    reponse = null;
    final refus = await _Telephone(avecChoix.port!)
        .post('appairer', {'code': avecChoix.nouveauCodeAppairage('USR0000').code, 'nom': 'Pixel'});
    expect((refus.$1, refus.$2['erreur']), (403, 'appairageRefuse'));
    expect(await base.db.query('appareil_mobile'), hasLength(1));

    // Le QR d’un autre utilisateur : le téléphone s’ouvre avec ce compte, sans rien demander.
    final (_, r2) = await _Telephone(avecChoix.port!)
        .post('appairer', {'code': avecChoix.nouveauCodeAppairage(karim).code, 'nom': 'iPhone'});
    expect(r2['session']['utilisateur']['code'], karim);
    expect(demandes, hasLength(2));
  });

  test('reconnexion sans mot de passe : le jeton d’appareil rouvre la session de son utilisateur', () async {
    final t = await appairer();
    final ancien = t.jeton;
    t.jeton = null;
    final (statut, r) = await t.post('connexion');
    expect(statut, 200, reason: '$r');
    expect(r['utilisateur']['code'], 'USR0000');
    t.jeton = r['jeton'] as String;
    expect((await t.get('accueil')).$1, 200);
    // La session précédente de ce téléphone est fermée.
    t.jeton = ancien;
    expect((await t.get('accueil')).$2['erreur'], 'sessionExpiree');
  });

  test('un rôle sans la permission « Application mobile » est refusé, avec elle il entre', () async {
    final karim = await creerKarim();
    final refus = _Telephone(serveur.port!);
    final (statut, r) = await refus.post('appairer', {'code': serveur.nouveauCodeAppairage(karim).code});
    expect(statut, 403);
    expect(r['erreur'], 'nonAutorise');
    expect(await base.db.query('appareil_mobile'), isEmpty);

    final role = (await base.db.query('utilisateur', where: 'code = ?', whereArgs: [karim])).single['role_code']!;
    Future<void> permission(Set<Permission> p) => RoleService(
      base.db,
      utilisateurCode: 'USR0000',
    ).modifier(role as String, nom: 'Vendeur', modules: const {'ventes', 'stock'}, permissions: p);
    await permission(const {Permission.utiliserMobile});
    final t = await appairer(utilisateur: karim);
    expect((await t.get('ventes')).$1, 200);
    // Pas le module Produits : création refusée.
    expect((await t.post('produits', {'designation': 'X'})).$2['erreur'], 'moduleInterdit');

    // Permission retirée : le téléphone ne rouvre plus de session ; compte désactivé non plus.
    await permission(const {});
    expect((await t.post('connexion')).$2['erreur'], 'nonAutorise');
    await UtilisateurService(base.db, utilisateurCode: 'USR0000').desactiver([karim]);
    expect((await t.post('connexion')).$2['erreur'], 'compteInactif');
  });

  test(
    'produit rapide avec stock initial, puis entrée rapide (session de caisse ouverte depuis le téléphone)',
    () async {
      final t = await connecter();
      final (statut, cree) = await t.post('produits', {
        'designation': 'Lait 1L',
        'codeBarres': '6130000000017',
        'prixAchat': 80,
        'prixVente': 100,
        'stockInitial': 10,
      });
      expect(statut, 200, reason: '$cree');
      final produit = cree['produit'] as Map<String, dynamic>;
      expect(produit['stock'], 10);
      expect(modifications, containsAll([DomaineMobile.catalogue, DomaineMobile.stock]));

      final (_, parCode) = await t.get('produits/code-barres/6130000000017');
      expect(parCode['produit']['designation'], 'Lait 1L');
      expect((await t.get('produits/code-barres/000')).$1, 404);

      final entree = {'produitCode': produit['code'], 'quantite': 5, 'prixAchat': 85};
      final (refus, erreur) = await t.post('entrees/rapide', entree);
      expect(refus, 422);
      expect(erreur['erreur'], 'sessionRequise');

      final (_, caisse) = await t.get('session-caisse');
      expect(caisse['ouverte'], isFalse);
      final premiere = (caisse['caisses'] as List).first['code'];
      expect((await t.post('session-caisse', {'caisseCode': premiere, 'fond': 0})).$2['ouverte'], isTrue);

      final (ok, r) = await t.post('entrees/rapide', entree);
      expect(ok, 200, reason: '$r');
      final (_, apres) = await t.get('produits/${produit['code']}');
      expect(apres['produit']['stock'], 15);
      expect(apres['produit']['prixAchat'], 85);

      // L'audit des écritures du téléphone revient ensuite à l'utilisateur du poste (aucun ici).
      final audit = await base.db.query('audit_contexte');
      expect(audit.first['utilisateur_code'], isNull);
    },
  );

  test('vente depuis le téléphone : article scanné au prix de la caisse, panier encaissé, stock sorti', () async {
    final t = await connecter();
    final (_, cree) = await t.post('produits', {
      'designation': 'Lait 1L',
      'codeBarres': '6130000000017',
      'prixAchat': 80,
      'prixVente': 100,
      'stockInitial': 10,
    });
    final code = (cree['produit'] as Map<String, dynamic>)['code'] as String;
    final (statut, a) = await t.get('caisse/article/6130000000017');
    expect(statut, 200, reason: '$a');
    final article = a['article'] as Map<String, dynamic>;
    expect((article['type'], article['code'], article['stock']), ('produit', code, 10));
    final prix = (article['prix'] as num).toDouble();
    expect(prix, greaterThanOrEqualTo(100), reason: 'prix TTC de la caisse');
    expect((await t.get('caisse/article/000')).$2['erreur'], 'produitInconnu');
    expect((await t.get('caisse')).$2['modes'], contains('Espèces'));

    final panier = {
      'lignes': [
        {'type': 'produit', 'code': code, 'quantite': 3},
      ],
      'mode': 'Espèces',
      'montant': 1000,
    };
    // Comme à la caisse : une session ouverte est exigée.
    expect((await t.post('ventes', panier)).$2['erreur'], 'sessionRequise');
    final premiere = ((await t.get('session-caisse')).$2['caisses'] as List).first['code'];
    await t.post('session-caisse', {'caisseCode': premiere, 'fond': 0});
    // Pas de crédit depuis le téléphone.
    expect((await t.post('ventes', {...panier, 'montant': 10})).$2['erreur'], 'paiementInsuffisant');
    // Le stock est gardé par l'encaissement.
    final trop = {
      ...panier,
      'montant': 100000,
      'lignes': [
        {'type': 'produit', 'code': code, 'quantite': 50},
      ],
    };
    expect((await t.post('ventes', trop)).$2['erreur'], 'stockInsuffisant');

    final (ok, r) = await t.post('ventes', panier);
    expect(ok, 200, reason: '$r');
    final vente = r['vente'] as Map<String, dynamic>;
    expect(vente['total'], closeTo(prix * 3, 0.01));
    expect(vente['monnaie'], closeTo(1000 - prix * 3, 0.01));
    expect((await t.get('produits/$code')).$2['produit']['stock'], 7);
    expect(modifications, containsAll([DomaineMobile.stock, DomaineMobile.commerce]));
    expect((await t.get('ventes')).$2['ventes'], hasLength(1));
  });

  test('facture photographiée : rangée et déposée dans la file Smart Scan', () async {
    final t = await connecter();
    final (statut, r) = await t.post('factures', List<int>.filled(2048, 7));
    expect(statut, 200, reason: '$r');
    final bon = await base.db.query('bon_reception');
    expect(bon, hasLength(1));
    expect(bon.first['statut'], 'Reçu');
    expect(File(bon.first['chemin_photo']! as String).lengthSync(), 2048);
    expect((await t.get('factures')).$2['factures'], hasLength(1));
    // Le poste l'annonce (pop-up avec accès à Smart Scan).
    expect(recues.single.bon, bon.first['code']);
    expect(recues.single.utilisateur, isNotEmpty);
  });

  test('lecture seule : on consulte, on n’écrit plus ; sans licence, rien', () async {
    final t = await connecter();
    licence = const Licence(niveau: null, motif: MotifLicence.expiree);
    expect((await t.get('produits')).$1, 200);
    expect((await t.post('produits', {'designation': 'X'})).$2['erreur'], 'lectureSeule');
    licence = Licence.aucune;
    expect((await t.get('produits')).$2['erreur'], 'licence');
  });

  test('le téléphone se délie lui-même (« Changer d’ordinateur »)', () async {
    final t = await connecter();
    expect((await t.post('oublier')).$1, 200);
    expect(await base.db.query('appareil_mobile'), isEmpty);
    expect((await t.get('accueil')).$2['erreur'], 'appareilInconnu');
  });

  test('révocation : le téléphone n’est plus reconnu', () async {
    final t = await connecter();
    final code = t.appareil!.split('.').first;
    await base.db.delete('appareil_mobile', where: 'code = ?', whereArgs: [code]);
    serveur.fermerSessionsAppareil(code);
    expect((await t.get('accueil')).$2['erreur'], 'appareilInconnu');
  });
}
