import 'package:sqflite_common/sqlite_api.dart';

/// Produits favoris de la caisse (onglet « Favoris » de la caisse), communs à tous les postes ; relation par code.
class FavorisCaisseRepository {
  const FavorisCaisseRepository(this.db);

  final DatabaseExecutor db;

  /// Codes des produits favoris, dans l'ordre où ils ont été ajoutés.
  Future<List<String>> lire() async => [
    for (final r in await db.query('favori_caisse', columns: ['produit_code'], orderBy: 'ordre'))
      r['produit_code']! as String,
  ];

  /// Ajoute [codes] à la fin des favoris (ceux déjà favoris gardent leur place).
  Future<void> ajouter(Iterable<String> codes) async {
    final deja = (await lire()).toSet();
    final r = await db.rawQuery('SELECT COALESCE(MAX(ordre), -1) + 1 n FROM favori_caisse');
    var ordre = r.first['n']! as int;
    for (final code in codes) {
      if (!deja.add(code)) continue;
      await db.insert('favori_caisse', {'produit_code': code, 'ordre': ordre++});
    }
  }

  Future<void> retirer(Iterable<String> codes) async {
    final liste = codes.toList();
    if (liste.isEmpty) return;
    await db.delete(
      'favori_caisse',
      where: 'produit_code IN (${List.filled(liste.length, '?').join(',')})',
      whereArgs: liste,
    );
  }
}
