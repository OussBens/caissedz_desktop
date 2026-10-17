import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_forms.dart';

/// Gabarit de page module (`PageHeader` + zone de contenu de l'AppShell).
///
/// En-tête : fil d'Ariane, bouton retour, titre 700 24, description 400 14, actions alignées en bas.
/// Zone : padding 24 / 32 / 32, espacement vertical 16.
class DsPage extends StatelessWidget {
  const DsPage({
    super.key,
    required this.titre,
    required this.child,
    this.actions = const [],
    this.onRecherche,
    this.indiceRecherche,
    this.filtres,
    this.sousTitre,
    this.defilable = false,
    this.filAriane,
    this.onRetour,
    this.barre,
  });

  final String titre;

  /// Description sous le titre.
  final String? sousTitre;
  final Widget child;
  final List<Widget> actions;

  /// Barre de recherche sous l'en-tête (compat lots 0 à 9).
  final ValueChanged<String>? onRecherche;
  final String? indiceRecherche;

  /// Widgets de filtre placés à droite de la recherche.
  final Widget? filtres;

  /// `true` : le contenu est placé dans une liste défilante (formulaires longs).
  final bool defilable;
  final List<String>? filAriane;
  final VoidCallback? onRetour;

  /// Rangée libre entre l'en-tête et le contenu (onglets, barre de sélection…).
  final Widget? barre;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final enTete = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsTailles.gridGap,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: DsSpacing.s2,
          spacing: DsSpacing.s4,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (filAriane != null && filAriane!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        for (final (i, b) in filAriane!.indexed) ...[
                          if (i > 0) Icon(LucideIcons.chevronRight, size: 12, color: c.textMuted),
                          Text(
                            b,
                            style: t.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: i == filAriane!.length - 1 ? c.textSecondary : c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      if (onRetour != null)
                        DsIconButton(
                          icone: LucideIcons.arrowLeft,
                          tooltip: 'Retour',
                          taille: DsTailles.controleSm,
                          contour: true,
                          onPressed: onRetour,
                        ),
                      Text(titre, style: t.pageTitle),
                    ],
                  ),
                  if (sousTitre != null) Text(sousTitre!, style: t.body.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
            if (actions.isNotEmpty) Wrap(spacing: DsSpacing.s2, runSpacing: DsSpacing.s2, children: actions),
          ],
        ),
        if (onRecherche != null || filtres != null)
          Row(
            spacing: DsSpacing.s3,
            children: [
              if (onRecherche != null) DsSearchField(indice: indiceRecherche, onChanged: onRecherche, largeur: 340),
              if (filtres != null) Expanded(child: filtres!),
            ],
          ),
        ?barre,
      ],
    );
    const padding = EdgeInsets.fromLTRB(
      DsTailles.pagePaddingX,
      DsTailles.pagePaddingY,
      DsTailles.pagePaddingX,
      DsTailles.pagePaddingX,
    );
    if (defilable) {
      return ListView(
        padding: padding,
        children: [
          enTete,
          const SizedBox(height: DsTailles.gridGap),
          child,
        ],
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsTailles.gridGap,
        children: [
          enTete,
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Point rouge 8 px (nouvelle activité non consultée) : barre latérale, onglets.
class DsPoint extends StatelessWidget {
  const DsPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: c.danger,
        shape: BoxShape.circle,
        border: Border.all(color: c.surfaceCard, width: 1.5),
      ),
    );
  }
}

/// Onglets (`Tabs`) : hauteur 40, espacement 24, soulignement primaire 2 px, compteur facultatif.
class DsOnglets extends StatelessWidget {
  const DsOnglets({
    super.key,
    required this.onglets,
    required this.courant,
    required this.onChanged,
    this.comptes,
    this.points,
  });
  final List<String> onglets;
  final int courant;
  final ValueChanged<int> onChanged;

  /// Compteur par onglet (`null` pour aucun).
  final List<int?>? comptes;

  /// Point rouge par onglet : nouvelle activité non consultée.
  final List<bool>? points;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderDefault)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: DsSpacing.s6,
          children: [
            for (final (i, o) in onglets.indexed)
              Builder(
                builder: (context) {
                  final actif = i == courant;
                  final compte = comptes != null && i < comptes!.length ? comptes![i] : null;
                  final point = points != null && i < points!.length && points![i];
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: actif ? c.primary : DsColors.transparent, width: 2)),
                        ),
                        child: Row(
                          spacing: 6,
                          children: [
                            Text(
                              o,
                              style: t.body.copyWith(
                                fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
                                color: actif ? c.textPrimary : c.textSecondary,
                              ),
                            ),
                            if (compte != null)
                              AnimatedContainer(
                                duration: DsMotion.fast,
                                constraints: const BoxConstraints(minWidth: 20),
                                height: 18,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: actif ? c.primaryTint : c.surfaceSunken,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '$compte',
                                  style: t.caption.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    color: actif ? c.primaryTintFg : c.textMuted,
                                  ),
                                ),
                              ),
                            if (point) DsPoint(key: ValueKey('point_onglet_$i')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Liste déroulante du DS (`Select`) : déclencheur 36 px, liste flottante 12 px, option cochée.
class DsSelect<T> extends StatefulWidget {
  const DsSelect({
    super.key,
    required this.valeur,
    required this.options,
    required this.libelle,
    required this.onChanged,
    this.titre,
    this.erreur,
    this.actif = true,
    this.icone,
    this.iconeOption,
    this.metaOption,
    this.placeholder,
    this.taille = DsTailles.controleMd,
    this.largeur,
    this.onLookup,
    this.lookupTooltip,
    this.recherche,
    this.cle,
  });
  final T? valeur;
  final List<T> options;
  final String Function(T) libelle;
  final ValueChanged<T?> onChanged;

  /// Libellé au-dessus du champ.
  final String? titre;
  final String? erreur;
  final bool actif;
  final IconData? icone;
  final IconData? Function(T)? iconeOption;
  final String? Function(T)? metaOption;
  final String? placeholder;
  final double taille;
  final double? largeur;
  final VoidCallback? onLookup;
  final String? lookupTooltip;

  /// Recherche dans un dialog (liste métier : filtres, liste ou cartes) parmi les [options] : affiche le bouton
  /// de recherche à côté de la liste ; la valeur retournée (non nulle) est transmise à [onChanged].
  final Future<T?> Function(List<T> options, T? valeur)? recherche;

  /// Clé de test du déclencheur.
  final Key? cle;

  @override
  State<DsSelect<T>> createState() => _DsSelectState<T>();
}

class _DsSelectState<T> extends State<DsSelect<T>> {
  final _cleDeclencheur = GlobalKey();
  bool _ouvert = false;

  /// Ouvre la liste dans une route transparente ancrée sous le déclencheur (fermeture au clic
  /// en dehors, Échap). La liste est ainsi en fin d'arbre, comme un menu Material.
  Future<void> _basculer() async {
    if (!widget.actif || _ouvert) return;
    final boite = _cleDeclencheur.currentContext?.findRenderObject() as RenderBox?;
    if (boite == null) return;
    // Position relative à l'overlay du navigateur qui affiche la liste (navigateur imbriqué du shell, décalé de la
    // barre latérale et de la barre de titre) : sinon la liste s'ouvre loin du champ.
    final navigateur = Navigator.of(context);
    final overlay = navigateur.overlay?.context.findRenderObject() as RenderBox?;
    final origine = boite.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = origine & boite.size;
    setState(() => _ouvert = true);
    final sel = widget.options.contains(widget.valeur) ? widget.valeur : null;
    final choix = await navigateur.push(
      _RoutePopupSelect<T>(
        ancre: rect,
        options: widget.options,
        libelle: widget.libelle,
        iconeOption: widget.iconeOption,
        metaOption: widget.metaOption,
        selection: sel,
      ),
    );
    if (!mounted) return;
    setState(() => _ouvert = false);
    if (choix != null) widget.onChanged(choix.valeur);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final ouvert = _ouvert;
    final sel = widget.options.contains(widget.valeur) ? widget.valeur : null;
    final petit = widget.taille <= DsTailles.controleSm;

    final declencheur = MouseRegion(
      cursor: widget.actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        key: widget.cle,
        behavior: HitTestBehavior.opaque,
        onTap: _basculer,
        child: AnimatedContainer(
          key: _cleDeclencheur,
          duration: DsMotion.fast,
          curve: DsMotion.standard,
          height: widget.taille,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
          decoration: BoxDecoration(
            color: widget.actif ? c.surfaceCard : c.surfaceSunken,
            borderRadius: DsRadius.borderMd,
            border: Border.all(color: widget.erreur != null ? c.danger : (ouvert ? c.borderFocus : c.borderDefault)),
            boxShadow: ouvert ? [BoxShadow(color: c.ringFocus, spreadRadius: 3)] : c.shadowXs,
          ),
          child: Row(
            spacing: DsSpacing.s2,
            children: [
              if (widget.icone != null) Icon(widget.icone, size: DsTailles.iconeSm, color: c.iconMuted),
              Expanded(
                child: Text(
                  sel != null ? widget.libelle(sel as T) : (widget.placeholder ?? 'Sélectionner'),
                  style: (petit ? t.bodySm : t.body).copyWith(
                    fontWeight: FontWeight.w500,
                    color: sel != null ? c.textPrimary : c.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedRotation(
                turns: ouvert ? .5 : 0,
                duration: DsMotion.base,
                curve: DsMotion.standard,
                child: Icon(LucideIcons.chevronDown, size: DsTailles.iconeSm, color: c.iconMuted),
              ),
            ],
          ),
        ),
      ),
    );

    final lookup =
        widget.onLookup ??
        (widget.recherche == null || !widget.actif
            ? null
            : () async {
                final v = await widget.recherche!(widget.options, widget.valeur);
                if (v != null && mounted) widget.onChanged(v);
              });
    final champ = lookup == null
        ? declencheur
        : Row(
            spacing: 6,
            children: [
              Expanded(child: declencheur),
              DsLookupButton(
                key: widget.cle is ValueKey<String>
                    ? ValueKey('${(widget.cle! as ValueKey<String>).value}_recherche')
                    : null,
                onPressed: lookup,
                tooltip: widget.lookupTooltip ?? AppLocalizations.of(context).selRechercherListe,
                taille: widget.taille,
              ),
            ],
          );

    Widget resultat = champ;
    if (widget.titre != null || widget.erreur != null) {
      resultat = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (widget.titre != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _basculer,
              child: Text(widget.titre!, style: t.label.copyWith(height: 1.3, color: c.textBody)),
            ),
          champ,
          if (widget.erreur != null)
            Row(
              spacing: 4,
              children: [
                Icon(LucideIcons.circleAlert, size: 13, color: c.dangerFg),
                Flexible(
                  child: Text(widget.erreur!, style: t.caption.copyWith(color: c.dangerFg)),
                ),
              ],
            ),
        ],
      );
    }
    if (widget.largeur != null) return SizedBox(width: widget.largeur, child: resultat);
    return resultat;
  }
}

/// Résultat d'une [_RoutePopupSelect] (enveloppe pour distinguer « fermé » d'une valeur nulle).
class _ChoixSelect<T> {
  const _ChoixSelect(this.valeur);
  final T valeur;
}

/// Route transparente affichant la liste d'options sous (ou au-dessus de) l'ancre.
class _RoutePopupSelect<T> extends PopupRoute<_ChoixSelect<T>> {
  _RoutePopupSelect({
    required this.ancre,
    required this.options,
    required this.libelle,
    required this.selection,
    this.iconeOption,
    this.metaOption,
  });
  final Rect ancre;
  final List<T> options;
  final String Function(T) libelle;
  final T? selection;
  final IconData? Function(T)? iconeOption;
  final String? Function(T)? metaOption;

  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Fermer';
  @override
  Duration get transitionDuration => DsMotion.base;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return LayoutBuilder(builder: (context, contraintes) => _construire(context, animation, contraintes.biggest));
  }

  Widget _construire(BuildContext context, Animation<double> animation, Size ecran) {
    final c = context.ds.colors;
    const hauteurMax = 280.0;
    final enDessous = ancre.bottom + 6 + hauteurMax <= ecran.height || ancre.top < ecran.height / 2;
    final liste = Material(
      color: DsColors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: hauteurMax),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: DsRadius.borderLg,
          border: Border.all(color: c.borderDefault),
          boxShadow: c.shadowMd,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (final o in options)
              _OptionSelect(
                libelle: libelle(o),
                icone: iconeOption?.call(o),
                meta: metaOption?.call(o),
                actif: o == selection,
                onTap: () => Navigator.of(context).pop(_ChoixSelect<T>(o)),
              ),
          ],
        ),
      ),
    );
    return Stack(
      children: [
        Positioned(
          left: ancre.left.clamp(0, (ecran.width - ancre.width).clamp(0, double.infinity)),
          width: ancre.width,
          top: enDessous ? ancre.bottom + 6 : null,
          bottom: enDessous ? null : ecran.height - ancre.top + 6,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: DsMotion.emphasized),
            child: SlideTransition(
              position: Tween(
                begin: Offset(0, enDessous ? -.03 : .03),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: DsMotion.emphasized)),
              child: liste,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionSelect extends StatefulWidget {
  const _OptionSelect({required this.libelle, required this.actif, required this.onTap, this.icone, this.meta});
  final String libelle;
  final IconData? icone;
  final String? meta;
  final bool actif;
  final VoidCallback onTap;
  @override
  State<_OptionSelect> createState() => _OptionSelectState();
}

class _OptionSelectState extends State<_OptionSelect> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _survol ? c.surfaceHover : DsColors.transparent,
            borderRadius: DsRadius.borderSm,
          ),
          child: Row(
            spacing: DsSpacing.s2,
            children: [
              if (widget.icone != null) Icon(widget.icone, size: DsTailles.iconeSm, color: c.iconDefault),
              Expanded(
                child: Text(
                  widget.libelle,
                  style: t.bodySm.copyWith(
                    fontWeight: widget.actif ? FontWeight.w600 : FontWeight.w400,
                    color: c.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.meta != null)
                Text(
                  widget.meta!,
                  style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                ),
              if (widget.actif) Icon(LucideIcons.check, size: DsTailles.iconeSm, color: c.iconActive),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interrupteur (`Switch`) : piste 36 × 20 (sm 28 × 16), libellé 500 14 à gauche, description.
class DsSwitch extends StatelessWidget {
  const DsSwitch({
    super.key,
    required this.valeur,
    required this.libelle,
    required this.onChanged,
    this.aide,
    this.petit = false,
    this.actif = true,
    this.cle,
  });
  final bool valeur;
  final String libelle;
  final String? aide;
  final ValueChanged<bool> onChanged;
  final bool petit;
  final bool actif;
  final Key? cle;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final w = petit ? 28.0 : 36.0;
    final h = petit ? 16.0 : 20.0;
    final k = h - 4;
    return Semantics(
      toggled: valeur,
      label: libelle,
      child: MouseRegion(
        cursor: actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: actif ? () => onChanged(!valeur) : null,
          child: Opacity(
            opacity: actif ? 1 : .5,
            child: Row(
              crossAxisAlignment: aide != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              spacing: DsSpacing.s3,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        libelle,
                        style: t.body.copyWith(fontWeight: FontWeight.w500, height: 1.3, color: c.textBody),
                      ),
                      if (aide != null) Text(aide!, style: t.caption.copyWith(height: 1.4, color: c.textMuted)),
                    ],
                  ),
                ),
                AnimatedContainer(
                  key: cle,
                  duration: DsMotion.base,
                  curve: DsMotion.standard,
                  width: w,
                  height: h,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: valeur ? c.primary : c.borderStrong,
                    borderRadius: DsRadius.borderPill,
                  ),
                  child: AnimatedAlign(
                    duration: DsMotion.base,
                    curve: DsMotion.emphasized,
                    alignment: valeur ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                    child: Container(
                      width: k,
                      height: k,
                      decoration: BoxDecoration(
                        color: DsColors.blanc,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: DsColors.ink950.withValues(alpha: .3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
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

/// Tons de l'état vide.
enum DsVideTon { neutre, primaire, succes }

/// État vide (`EmptyState`) : icône dans une boîte 52 px, titre 600 15, description, action.
class DsVide extends StatelessWidget {
  const DsVide({
    super.key,
    required this.message,
    this.icone = LucideIcons.inbox,
    this.action,
    this.description,
    this.petit = false,
    this.ton = DsVideTon.neutre,
  });

  /// Titre de l'état vide.
  final String message;
  final String? description;
  final IconData icone;
  final Widget? action;
  final bool petit;
  final DsVideTon ton;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, couleur) = switch (ton) {
      DsVideTon.primaire => (c.primaryTint, c.primaryTintFg),
      DsVideTon.succes => (c.successTint, c.successFg),
      DsVideTon.neutre => (c.surfaceSunken, c.iconDefault),
    };
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: petit ? 16 : 24, vertical: petit ? 24 : 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: petit ? 8 : 10,
          children: [
            Container(
              width: petit ? 40 : 52,
              height: petit ? 40 : 52,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(petit ? 10 : 14)),
              child: Icon(icone, size: petit ? 20 : 24, color: couleur),
            ),
            Text(
              message,
              style: t.cardTitle.copyWith(fontSize: petit ? 14 : 15, height: 1.3),
              textAlign: TextAlign.center,
            ),
            if (description != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  description!,
                  style: t.bodySm.copyWith(color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            if (action != null) Padding(padding: const EdgeInsets.only(top: 6), child: action),
          ],
        ),
      ),
    );
  }
}

/// Formatage monétaire commun (2 décimales, virgule, espaces fines, devise).
String formaterMontant(double v, [String devise = 'DA']) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parties = s.split('.');
  final entier = parties[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
  return '${neg ? '-' : ''}$entier,${parties[1]} $devise';
}

/// Formatage d'un nombre à la française : séparateur de milliers (espace) et virgule décimale.
String formaterNombre(double v, {int decimales = 0, bool grouper = true}) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(decimales);
  final parties = s.split('.');
  final entier = grouper ? parties[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ') : parties[0];
  return '${neg ? '-' : ''}$entier${parties.length > 1 ? ',${parties[1]}' : ''}';
}

/// Abréviation « k » des montants (axes de graphiques) : 12 400 → « 12,4 k ».
String formaterK(double v) {
  if (v.abs() >= 1000) {
    final k = v / 1000;
    return '${formaterNombre(k, decimales: k == k.roundToDouble() ? 0 : 1)} k';
  }
  return formaterNombre(v);
}

/// Lit un nombre saisi (virgule ou point, espaces tolérés) ; `null` si vide ou invalide.
double? lireNombre(String texte) {
  final s = texte.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
  if (s.isEmpty) return null;
  return double.tryParse(s);
}
