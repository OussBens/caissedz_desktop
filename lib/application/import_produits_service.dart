import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/produit.dart';
import 'catalogue_service.dart';

/// Ligne lue dans le fichier Excel, avant import.
class LigneImport {
  const LigneImport({
    required this.numero,
    required this.designation,
    this.codeBarres,
    this.categorie,
    this.prixAchat,
    this.prixVente,
    this.erreur,
  });
  final int numero;
  final String designation;
  final String? codeBarres;
  final String? categorie;
  final double? prixAchat;
  final double? prixVente;
  final String? erreur;
  bool get valide => erreur == null;
}

class RapportImport {
  const RapportImport({required this.lignes, required this.importees, required this.ignorees});
  final List<LigneImport> lignes;
  final int importees;
  final int ignorees;
}

/// Import de produits depuis un classeur Excel (.xlsx).
///
/// Colonnes attendues (en-tête ligne 1, insensible à la casse) :
/// `designation` (obligatoire), `code_barres`, `categorie`, `prix_achat`, `prix_vente`.
/// Les catégories inconnues sont créées ; les codes-barres déjà utilisés sont ignorés.
class ImportProduitsService {
  const ImportProduitsService(this.db, {required this.catalogue, this.margeDefautPct});

  final Database db;
  final CatalogueService catalogue;
  final double? margeDefautPct;

  static const List<String> colonnes = ['designation', 'code_barres', 'categorie', 'prix_achat', 'prix_vente'];

  /// Lit et valide le classeur, sans rien écrire.
  Future<List<LigneImport>> analyser(Uint8List octets) async {
    final classeur = Excel.decodeBytes(octets);
    if (classeur.tables.isEmpty) return const [];
    final feuille = classeur.tables.values.first;
    if (feuille.maxRows < 2) return const [];
    final entetes = feuille.rows.first
        .map((c) => (c?.value?.toString() ?? '').trim().toLowerCase().replaceAll(' ', '_'))
        .toList();
    int? idx(String nom) {
      final i = entetes.indexOf(nom);
      return i < 0 ? null : i;
    }

    final iDes = idx('designation') ?? idx('désignation');
    if (iDes == null) throw const FormatException('Colonne « designation » absente');
    final iCb = idx('code_barres');
    final iCat = idx('categorie') ?? idx('catégorie');
    final iPa = idx('prix_achat');
    final iPv = idx('prix_vente');
    final repo = CatalogueRepository(db);
    final resultat = <LigneImport>[];
    final codesVus = <String>{};
    for (var n = 1; n < feuille.rows.length; n++) {
      final row = feuille.rows[n];
      String? cell(int? i) => (i == null || i >= row.length) ? null : row[i]?.value?.toString().trim();
      double? nombre(int? i) => double.tryParse((cell(i) ?? '').replaceAll(',', '.'));
      final designation = cell(iDes) ?? '';
      final cb = cell(iCb);
      final cbNet = (cb == null || cb.isEmpty) ? null : cb;
      String? erreur;
      if (designation.isEmpty) {
        erreur = 'designation_vide';
      } else if (cbNet != null && (codesVus.contains(cbNet) || !await repo.codeBarresDisponible(cbNet))) {
        erreur = 'code_barres_deja_utilise';
      } else if ((nombre(iPa) ?? 0) < 0 || (nombre(iPv) ?? 0) < 0) {
        erreur = 'prix_invalide';
      }
      if (cbNet != null) codesVus.add(cbNet);
      resultat.add(
        LigneImport(
          numero: n + 1,
          designation: designation,
          codeBarres: cbNet,
          categorie: cell(iCat),
          prixAchat: nombre(iPa),
          prixVente: nombre(iPv),
          erreur: erreur,
        ),
      );
    }
    return resultat;
  }

  /// Importe les lignes valides. Chaque produit est créé via [CatalogueService] ;
  /// l'ensemble est exécuté ligne à ligne (un échec ignore la ligne, le reste continue).
  Future<RapportImport> importer(List<LigneImport> lignes) async {
    final repo = CatalogueRepository(db);
    final categories = {for (final c in await repo.categories()) c.nom.toLowerCase(): c};
    var importees = 0;
    var ignorees = 0;
    for (final l in lignes) {
      if (!l.valide) {
        ignorees++;
        continue;
      }
      var categorieCode = CodeGenerator.systeme(CodeGenerator.categorie);
      var sousCategorieCode = CodeGenerator.systeme(CodeGenerator.sousCategorie);
      final nomCat = l.categorie?.trim();
      if (nomCat != null && nomCat.isNotEmpty) {
        var cat = categories[nomCat.toLowerCase()];
        cat ??= categories[nomCat.toLowerCase()] = await catalogue.creerCategorie(nomCat);
        categorieCode = cat.code;
        sousCategorieCode = (await repo.sousCategories(cat.code)).first.code;
      }
      try {
        await catalogue.creerProduit(
          Produit(
            code: '',
            designation: l.designation,
            codeBarres: l.codeBarres,
            categorieCode: categorieCode,
            sousCategorieCode: sousCategorieCode,
            prixAchat: l.prixAchat ?? 0,
            prixVente: l.prixVente ?? 0,
          ),
          margeDefautPct: margeDefautPct,
        );
        importees++;
      } on CatalogueException {
        ignorees++;
      }
    }
    return RapportImport(lignes: lignes, importees: importees, ignorees: ignorees);
  }

  /// Modèle de classeur vide avec les en-têtes attendus.
  static Uint8List modele() {
    final classeur = Excel.createExcel();
    final feuille = classeur[classeur.getDefaultSheet()!];
    feuille.appendRow([for (final c in colonnes) TextCellValue(c)]);
    feuille.appendRow([
      TextCellValue('Exemple : Lait 1 L'),
      TextCellValue('6130000000015'),
      TextCellValue('Boissons'),
      const DoubleCellValue(80),
      const DoubleCellValue(100),
    ]);
    return Uint8List.fromList(classeur.encode()!);
  }
}
