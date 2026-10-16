import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 20 : colonnes d'audit (§3.2, §15 « Colonnes d'audit ») sur les tables métier.
/// - `cree_le`, `cree_par`, `modifie_le`, `modifie_par` ajoutées là où elles manquent ; création reprise de la
///   date et de l'auteur existants (`date`, `utilisateur_code`).
/// - `audit_contexte` (une ligne) : utilisateur connecté, écrit à la connexion par `AuthService`.
/// - Déclencheurs : création renseignée à l'insertion, « modifié le / par » à chaque mise à jour, quel que soit
///   le chemin d'écriture (service, dépôt, requête brute).
class MigrationV020Audit extends Migration {
  const MigrationV020Audit();

  @override
  int get version => 20;

  @override
  String get description => "Colonnes d'audit créé / modifié le / par";

  /// Tables métier auditées (opérations et référentiels modifiables).
  static const List<String> tables = [
    'achat',
    'besoin',
    'sortie_stock',
    'transfert_caisse',
    'transfert_stock',
    'retour',
    'vente',
    'versement',
    'client',
    'fournisseur',
    'magasin',
    'caisse',
    'categorie',
    'sous_categorie',
    'remise',
    'pack',
    'produit',
  ];

  static const String _maintenant = "strftime('%Y-%m-%dT%H:%M:%fZ','now')";
  static const String _utilisateur = '(SELECT utilisateur_code FROM audit_contexte WHERE id = 1)';

  @override
  Future<void> appliquer(Transaction txn) async {
    await txn.execute('CREATE TABLE audit_contexte (id INTEGER PRIMARY KEY CHECK (id = 1), utilisateur_code TEXT)');
    await txn.insert('audit_contexte', {'id': 1});
    for (final t in tables) {
      await ajouterAudit(txn, t);
    }
  }

  /// Ajoute les colonnes d'audit manquantes de [t] et ses déclencheurs de création / modification.
  static Future<void> ajouterAudit(Transaction txn, String t) async {
    {
      final colonnes = {for (final c in await txn.rawQuery('PRAGMA table_info($t)')) c['name']! as String};
      for (final c in ['cree_le', 'cree_par', 'modifie_le', 'modifie_par']) {
        if (!colonnes.contains(c)) await txn.execute('ALTER TABLE $t ADD COLUMN $c TEXT');
      }
      if (colonnes.contains('date')) await txn.execute('UPDATE $t SET cree_le = date WHERE cree_le IS NULL');
      if (colonnes.contains('utilisateur_code')) {
        await txn.execute('UPDATE $t SET cree_par = utilisateur_code WHERE cree_par IS NULL');
      }
      // Auteur : colonne `utilisateur_code` de l'opération si elle existe, sinon l'utilisateur connecté.
      final auteur = colonnes.contains('utilisateur_code') ? 'NEW.utilisateur_code, $_utilisateur' : _utilisateur;
      await txn.execute('''
        CREATE TRIGGER audit_${t}_creation AFTER INSERT ON $t
        WHEN NEW.cree_le IS NULL OR NEW.cree_par IS NULL
        BEGIN
          UPDATE $t SET cree_le = COALESCE(NEW.cree_le, $_maintenant),
                        cree_par = COALESCE(NEW.cree_par, $auteur)
          WHERE rowid = NEW.rowid;
        END
      ''');
      await txn.execute('''
        CREATE TRIGGER audit_${t}_modification AFTER UPDATE ON $t
        WHEN NEW.cree_le IS OLD.cree_le AND NEW.cree_par IS OLD.cree_par
        BEGIN
          UPDATE $t SET modifie_le = $_maintenant, modifie_par = COALESCE($_utilisateur, NEW.modifie_par)
          WHERE rowid = NEW.rowid;
        END
      ''');
    }
  }
}
