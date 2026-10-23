import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import '../data/boutique_repository.dart';
import '../data/caisse_repository.dart';
import '../data/catalogue_repository.dart';
import '../data/client_repository.dart';
import '../data/mobile_repository.dart';
import '../data/parametre_repository.dart';
import '../data/stock_repository.dart';
import '../data/tiers_repository.dart';
import '../data/utilisateur_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/achat.dart';
import '../domain/models/licence.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/produit.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import '../domain/referentiel/referentiel.dart';
import 'achat_service.dart';
import 'auth_service.dart';
import 'catalogue_ia_service.dart';
import 'catalogue_service.dart';
import 'session_caisse_service.dart';
import 'stock_service.dart';
import 'vente_mobile_service.dart';
import 'vente_service.dart';

/// Ce qui a changé après une écriture venue du téléphone (pour rafraîchir les écrans du poste).
enum DomaineMobile { catalogue, stock, commerce, appareils }

/// Facture photographiée reçue du téléphone : le bon déposé dans la file Smart Scan et qui l'a envoyée.
class FactureMobile {
  const FactureMobile({required this.bon, required this.utilisateur});
  final String bon;
  final String utilisateur;
}

/// Erreur renvoyée au téléphone : statut HTTP + code stable (traduit côté mobile).
class ErreurApiMobile implements Exception {
  const ErreurApiMobile(this.statut, this.code, [this.detail]);
  final int statut;
  final String code;
  final String? detail;
  @override
  String toString() => 'ErreurApiMobile($statut, $code${detail == null ? '' : ', $detail'})';
}

/// Téléphone qui vient de scanner le QR de l'administrateur : le poste lui demande quel utilisateur ouvrira
/// l'application sur ce téléphone ([ServeurMobile.choisirUtilisateur]).
class DemandeAppairage {
  const DemandeAppairage({
    required this.nom,
    required this.plateforme,
    required this.administrateur,
    this.modele = '',
    this.systeme = '',
    this.version = '',
    this.adresse = '',
  });

  /// Nom du téléphone (« Samsung SM-A515F »), `android` ou `ios`, modèle, système (« Android 14 »), version de
  /// l'application et adresse IP sur le réseau local (ce que le téléphone a envoyé).
  final String nom;
  final String plateforme;
  final String modele;
  final String systeme;
  final String version;
  final String adresse;

  /// Code de l'administrateur dont le QR a été scanné.
  final String administrateur;
}

/// Code d'appairage du QR personnel d'un utilisateur : valable [ServeurMobile.dureeCodeAppairage], une fois.
class CodeAppairage {
  const CodeAppairage(this.code, this.expireLe, this.utilisateurCode);
  final String code;
  final DateTime expireLe;

  /// Utilisateur qui affiche le QR : le téléphone qui le scanne lui appartient.
  final String utilisateurCode;
  bool get valide => DateTime.now().isBefore(expireLe);
}

class _SessionMobile {
  _SessionMobile(this.session, this.appareil) : vuLe = DateTime.now();
  final Session session;
  final String appareil;

  /// Dernière requête du téléphone : la session expire [ServeurMobile.dureeSession] après.
  DateTime vuLe;
  DateTime get expireLe => vuLe.add(ServeurMobile.dureeSession);
}

/// Serveur de l'application mobile CaisseDZ Scan, sur le réseau local du poste (HTTP + JSON, `/api/v1`).
///
/// 1. Appairage : un utilisateur autorisé (Admin, ou rôle avec `utiliserMobile`) affiche sur le poste son QR
///    personnel (adresses, port, code d'appairage à usage unique). Le téléphone qui le scanne reçoit un jeton
///    d'appareil (`X-CaisseDZ-Appareil: <code>.<jeton>`) lié à cet utilisateur, et sa première session. Le QR de
///    l'Admin ouvre sur le poste le choix de l'utilisateur du téléphone ([choisirUtilisateur]) : la réponse
///    attend ce choix ([dureeChoixUtilisateur] au plus). Le même téléphone appairé de nouveau (même
///    `identifiant` d'installation, ou à défaut même utilisateur, nom et plateforme) remplace son ancien appairage.
/// 2. Connexion : le téléphone rouvre une session (`Authorization: Bearer`, en mémoire) pour son utilisateur
///    avec le seul jeton d'appareil — aucun mot de passe ne passe sur le réseau. L'Admin, ou l'utilisateur
///    lui-même, révoque le téléphone ; un compte désactivé ou privé de la permission n'entre plus.
/// 3. Lectures (ventes, produits et stock) et écritures (produit rapide ou IA, entrée rapide, facture
///    déposée dans la file Smart Scan) passent par les services du poste, avec les droits du rôle.
class ServeurMobile {
  ServeurMobile(
    this.db, {
    required this.licence,
    required this.dossierFactures,
    this.catalogueIa,
    this.utilisateurPoste,
    this.surModification,
    this.surFacture,
    this.choisirUtilisateur,
    this.portPrefere = portParDefaut,
  });

  final Database db;

  /// Licence courante du poste (pas d'accès sans licence ; en lecture seule, aucune écriture).
  final Licence Function() licence;

  /// Dossier où sont rangées les factures photographiées sur le téléphone.
  final String dossierFactures;
  final CatalogueIaService Function()? catalogueIa;

  /// Utilisateur connecté sur le poste : contexte d'audit rétabli après une écriture du téléphone.
  final String? Function()? utilisateurPoste;
  final void Function(Set<DomaineMobile> domaines)? surModification;

  /// Une facture photographiée vient d'arriver du téléphone (le poste l'annonce).
  final void Function(FactureMobile facture)? surFacture;

  /// QR de l'Admin scanné : l'utilisateur qui ouvrira l'application sur ce téléphone, choisi sur le poste (`null` :
  /// refusé). Sans ce choix (tests, poste sans écran), le téléphone se connecte avec le compte de l'Admin.
  final Future<String?> Function(DemandeAppairage demande)? choisirUtilisateur;
  final int portPrefere;

  static const int portParDefaut = 8787;
  static const int versionApi = 1;
  static const Duration dureeCodeAppairage = Duration(minutes: 10);

  /// Le téléphone attend au plus ce délai que l'Admin choisisse son utilisateur sur le poste.
  static const Duration dureeChoixUtilisateur = Duration(minutes: 2);
  static const Duration dureeSession = Duration(hours: 12);
  static const int tailleMaxFacture = 15 * 1024 * 1024;
  static const String enteteAppareil = 'x-caissedz-appareil';

  HttpServer? _serveur;

  /// Codes d'appairage en cours, un par utilisateur.
  final Map<String, CodeAppairage> _codes = {};
  final Map<String, _SessionMobile> _sessions = {};
  Future<void> _verrou = Future.value();
  final Random _aleatoire = Random.secure();

  bool get demarre => _serveur != null;
  int? get port => _serveur?.port;

  MobileRepository get _repo => MobileRepository(db);

  /// Démarre l'écoute sur toutes les interfaces IPv4 ([portPrefere], sinon les 10 suivants, sinon un port libre).
  Future<int> demarrer({InternetAddress? adresse}) async {
    if (_serveur != null) return _serveur!.port;
    final hote = adresse ?? InternetAddress.anyIPv4;
    HttpServer? s;
    for (var port = portPrefere; port <= portPrefere + 10 && s == null; port++) {
      try {
        s = await HttpServer.bind(hote, port);
      } on SocketException {
        continue;
      }
    }
    s ??= await HttpServer.bind(hote, 0);
    _serveur = s;
    s.listen((r) => unawaited(_traiter(r)));
    developer.log('Serveur mobile démarré sur le port ${s.port}', name: 'caissedz.mobile');
    return s.port;
  }

  Future<void> arreter() async {
    final s = _serveur;
    _serveur = null;
    _sessions.clear();
    _codes.clear();
    await s?.close(force: true);
  }

  /// Nouveau code d'appairage pour le QR personnel de [utilisateurCode] (son précédent n'est plus accepté).
  CodeAppairage nouveauCodeAppairage(String utilisateurCode) {
    _codes.removeWhere((_, c) => !c.valide);
    return _codes[utilisateurCode] = CodeAppairage(_jeton(18), DateTime.now().add(dureeCodeAppairage), utilisateurCode);
  }

  /// Le QR de [utilisateurCode] n'est plus accepté (il s'est déconnecté du poste).
  void annulerCodeAppairage(String utilisateurCode) => _codes.remove(utilisateurCode);

  /// Adresses IPv4 du poste sur le réseau local, pour le QR (voir [ordonnerAdresses]).
  static Future<List<String>> adressesLocales() async {
    try {
      return ordonnerAdresses([
        for (final i in await NetworkInterface.list(type: InternetAddressType.IPv4))
          for (final a in i.addresses)
            if (!a.isLoopback && !a.isLinkLocal) (interface: i.name, adresse: a.address),
      ]);
    } on Object {
      return const [];
    }
  }

  /// Cartes virtuelles (WSL, Hyper-V, VirtualBox, VMware, Docker) : injoignables depuis un téléphone.
  static final RegExp _interfaceVirtuelle = RegExp(
    r'vEthernet|WSL|Hyper-V|VirtualBox|VMware|vmnet|Docker|vboxnet|Loopback',
    caseSensitive: false,
  );
  static final RegExp _interfaceWifi = RegExp(r'Wi-?Fi|WLAN|Wireless|sans fil', caseSensitive: false);

  /// Adresses à mettre dans le QR, la plus probable d'abord : le Wi-Fi (le téléphone y est), puis les autres
  /// cartes (192.168.x, 10.x, puis le reste), le partage de connexion de Windows (192.168.137.x) en dernier.
  /// Les cartes virtuelles sont écartées.
  static List<String> ordonnerAdresses(List<({String interface, String adresse})> cartes) {
    int rang(({String interface, String adresse}) c) {
      final a = c.adresse;
      if (_interfaceWifi.hasMatch(c.interface)) return 0;
      if (a.startsWith('192.168.137.')) return 4;
      return a.startsWith('192.168.') ? 1 : (a.startsWith('10.') ? 2 : 3);
    }

    final retenues = [
      for (final (i, c) in cartes.indexed)
        if (!_interfaceVirtuelle.hasMatch(c.interface)) (i, rang(c), c.adresse),
    ];
    // À rang égal, l'ordre de Windows est conservé (le tri de Dart n'est pas stable).
    retenues.sort((x, y) => x.$2 != y.$2 ? x.$2.compareTo(y.$2) : x.$1.compareTo(y.$1));
    return {for (final (_, _, adresse) in retenues) adresse}.toList();
  }

  /// Contenu du QR code d'appairage de l'utilisateur [utilisateur] (son nom, affiché par le téléphone).
  static String contenuQr({
    required List<String> adresses,
    required int port,
    required String code,
    required String boutique,
    required String utilisateur,
  }) => jsonEncode({
    't': 'caissedz-scan',
    'v': versionApi,
    'h': adresses,
    'p': port,
    'c': code,
    'n': boutique,
    'u': utilisateur,
  });

  /// Téléphones connectés : une session ouverte et une requête depuis moins de [delai].
  Set<String> appareilsConnectes({Duration delai = const Duration(minutes: 5)}) {
    final limite = DateTime.now().subtract(delai);
    return {
      for (final s in _sessions.values)
        if (s.vuLe.isAfter(limite)) s.appareil,
    };
  }

  /// Ferme les sessions ouvertes depuis [appareil] (révocation).
  void fermerSessionsAppareil(String appareil) => _sessions.removeWhere((_, s) => s.appareil == appareil);

  String _jeton(int octets) =>
      base64Url.encode(List<int>.generate(octets, (_) => _aleatoire.nextInt(256))).replaceAll('=', '');

  static String _empreinte(String jeton) => sha256.convert(utf8.encode(jeton)).toString();

  // ———————————————————————————— Requêtes ————————————————————————————

  Future<void> _traiter(HttpRequest r) async {
    final res = r.response;
    res.headers.set('Cache-Control', 'no-store');
    try {
      final corps = await _router(r);
      _repondre(res, 200, corps);
    } on ErreurApiMobile catch (e) {
      _repondre(res, e.statut, {'erreur': e.code, 'detail': ?e.detail});
    } on FormatException catch (e) {
      _repondre(res, 400, {'erreur': 'requeteInvalide', 'detail': e.message});
    } on Object catch (e, pile) {
      developer.log('Erreur du serveur mobile', name: 'caissedz.mobile', error: e, stackTrace: pile);
      _repondre(res, 500, {'erreur': 'serveur', 'detail': '$e'});
    }
  }

  void _repondre(HttpResponse res, int statut, Object corps) {
    try {
      res.statusCode = statut;
      res.headers.contentType = ContentType.json;
      res.write(jsonEncode(corps));
      unawaited(res.close());
    } on Object {
      // Le téléphone a coupé la connexion.
    }
  }

  Future<Map<String, Object?>> _router(HttpRequest r) async {
    final segments = r.uri.pathSegments;
    if (segments.length < 2 || segments[0] != 'api' || segments[1] != 'v$versionApi') {
      throw const ErreurApiMobile(404, 'introuvable');
    }
    final chemin = segments.skip(2).toList();
    final m = r.method;
    final route = chemin.isEmpty ? '' : chemin.first;

    if (m == 'GET' && route == 'info') return _info();
    if (m == 'POST' && route == 'appairer') {
      return _appairer(await _json(r), adresse: r.connectionInfo?.remoteAddress.address ?? '');
    }

    final appareil = await _appareil(r);
    if (m == 'POST' && route == 'connexion') return _connecter(appareil);
    if (m == 'POST' && route == 'oublier') return _oublier(appareil);

    final s = _session(r, appareil);
    if (m == 'POST' && route == 'deconnexion') {
      _sessions.remove(_bearer(r));
      return const {'ok': true};
    }
    switch ((m, route, chemin.length)) {
      case ('GET', 'moi', 1):
        return _profil(s);
      case ('GET', 'accueil', 1):
        return _accueil(s);
      case ('GET', 'ventes', 1):
        _module(s, 'ventes');
        return _ventes(s, r.uri.queryParameters);
      case ('POST', 'ventes', 1):
        _module(s, 'caisse');
        return _ecrire(s, () async => _vendre(s, await _json(r)), const {DomaineMobile.stock, DomaineMobile.commerce});
      case ('GET', 'caisse', 1):
        _module(s, 'caisse');
        return _caisse(s);
      case ('GET', 'caisse', 3) when chemin[1] == 'article':
        _module(s, 'caisse');
        return _articleCaisse(s, chemin[2]);
      case ('GET', 'ventes', 2):
        _module(s, 'ventes');
        return _vente(s, chemin[1]);
      case ('GET', 'references', 1):
        return _references(s);
      case ('GET', 'produits', 1):
        _moduleUn(s, const ['stock', 'produits', 'entrees']);
        return _produits(s, r.uri.queryParameters);
      case ('GET', 'produits', 3) when chemin[1] == 'code-barres':
        _moduleUn(s, const ['stock', 'produits', 'entrees']);
        return _produitParCodeBarres(s, chemin[2]);
      case ('GET', 'produits', 2):
        _moduleUn(s, const ['stock', 'produits', 'entrees']);
        return _produit(s, chemin[1]);
      case ('POST', 'produits', 1):
        _module(s, 'produits');
        return _ecrire(s, () async => _creerProduit(s, await _json(r)), {DomaineMobile.catalogue, DomaineMobile.stock});
      case ('GET', 'catalogue-ia', 2):
        _module(s, 'produits');
        return _rechercherIa(chemin[1]);
      case ('GET', 'session-caisse', 1):
        _module(s, 'entrees');
        return _sessionCaisse(s);
      case ('POST', 'session-caisse', 1):
        _module(s, 'entrees');
        return _ecrire(s, () async => _ouvrirSessionCaisse(s, await _json(r)), {DomaineMobile.commerce});
      case ('POST', 'entrees', 2) when chemin[1] == 'rapide':
        _module(s, 'entrees');
        return _ecrire(s, () async => _entreeRapide(s, await _json(r)), const {
          DomaineMobile.catalogue,
          DomaineMobile.stock,
          DomaineMobile.commerce,
        });
      case ('GET', 'factures', 1):
        _module(s, 'entrees');
        return _factures(s);
      case ('POST', 'factures', 1):
        _module(s, 'entrees');
        return _ecrire(s, () => _deposerFacture(s, r), {DomaineMobile.commerce});
    }
    throw const ErreurApiMobile(404, 'introuvable');
  }

  Future<Map<String, Object?>> _json(HttpRequest r) async {
    final texte = await utf8.decodeStream(r);
    if (texte.trim().isEmpty) return const {};
    final v = jsonDecode(texte);
    if (v is! Map<String, Object?>) throw const FormatException('objet JSON attendu');
    return v;
  }

  // ———————————————————————————— Accès ————————————————————————————

  Licence _licenceValable() {
    final l = licence();
    if (!l.peutOuvrir) throw const ErreurApiMobile(403, 'licence');
    return l;
  }

  Future<String> _appareil(HttpRequest r) async {
    final valeur = r.headers.value(enteteAppareil) ?? '';
    final i = valeur.indexOf('.');
    if (i <= 0) throw const ErreurApiMobile(401, 'appareilInconnu');
    final code = valeur.substring(0, i);
    final empreinte = await _repo.empreinteJeton(code);
    if (empreinte == null || empreinte != _empreinte(valeur.substring(i + 1))) {
      throw const ErreurApiMobile(401, 'appareilInconnu');
    }
    return code;
  }

  String? _bearer(HttpRequest r) {
    final v = r.headers.value(HttpHeaders.authorizationHeader) ?? '';
    return v.startsWith('Bearer ') ? v.substring(7).trim() : null;
  }

  Session _session(HttpRequest r, String appareil) {
    final jeton = _bearer(r);
    final s = jeton == null ? null : _sessions[jeton];
    if (s == null || s.appareil != appareil) throw const ErreurApiMobile(401, 'sessionExpiree');
    if (DateTime.now().isAfter(s.expireLe)) {
      _sessions.remove(jeton);
      throw const ErreurApiMobile(401, 'sessionExpiree');
    }
    s.vuLe = DateTime.now();
    _licenceValable();
    return s.session;
  }

  void _module(Session s, String module) {
    if (!s.peutAcceder(module)) throw ErreurApiMobile(403, 'moduleInterdit', module);
  }

  void _moduleUn(Session s, List<String> modules) {
    if (!modules.any(s.peutAcceder)) throw ErreurApiMobile(403, 'moduleInterdit', modules.first);
  }

  /// Écriture du téléphone : refusée en lecture seule, une à la fois, avec l'utilisateur du téléphone comme
  /// contexte d'audit (rétabli ensuite sur celui du poste), puis les écrans du poste sont rafraîchis.
  Future<Map<String, Object?>> _ecrire(
    Session s,
    Future<Map<String, Object?>> Function() action,
    Set<DomaineMobile> domaines,
  ) {
    if (licence().lectureSeule) throw const ErreurApiMobile(403, 'lectureSeule');
    final resultat = Completer<Map<String, Object?>>();
    _verrou = _verrou.then((_) async {
      final audit = UtilisateurRepository(db);
      try {
        await audit.definirAuditContexte(s.utilisateur.code);
        resultat.complete(await action());
        surModification?.call(domaines);
      } on Object catch (e, pile) {
        resultat.completeError(_traduire(e), pile);
      } finally {
        await audit.definirAuditContexte(utilisateurPoste?.call());
      }
    });
    return resultat.future;
  }

  /// Exceptions des services → erreurs de l'API (codes stables).
  static Object _traduire(Object e) => switch (e) {
    ErreurApiMobile() => e,
    AchatException(:final erreur) => ErreurApiMobile(422, erreur.name, e.detail),
    CatalogueException(:final erreur) => ErreurApiMobile(422, erreur.name),
    SessionException(:final erreur) => ErreurApiMobile(422, erreur.name),
    StockException(:final erreur) => ErreurApiMobile(422, erreur.name, e.detail),
    VenteException(:final erreur) => ErreurApiMobile(422, erreur.name, e.detail),
    _ => e,
  };

  // ———————————————————————————— Appairage et connexion ————————————————————————————

  Future<String> _nomBoutique() async => (await BoutiqueRepository(db).lire())?.nom ?? 'CaisseDZ';

  Future<Map<String, Object?>> _info() async => {
    'app': 'caissedz',
    'api': versionApi,
    'boutique': await _nomBoutique(),
    'poste': Platform.localHostname,
  };

  /// Le téléphone a scanné le QR personnel d'un utilisateur : il lui est lié et sa session est ouverte. Le QR de
  /// l'Admin : le téléphone est lié à l'utilisateur que l'Admin choisit sur le poste ; celui d'un autre
  /// utilisateur : à ce seul utilisateur (celui dont la session est ouverte sur le poste).
  Future<Map<String, Object?>> _appairer(Map<String, Object?> corps, {String adresse = ''}) async {
    _licenceValable();
    final code = _codes.values.where((c) => c.code == corps['code']).firstOrNull;
    if (code == null || !code.valide) throw const ErreurApiMobile(403, 'codeInvalide');
    // Usage unique : un QR photographié par un tiers ne relie pas un second téléphone.
    _codes.remove(code.utilisateurCode);
    await _exigerAutorise(code.utilisateurCode);
    String texte(String cle, [int max = 60]) {
      final v = '${corps[cle] ?? ''}'.trim();
      return v.length > max ? v.substring(0, max) : v;
    }

    final nom = texte('nom');
    var utilisateur = code.utilisateurCode;
    final choix = choisirUtilisateur;
    if (choix != null && ((await UtilisateurRepository(db).parCode(utilisateur))?.estAdmin ?? false)) {
      final choisi = await choix(
        DemandeAppairage(
          nom: nom.isEmpty ? 'Téléphone' : nom,
          plateforme: texte('plateforme', 20),
          modele: texte('modele'),
          systeme: texte('systeme'),
          version: texte('version', 20),
          adresse: adresse,
          administrateur: utilisateur,
        ),
      ).timeout(dureeChoixUtilisateur, onTimeout: () => null);
      if (choisi == null) throw const ErreurApiMobile(403, 'appairageRefuse');
      await _exigerAutorise(choisi);
      utilisateur = choisi;
    }
    final appareil = 'APP${_jeton(6).toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '')}';
    final jeton = _jeton(32);
    final identifiant = texte('identifiant', 64);
    final nomAppareil = nom.isEmpty ? 'Téléphone' : nom;
    final plateforme = texte('plateforme', 20);
    // Le même téléphone appairé de nouveau (QR rescanné, autre utilisateur) : son ancien appairage est remplacé,
    // il n'apparaît qu'une fois dans la liste du poste.
    final remplaces = await db.transaction((txn) async {
      final repo = MobileRepository(txn);
      final anciens = await repo.precedents(
        identifiant: identifiant.isEmpty ? null : identifiant,
        utilisateurCode: utilisateur,
        nom: nomAppareil,
        plateforme: plateforme,
      );
      for (final a in anciens) {
        await repo.revoquer(a);
      }
      await repo.insererAppareil(
        code: appareil,
        utilisateurCode: utilisateur,
        nom: nomAppareil,
        plateforme: plateforme,
        identifiant: identifiant.isEmpty ? null : identifiant,
        modele: texte('modele'),
        jetonHash: _empreinte(jeton),
        creePar: code.utilisateurCode,
      );
      return anciens;
    });
    remplaces.forEach(fermerSessionsAppareil);
    return {
      'appareil': appareil,
      'jeton': jeton,
      'boutique': await _nomBoutique(),
      'poste': Platform.localHostname,
      'session': await _ouvrirSession(appareil, utilisateur),
    };
  }

  /// Compte actif ayant droit au mobile (Admin, ou rôle avec `utiliserMobile`).
  Future<void> _exigerAutorise(String utilisateurCode) async {
    final u = await UtilisateurRepository(db).parCode(utilisateurCode);
    if (u == null || !u.actif) throw const ErreurApiMobile(403, 'compteInactif');
    if (!await _repo.estAutorise(utilisateurCode)) throw const ErreurApiMobile(403, 'nonAutorise');
  }

  static Map<String, Object?> _utilisateurJson(Utilisateur u) => {
    'code': u.code,
    'identifiant': u.identifiant,
    'nom': u.nomComplet.isEmpty ? u.identifiant : u.nomComplet,
    'role': u.roleNom ?? '',
    'admin': u.estAdmin,
  };

  /// Nouvelle session pour l'utilisateur du téléphone (après un redémarrage du poste, ou 12 h sans usage).
  Future<Map<String, Object?>> _connecter(String appareil) async {
    _licenceValable();
    final utilisateur = (await _repo.appareil(appareil))?.utilisateurCode;
    if (utilisateur == null) throw const ErreurApiMobile(401, 'appareilInconnu');
    await _exigerAutorise(utilisateur);
    return _ouvrirSession(appareil, utilisateur);
  }

  /// Ouvre la session de [utilisateurCode] sur [appareil] (les précédentes de ce téléphone sont fermées).
  Future<Map<String, Object?>> _ouvrirSession(String appareil, String utilisateurCode) async {
    final Session? session;
    try {
      session = await AuthService(db).reprendreSession(utilisateurCode);
    } finally {
      // AuthService écrit le contexte d'audit : celui du poste est rétabli.
      await UtilisateurRepository(db).definirAuditContexte(utilisateurPoste?.call());
    }
    if (session == null) throw const ErreurApiMobile(403, 'compteInactif');
    fermerSessionsAppareil(appareil);
    final jeton = _jeton(32);
    _sessions[jeton] = _SessionMobile(session, appareil);
    await _repo.enregistrerAcces(appareil, utilisateurCode: utilisateurCode);
    surModification?.call(const {DomaineMobile.appareils});
    return {'jeton': jeton, ...await _profil(session)};
  }

  /// Le téléphone se délie lui-même (« Changer d'ordinateur ») : il disparaît de la liste du poste.
  Future<Map<String, Object?>> _oublier(String appareil) async {
    await _repo.revoquer(appareil);
    fermerSessionsAppareil(appareil);
    surModification?.call(const {DomaineMobile.appareils});
    return const {'ok': true};
  }

  Future<Map<String, Object?>> _profil(Session s) async {
    final l = licence();
    final vente = await _parametresVente();
    return {
      'utilisateur': _utilisateurJson(s.utilisateur),
      'permissions': [for (final p in s.permissions) p.code],
      'modules': s.modulesAutorises?.toList(),
      'magasins': [
        for (final m in await _magasinsVisibles(s)) {'code': m.code, 'nom': m.nom},
      ],
      'magasinPrincipal': await StockService(
        db,
        utilisateurCode: s.utilisateur.code,
      ).magasinPrincipal(s.utilisateur.code),
      'devise': vente.devise,
      'lectureSeule': l.lectureSeule,
      'boutique': await _nomBoutique(),
    };
  }

  Future<ParametresVente> _parametresVente() async =>
      ParametresVente.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresVente.cles));

  /// Magasins consultables (§6.2) : tous pour l'Admin ou `voirStockTousMagasins`, sinon ceux de l'utilisateur.
  Future<List<({String code, String nom})>> _magasinsVisibles(Session s) async {
    final repo = StockRepository(db);
    final actifs = await repo.magasins(actifsSeulement: true);
    final siens = await repo.magasinsUtilisateur(s.utilisateur.code);
    final tous = siens.isEmpty || s.estAdmin || s.a(Permission.voirStockTousMagasins);
    return [
      for (final m in actifs)
        if (tous || siens.contains(m.code)) (code: m.code, nom: m.nom),
    ];
  }

  // ———————————————————————————— Lectures ————————————————————————————

  Future<Map<String, Object?>> _accueil(Session s) async {
    final maintenant = DateTime.now();
    final jour = await _repo.ventesDepuis(DateTime(maintenant.year, maintenant.month, maintenant.day));
    final vente = await _parametresVente();
    final magasins = [for (final m in await _magasinsVisibles(s)) m.code];
    final niveaux = await _stocks(magasins);
    var sousSeuil = 0;
    for (final pr in await CatalogueRepository(db).produits(actifsSeulement: true)) {
      if (pr.service) continue;
      if ((niveaux[pr.code] ?? 0) <= (pr.seuilStock ?? vente.seuilStockGlobal)) sousSeuil++;
    }
    final bons = await db.rawQuery('SELECT COUNT(*) n FROM bon_reception WHERE statut = ? AND utilisateur_code = ?', [
      StatutsBon.recu,
      s.utilisateur.code,
    ]);
    final session = await SessionCaisseService(db, utilisateurCode: s.utilisateur.code).courante();
    return {
      if (s.peutAcceder('ventes')) 'ventesJour': {'total': jour.total, 'nombre': jour.nombre},
      'sousSeuil': sousSeuil,
      'facturesEnAttente': bons.first['n'],
      'sessionCaisse': session == null ? null : {'code': session.code, 'caisse': session.caisseCode},
    };
  }

  /// Stock par produit sur [magasins].
  Future<Map<String, double>> _stocks(List<String> magasins) async {
    if (magasins.isEmpty) return const {};
    final rows = await db.rawQuery(
      'SELECT produit_code, SUM(quantite) q FROM mouvement_stock '
      'WHERE magasin_code IN (${List.filled(magasins.length, '?').join(',')}) GROUP BY produit_code',
      magasins,
    );
    return {for (final r in rows) r['produit_code']! as String: (r['q']! as num).toDouble()};
  }

  Future<Map<String, Object?>> _ventes(Session s, Map<String, String> q) async {
    final jour = DateTime.tryParse(q['jour'] ?? '');
    final depuis = jour ?? DateTime.tryParse(q['depuis'] ?? '');
    final jusqua = jour?.add(const Duration(days: 1)) ?? DateTime.tryParse(q['jusqua'] ?? '');
    final paniers = await VenteRepository(db).paniers(depuis: depuis, jusqua: jusqua, limite: 300);
    final clients = await _repo.nomsClients(paniers.map((pa) => pa.vente.clientCode));
    final marge = s.a(Permission.voirMarge);
    return {
      'ventes': [
        for (final pa in paniers)
          {
            'code': pa.vente.code,
            'date': pa.vente.date.toUtc().toIso8601String(),
            'client': clients[pa.vente.clientCode] ?? pa.vente.clientCode,
            'caissier': pa.caissier,
            'total': pa.vente.totalNet,
            'verse': pa.vente.verse,
            'reste': pa.vente.reste,
            'statut': pa.vente.statut,
            'articles': pa.nbArticles,
            'quantite': pa.quantite,
            'modes': pa.modes,
            if (marge) 'marge': pa.vente.totalNet - pa.totalAchat,
          },
      ],
    };
  }

  Future<Map<String, Object?>> _vente(Session s, String code) async {
    final v = await VenteRepository(db).vente(code);
    if (v == null) throw const ErreurApiMobile(404, 'venteInconnue');
    final clients = await _repo.nomsClients([v.clientCode]);
    final caissier = await UtilisateurRepository(db).parCode(v.utilisateurCode);
    return {
      'vente': {
        'code': v.code,
        'date': v.date.toUtc().toIso8601String(),
        'client': clients[v.clientCode] ?? v.clientCode,
        'caissier': caissier?.nomComplet ?? v.utilisateurCode,
        'brut': v.totalBrut,
        'remise': v.totalRemise,
        'total': v.totalNet,
        'verse': v.verse,
        'reste': v.reste,
        'statut': v.statut,
        'lignes': [
          for (final l in v.lignes)
            if (!l.composantPack)
              {
                'produit': l.produitCode,
                'designation': l.designation,
                'quantite': l.quantite,
                'unite': l.uniteVente,
                'prix': l.prixUnitaire,
                'remise': l.remise,
                'total': l.total,
              },
        ],
        'paiements': [
          for (final pa in v.paiements) {'mode': pa.mode, 'montant': pa.montant},
        ],
      },
    };
  }

  Future<Map<String, Object?>> _references(Session s) async {
    final cat = CatalogueRepository(db);
    final vente = await _parametresVente();
    return {
      'categories': [
        for (final c in await cat.categories()) {'code': c.code, 'nom': c.nom},
      ],
      'sousCategories': [
        for (final c in await cat.sousCategories()) {'code': c.code, 'categorie': c.categorieCode, 'nom': c.nom},
      ],
      'fournisseurs': [
        for (final f in await TiersRepository(db).fournisseurs())
          if (f.actif) {'code': f.code, 'nom': f.nom},
      ],
      'magasins': [
        for (final m in await _magasinsVisibles(s)) {'code': m.code, 'nom': m.nom},
      ],
      'unites': [
        for (final u in Referentiel.unitesMesure.valeurs) {'stocke': u.stocke, 'fr': u.fr, 'ar': u.ar, 'en': u.en},
      ],
      'margeDefaut': vente.margeDefautPct,
      'seuilStock': vente.seuilStockGlobal,
      'devise': vente.devise,
    };
  }

  Map<String, Object?> _produitJson(Session s, Produit pr, double stock, int seuilGlobal) => {
    'code': pr.code,
    'designation': pr.designation,
    'codeBarres': pr.codeBarres,
    'prixVente': pr.prixVente,
    if (s.a(Permission.voirPrixAchat)) 'prixAchat': pr.prixAchat,
    'unite': pr.unite,
    'tva': pr.tvaPct,
    'categorie': pr.categorieCode,
    'marque': pr.marque,
    'image': pr.image != null && pr.image!.startsWith('http') ? pr.image : null,
    'service': pr.service,
    'actif': pr.actif,
    'stock': stock,
    'seuil': pr.seuilStock ?? seuilGlobal,
  };

  Future<Map<String, Object?>> _produits(Session s, Map<String, String> q) async {
    final visibles = [for (final m in await _magasinsVisibles(s)) m.code];
    final magasin = q['magasin'];
    final magasins = magasin != null && visibles.contains(magasin) ? [magasin] : visibles;
    final stocks = await _stocks(magasins);
    final seuil = (await _parametresVente()).seuilStockGlobal;
    final produits = await CatalogueRepository(db).produits(recherche: q['q'], actifsSeulement: q['tous'] != '1');
    return {
      'produits': [for (final pr in produits) _produitJson(s, pr, stocks[pr.code] ?? 0, seuil)],
    };
  }

  Future<Map<String, Object?>> _produitDetail(Session s, Produit pr) async {
    final visibles = await _magasinsVisibles(s);
    final repartition = {for (final n in await StockRepository(db).repartition(pr.code)) n.magasinCode: n.quantite};
    final seuil = (await _parametresVente()).seuilStockGlobal;
    final total = visibles.fold<double>(0, (t, m) => t + (repartition[m.code] ?? 0));
    return {
      'produit': {
        ..._produitJson(s, pr, total, seuil),
        'repartition': [
          for (final m in visibles) {'magasin': m.code, 'nom': m.nom, 'quantite': repartition[m.code] ?? 0},
        ],
      },
    };
  }

  Future<Map<String, Object?>> _produit(Session s, String code) async {
    final pr = await CatalogueRepository(db).produitParCode(code);
    if (pr == null) throw const ErreurApiMobile(404, 'produitInconnu');
    return _produitDetail(s, pr);
  }

  Future<Map<String, Object?>> _produitParCodeBarres(Session s, String codeBarres) async {
    final pr = await CatalogueRepository(db).produitParCodeBarres(Uri.decodeComponent(codeBarres));
    if (pr == null) throw const ErreurApiMobile(404, 'produitInconnu');
    return _produitDetail(s, pr);
  }

  Future<Map<String, Object?>> _rechercherIa(String codeBarres) async {
    final service = catalogueIa?.call();
    if (service == null) throw const ErreurApiMobile(404, 'introuvable');
    final f = await service.rechercher(Uri.decodeComponent(codeBarres));
    if (f == null) throw const ErreurApiMobile(404, 'introuvable');
    return {
      'fiche': {
        'codeBarres': f.codeBarres,
        'designation': f.designation,
        'quantite': f.quantite,
        'marque': f.marque,
        'categorie': f.categorie,
        'image': f.image,
        'prixVente': f.prixVente,
        'source': f.source,
      },
    };
  }

  Future<Map<String, Object?>> _sessionCaisse(Session s) async {
    final courante = await SessionCaisseService(db, utilisateurCode: s.utilisateur.code).courante();
    final caisses = await CaisseRepository(db).caisses(actives: true);
    return {
      'ouverte': courante != null,
      'session': courante == null
          ? null
          : {
              'code': courante.code,
              'caisse': courante.caisseCode,
              'ouverteLe': courante.ouverteLe.toUtc().toIso8601String(),
            },
      'caisses': [
        for (final c in caisses)
          if (!c.coffre && (s.estAdmin || s.utilisateur.caisseCode == null || s.utilisateur.caisseCode == c.code))
            {'code': c.code, 'nom': c.nom, 'soldeInitial': c.soldeInitial},
      ],
    };
  }

  Future<Map<String, Object?>> _factures(Session s) async => {
    'factures': [
      for (final r in await _repo.bonsEnvoyes(s.utilisateur.code))
        {
          'code': r['code'],
          'date': r['date_reception'],
          'fichier': r['fichier'],
          'statut': r['statut'],
          'lignes': r['nb_lignes'],
          'entree': r['achat_code'],
        },
    ],
  };

  // ———————————————————————————— Écritures ————————————————————————————

  static double? _nombre(Object? v) => switch (v) {
    num() => v.toDouble(),
    String() => double.tryParse(v.replaceAll(',', '.').replaceAll(RegExp(r'\s'), '')),
    _ => null,
  };

  static String? _texte(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;

  Future<Map<String, Object?>> _creerProduit(Session s, Map<String, Object?> c) async {
    final vente = await _parametresVente();
    var categorie = _texte(c['categorieCode']) ?? CodeGenerator.systeme(CodeGenerator.categorie);
    var sousCategorie = _texte(c['sousCategorieCode']);
    final cat = CatalogueRepository(db);
    if (!(await cat.categories()).any((x) => x.code == categorie)) {
      categorie = CodeGenerator.systeme(CodeGenerator.categorie);
    }
    final sous = await cat.sousCategories(categorie);
    if (sousCategorie == null || !sous.any((x) => x.code == sousCategorie)) {
      sousCategorie = sous.firstOrNull?.code ?? CodeGenerator.systeme(CodeGenerator.sousCategorie);
    }
    final visibles = [for (final m in await _magasinsVisibles(s)) m.code];
    final magasin = _texte(c['magasinCode']);
    final stockInitial = _nombre(c['stockInitial']) ?? 0;
    final unite = _texte(c['unite']);
    final pr = await CatalogueService(db, utilisateurCode: s.utilisateur.code).creerProduit(
      Produit(
        code: '',
        designation: _texte(c['designation']) ?? '',
        codeBarres: _texte(c['codeBarres']),
        categorieCode: categorie,
        sousCategorieCode: sousCategorie,
        prixAchat: _nombre(c['prixAchat']) ?? 0,
        prixVente: _nombre(c['prixVente']) ?? 0,
        unite: unite != null && Referentiel.unitesMesure.parValeurStockee(unite) != null ? unite : 'Pièce',
        tvaPct: _nombre(c['tva']) ?? 19,
        source: c['source'] == 'IA' ? 'IA' : 'Manuel',
        marque: _texte(c['marque']),
        image: _texte(c['image']),
        fournisseurCode: _texte(c['fournisseurCode']),
      ),
      margeDefautPct: vente.margeDefautPct,
      genererCodeBarres: c['genererCodeBarres'] == true,
      stockInitial: stockInitial,
      magasinCode: magasin != null && visibles.contains(magasin)
          ? magasin
          : await StockService(db, utilisateurCode: s.utilisateur.code).magasinPrincipal(s.utilisateur.code),
    );
    return _produitDetail(s, pr);
  }

  Future<Map<String, Object?>> _ouvrirSessionCaisse(Session s, Map<String, Object?> c) async {
    final caisse = _texte(c['caisseCode']);
    if (caisse == null) throw const ErreurApiMobile(422, 'caisseInconnue');
    if (!s.estAdmin && s.utilisateur.caisseCode != null && s.utilisateur.caisseCode != caisse) {
      throw const ErreurApiMobile(403, 'caisseInconnue');
    }
    await SessionCaisseService(
      db,
      utilisateurCode: s.utilisateur.code,
    ).ouvrir(caisseCode: caisse, fondInitial: _nombre(c['fond']) ?? 0);
    return _sessionCaisse(s);
  }

  // ———————————————————————————— Vente (panier du téléphone) ————————————————————————————

  VenteMobileService _venteMobile(Session s) => VenteMobileService(db, utilisateurCode: s.utilisateur.code);

  /// Ce que le panier du téléphone propose : modes de paiement et clients actifs.
  Future<Map<String, Object?>> _caisse(Session s) async => {
    'modes': await _venteMobile(s).modesPaiement(),
    'clients': [
      for (final c in await ClientRepository(db).tous(actifsSeulement: true)) {'code': c.code, 'nom': c.nom},
    ],
    'devise': (await _parametresVente()).devise,
  };

  Future<Map<String, Object?>> _articleCaisse(Session s, String code) async {
    final a = await _venteMobile(s).resoudre(Uri.decodeComponent(code));
    if (a == null) throw const ErreurApiMobile(404, 'produitInconnu');
    return {'article': a.versJson()};
  }

  /// Encaisse le panier du téléphone : lignes (`type`, `code`, `quantite`), client, un paiement (`mode`, `montant`).
  Future<Map<String, Object?>> _vendre(Session s, Map<String, Object?> c) async {
    final brutes = c['lignes'];
    final lignes = <LigneMobile>[
      for (final l in brutes is List<Object?> ? brutes : const <Object?>[])
        if (l is Map<String, Object?>)
          (
            type: TypeArticle.values.asNameMap()['${l['type']}'] ?? (throw const FormatException('type d\'article')),
            code: _texte(l['code']) ?? (throw const FormatException('code d\'article')),
            quantite: _nombre(l['quantite']) ?? 0,
          ),
    ];
    final v = await _venteMobile(s).vendre(
      lignes: lignes,
      clientCode: _texte(c['clientCode']) ?? CodeGenerator.systeme(CodeGenerator.client),
      mode: _texte(c['mode']) ?? 'Espèces',
      montant: _nombre(c['montant']) ?? 0,
    );
    return {
      'vente': {
        'code': v.code,
        'total': v.totalNet,
        'verse': v.verse,
        'reste': v.reste,
        'monnaie': CalculsPrix.arrondir((v.verse - v.totalNet).clamp(0, double.infinity).toDouble()),
      },
    };
  }

  /// Entrée rapide (§9.6, comme `EntreeRapideDialog`) : un produit payé intégralement, dans le magasin
  /// choisi (sinon le principal de l'utilisateur), fournisseur divers si aucun.
  Future<Map<String, Object?>> _entreeRapide(Session s, Map<String, Object?> c) async {
    final produit = _texte(c['produitCode']);
    if (produit == null) throw const ErreurApiMobile(422, 'produitInconnu');
    final quantite = _nombre(c['quantite']) ?? 0;
    final prix = _nombre(c['prixAchat']) ?? 0;
    final stock = StockService(db, utilisateurCode: s.utilisateur.code);
    final principal = await stock.magasinPrincipal(s.utilisateur.code);
    final visibles = [for (final m in await _magasinsVisibles(s)) m.code];
    final choisi = _texte(c['magasinCode']);
    final magasin = choisi != null && visibles.contains(choisi) ? choisi : principal;
    final pv = _nombre(c['nouveauPrixVente']);
    final achat = await AchatService(db, utilisateurCode: s.utilisateur.code).enregistrer(
      fournisseurCode: _texte(c['fournisseurCode']) ?? CodeGenerator.systeme(CodeGenerator.fournisseur),
      magasinCode: principal,
      lignes: [
        DemandeAchatLigne(
          produitCode: produit,
          quantite: quantite,
          nombre: _nombre(c['nombre']) ?? 0,
          prixAchat: prix,
          nouveauPrixVente: pv != null && pv > 0 ? pv : null,
          repartition: {magasin: quantite},
        ),
      ],
      verse: quantite * prix,
      source: SourcesAchat.rapide,
      commentaire: 'CaisseDZ Scan',
    );
    return {
      'entree': {'code': achat.code, 'total': quantite * prix, 'magasin': magasin},
    };
  }

  /// Facture photographiée : rangée dans [dossierFactures] et déposée dans la file des bons de réception
  /// (Entrées › Mode IA), où le poste la lira plus tard avec Smart Scan.
  Future<Map<String, Object?>> _deposerFacture(Session s, HttpRequest r) async {
    final octets = BytesBuilder(copy: false);
    await for (final morceau in r) {
      octets.add(morceau);
      if (octets.length > tailleMaxFacture) throw const ErreurApiMobile(413, 'fichierTropGrand');
    }
    if (octets.isEmpty) throw const ErreurApiMobile(422, 'fichierInvalide');
    final nomRecu = r.headers.value('x-nom-fichier') ?? 'facture.jpg';
    final ext = switch (p.extension(nomRecu).toLowerCase()) {
      '.png' => '.png',
      '.webp' => '.webp',
      _ => '.jpg',
    };
    final maintenant = DateTime.now();
    String deux(int n) => n.toString().padLeft(2, '0');
    final horodatage =
        '${maintenant.year}${deux(maintenant.month)}${deux(maintenant.day)}-'
        '${deux(maintenant.hour)}${deux(maintenant.minute)}${deux(maintenant.second)}';
    final nom = 'mobile-$horodatage-${_jeton(3).replaceAll(RegExp('[^A-Za-z0-9]'), 'x')}$ext';
    final dossier = Directory(dossierFactures);
    await dossier.create(recursive: true);
    final fichier = File(p.join(dossier.path, nom));
    await fichier.writeAsBytes(octets.takeBytes(), flush: true);
    final commentaire = _texte(
      r.headers.value('x-commentaire') == null ? null : Uri.decodeComponent(r.headers.value('x-commentaire')!),
    );
    final bon = await AchatService(db, utilisateurCode: s.utilisateur.code).deposerBon(
      fichier: nom,
      chemin: fichier.path,
      commentaire: commentaire ?? 'CaisseDZ Scan · ${s.utilisateur.nomComplet}',
    );
    final u = s.utilisateur;
    surFacture?.call(FactureMobile(bon: bon.code, utilisateur: u.nomComplet.isEmpty ? u.identifiant : u.nomComplet));
    return {
      'facture': {'code': bon.code, 'date': bon.date.toUtc().toIso8601String(), 'fichier': nom, 'statut': bon.statut},
    };
  }
}
