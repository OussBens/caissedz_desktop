import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../app/providers.dart';
import '../../application/catalogue_ia_service.dart';
import '../../application/catalogue_service.dart';
import '../../application/import_produits_service.dart';
import '../../application/synchro_catalogue_service.dart';
import '../../data/catalogue_repository.dart';
import '../../data/parametre_repository.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

final catalogueRepositoryProvider = Provider<CatalogueRepository>(
  (ref) => CatalogueRepository(ref.watch(appDatabaseProvider).db),
);

final catalogueServiceProvider = Provider<CatalogueService>(
  (ref) =>
      CatalogueService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Paramètres de vente (marge par défaut, devise…), relus à la demande.
final parametresVenteProvider = FutureProvider<ParametresVente>((ref) async {
  final repo = ParametreRepository(ref.watch(appDatabaseProvider).db);
  return ParametresVente.depuisCles(
    await repo.lirePlusieurs([
      ParametresVente.cleMarge,
      ParametresVente.cleSeuil,
      ParametresVente.cleFidelite,
      ParametresVente.clePoints,
      ParametresVente.cleDevise,
    ]),
  );
});

final deviseProvider = Provider<String>((ref) => ref.watch(parametresVenteProvider).value?.devise ?? 'DA');

/// Paramètres de connexion au serveur CaisseDZ (Paramètres, lot 8).
final serveurCaisseDzProvider = FutureProvider<({String url, String? cle, String urlMantouj})>((ref) async {
  final repo = ParametreRepository(ref.watch(appDatabaseProvider).db);
  final v = await repo.lirePlusieurs(['serveur_url', 'serveur_cle', 'mantouj_url']);
  return (url: v['serveur_url'] ?? '', cle: v['serveur_cle'], urlMantouj: v['mantouj_url'] ?? '');
});

final catalogueIaServiceProvider = Provider<CatalogueIaService>((ref) {
  final s = ref.watch(serveurCaisseDzProvider).value;
  return CatalogueIaService.parDefaut(
    ref.watch(httpClientProvider),
    urlCaisseDz: s?.url == null || s!.url.isEmpty ? '' : '${s.url}/catalogue/produits',
    urlMantouj: s?.urlMantouj ?? '',
    cleApi: s?.cle,
  );
});

final synchroCatalogueServiceProvider = Provider<SynchroCatalogueService>((ref) {
  final s = ref.watch(serveurCaisseDzProvider).value;
  return SynchroCatalogueService(
    ref.watch(appDatabaseProvider).db,
    client: ref.watch(httpClientProvider),
    baseUrl: s?.url ?? '',
    cleApi: s?.cle,
  );
});

final importProduitsServiceProvider = Provider<ImportProduitsService>(
  (ref) => ImportProduitsService(
    ref.watch(appDatabaseProvider).db,
    catalogue: ref.watch(catalogueServiceProvider),
    margeDefautPct: ref.watch(parametresVenteProvider).value?.margeDefautPct,
  ),
);

/// Compteur de version du catalogue : incrémenté après chaque écriture pour rafraîchir les listes.
class VersionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void incrementer() => state++;
}

final catalogueVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

class RechercheNotifier extends Notifier<String> {
  @override
  String build() => '';
  void changer(String v) => state = v;
}

final rechercheProduitsProvider = NotifierProvider<RechercheNotifier, String>(RechercheNotifier.new);

final produitsProvider = FutureProvider<List<Produit>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).produits(recherche: ref.watch(rechercheProduitsProvider));
});

final categoriesProvider = FutureProvider<List<Categorie>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).categories();
});

final sousCategoriesProvider = FutureProvider<List<SousCategorie>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).sousCategories();
});

final colisProvider = FutureProvider<List<Colis>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).colis();
});

final packsProvider = FutureProvider<List<Pack>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).packs();
});

final remisesProvider = FutureProvider<List<Remise>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).remises();
});

/// À appeler après toute écriture dans le catalogue.
void rafraichirCatalogue(WidgetRef ref) => ref.read(catalogueVersionProvider.notifier).incrementer();
