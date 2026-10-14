import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/modules.dart';
import '../features/activation/activation_page.dart';
import '../features/caisse/pos_page.dart';
import '../features/compte/mon_compte_page.dart';
import '../features/configuration/configuration_page.dart';
import '../features/connexion/connexion_page.dart';
import '../features/galerie/galerie_page.dart';
import '../features/produits/produits_page.dart';
import '../features/roles/roles_page.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/module_placeholder_page.dart';
import '../features/shell/parametres_accueil_page.dart';
import '../features/stock/besoins_page.dart';
import '../features/stock/magasins_page.dart';
import '../features/stock/sorties_page.dart';
import '../features/stock/stock_page.dart';
import '../features/stock/transferts_page.dart';
import 'demarrage_providers.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const String routeAccueil = '/tableau-de-bord';

/// Route initiale (surchargée dans les tests).
final routeInitialeProvider = Provider<String>((ref) => routeAccueil);

/// Routes hors shell (avant connexion).
const Set<String> routesDemarrage = {ActivationPage.route, ConfigurationPage.route, ConnexionPage.route};

/// Redirection selon l'état : activation → configuration → connexion → application.
String? redirigerDemarrage({
  required bool activee,
  required bool configuree,
  required bool connecte,
  required String cible,
}) {
  if (!activee) return cible == ActivationPage.route ? null : ActivationPage.route;
  if (!configuree) return cible == ConfigurationPage.route ? null : ConfigurationPage.route;
  if (!connecte) return cible == ConnexionPage.route ? null : ConnexionPage.route;
  if (routesDemarrage.contains(cible)) return routeAccueil;
  return null;
}

GoRouter construireRouter(Ref ref, {String routeInitiale = routeAccueil}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: routeInitiale,
    refreshListenable: ref.read(demarrageListenableProvider),
    redirect: (context, state) => redirigerDemarrage(
      activee: ref.read(licenceProvider).estActivee,
      configuree: ref.read(configurationTermineeProvider),
      connecte: ref.read(sessionProvider) != null,
      cible: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: ActivationPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ActivationPage()),
      ),
      GoRoute(
        path: ConfigurationPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ConfigurationPage()),
      ),
      GoRoute(
        path: ConnexionPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ConnexionPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          for (final module in Modules.tous)
            GoRoute(
              path: module.route,
              name: module.id,
              pageBuilder: (context, state) => NoTransitionPage(key: ValueKey(module.id), child: pageModule(module)),
            ),
          GoRoute(
            path: RolesPage.route,
            pageBuilder: (c, s) => const NoTransitionPage(child: RolesPage()),
          ),
          GoRoute(
            path: MonComptePage.route,
            pageBuilder: (c, s) => const NoTransitionPage(child: MonComptePage()),
          ),
          GoRoute(
            path: GaleriePage.route,
            name: 'galerie',
            pageBuilder: (c, s) => const NoTransitionPage(child: GaleriePage()),
          ),
        ],
      ),
    ],
  );
}

/// Page d'un module : écrans livrés par lot, sinon page provisoire.
Widget pageModule(ModuleApp module) => switch (module.id) {
  'parametres' => const ParametresAccueilPage(),
  'caisse' => const PosPage(),
  'produits' => const ProduitsPage(),
  'stock' => const StockPage(),
  'magasins' => const MagasinsPage(),
  'transferts' => const TransfertsPage(),
  'besoins' => const BesoinsPage(),
  'sorties' => const SortiesPage(),
  _ => ModulePlaceholderPage(module: module),
};

final routerProvider = Provider<GoRouter>(
  (ref) => construireRouter(ref, routeInitiale: ref.read(routeInitialeProvider)),
);
