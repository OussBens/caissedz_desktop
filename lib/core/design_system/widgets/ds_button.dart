import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';

/// Variantes du bouton DS v2.2 (`Button.variant`).
enum DsButtonVariante { primaire, secondaire, fantome, doux, danger, accent, inverse }

/// Tailles du bouton DS : sm 32, md 36, lg 44.
enum DsButtonTaille { sm, md, lg }

/// Bouton du design system (`Button`) avec garde anti double-clic intégrée (450 ms).
///
/// - Si [onPressed] renvoie un `Future`, le bouton affiche le glyphe « chargement » (statique,
///   pour ne pas bloquer les dialogs ouverts depuis le bouton) et reste inactif jusqu'à sa complétion ;
///   [chargement] affiche le spinner animé du DS.
/// - Un second clic survenant moins de [delaiGarde] après le précédent est ignoré.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.libelle,
    this.onPressed,
    this.icone,
    this.iconeDroite,
    this.kbd,
    this.variante = DsButtonVariante.primaire,
    this.taille = DsButtonTaille.md,
    this.pleineLargeur = false,
    this.chargement = false,
    this.delaiGarde = const Duration(milliseconds: 450),
    this.tooltip,
    this.autofocus = false,
    this.iconeSeule = false,
  });

  final String libelle;
  final FutureOr<void> Function()? onPressed;
  final IconData? icone;
  final IconData? iconeDroite;

  /// Raccourci clavier affiché dans une puce (`kbd`), ex. « F12 ».
  final String? kbd;
  final DsButtonVariante variante;
  final DsButtonTaille taille;
  final bool pleineLargeur;
  final bool chargement;
  final Duration delaiGarde;
  final String? tooltip;
  final bool autofocus;

  /// Bouton carré réduit à son [icone] ; le [libelle] passe en infobulle (actions Modifier, Annuler).
  final bool iconeSeule;

  @override
  State<DsButton> createState() => _DsButtonState();
}

class _DsButtonState extends State<DsButton> {
  bool _enCours = false;
  DateTime? _dernierClic;
  bool _survol = false;
  bool _presse = false;
  bool _focus = false;

  bool get _actif => widget.onPressed != null && !_enCours && !widget.chargement;

  Future<void> _declencher() async {
    if (!_actif) return;
    final maintenant = clock.now();
    if (_dernierClic != null && maintenant.difference(_dernierClic!) < widget.delaiGarde) {
      return;
    }
    _dernierClic = maintenant;
    final resultat = widget.onPressed!();
    if (resultat is Future<void>) {
      setState(() => _enCours = true);
      try {
        await resultat;
      } finally {
        if (mounted) setState(() => _enCours = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final actif = _actif;
    final desactive = widget.onPressed == null;

    final (hauteur, paddingH, taillePolice, tailleIcone) = switch (widget.taille) {
      DsButtonTaille.sm => (DsTailles.controleSm, 12.0, 13.0, 16.0),
      DsButtonTaille.md => (DsTailles.controleMd, 14.0, 14.0, 18.0),
      DsButtonTaille.lg => (DsTailles.controleLg, 18.0, 15.0, 18.0),
    };

    // (fond, fond survol, texte, bordure)
    final (fondBase, fondSurvol, texte, bordure) = switch (widget.variante) {
      DsButtonVariante.primaire => (c.primary, c.primaryHover, c.primaryFg, null),
      DsButtonVariante.secondaire => (c.surfaceCard, c.surfaceHover, c.textPrimary, c.borderDefault),
      DsButtonVariante.fantome => (null, c.surfaceHover, c.textSecondary, null),
      DsButtonVariante.doux => (c.primaryTint, c.primaryTintHover, c.primaryTintFg, null),
      DsButtonVariante.danger => (c.danger, c.dangerHover, DsColors.blanc, null),
      DsButtonVariante.accent => (c.accent, c.accentHover, c.accentFg, null),
      DsButtonVariante.inverse => (c.surfaceInverse, DsColors.ink750, c.textInverse, null),
    };
    final fond = _survol && actif ? fondSurvol : fondBase;
    final kbdFond = widget.variante == DsButtonVariante.primaire || widget.variante == DsButtonVariante.danger
        ? DsColors.blanc.withValues(alpha: 0.18)
        : c.surfaceSunken;

    final style = t.body.copyWith(fontSize: taillePolice, fontWeight: FontWeight.w600, height: 1, color: texte);

    final seule = widget.iconeSeule && widget.icone != null;
    final contenu = Row(
      mainAxisSize: widget.pleineLargeur ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: DsSpacing.s2,
      children: [
        if (widget.chargement)
          SizedBox(
            width: tailleIcone - 4,
            height: tailleIcone - 4,
            child: CircularProgressIndicator(strokeWidth: 2, color: texte),
          )
        else if (_enCours)
          Icon(LucideIcons.loaderCircle, size: tailleIcone, color: texte)
        else if (widget.icone != null)
          Icon(widget.icone, size: tailleIcone, color: texte),
        if (!seule)
          Flexible(
            child: Text(widget.libelle, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        if (widget.kbd != null && !seule)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(color: kbdFond, borderRadius: DsRadius.borderXs),
            child: Text(
              widget.kbd!,
              style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, height: 1, color: texte),
            ),
          ),
        if (widget.iconeDroite != null) Icon(widget.iconeDroite, size: tailleIcone, color: texte),
      ],
    );

    Widget bouton = Semantics(
      button: true,
      enabled: actif,
      label: widget.libelle,
      child: FocusableActionDetector(
        enabled: actif,
        autofocus: widget.autofocus,
        onShowHoverHighlight: (v) => setState(() => _survol = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        mouseCursor: actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _declencher())},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: actif ? (_) => setState(() => _presse = true) : null,
          onTapUp: actif ? (_) => setState(() => _presse = false) : null,
          onTapCancel: actif ? () => setState(() => _presse = false) : null,
          onTap: actif ? _declencher : null,
          child: AnimatedScale(
            scale: _presse && actif ? DsMotion.pressScale : 1,
            duration: DsMotion.fast,
            curve: DsMotion.standard,
            child: AnimatedOpacity(
              opacity: desactive ? 0.5 : 1,
              duration: DsMotion.fast,
              child: AnimatedContainer(
                duration: DsMotion.fast,
                curve: DsMotion.standard,
                height: hauteur,
                width: seule ? hauteur : null,
                padding: EdgeInsets.symmetric(horizontal: seule ? 0 : paddingH),
                decoration: BoxDecoration(
                  color: fond,
                  borderRadius: DsRadius.borderMd,
                  border: Border.all(color: _focus ? c.borderFocus : (bordure ?? DsColors.transparent)),
                  boxShadow: widget.variante == DsButtonVariante.secondaire ? c.shadowXs : null,
                ),
                child: contenu,
              ),
            ),
          ),
        ),
      ),
    );
    final infobulle = widget.tooltip ?? (seule ? widget.libelle : null);
    if (infobulle != null) {
      bouton = Tooltip(message: infobulle, child: bouton);
    }
    return bouton;
  }
}

/// Bouton icône du DS (`IconButton`) : fantôme ou contour, badge facultatif.
///
/// [taille] est la dimension du carré (sm 32, md 36, lg 40). Icône 16 px sous 36, 18 px sinon.
class DsIconButton extends StatefulWidget {
  const DsIconButton({
    super.key,
    required this.icone,
    required this.tooltip,
    this.onPressed,
    this.taille = DsTailles.controleMd,
    this.couleur,
    this.couleurSurvol,
    this.actif = false,
    this.contour = false,
    this.badge,
    this.point = false,
  });

  final IconData icone;
  final String tooltip;
  final VoidCallback? onPressed;
  final double taille;
  final Color? couleur;
  final Color? couleurSurvol;

  /// État « actif » (surface active + icône primaire).
  final bool actif;

  /// Variante `outline` : fond carte, bordure et ombre xs.
  final bool contour;

  /// Compteur affiché en pastille rouge (ex. alertes), « 99+ » au-delà de 99. `0` ou `null` : rien.
  final int? badge;

  /// Point rouge sans compteur.
  final bool point;

  @override
  State<DsIconButton> createState() => _DsIconButtonState();
}

class _DsIconButtonState extends State<DsIconButton> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final desactive = widget.onPressed == null;
    final fond = widget.actif
        ? c.surfaceActive
        : (_survol && !desactive ? (widget.couleurSurvol ?? c.surfaceHover) : (widget.contour ? c.surfaceCard : null));
    final couleurIcone =
        widget.couleur ?? (widget.actif ? c.iconActive : (_survol && !desactive ? c.textPrimary : c.iconDefault));
    final tailleIcone = widget.taille < 36 ? DsTailles.iconeSm : DsTailles.icone;
    final badge = widget.badge;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: !desactive,
        label: widget.tooltip,
        child: MouseRegion(
          cursor: desactive ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _survol = true),
          onExit: (_) => setState(() => _survol = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: Opacity(
              opacity: desactive ? 0.45 : 1,
              child: AnimatedContainer(
                duration: DsMotion.fast,
                curve: DsMotion.standard,
                width: widget.taille,
                height: widget.taille,
                decoration: BoxDecoration(
                  color: fond,
                  borderRadius: DsRadius.borderMd,
                  border: Border.all(color: widget.contour ? c.borderDefault : DsColors.transparent),
                  boxShadow: widget.contour ? c.shadowXs : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(widget.icone, size: tailleIcone, color: couleurIcone),
                    ),
                    if (badge != null && badge > 0)
                      PositionedDirectional(
                        top: 2,
                        end: 1,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          height: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.danger,
                            borderRadius: DsRadius.borderMd,
                            border: Border.all(color: c.surfaceCard, width: 2),
                          ),
                          child: Text(
                            badge > 99 ? '99+' : '$badge',
                            style: t.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1,
                              color: DsColors.blanc,
                            ),
                          ),
                        ),
                      )
                    else if (widget.point)
                      PositionedDirectional(
                        top: 7,
                        end: 7,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: c.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surfaceCard, width: 2),
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
    );
  }
}

/// Puce « raccourci clavier » (`kbd`) : fond enfoncé, bordure, 11 px.
class DsKbd extends StatelessWidget {
  const DsKbd(this.texte, {super.key});
  final String texte;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: DsRadius.borderXs,
        border: Border.all(color: c.borderDefault),
      ),
      child: Text(
        texte,
        style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, height: 1, color: c.textMuted),
      ),
    );
  }
}

/// Icône Lucide dans une boîte 28 px bordée (en-tête de carte, KPI…).
class DsIconBox extends StatelessWidget {
  const DsIconBox(this.icone, {super.key, this.taille = 28, this.tailleIcone = 15, this.fond, this.couleur});
  final IconData icone;
  final double taille;
  final double tailleIcone;
  final Color? fond;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(taille * 0.25),
        border: fond == null ? Border.all(color: c.borderDefault) : null,
      ),
      child: Icon(icone, size: tailleIcone, color: couleur ?? c.iconDefault),
    );
  }
}

/// Icône de chargement discrète (spinner 2 px).
class DsSpinner extends StatelessWidget {
  const DsSpinner({super.key, this.taille = 16, this.couleur});
  final double taille;
  final Color? couleur;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: taille,
    height: taille,
    child: CircularProgressIndicator(strokeWidth: 2, color: couleur ?? context.ds.colors.primary),
  );
}

/// Icône « fermer » 32 px utilisée par les dialogs et toasts.
class DsBoutonFermer extends StatelessWidget {
  const DsBoutonFermer({super.key, required this.onPressed, required this.tooltip});
  final VoidCallback onPressed;
  final String tooltip;
  @override
  Widget build(BuildContext context) =>
      DsIconButton(icone: LucideIcons.x, tooltip: tooltip, taille: DsTailles.controleSm, onPressed: onPressed);
}
