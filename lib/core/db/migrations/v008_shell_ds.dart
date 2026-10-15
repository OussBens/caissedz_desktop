import 'package:sqflite_common/sqlite_api.dart';

import '../../../domain/modules.dart';
import '../../securite/mot_de_passe.dart';
import 'migration.dart';
import 'v002_demarrage.dart';

/// Version 8 : shell et démarrage du DS v2.2 (phase C).
///
/// - Administrateur système connectable dès l'installation (`admin` / `admin`, §4.5 : la configuration
///   initiale a lieu APRÈS la première connexion). ⚠️ PROVISOIRE : mot de passe à changer dans Mon compte.
/// - Boutique : NIS, article d'imposition, message du ticket, logo (`entreprise_param`, §7.9).
/// - Utilisateur : dernier accès (§5.4).
/// - Les 17 modules du DS : les anciens identifiants (transferts, versements, clôtures, situation) des
///   favoris et des accès des rôles sont repris sur leur module.
class MigrationV008ShellDs extends Migration {
  const MigrationV008ShellDs();

  static const String identifiantAdmin = 'admin';
  static const String motDePasseAdmin = 'admin';

  @override
  int get version => 8;

  @override
  String get description => 'Shell DS v2.2 : admin provisoire, boutique complète, 17 modules';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.update(
      'utilisateur',
      {'mot_de_passe': const MotDePasse(iterations: 1000).hacher(motDePasseAdmin)},
      where: 'code = ? AND mot_de_passe IS NULL',
      whereArgs: [MigrationV002Demarrage.codeAdmin],
    );
    await txn.execute('ALTER TABLE utilisateur ADD COLUMN dernier_acces TEXT');

    for (final colonne in ['nis', 'article', 'message_ticket', 'logo']) {
      await txn.execute("ALTER TABLE boutique ADD COLUMN $colonne TEXT NOT NULL DEFAULT ''");
    }

    for (final e in Modules.anciensIdentifiants.entries) {
      await txn.rawInsert(
        'INSERT OR IGNORE INTO role_module (role, module_id) SELECT role, ? FROM role_module WHERE module_id = ?',
        [e.value, e.key],
      );
      await txn.delete('role_module', where: 'module_id = ?', whereArgs: [e.key]);
      await txn.rawInsert(
        'INSERT OR IGNORE INTO favori_module (utilisateur_code, module_id, ordre) '
        'SELECT utilisateur_code, ?, ordre FROM favori_module WHERE module_id = ?',
        [e.value, e.key],
      );
      await txn.delete('favori_module', where: 'module_id = ?', whereArgs: [e.key]);
    }
  }
}
