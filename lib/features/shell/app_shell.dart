import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/mobile_providers.dart';
import '../../app/providers.dart';
import '../../application/serveur_mobile.dart' show FactureMobile;
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/licence.dart';
import '../../domain/models/session.dart';
import '../../domain/modules.dart';
import '../../domain/pastilles.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../catalogue_rayons/catalogue_rayons_dialog.dart';
import '../catalogue_rayons/catalogue_rayons_providers.dart';
import '../commun/pastilles_providers.dart';
import '../compte/mon_compte_dialog.dart';
import '../configuration/configuration_dialog.dart';
import '../entrees/recu_ia_dialog.dart' show afficherDemandeOffre;
import '../mobile/mobile_dialog.dart';
import '../offres/offres_page.dart';
import 'alertes_dialog.dart';
import 'controles_fenetre.dart';
import 'recherche_globale.dart';

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

/// Raison du verrouillage d'un module (palier, lecture seule, puis rôle), `null` s'il est accessible.
String? verrouModule(AppLocalizations l10n, ModuleApp m, {required Licence licence, required Session? session}) {
  if (!licence.couvre(m.niveauRequis)) return l10n.shellReservePalier(libellePalier(l10n, m.niveauRequis));
  if (!moduleOuvert(licence, m)) return l10n.lectureSeuleCourt;
  if (session != null && !session.peutAcceder(m.idAcces)) return l10n.shellAccesRestreint;
  return null;
}

/// Coque de l'application (DS v2.2 `AppShell`) : barre latérale (groupes, déconnexion) + barre
/// supérieure (menu des modules, favoris, témoin réseau, alertes, thème, compte, fenêtre) + module.
///
/// Contrôle d'accès : module interdit au rôle → « Accès refusé » ; module réservé au palier Avancé →
/// [LicenceGate]. Après la connexion, déroule la séquence du §4.5 : configuration initiale (1ʳᵉ fois),
/// alertes (s'il y en a), puis l'écran d'accueil (la Caisse).
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
      // Poste neuf : les rayons du catalogue BENS à télécharger selon l'activité (une fois, avant la configuration).
      final rayons = session.peutAcceder('produits') && !await ref.read(catalogueRayonsServiceProvider).estPropose();
      if (!mounted) return;
      if (rayons) {
        await afficherCatalogueRayons(context, accueil: true);
        if (!mounted) return;
      }
      if (!ref.read(configurationTermineeProvider) && session.estAdmin) {
        await afficherConfigurationInitiale(context);
        if (!mounted) return;
      }
      final alertes = ref.read(alertesProvider);
      final service = ref.read(alertesServiceProvider);
      final masquees =
          !await service.afficherALaConnexion() || await service.estMasqueAujourdhui(session.utilisateur.code);
      if (!mounted) return;
      // Puis l'écran d'accueil lui-même (la Caisse) : plus de menu des modules par-dessus.
      if (alertes.total > 0 && !masquees) await afficherAlertes(context);
    } finally {
      _sequenceEnCours = false;
    }
  }

  bool _factureAffichee = false;

  /// Photo de facture envoyée par le téléphone : annoncée à qui peut ouvrir Entrées, avec un accès direct à
  /// l'onglet Smart Scan. Plusieurs photos d'affilée : un seul pop-up (la liste les montre toutes).
  Future<void> _factureRecue(FactureMobile f) async {
    if (_factureAffichee || !(ref.read(sessionProvider)?.peutAcceder('entrees') ?? false)) return;
    final l10n = AppLocalizations.of(context);
    _factureAffichee = true;
    try {
      await afficherResultat(
        context,
        type: DsResultatType.info,
        titre: l10n.mobileFactureRecueTitre,
        message: l10n.mobileFactureRecueMessage(f.utilisateur, f.bon),
        action: Builder(
          builder: (ctx) => DsButton(
            key: const ValueKey('facture_mobile_smart_scan'),
            libelle: l10n.mobileOuvrirSmartScan,
            icone: LucideIcons.scanLine,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/entrees?onglet=1');
            },
          ),
        ),
      );
    } finally {
      _factureAffichee = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(sequenceEnAttenteProvider, (_, enAttente) {
      if (enAttente) WidgetsBinding.instance.addPostFrameCallback((_) => _sequenceSiDemandee());
    });
    ref.listen<FactureMobile?>(factureMobileProvider, (_, f) {
      if (f != null) unawaited(_factureRecue(f));
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
    final routeActive = module == null ? route : (Modules.parId(module.idAcces) ?? module).route;
    final pastilles = ref.watch(pastillesProvider);
    bool point(ModuleApp m) => m.route != routeActive && pastilles.any((c) => PastillesModules.module(c) == m.id);

    bool visible(ModuleApp m) => verrouModule(l10n, m, licence: licence, session: session) == null;
    final sections = [
      for (final g in GroupeModule.values)
        if (Modules.parGroupe(g).any(visible))
          DsNavSection(
            libelle: libelleGroupe(l10n, g),
            items: [
              for (final m in Modules.parGroupe(g).where(visible))
                DsNavEntree(
                  route: m.route,
                  libelle: m.libelle(l10n),
                  icone: m.icone,
                  badgeTexte: m.badgeTexte,
                  point: point(m),
                ),
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
    } else if (module != null && licence.couvre(module.niveauRequis) && !moduleOuvert(licence, module)) {
      // Essai terminé : ce module attend l'achat d'une formule ; la consultation reste ouverte ailleurs.
      contenu = LicenceGate(
        key: const ValueKey('gate_lecture_seule'),
        autorise: false,
        titre: l10n.lectureSeuleTitre,
        description: l10n.lectureSeuleDetail,
        libelleAction: l10n.shellVoirFormules,
        onActiverCle: () => context.push(OffresPage.route),
        child: widget.child,
      );
    } else if (module != null) {
      final palier = libellePalier(l10n, module.niveauRequis);
      contenu = LicenceGate(
        autorise: licence.couvre(module.niveauRequis),
        titre: l10n.dsGatePalierTitre(palier),
        libelleAction: l10n.dsGatePalierAction(palier),
        onActiverCle: () => context.push(OffresPage.route),
        child: widget.child,
      );
    }

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyM, control: true): OuvrirMenuModulesIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true): RechercheGlobaleIntent(),
      },
      child: Actions(
        actions: {
          OuvrirMenuModulesIntent: CallbackAction<OuvrirMenuModulesIntent>(
            onInvoke: (_) => afficherMenuModules(context),
          ),
          RechercheGlobaleIntent: CallbackAction<RechercheGlobaleIntent>(
            onInvoke: (_) => afficherRechercheGlobale(context),
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
                        rechercheGlobale: const ChampRechercheGlobale(),
                        alertes: alertes.total,
                        onMenu: () => afficherMenuModules(context),
                        onAlertes: () async {
                          await ref.read(alertesProvider.notifier).charger();
                          if (context.mounted) await afficherAlertes(context);
                        },
                        onUtilisateur: () => afficherMonCompte(context),
                        actions: [
                          // CaisseDZ Scan : QR personnel de l'utilisateur (Admin, ou rôle « Application mobile »).
                          if (session?.a(Permission.utiliserMobile) ?? false)
                            DsIconButton(
                              key: const ValueKey('topbar_mobile'),
                              icone: LucideIcons.smartphone,
                              tooltip: l10n.mobileBouton,
                              point: ref.watch(mobileProvider).actif,
                              onPressed: () => afficherMobile(context, ref),
                            ),
                        ],
                        themeSombre: ref.watch(themeModeProvider) == ThemeMode.dark,
                        onTheme: (_) => ref.read(themeModeProvider.notifier).basculer(),
                        controlesFenetre: const ControlesFenetre(),
                        // Les favoris prennent toute la place jusqu'à la recherche (défilement au-delà) ;
                        // le reste de la barre sert à déplacer la fenêtre.
                        favoris: LayoutBuilder(
                          builder: (context, contraintes) => Row(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: contraintes.maxWidth),
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
                                  onAjouter: () => afficherMenuModules(context, modeFavoris: true),
                                ),
                              ),
                              const Expanded(
                                child: ZoneDeplacement(child: SizedBox(height: DsTailles.topbar)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (licence.lectureSeule)
                        Container(
                          key: const ValueKey('bandeau_lecture_seule'),
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8, vertical: DsSpacing.s2),
                          decoration: BoxDecoration(
                            color: c.dangerTint,
                            border: Border(bottom: BorderSide(color: c.borderSubtle)),
                          ),
                          child: Row(
                            spacing: DsSpacing.s2,
                            children: [
                              Icon(LucideIcons.lock, size: DsTailles.iconeSm, color: c.dangerFg),
                              Expanded(
                                child: Text(
                                  l10n.lectureSeuleBandeau(
                                    licence.finMotif == null ? '—' : DateFormat('dd/MM/yyyy').format(licence.finMotif!),
                                  ),
                                  style: t.bodySmStrong.copyWith(color: c.dangerFg),
                                ),
                              ),
                              DsButton(
                                key: const ValueKey('bandeau_lecture_seule_formules'),
                                libelle: l10n.shellVoirFormules,
                                icone: LucideIcons.sparkles,
                                variante: DsButtonVariante.fantome,
                                taille: DsButtonTaille.sm,
                                onPressed: () => context.push(OffresPage.route),
                              ),
                            ],
                          ),
                        ),
                      // Rappel avant l'expiration de Smart Scans non utilisés (30 jours, puis 7).
                      if (!licence.lectureSeule && licence.expirationsScans.isNotEmpty)
                        Builder(
                          builder: (context) {
                            final premier = licence.expirationsScans.reduce((a, b) => a.fin.isBefore(b.fin) ? a : b);
                            return Container(
                              key: const ValueKey('bandeau_scans'),
                              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8, vertical: DsSpacing.s2),
                              decoration: BoxDecoration(
                                color: c.infoTint,
                                border: Border(bottom: BorderSide(color: c.borderSubtle)),
                              ),
                              child: Row(
                                spacing: DsSpacing.s2,
                                children: [
                                  Icon(LucideIcons.scanLine, size: DsTailles.iconeSm, color: c.infoFg),
                                  Expanded(
                                    child: Text(
                                      l10n.smartScanExpiration(
                                        premier.restant,
                                        DateFormat('dd/MM/yyyy').format(premier.fin),
                                      ),
                                      style: t.bodySmStrong.copyWith(color: c.infoFg),
                                    ),
                                  ),
                                  DsButton(
                                    libelle: l10n.smartScanPacksTitre,
                                    icone: LucideIcons.package,
                                    variante: DsButtonVariante.fantome,
                                    taille: DsButtonTaille.sm,
                                    onPressed: () => afficherDemandeOffre(context, ref),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (licence.essai && licence.niveau != null && licence.joursRestants(DateTime.now()) != null)
                        Container(
                          key: const ValueKey('bandeau_essai'),
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8, vertical: DsSpacing.s2),
                          decoration: BoxDecoration(
                            color: c.warningTint,
                            border: Border(bottom: BorderSide(color: c.borderSubtle)),
                          ),
                          child: Row(
                            spacing: DsSpacing.s2,
                            children: [
                              Icon(LucideIcons.hourglass, size: DsTailles.iconeSm, color: c.warningFg),
                              Expanded(
                                child: Text(
                                  l10n.shellBandeauEssai(
                                    libellePalier(l10n, licence.niveau!),
                                    licence.joursRestants(DateTime.now())!,
                                  ),
                                  style: t.bodySmStrong.copyWith(color: c.warningFg),
                                ),
                              ),
                              DsButton(
                                libelle: l10n.shellVoirFormules,
                                icone: LucideIcons.sparkles,
                                variante: DsButtonVariante.fantome,
                                taille: DsButtonTaille.sm,
                                onPressed: () => context.push(OffresPage.route),
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

/// Menu des modules (Ctrl+M, DS `ModuleMenuDialog`) : tuiles par groupe, favoris (5), verrous.
/// [modeFavoris] (« + » de la barre de favoris) : un clic sur un module l'ajoute ou le retire des favoris.
Future<void> afficherMenuModules(BuildContext context, {bool modeFavoris = false}) =>
    afficherDialog<void>(context, builder: (_) => MenuModulesDialog(modeFavoris: modeFavoris));

class MenuModulesDialog extends ConsumerWidget {
  const MenuModulesDialog({super.key, this.modeFavoris = false});
  final bool modeFavoris;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final licence = ref.watch(licenceProvider);
    final favoris = ref.watch(favorisProvider);
    final route = GoRouter.of(context).routeInformationProvider.value.uri.path;
    bool inclus(ModuleApp m) => licence.couvre(m.niveauRequis);
    final verrous = <String, String>{
      for (final m in Modules.tous.where(inclus)) m.route: ?verrouModule(l10n, m, licence: licence, session: session),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DsSpacing.s5,
            children: [
              DsModuleLauncher(
                titre: modeFavoris ? l10n.shellChoisirFavoris : l10n.shellMenuModules,
                modeFavoris: modeFavoris,
                // Les modules hors formule n'y sont pas (rien de « réservé au palier » à montrer) ;
                // ceux que le rôle ou la lecture seule ferment restent, avec leur cadenas.
                sections: [
                  for (final g in GroupeModule.values)
                    if (Modules.parGroupe(g).any(inclus))
                      DsNavSection(
                        libelle: libelleGroupe(l10n, g),
                        items: [
                          for (final m in Modules.parGroupe(g).where(inclus))
                            DsNavEntree(
                              route: m.route,
                              libelle: m.libelle(l10n),
                              icone: m.icone,
                              badgeTexte: m.badgeTexte,
                            ),
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
              if (modeFavoris)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: DsButton(
                    key: const ValueKey('favoris_termine'),
                    libelle: l10n.communTermine,
                    icone: LucideIcons.check,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
