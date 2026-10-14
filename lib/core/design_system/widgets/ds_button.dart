import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';

enum DsButtonVariante { primaire, secondaire, fantome, danger, succes }

enum DsButtonTaille { sm, md, lg }

/// Bouton du design system avec garde anti double-clic intégrée.
///
/// - Si [onPressed] renvoie un `Future`, le bouton est désactivé (avec un
///   indicateur de chargement) jusqu'à sa complétion.
/// - Dans tous les cas, un second clic survenant moins de [delaiGarde] après
///   le précédent est ignoré.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.libelle,
    this.onPressed,
    this.icone,
    this.variante = DsButtonVariante.primaire,
    this.taille = DsButtonTaille.md,
    this.pleineLargeur = false,
    this.chargement = false,
    this.delaiGarde = const Duration(milliseconds: 600),
    this.tooltip,
    this.autofocus = false,
  });

  final String libelle;
  final FutureOr<void> Function()? onPressed;
  final IconData? icone;
  final DsButtonVariante variante;
  final DsButtonTaille taille;
  final bool pleineLargeur;
  final bool chargement;
  final Duration delaiGarde;
  final String? tooltip;
  final bool autofocus;

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
    final enChargement = _enCours || widget.chargement;

    final hauteur = switch (widget.taille) {
      DsButtonTaille.sm => DsTailles.controleSm,
      DsButtonTaille.md => DsTailles.controleMd,
      DsButtonTaille.lg => DsTailles.controleLg,
    };
    final paddingH = switch (widget.taille) {
      DsButtonTaille.sm => DsSpacing.md,
      DsButtonTaille.md => DsSpacing.lg,
      DsButtonTaille.lg => DsSpacing.xl,
    };
    final style = widget.taille == DsButtonTaille.sm ? t.petitFort : t.corpsFort;

    Color fond;
    Color texte;
    Color? bordure;
    switch (widget.variante) {
      case DsButtonVariante.primaire:
        fond = _presse ? c.primaireActif : (_survol ? c.primaireSurvol : c.primaire);
        texte = c.surPrimaire;
      case DsButtonVariante.secondaire:
        fond = _presse ? c.surfaceAttenuee : (_survol ? c.surfaceAttenuee : c.surface);
        texte = c.texte;
        bordure = c.bordureForte;
      case DsButtonVariante.fantome:
        fond = _presse || _survol ? c.surfaceAttenuee : const Color(0x00000000);
        texte = c.texteSecondaire;
      case DsButtonVariante.danger:
        fond = _presse || _survol ? c.danger.withValues(alpha: 0.9) : c.danger;
        texte = c.texteInverse;
      case DsButtonVariante.succes:
        fond = _presse || _survol ? c.succes.withValues(alpha: 0.9) : c.succes;
        texte = c.texteInverse;
    }
    if (!actif) {
      fond = fond.withValues(alpha: fond.a * 0.55);
      texte = texte.withValues(alpha: 0.7);
    }

    final contenu = Row(
      mainAxisSize: widget.pleineLargeur ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.chargement)
          SizedBox(
            width: DsTailles.iconeSm,
            height: DsTailles.iconeSm,
            child: CircularProgressIndicator(strokeWidth: 2, color: texte),
          )
        else if (_enCours)
          Icon(LucideIcons.loader, size: DsTailles.icone, color: texte)
        else if (widget.icone != null)
          Icon(widget.icone, size: DsTailles.icone, color: texte),
        if (enChargement || widget.icone != null) const SizedBox(width: DsSpacing.sm),
        Flexible(
          child: Text(
            widget.libelle,
            style: style.copyWith(color: texte),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
        mouseCursor: actif ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
          child: AnimatedContainer(
            duration: DsMotion.rapide,
            curve: DsMotion.courbe,
            height: hauteur,
            padding: EdgeInsets.symmetric(horizontal: paddingH),
            decoration: BoxDecoration(
              color: fond,
              borderRadius: DsRadius.borderMd,
              border: Border.all(color: _focus ? c.focus : (bordure ?? const Color(0x00000000)), width: _focus ? 2 : 1),
            ),
            child: contenu,
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      bouton = Tooltip(message: widget.tooltip!, child: bouton);
    }
    return bouton;
  }
}

/// Bouton icône carré (barre de titre, actions de ligne…).
class DsIconButton extends StatelessWidget {
  const DsIconButton({
    super.key,
    required this.icone,
    required this.tooltip,
    this.onPressed,
    this.taille = DsTailles.controleSm,
    this.couleur,
    this.couleurSurvol,
    this.actif = false,
  });

  final IconData icone;
  final String tooltip;
  final VoidCallback? onPressed;
  final double taille;
  final Color? couleur;
  final Color? couleurSurvol;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: actif ? c.primaireDoux : const Color(0x00000000),
        borderRadius: DsRadius.borderSm,
        child: InkWell(
          onTap: onPressed,
          borderRadius: DsRadius.borderSm,
          hoverColor: couleurSurvol ?? c.surfaceAttenuee,
          child: SizedBox(
            width: taille,
            height: taille,
            child: Icon(
              icone,
              size: DsTailles.icone,
              color: onPressed == null ? c.texteAttenue : (actif ? c.primaire : (couleur ?? c.texteSecondaire)),
            ),
          ),
        ),
      ),
    );
  }
}
