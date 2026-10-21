import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';

import '../core/catalogue/catalogue_rayons_api.dart';
import '../data/parametre_repository.dart';
import '../domain/models/produit.dart';

/// L'identité du poste auprès du catalogue BENS : identifiant brut (X-Device-Id) et licence signée
/// (X-License-Key), comme pour Smart Scan.
typedef IdentiteTendance = ({String machine, String? cle});

/// Ce qu'un envoi a donné : lignes de ventes acceptées, codes-barres inconnus du catalogue, produits créés dans
/// le catalogue et fiches du catalogue complétées.
typedef ResultatTendance = ({int ventes, int inconnus, int crees, int completes});

/// Tendance du catalogue BENS : au lancement, le poste envoie à catalog-api.bensds.com (`POST /tendance`)
/// combien de tickets de chaque jour contenaient chaque code-barres, et les fiches saisies ou modifiées dans la
/// boutique (code-barres, nom, nom arabe, marque, catégorie, codes-barres secondaires). Le serveur en déduit
/// les produits qui se vendent dans plusieurs boutiques (tendance), crée les produits qu'il ne connaît pas et
/// complète les champs vides des autres ; il ne reçoit ni prix, ni quantités, ni stocks, ni clients.
///
/// Jours envoyés : depuis le dernier envoi réussi (ce jour-là compris, il était peut-être incomplet ; le
/// serveur remplace un jour renvoyé), au plus [joursMax] jours la première fois. Hors ligne, sans licence ou
/// refusé : rien n'est marqué envoyé, tout repart au lancement suivant.
class TendanceService {
  const TendanceService(this.db, {required this.client, required this.identite, this.baseUrl = urlParDefaut});

  static const String urlParDefaut = CatalogueRayonsApi.urlParDefaut;

  /// Jours envoyés la première fois.
  static const int joursMax = 30;

  /// Lignes par envoi (le serveur en accepte 5 000).
  static const int parEnvoi = 4000;

  /// Dernier jour envoyé (AAAA-MM-JJ) et horodatage d'audit des dernières fiches envoyées (`parametre_app`).
  static const String cleJour = 'tendance_jour_envoye';
  static const String cleFiches = 'tendance_fiches_le';

  static final RegExp _codeBarres = RegExp(r'^\d{8,14}$');

  final Database db;
  final http.Client client;
  final Future<IdentiteTendance> Function() identite;
  final String baseUrl;

  static String _jour(DateTime d) => d.toIso8601String().substring(0, 10);

  /// Tickets par jour et par code-barres depuis le jour [depuis] (ventes validées, codes-barres EAN / UPC :
  /// les codes internes `CDZ…` ne disent rien aux autres boutiques).
  Future<List<Map<String, Object>>> ventesDepuis(String depuis) async {
    final rows = await db.rawQuery(
      '''
      SELECT substr(v.date, 1, 10) AS jour, p.code_barres AS code_barres, COUNT(DISTINCT v.code) AS tickets
      FROM vente_ligne l
      JOIN vente v ON v.code = l.vente_code
      JOIN produit p ON p.code = l.produit_code
      WHERE v.statut = 'Validée' AND substr(v.date, 1, 10) >= ? AND p.code_barres IS NOT NULL
      GROUP BY jour, p.code_barres
      ORDER BY jour, p.code_barres
      ''',
      [depuis],
    );
    return [
      for (final r in rows)
        if (_codeBarres.hasMatch(r['code_barres']! as String))
          {'jour': r['jour']! as String, 'code_barres': r['code_barres']! as String, 'tickets': r['tickets']! as int},
    ];
  }

  /// Fiches saisies ou modifiées après [apres] (horodatage d'audit ; `null` : toutes) : produits à code-barres
  /// EAN / UPC, hors services et hors produits venus du catalogue jamais modifiés depuis (le catalogue les connaît
  /// déjà). Catégorie système (Divers) non envoyée. [dernier] : l'horodatage le plus récent des fiches lues (le
  /// prochain envoi part de là).
  Future<({List<Map<String, Object>> fiches, String? dernier})> fichesApres(String? apres) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.code_barres, p.designation, p.designation_ar, p.marque,
             CASE WHEN c.systeme = 1 THEN NULL ELSE c.nom END AS categorie,
             COALESCE(p.modifie_le, p.cree_le, '') AS le
      FROM produit p LEFT JOIN categorie c ON c.code = p.categorie_code
      WHERE p.code_barres IS NOT NULL AND p.service = 0
        AND (p.source <> ? OR p.modifie_le > p.cree_le)
        ${apres == null ? '' : 'AND COALESCE(p.modifie_le, p.cree_le) > ?'}
      ORDER BY p.code_barres
      ''',
      [Produit.sourceCatalogue, ?apres],
    );
    String? dernier;
    final retenus = <Map<String, Object?>>[];
    for (final r in rows) {
      final le = r['le']! as String;
      if (dernier == null || le.compareTo(dernier) > 0) dernier = le;
      if (_codeBarres.hasMatch(r['code_barres']! as String)) retenus.add(r);
    }
    final secondaires = <String, List<String>>{};
    final codes = [for (final r in retenus) r['code']! as String];
    for (var i = 0; i < codes.length; i += 500) {
      final lot = codes.sublist(i, (i + 500).clamp(0, codes.length));
      for (final r in await db.query(
        'produit_code_detail',
        columns: ['produit_code', 'code_barres'],
        where: 'produit_code IN (${List.filled(lot.length, '?').join(',')})',
        whereArgs: lot,
        orderBy: 'code_barres',
      )) {
        final cb = r['code_barres']! as String;
        if (_codeBarres.hasMatch(cb)) (secondaires[r['produit_code']! as String] ??= []).add(cb);
      }
    }
    String? texte(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
    final fiches = <Map<String, Object>>[
      for (final r in retenus)
        {
          'code_barres': r['code_barres']! as String,
          'codes_barres': [r['code_barres']! as String, ...?secondaires[r['code']! as String]],
          'nom': (r['designation']! as String).trim(),
          'nom_ar': ?texte(r['designation_ar']),
          'marque': ?texte(r['marque']),
          'categorie': ?texte(r['categorie']),
        },
    ];
    return (fiches: fiches, dernier: dernier);
  }

  /// Envoie ce qui ne l'a pas encore été. `null` : rien d'envoyé (pas de licence, hors ligne, refusé).
  Future<ResultatTendance?> envoyer({DateTime? maintenant}) async {
    final id = await identite();
    final cle = id.cle;
    if (cle == null || cle.isEmpty || id.machine.isEmpty) return null;
    final parametres = ParametreRepository(db);
    final aujourdhui = maintenant ?? DateTime.now();
    final premier = _jour(aujourdhui.subtract(const Duration(days: joursMax - 1)));
    final dernier = await parametres.lire(cleJour);
    final depuis = dernier == null || dernier.compareTo(premier) < 0 ? premier : dernier;
    final ventes = await ventesDepuis(depuis);
    final lues = await fichesApres(await parametres.lire(cleFiches));
    final fiches = lues.fiches;
    var total = (ventes: 0, inconnus: 0, crees: 0, completes: 0);
    if (ventes.isEmpty && fiches.isEmpty) return total;
    try {
      // Les fiches d'abord : un produit inconnu du catalogue y est créé avant que ses ventes ne soient comptées.
      var iv = 0, ifi = 0;
      do {
        final lotFiches = fiches.sublist(ifi, (ifi + parEnvoi).clamp(0, fiches.length));
        ifi += lotFiches.length;
        final place = parEnvoi - lotFiches.length;
        final lotVentes = ventes.sublist(iv, (iv + place).clamp(0, ventes.length));
        iv += lotVentes.length;
        final r = await _poster(id.machine, cle, {'produits': lotFiches, 'ventes': lotVentes});
        if (r == null) return null;
        total = (
          ventes: total.ventes + r.ventes,
          inconnus: total.inconnus + r.inconnus,
          crees: total.crees + r.crees,
          completes: total.completes + r.completes,
        );
      } while (iv < ventes.length || ifi < fiches.length);
    } on Object {
      return null;
    }
    await parametres.ecrire(cleJour, _jour(aujourdhui));
    if (lues.dernier != null) await parametres.ecrire(cleFiches, lues.dernier);
    return total;
  }

  Future<ResultatTendance?> _poster(String machine, String cle, Map<String, Object> corps) async {
    final r = await client
        .post(
          Uri.parse('$baseUrl/tendance'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Device-Id': machine,
            'X-License-Key': cle,
          },
          body: jsonEncode(corps),
        )
        .timeout(const Duration(seconds: 30));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    if (j is! Map || j['success'] != true || j['data'] is! Map) return null;
    final d = j['data'] as Map;
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    return (ventes: n(d['ventes']), inconnus: n(d['inconnus']), crees: n(d['crees']), completes: n(d['completes']));
  }
}
