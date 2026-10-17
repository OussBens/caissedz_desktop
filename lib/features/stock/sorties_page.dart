import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/stock.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../tableau_bord/tableau_bord_page.dart';
import 'stock_dialogs.dart';
import 'stock_providers.dart';

/// Écran Sorties (`SortiesScreen` du DS v2.2) : sorties de stock hors vente (casse, périmé, perte, consommation
/// interne, don, échantillon) ; KPI, filtres Type / Magasin, détail, modification, annulation avec motif.
class SortiesPage extends ConsumerStatefulWidget {
  const SortiesPage({super.key});

  @override
  ConsumerState<SortiesPage> createState() => _SortiesPageState();
}

class _SortiesPageState extends ConsumerState<SortiesPage> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _type;
  String? _magasin;
  String? _produit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final toutes = ref.watch(sortiesProvider).value ?? const <SortieStock>[];
    final magasins = ref.watch(magasinsProvider).value ?? const <Magasin>[];
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final noms = {for (final m in magasins) m.code: m.nom};
    final lignes = toutes
        .where(
          (s) =>
              dansPeriode(s.date, _periode) &&
              (_type == null || s.motif == _type) &&
              (_magasin == null || s.magasinCode == _magasin) &&
              (_produit == null || s.lignes.any((l) => l.produitCode == _produit)),
        )
        .toList();
    final actives = lignes.where((s) => s.actif);
    final (duAvant, auAvant) = periodePrecedente(_periode.du, _periode.au);
    final avant = toutes
        .where((s) => s.actif && dansPeriode(s.date, DsPeriode(du: duAvant, au: auAvant)))
        .fold(0.0, (a, s) => a + s.valeur);
    final perdue = actives.fold(0.0, (a, s) => a + s.valeur);
    final achat = permissionsSession(ref).contains(Permission.voirPrixAchat.code);

    final colonnes = <DsColonne<SortieStock>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (s) => s.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (s) => s.date,
        cellule: (_, s) => Text(formatDateHeure.format(s.date)),
      ),
      DsColonne(id: 'type', libelle: l10n.stockColType, fort: true, valeur: (s) => libelleMotif(l10n, s.motif)),
      DsColonne(id: 'mag', libelle: l10n.stockColMagasin, flex: 2, valeur: (s) => noms[s.magasinCode] ?? s.magasinCode),
      DsColonne(
        id: 'n',
        libelle: l10n.stkArticles,
        numerique: true,
        valeur: (s) => s.lignes.length,
        total: (ss) => '${ss.fold(0, (a, s) => a + s.lignes.length)}',
      ),
      DsColonne(
        id: 'valeur',
        libelle: l10n.stockColValeur,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: (s) => s.valeur,
        cellule: (_, s) => Text(da(s.valeur)),
        total: (ss) => da(ss.where((s) => s.actif).fold(0.0, (a, s) => a + s.valeur)),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (s) => s.actif ? 1 : 0,
        cellule: (_, s) => BadgeStatut(s.actif ? 'actif' : 'annule'),
      ),
      DsColonne(
        id: 'q',
        libelle: l10n.stockColQuantite,
        numerique: true,
        visibleParDefaut: false,
        valeur: (s) => s.quantite,
        cellule: (_, s) => Text(formaterNombre(s.quantite)),
      ),
      DsColonne(id: 'obs', libelle: l10n.stkMotif, visibleParDefaut: false, valeur: (s) => s.commentaire ?? ''),
      DsColonne(
        id: 'annule_par',
        libelle: l10n.ventesAnnulePar,
        visibleParDefaut: false,
        valeur: (s) => s.annulation == null ? '' : (utilisateurs[s.annulation!.par] ?? s.annulation!.par),
      ),
      DsColonne(
        id: 'motif_annulation',
        libelle: l10n.ventesMotifAnnulation,
        visibleParDefaut: false,
        valeur: (s) => s.annulation?.motif ?? '',
      ),
      ...colonnesAudit(context, ref, (SortieStock x) => x.audit),
    ];

    return PageModule(
      moduleId: 'sorties',
      sousTitre: l10n.stkDescriptionSorties,
      child: DsModuleTable<SortieStock>(
        entite: l10n.stkEntiteSorties,
        lignes: lignes,
        colonnes: colonnes,
        cle: (s) => s.code,
        afficherTotaux: true,
        permissions: permissionsSession(ref),
        messageVide: l10n.stkAucuneSortie,
        kpis: [
          DsStatCard(libelle: l10n.stkKpiSorties, valeur: '${actives.length}', icone: LucideIcons.packageMinus),
          DsStatCard(
            libelle: l10n.stkKpiArticlesSortis,
            valeur: '${actives.fold(0, (a, s) => a + s.lignes.length)}',
            icone: LucideIcons.boxes,
          ),
          if (achat)
            DsStatCard(
              libelle: l10n.stkKpiValeurPerdue,
              valeur: f2(perdue),
              suffixe: devise,
              icone: LucideIcons.wallet,
              tendance: avant <= 0 ? null : (perdue - avant) / avant * 100,
              tendanceInverser: true,
            ),
        ],
        periode: _periode,
        onPeriode: (p) => setState(() => _periode = p),
        periodeSeule: true,
        texteRecherche: (s) => '${s.code} ${libelleMotif(l10n, s.motif)} ${noms[s.magasinCode] ?? ''}',
        nbFiltresActifs: [_type, _magasin, _produit].where((f) => f != null).length,
        onReinitialiser: () => setState(() {
          _type = null;
          _magasin = null;
          _produit = null;
          _periode = DsPeriode.calculer('month');
        }),
        filtres: [
          DsFormRow(
            libelle: l10n.stockColType,
            largeurLibelle: 80,
            child: DsSelect<String?>(
              cle: const ValueKey('sorties_filtre_type'),
              valeur: _type,
              options: [null, for (final v in Referentiel.motifsSortie.valeurs) v.stocke],
              libelle: (t) => t == null ? l10n.retoursTous : libelleMotif(l10n, t),
              onChanged: (v) => setState(() => _type = v),
            ),
          ),
          DsFormRow(
            libelle: l10n.stockColMagasin,
            largeurLibelle: 80,
            child: DsSelect<String?>(
              valeur: _magasin,
              options: [null, for (final m in magasins) m.code],
              libelle: (c) => c == null ? l10n.retoursTous : (noms[c] ?? c),
              recherche: rechercheListe(context, ref, ListeMetier.magasin),
              onChanged: (v) => setState(() => _magasin = v),
            ),
          ),
          filtreProduit(
            context,
            ref,
            cle: const ValueKey('sorties_filtre_produit'),
            valeur: _produit,
            onChanged: (v) => setState(() => _produit = v),
          ),
        ],
        onExport: peutExporter(ref)
            ? (format, ss) => exporterTableau(
                context,
                ref,
                id: 'sorties',
                titre: l10n.stkEntiteSorties,
                colonnes: colonnes,
                lignes: ss,
                format: format,
              )
            : null,
        onOuvrir: (s) => afficherDetailSortie(context, ref, s),
        actions: [
          DsActionModule(
            libelle: l10n.tiersDetail,
            icone: LucideIcons.eye,
            regle: DsRegleSelection.une,
            detail: true,
            onPressed: (choix, _) => afficherDetailSortie(context, ref, choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('sorties_liste_produits'),
            libelle: l10n.stkListeProduits,
            icone: LucideIcons.listOrdered,
            regle: DsRegleSelection.une,
            onPressed: (choix, _) => afficherProduitsSortie(context, ref, choix.first),
          ),
          DsActionModule(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            iconeSeule: true,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && (!choix.first.actif || choix.first.retourCode != null),
            onPressed: (choix, _) => afficherFormulaireSortie(context, ref, sortie: choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('sorties_annuler'),
            libelle: l10n.dsAnnuler,
            icone: LucideIcons.x,
            iconeSeule: true,
            danger: true,
            onPressed: (choix, effacer) => annulerSorties(context, ref, choix, effacer),
          ),
        ],
        primaire: DsButton(
          key: const ValueKey('sortie_nouvelle'),
          libelle: l10n.stkNouvelleSortie,
          icone: LucideIcons.plus,
          onPressed: () => afficherFormulaireSortie(context, ref),
        ),
      ),
    );
  }
}
