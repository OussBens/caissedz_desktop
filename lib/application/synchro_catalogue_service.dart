import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';

import '../data/archivage_repository.dart';
import '../data/catalogue_repository.dart';
import '../domain/archivage.dart';
import '../domain/models/produit.dart';

/// Résultat d'une synchronisation du catalogue avec le serveur CaisseDZ.
class ResultatSynchro {
  const ResultatSynchro({required this.envoyes, required this.recus, required this.erreur});
  final int envoyes;
  final int recus;
  final String? erreur;
  bool get ok => erreur == null;
}

/// Synchronisation du catalogue local avec le serveur CaisseDZ.
///
/// ⚠️ PROVISOIRE : protocole hypothétique `POST <base>/catalogue/synchro`
/// avec `{ produits: [...] }` → `{ produits: [...] }` (fiches enrichies).
/// Inactive tant que l'URL du serveur n'est pas renseignée (Paramètres).
class SynchroCatalogueService {
  const SynchroCatalogueService(this.db, {required this.client, required this.baseUrl, this.cleApi});

  final Database db;
  final http.Client client;
  final String baseUrl;
  final String? cleApi;

  bool get configuree => baseUrl.isNotEmpty;

  Future<ResultatSynchro> synchroniser() async {
    if (!configuree) return const ResultatSynchro(envoyes: 0, recus: 0, erreur: 'non_configuree');
    final repo = CatalogueRepository(db);
    final produits = await repo.produits();
    final corps = jsonEncode({
      'produits': [
        for (final p in produits)
          {'code': p.code, 'designation': p.designation, 'code_barres': p.codeBarres, 'prix_vente': p.prixVente},
      ],
    });
    try {
      final r = await client
          .post(
            Uri.parse('$baseUrl/catalogue/synchro'),
            headers: {'Content-Type': 'application/json', if (cleApi != null) 'Authorization': 'Bearer $cleApi'},
            body: corps,
          )
          .timeout(const Duration(seconds: 20));
      if (r.statusCode != 200) {
        return ResultatSynchro(envoyes: produits.length, recus: 0, erreur: 'http_${r.statusCode}');
      }
      final j = jsonDecode(r.body) as Map;
      final recus = (j['produits'] as List?) ?? const [];
      var maj = 0;
      await db.transaction((txn) async {
        final r2 = CatalogueRepository(txn);
        for (final e in recus.cast<Map>()) {
          final cb = e['code_barres']?.toString();
          if (cb == null) continue;
          final local = await r2.produitParCodeBarres(cb);
          if (local == null) continue;
          final designation = e['designation']?.toString();
          final image = e['image']?.toString();
          Produit p = local;
          // Nom corrigé par le catalogue, sauf s'il est déjà pris par un autre produit (noms uniques).
          if (designation != null &&
              designation.isNotEmpty &&
              await ArchivageRepository(txn).ficheDuNom(EntiteArchivable.produit, designation, sauf: local.code) ==
                  null) {
            p = p.copyWith(designation: designation);
          }
          if (image != null) p = p.copyWith(image: image);
          await r2.mettreAJourProduit(p);
          maj++;
        }
      });
      return ResultatSynchro(envoyes: produits.length, recus: maj, erreur: null);
    } on Object catch (e) {
      return ResultatSynchro(envoyes: 0, recus: 0, erreur: e.toString());
    }
  }
}
