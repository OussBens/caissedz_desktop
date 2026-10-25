import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/quantite_produit.dart';

/// Fiche produit renvoyée par une source du catalogue IA.
class FicheProduitIa {
  const FicheProduitIa({
    required this.codeBarres,
    required this.designation,
    this.designationAr,
    this.quantite,
    this.typeQuantite,
    this.marque,
    this.categorie,
    this.image,
    this.prixVente,
    required this.source,
    this.aConfirmer = false,
    this.confirmation,
    this.seuilConfirmation,
  });
  final String codeBarres;
  final String designation;

  /// Nom arabe (catalogue BENS), s'il est connu.
  final String? designationAr;

  /// Contenance ou poids (« 500 ml », « 1 kg »), séparé du nom ([QuantiteProduit]).
  final String? quantite;

  /// Type de [quantite] (« Contenance », « Poids »), `null` si elle n'a pas d'unité.
  final String? typeQuantite;
  final String? marque;
  final String? categorie;
  final String? image;
  final double? prixVente;
  final String source;

  /// Produit ajouté au catalogue BENS par une boutique, pas encore confirmé par les autres : la caisse demande
  /// « est-ce bien ce produit ? » ([confirmation] sur [seuilConfirmation]).
  final bool aConfirmer;
  final int? confirmation;
  final int? seuilConfirmation;
}

/// Une source de la cascade.
abstract class SourceCatalogue {
  String get nom;
  Future<FicheProduitIa?> rechercher(String codeBarres);
}

/// Source HTTP JSON générique (CaisseDZ, Mantouj) : `GET <base>/<ean>` → JSON.
///
/// ⚠️ PROVISOIRE : les URL et formats exacts des API CaisseDZ et Mantouj sont
/// inconnus ; la source est inactive tant que [baseUrl] est vide.
class SourceHttpJson implements SourceCatalogue {
  const SourceHttpJson({required this.nom, required this.baseUrl, required this.client, this.cleApi});
  @override
  final String nom;
  final String baseUrl;
  final http.Client client;
  final String? cleApi;

  @override
  Future<FicheProduitIa?> rechercher(String codeBarres) async {
    if (baseUrl.isEmpty) return null;
    final r = await client
        .get(Uri.parse('$baseUrl/$codeBarres'), headers: {if (cleApi != null) 'Authorization': 'Bearer $cleApi'})
        .timeout(const Duration(seconds: 6));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map || (j['designation'] ?? j['nom'] ?? j['name']) == null) return null;
    return FicheProduitIa(
      codeBarres: codeBarres,
      designation: (j['designation'] ?? j['nom'] ?? j['name']).toString(),
      marque: j['marque']?.toString() ?? j['brand']?.toString(),
      categorie: j['categorie']?.toString() ?? j['category']?.toString(),
      image: j['image']?.toString(),
      prixVente: (j['prix_vente'] as num?)?.toDouble(),
      source: nom,
    );
  }
}

/// Catalogue BENS (catalog-api.bensds.com, `GET /products/barcode/<ean>`, lecture publique) : nom, nom arabe,
/// quantité, marque, photo. Le nom du catalogue contient souvent la quantité (« Eau Hayat 50cl ») : la fiche
/// garde le nom seul, la quantité vient à part (`taille` du catalogue, sinon celle lue dans le nom). Chaque recherche fait monter le produit dans le classement de son rayon.
class SourceBens implements SourceCatalogue {
  const SourceBens({required this.client, this.baseUrl = urlParDefaut, this.delai = const Duration(seconds: 5)});

  static const String nomSource = 'Catalogue BENS';
  static const String urlParDefaut = 'https://catalog-api.bensds.com';

  @override
  String get nom => nomSource;
  final http.Client client;
  final String baseUrl;
  final Duration delai;

  @override
  Future<FicheProduitIa?> rechercher(String codeBarres) async {
    if (!RegExp(r'^\d{6,14}$').hasMatch(codeBarres)) return null;
    final r = await client
        .get(Uri.parse('$baseUrl/products/barcode/$codeBarres'), headers: const {'Accept': 'application/json'})
        .timeout(delai);
    if (r.statusCode != 200) return null;
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    if (j is! Map || j['success'] != true || j['data'] is! Map) return null;
    final p = j['data'] as Map;
    String? texte(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
    final nom = texte(p['nom']);
    if (nom == null) return null;
    final s = QuantiteProduit.separer(nom, quantite: texte(p['taille']));
    // Catégorie du catalogue (« Beverages, Sodas ») : la plus précise, la dernière.
    final categorie = texte(texte(p['category'])?.split(',').last);
    return FicheProduitIa(
      codeBarres: codeBarres,
      designation: s.nom,
      designationAr: texte(p['nom_ar']),
      quantite: s.quantite,
      typeQuantite: s.type,
      marque: texte(p['brand']),
      categorie: categorie == 'Sans Categorie' ? null : categorie,
      image: texte(p['photo']),
      source: nomSource,
      aConfirmer: p['a_confirmer'] == true || p['a_confirmer'] == 1,
      confirmation: (p['confirmation'] as num?)?.toInt(),
      seuilConfirmation: (p['confirmation_seuil'] as num?)?.toInt(),
    );
  }
}

/// Open Food Facts / Open Beauty Facts (API v2 publique).
class SourceOpenFacts implements SourceCatalogue {
  const SourceOpenFacts({required this.nom, required this.hote, required this.client});
  @override
  final String nom;
  final String hote;
  final http.Client client;

  @override
  Future<FicheProduitIa?> rechercher(String codeBarres) async {
    final uri = Uri.https(hote, '/api/v2/product/$codeBarres.json', {
      'fields': 'product_name,product_name_fr,quantity,brands,categories,image_front_url',
    });
    final r = await client.get(uri, headers: {'User-Agent': 'CaisseDZ Desktop'}).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map || j['status'] != 1) return null;
    final p = j['product'] as Map;
    final nom = (p['product_name_fr'] ?? p['product_name'] ?? '').toString().trim();
    if (nom.isEmpty) return null;
    final s = QuantiteProduit.separer(nom, quantite: p['quantity']?.toString());
    return FicheProduitIa(
      codeBarres: codeBarres,
      designation: s.nom,
      quantite: s.quantite,
      typeQuantite: s.type,
      marque: p['brands']?.toString(),
      categorie: (p['categories']?.toString() ?? '').split(',').last.trim().isEmpty
          ? null
          : (p['categories'].toString()).split(',').last.trim(),
      image: p['image_front_url']?.toString(),
      source: this.nom,
    );
  }
}

/// Cascade catalogue BENS → CaisseDZ → Mantouj → Open Food Facts → Open Beauty Facts : première fiche trouvée.
class CatalogueIaService {
  const CatalogueIaService(this.sources);

  final List<SourceCatalogue> sources;

  factory CatalogueIaService.parDefaut(
    http.Client client, {
    String urlCaisseDz = '',
    String urlMantouj = '',
    String? cleApi,
  }) => CatalogueIaService([
    SourceBens(client: client),
    SourceHttpJson(nom: 'CaisseDZ', baseUrl: urlCaisseDz, client: client, cleApi: cleApi),
    SourceHttpJson(nom: 'Mantouj', baseUrl: urlMantouj, client: client),
    SourceOpenFacts(nom: 'Open Food Facts', hote: 'world.openfoodfacts.org', client: client),
    SourceOpenFacts(nom: 'Open Beauty Facts', hote: 'world.openbeautyfacts.org', client: client),
  ]);

  /// Interroge les sources dans l'ordre ; une source en erreur est ignorée.
  Future<FicheProduitIa?> rechercher(String codeBarres) async {
    for (final s in sources) {
      try {
        final f = await s.rechercher(codeBarres.trim());
        if (f != null) return f;
      } on Object {
        continue;
      }
    }
    return null;
  }
}
