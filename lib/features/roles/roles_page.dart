import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/permission_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';
import '../../domain/permissions.dart';

String libellePermission(AppLocalizations l10n, Permission p) => switch (p) {
      Permission.voirPrixAchat => l10n.permVoirPrixAchat,
      Permission.modifierPrix => l10n.permModifierPrix,
      Permission.appliquerRemise => l10n.permAppliquerRemise,
      Permission.annulerVente => l10n.permAnnulerVente,
      Permission.supprimerDocument => l10n.permSupprimerDocument,
      Permission.exporterDonnees => l10n.permExporterDonnees,
      Permission.gererUtilisateurs => l10n.permGererUtilisateurs,
    };

String libelleRole(AppLocalizations l10n, String role) => switch (role) {
      Roles.admin => l10n.roleAdmin,
      Roles.caissier => l10n.roleCaissier,
      Roles.magasinier => l10n.roleMagasinier,
      _ => role,
    };

/// Paramètres › Rôles et permissions (Admin, permission gererUtilisateurs).
class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key});

  static const String route = '/parametres/roles';

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  GrilleRoles? _grille;
  bool _modifiee = false;

  @override
  void initState() {
    super.initState();
    ref.read(permissionServiceProvider).lireGrille().then((g) {
      if (mounted) setState(() => _grille = g);
    });
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(permissionServiceProvider).enregistrerGrille(_grille!);
    setState(() => _modifiee = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.rolesEnregistre)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final peut = ref.watch(permissionProvider(Permission.gererUtilisateurs));
    final grille = _grille;
    final colonnes = [
      for (final r in Roles.tous)
        PermissionGridColonne(id: r, libelle: libelleRole(l10n, r), verrouillee: r == Roles.admin, infoVerrou: l10n.rolesAdminTotal),
    ];
    return ListView(
      padding: const EdgeInsets.all(DsSpacing.xl),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.rolesTitre, style: t.titreLg)),
            DsButton(libelle: l10n.communEnregistrer, icone: LucideIcons.save, onPressed: peut && _modifiee && grille != null ? _enregistrer : null),
          ],
        ),
        const SizedBox(height: DsSpacing.xs),
        Text(l10n.rolesIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
        const SizedBox(height: DsSpacing.xl),
        if (grille == null)
          Center(child: Text(l10n.communChargement, style: t.corps.copyWith(color: c.texteAttenue)))
        else ...[
          DsSectionTitre(l10n.rolesPermissions),
          PermissionGrid(
            lignes: [for (final p in Permission.values) PermissionGridLigne(id: p.code, libelle: libellePermission(l10n, p), icone: LucideIcons.shieldCheck)],
            colonnes: colonnes,
            lectureSeule: !peut,
            estCoche: (role, id) => grille.permissions[role]?.contains(Permission.parCode(id)) ?? false,
            onBasculer: (role, id) => setState(() {
              _grille = grille.basculerPermission(role, Permission.parCode(id)!);
              _modifiee = true;
            }),
          ),
          const SizedBox(height: DsSpacing.xl),
          DsSectionTitre(l10n.rolesModules),
          PermissionGrid(
            lignes: [for (final m in Modules.tous) PermissionGridLigne(id: m.id, libelle: m.libelle(l10n), icone: m.icone)],
            colonnes: colonnes,
            lectureSeule: !peut,
            estCoche: (role, id) => grille.modules[role]?.contains(id) ?? false,
            onBasculer: (role, id) => setState(() {
              _grille = grille.basculerModule(role, id);
              _modifiee = true;
            }),
          ),
        ],
      ],
    );
  }
}
