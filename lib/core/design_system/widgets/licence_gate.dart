import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Genres du [LicenceGate] (`LicenseGate.kind`).
enum DsGateGenre { licence, role, refuse, activation }

/// Garde d'accès (`LicenseGate`) : affiche [child] si [autorise], sinon un panneau en pointillés
/// (icône 56 px, titre 700 17, description, liste de fonctionnalités, action).
///
/// - `licence` : palier Avancé requis (tuile dégradée « nuit », icône étincelles).
/// - `role` : accès non autorisé par le rôle.
/// - `refuse` : accès refusé (écran plein module).
/// - `activation` : application non activée.
class LicenceGate extends StatelessWidget {
  const LicenceGate({
    super.key,
    required this.autorise,
    required this.child,
    this.onActiverCle,
    this.compact = false,
    this.genre = DsGateGenre.licence,
    this.titre,
    this.description,
    this.fonctionnalites = const [],
    this.libelleAction,
    this.onAction,
    this.secondaire,
  });

  final bool autorise;
  final Widget child;

  /// Compat lots 0 à 9 : action principale du genre `licence`.
  final VoidCallback? onActiverCle;

  /// Variante réduite en ligne (dans un panneau) plutôt que centrée.
  final bool compact;
  final DsGateGenre genre;
  final String? titre;
  final String? description;
  final List<String> fonctionnalites;
  final String? libelleAction;
  final VoidCallback? onAction;
  final Widget? secondaire;

  @override
  Widget build(BuildContext context) {
    if (autorise) return child;
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final (icone, titreDefaut, actionDefaut) = switch (genre) {
      DsGateGenre.licence => (LucideIcons.sparkles, l10n.dsGateLicenceTitre, l10n.dsGateLicenceAction),
      DsGateGenre.role => (LucideIcons.shieldOff, l10n.dsGateRoleTitre, l10n.dsGateRoleAction),
      DsGateGenre.refuse => (LucideIcons.shieldX, l10n.dsGateRefuseTitre, l10n.dsGateRefuseAction),
      DsGateGenre.activation => (LucideIcons.keyRound, l10n.dsGateActivationTitre, l10n.dsGateActivationAction),
    };
    final action = onAction ?? onActiverCle;
    final desc = description ?? (genre == DsGateGenre.licence ? l10n.licenceRequiseDetail : null);
    final licence = genre == DsGateGenre.licence;

    final tuile = Container(
      width: compact ? 40 : 56,
      height: compact ? 40 : 56,
      decoration: BoxDecoration(
        gradient: licence ? DsColors.gradientNight : null,
        color: licence ? null : c.surfaceCard,
        borderRadius: BorderRadius.circular(compact ? 10 : 16),
        border: licence ? null : Border.all(color: c.borderDefault),
      ),
      child: Icon(icone, size: compact ? 20 : 26, color: licence ? DsColors.blanc : c.iconDefault),
    );
    final textes = Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          titre ?? titreDefaut,
          style: t.heading.copyWith(fontSize: compact ? 14 : 17, fontWeight: FontWeight.w700, height: 1.3),
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
        if (desc != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              desc,
              style: t.bodySm.copyWith(color: c.textSecondary),
              textAlign: compact ? TextAlign.start : TextAlign.center,
            ),
          ),
        if (!compact && fonctionnalites.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                for (final f in fonctionnalites)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Icon(LucideIcons.check, size: 14, color: c.success),
                      Text(f, style: t.label.copyWith(color: c.textBody)),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
    final boutons = (action != null || secondaire != null)
        ? Padding(
            padding: EdgeInsets.only(top: compact ? 0 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DsSpacing.s2,
              children: [
                ?secondaire,
                if (action != null)
                  DsButton(
                    libelle: libelleAction ?? actionDefaut,
                    icone: licence ? LucideIcons.sparkles : null,
                    onPressed: action,
                  ),
              ],
            ),
          )
        : null;

    final panneau = Container(
      padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: DsRadius.borderXl,
        border: Border.all(color: c.borderStrong),
      ),
      child: compact
          ? Row(
              spacing: 14,
              children: [
                tuile,
                Expanded(child: textes),
                ?boutons,
              ],
            )
          : Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [tuile, textes, ?boutons]),
    );
    if (compact) return panneau;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.s6),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: panneau),
      ),
    );
  }
}
