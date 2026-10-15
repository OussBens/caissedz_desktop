import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/modules.dart';
import '../features/activation/activation_page.dart';
import '../features/caisse/pos_page.dart';
import '../features/connexion/connexion_page.dart';
import '../features/entrees/entrees_page.dart';
import '../features/galerie/galerie_page.dart';
import '../features/gestion_caisse/gestion_caisse_page.dart';
import '../features/historique/historique_page.dart';
import '../features/parametres/parametres_page.dart';
import '../features/produits/produits_page.dart';
import '../features/retours/retours_page.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/module_placeholder_page.dart';
import '../features/stock/besoins_page.dart';
import '../features/stock/magasins_page.dart';
import '../features/stock/sorties_page.dart';
import '../features/stock/stock_page.dart';
import '../features/tableau_bord/tableau_bord_page.dart';
import '../features/tiers/tiers_page.dart';
import '../features/utilisateurs/utilisateurs_page.dart';
import '../features/ventes/ventes_page.dart';
import '../features/zakat/zakat_page.dart';
import 'demarrage_providers.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Écran ouvert après la connexion (§4.5 : redirection vers la caisse).
const String routeAccueil = '/caisse';

/// Route initiale (surchargée dans les tests).
final routeInitialeProvider = Provider<String>((ref) => routeAccueil);

/// Routes hors shell (avant connexion).
const Set<String> routesDemarrage = {ActivationPage.route, ConnexionPage.route};

/// Redirections (§5.1) : non connecté → connexion (activation si l'application n'est pas activée,
/// la connexion restant accessible pour demo / demo) ; connecté vers la connexion → caisse.
/// L'activation reste accessible une fois connecté (sortie du mode démo, Paramètres › Licence).
String? redirigerDemarrage({required bool activee, required bool connecte, required String cible}) {
  if (!connecte) {
    if (routesDemarrage.contains(cible)) return null;
    return activee ? ConnexionPage.route : ActivationPage.route;
  }
  if (cible == ConnexionPage.route) return routeAccueil;
  return null;
}

GoRouter construireRouter(Ref ref, {String routeInitiale = routeAccueil}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: routeInitiale,
    refreshListenable: ref.read(demarrageListenableProvider),
    redirect: (context, state) => redirigerDemarrage(
      activee: ref.read(licenceProvider).estActivee,
      connecte: ref.read(sessionProvider) != null,
      cible: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: ActivationPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ActivationPage()),
      ),
      GoRoute(
        path: ConnexionPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ConnexionPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          for (final module in [...Modules.tous, ...Modules.rattachees])
            GoRoute(
              path: module.route,
              name: module.id,
              pageBuilder: (context, state) => NoTransitionPage(key: ValueKey(module.id), child: pageModule(module)),
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
  'parametres' => const ParametresPage(),
  'tableau_bord' => const TableauBordPage(),
  'situation' => const TableauBordPage(ongletInitial: 1),
  'zakat' => const ZakatPage(),
  'historique' => const HistoriquePage(),
  'caisse' => const PosPage(),
  'entrees' => const EntreesPage(),
  'gestion_caisse' => const GestionCaissePage(),
  'clotures' => const GestionCaissePage(ongletInitial: 2),
  'ventes' => const VentesPage(),
  'retours' => const RetoursPage(),
  'clients' => const ClientsPage(),
  'fournisseurs' => const FournisseursPage(),
  'versements' => const ClientsPage(ongletInitial: 1),
  'produits' => const ProduitsPage(),
  'stock' => const StockPage(),
  'magasins' => const MagasinsPage(),
  'transferts' => const MagasinsPage(ongletInitial: 1),
  'besoins' => const BesoinsPage(),
  'sorties' => const SortiesPage(),
  'utilisateurs' => const UtilisateursPage(),
  _ => ModulePlaceholderPage(module: module),
};

final routerProvider = Provider<GoRouter>(
  (ref) => construireRouter(ref, routeInitiale: ref.read(routeInitialeProvider)),
);
