import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/favoris_service.dart';
import '../core/db/app_database.dart';
import '../data/favoris_repository.dart';
import '../data/parametres_repository.dart';
import '../domain/modules.dart';
import 'demarrage_providers.dart';

/// Base de données ouverte au démarrage (surchargée dans `main` et les tests).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider doit être surchargé au démarrage');
});

final parametresAppRepositoryProvider = Provider<ParametresAppRepository>(
  (ref) => ParametresAppRepository(ref.watch(appDatabaseProvider).db),
);

final favorisServiceProvider = Provider<FavorisService>(
  (ref) => FavorisService(FavorisRepository(ref.watch(appDatabaseProvider).db)),
);

/// Code de l'utilisateur connecté (vide sans session) : clé des favoris.
final utilisateurCourantCodeProvider = Provider<String>((ref) => ref.watch(sessionProvider)?.utilisateur.code ?? '');

/// Contrôles natifs de la fenêtre (window_manager). Désactivé dans les tests.
final controlesFenetreProvider = Provider<bool>((ref) => true);

const List<Locale> localesSupportees = [Locale('fr'), Locale('ar'), Locale('en')];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('fr');

  Future<void> charger() async {
    final code = await ref.read(parametresAppRepositoryProvider).lire(ParametresAppRepository.cleLangue);
    if (code != null && localesSupportees.any((l) => l.languageCode == code)) {
      state = Locale(code);
    }
  }

  Future<void> changer(Locale locale) async {
    state = locale;
    await ref.read(parametresAppRepositoryProvider).ecrire(ParametresAppRepository.cleLangue, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  Future<void> charger() async {
    final v = await ref.read(parametresAppRepositoryProvider).lire(ParametresAppRepository.cleTheme);
    if (v == 'sombre') state = ThemeMode.dark;
    if (v == 'clair') state = ThemeMode.light;
  }

  Future<void> changer(ThemeMode mode) async {
    state = mode;
    await ref
        .read(parametresAppRepositoryProvider)
        .ecrire(ParametresAppRepository.cleTheme, mode == ThemeMode.dark ? 'sombre' : 'clair');
  }

  Future<void> basculer() => changer(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class SidebarReduiteNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> charger() async {
    final v = await ref.read(parametresAppRepositoryProvider).lire(ParametresAppRepository.cleSidebarReduite);
    state = v == '1';
  }

  Future<void> basculer() async {
    state = !state;
    await ref
        .read(parametresAppRepositoryProvider)
        .ecrire(ParametresAppRepository.cleSidebarReduite, state ? '1' : '0');
  }
}

final sidebarReduiteProvider = NotifierProvider<SidebarReduiteNotifier, bool>(SidebarReduiteNotifier.new);

/// Favoris (identifiants de modules, ordonnés, 7 maximum).
class FavorisNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  Future<void> charger() async {
    final code = ref.read(utilisateurCourantCodeProvider);
    state = code.isEmpty ? const [] : await ref.read(favorisServiceProvider).charger(code);
  }

  void reinitialiser() => state = const [];

  /// Retourne `false` si le maximum est atteint.
  Future<bool> ajouter(String moduleId) async {
    final nouvelle = FavorisService.ajouter(state, moduleId);
    if (nouvelle == null) return false;
    await _enregistrer(nouvelle);
    return true;
  }

  Future<void> retirer(String moduleId) => _enregistrer(FavorisService.retirer(state, moduleId));

  Future<bool> basculer(String moduleId) =>
      state.contains(moduleId) ? retirer(moduleId).then((_) => true) : ajouter(moduleId);

  Future<void> _enregistrer(List<String> favoris) async {
    state = favoris;
    await ref.read(favorisServiceProvider).enregistrer(ref.read(utilisateurCourantCodeProvider), favoris);
  }
}

final favorisProvider = NotifierProvider<FavorisNotifier, List<String>>(FavorisNotifier.new);

final favorisModulesProvider = Provider<List<ModuleApp>>(
  (ref) => ref.watch(favorisProvider).map(Modules.parId).whereType<ModuleApp>().toList(),
);

/// Alerte affichée dans le panneau d'alertes du shell.
@immutable
class Alerte {
  const Alerte({required this.id, required this.titre, this.detail, this.critique = false, this.route});
  final String id;
  final String titre;
  final String? detail;
  final bool critique;
  final String? route;
}

/// Alertes du shell (stock sous seuil, session ouverte… alimentées par les lots suivants).
class AlertesNotifier extends Notifier<List<Alerte>> {
  @override
  List<Alerte> build() => const [];

  void publier(Alerte alerte) => state = [...state.where((a) => a.id != alerte.id), alerte];
  void retirer(String id) => state = state.where((a) => a.id != id).toList();
  void vider() => state = const [];
}

final alertesProvider = NotifierProvider<AlertesNotifier, List<Alerte>>(AlertesNotifier.new);

/// Témoin Internet : sondage périodique d'une résolution DNS.
class InternetNotifier extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  void demarrer({Duration intervalle = const Duration(seconds: 30)}) {
    _timer?.cancel();
    unawaited(verifier());
    _timer = Timer.periodic(intervalle, (_) => verifier());
  }

  Future<void> verifier() async {
    bool ok;
    try {
      final r = await InternetAddress.lookup('dns.google').timeout(const Duration(seconds: 4));
      ok = r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on Object {
      ok = false;
    }
    if (ok != state) state = ok;
  }
}

final internetProvider = NotifierProvider<InternetNotifier, bool>(InternetNotifier.new);
