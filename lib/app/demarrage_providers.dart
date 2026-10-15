import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/alertes_service.dart';
import '../application/auth_service.dart';
import '../application/configuration_initiale_service.dart';
import '../application/licence_service.dart';
import '../domain/models/licence.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import 'providers.dart';

final licenceServiceProvider = Provider<LicenceService>((ref) => LicenceService(ref.watch(appDatabaseProvider).db));
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(appDatabaseProvider).db));
final configurationServiceProvider = Provider<ConfigurationInitialeService>(
  (ref) => ConfigurationInitialeService(ref.watch(appDatabaseProvider).db),
);
final alertesServiceProvider = Provider<AlertesService>((ref) => AlertesService(ref.watch(appDatabaseProvider).db));

/// Séquence post-connexion (§4.5) activée ? Les tests de widgets la désactivent (`pumpApp(sequence: false)`).
final sequencePostConnexionProvider = Provider<bool>((ref) => true);

/// Licence courante (chargée au démarrage).
class LicenceNotifier extends Notifier<Licence> {
  @override
  Licence build() => Licence.aucune;

  Future<void> charger() async => state = await ref.read(licenceServiceProvider).lire();

  /// Active une clé. Une session ouverte en mode démo est fermée : le compte demo/demo
  /// n'est plus utilisable une fois la vraie licence active.
  Future<Licence> activer(String cle) async {
    final l = await ref.read(licenceServiceProvider).activer(cle);
    state = l;
    if (ref.read(sessionProvider)?.demo ?? false) await ref.read(sessionProvider.notifier).deconnecter();
    return l;
  }

  Future<Licence> activerDemo() async {
    final l = await ref.read(licenceServiceProvider).activerDemo();
    state = l;
    return l;
  }
}

final licenceProvider = NotifierProvider<LicenceNotifier, Licence>(LicenceNotifier.new);

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

/// Séquence post-connexion à dérouler par le shell (configuration → alertes → menu des modules).
class SequenceNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void demander() => state = ref.read(sequencePostConnexionProvider);
  void terminer() => state = false;
}

final sequenceEnAttenteProvider = NotifierProvider<SequenceNotifier, bool>(SequenceNotifier.new);

/// Session de l'utilisateur connecté (`null` = personne).
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  static const String cleSessionMemorisee = 'session_memorisee';

  /// Connexion (§4.4). Application non activée : demo / demo active le mode démo (§4.3).
  Future<Session> connecter(String identifiant, String motDePasse, {bool resterConnecte = false}) async {
    if (!ref.read(licenceProvider).estActivee && AuthService.estIdentifiantDemo(identifiant)) {
      await ref.read(licenceProvider.notifier).activerDemo();
    }
    final s = await ref.read(authServiceProvider).connecter(identifiant, motDePasse);
    await _memoriser(resterConnecte ? s.utilisateur.code : null);
    await _ouvrir(s);
    return s;
  }

  /// « Rester connecté » (§4.1) : reprend la session mémorisée au démarrage. `false` si aucune.
  Future<bool> reprendre() async {
    final code = await ref.read(parametresAppRepositoryProvider).lire(cleSessionMemorisee);
    if (code == null || code.isEmpty) return false;
    final s = await ref.read(authServiceProvider).reprendreSession(code);
    if (s == null) {
      await _memoriser(null);
      return false;
    }
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

/// Charge l'état persistant au démarrage (licence, configuration, session mémorisée).
Future<void> chargerEtatDemarrage(ProviderContainer c) async {
  await c.read(licenceProvider.notifier).charger();
  await c.read(configurationTermineeProvider.notifier).charger();
  if (c.read(sessionProvider) == null) await c.read(sessionProvider.notifier).reprendre();
}
