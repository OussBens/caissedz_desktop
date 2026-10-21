import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/produit.dart';
import '../domain/models/stock.dart';

/// Produit vu par les alertes produits (actif, hors services).
typedef ProduitAlerte = ({
  String code,
  String designation,
  String categorie,
  String categorieCode,
  String sousCategorieCode,
  double prixAchat,
  double prixVente,
  int? seuil,
  String? codeBarres,
  bool photo,
  DateTime creeLe,
  String source,
  String? remiseCode,
  DateTime? tendanceLe,

  /// Premier mouvement de stock (`null` : jamais entré en stock).
  DateTime? premierMouvement,
});

/// Quantités d'un produit sur un jour : ventes (unités de stock), retours clients, tickets.
typedef JourVentes = ({double vendu, double retourne, int tickets});

/// Requêtes en lecture seule des alertes produits : journal du stock, ventes nettes des retours, achats, remises,
/// commandes fournisseurs. Les jours sont ceux du poste (`date(..., 'localtime')`, `AAAA-MM-JJ`).
class AlertesProduitsRepository {
  const AlertesProduitsRepository(this.db);

  final DatabaseExecutor db;

  static const String _venteValidee = 'Validée';
  static const String _achatValide = 'Validé';

  static String _iso(DateTime d) => d.toUtc().toIso8601String();

  /// Jour local `AAAA-MM-JJ` (clés des ventes et des mouvements par jour).
  static String _jour(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String jour(DateTime d) => _jour(d);
  static double _d(Object? v) => (v as num? ?? 0).toDouble();
  static DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;

  String _magasins(String colonne, List<String>? magasins) =>
      magasins == null ? '' : ' AND $colonne IN (${List.filled(magasins.length, '?').join(',')})';

  Future<List<ProduitAlerte>> produits() async => [
    for (final r in await db.rawQuery('''
      SELECT p.code, p.designation, COALESCE(c.nom, '') categorie, p.categorie_code, p.sous_categorie_code,
             p.prix_achat, p.prix_vente, p.seuil_stock, p.code_barres, p.cree_le, p.source, p.remise_code, p.tendance_le,
             (COALESCE(p.image, '') <> '' OR EXISTS (SELECT 1 FROM produit_photo f WHERE f.produit_code = p.code)) photo,
             m.premier
      FROM produit p
      LEFT JOIN categorie c ON c.code = p.categorie_code
      LEFT JOIN (SELECT produit_code, MIN(date) premier FROM mouvement_stock GROUP BY produit_code) m
        ON m.produit_code = p.code
      WHERE p.actif = 1 AND p.service = 0
    '''))
      (
        code: r['code']! as String,
        designation: r['designation']! as String,
        categorie: r['categorie']! as String,
        categorieCode: r['categorie_code']! as String,
        sousCategorieCode: r['sous_categorie_code']! as String,
        prixAchat: _d(r['prix_achat']),
        prixVente: _d(r['prix_vente']),
        seuil: r['seuil_stock'] as int?,
        codeBarres: r['code_barres'] as String?,
        photo: (r['photo'] as int? ?? 0) == 1,
        creeLe: _date(r['cree_le']) ?? DateTime.now(),
        source: r['source']! as String,
        remiseCode: r['remise_code'] as String?,
        tendanceLe: _date(r['tendance_le']),
        premierMouvement: _date(r['premier']),
      ),
  ];

  /// Stock par produit et par magasin ([magasins] : ceux de l'utilisateur, tous si `null`).
  Future<Map<String, Map<String, double>>> stocks({List<String>? magasins}) async {
    final m = <String, Map<String, double>>{};
    for (final r in await db.rawQuery(
      'SELECT produit_code, magasin_code, SUM(quantite) q FROM mouvement_stock WHERE 1 = 1'
      '${_magasins('magasin_code', magasins)} GROUP BY produit_code, magasin_code',
      [...?magasins],
    )) {
      (m[r['produit_code']! as String] ??= {})[r['magasin_code']! as String] = _d(r['q']);
    }
    return m;
  }

  /// Ventes validées (unités de stock, tickets) et retours clients actifs par produit et par jour depuis [depuis].
  Future<Map<String, Map<String, JourVentes>>> ventesParJour(DateTime depuis, {List<String>? magasins}) async {
    final m = <String, Map<String, JourVentes>>{};
    for (final r in await db.rawQuery(
      '''
      SELECT l.produit_code p, date(v.date, 'localtime') j, SUM(l.unites) q, COUNT(DISTINCT v.code) t
      FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
      WHERE v.statut = ? AND v.date >= ?${_magasins('v.magasin_code', magasins)}
      GROUP BY 1, 2
      ''',
      [_venteValidee, _iso(depuis), ...?magasins],
    )) {
      (m[r['p']! as String] ??= {})[r['j']! as String] = (vendu: _d(r['q']), retourne: 0, tickets: r['t']! as int);
    }
    for (final r in await db.rawQuery(
      '''
      SELECT rl.produit_code p, date(r.date, 'localtime') j, SUM(rl.quantite) q
      FROM retour_ligne rl JOIN retour r ON r.code = rl.retour_code
      WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ?${_magasins('r.magasin_code', magasins)}
      GROUP BY 1, 2
      ''',
      [_iso(depuis), ...?magasins],
    )) {
      final jours = m[r['p']! as String] ??= {};
      final j = r['j']! as String;
      final avant = jours[j];
      jours[j] = (vendu: avant?.vendu ?? 0, retourne: _d(r['q']), tickets: avant?.tickets ?? 0);
    }
    return m;
  }

  /// Dernière vente validée de chaque produit (toutes dates).
  Future<Map<String, DateTime>> dernieresVentes({List<String>? magasins}) async => {
    for (final r in await db.rawQuery(
      '''
      SELECT l.produit_code p, MAX(v.date) d FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
      WHERE v.statut = ?${_magasins('v.magasin_code', magasins)} GROUP BY 1
      ''',
      [_venteValidee, ...?magasins],
    ))
      r['p']! as String: ?_date(r['d']),
  };

  /// Unités vendues (nettes des retours) entre [debut] inclus et [fin] exclue : saisonnalité de l'an passé.
  Future<Map<String, double>> ventesEntre(DateTime debut, DateTime fin, {List<String>? magasins}) async {
    final m = <String, double>{};
    for (final r in await db.rawQuery(
      '''
      SELECT l.produit_code p, SUM(l.unites) q FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ?${_magasins('v.magasin_code', magasins)} GROUP BY 1
      ''',
      [_venteValidee, _iso(debut), _iso(fin), ...?magasins],
    )) {
      m[r['p']! as String] = _d(r['q']);
    }
    for (final r in await db.rawQuery(
      '''
      SELECT rl.produit_code p, SUM(rl.quantite) q FROM retour_ligne rl JOIN retour r ON r.code = rl.retour_code
      WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ? AND r.date < ?${_magasins('r.magasin_code', magasins)}
      GROUP BY 1
      ''',
      [_iso(debut), _iso(fin), ...?magasins],
    )) {
      final p = r['p']! as String;
      m[p] = (m[p] ?? 0) - _d(r['q']);
    }
    return m;
  }

  /// Deux derniers prix d'achat (entrées validées) de chaque produit, le plus récent d'abord.
  Future<Map<String, List<double>>> derniersPrixAchat() async {
    final m = <String, List<double>>{};
    for (final r in await db.rawQuery(
      '''
      SELECT p, prix FROM (
        SELECT l.produit_code p, l.prix_achat prix,
               ROW_NUMBER() OVER (PARTITION BY l.produit_code ORDER BY a.date DESC, a.code DESC, l.ordre DESC) rn
        FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
        WHERE a.statut = ? AND l.prix_achat > 0
      ) WHERE rn <= 2 ORDER BY p, rn
      ''',
      [_achatValide],
    )) {
      (m[r['p']! as String] ??= []).add(_d(r['prix']));
    }
    return m;
  }

  /// Échéance de la plus ancienne commande fournisseur ouverte (non soldée, active) de chaque produit : date de
  /// livraison prévue, sinon date de la commande.
  Future<Map<String, DateTime>> commandesOuvertes() async => {
    for (final r in await db.rawQuery('''
      SELECT l.produit_code p, MIN(COALESCE(c.date_livraison, c.date)) e
      FROM commande_fournisseur_ligne l JOIN commande_fournisseur c ON c.code = l.commande_code
      WHERE c.actif = 1 AND c.soldee = 0 GROUP BY 1
    '''))
      r['p']! as String: ?_date(r['e']),
  };

  /// Remises actives et commencées (date de début connue, fin non dépassée).
  Future<List<({String code, String designation, DateTime debut, String? produitCode, String? categorieCode})>>
  remisesActives(DateTime maintenant) async => [
    for (final r in await db.rawQuery(
      '''
      SELECT code, designation, date_debut, produit_code, categorie_code FROM remise
      WHERE actif = 1 AND date_debut IS NOT NULL AND substr(date_debut, 1, 10) <= ?1
        AND (date_fin IS NULL OR substr(date_fin, 1, 10) >= ?1)
      ''',
      [_jour(maintenant)],
    ))
      if (_date(r['date_debut']) case final debut?)
        (
          code: r['code']! as String,
          designation: r['designation']! as String,
          debut: debut,
          produitCode: r['produit_code'] as String?,
          categorieCode: r['categorie_code'] as String?,
        ),
  ];

  /// Sorties « Casse » (nombre) et écarts d'inventaire (unités, en valeur absolue) par produit depuis [depuis].
  Future<Map<String, ({int casses, double ecart})>> anomalies(DateTime depuis, {List<String>? magasins}) async {
    final m = <String, ({int casses, double ecart})>{};
    for (final r in await db.rawQuery(
      '''
      SELECT produit_code p,
        SUM(CASE WHEN type = ? AND lower(COALESCE(motif, '')) LIKE '%casse%' THEN 1 ELSE 0 END) c,
        SUM(CASE WHEN type = ? THEN ABS(quantite) ELSE 0 END) e
      FROM mouvement_stock WHERE date >= ?${_magasins('magasin_code', magasins)} GROUP BY 1
      ''',
      [TypesMouvement.sortie, TypesMouvement.inventaire, _iso(depuis), ...?magasins],
    )) {
      m[r['p']! as String] = (casses: (r['c'] as num? ?? 0).toInt(), ecart: _d(r['e']));
    }
    return m;
  }

  /// Variation nette du stock par produit et par jour depuis [depuis] (reconstitution des jours en rupture).
  Future<Map<String, Map<String, double>>> mouvementsParJour(DateTime depuis, {List<String>? magasins}) async {
    final m = <String, Map<String, double>>{};
    for (final r in await db.rawQuery(
      '''
      SELECT produit_code p, date(date, 'localtime') j, SUM(quantite) q FROM mouvement_stock
      WHERE date >= ?${_magasins('magasin_code', magasins)} GROUP BY 1, 2
      ''',
      [_iso(depuis), ...?magasins],
    )) {
      (m[r['p']! as String] ??= {})[r['j']! as String] = _d(r['q']);
    }
    return m;
  }

  /// Paires de produits sur un même ticket validé depuis [depuis] (hors lignes de pack), vues au moins [minimum] fois.
  Future<List<({String p1, String p2, int tickets})>> paires(DateTime depuis, {int minimum = 3}) async => [
    for (final r in await db.rawQuery(
      '''
      SELECT a.produit_code p1, b.produit_code p2, COUNT(DISTINCT a.vente_code) n
      FROM vente_ligne a
      JOIN vente_ligne b ON b.vente_code = a.vente_code AND a.produit_code < b.produit_code
      JOIN vente v ON v.code = a.vente_code
      WHERE v.statut = ? AND v.date >= ? AND a.pack_code IS NULL AND b.pack_code IS NULL
        AND a.produit_code <> ? AND b.produit_code <> ?
      GROUP BY 1, 2 HAVING n >= ?
      ''',
      [_venteValidee, _iso(depuis), _codeMontant, _codeMontant, minimum],
    ))
      (p1: r['p1']! as String, p2: r['p2']! as String, tickets: r['n']! as int),
  ];

  static const String _codeMontant = 'PRD0000';

  /// Codes des magasins actifs (stock déséquilibré entre magasins).
  Future<List<String>> magasinsActifs() async => [
    for (final r in await db.rawQuery('SELECT code FROM magasin WHERE actif = 1 ORDER BY code')) r['code']! as String,
  ];

  /// Jour du dernier téléchargement de chaque catégorie liée à un rayon du catalogue BENS.
  Future<Map<String, DateTime>> importsRayons() async => {
    for (final r in await db.rawQuery('SELECT categorie_code, MAX(importe_le) i FROM catalogue_rayon GROUP BY 1'))
      r['categorie_code']! as String: ?_date(r['i']),
  };

  /// Source des produits téléchargés du catalogue BENS.
  static const String sourceCatalogue = Produit.sourceCatalogue;
}
