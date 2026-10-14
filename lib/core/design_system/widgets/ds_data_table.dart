import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Description d'une colonne du [DsDataTable].
class DsColonne<T> {
  const DsColonne({
    required this.id,
    required this.libelle,
    required this.valeur,
    this.cellule,
    this.largeur,
    this.flex = 1,
    this.numerique = false,
    this.triable = true,
    this.masquable = true,
    this.visibleParDefaut = true,
    this.total,
  });

  /// Identifiant stable (utilisé pour le tri et la visibilité).
  final String id;
  final String libelle;

  /// Valeur brute de la cellule : sert au tri et à l'affichage par défaut.
  final Comparable<dynamic>? Function(T ligne) valeur;

  /// Rendu personnalisé de la cellule (sinon `valeur(ligne).toString()`).
  final Widget Function(BuildContext context, T ligne)? cellule;
  final double? largeur;
  final int flex;
  final bool numerique;
  final bool triable;
  final bool masquable;
  final bool visibleParDefaut;

  /// Calcul du total affiché dans la ligne de totaux (sur toutes les lignes).
  final String Function(List<T> lignes)? total;
}

/// Action du menu contextuel d'une ligne.
class DsActionContextuelle<T> {
  const DsActionContextuelle({
    required this.libelle,
    required this.onSelected,
    this.icone,
    this.destructif = false,
  });
  final String libelle;
  final IconData? icone;
  final bool destructif;
  final void Function(T ligne) onSelected;
}

/// Tableau de données unique du design system.
///
/// Fonctions : tri par colonne, sélection multiple (case à cocher), colonnes
/// masquables (menu « Colonnes »), pagination, menu contextuel (clic droit),
/// ligne de totaux, double-clic.
class DsDataTable<T> extends StatefulWidget {
  const DsDataTable({
    super.key,
    required this.colonnes,
    required this.lignes,
    required this.cle,
    this.selection,
    this.onSelectionChanged,
    this.actionsContextuelles = const [],
    this.onDoubleClic,
    this.taillePage = 25,
    this.taillesPage = const [10, 25, 50, 100],
    this.pagine = true,
    this.afficherTotaux = false,
    this.colonnesMasquees,
    this.onColonnesMasqueesChanged,
    this.triInitial,
    this.messageVide,
    this.hauteurLigne = DsTailles.ligneTable,
  });

  final List<DsColonne<T>> colonnes;
  final List<T> lignes;

  /// Clé stable d'une ligne (code métier), utilisée pour la sélection.
  final Object Function(T ligne) cle;
  final Set<Object>? selection;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final List<DsActionContextuelle<T>> actionsContextuelles;
  final void Function(T ligne)? onDoubleClic;
  final int taillePage;
  final List<int> taillesPage;
  final bool pagine;
  final bool afficherTotaux;
  final Set<String>? colonnesMasquees;
  final ValueChanged<Set<String>>? onColonnesMasqueesChanged;
  final DsTri? triInitial;
  final String? messageVide;
  final double hauteurLigne;

  @override
  State<DsDataTable<T>> createState() => _DsDataTableState<T>();
}

/// État de tri : colonne + sens.
@immutable
class DsTri {
  const DsTri(this.colonneId, {this.ascendant = true});
  final String colonneId;
  final bool ascendant;

  @override
  bool operator ==(Object other) =>
      other is DsTri && other.colonneId == colonneId && other.ascendant == ascendant;
  @override
  int get hashCode => Object.hash(colonneId, ascendant);
}

class _DsDataTableState<T> extends State<DsDataTable<T>> {
  DsTri? _tri;
  int _page = 0;
  late int _taillePage;
  late Set<Object> _selection;
  late Set<String> _masquees;
  Object? _survol;

  @override
  void initState() {
    super.initState();
    _tri = widget.triInitial;
    _taillePage = widget.taillePage;
    _selection = {...?widget.selection};
    _masquees = widget.colonnesMasquees ??
        widget.colonnes.where((c) => !c.visibleParDefaut).map((c) => c.id).toSet();
  }

  @override
  void didUpdateWidget(covariant DsDataTable<T> old) {
    super.didUpdateWidget(old);
    if (widget.selection != null && widget.selection != old.selection) {
      _selection = {...widget.selection!};
    }
    if (widget.colonnesMasquees != null && widget.colonnesMasquees != old.colonnesMasquees) {
      _masquees = {...widget.colonnesMasquees!};
    }
    if (widget.lignes.length != old.lignes.length) {
      _page = _page.clamp(0, _nbPages(widget.lignes.length) - 1);
    }
  }

  int _nbPages(int n) => widget.pagine ? (n / _taillePage).ceil().clamp(1, 1 << 30) : 1;

  List<DsColonne<T>> get _visibles => widget.colonnes.where((c) => !_masquees.contains(c.id)).toList();

  List<T> get _triees {
    final tri = _tri;
    if (tri == null) return widget.lignes;
    final colonne = widget.colonnes.where((c) => c.id == tri.colonneId).firstOrNull;
    if (colonne == null) return widget.lignes;
    final copie = [...widget.lignes];
    copie.sort((a, b) {
      final va = colonne.valeur(a);
      final vb = colonne.valeur(b);
      int r;
      if (va == null && vb == null) {
        r = 0;
      } else if (va == null) {
        r = -1;
      } else if (vb == null) {
        r = 1;
      } else {
        r = va.compareTo(vb);
      }
      return tri.ascendant ? r : -r;
    });
    return copie;
  }

  List<T> get _pageCourante {
    final triees = _triees;
    if (!widget.pagine) return triees;
    final debut = _page * _taillePage;
    if (debut >= triees.length) return const [];
    return triees.sublist(debut, (debut + _taillePage).clamp(0, triees.length));
  }

  void _changerSelection(Set<Object> nouvelle) {
    setState(() => _selection = nouvelle);
    widget.onSelectionChanged?.call(nouvelle);
  }

  void _basculerTri(DsColonne<T> colonne) {
    if (!colonne.triable) return;
    setState(() {
      if (_tri?.colonneId == colonne.id) {
        _tri = _tri!.ascendant ? DsTri(colonne.id, ascendant: false) : null;
      } else {
        _tri = DsTri(colonne.id);
      }
    });
  }

  Future<void> _menuContextuel(BuildContext ctx, T ligne, Offset position) async {
    if (widget.actionsContextuelles.isEmpty) return;
    final c = ctx.ds.colors;
    final t = ctx.ds.typo;
    final overlay = Overlay.of(ctx).context.findRenderObject()! as RenderBox;
    final choix = await showMenu<int>(
      context: ctx,
      position: RelativeRect.fromRect(position & const Size(1, 1), Offset.zero & overlay.size),
      items: [
        for (var i = 0; i < widget.actionsContextuelles.length; i++)
          PopupMenuItem<int>(
            value: i,
            height: 36,
            child: Row(
              children: [
                if (widget.actionsContextuelles[i].icone != null) ...[
                  Icon(
                    widget.actionsContextuelles[i].icone,
                    size: DsTailles.iconeSm,
                    color: widget.actionsContextuelles[i].destructif ? c.danger : c.texteSecondaire,
                  ),
                  const SizedBox(width: DsSpacing.sm),
                ],
                Text(
                  widget.actionsContextuelles[i].libelle,
                  style: t.corps.copyWith(
                    color: widget.actionsContextuelles[i].destructif ? c.danger : c.texte,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    if (choix != null) widget.actionsContextuelles[choix].onSelected(ligne);
  }

  Future<void> _menuColonnes(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx);
    final c = ctx.ds.colors;
    final t = ctx.ds.typo;
    final bouton = ctx.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(ctx).context.findRenderObject()! as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        bouton.localToGlobal(Offset.zero, ancestor: overlay),
        bouton.localToGlobal(bouton.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    await showMenu<void>(
      context: ctx,
      position: pos,
      items: [
        PopupMenuItem<void>(
          enabled: false,
          height: 32,
          child: Text(l10n.communColonnes, style: t.legende.copyWith(color: c.texteAttenue)),
        ),
        for (final col in widget.colonnes.where((c) => c.masquable))
          PopupMenuItem<void>(
            height: 36,
            child: StatefulBuilder(
              builder: (ctx2, setMenu) => Row(
                children: [
                  Checkbox(
                    value: !_masquees.contains(col.id),
                    activeColor: c.primaire,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _masquees.remove(col.id);
                        } else {
                          _masquees.add(col.id);
                        }
                      });
                      setMenu(() {});
                      widget.onColonnesMasqueesChanged?.call({..._masquees});
                    },
                  ),
                  Text(col.libelle, style: t.corps),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final visibles = _visibles;
    final lignesPage = _pageCourante;
    final total = widget.lignes.length;
    final selectionnable = widget.onSelectionChanged != null;
    final clesPage = lignesPage.map(widget.cle).toSet();
    final toutesSelectionnees = clesPage.isNotEmpty && clesPage.every(_selection.contains);
    final partiel = !toutesSelectionnees && clesPage.any(_selection.contains);

    Widget cellule(DsColonne<T> col, Widget enfant) {
      final contenu = Align(
        alignment: col.numerique ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: enfant,
      );
      final padded = Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md),
        child: contenu,
      );
      if (col.largeur != null) return SizedBox(width: col.largeur, child: padded);
      return Expanded(flex: col.flex, child: padded);
    }

    final enTete = Container(
      height: DsTailles.enTeteTable,
      decoration: BoxDecoration(
        color: c.surfaceAttenuee,
        border: Border(bottom: BorderSide(color: c.bordure)),
      ),
      child: Row(
        children: [
          if (selectionnable)
            SizedBox(
              width: 44,
              child: Checkbox(
                tristate: true,
                value: toutesSelectionnees ? true : (partiel ? null : false),
                activeColor: c.primaire,
                semanticLabel: l10n.communToutSelectionner,
                onChanged: (_) {
                  final nouvelle = {..._selection};
                  if (toutesSelectionnees) {
                    nouvelle.removeAll(clesPage);
                  } else {
                    nouvelle.addAll(clesPage);
                  }
                  _changerSelection(nouvelle);
                },
              ),
            ),
          for (final col in visibles)
            cellule(
              col,
              InkWell(
                onTap: col.triable ? () => _basculerTri(col) : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        col.libelle,
                        style: t.petitFort.copyWith(color: c.texteSecondaire),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_tri?.colonneId == col.id) ...[
                      const SizedBox(width: DsSpacing.xs),
                      Icon(
                        _tri!.ascendant ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                        size: 14,
                        color: c.primaire,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Builder(
            builder: (ctx) => DsIconButton(
              icone: LucideIcons.columns3,
              tooltip: l10n.communColonnes,
              onPressed: () => _menuColonnes(ctx),
            ),
          ),
          const SizedBox(width: DsSpacing.xs),
        ],
      ),
    );

    Widget ligneWidget(T ligne) {
      final cle = widget.cle(ligne);
      final selectionnee = _selection.contains(cle);
      final survolee = _survol == cle;
      return MouseRegion(
        onEnter: (_) => setState(() => _survol = cle),
        onExit: (_) => setState(() => _survol = null),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: widget.onDoubleClic == null ? null : () => widget.onDoubleClic!(ligne),
          onSecondaryTapDown: (d) => _menuContextuel(context, ligne, d.globalPosition),
          onTap: selectionnable
              ? () {
                  final nouvelle = {..._selection};
                  if (selectionnee) {
                    nouvelle.remove(cle);
                  } else {
                    nouvelle.add(cle);
                  }
                  _changerSelection(nouvelle);
                }
              : null,
          child: Container(
            height: widget.hauteurLigne,
            decoration: BoxDecoration(
              color: selectionnee ? c.selection : (survolee ? c.surfaceAttenuee : c.surface),
              border: Border(bottom: BorderSide(color: c.bordure)),
            ),
            child: Row(
              children: [
                if (selectionnable)
                  SizedBox(
                    width: 44,
                    child: Checkbox(
                      value: selectionnee,
                      activeColor: c.primaire,
                      onChanged: (_) {
                        final nouvelle = {..._selection};
                        if (selectionnee) {
                          nouvelle.remove(cle);
                        } else {
                          nouvelle.add(cle);
                        }
                        _changerSelection(nouvelle);
                      },
                    ),
                  ),
                for (final col in visibles)
                  cellule(
                    col,
                    col.cellule != null
                        ? col.cellule!(context, ligne)
                        : Text(
                            col.valeur(ligne)?.toString() ?? '',
                            style: col.numerique ? t.corps.copyWith(fontFeatures: const [FontFeature.tabularFigures()]) : t.corps,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),
      );
    }

    final totaux = widget.afficherTotaux
        ? Container(
            height: widget.hauteurLigne,
            decoration: BoxDecoration(
              color: c.surfaceAttenuee,
              border: Border(top: BorderSide(color: c.bordureForte)),
            ),
            child: Row(
              children: [
                if (selectionnable) const SizedBox(width: 44),
                for (var i = 0; i < visibles.length; i++)
                  cellule(
                    visibles[i],
                    Text(
                      visibles[i].total != null
                          ? visibles[i].total!(widget.lignes)
                          : (i == 0 ? l10n.communTotal : ''),
                      style: t.corpsFort.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
                const SizedBox(width: 44),
              ],
            ),
          )
        : null;

    final nbPages = _nbPages(total);
    final debut = total == 0 ? 0 : _page * _taillePage + 1;
    final fin = total == 0 ? 0 : (debut + lignesPage.length - 1);
    final piedDePage = widget.pagine
        ? Container(
            height: DsTailles.enTeteTable,
            padding: const EdgeInsetsDirectional.only(start: DsSpacing.md, end: DsSpacing.sm),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.bordure))),
            child: Row(
              children: [
                if (_selection.isNotEmpty)
                  Text(l10n.communSelectionnes(_selection.length), style: t.petit.copyWith(color: c.primaire)),
                const Spacer(),
                Text(l10n.communLignesParPage, style: t.petit.copyWith(color: c.texteSecondaire)),
                const SizedBox(width: DsSpacing.sm),
                DropdownButton<int>(
                  value: widget.taillesPage.contains(_taillePage) ? _taillePage : null,
                  underline: const SizedBox.shrink(),
                  style: t.petit.copyWith(color: c.texte),
                  items: [
                    for (final n in widget.taillesPage) DropdownMenuItem(value: n, child: Text('$n')),
                  ],
                  onChanged: (v) => setState(() {
                    _taillePage = v ?? _taillePage;
                    _page = 0;
                  }),
                ),
                const SizedBox(width: DsSpacing.lg),
                Text(l10n.communPagination(debut, fin, total), style: t.petit.copyWith(color: c.texteSecondaire)),
                const SizedBox(width: DsSpacing.sm),
                DsIconButton(
                  icone: LucideIcons.chevronLeft,
                  tooltip: l10n.communPagePrecedente,
                  onPressed: _page > 0 ? () => setState(() => _page--) : null,
                ),
                DsIconButton(
                  icone: LucideIcons.chevronRight,
                  tooltip: l10n.communPageSuivante,
                  onPressed: _page < nbPages - 1 ? () => setState(() => _page++) : null,
                ),
              ],
            ),
          )
        : null;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.bordure),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          enTete,
          if (lignesPage.isEmpty)
            SizedBox(
              height: widget.hauteurLigne * 3,
              child: Center(
                child: Text(
                  widget.messageVide ?? l10n.communAucunResultat,
                  style: t.corps.copyWith(color: c.texteAttenue),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lignesPage.length,
                itemExtent: widget.hauteurLigne,
                itemBuilder: (_, i) => ligneWidget(lignesPage[i]),
              ),
            ),
          ?totaux,
          ?piedDePage,
        ],
      ),
    );
  }
}
