import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fiche produit renvoyée par une source du catalogue IA.
class FicheProduitIa {
  const FicheProduitIa({
    required this.codeBarres,
    required this.designation,
    this.marque,
    this.categorie,
    this.image,
    this.prixVente,
    required this.source,
  });
  final String codeBarres;
  final String designation;
  final String? marque;
  final String? categorie;
  final String? image;
  final double? prixVente;
  final String source;
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
      'fields': 'product_name,product_name_fr,brands,categories,image_front_url',
    });
    final r = await client.get(uri, headers: {'User-Agent': 'CaisseDZ Desktop'}).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map || j['status'] != 1) return null;
    final p = j['product'] as Map;
    final nom = (p['product_name_fr'] ?? p['product_name'] ?? '').toString().trim();
    if (nom.isEmpty) return null;
    return FicheProduitIa(
      codeBarres: codeBarres,
      designation: nom,
      marque: p['brands']?.toString(),
      categorie: (p['categories']?.toString() ?? '').split(',').last.trim().isEmpty
          ? null
          : (p['categories'].toString()).split(',').last.trim(),
      image: p['image_front_url']?.toString(),
      source: this.nom,
    );
  }
}

/// Cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty Facts : première fiche trouvée.
class CatalogueIaService {
  const CatalogueIaService(this.sources);

  final List<SourceCatalogue> sources;

  factory CatalogueIaService.parDefaut(
    http.Client client, {
    String urlCaisseDz = '',
    String urlMantouj = '',
    String? cleApi,
  }) => CatalogueIaService([
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
