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

  /// Retours clients actifs avec leur coût d'achat (prix d'achat figé × quantité) : `r.*`, `cout`.
  /// Retour remis en stock : le coût revient en stock (déduit du coût des ventes) ; « Casse » : le coût reste
  /// une perte.
  static const String _retoursClients = '''
    (SELECT r.*, COALESCE((SELECT SUM(rl.prix_achat * rl.quantite) FROM retour_ligne rl
      WHERE rl.retour_code = r.code), 0) cout
     FROM retour r WHERE r.type = 'Client' AND r.etat = 1)''';

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

  /// 2 · Recette par produit : quantité, prix moyen, recette, nettes des retours clients (à leur date).
  Future<List<LigneSituation>> recetteParProduit(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT x.code, p.designation nom, cat.nom categorie, SUM(x.q) q, SUM(x.ca) ca FROM (
        SELECT l.produit_code code, l.quantite q, l.total ca
        FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
        WHERE v.statut = ?1 AND v.date >= ?2 AND v.date < ?3 AND (?4 IS NULL OR v.caisse_code = ?4)
        UNION ALL
        SELECT rl.produit_code, -rl.quantite, -rl.total
        FROM retour_ligne rl JOIN retour r ON r.code = rl.retour_code
        WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ?2 AND r.date < ?3 AND (?4 IS NULL OR r.caisse_code = ?4)
      ) x JOIN produit p ON p.code = x.code LEFT JOIN categorie cat ON cat.code = p.categorie_code
      WHERE (?5 IS NULL OR p.categorie_code = ?5)
      GROUP BY x.code ORDER BY ca DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin), f.caisse, f.categorie],
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

  /// 4 · Mouvement produit : stock initial, entrées, sorties, retours, stock final sur la période (audit m14).
  /// Les annulations de vente diminuent les sorties (elles ne sont pas des retours) ; tous magasins confondus,
  /// les transferts internes (entrée et sortie) sont ignorés.
  Future<List<LigneSituation>> mouvementProduit(DateTime debut, DateTime fin, FiltresSituation f) async {
    final b = _bornes(debut, fin);
    final tous = f.magasin == null;
    final exclus =
        "m.type NOT IN ('${TypesMouvement.retour}', '${TypesMouvement.annulation}'"
        "${tous ? ", '${TypesMouvement.transfert}'" : ''})";
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation nom,
        COALESCE(SUM(CASE WHEN m.date < ? THEN m.quantite END), 0) ini,
        COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND $exclus AND m.quantite > 0 THEN m.quantite END), 0) ent,
        COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND $exclus AND m.quantite < 0 THEN -m.quantite END), 0)
          - COALESCE(SUM(CASE WHEN m.date >= ? AND m.date < ? AND m.type = ? THEN m.quantite END), 0) sor,
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
        ...b,
        ...b,
        TypesMouvement.annulation,
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
          AND (? IS NULL OR m.magasin_code = ?)), 0) theo,
        COALESCE((SELECT SUM(m.nombre) FROM mouvement_stock m WHERE m.produit_code = p.code
          AND (? IS NULL OR m.magasin_code = ?)), 0) theo_n
      FROM produit p LEFT JOIN categorie cat ON cat.code = p.categorie_code
      WHERE p.actif = 1 AND p.service = 0 AND (? IS NULL OR p.categorie_code = ?)
      ORDER BY p.designation
      ''',
      [f.magasin, f.magasin, f.magasin, f.magasin, f.categorie, f.categorie],
    );
    return [
      for (final r in rows)
        {
          'code': r['code'],
          'nom': r['nom'],
          'categorie': r['categorie'] ?? '',
          'theorique': _d(r['theo']),
          'theoriqueNombre': _d(r['theo_n']),
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
      FROM produit p WHERE p.actif = 1 AND p.code <> 'PRD0000' AND (? IS NULL OR p.categorie_code = ?)
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

  /// 5 · Marge par panier : vente nette de ses retours, coût (figé à la vente, moins les retours remis en stock),
  /// marge, taux (sur le coût), montant retourné et perte « Casse ».
  Future<List<LigneSituation>> margeParPanier(DateTime debut, DateTime fin, FiltresSituation f) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code, v.date, c.nom client,
        v.total_net - COALESCE((SELECT SUM(r.total) FROM $_retoursClients r WHERE r.document_code = v.code), 0) montant,
        COALESCE((SELECT SUM(l.total_achat) FROM vente_ligne l WHERE l.vente_code = v.code), 0)
          - COALESCE((SELECT SUM(r.cout) FROM $_retoursClients r WHERE r.document_code = v.code
            AND r.remise_en_stock = 1), 0) cout,
        COALESCE((SELECT SUM(r.total) FROM $_retoursClients r WHERE r.document_code = v.code), 0) retours,
        COALESCE((SELECT SUM(r.cout) FROM $_retoursClients r WHERE r.document_code = v.code
          AND r.remise_en_stock = 0), 0) casse
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
      'retours': CalculsPrix.arrondir(_d(r['retours'])),
      'casse': CalculsPrix.arrondir(_d(r['casse'])),
    };
  }

  /// 6 · Marge par période : CA et coût nets des retours clients (à la date du retour), marge, taux par jour,
  /// semaine ou mois ; un retour « Casse » garde son coût (perte).
  Future<List<LigneSituation>> margeParPeriode(DateTime debut, DateTime fin, FiltresSituation f) async {
    String cle(String col) => switch (f.regroupement) {
      Regroupement.jour => "date($col, 'localtime')",
      Regroupement.semaine => "strftime('%Y-S%W', $col, 'localtime')",
      Regroupement.mois => "strftime('%Y-%m', $col, 'localtime')",
    };
    final rows = await db.rawQuery(
      '''
      SELECT k, SUM(montant) montant, SUM(cout) cout, SUM(retours) retours, SUM(casse) casse FROM (
        SELECT ${cle('v.date')} k, v.total_net montant,
          COALESCE((SELECT SUM(l.total_achat) FROM vente_ligne l WHERE l.vente_code = v.code), 0) cout,
          0 retours, 0 casse
        FROM vente v WHERE v.statut = ?1 AND v.date >= ?2 AND v.date < ?3
        UNION ALL
        SELECT ${cle('r.date')}, -r.total, CASE WHEN r.remise_en_stock = 1 THEN -r.cout ELSE 0 END,
          r.total, CASE WHEN r.remise_en_stock = 0 THEN r.cout ELSE 0 END
        FROM $_retoursClients r WHERE r.date >= ?2 AND r.date < ?3
      ) GROUP BY k ORDER BY k
      ''',
      [_venteValidee, ..._bornes(debut, fin)],
    );
    return [
      for (final r in rows) _marge(r, {'periode': r['k']}),
    ];
  }

  // ---------------------------------------------------------------- Tableau de bord

  /// Chiffre d'affaires net sur [debut, fin] (jours inclus) : ventes validées − retours clients (à leur date).
  Future<double> totalVentes(DateTime debut, DateTime fin) async => CalculsPrix.arrondir(
    _d(
      (await db.rawQuery(
        '''
        SELECT COALESCE((SELECT SUM(total_net) FROM vente WHERE statut = ?1 AND date >= ?2 AND date < ?3), 0)
          - COALESCE((SELECT SUM(total) FROM retour WHERE type = 'Client' AND etat = 1 AND date >= ?2 AND date < ?3), 0) t
        ''',
        [_venteValidee, ..._bornes(debut, fin)],
      )).first['t'],
    ),
  );

  /// Total des entrées (achats) validées sur [debut, fin].
  Future<double> totalAchats(DateTime debut, DateTime fin) async => _d(
    (await db.rawQuery('SELECT COALESCE(SUM(total), 0) t FROM achat WHERE statut = ? AND date >= ? AND date < ?', [
      _achatValide,
      ..._bornes(debut, fin),
    ])).first['t'],
  );

  /// Ventes par caissier : (nom, nombre de tickets, total net des retours de ses tickets), décroissant.
  Future<List<({String nom, int tickets, double total})>> ventesParCaissier(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT COALESCE(u.nom, x.u) nom, SUM(x.n) n, SUM(x.t) t FROM (
        SELECT v.utilisateur_code u, 1 n, v.total_net t FROM vente v
        WHERE v.statut = ?1 AND v.date >= ?2 AND v.date < ?3
        UNION ALL
        SELECT v.utilisateur_code, 0, -r.total FROM retour r JOIN vente v ON v.code = r.document_code
        WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ?2 AND r.date < ?3
      ) x LEFT JOIN utilisateur u ON u.code = x.u GROUP BY x.u ORDER BY t DESC
      ''',
      [_venteValidee, ..._bornes(debut, fin)],
    );
    return [for (final r in rows) (nom: r['nom'] as String, tickets: r['n'] as int, total: _d(r['t']))];
  }

  /// Top produits : (désignation, quantité, total) nets des retours clients, décroissant.
  Future<List<({String nom, double quantite, double total})>> topProduits(
    DateTime debut,
    DateTime fin, {
    int n = 5,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.designation d, SUM(x.q) q, SUM(x.t) t FROM (
        SELECT l.produit_code c, l.quantite q, l.total t FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
        WHERE v.statut = ?1 AND v.date >= ?2 AND v.date < ?3
        UNION ALL
        SELECT rl.produit_code, -rl.quantite, -rl.total FROM retour_ligne rl JOIN retour r ON r.code = rl.retour_code
        WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ?2 AND r.date < ?3
      ) x JOIN produit p ON p.code = x.c GROUP BY x.c HAVING SUM(x.t) > 0 ORDER BY t DESC LIMIT ?4
      ''',
      [_venteValidee, ..._bornes(debut, fin), n],
    );
    return [for (final r in rows) (nom: r['d'] as String, quantite: _d(r['q']), total: _d(r['t']))];
  }

  /// Produits actifs en rupture (stock ≤ 0), magasin optionnel.
  /// Ruptures (stock ≤ 0) sur les magasins [magasins] (tous si `null`) : même périmètre que les alertes (m5).
  Future<List<({String code, String nom, double stock})>> ruptures({List<String>? magasins, int limite = 50}) async {
    final filtre = magasins == null ? '' : 'AND m.magasin_code IN (${List.filled(magasins.length, '?').join(',')})';
    final rows = await db.rawQuery(
      '''
      SELECT p.code, p.designation d, COALESCE((SELECT SUM(m.quantite) FROM mouvement_stock m
        WHERE m.produit_code = p.code $filtre), 0) q
      FROM produit p WHERE p.actif = 1 AND p.service = 0 AND q <= 0 ORDER BY p.designation LIMIT ?
      ''',
      [...?magasins, limite],
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
