import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';

/// Zone de déplacement de la fenêtre (barre de titre masquée) ; neutre dans les tests.
class ZoneDeplacement extends ConsumerWidget {
  const ZoneDeplacement({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(controlesFenetreProvider) ? DragToMoveArea(child: child) : child;
}

/// Boutons réduire / agrandir / fermer de la fenêtre (§5.2) ; absents dans les tests.
class ControlesFenetre extends ConsumerStatefulWidget {
  const ControlesFenetre({super.key});

  @override
  ConsumerState<ControlesFenetre> createState() => _ControlesFenetreState();
}

class _ControlesFenetreState extends ConsumerState<ControlesFenetre> with WindowListener {
  bool _maximisee = false;
  late final bool _actifs = ref.read(controlesFenetreProvider);

  @override
  void initState() {
    super.initState();
    if (_actifs) {
      windowManager.addListener(this);
      windowManager.isMaximized().then((v) {
        if (mounted) setState(() => _maximisee = v);
      });
    }
  }

  @override
  void dispose() {
    if (_actifs) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximisee = true);
  @override
  void onWindowUnmaximize() => setState(() => _maximisee = false);

  @override
  Widget build(BuildContext context) {
    if (!_actifs) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BoutonFenetre(
          icone: LucideIcons.minus,
          tooltip: l10n.shellFenetreReduire,
          onPressed: () => windowManager.minimize(),
        ),
        _BoutonFenetre(
          icone: _maximisee ? LucideIcons.copy : LucideIcons.square,
          tooltip: _maximisee ? l10n.shellFenetreRestaurer : l10n.shellFenetreAgrandir,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        _BoutonFenetre(
          icone: LucideIcons.x,
          tooltip: l10n.shellFenetreFermer,
          fermeture: true,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _BoutonFenetre extends StatelessWidget {
  const _BoutonFenetre({required this.icone, required this.tooltip, required this.onPressed, this.fermeture = false});
  final IconData icone;
  final String tooltip;
  final VoidCallback onPressed;
  final bool fermeture;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        hoverColor: fermeture ? c.danger : c.surfaceHover,
        child: SizedBox(
          width: 46,
          height: DsTailles.barreTitre,
          child: Icon(icone, size: DsTailles.iconeSm, color: c.iconDefault),
        ),
      ),
    );
  }
}

/// Bandeau supérieur des écrans hors shell (connexion, activation) : déplacement + boutons de fenêtre.
class BandeauFenetre extends ConsumerWidget {
  const BandeauFenetre({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(controlesFenetreProvider)) return const SizedBox.shrink();
    return const SizedBox(
      height: DsTailles.barreTitre,
      child: Row(
        children: [
          Expanded(child: ZoneDeplacement(child: SizedBox.expand())),
          ControlesFenetre(),
        ],
      ),
    );
  }
}
