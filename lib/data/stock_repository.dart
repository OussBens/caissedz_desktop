import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
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
    int limite = 1000,
  }) async {
    final where = <String>[];
    final args = <Object>[];
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

  Future<void> insererMagasin(Magasin m) => db.insert('magasin', {
    'code': m.code,
    'nom': m.nom,
    'actif': m.actif ? 1 : 0,
    'systeme': 0,
    'adresse': m.adresse,
  });
  Future<void> mettreAJourMagasin(Magasin m) => db.update(
    'magasin',
    {'nom': m.nom, 'actif': m.actif ? 1 : 0, 'adresse': m.adresse},
    where: 'code = ?',
    whereArgs: [m.code],
  );

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

  Future<List<TransfertStock>> transferts({int limite = 500}) async {
    final rows = await db.query('transfert_stock', orderBy: 'date DESC', limit: limite);
    final lignes = await db.query('transfert_stock_ligne');
    return rows.map((r) {
      final code = r['code'] as String;
      return TransfertStock(
        code: code,
        date: DateTime.parse(r['date'] as String).toLocal(),
        magasinSource: r['magasin_source'] as String,
        magasinDestination: r['magasin_destination'] as String,
        utilisateurCode: r['utilisateur_code'] as String,
        commentaire: r['commentaire'] as String?,
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
  Future<void> insererBesoin(Besoin b) => db.insert('besoin', b.versLigne());
  Future<void> mettreAJourBesoin(Besoin b) =>
      db.update('besoin', b.versLigne(), where: 'code = ?', whereArgs: [b.code]);
  Future<void> supprimerBesoin(String code) => db.delete('besoin', where: 'code = ?', whereArgs: [code]);
  Future<List<Besoin>> besoins({String? statut}) async => (await db.query(
    'besoin',
    where: statut == null ? null : 'statut = ?',
    whereArgs: statut == null ? null : [statut],
    orderBy: 'date DESC',
  )).map(Besoin.depuisLigne).toList();
  Future<Besoin?> besoin(String code) async {
    final rows = await db.query('besoin', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Besoin.depuisLigne(rows.first);
  }

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
    for (final l in s.lignes) {
      await db.insert('sortie_stock_ligne', {
        'sortie_code': s.code,
        'produit_code': l.produitCode,
        'quantite': l.quantite,
        'nombre': l.nombre,
      });
    }
  }

  Future<List<SortieStock>> sorties({int limite = 500}) async {
    final rows = await db.query('sortie_stock', orderBy: 'date DESC', limit: limite);
    final lignes = await db.query('sortie_stock_ligne');
    return rows.map((r) {
      final code = r['code'] as String;
      return SortieStock(
        code: code,
        date: DateTime.parse(r['date'] as String).toLocal(),
        magasinCode: r['magasin_code'] as String,
        motif: r['motif'] as String,
        utilisateurCode: r['utilisateur_code'] as String,
        commentaire: r['commentaire'] as String?,
        lignes: lignes
            .where((l) => l['sortie_code'] == code)
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
}
