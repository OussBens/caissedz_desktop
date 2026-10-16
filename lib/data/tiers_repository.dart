import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/retour.dart';
import '../domain/models/tiers.dart';

/// Accès SQL aux fournisseurs, retours, versements et imputations.
class TiersRepository {
  const TiersRepository(this.db);

  final DatabaseExecutor db;

  Future<String> prochainCode(String table, String prefixe) async {
    final rows = await db.query(
      table,
      columns: ['code'],
      where: 'code LIKE ?',
      whereArgs: ['$prefixe%'],
      orderBy: CodeGenerator.ordreDecroissant,
      limit: 1,
    );
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  // ---- Fournisseurs ----
  Future<List<Fournisseur>> fournisseurs({String? recherche}) async {
    final r = recherche?.trim();
    final rows = await db.query(
      'fournisseur',
      where: r == null || r.isEmpty ? null : '(nom LIKE ? OR code LIKE ? OR telephone LIKE ?)',
      whereArgs: r == null || r.isEmpty ? null : ['%$r%', '%$r%', '%$r%'],
      orderBy: 'code',
    );
    return rows.map(Fournisseur.depuisLigne).toList();
  }

  Future<Fournisseur?> fournisseur(String code) async {
    final rows = await db.query('fournisseur', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Fournisseur.depuisLigne(rows.first);
  }

  Future<void> insererFournisseur(Fournisseur f) => db.insert('fournisseur', f.versLigne());
  Future<void> mettreAJourFournisseur(Fournisseur f) => db.update(
    'fournisseur',
    f.versLigne()
      ..remove('code')
      ..remove('systeme'),
    where: 'code = ?',
    whereArgs: [f.code],
  );

  // ---- Retours ----
  Future<void> insererRetour(Retour r) async {
    await db.insert('retour', r.versLigne());
    await _insererLignesRetour(r);
  }

  Future<void> _insererLignesRetour(Retour r) async {
    for (final (i, l) in r.lignes.indexed) {
      await db.insert('retour_ligne', {
        'retour_code': r.code,
        'ordre': i,
        'produit_code': l.produitCode,
        'designation': l.designation,
        'quantite': l.quantite,
        'nombre': l.nombre,
        'prix_unitaire': l.prixUnitaire,
        'total': l.total,
        'prix_achat': l.prixAchat,
        'ordre_origine': l.ordreOrigine,
      });
    }
  }

  /// Remplace un retour (même code) et ses lignes (modification).
  Future<void> remplacerRetour(Retour r) async {
    await db.delete('retour_ligne', where: 'retour_code = ?', whereArgs: [r.code]);
    await db.update('retour', r.versLigne()..remove('code'), where: 'code = ?', whereArgs: [r.code]);
    await _insererLignesRetour(r);
  }

  Future<void> annulerRetour(String code, {required String par, required String motif, DateTime? le}) => db.update(
    'retour',
    {
      'etat': 0,
      'annule_le': (le ?? DateTime.now()).toUtc().toIso8601String(),
      'annule_par': par,
      'motif_annulation': motif,
    },
    where: 'code = ?',
    whereArgs: [code],
  );

  Future<void> lierVersementRetour(String retourCode, String? versementCode) =>
      db.update('retour', {'versement_code': versementCode}, where: 'code = ?', whereArgs: [retourCode]);

  Future<List<Retour>> retours({
    String? type,
    String? documentCode,
    String? clientCode,
    bool actifsSeulement = false,
    int limite = 5000,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (documentCode != null) {
      where.add('document_code = ?');
      args.add(documentCode);
    }
    if (clientCode != null) {
      where.add('client_code = ?');
      args.add(clientCode);
    }
    if (actifsSeulement) where.add('etat = 1');
    final rows = await db.query(
      'retour',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, code DESC',
      limit: limite,
    );
    return [for (final r in rows) Retour.depuisLigne(r, await _lignesRetour(r['code'] as String))];
  }

  Future<Retour?> retour(String code) async {
    final rows = await db.query('retour', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Retour.depuisLigne(rows.first, await _lignesRetour(code));
  }

  Future<List<RetourLigne>> _lignesRetour(String code) async => (await db.query(
    'retour_ligne',
    where: 'retour_code = ?',
    whereArgs: [code],
    orderBy: 'ordre',
  )).map(RetourLigne.depuisLigne).toList();

  /// Quantités déjà retournées (retours actifs) par produit pour une pièce d'origine, hors [sauf].
  Future<Map<String, double>> quantitesRetournees(String documentCode, {String? sauf}) async {
    final rows = await db.rawQuery(
      'SELECT l.produit_code p, SUM(l.quantite) q FROM retour_ligne l JOIN retour r ON r.code = l.retour_code '
      'WHERE r.document_code = ? AND r.etat = 1 AND r.code != ? GROUP BY l.produit_code',
      [documentCode, sauf ?? ''],
    );
    return {for (final r in rows) r['p'] as String: (r['q'] as num).toDouble()};
  }

  /// Quantités déjà retournées (retours clients actifs) par ligne de la vente (`ordre`), hors [sauf].
  Future<Map<int, double>> quantitesRetourneesParLigne(String venteCode, {String? sauf}) async =>
      (await retoursParLigne(venteCode, sauf: sauf)).map((k, v) => MapEntry(k, v.quantite));

  /// Quantités et montants déjà retournés (retours clients actifs) par ligne de la vente, hors [sauf].
  Future<Map<int, ({double quantite, double montant})>> retoursParLigne(String venteCode, {String? sauf}) async {
    final rows = await db.rawQuery(
      'SELECT l.ordre_origine o, SUM(l.quantite) q, SUM(l.total) t FROM retour_ligne l '
      'JOIN retour r ON r.code = l.retour_code '
      "WHERE r.type = 'Client' AND r.document_code = ? AND r.etat = 1 AND r.code != ? AND l.ordre_origine IS NOT NULL "
      'GROUP BY l.ordre_origine',
      [venteCode, sauf ?? ''],
    );
    return {
      for (final r in rows) r['o'] as int: (quantite: (r['q'] as num).toDouble(), montant: (r['t'] as num).toDouble()),
    };
  }

  // ---- Versements ----
  Future<void> insererVersement(Versement v) async {
    await db.insert('versement', v.versLigne());
    for (final i in v.imputations) {
      await db.insert('versement_imputation', {
        'versement_code': v.code,
        'document_type': i.documentType,
        'document_code': i.documentCode,
        'montant': i.montant,
      });
    }
  }

  Future<void> supprimerVersement(String code) => db.delete('versement', where: 'code = ?', whereArgs: [code]);

  /// Annulation douce : le versement reste au journal (`etat = 0`), ses imputations sont libérées.
  Future<void> annulerVersement(String code, {required String par, required String motif, DateTime? le}) async {
    await db.delete('versement_imputation', where: 'versement_code = ?', whereArgs: [code]);
    await db.update(
      'versement',
      {
        'etat': 0,
        'annule_le': (le ?? DateTime.now()).toUtc().toIso8601String(),
        'annule_par': par,
        'motif_annulation': motif,
      },
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  /// Remplace un versement (même code) et ses imputations.
  Future<void> remplacerVersement(Versement v) async {
    await db.delete('versement_imputation', where: 'versement_code = ?', whereArgs: [v.code]);
    await db.delete('versement', where: 'code = ?', whereArgs: [v.code]);
    await insererVersement(v);
  }

  Future<Versement?> versement(String code) async {
    final rows = await db.query('versement', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Versement.depuisLigne(rows.first, await _imputations(code));
  }

  Future<List<Versement>> versements({String? tiersType, String? tiersCode, int limite = 500}) async {
    final where = <String>[];
    final args = <Object>[];
    if (tiersType != null) {
      where.add('tiers_type = ?');
      args.add(tiersType);
    }
    if (tiersCode != null) {
      where.add('tiers_code = ?');
      args.add(tiersCode);
    }
    final rows = await db.query(
      'versement',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
      limit: limite,
    );
    return [for (final r in rows) Versement.depuisLigne(r, await _imputations(r['code'] as String))];
  }

  Future<List<Imputation>> _imputations(String code) async =>
      (await db.query('versement_imputation', where: 'versement_code = ?', whereArgs: [code]))
          .map(
            (r) => Imputation(
              versementCode: code,
              documentType: r['document_type'] as String,
              documentCode: r['document_code'] as String,
              montant: (r['montant'] as num).toDouble(),
            ),
          )
          .toList();

  /// Ramène les imputations d'un document à [plafond] : celles des versements d'un autre tiers que
  /// [tiersCode] sont libérées, puis les plus récentes sont réduites d'abord. L'excédent redevient une avance
  /// du versement (le solde du tiers, lui, ne dépend pas des imputations).
  Future<void> plafonnerImputations(
    String documentType,
    String documentCode,
    double plafond, {
    required String tiersType,
    required String tiersCode,
  }) async {
    await db.rawDelete(
      '''
      DELETE FROM versement_imputation WHERE document_type = ?1 AND document_code = ?2 AND versement_code IN
        (SELECT code FROM versement WHERE NOT (tiers_type = ?3 AND tiers_code = ?4))
      ''',
      [documentType, documentCode, tiersType, tiersCode],
    );
    final rows = await db.rawQuery(
      '''
      SELECT i.versement_code c, i.montant m FROM versement_imputation i JOIN versement v ON v.code = i.versement_code
      WHERE i.document_type = ? AND i.document_code = ? ORDER BY v.date DESC, length(v.code) DESC, v.code DESC
      ''',
      [documentType, documentCode],
    );
    var excedent = CalculsPrix.arrondir(rows.fold(0.0, (s, r) => s + (r['m']! as num).toDouble()) - plafond);
    for (final r in rows) {
      if (excedent <= 0.004) break;
      final m = (r['m']! as num).toDouble();
      final where = 'versement_code = ? AND document_type = ? AND document_code = ?';
      final args = [r['c'], documentType, documentCode];
      if (m <= excedent + 0.004) {
        await db.delete('versement_imputation', where: where, whereArgs: args);
      } else {
        await db.update(
          'versement_imputation',
          {'montant': CalculsPrix.arrondir(m - excedent)},
          where: where,
          whereArgs: args,
        );
      }
      excedent = CalculsPrix.arrondir(excedent - m);
    }
  }

  /// Montant déjà imputé sur un document.
  Future<double> imputeSur(String documentType, String documentCode) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(montant),0) m FROM versement_imputation WHERE document_type = ? AND document_code = ?',
      [documentType, documentCode],
    );
    return (rows.first['m'] as num).toDouble();
  }

  /// Documents ouverts d'un client (ventes validées avec reste > 0, hors imputations), plus ancien d'abord.
  Future<List<DocumentOuvert>> documentsOuvertsClient(String clientCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT v.code code, v.date date, v.total_net total,
             v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.document_type = 'vente' AND i.document_code = v.code), 0) reste
      FROM vente v WHERE v.client_code = ? AND v.statut = 'Validée' AND v.reste > 0
      ORDER BY v.date ASC, v.code ASC
    ''',
      [clientCode],
    );
    return [
      for (final r in rows)
        if ((r['reste'] as num) > 0.0001)
          DocumentOuvert(
            type: 'vente',
            code: r['code'] as String,
            date: DateTime.parse(r['date'] as String).toLocal(),
            total: (r['total'] as num).toDouble(),
            reste: (r['reste'] as num).toDouble(),
          ),
    ];
  }

  /// Documents ouverts d'un fournisseur (achats avec reste > 0), plus ancien d'abord.
  Future<List<DocumentOuvert>> documentsOuvertsFournisseur(String fournisseurCode) async {
    final rows = await db.rawQuery(
      '''
      SELECT a.code code, a.date date, a.total total,
             a.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i WHERE i.document_type = 'achat' AND i.document_code = a.code), 0) reste
      FROM achat a WHERE a.fournisseur_code = ? AND a.statut = 'Validé' AND a.reste > 0
      ORDER BY a.date ASC, a.code ASC
    ''',
      [fournisseurCode],
    );
    return [
      for (final r in rows)
        if ((r['reste'] as num) > 0.0001)
          DocumentOuvert(
            type: 'achat',
            code: r['code'] as String,
            date: DateTime.parse(r['date'] as String).toLocal(),
            total: (r['total'] as num).toDouble(),
            reste: (r['reste'] as num).toDouble(),
          ),
    ];
  }

  /// Solde unique d'un tiers (vue `solde_tiers`) : positif = dû par le client / au fournisseur, négatif = avance.
  Future<double> solde(String tiersType, String tiersCode) async {
    final r = await db.query(
      'solde_tiers',
      columns: ['solde'],
      where: 'tiers_type = ? AND tiers_code = ?',
      whereArgs: [tiersType, tiersCode],
    );
    return r.isEmpty ? 0 : (r.first['solde'] as num).toDouble();
  }

  Future<double> soldeClient(String clientCode) => solde(TypesTiers.client, clientCode);

  Future<double> soldeFournisseur(String fournisseurCode) => solde(TypesTiers.fournisseur, fournisseurCode);

  // ---- Statistiques et relevés (calculés en direct, §7.6) ----

  /// Statistiques de tous les clients ou fournisseurs ([tiersType]), par code. Le solde vient de la vue
  /// `solde_tiers` ; `du` (restes ouverts après imputations) est informatif.
  Future<Map<String, StatsTiers>> statistiques(String tiersType) async {
    final client = tiersType == TypesTiers.client;
    final soldes = await db.query('solde_tiers', where: 'tiers_type = ?', whereArgs: [tiersType]);
    final ouverts = client
        ? await db.rawQuery('''
      SELECT v.client_code c,
        COALESCE(SUM(MAX(v.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
          WHERE i.document_type = 'vente' AND i.document_code = v.code), 0), 0)), 0) du
      FROM vente v WHERE v.statut = 'Validée' GROUP BY v.client_code
    ''')
        : await db.rawQuery('''
      SELECT a.fournisseur_code c,
        COALESCE(SUM(MAX(a.reste - COALESCE((SELECT SUM(i.montant) FROM versement_imputation i
          WHERE i.document_type = 'achat' AND i.document_code = a.code), 0), 0)), 0) du
      FROM achat a WHERE a.statut = 'Validé' GROUP BY a.fournisseur_code
    ''');
    final retours = await db.rawQuery(
      client
          ? 'SELECT client_code c, COALESCE(SUM(total), 0) t FROM retour WHERE type = ? AND etat = 1 GROUP BY client_code'
          : 'SELECT fournisseur_code c, COALESCE(SUM(total), 0) t FROM retour WHERE type = ? AND etat = 1 '
                'GROUP BY fournisseur_code',
      [tiersType],
    );
    double d(Object? v) => (v as num?)?.toDouble() ?? 0;
    final res = <String, StatsTiers>{};
    StatsTiers de(String c) => res[c] ?? StatsTiers.vide;
    for (final r in soldes) {
      final c = r['tiers_code'] as String;
      res[c] = de(c).copyWith(
        achats: d(r['documents']),
        solde: d(r['solde']),
        dernier: r['dernier'] == null ? null : DateTime.parse(r['dernier'] as String).toLocal(),
      );
    }
    for (final r in ouverts) {
      final c = r['c'] as String;
      res[c] = de(c).copyWith(du: d(r['du']));
    }
    for (final r in retours) {
      final c = r['c'] as String;
      res[c] = de(c).copyWith(retours: d(r['t']));
    }
    return res;
  }

  /// Relevé chronologique d'un tiers (Situation) : documents, paiements, retours, versements.
  Future<List<LigneReleve>> releve(String tiersType, String tiersCode) async {
    final client = tiersType == TypesTiers.client;
    final lignes = <LigneReleve>[];
    DateTime dt(Object? v) => DateTime.parse(v as String).toLocal();
    double d(Object? v) => (v as num?)?.toDouble() ?? 0;
    final docs = client
        ? await db.query(
            'vente',
            columns: ['code', 'date', 'total_net t', 'total_net - reste paye'],
            where: "client_code = ? AND statut = 'Validée'",
            whereArgs: [tiersCode],
          )
        : await db.query(
            'achat',
            columns: ['code', 'date', 'total t', 'total - reste paye'],
            where: "fournisseur_code = ? AND statut = 'Validé'",
            whereArgs: [tiersCode],
          );
    for (final r in docs) {
      lignes.add(
        LigneReleve(date: dt(r['date']), nature: NatureReleve.achat, reference: r['code'] as String, credit: d(r['t'])),
      );
      // Payé à la pièce hors monnaie rendue (total − reste), jamais le montant remis par le client.
      if (d(r['paye']) > 0.004) {
        lignes.add(
          LigneReleve(
            date: dt(r['date']),
            nature: NatureReleve.versement,
            reference: r['code'] as String,
            debit: d(r['paye']),
          ),
        );
      }
    }
    for (final r in await db.query(
      'retour',
      where: '${client ? 'client_code' : 'fournisseur_code'} = ? AND etat = 1',
      whereArgs: [tiersCode],
    )) {
      lignes.add(
        LigneReleve(
          date: dt(r['date']),
          nature: NatureReleve.retour,
          reference: r['code'] as String,
          debit: d(r['total']),
        ),
      );
    }
    final sensPaiement = client ? SensVersement.encaissement : SensVersement.decaissement;
    for (final r in await db.query(
      'versement',
      where: "tiers_type = ? AND tiers_code = ? AND etat = 1 AND mode != 'Avoir'",
      whereArgs: [tiersType, tiersCode],
    )) {
      final paiement = r['sens'] == sensPaiement;
      lignes.add(
        LigneReleve(
          date: dt(r['date']),
          nature: paiement ? NatureReleve.versement : NatureReleve.versementRetour,
          reference: r['code'] as String,
          debit: paiement ? d(r['montant']) : 0,
          credit: paiement ? 0 : d(r['montant']),
        ),
      );
    }
    lignes.sort((a, b) {
      final c = a.date.compareTo(b.date);
      return c != 0 ? c : a.nature.index.compareTo(b.nature.index);
    });
    return lignes;
  }
}
