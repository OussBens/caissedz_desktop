import 'dart:convert';
import 'dart:math';

import 'package:bens_license/bens_license.dart';
import 'package:bens_license/machine_id.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../core/licence/compte_bens_api.dart';
import '../core/licence/license_config.dart';
import '../data/licence_repository.dart';
import '../domain/models/licence.dart';
import '../domain/permissions.dart';

/// Pourquoi une clé collée n'active pas le poste.
class ActivationException implements Exception {
  const ActivationException(this.motif, {this.finLe});

  /// [MotifLicence.invalide] aussi pour un champ vide.
  final MotifLicence motif;

  /// Pour une clé expirée : son dernier jour.
  final DateTime? finLe;

  @override
  String toString() => 'ActivationException($motif)';
}

/// L'identifiant brut du poste pour son code de licence (`CD-XXXX-XXXX`) : le MachineGuid de Windows,
/// sinon un identifiant aléatoire gardé (une réinstallation demandera alors une nouvelle licence).
abstract class MachineLicence {
  Future<String> lire(LicenceRepository repo);
}

class MachineLicenceSysteme implements MachineLicence {
  const MachineLicenceSysteme();

  @override
  Future<String> lire(LicenceRepository repo) async {
    final id = await desktopMachineId();
    if (id != null && id.isNotEmpty) return id;
    final garde = await repo.lireValeur(LicenceRepository.clePosteSecours);
    if (garde != null) return garde;
    final r = Random.secure();
    final nouveau = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await repo.ecrireValeur(LicenceRepository.clePosteSecours, nouveau);
    return nouveau;
  }
}

/// La licence du poste (bens_ds docs/rev.md → Accounts with a password) : une licence BENS signée
/// pour le code de ce PC, vérifiée ici sans internet ([LicenseGate]). Elle arrive par le compte BENS
/// (inscription avec l'essai du palier choisi, connexion, check-in à chaque lancement), ou collée
/// depuis WhatsApp (secours hors ligne). Le compte BENS est celui du gérant ; les comptes locaux
/// (admin, caissiers) restent ceux de l'application.
class LicenceService {
  LicenceService(
    this.db, {
    this.machine = const MachineLicenceSysteme(),
    LicenseVerifier? verifier,
    this.api,
    this.version = versionApplication,
    DateTime Function()? horloge,
  }) : verifier = verifier ?? LicenseVerifier(product: licenseProduct, publicKey: licensePublicKey),
       _horloge = horloge ?? DateTime.now;

  final Database db;
  final MachineLicence machine;
  final LicenseVerifier verifier;

  /// Null : hors ligne seulement (tests sans serveur).
  final CompteBensApi? api;
  final String version;
  final DateTime Function() _horloge;

  /// Version envoyée au serveur.
  static const String versionApplication = '1.2.0';

  LicenceRepository get _repo => LicenceRepository(db);

  LicenseGate? _gate;

  Future<LicenseGate> _porte() async => _gate ??= LicenseGate(
    verifier: verifier,
    device: DeviceCode.fromRawId(slug: licenseSlug, prefix: licensePrefix, rawId: await machine.lire(_repo)),
    read: _repo.lireValeur,
    write: _repo.ecrireValeur,
    clock: _horloge,
  );

  /// Code de ce poste (`CD-XXXX-XXXX`), à envoyer à BENS pour une licence à coller.
  Future<String> codePoste() async => '${(await _porte()).device}';

  /// Lien WhatsApp vers BENS avec le code du poste.
  Future<Uri> lienWhatsApp() async => (await _porte()).whatsAppLink(bensWhatsApp, 'CaisseDZ Desktop');

  CompteBensApi get _api => api ?? (throw const CompteBensException(ErreurCompteBens.reseau));

  // ---------------------------------------------------------------- Lecture

  /// La licence gardée, vérifiée à chaque lancement (hors ligne), et le compte de ce poste.
  Future<Licence> lire() async {
    final check = await (await _porte()).load();
    final compte = await _repo.compte();
    final droits = await _repo.droits();
    final solde = await _repo.scans();
    final scans = (solde?['remaining'] as num?)?.toInt();
    final expirations = [
      for (final b in solde?['expiringSoon'] as List? ?? const [])
        if (DateTime.tryParse('${(b as Map)['endsOn'] ?? ''}') case final fin?)
          (restant: (b['remaining'] as num?)?.toInt() ?? 0, fin: fin),
    ];
    final cle = await _repo.lireValeur(LicenseGate.keyName);
    final refus = MotifLicence.values.asNameMap()[await _repo.lireValeur(LicenceRepository.cleRefusServeur)];
    if (check == null) return Licence(niveau: null, compte: compte, scansSmartScan: scans, refusServeur: refus);
    if (!check.isValid) {
      return Licence(
        niveau: null,
        cle: cle,
        motif: _motif(check.status),
        finMotif: check.license?.expiresOn,
        compte: compte,
        scansSmartScan: scans,
        refusServeur: refus,
      );
    }
    final l = check.license!;
    return Licence(
      niveau: NiveauLicence.parNumero(l.tier) ?? NiveauLicence.basic,
      cle: cle,
      essai: (droits['app'] as Map?)?['source'] == 'trial',
      expireLe: l.expiresOn,
      activeeLe: l.issuedOn,
      compte: compte,
      scansSmartScan: scans,
      expirationsScans: expirations,
    );
  }

  /// Pour Smart Scan : l'identifiant brut du poste (X-Device-Id) et la licence gardée (X-License-Key).
  Future<({String machine, String? cle})> identiteSmartScan() async =>
      (machine: await machine.lire(_repo), cle: await _repo.lireValeur(LicenseGate.keyName));

  static MotifLicence _motif(LicenseStatus s) => switch (s) {
    LicenseStatus.expired => MotifLicence.expiree,
    LicenseStatus.wrongDevice => MotifLicence.autrePoste,
    LicenseStatus.clockRollback => MotifLicence.dateReculee,
    _ => MotifLicence.invalide,
  };

  // ---------------------------------------------------------------- Clé collée

  /// Active le poste avec une clé reçue sur WhatsApp. Refusée : [ActivationException] avec son motif.
  Future<Licence> activer(String cle) async {
    if (cle.trim().isEmpty) throw const ActivationException(MotifLicence.invalide);
    final check = await (await _porte()).activate(cle);
    if (!check.isValid) throw ActivationException(_motif(check.status), finLe: check.license?.expiresOn);
    await _repo.ecrireValeur(LicenceRepository.cleRefusServeur, null);
    return lire();
  }

  // ---------------------------------------------------------------- Compte BENS

  /// Les paliers, mises à niveau et packs en vente, et la durée de l'essai ; hors ligne : les paliers connus.
  Future<OffresBens> offres() async {
    try {
      final j = await _api.offres();
      final offres = [for (final o in j['offers'] as List? ?? const []) OffreBens.fromJson((o as Map).cast())];
      return OffresBens(
        offres: offres.isEmpty ? OffreBens.parDefaut : offres,
        joursEssai: (j['trialDays'] as num?)?.toInt() ?? 14,
        enLigne: true,
      );
    } on CompteBensException {
      return const OffresBens(offres: OffreBens.parDefaut, joursEssai: 14, enLigne: false);
    }
  }

  /// Crée le compte BENS avec l'offre choisie : son essai de 14 jours commence (une fois par numéro et
  /// par poste). Renvoie la licence et si l'essai a été donné.
  Future<({Licence licence, bool essaiDonne})> inscrire({
    required String telephone,
    required String nom,
    required String commerce,
    required String motDePasse,
    required String offre,
  }) async {
    final j = await _api.inscrire(
      telephone: telephone,
      nom: nom,
      commerce: commerce,
      motDePasse: motDePasse,
      poste: await codePoste(),
      offre: offre,
      version: version,
    );
    final compte = CompteBens(telephone: telephoneE164(telephone), nom: nom.trim(), commerce: commerce.trim());
    return (licence: await _appliquer(j, compte: compte), essaiDonne: j['trialGiven'] == true);
  }

  /// Connexion au compte BENS sur ce poste (s'il était sur un autre poste, il est déplacé ici).
  Future<Licence> connecter({required String telephone, required String motDePasse}) async {
    final j = await _api.connecter(
      telephone: telephone,
      motDePasse: motDePasse,
      poste: await codePoste(),
      version: version,
    );
    return _appliquer(j, compte: CompteBens(telephone: telephoneE164(telephone)));
  }

  /// Mot de passe oublié : le code de récupération à envoyer à BENS.
  Future<String> demanderRecuperation(String telephone) async =>
      _api.demanderRecuperation(telephone: telephone, poste: await codePoste());

  /// Le code reçu de BENS et le nouveau mot de passe : connecté comme [connecter].
  Future<Licence> reinitialiser({required String telephone, required String code, required String motDePasse}) async {
    final j = await _api.reinitialiser(
      telephone: telephone,
      code: code,
      motDePasse: motDePasse,
      poste: await codePoste(),
      version: version,
    );
    return _appliquer(j, compte: CompteBens(telephone: telephoneE164(telephone)));
  }

  /// Au lancement (et à la demande) : la licence et les droits à jour. Hors ligne, rien ne change ;
  /// déconnecté par le serveur (le compte est passé sur un autre poste, mot de passe réinitialisé),
  /// le compte et sa clé sont oubliés ici.
  Future<Licence> synchroniser() async {
    final jeton = await _repo.lireValeur(LicenceRepository.cleJeton);
    if (jeton == null || api == null) return lire();
    try {
      final licence = await _appliquer(await _api.checkIn(jeton, version: version));
      await _envoyerChoixCatalogue(jeton);
      return licence;
    } on CompteBensException catch (e) {
      if (e.erreur == ErreurCompteBens.deconnecte) await _oublier();
      return lire();
    }
  }

  /// Rayons du catalogue choisis à l'accueil (`[{code, name, available, downloaded}]`) : envoyés à BENS
  /// (son tableau de bord montre ce que chaque client télécharge). Hors ligne ou sans compte, gardés pour
  /// le prochain check-in. Ne lance jamais d'exception.
  Future<void> signalerChoixCatalogue(List<Map<String, Object?>> rayons) async {
    final attente = await _choixEnAttente();
    await _repo.ecrireValeur(LicenceRepository.cleChoixCatalogue, jsonEncode([...attente, rayons]));
    final jeton = await _repo.lireValeur(LicenceRepository.cleJeton);
    if (jeton != null) await _envoyerChoixCatalogue(jeton);
  }

  Future<List<Object?>> _choixEnAttente() async {
    try {
      return jsonDecode(await _repo.lireValeur(LicenceRepository.cleChoixCatalogue) ?? '[]') as List<Object?>;
    } on Object {
      return [];
    }
  }

  Future<void> _envoyerChoixCatalogue(String jeton) async {
    if (api == null) return;
    final attente = await _choixEnAttente();
    var envoyes = 0;
    for (final rayons in attente) {
      try {
        await _api.envoyerChoixCatalogue(jeton, [for (final r in rayons! as List) (r as Map).cast<String, Object?>()]);
      } on CompteBensException catch (e) {
        // Refusé tel quel (saisie) : inutile de le renvoyer. Réseau, serveur, session : au prochain check-in.
        if (e.erreur != ErreurCompteBens.saisie) break;
      } on Object {
        // Entrée illisible : abandonnée.
      }
      envoyes++;
    }
    if (envoyes > 0) {
      final reste = attente.skip(envoyes).toList();
      await _repo.ecrireValeur(LicenceRepository.cleChoixCatalogue, reste.isEmpty ? null : jsonEncode(reste));
    }
  }

  /// Demande d'achat d'une offre depuis l'application (BENS rappelle). Vrai si elle était déjà demandée.
  Future<bool> demanderOffre(String offre) async {
    final jeton =
        await _repo.lireValeur(LicenceRepository.cleJeton) ??
        (throw const CompteBensException(ErreurCompteBens.deconnecte));
    return _api.demanderOffre(jeton, offre);
  }

  /// Déconnecte ce poste du compte BENS : la licence venue du compte part avec lui.
  Future<Licence> deconnecterCompte() async {
    final jeton = await _repo.lireValeur(LicenceRepository.cleJeton);
    if (jeton != null && api != null) {
      try {
        await _api.deconnecter(jeton);
      } on CompteBensException {
        // Hors ligne : la session sera refusée à son prochain usage de toute façon.
      }
    }
    await _oublier();
    return lire();
  }

  Future<void> _oublier() async {
    await _repo.oublierCompte();
    await _repo.ecrireValeur(LicenseGate.keyName, null);
    _gate?.current = null;
  }

  /// Une réponse du serveur (inscription, connexion, check-in) : la session, la clé (une plus récente
  /// la remplace ; aucune clé et aucun `app` actif : celle gardée est retirée, révocation ou
  /// remboursement), les droits.
  Future<Licence> _appliquer(Map<String, Object?> j, {CompteBens? compte}) async {
    final jeton = j['token'] as String?;
    if (compte != null || jeton != null) {
      final garde = await _repo.compte();
      final c = compte ?? garde ?? const CompteBens(telephone: '');
      // La connexion ne renvoie pas le nom : on garde celui de l'inscription.
      await _repo.enregistrerCompte(
        CompteBens(
          telephone: c.telephone,
          nom: c.nom.isNotEmpty ? c.nom : (garde?.nom ?? ''),
          commerce: c.commerce.isNotEmpty ? c.commerce : (garde?.commerce ?? ''),
        ),
        jeton,
      );
    }
    final droits = (j['entitlements'] as Map?)?.cast<String, Object?>() ?? const {};
    await _repo.ecrireDroits(droits);
    if (j['scans'] is Map) await _repo.ecrireScans((j['scans'] as Map).cast<String, Object?>());
    final gate = await _porte();
    final cle = j['key'] as String?;
    if (cle != null) {
      // Refusée ici (clé d'une autre application, version sans la bonne clé publique, autre PC) : on
      // le garde pour le dire, sans quoi l'écran ne montre que « aucune formule ».
      final r = await gate.activate(cle);
      await _repo.ecrireValeur(
        LicenceRepository.cleRefusServeur,
        r.isValid || r.status == LicenseStatus.expired ? null : _motif(r.status).name,
      );
    } else {
      await _repo.ecrireValeur(LicenceRepository.cleRefusServeur, null);
      if (j.containsKey('entitlements') && (droits['app'] as Map?)?['active'] != true) {
        await _repo.ecrireValeur(LicenseGate.keyName, null);
        gate.current = null;
      }
    }
    return lire();
  }

  /// Le numéro tel que le serveur le garde : `0555 12 34 56` → `+213555123456`.
  static String telephoneE164(String saisi) {
    final d = saisi.replaceAll(RegExp(r'[^\d+]'), '');
    if (d.startsWith('+')) return d;
    if (d.startsWith('00')) return '+${d.substring(2)}';
    if (d.length == 12 && d.startsWith('213')) return '+$d';
    if (d.startsWith('0')) return '+213${d.substring(1)}';
    return d;
  }
}
