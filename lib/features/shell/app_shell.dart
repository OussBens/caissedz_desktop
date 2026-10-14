import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';
import '../../domain/permissions.dart';
import '../activation/activation_page.dart';
import '../compte/mon_compte_page.dart';
import '../galerie/galerie_page.dart';
import '../roles/roles_page.dart';
import 'acces_refuse_page.dart';
import 'modules_menu.dart';
import 'sidebar.dart';
import 'title_bar.dart';

/// Intention « ouvrir le menu des modules » (Ctrl+M).
class OuvrirMenuModulesIntent extends Intent {
  const OuvrirMenuModulesIntent();
}

/// Coque de l'application : barre latérale + barre de titre + contenu.
///
/// Applique le contrôle d'accès : module interdit au rôle → écran « Accès
/// refusé » ; module réservé à la licence Avancé → [LicenceGate].
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final controlesFenetre = ref.watch(controlesFenetreProvider);
    final route = GoRouterState.of(context).uri.path;
    final module = Modules.tous.where((m) => m.route == route).firstOrNull;
    final session = ref.watch(sessionProvider);
    final licence = ref.watch(licenceProvider);
    final titre =
        module?.libelle(l10n) ??
        switch (route) {
          GaleriePage.route => l10n.galerieTitre,
          MonComptePage.route => l10n.compteTitre,
          RolesPage.route => l10n.rolesTitre,
          _ => l10n.appTitle,
        };

    Widget contenu = child;
    if (module != null && session != null && !session.peutAcceder(module.id)) {
      contenu = AccesRefusePage(role: libelleRole(l10n, session.utilisateur.role), module: module.libelle(l10n));
    } else if (route == RolesPage.route && session != null && !session.a(Permission.gererUtilisateurs)) {
      contenu = AccesRefusePage(role: libelleRole(l10n, session.utilisateur.role), module: l10n.rolesTitre);
    } else if (module != null) {
      contenu = LicenceGate(
        autorise: licence.couvre(module.niveauRequis),
        onActiverCle: () => context.push(ActivationPage.route),
        child: child,
      );
    }

    return Shortcuts(
      shortcuts: const {SingleActivator(LogicalKeyboardKey.keyM, control: true): OuvrirMenuModulesIntent()},
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
                      if (licence.demo)
                        Container(
                          key: const ValueKey('bandeau_demo'),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.lg, vertical: DsSpacing.xs),
                          color: c.avertissementDoux,
                          child: Row(
                            children: [
                              Icon(LucideIcons.flaskConical, size: DsTailles.iconeSm, color: c.avertissement),
                              const SizedBox(width: DsSpacing.sm),
                              Text(l10n.shellBandeauDemo, style: t.petitFort.copyWith(color: c.avertissement)),
                            ],
                          ),
                        ),
                      Expanded(child: contenu),
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
