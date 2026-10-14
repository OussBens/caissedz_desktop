import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'machine_key.dart';
import 'migration_runner.dart';
import 'migrations/migrations.dart';

/// Erreur levée quand la base ne peut pas être déchiffrée (clé incorrecte ou
/// fichier corrompu).
class CleBaseInvalideException implements Exception {
  const CleBaseInvalideException(this.chemin);
  final String chemin;
  @override
  String toString() => 'Impossible de déchiffrer la base « $chemin » : clé invalide ou fichier corrompu.';
}

/// Ouverture de la base SQLite chiffrée (SQLCipher) et application des migrations.
class AppDatabase {
  AppDatabase._(this.db, this.chemin, this.cleHex);

  final Database db;
  final String chemin;

  /// Clé de chiffrement (hex) de la base ouverte ; sert à re-chiffrer une sauvegarde restaurée.
  final String cleHex;

  /// Chemin du fichier de restauration en attente pour une base [chemin].
  static String cheminRestauration(String chemin) => '$chemin.restaurer';

  /// Applique une restauration en attente (`<base>.restaurer` remplace la base avant ouverture).
  static bool appliquerRestaurationEnAttente(String chemin) {
    final attente = File(cheminRestauration(chemin));
    if (!attente.existsSync()) return false;
    for (final suffixe in ['', '-wal', '-shm', '-journal']) {
      final f = File('$chemin$suffixe');
      if (f.existsSync()) f.deleteSync();
    }
    attente.renameSync(chemin);
    return true;
  }

  static const String nomFichier = 'caissedz.db';

  static bool _ffiInitialise = false;

  /// Initialise le moteur FFI (à appeler une fois au démarrage et dans les tests).
  ///
  /// [sansIsolate] exécute SQLite sur l'isolate courant : indispensable dans les
  /// tests de widgets (zone asynchrone simulée), à ne pas utiliser en production.
  static void initialiserMoteur({bool sansIsolate = false}) {
    if (!_ffiInitialise) {
      sqfliteFfiInit();
      _ffiInitialise = true;
    }
    final cible = sansIsolate ? databaseFactoryFfiNoIsolate : databaseFactoryFfi;
    if (!identical(databaseFactoryOrNull, cible)) databaseFactory = cible;
  }

  /// Ouvre (ou crée) la base chiffrée située dans [dossier] avec la clé [cleHex],
  /// active les clés étrangères et applique les migrations manquantes.
  static Future<AppDatabase> ouvrir({
    required String dossier,
    required String cleHex,
    List<Migration> migrations = toutesLesMigrations,
    String nom = nomFichier,
  }) async {
    if (!_ffiInitialise) initialiserMoteur();
    Directory(dossier).createSync(recursive: true);
    final chemin = p.join(dossier, nom);
    appliquerRestaurationEnAttente(chemin);
    final Database db;
    try {
      db = await databaseFactory.openDatabase(
        chemin,
        options: OpenDatabaseOptions(
          singleInstance: false,
          onConfigure: (db) async {
            // La clé doit être fournie AVANT toute autre opération (SQLCipher).
            await db.rawQuery("PRAGMA key = \"x'$cleHex'\"");
            await db.execute('PRAGMA foreign_keys = ON');
            await db.execute('PRAGMA journal_mode = WAL');
          },
        ),
      );
      // Première lecture : échoue si la clé ne permet pas de déchiffrer le fichier.
      await db.rawQuery('SELECT count(*) FROM sqlite_master');
    } on DatabaseException catch (e) {
      if (e.toString().contains('not a database') || e.getResultCode() == 26) {
        throw CleBaseInvalideException(chemin);
      }
      rethrow;
    }
    await MigrationRunner(migrations).executer(db);
    return AppDatabase._(db, chemin, cleHex);
  }

  /// Ouvre une base en mémoire (tests de widgets : aucune E/S fichier réelle,
  /// incompatible avec la zone asynchrone simulée de `testWidgets`).
  static Future<AppDatabase> ouvrirEnMemoire({
    required String cleHex,
    List<Migration> migrations = toutesLesMigrations,
  }) async {
    initialiserMoteur(sansIsolate: true);
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: (db) async {
          await db.rawQuery("PRAGMA key = \"x'$cleHex'\"");
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
    await MigrationRunner(migrations).executer(db);
    return AppDatabase._(db, inMemoryDatabasePath, cleHex);
  }

  /// Ouvre la base de l'application avec la clé dérivée de la machine (§4.2).
  static Future<AppDatabase> ouvrirAvecCleMachine({
    required String dossier,
    DerivationCle derivation = const DerivationCle(),
  }) async {
    final cle = await derivation.cleHex();
    return ouvrir(dossier: dossier, cleHex: cle);
  }

  Future<bool> clesEtrangeresActives() async {
    final rows = await db.rawQuery('PRAGMA foreign_keys');
    return (rows.first.values.first as int?) == 1;
  }

  Future<int> version() => const MigrationRunner(toutesLesMigrations).versionCourante(db);

  /// Vérifie que le fichier est bien chiffré : son en-tête ne doit pas être
  /// celui d'une base SQLite en clair (« SQLite format 3 »).
  static Future<bool> fichierEstChiffre(String chemin) async {
    final f = File(chemin);
    if (!f.existsSync()) return false;
    final raf = f.openSync();
    try {
      final entete = raf.readSync(16);
      return String.fromCharCodes(entete) != 'SQLite format 3\u0000';
    } finally {
      raf.closeSync();
    }
  }

  Future<void> fermer() => db.close();
}
