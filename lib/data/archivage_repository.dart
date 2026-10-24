import 'package:sqflite_common/sqlite_api.dart';

import '../domain/archivage.dart';

/// Accès SQL de l'archivage (migration v43) : références d'une fiche, archivage, restauration, suppression.
class ArchivageRepository {
  const ArchivageRepository(this.db);

  final DatabaseExecutor db;

  /// Colonnes `(table, colonne)` qui portent le code d'une fiche [e] : clés étrangères vers sa table et colonnes
  /// nommées comme ses codes ([EntiteArchivable.colonnes]), hors tables qu'elle possède. Lu sur le schéma réel :
  /// une table ajoutée par une migration future est prise en compte sans modifier ce code.
  Future<Set<(String, String)>> references(EntiteArchivable e) async {
    final tables = [
      for (final r in await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      ))
        r['name']! as String,
    ];
    final refs = <(String, String)>{};
    for (final t in tables) {
      if (e.possedees.contains(t)) continue;
      for (final fk in await db.rawQuery("PRAGMA foreign_key_list('$t')")) {
        if (fk['table'] == e.table) refs.add((t, fk['from']! as String));
      }
      for (final c in await db.rawQuery("PRAGMA table_info('$t')")) {
        final nom = c['name']! as String;
        if (e.colonnes.contains(nom)) refs.add((t, nom));
      }
    }
    return refs;
  }

  /// Codes parmi [codes] référencés ailleurs (ventes, achats, mouvements, versements, journal…) : ceux-là ont un
  /// historique et s'archivent au lieu d'être supprimés. Une fiche qui ne se référence qu'elle-même (son propre
  /// `modifie_par`) n'est pas comptée.
  Future<Set<String>> codesReferences(EntiteArchivable e, List<String> codes) async {
    final utilises = <String>{};
    if (codes.isEmpty) return utilises;
    final refs = await references(e);
    for (final lot in _lots(codes)) {
      final marques = _marques(lot);
      for (final (t, c) in refs) {
        // Dans la table de la fiche elle-même, ignorer la ligne qui se référence (`code` = valeur de la colonne).
        final soiMeme = t == e.table ? ' AND code <> "$c"' : '';
        final rows = await db.rawQuery('SELECT DISTINCT "$c" v FROM "$t" WHERE "$c" IN ($marques)$soiMeme', lot);
        for (final r in rows) {
          utilises.add(r['v']! as String);
        }
      }
      // Versements : le tiers est porté par `tiers_type` + `tiers_code` (sans clé étrangère).
      if (e == EntiteArchivable.client || e == EntiteArchivable.fournisseur) {
        final type = e == EntiteArchivable.client ? 'Client' : 'Fournisseur';
        for (final r in await db.rawQuery(
          'SELECT DISTINCT tiers_code v FROM versement WHERE tiers_type = ? AND tiers_code IN ($marques)',
          [type, ...lot],
        )) {
          utilises.add(r['v']! as String);
        }
      }
    }
    return utilises;
  }

  /// Lignes des fiches [codes] qui existent, par code (lues par lots : un catalogue entier reste rapide).
  Future<Map<String, Map<String, Object?>>> fiches(EntiteArchivable e, List<String> codes) async => {
    for (final lot in _lots(codes))
      for (final r in await db.query(e.table, where: 'code IN (${_marques(lot)})', whereArgs: lot))
        r['code']! as String: r,
  };

  /// Colonnes `(table, colonne)` des tables possédées par [e] qui portent son code (supprimées avec la fiche).
  Future<Set<(String, String)>> colonnesPossedees(EntiteArchivable e) async => {
    for (final t in e.possedees)
      for (final fk in await db.rawQuery("PRAGMA foreign_key_list('$t')"))
        if (fk['table'] == e.table) (t, fk['from']! as String),
  };

  /// Code d'une fiche non archivée de [e] qui porte déjà [nom] (casse et espaces autour ignorés), autre que
  /// [sauf] ; `null` si le nom est libre. Une fiche archivée ne réserve pas son nom.
  Future<String?> ficheDuNom(EntiteArchivable e, String nom, {String? sauf}) async {
    final rows = await db.rawQuery(
      'SELECT code FROM ${e.table} WHERE LOWER(TRIM(${e.colonneNom})) = LOWER(TRIM(?)) '
      'AND archive_le IS NULL AND code <> ? LIMIT 1',
      [nom, sauf ?? ''],
    );
    return rows.isEmpty ? null : rows.first['code']! as String;
  }

  /// Archive la fiche : désactivée et horodatée ; elle reste en base pour l'historique.
  Future<int> archiver(EntiteArchivable e, String code, {required String par}) async {
    final n = await db.update(
      e.table,
      {'actif': 0, 'archive_le': DateTime.now().toUtc().toIso8601String(), 'archive_par': par},
      where: 'code = ? AND archive_le IS NULL',
      whereArgs: [code],
    );
    // Un produit archivé quitte les favoris de la caisse.
    if (e == EntiteArchivable.produit) await db.delete('favori_caisse', where: 'produit_code = ?', whereArgs: [code]);
    return n;
  }

  /// Restaure une fiche archivée : elle redevient active et réapparaît dans les listes.
  Future<int> restaurer(EntiteArchivable e, String code) => db.update(
    e.table,
    {'actif': 1, 'archive_le': null, 'archive_par': null},
    where: 'code = ? AND archive_le IS NOT NULL',
    whereArgs: [code],
  );

  /// Supprime une fiche sans historique et ses lignes dans les tables possédées ([colonnesPossedees]).
  Future<void> supprimer(EntiteArchivable e, String code, Set<(String, String)> possedees) async {
    for (final (t, c) in possedees) {
      await db.delete(t, where: '"$c" = ?', whereArgs: [code]);
    }
    await db.delete(e.table, where: 'code = ?', whereArgs: [code]);
  }

  // ---------------------------------------------------------------- Règles de blocage

  /// Produits parmi [codes] dont le stock n'est pas nul dans au moins un magasin.
  Future<Set<String>> produitsAvecStock(List<String> codes) async => {
    for (final lot in _lots(codes))
      for (final r in await db.rawQuery(
        'SELECT DISTINCT produit_code p FROM ('
        ' SELECT produit_code, magasin_code FROM mouvement_stock WHERE produit_code IN (${_marques(lot)})'
        ' GROUP BY produit_code, magasin_code HAVING ABS(SUM(quantite)) > 1e-9)',
        lot,
      ))
        r['p']! as String,
  };

  /// Produits parmi [codes] composants d'un pack non archivé.
  Future<Set<String>> produitsEnPack(List<String> codes) async => {
    for (final lot in _lots(codes))
      for (final r in await db.rawQuery(
        'SELECT DISTINCT l.produit_code p FROM pack_ligne l JOIN pack k ON k.code = l.pack_code '
        'WHERE k.archive_le IS NULL AND l.produit_code IN (${_marques(lot)})',
        lot,
      ))
        r['p']! as String,
  };

  /// Solde (vue `solde_tiers`) d'un client ou d'un fournisseur : dû − réglé + rendu.
  Future<double> soldeTiers(String type, String code) async {
    final rows = await db.rawQuery('SELECT solde FROM solde_tiers WHERE tiers_type = ? AND tiers_code = ?', [
      type,
      code,
    ]);
    return rows.isEmpty ? 0 : ((rows.first['solde'] as num?) ?? 0).toDouble();
  }

  /// Le magasin garde-t-il du stock (un produit au moins avec une quantité non nulle) ?
  Future<bool> magasinAvecStock(String code) async => (await db.rawQuery(
    'SELECT 1 FROM mouvement_stock WHERE magasin_code = ? GROUP BY produit_code HAVING ABS(SUM(quantite)) > 1e-9 '
    'LIMIT 1',
    [code],
  )).isNotEmpty;

  /// Le magasin est-il le magasin principal (premier de la liste) d'un compte non archivé ?
  Future<bool> magasinPrincipal(String code) async => (await db.rawQuery(
    '''
    SELECT 1 FROM utilisateur_magasin um JOIN utilisateur u ON u.code = um.utilisateur_code
    WHERE um.magasin_code = ? AND u.archive_le IS NULL AND um.ordre = (
      SELECT MIN(x.ordre) FROM utilisateur_magasin x WHERE x.utilisateur_code = um.utilisateur_code)
    LIMIT 1
    ''',
    [code],
  )).isNotEmpty;

  Future<bool> sessionOuverte(String caisseCode) async => (await db.query(
    'session_caisse',
    columns: ['code'],
    where: 'caisse_code = ? AND statut = ?',
    whereArgs: [caisseCode, 'Ouverte'],
    limit: 1,
  )).isNotEmpty;

  /// Comptes non archivés qui ont le rôle [roleCode].
  Future<int> utilisateursDuRole(String roleCode) async =>
      (await db.rawQuery('SELECT COUNT(*) n FROM utilisateur WHERE role_code = ? AND archive_le IS NULL', [
            roleCode,
          ])).first['n']!
          as int;

  /// Nombre de lignes actives de [table] vérifiant [condition] (places du palier de la licence).
  Future<int> nbActifs(String table, [String condition = '1', List<Object?> args = const []]) async =>
      (await db.rawQuery('SELECT COUNT(*) n FROM $table WHERE actif = 1 AND $condition', args)).first['n']! as int;

  /// Codes par lots de 400 (limite des paramètres SQL).
  static Iterable<List<String>> _lots(List<String> codes) sync* {
    for (var i = 0; i < codes.length; i += 400) {
      yield codes.sublist(i, i + 400 > codes.length ? codes.length : i + 400);
    }
  }

  static String _marques(List<String> lot) => List.filled(lot.length, '?').join(',');
}
