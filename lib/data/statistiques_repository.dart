import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';
import '../domain/models/rapport.dart';

/// Indicateurs du tableau de bord.
class Kpi {
  const Kpi({
    required this.caJour,
    required this.ticketsJour,
    required this.panierMoyen,
    required this.caMois,
    required this.produitsSousSeuil,
    required this.creancesClients,
  });
  final double caJour;
  final int ticketsJour;
  final double panierMoyen;
  final double caMois;
  final int produitsSousSeuil;
  final double creancesClients;
}

/// Point d'une série (étiquette, valeur).
typedef PointSerie = ({String etiquette, double valeur});

/// Requêtes d'agrégation (tableau de bord, Situation, zakat). Lecture seule.
class StatistiquesRepository {
  const StatistiquesRepository(this.db);
  final DatabaseExecutor db;

  static const String _validee = 'Validée';

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  Future<double> _somme(String sql, List<Object?> args) async =>
      ((await db.rawQuery(sql, args)).first.values.first as num? ?? 0).toDouble();

  /// Créances clients = Σ (reste − imputations) des ventes validées − versements clients non imputés.
  Future<double> creancesClients() async {
    final du = await _somme(
      '''
      SELECT COALESCE(SUM(v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
        WHERE i.document_type = 'vente' AND i.document_code = v.code), 0)), 0)
      FROM vente v WHERE v.statut = ? AND v.reste > 0
      ''',
      [_validee],
    );
    final avances = await _somme('''
      SELECT COALESCE(SUM(v.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
        WHERE i.versement_code = v.code), 0)), 0)
      FROM versement v WHERE v.tiers_type = 'Client' AND v.sens = 'Encaissement' AND v.etat = 1
      ''', const []);
    return CalculsPrix.arrondir(du - avances);
  }

  /// Dettes fournisseurs = Σ (total − imputations) des achats validés − versements fournisseurs non imputés.
  Future<double> dettesFournisseurs() async {
    final du = await _somme('''
      SELECT COALESCE(SUM(a.total - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
        WHERE i.document_type = 'achat' AND i.document_code = a.code), 0)), 0)
      FROM achat a WHERE a.statut = 'Validé'
      ''', const []);
    final avances = await _somme('''
      SELECT COALESCE(SUM(v.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
        WHERE i.versement_code = v.code), 0)), 0)
      FROM versement v WHERE v.tiers_type = 'Fournisseur' AND v.sens = 'Décaissement' AND v.etat = 1
      ''', const []);
    return CalculsPrix.arrondir(du - avances);
  }

  /// Valeur du stock au prix d'achat (tous magasins, quantités positives).
  Future<double> valeurStockAchat() => _somme('''
    SELECT COALESCE(SUM(CASE WHEN s.q > 0 THEN s.q * p.prix_achat ELSE 0 END), 0) FROM
      (SELECT produit_code, SUM(quantite) q FROM mouvement_stock GROUP BY produit_code) s
      JOIN produit p ON p.code = s.produit_code
    ''', const []);

  /// Solde total de toutes les caisses (Σ entrées − sorties).
  Future<double> soldeCaisses() => _somme(
    "SELECT COALESCE(SUM(CASE WHEN sens = 'Entrée' THEN montant ELSE -montant END), 0) FROM mouvement_caisse",
    const [],
  );

  Future<int> produitsSousSeuil(int seuilGlobal) async {
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) n FROM produit p
      LEFT JOIN (SELECT produit_code, SUM(quantite) q FROM mouvement_stock GROUP BY produit_code) s ON s.produit_code = p.code
      WHERE p.actif = 1 AND COALESCE(s.q, 0) < COALESCE(p.seuil_stock, ?)
      ''',
      [seuilGlobal],
    );
    return rows.first['n'] as int;
  }

  Future<Kpi> kpi({required DateTime jour, required int seuilGlobal}) async {
    final debutJour = DateTime(jour.year, jour.month, jour.day);
    final finJour = debutJour.add(const Duration(days: 1));
    final debutMois = DateTime(jour.year, jour.month);
    final finMois = DateTime(jour.year, jour.month + 1);
    final j = (await db.rawQuery(
      'SELECT COUNT(*) n, COALESCE(SUM(total_net), 0) t FROM vente WHERE statut = ? AND date >= ? AND date < ?',
      [_validee, _iso(debutJour), _iso(finJour)],
    )).first;
    final m = await _somme(
      'SELECT COALESCE(SUM(total_net), 0) FROM vente WHERE statut = ? AND date >= ? AND date < ?',
      [_validee, _iso(debutMois), _iso(finMois)],
    );
    final n = j['n'] as int;
    final ca = (j['t'] as num).toDouble();
    return Kpi(
      caJour: CalculsPrix.arrondir(ca),
      ticketsJour: n,
      panierMoyen: n == 0 ? 0 : CalculsPrix.arrondir(ca / n),
      caMois: CalculsPrix.arrondir(m),
      produitsSousSeuil: await produitsSousSeuil(seuilGlobal),
      creancesClients: await creancesClients(),
    );
  }

  /// CA par jour sur [debut, fin], jours sans vente à 0.
  Future<List<PointSerie>> caParJour(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT date(date, 'localtime') j, SUM(total_net) t FROM vente
      WHERE statut = ? AND date >= ? AND date < ? GROUP BY j
      ''',
      [_validee, _iso(DateTime(debut.year, debut.month, debut.day)), _iso(DateTime(fin.year, fin.month, fin.day + 1))],
    );
    final parJour = {for (final r in rows) r['j'] as String: (r['t'] as num).toDouble()};
    final points = <PointSerie>[];
    for (var d = DateTime(debut.year, debut.month, debut.day); !d.isAfter(fin); d = d.add(const Duration(days: 1))) {
      final cle =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      points.add((
        etiquette: '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
        valeur: parJour[cle] ?? 0,
      ));
    }
    return points;
  }

  /// CA des [n] derniers mois (mois courant inclus).
  Future<List<PointSerie>> caParMois(DateTime jusqua, {int n = 12}) async {
    final debut = DateTime(jusqua.year, jusqua.month - (n - 1));
    final rows = await db.rawQuery(
      '''
      SELECT strftime('%Y-%m', date, 'localtime') m, SUM(total_net) t FROM vente
      WHERE statut = ? AND date >= ? GROUP BY m
      ''',
      [_validee, _iso(debut)],
    );
    final parMois = {for (final r in rows) r['m'] as String: (r['t'] as num).toDouble()};
    return [
      for (var i = 0; i < n; i++)
        () {
          final d = DateTime(debut.year, debut.month + i);
          final cle = '${d.year}-${d.month.toString().padLeft(2, '0')}';
          return (etiquette: '${d.month.toString().padLeft(2, '0')}/${d.year % 100}', valeur: parMois[cle] ?? 0);
        }(),
    ];
  }

  Future<List<PointSerie>> paiementsParMode(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.mode m, SUM(p.montant) t FROM vente_paiement p JOIN vente v ON v.code = p.vente_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY p.mode ORDER BY t DESC
      ''',
      [_validee, _iso(debut), _iso(fin)],
    );
    return [for (final r in rows) (etiquette: r['m'] as String, valeur: (r['t'] as num).toDouble())];
  }

  Future<List<PointSerie>> topProduits(DateTime debut, DateTime fin, {int n = 5}) async {
    final rows = await db.rawQuery(
      '''
      SELECT l.designation d, SUM(l.total) t FROM vente_ligne l JOIN vente v ON v.code = l.vente_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY l.produit_code ORDER BY t DESC LIMIT ?
      ''',
      [_validee, _iso(debut), _iso(fin), n],
    );
    return [for (final r in rows) (etiquette: r['d'] as String, valeur: (r['t'] as num).toDouble())];
  }

  Future<List<PointSerie>> ventesParCategorie(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT c.nom n, SUM(l.total) t FROM vente_ligne l
      JOIN vente v ON v.code = l.vente_code JOIN produit p ON p.code = l.produit_code JOIN categorie c ON c.code = p.categorie_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY c.code ORDER BY t DESC
      ''',
      [_validee, _iso(debut), _iso(fin)],
    );
    return [for (final r in rows) (etiquette: r['n'] as String, valeur: (r['t'] as num).toDouble())];
  }

  // ---- Situation : 10 rapports ----
  static const List<String> rapports = [
    'ventes_jour',
    'ventes_produit',
    'ventes_categorie',
    'ventes_client',
    'ventes_vendeur',
    'encaissements_mode',
    'achats_fournisseur',
    'retours',
    'etat_stock',
    'creances_dettes',
  ];

  Future<Rapport> rapport(String id, {required DateTime debut, required DateTime fin, int seuilGlobal = 5}) =>
      switch (id) {
        'ventes_jour' => _ventesJour(debut, fin),
        'ventes_produit' => _ventesProduit(debut, fin),
        'ventes_categorie' => _ventesCategorie(debut, fin),
        'ventes_client' => _ventesClient(debut, fin),
        'ventes_vendeur' => _ventesVendeur(debut, fin),
        'encaissements_mode' => _encaissementsMode(debut, fin),
        'achats_fournisseur' => _achatsFournisseur(debut, fin),
        'retours' => _retours(debut, fin),
        'etat_stock' => _etatStock(seuilGlobal),
        'creances_dettes' => _creancesDettes(),
        _ => throw ArgumentError.value(id, 'id', 'rapport inconnu'),
      };

  double _d(Object? v) => (v as num? ?? 0).toDouble();
  List<Object?> _args(DateTime debut, DateTime fin) => [_validee, _iso(debut), _iso(fin)];

  Future<Rapport> _ventesJour(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT date(date, 'localtime') j, COUNT(*) n, SUM(total_brut) b, SUM(total_remise) r, SUM(total_net) t,
             SUM(CASE WHEN verse > total_net THEN total_net ELSE verse END) e, SUM(reste) c
      FROM vente WHERE statut = ? AND date >= ? AND date <= ? GROUP BY j ORDER BY j
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows)
        [_jourFr(r['j'] as String), r['n'], _d(r['b']), _d(r['r']), _d(r['t']), _d(r['e']), _d(r['c'])],
    ];
    return Rapport(
      id: 'ventes_jour',
      titre: 'Ventes par jour',
      colonnes: const [
        RapportColonne('Jour'),
        RapportColonne('Tickets', numerique: true),
        RapportColonne('Brut', numerique: true, monetaire: true),
        RapportColonne('Remises', numerique: true, monetaire: true),
        RapportColonne('Net', numerique: true, monetaire: true),
        RapportColonne('Encaissé', numerique: true, monetaire: true),
        RapportColonne('À crédit', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 7, textes: {0: 'Total'}),
    );
  }

  Future<Rapport> _ventesProduit(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT l.produit_code c, l.designation d, SUM(l.quantite) q, SUM(l.total) t, SUM(l.quantite) * p.prix_achat k
      FROM vente_ligne l JOIN vente v ON v.code = l.vente_code JOIN produit p ON p.code = l.produit_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY l.produit_code ORDER BY t DESC
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows)
        [r['c'], r['d'], _d(r['q']), _d(r['t']), _d(r['k']), CalculsPrix.arrondir(_d(r['t']) - _d(r['k']))],
    ];
    return Rapport(
      id: 'ventes_produit',
      titre: 'Ventes par produit',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Désignation', flex: 3),
        RapportColonne('Quantité', numerique: true),
        RapportColonne('CA', numerique: true, monetaire: true),
        RapportColonne('Coût estimé', numerique: true, monetaire: true),
        RapportColonne('Marge', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 6, textes: {0: 'Total', 1: ''}),
    );
  }

  Future<Rapport> _ventesCategorie(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT c.code cc, c.nom n, SUM(l.quantite) q, SUM(l.total) t FROM vente_ligne l
      JOIN vente v ON v.code = l.vente_code JOIN produit p ON p.code = l.produit_code JOIN categorie c ON c.code = p.categorie_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY c.code ORDER BY t DESC
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows) [r['cc'], r['n'], _d(r['q']), _d(r['t'])],
    ];
    return Rapport(
      id: 'ventes_categorie',
      titre: 'Ventes par catégorie',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Catégorie', flex: 3),
        RapportColonne('Quantité', numerique: true),
        RapportColonne('CA', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 4, textes: {0: 'Total', 1: ''}),
    );
  }

  Future<Rapport> _ventesClient(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT v.client_code c, cl.nom n, COUNT(*) nb, SUM(v.total_net) t, SUM(v.reste) r
      FROM vente v JOIN client cl ON cl.code = v.client_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY v.client_code ORDER BY t DESC
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows) [r['c'], r['n'], r['nb'], _d(r['t']), _d(r['r'])],
    ];
    return Rapport(
      id: 'ventes_client',
      titre: 'Ventes par client',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Client', flex: 3),
        RapportColonne('Tickets', numerique: true),
        RapportColonne('CA', numerique: true, monetaire: true),
        RapportColonne('Reste dû', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 5, textes: {0: 'Total', 1: ''}),
    );
  }

  Future<Rapport> _ventesVendeur(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT v.utilisateur_code c, COALESCE(u.nom, v.utilisateur_code) n, v.caisse_code k, COUNT(*) nb, SUM(v.total_net) t
      FROM vente v LEFT JOIN utilisateur u ON u.code = v.utilisateur_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY v.utilisateur_code, v.caisse_code ORDER BY t DESC
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows) [r['c'], r['n'], r['k'], r['nb'], _d(r['t'])],
    ];
    return Rapport(
      id: 'ventes_vendeur',
      titre: 'Ventes par vendeur et caisse',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Vendeur', flex: 3),
        RapportColonne('Caisse'),
        RapportColonne('Tickets', numerique: true),
        RapportColonne('CA', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 5, textes: {0: 'Total', 1: '', 2: ''}),
    );
  }

  Future<Rapport> _encaissementsMode(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery('''
      SELECT p.mode m, COUNT(*) nb, SUM(p.montant) t FROM vente_paiement p JOIN vente v ON v.code = p.vente_code
      WHERE v.statut = ? AND v.date >= ? AND v.date <= ? GROUP BY p.mode ORDER BY t DESC
      ''', _args(debut, fin));
    final lignes = [
      for (final r in rows) [r['m'], r['nb'], _d(r['t'])],
    ];
    return Rapport(
      id: 'encaissements_mode',
      titre: 'Encaissements par mode de paiement',
      colonnes: const [
        RapportColonne('Mode', flex: 2),
        RapportColonne('Paiements', numerique: true),
        RapportColonne('Montant', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 3, textes: {0: 'Total'}),
    );
  }

  Future<Rapport> _achatsFournisseur(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT a.fournisseur_code c, f.nom n, COUNT(*) nb, SUM(a.total) t, SUM(a.verse) v,
             SUM(a.total - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
               WHERE i.document_type = 'achat' AND i.document_code = a.code), 0)) r
      FROM achat a JOIN fournisseur f ON f.code = a.fournisseur_code
      WHERE a.statut = 'Validé' AND a.date >= ? AND a.date <= ? GROUP BY a.fournisseur_code ORDER BY t DESC
      ''',
      [_iso(debut), _iso(fin)],
    );
    final lignes = [
      for (final r in rows) [r['c'], r['n'], r['nb'], _d(r['t']), _d(r['v']), _d(r['r'])],
    ];
    return Rapport(
      id: 'achats_fournisseur',
      titre: 'Achats par fournisseur',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Fournisseur', flex: 3),
        RapportColonne('Achats', numerique: true),
        RapportColonne('Total', numerique: true, monetaire: true),
        RapportColonne('Versé', numerique: true, monetaire: true),
        RapportColonne('Reste', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 6, textes: {0: 'Total', 1: ''}),
    );
  }

  Future<Rapport> _retours(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT r.code c, r.date d, r.vente_code v, cl.nom n, r.total t, r.rembourse rb, r.motif m
      FROM retour r JOIN client cl ON cl.code = r.client_code
      WHERE r.date >= ? AND r.date <= ? ORDER BY r.date DESC
      ''',
      [_iso(debut), _iso(fin)],
    );
    final lignes = [
      for (final r in rows)
        [
          r['c'],
          _jourFr(DateTime.parse(r['d'] as String).toLocal().toIso8601String()),
          r['v'],
          r['n'],
          _d(r['t']),
          _d(r['rb']),
          r['m'],
        ],
    ];
    return Rapport(
      id: 'retours',
      titre: 'Retours clients',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Date'),
        RapportColonne('Ticket'),
        RapportColonne('Client', flex: 2),
        RapportColonne('Total', numerique: true, monetaire: true),
        RapportColonne('Remboursé', numerique: true, monetaire: true),
        RapportColonne('Motif', flex: 2),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 7, textes: {0: 'Total', 1: '', 2: '', 3: '', 6: ''}),
    );
  }

  Future<Rapport> _etatStock(int seuilGlobal) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.code c, p.designation d, cat.nom n, COALESCE(s.q, 0) q, COALESCE(p.seuil_stock, ?) seuil,
             COALESCE(s.q, 0) * p.prix_achat va, COALESCE(s.q, 0) * p.prix_vente vv
      FROM produit p JOIN categorie cat ON cat.code = p.categorie_code
      LEFT JOIN (SELECT produit_code, SUM(quantite) q FROM mouvement_stock GROUP BY produit_code) s ON s.produit_code = p.code
      WHERE p.actif = 1 ORDER BY p.designation
      ''',
      [seuilGlobal],
    );
    final lignes = [
      for (final r in rows)
        [
          r['c'],
          r['d'],
          r['n'],
          _d(r['q']),
          r['seuil'],
          _d(r['q']) < (r['seuil'] as num).toDouble() ? 'Sous seuil' : 'OK',
          _d(r['va']),
          _d(r['vv']),
        ],
    ];
    return Rapport(
      id: 'etat_stock',
      titre: 'État du stock valorisé',
      colonnes: const [
        RapportColonne('Code'),
        RapportColonne('Désignation', flex: 3),
        RapportColonne('Catégorie', flex: 2),
        RapportColonne('Quantité', numerique: true),
        RapportColonne('Seuil', numerique: true),
        RapportColonne('État'),
        RapportColonne('Valeur achat', numerique: true, monetaire: true),
        RapportColonne('Valeur vente', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: _totaux(lignes, 8, textes: {0: 'Total', 1: '', 2: '', 4: '', 5: ''}),
    );
  }

  Future<Rapport> _creancesDettes() async {
    final clients = await db.rawQuery('''
      SELECT cl.code c, cl.nom n,
        COALESCE((SELECT SUM(v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
            WHERE i.document_type = 'vente' AND i.document_code = v.code), 0))
          FROM vente v WHERE v.client_code = cl.code AND v.statut = 'Validée' AND v.reste > 0), 0)
        - COALESCE((SELECT SUM(ve.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.versement_code = ve.code), 0))
          FROM versement ve WHERE ve.tiers_type = 'Client' AND ve.tiers_code = cl.code AND ve.sens = 'Encaissement' AND ve.etat = 1), 0) s
      FROM client cl WHERE cl.systeme = 0
      ''');
    final fournisseurs = await db.rawQuery('''
      SELECT f.code c, f.nom n,
        COALESCE((SELECT SUM(a.total - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
            WHERE i.document_type = 'achat' AND i.document_code = a.code), 0))
          FROM achat a WHERE a.fournisseur_code = f.code AND a.statut = 'Validé'), 0)
        - COALESCE((SELECT SUM(ve.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.versement_code = ve.code), 0))
          FROM versement ve WHERE ve.tiers_type = 'Fournisseur' AND ve.tiers_code = f.code AND ve.sens = 'Décaissement' AND ve.etat = 1), 0) s
      FROM fournisseur f WHERE f.systeme = 0
      ''');
    final lignes = <List<Object?>>[
      for (final r in clients)
        if (_d(r['s']).abs() > 0.004) ['Client', r['c'], r['n'], CalculsPrix.arrondir(_d(r['s']))],
      for (final r in fournisseurs)
        if (_d(r['s']).abs() > 0.004) ['Fournisseur', r['c'], r['n'], CalculsPrix.arrondir(_d(r['s']))],
    ];
    return Rapport(
      id: 'creances_dettes',
      titre: 'Créances clients et dettes fournisseurs',
      colonnes: const [
        RapportColonne('Type'),
        RapportColonne('Code'),
        RapportColonne('Tiers', flex: 3),
        RapportColonne('Solde', numerique: true, monetaire: true),
      ],
      lignes: lignes,
      totaux: null,
    );
  }

  static String _jourFr(String iso) {
    final p = iso.substring(0, 10).split('-');
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  /// Ligne de totaux : somme des colonnes numériques, textes imposés sur les autres.
  static List<Object?> _totaux(List<List<Object?>> lignes, int n, {Map<int, String> textes = const {}}) => [
    for (var i = 0; i < n; i++)
      if (textes.containsKey(i))
        textes[i]
      else if (lignes.isNotEmpty && lignes.first[i] is int)
        lignes.fold<int>(0, (s, l) => s + (l[i] as int))
      else if (lignes.isNotEmpty && lignes.first[i] is double)
        CalculsPrix.arrondir(lignes.fold<double>(0, (s, l) => s + (l[i] as double)))
      else
        null,
  ];
}
