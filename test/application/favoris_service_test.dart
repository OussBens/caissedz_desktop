import 'package:caissedz_desktop/application/favoris_service.dart';
import 'package:caissedz_desktop/data/favoris_repository.dart';
import 'package:caissedz_desktop/domain/modules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  group('FavorisService', () {
    test('ajoute au plus 7 favoris', () {
      var favoris = <String>[];
      final ids = Modules.tous.map((m) => m.id).toList();
      for (var i = 0; i < 7; i++) {
        favoris = FavorisService.ajouter(favoris, ids[i])!;
      }
      expect(favoris.length, Modules.maxFavoris);
      expect(FavorisService.ajouter(favoris, ids[7]), isNull);
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
}
