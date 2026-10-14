import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_service.dart';
import '../application/configuration_initiale_service.dart';
import '../application/licence_service.dart';
import '../application/permission_service.dart';
import '../domain/models/licence.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import 'providers.dart';

final licenceServiceProvider = Provider<LicenceService>((ref) => LicenceService(ref.watch(appDatabaseProvider).db));
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(appDatabaseProvider).db));
final configurationServiceProvider =
    Provider<ConfigurationInitialeService>((ref) => ConfigurationInitialeService(ref.watch(appDatabaseProvider).db));
final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService(ref.watch(appDatabaseProvider).db));

/// Licence courante (chargée au démarrage).
class LicenceNotifier extends Notifier<Licence> {
  @override
  Licence build() => Licence.aucune;

  Future<void> charger() async => state = await ref.read(licenceServiceProvider).lire();

  Future<Licence> activer(String cle) async {
    final l = await ref.read(licenceServiceProvider).activer(cle);
    state = l;
    return l;
  }

  Future<Licence> activerDemo() async {
    final l = await ref.read(licenceServiceProvider).activerDemo();
    state = l;
    return l;
  }
}

final licenceProvider = NotifierProvider<LicenceNotifier, Licence>(LicenceNotifier.new);

/// Configuration initiale terminée ?
class ConfigurationNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> charger() async => state = await ref.read(configurationServiceProvider).estTerminee();

  Future<void> terminer(ConfigurationInitiale c) async {
    await ref.read(configurationServiceProvider).terminer(c);
    state = true;
  }
}

final configurationTermineeProvider = NotifierProvider<ConfigurationNotifier, bool>(ConfigurationNotifier.new);

/// Session de l'utilisateur connecté (`null` = personne).
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  Future<Session> connecter(String identifiant, String motDePasse) async {
    final s = await ref.read(authServiceProvider).connecter(identifiant, motDePasse);
    state = s;
    await ref.read(favorisProvider.notifier).charger();
    return s;
  }

  void deconnecter() {
    state = null;
    ref.read(favorisProvider.notifier).reinitialiser();
  }

  void mettreAJourUtilisateur(Utilisateur u) => state = state?.copyWith(utilisateur: u);
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

/// Permission de l'utilisateur connecté (false sans session).
final permissionProvider = Provider.family<bool, Permission>((ref, p) => ref.watch(sessionProvider)?.a(p) ?? false);

/// Niveau de licence courant couvre-t-il [requis] ?
final licenceCouvreProvider =
    Provider.family<bool, NiveauLicence>((ref, requis) => ref.watch(licenceProvider).couvre(requis));

/// Notifie le routeur quand l'état de démarrage change (licence, configuration, session).
class DemarrageListenable extends ChangeNotifier {
  DemarrageListenable(Ref ref) {
    for (final p in [licenceProvider, configurationTermineeProvider, sessionProvider]) {
      ref.listen<Object?>(p, (_, _) => notifyListeners());
    }
  }
}

final demarrageListenableProvider = Provider<DemarrageListenable>((ref) {
  final l = DemarrageListenable(ref);
  ref.onDispose(l.dispose);
  return l;
});

/// Charge l'état persistant au démarrage (licence, configuration).
Future<void> chargerEtatDemarrage(ProviderContainer c) async {
  await c.read(licenceProvider.notifier).charger();
  await c.read(configurationTermineeProvider.notifier).charger();
}
