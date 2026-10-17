import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/permissions.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import 'stock_dialogs.dart';
import 'stock_providers.dart';

/// Écran Magasins (`MagasinsScreen` du DS v2.2, licence Avancé) : onglets Magasins et Transferts.
class MagasinsPage extends ConsumerStatefulWidget {
  const MagasinsPage({super.key, this.ongletInitial = 0});

  /// 0 = magasins, 1 = transferts.
  final int ongletInitial;

  @override
  ConsumerState<MagasinsPage> createState() => _MagasinsPageState();
}

class _MagasinsPageState extends ConsumerState<MagasinsPage> {
  late int _onglet = widget.ongletInitial;
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _source;
  String? _destination;
  bool? _actif;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final magasins = ref.watch(magasinsProvider).value ?? const <Magasin>[];
    final transferts = ref.watch(transfertsProvider).value ?? const <TransfertStock>[];
    return PageModule(
      moduleId: 'magasins',
      sousTitre: l10n.stkDescriptionMagasins,
      actions: [DsBadge(libelle: l10n.stkPalierAvance, ton: DsBadgeTon.primaire, icone: LucideIcons.sparkles)],
      onglets: [l10n.stkOngletMagasins, l10n.stkOngletTransferts],
      comptes: [magasins.length, transferts.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0 ? _magasins(l10n, magasins, transferts) : _transferts(l10n, magasins, transferts),
    );
  }

  Widget _magasins(AppLocalizations l10n, List<Magasin> magasins, List<TransfertStock> transferts) {
    final devise = ref.watch(deviseProvider);
    final produits = {for (final p in ref.watch(produitsProvider).value ?? const <Produit>[]) p.code: p};
    final stocks = ref.watch(stocksParMagasinProvider).value ?? const <String, Map<String, double>>{};
    final utilisateurs = ref.watch(utilisateursParMagasinProvider).value ?? const <String, List<String>>{};
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final nbProduits = <String, int>{};
    final valeurs = <String, double>{};
    for (final MapEntry(key: p, value: parMagasin) in stocks.entries) {
      for (final MapEntry(key: m, value: q) in parMagasin.entries) {
        if (q.abs() > 1e-9) nbProduits[m] = (nbProduits[m] ?? 0) + 1;
        valeurs[m] = (valeurs[m] ?? 0) + q * (produits[p]?.prixAchat ?? 0);
      }
    }
    final colonnes = <DsColonne<Magasin>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (m) => m.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.stkMagasin, valeur: (m) => m.nom, fort: true, flex: 2),
      DsColonne(id: 'adresse', libelle: l10n.stkAdresse, valeur: (m) => m.adresse, attenue: true, flex: 2),
      DsColonne(
        id: 'produits',
        libelle: l10n.produitsOngletProduits,
        numerique: true,
        valeur: (m) => nbProduits[m.code] ?? 0,
      ),
      DsColonne(
        id: 'valeur',
        libelle: l10n.stkValeurStock,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: (m) => valeurs[m.code] ?? 0,
        cellule: (_, m) => Text(formaterMontant(valeurs[m.code] ?? 0, devise)),
      ),
      DsColonne(
        id: 'users',
        libelle: l10n.stkUtilisateurs,
        numerique: true,
        valeur: (m) => utilisateurs[m.code]?.length ?? 0,
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (m) => m.actif ? 1 : 0,
        cellule: (_, m) => BadgeStatut(m.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(id: 'tel', libelle: l10n.stkTelephone, visibleParDefaut: false, valeur: (m) => m.telephone),
      DsColonne(
        id: 'resp',
        libelle: l10n.stkResponsable,
        visibleParDefaut: false,
        valeur: (m) => m.responsableCode == null ? '' : (noms[m.responsableCode] ?? m.responsableCode!),
      ),
      DsColonne(id: 'obs', libelle: l10n.retoursObservation, visibleParDefaut: false, valeur: (m) => m.observation),
      ...colonnesAudit(context, ref, (Magasin x) => x.audit),
    ];
    final achat = permissionsSession(ref).contains(Permission.voirPrixAchat.code);
    return DsModuleTable<Magasin>(
      key: const ValueKey('magasins'),
      entite: l10n.stkEntiteMagasins,
      lignes: magasins,
      colonnes: colonnes,
      cle: (m) => m.code,
      permissions: permissionsSession(ref),
      kpis: [
        DsStatCard(
          libelle: l10n.stkKpiMagasinsActifs,
          valeur: '${magasins.where((m) => m.actif).length}',
          icone: LucideIcons.store,
        ),
        if (achat)
          DsStatCard(
            libelle: l10n.stkKpiValeurTotale,
            valeur: f2(valeurs.values.fold(0.0, (a, b) => a + b)),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
        DsStatCard(
          libelle: l10n.stkKpiUtilisateursRattaches,
          valeur: '${utilisateurs.values.expand((u) => u).toSet().length}',
          icone: LucideIcons.users,
        ),
      ],
      texteRecherche: (m) => '${m.code} ${m.nom} ${m.adresse}',
      onExport: peutExporter(ref)
          ? (format, ms) => exporterTableau(
              context,
              ref,
              id: 'magasins',
              titre: l10n.stkOngletMagasins,
              colonnes: colonnes,
              lignes: ms,
              format: format,
            )
          : null,
      onOuvrir: (m) => afficherDetailMagasin(context, ref, m),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailMagasin(context, ref, choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          iconeSeule: true,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherFormulaireMagasin(context, ref, magasin: choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('magasins_desactiver'),
          libelle: l10n.stkDesactiver,
          icone: LucideIcons.circlePause,
          danger: true,
          onPressed: (choix, effacer) => desactiverMagasins(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('magasin_nouveau'),
        libelle: l10n.stkNouveauMagasin,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireMagasin(context, ref),
      ),
    );
  }

  Widget _transferts(AppLocalizations l10n, List<Magasin> magasins, List<TransfertStock> tous) {
    final noms = {for (final m in magasins) m.code: m.nom};
    final lignes = tous
        .where(
          (t) =>
              dansPeriode(t.date, _periode) &&
              (_source == null || t.magasinSource == _source) &&
              (_destination == null || t.magasinDestination == _destination) &&
              (_actif == null || t.actif == _actif),
        )
        .toList();
    final colonnes = <DsColonne<TransfertStock>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (t) => t.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (t) => t.date,
        cellule: (_, t) => Text(formatDate.format(t.date)),
      ),
      DsColonne(id: 'src', libelle: l10n.stkDepuis, flex: 2, valeur: (t) => noms[t.magasinSource] ?? t.magasinSource),
      DsColonne(
        id: 'dst',
        libelle: l10n.stkVers,
        fort: true,
        flex: 2,
        valeur: (t) => noms[t.magasinDestination] ?? t.magasinDestination,
      ),
      DsColonne(id: 'n', libelle: l10n.stkArticles, numerique: true, valeur: (t) => t.lignes.length),
      DsColonne(
        id: 'q',
        libelle: l10n.stockColQuantite,
        numerique: true,
        valeur: (t) => t.quantite,
        cellule: (_, t) => Text(formaterNombre(t.quantite)),
        total: (ts) => formaterNombre(ts.where((t) => t.actif).fold(0.0, (a, t) => a + t.quantite)),
      ),
      DsColonne(
        id: 'statut',
        libelle: l10n.stkStatut,
        valeur: (t) => t.actif ? 1 : 0,
        cellule: (_, t) => BadgeStatut(t.actif ? 'valide' : 'annule'),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (t) => t.commentaire ?? '',
      ),
      DsColonne(
        id: 'motif_annulation',
        libelle: l10n.ventesMotifAnnulation,
        visibleParDefaut: false,
        valeur: (t) => t.annulation?.motif ?? '',
      ),
      ...colonnesAudit(context, ref, (TransfertStock x) => x.audit),
    ];
    return DsModuleTable<TransfertStock>(
      key: const ValueKey('transferts'),
      entite: l10n.stkEntiteTransferts,
      lignes: lignes,
      colonnes: colonnes,
      cle: (t) => t.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.stkAucunTransfert,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      periodeSeule: true,
      texteRecherche: (t) => '${t.code} ${noms[t.magasinSource] ?? ''} ${noms[t.magasinDestination] ?? ''}',
      nbFiltresActifs: [_source, _destination, _actif].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _source = null;
        _destination = null;
        _actif = null;
        _periode = DsPeriode.calculer('month');
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.stkDepuis,
          largeurLibelle: 80,
          child: DsSelect<String?>(
            valeur: _source,
            options: [null, for (final m in magasins) m.code],
            libelle: (c) => c == null ? l10n.retoursTous : (noms[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.magasin),
            onChanged: (v) => setState(() => _source = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.stkVers,
          largeurLibelle: 80,
          child: DsSelect<String?>(
            valeur: _destination,
            options: [null, for (final m in magasins) m.code],
            libelle: (c) => c == null ? l10n.retoursTous : (noms[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.magasin),
            onChanged: (v) => setState(() => _destination = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.stkStatut,
          largeurLibelle: 80,
          child: DsSelect<bool?>(
            valeur: _actif,
            options: const [null, true, false],
            libelle: (a) => a == null ? l10n.retoursTous : libelleStatut(l10n, a ? 'valide' : 'annule'),
            onChanged: (v) => setState(() => _actif = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ts) => exporterTableau(
              context,
              ref,
              id: 'transferts',
              titre: l10n.stkOngletTransferts,
              colonnes: colonnes,
              lignes: ts,
              format: format,
            )
          : null,
      onOuvrir: (t) => afficherDetailTransfert(context, ref, t),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailTransfert(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('transferts_liste_produits'),
          libelle: l10n.stkListeProduits,
          icone: LucideIcons.listOrdered,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherProduitsTransfert(context, ref, choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          iconeSeule: true,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && !choix.first.actif,
          onPressed: (choix, _) => afficherFormulaireTransfert(context, ref, transfert: choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('transferts_annuler'),
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.x,
          iconeSeule: true,
          danger: true,
          onPressed: (choix, effacer) => annulerTransferts(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('transfert_nouveau'),
        libelle: l10n.stkNouveauTransfert,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireTransfert(context, ref),
      ),
    );
  }
}
