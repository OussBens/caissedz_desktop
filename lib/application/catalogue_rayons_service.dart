import 'package:sqflite_common/sqlite_api.dart';

import '../core/catalogue/catalogue_rayons_api.dart';
import '../data/catalogue_rayons_repository.dart';
import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/produit.dart';
import '../domain/models/rayon_catalogue.dart';

/// Rayons du catalogue BENS (accueil après la connexion, puis Produits › Catalogue BENS) : l'utilisateur
/// choisit des rayons selon son activité, leurs produits les mieux classés (au plus 2 000 chacun, porc et
/// alcool exclus par le serveur) entrent dans le catalogue local, SANS prix ni stock.
///
/// Chaque rayon a SA catégorie locale (créée à son nom FR, ou celle qui porte déjà ce nom). Un produit
/// dont un code-barres est déjà connu n'est pas ajouté : un nouveau téléchargement ne crée aucun doublon.
/// Tout est reçu d'abord, puis écrit en UNE transaction.
class CatalogueRayonsService {
  const CatalogueRayonsService(this.db, {required this.api, required this.utilisateurCode});

  final Database db;
  final CatalogueRayonsApi api;
  final String utilisateurCode;

  /// L'écran des rayons a déjà été proposé à l'accueil (appliqué ou « Plus tard »).
  static const String clePropose = 'catalogue_rayons_propose';

  Future<List<RayonCatalogue>> rayons() => api.rayons();

  Future<Map<String, RayonImporte>> rayonsImportes() => CatalogueRayonsRepository(db).rayonsImportes();

  Future<bool> estPropose() async => await ParametreRepository(db).lire(clePropose) == '1';

  Future<void> marquerPropose() => ParametreRepository(db).ecrire(clePropose, '1');

  /// Télécharge les produits des rayons [choix]. [onProgres] suit la réception (page par page).
  /// Lance [CatalogueRayonsException] si le catalogue ne répond pas : alors rien n'est écrit.
  Future<ResultatTelechargement> telecharger(
    List<RayonCatalogue> choix, {
    void Function(ProgresTelechargement)? onProgres,
    DateTime? maintenant,
  }) async {
    final attendus = choix.fold(0, (n, r) => n + r.produits);
    final recus = <String, List<ProduitCatalogue>>{};
    var nbRecus = 0;
    for (final (i, rayon) in choix.indexed) {
      final liste = recus[rayon.code] = [];
      onProgres?.call((rayon: rayon, indexRayon: i, nbRayons: choix.length, recus: nbRecus, attendus: attendus));
      for (var page = 1, pages = 1; page <= pages; page++) {
        final r = await api.produits(rayon.code, page: page);
        pages = r.pages;
        liste.addAll(r.produits);
        nbRecus += r.produits.length;
        onProgres?.call((rayon: rayon, indexRayon: i, nbRayons: choix.length, recus: nbRecus, attendus: attendus));
        if (r.produits.isEmpty) break;
      }
    }
    final le = maintenant ?? DateTime.now();
    return db.transaction((txn) async {
      final repo = CatalogueRayonsRepository(txn);
      final catalogue = CatalogueRepository(txn);
      final journal = HistoriqueRepository(txn);
      final pris = await repo.codesBarresUtilises();
      final importes = await repo.rayonsImportes();
      var numero = CodeGenerator.numero(await catalogue.prochainCode('produit', CodeGenerator.produit), CodeGenerator.produit)!;
      final resultats = <ResultatRayon>[];
      for (final rayon in choix) {
        final lien = await _categorie(txn, rayon, importes[rayon.code]);
        final nouveaux = <(Produit, List<String>)>[];
        var deja = 0, ignores = 0;
        for (final p in recus[rayon.code]!) {
          if (p.nom.isEmpty || p.codesBarres.isEmpty) {
            ignores++;
            continue;
          }
          if (p.codesBarres.any(pris.contains)) {
            deja++;
            continue;
          }
          final produit = Produit(
            code: CodeGenerator.pour(CodeGenerator.produit, numero++),
            designation: p.nom,
            codeBarres: p.codesBarres.first,
            categorieCode: lien.categorieCode,
            sousCategorieCode: lien.sousCategorieCode,
            source: Produit.sourceCatalogue,
            image: p.photo,
            marque: p.marque,
          );
          nouveaux.add((produit, p.codesBarres.skip(1).toList()));
          pris.addAll(p.codesBarres);
        }
        await repo.insererProduits(nouveaux);
        final ajoutes = nouveaux.length;
        await repo.enregistrer(
          rayonCode: rayon.code,
          nom: rayon.nomFr,
          categorieCode: lien.categorieCode,
          sousCategorieCode: lien.sousCategorieCode,
          disponibles: recus[rayon.code]!.length,
          ajoutes: ajoutes,
          le: le,
        );
        await journal.journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Téléchargement catalogue',
          entite: 'catalogue_rayon',
          entiteCode: rayon.code,
          detail: '${rayon.nomFr} : $ajoutes ajoutés, $deja déjà présents',
        );
        resultats.add(
          ResultatRayon(
            rayon: rayon,
            disponibles: recus[rayon.code]!.length,
            telecharges: ajoutes,
            dejaPresents: deja,
            ignores: ignores,
          ),
        );
      }
      await ParametreRepository(txn).ecrire(clePropose, '1');
      return ResultatTelechargement(resultats);
    });
  }

  /// La catégorie du rayon : celle déjà liée, sinon celle qui porte son nom, sinon une nouvelle (avec sa
  /// sous-catégorie, comme toute catégorie).
  Future<({String categorieCode, String sousCategorieCode})> _categorie(
    Transaction txn,
    RayonCatalogue rayon,
    RayonImporte? deja,
  ) async {
    final catalogue = CatalogueRepository(txn);
    // La catégorie liée, tant que sa sous-catégorie existe (elle a pu être supprimée entre-temps).
    if (deja != null && (await catalogue.sousCategories(deja.categorieCode)).any((s) => s.code == deja.sousCategorieCode)) {
      return (categorieCode: deja.categorieCode, sousCategorieCode: deja.sousCategorieCode);
    }
    final parNom = await CatalogueRayonsRepository(txn).categorieParNom(rayon.nomFr);
    if (parNom != null) return parNom;
    final code = await catalogue.prochainCode('categorie', CodeGenerator.categorie);
    await catalogue.insererCategorie(Categorie(code: code, nom: rayon.nomFr));
    final sc = await catalogue.prochainCode('sous_categorie', CodeGenerator.sousCategorie);
    await catalogue.insererSousCategorie(SousCategorie(code: sc, categorieCode: code, nom: rayon.nomFr));
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Création',
      entite: 'categorie',
      entiteCode: code,
      detail: rayon.nomFr,
    );
    return (categorieCode: code, sousCategorieCode: sc);
  }
}
