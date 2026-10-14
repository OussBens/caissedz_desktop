import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';
import '../galerie/galerie_page.dart';
import 'modules_menu.dart';

/// Barre latérale : favoris (7 max) puis groupes Général / Stock / Tiers / Gestion.
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final reduite = ref.watch(sidebarReduiteProvider);
    final favoris = ref.watch(favorisModulesProvider);
    final routeCourante = GoRouterState.of(context).uri.path;
    final licence = ref.watch(licenceProvider);
    final session = ref.watch(sessionProvider);

    Widget entreeModule(ModuleApp m, {bool favori = false}) => _EntreeSidebar(
          icone: m.icone,
          libelle: m.libelle(l10n),
          actif: routeCourante == m.route,
          reduite: reduite,
          verrou: !licence.couvre(m.niveauRequis)
              ? l10n.shellVerrouille
              : (session != null && !session.peutAcceder(m.id) ? l10n.shellAccesRestreint : null),
          onTap: () => context.go(m.route),
          onSecondaryTap: () => _menuContextuel(context, ref, m, favori: ref.read(favorisProvider).contains(m.id)),
        );

    Widget titreGroupe(String texte) => reduite
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: DsSpacing.sm),
            child: Divider(height: 1, color: c.sidebarActif),
          )
        : Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(DsSpacing.lg, DsSpacing.lg, DsSpacing.lg, DsSpacing.xs),
            child: Text(
              texte.toUpperCase(),
              style: t.legende.copyWith(color: c.sidebarTexte.withValues(alpha: 0.7)),
            ),
          );

    return AnimatedContainer(
      duration: DsMotion.normal,
      curve: DsMotion.courbe,
      width: reduite ? DsTailles.sidebarLargeurReduite : DsTailles.sidebarLargeur,
      color: c.sidebarFond,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête : logo + bouton réduire
          SizedBox(
            height: DsTailles.barreTitre + DsSpacing.lg,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md),
              child: Row(
                mainAxisAlignment: reduite ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  if (!reduite)
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: c.primaire, borderRadius: DsRadius.borderMd),
                          child: Icon(LucideIcons.store, size: 16, color: c.surPrimaire),
                        ),
                        const SizedBox(width: DsSpacing.sm),
                        Text(l10n.appTitle, style: t.titreSm.copyWith(color: c.sidebarTexteActif)),
                      ],
                    ),
                  DsIconButton(
                    icone: reduite ? LucideIcons.panelLeftOpen : LucideIcons.panelLeftClose,
                    tooltip: reduite ? l10n.shellEtendreSidebar : l10n.shellReduireSidebar,
                    couleur: c.sidebarTexte,
                    couleurSurvol: c.sidebarActif,
                    onPressed: () => ref.read(sidebarReduiteProvider.notifier).basculer(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: DsSpacing.lg),
              children: [
                titreGroupe(l10n.shellFavoris),
                if (favoris.isEmpty && !reduite)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DsSpacing.lg, vertical: DsSpacing.xs),
                    child: Text(
                      l10n.shellFavorisVide,
                      style: t.legende.copyWith(color: c.sidebarTexte.withValues(alpha: 0.6)),
                    ),
                  ),
                for (final m in favoris) entreeModule(m, favori: true),
                titreGroupe(l10n.shellNavGeneral),
                for (final m in Modules.parGroupe(GroupeModule.general)) entreeModule(m),
                titreGroupe(l10n.shellNavStock),
                for (final m in Modules.parGroupe(GroupeModule.stock)) entreeModule(m),
                titreGroupe(l10n.shellNavTiers),
                for (final m in Modules.parGroupe(GroupeModule.tiers)) entreeModule(m),
                titreGroupe(l10n.shellNavGestion),
                for (final m in Modules.parGroupe(GroupeModule.gestion)) entreeModule(m),
              ],
            ),
          ),
          Divider(height: 1, color: c.sidebarActif),
          _EntreeSidebar(
            icone: LucideIcons.layoutGrid,
            libelle: '${l10n.shellMenuModules}  ·  ${l10n.shellMenuModulesRaccourci}',
            reduite: reduite,
            onTap: () => afficherMenuModules(context),
          ),
          _EntreeSidebar(
            icone: LucideIcons.palette,
            libelle: l10n.shellGalerie,
            actif: routeCourante == GaleriePage.route,
            reduite: reduite,
            onTap: () => context.go(GaleriePage.route),
          ),
          const SizedBox(height: DsSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _menuContextuel(BuildContext context, WidgetRef ref, ModuleApp m, {required bool favori}) async {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final box = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final choix = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'favori',
          height: 36,
          child: Row(
            children: [
              Icon(favori ? LucideIcons.starOff : LucideIcons.star, size: DsTailles.iconeSm, color: c.texteSecondaire),
              const SizedBox(width: DsSpacing.sm),
              Text(favori ? l10n.shellFavorisRetirer : l10n.shellFavorisAjouter, style: t.corps),
            ],
          ),
        ),
      ],
    );
    if (choix == 'favori' && context.mounted) {
      final ok = await ref.read(favorisProvider.notifier).basculer(m.id);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shellFavorisMax)));
      }
    }
  }
}

class _EntreeSidebar extends StatefulWidget {
  const _EntreeSidebar({
    required this.icone,
    required this.libelle,
    required this.reduite,
    required this.onTap,
    this.onSecondaryTap,
    this.actif = false,
    this.verrou,
  });
  final IconData icone;
  final String libelle;
  final bool reduite;
  final bool actif;

  /// Motif de verrouillage affiché en infobulle (licence, rôle) ; `null` = accessible.
  final String? verrou;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  @override
  State<_EntreeSidebar> createState() => _EntreeSidebarState();
}

class _EntreeSidebarState extends State<_EntreeSidebar> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final couleurTexte = widget.verrou != null
        ? c.sidebarTexte.withValues(alpha: 0.55)
        : (widget.actif ? c.sidebarTexteActif : c.sidebarTexte);
    final contenu = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onSecondaryTap,
        child: AnimatedContainer(
          duration: DsMotion.rapide,
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: DsSpacing.sm, vertical: 1),
          padding: EdgeInsets.symmetric(horizontal: widget.reduite ? 0 : DsSpacing.md),
          decoration: BoxDecoration(
            color: widget.actif || _survol ? c.sidebarActif : const Color(0x00000000),
            borderRadius: DsRadius.borderMd,
            border: BorderDirectional(
              start: BorderSide(color: widget.actif ? c.primaire : const Color(0x00000000), width: 3),
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.reduite ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(widget.icone, size: DsTailles.icone, color: widget.actif ? c.primaire : couleurTexte),
              if (!widget.reduite) ...[
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: Text(
                    widget.libelle,
                    style: (widget.actif ? t.corpsFort : t.corps).copyWith(color: couleurTexte),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.verrou != null) Icon(LucideIcons.lock, size: 12, color: couleurTexte),
              ],
            ],
          ),
        ),
      ),
    );
    if (!widget.reduite && widget.verrou == null) return contenu;
    return Tooltip(message: widget.verrou ?? widget.libelle, child: contenu);
  }
}
