import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/achat.dart';
import '../domain/models/document_commercial.dart';
import '../domain/models/vente.dart';

/// Lecture des documents commerciaux : devis / proforma / commandes clients, bons de livraison, commandes
/// fournisseurs. Les quantités livrées et reçues sont calculées (jamais stockées).
class DocumentsCommerciauxRepository {
  const DocumentsCommerciauxRepository(this.db);

  final DatabaseExecutor db;

  // ---- Documents clients ----

  Future<List<DocumentClient>> documentsClients({String? type, DateTime? debut, DateTime? fin}) async {
    final where = <String>[];
    final args = <Object?>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (debut != null) {
      where.add('date >= ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('date <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    final rows = await db.query(
      'document_client',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, ${CodeGenerator.ordreDecroissant}',
    );
    return [for (final r in rows) await _documentComplet(r)];
  }

  Future<DocumentClient?> documentClient(String code) async {
    final rows = await db.query('document_client', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : _documentComplet(rows.first);
  }

  Future<DocumentClient> _documentComplet(Map<String, Object?> r) async {
    final d = DocumentClient.depuisLigne(r);
    var lignes = [
      for (final l in await db.query(
        'document_client_ligne',
        where: 'document_code = ?',
        whereArgs: [d.code],
        orderBy: 'ordre',
      ))
        DocumentLigne.depuisLigne(l),
    ];
    if (!d.estCommande) return d.copyWith(lignes: lignes);
    final livre = await quantitesLivrees(d.code);
    lignes = [for (final l in lignes) l.copyWith(livre: livre[l.ordre] ?? 0)];
    final bl = await db.rawQuery(
      '''
      SELECT b.code FROM bon_livraison b JOIN vente v ON v.code = b.vente_code
      WHERE b.commande_code = ? AND v.statut <> ? ORDER BY ${CodeGenerator.ordreCroissant.replaceAll('code', 'b.code')}
      ''',
      [d.code, StatutsVente.annulee],
    );
    return d.copyWith(lignes: lignes, livraisons: [for (final b in bl) b['code']! as String]);
  }

  /// Quantité livrée par ligne de commande (bons de livraison dont la vente n'est pas annulée).
  Future<Map<int, double>> quantitesLivrees(String commandeCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT l.ordre_commande o, SUM(l.quantite) q FROM bon_livraison_ligne l
      JOIN bon_livraison b ON b.code = l.livraison_code JOIN vente v ON v.code = b.vente_code
      WHERE b.commande_code = ? AND v.statut <> ? AND l.ordre_commande IS NOT NULL GROUP BY l.ordre_commande
      ''',
      [commandeCode, StatutsVente.annulee],
    );
    return {for (final r in rows) r['o']! as int: (r['q']! as num).toDouble()};
  }

  // ---- Bons de livraison ----

  static const String _selectLivraison = '''
    SELECT b.*, v.statut vente_statut, v.total_net vente_total FROM bon_livraison b JOIN vente v ON v.code = b.vente_code
  ''';

  Future<List<BonLivraison>> livraisons({DateTime? debut, DateTime? fin, String? commandeCode}) async {
    final where = <String>[];
    final args = <Object?>[];
    if (debut != null) {
      where.add('b.date >= ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('b.date <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    if (commandeCode != null) {
      where.add('b.commande_code = ?');
      args.add(commandeCode);
    }
    final rows = await db.rawQuery(
      '$_selectLivraison ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'} '
      'ORDER BY b.date DESC, length(b.code) DESC, b.code DESC',
      args,
    );
    return [for (final r in rows) await _livraisonComplete(r)];
  }

  Future<BonLivraison?> livraison(String code) async {
    final rows = await db.rawQuery('$_selectLivraison WHERE b.code = ?', [code]);
    return rows.isEmpty ? null : _livraisonComplete(rows.first);
  }

  /// Bon de livraison actif d'une vente, s'il existe.
  Future<BonLivraison?> livraisonDeVente(String venteCode) async {
    final rows = await db.rawQuery('$_selectLivraison WHERE b.vente_code = ?', [venteCode]);
    return rows.isEmpty ? null : _livraisonComplete(rows.first);
  }

  Future<BonLivraison> _livraisonComplete(Map<String, Object?> r) async => BonLivraison.depuisLigne(r, [
    for (final l in await db.query(
      'bon_livraison_ligne',
      where: 'livraison_code = ?',
      whereArgs: [r['code']],
      orderBy: 'ordre',
    ))
      BonLivraisonLigne.depuisLigne(l),
  ]);

  // ---- Commandes fournisseurs ----

  Future<List<CommandeFournisseur>> commandesFournisseurs({DateTime? debut, DateTime? fin}) async {
    final where = <String>[];
    final args = <Object?>[];
    if (debut != null) {
      where.add('date >= ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('date <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    final rows = await db.query(
      'commande_fournisseur',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, ${CodeGenerator.ordreDecroissant}',
    );
    return [for (final r in rows) await _commandeComplete(r)];
  }

  Future<CommandeFournisseur?> commandeFournisseur(String code) async {
    final rows = await db.query('commande_fournisseur', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : _commandeComplete(rows.first);
  }

  /// Quantités reçues réparties sur les lignes, dans l'ordre (un produit commandé sur deux lignes remplit
  /// la première avant la seconde) ; entrées annulées exclues.
  Future<CommandeFournisseur> _commandeComplete(Map<String, Object?> r) async {
    final c = CommandeFournisseur.depuisLigne(r);
    final lignes = [
      for (final l in await db.query(
        'commande_fournisseur_ligne',
        where: 'commande_code = ?',
        whereArgs: [c.code],
        orderBy: 'ordre',
      ))
        CommandeFournisseurLigne.depuisLigne(l),
    ];
    final recus = await db.rawQuery(
      '''
      SELECT l.produit_code p, SUM(l.quantite) q FROM achat_ligne l JOIN achat a ON a.code = l.achat_code
      WHERE a.commande_code = ? AND a.statut <> ? GROUP BY l.produit_code
      ''',
      [c.code, StatutsAchat.annule],
    );
    final dispo = {for (final x in recus) x['p']! as String: (x['q']! as num).toDouble()};
    final reparties = <CommandeFournisseurLigne>[];
    for (final (i, l) in lignes.indexed) {
      final d = dispo[l.produitCode] ?? 0;
      // La dernière ligne du produit prend aussi un éventuel excédent reçu.
      final dernier = !lignes.skip(i + 1).any((x) => x.produitCode == l.produitCode);
      final pris = dernier ? d : (d < l.quantite ? d : l.quantite);
      dispo[l.produitCode] = d - pris;
      reparties.add(l.copyWith(recu: pris));
    }
    final entrees = await db.query(
      'achat',
      columns: ['code'],
      where: 'commande_code = ? AND statut <> ?',
      whereArgs: [c.code, StatutsAchat.annule],
      orderBy: CodeGenerator.ordreCroissant,
    );
    return c.copyWith(lignes: reparties, receptions: [for (final e in entrees) e['code']! as String]);
  }
}
