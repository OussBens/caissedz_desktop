import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/facture.dart';

/// Accès SQL aux factures et avoirs (table `facture`, en ajout seul).
class FactureRepository {
  const FactureRepository(this.db);
  final DatabaseExecutor db;

  /// Prochain numéro de la série [prefixe] (FAC ou AVO) : numérotation continue, sans trou.
  Future<String> prochainCode(String prefixe) async {
    final rows = await db.query(
      'facture',
      columns: ['code'],
      where: 'code LIKE ?',
      whereArgs: ['$prefixe%'],
      orderBy: CodeGenerator.ordreDecroissant,
      limit: 1,
    );
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  Future<String?> dernierHash() async {
    final r = await db.query('facture', columns: ['hash'], orderBy: 'rowid DESC', limit: 1);
    return r.isEmpty ? null : r.first['hash']! as String;
  }

  Future<void> inserer(Facture f) => db.insert('facture', f.versLigne());

  Future<Facture?> facture(String code) async {
    final r = await db.query('facture', where: 'code = ?', whereArgs: [code]);
    return r.isEmpty ? null : Facture.depuisLigne(r.first);
  }

  /// Facture émise pour une vente (une seule par vente).
  Future<Facture?> factureDeVente(String venteCode) async {
    final r = await db.query(
      'facture',
      where: 'vente_code = ? AND type = ?',
      whereArgs: [venteCode, TypesFacture.facture],
      limit: 1,
    );
    return r.isEmpty ? null : Facture.depuisLigne(r.first);
  }

  /// Avoir émis pour un retour client.
  Future<Facture?> avoirDuRetour(String retourCode) async {
    final r = await db.query('facture', where: 'retour_code = ?', whereArgs: [retourCode], limit: 1);
    return r.isEmpty ? null : Facture.depuisLigne(r.first);
  }

  /// Avoirs émis sur une facture.
  Future<List<Facture>> avoirsDe(String factureCode) async {
    final r = await db.query('facture', where: 'facture_origine = ?', whereArgs: [factureCode], orderBy: 'rowid');
    return r.map(Facture.depuisLigne).toList();
  }

  /// Factures et avoirs dans l'ordre d'émission (chaîne), sur une période si précisée.
  Future<List<Facture>> factures({DateTime? debut, DateTime? fin, String? type}) async {
    final where = <String>[];
    final args = <Object>[];
    if (debut != null) {
      where.add('date >= ?');
      args.add(debut.toUtc().toIso8601String());
    }
    if (fin != null) {
      where.add('date <= ?');
      args.add(fin.toUtc().toIso8601String());
    }
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    final r = await db.query(
      'facture',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'rowid',
    );
    return r.map(Facture.depuisLigne).toList();
  }

  /// Droits de timbre des factures émises sur la période.
  Future<double> timbres(DateTime debut, DateTime fin) async {
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(timbre), 0) t FROM facture WHERE type = ? AND date >= ? AND date <= ?',
      [TypesFacture.facture, debut.toUtc().toIso8601String(), fin.toUtc().toIso8601String()],
    );
    return (r.first['t']! as num).toDouble();
  }
}
