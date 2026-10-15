import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/audit.dart';
import '../domain/models/stock.dart';

/// Accès SQL au stock : journal des mouvements, niveaux calculés, magasins, documents.
class StockRepository {
  const StockRepository(this.db);

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

  // ---- Journal ----
  Future<int> insererMouvement(MouvementStock m) => db.insert('mouvement_stock', m.versLigne());

  Future<List<MouvementStock>> mouvements({
    String? produitCode,
    String? magasinCode,
    String? type,
    DateTime? depuis,
    DateTime? jusqua,
    String? referenceCode,
    int limite = 1000,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (referenceCode != null) {
      where.add('reference_code = ?');
      args.add(referenceCode);
    }
    if (produitCode != null) {
      where.add('produit_code = ?');
      args.add(produitCode);
    }
    if (magasinCode != null) {
      where.add('magasin_code = ?');
      args.add(magasinCode);
    }
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (depuis != null) {
      where.add('date >= ?');
      args.add(depuis.toUtc().toIso8601String());
    }
    if (jusqua != null) {
      where.add('date <= ?');
      args.add(jusqua.toUtc().toIso8601String());
    }
    final rows = await db.query(
      'mouvement_stock',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, id DESC',
      limit: limite,
    );
    return rows.map(MouvementStock.depuisLigne).toList();
  }

  /// Stock = somme des mouvements (jamais un compteur).
  Future<NiveauStock> niveau(String produitCode, String magasinCode) async {
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(quantite),0) q, COALESCE(SUM(nombre),0) n FROM mouvement_stock WHERE produit_code = ? AND magasin_code = ?',
      [produitCode, magasinCode],
    );
    return NiveauStock(
      produitCode: produitCode,
      magasinCode: magasinCode,
      quantite: (r.first['q'] as num).toDouble(),
      nombre: (r.first['n'] as num).toDouble(),
    );
  }

  /// Stock total d'un produit, tous magasins.
  Future<NiveauStock> niveauTotal(String produitCode) async {
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(quantite),0) q, COALESCE(SUM(nombre),0) n FROM mouvement_stock WHERE produit_code = ?',
      [produitCode],
    );
    return NiveauStock(
      produitCode: produitCode,
      magasinCode: '*',
      quantite: (r.first['q'] as num).toDouble(),
      nombre: (r.first['n'] as num).toDouble(),
    );
  }

  /// Niveaux de tous les produits (par magasin ou tous magasins).
  Future<List<NiveauStock>> niveaux({String? magasinCode}) async {
    final rows = magasinCode == null
        ? await db.rawQuery(
            'SELECT produit_code, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock GROUP BY produit_code',
          )
        : await db.rawQuery(
            'SELECT produit_code, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock WHERE magasin_code = ? GROUP BY produit_code',
            [magasinCode],
          );
    return rows
        .map(
          (r) => NiveauStock(
            produitCode: r['produit_code'] as String,
            magasinCode: magasinCode ?? '*',
            quantite: (r['q'] as num).toDouble(),
            nombre: (r['n'] as num).toDouble(),
          ),
        )
        .toList();
  }

  /// Répartition d'un produit par magasin.
  Future<List<NiveauStock>> repartition(String produitCode) async {
    final rows = await db.rawQuery(
      'SELECT magasin_code, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock WHERE produit_code = ? GROUP BY magasin_code',
      [produitCode],
    );
    return rows
        .map(
          (r) => NiveauStock(
            produitCode: produitCode,
            magasinCode: r['magasin_code'] as String,
            quantite: (r['q'] as num).toDouble(),
            nombre: (r['n'] as num).toDouble(),
          ),
        )
        .toList();
  }

  // ---- Magasins ----
  Future<List<Magasin>> magasins({bool actifsSeulement = false}) async => (await db.query(
    'magasin',
    where: actifsSeulement ? 'actif = 1' : null,
    orderBy: 'code',
  )).map(Magasin.depuisLigne).toList();

  Future<Magasin?> magasin(String code) async {
    final rows = await db.query('magasin', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Magasin.depuisLigne(rows.first);
  }

  Map<String, Object?> _ligneMagasin(Magasin m) => {
    'nom': m.nom,
    'actif': m.actif ? 1 : 0,
    'adresse': m.adresse,
    'telephone': m.telephone,
    'responsable_code': m.responsableCode,
    'observation': m.observation,
  };

  Future<void> insererMagasin(Magasin m) => db.insert('magasin', {'code': m.code, 'systeme': 0, ..._ligneMagasin(m)});
  Future<void> mettreAJourMagasin(Magasin m) =>
      db.update('magasin', _ligneMagasin(m), where: 'code = ?', whereArgs: [m.code]);

  /// Un autre magasin porte-t-il déjà ce nom (sans tenir compte de la casse) ?
  Future<bool> nomMagasinPris(String nom, {String? sauf}) async => (await db.rawQuery(
    'SELECT 1 FROM magasin WHERE lower(nom) = lower(?) AND code != ? LIMIT 1',
    [nom.trim(), sauf ?? ''],
  )).isNotEmpty;

  /// Quantités par produit et par magasin : `{produit: {magasin: quantité}}`.
  Future<Map<String, Map<String, double>>> stocksParMagasin() async {
    final rows = await db.rawQuery(
      'SELECT produit_code p, magasin_code m, SUM(quantite) q FROM mouvement_stock GROUP BY produit_code, magasin_code',
    );
    final r = <String, Map<String, double>>{};
    for (final x in rows) {
      (r[x['p']! as String] ??= {})[x['m']! as String] = (x['q']! as num).toDouble();
    }
    return r;
  }

  /// Pièces (2ᵉ stock « nombre ») par produit et par magasin : `{produit: {magasin: nombre}}`.
  Future<Map<String, Map<String, double>>> nombresParMagasin() async {
    final rows = await db.rawQuery(
      'SELECT produit_code p, magasin_code m, SUM(nombre) n FROM mouvement_stock GROUP BY produit_code, magasin_code',
    );
    final r = <String, Map<String, double>>{};
    for (final x in rows) {
      (r[x['p']! as String] ??= {})[x['m']! as String] = (x['n']! as num).toDouble();
    }
    return r;
  }

  /// Utilisateurs rattachés à chaque magasin : `{magasin: [utilisateurs]}`.
  Future<Map<String, List<String>>> utilisateursParMagasin() async {
    final rows = await db.query('utilisateur_magasin', orderBy: 'ordre');
    final r = <String, List<String>>{};
    for (final x in rows) {
      (r[x['magasin_code']! as String] ??= []).add(x['utilisateur_code']! as String);
    }
    return r;
  }

  /// Utilisateurs dont ce magasin est le principal (premier de leur liste).
  Future<List<String>> utilisateursPrincipal(String magasinCode) async => (await db.rawQuery(
    '''
    SELECT um.utilisateur_code u FROM utilisateur_magasin um
    WHERE um.magasin_code = ? AND um.ordre = (
      SELECT MIN(x.ordre) FROM utilisateur_magasin x WHERE x.utilisateur_code = um.utilisateur_code)
    ''',
    [magasinCode],
  )).map((r) => r['u']! as String).toList();

  /// Caisses rattachées à chaque magasin : `{magasin: [noms]}`.
  Future<Map<String, List<String>>> caissesParMagasin() async {
    final rows = await db.query('caisse', columns: ['nom', 'magasin_code'], where: 'actif = 1', orderBy: 'code');
    final r = <String, List<String>>{};
    for (final x in rows) {
      final m = x['magasin_code'] as String?;
      if (m != null) (r[m] ??= []).add(x['nom']! as String);
    }
    return r;
  }

  /// Magasins d'un utilisateur, dans l'ordre ; le premier est son magasin principal.
  Future<List<String>> magasinsUtilisateur(String utilisateurCode) async => (await db.query(
    'utilisateur_magasin',
    columns: ['magasin_code'],
    where: 'utilisateur_code = ?',
    whereArgs: [utilisateurCode],
    orderBy: 'ordre',
  )).map((r) => r['magasin_code'] as String).toList();

  Future<void> definirMagasinsUtilisateur(String utilisateurCode, List<String> codes) async {
    await db.delete('utilisateur_magasin', where: 'utilisateur_code = ?', whereArgs: [utilisateurCode]);
    for (final (i, c) in codes.indexed) {
      await db.insert('utilisateur_magasin', {'utilisateur_code': utilisateurCode, 'magasin_code': c, 'ordre': i});
    }
  }

  // ---- Transferts ----
  Future<void> insererTransfert(TransfertStock t) async {
    await db.insert('transfert_stock', {
      'code': t.code,
      'date': t.date.toUtc().toIso8601String(),
      'magasin_source': t.magasinSource,
      'magasin_destination': t.magasinDestination,
      'utilisateur_code': t.utilisateurCode,
      'commentaire': t.commentaire,
    });
    for (final l in t.lignes) {
      await db.insert('transfert_stock_ligne', {
        'transfert_code': t.code,
        'produit_code': l.produitCode,
        'quantite': l.quantite,
        'nombre': l.nombre,
      });
    }
  }

  Future<void> remplacerTransfert(TransfertStock t) async {
    await db.update(
      'transfert_stock',
      {
        'date': t.date.toUtc().toIso8601String(),
        'magasin_source': t.magasinSource,
        'magasin_destination': t.magasinDestination,
        'commentaire': t.commentaire,
      },
      where: 'code = ?',
      whereArgs: [t.code],
    );
    await db.delete('transfert_stock_ligne', where: 'transfert_code = ?', whereArgs: [t.code]);
    for (final l in t.lignes) {
      await db.insert('transfert_stock_ligne', {
        'transfert_code': t.code,
        'produit_code': l.produitCode,
        'quantite': l.quantite,
        'nombre': l.nombre,
      });
    }
  }

  /// Annulation douce d'un document (`sortie_stock`, `transfert_stock`, `besoin`).
  Future<void> annulerDocument(String table, String code, {required String par, required String motif}) => db.update(
    table,
    {
      'actif': 0,
      'annule_par': par,
      'motif_annulation': motif,
      'date_annulation': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'code = ?',
    whereArgs: [code],
  );

  Future<TransfertStock?> transfert(String code) async => (await transferts(code: code)).firstOrNull;

  Future<List<TransfertStock>> transferts({int limite = 500, String? code}) async {
    final rows = await db.query(
      'transfert_stock',
      where: code == null ? null : 'code = ?',
      whereArgs: code == null ? null : [code],
      orderBy: 'date DESC, code DESC',
      limit: limite,
    );
    final lignes = await db.query(
      'transfert_stock_ligne',
      where: code == null ? null : 'transfert_code = ?',
      whereArgs: code == null ? null : [code],
    );
    return rows.map((r) {
      final code = r['code'] as String;
      return TransfertStock(
        audit: Audit.depuisLigne(r),
        code: code,
        date: DateTime.parse(r['date'] as String).toLocal(),
        magasinSource: r['magasin_source'] as String,
        magasinDestination: r['magasin_destination'] as String,
        utilisateurCode: r['utilisateur_code'] as String,
        commentaire: r['commentaire'] as String?,
        annulation: Annulation.depuisLigne(r),
        lignes: lignes
            .where((l) => l['transfert_code'] == code)
            .map(
              (l) => LigneStock(
                produitCode: l['produit_code'] as String,
                quantite: (l['quantite'] as num).toDouble(),
                nombre: (l['nombre'] as num).toDouble(),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  // ---- Besoins ----
  Future<void> insererBesoin(Besoin b) async {
    await db.insert('besoin', b.versLigne());
    await _lignesBesoin(b);
  }

  Future<void> remplacerBesoin(Besoin b) async {
    await db.update('besoin', b.versLigne(), where: 'code = ?', whereArgs: [b.code]);
    await db.delete('besoin_ligne', where: 'besoin_code = ?', whereArgs: [b.code]);
    await _lignesBesoin(b);
  }

  Future<void> _lignesBesoin(Besoin b) async {
    for (final l in b.lignes) {
      await db.insert('besoin_ligne', {
        'besoin_code': b.code,
        'produit_code': l.produitCode,
        'quantite': l.quantite,
        'prix': l.prix,
      });
    }
  }

  Future<void> changerStatutBesoin(String code, String statut) =>
      db.update('besoin', {'statut': statut}, where: 'code = ?', whereArgs: [code]);

  Future<List<Besoin>> besoins({String? code}) async {
    final rows = await db.query(
      'besoin',
      where: code == null ? null : 'code = ?',
      whereArgs: code == null ? null : [code],
      orderBy: 'date DESC, code DESC',
    );
    final lignes = await db.query(
      'besoin_ligne',
      where: code == null ? null : 'besoin_code = ?',
      whereArgs: code == null ? null : [code],
    );
    return [
      for (final r in rows)
        Besoin.depuisLigne(r, [
          for (final l in lignes)
            if (l['besoin_code'] == r['code'])
              LigneStock(
                produitCode: l['produit_code']! as String,
                quantite: (l['quantite']! as num).toDouble(),
                prix: (l['prix']! as num).toDouble(),
              ),
        ]),
    ];
  }

  Future<Besoin?> besoin(String code) async => (await besoins(code: code)).firstOrNull;

  // ---- Sorties ----
  Future<void> insererSortie(SortieStock s) async {
    await db.insert('sortie_stock', {
      'code': s.code,
      'date': s.date.toUtc().toIso8601String(),
      'magasin_code': s.magasinCode,
      'motif': s.motif,
      'utilisateur_code': s.utilisateurCode,
      'commentaire': s.commentaire,
    });
    await _lignesSortie(s);
  }

  Future<void> remplacerSortie(SortieStock s) async {
    await db.update(
      'sortie_stock',
      {
        'date': s.date.toUtc().toIso8601String(),
        'magasin_code': s.magasinCode,
        'motif': s.motif,
        'commentaire': s.commentaire,
      },
      where: 'code = ?',
      whereArgs: [s.code],
    );
    await db.delete('sortie_stock_ligne', where: 'sortie_code = ?', whereArgs: [s.code]);
    await _lignesSortie(s);
  }

  Future<void> _lignesSortie(SortieStock s) async {
    for (final l in s.lignes) {
      await db.insert('sortie_stock_ligne', {
        'sortie_code': s.code,
        'produit_code': l.produitCode,
        'quantite': l.quantite,
        'nombre': l.nombre,
        'prix': l.prix,
      });
    }
  }

  Future<SortieStock?> sortie(String code) async => (await sorties(code: code)).firstOrNull;

  Future<List<SortieStock>> sorties({int limite = 500, String? code}) async {
    final rows = await db.query(
      'sortie_stock',
      where: code == null ? null : 'code = ?',
      whereArgs: code == null ? null : [code],
      orderBy: 'date DESC, code DESC',
      limit: limite,
    );
    final lignes = await db.query(
      'sortie_stock_ligne',
      where: code == null ? null : 'sortie_code = ?',
      whereArgs: code == null ? null : [code],
    );
    return rows.map((r) {
      final code = r['code'] as String;
      return SortieStock(
        audit: Audit.depuisLigne(r),
        code: code,
        date: DateTime.parse(r['date'] as String).toLocal(),
        magasinCode: r['magasin_code'] as String,
        motif: r['motif'] as String,
        utilisateurCode: r['utilisateur_code'] as String,
        commentaire: r['commentaire'] as String?,
        annulation: Annulation.depuisLigne(r),
        lignes: lignes
            .where((l) => l['sortie_code'] == code)
            .map(
              (l) => LigneStock(
                produitCode: l['produit_code'] as String,
                quantite: (l['quantite'] as num).toDouble(),
                nombre: (l['nombre'] as num).toDouble(),
                prix: (l['prix'] as num).toDouble(),
              ),
            )
            .toList(),
      );
    }).toList();
  }
}
