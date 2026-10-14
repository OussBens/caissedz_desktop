import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';

Future<void> afficherPanneauAlertes(BuildContext context) {
  final c = context.ds.colors;
  return showDialog<void>(context: context, barrierColor: c.overlay, builder: (_) => const _AlertesDialog());
}

class _AlertesDialog extends ConsumerWidget {
  const _AlertesDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final alertes = ref.watch(alertesProvider);
    return DsDialog(
      titre: l10n.shellAlertes,
      icone: Icon(LucideIcons.bell, color: c.primaire),
      contenu: alertes.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: DsSpacing.xl),
              child: Center(
                child: Text(l10n.shellAlertesAucune, style: t.corps.copyWith(color: c.texteAttenue)),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final a in alertes)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      a.critique ? LucideIcons.triangleAlert : LucideIcons.info,
                      color: a.critique ? c.danger : c.avertissement,
                      size: DsTailles.icone,
                    ),
                    title: Text(a.titre, style: t.corpsFort),
                    subtitle: a.detail == null
                        ? null
                        : Text(a.detail!, style: t.petit.copyWith(color: c.texteSecondaire)),
                    trailing: DsIconButton(
                      icone: LucideIcons.x,
                      tooltip: l10n.communFermer,
                      onPressed: () => ref.read(alertesProvider.notifier).retirer(a.id),
                    ),
                    onTap: a.route == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            context.go(a.route!);
                          },
                  ),
              ],
            ),
    );
  }
}
