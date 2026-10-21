import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import '../domain/modules.dart';
import '../features/activation/activation_page.dart';
import '../features/caisse/pos_page.dart';
import '../features/commercial/commandes_fournisseurs_page.dart';
import '../features/commercial/documents_page.dart';
import '../features/compte_bens/compte_bens_pages.dart';
import '../features/connexion/connexion_page.dart';
import '../features/entrees/entrees_page.dart';
import '../features/galerie/galerie_page.dart';
import '../features/gestion_caisse/gestion_caisse_page.dart';
import '../features/historique/historique_page.dart';
import '../features/offres/offres_page.dart';
import '../features/parametres/parametres_page.dart';
import '../features/produits/produits_page.dart';
import '../features/retours/retours_page.dart';
import '../features/shell/app_shell.dart';
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

/// Routes hors shell (avant connexion) : formules, compte BENS, clé, connexion locale.
const Set<String> routesDemarrage = {
  OffresPage.route,
  InscriptionPage.route,
  ConnexionComptePage.route,
  MotDePasseOubliePage.route,
  ActivationPage.route,
  ConnexionPage.route,
};

/// Écran ouvert après la connexion en lecture seule (la caisse est en pause).
const String routeAccueilLectureSeule = '/tableau-de-bord';

/// Redirections (§5.1) : sans licence sur ce poste (premier lancement, licence retirée) → les formules ;
/// avec une licence valable, ou en lecture seule (essai terminé), non connecté → la connexion locale ;
/// connecté vers la connexion → caisse (tableau de bord en lecture seule). Les formules et la clé restent
/// accessibles une fois connecté (mise à niveau, Paramètres › Licence).
String? redirigerDemarrage({
  required bool activee,
  required bool connecte,
  required String cible,
  bool lectureSeule = false,
}) {
  if (!connecte) {
    if (cible == ConnexionPage.route) return activee ? null : OffresPage.route;
    if (routesDemarrage.contains(cible)) return null;
    return activee ? ConnexionPage.route : OffresPage.route;
  }
  if (cible == ConnexionPage.route) return lectureSeule ? routeAccueilLectureSeule : routeAccueil;
  return null;
}

GoRouter construireRouter(Ref ref, {String routeInitiale = routeAccueil}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: routeInitiale,
    refreshListenable: ref.read(demarrageListenableProvider),
    redirect: (context, state) => redirigerDemarrage(
      activee: ref.read(licenceProvider).peutOuvrir,
      lectureSeule: ref.read(licenceProvider).lectureSeule,
      connecte: ref.read(sessionProvider) != null,
      cible: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: OffresPage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: OffresPage()),
      ),
      GoRoute(
        path: InscriptionPage.route,
        pageBuilder: (c, s) => NoTransitionPage(
          key: s.pageKey,
          child: InscriptionPage(offre: s.uri.queryParameters['offre']),
        ),
      ),
      GoRoute(
        path: ConnexionComptePage.route,
        pageBuilder: (c, s) => const NoTransitionPage(child: ConnexionComptePage()),
      ),
      GoRoute(
        path: MotDePasseOubliePage.route,
        pageBuilder: (c, s) => NoTransitionPage(
          key: s.pageKey,
          child: MotDePasseOubliePage(telephone: s.uri.queryParameters['telephone']),
        ),
      ),
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
              // `?onglet=` et `?q=` (recherche globale) : onglet à ouvrir et recherche pré-remplie dans la liste.
              pageBuilder: (context, state) => NoTransitionPage(
                key: ValueKey('${module.id}?${state.uri.query}'),
                child: DsRechercheInitiale(
                  texte: state.uri.queryParameters['q'],
                  child: pageModule(module, onglet: int.tryParse(state.uri.queryParameters['onglet'] ?? '')),
                ),
              ),
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

/// Page d'un module (17 modules + pages rattachées ouvertes sur l'onglet de leur module parent).
Widget pageModule(ModuleApp module, {int? onglet}) => switch (module.id) {
  'parametres' => const ParametresPage(),
  'tableau_bord' => const TableauBordPage(),
  'situation' => const TableauBordPage(ongletInitial: 1),
  'zakat' => const ZakatPage(),
  'historique' => const HistoriquePage(),
  'caisse' => const PosPage(),
  'entrees' => EntreesPage(ongletInitial: onglet ?? 0),
  'gestion_caisse' => const GestionCaissePage(),
  'clotures' => const GestionCaissePage(ongletInitial: 2),
  'ventes' => VentesPage(ongletInitial: onglet ?? 0),
  'documents' => DocumentsPage(ongletInitial: onglet ?? 0),
  'commandes_fournisseurs' => const CommandesFournisseursPage(),
  'retours' => RetoursPage(ongletInitial: onglet ?? 0),
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
  _ => throw ArgumentError.value(module.id, 'module', 'Module inconnu'),
};

final routerProvider = Provider<GoRouter>(
  (ref) => construireRouter(ref, routeInitiale: ref.read(routeInitialeProvider)),
);
