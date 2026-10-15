import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../application/role_service.dart';
import '../../application/utilisateur_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/stock_repository.dart';
import '../../data/utilisateur_repository.dart';
import '../../domain/models/utilisateur.dart';
import '../../domain/modules.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import '../produits/produits_providers.dart';

final utilisateurServiceProvider = Provider<UtilisateurService>(
  (ref) =>
      UtilisateurService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

final roleServiceProvider = Provider<RoleService>(
  (ref) => RoleService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Version des comptes et des rôles : incrémentée après chaque écriture.
final utilisateursVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirUtilisateurs(WidgetRef ref) => ref.read(utilisateursVersionProvider.notifier).incrementer();

/// Ligne de l'onglet Utilisateurs : compte, magasins ordonnés et ventes des 30 derniers jours.
class LigneUtilisateur {
  const LigneUtilisateur({required this.u, required this.magasins, this.nbVentes = 0, this.totalVendu = 0});
  final Utilisateur u;
  final List<String> magasins;
  final int nbVentes;
  final double totalVendu;

  /// Nom affiché : prénom + nom, sinon l'identifiant.
  String get nom => u.nomComplet.isEmpty ? u.identifiant : u.nomComplet;
}

final lignesUtilisateursProvider = FutureProvider<List<LigneUtilisateur>>((ref) async {
  ref.watch(utilisateursVersionProvider);
  final db = ref.watch(appDatabaseProvider).db;
  final repo = UtilisateurRepository(db);
  final ventes = await repo.ventesParUtilisateur(DateTime.now().subtract(const Duration(days: 30)));
  final stock = StockRepository(db);
  return [
    for (final u in await repo.tous())
      // Le compte de démonstration système n'est pas un compte gérable.
      if (!(u.systeme && u.identifiant == 'demo'))
        LigneUtilisateur(
          u: u,
          magasins: await stock.magasinsUtilisateur(u.code),
          nbVentes: ventes[u.code]?.nb ?? 0,
          totalVendu: ventes[u.code]?.total ?? 0,
        ),
  ];
});

final rolesProvider = FutureProvider<List<Role>>((ref) {
  ref.watch(utilisateursVersionProvider);
  return ref.watch(roleServiceProvider).roles();
});

/// Libellé d'une permission spéciale (§6.2).
String libellePermission(AppLocalizations l10n, Permission p) => switch (p) {
  Permission.voirPrixAchat => l10n.permVoirPrixAchat,
  Permission.voirMarge => l10n.permVoirMarge,
  Permission.modifierPrixVente => l10n.permModifierPrixVente,
  Permission.annulerOperations => l10n.permAnnulerOperations,
  Permission.changerCaisseMagasin => l10n.permChangerCaisseMagasin,
  Permission.gererTransfertsCaisse => l10n.permGererTransfertsCaisse,
  Permission.voirStockTousMagasins => l10n.permVoirStockTousMagasins,
};

IconData _iconePermission(Permission p) => switch (p) {
  Permission.voirPrixAchat => LucideIcons.eye,
  Permission.voirMarge => LucideIcons.trendingUp,
  Permission.modifierPrixVente => LucideIcons.tag,
  Permission.annulerOperations => LucideIcons.ban,
  Permission.changerCaisseMagasin => LucideIcons.repeat,
  Permission.gererTransfertsCaisse => LucideIcons.arrowLeftRight,
  Permission.voirStockTousMagasins => LucideIcons.store,
};

/// Modules attribuables à un rôle (`PermissionGrid.MODULES`) : les modules de premier niveau.
List<PermissionItem> itemsModules(AppLocalizations l10n) => [
  for (final m in Modules.tous)
    if (m.parentId == null) PermissionItem(cle: m.id, libelle: m.libelle(l10n), icone: m.icone),
];

/// Permissions spéciales (`PermissionGrid.SPECIAL`).
List<PermissionItem> itemsSpeciales(AppLocalizations l10n) => [
  for (final p in Permission.values)
    PermissionItem(cle: p.code, libelle: libellePermission(l10n, p), icone: _iconePermission(p)),
];

/// Cases cochées d'un rôle (modules + permissions) ; l'Admin a tout.
Set<String> valeursRole(Role r, AppLocalizations l10n) => r.estAdmin
    ? {...itemsModules(l10n).map((i) => i.cle), ...Permission.values.map((p) => p.code)}
    : {...r.modules, ...r.permissions.map((p) => p.code)};

/// Libellé d'un rôle : rôles du seed traduits, rôles créés tels quels.
String libelleRole(BuildContext context, String? nom) => nom == null ? '' : libelleRef(context, Referentiel.roles, nom);

String messageErreurUtilisateur(AppLocalizations l10n, ErreurUtilisateur e) => switch (e) {
  ErreurUtilisateur.utilisateurInconnu => l10n.usrErrInconnu,
  ErreurUtilisateur.identifiantInvalide => l10n.usrIdentifiantInvalide,
  ErreurUtilisateur.identifiantPris => l10n.usrIdentifiantPris,
  ErreurUtilisateur.motDePasseFaible => l10n.usrErrMotDePasse,
  ErreurUtilisateur.telephoneObligatoire => l10n.usrErrTelephone,
  ErreurUtilisateur.roleInvalide => l10n.usrErrRole,
  ErreurUtilisateur.magasinsObligatoires => l10n.usrErrMagasins,
  ErreurUtilisateur.compteAdministrateur => l10n.usrBloqueAdmin,
  ErreurUtilisateur.compteCourant => l10n.usrBloqueCourant,
  ErreurUtilisateur.dejaInactif => l10n.usrBloqueInactif,
};

String messageErreurRole(AppLocalizations l10n, ErreurRole e) => switch (e) {
  ErreurRole.roleInconnu => l10n.usrRoleErrInconnu,
  ErreurRole.nomObligatoire => l10n.usrNomRole,
  ErreurRole.nomPris => l10n.usrNomRolePris,
  ErreurRole.roleSysteme => l10n.usrRoleBloqueSysteme,
  ErreurRole.aucunModule => l10n.usrRoleErrModules,
  ErreurRole.utilisateursRattaches => l10n.usrRoleBloqueUtilisateurs,
  ErreurRole.dejaInactif => l10n.usrBloqueInactif,
};
