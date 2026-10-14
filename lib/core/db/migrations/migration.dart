import 'package:sqflite_common/sqlite_api.dart';

/// Une migration versionnée du schéma.
abstract class Migration {
  const Migration();

  /// Numéro de version cible (strictement croissant, 1, 2, 3…).
  int get version;

  /// Description courte (journal).
  String get description;

  /// Applique la migration dans la transaction [txn].
  Future<void> appliquer(Transaction txn);
}
