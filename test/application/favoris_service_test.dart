import 'package:caissedz_desktop/application/archivage_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/favoris_service.dart';
import 'package:caissedz_desktop/data/favoris_caisse_repository.dart';
import 'package:caissedz_desktop/data/favoris_repository.dart';
import 'package:caissedz_desktop/domain/archivage.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/modules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  group('FavorisService', () {
    test('ajoute au plus 5 favoris', () {
      var favoris = <String>[];
      final ids = Modules.tous.map((m) => m.id).toList();
      for (var i = 0; i < 5; i++) {
        favoris = FavorisService.ajouter(favoris, ids[i])!;
      }
      expect(favoris.length, Modules.maxFavoris);
      expect(FavorisService.ajouter(favoris, ids[5]), isNull);
      // Ajouter un favori déjà présent ne change rien et ne compte pas.
      expect(FavorisService.ajouter(favoris, ids[0]), favoris);
    });

    test('retire et bascule', () {
      final f = FavorisService.ajouter(const [], 'caisse')!;
      expect(FavorisService.basculer(f, 'caisse'), isEmpty);
      expect(FavorisService.basculer(const [], 'caisse'), ['caisse']);
      expect(FavorisService.retirer(f, 'inconnu'), f);
    });

    test('persiste par utilisateur, dans l’ordre, et ignore les modules inconnus', () async {
      final base = await ouvrirBaseDeTest();
      final service = FavorisService(FavorisRepository(base.db));
      await service.enregistrer('admin', ['ventes', 'caisse', 'produits']);
      await service.enregistrer('caissier1', ['caisse']);
      await base.db.insert('favori_module', {'utilisateur_code': 'admin', 'module_id': 'module_supprime', 'ordre': 9});
      expect(await service.charger('admin'), ['ventes', 'caisse', 'produits']);
      expect(await service.charger('caissier1'), ['caisse']);
      expect(await service.charger('inconnu'), isEmpty);
      await service.enregistrer('admin', ['stock']);
      expect(await service.charger('admin'), ['stock']);
    });
  });

  test('FavorisCaisseRepository : ordre d’ajout, sans doublon, retrait, effacé avec le produit', () async {
    final base = await ouvrirBaseDeTest();
    final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
    Future<String> produit(String nom) async => (await cat.creerProduit(
      Produit(code: '', designation: nom, categorieCode: 'CATE0000', sousCategorieCode: 'SC0000', prixVente: 10),
    )).code;
    final lait = await produit('Lait');
    final eau = await produit('Eau');
    final pain = await produit('Pain');
    final repo = FavorisCaisseRepository(base.db);
    await repo.ajouter([eau, lait]);
    await repo.ajouter([lait, pain]);
    expect(await repo.lire(), [eau, lait, pain]);
    await repo.retirer([lait]);
    expect(await repo.lire(), [eau, pain]);
    await ArchivageService(base.db, utilisateurCode: 'USR0000').supprimer(EntiteArchivable.produit, [eau]);
    expect(await repo.lire(), [pain]);
  });
}
