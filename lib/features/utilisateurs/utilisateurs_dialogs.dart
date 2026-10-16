import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../application/role_service.dart';
import '../../application/utilisateur_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/utilisateur_repository.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/utilisateur.dart';
import '../../domain/permissions.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import 'utilisateurs_providers.dart';

final DateFormat formatAcces = DateFormat('dd/MM/yyyy HH:mm');

String _date(DateTime? d) => d == null ? '—' : formatAcces.format(d);

/// Exécute une écriture du module ; affiche l'erreur métier dans un `ResultDialog`.
Future<bool> executerUtilisateurs(
  BuildContext context,
  WidgetRef ref,
  String titre,
  Future<void> Function() action,
) async {
  final l10n = AppLocalizations.of(context);
  String? message;
  try {
    await action();
  } on UtilisateurException catch (e) {
    message = messageErreurUtilisateur(l10n, e.erreur);
  } on RoleException catch (e) {
    message = messageErreurRole(l10n, e.erreur);
  }
  rafraichirUtilisateurs(ref);
  if (message != null && context.mounted) {
    unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: titre, message: message));
  }
  return message == null;
}

// ---------------------------------------------------------------------------------------------------------------
// Utilisateur : formulaire (UtilisateurFormDialog, 900 px).
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherFormulaireUtilisateur(BuildContext context, WidgetRef ref, {LigneUtilisateur? ligne}) async {
  final db = ref.read(appDatabaseProvider).db;
  final roles = await ref.read(rolesProvider.future);
  final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
  final pris = {for (final u in await UtilisateurRepository(db).tous()) u.identifiant.toLowerCase(): u.code};
  final code = ligne?.u.code ?? await ref.read(utilisateurServiceProvider).prochainCode();
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    fermableParVoile: false,
    builder: (_) => _UtilisateurForm(
      ligne: ligne,
      code: code,
      roles: roles,
      caisses: caisses,
      magasins: magasins,
      identifiantsPris: pris,
    ),
  );
}

class _UtilisateurForm extends ConsumerStatefulWidget {
  const _UtilisateurForm({
    required this.ligne,
    required this.code,
    required this.roles,
    required this.caisses,
    required this.magasins,
    required this.identifiantsPris,
  });
  final LigneUtilisateur? ligne;
  final String code;
  final List<Role> roles;
  final List<Caisse> caisses;
  final List<Magasin> magasins;
  final Map<String, String> identifiantsPris;

  @override
  ConsumerState<_UtilisateurForm> createState() => _UtilisateurFormState();
}

class _UtilisateurFormState extends ConsumerState<_UtilisateurForm> {
  Utilisateur? get _u => widget.ligne?.u;
  bool get _edition => _u != null;
  late final _identifiant = TextEditingController(text: _u?.identifiant ?? '');
  final _motDePasse = TextEditingController();
  late final _prenom = TextEditingController(text: _u?.prenom ?? '');
  late final _nom = TextEditingController(text: _u?.nom ?? '');
  late final _telephone = TextEditingController(text: _u?.telephone ?? '');
  late final _observation = TextEditingController(text: _u?.observation ?? '');
  late String _role = _u?.roleCode ?? _roleParDefaut();
  late String? _caisse = _edition ? _u!.caisseCode : widget.caisses.firstOrNull?.code;
  late List<String> _magasins = _edition
      ? [...widget.ligne!.magasins]
      : [if (widget.magasins.isNotEmpty) widget.magasins.first.code];
  late bool _actif = _u?.actif ?? true;
  bool _occupe = false;
  final _erreurs = <String, String>{};

  String _roleParDefaut() {
    final assignables = _assignables;
    return assignables.any((r) => r.code == Roles.caissier) ? Roles.caissier : (assignables.firstOrNull?.code ?? '');
  }

  /// Rôles proposés : actifs et hors Admin (admin unique, non assignable) ; l'Admin garde le sien.
  List<Role> get _assignables => [
    for (final r in widget.roles)
      if ((_u?.estAdmin ?? false) ? r.estAdmin : (!r.estAdmin && (r.actif || r.code == _u?.roleCode))) r,
  ];

  bool get _admin => _role == Roles.admin;

  @override
  void dispose() {
    for (final c in [_identifiant, _motDePasse, _prenom, _nom, _telephone, _observation]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _identifiantPris {
    final code = widget.identifiantsPris[_identifiant.text.trim().toLowerCase()];
    return code != null && code != _u?.code;
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _occupe = true;
      _erreurs.clear();
    });
    final s = ref.read(utilisateurServiceProvider);
    try {
      final Utilisateur u;
      if (_edition) {
        u = await s.modifier(
          _u!.code,
          identifiant: _identifiant.text,
          nouveauMotDePasse: _motDePasse.text,
          prenom: _prenom.text,
          nom: _nom.text,
          telephone: _telephone.text,
          roleCode: _role,
          caisseCode: _admin ? null : _caisse,
          magasins: _magasins,
          observation: _observation.text,
          actif: _actif,
        );
      } else {
        u = await s.creer(
          identifiant: _identifiant.text,
          motDePasse: _motDePasse.text,
          prenom: _prenom.text,
          nom: _nom.text,
          telephone: _telephone.text,
          roleCode: _role,
          caisseCode: _admin ? null : _caisse,
          magasins: _magasins,
          observation: _observation.text,
        );
      }
      rafraichirUtilisateurs(ref);
      ref.invalidate(nomsUtilisateursProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(
        context,
        titre: _edition ? l10n.usrModifie : l10n.usrCree,
        description: _edition ? (u.nomComplet.isEmpty ? u.identifiant : u.nomComplet) : u.code,
        ton: DsToastTon.succes,
      );
    } on UtilisateurException catch (e) {
      if (!mounted) return;
      final message = messageErreurUtilisateur(l10n, e.erreur);
      final champ = switch (e.erreur) {
        ErreurUtilisateur.identifiantInvalide || ErreurUtilisateur.identifiantPris => 'identifiant',
        ErreurUtilisateur.motDePasseFaible => 'mdp',
        ErreurUtilisateur.telephoneObligatoire => 'tel',
        ErreurUtilisateur.roleInvalide => 'role',
        ErreurUtilisateur.magasinsObligatoires => 'magasins',
        _ => 'etat',
      };
      setState(() {
        _occupe = false;
        _erreurs[champ] = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final force = UtilisateurService.force(_motDePasse.text);
    final role = widget.roles.where((r) => r.code == _role).firstOrNull;
    final valide =
        _identifiant.text.trim().isNotEmpty &&
        !_identifiantPris &&
        (_edition || force >= UtilisateurService.forceMinimale) &&
        _magasins.isNotEmpty;
    const lw = 128.0;
    final nomAffiche = _u == null ? '' : (_u!.nomComplet.isEmpty ? _u!.identifiant : _u!.nomComplet);
    return DsDialog(
      titre: _edition ? l10n.usrModifierTitre : l10n.usrNouvel,
      iconeData: _edition ? LucideIcons.pencil : LucideIcons.userPlus,
      description: _edition ? '$nomAffiche · ${_u!.code}' : l10n.usrFormDescription,
      largeur: 900,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('usr_enregistrer'),
          libelle: _edition ? l10n.communModifier : l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: valide ? _enregistrer : null,
        ),
      ],
      contenu: DsGrilleFormulaire(
        children: [
          DsSpan(child: DsSubHead(l10n.usrSectionCompte, icone: LucideIcons.user)),
          DsFormRow(
            libelle: l10n.usrCode,
            largeurLibelle: lw,
            child: DsTextField(valeurInitiale: widget.code, actif: false),
          ),
          if (_edition)
            DsFormRow(
              libelle: l10n.usrEtat,
              largeurLibelle: lw,
              erreur: _erreurs['etat'],
              child: DsSwitch(
                cle: const ValueKey('usr_actif'),
                valeur: _actif,
                libelle: _actif ? l10n.usrActif : l10n.usrInactif,
                actif: !(_u!.estAdmin && _u!.systeme),
                onChanged: (v) => setState(() => _actif = v),
              ),
            )
          else
            const SizedBox.shrink(),
          DsFormRow(
            libelle: l10n.usrIdentifiant,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _identifiantPris ? l10n.usrIdentifiantPris : _erreurs['identifiant'],
            child: DsTextField(
              key: const ValueKey('usr_identifiant'),
              controller: _identifiant,
              iconePrefixe: LucideIcons.atSign,
              indice: l10n.usrIdentifiantIndice,
              autofocus: !_edition,
              onChanged: (_) => setState(() => _erreurs.remove('identifiant')),
            ),
          ),
          DsFormRow(
            libelle: _edition ? l10n.usrNouveauMotDePasse : l10n.usrMotDePasse,
            obligatoire: !_edition,
            largeurLibelle: lw,
            aide: _edition ? l10n.usrMdpVide : null,
            erreur: _erreurs['mdp'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s1_5,
              children: [
                DsTextField(
                  key: const ValueKey('usr_mdp'),
                  controller: _motDePasse,
                  obscur: true,
                  iconePrefixe: LucideIcons.keyRound,
                  indice: l10n.usrMdpIndice,
                  onChanged: (_) => setState(() => _erreurs.remove('mdp')),
                ),
                if (_motDePasse.text.isNotEmpty) _JaugeForce(force),
              ],
            ),
          ),
          DsFormRow(
            libelle: l10n.usrPrenom,
            largeurLibelle: lw,
            child: DsTextField(key: const ValueKey('usr_prenom'), controller: _prenom),
          ),
          DsFormRow(
            libelle: l10n.usrNom,
            largeurLibelle: lw,
            child: DsTextField(key: const ValueKey('usr_nom'), controller: _nom),
          ),
          DsFormRow(
            libelle: l10n.usrTelephone,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _erreurs['tel'],
            child: DsTextField(
              key: const ValueKey('usr_telephone'),
              controller: _telephone,
              indice: l10n.usrTelephoneIndice,
              onChanged: (_) => setState(() => _erreurs.remove('tel')),
            ),
          ),
          const SizedBox.shrink(),
          DsSpan(child: DsSubHead(l10n.usrSectionAcces, icone: LucideIcons.shieldCheck)),
          DsFormRow(
            libelle: l10n.usrRole,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _erreurs['role'],
            aide: _admin
                ? l10n.usrAdminRole
                : role == null
                ? null
                : l10n.usrNbPermissions(role.modules.length + role.permissions.length),
            child: DsSelect<String>(
              cle: const ValueKey('usr_role'),
              valeur: _role,
              options: [for (final r in _assignables) r.code],
              libelle: (c) => libelleRole(context, widget.roles.where((r) => r.code == c).firstOrNull?.nom ?? c),
              actif: !(_u?.estAdmin ?? false),
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
          ),
          DsFormRow(
            libelle: l10n.usrCaisseAttachee,
            largeurLibelle: lw,
            aide: _admin ? l10n.usrCaisseAdmin : l10n.usrCaisseIndice,
            child: DsSelect<String?>(
              cle: const ValueKey('usr_caisse'),
              valeur: _admin ? null : _caisse,
              options: [null, for (final c in widget.caisses) c.code],
              libelle: (c) => c == null ? l10n.usrAucune : widget.caisses.firstWhere((x) => x.code == c).nom,
              actif: !_admin,
              recherche: rechercheListe(context, ref, ListeMetier.caisse),
              onChanged: (v) => setState(() => _caisse = v),
            ),
          ),
          DsSpan(
            child: DsFormRow(
              libelle: l10n.usrColMagasins,
              obligatoire: true,
              largeurLibelle: lw,
              alignerDebut: true,
              aide: l10n.usrMagasinsIndice,
              erreur: _erreurs['magasins'],
              child: DsOrderedMultiSelect<String>(
                key: const ValueKey('usr_magasins'),
                options: [for (final m in widget.magasins) DsOption(m.code, libelle: m.nom)],
                valeur: _magasins,
                libellePremier: l10n.usrDefaut,
                onChanged: (v) => setState(() {
                  _magasins = v;
                  _erreurs.remove('magasins');
                }),
              ),
            ),
          ),
          DsSpan(
            child: DsFormRow(
              libelle: l10n.usrObservation,
              largeurLibelle: lw,
              alignerDebut: true,
              child: DsTextField(controller: _observation, multiligne: true, lignes: 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Jauge de robustesse du mot de passe : 4 segments et libellé (Très faible → Fort).
class _JaugeForce extends StatelessWidget {
  const _JaugeForce(this.force);
  final int force;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final couleur = [c.danger, c.danger, c.warning, c.success, c.success][force];
    final libelle = [l10n.usrForce0, l10n.usrForce1, l10n.usrForce2, l10n.usrForce3, l10n.usrForce4][force];
    return Row(
      spacing: DsSpacing.s2,
      children: [
        Expanded(
          child: Row(
            spacing: DsSpacing.s1,
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: DsMotion.base,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < force ? couleur : c.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(
          libelle,
          key: const ValueKey('usr_force'),
          style: t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: couleur),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Utilisateur : détail (UtilisateurDetailDialog, 940 px), mot de passe, désactivation.
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherDetailUtilisateur(BuildContext context, WidgetRef ref, LigneUtilisateur l) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final roles = await ref.read(rolesProvider.future);
  final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
  final magasins = {for (final m in await ref.read(magasinsProvider.future)) m.code: m.nom};
  final noms = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final u = l.u;
  final role = roles.where((r) => r.code == u.roleCode).firstOrNull;
  final nomsMagasins = [
    for (final (i, m) in l.magasins.indexed) '${magasins[m] ?? m}${i == 0 ? ' ${l10n.usrDefaut}' : ''}',
  ].join(', ');
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.userCog,
      titre: l.nom,
      description: '@${u.identifiant} · ${u.code}',
      badges: [
        DsBadge(
          libelle: libelleRole(context, u.roleNom),
          ton: u.estAdmin ? DsBadgeTon.primaire : DsBadgeTon.neutre,
          icone: LucideIcons.shield,
        ),
        BadgeStatut(u.actif ? 'actif' : 'inactif'),
      ],
      onModifier: () => afficherFormulaireUtilisateur(context, ref, ligne: l),
      stats: [
        DsStatItem(libelle: l10n.usrKpiVentes, valeur: '${l.nbVentes}', icone: LucideIcons.receipt),
        DsStatItem(
          libelle: l10n.usrKpiTotal,
          valeur: f2(l.totalVendu),
          suffixe: devise,
          icone: LucideIcons.banknote,
          ton: DsBadgeTon.succes,
        ),
        DsStatItem(libelle: l10n.usrColDernierAcces, valeur: _date(u.dernierAcces), icone: LucideIcons.clock),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.usrInfos,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.usrIdentifiant, u.identifiant, mono: true),
            DsKeyValue(l10n.usrTelephone, u.telephone.isEmpty ? '—' : u.telephone),
            DsKeyValue(l10n.usrRole, libelleRole(context, u.roleNom)),
            DsKeyValue(
              l10n.usrCaisseAttachee,
              u.caisseCode == null ? (u.estAdmin ? l10n.usrLibreAdmin : l10n.usrLibre) : caisses[u.caisseCode] ?? '',
            ),
            DsKeyValue(l10n.usrColMagasins, nomsMagasins.isEmpty ? '—' : nomsMagasins, span: 2),
            if (u.observation.isNotEmpty) DsKeyValue(l10n.usrObservation, u.observation, span: 3),
          ],
        ),
        if (role != null)
          DsSectionDetail(
            titre: l10n.usrPermissionsRole,
            icone: LucideIcons.lock,
            contenu: PermissionGrid(
              lectureSeule: true,
              colonnes: 4,
              items: [...itemsModules(l10n), ...itemsSpeciales(l10n)],
              valeur: valeursRole(role, l10n),
            ),
          ),
        DsSectionDetail(
          titre: l10n.usrAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.usrCreePar, u.creePar == null ? '—' : (noms[u.creePar] ?? u.creePar!)),
            DsKeyValue(l10n.usrCreeLe, _date(u.creeLe)),
            DsKeyValue(l10n.usrModifiePar, u.modifiePar == null ? '—' : (noms[u.modifiePar] ?? u.modifiePar!)),
            DsKeyValue(l10n.usrModifieLe, _date(u.modifieLe)),
          ],
        ),
      ],
    ),
  );
}

/// Réinitialise le mot de passe et affiche le mot de passe temporaire à communiquer.
Future<void> reinitialiserMotDePasse(BuildContext context, WidgetRef ref, Utilisateur u) async {
  final l10n = AppLocalizations.of(context);
  String? temporaire;
  final ok = await executerUtilisateurs(context, ref, l10n.usrReinitialiser, () async {
    temporaire = await ref.read(utilisateurServiceProvider).reinitialiserMotDePasse(u.code);
  });
  if (!ok || !context.mounted) return;
  await afficherResultat(
    context,
    type: DsResultatType.info,
    titre: l10n.usrMdpReinitTitre,
    message: l10n.usrMdpReinitMessage(u.identifiant, temporaire!),
  );
}

Future<void> desactiverUtilisateurs(
  BuildContext context,
  WidgetRef ref,
  List<LigneUtilisateur> choix,
  VoidCallback effacer,
) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(utilisateurServiceProvider);
  String? motif(Utilisateur u) => switch (service.blocageDesactivation(u)) {
    null => null,
    final e => messageErreurUtilisateur(l10n, e),
  };
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.desactiver,
    entite: l10n.usrEntiteUtilisateur,
    entitePluriel: l10n.usrEntiteUtilisateurs,
    elements: [
      for (final l in choix)
        DsElementLot(
          id: l.u.code,
          titre: l.nom,
          sousTitre: '@${l.u.identifiant} · ${libelleRole(context, l.u.roleNom)}',
          motifBlocage: motif(l.u),
        ),
    ],
  );
  if (ok == null || !context.mounted) return;
  final codes = [
    for (final l in choix)
      if (motif(l.u) == null) l.u.code,
  ];
  final fait = await executerUtilisateurs(context, ref, l10n.usrDesactiver, () => service.desactiver(codes));
  effacer();
  if (fait && context.mounted) {
    afficherToast(context, titre: l10n.usrDesactives, description: l10n.usrDesactivesDetail);
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Rôle : assistant (RoleWizardDialog, 900 px, 3 étapes), détail, désactivation.
// ---------------------------------------------------------------------------------------------------------------

/// Ouvre l'assistant : création ([role] nul), modification, ou duplication ([dupliquer]).
Future<void> afficherAssistantRole(BuildContext context, WidgetRef ref, {Role? role, bool dupliquer = false}) async {
  final l10n = AppLocalizations.of(context);
  if (role != null && role.systeme && !dupliquer) {
    return afficherResultat(
      context,
      type: DsResultatType.erreur,
      titre: l10n.usrAdminBloqueTitre,
      message: l10n.usrAdminBloqueMessage,
    );
  }
  final roles = await ref.read(rolesProvider.future);
  final code = role != null && !dupliquer ? role.code : await ref.read(roleServiceProvider).prochainCode();
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    fermableParVoile: false,
    builder: (_) => _RoleAssistant(role: role, dupliquer: dupliquer, code: code, roles: roles),
  );
}

class _RoleAssistant extends ConsumerStatefulWidget {
  const _RoleAssistant({required this.role, required this.dupliquer, required this.code, required this.roles});
  final Role? role;
  final bool dupliquer;
  final String code;
  final List<Role> roles;

  @override
  ConsumerState<_RoleAssistant> createState() => _RoleAssistantState();
}

class _RoleAssistantState extends ConsumerState<_RoleAssistant> {
  bool get _edition => widget.role != null && !widget.dupliquer;
  int _etape = 0;
  late final _nom = TextEditingController();
  late final _observation = TextEditingController(text: widget.role?.observation ?? '');
  late bool _actif = widget.role?.actif ?? true;
  Set<String>? _valeurs;
  bool _occupe = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_valeurs != null) return;
    final l10n = AppLocalizations.of(context);
    final r = widget.role;
    _valeurs = r == null ? {'tableau_bord', 'caisse'} : valeursRole(r, l10n);
    _nom.text = r == null ? '' : (widget.dupliquer ? l10n.usrCopie(r.nom) : r.nom);
  }

  @override
  void dispose() {
    _nom.dispose();
    _observation.dispose();
    super.dispose();
  }

  bool get _doublon {
    final n = _nom.text.trim().toLowerCase();
    return widget.roles.any((r) => r.nom.toLowerCase() == n && (!_edition || r.code != widget.role!.code));
  }

  Set<String> _modules(AppLocalizations l10n) => {
    for (final i in itemsModules(l10n))
      if (_valeurs!.contains(i.cle)) i.cle,
  };

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    if (_edition) {
      final ok = await afficherConfirmation(
        context,
        titre: l10n.usrConfirmRoleTitre,
        message: l10n.usrConfirmRoleMessage(widget.role!.nbUtilisateurs),
        genre: DsConfirmGenre.avertissement,
        libelleConfirmer: l10n.communModifier,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _occupe = true);
    final s = ref.read(roleServiceProvider);
    final modules = _modules(l10n);
    final permissions = {
      for (final p in Permission.values)
        if (_valeurs!.contains(p.code)) p,
    };
    final fait = await executerUtilisateurs(context, ref, l10n.usrEnregistrerRole, () async {
      if (_edition) {
        await s.modifier(
          widget.role!.code,
          nom: _nom.text,
          observation: _observation.text,
          actif: _actif,
          modules: modules,
          permissions: permissions,
        );
      } else {
        await s.creer(nom: _nom.text, observation: _observation.text, modules: modules, permissions: permissions);
      }
    });
    if (!mounted) return;
    if (!fait) {
      setState(() => _occupe = false);
      return;
    }
    Navigator.of(context).pop();
    afficherToast(context, titre: l10n.usrRoleEnregistre, description: l10n.usrRoleEnregistreDetail);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nMod = _modules(l10n).length;
    final peutSuivre = switch (_etape) {
      0 => _nom.text.trim().isNotEmpty && !_doublon,
      1 => nMod > 0,
      _ => true,
    };
    return DsDialog(
      titre: _edition ? l10n.usrModifierRole : l10n.usrNouveauRole,
      iconeData: _edition ? LucideIcons.pencil : LucideIcons.shieldPlus,
      description: _edition
          ? l10n.usrRoleConcernes(widget.role!.code, widget.role!.nbUtilisateurs)
          : l10n.usrRoleDescription,
      largeur: 900,
      piedDebut: _etape > 0
          ? DsButton(
              libelle: l10n.usrPrecedent,
              icone: LucideIcons.arrowLeft,
              variante: DsButtonVariante.secondaire,
              onPressed: () => setState(() => _etape--),
            )
          : null,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        if (_etape < 2)
          DsButton(
            key: const ValueKey('role_suivant'),
            libelle: l10n.usrSuivant,
            iconeDroite: LucideIcons.arrowRight,
            onPressed: peutSuivre ? () => setState(() => _etape++) : null,
          )
        else
          DsButton(
            key: const ValueKey('role_enregistrer'),
            libelle: _edition ? l10n.communModifier : l10n.usrEnregistrerRole,
            icone: LucideIcons.check,
            chargement: _occupe,
            onPressed: _enregistrer,
          ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 18,
        children: [
          DsStepper(
            etapes: [l10n.usrEtapeInfos, l10n.usrEtapePermissions, l10n.usrEtapeSpeciales],
            descriptions: [l10n.usrEtapeInfosDesc, l10n.usrEtapeModules(nMod), l10n.usrEtapeSpecialesDesc],
            courante: _etape,
            onEtape: (i) => setState(() => _etape = i),
          ),
          if (_etape == 0)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: DsSpacing.s3,
                  children: [
                    DsFormRow(
                      libelle: l10n.usrCode,
                      child: DsTextField(valeurInitiale: widget.code, actif: false),
                    ),
                    DsFormRow(
                      libelle: l10n.usrNomRole,
                      obligatoire: true,
                      erreur: _doublon ? l10n.usrNomRolePris : null,
                      child: DsTextField(
                        key: const ValueKey('role_nom'),
                        controller: _nom,
                        autofocus: true,
                        indice: l10n.usrNomRoleIndice,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_edition)
                      DsFormRow(
                        libelle: l10n.usrEtat,
                        child: DsSwitch(
                          cle: const ValueKey('role_actif'),
                          valeur: _actif,
                          libelle: _actif ? l10n.usrActif : l10n.usrInactif,
                          onChanged: (v) => setState(() => _actif = v),
                        ),
                      ),
                    DsFormRow(
                      libelle: l10n.usrObservation,
                      alignerDebut: true,
                      child: DsTextField(
                        controller: _observation,
                        multiligne: true,
                        lignes: 2,
                        indice: l10n.usrObsRoleIndice,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_etape == 1)
            PermissionGrid(
              prefixeCle: 'role_module',
              titre: l10n.usrModulesTitre,
              description: l10n.usrModulesDesc,
              items: itemsModules(l10n),
              valeur: _valeurs!,
              onChanged: (v) => setState(() => _valeurs = v),
            )
          else
            PermissionGrid(
              prefixeCle: 'role_perm',
              colonnes: 2,
              titre: l10n.usrEtapeSpeciales,
              description: l10n.usrSpecialesDesc,
              items: itemsSpeciales(l10n),
              valeur: _valeurs!,
              onChanged: (v) => setState(() => _valeurs = v),
            ),
        ],
      ),
    );
  }
}

Future<void> afficherDetailRole(BuildContext context, WidgetRef ref, Role r) async {
  final l10n = AppLocalizations.of(context);
  final noms = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.shield,
      titre: l10n.usrRoleTitre(libelleRole(context, r.nom)),
      description: r.code,
      badges: [
        if (r.systeme) DsBadge(libelle: l10n.usrSysteme, ton: DsBadgeTon.primaire, icone: LucideIcons.lock),
        BadgeStatut(r.actif ? 'actif' : 'inactif'),
      ],
      onModifier: r.systeme ? null : () => afficherAssistantRole(context, ref, role: r),
      stats: [
        DsStatItem(libelle: l10n.usrCode, valeur: r.code, icone: LucideIcons.hash),
        DsStatItem(libelle: l10n.usrColUtilisateur, valeur: '${r.nbUtilisateurs}', icone: LucideIcons.users),
        DsStatItem(
          libelle: l10n.usrEtat,
          valeur: r.actif ? l10n.usrActif : l10n.usrInactif,
          icone: LucideIcons.circleCheck,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.usrEtapePermissions,
          icone: LucideIcons.lock,
          contenu: PermissionGrid(
            lectureSeule: true,
            colonnes: 4,
            items: [...itemsModules(l10n), ...itemsSpeciales(l10n)],
            valeur: valeursRole(r, l10n),
          ),
        ),
        DsSectionDetail(
          titre: l10n.usrObservation,
          icone: LucideIcons.messageSquareText,
          contenu: Text(r.observation.isEmpty ? '—' : r.observation, style: context.ds.typo.body),
        ),
        DsSectionDetail(
          titre: l10n.usrAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.usrCreePar, r.creePar == null ? '—' : (noms[r.creePar] ?? r.creePar!)),
            DsKeyValue(l10n.usrCreeLe, _date(r.creeLe)),
            DsKeyValue(l10n.usrModifiePar, r.modifiePar == null ? '—' : (noms[r.modifiePar] ?? r.modifiePar!)),
          ],
        ),
      ],
    ),
  );
}

Future<void> desactiverRoles(BuildContext context, WidgetRef ref, List<Role> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(roleServiceProvider);
  String? motif(Role r) => switch (service.blocageDesactivation(r)) {
    null => null,
    final e => messageErreurRole(l10n, e),
  };
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.desactiver,
    entite: l10n.usrEntiteRole,
    entitePluriel: l10n.usrEntiteRoles,
    elements: [
      for (final r in choix)
        DsElementLot(
          id: r.code,
          titre: libelleRole(context, r.nom),
          sousTitre: r.code,
          meta: l10n.usrNbUtilisateurs(r.nbUtilisateurs),
          motifBlocage: motif(r),
        ),
    ],
  );
  if (ok == null || !context.mounted) return;
  final codes = [
    for (final r in choix)
      if (motif(r) == null) r.code,
  ];
  final fait = await executerUtilisateurs(context, ref, l10n.usrDesactiver, () => service.desactiver(codes));
  effacer();
  if (fait && context.mounted) afficherToast(context, titre: l10n.usrRolesDesactives);
}
