import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';
import '../domain/models/stock.dart';

/// Ligne d'une analyse de la Situation (valeurs brutes par clé de colonne).
typedef LigneSituation = Map<String, Object?>;

/// Regroupement de la marge par période.
enum Regroupement { jour, semaine, mois }

/// Filtres d'une analyse : `null` = tous.
class FiltresSituation {
  const FiltresSituation({
    this.caisse,
    this.caissier,
    this.client,
    this.categorie,
    this.produit,
    this.magasin,
    this.typeMouvement,
    this.regroupement = Regroupement.jour,
  });
  final String? caisse;
  final String? caissier;
  final String? client;
  final String? categorie;
  final String? produit;
  final String? magasin;
  final String? typeMouvement;
  final Regroupement regroupement;
}

/// Les 10 analyses de Situation (§9.14) et les agrégats du tableau de bord v2.2. Lecture seule.
///
/// Les dates sont stockées en UTC ISO 8601 ; les regroupements par jour se font en heure locale.
class SituationRepository {
  const SituationRepository(this.db);
  final DatabaseExecutor db;

  static const String _venteValidee = 'Validée';
  static const String _achatValide = 'Validé';

  /// Identifiants des 10 analyses, dans l'ordre de la navigation du DS.
  static const List<String> analyses = ['mvc', 'mvp', 'rcp', 'rcpr', 'mgp', 'mgper', 'inv', 'cout', 'scli', 'sfrn'];

  /// Analyses qui exposent le coût d'achat (permission `voirPrixAchat`).
  static const Set<String> analysesCout = {'mgp', 'mgper', 'cout'};

  String _iso(DateTime d) => d.toUtc().toIso8601String();
  double _d(Object? v) => (v as num? ?? 0).toDouble();

  /// Début inclus, fin exclue (lendemain de [fin] à minuit).
  List<String> _bornes(DateTime debut, DateTime fin) => [
    _iso(DateTime(debut.year, debut.month, debut.day)),
    _iso(DateTime(fin.year, fin.month, fin.day + 1)),
  ];

  /// Reste effectif d'une vente : reste − imputations des versements actifs.
  static const String _resteVente = '''
    (v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
      JOIN versement ve ON ve.code = i.versement_code
      WHERE i.document_type = 'vente' AND i.document_code = v.code AND ve.etat = 1), 0))''';

  // ---------------------------------------------------------------- Ventes

  /// 1 · Recette par panier : montant, payé, reste.
  Future<List<LigneSituation>> recetteParPanier(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code, v.date, c.nom client, u.nom caissier, ca.nom caisse, v.total_net montant, $_resteVente reste
      FROM vente v JOIN client c ON c.code = v.client_code JOIN caisse ca ON ca.code = v.caisse_code
      LEFT JOIN utilisateur u ON u.code = v.utilisateur_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ?
        AND (? IS NULL OR v.caisse_code = ?) AND (? IS NULL OR v.utilisateur_code = ?)
      ORDER BY v.date DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin), f.caisse, f.caisse, f.caissier, f.caissier],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'date': DateTime.parse(r['date'] as String).toLocal(),
          'client': r['client'],
          'caissier': r['caissier'] ?? '',
          'caisse': r['caisse'],
          'montant': _d(r['montant']),
          'paye': CalculsPrix.arrondir(_d(r['montant']) - _d(r['reste'])),
          'reste': CalculsPrix.arrondir(_d(r['reste'])),
        },
    ];
  }

  /// 2 · Recette par produit : quantité, prix moyen, recette.
  Future<List<LigneSituation>> recetteParProduit(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT l.produit_code code, p.designation nom, cat.nom categorie, SUM(l.quantite) q, SUM(l.total) ca
      FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
      JOIN produit p ON p.code = l.produit_code LEFT JOIN categorie cat ON cat.code = p.categorie_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ?
        AND (? IS NULL OR p.categorie_code = ?) AND (? IS NULL OR v.caisse_code = ?)
      GROUP BY l.produit_code ORDER BY ca DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin), f.categorie, f.categorie, f.caisse, f.caisse],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'nom': r['nom'],
          'categorie': r['categorie'] ?? '',
          'quantite': _d(r['q']),
          'prixMoyen': _d(r['q']) == 0 ? 0.0 : CalculsPrix.arrondir(_d(r['ca']) / _d(r['q'])),
          'recette': _d(r['ca']),
        },
    ];
  }

  // ---------------------------------------------------------------- Trésorerie

  /// 3 · Mouvement de caisse : entrées / sorties par jour, caisse et type (grand-livre agrégé).
  Future<List<LigneSituation>> mouvementCaisse(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT date(m.date, 'localtime') j, ca.nom caisse, m.type,
        SUM(CASE WHEN m.sens = 'Entrée' THEN m.montant ELSE 0 END) e,
        SUM(CASE WHEN m.sens = 'Sortie' THEN m.montant ELSE 0 END) s
      FROM mouvement_caisse m JOIN caisse ca ON ca.code = m.caisse_code
      WHERE m.date >= ? AND m.date < ? AND (? IS NULL OR m.caisse_code = ?) AND (? IS NULL OR m.type = ?)
      GROUP BY j, m.caisse_code, m.type ORDER BY j DESC, ca.nom, m.type
      ''',
      [..._bornes(debut, fin), f.caisse, f.caisse, f.typeMouvement, f.typeMouvement],
    );
    return [
      for (final r in rows)
        {
          'date': DateTime.parse(r['j'] as String),
          'caisse': r['caisse'],
          'type': r['type'],
          'entrees': _d(r['e']),
          'sorties': _d(r['s']),
        },
    ];
  }

  // ---------------------------------------------------------------- Stock

  /// 4 · Mouvement produit : stock initial, entrées, sorties, retours, stock final sur la période.
  Future<List<LigneSituation>> mouvementProduit(DateTime debut, DateTime fin, FiltresSituation f) async {
    final b = _bornes(debut, fin);
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation nom,
        COALESCE(SUM(CASE WHEN m.date < ? THEN m.quantite END), 0) ini,
        COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND m.type != ? AND m.quantite > 0 THEN m.quantite END), 0) ent,
        COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND m.type != ? AND m.quantite < 0 THEN -m.quantite END), 0) sor,
        COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND m.type = ? THEN m.quantite END), 0) ret,
        COALESCE(SUM(CASE WHEN m.date < ? THEN m.quantite END), 0) fin
      FROM produit p JOIN mouvement_stock m ON m.produit_code = p.code
      WHERE (? IS NULL OR m.magasin_code = ?) AND (? IS NULL OR p.code = ?)
      GROUP BY p.code HAVING ini != 0 OR ent != 0 OR sor != 0 OR ret != 0
      ORDER BY p.designation
      ''',
      [
        b[0],
        ...b,
        TypesMouvement.retour,
        ...b,
        TypesMouvement.retour,
        ...b,
        TypesMouvement.retour,
        b[1],
        f.magasin,
        f.magasin,
        f.produit,
        f.produit,
      ],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'nom': r['nom'],
          'initial': _d(r['ini']),
          'entrees': _d(r['ent']),
          'sorties': _d(r['sor']),
          'retours': _d(r['ret']),
          'final': _d(r['fin']),
        },
    ];
  }

  /// 7 · Inventaire : stock théorique et valorisation par produit actif (magasin et catégorie filtrables).
  Future<List<LigneSituation>> inventaire(FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation nom, p.prix_achat pa, cat.nom categorie,
        COALESCE((SELECT SUM(m.quantite) FROM mouvement_stock m WHERE m.produit_code = p.code
          AND (? IS NULL OR m.magasin_code = ?)), 0) theo
      FROM produit p LEFT JOIN categorie cat ON cat.code = p.categorie_code
      WHERE p.actif = 1 AND (? IS NULL OR p.categorie_code = ?)
      ORDER BY p.designation
      ''',
      [f.magasin, f.magasin, f.categorie, f.categorie],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'nom': r['nom'],
          'categorie': r['categorie'] ?? '',
          'theorique': _d(r['theo']),
          'prixAchat': _d(r['pa']),
          'valeur': CalculsPrix.arrondir(_d(r['theo']) * _d(r['pa'])),
        },
    ];
  }

  /// 8 · Coût produit : dernier prix d'achat, coût moyen pondéré, min / max, prix de vente, taux de marge.
  Future<List<LigneSituation>> coutProduit(FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation nom, p.prix_achat pa, p.prix_vente pv,
        (SELECT l.prix_achat FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
          WHERE l.produit_code = p.code AND a.statut = ? ORDER BY a.date DESC LIMIT 1) dernier,
        (SELECT SUM(l.total) / NULLIF(SUM(l.quantite), 0) FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
          WHERE l.produit_code = p.code AND a.statut = ?) cmp,
        (SELECT MIN(l.prix_achat) FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
          WHERE l.produit_code = p.code AND a.statut = ?) mini,
        (SELECT MAX(l.prix_achat) FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
          WHERE l.produit_code = p.code AND a.statut = ?) maxi
      FROM produit p WHERE p.actif = 1 AND (? IS NULL OR p.categorie_code = ?)
      ORDER BY p.designation
      ''',
      [_achatValide, _achatValide, _achatValide, _achatValide, f.categorie, f.categorie],
    );
    return [
      for (final r in rows)
        () {
          // Sans achat enregistré, le coût est le prix d'achat de la fiche.
          final cmp = r['cmp'] == null ? _d(r['pa']) : CalculsPrix.arrondir(_d(r['cmp']));
          final pv = _d(r['pv']);
          return <String, Object?>{
            'code': r['code'],
            'nom': r['nom'],
            'dernier': r['dernier'] == null ? _d(r['pa']) : _d(r['dernier']),
            'moyen': cmp,
            'min': r['mini'] == null ? _d(r['pa']) : _d(r['mini']),
            'max': r['maxi'] == null ? _d(r['pa']) : _d(r['maxi']),
            'prixVente': pv,
            'taux': cmp <= 0 ? null : CalculsPrix.arrondir((pv - cmp) / cmp * 100),
          };
        }(),
    ];
  }

  // ---------------------------------------------------------------- Marges

  /// 5 · Marge par panier : vente, coût (figé à la vente), marge, taux (sur le coût).
  Future<List<LigneSituation>> margeParPanier(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code, v.date, c.nom client, v.total_net montant,
        COALESCE((SELECT SUM(l.total_achat) FROM vente_ligne l WHERE l.vente_code = v.code), 0) cout
      FROM vente v JOIN client c ON c.code = v.client_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ?
        AND (? IS NULL OR v.utilisateur_code = ?) AND (? IS NULL OR v.client_code = ?)
      ORDER BY v.date DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin), f.caissier, f.caissier, f.client, f.client],
    );
    return [
      for (final r in rows)
        _marge(r, {'code': r['code'], 'date': DateTime.parse(r['date'] as String).toLocal(), 'client': r['client']}),
    ];
  }

  LigneSituation _marge(Map<String, Object?> r, LigneSituation base) {
    final montant = _d(r['montant']);
    final cout = CalculsPrix.arrondir(_d(r['cout']));
    final marge = CalculsPrix.arrondir(montant - cout);
    return {
      ...base,
      'montant': montant,
      'cout': cout,
      'marge': marge,
      'taux': cout <= 0 ? null : CalculsPrix.arrondir(marge / cout * 100),
    };
  }

  /// 6 · Marge par période : CA, coût, marge, taux par jour, semaine ou mois.
  Future<List<LigneSituation>> margeParPeriode(DateTime debut, DateTime fin, FiltresSituation f) async {
    final cle = switch (f.regroupement) {
      Regroupement.jour => "date(v.date, 'localtime')",
      Regroupement.semaine => "strftime('%Y-S%W', v.date, 'localtime')",
      Regroupement.mois => "strftime('%Y-%m', v.date, 'localtime')",
    };
    final rows = await db.rawQuery(
      '''
      SELECT $cle k, SUM(v.total_net) montant,
        SUM(COALESCE((SELECT SUM(l.total_achat) FROM vente_ligne l WHERE l.vente_code = v.code), 0)) cout
      FROM vente v WHERE v.statut = ? AND v.date >= ? AND v.date < ?
      GROUP BY k ORDER BY k
      ''',
      [_venteValidee, ..._bornes(debut, fin)],
    );
    return [
      for (final r in rows) _marge(r, {'periode': r['k']}),
    ];
  }

  // ---------------------------------------------------------------- Tableau de bord

  /// Total des ventes validées sur [debut, fin] (jours inclus).
  Future<double> totalVentes(DateTime debut, DateTime fin) async => _d(
    (await db.rawQuery('SELECT COALESCE(SUM(total_net), 0) t FROM vente WHERE statut = ? AND date >= ? AND date < ?', [
      _venteValidee,
      ..._bornes(debut, fin),
    ])).first['t'],
  );

  /// Total des entrées (achats) validées sur [debut, fin].
  Future<double> totalAchats(DateTime debut, DateTime fin) async => _d(
    (await db.rawQuery('SELECT COALESCE(SUM(total), 0) t FROM achat WHERE statut = ? AND date >= ? AND date < ?', [
      _achatValide,
      ..._bornes(debut, fin),
    ])).first['t'],
  );

  /// Ventes par caissier : (nom, nombre de tickets, total), décroissant.
  Future<List<({String nom, int tickets, double total})>> ventesParCaissier(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT COALESCE(u.nom, v.utilisateur_code) nom, COUNT(*) n, SUM(v.total_net) t
      FROM vente v LEFT JOIN utilisateur u ON u.code = v.utilisateur_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ? GROUP BY v.utilisateur_code ORDER BY t DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin)],
    );
    return [for (final r in rows) (nom: r['nom'] as String, tickets: r['n'] as int, total: _d(r['t']))];
  }

  /// Top produits : (désignation, quantité, total), décroissant.
  Future<List<({String nom, double quantite, double total})>> topProduits(
    DateTime debut,
    DateTime fin, {
    int n = 5,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.designation d, SUM(l.quantite) q, SUM(l.total) t FROM vente_ligne l
      JOIN vente v ON v.code = l.vente_code JOIN produit p ON p.code = l.produit_code
      WHERE v.statut = ? AND v.date >= ? AND v.date < ? GROUP BY l.produit_code ORDER BY t DESC LIMIT ?
      ''',
      [_venteValidee, ..._bornes(debut, fin), n],
    );
    return [for (final r in rows) (nom: r['d'] as String, quantite: _d(r['q']), total: _d(r['t']))];
  }

  /// Produits actifs en rupture (stock ≤ 0), magasin optionnel.
  Future<List<({String code, String nom, double stock})>> ruptures({String? magasin, int limite = 50}) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation d, COALESCE((SELECT SUM(m.quantite) FROM mouvement_stock m
        WHERE m.produit_code = p.code AND (? IS NULL OR m.magasin_code = ?)), 0) q
      FROM produit p WHERE p.actif = 1 AND q <= 0 ORDER BY p.designation LIMIT ?
      ''',
      [magasin, magasin, limite],
    );
    return [for (final r in rows) (code: r['code'] as String, nom: r['d'] as String, stock: _d(r['q']))];
  }

  /// Dernières ventes (toutes, annulées comprises) : code, date, client, premier mode, montant, statut DS.
  Future<List<LigneSituation>> dernieresVentes({int n = 5}) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code, v.date, c.nom client, v.total_net montant, v.statut, $_resteVente reste,
        (SELECT p.mode FROM vente_paiement p WHERE p.vente_code = v.code ORDER BY p.ordre LIMIT 1) mode
      FROM vente v JOIN client c ON c.code = v.client_code ORDER BY v.date DESC LIMIT ?
      ''',
      [n],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'date': DateTime.parse(r['date'] as String).toLocal(),
          'client': r['client'],
          'mode': r['mode'],
          'montant': _d(r['montant']),
          'statut': r['statut'] != _venteValidee
              ? 'annule'
              : (_d(r['reste']) > 0.004 ? (_d(r['reste']) < _d(r['montant']) ? 'partiel' : 'credit') : 'paye'),
        },
    ];
  }
}
