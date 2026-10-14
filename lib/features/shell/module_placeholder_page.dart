import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';

/// Page provisoire d'un module non encore livré.
class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({super.key, required this.module});

  final ModuleApp module;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final nom = module.libelle(l10n);
    return Padding(
      padding: const EdgeInsets.all(DsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nom, style: t.titreLg),
          const SizedBox(height: DsSpacing.lg),
          DsCard(
            child: Row(
              children: [
                Icon(module.icone, size: 32, color: c.texteAttenue),
                const SizedBox(width: DsSpacing.lg),
                Expanded(
                  child: Text(l10n.modulePlaceholder(nom), style: t.corps.copyWith(color: c.texteSecondaire)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
