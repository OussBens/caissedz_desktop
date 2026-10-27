import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/archivage.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../caisse/caisse_dialogs.dart';
import '../commun/archives.dart';
import '../commun/chargement.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import 'gestion_caisse_dialogs.dart';
import 'gestion_caisse_providers.dart';

/// Écran Gestion caisse (`GestionCaisseScreen` du DS v2.2, §9.13) : onglets Caisses (cartes de session +
/// tableau), Transferts, Clôtures Z (par caisse, export de contrôle fiscal), Mouvements (grand-livre) et Sessions.
class GestionCaissePage extends ConsumerStatefulWidget {
  const GestionCaissePage({super.key, this.ongletInitial = 0});

  /// 0 Caisses · 1 Transferts · 2 Clôtures Z · 3 Mouvements · 4 Sessions.
  final int ongletInitial;

  @override
  ConsumerState<GestionCaissePage> createState() => _GestionCaissePageState();
}

class _GestionCaissePageState extends ConsumerState<GestionCaissePage> {
  late int _onglet = widget.ongletInitial;
  DsPeriode _periodeTransferts = DsPeriode.calculer('month');
  DsPeriode _periodeClotures = DsPeriode.calculer('year');
  DsPeriode _periodeMouvements = DsPeriode.calculer('month');
  DsPeriode _periodeSessions = DsPeriode.calculer('month');
  String? _caisseClotures;
  String? _caisseMouvements;
  String? _sessionMouvements;
  String? _typeMouvements;
  bool _archivesCaisses = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final caisses = ref.watch(caissesListeProvider).value ?? const <Caisse>[];
    final transferts = ref.watch(transfertsCaisseProvider).value ?? const <TransfertCaisse>[];
    final clotures = ref.watch(cloturesProvider).value ?? const <Cloture>[];
    final mouvements = ref.watch(mouvementsCaisseProvider).value ?? const <MouvementCaisse>[];
    final sessions = ref.watch(sessionsCaisseProvider).value ?? const <SessionCaisse>[];
    final noms = {for (final c in caisses) c.code: c.nom};
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    // Basic (une seule caisse) : pas d'onglet Transferts. Les onglets gardent leur numéro (0…4, celui des
    // routes) ; seul l'affichage saute les transferts.
    final avecTransferts = ref.watch(transfertsCaissePermisProvider);
    final visibles = [0, if (avecTransferts) 1, 2, 3, 4];
    final onglet = visibles.contains(_onglet) ? _onglet : 0;
    final libelles = [
      l10n.gcOngletCaisses,
      l10n.gcOngletTransferts,
      l10n.gcOngletClotures,
      l10n.gcOngletMouvements,
      l10n.gcOngletSessions,
    ];
    final comptes = [
      caisses.where((c) => !c.audit.archive).length,
      transferts.length,
      clotures.length,
      mouvements.length,
      sessions.length,
    ];
    return PageModule(
      moduleId: 'gestion_caisse',
      onglets: [for (final i in visibles) libelles[i]],
      comptes: [for (final i in visibles) comptes[i]],
      ongletCourant: visibles.indexOf(onglet),
      onOnglet: (i) => setState(() => _onglet = visibles[i]),
      child: switch (onglet) {
        // §9.13 : transferts caisse réservés à la permission `gererTransfertsCaisse` (sinon « accès refusé »).
        1 when !ref.watch(permissionProvider(Permission.gererTransfertsCaisse)) => LicenceGate(
          key: const ValueKey('transferts_refuse'),
          autorise: false,
          genre: DsGateGenre.refuse,
          description: l10n.dsGateRefuseDetail(l10n.gcOngletTransferts),
          child: const SizedBox.shrink(),
        ),
        1 => _transferts(l10n, transferts, noms, utilisateurs),
        2 => _clotures(l10n, clotures, caisses, noms, utilisateurs),
        3 => _mouvements(l10n, mouvements, sessions, caisses, noms, utilisateurs),
        4 => _sessions(l10n, sessions, noms, utilisateurs),
        _ => _caisses(l10n, caisses, sessions, utilisateurs),
      },
    );
  }

  // ———————————————————————————— Caisses ————————————————————————————

  Widget _caisses(
    AppLocalizations l10n,
    List<Caisse> caisses,
    List<SessionCaisse> sessions,
    Map<String, String> utilisateurs,
  ) {
    final devise = ref.watch(deviseProvider);
    final soldes = ref.watch(soldesCaissesProvider).value ?? const <String, SoldeCaisse>{};
    final magasins = {for (final m in ref.watch(magasinsProvider).value ?? const []) m.code: m.nom};
    final ouvertes = {
      for (final s in sessions)
        if (s.estOuverte) s.caisseCode: s,
    };
    double solde(Caisse c) => soldes[c.code]?.total ?? 0;
    // Les caisses archivées restent lues (noms des sessions, clôtures, mouvements) mais quittent la liste.
    final gestion = [
      for (final c in caisses)
        if (!c.audit.archive) c,
    ];
    final archives = [
      for (final c in caisses)
        if (c.audit.archive) c,
    ];
    final physiques = gestion.where((c) => c.actif && c.type == TypesCaisse.physique).toList();
    final colonnes = <DsColonne<Caisse>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, attenue: true, valeur: (c) => c.code),
      DsColonne(id: 'nom', libelle: l10n.gcColCaisse, fort: true, flex: 2, valeur: (c) => c.nom),
      DsColonne(
        id: 'type',
        libelle: l10n.caisseType,
        valeur: (c) => c.type,
        cellule: (_, c) => DsBadge(
          libelle: libelleTypeCaisse(l10n, c.type),
          ton: c.type == TypesCaisse.compte ? DsBadgeTon.accent : DsBadgeTon.neutre,
        ),
      ),
      DsColonne(
        id: 'initial',
        libelle: l10n.gcColSoldeInitial,
        numerique: true,
        valeur: (c) => c.soldeInitial,
        cellule: (_, c) => Text(formaterMontant(c.soldeInitial, devise)),
      ),
      DsColonne(
        id: 'solde',
        libelle: l10n.gcColSoldeActuel,
        numerique: true,
        fort: true,
        valeur: solde,
        cellule: (_, c) => Text(formaterMontant(solde(c), devise)),
        total: (cs) => formaterMontant(cs.fold(0.0, (x, c) => x + solde(c)), devise),
      ),
      DsColonne(
        id: 'session',
        libelle: l10n.gcColSession,
        valeur: (c) => ouvertes.containsKey(c.code) ? 'ouverte' : 'fermee',
        cellule: (_, c) => BadgeStatut(ouvertes.containsKey(c.code) ? 'ouverte' : 'fermee'),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.gcColEtat,
        valeur: (c) => c.actif ? 'actif' : 'inactif',
        cellule: (_, c) => BadgeStatut(c.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(
        id: 'magasin',
        libelle: l10n.caisseMagasin,
        visibleParDefaut: false,
        valeur: (c) => c.magasinCode == null ? '—' : (magasins[c.magasinCode] ?? c.magasinCode!),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (c) => c.observation ?? '',
      ),
      ...colonnesAudit(context, ref, (Caisse x) => x.audit),
    ];

    void basculer(bool v) => setState(() => _archivesCaisses = v);
    if (_archivesCaisses) {
      return tableArchives<Caisse>(
        context,
        ref,
        key: const ValueKey('gc_caisses_archives'),
        entite: l10n.gcEntiteCaisses,
        lignes: archives,
        colonnes: colonnes,
        cle: (c) => c.code,
        texteRecherche: (c) => '${c.code} ${c.nom}',
        archiveLe: (c) => c.audit.archiveLe,
        archivePar: (c) => c.audit.archivePar,
        onDetail: (c) => afficherDetailCaisse(context, ref, c),
        onRestaurer: (choix, effacer) => restaurerArchives(
          context,
          ref,
          entite: EntiteArchivable.caisse,
          choix: choix,
          code: (c) => c.code,
          titre: (c) => c.nom,
          libelleEntite: l10n.gcEntiteCaisse,
          libelleEntites: l10n.gcEntiteCaisses,
          effacer: effacer,
          rafraichir: () => rafraichirCaisse(ref),
        ),
        bouton: boutonArchives(l10n, archives: true, nombre: archives.length, onChanged: basculer),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsTailles.gridGap,
      children: [
        if (physiques.isNotEmpty)
          LayoutBuilder(
            builder: (context, contraintes) {
              const gap = 16.0;
              final n = ((contraintes.maxWidth + gap) / (300 + gap)).floor().clamp(1, physiques.length);
              final largeur = (contraintes.maxWidth - gap * (n - 1)) / n;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final c in physiques)
                    SizedBox(
                      key: ValueKey('carte_${c.code}'),
                      width: largeur,
                      child: DsCashSessionCard(
                        ouverte: ouvertes.containsKey(c.code),
                        caisse: c.nom,
                        code: ouvertes[c.code]?.code,
                        ouvertureHeure: ouvertes[c.code] == null ? null : formatHeure(ouvertes[c.code]!.ouverteLe),
                        ouverturePar: ouvertes[c.code] == null
                            ? null
                            : (utilisateurs[ouvertes[c.code]!.utilisateurCode] ?? ouvertes[c.code]!.utilisateurCode),
                        solde: solde(c),
                        devise: devise,
                        // Le coffre ne s'ouvre pas : il reçoit les espèces à chaque clôture.
                        onOuvrir: c.coffre ? null : () => afficherOuvertureCaisse(context, ref, caisseCode: c.code),
                        onCloturer: () =>
                            afficherClotureSession(context, ref, nomCaisse: c.nom, sessionCible: ouvertes[c.code]),
                        onMouvement: () => afficherMouvementManuel(context, ref, caisseCode: c.code),
                      ),
                    ),
                ],
              );
            },
          ),
        DsModuleTable<Caisse>(
          key: const ValueKey('gc_caisses'),
          entite: l10n.gcEntiteCaisses,
          lignes: gestion,
          raccourcis: [
            DsRaccourci(
              id: 'actives',
              libelle: l10n.racActives,
              icone: LucideIcons.circleCheck,
              filtre: (c) => c.actif,
            ),
            DsRaccourci(
              id: 'desactivees',
              libelle: l10n.racDesactivees,
              icone: LucideIcons.circleOff,
              filtre: (c) => !c.actif,
            ),
          ],
          chargement: enChargement(ref.watch(caissesListeProvider)),
          cle: (c) => c.code,
          afficherTotaux: true,
          permissions: permissionsSession(ref),
          messageVide: l10n.caisseAucune,
          indiceRecherche: l10n.gcRechercheCaisses,
          texteRecherche: (c) => '${c.code} ${c.nom}',
          colonnes: colonnes,
          onOuvrir: (c) => afficherDetailCaisse(context, ref, c),
          actions: [
            DsActionModule(
              libelle: l10n.tiersDetail,
              icone: LucideIcons.eye,
              regle: DsRegleSelection.une,
              detail: true,
              onPressed: (choix, _) => afficherDetailCaisse(context, ref, choix.first),
            ),
            DsActionModule(
              cle: const ValueKey('caisses_modifier'),
              libelle: l10n.communModifier,
              icone: LucideIcons.pencil,
              iconeSeule: true,
              regle: DsRegleSelection.une,
              onPressed: (choix, _) => afficherFormulaireCaisse(context, ref, caisse: choix.first),
            ),
            DsActionModule(
              cle: const ValueKey('caisses_desactiver'),
              libelle: l10n.caisseDesactiver,
              icone: LucideIcons.circlePause,
              danger: true,
              onPressed: (choix, effacer) => desactiverCaisses(context, ref, choix, effacer),
            ),
            DsActionModule(
              cle: const ValueKey('caisses_supprimer'),
              libelle: l10n.communSupprimer,
              icone: LucideIcons.trash2,
              danger: true,
              onPressed: (choix, effacer) => supprimerOuArchiver(
                context,
                ref,
                entite: EntiteArchivable.caisse,
                choix: choix,
                code: (c) => c.code,
                titre: (c) => c.nom,
                libelleEntite: l10n.gcEntiteCaisse,
                libelleEntites: l10n.gcEntiteCaisses,
                effacer: effacer,
                rafraichir: () => rafraichirCaisse(ref),
              ),
            ),
          ],
          secondaire: boutonArchives(
            l10n,
            cle: const ValueKey('caisses_archives_bouton'),
            archives: false,
            nombre: archives.length,
            onChanged: basculer,
          ),
          // Basic : la caisse principale seulement, pas de nouvelle caisse.
          primaire: ref.watch(plusieursCaissesProvider)
              ? DsButton(
                  key: const ValueKey('caisse_nouvelle'),
                  libelle: l10n.caisseNouvelle,
                  icone: LucideIcons.plus,
                  onPressed: () => afficherFormulaireCaisse(context, ref),
                )
              : null,
        ),
      ],
    );
  }

  // ———————————————————————————— Transferts ————————————————————————————

  Widget _transferts(
    AppLocalizations l10n,
    List<TransfertCaisse> tous,
    Map<String, String> noms,
    Map<String, String> utilisateurs,
  ) {
    final devise = ref.watch(deviseProvider);
    final lignes = tous.where((t) => dansPeriode(t.date, _periodeTransferts)).toList();
    return DsModuleTable<TransfertCaisse>(
      key: const ValueKey('gc_transferts'),
      entite: l10n.gcEntiteTransferts,
      lignes: lignes,
      chargement: enChargement(ref.watch(transfertsCaisseProvider)),
      cle: (t) => t.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.transfertCaisseAucun,
      periode: _periodeTransferts,
      onPeriode: (p) => setState(() => _periodeTransferts = p),
      indiceRecherche: l10n.gcRechercheTransferts,
      texteRecherche: (t) =>
          '${t.code} ${noms[t.caisseSource] ?? ''} ${noms[t.caisseDestination] ?? ''} ${t.commentaire ?? ''}',
      colonnes: [
        DsColonne(id: 'code', libelle: l10n.produitsColCode, attenue: true, valeur: (t) => t.code),
        DsColonne(
          id: 'date',
          libelle: l10n.communDate,
          attenue: true,
          valeur: (t) => t.date,
          cellule: (_, t) => Text(formatDateHeure.format(t.date)),
        ),
        DsColonne(id: 'src', libelle: l10n.gcColDepuis, valeur: (t) => noms[t.caisseSource] ?? t.caisseSource),
        DsColonne(
          id: 'dst',
          libelle: l10n.gcColVers,
          fort: true,
          valeur: (t) => noms[t.caisseDestination] ?? t.caisseDestination,
        ),
        DsColonne(
          id: 'montant',
          libelle: l10n.retoursMontant,
          numerique: true,
          valeur: (t) => t.montant,
          cellule: (_, t) => Text(formaterMontant(t.montant, devise)),
          total: (ts) => formaterMontant(ts.where((t) => t.actif).fold(0.0, (x, t) => x + t.montant), devise),
        ),
        DsColonne(
          id: 'statut',
          libelle: l10n.gcColStatut,
          valeur: (t) => t.actif ? 'valide' : 'annule',
          cellule: (_, t) => BadgeStatut(t.actif ? 'valide' : 'annule'),
        ),
        DsColonne(id: 'mode', libelle: l10n.gcColMode, visibleParDefaut: false, valeur: (t) => t.mode),
        DsColonne(
          id: 'obs',
          libelle: l10n.retoursObservation,
          visibleParDefaut: false,
          valeur: (t) => t.commentaire ?? '',
        ),
        DsColonne(
          id: 'annule_par',
          libelle: l10n.ventesAnnulePar,
          visibleParDefaut: false,
          valeur: (t) => t.annulePar == null ? '' : (utilisateurs[t.annulePar] ?? t.annulePar!),
        ),
        DsColonne(
          id: 'motif',
          libelle: l10n.ventesMotifAnnulation,
          visibleParDefaut: false,
          valeur: (t) => t.motifAnnulation ?? '',
        ),
        ...colonnesAudit(context, ref, (TransfertCaisse x) => x.audit),
      ],
      actions: [
        DsActionModule(
          cle: const ValueKey('transferts_annuler'),
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.x,
          iconeSeule: true,
          danger: true,
          onPressed: (choix, effacer) => annulerTransfertsCaisse(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('transfert_nouveau'),
        libelle: l10n.transfertCaisseNouveau,
        icone: LucideIcons.arrowLeftRight,
        onPressed: () => afficherTransfertCaisse(context, ref),
      ),
    );
  }

  // ———————————————————————————— Clôtures Z ————————————————————————————

  Widget _clotures(
    AppLocalizations l10n,
    List<Cloture> toutes,
    List<Caisse> caisses,
    Map<String, String> noms,
    Map<String, String> utilisateurs,
  ) {
    final devise = ref.watch(deviseProvider);
    final lignes = toutes
        .where(
          (z) => dansPeriode(z.fin, _periodeClotures) && (_caisseClotures == null || z.caisseCode == _caisseClotures),
        )
        .toList();
    final colonnes = [
      ...colonnesClotures(l10n, devise, noms, utilisateurs),
      ...colonnesAudit(context, ref, (Cloture x) => x.audit),
    ];
    return DsModuleTable<Cloture>(
      key: const ValueKey('gc_clotures'),
      entite: l10n.gcEntiteClotures,
      lignes: lignes,
      chargement: enChargement(ref.watch(cloturesProvider)),
      cle: (z) => z.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.clotureAucune,
      periode: _periodeClotures,
      onPeriode: (p) => setState(() => _periodeClotures = p),
      indiceRecherche: l10n.gcRechercheClotures,
      texteRecherche: (z) => '${z.code} ${nomCaisseCloture(l10n, z, noms)}',
      nbFiltresActifs: _caisseClotures == null ? 0 : 1,
      onReinitialiser: () => setState(() => _caisseClotures = null),
      filtres: [
        if (ref.watch(plusieursCaissesProvider))
          DsFormRow(
            libelle: l10n.gcColCaisse,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              cle: const ValueKey('clotures_filtre_caisse'),
              valeur: _caisseClotures,
              options: [null, for (final c in caisses) c.code],
              libelle: (code) => code == null ? l10n.tiersToutes : (noms[code] ?? code),
              recherche: rechercheListe(context, ref, ListeMetier.caisse),
              onChanged: (v) => setState(() => _caisseClotures = v),
            ),
          ),
      ],
      colonnes: colonnes,
      onExport: peutExporter(ref)
          ? (format, zs) => exporterTableau(
              context,
              ref,
              id: 'clotures_z',
              titre: l10n.gcOngletClotures,
              colonnes: colonnes,
              lignes: zs,
              format: format,
            )
          : null,
      onOuvrir: (z) => afficherDetailCloture(context, ref, z),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailCloture(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('clotures_pdf'),
          libelle: 'PDF',
          icone: LucideIcons.fileDown,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => imprimerCloture(context, ref, choix.first),
        ),
      ],
      secondaire: DsButton(
        key: const ValueKey('cloture_fiscal'),
        libelle: l10n.gcExportFiscal,
        icone: LucideIcons.landmark,
        variante: DsButtonVariante.secondaire,
        onPressed: peutExporter(ref) ? () => afficherExportFiscal(context, ref) : null,
      ),
      primaire: DsButton(
        key: const ValueKey('cloture_nouvelle'),
        libelle: l10n.gcNouvelleClotureZ,
        icone: LucideIcons.fileLock2,
        onPressed: () => afficherClotureZ(context, ref, caisseCode: _caisseClotures),
      ),
    );
  }

  // ———————————————————————————— Mouvements ————————————————————————————

  Widget _mouvements(
    AppLocalizations l10n,
    List<MouvementCaisse> tous,
    List<SessionCaisse> sessions,
    List<Caisse> caisses,
    Map<String, String> noms,
    Map<String, String> utilisateurs,
  ) {
    final devise = ref.watch(deviseProvider);
    final sessionsDe = {for (final m in tous) m: sessionDuMouvement(m, sessions)};
    final types = {for (final m in tous) m.type}.toList()..sort();
    final lignes = tous
        .where(
          (m) =>
              dansPeriode(m.date, _periodeMouvements) &&
              (_caisseMouvements == null || m.caisseCode == _caisseMouvements) &&
              (_sessionMouvements == null || sessionsDe[m] == _sessionMouvements) &&
              (_typeMouvements == null || m.type == _typeMouvements),
        )
        .toList();
    final colonnes = [
      ...colonnesMouvements(l10n, devise, noms, utilisateurs, session: (m) => sessionsDe[m]),
      ...colonnesAudit(context, ref, (MouvementCaisse x) => x.audit),
    ];
    return DsModuleTable<MouvementCaisse>(
      key: const ValueKey('gc_mouvements'),
      entite: l10n.gcEntiteMouvements,
      lignes: lignes,
      chargement: enChargement(ref.watch(mouvementsCaisseProvider)),
      cle: (m) => m.id ?? m.hashCode,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.mouvementAucun,
      periode: _periodeMouvements,
      onPeriode: (p) => setState(() => _periodeMouvements = p),
      indiceRecherche: l10n.gcRechercheMouvements,
      texteRecherche: (m) =>
          '${m.referenceCode ?? ''} ${libelleTypeMouvementCaisse(l10n, m.type)} ${m.commentaire ?? ''}',
      nbFiltresActifs: [_caisseMouvements, _sessionMouvements, _typeMouvements].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _caisseMouvements = null;
        _sessionMouvements = null;
        _typeMouvements = null;
      }),
      filtres: [
        if (ref.watch(plusieursCaissesProvider))
          DsFormRow(
            libelle: l10n.gcColCaisse,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              cle: const ValueKey('mouvements_filtre_caisse'),
              valeur: _caisseMouvements,
              options: [null, for (final c in caisses) c.code],
              libelle: (code) => code == null ? l10n.tiersToutes : (noms[code] ?? code),
              recherche: rechercheListe(context, ref, ListeMetier.caisse),
              onChanged: (v) => setState(() => _caisseMouvements = v),
            ),
          ),
        DsFormRow(
          libelle: l10n.gcColSession,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            cle: const ValueKey('mouvements_filtre_session'),
            valeur: _sessionMouvements,
            options: [
              null,
              for (final s in sessions)
                if (_caisseMouvements == null || s.caisseCode == _caisseMouvements) s.code,
            ],
            libelle: (code) => code ?? l10n.tiersToutes,
            recherche: rechercheListe(context, ref, ListeMetier.session),
            onChanged: (v) => setState(() => _sessionMouvements = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.caisseType,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            cle: const ValueKey('mouvements_filtre_type'),
            valeur: _typeMouvements,
            options: [null, ...types],
            libelle: (t) => t == null ? l10n.retoursTous : libelleTypeMouvementCaisse(l10n, t),
            onChanged: (v) => setState(() => _typeMouvements = v),
          ),
        ),
      ],
      colonnes: colonnes,
      onExport: peutExporter(ref)
          ? (format, ms) => exporterTableau(
              context,
              ref,
              id: 'mouvements_caisse',
              titre: l10n.gcOngletMouvements,
              colonnes: colonnes,
              lignes: ms,
              format: format,
            )
          : null,
      primaire: DsButton(
        key: const ValueKey('mouvement_manuel'),
        libelle: l10n.gcMouvementManuel,
        icone: LucideIcons.plus,
        onPressed: () => afficherMouvementManuel(context, ref, caisseCode: _caisseMouvements),
      ),
    );
  }

  // ———————————————————————————— Sessions ————————————————————————————

  Widget _sessions(
    AppLocalizations l10n,
    List<SessionCaisse> toutes,
    Map<String, String> noms,
    Map<String, String> utilisateurs,
  ) {
    final devise = ref.watch(deviseProvider);
    final lignes = toutes.where((s) => s.estOuverte || dansPeriode(s.ouverteLe, _periodeSessions)).toList();
    double? theorique(SessionCaisse s) => s.montantFermeture == null ? null : s.montantFermeture! - (s.ecart ?? 0);
    String montant(double? v) => v == null ? '—' : formaterMontant(v, devise);
    return DsModuleTable<SessionCaisse>(
      key: const ValueKey('gc_sessions'),
      entite: l10n.gcEntiteSessions,
      lignes: lignes,
      chargement: enChargement(ref.watch(sessionsCaisseProvider)),
      cle: (s) => s.code,
      permissions: permissionsSession(ref),
      messageVide: l10n.gcAucuneSession,
      periode: _periodeSessions,
      onPeriode: (p) => setState(() => _periodeSessions = p),
      raccourcis: [
        DsRaccourci(
          id: 'ouvertes',
          libelle: l10n.racSessionsOuvertes,
          icone: LucideIcons.lockOpen,
          filtre: (s) => s.estOuverte,
        ),
        DsRaccourci(
          id: 'longues',
          libelle: l10n.racOuvertesPlus24h,
          icone: LucideIcons.alarmClock,
          filtre: (s) => s.estOuverte && DateTime.now().difference(s.ouverteLe).inHours >= 24,
        ),
        DsRaccourci(
          id: 'cloturees',
          libelle: l10n.racClotureesAujourdhui,
          icone: LucideIcons.lock,
          filtre: (s) => !s.estOuverte && estAujourdhui(s.fermeeLe),
        ),
        DsRaccourci(
          id: 'ecart',
          libelle: l10n.racAvecEcart,
          icone: LucideIcons.triangleAlert,
          filtre: (s) => (s.ecart ?? 0).abs() > 0.004,
        ),
      ],
      indiceRecherche: l10n.gcRechercheSessions,
      texteRecherche: (s) => '${s.code} ${noms[s.caisseCode] ?? ''}',
      colonnes: [
        DsColonne(id: 'code', libelle: l10n.gcColSession, fort: true, valeur: (s) => s.code),
        DsColonne(id: 'caisse', libelle: l10n.gcColCaisse, valeur: (s) => noms[s.caisseCode] ?? s.caisseCode),
        DsColonne(
          id: 'ouv',
          libelle: l10n.gcColOuverture,
          attenue: true,
          valeur: (s) => s.ouverteLe,
          cellule: (_, s) => Text(formatJourHeure.format(s.ouverteLe)),
        ),
        DsColonne(
          id: 'clo',
          libelle: l10n.gcColCloture,
          attenue: true,
          valeur: (s) => s.fermeeLe,
          cellule: (_, s) => Text(s.fermeeLe == null ? '—' : formatJourHeure.format(s.fermeeLe!)),
        ),
        DsColonne(
          id: 'fond',
          libelle: l10n.gcColFond,
          numerique: true,
          valeur: (s) => s.fondInitial,
          cellule: (_, s) => Text(formaterMontant(s.fondInitial, devise)),
        ),
        DsColonne(
          id: 'theorique',
          libelle: l10n.gcColTheorique,
          numerique: true,
          valeur: theorique,
          cellule: (_, s) => Text(montant(theorique(s))),
        ),
        DsColonne(
          id: 'reel',
          libelle: l10n.gcColReel,
          numerique: true,
          valeur: (s) => s.montantFermeture,
          cellule: (_, s) => Text(montant(s.montantFermeture)),
        ),
        DsColonne(
          id: 'ecart',
          libelle: l10n.gcColEcart,
          numerique: true,
          valeur: (s) => s.ecart,
          cellule: (ctx, s) {
            final e = s.ecart;
            if (e == null) return const Text('—');
            final c = ctx.ds.colors;
            return Text(
              '${e > 0.005 ? '+' : ''}${f2(e)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: e < -0.005
                    ? c.dangerFg
                    : e > 0.005
                    ? c.successFg
                    : c.textSecondary,
              ),
            );
          },
        ),
        DsColonne(
          id: 'statut',
          libelle: l10n.gcColStatut,
          valeur: statutSession,
          cellule: (_, s) => BadgeStatut(statutSession(s)),
        ),
        DsColonne(
          id: 'par',
          libelle: l10n.gcColOuvertePar,
          visibleParDefaut: false,
          valeur: (s) => utilisateurs[s.utilisateurCode] ?? s.utilisateurCode,
        ),
        ...colonnesAudit(context, ref, (SessionCaisse x) => x.audit),
      ],
      onOuvrir: (s) => afficherMouvementsSession(context, ref, s),
      actions: [
        DsActionModule(
          libelle: l10n.gcVoirMouvements,
          icone: LucideIcons.list,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherMouvementsSession(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('sessions_cloturer'),
          libelle: l10n.gcCloturer,
          icone: LucideIcons.lock,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && !choix.first.estOuverte,
          onPressed: (choix, _) => afficherClotureSession(
            context,
            ref,
            nomCaisse: noms[choix.first.caisseCode] ?? choix.first.caisseCode,
            sessionCible: choix.first,
          ),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('session_ouvrir'),
        libelle: l10n.gcOuvrirSession,
        icone: LucideIcons.lockOpen,
        onPressed: () => afficherOuvertureCaisse(context, ref),
      ),
    );
  }
}
