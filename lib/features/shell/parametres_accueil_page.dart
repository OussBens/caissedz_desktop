import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/permissions.dart';
import '../activation/activation_page.dart';
import '../roles/roles_page.dart';

/// Accueil provisoire du module Paramètres (lot 8) : accès aux rôles et à la licence.
class ParametresAccueilPage extends ConsumerWidget {
  const ParametresAccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    final peutRoles = ref.watch(permissionProvider(Permission.gererUtilisateurs));
    final niveau = licence.demo ? l10n.licenceDemo : (licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic);
    Widget carte({required IconData icone, required String titre, required String detail, VoidCallback? onTap}) => SizedBox(
          width: 300,
          child: DsCard(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icone, size: DsTailles.iconeLg, color: onTap == null ? c.texteAttenue : c.primaire),
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, style: t.corpsFort.copyWith(color: onTap == null ? c.texteAttenue : c.texte)),
                      Text(detail, style: t.petit.copyWith(color: c.texteSecondaire)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: DsTailles.iconeSm, color: c.texteAttenue),
              ],
            ),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(DsSpacing.xl),
      children: [
        Text(l10n.moduleParametres, style: t.titreLg),
        const SizedBox(height: DsSpacing.lg),
        Wrap(
          spacing: DsSpacing.md,
          runSpacing: DsSpacing.md,
          children: [
            carte(
              icone: LucideIcons.shield,
              titre: l10n.parametresRolesCarte,
              detail: peutRoles ? l10n.parametresRolesCarteDetail : l10n.shellAccesRestreint,
              onTap: peutRoles ? () => context.go(RolesPage.route) : null,
            ),
            carte(
              icone: LucideIcons.keyRound,
              titre: l10n.parametresLicenceCarte,
              detail: l10n.licenceNiveau(niveau),
              onTap: () => context.push(ActivationPage.route),
            ),
          ],
        ),
      ],
    );
  }
}
