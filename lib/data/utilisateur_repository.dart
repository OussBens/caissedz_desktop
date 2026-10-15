import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/utilisateur.dart';

class UtilisateurRepository {
  const UtilisateurRepository(this.db);

  final DatabaseExecutor db;

  static const String prefixe = CodeGenerator.utilisateur;

  static const String _select = '''
    SELECT u.code, u.identifiant, u.nom, u.prenom, u.telephone, u.role_code, r.nom role_nom, u.caisse_code,
           u.observation, u.actif, u.systeme, u.dernier_acces, u.cree_le, u.cree_par, u.modifie_le, u.modifie_par
    FROM utilisateur u LEFT JOIN role r ON r.code = u.role_code''';

  Future<List<Utilisateur>> _lire(String? where, List<Object?> args) async => (await db.rawQuery(
    '$_select${where == null ? '' : ' WHERE $where'} ORDER BY u.code',
    args,
  )).map(Utilisateur.depuisLigne).toList();

  Future<Utilisateur?> parIdentifiant(String identifiant) async =>
      (await _lire('u.identifiant = ? COLLATE NOCASE', [identifiant.trim()])).firstOrNull;

  Future<Utilisateur?> parCode(String code) async => (await _lire('u.code = ?', [code])).firstOrNull;

  Future<List<Utilisateur>> tous() => _lire(null, const []);

  Future<String?> empreinte(String code) async {
    final rows = await db.query('utilisateur', columns: ['mot_de_passe'], where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : rows.first['mot_de_passe'] as String?;
  }

  Future<bool> identifiantDisponible(String identifiant, {String? saufCode}) async {
    final rows = await db.query(
      'utilisateur',
      columns: ['code'],
      where: 'identifiant = ? COLLATE NOCASE',
      whereArgs: [identifiant.trim()],
    );
    return rows.isEmpty || (saufCode != null && rows.first['code'] == saufCode);
  }

  Future<String> prochainCode() async {
    final rows = await db.query('utilisateur', columns: ['code'], orderBy: 'code DESC', limit: 1);
    return CodeGenerator.suivant(prefixe, rows.isEmpty ? null : rows.first['code'] as String);
  }

  /// Horodate la connexion réussie de l'utilisateur.
  Future<void> enregistrerAcces(String code, DateTime quand) => db.update(
    'utilisateur',
    {'dernier_acces': quand.toUtc().toIso8601String()},
    where: 'code = ?',
    whereArgs: [code],
  );

  Future<void> mettreAJour(String code, Map<String, Object?> valeurs) async {
    await db.update(
      'utilisateur',
      {...valeurs, 'modifie_le': DateTime.now().toUtc().toIso8601String()},
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  Future<void> inserer(Utilisateur u, String? empreinte) async {
    await db.insert('utilisateur', {
      'code': u.code,
      'identifiant': u.identifiant.trim(),
      'nom': u.nom,
      'prenom': u.prenom,
      'telephone': u.telephone,
      'role_code': u.roleCode,
      'caisse_code': u.caisseCode,
      'observation': u.observation,
      'mot_de_passe': empreinte,
      'actif': u.actif ? 1 : 0,
      'systeme': u.systeme ? 1 : 0,
      'cree_par': u.creePar,
    });
  }

  /// Ventes validées par utilisateur depuis [depuis] : `{code: (nb, total)}`.
  Future<Map<String, ({int nb, double total})>> ventesParUtilisateur(DateTime depuis) async {
    final rows = await db.rawQuery(
      '''
      SELECT utilisateur_code u, COUNT(*) nb, COALESCE(SUM(total_net), 0) t FROM vente
      WHERE statut = 'Validée' AND date >= ? GROUP BY utilisateur_code
      ''',
      [depuis.toUtc().toIso8601String()],
    );
    return {for (final r in rows) r['u'] as String: (nb: r['nb'] as int, total: (r['t'] as num).toDouble())};
  }
}
