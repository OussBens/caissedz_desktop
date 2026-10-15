import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/db/app_database.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import 'parametres_service.dart';

enum ErreurSauvegarde { motDePasseVide, fichierIntrouvable, motDePasseInvalide, cheminInvalide }

class SauvegardeException implements Exception {
  const SauvegardeException(this.erreur, [this.detail]);
  final ErreurSauvegarde erreur;
  final String? detail;
  @override
  String toString() => 'SauvegardeException($erreur${detail == null ? '' : ', $detail'})';
}

/// Contenu d'une sauvegarde vérifiée.
class InfoSauvegarde {
  const InfoSauvegarde({
    required this.version,
    required this.boutique,
    required this.nbVentes,
    required this.nbProduits,
  });
  final int version;
  final String boutique;
  final int nbVentes;
  final int nbProduits;
}

/// Sauvegarde / restauration de la base chiffrée (§4.2).
///
/// Sauvegarde : copie SQLCipher (`sqlcipher_export`) chiffrée avec un mot de passe choisi par l'utilisateur,
/// donc restaurable sur une autre machine. Restauration : la sauvegarde est vérifiée, re-chiffrée avec la clé
/// de la machine dans `<base>.restaurer`, puis appliquée au prochain démarrage (la base ouverte n'est jamais
/// remplacée à chaud).
class SauvegardeService {
  const SauvegardeService(this.base, {this.utilisateurCode});
  final AppDatabase base;

  /// Auteur journalisé dans l'Historique (sauvegarde, restauration) ; rien n'est journalisé sans lui.
  final String? utilisateurCode;

  static String _nomFichier(String chemin) => chemin.split(RegExp(r'[\\/]')).last;

  Future<void> _journal(String action, String chemin) async {
    if (utilisateurCode == null) return;
    await HistoriqueRepository(
      base.db,
    ).journaliser(utilisateurCode: utilisateurCode!, action: action, entite: 'sauvegarde', detail: _nomFichier(chemin));
  }

  static String _echapper(String s) => s.replaceAll("'", "''");

  Future<void> sauvegarder({required String chemin, required String motDePasse}) async {
    if (motDePasse.isEmpty) throw const SauvegardeException(ErreurSauvegarde.motDePasseVide);
    final f = File(chemin);
    if (f.existsSync()) f.deleteSync();
    final db = base.db;
    await db.execute("ATTACH DATABASE '${_echapper(chemin)}' AS sauvegarde KEY '${_echapper(motDePasse)}'");
    try {
      await db.rawQuery("SELECT sqlcipher_export('sauvegarde')");
      await db.execute('PRAGMA sauvegarde.user_version = ${await base.version()}');
    } finally {
      await db.execute('DETACH DATABASE sauvegarde');
    }
    await _journal('Sauvegarde', chemin);
  }

  /// Préfixe des fichiers de la sauvegarde automatique (les [conserver] plus récents sont gardés).
  static const String prefixeAuto = 'caissedz_auto_';

  /// Auteur journalisé de la sauvegarde automatique (aucun utilisateur n'est encore connecté).
  static const String utilisateurSysteme = 'SYSTEME';
  static const int conserverDefaut = 30;

  /// Sauvegarde automatique au démarrage (§4.1 étape 8, §12.2) si elle est due selon les Paramètres :
  /// fichier `caissedz_auto_AAAAMMJJ_HHMM.cdz` dans le dossier choisi, chiffré avec le mot de passe enregistré,
  /// date de dernière sauvegarde mise à jour, anciens fichiers automatiques au-delà de [conserver] supprimés.
  /// Retourne le chemin écrit, ou `null` si rien n'était dû.
  Future<String?> sauvegarderAutoSiDue({DateTime? maintenant, int conserver = conserverDefaut}) async {
    final now = maintenant ?? DateTime.now();
    final p = ParametresSauvegardeAuto.depuisCles(
      await ParametreRepository(base.db).lirePlusieurs(ParametresSauvegardeAuto.cles),
    );
    if (!p.estDue(now)) return null;
    final dossier = Directory(p.dossier.trim());
    if (!dossier.existsSync()) dossier.createSync(recursive: true);
    String p2(int v) => v.toString().padLeft(2, '0');
    final nom = '$prefixeAuto${now.year}${p2(now.month)}${p2(now.day)}_${p2(now.hour)}${p2(now.minute)}.cdz';
    final chemin = '${dossier.path}${Platform.pathSeparator}$nom';
    await sauvegarder(chemin: chemin, motDePasse: p.motDePasse);
    await ParametreRepository(base.db).ecrire(ParametresSauvegardeAuto.cleDerniere, now.toUtc().toIso8601String());
    final anciens =
        dossier
            .listSync()
            .whereType<File>()
            .where((f) => _nomFichier(f.path).startsWith(prefixeAuto) && f.path.endsWith('.cdz'))
            .toList()
          ..sort((a, b) => _nomFichier(b.path).compareTo(_nomFichier(a.path)));
    for (final f in anciens.skip(conserver)) {
      f.deleteSync();
    }
    return chemin;
  }

  /// Ouvre la sauvegarde avec [motDePasse] et en lit le contenu.
  Future<InfoSauvegarde> verifier({required String chemin, required String motDePasse}) async {
    if (motDePasse.isEmpty) throw const SauvegardeException(ErreurSauvegarde.motDePasseVide);
    if (!File(chemin).existsSync()) throw const SauvegardeException(ErreurSauvegarde.fichierIntrouvable);
    final db = await _ouvrirSauvegarde(chemin, motDePasse);
    try {
      final version = (await db.rawQuery('PRAGMA user_version')).first.values.first as int;
      final boutique = await db.query('boutique', columns: ['nom'], limit: 1);
      final ventes = (await db.rawQuery('SELECT COUNT(*) n FROM vente')).first['n'] as int;
      final produits = (await db.rawQuery('SELECT COUNT(*) n FROM produit')).first['n'] as int;
      return InfoSauvegarde(
        version: version,
        boutique: boutique.isEmpty ? '' : boutique.first['nom'] as String,
        nbVentes: ventes,
        nbProduits: produits,
      );
    } finally {
      await db.close();
    }
  }

  /// Prépare la restauration : `<base>.restaurer` chiffré avec la clé machine, appliqué au prochain démarrage.
  Future<InfoSauvegarde> preparerRestauration({required String chemin, required String motDePasse}) async {
    final info = await verifier(chemin: chemin, motDePasse: motDePasse);
    final cible = AppDatabase.cheminRestauration(base.chemin);
    final f = File(cible);
    if (f.existsSync()) f.deleteSync();
    final db = await _ouvrirSauvegarde(chemin, motDePasse);
    try {
      await db.execute("ATTACH DATABASE '${_echapper(cible)}' AS cible KEY \"x'${base.cleHex}'\"");
      await db.rawQuery("SELECT sqlcipher_export('cible')");
      await db.execute('PRAGMA cible.user_version = ${info.version}');
      // Journalisée dans la base restaurée, celle qui sera ouverte au prochain démarrage.
      if (utilisateurCode != null && info.version >= 3) {
        await db.rawInsert(
          'INSERT INTO cible.historique (utilisateur_code, action, entite, detail, date) VALUES (?, ?, ?, ?, ?)',
          [
            utilisateurCode,
            'Restauration',
            'sauvegarde',
            _nomFichier(chemin),
            DateTime.now().toUtc().toIso8601String(),
          ],
        );
      }
      await db.execute('DETACH DATABASE cible');
    } finally {
      await db.close();
    }
    return info;
  }

  /// Annule une restauration en attente.
  Future<void> annulerRestauration() async {
    final f = File(AppDatabase.cheminRestauration(base.chemin));
    if (f.existsSync()) f.deleteSync();
  }

  bool get restaurationEnAttente => File(AppDatabase.cheminRestauration(base.chemin)).existsSync();

  Future<Database> _ouvrirSauvegarde(String chemin, String motDePasse) async {
    try {
      final db = await databaseFactory.openDatabase(
        chemin,
        options: OpenDatabaseOptions(
          singleInstance: false,
          onConfigure: (db) => db.rawQuery("PRAGMA key = '${_echapper(motDePasse)}'"),
        ),
      );
      try {
        await db.rawQuery('SELECT count(*) FROM sqlite_master');
      } catch (_) {
        await db.close();
        rethrow;
      }
      return db;
    } on DatabaseException catch (e) {
      if (e.toString().contains('not a database') || e.getResultCode() == 26) {
        throw const SauvegardeException(ErreurSauvegarde.motDePasseInvalide);
      }
      throw SauvegardeException(ErreurSauvegarde.cheminInvalide, e.toString());
    }
  }
}
