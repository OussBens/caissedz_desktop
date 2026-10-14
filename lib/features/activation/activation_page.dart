import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/licence_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/permissions.dart';
import '../shell/cadre_demarrage.dart';

/// Écran d'activation : clé SHA-256 (64 caractères) liée à la machine, ou mode démo.
class ActivationPage extends ConsumerStatefulWidget {
  const ActivationPage({super.key});

  static const String route = '/activation';

  @override
  ConsumerState<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends ConsumerState<ActivationPage> {
  final _cle = TextEditingController();
  String? _erreur;
  String _machine = '';

  @override
  void initState() {
    super.initState();
    ref.read(licenceServiceProvider).identifiantMachine().then((v) {
      if (mounted) setState(() => _machine = v);
    });
  }

  @override
  void dispose() {
    _cle.dispose();
    super.dispose();
  }

  Future<void> _activer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _erreur = null);
    try {
      final licence = await ref.read(licenceProvider.notifier).activer(_cle.text);
      if (!mounted) return;
      final niveau = licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic;
      unawaited(afficherResultat(context, type: DsResultatType.succes, titre: l10n.activationTitre, message: l10n.activationReussie(niveau)));
    } on ActivationException catch (e) {
      setState(() => _erreur = e.erreur == ErreurActivation.formatInvalide ? l10n.activationErreurFormat : l10n.activationErreurInconnue);
    }
  }

  Future<void> _demo() async {
    await ref.read(licenceProvider.notifier).activerDemo();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    return CadreDemarrage(
      titre: l10n.activationTitre,
      icone: LucideIcons.keyRound,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.activationIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.lg),
          Text(l10n.activationIdentifiantMachine, style: t.petitFort.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
            decoration: BoxDecoration(color: c.surfaceAttenuee, borderRadius: DsRadius.borderMd, border: Border.all(color: c.bordure)),
            child: Row(
              children: [
                Expanded(child: SelectableText(_machine, style: t.mono)),
                DsIconButton(
                  icone: LucideIcons.copy,
                  tooltip: l10n.activationCopierIdentifiant,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _machine));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.activationIdentifiantCopie)));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.lg),
          DsTextField(
            controller: _cle,
            libelle: l10n.activationCle,
            indice: l10n.activationCleIndice,
            iconePrefixe: LucideIcons.keyRound,
            erreur: _erreur,
            autofocus: true,
            onSubmitted: (_) => _activer(),
          ),
          const SizedBox(height: DsSpacing.lg),
          DsButton(libelle: l10n.activationBouton, icone: LucideIcons.check, taille: DsButtonTaille.lg, pleineLargeur: true, onPressed: _activer),
          const SizedBox(height: DsSpacing.xl),
          const DsDivider(),
          const SizedBox(height: DsSpacing.lg),
          Text(l10n.activationDemoAide, style: t.petit.copyWith(color: c.texteAttenue)),
          const SizedBox(height: DsSpacing.sm),
          DsButton(
            libelle: l10n.activationDemo,
            icone: LucideIcons.play,
            variante: DsButtonVariante.secondaire,
            pleineLargeur: true,
            onPressed: licence.estActivee && !licence.demo ? null : _demo,
          ),
          if (licence.estActivee) ...[
            const SizedBox(height: DsSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DsBadge(
                libelle: licence.demo ? l10n.licenceDemo : l10n.licenceNiveau(licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic),
                ton: licence.demo ? DsBadgeTon.avertissement : DsBadgeTon.succes,
                icone: LucideIcons.badgeCheck,
              ),
            ),
            const SizedBox(height: DsSpacing.sm),
            DsButton(libelle: l10n.communFermer, variante: DsButtonVariante.fantome, onPressed: () => context.canPop() ? context.pop() : context.go('/tableau-de-bord')),
          ],
        ],
      ),
    );
  }
}
