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
/// alcool exclus par le serveur) entrent dans le catalogue local, SANS prix ni stock, avec leur nom arabe
/// quand le catalogue le connaît.
///
/// Chaque rayon a SA catégorie locale (créée à son nom FR, ou celle qui porte déjà ce nom). Un produit
/// dont un code-barres est déjà connu n'est pas ajouté : un nouveau téléchargement ne crée aucun doublon.
/// Ensuite, au lancement, les produits devenus tendance dans ces rayons sont ajoutés
/// ([actualiserTendances]). Tout est reçu d'abord, puis écrit en UNE transaction.
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

  /// Toutes les pages du rayon [code] ([depuis] : seulement les produits devenus tendance depuis ce jour).
  Future<List<ProduitCatalogue>> _recevoir(String code, {DateTime? depuis, void Function(int)? onPage}) async {
    final liste = <ProduitCatalogue>[];
    for (var page = 1, pages = 1; page <= pages; page++) {
      final r = await api.produits(code, page: page, depuis: depuis);
      pages = r.pages;
      liste.addAll(r.produits);
      onPage?.call(r.produits.length);
      if (r.produits.isEmpty) break;
    }
    return liste;
  }

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
      void progres() =>
          onProgres?.call((rayon: rayon, indexRayon: i, nbRayons: choix.length, recus: nbRecus, attendus: attendus));
      progres();
      recus[rayon.code] = await _recevoir(
        rayon.code,
        onPage: (n) {
          nbRecus += n;
          progres();
        },
      );
    }
    final le = maintenant ?? DateTime.now();
    return db.transaction((txn) async {
      final repo = CatalogueRayonsRepository(txn);
      final importes = await repo.rayonsImportes();
      final ajout = await _Ajout.ouvrir(txn);
      final resultats = <ResultatRayon>[];
      for (final rayon in choix) {
        final lien = await _categorie(txn, rayon, importes[rayon.code]);
        final r = await ajout.ajouter(recus[rayon.code]!, lien);
        await repo.enregistrer(
          rayonCode: rayon.code,
          nom: rayon.nomFr,
          categorieCode: lien.categorieCode,
          sousCategorieCode: lien.sousCategorieCode,
          disponibles: recus[rayon.code]!.length,
          ajoutes: r.ajoutes,
          le: le,
        );
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Téléchargement catalogue',
          entite: 'catalogue_rayon',
          entiteCode: rayon.code,
          detail: '${rayon.nomFr} : ${r.ajoutes} ajoutés, ${r.deja} déjà présents',
        );
        resultats.add(
          ResultatRayon(
            rayon: rayon,
            disponibles: recus[rayon.code]!.length,
            telecharges: r.ajoutes,
            dejaPresents: r.deja,
            ignores: r.ignores,
          ),
        );
      }
      await ParametreRepository(txn).ecrire(clePropose, '1');
      return ResultatTelechargement(resultats);
    });
  }

  /// Au lancement : ajoute aux rayons déjà téléchargés les produits devenus tendance depuis la dernière fois
  /// (le jour de la dernière demande compris : un produit devenu tendance ce jour-là n'est pas manqué), et
  /// donne leur nom arabe aux produits du catalogue qui n'en avaient pas. Renvoie le nombre de produits
  /// ajoutés et de noms arabes repris ; lance [CatalogueRayonsException] hors ligne (rien n'est écrit).
  Future<({int ajoutes, int nomsAr})> actualiserTendances({DateTime? maintenant}) async {
    final importes = await rayonsImportes();
    if (importes.isEmpty) return (ajoutes: 0, nomsAr: 0);
    final recus = <String, List<ProduitCatalogue>>{};
    for (final MapEntry(key: code, value: r) in importes.entries) {
      final depuis = r.tendanceLe ?? r.importeLe;
      final liste = await _recevoir(code, depuis: DateTime(depuis.year, depuis.month, depuis.day));
      // Seulement les produits marqués tendance : un serveur qui ignorerait `depuis` renverrait tout le rayon.
      recus[code] = [
        for (final p in liste)
          if (p.tendance) p,
      ];
    }
    final le = maintenant ?? DateTime.now();
    return db.transaction((txn) async {
      final repo = CatalogueRayonsRepository(txn);
      final ajout = await _Ajout.ouvrir(txn);
      var ajoutes = 0;
      for (final MapEntry(key: code, value: r) in importes.entries) {
        final rayon = RayonCatalogue(code: code, nomFr: r.nom);
        final lien = await _categorie(txn, rayon, r);
        final resultat = await ajout.ajouter(recus[code]!, lien);
        await repo.marquerTendance(code, ajoutes: resultat.ajoutes, le: le);
        if (resultat.ajoutes > 0) {
          await HistoriqueRepository(txn).journaliser(
            utilisateurCode: utilisateurCode,
            action: 'Tendance catalogue',
            entite: 'catalogue_rayon',
            entiteCode: code,
            detail: '${r.nom} : ${resultat.ajoutes} produits tendance ajoutés',
          );
        }
        ajoutes += resultat.ajoutes;
      }
      return (ajoutes: ajoutes, nomsAr: ajout.nomsAr);
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
    if (deja != null &&
        (await catalogue.sousCategories(deja.categorieCode)).any((s) => s.code == deja.sousCategorieCode)) {
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

/// Ajout de produits du catalogue dans une transaction : codes-barres déjà pris et prochain numéro `PRD`
/// suivis d'un rayon à l'autre ; les produits déjà présents reçoivent le nom arabe qui leur manquait.
class _Ajout {
  _Ajout._(this.txn, this.pris, this.numero);

  static Future<_Ajout> ouvrir(Transaction txn) async {
    final catalogue = CatalogueRepository(txn);
    final numero = CodeGenerator.numero(
      await catalogue.prochainCode('produit', CodeGenerator.produit),
      CodeGenerator.produit,
    )!;
    return _Ajout._(txn, await CatalogueRayonsRepository(txn).codesBarresUtilises(), numero);
  }

  final Transaction txn;
  final Set<String> pris;
  int numero;
  int nomsAr = 0;

  Future<({int ajoutes, int deja, int ignores})> ajouter(
    List<ProduitCatalogue> produits,
    ({String categorieCode, String sousCategorieCode}) lien,
  ) async {
    final nouveaux = <(Produit, List<String>)>[];
    final nomsDeja = <String, String>{};
    var deja = 0, ignores = 0;
    for (final p in produits) {
      if (p.nom.isEmpty || p.codesBarres.isEmpty) {
        ignores++;
        continue;
      }
      if (p.codesBarres.any(pris.contains)) {
        deja++;
        if (p.nomAr != null) nomsDeja[p.codesBarres.first] = p.nomAr!;
        continue;
      }
      final produit = Produit(
        code: CodeGenerator.pour(CodeGenerator.produit, numero++),
        designation: p.nom,
        designationAr: p.nomAr,
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
    final repo = CatalogueRayonsRepository(txn);
    await repo.insererProduits(nouveaux);
    nomsAr += await repo.completerNomsArabes(nomsDeja);
    // Tendance du catalogue : produits ajoutés comme déjà présents (alerte « Tendances du marché »).
    final tendances = [
      for (final p in produits)
        if (p.tendance) ...p.codesBarres,
    ];
    if (tendances.isNotEmpty) await repo.marquerProduitsTendance(tendances, DateTime.now());
    return (ajoutes: nouveaux.length, deja: deja, ignores: ignores);
  }
}
