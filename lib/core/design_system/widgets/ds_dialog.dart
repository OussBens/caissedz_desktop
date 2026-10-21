import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_forms.dart';
import 'ds_module_kit.dart';
import 'ds_page.dart';
import 'ds_primitives.dart';

/// Tons de l'icأ´ne d'en-tأھte d'un [DsDialog].
enum DsDialogTon { defaut, danger, avertissement, succes, info, neutre }

/// Conteneur de dialogue (`Dialog`) : 520 px, rayon 16, surface أ©levأ©e, en-tأھte icأ´ne 40 px tonale,
/// titre 600 18, corps dأ©filant, boutons du pied centrأ©s. Sans sous-titre : seuls la confirmation et le rأ©sultat
/// affichent leur [message] sous le titre.
class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    required this.titre,
    required this.contenu,
    this.actions = const [],
    this.largeur = 520,
    this.icone,
    this.iconeData,
    this.ton = DsDialogTon.defaut,
    this.message,
    this.fermable = true,
    this.piedDebut,
  });

  final String titre;
  final Widget contenu;
  final List<Widget> actions;
  final double largeur;

  /// Icأ´ne d'en-tأھte (compat) : si c'est un [Icon], son glyphe est repris dans la boأ®te tonale.
  final Widget? icone;
  final IconData? iconeData;
  final DsDialogTon ton;

  /// Message de la confirmation ou du rأ©sultat (le seul texte sous le titre).
  final String? message;
  final bool fermable;

  /// Widget placأ© au dأ©but du pied (compteur de sأ©lection, bouton آ« Nouveau آ»â€¦).
  final Widget? piedDebut;

  static (Color, Color) couleursTon(DsColors c, DsDialogTon ton) => switch (ton) {
    DsDialogTon.defaut => (c.primaryTint, c.primaryTintFg),
    DsDialogTon.danger => (c.dangerTint, c.dangerFg),
    DsDialogTon.avertissement => (c.warningTint, c.warningFg),
    DsDialogTon.succes => (c.successTint, c.successFg),
    DsDialogTon.info => (c.infoTint, c.infoFg),
    DsDialogTon.neutre => (c.surfaceSunken, c.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final (fondIcone, couleurIcone) = couleursTon(c, ton);
    final glyphe = iconeData ?? (icone is Icon ? (icone! as Icon).icon : null);
    final boiteIcone = glyphe != null
        ? Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: fondIcone, borderRadius: BorderRadius.circular(10)),
            child: Icon(glyphe, size: 20, color: couleurIcone),
          )
        : icone;
    return Dialog(
      backgroundColor: c.surfaceRaised,
      insetPadding: const EdgeInsets.all(DsSpacing.s6),
      shape: RoundedRectangleBorder(
        borderRadius: DsRadius.borderXl,
        side: BorderSide(color: c.borderDefault),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largeur),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DsSpacing.s5, DsSpacing.s5, DsSpacing.s5, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  ?boiteIcone,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: boiteIcone != null ? 2 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(titre, style: t.heading.copyWith(fontSize: 18, height: 1.3, letterSpacing: -.18)),
                          if (message != null) Text(message!, style: t.body.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  if (fermable)
                    Transform.translate(
                      offset: const Offset(6, -4),
                      child: DsBoutonFermer(
                        tooltip: l10n.communFermer,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(DsSpacing.s5, DsSpacing.s5, DsSpacing.s5, 0),
                child: contenu,
              ),
            ),
            if (actions.isNotEmpty || piedDebut != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(DsSpacing.s5, DsSpacing.s6, DsSpacing.s5, DsSpacing.s5),
                // Boutons centrأ©s ; le contenu de dأ©but de pied (compteur, آ« Nouveau آ»â€¦) reste au dأ©but.
                child: piedDebut == null
                    ? SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: DsSpacing.s2,
                          runSpacing: DsSpacing.s2,
                          children: actions,
                        ),
                      )
                    // Deux zones أ©gales de part et d'autre : les boutons restent au centre exact du pied.
                    : LayoutBuilder(
                        builder: (context, contraintes) => Row(
                          spacing: DsSpacing.s2,
                          children: [
                            Expanded(
                              child: Align(alignment: AlignmentDirectional.centerStart, child: piedDebut),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: contraintes.maxWidth * .6),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: DsSpacing.s2,
                                runSpacing: DsSpacing.s2,
                                children: actions,
                              ),
                            ),
                            const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
              )
            else
              const SizedBox(height: DsSpacing.s5),
          ],
        ),
      ),
    );
  }
}

/// Ouvre un dialog DS avec le voile et le flou du design (`surface-overlay`).
Future<R?> afficherDialog<R>(BuildContext context, {required WidgetBuilder builder, bool fermableParVoile = true}) {
  final c = context.ds.colors;
  return showDialog<R>(
    context: context,
    barrierColor: c.surfaceOverlay,
    barrierDismissible: fermableParVoile,
    builder: builder,
  );
}

/// Genres du dialog de confirmation (`ConfirmDialog.kind`).
enum DsConfirmGenre { confirmer, danger, avertissement, refuser }

/// Dialogue de confirmation. Retourne `true` si confirmأ©.
///
/// [genre] : `confirmer` (?), `danger` (corbeille, bouton rouge آ« Supprimer آ»),
/// `avertissement` (triangle, آ« Continuer آ»), `refuser` (interdit, un seul bouton آ« Compris آ»).
Future<bool> afficherConfirmation(
  BuildContext context, {
  required String titre,
  required String message,
  String? libelleConfirmer,
  String? libelleAnnuler,
  bool destructif = false,
  DsConfirmGenre? genre,
  IconData? icone,
  Widget? contenu,
}) async {
  final l10n = AppLocalizations.of(context);
  final g = genre ?? (destructif ? DsConfirmGenre.danger : DsConfirmGenre.confirmer);
  final (ton, iconeDefaut, variante, libelleDefaut) = switch (g) {
    DsConfirmGenre.confirmer => (
      DsDialogTon.defaut,
      LucideIcons.circleHelp,
      DsButtonVariante.primaire,
      l10n.communConfirmer,
    ),
    // Via `destructif` (compat) l'action reste آ« Confirmer آ» ; via `genre: danger` explicite : آ« Supprimer آ».
    DsConfirmGenre.danger => (
      DsDialogTon.danger,
      genre == null ? LucideIcons.triangleAlert : LucideIcons.trash2,
      DsButtonVariante.danger,
      genre == null ? l10n.communConfirmer : l10n.communSupprimer,
    ),
    DsConfirmGenre.avertissement => (
      DsDialogTon.avertissement,
      LucideIcons.triangleAlert,
      DsButtonVariante.primaire,
      l10n.dsContinuer,
    ),
    DsConfirmGenre.refuser => (DsDialogTon.neutre, LucideIcons.ban, null, l10n.dsCompris),
  };
  final resultat = await afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: titre,
      message: message,
      iconeData: icone ?? iconeDefaut,
      ton: ton,
      largeur: 460,
      contenu: contenu ?? const SizedBox.shrink(),
      actions: [
        if (variante == null)
          DsButton(
            libelle: libelleConfirmer ?? libelleDefaut,
            variante: DsButtonVariante.secondaire,
            autofocus: true,
            onPressed: () => Navigator.of(ctx).pop(false),
          )
        else ...[
          DsButton(
            libelle: libelleAnnuler ?? l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: libelleConfirmer ?? libelleDefaut,
            variante: variante,
            autofocus: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ],
    ),
  );
  return resultat ?? false;
}

enum DsResultatType { succes, erreur, info, avertissement }

/// Dialogue de rأ©sultat (`ResultDialog`) : succأ¨s / erreur / information.
Future<void> afficherResultat(
  BuildContext context, {
  required DsResultatType type,
  required String titre,
  required String message,
  String? libelleAction,
  Widget? action,
  Widget? contenu,
}) async {
  final l10n = AppLocalizations.of(context);
  final (icone, ton) = switch (type) {
    DsResultatType.succes => (LucideIcons.circleCheck, DsDialogTon.succes),
    DsResultatType.erreur => (LucideIcons.circleX, DsDialogTon.danger),
    DsResultatType.info => (LucideIcons.info, DsDialogTon.info),
    DsResultatType.avertissement => (LucideIcons.triangleAlert, DsDialogTon.avertissement),
  };
  await afficherDialog<void>(
    context,
    builder: (ctx) => DsDialog(
      titre: titre,
      message: message,
      iconeData: icone,
      ton: ton,
      largeur: 440,
      contenu: contenu ?? const SizedBox.shrink(),
      actions: [
        ?action,
        DsButton(
          libelle: libelleAction ?? l10n.communFermer,
          variante: type == DsResultatType.succes && action == null
              ? DsButtonVariante.primaire
              : DsButtonVariante.secondaire,
          autofocus: true,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    ),
  );
}

/// Colonne d'un [afficherSelecteur] / [DsPickerDialog].
class DsColonnePicker<T> {
  const DsColonnePicker({
    required this.libelle,
    required this.valeur,
    this.fort = false,
    this.attenue = false,
    this.largeur,
    this.mono = false,
  });
  final String libelle;
  final String Function(T) valeur;
  final bool fort;
  final bool attenue;
  final bool mono;
  final double? largeur;
}

/// Dialogue de sأ©lection dans une liste filtrable (`PickerDialog`, sأ©lection simple).
/// Retourne l'أ©lأ©ment choisi.
Future<T?> afficherSelecteur<T>(
  BuildContext context, {
  required String titre,
  required List<T> elements,
  required String Function(T) libelle,
  String Function(T)? sousLibelle,
  String? indiceRecherche,
  IconData icone = LucideIcons.list,
  List<DsColonnePicker<T>>? colonnes,
  VoidCallback? onCreer,
  String? libelleCreer,
}) {
  return afficherDialog<T>(
    context,
    builder: (ctx) => DsPickerDialog<T>(
      titre: titre,
      icone: icone,
      elements: elements,
      libelle: libelle,
      sousLibelle: sousLibelle,
      indiceRecherche: indiceRecherche,
      colonnes: colonnes,
      onCreer: onCreer,
      libelleCreer: libelleCreer,
    ),
  );
}

/// Dialog de sأ©lection (`PickerDialog`) : recherche, liste dense, آ« Nouveau آ», validation.
///
/// [multiple] : cases أ  cocher et retour d'une liste ; sinon une ligne cliquأ©e est retournأ©e au
/// double-clic ou via آ« Choisir آ».
class DsPickerDialog<T> extends StatefulWidget {
  const DsPickerDialog({
    super.key,
    required this.titre,
    required this.elements,
    required this.libelle,
    this.icone = LucideIcons.list,
    this.sousLibelle,
    this.indiceRecherche,
    this.colonnes,
    this.multiple = false,
    this.onCreer,
    this.libelleCreer,
    this.libelleConfirmer,
    this.largeur = 880,
    this.hauteurMax = 340,
    this.selectionInitiale = const [],
    this.cle,
    this.hauteurFixe = false,
    this.filtres,
    this.filtre,
    this.carte,
    this.largeurCarte = 220,
    this.hauteurCarte = 150,
    this.vueInitiale = DsVueModule.liste,
  });
  final String titre;
  final IconData icone;
  final List<T> elements;
  final String Function(T) libelle;
  final String Function(T)? sousLibelle;
  final String? indiceRecherche;
  final List<DsColonnePicker<T>>? colonnes;
  final bool multiple;
  final VoidCallback? onCreer;
  final String? libelleCreer;
  final String? libelleConfirmer;
  final double largeur;
  final double hauteurMax;
  final List<T> selectionInitiale;

  /// Clأ© stable d'un أ©lأ©ment (par dأ©faut l'objet lui-mأھme).
  final Object Function(T)? cle;

  /// La liste garde la hauteur [hauteurMax] mأھme avec peu de rأ©sultats (le dialog ne saute pas أ  la saisie).
  final bool hauteurFixe;

  /// Filtres complأ©mentaires affichأ©s sous la recherche ; [filtre] retient les أ©lأ©ments affichأ©s (la sأ©lection
  /// des أ©lأ©ments masquأ©s est conservأ©e).
  final Widget? filtres;
  final bool Function(T)? filtre;

  /// Rendu en carte d'un أ©lأ©ment : active la bascule آ« liste / cartes آ» (produits, clients, fournisseurs, ventes).
  final Widget Function(BuildContext context, T element, DsEtatCarte etat)? carte;
  final double largeurCarte;
  final double hauteurCarte;
  final DsVueModule vueInitiale;

  @override
  State<DsPickerDialog<T>> createState() => _DsPickerDialogState<T>();
}

class _DsPickerDialogState<T> extends State<DsPickerDialog<T>> {
  String _filtre = '';
  late final Set<Object> _selection = {for (final e in widget.selectionInitiale) _cle(e)};
  late DsVueModule _vue = widget.carte == null ? DsVueModule.liste : widget.vueInitiale;

  void _basculer(T e) {
    final cle = _cle(e);
    final actif = _selection.contains(cle);
    setState(() {
      if (widget.multiple) {
        actif ? _selection.remove(cle) : _selection.add(cle);
      } else {
        _selection
          ..clear()
          ..add(cle);
      }
    });
  }

  Object _cle(T e) => widget.cle?.call(e) ?? e as Object;

  List<T> get _filtres {
    final q = _filtre.trim().toLowerCase();
    final base = widget.filtre == null ? widget.elements : widget.elements.where(widget.filtre!).toList();
    if (q.isEmpty) return base;
    return base.where((e) {
      if (widget.libelle(e).toLowerCase().contains(q)) return true;
      if (widget.sousLibelle?.call(e).toLowerCase().contains(q) ?? false) return true;
      return widget.colonnes?.any((c) => c.valeur(e).toLowerCase().contains(q)) ?? false;
    }).toList();
  }

  void _confirmer([List<T>? choix]) {
    final ids = choix?.map(_cle).toSet() ?? _selection;
    final retenus = widget.elements.where((e) => ids.contains(_cle(e))).toList();
    if (widget.multiple) {
      Navigator.of(context).pop(retenus);
    } else {
      Navigator.of(context).pop(retenus.firstOrNull);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final filtres = _filtres;
    final colonnes =
        widget.colonnes ??
        [
          DsColonnePicker<T>(libelle: l10n.dsLibelle, valeur: widget.libelle, fort: true),
          if (widget.sousLibelle != null) DsColonnePicker<T>(libelle: '', valeur: widget.sousLibelle!, attenue: true),
        ];
    final n = _selection.length;
    final indication = n > 0
        ? l10n.communSelectionnes(n)
        : (widget.multiple ? l10n.dsCochezLignes : l10n.dsCliquezLigne);
    return DsDialog(
      titre: widget.titre,
      iconeData: widget.icone,
      largeur: widget.largeur,
      piedDebut: Row(
        spacing: DsSpacing.s2,
        children: [
          if (widget.onCreer != null)
            DsButton(
              libelle: widget.libelleCreer ?? l10n.communNouveau,
              icone: LucideIcons.plus,
              variante: DsButtonVariante.fantome,
              onPressed: widget.onCreer,
            ),
          Flexible(
            child: Text(
              indication,
              style: t.label.copyWith(color: c.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          libelle: widget.libelleConfirmer ?? (widget.multiple ? l10n.dsAjouter : l10n.dsChoisir),
          icone: LucideIcons.check,
          onPressed: n == 0 ? null : () => _confirmer(),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          Row(
            spacing: DsSpacing.s3,
            children: [
              Expanded(
                child: DsSearchField(
                  autofocus: true,
                  kbd: '',
                  indice: widget.indiceRecherche ?? l10n.communRechercher,
                  onChanged: (v) => setState(() => _filtre = v),
                ),
              ),
              if (widget.carte != null)
                DsSegmentedControl<DsVueModule>(
                  key: const ValueKey('picker_vue'),
                  valeur: _vue,
                  onChanged: (v) => setState(() => _vue = v),
                  options: [
                    DsOption(DsVueModule.liste, icone: LucideIcons.list, tooltip: l10n.dsAffichageListe),
                    DsOption(DsVueModule.grille, icone: LucideIcons.layoutGrid, tooltip: l10n.dsAffichageGrille),
                  ],
                ),
            ],
          ),
          ?widget.filtres,
          if (_vue == DsVueModule.grille && widget.carte != null)
            SizedBox(
              height: widget.hauteurMax,
              child: filtres.isEmpty
                  ? DsVide(message: l10n.communAucunResultat, icone: LucideIcons.searchX, petit: true)
                  : GridView.builder(
                      padding: const EdgeInsets.all(4),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: widget.largeurCarte,
                        mainAxisExtent: widget.hauteurCarte,
                        crossAxisSpacing: DsSpacing.s3,
                        mainAxisSpacing: DsSpacing.s3,
                      ),
                      itemCount: filtres.length,
                      itemBuilder: (ctx, i) {
                        final e = filtres[i];
                        return KeyedSubtree(
                          key: ValueKey('picker_carte_$i'),
                          child: widget.carte!(
                            ctx,
                            e,
                            DsEtatCarte(
                              selectionnee: _selection.contains(_cle(e)),
                              basculer: () => _basculer(e),
                              ouvrir: widget.multiple ? null : () => _confirmer([e]),
                            ),
                          ),
                        );
                      },
                    ),
            )
          else
            Container(
              height: widget.hauteurFixe ? widget.hauteurMax : null,
              constraints: BoxConstraints(maxHeight: widget.hauteurMax),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: c.surfaceCard,
                borderRadius: DsRadius.borderLg,
                border: Border.all(color: c.borderDefault),
              ),
              child: filtres.isEmpty
                  ? DsVide(message: l10n.communAucunResultat, icone: LucideIcons.searchX, petit: true)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: DsTailles.enTeteTable,
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4),
                          decoration: BoxDecoration(
                            color: c.surfaceSunken,
                            border: Border(bottom: BorderSide(color: c.borderDefault)),
                          ),
                          child: Row(
                            children: [
                              if (widget.multiple) const SizedBox(width: 32),
                              for (final col in colonnes)
                                col.largeur != null
                                    ? SizedBox(
                                        width: col.largeur,
                                        child: Text(
                                          col.libelle.toUpperCase(),
                                          style: t.overline.copyWith(color: c.textMuted),
                                        ),
                                      )
                                    : Expanded(
                                        child: Text(
                                          col.libelle.toUpperCase(),
                                          style: t.overline.copyWith(color: c.textMuted),
                                        ),
                                      ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtres.length,
                            itemExtent: DsTailles.ligneTableDense,
                            itemBuilder: (ctx, i) {
                              final e = filtres[i];
                              final cle = _cle(e);
                              final actif = _selection.contains(cle);
                              return _LignePicker(
                                actif: actif,
                                onTap: () => setState(() {
                                  if (widget.multiple) {
                                    actif ? _selection.remove(cle) : _selection.add(cle);
                                  } else {
                                    _selection
                                      ..clear()
                                      ..add(cle);
                                  }
                                }),
                                onDoubleTap: widget.multiple ? null : () => _confirmer([e]),
                                child: Row(
                                  children: [
                                    if (widget.multiple)
                                      SizedBox(
                                        width: 32,
                                        child: DsCheckbox(
                                          valeur: actif,
                                          onChanged: (_) =>
                                              setState(() => actif ? _selection.remove(cle) : _selection.add(cle)),
                                        ),
                                      ),
                                    for (final col in colonnes)
                                      Builder(
                                        builder: (context) {
                                          final texte = Text(
                                            col.valeur(e),
                                            style: (col.mono ? t.mono : t.bodySm).copyWith(
                                              fontWeight: col.fort ? FontWeight.w600 : FontWeight.w400,
                                              color: col.fort
                                                  ? c.textPrimary
                                                  : (col.attenue ? c.textMuted : c.textBody),
                                              fontFeatures: DsTypography.tabular,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                          return col.largeur != null
                                              ? SizedBox(width: col.largeur, child: texte)
                                              : Expanded(child: texte);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class _LignePicker extends StatefulWidget {
  const _LignePicker({required this.child, required this.actif, required this.onTap, this.onDoubleTap});
  final Widget child;
  final bool actif;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  @override
  State<_LignePicker> createState() => _LignePickerState();
}

class _LignePickerState extends State<_LignePicker> {
  bool _survol = false;
  DateTime? _dernierTap;

  // Double-clic gأ©rأ© أ  la main : le simple clic sأ©lectionne immأ©diatement (pas de dأ©lai
  // d'attente du second clic), un second clic sous 400 ms valide.
  void _tap() {
    final maintenant = DateTime.now();
    final double_ = _dernierTap != null && maintenant.difference(_dernierTap!) < const Duration(milliseconds: 400);
    _dernierTap = maintenant;
    if (double_ && widget.onDoubleTap != null) {
      widget.onDoubleTap!();
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4),
          decoration: BoxDecoration(
            color: widget.actif ? c.surfaceActive : (_survol ? c.surfaceHover : DsColors.transparent),
            border: Border(bottom: BorderSide(color: c.borderSubtle)),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// أ‰lأ©ment d'un [DsBulkActionDialog].
class DsElementLot {
  const DsElementLot({required this.id, required this.titre, this.sousTitre, this.meta, this.motifBlocage});
  final Object id;
  final String titre;
  final String? sousTitre;
  final String? meta;

  /// Raison pour laquelle l'أ©lأ©ment ne peut pas أھtre traitأ© (ligne verrouillأ©e).
  final String? motifBlocage;
}

/// Actions en lot (`BulkActionDialog.action`).
enum DsActionLot { annuler, supprimer, activer, desactiver }

/// Dialog d'action en lot (`BulkActionDialog`) : liste des أ©lأ©ments, bloquأ©s signalأ©s, motif obligatoire.
/// Retourne le motif saisi (chaأ®ne vide si non requis) ou `null` si fermأ©.
Future<String?> afficherActionLot(
  BuildContext context, {
  required DsActionLot action,
  required List<DsElementLot> elements,
  required String entite,
  String? entitePluriel,
  bool motifRequis = false,
  String? libelleMotif,
  String? titre,
  String? description,
  String? libelleConfirmer,
}) {
  return afficherDialog<String>(
    context,
    builder: (ctx) => _BulkActionDialog(
      action: action,
      elements: elements,
      entite: entite,
      entitePluriel: entitePluriel,
      motifRequis: motifRequis,
      libelleMotif: libelleMotif,
      titre: titre,
      description: description,
      libelleConfirmer: libelleConfirmer,
    ),
  );
}

class _BulkActionDialog extends StatefulWidget {
  const _BulkActionDialog({
    required this.action,
    required this.elements,
    required this.entite,
    this.entitePluriel,
    required this.motifRequis,
    this.libelleMotif,
    this.titre,
    this.description,
    this.libelleConfirmer,
  });
  final DsActionLot action;
  final List<DsElementLot> elements;
  final String entite;
  final String? entitePluriel;
  final bool motifRequis;
  final String? libelleMotif;
  final String? titre;
  final String? description;
  final String? libelleConfirmer;
  @override
  State<_BulkActionDialog> createState() => _BulkActionDialogState();
}

class _BulkActionDialogState extends State<_BulkActionDialog> {
  final _motif = TextEditingController();

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final (icone, ton, variante, verbe, participe) = switch (widget.action) {
      DsActionLot.annuler => (
        LucideIcons.ban,
        DsDialogTon.danger,
        DsButtonVariante.danger,
        l10n.communAnnuler,
        l10n.dsAnnules,
      ),
      DsActionLot.supprimer => (
        LucideIcons.trash2,
        DsDialogTon.danger,
        DsButtonVariante.danger,
        l10n.communSupprimer,
        l10n.dsSupprimes,
      ),
      DsActionLot.activer => (
        LucideIcons.circleCheck,
        DsDialogTon.succes,
        DsButtonVariante.primaire,
        l10n.dsActiver,
        l10n.dsActives,
      ),
      DsActionLot.desactiver => (
        LucideIcons.circlePause,
        DsDialogTon.avertissement,
        DsButtonVariante.primaire,
        l10n.dsDesactiver,
        l10n.dsDesactives,
      ),
    };
    final bloques = widget.elements.where((e) => e.motifBlocage != null).toList();
    final okN = widget.elements.length - bloques.length;
    final pluriel = widget.entitePluriel ?? '${widget.entite}s';
    String nom(int n) => '$n ${n > 1 ? pluriel : widget.entite}';
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _motif,
      builder: (context, motif, _) {
        final peut = okN > 0 && (!widget.motifRequis || motif.text.trim().isNotEmpty);
        return DsDialog(
          titre: widget.titre ?? '$verbe ${nom(widget.elements.length)} ?',
          // Seul un avertissement s'affiche sous le titre : message de l'appelant ou أ©lأ©ments bloquأ©s.
          message:
              widget.description ??
              (bloques.isNotEmpty ? l10n.dsLotPartiel(nom(okN), widget.elements.length, participe) : null),
          iconeData: icone,
          ton: ton,
          largeur: 600,
          actions: [
            DsButton(
              libelle: l10n.communFermer,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(context).pop(),
            ),
            DsButton(
              libelle: widget.libelleConfirmer ?? '$verbe${okN > 0 ? ' ($okN)' : ''}',
              variante: variante,
              onPressed: peut ? () => Navigator.of(context).pop(motif.text.trim()) : null,
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              if (bloques.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: c.dangerTint, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(LucideIcons.circleAlert, size: 18, color: c.dangerFg),
                      ),
                      Expanded(
                        child: Text(
                          l10n.dsLotBloques(nom(bloques.length), bloques.first.motifBlocage!.toLowerCase()),
                          style: t.bodySm.copyWith(fontWeight: FontWeight.w500, height: 1.45, color: c.dangerFg),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                constraints: const BoxConstraints(maxHeight: 232),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.borderDefault),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final (i, it) in widget.elements.indexed)
                      Builder(
                        builder: (context) {
                          final b = it.motifBlocage != null;
                          return Opacity(
                            opacity: b ? .75 : 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: i > 0 ? Border(top: BorderSide(color: c.borderSubtle)) : null,
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Icon(b ? LucideIcons.lock : icone, size: 16, color: b ? c.dangerFg : c.iconMuted),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it.titre,
                                          style: t.bodySm.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (b || it.sousTitre != null)
                                          Text(
                                            b ? it.motifBlocage! : it.sousTitre!,
                                            style: t.caption.copyWith(height: 1.4, color: b ? c.dangerFg : c.textMuted),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (it.meta != null)
                                    Text(
                                      it.meta!,
                                      style: t.label.copyWith(
                                        color: c.textSecondary,
                                        fontFeatures: DsTypography.tabular,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              if (widget.motifRequis)
                DsTextField(
                  controller: _motif,
                  libelle: widget.libelleMotif ?? l10n.dsMotifAnnulation,
                  obligatoire: true,
                  multiligne: true,
                  lignes: 2,
                  indice: l10n.dsMotifIndice,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Colonne configurable d'un [afficherReglageColonnes].
class DsColonneReglage {
  const DsColonneReglage({
    required this.id,
    required this.libelle,
    this.verrouillee = false,
    this.visible = true,
    this.parDefaut = true,
  });
  final String id;
  final String libelle;
  final bool verrouillee;
  final bool visible;
  final bool parDefaut;

  DsColonneReglage copyWith({bool? visible}) => DsColonneReglage(
    id: id,
    libelle: libelle,
    verrouillee: verrouillee,
    visible: visible ?? this.visible,
    parDefaut: parDefaut,
  );
}

/// Rأ©sultat du dialog آ« colonnes آ» : identifiants masquأ©s + mأ©morisation.
typedef DsReglageColonnes = ({Set<String> masquees, bool conserver});

/// Dialog آ« Afficher / masquer les colonnes آ» (`ColumnSettings`) : obligatoires verrouillأ©es,
/// par dأ©faut, autres ; recherche au-delأ  de 10 colonnes ; آ« Garder ma sأ©lection آ».
Future<DsReglageColonnes?> afficherReglageColonnes(
  BuildContext context, {
  required List<DsColonneReglage> colonnes,
  bool conserver = true,
}) {
  return afficherDialog<DsReglageColonnes>(
    context,
    builder: (ctx) => _ReglageColonnesDialog(colonnes: colonnes, conserver: conserver),
  );
}

class _ReglageColonnesDialog extends StatefulWidget {
  const _ReglageColonnesDialog({required this.colonnes, required this.conserver});
  final List<DsColonneReglage> colonnes;
  final bool conserver;
  @override
  State<_ReglageColonnesDialog> createState() => _ReglageColonnesDialogState();
}

class _ReglageColonnesDialogState extends State<_ReglageColonnesDialog> {
  late List<DsColonneReglage> _cols = [
    for (final c in widget.colonnes) c.copyWith(visible: c.verrouillee ? true : c.visible),
  ];
  late bool _conserver = widget.conserver;
  String _q = '';

  void _tout(bool v) => setState(() => _cols = [for (final c in _cols) c.verrouillee ? c : c.copyWith(visible: v)]);
  void _defaut() =>
      setState(() => _cols = [for (final c in _cols) c.verrouillee ? c : c.copyWith(visible: c.parDefaut)]);

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final q = _q.trim().toLowerCase();
    bool match(DsColonneReglage x) => q.isEmpty || x.libelle.toLowerCase().contains(q);
    final nombreuses = _cols.length > 10;
    final groupes = [
      (
        l10n.dsObligatoires,
        l10n.dsToujoursAffichees,
        LucideIcons.lock,
        _cols.where((x) => x.verrouillee && match(x)).toList(),
      ),
      (
        l10n.dsColonnesParDefaut,
        null,
        LucideIcons.star,
        _cols.where((x) => !x.verrouillee && x.parDefaut && match(x)).toList(),
      ),
      (
        l10n.dsAutresColonnes,
        null,
        LucideIcons.columns3,
        _cols.where((x) => !x.verrouillee && !x.parDefaut && match(x)).toList(),
      ),
    ].where((g) => g.$4.isNotEmpty).toList();
    return DsDialog(
      titre: l10n.dsColonnesTitre,
      iconeData: LucideIcons.columns3,
      largeur: nombreuses ? 640 : 440,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          libelle: l10n.dsAppliquer,
          icone: LucideIcons.check,
          onPressed: () => Navigator.of(context).pop((
            masquees: {
              for (final x in _cols)
                if (!x.visible) x.id,
            },
            conserver: _conserver,
          )),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (nombreuses)
                DsSearchField(
                  kbd: '',
                  indice: l10n.dsRechercherColonne,
                  largeur: 200,
                  onChanged: (v) => setState(() => _q = v),
                ),
              DsButton(
                libelle: l10n.dsAfficherTout,
                icone: LucideIcons.eye,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.secondaire,
                delaiGarde: Duration.zero,
                onPressed: () => _tout(true),
              ),
              DsButton(
                libelle: l10n.dsMasquerTout,
                icone: LucideIcons.eyeOff,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.secondaire,
                delaiGarde: Duration.zero,
                onPressed: () => _tout(false),
              ),
              DsButton(
                libelle: l10n.dsParDefaut,
                icone: LucideIcons.rotateCcw,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                delaiGarde: Duration.zero,
                onPressed: _defaut,
              ),
            ],
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 360),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.borderDefault),
            ),
            child: groupes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
                    child: Text(
                      l10n.dsAucuneColonne,
                      textAlign: TextAlign.center,
                      style: t.bodySm.copyWith(color: c.textMuted),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 6),
                    children: [
                      for (final (gi, g) in groupes.indexed)
                        Container(
                          decoration: BoxDecoration(
                            border: gi > 0 ? Border(top: BorderSide(color: c.borderSubtle)) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                                child: Row(
                                  spacing: 6,
                                  children: [
                                    Icon(g.$3, size: 12, color: c.textMuted),
                                    Flexible(
                                      child: Text(
                                        g.$1.toUpperCase(),
                                        style: t.overline.copyWith(color: c.textMuted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'آ· ${g.$4.length}',
                                      style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                                    ),
                                    if (g.$2 != null) ...[
                                      const Spacer(),
                                      Flexible(
                                        child: Text(
                                          g.$2!,
                                          style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 2,
                                  children: [
                                    for (final x in g.$4)
                                      SizedBox(
                                        width: nombreuses ? 180 : double.infinity,
                                        height: 34,
                                        child: Row(
                                          spacing: 6,
                                          children: [
                                            Flexible(
                                              child: DsCheckbox(
                                                cle: ValueKey('colonne_${x.id}'),
                                                libelle: x.libelle,
                                                valeur: x.visible,
                                                onChanged: x.verrouillee
                                                    ? null
                                                    : (v) => setState(
                                                        () => _cols = [
                                                          for (final y in _cols)
                                                            y.id == x.id ? y.copyWith(visible: v) : y,
                                                        ],
                                                      ),
                                              ),
                                            ),
                                            if (x.verrouillee) Icon(LucideIcons.lock, size: 12, color: c.iconMuted),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          DsSwitch(
            libelle: l10n.dsGarderSelection,
            aide: l10n.dsGarderSelectionAide,
            valeur: _conserver,
            onChanged: (v) => setState(() => _conserver = v),
          ),
        ],
      ),
    );
  }
}

/// Entrأ©e d'un [afficherMenuContextuel].
class DsMenuItem {
  const DsMenuItem({
    required this.libelle,
    this.icone,
    this.kbd,
    this.danger = false,
    this.desactive = false,
    this.onTap,
  }) : separateur = false;
  const DsMenuItem.separateur()
    : libelle = '',
      icone = null,
      kbd = null,
      danger = false,
      desactive = false,
      onTap = null,
      separateur = true;
  final String libelle;
  final IconData? icone;
  final String? kbd;
  final bool danger;
  final bool desactive;
  final VoidCallback? onTap;
  final bool separateur;
}

/// Menu contextuel (`ContextMenu`) أ  la position donnأ©e : 220 px min, surface أ©levأ©e, items 34 px.
Future<void> afficherMenuContextuel(
  BuildContext context, {
  required Offset position,
  required List<DsMenuItem> items,
  String? titre,
}) async {
  final c = context.ds.colors;
  final t = context.ds.typo;
  final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final choix = await showMenu<int>(
    context: context,
    color: c.surfaceRaised,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: c.borderDefault),
    ),
    constraints: const BoxConstraints(minWidth: 220),
    // [position] est globale ; l'overlay du navigateur imbriquأ© (shell) est dأ©calأ© de la barre latأ©rale.
    position: RelativeRect.fromRect(overlay.globalToLocal(position) & const Size(1, 1), Offset.zero & overlay.size),
    items: [
      if (titre != null)
        PopupMenuItem<int>(
          enabled: false,
          height: 28,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Text(titre.toUpperCase(), style: t.overline.copyWith(color: c.textMuted)),
        ),
      for (final (i, it) in items.indexed)
        if (it.separateur)
          PopupMenuItem<int>(
            enabled: false,
            height: 11,
            padding: EdgeInsets.zero,
            child: Divider(height: 1, thickness: 1, color: c.borderSubtle, indent: 4, endIndent: 4),
          )
        else
          PopupMenuItem<int>(
            value: i,
            enabled: !it.desactive,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Opacity(
              opacity: it.desactive ? .45 : 1,
              child: Row(
                spacing: 10,
                children: [
                  Icon(it.icone ?? LucideIcons.dot, size: 16, color: it.danger ? c.dangerFg : c.iconDefault),
                  Expanded(
                    child: Text(
                      it.libelle,
                      style: t.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: it.danger ? c.dangerFg : c.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (it.kbd != null)
                    Text(
                      it.kbd!,
                      style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: c.textMuted),
                    ),
                ],
              ),
            ),
          ),
    ],
  );
  if (choix != null) items[choix].onTap?.call();
}
