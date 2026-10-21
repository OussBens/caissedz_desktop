import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/stock_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/codes_barres.dart';
import '../domain/models/produit.dart';
import '../domain/models/stock.dart';

enum ErreurCatalogue {
  designationVide,
  codeBarresInvalide,
  codeBarresDejaUtilise,
  prixInvalide,
  categorieSysteme,
  categorieUtilisee,
  quantiteInvalide,
  lignesVides,
  produitUtilise,
  nomDejaUtilise,
}

class CatalogueException implements Exception {
  const CatalogueException(this.erreur);
  final ErreurCatalogue erreur;
  @override
  String toString() => 'CatalogueException($erreur)';
}

/// Cas d'usage du catalogue : catégories, produits, colis, packs, remises.
/// Toute écriture multi-tables est faite dans UNE transaction.
class CatalogueService {
  const CatalogueService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  CatalogueRepository get _repo => CatalogueRepository(db);

  // ---------------- Catégories ----------------
  Future<Categorie> creerCategorie(
    String nom, {
    String? sousCategorieParDefaut,
    String? description,
    bool actif = true,
  }) async {
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('categorie', CodeGenerator.categorie);
      final c = Categorie(code: code, nom: nom.trim(), description: _texte(description), actif: actif);
      await repo.insererCategorie(c);
      // Chaque catégorie possède au moins une sous-catégorie pour accueillir les produits.
      final sc = await repo.prochainCode('sous_categorie', CodeGenerator.sousCategorie);
      await repo.insererSousCategorie(
        SousCategorie(code: sc, categorieCode: code, nom: sousCategorieParDefaut ?? nom.trim()),
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'categorie',
        entiteCode: code,
        detail: nom.trim(),
      );
      return c;
    });
  }

  Future<SousCategorie> creerSousCategorie(
    String categorieCode,
    String nom, {
    String? description,
    bool actif = true,
  }) async {
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('sous_categorie', CodeGenerator.sousCategorie);
      final s = SousCategorie(
        code: code,
        categorieCode: categorieCode,
        nom: nom.trim(),
        description: _texte(description),
        actif: actif,
      );
      await repo.insererSousCategorie(s);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'sous_categorie',
        entiteCode: code,
        detail: s.nom,
      );
      return s;
    });
  }

  static String? _texte(String? s) => s == null || s.trim().isEmpty ? null : s.trim();

  /// Modifie nom, description et état d'une catégorie (la catégorie système reste active).
  Future<void> modifierCategorie(Categorie c) async {
    if (c.nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    final systeme = c.code == CodeGenerator.systeme(CodeGenerator.categorie);
    await db.transaction((txn) async {
      await CatalogueRepository(txn).modifierCategorie(
        Categorie(code: c.code, nom: c.nom.trim(), description: _texte(c.description), actif: systeme || c.actif),
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'categorie',
        entiteCode: c.code,
        detail: c.nom.trim(),
      );
    });
  }

  Future<void> modifierSousCategorie(SousCategorie s) async {
    if (s.nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    final systeme = s.code == CodeGenerator.systeme(CodeGenerator.sousCategorie);
    await db.transaction((txn) async {
      await CatalogueRepository(txn).modifierSousCategorie(
        SousCategorie(
          code: s.code,
          categorieCode: systeme ? CodeGenerator.systeme(CodeGenerator.categorie) : s.categorieCode,
          nom: s.nom.trim(),
          description: _texte(s.description),
          actif: systeme || s.actif,
        ),
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'sous_categorie',
        entiteCode: s.code,
        detail: s.nom.trim(),
      );
    });
  }

  Future<void> renommerCategorie(String code, String nom) async {
    if (code == CodeGenerator.systeme(CodeGenerator.categorie)) {
      throw const CatalogueException(ErreurCatalogue.categorieSysteme);
    }
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    await _repo.renommerCategorie(code, nom.trim());
  }

  Future<void> renommerSousCategorie(String code, String nom) async {
    if (code == CodeGenerator.systeme(CodeGenerator.sousCategorie)) {
      throw const CatalogueException(ErreurCatalogue.categorieSysteme);
    }
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    await _repo.renommerSousCategorie(code, nom.trim());
  }

  /// Supprime des catégories (les catégories système sont ignorées), dans UNE transaction : leurs produits
  /// passent dans « Sans catégorie » (`CATE0000` / `SC0000`), leurs sous-catégories sont supprimées et les remises
  /// qui les visaient n'ont plus de catégorie. Retourne le nombre de produits déplacés.
  Future<int> supprimerCategories(List<String> codes) async {
    final systeme = CodeGenerator.systeme(CodeGenerator.categorie);
    final cibles = codes.where((c) => c != systeme).toList();
    if (cibles.isEmpty) {
      if (codes.isNotEmpty) throw const CatalogueException(ErreurCatalogue.categorieSysteme);
      return 0;
    }
    return db.transaction((txn) async {
      var deplaces = 0;
      for (final code in cibles) {
        deplaces += await txn.update(
          'produit',
          {'categorie_code': systeme, 'sous_categorie_code': CodeGenerator.systeme(CodeGenerator.sousCategorie)},
          where: 'categorie_code = ?',
          whereArgs: [code],
        );
        await txn.update('remise', {'categorie_code': null}, where: 'categorie_code = ?', whereArgs: [code]);
        await CatalogueRepository(txn).supprimerCategorie(code);
        await HistoriqueRepository(
          txn,
        ).journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'categorie', entiteCode: code);
      }
      return deplaces;
    });
  }

  Future<void> supprimerCategorie(String code) => supprimerCategories([code]);

  /// Supprime des sous-catégories (système ignorée) ; leurs produits passent dans « Sans catégorie ».
  Future<int> supprimerSousCategories(List<String> codes) async {
    final systeme = CodeGenerator.systeme(CodeGenerator.sousCategorie);
    final cibles = codes.where((c) => c != systeme).toList();
    if (cibles.isEmpty) {
      if (codes.isNotEmpty) throw const CatalogueException(ErreurCatalogue.categorieSysteme);
      return 0;
    }
    return db.transaction((txn) async {
      var deplaces = 0;
      for (final code in cibles) {
        deplaces += await txn.update(
          'produit',
          {'categorie_code': CodeGenerator.systeme(CodeGenerator.categorie), 'sous_categorie_code': systeme},
          where: 'sous_categorie_code = ?',
          whereArgs: [code],
        );
        await CatalogueRepository(txn).supprimerSousCategorie(code);
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Suppression',
          entite: 'sous_categorie',
          entiteCode: code,
        );
      }
      return deplaces;
    });
  }

  Future<void> supprimerSousCategorie(String code) => supprimerSousCategories([code]);

  // ---------------- Produits ----------------
  /// Valide et complète un produit : marge ↔ prix de vente, code-barres.
  Future<Produit> _preparer(Produit p, {required bool nouveau, double? margeDefautPct}) async {
    if (p.designation.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    if (p.prixAchat < 0 || p.prixVente < 0) throw const CatalogueException(ErreurCatalogue.prixInvalide);
    if (p.nombreParUnite <= 0) throw const CatalogueException(ErreurCatalogue.quantiteInvalide);
    var produit = p.copyWith(designation: p.designation.trim());
    // Prix de vente absent → calculé depuis la marge (produit ou marge par défaut).
    if (produit.prixVente <= 0 && produit.prixAchat > 0) {
      final marge = produit.margePct > 0 ? produit.margePct : (margeDefautPct ?? 0);
      produit = produit.copyWith(
        prixVente: CalculsPrix.prixVenteDepuisMarge(produit.prixAchat, marge),
        margePct: marge,
      );
    } else {
      produit = produit.copyWith(margePct: CalculsPrix.margeDepuisPrix(produit.prixAchat, produit.prixVente));
    }
    final cb = produit.codeBarres?.trim();
    if (cb != null && cb.isNotEmpty) {
      if (CodesBarres.typeDe(cb) == TypeCodeBarres.autre && cb.length < 4) {
        throw const CatalogueException(ErreurCatalogue.codeBarresInvalide);
      }
      if (!await _repo.codeBarresDisponible(cb, saufProduit: nouveau ? null : produit.code)) {
        throw const CatalogueException(ErreurCatalogue.codeBarresDejaUtilise);
      }
      produit = produit.copyWith(codeBarres: cb);
    } else {
      produit = produit.copyWith(effacerCodeBarres: true);
    }
    return produit;
  }

  /// Crée un produit ; `code` ignoré (généré). Code-barres interne généré si [genererCodeBarres].
  ///
  /// [codesSecondaires] : autres codes-barres reconnus en caisse ; [emballages] : petit puis grand colis
  /// (`null` = aucun) ; [stockInitial] : entrée en stock dans [magasinCode] (hors produit-service).
  Future<Produit> creerProduit(
    Produit p, {
    double? margeDefautPct,
    bool genererCodeBarres = false,
    List<String> codesSecondaires = const [],
    List<EmballageProduit?> emballages = const [],
    double stockInitial = 0,
    String? magasinCode,
    List<String> photos = const [],
  }) async {
    final prepare = await _preparer(p, nouveau: true, margeDefautPct: margeDefautPct);
    final codes = await _verifierCodes(codesSecondaires, prepare.codeBarres);
    await _verifierEmballages(emballages, null);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('produit', CodeGenerator.produit);
      var produit = Produit(
        code: code,
        designation: prepare.designation,
        designationAr: prepare.designationAr,
        codeBarres: prepare.codeBarres,
        categorieCode: prepare.categorieCode,
        sousCategorieCode: prepare.sousCategorieCode,
        prixAchat: prepare.prixAchat,
        prixVente: prepare.prixVente,
        margePct: prepare.margePct,
        unite: prepare.unite,
        tvaPct: prepare.tvaPct,
        seuilStock: prepare.seuilStock,
        suiviNombre: prepare.suiviNombre,
        nombreParUnite: prepare.nombreParUnite,
        source: prepare.source,
        actif: prepare.actif,
        image: photos.isEmpty ? prepare.image : photos.first,
        marque: prepare.marque,
        description: prepare.description,
        fournisseurCode: prepare.fournisseurCode,
        dateExpiration: prepare.dateExpiration,
        service: prepare.service,
        taille: prepare.taille,
        couleur: prepare.couleur,
        observation: prepare.observation,
        suiviSerie: prepare.suiviSerie,
        remiseCode: prepare.remiseCode,
      );
      if (genererCodeBarres && produit.codeBarres == null) {
        produit = produit.copyWith(codeBarres: await _genererCodeBarresInterne(repo));
      }
      await repo.insererProduit(produit);
      await repo.remplacerCodesSecondaires(code, codes);
      await repo.remplacerPhotos(code, photos.take(4).toList());
      await _enregistrerEmballages(repo, produit, emballages);
      if (stockInitial > 0 && !produit.service && magasinCode != null) {
        await StockRepository(txn).insererMouvement(
          MouvementStock(
            date: DateTime.now(),
            produitCode: code,
            magasinCode: magasinCode,
            type: TypesMouvement.initial,
            quantite: stockInitial,
            utilisateurCode: utilisateurCode,
            commentaire: 'Stock initial',
          ),
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'produit',
        entiteCode: code,
        detail: produit.designation,
      );
      return produit;
    });
  }

  /// [codesSecondaires] / [emballages] à `null` : inchangés.
  Future<Produit> modifierProduit(
    Produit p, {
    double? margeDefautPct,
    List<String>? codesSecondaires,
    List<EmballageProduit?>? emballages,
    List<String>? photos,
  }) async {
    var prepare = await _preparer(p, nouveau: false, margeDefautPct: margeDefautPct);
    if (photos != null) {
      prepare = photos.isEmpty
          ? Produit.depuisLigne({...prepare.versLigne(), 'image': null})
          : prepare.copyWith(image: photos.first);
    }
    final codes = codesSecondaires == null ? null : await _verifierCodes(codesSecondaires, prepare.codeBarres, p.code);
    if (emballages != null) await _verifierEmballages(emballages, p.code);
    await db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      await repo.mettreAJourProduit(prepare);
      if (codes != null) await repo.remplacerCodesSecondaires(p.code, codes);
      if (photos != null) await repo.remplacerPhotos(p.code, photos.take(4).toList());
      if (emballages != null) await _enregistrerEmballages(repo, prepare, emballages);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'produit',
        entiteCode: p.code,
        detail: prepare.designation,
      );
    });
    return prepare;
  }

  Future<List<String>> _verifierCodes(List<String> codes, String? principal, [String? produitCode]) async {
    final nets = <String>[];
    for (final c in codes.map((c) => c.trim()).where((c) => c.isNotEmpty)) {
      if (c == principal || nets.contains(c)) continue;
      if (!await _repo.codeBarresDisponible(c, saufProduit: produitCode)) {
        throw const CatalogueException(ErreurCatalogue.codeBarresDejaUtilise);
      }
      nets.add(c);
    }
    return nets;
  }

  Future<void> _verifierEmballages(List<EmballageProduit?> emballages, String? produitCode) async {
    final existants = produitCode == null ? const <Colis>[] : await _colisFiche(_repo, produitCode);
    for (final (i, e) in emballages.indexed) {
      if (e == null) continue;
      if (e.quantite <= 1 || e.prixVente < 0) throw const CatalogueException(ErreurCatalogue.quantiteInvalide);
      final cb = e.codeBarres?.trim();
      final sauf = i < existants.length ? existants[i].code : null;
      if (cb != null && cb.isNotEmpty && !await _repo.codeBarresDisponible(cb, saufColis: sauf)) {
        throw const CatalogueException(ErreurCatalogue.codeBarresDejaUtilise);
      }
    }
  }

  /// Colis actifs d'un produit, du plus petit au plus grand (petit colis puis grand colis).
  static Future<List<Colis>> _colisFiche(CatalogueRepository repo, String produitCode) async =>
      (await repo.colis(produitCode: produitCode)).where((c) => c.actif).toList()
        ..sort((a, b) => a.quantite.compareTo(b.quantite));

  /// Petit / grand colis de la fiche : mis à jour, créés, ou désactivés quand l'emballage est vidé.
  Future<void> _enregistrerEmballages(CatalogueRepository repo, Produit p, List<EmballageProduit?> emballages) async {
    final existants = await _colisFiche(repo, p.code);
    for (var i = 0; i < 2; i++) {
      final e = i < emballages.length ? emballages[i] : null;
      final actuel = i < existants.length ? existants[i] : null;
      final nom = i == 0 ? 'Boîte' : 'Carton';
      final cb = e?.codeBarres?.trim();
      if (e == null) {
        if (actuel != null && i < emballages.length) {
          await repo.mettreAJourColis(
            Colis(
              code: actuel.code,
              produitCode: p.code,
              designation: actuel.designation,
              quantite: actuel.quantite,
              codeBarres: actuel.codeBarres,
              prixVente: actuel.prixVente,
              actif: false,
            ),
          );
        }
        continue;
      }
      final colis = Colis(
        code: actuel?.code ?? await repo.prochainCode('colis', CodeGenerator.colis),
        produitCode: p.code,
        designation: actuel?.designation ?? nom,
        quantite: e.quantite,
        codeBarres: cb == null || cb.isEmpty ? null : cb,
        prixVente: e.prixVente,
      );
      if (actuel == null) {
        await repo.insererColis(colis);
      } else {
        await repo.mettreAJourColis(colis);
      }
    }
  }

  /// Emballages de la fiche (petit puis grand colis).
  Future<List<Colis>> emballages(String produitCode) => _colisFiche(_repo, produitCode);
  Future<List<String>> photos(String produitCode) => _repo.photos(produitCode);
  Future<List<String>> codesSecondaires(String produitCode) => _repo.codesSecondaires(produitCode);

  /// Supprime des produits sans mouvement ni pack ; sinon [ErreurCatalogue.produitUtilise] (à désactiver).
  Future<void> supprimerProduits(List<String> codes) async {
    for (final c in codes) {
      if (await _repo.nbUsagesProduit(c) > 0) throw const CatalogueException(ErreurCatalogue.produitUtilise);
    }
    try {
      await db.transaction((txn) async {
        final repo = CatalogueRepository(txn);
        for (final c in codes) {
          await repo.supprimerProduit(c);
          await HistoriqueRepository(txn)
              .journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'produit', entiteCode: c);
        }
      });
    } on DatabaseException {
      throw const CatalogueException(ErreurCatalogue.produitUtilise);
    }
  }

  /// Affecte des produits à une catégorie / sous-catégorie, à une remise ou à un pack (quantité 1).
  /// Sans [remplacer], seuls les produits sans affectation (catégorie système, sans remise, hors pack)
  /// sont modifiés.
  Future<int> affecter(
    List<String> codes, {
    String? sousCategorieCode,
    String? remiseCode,
    String? packCode,
    bool remplacer = true,
  }) async {
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      var n = 0;
      SousCategorie? sc;
      if (sousCategorieCode != null) {
        sc = (await repo.sousCategories()).where((s) => s.code == sousCategorieCode).firstOrNull;
      }
      Pack? pack;
      if (packCode != null) pack = (await repo.packs()).where((k) => k.code == packCode).firstOrNull;
      final lignes = [...?pack?.lignes];
      for (final code in codes) {
        final p = await repo.produitParCode(code);
        if (p == null) continue;
        if (sc != null && (remplacer || p.categorieCode == CodeGenerator.systeme(CodeGenerator.categorie))) {
          await repo.mettreAJourProduit(p.copyWith(categorieCode: sc.categorieCode, sousCategorieCode: sc.code));
          n++;
        } else if (remiseCode != null && (remplacer || p.remiseCode == null)) {
          await repo.mettreAJourProduit(p.copyWith(remiseCode: remiseCode));
          n++;
        } else if (pack != null) {
          final i = lignes.indexWhere((l) => l.produitCode == code);
          if (i < 0) {
            lignes.add(PackLigne(produitCode: code, quantite: 1));
            n++;
          } else if (remplacer) {
            lignes[i] = PackLigne(produitCode: code, quantite: 1);
            n++;
          }
        }
      }
      if (pack != null) await repo.mettreAJourPack(pack.copyWith(lignes: lignes));
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Affectation',
        entite: 'produit',
        entiteCode: codes.join(','),
        detail: sousCategorieCode ?? remiseCode ?? packCode,
      );
      return n;
    });
  }

  Future<void> activerProduit(String code, bool actif) async {
    final p = await _repo.produitParCode(code);
    if (p == null) return;
    await _repo.mettreAJourProduit(p.copyWith(actif: actif));
  }

  Future<String> _genererCodeBarresInterne(CatalogueRepository repo, [DateTime? date]) async {
    final d = date ?? DateTime.now();
    final jour = '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final seq = await repo.sequenceCodeBarres(jour);
    return CodesBarres.genererInterne(d, seq);
  }

  /// Réserve le prochain code-barres interne (`CDZ` + date + séquence) pour un produit en cours de saisie.
  Future<String> reserverCodeBarresInterne({DateTime? date}) =>
      db.transaction((txn) => _genererCodeBarresInterne(CatalogueRepository(txn), date));

  /// Génère et affecte un code-barres interne (CDZ + date) à un produit sans code.
  Future<Produit> genererCodeBarresInterne(String produitCode, {DateTime? date}) async {
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final p = await repo.produitParCode(produitCode);
      if (p == null) throw ArgumentError('Produit inconnu : $produitCode');
      if (p.codeBarres != null) return p;
      final maj = p.copyWith(codeBarres: await _genererCodeBarresInterne(repo, date));
      await repo.mettreAJourProduit(maj);
      return maj;
    });
  }

  // ---------------- Colis ----------------
  Future<Colis> creerColis(Colis c) async {
    if (c.quantite <= 0) throw const CatalogueException(ErreurCatalogue.quantiteInvalide);
    if (c.designation.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    if (c.codeBarres != null && !await _repo.codeBarresDisponible(c.codeBarres!)) {
      throw const CatalogueException(ErreurCatalogue.codeBarresDejaUtilise);
    }
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('colis', CodeGenerator.colis);
      final colis = Colis(
        code: code,
        produitCode: c.produitCode,
        designation: c.designation.trim(),
        quantite: c.quantite,
        codeBarres: c.codeBarres,
        prixVente: c.prixVente,
        actif: c.actif,
      );
      await repo.insererColis(colis);
      return colis;
    });
  }

  Future<void> modifierColis(Colis c) async {
    if (c.quantite <= 0) throw const CatalogueException(ErreurCatalogue.quantiteInvalide);
    await _repo.mettreAJourColis(c);
  }

  // ---------------- Packs ----------------
  Future<Pack> creerPack(Pack p) async {
    if (p.designation.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    if (p.lignes.isEmpty) throw const CatalogueException(ErreurCatalogue.lignesVides);
    if (p.lignes.any((l) => l.quantite <= 0)) throw const CatalogueException(ErreurCatalogue.quantiteInvalide);
    if (p.codeBarres != null && !await _repo.codeBarresDisponible(p.codeBarres!)) {
      throw const CatalogueException(ErreurCatalogue.codeBarresDejaUtilise);
    }
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('pack', CodeGenerator.pack);
      final pack = Pack(
        code: code,
        designation: p.designation.trim(),
        codeBarres: p.codeBarres,
        prixVente: p.prixVente,
        actif: p.actif,
        lignes: p.lignes,
        description: p.description,
      );
      await repo.insererPack(pack);
      return pack;
    });
  }

  Future<void> modifierPack(Pack p) async {
    if (p.lignes.isEmpty) throw const CatalogueException(ErreurCatalogue.lignesVides);
    await db.transaction((txn) => CatalogueRepository(txn).mettreAJourPack(p));
  }

  /// Packs déjà vendus : gardés pour l'historique des ventes (lignes scellées), donc non supprimables.
  Future<Set<String>> packsVendus() async => {
    for (final r in await db.rawQuery('SELECT DISTINCT pack_code FROM vente_ligne WHERE pack_code IS NOT NULL'))
      r['pack_code']! as String,
  };

  /// Supprime des packs jamais vendus (leurs lignes partent avec eux) ; un pack vendu est refusé.
  Future<void> supprimerPacks(List<String> codes) async {
    final vendus = await packsVendus();
    if (codes.any(vendus.contains)) throw const CatalogueException(ErreurCatalogue.produitUtilise);
    await db.transaction((txn) async {
      for (final code in codes) {
        await txn.delete('pack', where: 'code = ?', whereArgs: [code]);
        await HistoriqueRepository(txn)
            .journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'pack', entiteCode: code);
      }
    });
  }

  Future<void> activerPack(String code, bool actif) async {
    final p = (await _repo.packs()).where((k) => k.code == code).firstOrNull;
    if (p == null) return;
    await db.transaction((txn) => CatalogueRepository(txn).mettreAJourPack(p.copyWith(actif: actif)));
  }

  // ---------------- Remises ----------------
  void _validerRemise(Remise r) {
    if (r.designation.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    if (r.valeur <= 0 || (r.estPourcentage && r.valeur > 100) || r.seuil < 0) {
      throw const CatalogueException(ErreurCatalogue.prixInvalide);
    }
  }

  /// Crée une remise ; une remise « Par Produit » est assignée aux [produits] (`produit.remise_code`).
  Future<Remise> creerRemise(Remise r, {List<String> produits = const []}) async {
    _validerRemise(r);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final remise = r.copyWith(code: await repo.prochainCode('remise', CodeGenerator.remise));
      await repo.insererRemise(remise);
      if (!r.parMontant) await _assignerRemise(repo, remise.code, produits);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'remise',
        entiteCode: remise.code,
        detail: r.designation.trim(),
      );
      return remise;
    });
  }

  /// Modifie une remise ; si [produits] est fourni, il remplace la liste des produits assignés.
  Future<void> modifierRemise(Remise r, {List<String>? produits}) async {
    _validerRemise(r);
    await db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      await repo.mettreAJourRemise(r);
      if (r.parMontant) {
        await _assignerRemise(repo, r.code, const []);
      } else if (produits != null) {
        await _assignerRemise(repo, r.code, produits);
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'remise',
        entiteCode: r.code,
        detail: r.designation,
      );
    });
  }

  Future<void> _assignerRemise(CatalogueRepository repo, String remiseCode, List<String> produits) async {
    for (final p in await repo.produits()) {
      final dedans = produits.contains(p.code);
      if (dedans && p.remiseCode != remiseCode) {
        await repo.mettreAJourProduit(p.copyWith(remiseCode: remiseCode));
      } else if (!dedans && p.remiseCode == remiseCode) {
        await repo.mettreAJourProduit(p.copyWith(effacerRemise: true));
      }
    }
  }

  Future<void> activerRemise(String code, bool actif) async {
    final r = (await _repo.remises()).where((x) => x.code == code).firstOrNull;
    if (r == null) return;
    await _repo.mettreAJourRemise(r.copyWith(actif: actif));
  }

  /// Supprime des remises : les produits qui la portaient n'ont plus de remise. Les ventes passées gardent le
  /// code et le montant de la remise accordée.
  Future<void> supprimerRemises(List<String> codes) => db.transaction((txn) async {
    for (final code in codes) {
      await txn.update('produit', {'remise_code': null}, where: 'remise_code = ?', whereArgs: [code]);
      await CatalogueRepository(txn).supprimerRemise(code);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'remise', entiteCode: code);
    }
  });

  Future<void> supprimerRemise(String code) => supprimerRemises([code]);

  /// Meilleure remise applicable à un produit à une date donnée (montant de remise sur [montant]).
  Future<double> remiseApplicable(Produit p, double montant, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    var meilleure = 0.0;
    for (final r in await _repo.remises()) {
      final parProduit = !r.parMontant && p.remiseCode == r.code && r.estActive(d);
      if (!parProduit && !r.estApplicable(d, produitCode: p.code, categorieCode: p.categorieCode)) continue;
      final m = CalculsPrix.remise(montant, type: r.type, valeur: r.valeur);
      if (m > meilleure) meilleure = m;
    }
    return meilleure;
  }
}
