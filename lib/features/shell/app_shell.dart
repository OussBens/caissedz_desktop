import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/session.dart';
import '../../domain/modules.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../activation/activation_page.dart';
import '../compte/mon_compte_dialog.dart';
import '../configuration/configuration_dialog.dart';
import 'alertes_dialog.dart';
import 'controles_fenetre.dart';

/// Intention « ouvrir le menu des modules » (Ctrl+M).
class OuvrirMenuModulesIntent extends Intent {
  const OuvrirMenuModulesIntent();
}

/// Libellé du groupe de la barre latérale.
String libelleGroupe(AppLocalizations l10n, GroupeModule g) => switch (g) {
  GroupeModule.general => l10n.shellNavGeneral,
  GroupeModule.stock => l10n.shellNavStock,
  GroupeModule.tiers => l10n.shellNavTiers,
  GroupeModule.gestion => l10n.shellNavGestion,
};

/// Raison du verrouillage d'un module (licence puis rôle), `null` s'il est accessible.
String? verrouModule(AppLocalizations l10n, ModuleApp m, {required bool licenceCouvre, required Session? session}) {
  if (!licenceCouvre) return l10n.shellVerrouille;
  if (session != null && !session.peutAcceder(m.idAcces)) return l10n.shellAccesRestreint;
  return null;
}

/// Coque de l'application (DS v2.2 `AppShell`) : barre latérale (groupes, magasin, déconnexion) + barre
/// supérieure (menu des modules, favoris, témoin réseau, alertes, thème, compte, fenêtre) + module.
///
/// Contrôle d'accès : module interdit au rôle → « Accès refusé » ; module réservé au palier Avancé →
/// [LicenceGate]. Après la connexion, déroule la séquence du §4.5 : configuration initiale (1ʳᵉ fois),
/// alertes (s'il y en a), menu des modules.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _sequenceEnCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sequenceSiDemandee());
  }

  void _sequenceSiDemandee() {
    if (!mounted || _sequenceEnCours || !ref.read(sequenceEnAttenteProvider)) return;
    _derouler();
  }

  Future<void> _derouler() async {
    _sequenceEnCours = true;
    ref.read(sequenceEnAttenteProvider.notifier).terminer();
    try {
      final session = ref.read(sessionProvider);
      if (session == null) return;
      if (!ref.read(configurationTermineeProvider) && session.estAdmin) {
        await afficherConfigurationInitiale(context);
        if (!mounted) return;
      }
      final alertes = ref.read(alertesProvider);
      final masquees = await ref.read(alertesServiceProvider).estMasqueAujourdhui(session.utilisateur.code);
      if (!mounted) return;
      if (alertes.total > 0 && !masquees) {
        await afficherAlertes(context);
        if (!mounted) return;
      }
      if (ref.read(sessionProvider) != null) await afficherMenuModules(context);
    } finally {
      _sequenceEnCours = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(sequenceEnAttenteProvider, (_, enAttente) {
      if (enAttente) WidgetsBinding.instance.addPostFrameCallback((_) => _sequenceSiDemandee());
    });
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final route = GoRouterState.of(context).uri.path;
    final module = Modules.parRoute(route);
    final session = ref.watch(sessionProvider);
    final licence = ref.watch(licenceProvider);
    final locale = ref.watch(localeProvider);
    final favoris = ref.watch(favorisModulesProvider);
    final alertes = ref.watch(alertesProvider);
    final magasins = ref.watch(magasinCourantProvider);
    final routeActive = module == null ? route : (Modules.parId(module.idAcces) ?? module).route;

    bool visible(ModuleApp m) =>
        verrouModule(l10n, m, licenceCouvre: licence.couvre(m.niveauRequis), session: session) == null;
    final sections = [
      for (final g in GroupeModule.values)
        if (Modules.parGroupe(g).any(visible))
          DsNavSection(
            libelle: libelleGroupe(l10n, g),
            items: [
              for (final m in Modules.parGroupe(g).where(visible))
                DsNavEntree(route: m.route, libelle: m.libelle(l10n), icone: m.icone, badgeTexte: m.badgeTexte),
            ],
          ),
    ];

    Widget contenu = widget.child;
    final refuse = session != null && module != null && !session.peutAcceder(module.idAcces);
    if (refuse) {
      contenu = LicenceGate(
        key: const ValueKey('acces_refuse'),
        autorise: false,
        genre: DsGateGenre.refuse,
        description: l10n.dsGateRefuseDetail(module.libelle(l10n)),
        onAction: () => context.go(Modules.parId('tableau_bord')!.route),
        child: widget.child,
      );
    } else if (module != null) {
      contenu = LicenceGate(
        autorise: licence.couvre(module.niveauRequis),
        onActiverCle: () => context.push(ActivationPage.route),
        child: widget.child,
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
            backgroundColor: c.surfaceApp,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsSidebar(
                  sections: sections,
                  active: routeActive,
                  onNavigate: context.go,
                  replie: ref.watch(sidebarReduiteProvider),
                  onBasculer: () => ref.read(sidebarReduiteProvider.notifier).basculer(),
                  pied: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s2,
                    children: [
                      if (licence.couvre(NiveauLicence.avance) && magasins.magasinCourant != null)
                        DsStoreSwitcher(
                          key: const ValueKey('selecteur_magasin'),
                          nom: magasins.magasinCourant!.nom,
                          magasins: [for (final m in magasins.magasins) m.nom],
                          onChanged: (nom) {
                            final m = magasins.magasins.where((m) => m.nom == nom).firstOrNull;
                            if (m != null) ref.read(magasinCourantProvider.notifier).changer(m.code);
                          },
                        ),
                      DsButton(
                        key: const ValueKey('bouton_deconnexion'),
                        libelle: l10n.connexionDeconnecter,
                        icone: LucideIcons.logOut,
                        variante: DsButtonVariante.secondaire,
                        pleineLargeur: true,
                        onPressed: () => ref.read(sessionProvider.notifier).deconnecter(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DsTopBar(
                        utilisateur: session?.utilisateur.nomComplet ?? '',
                        role: session == null
                            ? ''
                            : Referentiel.roles.libelle(session.utilisateur.roleNom ?? '', locale),
                        enLigne: ref.watch(internetProvider),
                        alertes: alertes.total,
                        onMenu: () => afficherMenuModules(context),
                        onAlertes: () async {
                          await ref.read(alertesProvider.notifier).charger();
                          if (context.mounted) await afficherAlertes(context);
                        },
                        onUtilisateur: () => afficherMonCompte(context),
                        themeSombre: ref.watch(themeModeProvider) == ThemeMode.dark,
                        onTheme: (_) => ref.read(themeModeProvider.notifier).basculer(),
                        controlesFenetre: const ControlesFenetre(),
                        favoris: Row(
                          children: [
                            Flexible(
                              child: DsFavorisBar(
                                key: const ValueKey('barre_favoris'),
                                items: [
                                  for (final m in favoris)
                                    DsFavori(route: m.route, libelle: m.libelle(l10n), icone: m.icone),
                                ],
                                actif: routeActive,
                                max: Modules.maxFavoris,
                                onOuvrir: context.go,
                                onRetirer: (r) {
                                  final m = Modules.parRoute(r);
                                  if (m != null) ref.read(favorisProvider.notifier).retirer(m.id);
                                },
                                onAjouter: () => afficherMenuModules(context),
                              ),
                            ),
                            const Expanded(
                              child: ZoneDeplacement(child: SizedBox(height: DsTailles.topbar)),
                            ),
                          ],
                        ),
                      ),
                      if (licence.demo)
                        Container(
                          key: const ValueKey('bandeau_demo'),
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8, vertical: DsSpacing.s2),
                          decoration: BoxDecoration(
                            color: c.warningTint,
                            border: Border(bottom: BorderSide(color: c.borderSubtle)),
                          ),
                          child: Row(
                            spacing: DsSpacing.s2,
                            children: [
                              Icon(LucideIcons.flaskConical, size: DsTailles.iconeSm, color: c.warningFg),
                              Expanded(
                                child: Text(l10n.shellBandeauDemo, style: t.bodySmStrong.copyWith(color: c.warningFg)),
                              ),
                              DsButton(
                                libelle: l10n.connexionSaisirCle,
                                icone: LucideIcons.keyRound,
                                variante: DsButtonVariante.fantome,
                                taille: DsButtonTaille.sm,
                                onPressed: () => context.push(ActivationPage.route),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: KeyedSubtree(key: ValueKey(route), child: contenu),
                      ),
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

/// Menu des modules (Ctrl+M, DS `ModuleMenuDialog`) : tuiles par groupe, favoris (7), verrous.
Future<void> afficherMenuModules(BuildContext context) =>
    afficherDialog<void>(context, builder: (_) => const MenuModulesDialog());

class MenuModulesDialog extends ConsumerWidget {
  const MenuModulesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final licence = ref.watch(licenceProvider);
    final favoris = ref.watch(favorisProvider);
    final route = GoRouter.of(context).routeInformationProvider.value.uri.path;
    final verrous = <String, String>{
      for (final m in Modules.tous)
        m.route: ?verrouModule(l10n, m, licenceCouvre: licence.couvre(m.niveauRequis), session: session),
    };
    return Dialog(
      key: const ValueKey('menu_modules'),
      backgroundColor: c.surfaceRaised,
      insetPadding: const EdgeInsets.all(DsSpacing.s6),
      shape: RoundedRectangleBorder(
        borderRadius: DsRadius.borderXl,
        side: BorderSide(color: c.borderDefault),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DsSpacing.s6),
          child: DsModuleLauncher(
            titre: l10n.shellMenuModules,
            sections: [
              for (final g in GroupeModule.values)
                DsNavSection(
                  libelle: libelleGroupe(l10n, g),
                  items: [
                    for (final m in Modules.parGroupe(g))
                      DsNavEntree(route: m.route, libelle: m.libelle(l10n), icone: m.icone, badgeTexte: m.badgeTexte),
                  ],
                ),
            ],
            favoris: [for (final id in favoris) ?Modules.parId(id)?.route],
            verrous: verrous,
            actif: route,
            maxFavoris: Modules.maxFavoris,
            onOuvrir: (r) {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.go(r);
            },
            onBasculerFavori: (r) {
              final m = Modules.parRoute(r);
              if (m != null) ref.read(favorisProvider.notifier).basculer(m.id);
            },
          ),
        ),
      ),
    );
  }
}
