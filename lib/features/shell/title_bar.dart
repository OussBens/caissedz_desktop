import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import 'alertes_panel.dart';

/// Barre de titre personnalisée : titre, alertes, témoin Internet, boutons fenêtre.
class TitleBar extends ConsumerStatefulWidget {
  const TitleBar({super.key, required this.titre, this.controlesFenetre = true});

  final String titre;

  /// Désactivé dans les tests (pas de fenêtre native).
  final bool controlesFenetre;

  @override
  ConsumerState<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends ConsumerState<TitleBar> with WindowListener {
  bool _maximisee = false;

  @override
  void initState() {
    super.initState();
    if (widget.controlesFenetre) {
      windowManager.addListener(this);
      windowManager.isMaximized().then((v) {
        if (mounted) setState(() => _maximisee = v);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controlesFenetre) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximisee = true);
  @override
  void onWindowUnmaximize() => setState(() => _maximisee = false);

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final internet = ref.watch(internetProvider);
    final alertes = ref.watch(alertesProvider);

    Widget zoneDeplacement(Widget enfant) =>
        widget.controlesFenetre ? DragToMoveArea(child: enfant) : enfant;

    return Container(
      height: DsTailles.barreTitre,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.bordure)),
      ),
      child: Row(
        children: [
          Expanded(
            child: zoneDeplacement(
              Container(
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.only(start: DsSpacing.lg),
                child: Text(widget.titre, style: t.titreSm, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          // Témoin Internet
          Tooltip(
            message: internet ? l10n.shellInternetConnecte : l10n.shellInternetDeconnecte,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    internet ? LucideIcons.wifi : LucideIcons.wifiOff,
                    key: ValueKey('internet_${internet ? 'on' : 'off'}'),
                    size: DsTailles.iconeSm,
                    color: internet ? c.succes : c.texteAttenue,
                  ),
                  const SizedBox(width: DsSpacing.xs),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: internet ? c.succes : c.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Alertes
          Stack(
            clipBehavior: Clip.none,
            children: [
              DsIconButton(
                icone: LucideIcons.bell,
                tooltip: l10n.shellAlertes,
                onPressed: () => afficherPanneauAlertes(context),
              ),
              if (alertes.isNotEmpty)
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: IgnorePointer(
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(minWidth: 14),
                    decoration: BoxDecoration(
                      color: alertes.any((a) => a.critique) ? c.danger : c.avertissement,
                      borderRadius: BorderRadius.circular(DsRadius.pill),
                    ),
                    child: Text(
                      '${alertes.length}',
                      textAlign: TextAlign.center,
                      style: t.legende.copyWith(color: c.texteInverse, fontSize: 9, height: 1.4),
                    ),
                  ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: DsSpacing.sm),
          if (widget.controlesFenetre) ...[
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
        ],
      ),
    );
  }
}

class _BoutonFenetre extends StatelessWidget {
  const _BoutonFenetre({
    required this.icone,
    required this.tooltip,
    required this.onPressed,
    this.fermeture = false,
  });
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
        hoverColor: fermeture ? c.danger : c.surfaceAttenuee,
        child: SizedBox(
          width: 46,
          height: DsTailles.barreTitre,
          child: Icon(icone, size: DsTailles.iconeSm, color: c.texteSecondaire),
        ),
      ),
    );
  }
}
