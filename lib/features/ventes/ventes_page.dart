import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_controller.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';
import 'retour_dialog.dart';
import 'ventes_dialogs.dart';
import 'ventes_providers.dart';

/// Écran Ventes (`PaniersScreen` du DS v2.2) : KPIs, filtres (période, type, statut, caissier, client,
/// caisse, session, montant), tableau des paniers et actions Détail / Modifier / Annuler.
class VentesPage extends ConsumerStatefulWidget {
  const VentesPage({super.key});

  @override
  ConsumerState<VentesPage> createState() => _VentesPageState();
}

class _VentesPageState extends ConsumerState<VentesPage> {
  DsPeriode _periode = DsPeriode.calculer('today');
  String? _type;
  String? _statut;
  String? _caissier;
  String? _client;
  String? _caisse;
  String? _session;
  DsIntervalle _montant = const DsIntervalle();

  void _reinitialiser() => setState(() {
    _periode = DsPeriode.calculer('today');
    _type = null;
    _statut = null;
    _caissier = null;
    _client = null;
    _caisse = null;
    _session = null;
    _montant = const DsIntervalle();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final tous = ref.watch(paniersProvider(bornesPeriode(_periode))).value ?? const <PanierResume>[];
    final nomsClients = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    final caisses = ref.watch(caissesListeProvider).value ?? const <Caisse>[];
    String nomCaisse(String c) => caisses.where((x) => x.code == c).firstOrNull?.nom ?? c;
    String client(PanierResume p) => nomClientPanier(l10n, p.vente.clientCode, nomsClients);

    final lignes = tous
        .where(
          (p) =>
              (_type == null || p.type == _type) &&
              (_statut == null || p.statut == _statut) &&
              (_caissier == null || p.caissier == _caissier) &&
              (_client == null || p.vente.clientCode == _client) &&
              (_caisse == null || p.vente.caisseCode == _caisse) &&
              (_session == null || p.vente.sessionCode == _session) &&
              (_montant.min == null || p.vente.totalNet >= _montant.min!) &&
              (_montant.max == null || p.vente.totalNet <= _montant.max!),
        )
        .toList();
    final actifs = lignes.where((p) => !p.annule).toList();
    double somme(Iterable<PanierResume> ps, double Function(PanierResume) f) => ps.fold(0.0, (s, p) => s + f(p));
    final voirAchat = ref.watch(permissionProvider(Permission.voirPrixAchat));
    final peutAnnuler = ref.watch(permissionProvider(Permission.annulerVente));

    final colonnes = <DsColonne<PanierResume>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        valeur: (p) => p.vente.date,
        attenue: true,
        cellule: (_, p) => Text(formatDateHeure.format(p.vente.date)),
      ),
      DsColonne(id: 'client', libelle: l10n.ventesClient, valeur: client, fort: true, flex: 2),
      DsColonne(
        id: 'type',
        libelle: l10n.ventesType,
        valeur: (p) => p.type,
        cellule: (_, p) => DsStatusBadge(statut: p.type, libelle: libelleStatut(l10n, p.type), point: false),
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.ventesMontant,
        numerique: true,
        valeur: (p) => p.vente.totalNet,
        cellule: (_, p) => Text(da(p.vente.totalNet)),
        total: (ps) => da(somme(ps.where((p) => !p.annule), (p) => p.vente.totalNet)),
      ),
      DsColonne(
        id: 'paye',
        libelle: l10n.ventesPaye,
        numerique: true,
        valeur: (p) => p.paye,
        cellule: (_, p) => Text(da(p.paye)),
        total: (ps) => da(somme(ps.where((p) => !p.annule), (p) => p.paye)),
      ),
      DsColonne(
        id: 'reste',
        libelle: l10n.ventesReste,
        numerique: true,
        valeur: (p) => p.resteActuel,
        cellule: (context, p) => p.resteActuel > 0
            ? Text(
                da(p.resteActuel),
                style: TextStyle(fontWeight: FontWeight.w600, color: context.ds.colors.warningFg),
              )
            : const Text('—'),
        total: (ps) => da(somme(ps.where((p) => !p.annule), (p) => p.resteActuel)),
      ),
      DsColonne(id: 'mode', libelle: l10n.ventesPaiement, valeur: (p) => libelleModes(context, p.modes)),
      DsColonne(id: 'caissier', libelle: l10n.ventesCaissier, valeur: (p) => p.caissier),
      DsColonne(
        id: 'statut',
        libelle: l10n.ventesStatut,
        valeur: (p) => p.statut,
        cellule: (_, p) => BadgeStatut(p.statut),
      ),
      DsColonne(
        id: 'n',
        libelle: l10n.ventesArticles,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => p.nbArticles,
      ),
      DsColonne(
        id: 'q',
        libelle: l10n.ventesQuantite,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => p.quantite,
        cellule: (_, p) => Text(formaterNombre(p.quantite)),
      ),
      DsColonne(
        id: 'nbv',
        libelle: l10n.ventesNbVersements,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => p.nbVersements,
      ),
      DsColonne(
        id: 'achat',
        libelle: l10n.ventesMontantAchat,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (p) => p.totalAchat,
        cellule: (_, p) => Text(da(p.totalAchat)),
      ),
      DsColonne(
        id: 'marge',
        libelle: l10n.ventesKpiMarge,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (p) => p.marge,
        cellule: (_, p) => Text(da(p.marge)),
      ),
      DsColonne(
        id: 'caisse',
        libelle: l10n.ventesCaisse,
        visibleParDefaut: false,
        valeur: (p) => nomCaisse(p.vente.caisseCode),
      ),
      DsColonne(
        id: 'session',
        libelle: l10n.ventesSession,
        visibleParDefaut: false,
        valeur: (p) => p.vente.sessionCode,
        mono: true,
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.tiersObservation,
        visibleParDefaut: false,
        valeur: (p) => p.vente.commentaire ?? '',
      ),
      DsColonne(
        id: 'annule_par',
        libelle: l10n.ventesAnnulePar,
        visibleParDefaut: false,
        valeur: (p) => p.annuleePar ?? '',
      ),
      DsColonne(
        id: 'annule_le',
        libelle: l10n.ventesAnnuleLe,
        visibleParDefaut: false,
        valeur: (p) => p.annuleeLe,
        cellule: (_, p) => Text(p.annuleeLe == null ? '' : formatDateHeure.format(p.annuleeLe!)),
      ),
    ];

    Future<void> modifier(PanierResume p) => afficherModifPanier(context, ref, p, nomsClients: nomsClients);
    Future<void> detail(PanierResume p) => afficherDetailPanier(
      context,
      ref,
      p,
      nomsClients: nomsClients,
      onModifier: p.annule ? null : () => modifier(p),
    );

    List<String> distincts(String Function(PanierResume) f) => (tous.map(f).toSet().toList()..sort());

    return PageModule(
      moduleId: 'ventes',
      sousTitre: l10n.ventesDescription,
      actions: [
        DsButton(
          key: const ValueKey('ventes_verifier_chaine'),
          libelle: l10n.ventesVerifierChaine,
          icone: LucideIcons.shieldCheck,
          variante: DsButtonVariante.secondaire,
          onPressed: _verifierChaine,
        ),
      ],
      child: DsModuleTable<PanierResume>(
        entite: l10n.ventesEntitePluriel,
        lignes: lignes,
        colonnes: colonnes,
        cle: (p) => p.code,
        afficherTotaux: true,
        filtresOuverts: true,
        colonnesFiltres: 4,
        permissions: permissionsSession(ref),
        messageVide: l10n.ventesAucune,
        kpis: [
          DsStatCard(libelle: l10n.ventesKpiNombre, valeur: '${actifs.length}', icone: LucideIcons.receipt),
          DsStatCard(
            libelle: l10n.ventesKpiCa,
            valeur: f2(somme(actifs, (p) => p.vente.totalNet)),
            suffixe: devise,
            icone: LucideIcons.banknote,
          ),
          if (voirAchat)
            DsStatCard(
              libelle: l10n.ventesKpiMarge,
              valeur: f2(somme(actifs, (p) => p.marge)),
              suffixe: devise,
              icone: LucideIcons.trendingUp,
            ),
          DsStatCard(
            libelle: l10n.ventesKpiEncaisse,
            valeur: f2(somme(actifs, (p) => p.paye)),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
          DsStatCard(
            libelle: l10n.ventesKpiCredit,
            valeur: f2(somme(actifs, (p) => p.resteActuel)),
            suffixe: devise,
            icone: LucideIcons.handCoins,
          ),
        ],
        periode: _periode,
        onPeriode: (p) => setState(() => _periode = p),
        indiceRecherche: l10n.ventesRechercheIndice,
        texteRecherche: (p) => '${p.code} ${client(p)}',
        nbFiltresActifs:
            [_type, _statut, _caissier, _client, _caisse, _session].where((f) => f != null).length +
            (_montant.estVide ? 0 : 1),
        onReinitialiser: _reinitialiser,
        filtres: [
          _filtre<String?>(
            l10n.ventesType,
            cle: 'filtre_type_panier',
            valeur: _type,
            options: const [null, 'ticket', 'facture'],
            libelle: (v) => v == null ? l10n.ventesTous : libelleStatut(l10n, v),
            onChanged: (v) => setState(() => _type = v),
          ),
          _filtre<String?>(
            l10n.ventesStatut,
            cle: 'filtre_statut_panier',
            valeur: _statut,
            options: const [null, 'paye', 'credit', 'retourne', 'annule'],
            libelle: (v) => v == null ? l10n.ventesTous : libelleStatut(l10n, v),
            onChanged: (v) => setState(() => _statut = v),
          ),
          _filtre<String?>(
            l10n.ventesCaissier,
            valeur: _caissier,
            options: [null, ...distincts((p) => p.caissier)],
            libelle: (v) => v ?? l10n.ventesTous,
            onChanged: (v) => setState(() => _caissier = v),
          ),
          _filtre<String?>(
            l10n.ventesClient,
            valeur: _client,
            options: [null, ...distincts((p) => p.vente.clientCode)],
            libelle: (v) => v == null ? l10n.ventesTous : nomClientPanier(l10n, v, nomsClients),
            onChanged: (v) => setState(() => _client = v),
          ),
          _filtre<String?>(
            l10n.ventesCaisse,
            valeur: _caisse,
            options: [null, ...caisses.map((c) => c.code)],
            libelle: (v) => v == null ? l10n.ventesToutes : nomCaisse(v),
            onChanged: (v) => setState(() => _caisse = v),
          ),
          _filtre<String?>(
            l10n.ventesSession,
            valeur: _session,
            options: [null, ...distincts((p) => p.vente.sessionCode).reversed],
            libelle: (v) => v ?? l10n.ventesToutes,
            onChanged: (v) => setState(() => _session = v),
          ),
          DsFormRow(
            libelle: l10n.ventesMontant,
            largeurLibelle: 64,
            child: DsRangeFilter(
              valeur: _montant,
              unite: devise,
              libelleEffacer: l10n.dsEffacer,
              libelleValider: l10n.dsValider,
              onChanged: (v) => setState(() => _montant = v),
            ),
          ),
        ],
        onExport: peutExporter(ref)
            ? (format, ps) => exporterTableau(
                context,
                ref,
                id: 'ventes',
                titre: l10n.moduleVentes,
                colonnes: colonnes,
                lignes: ps,
                format: format,
              )
            : null,
        onOuvrir: detail,
        actions: [
          DsActionModule(
            libelle: l10n.tiersDetail,
            icone: LucideIcons.eye,
            regle: DsRegleSelection.une,
            detail: true,
            onPressed: (choix, _) => detail(choix.first),
          ),
          DsActionModule(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && choix.first.annule,
            onPressed: (choix, _) => modifier(choix.first),
          ),
          if (peutAnnuler)
            DsActionModule(
              libelle: l10n.dsAnnuler,
              icone: LucideIcons.ban,
              danger: true,
              onPressed: (choix, effacer) => annulerPaniers(context, ref, choix, effacer, nomsClients: nomsClients),
            ),
        ],
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.ventesCreerRetour,
            icone: LucideIcons.undo2,
            onSelected: (p) {
              if (!p.annule) afficherNouveauRetour(context, ref, venteCode: p.code);
            },
          ),
        ],
        primaire: DsButton(
          key: const ValueKey('ventes_nouvelle'),
          libelle: l10n.ventesNouvelle,
          icone: LucideIcons.monitorSmartphone,
          onPressed: () => context.go('/caisse'),
        ),
      ),
    );
  }

  Widget _filtre<T>(
    String titre, {
    String? cle,
    required T valeur,
    required List<T> options,
    required String Function(T) libelle,
    required ValueChanged<T> onChanged,
  }) => DsFormRow(
    libelle: titre,
    largeurLibelle: 64,
    child: DsSelect<T>(
      key: cle == null ? null : ValueKey(cle),
      valeur: valeur,
      options: options,
      libelle: libelle,
      onChanged: (v) => onChanged(v as T),
    ),
  );

  Future<void> _verifierChaine() async {
    final l10n = AppLocalizations.of(context);
    final ko = await ref.read(venteServiceProvider).verifierChaine();
    if (!mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: ko == null ? DsResultatType.succes : DsResultatType.erreur,
        titre: l10n.ventesVerifierChaine,
        message: ko == null ? l10n.ventesChaineOk : l10n.ventesChaineKo(ko),
      ),
    );
  }
}
