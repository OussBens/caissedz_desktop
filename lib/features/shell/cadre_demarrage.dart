import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import 'title_bar.dart';

/// Cadre commun des écrans hors shell (activation, configuration, connexion) :
/// barre de titre, fond, carte centrée, sélecteur de langue et de thème.
class CadreDemarrage extends ConsumerWidget {
  const CadreDemarrage({super.key, required this.titre, required this.child, this.largeur = 520, this.icone});

  final String titre;
  final Widget child;
  final double largeur;
  final IconData? icone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: c.fond,
      body: Column(
        children: [
          TitleBar(titre: l10n.appTitle, controlesFenetre: ref.watch(controlesFenetreProvider), minimal: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DsSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: largeur),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final l in localesSupportees) ...[
                            DsButton(
                              libelle: l.languageCode.toUpperCase(),
                              taille: DsButtonTaille.sm,
                              variante: locale == l ? DsButtonVariante.primaire : DsButtonVariante.fantome,
                              onPressed: () => ref.read(localeProvider.notifier).changer(l),
                            ),
                            const SizedBox(width: DsSpacing.xs),
                          ],
                          DsIconButton(
                            icone: mode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon,
                            tooltip: mode == ThemeMode.dark ? l10n.galerieClair : l10n.galerieSombre,
                            onPressed: () => ref.read(themeModeProvider.notifier).basculer(),
                          ),
                        ],
                      ),
                      const SizedBox(height: DsSpacing.md),
                      DsCard(
                        elevee: true,
                        padding: const EdgeInsets.all(DsSpacing.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: c.primaire, borderRadius: DsRadius.borderMd),
                                  child: Icon(icone ?? LucideIcons.store, size: 22, color: c.surPrimaire),
                                ),
                                const SizedBox(width: DsSpacing.md),
                                Expanded(child: Text(titre, style: t.titreLg)),
                              ],
                            ),
                            const SizedBox(height: DsSpacing.xl),
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
