import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/referentiel/referentiel.dart';
import '../compte/mon_compte_page.dart';
import 'alertes_panel.dart';

/// Barre de titre personnalisée : titre, alertes, témoin Internet, boutons fenêtre.
class TitleBar extends ConsumerStatefulWidget {
  const TitleBar({super.key, required this.titre, this.controlesFenetre = true, this.minimal = false});

  final String titre;

  /// Écrans hors shell : sans alertes ni menu utilisateur.
  final bool minimal;

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
    final session = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);

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
          if (!widget.minimal)
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
          // Menu utilisateur
          if (!widget.minimal && session != null)
            PopupMenuButton<String>(
              tooltip: l10n.shellMenuUtilisateur,
              offset: const Offset(0, DsTailles.barreTitre),
              onSelected: (v) {
                if (v == 'compte') context.go(MonComptePage.route);
                if (v == 'deconnexion') ref.read(sessionProvider.notifier).deconnecter();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'compte', height: 36, child: Row(children: [Icon(LucideIcons.userCog, size: DsTailles.iconeSm, color: c.texteSecondaire), const SizedBox(width: DsSpacing.sm), Text(l10n.compteTitre, style: t.corps)])),
                PopupMenuItem(value: 'deconnexion', height: 36, child: Row(children: [Icon(LucideIcons.logOut, size: DsTailles.iconeSm, color: c.danger), const SizedBox(width: DsSpacing.sm), Text(l10n.connexionDeconnecter, style: t.corps.copyWith(color: c.danger))])),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: c.primaireDoux, child: Text(session.utilisateur.nom.isEmpty ? '?' : session.utilisateur.nom[0].toUpperCase(), style: t.legende.copyWith(color: c.primaire))),
                    const SizedBox(width: DsSpacing.sm),
                    Text(session.utilisateur.nom, style: t.petitFort),
                    const SizedBox(width: DsSpacing.xs),
                    Text('· ${Referentiel.roles.libelle(session.utilisateur.role, locale)}', style: t.petit.copyWith(color: c.texteAttenue)),
                    const SizedBox(width: DsSpacing.xs),
                    Icon(LucideIcons.chevronDown, size: 14, color: c.texteAttenue),
                  ],
                ),
              ),
            ),
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
