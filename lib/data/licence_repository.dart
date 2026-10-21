import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/licence.dart';
import 'parametres_repository.dart';

/// La licence du poste et le compte BENS, dans `parametre_app` (base chiffrée) : la clé signée et la
/// dernière date vue (LicenseGate : `license_key`, `license_seen`), la session du compte, ses droits
/// au dernier check-in.
class LicenceRepository {
  const LicenceRepository(this.db);

  final DatabaseExecutor db;

  static const String cleJeton = 'compte_jeton';
  static const String cleTelephone = 'compte_telephone';
  static const String cleNom = 'compte_nom';
  static const String cleCommerce = 'compte_commerce';
  static const String cleDroits = 'compte_droits';

  /// Solde Smart Scan du compte au dernier check-in (lots inclus et packs, avec leur fin).
  static const String cleScans = 'compte_scans';

  /// Pourquoi la dernière licence envoyée par le serveur a été refusée ici (`MotifLicence.name`).
  static const String cleRefusServeur = 'compte_licence_refusee';

  /// Identifiant aléatoire du poste quand Windows ne donne pas son MachineGuid.
  static const String clePosteSecours = 'licence_poste_secours';

  /// Choix de rayons du catalogue pas encore envoyés à BENS (hors ligne) : liste JSON de listes de rayons.
  static const String cleChoixCatalogue = 'compte_choix_catalogue';

  /// Ce qui appartient au poste, pas aux données du commerce : une restauration (sauvegarde d'un
  /// autre PC) garde ces valeurs-ci. La clé est liée au PC, la session du compte aussi.
  static const List<String> clesDuPoste = [
    'license_key',
    'license_seen',
    cleJeton,
    cleTelephone,
    cleNom,
    cleCommerce,
    cleDroits,
    cleScans,
    cleRefusServeur,
    clePosteSecours,
  ];

  ParametresAppRepository get _p => ParametresAppRepository(db);

  Future<String?> lireValeur(String cle) async {
    final v = await _p.lire(cle);
    return v == null || v.isEmpty ? null : v;
  }

  Future<void> ecrireValeur(String cle, String? valeur) => _p.ecrire(cle, valeur);

  /// Le compte BENS de ce poste, s'il y est connecté.
  Future<CompteBens?> compte() async {
    final tel = await lireValeur(cleTelephone);
    if (tel == null || await lireValeur(cleJeton) == null) return null;
    return CompteBens(
      telephone: tel,
      nom: await lireValeur(cleNom) ?? '',
      commerce: await lireValeur(cleCommerce) ?? '',
    );
  }

  /// Le compte et, s'il est donné, le jeton de sa session (sinon celui gardé reste).
  Future<void> enregistrerCompte(CompteBens c, String? jeton) async {
    await ecrireValeur(cleTelephone, c.telephone);
    await ecrireValeur(cleNom, c.nom);
    await ecrireValeur(cleCommerce, c.commerce);
    if (jeton != null) await ecrireValeur(cleJeton, jeton);
  }

  Future<void> oublierCompte() async {
    for (final k in [cleJeton, cleTelephone, cleNom, cleCommerce, cleDroits, cleScans, cleRefusServeur]) {
      await ecrireValeur(k, null);
    }
  }

  /// Les droits du compte au dernier check-in (`{"app": {...}, "smartscan": {...}}`).
  Future<Map<String, Object?>> droits() async {
    final v = await lireValeur(cleDroits);
    if (v == null) return const {};
    try {
      return (jsonDecode(v) as Map).cast<String, Object?>();
    } on FormatException {
      return const {};
    }
  }

  Future<void> ecrireDroits(Map<String, Object?> d) => ecrireValeur(cleDroits, jsonEncode(d));

  /// Le solde Smart Scan au dernier check-in (`{remaining, total, buckets, expiringSoon}`), ou null.
  Future<Map<String, Object?>?> scans() async {
    final v = await lireValeur(cleScans);
    if (v == null) return null;
    try {
      return (jsonDecode(v) as Map).cast<String, Object?>();
    } on FormatException {
      return null;
    }
  }

  Future<void> ecrireScans(Map<String, Object?>? s) => ecrireValeur(cleScans, s == null ? null : jsonEncode(s));
}
