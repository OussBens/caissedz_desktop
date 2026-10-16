import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';

/// Point d'une série (étiquette, valeur).
typedef PointSerie = ({String etiquette, double valeur});

/// Requêtes d'agrégation (tableau de bord, zakat). Lecture seule. Les analyses de la Situation sont dans
/// `SituationRepository`.
class StatistiquesRepository {
  const StatistiquesRepository(this.db);
  final DatabaseExecutor db;

  static const String _validee = 'Validée';

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  Future<double> _somme(String sql, List<Object?> args) async =>
      ((await db.rawQuery(sql, args)).first.values.first as num? ?? 0).toDouble();

  /// Créances clients = Σ des soldes clients positifs (vue `solde_tiers`, même valeur que la liste Clients).
  Future<double> creancesClients() async => CalculsPrix.arrondir(
    await _somme("SELECT COALESCE(SUM(solde), 0) FROM solde_tiers WHERE tiers_type = 'Client' AND solde > 0", const []),
  );

  /// Dettes fournisseurs = Σ des soldes fournisseurs positifs (vue `solde_tiers`) ; une avance chez un
  /// fournisseur ne réduit pas la dette envers un autre.
  Future<double> dettesFournisseurs() async => CalculsPrix.arrondir(
    await _somme(
      "SELECT COALESCE(SUM(solde), 0) FROM solde_tiers WHERE tiers_type = 'Fournisseur' AND solde > 0",
      const [],
    ),
  );

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
      WHERE p.actif = 1 AND p.service = 0 AND COALESCE(s.q, 0) < COALESCE(p.seuil_stock, ?)
      ''',
      [seuilGlobal],
    );
    return rows.first['n'] as int;
  }

  /// CA net par jour sur [debut, fin] (retours clients déduits à leur date), jours sans vente à 0.
  Future<List<PointSerie>> caParJour(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT j, SUM(t) t FROM (
        SELECT date(date, 'localtime') j, total_net t FROM vente WHERE statut = ?1 AND date >= ?2 AND date < ?3
        UNION ALL
        SELECT date(date, 'localtime'), -total FROM retour WHERE type = 'Client' AND etat = 1 AND date >= ?2 AND date < ?3
      ) GROUP BY j
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

  /// Encaissements des ventes par mode ; la monnaie rendue est déduite des espèces (comme la Z).
  Future<List<PointSerie>> paiementsParMode(DateTime debut, DateTime fin) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.mode m, SUM(p.montant) t FROM vente_paiement p JOIN vente v ON v.code = p.vente_code
      WHERE v.statut = ?1 AND v.date >= ?2 AND v.date <= ?3 GROUP BY p.mode
      ''',
      [_validee, _iso(debut), _iso(fin)],
    );
    final rendu = await _somme(
      '''
      SELECT COALESCE(SUM(CASE WHEN verse > total_net THEN verse - total_net ELSE 0 END), 0) FROM vente
      WHERE statut = ?1 AND date >= ?2 AND date <= ?3
      ''',
      [_validee, _iso(debut), _iso(fin)],
    );
    final parMode = {for (final r in rows) r['m'] as String: (r['t'] as num).toDouble()};
    if (rendu > 0) parMode['Espèces'] = (parMode['Espèces'] ?? 0) - rendu;
    parMode.removeWhere((_, m) => m.abs() < 0.005);
    final tries = parMode.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in tries) (etiquette: e.key, valeur: CalculsPrix.arrondir(e.value))];
  }
}
