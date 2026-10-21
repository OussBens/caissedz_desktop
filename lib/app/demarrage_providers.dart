import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/alertes_service.dart';
import '../application/auth_service.dart';
import '../application/catalogue_rayons_service.dart';
import '../application/configuration_initiale_service.dart';
import '../application/licence_service.dart';
import '../application/tendance_service.dart';
import '../core/catalogue/catalogue_rayons_api.dart';
import '../core/licence/compte_bens_api.dart';
import '../domain/models/licence.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import '../features/produits/produits_providers.dart' show catalogueVersionProvider, httpClientProvider;
import 'providers.dart';

final licenceServiceProvider = Provider<LicenceService>(
  (ref) => LicenceService(ref.watch(appDatabaseProvider).db, api: CompteBensApi(client: ref.watch(httpClientProvider))),
);
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(appDatabaseProvider).db));
final configurationServiceProvider = Provider<ConfigurationInitialeService>(
  (ref) => ConfigurationInitialeService(ref.watch(appDatabaseProvider).db),
);
final alertesServiceProvider = Provider<AlertesService>((ref) => AlertesService(ref.watch(appDatabaseProvider).db));

/// Ventes et noms arabes envoyés au catalogue BENS (tendance), authentifiés par la licence du poste.
final tendanceServiceProvider = Provider<TendanceService>(
  (ref) => TendanceService(
    ref.watch(appDatabaseProvider).db,
    client: ref.watch(httpClientProvider),
    identite: ref.watch(licenceServiceProvider).identiteSmartScan,
  ),
);

/// Séquence post-connexion (§4.5) activée ? Les tests de widgets la désactivent (`pumpApp(sequence: false)`).
final sequencePostConnexionProvider = Provider<bool>((ref) => true);

/// Licence courante (chargée au démarrage, vérifiée hors ligne) et compte BENS du poste.
class LicenceNotifier extends Notifier<Licence> {
  @override
  Licence build() => Licence.aucune;

  LicenceService get _service => ref.read(licenceServiceProvider);

  Future<void> charger() async => state = await _service.lire();

  /// Check-in auprès de BENS (au lancement, sans bloquer l'ouverture) : licence et droits à jour.
  Future<void> synchroniser() async => state = await _service.synchroniser();

  /// Active une clé collée (reçue sur WhatsApp).
  Future<Licence> activer(String cle) async => state = await _service.activer(cle);

  /// Crée le compte BENS avec l'offre choisie (son essai commence). Vrai si l'essai a été donné.
  Future<bool> inscrire({
    required String telephone,
    required String nom,
    required String commerce,
    required String motDePasse,
    required String offre,
  }) async {
    final r = await _service.inscrire(
      telephone: telephone,
      nom: nom,
      commerce: commerce,
      motDePasse: motDePasse,
      offre: offre,
    );
    state = r.licence;
    return r.essaiDonne;
  }

  Future<Licence> connecterCompte({required String telephone, required String motDePasse}) async =>
      state = await _service.connecter(telephone: telephone, motDePasse: motDePasse);

  Future<Licence> reinitialiser({required String telephone, required String code, required String motDePasse}) async =>
      state = await _service.reinitialiser(telephone: telephone, code: code, motDePasse: motDePasse);

  /// Déconnecte le poste du compte BENS ; une session locale ouverte est fermée si la licence part avec.
  Future<void> deconnecterCompte() async {
    state = await _service.deconnecterCompte();
    if (!state.estActivee && ref.read(sessionProvider) != null) await ref.read(sessionProvider.notifier).deconnecter();
  }
}

final licenceProvider = NotifierProvider<LicenceNotifier, Licence>(LicenceNotifier.new);

/// Les offres de CaisseDZ Desktop et la durée de l'essai (bensds.com ; hors ligne : les paliers connus).
final offresBensProvider = FutureProvider<OffresBens>((ref) => ref.watch(licenceServiceProvider).offres());

/// Configuration initiale terminée ? (proposée à l'administrateur après sa connexion, §4.5).
class ConfigurationNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> charger() async => state = await ref.read(configurationServiceProvider).estTerminee();

  Future<void> terminer(ConfigurationInitiale c) async {
    final code = ref.read(sessionProvider)?.utilisateur.code ?? '';
    await ref.read(configurationServiceProvider).terminer(c, utilisateurCode: code);
    state = true;
  }
}

final configurationTermineeProvider = NotifierProvider<ConfigurationNotifier, bool>(ConfigurationNotifier.new);

/// Séquence post-connexion à dérouler par le shell (configuration → alertes, puis la Caisse).
class SequenceNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void demander() => state = ref.read(sequencePostConnexionProvider);
  void terminer() => state = false;
}

final sequenceEnAttenteProvider = NotifierProvider<SequenceNotifier, bool>(SequenceNotifier.new);

/// Les comptes de ce poste proposés à l'écran de connexion (AuthService.comptesConnexion).
final comptesConnexionProvider = FutureProvider.autoDispose<List<Utilisateur>>(
  (ref) => ref.read(authServiceProvider).comptesConnexion(),
);

/// Session de l'utilisateur connecté (`null` = personne).
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  static const String cleSessionMemorisee = 'session_memorisee';

  /// Connexion (§4.4), seulement avec une licence valable sur ce poste (essai en cours ou palier acheté).
  Future<Session> connecter(String identifiant, String motDePasse, {bool resterConnecte = false}) async {
    if (!ref.read(licenceProvider).peutOuvrir) throw const ConnexionException(ErreurConnexion.nonActivee);
    final s = await ref
        .read(authServiceProvider)
        .connecter(identifiant, motDePasse, telephoneCompte: ref.read(licenceProvider).compte?.telephone);
    await _memoriser(resterConnecte ? s.utilisateur.code : null);
    await _ouvrir(s);
    return s;
  }

  /// « Rester connecté » (§4.1) : reprend la session mémorisée au démarrage. `false` si aucune.
  Future<bool> reprendre() async {
    final code = await ref.read(parametresAppRepositoryProvider).lire(cleSessionMemorisee);
    if (code == null || code.isEmpty || !ref.read(licenceProvider).peutOuvrir) return false;
    final s = await ref.read(authServiceProvider).reprendreSession(code);
    if (s == null) {
      await _memoriser(null);
      return false;
    }
    await _ouvrir(s);
    return true;
  }

  /// Juste après l'inscription ou la connexion au compte BENS sur un poste neuf : la session de
  /// l'administrateur local, qui prend le mot de passe du compte. Faux s'il était déjà configuré
  /// (l'écran de connexion habituel suit).
  Future<bool> ouvrirAdminInitial({required String nom, required String motDePasse}) async {
    if (!ref.read(licenceProvider).estActivee) return false;
    final s = await ref.read(authServiceProvider).ouvrirAdminInitial(nom: nom, motDePasse: motDePasse);
    if (s == null) return false;
    await _ouvrir(s);
    return true;
  }

  /// Après la réinitialisation du mot de passe du compte BENS (code donné par BENS) : l'administrateur
  /// du compte prend le nouveau mot de passe et sa session s'ouvre. Faux sans administrateur actif.
  Future<bool> ouvrirAdminReinitialise(String motDePasse) async {
    if (!ref.read(licenceProvider).estActivee) return false;
    final s = await ref.read(authServiceProvider).ouvrirAdminReinitialise(motDePasse);
    if (s == null) return false;
    await _ouvrir(s);
    return true;
  }

  Future<void> deconnecter() async {
    final code = state?.utilisateur.code;
    state = null;
    ref.read(favorisProvider.notifier).reinitialiser();
    ref.read(magasinCourantProvider.notifier).reinitialiser();
    ref.read(alertesProvider.notifier).reinitialiser();
    ref.read(sequenceEnAttenteProvider.notifier).terminer();
    await _memoriser(null);
    if (code != null) await ref.read(authServiceProvider).deconnecter(code);
  }

  void mettreAJourUtilisateur(Utilisateur u) => state = state?.copyWith(utilisateur: u);

  /// Ordre du §4.4 : droits (session) → favoris → magasins → alertes, puis séquence du §4.5.
  Future<void> _ouvrir(Session s) async {
    state = s;
    await ref.read(favorisProvider.notifier).charger();
    await ref.read(magasinCourantProvider.notifier).charger();
    await ref.read(alertesProvider.notifier).charger();
    ref.read(sequenceEnAttenteProvider.notifier).demander();
  }

  Future<void> _memoriser(String? code) => ref.read(parametresAppRepositoryProvider).ecrire(cleSessionMemorisee, code);
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

/// Permission de l'utilisateur connecté (false sans session).
final permissionProvider = Provider.family<bool, Permission>((ref, p) => ref.watch(sessionProvider)?.a(p) ?? false);

/// Niveau de licence courant couvre-t-il [requis] ?
final licenceCouvreProvider = Provider.family<bool, NiveauLicence>(
  (ref, requis) => ref.watch(licenceProvider).couvre(requis),
);

/// Notifie le routeur quand l'état de démarrage change (licence, session).
class DemarrageListenable extends ChangeNotifier {
  DemarrageListenable(Ref ref) {
    for (final p in [licenceProvider, sessionProvider]) {
      ref.listen<Object?>(p, (_, _) => notifyListeners());
    }
  }
}

final demarrageListenableProvider = Provider<DemarrageListenable>((ref) {
  final l = DemarrageListenable(ref);
  ref.onDispose(l.dispose);
  return l;
});

/// Charge l'état persistant au démarrage (licence, configuration, session mémorisée), puis fait le
/// check-in du compte BENS en arrière-plan (hors ligne, la licence gardée suffit).
Future<void> chargerEtatDemarrage(ProviderContainer c, {bool synchroniser = true}) async {
  await c.read(licenceProvider.notifier).charger();
  await c.read(configurationTermineeProvider.notifier).charger();
  if (c.read(sessionProvider) == null) await c.read(sessionProvider.notifier).reprendre();
  if (synchroniser) unawaited(synchroniserAuLancement(c));
}

/// En arrière-plan au lancement : check-in du compte BENS, puis tendance du catalogue (ventes et noms arabes
/// envoyés, produits devenus tendance ajoutés aux rayons téléchargés). Hors ligne, chaque étape attend le
/// lancement suivant sans gêner les autres.
Future<void> synchroniserAuLancement(ProviderContainer c) async {
  await c.read(licenceProvider.notifier).synchroniser();
  if (!c.read(licenceProvider).estActivee) return;
  await c.read(tendanceServiceProvider).envoyer();
  try {
    final r = await CatalogueRayonsService(
      c.read(appDatabaseProvider).db,
      api: CatalogueRayonsApi(client: c.read(httpClientProvider)),
      utilisateurCode: '',
    ).actualiserTendances();
    if (r.ajoutes > 0 || r.nomsAr > 0) c.read(catalogueVersionProvider.notifier).incrementer();
  } on CatalogueRayonsException {
    // Catalogue injoignable : au prochain lancement.
  }
}
