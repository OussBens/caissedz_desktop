import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_page.dart';
import 'ds_primitives.dart';

/// Case à cocher du DS (`Checkbox`) : 16 px, rayon 5, coche primaire, libellé 500 14 + description.
class DsCheckbox extends StatelessWidget {
  const DsCheckbox({
    super.key,
    required this.valeur,
    this.onChanged,
    this.libelle,
    this.description,
    this.indetermine = false,
    this.cle,
    this.semantique,
  });
  final bool valeur;
  final ValueChanged<bool>? onChanged;
  final String? libelle;
  final String? description;
  final bool indetermine;

  /// Libellé d'accessibilité quand la case n'a pas de [libelle] visible.
  final String? semantique;

  /// Clé de test posée sur la case elle-même.
  final Key? cle;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final actif = onChanged != null;
    final allume = valeur || indetermine;
    final case_ = AnimatedContainer(
      key: cle,
      duration: DsMotion.fast,
      curve: DsMotion.standard,
      width: 16,
      height: 16,
      margin: EdgeInsets.only(top: description != null ? 2 : 0),
      decoration: BoxDecoration(
        color: allume ? c.primary : c.surfaceCard,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: allume ? c.primary : c.borderStrong),
      ),
      child: allume ? Icon(indetermine ? LucideIcons.minus : LucideIcons.check, size: 12, color: c.primaryFg) : null,
    );
    return Semantics(
      checked: indetermine ? null : valeur,
      mixed: indetermine,
      enabled: actif,
      label: libelle ?? semantique,
      child: MouseRegion(
        cursor: actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: actif ? () => onChanged!(!valeur) : null,
          child: Opacity(
            opacity: actif ? 1 : .5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: description != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              spacing: 10,
              children: [
                case_,
                if (libelle != null || description != null)
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        if (libelle != null)
                          Text(
                            libelle!,
                            style: t.body.copyWith(fontWeight: FontWeight.w500, height: 1.3, color: c.textBody),
                          ),
                        if (description != null)
                          Text(description!, style: t.caption.copyWith(height: 1.4, color: c.textMuted)),
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

/// Champ de recherche (`SearchField`) : loupe, puce raccourci, bouton effacer.
class DsSearchField extends StatefulWidget {
  const DsSearchField({
    super.key,
    this.controller,
    this.valeur,
    this.onChanged,
    this.onSubmitted,
    this.indice,
    this.kbd = 'Ctrl F',
    this.largeur,
    this.grand = false,
    this.autofocus = false,
    this.focusNode,
  });
  final TextEditingController? controller;

  /// Valeur contrôlée (si [controller] est absent).
  final String? valeur;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? indice;

  /// Raccourci affiché quand le champ est vide (`''` pour masquer).
  final String kbd;
  final double? largeur;

  /// Hauteur 44 au lieu de 36.
  final bool grand;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<DsSearchField> createState() => _DsSearchFieldState();
}

class _DsSearchFieldState extends State<DsSearchField> {
  TextEditingController? _interne;
  TextEditingController get _ctrl =>
      widget.controller ?? (_interne ??= TextEditingController(text: widget.valeur ?? ''));

  @override
  void didUpdateWidget(covariant DsSearchField old) {
    super.didUpdateWidget(old);
    if (widget.controller == null && widget.valeur != null && widget.valeur != _ctrl.text) {
      _ctrl.text = widget.valeur!;
    }
  }

  @override
  void dispose() {
    _interne?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _ctrl,
      builder: (context, v, _) => DsTextField(
        controller: _ctrl,
        focusNode: widget.focusNode,
        indice: widget.indice ?? 'Rechercher',
        iconePrefixe: LucideIcons.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        taille: widget.grand ? DsTailles.controleLg : DsTailles.controleMd,
        largeur: widget.largeur,
        suffixe: v.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onChanged?.call('');
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(LucideIcons.x, size: 14, color: c.iconMuted),
                ),
              )
            : (widget.kbd.isEmpty ? null : DsKbd(widget.kbd)),
      ),
    );
  }
}

/// Champ date (`DateField`) : affichage jj/mm/aaaa, icône calendrier, sélecteur Material.
class DsDateField extends StatelessWidget {
  const DsDateField({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.min,
    this.max,
    this.taille = DsTailles.controleMd,
    this.actif = true,
    this.largeur,
    this.indice = 'jj/mm/aaaa',
    this.libelle,
    this.erreur,
  });
  final DateTime? valeur;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? min;
  final DateTime? max;
  final double taille;
  final bool actif;
  final double? largeur;
  final String indice;
  final String? libelle;
  final String? erreur;

  static String formater(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _ouvrir(BuildContext context) async {
    final choix = await showDatePicker(
      context: context,
      initialDate: valeur ?? DateTime.now(),
      firstDate: min ?? DateTime(2000),
      lastDate: max ?? DateTime(2100),
      locale: Localizations.localeOf(context),
    );
    if (choix != null) onChanged(choix);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final boite = MouseRegion(
      cursor: actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: actif ? () => _ouvrir(context) : null,
        child: Opacity(
          opacity: actif ? 1 : .7,
          child: Container(
            height: taille,
            width: largeur,
            padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
            decoration: BoxDecoration(
              color: actif ? c.surfaceCard : c.surfaceSunken,
              borderRadius: DsRadius.borderMd,
              border: Border.all(color: erreur != null ? c.danger : c.borderDefault),
              boxShadow: c.shadowXs,
            ),
            child: Row(
              spacing: DsSpacing.s2,
              children: [
                Expanded(
                  child: Text(
                    valeur == null ? indice : formater(valeur!),
                    style: (taille <= DsTailles.controleSm ? t.bodySm : t.body).copyWith(
                      color: valeur == null ? c.textMuted : c.textPrimary,
                      fontFeatures: DsTypography.tabular,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(LucideIcons.calendar, size: DsTailles.iconeSm, color: c.iconMuted),
              ],
            ),
          ),
        ),
      ),
    );
    if (libelle == null && erreur == null) return boite;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (libelle != null) Text(libelle!, style: t.label.copyWith(height: 1.3, color: c.textBody)),
        boite,
        if (erreur != null)
          Row(
            spacing: 4,
            children: [
              Icon(LucideIcons.circleAlert, size: 13, color: c.dangerFg),
              Flexible(
                child: Text(erreur!, style: t.caption.copyWith(color: c.dangerFg)),
              ),
            ],
          ),
      ],
    );
  }
}

/// Ligne de formulaire (`FormRow`) : libellé à gauche (largeur fixe), champ à droite, aide / erreur.
class DsFormRow extends StatelessWidget {
  const DsFormRow({
    super.key,
    required this.libelle,
    required this.child,
    this.obligatoire = false,
    this.aide,
    this.erreur,
    this.largeurLibelle = 140,
    this.alignerDebut = false,
    this.onLookup,
    this.lookupTooltip = 'Choisir dans la liste',
  });
  final String libelle;
  final Widget child;
  final bool obligatoire;
  final String? aide;
  final String? erreur;
  final double largeurLibelle;

  /// Aligne le libellé en haut (champs multilignes).
  final bool alignerDebut;

  /// Bouton « ≡ » ouvrant une liste de sélection.
  final VoidCallback? onLookup;
  final String lookupTooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Row(
      crossAxisAlignment: alignerDebut ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: largeurLibelle,
          child: Padding(
            padding: EdgeInsets.only(top: alignerDebut ? 9 : 0),
            child: Text.rich(
              TextSpan(
                text: libelle,
                children: [
                  if (obligatoire)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: c.warning, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              style: t.label.copyWith(color: c.textSecondary),
            ),
          ),
        ),
        const SizedBox(width: DsSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Row(
                spacing: 6,
                children: [
                  Expanded(child: child),
                  if (onLookup != null) DsLookupButton(onPressed: onLookup!, tooltip: lookupTooltip),
                ],
              ),
              if (erreur != null || aide != null)
                Row(
                  spacing: 4,
                  children: [
                    if (erreur != null) Icon(LucideIcons.circleAlert, size: 13, color: c.dangerFg),
                    Flexible(
                      child: Text(
                        erreur ?? aide!,
                        style: t.caption.copyWith(height: 1.4, color: erreur != null ? c.dangerFg : c.textMuted),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bouton « ≡ » (fond teinte primaire) ouvrant un dialog de sélection.
class DsLookupButton extends StatefulWidget {
  const DsLookupButton({super.key, required this.onPressed, required this.tooltip, this.taille = DsTailles.controleMd});
  final VoidCallback onPressed;
  final String tooltip;
  final double taille;
  @override
  State<DsLookupButton> createState() => _DsLookupButtonState();
}

class _DsLookupButtonState extends State<DsLookupButton> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _survol = true),
        onExit: (_) => setState(() => _survol = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: DsMotion.fast,
            width: widget.taille,
            height: widget.taille,
            decoration: BoxDecoration(
              color: _survol ? c.primaryTintHover : c.primaryTint,
              borderRadius: DsRadius.borderMd,
            ),
            child: Icon(LucideIcons.list, size: widget.taille < 36 ? 16 : 18, color: c.primaryTintFg),
          ),
        ),
      ),
    );
  }
}

/// Option d'un [DsSegmentedControl], d'un [DsChoiceCards] ou d'un [DsChipGroup].
class DsOption<T> {
  const DsOption(
    this.valeur, {
    this.libelle,
    this.icone,
    this.description,
    this.meta,
    this.couleur,
    this.desactive = false,
    this.tooltip,
  });
  final T valeur;
  final String? libelle;
  final IconData? icone;
  final String? description;
  final String? meta;
  final Color? couleur;
  final bool desactive;
  final String? tooltip;
}

/// Contrôle segmenté (`SegmentedControl`) : fond enfoncé, segment actif carte + ombre sm.
class DsSegmentedControl<T> extends StatelessWidget {
  const DsSegmentedControl({
    super.key,
    required this.options,
    required this.valeur,
    required this.onChanged,
    this.petit = false,
    this.pleineLargeur = false,
  });
  final List<DsOption<T>> options;
  final T valeur;
  final ValueChanged<T> onChanged;
  final bool petit;
  final bool pleineLargeur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final h = petit ? 28.0 : 32.0;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        mainAxisSize: pleineLargeur ? MainAxisSize.max : MainAxisSize.min,
        spacing: 2,
        children: [
          for (final o in options)
            Builder(
              builder: (context) {
                final actif = o.valeur == valeur;
                Widget segment = Tooltip(
                  message: o.tooltip ?? '',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onChanged(o.valeur),
                      child: AnimatedContainer(
                        duration: DsMotion.base,
                        curve: DsMotion.standard,
                        height: h,
                        padding: EdgeInsets.symmetric(horizontal: o.libelle != null ? 12 : 8),
                        decoration: BoxDecoration(
                          color: actif ? c.surfaceCard : DsColors.transparent,
                          borderRadius: DsRadius.borderMd,
                          boxShadow: actif ? c.shadowSm : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            if (o.icone != null)
                              Icon(o.icone, size: 15, color: actif ? c.textPrimary : c.textSecondary),
                            if (o.libelle != null)
                              Flexible(
                                child: Text(
                                  o.libelle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.bodySm.copyWith(
                                    fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
                                    color: actif ? c.textPrimary : c.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                if (pleineLargeur) segment = Expanded(child: segment);
                return segment;
              },
            ),
        ],
      ),
    );
  }
}

/// Cartes de choix exclusif (`ChoiceCards`) : radio ou icône, libellé, description, meta.
class DsChoiceCards<T> extends StatelessWidget {
  const DsChoiceCards({
    super.key,
    required this.options,
    required this.valeur,
    required this.onChanged,
    this.colonnes,
    this.petit = false,
  });
  final List<DsOption<T>> options;
  final T? valeur;
  final ValueChanged<T> onChanged;
  final int? colonnes;
  final bool petit;

  @override
  Widget build(BuildContext context) {
    final n = colonnes ?? options.length;
    final gap = petit ? 8.0 : 10.0;
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = (contraintes.maxWidth - gap * (n - 1)) / n;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final o in options)
              SizedBox(
                width: largeur,
                child: _Choix<T>(option: o, actif: o.valeur == valeur, petit: petit, onTap: () => onChanged(o.valeur)),
              ),
          ],
        );
      },
    );
  }
}

class _Choix<T> extends StatefulWidget {
  const _Choix({required this.option, required this.actif, required this.petit, required this.onTap});
  final DsOption<T> option;
  final bool actif;
  final bool petit;
  final VoidCallback onTap;
  @override
  State<_Choix<T>> createState() => _ChoixState<T>();
}

class _ChoixState<T> extends State<_Choix<T>> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final o = widget.option;
    final on = widget.actif;
    final sm = widget.petit;
    return MouseRegion(
      cursor: o.desactive ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: o.desactive ? null : widget.onTap,
        child: Opacity(
          opacity: o.desactive ? .5 : 1,
          child: AnimatedContainer(
            duration: DsMotion.fast,
            curve: DsMotion.standard,
            padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 14, vertical: sm ? 10 : 12),
            decoration: BoxDecoration(
              color: on ? c.primaryTint : (_survol ? c.surfaceHover : c.surfaceCard),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: on ? c.primary : c.borderDefault),
              boxShadow: on ? [BoxShadow(color: c.primary, spreadRadius: 1)] : c.shadowXs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                if (o.icone != null)
                  AnimatedContainer(
                    duration: DsMotion.fast,
                    width: sm ? 28 : 32,
                    height: sm ? 28 : 32,
                    decoration: BoxDecoration(color: on ? c.primary : c.surfaceSunken, borderRadius: DsRadius.borderMd),
                    child: Icon(o.icone, size: sm ? 15 : 17, color: on ? c.primaryFg : c.iconDefault),
                  )
                else
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.surfaceCard,
                      border: Border.all(color: on ? c.primary : c.borderStrong, width: 1.5),
                    ),
                    child: on
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: c.primary),
                          )
                        : null,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        o.libelle ?? '${o.valeur}',
                        style: t.body.copyWith(
                          fontSize: sm ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: on ? c.primaryTintFg : c.textPrimary,
                        ),
                      ),
                      if (o.description != null)
                        Text(o.description!, style: t.caption.copyWith(height: 1.4, color: c.textSecondary)),
                      if (o.meta != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            o.meta!,
                            style: t.body.copyWith(
                              fontSize: sm ? 13 : 15,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              fontFeatures: DsTypography.tabular,
                            ),
                          ),
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

/// Groupe de puces (`ChipGroup`) : sélection simple ou multiple, pastille couleur facultative.
class DsChipGroup<T> extends StatelessWidget {
  const DsChipGroup({
    super.key,
    required this.options,
    required this.selection,
    required this.onChanged,
    this.multiple = true,
    this.petit = false,
    this.pastilleSeule = false,
  });
  final List<DsOption<T>> options;
  final Set<T> selection;
  final ValueChanged<Set<T>> onChanged;
  final bool multiple;
  final bool petit;

  /// Couleurs seules (ronds 32 px) sans libellé.
  final bool pastilleSeule;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final o in options)
          _Chip<T>(
            option: o,
            actif: selection.contains(o.valeur),
            petit: petit,
            pastilleSeule: pastilleSeule,
            onTap: () {
              final actif = selection.contains(o.valeur);
              if (multiple) {
                final s = {...selection};
                actif ? s.remove(o.valeur) : s.add(o.valeur);
                onChanged(s);
              } else {
                onChanged({o.valeur});
              }
            },
          ),
      ],
    );
  }
}

class _Chip<T> extends StatefulWidget {
  const _Chip({
    required this.option,
    required this.actif,
    required this.petit,
    required this.pastilleSeule,
    required this.onTap,
  });
  final DsOption<T> option;
  final bool actif;
  final bool petit;
  final bool pastilleSeule;
  final VoidCallback onTap;
  @override
  State<_Chip<T>> createState() => _ChipState<T>();
}

class _ChipState<T> extends State<_Chip<T>> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final o = widget.option;
    final on = widget.actif;
    final sm = widget.petit;
    final clair = o.couleur != null && o.couleur!.computeLuminance() > .8;
    if (widget.pastilleSeule && o.couleur != null) {
      return Tooltip(
        message: o.libelle ?? '',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _survol = true),
          onExit: (_) => setState(() => _survol = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: DsMotion.fast,
              width: sm ? 28 : 32,
              height: sm ? 28 : 32,
              decoration: BoxDecoration(
                color: o.couleur,
                shape: BoxShape.circle,
                border: Border.all(color: clair ? c.borderStrong : DsColors.transparent),
                boxShadow: on || _survol
                    ? [
                        BoxShadow(color: c.surfaceCard, spreadRadius: 2),
                        BoxShadow(color: on ? c.primary : c.borderStrong, spreadRadius: 4),
                      ]
                    : null,
              ),
              child: on ? Icon(LucideIcons.check, size: 14, color: clair ? DsColors.ink950 : DsColors.blanc) : null,
            ),
          ),
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DsMotion.fast,
          curve: DsMotion.standard,
          height: sm ? 28 : 32,
          constraints: BoxConstraints(minWidth: sm ? 36 : 40),
          padding: EdgeInsetsDirectional.only(
            start: o.couleur != null ? (sm ? 6 : 8) : (sm ? 10 : 12),
            end: sm ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: on ? c.primaryTint : c.surfaceCard,
            borderRadius: DsRadius.borderPill,
            border: Border.all(color: on ? c.primary : (_survol ? c.borderStrong : c.borderDefault)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (o.couleur != null)
                Container(
                  width: sm ? 14 : 16,
                  height: sm ? 14 : 16,
                  decoration: BoxDecoration(
                    color: o.couleur,
                    shape: BoxShape.circle,
                    border: Border.all(color: clair ? c.borderStrong : DsColors.transparent),
                  ),
                ),
              Text(
                o.libelle ?? '${o.valeur}',
                style: t.bodySm.copyWith(
                  fontSize: sm ? 12 : 13,
                  fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  color: on ? c.primaryTintFg : c.textBody,
                  fontFeatures: DsTypography.tabular,
                ),
              ),
              if (on && o.couleur == null) Icon(LucideIcons.check, size: 13, color: c.primaryTintFg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Couleurs produit du DS (`PRODUCT_COLORS`) : libellé FR stocké + couleur.
const List<(String, Color)> dsCouleursProduit = [
  ('Blanc', Color(0xFFFFFFFF)),
  ('Noir', Color(0xFF1A1A1F)),
  ('Gris', Color(0xFF8A8A94)),
  ('Beige', Color(0xFFE6D3B3)),
  ('Marron', Color(0xFF7A4B2A)),
  ('Rouge', Color(0xFFD92D20)),
  ('Bordeaux', Color(0xFF7A1E2E)),
  ('Rose', Color(0xFFF17AB0)),
  ('Orange', Color(0xFFF38744)),
  ('Jaune', Color(0xFFF5C518)),
  ('Vert', Color(0xFF2E9E5B)),
  ('Kaki', Color(0xFF6B6B3A)),
  ('Bleu ciel', Color(0xFF6CB6F0)),
  ('Bleu', Color(0xFF2563EB)),
  ('Marine', Color(0xFF1E2A5A)),
  ('Violet', Color(0xFF7C4DDB)),
];

/// Saisie de clé par groupes (`KeyInput`) : cases monospace 44 px, passage automatique au groupe suivant.
class DsKeyInput extends StatefulWidget {
  const DsKeyInput({
    super.key,
    this.groupes = 5,
    this.tailleGroupe = 4,
    required this.valeur,
    required this.onChanged,
    this.erreur = false,
    this.actif = true,
    this.prefixe,
  });
  final int groupes;
  final int tailleGroupe;

  /// Clé brute (sans tirets), lettres majuscules et chiffres.
  final String valeur;
  final ValueChanged<String> onChanged;
  final bool erreur;
  final bool actif;
  final String? prefixe;

  static String nettoyer(String v) => v.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Formate avec des tirets (`AAAA-BBBB-…`).
  static String formater(String v, [int taille = 4]) {
    final s = nettoyer(v);
    final parties = <String>[];
    for (var i = 0; i < s.length; i += taille) {
      parties.add(s.substring(i, (i + taille).clamp(0, s.length)));
    }
    return parties.join('-');
  }

  @override
  State<DsKeyInput> createState() => _DsKeyInputState();
}

class _DsKeyInputState extends State<DsKeyInput> {
  late final List<TextEditingController> _ctrls = List.generate(widget.groupes, (_) => TextEditingController());
  late final List<FocusNode> _focus = List.generate(widget.groupes, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _synchroniser();
  }

  @override
  void didUpdateWidget(covariant DsKeyInput old) {
    super.didUpdateWidget(old);
    if (old.valeur != widget.valeur) _synchroniser();
  }

  void _synchroniser() {
    final propre = DsKeyInput.nettoyer(widget.valeur);
    for (var i = 0; i < widget.groupes; i++) {
      final debut = i * widget.tailleGroupe;
      final texte = debut >= propre.length
          ? ''
          : propre.substring(debut, (debut + widget.tailleGroupe).clamp(0, propre.length));
      if (_ctrls[i].text != texte) {
        _ctrls[i].value = TextEditingValue(
          text: texte,
          selection: TextSelection.collapsed(offset: texte.length),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  void _surGroupe(int i, String v) {
    final propre = DsKeyInput.nettoyer(v);
    final taille = widget.tailleGroupe;
    final courant = DsKeyInput.nettoyer(widget.valeur);
    final parties = List.generate(widget.groupes, (k) {
      final d = k * taille;
      return d >= courant.length ? '' : courant.substring(d, (d + taille).clamp(0, courant.length));
    });
    if (propre.length > taille) {
      // Collage d'une clé complète : on redistribue à partir du groupe courant.
      final prefixe = parties.take(i).join();
      final total = (prefixe + propre);
      widget.onChanged(total.substring(0, total.length.clamp(0, widget.groupes * taille)));
      final suivant = (i + (propre.length / taille).ceil()).clamp(0, widget.groupes - 1);
      _focus[suivant].requestFocus();
      return;
    }
    parties[i] = propre;
    widget.onChanged(parties.join());
    if (propre.length == taille && i < widget.groupes - 1) _focus[i + 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          if (widget.prefixe != null)
            Text(
              '${widget.prefixe}–',
              style: t.mono.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: c.textMuted),
            ),
          for (var i = 0; i < widget.groupes; i++) ...[
            if (i > 0) Text('–', style: t.bodyStrong.copyWith(color: c.textDisabled)),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrls[i],
              builder: (context, v, _) {
                final complet = v.text.length == widget.tailleGroupe;
                return Container(
                  width: widget.tailleGroupe * 14 + 22,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.actif ? c.surfaceCard : c.surfaceSunken,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: widget.erreur ? c.danger : (complet ? c.primary : c.borderDefault)),
                  ),
                  child: KeyboardListener(
                    focusNode: FocusNode(skipTraversal: true),
                    onKeyEvent: (e) {
                      if (e is KeyDownEvent &&
                          e.logicalKey == LogicalKeyboardKey.backspace &&
                          v.text.isEmpty &&
                          i > 0) {
                        _focus[i - 1].requestFocus();
                      }
                    },
                    child: TextField(
                      key: ValueKey('cle_groupe_$i'),
                      controller: _ctrls[i],
                      focusNode: _focus[i],
                      enabled: widget.actif,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      style: t.mono.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.9,
                        color: c.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (txt) => _surGroupe(i, txt),
                      onTap: () =>
                          _ctrls[i].selection = TextSelection(baseOffset: 0, extentOffset: _ctrls[i].text.length),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Sélection multiple ordonnée (`OrderedMultiSelect`) : liste numérotée (1 = par défaut) + puces à ajouter.
class DsOrderedMultiSelect<T> extends StatelessWidget {
  const DsOrderedMultiSelect({
    super.key,
    required this.options,
    required this.valeur,
    required this.onChanged,
    this.texteVide = 'Aucun élément sélectionné',
    this.libellePremier = 'Par défaut',
  });
  final List<DsOption<T>> options;
  final List<T> valeur;
  final ValueChanged<List<T>> onChanged;
  final String texteVide;
  final String libellePremier;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final selection = [for (final v in valeur) options.where((o) => o.valeur == v).firstOrNull].nonNulls.toList();
    final reste = options.where((o) => !valeur.contains(o.valeur)).toList();
    void deplacer(int i, int d) {
      final j = i + d;
      if (j < 0 || j >= valeur.length) return;
      final a = [...valeur];
      final tmp = a[i];
      a[i] = a[j];
      a[j] = tmp;
      onChanged(a);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s2,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selection.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(texteVide, style: t.bodySm.copyWith(color: c.textMuted)),
                ),
              for (final (i, o) in selection.indexed)
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
                  decoration: BoxDecoration(
                    border: i > 0 ? Border(top: BorderSide(color: c.borderSubtle)) : null,
                  ),
                  child: Row(
                    spacing: 10,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == 0 ? c.primary : c.surfaceSunken,
                          borderRadius: DsRadius.borderSm,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: t.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: i == 0 ? c.primaryFg : c.textSecondary,
                            fontFeatures: DsTypography.tabular,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          o.libelle ?? '${o.valeur}',
                          style: t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (i == 0) DsBadge(libelle: libellePremier, ton: DsBadgeTon.primaire, petit: true),
                      DsIconButton(
                        icone: LucideIcons.chevronUp,
                        tooltip: 'Monter',
                        taille: 28,
                        onPressed: i == 0 ? null : () => deplacer(i, -1),
                      ),
                      DsIconButton(
                        icone: LucideIcons.chevronDown,
                        tooltip: 'Descendre',
                        taille: 28,
                        onPressed: i == selection.length - 1 ? null : () => deplacer(i, 1),
                      ),
                      DsIconButton(
                        icone: LucideIcons.x,
                        tooltip: 'Retirer',
                        taille: 28,
                        onPressed: () => onChanged(valeur.where((v) => v != o.valeur).toList()),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (reste.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in reste)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onChanged([...valeur, o.valeur]),
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: DsRadius.borderPill,
                        border: Border.all(color: c.borderStrong, style: BorderStyle.solid),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Icon(LucideIcons.plus, size: 13, color: c.textSecondary),
                          Text(
                            o.libelle ?? '${o.valeur}',
                            style: t.bodySm.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Période calculée (`PeriodFilter.compute`).
class DsPeriode {
  const DsPeriode({required this.du, required this.au, this.preset});
  final DateTime du;
  final DateTime au;
  final String? preset;

  /// Clés des périodes rapides du DS, dans l'ordre.
  static const List<String> presets = [
    'today',
    'yesterday',
    'week',
    'lastWeek',
    'month',
    'lastMonth',
    'last7days',
    'last30days',
    'year',
    'lastYear',
  ];

  /// Libellés FR des presets (traduire à l'affichage via ARB si nécessaire).
  static const Map<String, String> libellesFr = {
    'today': "Aujourd'hui",
    'yesterday': 'Hier',
    'week': 'Cette semaine',
    'lastWeek': 'Semaine dernière',
    'month': 'Ce mois',
    'lastMonth': 'Mois dernier',
    'last7days': '7 derniers jours',
    'last30days': '30 derniers jours',
    'year': 'Cette année',
    'lastYear': 'Année dernière',
  };

  static DsPeriode calculer(String cle, [DateTime? maintenant]) {
    final n = maintenant ?? DateTime.now();
    final y = n.year, m = n.month, d = n.day;
    final wd = (n.weekday + 6) % 7; // lundi = 0
    DateTime dd(int y, int m, int d) => DateTime(y, m, d);
    final (du, au) = switch (cle) {
      'today' => (dd(y, m, d), dd(y, m, d)),
      'yesterday' => (dd(y, m, d - 1), dd(y, m, d - 1)),
      'week' => (dd(y, m, d - wd), dd(y, m, d - wd + 6)),
      'lastWeek' => (dd(y, m, d - wd - 7), dd(y, m, d - wd - 1)),
      'month' => (dd(y, m, 1), dd(y, m + 1, 0)),
      'lastMonth' => (dd(y, m - 1, 1), dd(y, m, 0)),
      'last7days' => (dd(y, m, d - 6), dd(y, m, d)),
      'last30days' => (dd(y, m, d - 29), dd(y, m, d)),
      'year' => (dd(y, 1, 1), dd(y, 12, 31)),
      'lastYear' => (dd(y - 1, 1, 1), dd(y - 1, 12, 31)),
      _ => (dd(y, m, d), dd(y, m, d)),
    };
    return DsPeriode(du: du, au: au, preset: cle);
  }
}

/// Filtre de période (`PeriodFilter`) : Du / Au / Période rapide.
class DsPeriodFilter extends StatelessWidget {
  const DsPeriodFilter({
    super.key,
    required this.periode,
    required this.onChanged,
    this.libelleDu = 'Du',
    this.libelleAu = 'Au',
    this.libellePreset = 'Période rapide',
    this.libellesPresets = DsPeriode.libellesFr,
    this.enLigne = true,
    this.largeurLibelle = 40,
  });
  final DsPeriode periode;
  final ValueChanged<DsPeriode> onChanged;
  final String libelleDu;
  final String libelleAu;
  final String libellePreset;
  final Map<String, String> libellesPresets;
  final bool enLigne;
  final double largeurLibelle;

  @override
  Widget build(BuildContext context) {
    final champs = [
      DsFormRow(
        libelle: libelleDu,
        largeurLibelle: largeurLibelle,
        child: DsDateField(
          valeur: periode.du,
          max: periode.au,
          onChanged: (v) => onChanged(DsPeriode(du: v ?? periode.du, au: periode.au)),
        ),
      ),
      DsFormRow(
        libelle: libelleAu,
        largeurLibelle: largeurLibelle,
        child: DsDateField(
          valeur: periode.au,
          min: periode.du,
          onChanged: (v) => onChanged(DsPeriode(du: periode.du, au: v ?? periode.au)),
        ),
      ),
      DsFormRow(
        libelle: libellePreset,
        largeurLibelle: enLigne ? 100 : largeurLibelle,
        child: DsSelect<String>(
          valeur: periode.preset,
          options: DsPeriode.presets,
          libelle: (k) => libellesPresets[k] ?? k,
          placeholder: 'Choisir…',
          onChanged: (k) => k == null ? null : onChanged(DsPeriode.calculer(k)),
        ),
      ),
    ];
    if (!enLigne) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: DsSpacing.s3, children: champs);
    }
    return Row(
      spacing: DsSpacing.s5,
      children: [for (final f in champs) Expanded(child: f)],
    );
  }
}

/// Intervalle numérique (`RangeFilter`).
class DsIntervalle {
  const DsIntervalle({this.min, this.max});
  final double? min;
  final double? max;
  bool get estVide => min == null && max == null;
}

/// Filtre « Min → Max » (`RangeFilter`) : bouton teinté quand actif, popover de saisie.
class DsRangeFilter extends StatefulWidget {
  const DsRangeFilter({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.unite,
    this.placeholder = 'Min → Max',
    this.largeur,
    this.libelleMin = 'Min',
    this.libelleMax = 'Max',
    this.libelleEffacer = 'Effacer',
    this.libelleValider = 'Valider',
  });
  final DsIntervalle valeur;
  final ValueChanged<DsIntervalle> onChanged;
  final String? unite;
  final String placeholder;
  final double? largeur;
  final String libelleMin;
  final String libelleMax;
  final String libelleEffacer;
  final String libelleValider;

  @override
  State<DsRangeFilter> createState() => _DsRangeFilterState();
}

class _DsRangeFilterState extends State<DsRangeFilter> {
  final _lien = LayerLink();
  final _portail = OverlayPortalController();
  final _min = TextEditingController();
  final _max = TextEditingController();

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _ouvrir() {
    _min.text = widget.valeur.min == null ? '' : formaterNombre(widget.valeur.min!);
    _max.text = widget.valeur.max == null ? '' : formaterNombre(widget.valeur.max!);
    _portail.toggle();
    setState(() {});
  }

  void _valider(DsIntervalle v) {
    widget.onChanged(v);
    _portail.hide();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final a = widget.valeur;
    final actif = !a.estVide;
    final ouvert = _portail.isShowing;
    String f(double? n) => n == null ? '…' : formaterNombre(n);
    return CompositedTransformTarget(
      link: _lien,
      child: OverlayPortal(
        controller: _portail,
        overlayChildBuilder: (ctx) => Positioned(
          width: 280,
          child: CompositedTransformFollower(
            link: _lien,
            targetAnchor: AlignmentDirectional.bottomStart.resolve(Directionality.of(context)),
            followerAnchor: AlignmentDirectional.topStart.resolve(Directionality.of(context)),
            offset: const Offset(0, 6),
            child: TapRegion(
              groupId: _portail,
              onTapOutside: (_) => _valider(a),
              child: Material(
                color: DsColors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(color: c.borderDefault),
                    boxShadow: c.shadowMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: DsTextField(
                              libelle: widget.libelleMin,
                              controller: _min,
                              numerique: true,
                              autofocus: true,
                              suffixeTexte: widget.unite,
                            ),
                          ),
                          Expanded(
                            child: DsTextField(
                              libelle: widget.libelleMax,
                              controller: _max,
                              numerique: true,
                              suffixeTexte: widget.unite,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 8,
                        children: [
                          DsButton(
                            libelle: widget.libelleEffacer,
                            variante: DsButtonVariante.fantome,
                            taille: DsButtonTaille.sm,
                            onPressed: () => _valider(const DsIntervalle()),
                          ),
                          DsButton(
                            libelle: widget.libelleValider,
                            icone: LucideIcons.check,
                            taille: DsButtonTaille.sm,
                            onPressed: () =>
                                _valider(DsIntervalle(min: lireNombre(_min.text), max: lireNombre(_max.text))),
                          ),
                        ],
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
            child: GestureDetector(
              onTap: _ouvrir,
              child: AnimatedContainer(
                duration: DsMotion.fast,
                width: widget.largeur,
                height: DsTailles.controleMd,
                padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
                decoration: BoxDecoration(
                  color: actif ? c.primaryTint : c.surfaceCard,
                  borderRadius: DsRadius.borderMd,
                  border: Border.all(color: ouvert ? c.borderFocus : (actif ? c.primary : c.borderDefault)),
                  boxShadow: ouvert ? [BoxShadow(color: c.ringFocus, spreadRadius: 3)] : c.shadowXs,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(LucideIcons.arrowLeftRight, size: 16, color: actif ? c.primaryTintFg : c.iconMuted),
                    Expanded(
                      child: Text(
                        actif
                            ? '${f(a.min)} → ${f(a.max)}${widget.unite == null ? '' : ' ${widget.unite}'}'
                            : widget.placeholder,
                        style: t.body.copyWith(
                          fontWeight: actif ? FontWeight.w600 : FontWeight.w400,
                          color: actif ? c.primaryTintFg : c.textMuted,
                          fontFeatures: DsTypography.tabular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: ouvert ? .5 : 0,
                      duration: DsMotion.base,
                      child: Icon(LucideIcons.chevronDown, size: 16, color: c.iconMuted),
                    ),
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

/// Magasin d'un [DsSplitAllocator].
class DsMagasinRepartition {
  const DsMagasinRepartition({required this.code, required this.nom, this.principal = false, this.stock});
  final String code;
  final String nom;
  final bool principal;
  final double? stock;
}

/// Répartition d'une quantité entre magasins (`SplitAllocator`) : compteurs Total / Réparti / Reste.
class DsSplitAllocator extends StatelessWidget {
  const DsSplitAllocator({
    super.key,
    required this.total,
    required this.magasins,
    required this.valeur,
    required this.onChanged,
    this.unite = '',
    this.decimales = 0,
    this.libelles = const {},
  });
  final double total;
  final List<DsMagasinRepartition> magasins;

  /// Quantité par code magasin.
  final Map<String, double> valeur;
  final ValueChanged<Map<String, double>> onChanged;
  final String unite;
  final int decimales;

  /// Libellés traduits : total, reparti, reste, principal, enStock, toutPrincipal, repartir, restePrincipal.
  final Map<String, String> libelles;

  static bool equilibre(double total, Map<String, double> v) =>
      (total - v.values.fold(0.0, (a, b) => a + b)).abs() < 1e-6;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    String l(String k, String defaut) => libelles[k] ?? defaut;
    final principal = magasins.where((m) => m.principal).firstOrNull ?? magasins.firstOrNull;
    final reparti = magasins.fold(0.0, (a, m) => a + (valeur[m.code] ?? 0));
    final reste = double.parse((total - reparti).toStringAsFixed(6));
    String q(double n) => '${formaterNombre(n, decimales: decimales)}${unite.isEmpty ? '' : ' $unite'}';
    void repartirEgalement() {
      if (magasins.isEmpty) return;
      final par = decimales > 0
          ? double.parse((total / magasins.length).toStringAsFixed(decimales))
          : (total / magasins.length).floorToDouble();
      final o = <String, double>{};
      for (final (i, m) in magasins.indexed) {
        o[m.code] = i == 0 ? double.parse((total - par * (magasins.length - 1)).toStringAsFixed(decimales)) : par;
      }
      onChanged(o);
    }

    Widget compteur(String libelle, String v, Color fond, Color couleur, [IconData? icone]) => Expanded(
      child: AnimatedContainer(
        duration: DsMotion.base,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 6,
              children: [
                if (icone != null) Icon(icone, size: 13, color: couleur),
                Text(
                  libelle,
                  style: t.caption.copyWith(fontWeight: FontWeight.w600, color: couleur),
                ),
              ],
            ),
            Text(
              v,
              style: t.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: couleur,
                fontFeatures: DsTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        Row(
          spacing: DsSpacing.s2,
          children: [
            compteur(l('total', 'Total'), q(total), c.primaryTint, c.primaryTintFg),
            compteur(l('reparti', 'Réparti'), q(reparti), c.successTint, c.successFg),
            compteur(
              l('reste', 'Reste'),
              q(reste),
              reste == 0 ? c.surfaceSunken : c.dangerTint,
              reste == 0 ? c.textSecondary : c.dangerFg,
              reste == 0 ? LucideIcons.circleCheck : LucideIcons.circleAlert,
            ),
          ],
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            children: [
              for (final (i, m) in magasins.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (valeur[m.code] ?? 0) > 0 ? c.surfaceCard : c.surfaceSunken,
                    border: i > 0 ? Border(top: BorderSide(color: c.borderSubtle)) : null,
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Icon(LucideIcons.store, size: 16, color: (valeur[m.code] ?? 0) > 0 ? c.iconActive : c.iconMuted),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 8,
                              children: [
                                Flexible(
                                  child: Text(
                                    m.nom,
                                    style: t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (m.principal)
                                  DsBadge(libelle: l('principal', 'Principal'), ton: DsBadgeTon.primaire, petit: true),
                              ],
                            ),
                            if (m.stock != null)
                              Text(
                                '${l('enStock', 'En stock')} : ${q(m.stock!)}',
                                style: t.caption.copyWith(color: c.textMuted),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: DsTextField(
                          key: ValueKey('repartition_${m.code}'),
                          numerique: true,
                          taille: 34,
                          indice: '0',
                          suffixeTexte: unite.isEmpty ? null : unite,
                          valeurInitiale: null,
                          controller: _ControleurRepartition.pour(m.code, valeur[m.code], decimales),
                          onChanged: (txt) => onChanged({...valeur, m.code: lireNombre(txt) ?? 0}),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: DsSpacing.s2,
          runSpacing: DsSpacing.s2,
          children: [
            DsButton(
              libelle: l('toutPrincipal', 'Tout dans le principal'),
              icone: LucideIcons.store,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.fantome,
              delaiGarde: Duration.zero,
              onPressed: principal == null ? null : () => onChanged({principal.code: total}),
            ),
            DsButton(
              libelle: l('repartir', 'Répartir également'),
              icone: LucideIcons.split,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.fantome,
              delaiGarde: Duration.zero,
              onPressed: repartirEgalement,
            ),
            if (reste > 0 && principal != null)
              DsButton(
                libelle: l('restePrincipal', 'Reste au principal'),
                icone: LucideIcons.plus,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                delaiGarde: Duration.zero,
                onPressed: () => onChanged({...valeur, principal.code: (valeur[principal.code] ?? 0) + reste}),
              ),
          ],
        ),
      ],
    );
  }
}

/// Contrôleurs de texte stables par magasin pour [DsSplitAllocator] (évite de perdre la saisie au rebuild).
class _ControleurRepartition {
  static final Map<String, TextEditingController> _cache = {};
  static TextEditingController pour(String code, double? valeur, int decimales) {
    final ctrl = _cache.putIfAbsent(code, TextEditingController.new);
    final attendu = valeur == null || valeur == 0 ? '' : formaterNombre(valeur, decimales: decimales, grouper: false);
    final actuel = lireNombre(ctrl.text) ?? 0;
    if ((valeur ?? 0) != actuel) {
      ctrl.value = TextEditingValue(
        text: attendu,
        selection: TextSelection.collapsed(offset: attendu.length),
      );
    }
    return ctrl;
  }
}

/// Photo d'un [DsPhotoUploader].
class DsPhoto {
  const DsPhoto({required this.id, required this.nom, this.octets, this.chemin});
  final String id;
  final String nom;
  final List<int>? octets;
  final String? chemin;
}

/// Téléversement de photos (`PhotoUploader`) : tuiles 88 px, « Principale » sur la première.
class DsPhotoUploader extends StatelessWidget {
  const DsPhotoUploader({
    super.key,
    required this.photos,
    required this.onAjouter,
    this.onRetirer,
    this.max = 4,
    this.taille = 88,
    this.aide = 'JPG ou PNG · 2 Mo max',
    this.libelleAjouter = 'Ajouter',
    this.libellePrincipale = 'Principale',
    this.libelleFin = 'la première est la photo principale',
  });
  final List<DsPhoto> photos;
  final VoidCallback onAjouter;
  final ValueChanged<DsPhoto>? onRetirer;
  final int max;
  final double taille;
  final String aide;
  final String libelleAjouter;
  final String libellePrincipale;
  final String libelleFin;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, p) in photos.indexed)
              _TuilePhoto(
                photo: p,
                taille: taille,
                principale: i == 0,
                libellePrincipale: libellePrincipale,
                onRetirer: onRetirer == null ? null : () => onRetirer!(p),
              ),
            if (photos.length < max)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onAjouter,
                  child: Container(
                    key: const ValueKey('photo_ajouter'),
                    width: taille,
                    height: taille,
                    decoration: BoxDecoration(
                      color: c.surfaceSunken,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.borderStrong, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(LucideIcons.imagePlus, size: 20, color: c.textSecondary),
                        Text(
                          libelleAjouter,
                          style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text('${photos.length} / $max · $aide · $libelleFin', style: t.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}

class _TuilePhoto extends StatefulWidget {
  const _TuilePhoto({
    required this.photo,
    required this.taille,
    required this.principale,
    required this.libellePrincipale,
    this.onRetirer,
  });
  final DsPhoto photo;
  final double taille;
  final bool principale;
  final String libellePrincipale;
  final VoidCallback? onRetirer;
  @override
  State<_TuilePhoto> createState() => _TuilePhotoState();
}

class _TuilePhotoState extends State<_TuilePhoto> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final p = widget.photo;
    final image = p.octets != null ? Image.memory(Uint8List.fromList(p.octets!), fit: BoxFit.cover) : null;
    return MouseRegion(
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: Tooltip(
        message: p.nom,
        child: Container(
          width: widget.taille,
          height: widget.taille,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: image == null ? c.primaryTint : c.surfaceSunken,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.borderDefault),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null) image else Icon(LucideIcons.image, size: 22, color: c.primaryTintFg),
              if (widget.principale)
                PositionedDirectional(
                  start: 4,
                  bottom: 4,
                  child: Container(
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.surfaceOverlay, borderRadius: DsRadius.borderPill),
                    child: Text(
                      widget.libellePrincipale,
                      style: t.caption.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: DsColors.blanc,
                      ),
                    ),
                  ),
                ),
              if (widget.onRetirer != null)
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: AnimatedOpacity(
                    opacity: _survol ? 1 : 0,
                    duration: DsMotion.fast,
                    child: GestureDetector(
                      onTap: widget.onRetirer,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(color: c.surfaceOverlay, borderRadius: DsRadius.borderSm),
                        child: const Icon(LucideIcons.x, size: 13, color: DsColors.blanc),
                      ),
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
