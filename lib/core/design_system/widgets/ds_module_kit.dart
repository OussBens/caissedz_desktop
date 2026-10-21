import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_data_table.dart';
import 'ds_dialog.dart';
import 'ds_forms.dart';
import 'ds_module.dart';
import 'ds_page.dart';
import 'ds_primitives.dart';

/// Briques partagées des écrans de module (`ui_kits/desktop/ModuleKit.jsx`) :
/// [DsModuleTable], [DsGridCard], [DsEntityDetailDialog], [DsSubHead].

/// Lecture seule (essai terminé), posée à la racine de l'application (pages et dialogs) : un
/// [DsModuleTable] n'y offre que le détail des lignes (ni création, ni modification, ni export, ni menu
/// contextuel) et un [DsEntityDetailDialog] ni Modifier ni ses actions de pied (impression, versement…).
class DsLectureSeule extends InheritedWidget {
  const DsLectureSeule({super.key, required this.actif, required super.child});

  final bool actif;

  static bool de(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DsLectureSeule>()?.actif ?? false;

  @override
  bool updateShouldNotify(DsLectureSeule ancien) => ancien.actif != actif;
}

/// Place d'une action dans la barre d'un module, dans cet ordre : autres actions, Détail, Supprimer /
/// Annuler / Désactiver, Modifier (puis le bouton Nouveau). Détail, suppression et modification sont des
/// icônes seules, leur libellé en infobulle. [principale] : l'action phare du module, en violet tout à droite
/// (avant le bouton Nouveau), avec son libellé.
enum DsGenreAction { autre, detail, suppression, modification, principale }

/// Action de la barre de sélection d'un [DsModuleTable] : reçoit les lignes cochées.
class DsActionModule<T> {
  const DsActionModule({
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.regle = DsRegleSelection.plusieurs,
    this.danger = false,
    this.desactive,
    this.cle,
    this.detail = false,
    this.iconeSeule = false,
    this.genre,
  });

  /// Place imposée dans la barre ; sinon déduite (voir [place]).
  final DsGenreAction? genre;

  /// Icônes de suppression, d'annulation et de désactivation (corbeille, croix, pause, utilisateur barré).
  static final Set<IconData> _iconesSuppression = {
    LucideIcons.trash2,
    LucideIcons.x,
    LucideIcons.circlePause,
    LucideIcons.userX,
    LucideIcons.ban,
  };

  /// Le genre donné, sinon déduit : [detail], le crayon (Modifier), une icône de suppression sur une
  /// action [danger] ; le reste est une autre action.
  DsGenreAction get place =>
      genre ??
      (detail
          ? DsGenreAction.detail
          : icone == LucideIcons.pencil
          ? DsGenreAction.modification
          : danger && _iconesSuppression.contains(icone)
          ? DsGenreAction.suppression
          : DsGenreAction.autre);

  /// Bouton réduit à l'icône : Détail, Supprimer / Annuler, Modifier toujours, les autres sur demande.
  bool get reduiteAIcone =>
      icone != null && (iconeSeule || (place != DsGenreAction.autre && place != DsGenreAction.principale));
  final String libelle;
  final IconData? icone;
  final DsRegleSelection regle;
  final bool danger;

  /// Désactivation selon la sélection (ex. ligne système, déjà annulée).
  final bool Function(List<T> choisis)? desactive;

  /// Reçoit les lignes choisies et une fonction qui vide la sélection.
  final FutureOr<void> Function(List<T> choisis, VoidCallback effacer) onPressed;
  final Key? cle;

  /// Action « Détail » (œil) : déclenchée aussi par le double-clic sur une ligne.
  final bool detail;

  /// Bouton réduit à l'icône (Modifier, Annuler), libellé en infobulle.
  final bool iconeSeule;
}

/// Libellés FR / AR / EN des périodes rapides du [DsPeriodFilter].
Map<String, String> libellesPeriodes(AppLocalizations l10n) => {
  'today': l10n.dsPeriodeAujourdhui,
  'yesterday': l10n.dsPeriodeHier,
  'week': l10n.dsPeriodeSemaine,
  'lastWeek': l10n.dsPeriodeSemaineDerniere,
  'month': l10n.dsPeriodeMois,
  'lastMonth': l10n.dsPeriodeMoisDernier,
  'last7days': l10n.dsPeriode7Jours,
  'last30days': l10n.dsPeriode30Jours,
  'year': l10n.dsPeriodeAnnee,
  'lastYear': l10n.dsPeriodeAnneeDerniere,
};

/// Filtre de période localisé (Du / Au / Période rapide).
class DsPeriodeLocalisee extends StatelessWidget {
  const DsPeriodeLocalisee({super.key, required this.periode, required this.onChanged});
  final DsPeriode periode;
  final ValueChanged<DsPeriode> onChanged;

  static DsPeriodFilter _filtre(BuildContext context, DsPeriode periode, ValueChanged<DsPeriode> onChanged) {
    final l10n = AppLocalizations.of(context);
    return DsPeriodFilter(
      periode: periode,
      onChanged: onChanged,
      libelleDu: l10n.dsDu,
      libelleAu: l10n.dsAu,
      libellePreset: l10n.dsPeriodeRapide,
      libellesPresets: libellesPeriodes(l10n),
    );
  }

  /// Du / Au / Période rapide en trois cellules d'une grille de filtres (alignés sur les autres filtres).
  static List<Widget> champs(BuildContext context, DsPeriode periode, ValueChanged<DsPeriode> onChanged) =>
      _filtre(context, periode, onChanged).champs;

  @override
  Widget build(BuildContext context) => _filtre(context, periode, onChanged);
}

/// `true` si [date] est dans [periode] (bornes incluses, à la journée).
bool dansPeriode(DateTime date, DsPeriode periode) {
  final j = DateTime(date.year, date.month, date.day);
  final du = DateTime(periode.du.year, periode.du.month, periode.du.day);
  final au = DateTime(periode.au.year, periode.au.month, periode.au.day);
  return !j.isBefore(du) && !j.isAfter(au);
}

/// Recherche pré-remplie dans les [DsModuleTable] du sous-arbre (ouverture depuis la recherche globale).
class DsRechercheInitiale extends InheritedWidget {
  const DsRechercheInitiale({super.key, required this.texte, required super.child});
  final String? texte;

  @override
  bool updateShouldNotify(DsRechercheInitiale oldWidget) => texte != oldWidget.texte;
}

/// Mode d'affichage d'un [DsModuleTable] à cartes.
enum DsVueModule { grille, liste }

/// État d'une carte de grille : sélection, bascule, ouverture.
class DsEtatCarte {
  const DsEtatCarte({required this.selectionnee, required this.basculer, this.ouvrir});
  final bool selectionnee;
  final VoidCallback basculer;
  final VoidCallback? ouvrir;
}

/// Onglet de module standard (`ModuleTable`) :
/// KPI → filtres + export → barre de sélection (recherche, actions, bouton principal) → tableau + totaux
/// → pagination ; vue grille optionnelle (cartes sélectionnables).
class DsModuleTable<T> extends StatefulWidget {
  const DsModuleTable({
    super.key,
    required this.entite,
    required this.lignes,
    required this.colonnes,
    required this.cle,
    this.kpis,
    this.filtres,
    this.nbFiltresActifs = 0,
    this.onReinitialiser,
    this.colonnesFiltres = 3,
    this.filtresOuverts = false,
    this.periodeSeule = false,
    this.periode,
    this.onPeriode,
    this.indiceRecherche,
    this.texteRecherche,
    this.actions = const [],
    this.primaire,
    this.secondaire,
    this.afficherTotaux = false,
    this.onExport,
    this.carte,
    this.vueParDefaut = DsVueModule.liste,
    this.largeurMinCarte = 220,
    this.onOuvrir,
    this.actionsContextuelles = const [],
    this.permissions = const {},
    this.messageVide,
    this.cleTable,
    this.apresFiltres,
  });

  /// Nom pluriel des éléments (« produits »), affiché avec le compteur des totaux.
  final String entite;
  final List<T> lignes;
  final List<DsColonne<T>> colonnes;
  final Object Function(T) cle;
  final List<Widget>? kpis;
  final List<Widget>? filtres;
  final int nbFiltresActifs;
  final VoidCallback? onReinitialiser;
  final int colonnesFiltres;
  final bool filtresOuverts;

  /// Période seule sur la 1ʳᵉ ligne du panneau de filtres, les autres filtres à partir de la 2ᵉ.
  final bool periodeSeule;

  /// Période du filtre (absente : pas de filtre de période).
  final DsPeriode? periode;
  final ValueChanged<DsPeriode>? onPeriode;
  final String? indiceRecherche;

  /// Texte indexé pour la recherche (par défaut : valeurs des colonnes).
  final String Function(T)? texteRecherche;
  final List<DsActionModule<T>> actions;
  final Widget? primaire;
  final Widget? secondaire;
  final bool afficherTotaux;

  /// Export Excel / PDF des lignes (filtrées, ou cochées) avec les colonnes autorisées.
  final void Function(DsFormatExport format, List<T> lignes)? onExport;
  final Widget Function(BuildContext context, T ligne, DsEtatCarte etat)? carte;
  final DsVueModule vueParDefaut;
  final double largeurMinCarte;

  /// Double-clic / détail (à défaut, l'action [DsActionModule.detail]).
  final void Function(T)? onOuvrir;
  final List<DsActionContextuelle<T>> actionsContextuelles;
  final Set<String> permissions;
  final String? messageVide;
  final Key? cleTable;

  /// Bloc inséré entre le panneau de filtres et la barre de sélection (graphique d'une analyse…).
  final Widget? apresFiltres;

  @override
  State<DsModuleTable<T>> createState() => _DsModuleTableState<T>();
}

class _DsModuleTableState<T> extends State<DsModuleTable<T>> {
  Set<Object> _selection = {};
  String _recherche = '';
  final _controleur = TextEditingController();
  bool _rechercheInitialeLue = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rechercheInitialeLue) return;
    _rechercheInitialeLue = true;
    final texte = context.getInheritedWidgetOfExactType<DsRechercheInitiale>()?.texte;
    if (texte != null && texte.isNotEmpty) {
      _controleur.text = texte;
      _recherche = texte;
    }
  }

  late DsVueModule _vue = widget.carte != null ? widget.vueParDefaut : DsVueModule.liste;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DsModuleTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Les lignes disparues (supprimées, filtrées) quittent la sélection.
    final cles = widget.lignes.map(widget.cle).toSet();
    if (_selection.any((k) => !cles.contains(k))) _selection = _selection.where(cles.contains).toSet();
  }

  String _texte(T ligne) {
    if (widget.texteRecherche != null) return widget.texteRecherche!(ligne);
    return widget.colonnes.map((c) => c.valeur(ligne)?.toString() ?? '').join(' ');
  }

  void _effacer() => setState(() => _selection = {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _recherche.trim().toLowerCase();
    final donnees = q.isEmpty
        ? widget.lignes
        : widget.lignes.where((l) => _texte(l).toLowerCase().contains(q)).toList();
    final choisis = widget.lignes.where((l) => _selection.contains(widget.cle(l))).toList();
    final lectureSeule = DsLectureSeule.de(context);
    // Ordre de la barre : autres actions, Détail, Supprimer / Annuler, Modifier (chacun dans l'ordre du
    // module), puis Nouveau.
    final source = lectureSeule ? widget.actions.where((a) => a.detail) : widget.actions;
    final actions = [for (final g in DsGenreAction.values) ...source.where((a) => a.place == g)];
    final detail = widget.actions.where((a) => a.detail).firstOrNull;
    void Function(T)? ouvrir = widget.onOuvrir;
    if (ouvrir == null && detail != null) {
      ouvrir = (l) {
        setState(() => _selection = {widget.cle(l)});
        detail.onPressed([l], _effacer);
      };
    }
    // Sans détail propre au module : le double-clic affiche toutes les colonnes de la ligne (masquées comprises).
    ouvrir ??= (l) => afficherDetailLigne<T>(
      context,
      entite: widget.entite,
      colonnes: [
        for (final c in widget.colonnes)
          if (c.permission == null || widget.permissions.contains(c.permission)) c,
      ],
      ligne: l,
    );

    final export = widget.onExport == null || lectureSeule
        ? null
        : DsExportMenu(
            nbSelection: _selection.length,
            total: donnees.length,
            onExport: (f, portee) => widget.onExport!(f, portee == DsPorteeExport.selection ? choisis : donnees),
          );

    final autres = <Widget>[
      if (widget.filtres == null && widget.periode == null && export != null) export,
      if (widget.carte != null)
        DsSegmentedControl<DsVueModule>(
          key: const ValueKey('module_vue'),
          valeur: _vue,
          onChanged: (v) => setState(() => _vue = v),
          options: [
            DsOption(DsVueModule.grille, icone: LucideIcons.layoutGrid, tooltip: l10n.dsAffichageGrille),
            DsOption(DsVueModule.liste, icone: LucideIcons.list, tooltip: l10n.dsAffichageListe),
          ],
        ),
      if (!lectureSeule) ?widget.secondaire,
    ];

    final enfants = <Widget>[
      if (widget.kpis != null && widget.kpis!.isNotEmpty) DsChiffresRepliables(cle: widget.entite, kpis: widget.kpis!),
      if (widget.filtres != null || widget.periode != null)
        DsFilterPanel(
          ouvertParDefaut: widget.filtresOuverts,
          nbActifs: widget.nbFiltresActifs,
          onReinitialiser: widget.onReinitialiser,
          onAppliquer: () {},
          colonnes: widget.colonnesFiltres,
          trailing: export,
          children: [
            // Du, Au et Période rapide occupent chacun une cellule : alignés sur les autres filtres.
            if (widget.periode != null) ...DsPeriodeLocalisee.champs(context, widget.periode!, widget.onPeriode!),
            if (widget.periode != null && widget.periodeSeule) const DsFinLigne(),
            ...?widget.filtres,
          ],
        ),
      ?widget.apresFiltres,
      DsSelectionBar(
        nb: _selection.length,
        total: donnees.length,
        onEffacer: _effacer,
        leading: DsSearchField(
          controller: _controleur,
          largeur: 280,
          kbd: '',
          indice: widget.indiceRecherche ?? l10n.dsRechercherIndice,
          onChanged: (v) => setState(() => _recherche = v),
        ),
        actions: [
          for (final a in actions)
            DsActionSelection(
              libelle: a.libelle,
              icone: a.icone,
              regle: a.regle,
              danger: a.danger,
              variante: a.place == DsGenreAction.principale ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
              cle: a.cle,
              iconeSeule: a.reduiteAIcone,
              desactive: a.desactive?.call(choisis) ?? false,
              onPressed: () => a.onPressed(choisis, _effacer),
            ),
        ],
        // Autres actions (export, vue, bouton secondaire) avant Détail / Supprimer / Modifier ; Nouveau en dernier.
        avant: autres.isEmpty ? null : Row(mainAxisSize: MainAxisSize.min, spacing: DsSpacing.s2, children: autres),
        trailing: lectureSeule ? null : widget.primaire,
      ),
      if (donnees.isEmpty && widget.lignes.isNotEmpty)
        DsCard(
          child: DsVide(
            icone: LucideIcons.searchX,
            message: l10n.dsAucunResultat,
            description: l10n.dsModifiezRecherche,
            action: DsButton(
              libelle: l10n.dsReinitialiser,
              icone: LucideIcons.rotateCcw,
              variante: DsButtonVariante.secondaire,
              onPressed: () {
                _controleur.clear();
                setState(() => _recherche = '');
                widget.onReinitialiser?.call();
              },
            ),
          ),
        )
      else if (_vue == DsVueModule.grille && widget.carte != null && donnees.isNotEmpty)
        LayoutBuilder(
          builder: (context, c) {
            final n = ((c.maxWidth + DsSpacing.s4) / (widget.largeurMinCarte + DsSpacing.s4)).floor().clamp(1, 12);
            final largeur = (c.maxWidth - DsSpacing.s4 * (n - 1)) / n;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s3,
              children: [
                Wrap(
                  spacing: DsSpacing.s4,
                  runSpacing: DsSpacing.s4,
                  children: [
                    for (final l in donnees)
                      SizedBox(
                        width: largeur,
                        child: Builder(
                          builder: (context) {
                            final k = widget.cle(l);
                            final on = _selection.contains(k);
                            return widget.carte!(
                              context,
                              l,
                              DsEtatCarte(
                                selectionnee: on,
                                basculer: () =>
                                    setState(() => _selection = on ? ({..._selection}..remove(k)) : {..._selection, k}),
                                ouvrir: ouvrir == null ? null : () => ouvrir!(l),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                Text(
                  '${donnees.length} ${widget.entite}',
                  style: context.ds.typo.label.copyWith(color: context.ds.colors.textSecondary),
                ),
              ],
            );
          },
        )
      else
        DsDataTable<T>(
          key: widget.cleTable,
          colonnes: widget.colonnes,
          lignes: donnees,
          cle: widget.cle,
          selection: _selection,
          onSelectionChanged: (s) => setState(() => _selection = s),
          onDoubleClic: ouvrir,
          actionsContextuelles: lectureSeule ? const [] : widget.actionsContextuelles,
          afficherTotaux: widget.afficherTotaux,
          permissions: widget.permissions,
          messageVide: widget.messageVide,
        ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: DsTailles.gridGap, children: enfants);
  }
}

/// Cartes de chiffres d'un module, repliables : fermées par défaut, l'en-tête « Chiffres clés » les ouvre.
/// Le choix est gardé par module ([cle]) le temps de la session.
class DsChiffresRepliables extends StatefulWidget {
  const DsChiffresRepliables({super.key, required this.cle, required this.kpis});

  final String cle;
  final List<Widget> kpis;

  /// Modules dont les chiffres sont ouverts (tests : à vider entre deux tests si besoin).
  static final Set<String> ouverts = {};

  @override
  State<DsChiffresRepliables> createState() => _DsChiffresRepliablesState();
}

class _DsChiffresRepliablesState extends State<DsChiffresRepliables> {
  bool get _ouvert => DsChiffresRepliables.ouverts.contains(widget.cle);

  void _basculer() => setState(
    () => _ouvert ? DsChiffresRepliables.ouverts.remove(widget.cle) : DsChiffresRepliables.ouverts.add(widget.cle),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final o = _ouvert;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              key: const ValueKey('module_chiffres'),
              behavior: HitTestBehavior.opaque,
              onTap: _basculer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DsSpacing.s1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: DsSpacing.s2,
                  children: [
                    Icon(LucideIcons.chartColumn, size: DsTailles.iconeSm, color: o ? c.iconActive : c.iconMuted),
                    Text(l10n.dsChiffresCles, style: t.label.copyWith(color: c.textSecondary)),
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
          ),
        ),
        AnimatedSize(
          duration: DsMotion.slow,
          curve: DsMotion.emphasized,
          alignment: Alignment.topCenter,
          child: o
              ? Padding(
                  padding: const EdgeInsets.only(top: DsSpacing.s2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DsSpacing.s4,
                    children: [for (final k in widget.kpis) Expanded(child: k)],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Carte de grille sélectionnable (`GridCard`) : clic = sélection, double-clic = détail.
class DsGridCard extends StatefulWidget {
  const DsGridCard({super.key, required this.etat, required this.child});
  final DsEtatCarte etat;
  final Widget child;

  @override
  State<DsGridCard> createState() => _DsGridCardState();
}

class _DsGridCardState extends State<DsGridCard> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final on = widget.etat.selectionnee;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.etat.basculer,
        onDoubleTap: widget.etat.ouvrir,
        child: AnimatedContainer(
          duration: DsMotion.fast,
          decoration: BoxDecoration(
            color: on ? c.primaryTint : c.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on || _survol ? c.borderFocus : c.borderDefault),
            boxShadow: on ? [BoxShadow(color: c.ringFocus, spreadRadius: 3)] : (_survol ? c.shadowSm : c.shadowXs),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              widget.child,
              PositionedDirectional(
                top: 10,
                start: 10,
                child: AnimatedOpacity(
                  duration: DsMotion.fast,
                  opacity: on || _survol ? 1 : 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: on ? c.primary : c.surfaceCard,
                      borderRadius: BorderRadius.circular(6),
                      border: on ? null : Border.all(color: c.borderStrong, width: 1.5),
                    ),
                    child: on ? Icon(LucideIcons.check, size: 14, color: c.primaryFg) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section d'un [DsEntityDetailDialog] : grille clé / valeur, tableau dense ou contenu libre.
class DsSectionDetail {
  const DsSectionDetail({
    required this.titre,
    this.icone,
    this.items,
    this.colonnesGrille = 3,
    this.tableau,
    this.nbLignes,
    this.contenu,
    this.repliable = false,
    this.flex,
  });
  final String titre;
  final IconData? icone;
  final List<DsKeyValue>? items;
  final int colonnesGrille;

  /// Tableau dense (déjà construit, ex. `DsDataTable(dense: true, encadre: false)`).
  final Widget? tableau;
  final int? nbLignes;
  final Widget? contenu;
  final bool repliable;

  /// Sections consécutives avec un [flex] : côte à côte sur une rangée, dans ces proportions.
  final int? flex;
}

/// Dialog de détail générique (`EntityDetailDialog`) : badges → StatsStrip → sections.
class DsEntityDetailDialog extends StatelessWidget {
  const DsEntityDetailDialog({
    super.key,
    required this.titre,
    this.icone,
    this.description,
    this.badges,
    this.stats,
    this.sections = const [],
    this.largeur = 1100,
    this.onModifier,
    this.modifierDesactive = false,
    this.piedSupplementaire = const [],
  });
  final String titre;
  final IconData? icone;
  final String? description;
  final List<Widget>? badges;
  final List<DsStatItem>? stats;
  final List<DsSectionDetail> sections;
  final double largeur;
  final VoidCallback? onModifier;
  final bool modifierDesactive;
  final List<Widget> piedSupplementaire;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Lecture seule : on consulte, sans modifier, imprimer ni exporter.
    final lectureSeule = DsLectureSeule.de(context);
    return DsDialog(
      titre: titre,
      iconeData: icone,
      message: description,
      largeur: largeur,
      actions: [
        if (!lectureSeule) ...piedSupplementaire,
        if (onModifier != null && !lectureSeule)
          DsButton(
            key: const ValueKey('detail_modifier'),
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            iconeSeule: true,
            variante: DsButtonVariante.secondaire,
            onPressed: modifierDesactive
                ? null
                : () {
                    Navigator.of(context).pop();
                    onModifier!();
                  },
          ),
        DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(context).pop()),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          if (badges != null && badges!.isNotEmpty)
            Wrap(spacing: DsSpacing.s2, runSpacing: DsSpacing.s2, children: badges!),
          if (stats != null && stats!.isNotEmpty) DsStatsStrip(items: stats!),
          for (final rangee in _rangees())
            if (rangee.first.flex == null)
              _section(rangee.single)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [for (final s in rangee) Expanded(flex: s.flex!, child: _section(s))],
              ),
        ],
      ),
    );
  }

  /// Regroupe les sections consécutives qui ont un `flex` (une rangée), les autres restent seules.
  List<List<DsSectionDetail>> _rangees() {
    final rangees = <List<DsSectionDetail>>[];
    for (final s in sections) {
      if (s.flex != null && rangees.isNotEmpty && rangees.last.last.flex != null) {
        rangees.last.add(s);
      } else {
        rangees.add([s]);
      }
    }
    return rangees;
  }

  Widget _section(DsSectionDetail s) => DsDetailSection(
    titre: s.titre,
    icone: s.icone,
    compte: s.nbLignes,
    padding: s.tableau != null ? EdgeInsets.zero : const EdgeInsets.all(DsSpacing.s4),
    repliable: s.repliable,
    ouverteParDefaut: !s.repliable,
    child:
        s.tableau ??
        (s.items != null ? DsKeyValueGrid(items: s.items!, colonnes: s.colonnesGrille) : s.contenu ?? const SizedBox()),
  );
}

/// Ouvre un [DsEntityDetailDialog].
Future<void> afficherDetailEntite(BuildContext context, DsEntityDetailDialog dialog) =>
    afficherDialog<void>(context, builder: (_) => dialog);

/// Intertitre de formulaire (`SubHead`) : capitales 11 px atténuées.
class DsSubHead extends StatelessWidget {
  const DsSubHead(this.texte, {super.key, this.icone});
  final String texte;

  /// Icône de section (pastille teintée devant le titre).
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final c = context.ds.colors;
    // Titre de section coloré, suivi d'un filet : les blocs d'un formulaire se repèrent d'un coup d'œil.
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          if (icone != null)
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.primaryTint, borderRadius: BorderRadius.circular(6)),
              child: Icon(icone, size: 14, color: c.primaryTintFg),
            ),
          Text(
            texte.toUpperCase(),
            style: t.caption.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .66,
              color: c.primary,
            ),
          ),
          Expanded(child: Container(height: 1, color: c.borderSubtle)),
        ],
      ),
    );
  }
}

/// Grille de formulaire à colonnes (`gridTemplateColumns: repeat(n, 1fr)`) : les enfants
/// [DsSpan] occupent plusieurs colonnes.
class DsGrilleFormulaire extends StatelessWidget {
  const DsGrilleFormulaire({
    super.key,
    required this.children,
    this.colonnes = 2,
    this.espaceX = 28,
    this.espaceY = 12,
  });
  final List<Widget> children;
  final int colonnes;
  final double espaceX;
  final double espaceY;

  @override
  Widget build(BuildContext context) {
    final rangees = <List<Widget>>[];
    var courante = <Widget>[];
    var occupe = 0;
    for (final e in children) {
      final span = (e is DsSpan ? e.span : 1).clamp(1, colonnes);
      if (occupe + span > colonnes) {
        rangees.add(courante);
        courante = [];
        occupe = 0;
      }
      courante.add(Expanded(flex: span, child: e is DsSpan ? e.child : e));
      occupe += span;
    }
    if (courante.isNotEmpty) {
      if (occupe < colonnes) courante.add(Spacer(flex: colonnes - occupe));
      rangees.add(courante);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: espaceY,
      children: [
        for (final r in rangees) Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: espaceX, children: r),
      ],
    );
  }
}

/// Élément d'une [DsGrilleFormulaire] occupant [span] colonnes (`gridColumn: '1 / -1'` = toutes).
class DsSpan extends StatelessWidget {
  const DsSpan({super.key, required this.child, this.span = 99});
  final Widget child;
  final int span;

  @override
  Widget build(BuildContext context) => child;
}

/// Fin de ligne dans un [DsFilterPanel] : les cellules suivantes commencent sur une nouvelle ligne.
class DsFinLigne extends StatelessWidget {
  const DsFinLigne({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Détail générique d'une ligne de tableau : chaque colonne (masquées comprises) en libellé / valeur, sur deux
/// colonnes ; titre = valeur de la première colonne.
Future<void> afficherDetailLigne<T>(
  BuildContext context, {
  required String entite,
  required List<DsColonne<T>> colonnes,
  required T ligne,
}) {
  final l10n = AppLocalizations.of(context);
  Widget valeur(BuildContext context, DsColonne<T> c) {
    if (c.cellule != null) return c.cellule!(context, ligne);
    final v = c.valeur(ligne)?.toString() ?? '';
    return Text(v.isEmpty ? '—' : v, style: context.ds.typo.bodySm.copyWith(color: context.ds.colors.textPrimary));
  }

  final premiere = colonnes.isEmpty ? null : colonnes.first.valeur(ligne)?.toString();
  return afficherDialog<void>(
    context,
    builder: (ctx) => DsDialog(
      key: const ValueKey('detail_ligne'),
      titre: premiere == null || premiere.isEmpty ? entite : premiere,
      iconeData: LucideIcons.fileText,
      largeur: 720,
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
      contenu: LayoutBuilder(
        builder: (context, c) {
          final largeur = (c.maxWidth - DsSpacing.s5) / 2;
          return Wrap(
            spacing: DsSpacing.s5,
            runSpacing: DsSpacing.s3,
            children: [
              for (final col in colonnes)
                SizedBox(
                  width: largeur,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(col.libelle, style: context.ds.typo.caption.copyWith(color: context.ds.colors.textMuted)),
                      Align(alignment: AlignmentDirectional.centerStart, child: valeur(context, col)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
