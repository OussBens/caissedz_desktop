import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/retour.dart';
import '../domain/models/tiers.dart';

/// Accès SQL aux fournisseurs, retours, versements et imputations.
class TiersRepository {
  const TiersRepository(this.db);

  final DatabaseExecutor db;

  Future<String> prochainCode(String table, String prefixe) async {
    final rows = await db.query(
      table,
      columns: ['code'],
      where: 'code LIKE ?',
      whereArgs: ['$prefixe%'],
      orderBy: 'code DESC',
      limit: 1,
    );
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  // ---- Fournisseurs ----
  Future<List<Fournisseur>> fournisseurs({String? recherche}) async {
    final r = recherche?.trim();
    final rows = await db.query(
      'fournisseur',
      where: r == null || r.isEmpty ? null : '(nom LIKE ? OR code LIKE ? OR telephone LIKE ?)',
      whereArgs: r == null || r.isEmpty ? null : ['%$r%', '%$r%', '%$r%'],
      orderBy: 'code',
    );
    return rows.map(Fournisseur.depuisLigne).toList();
  }

  Future<Fournisseur?> fournisseur(String code) async {
    final rows = await db.query('fournisseur', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Fournisseur.depuisLigne(rows.first);
  }

  Future<void> insererFournisseur(Fournisseur f) => db.insert('fournisseur', f.versLigne());
  Future<void> mettreAJourFournisseur(Fournisseur f) => db.update(
    'fournisseur',
    f.versLigne()
      ..remove('code')
      ..remove('systeme'),
    where: 'code = ?',
    whereArgs: [f.code],
  );

  // ---- Retours ----
  Future<void> insererRetour(Retour r) async {
    await db.insert('retour', {
      'code': r.code,
      'date': r.date.toUtc().toIso8601String(),
      'vente_code': r.venteCode,
      'client_code': r.clientCode,
      'magasin_code': r.magasinCode,
      'utilisateur_code': r.utilisateurCode,
      'total': r.total,
      'rembourse': r.rembourse,
      'motif': r.motif,
      'versement_code': r.versementCode,
    });
    for (final (i, l) in r.lignes.indexed) {
      await db.insert('retour_ligne', {
        'retour_code': r.code,
        'ordre': i,
        'produit_code': l.produitCode,
        'designation': l.designation,
        'quantite': l.quantite,
        'nombre': l.nombre,
        'prix_unitaire': l.prixUnitaire,
        'total': l.total,
      });
    }
  }

  Future<void> lierVersementRetour(String retourCode, String versementCode) =>
      db.update('retour', {'versement_code': versementCode}, where: 'code = ?', whereArgs: [retourCode]);

  Future<List<Retour>> retours({String? venteCode, String? clientCode, int limite = 500}) async {
    final where = <String>[];
    final args = <Object>[];
    if (venteCode != null) {
      where.add('vente_code = ?');
      args.add(venteCode);
    }
    if (clientCode != null) {
      where.add('client_code = ?');
      args.add(clientCode);
    }
    final rows = await db.query(
      'retour',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
      limit: limite,
    );
    return [for (final r in rows) Retour.depuisLigne(r, await _lignesRetour(r['code'] as String))];
  }

  Future<Retour?> retour(String code) async {
    final rows = await db.query('retour', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Retour.depuisLigne(rows.first, await _lignesRetour(code));
  }

  Future<List<RetourLigne>> _lignesRetour(String code) async => (await db.query(
    'retour_ligne',
    where: 'retour_code = ?',
    whereArgs: [code],
    orderBy: 'ordre',
  )).map(RetourLigne.depuisLigne).toList();

  /// Quantités déjà retournées par produit pour une vente.
  Future<Map<String, double>> quantitesRetournees(String venteCode) async {
    final rows = await db.rawQuery(
      'SELECT l.produit_code p, SUM(l.quantite) q FROM retour_ligne l JOIN retour r ON r.code = l.retour_code WHERE r.vente_code = ? GROUP BY l.produit_code',
      [venteCode],
    );
    return {for (final r in rows) r['p'] as String: (r['q'] as num).toDouble()};
  }

  // ---- Versements ----
  Future<void> insererVersement(Versement v) async {
    await db.insert('versement', v.versLigne());
    for (final i in v.imputations) {
      await db.insert('versement_imputation', {
        'versement_code': v.code,
        'document_type': i.documentType,
        'document_code': i.documentCode,
        'montant': i.montant,
      });
    }
  }

  Future<void> supprimerVersement(String code) => db.delete('versement', where: 'code = ?', whereArgs: [code]);

  Future<Versement?> versement(String code) async {
    final rows = await db.query('versement', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Versement.depuisLigne(rows.first, await _imputations(code));
  }

  Future<List<Versement>> versements({String? tiersType, String? tiersCode, int limite = 500}) async {
    final where = <String>[];
    final args = <Object>[];
    if (tiersType != null) {
      where.add('tiers_type = ?');
      args.add(tiersType);
    }
    if (tiersCode != null) {
      where.add('tiers_code = ?');
      args.add(tiersCode);
    }
    final rows = await db.query(
      'versement',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
      limit: limite,
    );
    return [for (final r in rows) Versement.depuisLigne(r, await _imputations(r['code'] as String))];
  }

  Future<List<Imputation>> _imputations(String code) async =>
      (await db.query('versement_imputation', where: 'versement_code = ?', whereArgs: [code]))
          .map(
            (r) => Imputation(
              versementCode: code,
              documentType: r['document_type'] as String,
              documentCode: r['document_code'] as String,
              montant: (r['montant'] as num).toDouble(),
            ),
          )
          .toList();

  /// Montant déjà imputé sur un document.
  Future<double> imputeSur(String documentType, String documentCode) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(montant),0) m FROM versement_imputation WHERE document_type = ? AND document_code = ?',
      [documentType, documentCode],
    );
    return (rows.first['m'] as num).toDouble();
  }

  /// Documents ouverts d'un client (ventes validées avec reste > 0, hors imputations), plus ancien d'abord.
  Future<List<DocumentOuvert>> documentsOuvertsClient(String clientCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code code, v.date date, v.total_net total,
             v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.document_type = 'vente' AND i.document_code = v.code), 0) reste
      FROM vente v WHERE v.client_code = ? AND v.statut = 'Validée' AND v.reste > 0
      ORDER BY v.date ASC, v.code ASC
    ''',
      [clientCode],
    );
    return [
      for (final r in rows)
        if ((r['reste'] as num) > 0.0001)
          DocumentOuvert(
            type: 'vente',
            code: r['code'] as String,
            date: DateTime.parse(r['date'] as String).toLocal(),
            total: (r['total'] as num).toDouble(),
            reste: (r['reste'] as num).toDouble(),
          ),
    ];
  }

  /// Documents ouverts d'un fournisseur (achats avec reste > 0), plus ancien d'abord.
  Future<List<DocumentOuvert>> documentsOuvertsFournisseur(String fournisseurCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT a.code code, a.date date, a.total total,
             a.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.document_type = 'achat' AND i.document_code = a.code), 0) reste
      FROM achat a WHERE a.fournisseur_code = ? AND a.statut = 'Validé' AND a.reste > 0
      ORDER BY a.date ASC, a.code ASC
    ''',
      [fournisseurCode],
    );
    return [
      for (final r in rows)
        if ((r['reste'] as num) > 0.0001)
          DocumentOuvert(
            type: 'achat',
            code: r['code'] as String,
            date: DateTime.parse(r['date'] as String).toLocal(),
            total: (r['total'] as num).toDouble(),
            reste: (r['reste'] as num).toDouble(),
          ),
    ];
  }

  /// Solde d'un client : Σ restes ouverts − versements non imputés (positif = dû par le client).
  Future<double> soldeClient(String clientCode) async {
    final docs = await documentsOuvertsClient(clientCode);
    final du = docs.fold(0.0, (s, d) => s + d.reste);
    final avances = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(v.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.versement_code = v.code), 0)), 0) m
      FROM versement v WHERE v.tiers_type = 'Client' AND v.tiers_code = ? AND v.sens = 'Encaissement'
    ''',
      [clientCode],
    );
    return du - (avances.first['m'] as num).toDouble();
  }

  Future<double> soldeFournisseur(String fournisseurCode) async {
    final docs = await documentsOuvertsFournisseur(fournisseurCode);
    final du = docs.fold(0.0, (s, d) => s + d.reste);
    final avances = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(v.montant - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.versement_code = v.code), 0)), 0) m
      FROM versement v WHERE v.tiers_type = 'Fournisseur' AND v.tiers_code = ? AND v.sens = 'Décaissement'
    ''',
      [fournisseurCode],
    );
    return du - (avances.first['m'] as num).toDouble();
  }
}
