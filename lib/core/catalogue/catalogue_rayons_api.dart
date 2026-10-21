import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/rayon_catalogue.dart';

/// Pourquoi le catalogue n'a pas répondu.
enum ErreurCatalogueRayons {
  /// Pas d'internet, serveur injoignable ou trop lent.
  reseau,

  /// Réponse inattendue du serveur.
  serveur,
}

class CatalogueRayonsException implements Exception {
  const CatalogueRayonsException(this.erreur, [this.message]);
  final ErreurCatalogueRayons erreur;
  final String? message;
  @override
  String toString() => 'CatalogueRayonsException($erreur${message == null ? '' : ', $message'})';
}

/// Les rayons du catalogue BENS (catalog-api.bensds.com, lecture publique) :
/// `GET /rayons` et `GET /rayons/{code}/products?page=&limit=[&depuis=AAAA-MM-JJ]` (500 produits par page au
/// plus ; `depuis` : seulement ceux devenus tendance depuis ce jour).
class CatalogueRayonsApi {
  const CatalogueRayonsApi({required this.client, this.baseUrl = urlParDefaut});

  static const String urlParDefaut = 'https://catalog-api.bensds.com';
  static const int parPage = 500;
  static const Duration _delai = Duration(seconds: 30);

  final http.Client client;
  final String baseUrl;

  Future<Map<String, Object?>> _get(String chemin) async {
    final http.Response r;
    try {
      r = await client.get(Uri.parse('$baseUrl$chemin'), headers: const {'Accept': 'application/json'}).timeout(_delai);
    } on Object catch (e) {
      throw CatalogueRayonsException(ErreurCatalogueRayons.reseau, '$e');
    }
    try {
      final j = (jsonDecode(utf8.decode(r.bodyBytes)) as Map).cast<String, Object?>();
      if (r.statusCode == 200 && j['success'] == true && j['data'] is Map) {
        return (j['data']! as Map).cast<String, Object?>();
      }
      throw CatalogueRayonsException(ErreurCatalogueRayons.serveur, 'http ${r.statusCode} ${j['error'] ?? ''}');
    } on CatalogueRayonsException {
      rethrow;
    } on Object catch (e) {
      throw CatalogueRayonsException(ErreurCatalogueRayons.serveur, 'http ${r.statusCode} $e');
    }
  }

  /// Les rayons actifs, dans leur ordre.
  Future<List<RayonCatalogue>> rayons() async {
    final d = await _get('/rayons');
    return [for (final r in d['rayons'] as List? ?? const []) RayonCatalogue.depuisJson((r as Map).cast())];
  }

  /// Une page des produits proposés par le rayon [code] (les mieux classés d'abord) et le nombre de pages ;
  /// [depuis] : seulement ceux devenus tendance depuis ce jour.
  Future<({List<ProduitCatalogue> produits, int pages})> produits(String code, {int page = 1, DateTime? depuis}) async {
    final jour = depuis == null ? '' : '&depuis=${depuis.toIso8601String().substring(0, 10)}';
    final d = await _get('/rayons/${Uri.encodeComponent(code)}/products?page=$page&limit=$parPage$jour');
    return (
      produits: [for (final p in d['products'] as List? ?? const []) ProduitCatalogue.depuisJson((p as Map).cast())],
      pages: (d['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}
