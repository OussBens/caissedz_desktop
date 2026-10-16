import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Scellement SHA-256 chaîné des documents (tickets, clôtures) — §12.
///
/// `hash = SHA-256(hash_precedent | canonique(document))`. Le premier document
/// de la chaîne utilise [genese] comme hash précédent. La vérification rejoue
/// la chaîne : toute altération d'un document ou de l'ordre est détectée.
class Scellement {
  const Scellement._();

  static const String genese = '0000000000000000000000000000000000000000000000000000000000000000';

  /// Forme canonique : champs triés, nombres à 2 décimales, listes ordonnées.
  static String canonique(Map<String, Object?> doc) => jsonEncode(_normaliser(doc));

  static Object? _normaliser(Object? v) {
    if (v is Map) {
      final cles = v.keys.map((k) => k.toString()).toList()..sort();
      return {for (final k in cles) k: _normaliser(v[k])};
    }
    if (v is List) return v.map(_normaliser).toList();
    if (v is num) return v.toStringAsFixed(2);
    if (v is DateTime) return v.toUtc().toIso8601String();
    return v;
  }

  static String hacher(Map<String, Object?> doc, String hashPrecedent) =>
      sha256.convert(utf8.encode('$hashPrecedent|${canonique(doc)}')).toString();

  /// Vérifie une chaîne de documents `(doc, hashPrecedent, hash)` dans l'ordre.
  /// Retourne l'index du premier document invalide, ou `null` si tout est valide. La chaîne part de la
  /// [genese], ou du hash précédent du premier document si [depuisPremier] (extrait d'une période).
  static int? verifier(
    List<({Map<String, Object?> doc, String hashPrecedent, String hash})> chaine, {
    bool depuisPremier = false,
  }) {
    var attendu = depuisPremier && chaine.isNotEmpty ? chaine.first.hashPrecedent : genese;
    for (var i = 0; i < chaine.length; i++) {
      final e = chaine[i];
      if (e.hashPrecedent != attendu) return i;
      if (hacher(e.doc, e.hashPrecedent) != e.hash) return i;
      attendu = e.hash;
    }
    return null;
  }
}
