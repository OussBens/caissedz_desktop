import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/raccourcis_caisse.dart';
import '../caisse/pos_dialogs.dart';

/// Paramètres › Raccourcis clavier : une touche par action de caisse, modifiable par l'administrateur seulement.
/// Une touche déjà prise par une autre action ne peut pas être doublée (on l'échange ou on en choisit une autre).
class CarteRaccourcisCaisse extends StatelessWidget {
  const CarteRaccourcisCaisse({super.key, required this.valeur, required this.onChanged, required this.modifiable});

  final RaccourcisCaisse valeur;
  final ValueChanged<RaccourcisCaisse> onChanged;
  final bool modifiable;

  Future<void> _changer(BuildContext context, ActionCaisse a) async {
    final nouveau = await afficherDialog<RaccourcisCaisse>(
      context,
      builder: (_) => _CaptureRaccourciDialog(action: a, raccourcis: valeur),
    );
    if (nouveau != null && nouveau != valeur) onChanged(nouveau);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    return DsCard(
      titre: l10n.pmRaccourcisTitre,
      icone: LucideIcons.keyboard,
      info: l10n.pmRaccourcisInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          if (!modifiable)
            Text(
              l10n.pmRaccourcisAdminSeul,
              key: const ValueKey('param_raccourcis_lecture'),
              style: t.bodySm.copyWith(color: c.warningFg),
            ),
          LayoutBuilder(
            builder: (context, contraintes) {
              final deux = contraintes.maxWidth >= 760;
              final largeur = deux ? (contraintes.maxWidth - DsSpacing.s6) / 2 : contraintes.maxWidth;
              return Wrap(
                spacing: DsSpacing.s6,
                children: [
                  for (final a in ActionCaisse.values) SizedBox(width: largeur, child: _ligne(context, l10n, a)),
                ],
              );
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DsButton(
              key: const ValueKey('param_raccourcis_defaut'),
              libelle: l10n.pmRaccourcisDefaut,
              icone: LucideIcons.rotateCcw,
              variante: DsButtonVariante.secondaire,
              taille: DsButtonTaille.sm,
              onPressed: modifiable && valeur != RaccourcisCaisse.defaut
                  ? () => onChanged(RaccourcisCaisse.defaut)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ligne(BuildContext context, AppLocalizations l10n, ActionCaisse a) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final defaut = RaccourcisCaisse.touchesDefaut[a]!;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.s1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          Expanded(
            child: Text(libelleActionCaisse(l10n, a), style: t.body.copyWith(color: c.textPrimary)),
          ),
          if (modifiable && !valeur.estDefaut(a))
            DsIconButton(
              key: ValueKey('param_raccourci_defaut_${a.name}'),
              icone: LucideIcons.rotateCcw,
              tooltip: l10n.pmRaccourciRetablir(defaut.libelle),
              taille: DsTailles.controleSm,
              onPressed: () => unawaited(_retablir(context, a, defaut)),
            ),
          SizedBox(
            width: 128,
            child: DsButton(
              key: ValueKey('param_raccourci_${a.name}'),
              libelle: valeur.libelle(a),
              icone: LucideIcons.keyboard,
              tooltip: modifiable ? l10n.pmRaccourciChanger : null,
              variante: DsButtonVariante.secondaire,
              taille: DsButtonTaille.sm,
              pleineLargeur: true,
              onPressed: modifiable ? () => _changer(context, a) : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Touche par défaut : si une autre action l'utilise, le dialog de capture propose l'échange.
  Future<void> _retablir(BuildContext context, ActionCaisse a, ToucheRaccourci defaut) async {
    if (valeur.utiliseePar(defaut, sauf: a) == null) {
      onChanged(valeur.avec(a, defaut));
      return;
    }
    final nouveau = await afficherDialog<RaccourcisCaisse>(
      context,
      builder: (_) => _CaptureRaccourciDialog(action: a, raccourcis: valeur, proposee: defaut),
    );
    if (nouveau != null && nouveau != valeur) onChanged(nouveau);
  }
}

/// Saisie d'une touche : la combinaison pressée s'affiche ; refusée si réservée, et si elle sert déjà à une autre
/// action, on peut échanger les deux touches (chaque touche reste unique).
class _CaptureRaccourciDialog extends StatefulWidget {
  const _CaptureRaccourciDialog({required this.action, required this.raccourcis, this.proposee});

  final ActionCaisse action;
  final RaccourcisCaisse raccourcis;
  final ToucheRaccourci? proposee;

  @override
  State<_CaptureRaccourciDialog> createState() => _CaptureRaccourciDialogState();
}

class _CaptureRaccourciDialogState extends State<_CaptureRaccourciDialog> {
  final _focus = FocusNode(debugLabel: 'capture_raccourci');
  late ToucheRaccourci? _touche = widget.proposee;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _capturer(FocusNode _, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.handled;
    final k = e.logicalKey;
    // Échap ferme le dialog ; Ctrl, Maj, Alt seuls attendent la touche qui les accompagne.
    if (k == LogicalKeyboardKey.escape) return KeyEventResult.ignored;
    if (ToucheRaccourci.estModificateur(k)) return KeyEventResult.handled;
    final clavier = HardwareKeyboard.instance;
    setState(
      () => _touche = ToucheRaccourci(
        k,
        ctrl: clavier.isControlPressed,
        shift: clavier.isShiftPressed,
        alt: clavier.isAltPressed,
      ),
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final touche = _touche;
    final interdite = touche?.estInterdite ?? false;
    final autre = touche == null || interdite ? null : widget.raccourcis.utiliseePar(touche, sauf: widget.action);
    final inchangee = touche != null && touche == widget.raccourcis.touche(widget.action);
    final String? erreur = interdite
        ? l10n.pmRaccourciInterdit
        : autre != null
        ? l10n.pmRaccourciDejaUtilise(libelleActionCaisse(l10n, autre))
        : null;
    final valide = touche != null && !interdite && !inchangee;
    return DsDialog(
      titre: libelleActionCaisse(l10n, widget.action),
      iconeData: LucideIcons.keyboard,
      largeur: 460,
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          Text(l10n.pmRaccourciCapture, style: t.body.copyWith(color: c.textSecondary)),
          Focus(
            focusNode: _focus,
            autofocus: true,
            onKeyEvent: _capturer,
            child: GestureDetector(
              onTap: _focus.requestFocus,
              child: ListenableBuilder(
                listenable: _focus,
                builder: (context, _) => Container(
                  key: const ValueKey('capture_raccourci'),
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.surfaceSunken,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(
                      color: erreur != null
                          ? c.dangerFg
                          : _focus.hasFocus
                          ? c.primary
                          : c.borderDefault,
                      width: _focus.hasFocus ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    touche?.libelle ?? l10n.pmRaccourciAttente,
                    key: const ValueKey('capture_raccourci_touche'),
                    style: touche == null
                        ? t.body.copyWith(color: c.textMuted)
                        : t.heading.copyWith(color: c.textPrimary, fontFeatures: DsTypography.tabular),
                  ),
                ),
              ),
            ),
          ),
          if (erreur != null)
            Text(
              erreur,
              key: const ValueKey('capture_raccourci_erreur'),
              style: t.bodySm.copyWith(color: c.dangerFg),
            )
          else if (touche != null && touche.estAlphanumerique)
            Text(l10n.pmRaccourciLettres, style: t.bodySm.copyWith(color: c.textMuted)),
        ],
      ),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (autre != null)
          DsButton(
            key: const ValueKey('capture_raccourci_echanger'),
            libelle: l10n.pmRaccourciEchanger,
            icone: LucideIcons.arrowLeftRight,
            onPressed: () => Navigator.of(
              context,
            ).pop(widget.raccourcis.avec(autre, widget.raccourcis.touche(widget.action)).avec(widget.action, touche!)),
          )
        else
          DsButton(
            key: const ValueKey('capture_raccourci_valider'),
            libelle: l10n.communValider,
            icone: LucideIcons.check,
            onPressed: valide ? () => Navigator.of(context).pop(widget.raccourcis.avec(widget.action, touche)) : null,
          ),
      ],
    );
  }
}
