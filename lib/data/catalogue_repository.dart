import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/produit.dart';

/// Accès SQL au catalogue : catégories, produits, colis, packs, remises.
class CatalogueRepository {
  const CatalogueRepository(this.db);

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

  // ---- Catégories ----
  Future<List<Categorie>> categories() async =>
      (await db.query('categorie', orderBy: 'code')).map(Categorie.depuisLigne).toList();
  Future<List<SousCategorie>> sousCategories([String? categorieCode]) async => (await db.query(
    'sous_categorie',
    where: categorieCode == null ? null : 'categorie_code = ?',
    whereArgs: categorieCode == null ? null : [categorieCode],
    orderBy: 'code',
  )).map(SousCategorie.depuisLigne).toList();
  Future<void> insererCategorie(Categorie c) => db.insert('categorie', {
    'code': c.code,
    'nom': c.nom,
    'systeme': 0,
    'description': c.description,
    'actif': c.actif ? 1 : 0,
  });
  Future<void> modifierCategorie(Categorie c) => db.update(
    'categorie',
    {'nom': c.nom, 'description': c.description, 'actif': c.actif ? 1 : 0},
    where: 'code = ?',
    whereArgs: [c.code],
  );
  Future<void> modifierSousCategorie(SousCategorie s) => db.update(
    'sous_categorie',
    {'nom': s.nom, 'categorie_code': s.categorieCode, 'description': s.description, 'actif': s.actif ? 1 : 0},
    where: 'code = ?',
    whereArgs: [s.code],
  );
  Future<void> renommerCategorie(String code, String nom) =>
      db.update('categorie', {'nom': nom}, where: 'code = ? AND systeme = 0', whereArgs: [code]);
  Future<void> insererSousCategorie(SousCategorie s) =>
      db.insert('sous_categorie', {
        'code': s.code,
        'categorie_code': s.categorieCode,
        'nom': s.nom,
        'systeme': 0,
        'description': s.description,
        'actif': s.actif ? 1 : 0,
      });
  Future<void> renommerSousCategorie(String code, String nom) =>
      db.update('sous_categorie', {'nom': nom}, where: 'code = ? AND systeme = 0', whereArgs: [code]);
  Future<int> nbProduitsCategorie(String code) async =>
      (await db.rawQuery('SELECT count(*) n FROM produit WHERE categorie_code = ?', [code])).first['n'] as int;
  Future<int> nbProduitsSousCategorie(String code) async =>
      (await db.rawQuery('SELECT count(*) n FROM produit WHERE sous_categorie_code = ?', [code])).first['n'] as int;
  Future<void> supprimerCategorie(String code) async {
    await db.delete('sous_categorie', where: 'categorie_code = ? AND systeme = 0', whereArgs: [code]);
    await db.delete('categorie', where: 'code = ? AND systeme = 0', whereArgs: [code]);
  }

  Future<void> supprimerSousCategorie(String code) =>
      db.delete('sous_categorie', where: 'code = ? AND systeme = 0', whereArgs: [code]);

  // ---- Produits ----
  Future<List<Produit>> produits({String? recherche, bool actifsSeulement = false, String? categorieCode}) async {
    final where = <String>[];
    final args = <Object>[];
    if (recherche != null && recherche.trim().isNotEmpty) {
      where.add('(designation LIKE ? OR code LIKE ? OR code_barres LIKE ?)');
      final r = '%${recherche.trim()}%';
      args.addAll([r, r, r]);
    }
    if (actifsSeulement) where.add('actif = 1');
    if (categorieCode != null) {
      where.add('categorie_code = ?');
      args.add(categorieCode);
    }
    final rows = await db.query(
      'produit',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'designation',
    );
    return rows.map(Produit.depuisLigne).toList();
  }

  Future<Produit?> produitParCode(String code) async {
    final rows = await db.query('produit', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Produit.depuisLigne(rows.first);
  }

  /// Produit par code-barres principal ou secondaire (`produit_code_detail`).
  Future<Produit?> produitParCodeBarres(String codeBarres) async {
    final rows = await db.rawQuery(
      'SELECT * FROM produit WHERE code_barres = ? '
      'OR code IN (SELECT produit_code FROM produit_code_detail WHERE code_barres = ?) LIMIT 1',
      [codeBarres, codeBarres],
    );
    return rows.isEmpty ? null : Produit.depuisLigne(rows.first);
  }

  /// Code-barres libre (produits, codes secondaires, colis, packs). [saufProduit] ignore ce produit et ses
  /// codes secondaires ; [saufColis] ignore ce colis.
  Future<bool> codeBarresDisponible(String codeBarres, {String? saufProduit, String? saufColis}) async {
    for (final (table, col) in [
      ('produit', 'code'),
      ('produit_code_detail', 'produit_code'),
      ('colis', 'code'),
      ('pack', 'code'),
    ]) {
      final rows = await db.query(table, columns: [col], where: 'code_barres = ?', whereArgs: [codeBarres]);
      if (rows.isEmpty) continue;
      final v = rows.first[col];
      if ((table == 'produit' || table == 'produit_code_detail') && v == saufProduit) continue;
      if (table == 'colis' && v == saufColis) continue;
      return false;
    }
    return true;
  }

  Future<List<String>> codesSecondaires(String produitCode) async => [
    for (final r in await db.query(
      'produit_code_detail',
      where: 'produit_code = ?',
      whereArgs: [produitCode],
      orderBy: 'code_barres',
    ))
      r['code_barres'] as String,
  ];

  Future<void> remplacerCodesSecondaires(String produitCode, List<String> codes) async {
    await db.delete('produit_code_detail', where: 'produit_code = ?', whereArgs: [produitCode]);
    for (final c in codes) {
      await db.insert('produit_code_detail', {'produit_code': produitCode, 'code_barres': c});
    }
  }

  /// Nombre de mouvements de stock et de compositions de packs qui référencent un produit.
  Future<int> nbUsagesProduit(String code) async =>
      (await db.rawQuery(
            'SELECT (SELECT count(*) FROM mouvement_stock WHERE produit_code = ?) + '
            '(SELECT count(*) FROM pack_ligne WHERE produit_code = ?) n',
            [code, code],
          )).first['n']
          as int;

  Future<void> supprimerProduit(String code) async {
    await db.delete('produit_code_detail', where: 'produit_code = ?', whereArgs: [code]);
    await db.delete('colis', where: 'produit_code = ?', whereArgs: [code]);
    await db.delete('produit', where: 'code = ?', whereArgs: [code]);
  }

  Future<void> insererProduit(Produit p) => db.insert('produit', p.versLigne());
  Future<void> mettreAJourProduit(Produit p) => db.update(
    'produit',
    {...p.versLigne(), 'modifie_le': DateTime.now().toUtc().toIso8601String()},
    where: 'code = ?',
    whereArgs: [p.code],
  );
  Future<int> nbProduits() async => (await db.rawQuery('SELECT count(*) n FROM produit')).first['n'] as int;

  // ---- Colis ----
  Future<List<Colis>> colis({String? produitCode}) async => (await db.query(
    'colis',
    where: produitCode == null ? null : 'produit_code = ?',
    whereArgs: produitCode == null ? null : [produitCode],
    orderBy: 'code',
  )).map(Colis.depuisLigne).toList();
  Future<Colis?> colisParCodeBarres(String cb) async {
    final rows = await db.query('colis', where: 'code_barres = ? AND actif = 1', whereArgs: [cb]);
    return rows.isEmpty ? null : Colis.depuisLigne(rows.first);
  }

  Future<void> insererColis(Colis c) => db.insert('colis', c.versLigne());
  Future<void> mettreAJourColis(Colis c) => db.update('colis', c.versLigne(), where: 'code = ?', whereArgs: [c.code]);

  // ---- Packs ----
  Future<List<Pack>> packs() async {
    final rows = await db.query('pack', orderBy: 'code');
    final lignes = await db.query('pack_ligne');
    return rows.map((r) {
      final code = r['code'] as String;
      return Pack.depuisLigne(
        r,
        lignes
            .where((l) => l['pack_code'] == code)
            .map((l) => PackLigne(produitCode: l['produit_code'] as String, quantite: l['quantite'] as int))
            .toList(),
      );
    }).toList();
  }

  Future<Pack?> packParCodeBarres(String cb) async {
    final rows = await db.query('pack', where: 'code_barres = ? AND actif = 1', whereArgs: [cb]);
    if (rows.isEmpty) return null;
    final lignes = await db.query('pack_ligne', where: 'pack_code = ?', whereArgs: [rows.first['code']]);
    return Pack.depuisLigne(
      rows.first,
      lignes.map((l) => PackLigne(produitCode: l['produit_code'] as String, quantite: l['quantite'] as int)).toList(),
    );
  }

  Future<void> insererPack(Pack p) async {
    await db.insert('pack', p.versLigne());
    for (final l in p.lignes) {
      await db.insert('pack_ligne', {'pack_code': p.code, 'produit_code': l.produitCode, 'quantite': l.quantite});
    }
  }

  Future<void> mettreAJourPack(Pack p) async {
    await db.update('pack', p.versLigne(), where: 'code = ?', whereArgs: [p.code]);
    await db.delete('pack_ligne', where: 'pack_code = ?', whereArgs: [p.code]);
    for (final l in p.lignes) {
      await db.insert('pack_ligne', {'pack_code': p.code, 'produit_code': l.produitCode, 'quantite': l.quantite});
    }
  }

  // ---- Remises ----
  Future<List<Remise>> remises() async => (await db.query('remise', orderBy: 'code')).map(Remise.depuisLigne).toList();
  Future<void> insererRemise(Remise r) => db.insert('remise', r.versLigne());
  Future<void> mettreAJourRemise(Remise r) =>
      db.update('remise', r.versLigne(), where: 'code = ?', whereArgs: [r.code]);
  Future<void> supprimerRemise(String code) => db.delete('remise', where: 'code = ?', whereArgs: [code]);

  // ---- Séquence des codes-barres internes ----
  Future<int> sequenceCodeBarres(String jour) async {
    final rows = await db.query('sequence_code_barres', where: 'jour = ?', whereArgs: [jour]);
    final suivant = rows.isEmpty ? 1 : (rows.first['dernier'] as int) + 1;
    await db.insert('sequence_code_barres', {
      'jour': jour,
      'dernier': suivant,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return suivant;
  }
}
