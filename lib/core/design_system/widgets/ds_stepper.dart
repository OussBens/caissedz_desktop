import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';

/// Indicateur d'étapes horizontal (`Stepper`) : pastilles 28 px (sm 24), faites = primaire + coche,
/// courante = primaire + anneau teinté, à venir = carte + bordure forte ; connecteurs 2 px.
class DsStepper extends StatelessWidget {
  const DsStepper({super.key, required this.etapes, required this.courante, this.onEtape, this.petit = false});

  final List<String> etapes;

  /// Index de l'étape courante (à partir de 0).
  final int courante;

  /// Clic sur une étape déjà faite.
  final ValueChanged<int>? onEtape;
  final bool petit;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final d = petit ? 24.0 : 28.0;
    if (etapes.isEmpty) return Text('—', style: t.caption.copyWith(color: c.textMuted));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, e) in etapes.indexed)
          Expanded(
            flex: i == etapes.length - 1 ? 1 : 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _Etape(
                    numero: i + 1,
                    libelle: e,
                    faite: i < courante,
                    courante: i == courante,
                    diametre: d,
                    petit: petit,
                    onTap: onEtape != null && i < courante ? () => onEtape!(i) : null,
                  ),
                ),
                if (i < etapes.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      constraints: const BoxConstraints(minWidth: 12),
                      margin: EdgeInsets.fromLTRB(8, d / 2 - 1, 8, 0),
                      decoration: BoxDecoration(
                        color: i < courante ? c.primary : c.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Etape extends StatelessWidget {
  const _Etape({
    required this.numero,
    required this.libelle,
    required this.faite,
    required this.courante,
    required this.diametre,
    required this.petit,
    this.onTap,
  });
  final int numero;
  final String libelle;
  final bool faite;
  final bool courante;
  final double diametre;
  final bool petit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final aVenir = !faite && !courante;
    final contenu = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        AnimatedContainer(
          duration: DsMotion.base,
          curve: DsMotion.standard,
          width: diametre,
          height: diametre,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: aVenir ? c.surfaceCard : c.primary,
            border: Border.all(color: aVenir ? c.borderStrong : c.primary, width: 1.5),
            boxShadow: courante ? [BoxShadow(color: c.primaryTint, spreadRadius: 4)] : null,
          ),
          child: faite
              ? Icon(LucideIcons.check, size: petit ? 13 : 15, color: c.primaryFg)
              : Text(
                  '$numero',
                  style: t.bodySm.copyWith(
                    fontSize: petit ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: aVenir ? c.textMuted : c.primaryFg,
                    fontFeatures: DsTypography.tabular,
                  ),
                ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                libelle,
                style: t.bodySm.copyWith(
                  fontSize: petit ? 12.5 : 13.5,
                  fontWeight: courante ? FontWeight.w600 : FontWeight.w500,
                  height: 1.3,
                  color: aVenir ? c.textMuted : c.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
    if (onTap == null) return Tooltip(message: libelle, child: contenu);
    return Tooltip(
      message: libelle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: contenu),
      ),
    );
  }
}
