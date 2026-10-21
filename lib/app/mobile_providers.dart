import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../application/serveur_mobile.dart';
import '../data/boutique_repository.dart';
import '../data/mobile_repository.dart';
import '../data/utilisateur_repository.dart';
import '../domain/models/appareil_mobile.dart';
import '../features/produits/produits_providers.dart';
import '../features/stock/stock_providers.dart';
import '../features/tiers/tiers_providers.dart';
import 'demarrage_providers.dart';
import 'providers.dart';

/// Serveur de l'application mobile CaisseDZ Scan (réseau local), créé une fois avec l'application.
final serveurMobileProvider = Provider<ServeurMobile>((ref) {
  final base = ref.watch(appDatabaseProvider);
  final serveur = ServeurMobile(
    base.db,
    licence: () => ref.read(licenceProvider),
    dossierFactures: p.join(p.dirname(base.chemin), 'factures_mobile'),
    catalogueIa: () => ref.read(catalogueIaServiceProvider),
    utilisateurPoste: () => ref.read(sessionProvider)?.utilisateur.code,
    surModification: (domaines) {
      if (domaines.contains(DomaineMobile.catalogue)) ref.read(catalogueVersionProvider.notifier).incrementer();
      if (domaines.contains(DomaineMobile.stock)) ref.read(stockVersionProvider.notifier).incrementer();
      if (domaines.contains(DomaineMobile.commerce)) ref.read(commerceVersionProvider.notifier).incrementer();
      if (domaines.contains(DomaineMobile.appareils)) ref.read(appareilsVersionProvider.notifier).incrementer();
    },
    surFacture: (f) => ref.read(factureMobileProvider.notifier).recue(f),
  );
  ref.onDispose(() => unawaited(serveur.arreter()));
  return serveur;
});

/// État du lien avec les téléphones : serveur démarré, adresses du poste, QR d'appairage personnel.
@immutable
class EtatMobile {
  const EtatMobile({
    this.actif = false,
    this.port,
    this.adresses = const [],
    this.qr,
    this.qrUtilisateur,
    this.expireLe,
    this.erreur,
  });
  static const EtatMobile arrete = EtatMobile();

  final bool actif;
  final int? port;
  final List<String> adresses;

  /// Contenu du QR code d'appairage (null tant qu'il n'a pas été demandé).
  final String? qr;

  /// Utilisateur à qui appartient [qr] : le téléphone qui le scanne se connecte avec son compte.
  final String? qrUtilisateur;
  final DateTime? expireLe;
  final String? erreur;

  /// Le QR affiché peut-il servir à [utilisateurCode] ?
  bool qrValablePour(String? utilisateurCode) =>
      qr != null && qrUtilisateur == utilisateurCode && (expireLe?.isAfter(DateTime.now()) ?? false);

  EtatMobile sansQr() => EtatMobile(actif: actif, port: port, adresses: adresses, erreur: erreur);
}

class MobileNotifier extends Notifier<EtatMobile> {
  @override
  EtatMobile build() {
    // Changement d'utilisateur sur le poste : son QR n'est plus valable.
    ref.listen(sessionProvider.select((s) => s?.utilisateur.code), (avant, _) {
      if (avant != null) _serveur.annulerCodeAppairage(avant);
      state = state.sansQr();
    });
    return EtatMobile.arrete;
  }

  /// Paramètre mémorisé : le serveur redémarre avec l'application une fois activé.
  static const String cleActif = 'mobile_actif';

  ServeurMobile get _serveur => ref.read(serveurMobileProvider);

  /// Au lancement : relance le serveur s'il était activé (un échec ne bloque jamais l'ouverture).
  Future<void> demarrerSiActif() async {
    if (await ref.read(parametresAppRepositoryProvider).lire(cleActif) != '1') return;
    await demarrer(qr: false);
  }

  /// Démarre le serveur et prépare un QR d'appairage neuf ([qr]).
  Future<void> demarrer({bool qr = true}) async {
    try {
      final port = await _serveur.demarrer();
      await ref.read(parametresAppRepositoryProvider).ecrire(cleActif, '1');
      final adresses = await ServeurMobile.adressesLocales();
      state = EtatMobile(actif: true, port: port, adresses: adresses);
      if (qr) await nouveauQr();
    } on Object catch (e, pile) {
      developer.log('Serveur mobile impossible à démarrer', name: 'caissedz.mobile', error: e, stackTrace: pile);
      state = EtatMobile(erreur: '$e');
    }
  }

  /// Nouveau QR personnel de l'utilisateur connecté (et adresses relues : le Wi-Fi a pu changer).
  Future<void> nouveauQr() async {
    if (!_serveur.demarre) return demarrer();
    final utilisateur = ref.read(sessionProvider)?.utilisateur;
    if (utilisateur == null) return;
    final code = _serveur.nouveauCodeAppairage(utilisateur.code);
    final adresses = await ServeurMobile.adressesLocales();
    final boutique = (await BoutiqueRepository(ref.read(appDatabaseProvider).db).lire())?.nom ?? 'CaisseDZ';
    state = EtatMobile(
      actif: true,
      port: _serveur.port,
      adresses: adresses,
      qr: ServeurMobile.contenuQr(
        adresses: adresses,
        port: _serveur.port!,
        code: code.code,
        boutique: boutique,
        utilisateur: utilisateur.nomComplet.isEmpty ? utilisateur.identifiant : utilisateur.nomComplet,
      ),
      qrUtilisateur: utilisateur.code,
      expireLe: code.expireLe,
    );
  }

  Future<void> arreter() async {
    await _serveur.arreter();
    await ref.read(parametresAppRepositoryProvider).ecrire(cleActif, '0');
    state = EtatMobile.arrete;
  }

  /// Révoque un téléphone : il devra être appairé de nouveau.
  Future<void> revoquer(String code) async {
    await MobileRepository(ref.read(appDatabaseProvider).db).revoquer(code);
    _serveur.fermerSessionsAppareil(code);
    ref.read(appareilsVersionProvider.notifier).incrementer();
  }
}

final mobileProvider = NotifierProvider<MobileNotifier, EtatMobile>(MobileNotifier.new);

/// Dernière facture photographiée reçue du téléphone (chaque réception notifie, même bon ou non).
class FactureMobileNotifier extends Notifier<FactureMobile?> {
  @override
  FactureMobile? build() => null;

  void recue(FactureMobile f) => state = f;
}

final factureMobileProvider = NotifierProvider<FactureMobileNotifier, FactureMobile?>(FactureMobileNotifier.new);

final appareilsVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

/// Téléphones appairés : tous pour l'Admin, sinon ceux de l'utilisateur connecté.
final appareilsMobilesProvider = FutureProvider<List<AppareilMobile>>((ref) {
  ref.watch(appareilsVersionProvider);
  final session = ref.watch(sessionProvider);
  if (session == null) return const <AppareilMobile>[];
  return MobileRepository(ref.watch(appDatabaseProvider).db)
      .appareils(utilisateurCode: session.estAdmin ? null : session.utilisateur.code);
});

/// Téléphones connectés en ce moment (requête récente) ; relu à chaque changement des appareils.
final appareilsConnectesProvider = Provider<Set<String>>((ref) {
  ref.watch(appareilsVersionProvider);
  return ref.watch(serveurMobileProvider).appareilsConnectes();
});

/// Noms des utilisateurs (code → nom complet), pour « dernier utilisateur » des téléphones.
final nomsUtilisateursProvider = FutureProvider<Map<String, String>>((ref) async {
  ref.watch(appareilsVersionProvider);
  return {for (final u in await UtilisateurRepository(ref.watch(appDatabaseProvider).db).tous()) u.code: u.nomComplet};
});
