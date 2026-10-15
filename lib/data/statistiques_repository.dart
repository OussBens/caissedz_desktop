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
}
