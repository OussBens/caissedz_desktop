import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/document_commercial.dart';
import '../domain/models/retour.dart';

/// Un résultat de la recherche globale : la fiche ou le document trouvé et le module qui l'affiche.
class ResultatRecherche {
  const ResultatRecherche({
    required this.moduleId,
    required this.type,
    required this.code,
    required this.titre,
    this.detail = '',
    this.date,
    this.onglet,
  });

  /// Module qui affiche le résultat (routes de `Modules`).
  final String moduleId;

  /// Nature du résultat (valeur de [TypesRecherche]).
  final String type;
  final String code;
  final String titre;
  final String detail;
  final DateTime? date;

  /// Onglet du module à ouvrir (documents, factures, retours fournisseurs).
  final int? onglet;
}

/// Natures de résultats de la recherche globale, dans l'ordre d'affichage.
abstract final class TypesRecherche {
  static const produit = 'produit';
  static const client = 'client';
  static const fournisseur = 'fournisseur';
  static const vente = 'vente';
  static const facture = 'facture';
  static const document = 'document';
  static const livraison = 'livraison';
  static const entree = 'entree';
  static const commandeFournisseur = 'commande_fournisseur';
  static const retour = 'retour';
  static const versement = 'versement';
  static const sortie = 'sortie';
  static const transfert = 'transfert';
  static const besoin = 'besoin';
  static const tous = [
    produit,
    client,
    fournisseur,
    vente,
    facture,
    document,
    livraison,
    entree,
    commandeFournisseur,
    retour,
    versement,
    sortie,
    transfert,
    besoin,
  ];
}

/// Recherche dans tout le système (codes, noms, téléphones, codes-barres, références) : quelques résultats par
/// nature, les plus récents d'abord. Lecture seule.
class RechercheGlobaleRepository {
  const RechercheGlobaleRepository(this.db);

  final DatabaseExecutor db;

  Future<List<ResultatRecherche>> rechercher(String texte, {int parType = 5}) async {
    final t = texte.trim();
    if (t.length < 2) return const [];
    final motif = '%${t.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    String like(List<String> colonnes) => '(${colonnes.map((c) => "$c LIKE ? ESCAPE '\\'").join(' OR ')})';
    List<Object?> args(int n) => List.filled(n, motif);
    DateTime? date(Object? v) => v == null ? null : DateTime.tryParse(v as String);

    Future<List<Map<String, Object?>>> q(String sql, int n) => db.rawQuery('$sql LIMIT $parType', args(n));

    final resultats = <ResultatRecherche>[];
    for (final r in await q(
      'SELECT code, designation, code_barres FROM produit '
      'WHERE ${like(['code', 'designation', 'code_barres', 'marque'])} ORDER BY designation',
      4,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'produits',
          type: TypesRecherche.produit,
          code: r['code']! as String,
          titre: r['designation']! as String,
          detail: (r['code_barres'] as String?) ?? '',
        ),
      );
    }
    for (final (table, module, type) in [
      ('client', 'clients', TypesRecherche.client),
      ('fournisseur', 'fournisseurs', TypesRecherche.fournisseur),
    ]) {
      for (final r in await q(
        'SELECT code, nom, telephone FROM $table WHERE systeme = 0 AND ${like(['code', 'nom', 'telephone', 'nif'])} '
        'ORDER BY nom',
        4,
      )) {
        resultats.add(
          ResultatRecherche(
            moduleId: module,
            type: type,
            code: r['code']! as String,
            titre: r['nom']! as String,
            detail: (r['telephone'] as String?) ?? '',
          ),
        );
      }
    }
    for (final r in await q(
      'SELECT v.code, v.date, v.total_net, v.statut, c.nom FROM vente v LEFT JOIN client c ON c.code = v.client_code '
      'WHERE ${like(['v.code', 'c.nom'])} ORDER BY v.date DESC',
      2,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'ventes',
          type: TypesRecherche.vente,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: '${(r['total_net']! as num).toStringAsFixed(2)} · ${r['statut']}',
          date: date(r['date']),
        ),
      );
    }
    for (final r in await q(
      'SELECT f.code, f.date, f.vente_code, f.net_a_payer, c.nom FROM facture f '
      'LEFT JOIN client c ON c.code = f.client_code WHERE ${like(['f.code', 'f.vente_code', 'c.nom'])} '
      'ORDER BY f.date DESC',
      3,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'ventes',
          type: TypesRecherche.facture,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: '${r['vente_code']} · ${(r['net_a_payer']! as num).toStringAsFixed(2)}',
          date: date(r['date']),
          onglet: 1,
        ),
      );
    }
    for (final r in await q(
      'SELECT d.code, d.date, d.type, c.nom FROM document_client d LEFT JOIN client c ON c.code = d.client_code '
      'WHERE ${like(['d.code', 'c.nom'])} ORDER BY d.date DESC',
      2,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'documents',
          type: TypesRecherche.document,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: r['type']! as String,
          date: date(r['date']),
          onglet: switch (r['type']) {
            TypesDocumentClient.proforma => 1,
            TypesDocumentClient.commande => 2,
            _ => 0,
          },
        ),
      );
    }
    for (final r in await q(
      'SELECT b.code, b.date, b.vente_code, c.nom FROM bon_livraison b LEFT JOIN client c ON c.code = b.client_code '
      'WHERE ${like(['b.code', 'b.vente_code', 'b.commande_code', 'c.nom'])} ORDER BY b.date DESC',
      4,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'documents',
          type: TypesRecherche.livraison,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: r['vente_code']! as String,
          date: date(r['date']),
          onglet: 3,
        ),
      );
    }
    for (final (table, module, type, extra) in [
      ('achat', 'entrees', TypesRecherche.entree, 'a.reference'),
      ('commande_fournisseur', 'commandes_fournisseurs', TypesRecherche.commandeFournisseur, 'a.code'),
      ('besoin', 'besoins', TypesRecherche.besoin, 'a.code'),
    ]) {
      for (final r in await q(
        'SELECT a.code, a.date, $extra extra, f.nom FROM $table a LEFT JOIN fournisseur f ON f.code = a.fournisseur_code '
        'WHERE ${like(['a.code', extra, 'f.nom'])} ORDER BY a.date DESC',
        3,
      )) {
        resultats.add(
          ResultatRecherche(
            moduleId: module,
            type: type,
            code: r['code']! as String,
            titre: (r['nom'] as String?) ?? '',
            detail: r['extra'] == r['code'] ? '' : (r['extra'] as String?) ?? '',
            date: date(r['date']),
          ),
        );
      }
    }
    for (final r in await q(
      'SELECT r.code, r.date, r.type, r.document_code, COALESCE(c.nom, f.nom) nom FROM retour r '
      'LEFT JOIN client c ON c.code = r.client_code LEFT JOIN fournisseur f ON f.code = r.fournisseur_code '
      'WHERE ${like(['r.code', 'r.document_code', 'c.nom', 'f.nom'])} ORDER BY r.date DESC',
      4,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'retours',
          type: TypesRecherche.retour,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: r['document_code']! as String,
          date: date(r['date']),
          onglet: r['type'] == TypesTiers.fournisseur ? 1 : 0,
        ),
      );
    }
    for (final r in await q(
      'SELECT v.code, v.date, v.montant, v.tiers_type, COALESCE(c.nom, f.nom) nom FROM versement v '
      "LEFT JOIN client c ON v.tiers_type = '${TypesTiers.client}' AND c.code = v.tiers_code "
      "LEFT JOIN fournisseur f ON v.tiers_type = '${TypesTiers.fournisseur}' AND f.code = v.tiers_code "
      'WHERE ${like(['v.code', 'v.reference', 'c.nom', 'f.nom'])} ORDER BY v.date DESC',
      4,
    )) {
      resultats.add(
        ResultatRecherche(
          moduleId: 'versements',
          type: TypesRecherche.versement,
          code: r['code']! as String,
          titre: (r['nom'] as String?) ?? '',
          detail: (r['montant']! as num).toStringAsFixed(2),
          date: date(r['date']),
        ),
      );
    }
    for (final (table, module, type, colonne) in [
      ('sortie_stock', 'sorties', TypesRecherche.sortie, 'motif'),
      ('transfert_stock', 'transferts', TypesRecherche.transfert, 'magasin_destination'),
    ]) {
      for (final r in await q(
        'SELECT code, date, $colonne extra FROM $table WHERE ${like(['code', colonne])} ORDER BY date DESC',
        2,
      )) {
        resultats.add(
          ResultatRecherche(
            moduleId: module,
            type: type,
            code: r['code']! as String,
            titre: (r['extra'] as String?) ?? '',
            date: date(r['date']),
          ),
        );
      }
    }
    return resultats;
  }
}
