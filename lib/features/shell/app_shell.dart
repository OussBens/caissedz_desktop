import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';
import '../galerie/galerie_page.dart';
import 'modules_menu.dart';
import 'sidebar.dart';
import 'title_bar.dart';

/// Intention « ouvrir le menu des modules » (Ctrl+M).
class OuvrirMenuModulesIntent extends Intent {
  const OuvrirMenuModulesIntent();
}

/// Coque de l'application : barre latérale + barre de titre + contenu.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final l10n = AppLocalizations.of(context);
    final controlesFenetre = ref.watch(controlesFenetreProvider);
    final route = GoRouterState.of(context).uri.path;
    final module = Modules.tous.where((m) => m.route == route).firstOrNull;
    final titre = module?.libelle(l10n) ?? (route == GaleriePage.route ? l10n.galerieTitre : l10n.appTitle);

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyM, control: true): OuvrirMenuModulesIntent(),
      },
      child: Actions(
        actions: {
          OuvrirMenuModulesIntent: CallbackAction<OuvrirMenuModulesIntent>(
            onInvoke: (_) => afficherMenuModules(context),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: c.fond,
            body: Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      TitleBar(titre: titre, controlesFenetre: controlesFenetre),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
