import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/favoris_service.dart';
import '../core/db/app_database.dart';
import '../data/favoris_repository.dart';
import '../data/parametres_repository.dart';
import '../data/stock_repository.dart';
import '../domain/models/alerte.dart';
import '../domain/models/stock.dart';
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
  (ref) => [for (final id in ref.watch(favorisProvider)) ...Modules.tous.where((m) => m.id == id)],
);

/// Alertes du jour de l'utilisateur connecté (§5.3), recalculées à la connexion et à l'ouverture du dialog.
class AlertesNotifier extends Notifier<AlertesDuJour> {
  @override
  AlertesDuJour build() => AlertesDuJour.vide;

  Future<AlertesDuJour> charger() async {
    final session = ref.read(sessionProvider);
    state = session == null ? AlertesDuJour.vide : await ref.read(alertesServiceProvider).calculer(session);
    return state;
  }

  void reinitialiser() => state = AlertesDuJour.vide;
}

final alertesProvider = NotifierProvider<AlertesNotifier, AlertesDuJour>(AlertesNotifier.new);

/// Magasins accessibles à l'utilisateur connecté et magasin courant (§6.3 : le premier est le principal ;
/// l'Admin voit tous les magasins, les siens d'abord).
@immutable
class MagasinsSession {
  const MagasinsSession({this.magasins = const [], this.courant});
  static const MagasinsSession aucun = MagasinsSession();
  final List<Magasin> magasins;
  final String? courant;

  Magasin? get magasinCourant => magasins.where((m) => m.code == courant).firstOrNull;
}

class MagasinCourantNotifier extends Notifier<MagasinsSession> {
  @override
  MagasinsSession build() => MagasinsSession.aucun;

  Future<void> charger() async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      state = MagasinsSession.aucun;
      return;
    }
    final repo = StockRepository(ref.read(appDatabaseProvider).db);
    final actifs = await repo.magasins(actifsSeulement: true);
    final siens = await repo.magasinsUtilisateur(session.utilisateur.code);
    final ordonnes = [
      for (final c in siens) ...actifs.where((m) => m.code == c),
      if (session.estAdmin) ...actifs.where((m) => !siens.contains(m.code)),
    ];
    final liste = ordonnes.isEmpty && session.estAdmin ? actifs : ordonnes;
    state = MagasinsSession(magasins: liste, courant: liste.firstOrNull?.code);
  }

  void changer(String code) {
    if (state.magasins.any((m) => m.code == code)) state = MagasinsSession(magasins: state.magasins, courant: code);
  }

  void reinitialiser() => state = MagasinsSession.aucun;
}

final magasinCourantProvider = NotifierProvider<MagasinCourantNotifier, MagasinsSession>(MagasinCourantNotifier.new);

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
