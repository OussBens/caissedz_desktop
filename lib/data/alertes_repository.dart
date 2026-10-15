import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/achat.dart';
import '../domain/models/vente.dart';

/// Requêtes des alertes du shell (§5.3).
class AlertesRepository {
  const AlertesRepository(this.db);

  final DatabaseExecutor db;

  /// Produits actifs dont le stock (magasins [magasins], tous si `null`) est ≤ leur seuil
  /// (seuil du produit, sinon [seuilGlobal]) ; ruptures d'abord.
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
      WHERE p.actif = 1 AND COALESCE(s.q, 0) <= COALESCE(p.seuil_stock, ?)
      ORDER BY COALESCE(s.q, 0) > 0, COALESCE(s.q, 0), p.designation
      ''',
      [seuilGlobal, ...?magasins, seuilGlobal],
    );
  }

  /// Plus gros restes dus par client (ventes validées − imputations), [limite] premiers.
  Future<List<Map<String, Object?>>> creditsClients({int limite = 3, double seuil = 0}) => db.rawQuery(
    '''
    SELECT c.code, c.nom, SUM(v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
             WHERE i.document_type = 'vente' AND i.document_code = v.code), 0)) du,
           MAX(v.date) derniere
    FROM vente v JOIN client c ON c.code = v.client_code
    WHERE v.statut = ? AND v.reste > 0
    GROUP BY c.code HAVING du > MAX(0.005, ?) ORDER BY du DESC LIMIT ?
    ''',
    [StatutsVente.validee, seuil, limite],
  );

  /// Plus grosses dettes par fournisseur (achats validés − imputations), [limite] premières.
  Future<List<Map<String, Object?>>> dettesFournisseurs({int limite = 3}) => db.rawQuery(
    '''
    SELECT f.code, f.nom, SUM(a.total - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
             WHERE i.document_type = 'achat' AND i.document_code = a.code), 0)) du,
           MAX(a.date) derniere
    FROM achat a JOIN fournisseur f ON f.code = a.fournisseur_code
    WHERE a.statut = ?
    GROUP BY f.code HAVING du > 0.005 ORDER BY du DESC LIMIT ?
    ''',
    [StatutsAchat.valide, limite],
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
