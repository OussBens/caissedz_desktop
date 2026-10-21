import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_dialog.dart';
import 'ds_forms.dart';
import 'ds_module.dart';
import 'ds_page.dart';

/// Description d'une colonne du [DsDataTable].
class DsColonne<T> {
  const DsColonne({
    required this.id,
    required this.libelle,
    required this.valeur,
    this.cellule,
    this.largeur,
    this.largeurMin,
    this.flex = 1,
    this.numerique = false,
    this.centre = false,
    this.triable = true,
    this.masquable = true,
    this.visibleParDefaut = true,
    this.total,
    this.permission,
    this.fort = false,
    this.attenue = false,
    this.mono = false,
  });

  /// Identifiant stable (utilisé pour le tri et la visibilité).
  final String id;
  final String libelle;

  /// Valeur brute de la cellule : sert au tri et à l'affichage par défaut.
  final Comparable<dynamic>? Function(T ligne) valeur;

  /// Rendu personnalisé de la cellule (sinon `valeur(ligne).toString()`).
  final Widget Function(BuildContext context, T ligne)? cellule;
  final double? largeur;

  /// Largeur minimale d'une colonne souple : sous la somme des minimums, le tableau défile horizontalement.
  final double? largeurMin;
  final int flex;

  /// Largeur occupée au minimum par la colonne.
  double get largeurMinimale => largeur ?? largeurMin ?? (flex > 1 ? 180 : 110);

  /// Alignement à droite (montants, quantités).
  final bool numerique;
  final bool centre;
  final bool triable;

  /// `false` : colonne obligatoire, toujours affichée (verrouillée dans le dialog « colonnes »).
  final bool masquable;
  final bool visibleParDefaut;

  /// Calcul du total affiché dans la ligne de totaux (sur toutes les lignes).
  final String Function(List<T> lignes)? total;

  /// Permission requise pour voir la colonne (ex. `voirPrixAchat`). Sans la
  /// permission, la colonne est masquée et absente du menu « Colonnes ».
  final String? permission;

  /// Texte 600 couleur primaire (nom, désignation).
  final bool fort;

  /// Texte atténué (codes, dates secondaires).
  final bool attenue;

  /// Police monospace (codes-barres, empreintes).
  final bool mono;
}

/// Action du menu contextuel d'une ligne.
class DsActionContextuelle<T> {
  const DsActionContextuelle({
    required this.libelle,
    required this.onSelected,
    this.icone,
    this.destructif = false,
    this.visible,
    this.kbd,
    this.separateurAvant = false,
  });
  final String libelle;
  final IconData? icone;
  final bool destructif;
  final void Function(T ligne) onSelected;

  /// Condition d'affichage dans le menu (toujours visible si `null`).
  final bool Function(T ligne)? visible;
  final String? kbd;
  final bool separateurAvant;
}

/// Hauteur d'une liste de produits dans un dialog (panier, entrée, sortie, recherche…) : hauteur de l'écran moins
/// [reserve] (en-tête, champs et pied du dialog), au moins [min].
double hauteurListeDialog(BuildContext context, {double reserve = 260, double min = 300}) {
  final h = MediaQuery.sizeOf(context).height - reserve;
  return h < min ? min : h;
}

/// Tableau de données unique du design system (`DataTable`).
///
/// Fonctions : tri par colonne, sélection multiple (case à cocher), colonnes masquables
/// (dialog « Afficher / masquer les colonnes »), pagination DS, menu contextuel (clic droit),
/// ligne de totaux, double-clic, mode dense (40 px), chargement (lignes fantômes).
///
/// Grandes listes : seule la page courante est construite ; le tri et les totaux sont calculés une fois par liste
/// (pas à chaque survol ou sélection) et le survol d'une ligne ne reconstruit que son fond.
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
    this.onClic,
    this.taillePage = 25,
    this.taillesPage = const [25, 50, 100],
    this.pagine = true,
    this.afficherTotaux = false,
    this.colonnesMasquees,
    this.onColonnesMasqueesChanged,
    this.triInitial,
    this.messageVide,
    this.iconeVide = LucideIcons.inbox,
    this.hauteurLigne,
    this.dense = false,
    this.permissions = const {},
    this.reglageColonnes,
    this.encadre = true,
    this.hauteurMax,
    this.hauteurFixe = false,
    this.reserveEcran,
    this.chargement = false,
  });

  final List<DsColonne<T>> colonnes;
  final List<T> lignes;

  /// Clé stable d'une ligne (code métier), utilisée pour la sélection.
  final Object Function(T ligne) cle;
  final Set<Object>? selection;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final List<DsActionContextuelle<T>> actionsContextuelles;
  final void Function(T ligne)? onDoubleClic;

  /// Clic simple sur une ligne (sélection simple dans les pickers).
  final void Function(T ligne)? onClic;
  final int taillePage;
  final List<int> taillesPage;
  final bool pagine;
  final bool afficherTotaux;
  final Set<String>? colonnesMasquees;
  final ValueChanged<Set<String>>? onColonnesMasqueesChanged;
  final DsTri? triInitial;
  final String? messageVide;
  final IconData iconeVide;

  /// Hauteur de ligne explicite (sinon 52, ou 40 en [dense]).
  final double? hauteurLigne;
  final bool dense;

  /// Permissions de l'utilisateur connecté (codes) : filtrent les colonnes à permission.
  final Set<String> permissions;

  /// Afficher le bouton « colonnes » (par défaut : oui sauf en mode dense).
  final bool? reglageColonnes;

  /// Bordure + rayon 12 autour du tableau.
  final bool encadre;

  /// Hauteur maximale (le corps défile au-delà).
  final double? hauteurMax;

  /// Le tableau occupe toujours [hauteurMax] (dialogs : la hauteur ne varie pas avec le nombre de lignes).
  final bool hauteurFixe;

  /// Listes de produits des dialogs : la hauteur maximale suit l'écran, moins cette réserve (en-tête, champs,
  /// pied) — voir [hauteurListeDialog]. Prioritaire sur [hauteurMax].
  final double? reserveEcran;

  /// Données en cours de lecture : sans ligne encore, des lignes fantômes et « Chargement… » remplacent le
  /// message « aucun élément ».
  final bool chargement;

  /// Colonnes que l'utilisateur a le droit de voir.
  List<DsColonne<T>> get colonnesAutorisees =>
      colonnes.where((c) => c.permission == null || permissions.contains(c.permission)).toList();

  @override
  State<DsDataTable<T>> createState() => DsDataTableState<T>();
}

/// État de tri : colonne + sens.
@immutable
class DsTri {
  const DsTri(this.colonneId, {this.ascendant = true});
  final String colonneId;
  final bool ascendant;

  @override
  bool operator ==(Object other) => other is DsTri && other.colonneId == colonneId && other.ascendant == ascendant;
  @override
  int get hashCode => Object.hash(colonneId, ascendant);
}

class DsDataTableState<T> extends State<DsDataTable<T>> {
  DsTri? _tri;
  int _page = 0;
  late int _taillePage;
  late Set<Object> _selection;
  late Set<String> _masquees;

  /// Ligne survolée : écoutée par chaque ligne, sans reconstruire le tableau.
  final _survol = ValueNotifier<Object?>(null);
  final _defilementH = ScrollController();

  // Tri et totaux de la dernière liste reçue, recalculés seulement quand la liste, les colonnes (page reconstruite :
  // leurs valeurs peuvent dépendre d'autres données) ou le tri changent.
  List<DsColonne<T>>? _triColonnes;
  List<DsColonne<T>>? _totauxColonnes;
  List<T>? _triSource;
  DsTri? _triCle;
  List<T> _triCache = const [];
  List<T>? _totauxSource;
  final Map<String, String> _totauxCache = {};

  @override
  void dispose() {
    _survol.dispose();
    _defilementH.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tri = widget.triInitial;
    _taillePage = widget.taillePage;
    _selection = {...?widget.selection};
    _masquees = widget.colonnesMasquees ?? widget.colonnes.where((c) => !c.visibleParDefaut).map((c) => c.id).toSet();
  }

  @override
  void didUpdateWidget(covariant DsDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection != null && widget.selection != oldWidget.selection) {
      _selection = {...widget.selection!};
    }
    if (widget.colonnesMasquees != null && widget.colonnesMasquees != oldWidget.colonnesMasquees) {
      _masquees = {...widget.colonnesMasquees!};
    }
    if (widget.lignes.length != oldWidget.lignes.length) {
      _page = _page.clamp(0, _nbPages(widget.lignes.length) - 1);
    }
  }

  int _nbPages(int n) => widget.pagine ? (n / _taillePage).ceil().clamp(1, 1 << 30) : 1;

  /// Colonnes verrouillées (toujours visibles) : `masquable == false`, ou, à défaut de déclaration,
  /// la colonne `code` et la première colonne forte (sinon la première).
  bool _verrouillee(DsColonne<T> col) {
    final autorisees = widget.colonnesAutorisees;
    if (autorisees.any((c) => !c.masquable)) return !col.masquable;
    final forte = autorisees.where((c) => c.fort).firstOrNull;
    return col.id == 'code' || (forte != null ? identical(col, forte) : identical(col, autorisees.first));
  }

  List<DsColonne<T>> get _visibles =>
      widget.colonnesAutorisees.where((c) => _verrouillee(c) || !_masquees.contains(c.id)).toList();

  List<T> get _triees {
    final tri = _tri;
    if (tri == null) return widget.lignes;
    if (identical(_triSource, widget.lignes) && identical(_triColonnes, widget.colonnes) && _triCle == tri) {
      return _triCache;
    }
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
    _triSource = widget.lignes;
    _triColonnes = widget.colonnes;
    _triCle = tri;
    return _triCache = copie;
  }

  /// Total d'une colonne sur toutes les lignes, gardé tant que la liste ne change pas.
  String _total(DsColonne<T> col) {
    if (!identical(_totauxSource, widget.lignes) || !identical(_totauxColonnes, widget.colonnes)) {
      _totauxSource = widget.lignes;
      _totauxColonnes = widget.colonnes;
      _totauxCache.clear();
    }
    return _totauxCache[col.id] ??= col.total!(widget.lignes);
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
    final actions = [
      for (final a in widget.actionsContextuelles)
        if (a.visible == null || a.visible!(ligne)) a,
    ];
    if (actions.isEmpty) return;
    await afficherMenuContextuel(
      ctx,
      position: position,
      items: [
        for (final a in actions) ...[
          if (a.separateurAvant) const DsMenuItem.separateur(),
          DsMenuItem(
            libelle: a.libelle,
            icone: a.icone,
            kbd: a.kbd,
            danger: a.destructif,
            onTap: () => a.onSelected(ligne),
          ),
        ],
      ],
    );
  }

  Future<void> _reglerColonnes(BuildContext ctx) async {
    final resultat = await afficherReglageColonnes(
      ctx,
      colonnes: [
        for (final col in widget.colonnesAutorisees)
          DsColonneReglage(
            id: col.id,
            libelle: col.libelle,
            verrouillee: _verrouillee(col),
            visible: !_masquees.contains(col.id),
            parDefaut: col.visibleParDefaut,
          ),
      ],
    );
    if (resultat == null || !mounted) return;
    setState(() => _masquees = resultat.masquees);
    widget.onColonnesMasqueesChanged?.call({..._masquees});
  }

  /// Chargement : « Chargement… » puis des lignes fantômes (barres pâles à la place des cellules), sans
  /// animation continue.
  Widget _fantomes(
    List<DsColonne<T>> visibles,
    double hauteurLigne, {
    required bool selectionnable,
    required bool reglage,
    required Widget Function(DsColonne<T>, Widget) cellule,
  }) {
    final c = context.ds.colors;
    const largeurs = [.8, .55, .7, .45, .65, .5];
    return Column(
      key: const ValueKey('table_chargement'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 6; i++)
          Container(
            height: hauteurLigne,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.borderSubtle)),
            ),
            child: Row(
              children: [
                if (selectionnable) const SizedBox(width: 48),
                if (reglage) const SizedBox(width: 44),
                for (final (j, col) in visibles.indexed)
                  cellule(
                    col,
                    i == 0 && j == 0
                        ? Text(
                            AppLocalizations.of(context).dsChargement,
                            style: context.ds.typo.bodySm.copyWith(color: c.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : FractionallySizedBox(
                            widthFactor: largeurs[(i + j) % largeurs.length],
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderSm),
                            ),
                          ),
                  ),
              ],
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
    final afficherReglage = widget.reglageColonnes ?? !widget.dense;
    final hauteurLigne = widget.hauteurLigne ?? (widget.dense ? DsTailles.ligneTableDense : DsTailles.ligneTable);
    final clesPage = lignesPage.map(widget.cle).toSet();
    final toutesSelectionnees = clesPage.isNotEmpty && clesPage.every(_selection.contains);
    final partiel = !toutesSelectionnees && clesPage.any(_selection.contains);
    final nMasquees = widget.colonnesAutorisees.length - visibles.length;

    AlignmentGeometry alignement(DsColonne<T> col) => col.numerique
        ? AlignmentDirectional.centerEnd
        : (col.centre ? Alignment.center : AlignmentDirectional.centerStart);

    Widget cellule(DsColonne<T> col, Widget enfant) {
      final padded = Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4),
        child: Align(alignment: alignement(col), child: enfant),
      );
      if (col.largeur != null) return SizedBox(width: col.largeur, child: padded);
      return Expanded(flex: col.flex, child: padded);
    }

    final styleEnTete = t.overline.copyWith(color: c.textMuted);

    final enTete = Container(
      height: DsTailles.enTeteTable,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        border: Border(bottom: BorderSide(color: c.borderDefault)),
      ),
      child: Row(
        children: [
          if (selectionnable)
            SizedBox(
              width: 48,
              child: Center(
                child: DsCheckbox(
                  cle: const ValueKey('table_tout_selectionner'),
                  semantique: l10n.communToutSelectionner,
                  valeur: toutesSelectionnees,
                  indetermine: partiel,
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
            ),
          if (afficherReglage)
            Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: BorderDirectional(end: BorderSide(color: c.borderSubtle)),
              ),
              child: Builder(
                builder: (ctx) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DsIconButton(
                      key: const ValueKey('table_colonnes'),
                      icone: LucideIcons.columns3,
                      tooltip: l10n.dsColonnesMasquees(visibles.length, widget.colonnesAutorisees.length),
                      taille: 30,
                      couleur: c.textSecondary,
                      onPressed: () => _reglerColonnes(ctx),
                    ),
                    if (nMasquees > 0)
                      PositionedDirectional(
                        top: 2,
                        end: 1,
                        child: IgnorePointer(
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 14),
                            height: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(7)),
                            child: Text(
                              '$nMasquees',
                              style: t.caption.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: c.primaryFg,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          for (final col in visibles)
            cellule(
              col,
              MouseRegion(
                cursor: col.triable ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: col.triable ? () => _basculerTri(col) : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Flexible(
                        child: Text(
                          col.libelle.toUpperCase(),
                          style: _tri?.colonneId == col.id ? styleEnTete.copyWith(color: c.textPrimary) : styleEnTete,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (col.triable)
                        Opacity(
                          opacity: _tri?.colonneId == col.id ? 1 : .5,
                          child: Icon(
                            _tri?.colonneId == col.id
                                ? (_tri!.ascendant ? LucideIcons.chevronUp : LucideIcons.chevronDown)
                                : LucideIcons.chevronsUpDown,
                            size: 12,
                            color: _tri?.colonneId == col.id ? c.textPrimary : c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget ligneWidget(T ligne) {
      final cle = widget.cle(ligne);
      final selectionnee = _selection.contains(cle);
      final cliquable = widget.onDoubleClic != null || widget.onClic != null || selectionnable;
      final rangee = Row(
        children: [
          if (selectionnable)
            SizedBox(
              width: 48,
              child: Center(
                child: DsCheckbox(
                  valeur: selectionnee,
                  onChanged: (_) {
                    final nouvelle = {..._selection};
                    selectionnee ? nouvelle.remove(cle) : nouvelle.add(cle);
                    _changerSelection(nouvelle);
                  },
                ),
              ),
            ),
          if (afficherReglage) const SizedBox(width: 44),
          for (final col in visibles)
            cellule(
              col,
              col.cellule != null
                  ? col.cellule!(context, ligne)
                  : Builder(
                      builder: (context) {
                        final v = col.valeur(ligne);
                        final texte = v == null || v.toString().isEmpty ? '—' : v.toString();
                        final vide = texte == '—';
                        return Text(
                          texte,
                          style: (col.mono ? t.mono : t.bodySm).copyWith(
                            fontWeight: col.fort ? FontWeight.w600 : FontWeight.w400,
                            color: vide || col.attenue ? c.textMuted : (col.fort ? c.textPrimary : c.textBody),
                            fontFeatures: DsTypography.tabular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
            ),
        ],
      );
      // Seul le fond suit le survol : les cellules ne sont pas reconstruites.
      final contenu = ValueListenableBuilder<Object?>(
        valueListenable: _survol,
        child: rangee,
        builder: (context, survol, enfant) => Container(
          height: hauteurLigne,
          decoration: BoxDecoration(
            color: selectionnee ? c.surfaceActive : (survol == cle ? c.surfaceHover : DsColors.transparent),
            border: Border(bottom: BorderSide(color: c.borderSubtle)),
          ),
          child: enfant,
        ),
      );
      return MouseRegion(
        cursor: cliquable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _survol.value = cle,
        onExit: (_) {
          if (_survol.value == cle) _survol.value = null;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: widget.onDoubleClic == null ? null : () => widget.onDoubleClic!(ligne),
          onSecondaryTapDown: (d) => _menuContextuel(context, ligne, d.globalPosition),
          onTap: widget.onClic != null
              ? () => widget.onClic!(ligne)
              : (selectionnable
                    ? () {
                        final nouvelle = {..._selection};
                        selectionnee ? nouvelle.remove(cle) : nouvelle.add(cle);
                        _changerSelection(nouvelle);
                      }
                    : null),
          child: widget.onDoubleClic != null
              ? Tooltip(message: l10n.dsDoubleClicDetail, waitDuration: const Duration(seconds: 1), child: contenu)
              : contenu,
        ),
      );
    }

    final totaux = widget.afficherTotaux && lignesPage.isNotEmpty
        ? Container(
            height: hauteurLigne,
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              border: Border(top: BorderSide(color: c.borderDefault)),
            ),
            child: Row(
              children: [
                if (selectionnable) const SizedBox(width: 48),
                if (afficherReglage) const SizedBox(width: 44),
                for (var i = 0; i < visibles.length; i++)
                  cellule(
                    visibles[i],
                    Text(
                      visibles[i].total != null ? _total(visibles[i]) : (i == 0 ? l10n.communTotal : ''),
                      style: t.bodySmStrong.copyWith(color: c.textPrimary, fontFeatures: DsTypography.tabular),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          )
        : null;

    final nbPages = _nbPages(total);

    final Widget corps = lignesPage.isEmpty && widget.chargement
        ? _fantomes(visibles, hauteurLigne, selectionnable: selectionnable, reglage: afficherReglage, cellule: cellule)
        : lignesPage.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4, vertical: DsSpacing.s12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: DsSpacing.s2,
              children: [
                Icon(widget.iconeVide, size: 28, color: c.iconMuted),
                Text(
                  widget.messageVide ?? l10n.dsAucunElement,
                  style: t.bodySm.copyWith(color: c.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: lignesPage.length,
            itemExtent: hauteurLigne,
            itemBuilder: (_, i) => ligneWidget(lignesPage[i]),
          );

    // Dans une page défilante (hauteur non bornée), le tableau prend la hauteur de ses lignes.
    Widget souple(Widget enfant, bool borne) => borne ? Flexible(child: enfant) : enfant;

    final pagination = DsPagination(
      page: _page + 1,
      nbPages: nbPages,
      total: total,
      taillePage: _taillePage,
      taillesPage: widget.taillesPage,
      nbSelection: _selection.length,
      onChanged: (p) => setState(() => _page = p - 1),
      onTaillePageChanged: (v) => setState(() {
        _taillePage = v;
        _page = 0;
      }),
    );

    // Trop de colonnes pour la largeur disponible : en-tête, lignes et totaux défilent horizontalement ensemble.
    final double largeurMin =
        (selectionnable ? 48 : 0) +
        (afficherReglage ? 44 : 0) +
        visibles.fold(0.0, (s, col) => s + col.largeurMinimale);

    return LayoutBuilder(
      builder: (context, contraintes) {
        final hauteurMax = widget.reserveEcran != null
            ? hauteurListeDialog(context, reserve: widget.reserveEcran!)
            : widget.hauteurMax;
        final borne = contraintes.hasBoundedHeight || hauteurMax != null;
        final etire = widget.hauteurFixe && hauteurMax != null;
        final defilement = contraintes.hasBoundedWidth && contraintes.maxWidth < largeurMin;
        Widget grille = Column(
          mainAxisSize: etire ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            enTete,
            if (etire) Expanded(child: corps) else souple(corps, borne),
            ?totaux,
          ],
        );
        if (defilement) {
          grille = Scrollbar(
            controller: _defilementH,
            thumbVisibility: true,
            child: SingleChildScrollView(
              key: const ValueKey('table_defilement_horizontal'),
              controller: _defilementH,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: largeurMin, child: grille),
            ),
          );
        }
        // Encadré (`ModuleTable`) : la pagination est dans la carte, sous un filet.
        final paginationInterne = widget.pagine && widget.encadre;
        final tableau = Container(
          height: widget.hauteurFixe ? hauteurMax : null,
          constraints: hauteurMax != null ? BoxConstraints(maxHeight: hauteurMax) : null,
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: widget.encadre ? DsRadius.borderLg : null,
            border: widget.encadre ? Border.all(color: c.borderDefault) : null,
            boxShadow: widget.encadre ? c.shadowXs : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (etire) Expanded(child: grille) else souple(grille, borne),
              if (paginationInterne)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4, vertical: DsSpacing.s3),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.borderSubtle)),
                  ),
                  child: pagination,
                ),
            ],
          ),
        );
        if (!widget.pagine || paginationInterne) return tableau;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsSpacing.s3,
          children: [souple(tableau, contraintes.hasBoundedHeight), pagination],
        );
      },
    );
  }
}

/// Formate une valeur numérique de cellule (alias pratique pour les colonnes).
String celluleMontant(double v, [String devise = 'DA']) => formaterMontant(v, devise);
