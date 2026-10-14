import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';

/// Menu des modules (Ctrl+M) : grille de tous les modules avec recherche.
Future<void> afficherMenuModules(BuildContext context) {
  final c = context.ds.colors;
  return showDialog<void>(
    context: context,
    barrierColor: c.overlay,
    builder: (_) => const ModulesMenuDialog(),
  );
}

class ModulesMenuDialog extends ConsumerStatefulWidget {
  const ModulesMenuDialog({super.key});

  @override
  ConsumerState<ModulesMenuDialog> createState() => _ModulesMenuDialogState();
}

class _ModulesMenuDialogState extends ConsumerState<ModulesMenuDialog> {
  String _filtre = '';

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final favoris = ref.watch(favorisProvider);
    final filtre = _filtre.trim().toLowerCase();
    final modules = Modules.tous.where((m) => filtre.isEmpty || m.libelle(l10n).toLowerCase().contains(filtre)).toList();

    String nomGroupe(GroupeModule g) => switch (g) {
          GroupeModule.general => l10n.shellNavGeneral,
          GroupeModule.stock => l10n.shellNavStock,
          GroupeModule.tiers => l10n.shellNavTiers,
          GroupeModule.gestion => l10n.shellNavGestion,
        };

    return DsDialog(
      titre: l10n.shellMenuModules,
      largeur: 760,
      icone: Icon(LucideIcons.layoutGrid, color: c.primaire),
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsTextField(
            autofocus: true,
            indice: l10n.shellMenuModulesRecherche,
            iconePrefixe: LucideIcons.search,
            onChanged: (v) => setState(() => _filtre = v),
            onSubmitted: (_) {
              if (modules.length == 1) {
                Navigator.of(context).pop();
                context.go(modules.first.route);
              }
            },
          ),
          const SizedBox(height: DsSpacing.lg),
          if (modules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DsSpacing.xl),
              child: Center(child: Text(l10n.shellMenuModulesAucun, style: t.corps.copyWith(color: c.texteAttenue))),
            )
          else
            for (final g in GroupeModule.values)
              if (modules.any((m) => m.groupe == g)) ...[
                Text(nomGroupe(g).toUpperCase(), style: t.legende.copyWith(color: c.texteAttenue)),
                const SizedBox(height: DsSpacing.sm),
                Wrap(
                  spacing: DsSpacing.sm,
                  runSpacing: DsSpacing.sm,
                  children: [
                    for (final m in modules.where((m) => m.groupe == g))
                      _TuileModule(
                        module: m,
                        favori: favoris.contains(m.id),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(m.route);
                        },
                        onFavori: () async {
                          final ok = await ref.read(favorisProvider.notifier).basculer(m.id);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shellFavorisMax)));
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: DsSpacing.lg),
              ],
        ],
      ),
    );
  }
}

class _TuileModule extends StatelessWidget {
  const _TuileModule({required this.module, required this.favori, required this.onTap, required this.onFavori});
  final ModuleApp module;
  final bool favori;
  final VoidCallback onTap;
  final VoidCallback onFavori;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 164,
      child: DsCard(
        padding: const EdgeInsets.all(DsSpacing.md),
        onTap: onTap,
        child: Row(
          children: [
            Icon(module.icone, size: DsTailles.iconeLg, color: c.primaire),
            const SizedBox(width: DsSpacing.sm),
            Expanded(child: Text(module.libelle(l10n), style: t.petitFort, maxLines: 2, overflow: TextOverflow.ellipsis)),
            DsIconButton(
              icone: favori ? LucideIcons.star : LucideIcons.star,
              tooltip: favori ? l10n.shellFavorisRetirer : l10n.shellFavorisAjouter,
              taille: 28,
              couleur: favori ? c.avertissement : c.texteAttenue,
              onPressed: onFavori,
            ),
          ],
        ),
      ),
    );
  }
}
