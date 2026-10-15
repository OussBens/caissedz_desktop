import 'package:sqflite_common/sqlite_api.dart';

import '../domain/code_generator.dart';
import '../domain/models/utilisateur.dart';

class UtilisateurRepository {
  const UtilisateurRepository(this.db);

  final DatabaseExecutor db;

  static const String prefixe = 'USR';

  Future<Utilisateur?> parIdentifiant(String identifiant) async {
    final rows = await db.query(
      'utilisateur',
      where: 'identifiant = ? COLLATE NOCASE',
      whereArgs: [identifiant.trim()],
    );
    return rows.isEmpty ? null : Utilisateur.depuisLigne(rows.first);
  }

  Future<Utilisateur?> parCode(String code) async {
    final rows = await db.query('utilisateur', where: 'code = ?', whereArgs: [code]);
    return rows.isEmpty ? null : Utilisateur.depuisLigne(rows.first);
  }

  Future<List<Utilisateur>> tous() async =>
      (await db.query('utilisateur', orderBy: 'code')).map(Utilisateur.depuisLigne).toList();

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

  Future<void> inserer(Utilisateur u, String empreinte) async {
    await db.insert('utilisateur', {
      'code': u.code,
      'identifiant': u.identifiant.trim(),
      'nom': u.nom,
      'role': u.role,
      'mot_de_passe': empreinte,
      'actif': u.actif ? 1 : 0,
      'systeme': u.systeme ? 1 : 0,
    });
  }
}
