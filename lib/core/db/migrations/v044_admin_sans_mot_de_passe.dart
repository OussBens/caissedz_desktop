import 'package:sqflite_common/sqlite_api.dart';

import '../../securite/mot_de_passe.dart';
import 'migration.dart';
import 'v002_demarrage.dart';

/// Version 44 : plus de compte admin / admin.
///
/// L'administrateur se connecte avec le mot de passe du compte BENS créé (ou connecté) sur ce poste. S'il a
/// encore le mot de passe d'origine `admin` (posé par l'ancienne v008), il est effacé : l'administrateur
/// reprend le mot de passe du compte à la prochaine connexion au compte BENS (ou par « Mot de passe oublié »).
class MigrationV044AdminSansMotDePasse extends Migration {
  const MigrationV044AdminSansMotDePasse();

  @override
  int get version => 44;

  @override
  String get description => 'Administrateur sans mot de passe admin par défaut';

  @override
  Future<void> appliquer(Transaction txn) async {
    final lignes = await txn.query(
      'utilisateur',
      columns: ['mot_de_passe'],
      where: 'code = ?',
      whereArgs: [MigrationV002Demarrage.codeAdmin],
    );
    final empreinte = lignes.isEmpty ? null : lignes.single['mot_de_passe'] as String?;
    if (empreinte == null || !MotDePasse.verifier('admin', empreinte)) return;
    await txn.update(
      'utilisateur',
      {'mot_de_passe': null},
      where: 'code = ?',
      whereArgs: [MigrationV002Demarrage.codeAdmin],
    );
  }
}
