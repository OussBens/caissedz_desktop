import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/codes_barres.dart';
import '../domain/models/produit.dart';

enum ErreurCatalogue {
  designationVide,
  codeBarresInvalide,
  codeBarresDejaUtilise,
  prixInvalide,
  categorieSysteme,
  categorieUtilisee,
  quantiteInvalide,
  lignesVides,
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
  Future<Categorie> creerCategorie(String nom, {String? sousCategorieParDefaut}) async {
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('categorie', CodeGenerator.categorie);
      final c = Categorie(code: code, nom: nom.trim());
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

  Future<SousCategorie> creerSousCategorie(String categorieCode, String nom) async {
    if (nom.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('sous_categorie', CodeGenerator.sousCategorie);
      final s = SousCategorie(code: code, categorieCode: categorieCode, nom: nom.trim());
      await repo.insererSousCategorie(s);
      return s;
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

  /// Suppression refusée si la catégorie est système ou si des produits y sont rattachés.
  Future<void> supprimerCategorie(String code) async {
    if (code == CodeGenerator.systeme(CodeGenerator.categorie)) {
      throw const CatalogueException(ErreurCatalogue.categorieSysteme);
    }
    if (await _repo.nbProduitsCategorie(code) > 0) throw const CatalogueException(ErreurCatalogue.categorieUtilisee);
    await db.transaction((txn) async {
      await CatalogueRepository(txn).supprimerCategorie(code);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'categorie', entiteCode: code);
    });
  }

  Future<void> supprimerSousCategorie(String code) async {
    if (code == CodeGenerator.systeme(CodeGenerator.sousCategorie)) {
      throw const CatalogueException(ErreurCatalogue.categorieSysteme);
    }
    if (await _repo.nbProduitsSousCategorie(code) > 0) {
      throw const CatalogueException(ErreurCatalogue.categorieUtilisee);
    }
    await _repo.supprimerSousCategorie(code);
  }

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
  Future<Produit> creerProduit(Produit p, {double? margeDefautPct, bool genererCodeBarres = false}) async {
    final prepare = await _preparer(p, nouveau: true, margeDefautPct: margeDefautPct);
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('produit', CodeGenerator.produit);
      var produit = Produit(
        code: code,
        designation: prepare.designation,
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
        image: prepare.image,
      );
      if (genererCodeBarres && produit.codeBarres == null) {
        produit = produit.copyWith(codeBarres: await _genererCodeBarresInterne(repo));
      }
      await repo.insererProduit(produit);
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

  Future<Produit> modifierProduit(Produit p, {double? margeDefautPct}) async {
    final prepare = await _preparer(p, nouveau: false, margeDefautPct: margeDefautPct);
    await db.transaction((txn) async {
      await CatalogueRepository(txn).mettreAJourProduit(prepare);
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

  /// Génère et affecte un code-barres interne (CAISSEDZ + date) à un produit sans code.
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
      );
      await repo.insererPack(pack);
      return pack;
    });
  }

  Future<void> modifierPack(Pack p) async {
    if (p.lignes.isEmpty) throw const CatalogueException(ErreurCatalogue.lignesVides);
    await db.transaction((txn) => CatalogueRepository(txn).mettreAJourPack(p));
  }

  // ---------------- Remises ----------------
  Future<Remise> creerRemise(Remise r) async {
    if (r.designation.trim().isEmpty) throw const CatalogueException(ErreurCatalogue.designationVide);
    if (r.valeur <= 0 || (r.type == 'Pourcentage' && r.valeur > 100)) {
      throw const CatalogueException(ErreurCatalogue.prixInvalide);
    }
    return db.transaction((txn) async {
      final repo = CatalogueRepository(txn);
      final code = await repo.prochainCode('remise', CodeGenerator.remise);
      final remise = Remise(
        code: code,
        designation: r.designation.trim(),
        type: r.type,
        valeur: r.valeur,
        produitCode: r.produitCode,
        categorieCode: r.categorieCode,
        dateDebut: r.dateDebut,
        dateFin: r.dateFin,
        actif: r.actif,
      );
      await repo.insererRemise(remise);
      return remise;
    });
  }

  Future<void> modifierRemise(Remise r) => _repo.mettreAJourRemise(r);
  Future<void> supprimerRemise(String code) => _repo.supprimerRemise(code);

  /// Meilleure remise applicable à un produit à une date donnée (montant de remise sur [montant]).
  Future<double> remiseApplicable(Produit p, double montant, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    var meilleure = 0.0;
    for (final r in await _repo.remises()) {
      if (!r.estApplicable(d, produitCode: p.code, categorieCode: p.categorieCode)) continue;
      final m = CalculsPrix.remise(montant, type: r.type, valeur: r.valeur);
      if (m > meilleure) meilleure = m;
    }
    return meilleure;
  }
}
