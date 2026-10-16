import 'package:sqflite_common/sqlite_api.dart';

import 'migration.dart';

/// Version 24 : les entrées (normales et rapides) sont codées `ENT` au lieu de `SS`. Les entrées existantes sont
/// renommées (`SS0007` → `ENT0007`) partout où leur code est repris : lignes, bons reçus, imputations de
/// versements, retours fournisseurs, mouvements de stock et de caisse, historique.
class MigrationV024CodesEntree extends Migration {
  const MigrationV024CodesEntree();

  @override
  int get version => 24;

  @override
  String get description => 'Code des entrées : ENT au lieu de SS';

  static const _ancien = "GLOB 'SS[0-9]*'";
  static String _nouveau(String colonne) => "'ENT' || substr($colonne, 3)";

  @override
  Future<void> appliquer(Transaction txn) async {
    Future<void> renommer(String table, String colonne, [String condition = '1']) =>
        txn.execute('UPDATE $table SET $colonne = ${_nouveau(colonne)} WHERE $colonne $_ancien AND ($condition)');
    await renommer('achat', 'code');
    await renommer('achat_ligne', 'achat_code');
    await renommer('bon_reception', 'achat_code');
    await renommer('versement_imputation', 'document_code', "document_type = 'achat'");
    await renommer('retour', 'document_code', "type = 'Fournisseur'");
    await renommer('mouvement_stock', 'reference_code');
    await renommer('mouvement_caisse', 'reference_code');
    await renommer('historique', 'entite_code');
  }
}
