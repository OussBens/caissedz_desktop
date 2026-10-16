import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_dialog.dart';
import 'ds_forms.dart' show DsLargeurLibelle;
import 'ds_module_kit.dart' show DsFinLigne, DsSpan;
import 'ds_page.dart';

/// Panneau de filtres repliable (`FilterPanel`) : en-tête 52 px, compteur de filtres actifs,
/// grille de champs, boutons « Réinitialiser » / « Filtrer ».
class DsFilterPanel extends StatefulWidget {
  const DsFilterPanel({
    super.key,
    required this.children,
    this.titre,
    this.nbActifs = 0,
    this.ouvert,
    this.ouvertParDefaut = true,
    this.onToggle,
    this.onAppliquer,
    this.onReinitialiser,
    this.libelleAppliquer,
    this.colonnes = 3,
    this.trailing,
  });
  final List<Widget> children;
  final String? titre;
  final int nbActifs;
  final bool? ouvert;
  final bool ouvertParDefaut;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onAppliquer;
  final VoidCallback? onReinitialiser;
  final String? libelleAppliquer;
  final int colonnes;
  final Widget? trailing;

  @override
  State<DsFilterPanel> createState() => _DsFilterPanelState();
}

class _DsFilterPanelState extends State<DsFilterPanel> {
  late bool _ouvert = widget.ouvertParDefaut;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final o = widget.ouvert ?? _ouvert;
    void basculer() {
      if (widget.ouvert == null) setState(() => _ouvert = !o);
      widget.onToggle?.call(!o);
    }

    const gapX = 20.0;
    const gapY = 12.0;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderDefault),
        boxShadow: c.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
            child: Row(
              spacing: 10,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: basculer,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              LucideIcons.slidersHorizontal,
                              size: DsTailles.icone,
                              color: widget.nbActifs > 0 ? c.iconActive : c.iconDefault,
                            ),
                            if (widget.nbActifs > 0)
                              PositionedDirectional(
                                top: -3,
                                end: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: c.danger,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: c.surfaceCard, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(widget.titre ?? l10n.dsFiltres, style: t.cardTitle),
                        if (widget.nbActifs > 0)
                          Container(
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.primaryTint, borderRadius: DsRadius.borderPill),
                            child: Text(
                              l10n.dsActifs(widget.nbActifs),
                              style: t.caption.copyWith(fontWeight: FontWeight.w600, height: 1, color: c.primaryTintFg),
                            ),
                          ),
                        AnimatedRotation(
                          turns: o ? .5 : 0,
                          duration: DsMotion.base,
                          curve: DsMotion.standard,
                          child: Icon(LucideIcons.chevronDown, size: DsTailles.iconeSm, color: c.iconMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ?widget.trailing,
              ],
            ),
          ),
          AnimatedSize(
            duration: DsMotion.slow,
            curve: DsMotion.emphasized,
            alignment: Alignment.topCenter,
            child: o
                ? Container(
                    padding: const EdgeInsets.all(DsSpacing.s4),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.borderSubtle)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: DsSpacing.s4,
                      children: [
                        LayoutBuilder(
                          builder: (context, contraintes) {
                            final n = widget.colonnes;
                            final largeur = (contraintes.maxWidth - gapX * (n - 1)) / n;
                            // Même largeur de libellé dans toutes les cellules : colonnes alignées.
                            double largeurDe(int span) => largeur * span + gapX * (span - 1);
                            // Position dans la ligne courante : un [DsFinLigne] complète la ligne par du vide.
                            var position = 0;
                            final cellules = <Widget>[];
                            for (final ch in widget.children) {
                              if (ch is DsFinLigne) {
                                if (position > 0) cellules.add(SizedBox(width: largeurDe(n - position) - .5));
                                position = 0;
                                continue;
                              }
                              final span = ch is DsSpan ? ch.span.clamp(1, n) : 1;
                              if (position + span > n) position = 0;
                              position = (position + span) % n;
                              cellules.add(SizedBox(width: largeurDe(span), child: ch));
                            }
                            return DsLargeurLibelle(
                              largeur: (largeur * (n >= 4 ? .30 : .36)).clamp(56.0, 110.0),
                              child: Wrap(spacing: gapX, runSpacing: gapY, children: cellules),
                            );
                          },
                        ),
                        if (widget.onAppliquer != null || widget.onReinitialiser != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: DsSpacing.s2,
                            children: [
                              if (widget.onReinitialiser != null)
                                DsButton(
                                  libelle: l10n.dsReinitialiser,
                                  icone: LucideIcons.rotateCcw,
                                  variante: DsButtonVariante.fantome,
                                  onPressed: widget.nbActifs == 0 ? null : widget.onReinitialiser,
                                ),
                              if (widget.onAppliquer != null)
                                DsButton(
                                  libelle: widget.libelleAppliquer ?? l10n.dsFiltrer,
                                  icone: LucideIcons.filter,
                                  onPressed: widget.onAppliquer,
                                ),
                            ],
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Pagination (`Pagination`) : « 1–25 sur 240 », taille de page, boutons de pages avec ellipses.
class DsPagination extends StatelessWidget {
  const DsPagination({
    super.key,
    required this.page,
    required this.nbPages,
    required this.onChanged,
    this.total,
    this.taillePage = 25,
    this.taillesPage = const [25, 50, 100],
    this.onTaillePageChanged,
    this.nbSelection = 0,
  });

  /// Page courante, à partir de 1.
  final int page;
  final int nbPages;
  final ValueChanged<int> onChanged;
  final int? total;
  final int taillePage;
  final List<int> taillesPage;
  final ValueChanged<int>? onTaillePageChanged;
  final int nbSelection;

  /// Pages à afficher (nombres) et ellipses (`null`), comme `Pagination.pages`.
  static List<int?> pages(int p, int n) {
    if (n <= 7) return [for (var i = 1; i <= n; i++) i];
    final s = <int>{1, n, p - 1, p, p + 1};
    if (p <= 4) s.addAll([2, 3, 4, 5]);
    if (p >= n - 3) s.addAll([n - 4, n - 3, n - 2, n - 1]);
    final a = s.where((x) => x >= 1 && x <= n).toList()..sort();
    final out = <int?>[];
    for (var i = 0; i < a.length; i++) {
      if (i > 0 && a[i] - a[i - 1] > 1) out.add(null);
      out.add(a[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final tot = total ?? 0;
    final de = tot == 0 ? 0 : (page - 1) * taillePage + 1;
    final a = tot == 0 ? 0 : (page * taillePage).clamp(0, tot);
    final style = t.bodySm.copyWith(color: c.textSecondary);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DsSpacing.s3,
      runSpacing: DsSpacing.s2,
      children: [
        if (total != null)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$de–$a',
                  style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text:
                      ' ${l10n.communPagination(0, 0, 0).replaceAll(RegExp(r'[0-9–]'), '').trim()} ${formaterNombre(tot.toDouble())}',
                ),
              ],
            ),
            style: style.copyWith(fontFeatures: DsTypography.tabular),
          ),
        if (onTaillePageChanged != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DsSpacing.s2,
            children: [
              DsSelect<int>(
                valeur: taillesPage.contains(taillePage) ? taillePage : null,
                options: taillesPage,
                libelle: (n) => '$n',
                taille: DsTailles.controleSm,
                largeur: 76,
                onChanged: (v) => v == null ? null : onTaillePageChanged!(v),
              ),
              Text(l10n.dsParPage, style: style),
            ],
          ),
        if (nbSelection > 0) Text(l10n.communSelectionnes(nbSelection), style: style.copyWith(color: c.primaryTintFg)),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            _BoutonPage(
              tooltip: l10n.dsPagePrecedente,
              desactive: page <= 1,
              onTap: () => onChanged(page - 1),
              child: Icon(LucideIcons.chevronLeft, size: 16, color: c.textBody),
            ),
            for (final x in pages(page, nbPages))
              if (x == null)
                SizedBox(
                  width: 24,
                  child: Text(
                    '…',
                    textAlign: TextAlign.center,
                    style: style.copyWith(color: c.textMuted),
                  ),
                )
              else
                _BoutonPage(
                  actif: x == page,
                  onTap: () => onChanged(x),
                  child: Text(
                    '$x',
                    style: t.bodySm.copyWith(
                      fontWeight: x == page ? FontWeight.w600 : FontWeight.w500,
                      color: x == page ? c.primaryFg : c.textBody,
                      fontFeatures: DsTypography.tabular,
                    ),
                  ),
                ),
            _BoutonPage(
              tooltip: l10n.dsPageSuivante,
              desactive: page >= nbPages,
              onTap: () => onChanged(page + 1),
              child: Icon(LucideIcons.chevronRight, size: 16, color: c.textBody),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoutonPage extends StatefulWidget {
  const _BoutonPage({
    required this.child,
    required this.onTap,
    this.actif = false,
    this.desactive = false,
    this.tooltip,
  });
  final Widget child;
  final VoidCallback onTap;
  final bool actif;
  final bool desactive;
  final String? tooltip;
  @override
  State<_BoutonPage> createState() => _BoutonPageState();
}

class _BoutonPageState extends State<_BoutonPage> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final bouton = MouseRegion(
      cursor: widget.desactive ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: widget.desactive ? null : widget.onTap,
        child: Opacity(
          opacity: widget.desactive ? .4 : 1,
          child: AnimatedContainer(
            duration: DsMotion.fast,
            constraints: const BoxConstraints(minWidth: 32),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.actif ? c.primary : (_survol && !widget.desactive ? c.surfaceHover : DsColors.transparent),
              borderRadius: DsRadius.borderMd,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
    if (widget.tooltip == null) return bouton;
    return Tooltip(message: widget.tooltip!, child: bouton);
  }
}

/// Règle d'activation d'une action de sélection.
enum DsRegleSelection { une, plusieurs, toujours }

/// Action d'une [DsSelectionBar].
class DsActionSelection {
  const DsActionSelection({
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.regle = DsRegleSelection.plusieurs,
    this.variante = DsButtonVariante.secondaire,
    this.danger = false,
    this.desactive = false,
    this.cle,
  });
  final String libelle;
  final VoidCallback onPressed;
  final IconData? icone;
  final DsRegleSelection regle;
  final DsButtonVariante variante;
  final bool danger;
  final bool desactive;
  final Key? cle;
}

/// Barre d'actions sur la sélection (`SelectionBar`) : compteur teinté + boutons conditionnés.
class DsSelectionBar extends StatelessWidget {
  const DsSelectionBar({
    super.key,
    required this.nb,
    this.total,
    this.actions = const [],
    this.onEffacer,
    this.leading,
    this.trailing,
    this.petit = false,
  });
  final int nb;
  final int? total;
  final List<DsActionSelection> actions;
  final VoidCallback? onEffacer;
  final Widget? leading;
  final Widget? trailing;
  final bool petit;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    // Recherche à gauche, compteur + actions à droite ; les actions passent à la ligne quand la
    // largeur manque (fenêtre minimale 1000 px, modules à 5 actions).
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DsSpacing.s4,
        runSpacing: DsSpacing.s2,
        children: [
          ?leading,
          Wrap(
            spacing: DsSpacing.s2,
            runSpacing: DsSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (nb > 0)
                Container(
                  height: 32,
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
                  decoration: BoxDecoration(color: c.primaryTint, borderRadius: DsRadius.borderMd),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: DsSpacing.s2,
                    children: [
                      Icon(LucideIcons.listChecks, size: 16, color: c.primaryTintFg),
                      Text(
                        total != null ? l10n.dsSelectionneSur(nb, total!) : l10n.communSelectionnes(nb),
                        style: t.bodySmStrong.copyWith(color: c.primaryTintFg),
                      ),
                      if (onEffacer != null)
                        DsIconButton(
                          icone: LucideIcons.x,
                          tooltip: l10n.dsToutDeselectionner,
                          taille: 24,
                          couleur: c.primaryTintFg,
                          onPressed: onEffacer,
                        ),
                    ],
                  ),
                ),
              for (final a in actions)
                Builder(
                  builder: (context) {
                    final ok = switch (a.regle) {
                      DsRegleSelection.une => nb == 1,
                      DsRegleSelection.plusieurs => nb >= 1,
                      DsRegleSelection.toujours => true,
                    };
                    final actif = ok && !a.desactive;
                    return Tooltip(
                      message: actif
                          ? a.libelle
                          : (a.regle == DsRegleSelection.une ? l10n.dsSelectionnezUne : l10n.dsSelectionnezAuMoins),
                      child: KeyedSubtree(
                        key: a.cle,
                        child: DsButton(
                          libelle: a.libelle,
                          icone: a.icone,
                          taille: petit ? DsButtonTaille.sm : DsButtonTaille.md,
                          variante: a.danger && actif ? DsButtonVariante.danger : a.variante,
                          onPressed: actif ? a.onPressed : null,
                        ),
                      ),
                    );
                  },
                ),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

/// Formats d'export du [DsExportMenu].
enum DsFormatExport { excel, pdf }

/// Portée d'un export.
enum DsPorteeExport { tout, selection }

/// Menu d'export (`ExportMenu`) : boutons Excel / PDF ; avec sélection, menu « Tout / Sélection ».
class DsExportMenu extends StatelessWidget {
  const DsExportMenu({
    super.key,
    required this.onExport,
    this.nbSelection = 0,
    this.total,
    this.formats = const [DsFormatExport.excel, DsFormatExport.pdf],
    this.separe = true,
    this.petit = false,
  });
  final void Function(DsFormatExport format, DsPorteeExport portee) onExport;
  final int nbSelection;
  final int? total;
  final List<DsFormatExport> formats;

  /// `true` : un bouton par format ; `false` : un seul bouton « Exporter ».
  final bool separe;
  final bool petit;

  (String, IconData, Color) _infos(BuildContext context, DsFormatExport f) {
    final c = context.ds.colors;
    return switch (f) {
      DsFormatExport.excel => ('Excel', LucideIcons.fileSpreadsheet, c.success),
      DsFormatExport.pdf => ('PDF', LucideIcons.fileText, c.danger),
    };
  }

  Future<void> _menu(BuildContext context, List<DsFormatExport> fs) async {
    final l10n = AppLocalizations.of(context);
    final boite = context.findRenderObject()! as RenderBox;
    final pos = boite.localToGlobal(Offset(0, boite.size.height + 6));
    await afficherMenuContextuel(
      context,
      position: pos,
      items: [
        for (final f in fs) ...[
          DsMenuItem(
            libelle: separe ? l10n.dsToutExporter : '${_infos(context, f).$1} · ${l10n.dsToutExporter.toLowerCase()}',
            icone: _infos(context, f).$2,
            kbd: total?.toString(),
            onTap: () => onExport(f, DsPorteeExport.tout),
          ),
          if (nbSelection > 0)
            DsMenuItem(
              libelle: separe
                  ? l10n.dsSelectionSeulement
                  : '${_infos(context, f).$1} · ${l10n.dsSelectionSeulement.toLowerCase()}',
              icone: LucideIcons.listChecks,
              kbd: '$nbSelection',
              onTap: () => onExport(f, DsPorteeExport.selection),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final taille = petit ? DsButtonTaille.sm : DsButtonTaille.md;
    if (!separe) {
      return Builder(
        builder: (ctx) => DsButton(
          libelle: l10n.dsExporter,
          icone: LucideIcons.download,
          iconeDroite: LucideIcons.chevronDown,
          variante: DsButtonVariante.secondaire,
          taille: taille,
          delaiGarde: Duration.zero,
          onPressed: () => _menu(ctx, formats),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DsSpacing.s2,
      children: [
        for (final f in formats)
          Builder(
            builder: (ctx) {
              final (libelle, icone, couleur) = _infos(ctx, f);
              return _BoutonExport(
                libelle: libelle,
                icone: icone,
                couleur: couleur,
                taille: taille,
                menu: nbSelection > 0,
                onPressed: () => nbSelection > 0 ? _menu(ctx, [f]) : onExport(f, DsPorteeExport.tout),
              );
            },
          ),
      ],
    );
  }
}

class _BoutonExport extends StatelessWidget {
  const _BoutonExport({
    required this.libelle,
    required this.icone,
    required this.couleur,
    required this.taille,
    required this.menu,
    required this.onPressed,
  });
  final String libelle;
  final IconData icone;
  final Color couleur;
  final DsButtonTaille taille;
  final bool menu;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final h = taille == DsButtonTaille.sm ? DsTailles.controleSm : DsTailles.controleMd;
    return Semantics(
      button: true,
      label: libelle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: h,
            padding: EdgeInsets.symmetric(horizontal: taille == DsButtonTaille.sm ? 12 : 14),
            decoration: BoxDecoration(
              color: c.surfaceCard,
              borderRadius: DsRadius.borderMd,
              border: Border.all(color: c.borderDefault),
              boxShadow: c.shadowXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DsSpacing.s2,
              children: [
                Icon(icone, size: 16, color: couleur),
                Text(
                  libelle,
                  style: t.body.copyWith(
                    fontSize: taille == DsButtonTaille.sm ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                if (menu) Icon(LucideIcons.chevronDown, size: 16, color: c.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
