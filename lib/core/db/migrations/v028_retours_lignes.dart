import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 28 : retours rattachés à la ligne de vente et à la caisse.
/// - `vente_ligne.unites` : unités de stock réellement sorties par la ligne (colis × quantité figé à la vente) ;
///   un retour ou une annulation ne relit plus la définition actuelle du colis. Reprise des anciennes lignes
///   avec le colis actuel (seule information disponible).
/// - `retour.caisse_code` : caisse du retour (période close contrôlée par caisse), reprise du versement lié
///   puis de la vente d'origine.
/// - `retour.points_repris` : points de fidélité retirés au prorata, rendus si le retour est annulé.
/// - `retour_ligne.ordre_origine` : ligne de la vente retournée (et non plus la 1ʳᵉ ligne du produit).
class MigrationV028RetoursLignes extends Migration {
  const MigrationV028RetoursLignes();

  @override
  int get version => 28;

  @override
  String get description => 'Retours par ligne de vente, unités figées, caisse et points des retours';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('ALTER TABLE vente_ligne ADD COLUMN unites REAL NOT NULL DEFAULT 0');
    await txn.execute('''
      UPDATE vente_ligne SET unites = CASE
        WHEN unite_vente = 'Nombre' OR (pack_code IS NOT NULL AND composant_pack = 0) THEN 0
        ELSE quantite * COALESCE((SELECT c.quantite FROM colis c WHERE c.code = vente_ligne.colis_code), 1) END
    ''');
    await txn.execute('ALTER TABLE retour ADD COLUMN caisse_code TEXT');
    await txn.execute('''
      UPDATE retour SET caisse_code = COALESCE(
        (SELECT v.caisse_code FROM versement v WHERE v.retour_code = retour.code AND v.caisse_code IS NOT NULL
          ORDER BY v.etat DESC LIMIT 1),
        CASE WHEN type = 'Client' THEN (SELECT ve.caisse_code FROM vente ve WHERE ve.code = retour.document_code) END)
    ''');
    await txn.execute('ALTER TABLE retour ADD COLUMN points_repris INTEGER NOT NULL DEFAULT 0');
    await txn.execute('ALTER TABLE retour_ligne ADD COLUMN ordre_origine INTEGER');
    await txn.execute('''
      UPDATE retour_ligne SET ordre_origine = (
        SELECT MIN(l.ordre) FROM vente_ligne l JOIN retour r ON r.code = retour_ligne.retour_code
        WHERE r.type = 'Client' AND l.vente_code = r.document_code AND l.produit_code = retour_ligne.produit_code
          AND (l.pack_code IS NULL OR l.composant_pack = 1))
    ''');
  }
}
