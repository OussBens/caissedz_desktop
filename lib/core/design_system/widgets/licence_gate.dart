import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_primitives.dart';

/// Garde de licence : affiche [child] si [autorise], sinon un écran « licence Avancé requise ».
class LicenceGate extends StatelessWidget {
  const LicenceGate({super.key, required this.autorise, required this.child, this.onActiverCle, this.compact = false});

  final bool autorise;
  final Widget child;
  final VoidCallback? onActiverCle;

  /// Variante réduite (dans un panneau) plutôt que pleine page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (autorise) return child;
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final contenu = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 40 : 64,
          height: compact ? 40 : 64,
          decoration: BoxDecoration(color: c.avertissementDoux, borderRadius: DsRadius.borderLg),
          child: Icon(LucideIcons.lock, size: compact ? 20 : 30, color: c.avertissement),
        ),
        SizedBox(height: compact ? DsSpacing.sm : DsSpacing.lg),
        Text(l10n.licenceRequise, style: compact ? t.titreSm : t.titreMd, textAlign: TextAlign.center),
        const SizedBox(height: DsSpacing.xs),
        Text(
          l10n.licenceRequiseDetail,
          style: t.corps.copyWith(color: c.texteSecondaire),
          textAlign: TextAlign.center,
        ),
        if (onActiverCle != null) ...[
          const SizedBox(height: DsSpacing.lg),
          DsButton(libelle: l10n.licenceGererCle, icone: LucideIcons.keyRound, onPressed: onActiverCle),
        ],
      ],
    );
    if (compact) return Padding(padding: const EdgeInsets.all(DsSpacing.lg), child: contenu);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: DsCard(padding: const EdgeInsets.all(DsSpacing.xxl), child: contenu),
      ),
    );
  }
}
