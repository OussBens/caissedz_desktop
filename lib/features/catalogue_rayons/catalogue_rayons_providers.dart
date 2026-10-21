import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/catalogue_rayons_service.dart';
import '../../core/catalogue/catalogue_rayons_api.dart';
import '../produits/produits_providers.dart' show httpClientProvider;

final catalogueRayonsApiProvider = Provider<CatalogueRayonsApi>(
  (ref) => CatalogueRayonsApi(client: ref.watch(httpClientProvider)),
);

final catalogueRayonsServiceProvider = Provider<CatalogueRayonsService>(
  (ref) => CatalogueRayonsService(
    ref.watch(appDatabaseProvider).db,
    api: ref.watch(catalogueRayonsApiProvider),
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
  ),
);
