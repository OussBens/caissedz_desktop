import '../data/favoris_repository.dart';
import '../domain/modules.dart';

/// Gestion des favoris de la barre latérale (maximum [Modules.maxFavoris]).
class FavorisService {
  const FavorisService(this.repository);

  final FavorisRepository repository;

  Future<List<String>> charger(String utilisateurCode) async {
    final ids = await repository.lire(utilisateurCode);
    // Ignore les modules inconnus (module supprimé d'une version à l'autre).
    return ids.where((id) => Modules.parId(id) != null).take(Modules.maxFavoris).toList();
  }

  /// Retourne la nouvelle liste, ou `null` si le maximum est atteint.
  static List<String>? ajouter(List<String> favoris, String moduleId) {
    if (favoris.contains(moduleId)) return favoris;
    if (favoris.length >= Modules.maxFavoris) return null;
    return [...favoris, moduleId];
  }

  static List<String> retirer(List<String> favoris, String moduleId) => favoris.where((id) => id != moduleId).toList();

  static List<String> basculer(List<String> favoris, String moduleId) =>
      favoris.contains(moduleId) ? retirer(favoris, moduleId) : (ajouter(favoris, moduleId) ?? favoris);

  Future<void> enregistrer(String utilisateurCode, List<String> favoris) =>
      repository.ecrire(utilisateurCode, favoris.take(Modules.maxFavoris).toList());
}
