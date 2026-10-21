import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/vente.dart';

/// Requêtes des alertes du shell (§5.3).
class AlertesRepository {
  const AlertesRepository(this.db);

  final DatabaseExecutor db;

  /// Condition SQL sur `produit p` : exclut les produits du catalogue BENS jamais entrés en stock.
  static const String sansStockCatalogue =
      "NOT (p.source = 'Catalogue' AND NOT EXISTS (SELECT 1 FROM mouvement_stock m WHERE m.produit_code = p.code))";

  /// Produits actifs dont le stock (magasins [magasins], tous si `null`) est ≤ leur seuil
  /// (seuil du produit, sinon [seuilGlobal]) ; ruptures d'abord. Un produit téléchargé du catalogue BENS
  /// qui n'est jamais entré en stock ([sansStockCatalogue]) n'est pas une rupture : le commerce ne le vend
  /// peut-être pas encore.
  Future<List<Map<String, Object?>>> ruptures({required int seuilGlobal, List<String>? magasins}) {
    final filtre = magasins == null ? '' : 'WHERE magasin_code IN (${List.filled(magasins.length, '?').join(',')})';
    return db.rawQuery(
      '''
      SELECT p.code, p.designation, COALESCE(c.nom, '') categorie, COALESCE(s.q, 0) stock,
             COALESCE(p.seuil_stock, ?) seuil
      FROM produit p
      LEFT JOIN categorie c ON c.code = p.categorie_code
      LEFT JOIN (SELECT produit_code, SUM(quantite) q FROM mouvement_stock $filtre GROUP BY produit_code) s
        ON s.produit_code = p.code
      WHERE p.actif = 1 AND p.service = 0 AND COALESCE(s.q, 0) <= COALESCE(p.seuil_stock, ?) AND $sansStockCatalogue
      ORDER BY COALESCE(s.q, 0) > 0, COALESCE(s.q, 0), p.designation
      ''',
      [seuilGlobal, ...?magasins, seuilGlobal],
    );
  }

  /// Plus gros restes dus par client (ventes validées − imputations), [limite] premiers.
  /// Produits actifs en stock (magasins [magasins], tous si `null`) dont la date d'expiration
  /// (`date_empreint` de la spec) est au plus [jusquA] (`AAAA-MM-JJ`) ; les plus proches d'abord.
  Future<List<Map<String, Object?>>> expirations({required String jusquA, List<String>? magasins}) {
    final filtre = magasins == null ? '' : 'WHERE magasin_code IN (${List.filled(magasins.length, '?').join(',')})';
    return db.rawQuery(
      '''
      SELECT p.code, p.designation, COALESCE(c.nom, '') categorie, s.q stock, substr(p.date_expiration, 1, 10) expire_le
      FROM produit p
      LEFT JOIN categorie c ON c.code = p.categorie_code
      JOIN (SELECT produit_code, SUM(quantite) q FROM mouvement_stock $filtre GROUP BY produit_code) s
        ON s.produit_code = p.code
      WHERE p.actif = 1 AND s.q > 0 AND p.date_expiration IS NOT NULL AND substr(p.date_expiration, 1, 10) <= ?
      ORDER BY expire_le, p.designation
      ''',
      [...?magasins, jusquA],
    );
  }

  /// Plus gros soldes clients débiteurs (vue `solde_tiers`, avances comprises), au-delà de [seuil].
  Future<List<Map<String, Object?>>> creditsClients({int limite = 3, double seuil = 0}) => db.rawQuery(
    '''
    SELECT c.code, c.nom, s.solde du, s.dernier derniere
    FROM solde_tiers s JOIN client c ON c.code = s.tiers_code
    WHERE s.tiers_type = 'Client' AND s.solde > MAX(0.005, ?)
    ORDER BY s.solde DESC LIMIT ?
    ''',
    [seuil, limite],
  );

  /// Plus grosses dettes par fournisseur (vue `solde_tiers`, avances déduites), [limite] premières.
  Future<List<Map<String, Object?>>> dettesFournisseurs({int limite = 3}) => db.rawQuery(
    '''
    SELECT f.code, f.nom, s.solde du, s.dernier derniere
    FROM solde_tiers s JOIN fournisseur f ON f.code = s.tiers_code
    WHERE s.tiers_type = 'Fournisseur' AND s.solde > 0.005
    ORDER BY s.solde DESC LIMIT ?
    ''',
    [limite],
  );

  /// Sessions de caisse encore ouvertes, démarrées avant [debutJour].
  Future<List<Map<String, Object?>>> sessionsAnciennes(DateTime debutJour) => db.rawQuery(
    '''
    SELECT s.code, s.ouverte_le, COALESCE(k.nom, s.caisse_code) caisse, COALESCE(u.nom, s.utilisateur_code) utilisateur
    FROM session_caisse s
    LEFT JOIN caisse k ON k.code = s.caisse_code
    LEFT JOIN utilisateur u ON u.code = s.utilisateur_code
    WHERE s.statut = ? AND s.ouverte_le < ?
    ORDER BY s.ouverte_le
    ''',
    [StatutsSession.ouverte, debutJour.toUtc().toIso8601String()],
  );
}
