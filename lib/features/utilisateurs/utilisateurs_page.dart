import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/archivage.dart';
import '../../domain/models/audit.dart';
import '../../domain/models/utilisateur.dart';
import '../../domain/permissions.dart';
import '../commun/archives.dart';
import '../commun/carte_entite.dart';
import '../commun/chargement.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
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
  bool _archivesUtilisateurs = false;
  bool _archivesRoles = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lignes = ref.watch(lignesUtilisateursProvider).value ?? const <LigneUtilisateur>[];
    final roles = ref.watch(rolesProvider).value ?? const <Role>[];
    final nbLignes = lignes.where((l) => !l.u.archive).length;
    final nbRoles = roles.where((r) => !r.archive).length;
    return PageModule(
      moduleId: 'utilisateurs',
      onglets: [l10n.usrOngletUtilisateurs, l10n.usrOngletRoles],
      comptes: [nbLignes, nbRoles],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0 ? _utilisateurs(l10n, lignes, roles) : _roles(l10n, roles),
    );
  }

  Widget _utilisateurs(AppLocalizations l10n, List<LigneUtilisateur> tous, List<Role> tousRoles) {
    final devise = ref.watch(deviseProvider);
    final caisses = {for (final c in ref.watch(caissesListeProvider).value ?? const []) c.code: c.nom};
    // Caisses du compte, la première (par défaut) d'abord ; l'Admin les a toutes.
    String nomCaisses(LigneUtilisateur l) =>
        l.u.estAdmin ? l10n.usrToutesCaisses : [for (final c in l.caisses) caisses[c] ?? c].join(', ');
    // Les comptes archivés restent lus (auteurs des anciennes opérations) mais quittent la liste de gestion.
    final toutes = [
      for (final l in tous)
        if (!l.u.archive) l,
    ];
    final archives = [
      for (final l in tous)
        if (l.u.archive) l,
    ];
    final roles = [
      for (final r in tousRoles)
        if (!r.archive) r,
    ];
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
        libelle: l10n.usrColCaisses,
        valeur: nomCaisses,
        cellule: (context, l) => l.u.estAdmin
            ? Text(l10n.usrToutesCaisses, style: TextStyle(color: context.ds.colors.textMuted))
            : Text(nomCaisses(l), overflow: TextOverflow.ellipsis),
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
      ...colonnesAudit(
        context,
        ref,
        (LigneUtilisateur x) =>
            Audit(creeLe: x.u.creeLe, creePar: x.u.creePar, modifieLe: x.u.modifieLe, modifiePar: x.u.modifiePar),
      ),
    ];
    void basculer(bool v) => setState(() => _archivesUtilisateurs = v);
    if (_archivesUtilisateurs) {
      return tableArchives<LigneUtilisateur>(
        context,
        ref,
        key: const ValueKey('utilisateurs_archives'),
        entite: l10n.usrEntiteUtilisateurs,
        lignes: archives,
        colonnes: colonnes,
        cle: (l) => l.u.code,
        texteRecherche: (l) => '${l.nom} ${l.u.identifiant} ${l.u.telephone}',
        archiveLe: (l) => l.u.archiveLe,
        archivePar: (l) => l.u.archivePar,
        onDetail: (l) => afficherDetailUtilisateur(context, ref, l),
        onRestaurer: (choix, effacer) => restaurerArchives(
          context,
          ref,
          entite: EntiteArchivable.utilisateur,
          choix: choix,
          code: (l) => l.u.code,
          titre: (l) => l.nom,
          libelleEntite: l10n.usrEntiteUtilisateur,
          libelleEntites: l10n.usrEntiteUtilisateurs,
          effacer: effacer,
          rafraichir: () => rafraichirUtilisateurs(ref),
        ),
        bouton: boutonArchives(l10n, archives: true, nombre: archives.length, onChanged: basculer),
      );
    }
    // Rôles qui ouvrent l'application mobile (raccourci « Accès mobile »).
    final rolesMobile = {
      for (final r in tousRoles)
        if (r.aPermission(Permission.utiliserMobile)) r.code,
    };
    return DsModuleTable<LigneUtilisateur>(
      key: const ValueKey('utilisateurs'),
      entite: l10n.usrEntiteUtilisateurs,
      lignes: lignes,
      raccourcis: [
        DsRaccourci(id: 'actifs', libelle: l10n.racActifs, icone: LucideIcons.circleCheck, filtre: (l) => l.u.actif),
        DsRaccourci(
          id: 'desactives',
          libelle: l10n.racDesactives,
          icone: LucideIcons.circleOff,
          filtre: (l) => !l.u.actif,
        ),
        DsRaccourci(
          id: 'admins',
          libelle: l10n.racAdministrateurs,
          icone: LucideIcons.shieldCheck,
          filtre: (l) => l.u.estAdmin,
        ),
        DsRaccourci(
          id: 'jamais',
          libelle: l10n.racJamaisConnectes,
          icone: LucideIcons.userX,
          filtre: (l) => l.u.dernierAcces == null,
        ),
        DsRaccourci(
          id: 'absents',
          libelle: l10n.racAbsents30,
          icone: LucideIcons.moon,
          filtre: (l) => l.u.actif && l.u.dernierAcces != null && sansDepuis(l.u.dernierAcces, 30),
        ),
        DsRaccourci(
          id: 'mobile',
          libelle: l10n.racAccesMobile,
          icone: LucideIcons.smartphone,
          filtre: (l) => l.u.actif && rolesMobile.contains(l.u.roleCode),
        ),
      ],
      chargement: enChargement(ref.watch(lignesUtilisateursProvider)),
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
      carte: (context, l, etatCarte) => CarteEntite(
        etat: etatCarte,
        titre: l.nom,
        sousTitre: '@${l.u.identifiant} · ${libelleRole(context, l.u.roleNom)}',
        icone: LucideIcons.user,
        statut: l.u.actif ? 'actif' : 'inactif',
        montant: formaterMontant(l.totalVendu, devise),
        libelleMontant: l10n.usrColVentes,
        lignes: [
          (LucideIcons.monitor, nomCaisses(l)),
          (LucideIcons.clock, l.u.dernierAcces == null ? '—' : formatAcces.format(l.u.dernierAcces!)),
        ],
      ),
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
          iconeSeule: true,
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
        DsActionModule(
          cle: const ValueKey('usr_supprimer'),
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerOuArchiver(
            context,
            ref,
            entite: EntiteArchivable.utilisateur,
            choix: choix,
            code: (l) => l.u.code,
            titre: (l) => l.nom,
            libelleEntite: l10n.usrEntiteUtilisateur,
            libelleEntites: l10n.usrEntiteUtilisateurs,
            effacer: effacer,
            rafraichir: () => rafraichirUtilisateurs(ref),
          ),
        ),
      ],
      secondaire: boutonArchives(
        l10n,
        cle: const ValueKey('usr_archives_bouton'),
        archives: false,
        nombre: archives.length,
        onChanged: basculer,
      ),
      primaire: DsButton(
        key: const ValueKey('usr_nouveau'),
        libelle: l10n.usrNouvel,
        icone: LucideIcons.userPlus,
        onPressed: () => afficherFormulaireUtilisateur(context, ref),
      ),
    );
  }

  Widget _roles(AppLocalizations l10n, List<Role> tous) {
    // Les rôles archivés restent lus (rôle des comptes archivés) mais quittent la liste de gestion.
    final roles = [
      for (final r in tous)
        if (!r.archive) r,
    ];
    final archives = [
      for (final r in tous)
        if (r.archive) r,
    ];
    // Ce que le palier propose : les modules et permissions hors palier ne sont ni montrés ni comptés.
    final niveau = ref.watch(licenceProvider).niveau;
    final modulesPalier = {for (final i in itemsModules(l10n, niveau: niveau)) i.cle};
    final specialesPalier = {for (final i in itemsSpeciales(l10n, niveau: niveau)) i.cle};
    final nbModules = modulesPalier.length;
    int modulesDe(Role r) => r.modules.where(modulesPalier.contains).length;
    int specialesDe(Role r) => r.permissions.where((p) => specialesPalier.contains(p.code)).length;
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
        valeur: (r) => r.estAdmin ? nbModules : modulesDe(r),
        cellule: (_, r) => Text(r.estAdmin ? l10n.usrTous : '${modulesDe(r)}'),
      ),
      DsColonne(
        id: 'speciales',
        libelle: l10n.usrColSpeciales,
        numerique: true,
        valeur: (r) => r.estAdmin ? specialesPalier.length : specialesDe(r),
        cellule: (_, r) => Text(r.estAdmin ? l10n.usrToutes : '${specialesDe(r)}'),
      ),
      DsColonne(id: 'users', libelle: l10n.usrOngletUtilisateurs, numerique: true, valeur: (r) => r.nbUtilisateurs),
      DsColonne(id: 'obs', libelle: l10n.usrObservation, attenue: true, flex: 2, valeur: (r) => r.observation),
      DsColonne(
        id: 'etat',
        libelle: l10n.usrEtat,
        valeur: (r) => r.actif ? 1 : 0,
        cellule: (_, r) => BadgeStatut(r.actif ? 'actif' : 'inactif'),
      ),
      ...colonnesAudit(
        context,
        ref,
        (Role x) => Audit(creeLe: x.creeLe, creePar: x.creePar, modifieLe: x.modifieLe, modifiePar: x.modifiePar),
      ),
    ];
    void basculer(bool v) => setState(() => _archivesRoles = v);
    if (_archivesRoles) {
      return tableArchives<Role>(
        context,
        ref,
        key: const ValueKey('roles_archives'),
        entite: l10n.usrEntiteRoles,
        lignes: archives,
        colonnes: colonnes,
        cle: (r) => r.code,
        texteRecherche: (r) => '${r.code} ${r.nom} ${r.observation}',
        archiveLe: (r) => r.archiveLe,
        archivePar: (r) => r.archivePar,
        onDetail: (r) => afficherDetailRole(context, ref, r),
        onRestaurer: (choix, effacer) => restaurerArchives(
          context,
          ref,
          entite: EntiteArchivable.role,
          choix: choix,
          code: (r) => r.code,
          titre: (r) => libelleRole(context, r.nom),
          libelleEntite: l10n.usrEntiteRole,
          libelleEntites: l10n.usrEntiteRoles,
          effacer: effacer,
          rafraichir: () => rafraichirUtilisateurs(ref),
        ),
        bouton: boutonArchives(l10n, archives: true, nombre: archives.length, onChanged: basculer),
      );
    }
    return DsModuleTable<Role>(
      key: const ValueKey('roles'),
      entite: l10n.usrEntiteRoles,
      lignes: roles,
      raccourcis: [
        DsRaccourci(
          id: 'avec',
          libelle: l10n.racAvecUtilisateurs,
          icone: LucideIcons.users,
          filtre: (r) => r.nbUtilisateurs > 0,
        ),
        DsRaccourci(
          id: 'sans',
          libelle: l10n.racSansUtilisateur,
          icone: LucideIcons.userX,
          filtre: (r) => r.nbUtilisateurs == 0,
        ),
        DsRaccourci(
          id: 'mobile',
          libelle: l10n.racAccesMobile,
          icone: LucideIcons.smartphone,
          filtre: (r) => r.aPermission(Permission.utiliserMobile),
        ),
        DsRaccourci(
          id: 'achat',
          libelle: l10n.racVoitPrixAchat,
          icone: LucideIcons.eye,
          filtre: (r) => r.aPermission(Permission.voirPrixAchat),
        ),
        DsRaccourci(id: 'systeme', libelle: l10n.racRolesSysteme, icone: LucideIcons.lock, filtre: (r) => r.systeme),
      ],
      chargement: enChargement(ref.watch(rolesProvider)),
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
          iconeSeule: true,
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
        DsActionModule(
          cle: const ValueKey('roles_supprimer'),
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerOuArchiver(
            context,
            ref,
            entite: EntiteArchivable.role,
            choix: choix,
            code: (r) => r.code,
            titre: (r) => libelleRole(context, r.nom),
            libelleEntite: l10n.usrEntiteRole,
            libelleEntites: l10n.usrEntiteRoles,
            effacer: effacer,
            rafraichir: () => rafraichirUtilisateurs(ref),
          ),
        ),
      ],
      secondaire: boutonArchives(
        l10n,
        cle: const ValueKey('roles_archives_bouton'),
        archives: false,
        nombre: archives.length,
        onChanged: basculer,
      ),
      primaire: DsButton(
        key: const ValueKey('role_nouveau'),
        libelle: l10n.usrNouveauRole,
        icone: LucideIcons.shieldPlus,
        onPressed: () => afficherAssistantRole(context, ref),
      ),
    );
  }
}
