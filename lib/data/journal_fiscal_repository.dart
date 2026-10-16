import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/journal_fiscal.dart';
import '../domain/scellement.dart';

/// Journal fiscal chaîné (§12.3) : ventes, annulations, retours, clôtures Z, factures et avoirs. Chaque
/// événement est scellé `SHA-256(hash_precedent | contenu canonique)` ; la table refuse modification et
/// suppression (déclencheurs v30).
class JournalFiscalRepository {
  const JournalFiscalRepository(this.db);
  final DatabaseExecutor db;

  /// Ajoute un événement chaîné au dernier (à appeler dans la transaction de l'opération).
  Future<EvenementFiscal> ajouter({
    required String type,
    required String referenceCode,
    String? caisseCode,
    required String utilisateurCode,
    double montant = 0,
    Map<String, Object?> details = const {},
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dernier = await db.query('journal_fiscal', columns: ['hash'], orderBy: 'id DESC', limit: 1);
    final precedent = dernier.isEmpty ? Scellement.genese : dernier.first['hash']! as String;
    final contenu = Scellement.canonique({
      'type': type,
      'reference': referenceCode,
      'date': d,
      'caisse': caisseCode,
      'utilisateur': utilisateurCode,
      'montant': montant,
      'details': details,
    });
    final e = EvenementFiscal(
      date: d,
      type: type,
      referenceCode: referenceCode,
      caisseCode: caisseCode,
      utilisateurCode: utilisateurCode,
      montant: montant,
      contenu: contenu,
      hash: hacher(contenu, precedent),
      hashPrecedent: precedent,
    );
    final id = await db.insert('journal_fiscal', e.versLigne());
    return EvenementFiscal.depuisLigne({...e.versLigne(), 'id': id});
  }

  static String hacher(String contenu, String precedent) =>
      sha256.convert(utf8.encode('$precedent|$contenu')).toString();

  Future<List<EvenementFiscal>> evenements({
    DateTime? debut,
    DateTime? fin,
    String? type,
    String? referenceCode,
  }) async {
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
    if (referenceCode != null) {
      where.add('reference_code = ?');
      args.add(referenceCode);
    }
    final rows = await db.query(
      'journal_fiscal',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'id',
    );
    return rows.map(EvenementFiscal.depuisLigne).toList();
  }

  /// Vérifie une suite d'événements consécutifs ; `null` = intacte, sinon index du premier événement altéré.
  /// La suite part de la genèse, ou du `hash_precedent` du premier événement si [depuisPremier] (extrait).
  static int? verifierSuite(List<EvenementFiscal> suite, {bool depuisPremier = false}) {
    var attendu = depuisPremier && suite.isNotEmpty ? suite.first.hashPrecedent : Scellement.genese;
    for (var i = 0; i < suite.length; i++) {
      final e = suite[i];
      if (e.hashPrecedent != attendu || hacher(e.contenu, e.hashPrecedent) != e.hash) return i;
      attendu = e.hash;
    }
    return null;
  }

  /// Vérifie tout le journal ; `null` = intact, sinon id du premier événement altéré.
  Future<int?> verifier() async {
    final tous = await evenements();
    final i = verifierSuite(tous);
    return i == null ? null : tous[i].id;
  }
}
