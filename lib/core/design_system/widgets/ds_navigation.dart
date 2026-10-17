import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_forms.dart';
import 'ds_primitives.dart';

/// Entrée de navigation (module).
class DsNavEntree {
  const DsNavEntree({required this.route, required this.libelle, required this.icone, this.badge, this.badgeTexte});
  final String route;
  final String libelle;
  final IconData icone;

  /// Compteur (pastille bordée).
  final int? badge;

  /// Étiquette texte (pastille teintée, ex. « IA »).
  final String? badgeTexte;
}

/// Groupe de la barre latérale.
class DsNavSection {
  const DsNavSection({required this.libelle, required this.items});
  final String libelle;
  final List<DsNavEntree> items;
}

/// Élément de la barre latérale (`NavItem`) : 36 px, rayon 8, barre primaire 3 px quand actif.
class DsNavItem extends StatefulWidget {
  const DsNavItem({super.key, required this.entree, required this.actif, required this.replie, required this.onTap});
  final DsNavEntree entree;
  final bool actif;
  final bool replie;
  final VoidCallback onTap;
  @override
  State<DsNavItem> createState() => _DsNavItemState();
}

class _DsNavItemState extends State<DsNavItem> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final on = widget.actif;
    final it = widget.entree;
    final couleurTexte = on ? c.primaryTintFg : (_survol ? c.textPrimary : c.textSecondary);
    final bouton = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: DsMotion.fast,
              curve: DsMotion.standard,
              height: DsTailles.navItem,
              padding: EdgeInsets.symmetric(horizontal: widget.replie ? 0 : 10),
              decoration: BoxDecoration(
                color: on ? c.surfaceActive : (_survol ? c.surfaceHover : DsColors.transparent),
                borderRadius: DsRadius.borderMd,
              ),
              child: Row(
                mainAxisAlignment: widget.replie ? MainAxisAlignment.center : MainAxisAlignment.start,
                spacing: 10,
                children: [
                  Icon(it.icone, size: DsTailles.icone, color: on ? c.iconActive : couleurTexte),
                  if (!widget.replie) ...[
                    Expanded(
                      child: Text(
                        it.libelle,
                        style: t.bodySm.copyWith(
                          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                          color: couleurTexte,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (it.badge != null)
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.surfaceCard,
                          borderRadius: DsRadius.borderSm,
                          border: Border.all(color: c.borderDefault),
                        ),
                        child: Text(
                          '${it.badge}',
                          style: t.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: c.textSecondary,
                          ),
                        ),
                      )
                    else if (it.badgeTexte != null)
                      Container(
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: c.primaryTint, borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          it.badgeTexte!,
                          style: t.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            letterSpacing: .4,
                            color: c.primaryTintFg,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (on)
              PositionedDirectional(
                start: -12,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(3)),
                ),
              ),
          ],
        ),
      ),
    );
    if (!widget.replie) return bouton;
    return Tooltip(message: it.libelle, positionDelegate: positionLaterale(context), child: bouton);
  }
}

/// Position d'infobulle à côté de la cible (à droite, à gauche en RTL), centrée verticalement, pour ne pas
/// masquer l'élément suivant de la barre latérale ; reste dans la fenêtre.
TooltipPositionDelegate positionLaterale(BuildContext context, {double ecart = 8}) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return (p) {
    final demi = p.targetSize.width / 2 + ecart;
    final x = rtl ? p.target.dx - demi - p.tooltipSize.width : p.target.dx + demi;
    final y = p.target.dy - p.tooltipSize.height / 2;
    final maxX = p.overlaySize.width.isFinite ? p.overlaySize.width - p.tooltipSize.width : x;
    final maxY = p.overlaySize.height.isFinite ? p.overlaySize.height - p.tooltipSize.height : y;
    return Offset(x.clamp(0, maxX < 0 ? 0 : maxX).toDouble(), y.clamp(0, maxY < 0 ? 0 : maxY).toDouble());
  };
}

/// Barre latérale (`Sidebar`) : 248 px (72 repliée), logo, groupes repliables séparés, pied, copyright.
class DsSidebar extends StatefulWidget {
  const DsSidebar({
    super.key,
    required this.sections,
    required this.active,
    required this.onNavigate,
    this.replie = false,
    this.onBasculer,
    this.pied,
    this.copyright = '© 2026 CaisseDZ',
  });
  final List<DsNavSection> sections;
  final String? active;
  final ValueChanged<String> onNavigate;
  final bool replie;
  final VoidCallback? onBasculer;
  final Widget? pied;
  final String copyright;

  @override
  State<DsSidebar> createState() => _DsSidebarState();
}

class _DsSidebarState extends State<DsSidebar> {
  /// Libellés des catégories repliées (le module actif d'une catégorie repliée reste visible).
  final Set<String> _categoriesRepliees = {};

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final sections = widget.sections;
    final active = widget.active;
    final replie = widget.replie;
    final onBasculer = widget.onBasculer;
    final pied = widget.pied;
    return AnimatedContainer(
      duration: DsMotion.slow,
      curve: DsMotion.emphasized,
      width: replie ? DsTailles.sidebarLargeurReduite : DsTailles.sidebarLargeur,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: c.surfaceSidebar,
        border: BorderDirectional(end: BorderSide(color: c.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: DsTailles.topbar,
            padding: replie ? EdgeInsets.zero : const EdgeInsetsDirectional.only(start: 20, end: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.borderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: replie ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (!replie)
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: DsLogo(),
                    ),
                  ),
                if (onBasculer != null)
                  DsIconButton(
                    icone: replie ? LucideIcons.panelLeftOpen : LucideIcons.panelLeftClose,
                    tooltip: replie ? l10n.dsDeplier : l10n.dsReplier,
                    taille: 28,
                    contour: true,
                    onPressed: onBasculer,
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              children: [
                for (final (i, s) in sections.indexed)
                  Container(
                    margin: EdgeInsets.only(top: i > 0 ? 8 : 0),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: i > 0 ? Border(top: BorderSide(color: c.borderSubtle)) : null,
                    ),
                    child: Builder(
                      builder: (context) {
                        final repliable = !replie && s.libelle.isNotEmpty;
                        final fermee = repliable && _categoriesRepliees.contains(s.libelle);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (repliable)
                              _EnteteCategorie(
                                key: ValueKey('nav_categorie_$i'),
                                libelle: s.libelle,
                                ouverte: !fermee,
                                onTap: () => setState(
                                  () => fermee
                                      ? _categoriesRepliees.remove(s.libelle)
                                      : _categoriesRepliees.add(s.libelle),
                                ),
                              ),
                            AnimatedSize(
                              duration: DsMotion.base,
                              curve: DsMotion.standard,
                              alignment: AlignmentDirectional.topStart,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final it in s.items)
                                    if (!fermee || active == it.route)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: DsNavItem(
                                          key: ValueKey('nav_${it.route}'),
                                          entree: it,
                                          actif: active == it.route,
                                          replie: replie,
                                          onTap: () => widget.onNavigate(it.route),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (!replie && pied != null) Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 0), child: pied),
          if (!replie)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.borderSubtle)),
              ),
              child: Text(
                widget.copyright,
                textAlign: TextAlign.center,
                style: t.caption.copyWith(fontSize: 11, color: c.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// En-tête de catégorie de la barre latérale : libellé et chevron, clic = replier / déplier.
class _EnteteCategorie extends StatefulWidget {
  const _EnteteCategorie({super.key, required this.libelle, required this.ouverte, required this.onTap});
  final String libelle;
  final bool ouverte;
  final VoidCallback onTap;

  @override
  State<_EnteteCategorie> createState() => _EnteteCategorieState();
}

class _EnteteCategorieState extends State<_EnteteCategorie> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final couleur = _survol ? c.textSecondary : c.textMuted;
    return Semantics(
      button: true,
      expanded: widget.ouverte,
      child: Tooltip(
        message: widget.ouverte ? l10n.dsReplier : l10n.dsDeplier,
        waitDuration: const Duration(milliseconds: 600),
        positionDelegate: positionLaterale(context),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _survol = true),
          onExit: (_) => setState(() => _survol = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.libelle.toUpperCase(), style: t.overline.copyWith(height: 1, color: couleur)),
                  ),
                  AnimatedRotation(
                    // Replié : chevron vers le sens de lecture (droite en LTR, gauche en RTL).
                    turns: widget.ouverte ? 0 : (Directionality.of(context) == TextDirection.rtl ? .25 : -.25),
                    duration: DsMotion.fast,
                    child: Icon(LucideIcons.chevronDown, size: 14, color: couleur),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur de magasin (`StoreSwitcher`) du pied de la barre latérale.
class DsStoreSwitcher extends StatefulWidget {
  const DsStoreSwitcher({super.key, required this.nom, this.legende, this.magasins = const [], this.onChanged});
  final String nom;
  final String? legende;
  final List<String> magasins;
  final ValueChanged<String>? onChanged;
  @override
  State<DsStoreSwitcher> createState() => _DsStoreSwitcherState();
}

class _DsStoreSwitcherState extends State<DsStoreSwitcher> {
  bool _survol = false;
  final _lien = LayerLink();
  final _portail = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final direction = Directionality.of(context);
    return CompositedTransformTarget(
      link: _lien,
      child: OverlayPortal(
        controller: _portail,
        overlayChildBuilder: (ctx) => Positioned(
          width: DsTailles.sidebarLargeur - 24,
          child: CompositedTransformFollower(
            link: _lien,
            targetAnchor: AlignmentDirectional.topStart.resolve(direction),
            followerAnchor: AlignmentDirectional.bottomStart.resolve(direction),
            offset: const Offset(0, -6),
            child: TapRegion(
              groupId: _portail,
              onTapOutside: (_) => setState(_portail.hide),
              child: Material(
                color: DsColors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(color: c.borderDefault),
                    boxShadow: c.shadowMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in widget.magasins)
                        InkWell(
                          borderRadius: DsRadius.borderSm,
                          onTap: () {
                            widget.onChanged?.call(s);
                            setState(_portail.hide);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: s == widget.nom ? c.surfaceActive : DsColors.transparent,
                              borderRadius: DsRadius.borderSm,
                            ),
                            child: Row(
                              spacing: 8,
                              children: [
                                Icon(LucideIcons.store, size: 15, color: c.iconDefault),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: t.bodySm.copyWith(
                                      fontWeight: s == widget.nom ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (s == widget.nom) Icon(LucideIcons.check, size: 15, color: c.iconActive),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        child: TapRegion(
          groupId: _portail,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _survol = true),
            onExit: (_) => setState(() => _survol = false),
            child: GestureDetector(
              onTap: widget.magasins.isEmpty ? null : () => setState(_portail.toggle),
              child: AnimatedContainer(
                duration: DsMotion.fast,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _survol ? c.surfaceHover : c.surfaceSunken,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.borderSubtle),
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: c.accent, borderRadius: DsRadius.borderMd),
                      child: Icon(LucideIcons.store, size: 17, color: c.accentFg),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.legende ?? l10n.dsMagasin,
                            style: t.caption.copyWith(fontSize: 11, color: c.textMuted),
                          ),
                          Text(widget.nom, style: t.bodySmStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronsUpDown, size: 15, color: c.iconMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bascule clair / sombre (`ThemeToggle`) : soleil ↔ lune animés.
class DsThemeToggle extends StatelessWidget {
  const DsThemeToggle({super.key, required this.sombre, required this.onChanged});
  final bool sombre;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: sombre ? l10n.dsThemeClair : l10n.dsThemeSombre,
      child: InkWell(
        key: const ValueKey('bascule_theme'),
        borderRadius: DsRadius.borderMd,
        hoverColor: c.surfaceHover,
        onTap: () => onChanged(!sombre),
        child: SizedBox(
          width: DsTailles.controleMd,
          height: DsTailles.controleMd,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSlide(
                  offset: sombre ? Offset.zero : const Offset(0, .7),
                  duration: DsMotion.slow,
                  curve: DsMotion.emphasized,
                  child: AnimatedOpacity(
                    opacity: sombre ? 1 : 0,
                    duration: DsMotion.slow,
                    child: Icon(LucideIcons.sun, size: DsTailles.icone, color: c.iconDefault),
                  ),
                ),
                AnimatedSlide(
                  offset: sombre ? const Offset(0, -.7) : Offset.zero,
                  duration: DsMotion.slow,
                  curve: DsMotion.emphasized,
                  child: AnimatedOpacity(
                    opacity: sombre ? 0 : 1,
                    duration: DsMotion.slow,
                    child: Icon(LucideIcons.moon, size: DsTailles.icone, color: c.iconDefault),
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

/// Témoin « En ligne / Hors ligne » de la barre supérieure.
class DsTemoinLigne extends StatelessWidget {
  const DsTemoinLigne({super.key, required this.enLigne, this.libelle});
  final bool enLigne;
  final String? libelle;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final couleur = enLigne ? c.successFg : c.textSecondary;
    return Tooltip(
      message: enLigne ? l10n.dsSynchronise : l10n.dsHorsLigneLocal,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: enLigne ? c.successTint : c.surfaceSunken, borderRadius: DsRadius.borderPill),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
            ),
            Text(
              libelle ?? (enLigne ? l10n.dsEnLigne : l10n.dsHorsLigne),
              style: t.caption.copyWith(fontWeight: FontWeight.w600, color: couleur),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre supérieure (`TopBar`) : menu des modules, recherche, favoris, témoin réseau, actions,
/// alertes, thème, compte, contrôles de fenêtre.
class DsTopBar extends StatelessWidget {
  const DsTopBar({
    super.key,
    required this.utilisateur,
    required this.role,
    this.enLigne = true,
    this.alertes = 0,
    this.onRecherche,
    this.indiceRecherche,
    this.actions = const [],
    this.controlesFenetre,
    this.onUtilisateur,
    this.onAlertes,
    this.onMenu,
    this.favoris,
    this.themeSombre = false,
    this.onTheme,
    this.largeurRecherche = 340,
    this.rechercheGlobale,
  });
  final String utilisateur;
  final String role;
  final bool enLigne;
  final int alertes;
  final ValueChanged<String>? onRecherche;
  final String? indiceRecherche;
  final List<Widget> actions;
  final Widget? controlesFenetre;
  final VoidCallback? onUtilisateur;
  final VoidCallback? onAlertes;
  final VoidCallback? onMenu;
  final Widget? favoris;
  final bool themeSombre;
  final ValueChanged<bool>? onTheme;
  final double largeurRecherche;

  /// Champ de recherche globale, placé à côté du témoin réseau et des alertes.
  final Widget? rechercheGlobale;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Container(
      height: DsTailles.topbar,
      padding: EdgeInsetsDirectional.only(start: onMenu != null ? 12 : 24, end: 8),
      decoration: BoxDecoration(
        color: c.surfaceSidebar,
        border: Border(bottom: BorderSide(color: c.borderDefault)),
      ),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          if (onMenu != null)
            DsIconButton(
              key: const ValueKey('topbar_menu'),
              icone: LucideIcons.layoutGrid,
              tooltip: l10n.dsMenuModules,
              onPressed: onMenu,
            ),
          if (onRecherche != null)
            DsSearchField(largeur: largeurRecherche, indice: indiceRecherche, onChanged: onRecherche),
          Expanded(
            child: favoris == null
                ? const SizedBox.shrink()
                : Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: favoris),
          ),
          ?rechercheGlobale,
          DsTemoinLigne(enLigne: enLigne),
          ...actions,
          DsIconButton(
            key: const ValueKey('topbar_alertes'),
            icone: LucideIcons.bell,
            tooltip: l10n.dsAlertes,
            badge: alertes,
            onPressed: onAlertes,
          ),
          if (onTheme != null) DsThemeToggle(sombre: themeSombre, onChanged: onTheme!),
          Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 8), color: c.borderDefault),
          InkWell(
            key: const ValueKey('topbar_compte'),
            borderRadius: DsRadius.borderMd,
            onTap: onUtilisateur,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                spacing: 10,
                children: [
                  DsAvatar(nom: utilisateur, taille: 34),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(utilisateur, style: t.bodySmStrong.copyWith(height: 1.2)),
                      Text(role, style: t.caption.copyWith(height: 1.2, color: c.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (controlesFenetre != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Align(alignment: Alignment.topCenter, child: controlesFenetre),
            ),
        ],
      ),
    );
  }
}

/// Favori de la barre supérieure.
class DsFavori {
  const DsFavori({required this.route, required this.libelle, required this.icone});
  final String route;
  final String libelle;
  final IconData icone;
}

/// Barre de favoris (`FavoritesBar`) : onglets 32 px, soulignement primaire sous l'actif, « + ».
class DsFavorisBar extends StatelessWidget {
  const DsFavorisBar({
    super.key,
    required this.items,
    this.actif,
    this.onOuvrir,
    this.onRetirer,
    this.onAjouter,
    this.max = 7,
    this.libelleAjouter,
  });
  final List<DsFavori> items;
  final String? actif;
  final ValueChanged<String>? onOuvrir;
  final ValueChanged<String>? onRetirer;
  final VoidCallback? onAjouter;
  final int max;
  final String? libelleAjouter;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 4,
        children: [
          for (final i in items)
            _Favori(
              favori: i,
              actif: actif == i.route,
              onOuvrir: () => onOuvrir?.call(i.route),
              onRetirer: onRetirer == null ? null : () => onRetirer!(i.route),
            ),
          if (onAjouter != null && items.length < max)
            Tooltip(
              message: libelleAjouter ?? l10n.dsAjouterFavoris,
              child: InkWell(
                key: const ValueKey('favoris_ajouter'),
                borderRadius: DsRadius.borderMd,
                onTap: onAjouter,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: DsRadius.borderMd,
                    border: Border.all(color: c.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(LucideIcons.plus, size: 14, color: c.textMuted),
                      if (items.isEmpty)
                        Text(
                          libelleAjouter ?? l10n.dsAjouter,
                          style: t.bodySm.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500, color: c.textMuted),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Favori extends StatefulWidget {
  const _Favori({required this.favori, required this.actif, required this.onOuvrir, this.onRetirer});
  final DsFavori favori;
  final bool actif;
  final VoidCallback onOuvrir;
  final VoidCallback? onRetirer;
  @override
  State<_Favori> createState() => _FavoriState();
}

class _FavoriState extends State<_Favori> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final on = widget.actif;
    return MouseRegion(
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: DsMotion.fast,
            height: 32,
            decoration: BoxDecoration(
              color: on ? c.primaryTint : (_survol ? c.surfaceHover : DsColors.transparent),
              borderRadius: DsRadius.borderMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: widget.onOuvrir,
                  borderRadius: DsRadius.borderMd,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 10, end: widget.onRetirer != null ? 4 : 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 7,
                      children: [
                        Icon(widget.favori.icone, size: 15, color: on ? c.iconActive : c.textSecondary),
                        Text(
                          widget.favori.libelle,
                          style: t.bodySm.copyWith(
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                            color: on ? c.primaryTintFg : c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.onRetirer != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: AnimatedOpacity(
                      opacity: _survol ? 1 : 0,
                      duration: DsMotion.fast,
                      child: DsIconButton(
                        icone: LucideIcons.x,
                        tooltip: l10n.dsRetirerFavoris,
                        taille: 20,
                        couleur: c.iconMuted,
                        onPressed: widget.onRetirer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (on)
            PositionedDirectional(
              start: 10,
              end: 10,
              bottom: -14,
              child: Container(
                height: 2,
                decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lanceur de modules (`ModuleLauncher`, Ctrl+M) : recherche, compteur de favoris, tuiles par section.
class DsModuleLauncher extends StatefulWidget {
  const DsModuleLauncher({
    super.key,
    required this.sections,
    required this.favoris,
    required this.onOuvrir,
    this.onBasculerFavori,
    this.verrous = const {},
    this.actif,
    this.maxFavoris = 7,
    this.titre,
    this.modeFavoris = false,
  });
  final List<DsNavSection> sections;
  final List<String> favoris;
  final ValueChanged<String> onOuvrir;
  final ValueChanged<String>? onBasculerFavori;

  /// Route → raison du verrouillage (licence, rôle).
  final Map<String, String> verrous;
  final String? actif;
  final int maxFavoris;
  final String? titre;

  /// Choix des favoris : un clic sur une tuile l'ajoute ou la retire des favoris au lieu d'ouvrir le module.
  final bool modeFavoris;

  @override
  State<DsModuleLauncher> createState() => _DsModuleLauncherState();
}

class _DsModuleLauncherState extends State<DsModuleLauncher> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final q = _q.trim().toLowerCase();
    final plein = widget.favoris.length >= widget.maxFavoris;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: DsSpacing.s4,
      children: [
        Row(
          spacing: DsSpacing.s3,
          children: [
            Expanded(
              child: Text(
                widget.titre ?? l10n.dsModules,
                style: t.heading.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Icon(LucideIcons.star, size: 13, color: plein ? c.warningFg : c.textMuted),
                Text(
                  '${widget.favoris.length} / ${widget.maxFavoris}',
                  style: t.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: plein ? c.warningFg : c.textMuted,
                  ),
                ),
              ],
            ),
            DsSearchField(
              autofocus: true,
              kbd: '',
              indice: l10n.dsRechercherModule,
              largeur: 260,
              onChanged: (v) => setState(() => _q = v),
            ),
          ],
        ),
        if (widget.modeFavoris)
          DsNote(
            ton: plein ? DsBadgeTon.avertissement : DsBadgeTon.info,
            icone: LucideIcons.star,
            texte: plein ? l10n.dsFavorisAideComplets(widget.maxFavoris) : l10n.dsFavorisAide(widget.maxFavoris),
          ),
        for (final s in widget.sections)
          Builder(
            builder: (context) {
              final items = s.items.where((i) => q.isEmpty || i.libelle.toLowerCase().contains(q)).toList();
              if (items.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DsSpacing.s2,
                children: [
                  if (s.libelle.isNotEmpty)
                    Text(s.libelle.toUpperCase(), style: t.overline.copyWith(color: c.textMuted)),
                  LayoutBuilder(
                    builder: (context, contraintes) {
                      const gap = 12.0;
                      final n = ((contraintes.maxWidth + gap) / (150 + gap)).floor().clamp(1, 12);
                      final largeur = (contraintes.maxWidth - gap * (n - 1)) / n;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final i in items)
                            SizedBox(
                              width: largeur,
                              child: _TuileModule(
                                entree: i,
                                actif: widget.actif == i.route,
                                favori: widget.favoris.contains(i.route),
                                verrou: widget.verrous[i.route],
                                peutFavori: !plein,
                                modeFavoris: widget.modeFavoris,
                                onOuvrir: () => widget.onOuvrir(i.route),
                                onFavori: widget.onBasculerFavori == null
                                    ? null
                                    : () => widget.onBasculerFavori!(i.route),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _TuileModule extends StatefulWidget {
  const _TuileModule({
    required this.entree,
    required this.actif,
    required this.favori,
    required this.peutFavori,
    required this.onOuvrir,
    this.verrou,
    this.onFavori,
    this.modeFavoris = false,
  });
  final DsNavEntree entree;
  final bool actif;
  final bool favori;
  final bool peutFavori;
  final bool modeFavoris;
  final String? verrou;
  final VoidCallback onOuvrir;
  final VoidCallback? onFavori;
  @override
  State<_TuileModule> createState() => _TuileModuleState();
}

class _TuileModuleState extends State<_TuileModule> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final mode = widget.modeFavoris;
    // Mode favoris : la tuile « active » est un favori ; sinon, le module ouvert.
    final on = mode ? widget.favori : widget.actif;
    final bloquee = widget.verrou != null || (mode && !widget.favori && !widget.peutFavori);
    final verrou = widget.verrou != null;
    final i = widget.entree;
    final VoidCallback? onTap = bloquee ? null : (mode ? widget.onFavori : widget.onOuvrir);
    final aide =
        widget.verrou ??
        (!mode
            ? ''
            : widget.favori
            ? l10n.dsRetirerFavoris
            : (widget.peutFavori ? l10n.dsAjouterFavoris : l10n.dsFavorisComplets));
    final bordure = on ? (mode ? c.warning : c.primary) : c.borderDefault;
    return MouseRegion(
      cursor: bloquee ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: Stack(
        // La tuile occupe toute la largeur de sa cellule (grille alignée) et une hauteur fixe.
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Tooltip(
              message: aide,
              child: AnimatedContainer(
                duration: DsMotion.fast,
                curve: DsMotion.standard,
                height: 124,
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
                transform: Matrix4.translationValues(0, _survol && !bloquee ? -1 : 0, 0),
                decoration: BoxDecoration(
                  color: on
                      ? (mode ? c.warningTint : c.primaryTint)
                      : (_survol && !bloquee ? c.surfaceHover : c.surfaceCard),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: bordure, width: on && mode ? 1.5 : 1),
                  boxShadow: _survol && !bloquee ? c.shadowSm : c.shadowXs,
                ),
                child: Opacity(
                  opacity: bloquee ? .55 : 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: on ? c.primary : c.primaryTint,
                              borderRadius: DsRadius.borderLg,
                            ),
                            child: Icon(i.icone, size: 22, color: on ? c.primaryFg : c.primaryTintFg),
                          ),
                          if (i.badge != null || i.badgeTexte != null)
                            PositionedDirectional(
                              top: -6,
                              end: -8,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 18),
                                height: 18,
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: i.badge != null ? c.danger : c.accent,
                                  borderRadius: DsRadius.borderPill,
                                ),
                                child: Text(
                                  i.badge?.toString() ?? i.badgeTexte!,
                                  style: t.caption.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                    color: DsColors.blanc,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        i.libelle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySm.copyWith(fontWeight: FontWeight.w600, height: 1.25),
                      ),
                      if (verrou)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Icon(LucideIcons.lock, size: 11, color: c.textMuted),
                            Flexible(
                              child: Text(
                                widget.verrou!,
                                style: t.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: c.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (mode && !verrou)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: DsMotion.fast,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.favori ? c.warning : c.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.favori ? c.warning : c.borderDefault),
                  ),
                  child: Icon(
                    widget.favori ? LucideIcons.check : LucideIcons.star,
                    size: 13,
                    color: widget.favori ? DsColors.blanc : c.iconMuted,
                  ),
                ),
              ),
            )
          else if (!mode && widget.onFavori != null && !verrou && (_survol || widget.favori))
            PositionedDirectional(
              top: 6,
              end: 6,
              child: DsIconButton(
                icone: LucideIcons.star,
                tooltip: widget.favori
                    ? l10n.dsRetirerFavoris
                    : (widget.peutFavori ? l10n.dsAjouterFavoris : l10n.dsFavorisComplets),
                taille: 26,
                couleur: widget.favori ? c.warning : c.iconMuted,
                onPressed: widget.favori || widget.peutFavori ? widget.onFavori : null,
              ),
            ),
        ],
      ),
    );
  }
}
