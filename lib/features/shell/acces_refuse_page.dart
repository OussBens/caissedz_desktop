import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';

/// Écran « Accès refusé » : le rôle de l'utilisateur n'a pas accès au module.
class AccesRefusePage extends StatelessWidget {
  const AccesRefusePage({super.key, required this.role, required this.module});

  final String role;
  final String module;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: DsCard(
          padding: const EdgeInsets.all(DsSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: c.dangerDoux, borderRadius: DsRadius.borderLg),
                child: Icon(LucideIcons.shieldOff, size: 30, color: c.danger),
              ),
              const SizedBox(height: DsSpacing.lg),
              Text(l10n.accesRefuseTitre, style: t.titreMd),
              const SizedBox(height: DsSpacing.xs),
              Text(l10n.accesRefuseMessage(role, module), style: t.corps.copyWith(color: c.texteSecondaire), textAlign: TextAlign.center),
              const SizedBox(height: DsSpacing.lg),
              DsButton(libelle: l10n.accesRefuseRetour, icone: LucideIcons.layoutDashboard, variante: DsButtonVariante.secondaire, onPressed: () => context.go('/tableau-de-bord')),
            ],
          ),
        ),
      ),
    );
  }
}
