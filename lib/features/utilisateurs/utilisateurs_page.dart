import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/utilisateur.dart';
import '../../domain/permissions.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_page.dart';
import '../produits/produits_providers.dart';
import 'utilisateurs_dialogs.dart';
import 'utilisateurs_providers.dart';

/// Écran Utilisateurs (`UtilisateursScreen` du DS v2.2, §9.12) : onglets Utilisateurs et Rôles.
class UtilisateursPage extends ConsumerStatefulWidget {
  const UtilisateursPage({super.key, this.ongletInitial = 0});

  /// 0 = utilisateurs, 1 = rôles.
  final int ongletInitial;

  @override
  ConsumerState<UtilisateursPage> createState() => _UtilisateursPageState();
}

class _UtilisateursPageState extends ConsumerState<UtilisateursPage> {
  late int _onglet = widget.ongletInitial;
  String? _role;
  bool? _actif;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lignes = ref.watch(lignesUtilisateursProvider).value ?? const <LigneUtilisateur>[];
    final roles = ref.watch(rolesProvider).value ?? const <Role>[];
    return PageModule(
      moduleId: 'utilisateurs',
      sousTitre: l10n.usrDescription,
      onglets: [l10n.usrOngletUtilisateurs, l10n.usrOngletRoles],
      comptes: [lignes.length, roles.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0 ? _utilisateurs(l10n, lignes, roles) : _roles(l10n, roles),
    );
  }

  Widget _utilisateurs(AppLocalizations l10n, List<LigneUtilisateur> toutes, List<Role> roles) {
    final devise = ref.watch(deviseProvider);
    final caisses = {for (final c in ref.watch(caissesListeProvider).value ?? const []) c.code: c.nom};
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final lignes = toutes
        .where((l) => (_role == null || l.u.roleCode == _role) && (_actif == null || l.u.actif == _actif))
        .toList();
    final colonnes = <DsColonne<LigneUtilisateur>>[
      DsColonne(id: 'code', libelle: l10n.usrCode, valeur: (l) => l.u.code, attenue: true),
      DsColonne(
        id: 'nom',
        libelle: l10n.usrColUtilisateur,
        fort: true,
        flex: 2,
        valeur: (l) => l.nom,
        cellule: (context, l) => Row(
          spacing: 10,
          children: [
            DsAvatar(nom: l.nom, taille: 28),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.nom, overflow: TextOverflow.ellipsis),
                  Text(
                    '@${l.u.identifiant}',
                    overflow: TextOverflow.ellipsis,
                    style: context.ds.typo.caption.copyWith(color: context.ds.colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      DsColonne(
        id: 'role',
        libelle: l10n.usrRole,
        valeur: (l) => libelleRole(context, l.u.roleNom),
        cellule: (context, l) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: DsBadge(
            libelle: libelleRole(context, l.u.roleNom),
            ton: l.u.estAdmin ? DsBadgeTon.primaire : DsBadgeTon.neutre,
            icone: LucideIcons.shield,
          ),
        ),
      ),
      DsColonne(
        id: 'caisse',
        libelle: l10n.usrColCaisse,
        valeur: (l) => l.u.caisseCode == null ? '' : (caisses[l.u.caisseCode] ?? l.u.caisseCode!),
        cellule: (context, l) => l.u.caisseCode == null
            ? Text(l10n.usrLibre, style: TextStyle(color: context.ds.colors.textMuted))
            : Text(caisses[l.u.caisseCode] ?? l.u.caisseCode!),
      ),
      DsColonne(id: 'magasins', libelle: l10n.usrColMagasins, numerique: true, valeur: (l) => l.magasins.length),
      DsColonne(id: 'ventes', libelle: l10n.usrColVentes, numerique: true, valeur: (l) => l.nbVentes),
      DsColonne(
        id: 'acces',
        libelle: l10n.usrColDernierAcces,
        attenue: true,
        valeur: (l) => l.u.dernierAcces,
        cellule: (_, l) => Text(l.u.dernierAcces == null ? '—' : formatAcces.format(l.u.dernierAcces!)),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.usrEtat,
        valeur: (l) => l.u.actif ? 1 : 0,
        cellule: (_, l) => BadgeStatut(l.u.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(id: 'tel', libelle: l10n.usrTelephone, visibleParDefaut: false, valeur: (l) => l.u.telephone),
      DsColonne(
        id: 'total',
        libelle: l10n.usrKpiTotal,
        numerique: true,
        visibleParDefaut: false,
        valeur: (l) => l.totalVendu,
        cellule: (_, l) => Text(formaterMontant(l.totalVendu, devise)),
      ),
      DsColonne(
        id: 'cree_par',
        libelle: l10n.usrCreePar,
        visibleParDefaut: false,
        valeur: (l) => l.u.creePar == null ? '' : (noms[l.u.creePar] ?? l.u.creePar!),
      ),
      DsColonne(
        id: 'cree_le',
        libelle: l10n.usrCreeLe,
        visibleParDefaut: false,
        valeur: (l) => l.u.creeLe,
        cellule: (_, l) => Text(l.u.creeLe == null ? '—' : formatAcces.format(l.u.creeLe!)),
      ),
      DsColonne(
        id: 'modifie_par',
        libelle: l10n.usrModifiePar,
        visibleParDefaut: false,
        valeur: (l) => l.u.modifiePar == null ? '' : (noms[l.u.modifiePar] ?? l.u.modifiePar!),
      ),
    ];
    return DsModuleTable<LigneUtilisateur>(
      key: const ValueKey('utilisateurs'),
      entite: l10n.usrEntiteUtilisateurs,
      lignes: lignes,
      colonnes: colonnes,
      cle: (l) => l.u.code,
      permissions: permissionsSession(ref),
      messageVide: l10n.usrAucunUtilisateur,
      kpis: [
        DsStatCard(
          libelle: l10n.usrKpiActifs,
          valeur: '${toutes.where((l) => l.u.actif).length}',
          icone: LucideIcons.users,
        ),
        DsStatCard(
          libelle: l10n.usrKpiVentes,
          valeur: '${toutes.fold(0, (a, l) => a + l.nbVentes)}',
          icone: LucideIcons.receipt,
        ),
        DsStatCard(
          libelle: l10n.usrKpiTotal,
          valeur: f2(toutes.fold(0.0, (a, l) => a + l.totalVendu)),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
      ],
      indiceRecherche: l10n.usrRecherche,
      texteRecherche: (l) => '${l.nom} ${l.u.identifiant} ${l.u.telephone}',
      nbFiltresActifs: [_role, _actif].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _role = null;
        _actif = null;
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.usrRole,
          largeurLibelle: 60,
          child: DsSelect<String?>(
            cle: const ValueKey('usr_filtre_role'),
            valeur: _role,
            options: [null, for (final r in roles) r.code],
            libelle: (c) =>
                c == null ? l10n.usrTous : libelleRole(context, roles.where((r) => r.code == c).firstOrNull?.nom ?? c),
            onChanged: (v) => setState(() => _role = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.usrEtat,
          largeurLibelle: 60,
          child: DsSelect<bool?>(
            valeur: _actif,
            options: const [null, true, false],
            libelle: (a) => a == null
                ? l10n.usrTous
                : a
                ? l10n.usrActif
                : l10n.usrInactif,
            onChanged: (v) => setState(() => _actif = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: 'utilisateurs',
              titre: l10n.usrOngletUtilisateurs,
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      onOuvrir: (l) => afficherDetailUtilisateur(context, ref, l),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailUtilisateur(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('usr_modifier'),
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherFormulaireUtilisateur(context, ref, ligne: choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('usr_reinitialiser'),
          libelle: l10n.usrReinitialiser,
          icone: LucideIcons.keyRound,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => reinitialiserMotDePasse(context, ref, choix.first.u),
        ),
        DsActionModule(
          cle: const ValueKey('usr_desactiver'),
          libelle: l10n.usrDesactiver,
          icone: LucideIcons.userX,
          danger: true,
          onPressed: (choix, effacer) => desactiverUtilisateurs(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('usr_nouveau'),
        libelle: l10n.usrNouvel,
        icone: LucideIcons.userPlus,
        onPressed: () => afficherFormulaireUtilisateur(context, ref),
      ),
    );
  }

  Widget _roles(AppLocalizations l10n, List<Role> roles) {
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final nbModules = itemsModules(l10n).length;
    final colonnes = <DsColonne<Role>>[
      DsColonne(id: 'code', libelle: l10n.usrCode, valeur: (r) => r.code, attenue: true),
      DsColonne(
        id: 'nom',
        libelle: l10n.usrRole,
        fort: true,
        flex: 2,
        valeur: (r) => libelleRole(context, r.nom),
        cellule: (context, r) => Row(
          spacing: DsSpacing.s2,
          children: [
            Flexible(child: Text(libelleRole(context, r.nom), overflow: TextOverflow.ellipsis)),
            if (r.systeme) DsBadge(libelle: l10n.usrSysteme, ton: DsBadgeTon.primaire, icone: LucideIcons.lock),
          ],
        ),
      ),
      DsColonne(
        id: 'modules',
        libelle: l10n.usrColModules,
        numerique: true,
        valeur: (r) => r.estAdmin ? nbModules : r.modules.length,
        cellule: (_, r) => Text(r.estAdmin ? l10n.usrTous : '${r.modules.length}'),
      ),
      DsColonne(
        id: 'speciales',
        libelle: l10n.usrColSpeciales,
        numerique: true,
        valeur: (r) => r.estAdmin ? Permission.values.length : r.permissions.length,
        cellule: (_, r) => Text(r.estAdmin ? l10n.usrToutes : '${r.permissions.length}'),
      ),
      DsColonne(id: 'users', libelle: l10n.usrOngletUtilisateurs, numerique: true, valeur: (r) => r.nbUtilisateurs),
      DsColonne(id: 'obs', libelle: l10n.usrObservation, attenue: true, flex: 2, valeur: (r) => r.observation),
      DsColonne(
        id: 'etat',
        libelle: l10n.usrEtat,
        valeur: (r) => r.actif ? 1 : 0,
        cellule: (_, r) => BadgeStatut(r.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(
        id: 'cree_par',
        libelle: l10n.usrCreePar,
        visibleParDefaut: false,
        valeur: (r) => r.creePar == null ? '' : (noms[r.creePar] ?? r.creePar!),
      ),
      DsColonne(
        id: 'cree_le',
        libelle: l10n.usrCreeLe,
        visibleParDefaut: false,
        valeur: (r) => r.creeLe,
        cellule: (_, r) => Text(r.creeLe == null ? '—' : formatAcces.format(r.creeLe!)),
      ),
    ];
    return DsModuleTable<Role>(
      key: const ValueKey('roles'),
      entite: l10n.usrEntiteRoles,
      lignes: roles,
      colonnes: colonnes,
      cle: (r) => r.code,
      permissions: permissionsSession(ref),
      messageVide: l10n.usrAucunRole,
      texteRecherche: (r) => '${r.code} ${r.nom} ${r.observation}',
      onExport: peutExporter(ref)
          ? (format, rs) => exporterTableau(
              context,
              ref,
              id: 'roles',
              titre: l10n.usrOngletRoles,
              colonnes: colonnes,
              lignes: rs,
              format: format,
            )
          : null,
      onOuvrir: (r) => afficherDetailRole(context, ref, r),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailRole(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('roles_modifier'),
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherAssistantRole(context, ref, role: choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('roles_dupliquer'),
          libelle: l10n.usrDupliquer,
          icone: LucideIcons.copy,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherAssistantRole(context, ref, role: choix.first, dupliquer: true),
        ),
        DsActionModule(
          cle: const ValueKey('roles_desactiver'),
          libelle: l10n.usrDesactiver,
          icone: LucideIcons.circlePause,
          danger: true,
          onPressed: (choix, effacer) => desactiverRoles(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('role_nouveau'),
        libelle: l10n.usrNouveauRole,
        icone: LucideIcons.shieldPlus,
        onPressed: () => afficherAssistantRole(context, ref),
      ),
    );
  }
}
