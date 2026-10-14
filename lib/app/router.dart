import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/modules.dart';
import '../features/galerie/galerie_page.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/module_placeholder_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter construireRouter({String routeInitiale = '/tableau-de-bord'}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: routeInitiale,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          for (final module in Modules.tous)
            GoRoute(
              path: module.route,
              name: module.id,
              pageBuilder: (context, state) => NoTransitionPage(
                key: ValueKey(module.id),
                child: ModulePlaceholderPage(module: module),
              ),
            ),
          GoRoute(
            path: GaleriePage.route,
            name: 'galerie',
            pageBuilder: (context, state) => const NoTransitionPage(child: GaleriePage()),
          ),
        ],
      ),
    ],
  );
}
