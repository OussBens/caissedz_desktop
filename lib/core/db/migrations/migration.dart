import 'package:sqflite_common/sqlite_api.dart';

/// Une migration versionnée du schéma.
abstract class Migration {
  const Migration();

  /// Numéro de version cible (strictement croissant, 1, 2, 3…).
  int get version;

  /// Description courte (journal).
  String get description;

  /// `true` pour reconstruire une table référencée (procédure SQLite « 12 étapes ») : les clés étrangères
  /// sont désactivées le temps de la migration puis vérifiées (`PRAGMA foreign_key_check`) avant validation.
  bool get reconstruitTables => false;

  /// Applique la migration dans la transaction [txn].
  Future<void> appliquer(Transaction txn);
}
