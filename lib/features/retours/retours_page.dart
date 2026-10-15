import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/permissions.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';
import 'retours_dialogs.dart';

/// Écran Retours (`RetoursScreen` du DS v2.2) : onglets Retours clients / Retours fournisseurs, KPIs,
/// filtres (période, tiers, règlement, état), tableau et actions Détail / Modifier / Annuler.
class RetoursPage extends ConsumerStatefulWidget {
  const RetoursPage({super.key, this.ongletInitial = 0});

  /// 0 = retours clients, 1 = retours fournisseurs.
  final int ongletInitial;

  @override
  ConsumerState<RetoursPage> createState() => _RetoursPageState();
}

class _RetoursPageState extends ConsumerState<RetoursPage> {
  late int _onglet = widget.ongletInitial;
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _tiers;
  String? _reglement;
  bool? _actif;

  String get _type => _onglet == 0 ? TypesTiers.client : TypesTiers.fournisseur;

  void _reinitialiser() => setState(() {
    _periode = DsPeriode.calculer('month');
    _tiers = null;
    _reglement = null;
    _actif = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final tous = ref.watch(retoursProvider).value ?? const <Retour>[];
    final client = _type == TypesTiers.client;
    final noms = client
        ? {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom}
        : {for (final f in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[]) f.code: f.nom};
    final prixVente = {for (final p in ref.watch(produitsProvider).value ?? const <Produit>[]) p.code: p.prixVente};
    final duType = tous.where((r) => r.type == _type).toList();
    final lignes = duType
        .where(
          (r) =>
              dansPeriode(r.date, _periode) &&
              (_tiers == null || r.tiersCode == _tiers) &&
              (_reglement == null || r.reglement == _reglement) &&
              (_actif == null || r.actif == _actif),
        )
        .toList();
    final actifs = lignes.where((r) => r.actif);
    String tiers(Retour r) => nomTiersRetour(l10n, r, noms);
    double pv(Retour r) => r.estClient ? (r.ligne?.prixUnitaire ?? 0) : (prixVente[r.ligne?.produitCode] ?? 0);

    final colonnes = <DsColonne<Retour>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (r) => r.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        valeur: (r) => r.date,
        attenue: true,
        cellule: (_, r) => Text(formatDate.format(r.date)),
      ),
      DsColonne(
        id: 'tiers',
        libelle: client ? l10n.retoursClient : l10n.retoursFournisseur,
        valeur: tiers,
        fort: true,
        flex: 2,
      ),
      DsColonne(id: 'origine', libelle: l10n.retoursOrigine, valeur: (r) => r.documentCode, attenue: true),
      DsColonne(id: 'produit', libelle: l10n.retoursProduit, valeur: (r) => r.ligne?.designation ?? '', flex: 2),
      DsColonne(
        id: 'qte',
        libelle: l10n.retoursQte,
        numerique: true,
        valeur: (r) => r.quantite,
        cellule: (_, r) => Text(formaterNombre(r.quantite)),
        total: (rs) => formaterNombre(rs.where((r) => r.actif).fold(0.0, (s, r) => s + r.quantite)),
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.retoursMontant,
        numerique: true,
        valeur: (r) => r.total,
        cellule: (_, r) => Text(da(r.total)),
        total: (rs) => da(rs.where((r) => r.actif).fold(0.0, (s, r) => s + r.total)),
      ),
      DsColonne(
        id: 'reglement',
        libelle: client ? l10n.retoursRemboursement : l10n.retoursReglement,
        valeur: (r) => libelleReglementRetour(l10n, r.type, r.reglement),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (r) => r.actif ? 1 : 0,
        cellule: (_, r) => BadgeStatut(r.actif ? 'actif' : 'annule'),
      ),
      DsColonne(
        id: 'achat',
        libelle: l10n.retoursPrixAchat,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (r) => r.ligne?.prixAchat ?? 0,
        cellule: (_, r) => Text(da(r.ligne?.prixAchat ?? 0)),
      ),
      DsColonne(
        id: 'vente',
        libelle: l10n.retoursPrixVente,
        numerique: true,
        visibleParDefaut: false,
        valeur: pv,
        cellule: (_, r) => Text(da(pv(r))),
      ),
      DsColonne(id: 'obs', libelle: l10n.retoursObservation, visibleParDefaut: false, valeur: (r) => r.motif ?? ''),
      DsColonne(
        id: 'serie',
        libelle: l10n.retoursNumSerie,
        visibleParDefaut: false,
        valeur: (r) => r.numeroSerie ?? '',
      ),
      DsColonne(id: 'cree_par', libelle: l10n.ventesCreePar, visibleParDefaut: false, valeur: (r) => r.utilisateurCode),
      DsColonne(
        id: 'annule_par',
        libelle: l10n.ventesAnnulePar,
        visibleParDefaut: false,
        valeur: (r) => r.annulePar ?? '',
      ),
      DsColonne(
        id: 'motif_annulation',
        libelle: l10n.ventesMotifAnnulation,
        visibleParDefaut: false,
        valeur: (r) => r.motifAnnulation ?? '',
      ),
    ];

    Future<void> modifier(Retour r) => afficherFormulaireRetour(context, ref, retour: r);
    Future<void> detail(Retour r) => afficherDetailRetour(
      context,
      ref,
      r,
      nomsTiers: noms,
      prixVenteCatalogue: prixVente[r.ligne?.produitCode],
      onModifier: r.actif ? () => modifier(r) : null,
    );
    final codesTiers = (duType.map((r) => r.tiersCode).toSet().toList()
      ..sort((a, b) => (noms[a] ?? a).compareTo(noms[b] ?? b)));

    return PageModule(
      moduleId: 'retours',
      sousTitre: l10n.retoursDescription,
      onglets: [l10n.retoursOngletClients, l10n.retoursOngletFournisseurs],
      comptes: [
        tous.where((r) => r.type == TypesTiers.client).length,
        tous.where((r) => r.type == TypesTiers.fournisseur).length,
      ],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() {
        _onglet = i;
        _tiers = null;
        _reglement = null;
      }),
      child: DsModuleTable<Retour>(
        key: ValueKey('retours_$_type'),
        entite: l10n.retoursEntitePluriel,
        lignes: lignes,
        colonnes: colonnes,
        cle: (r) => r.code,
        afficherTotaux: true,
        permissions: permissionsSession(ref),
        messageVide: l10n.retoursAucun,
        kpis: [
          DsStatCard(libelle: l10n.retoursKpiNombre, valeur: '${actifs.length}', icone: LucideIcons.undo2),
          DsStatCard(
            libelle: l10n.retoursKpiQuantite,
            valeur: formaterNombre(actifs.fold(0.0, (s, r) => s + r.quantite)),
            icone: LucideIcons.boxes,
          ),
          DsStatCard(
            libelle: client ? l10n.retoursKpiRembourse : l10n.retoursKpiDeduit,
            valeur: f2(actifs.fold(0.0, (s, r) => s + r.total)),
            suffixe: devise,
            icone: LucideIcons.banknote,
          ),
        ],
        periode: _periode,
        onPeriode: (p) => setState(() => _periode = p),
        colonnesFiltres: 3,
        indiceRecherche: l10n.retoursRecherche,
        texteRecherche: (r) => '${r.code} ${tiers(r)} ${r.ligne?.designation ?? ''}',
        nbFiltresActifs: [_tiers, _reglement, _actif].where((f) => f != null).length,
        onReinitialiser: _reinitialiser,
        filtres: [
          DsFormRow(
            libelle: client ? l10n.retoursClient : l10n.retoursFournisseur,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              valeur: _tiers,
              options: [null, ...codesTiers],
              libelle: (c) =>
                  c == null ? l10n.retoursTous : (client && c == 'CLN0000' ? l10n.posClientPassage : (noms[c] ?? c)),
              recherche: rechercheListe(context, ref, client ? ListeMetier.client : ListeMetier.fournisseur),
              onChanged: (v) => setState(() => _tiers = v),
            ),
          ),
          DsFormRow(
            libelle: client ? l10n.retoursRemboursement : l10n.retoursReglement,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              key: const ValueKey('filtre_reglement_retour'),
              valeur: _reglement,
              options: [null, ...(client ? ReglementsRetour.client : ReglementsRetour.fournisseur)],
              libelle: (r) => r == null ? l10n.retoursTous : libelleReglementRetour(l10n, _type, r),
              onChanged: (v) => setState(() => _reglement = v),
            ),
          ),
          DsFormRow(
            libelle: l10n.retoursEtat,
            largeurLibelle: 90,
            child: DsSelect<bool?>(
              key: const ValueKey('filtre_etat_retour'),
              valeur: _actif,
              options: const [null, true, false],
              libelle: (a) => a == null ? l10n.retoursTous : libelleStatut(l10n, a ? 'actif' : 'annule'),
              onChanged: (v) => setState(() => _actif = v),
            ),
          ),
        ],
        onExport: peutExporter(ref)
            ? (format, rs) => exporterTableau(
                context,
                ref,
                id: 'retours',
                titre: client ? l10n.retoursOngletClients : l10n.retoursOngletFournisseurs,
                colonnes: colonnes,
                lignes: rs,
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
            desactive: (choix) => choix.isNotEmpty && !choix.first.actif,
            onPressed: (choix, _) => modifier(choix.first),
          ),
          DsActionModule(
            libelle: l10n.dsAnnuler,
            icone: LucideIcons.ban,
            danger: true,
            onPressed: (choix, effacer) => annulerRetours(context, ref, choix, effacer, nomsTiers: noms),
          ),
        ],
        primaire: DsButton(
          key: const ValueKey('retour_nouveau'),
          libelle: l10n.retoursNouveau,
          icone: LucideIcons.plus,
          onPressed: () => afficherFormulaireRetour(context, ref, type: _type),
        ),
      ),
    );
  }
}
