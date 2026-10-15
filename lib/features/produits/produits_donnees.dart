import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../domain/models/produit.dart';
import '../stock/stock_providers.dart';
import 'produits_providers.dart';

/// Stock par produit sur les magasins consultables par l'utilisateur (§9.4 : « Quantité affichée = stock
/// des magasins consultables ») ; tous les magasins si aucun n'est affecté.
final stocksProduitsProvider = FutureProvider<Map<String, double>>((ref) async {
  ref.watch(stockVersionProvider);
  final repo = ref.watch(stockRepositoryProvider);
  final mes = await ref.watch(mesMagasinsProvider.future);
  final stocks = <String, double>{};
  if (mes.isEmpty) {
    for (final n in await repo.niveaux()) {
      stocks[n.produitCode] = n.quantite;
    }
  } else {
    for (final m in mes) {
      for (final n in await repo.niveaux(magasinCode: m)) {
        stocks[n.produitCode] = (stocks[n.produitCode] ?? 0) + n.quantite;
      }
    }
  }
  return stocks;
});

/// Nombre de codes-barres secondaires par produit.
final nbCodesSecondairesProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).compterParProduit('produit_code_detail');
});

/// Nombre de photos par produit.
final nbPhotosProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).compterParProduit('produit_photo');
});

/// Dossier des photos produit, à côté de la base.
final dossierPhotosProvider = Provider<String>((ref) {
  final chemin = ref.watch(appDatabaseProvider).chemin;
  final base = chemin.startsWith(':') || chemin.isEmpty ? Directory.systemTemp.path : p.dirname(chemin);
  return p.join(base, 'photos');
});

/// Seuil d'alerte effectif d'un produit (propre, sinon global).
int seuilDe(Produit produit, int seuilGlobal) => produit.seuilStock ?? seuilGlobal;

/// État de stock affiché (`StatusBadge`) : `inactif`, `actif` (service ou stock suffisant), `rupture`, `seuil`.
String etatStockProduit(Produit produit, double stock, int seuilGlobal) {
  if (!produit.actif) return 'inactif';
  if (produit.service) return 'actif';
  if (stock <= 0) return 'rupture';
  if (stock <= seuilDe(produit, seuilGlobal)) return 'seuil';
  return 'actif';
}

/// Taux de marge en % sur le prix d'achat.
double margeProduit(Produit produit) =>
    produit.prixAchat <= 0 ? 0 : (produit.prixVente - produit.prixAchat) / produit.prixAchat * 100;

/// Copie une photo choisie dans le dossier des photos et renvoie son nouveau chemin.
Future<String> importerPhoto(String dossier, String source) async {
  await Directory(dossier).create(recursive: true);
  final nom = '${DateTime.now().microsecondsSinceEpoch}${p.extension(source).toLowerCase()}';
  final cible = p.join(dossier, nom);
  await File(source).copy(cible);
  return cible;
}
