import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/produit.dart';

/// Rayon du catalogue BENS déjà téléchargé et la catégorie locale qui l'accueille ; [tendanceLe] : dernier ajout
/// des produits devenus tendance (`null` : jamais depuis le téléchargement).
typedef RayonImporte = ({
  String nom,
  String categorieCode,
  String sousCategorieCode,
  int telecharges,
  DateTime importeLe,
  DateTime? tendanceLe,
});

/// Accès SQL aux rayons du catalogue BENS téléchargés (table `catalogue_rayon`).
class CatalogueRayonsRepository {
  const CatalogueRayonsRepository(this.db);

  final DatabaseExecutor db;

  Future<Map<String, RayonImporte>> rayonsImportes() async => {
    for (final r in await db.query('catalogue_rayon'))
      r['rayon_code']! as String: (
        nom: r['nom']! as String,
        categorieCode: r['categorie_code']! as String,
        sousCategorieCode: r['sous_categorie_code']! as String,
        telecharges: r['telecharges']! as int,
        importeLe: DateTime.parse(r['importe_le']! as String).toLocal(),
        tendanceLe: DateTime.tryParse((r['tendance_le'] as String?) ?? '')?.toLocal(),
      ),
  };

  /// Donne leur nom arabe ([noms] : par code-barres) aux produits du catalogue qui n'en ont pas encore.
  /// Renvoie le nombre de produits complétés.
  Future<int> completerNomsArabes(Map<String, String> noms) async {
    var n = 0;
    for (final MapEntry(key: codeBarres, value: nom) in noms.entries) {
      n += await db.rawUpdate(
        'UPDATE produit SET designation_ar = ? WHERE code_barres = ? AND source = ? '
        "AND TRIM(COALESCE(designation_ar, '')) = ''",
        [nom, codeBarres, Produit.sourceCatalogue],
      );
    }
    return n;
  }

  /// Produits du poste signalés tendance par le catalogue (par code-barres principal) : `tendance_le` = [le], s'ils
  /// ne l'étaient pas déjà (alerte « Tendances du marché »).
  Future<void> marquerProduitsTendance(Iterable<String> codesBarres, DateTime le) async {
    final codes = codesBarres.toList();
    for (var i = 0; i < codes.length; i += 500) {
      final lot = codes.sublist(i, i + 500 > codes.length ? codes.length : i + 500);
      await db.rawUpdate(
        'UPDATE produit SET tendance_le = ? WHERE tendance_le IS NULL '
        'AND code_barres IN (${List.filled(lot.length, '?').join(',')})',
        [le.toUtc().toIso8601String(), ...lot],
      );
    }
  }

  /// Note le jour où le catalogue a confirmé nouveaux sur le marché les produits de ces codes-barres (s'il n'est
  /// pas déjà noté).
  Future<void> marquerProduitsNouveaux(Map<String, DateTime> parCodeBarres) async {
    for (final MapEntry(key: cb, value: le) in parCodeBarres.entries) {
      await db.rawUpdate('UPDATE produit SET nouveau_le = ? WHERE nouveau_le IS NULL AND code_barres = ?', [
        le.toIso8601String().substring(0, 10),
        cb,
      ]);
    }
  }

  /// Les produits devenus tendance du rayon [rayonCode] ont été demandés le [le] ([ajoutes] nouveaux).
  Future<void> marquerTendance(String rayonCode, {required int ajoutes, required DateTime le}) => db.rawUpdate(
    'UPDATE catalogue_rayon SET telecharges = telecharges + ?, tendance_le = ? WHERE rayon_code = ?',
    [ajoutes, le.toUtc().toIso8601String(), rayonCode],
  );

  /// Tous les codes-barres déjà pris (produits, codes secondaires, colis, packs).
  Future<Set<String>> codesBarresUtilises() async => {
    for (final r in await db.rawQuery('''
      SELECT code_barres c FROM produit WHERE code_barres IS NOT NULL
      UNION SELECT code_barres FROM produit_code_detail
      UNION SELECT code_barres FROM colis WHERE code_barres IS NOT NULL
      UNION SELECT code_barres FROM pack WHERE code_barres IS NOT NULL
    '''))
      r['c']! as String,
  };

  /// Catégorie existante de ce nom (sans tenir compte de la casse) et sa première sous-catégorie.
  Future<({String categorieCode, String sousCategorieCode})?> categorieParNom(String nom) async {
    final rows = await db.rawQuery(
      '''
      SELECT c.code, (SELECT s.code FROM sous_categorie s WHERE s.categorie_code = c.code ORDER BY s.code LIMIT 1) sc
      FROM categorie c WHERE lower(c.nom) = lower(?) ORDER BY c.code LIMIT 1
      ''',
      [nom.trim()],
    );
    if (rows.isEmpty || rows.first['sc'] == null) return null;
    return (categorieCode: rows.first['code']! as String, sousCategorieCode: rows.first['sc']! as String);
  }

  /// Insère d'un bloc des milliers de produits et leurs codes-barres secondaires (un seul aller-retour).
  Future<void> insererProduits(List<(Produit, List<String>)> produits) async {
    if (produits.isEmpty) return;
    final lot = db.batch();
    for (final (p, secondaires) in produits) {
      lot.insert('produit', p.versLigne());
      for (final cb in secondaires) {
        lot.insert('produit_code_detail', {'produit_code': p.code, 'code_barres': cb});
      }
    }
    await lot.commit(noResult: true);
  }

  /// Enregistre (ou complète) le rayon [rayonCode] : [ajoutes] produits de plus, [disponibles] proposés.
  Future<void> enregistrer({
    required String rayonCode,
    required String nom,
    required String categorieCode,
    required String sousCategorieCode,
    required int disponibles,
    required int ajoutes,
    required DateTime le,
  }) => db.rawInsert(
    '''
    INSERT INTO catalogue_rayon (rayon_code, nom, categorie_code, sous_categorie_code, disponibles, telecharges, importe_le)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(rayon_code) DO UPDATE SET nom = excluded.nom, categorie_code = excluded.categorie_code,
      sous_categorie_code = excluded.sous_categorie_code, disponibles = excluded.disponibles,
      telecharges = catalogue_rayon.telecharges + excluded.telecharges, importe_le = excluded.importe_le
    ''',
    [rayonCode, nom, categorieCode, sousCategorieCode, disponibles, ajoutes, le.toUtc().toIso8601String()],
  );
}
