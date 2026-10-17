import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/situation_repository.dart';
import '../../data/statistiques_repository.dart';
import '../../domain/models/rapport.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'situation_onglet.dart';

final situationRepositoryProvider = Provider<SituationRepository>(
  (ref) => SituationRepository(ref.watch(appDatabaseProvider).db),
);

/// Données du tableau de bord v2.2 (`DashboardV22`) pour une période et la période précédente de même durée.
class DonneesTableauBord {
  const DonneesTableauBord({
    required this.ventes,
    required this.ventesAvant,
    required this.achats,
    required this.detteFournisseurs,
    required this.creditClients,
    required this.jours,
    required this.courant,
    required this.precedent,
    required this.paiements,
    required this.caissiers,
    required this.topProduits,
    required this.dernieresVentes,
    required this.ruptures,
  });
  final double ventes;
  final double ventesAvant;
  final double achats;
  final double detteFournisseurs;
  final double creditClients;
  final List<String> jours;
  final List<double> courant;
  final List<double> precedent;
  final List<PointSerie> paiements;
  final List<({String nom, int tickets, double total})> caissiers;
  final List<({String nom, double quantite, double total})> topProduits;
  final List<LigneSituation> dernieresVentes;
  final List<({String code, String nom, double stock})> ruptures;

  double get net => ventes - achats;

  /// Évolution des ventes en % (null sans période précédente).
  double? get tendance => ventesAvant <= 0 ? null : (ventes - ventesAvant) / ventesAvant * 100;
}

/// Période précédente de même durée, juste avant [du].
(DateTime, DateTime) periodePrecedente(DateTime du, DateTime au) {
  final jours = DateTime(au.year, au.month, au.day).difference(DateTime(du.year, du.month, du.day)).inDays + 1;
  final fin = DateTime(du.year, du.month, du.day - 1);
  return (DateTime(fin.year, fin.month, fin.day - (jours - 1)), fin);
}

final tableauBordProvider = FutureProvider.family<DonneesTableauBord, (DateTime, DateTime)>((ref, p) async {
  ref.watch(rapportsVersionProvider);
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  ref.watch(caisseVersionProvider);
  final stats = ref.watch(statistiquesRepositoryProvider);
  final s = ref.watch(situationRepositoryProvider);
  final (du, au) = p;
  final (duAvant, auAvant) = periodePrecedente(du, au);
  final courant = await stats.caParJour(du, au);
  final precedent = await stats.caParJour(duAvant, auAvant);
  final fin = DateTime(au.year, au.month, au.day + 1);
  return DonneesTableauBord(
    ventes: await s.totalVentes(du, au),
    ventesAvant: await s.totalVentes(duAvant, auAvant),
    achats: await s.totalAchats(du, au),
    detteFournisseurs: await stats.dettesFournisseurs(),
    creditClients: await stats.creancesClients(),
    jours: [for (final c in courant) c.etiquette],
    courant: [for (final c in courant) c.valeur],
    precedent: [for (final (i, _) in courant.indexed) i < precedent.length ? precedent[i].valeur : 0],
    paiements: await stats.paiementsParMode(DateTime(du.year, du.month, du.day), fin),
    caissiers: await s.ventesParCaissier(du, au),
    topProduits: await s.topProduits(du, au),
    dernieresVentes: await s.dernieresVentes(),
    ruptures: await s.ruptures(limite: 10, magasins: await magasinsDeLaSession(ref)),
  );
});

/// Mode de période du tableau de bord (`SegmentedControl` Jour / Semaine / Mois / Période).
enum ModePeriode { jour, semaine, mois, periode }

/// Tableau de bord (§9.14, `DashboardV22`) : onglets Tableau de bord / Situation.
class TableauBordPage extends ConsumerStatefulWidget {
  const TableauBordPage({super.key, this.ongletInitial = 0});

  /// 0 = vue d'ensemble, 1 = Situation.
  final int ongletInitial;

  @override
  ConsumerState<TableauBordPage> createState() => _TableauBordPageState();
}

class _TableauBordPageState extends ConsumerState<TableauBordPage> {
  late int _onglet = widget.ongletInitial;
  ModePeriode _mode = ModePeriode.mois;
  DsPeriode _periode = DsPeriode.calculer('month');

  void _choisirMode(ModePeriode m) {
    if (m == ModePeriode.periode) {
      _choisirPeriode();
      return;
    }
    setState(() {
      _mode = m;
      _periode = DsPeriode.calculer(switch (m) {
        ModePeriode.jour => 'today',
        ModePeriode.semaine => 'week',
        _ => 'month',
      });
    });
  }

  Future<void> _choisirPeriode() async {
    final l10n = AppLocalizations.of(context);
    var choix = _periode;
    final ok = await afficherDialog<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, maj) => DsDialog(
          titre: l10n.tableauBordChoisirPeriode,
          iconeData: LucideIcons.calendar,
          largeur: 880,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              key: const ValueKey('periode_appliquer'),
              libelle: l10n.dsValider,
              icone: LucideIcons.check,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: DsPeriodeLocalisee(periode: choix, onChanged: (p) => maj(() => choix = p)),
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _mode = ModePeriode.periode;
        _periode = choix;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final du = _periode.du, au = _periode.au;
    final cle = (DateTime(du.year, du.month, du.day), DateTime(au.year, au.month, au.day));
    final jours = cle.$2.difference(cle.$1).inDays + 1;
    final libellePeriode =
        '${DateFormat('dd MMM', locale).format(du)} – ${DateFormat('dd MMM yyyy', locale).format(au)}';
    final donnees = ref.watch(tableauBordProvider(cle)).value;
    return PageModule(
      moduleId: 'tableau_bord',
      sousTitre: _onglet == 0
          ? l10n.tableauBordDescription(formatDate.format(au), formatDate.format(du), jours) // paramètres (au, du)
          : l10n.situationDescription,
      onglets: [l10n.tableauBordOnglet, l10n.situationOnglet],
      comptes: [null, SituationRepository.analyses.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      actions: _onglet == 0
          ? [
              DsSegmentedControl<ModePeriode>(
                valeur: _mode,
                onChanged: _choisirMode,
                options: [
                  DsOption(ModePeriode.jour, libelle: l10n.tableauBordJour),
                  DsOption(ModePeriode.semaine, libelle: l10n.tableauBordSemaine),
                  DsOption(ModePeriode.mois, libelle: l10n.tableauBordMois),
                  DsOption(ModePeriode.periode, libelle: l10n.tableauBordPeriode),
                ],
              ),
              DsButton(
                key: const ValueKey('tableau_bord_periode'),
                libelle: libellePeriode,
                icone: LucideIcons.calendar,
                variante: DsButtonVariante.secondaire,
                onPressed: _choisirPeriode,
              ),
              if (peutExporter(ref) && donnees != null)
                DsExportMenu(
                  separe: false,
                  onExport: (format, _) => exporterRapport(context, ref, _rapport(l10n, donnees), format),
                ),
            ]
          : const [],
      child: _onglet == 0 ? _VueEnsemble(donnees: donnees) : const SituationOnglet(),
    );
  }

  Rapport _rapport(AppLocalizations l10n, DonneesTableauBord d) => Rapport(
    id: 'tableau_bord',
    titre: l10n.moduleTableauBord,
    colonnes: [
      RapportColonne(l10n.tableauBordIndicateur, flex: 3),
      RapportColonne(l10n.tableauBordPeriodeCourante, numerique: true, monetaire: true, flex: 2),
      RapportColonne(l10n.tableauBordPeriodePrecedente, numerique: true, monetaire: true, flex: 2),
    ],
    lignes: [
      [l10n.tableauBordVentes, d.ventes, d.ventesAvant],
      [l10n.tableauBordAchats, d.achats, null],
      [l10n.tableauBordNet, d.net, null],
      [l10n.tableauBordDetteFournisseurs, d.detteFournisseurs, null],
      [l10n.tableauBordCreditClients, d.creditClients, null],
      for (final (i, j) in d.jours.indexed) [j, d.courant[i], d.precedent[i]],
    ],
  );
}

/// Vue d'ensemble : 6 KPI, 5 graphiques, dernières ventes et ruptures.
class _VueEnsemble extends ConsumerWidget {
  const _VueEnsemble({required this.donnees});
  final DonneesTableauBord? donnees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final devise = ref.watch(deviseProvider);
    final d = donnees;
    String v(double? x) => x == null ? '—' : f2(x);
    String k(double x) => '${formaterK(x)} $devise';
    final tendance = d?.tendance;
    final (duAvant, auAvant) = (d == null || d.jours.isEmpty) ? (null, null) : (d.jours.first, d.jours.last);
    final kpis = [
      DsStatCard(
        libelle: l10n.tableauBordVentes,
        valeur: v(d?.ventes),
        suffixe: devise,
        icone: LucideIcons.banknote,
        tendance: tendance,
        sousTexte: l10n.tableauBordVsPrecedente,
        info: l10n.tableauBordVentesInfo,
      ),
      DsStatCard(
        libelle: l10n.tableauBordPeriodePrecedente,
        valeur: v(d?.ventesAvant),
        suffixe: devise,
        icone: LucideIcons.history,
        info: l10n.tableauBordPrecedenteInfo,
        sousTexte: duAvant == null ? null : '$duAvant – $auAvant',
      ),
      DsStatCard(
        libelle: l10n.tableauBordAchats,
        valeur: v(d?.achats),
        suffixe: devise,
        icone: LucideIcons.shoppingCart,
        info: l10n.tableauBordAchatsInfo,
      ),
      DsStatCard(
        libelle: l10n.tableauBordNet,
        valeur: v(d?.net),
        suffixe: devise,
        icone: LucideIcons.scale,
        info: l10n.tableauBordNetInfo,
      ),
      DsStatCard(
        key: const ValueKey('kpi_dette_fournisseurs'),
        libelle: l10n.tableauBordDetteFournisseurs,
        valeur: v(d?.detteFournisseurs),
        suffixe: devise,
        icone: LucideIcons.truck,
        info: l10n.tableauBordDetteInfo,
        onTap: () => context.go('/fournisseurs'),
      ),
      DsStatCard(
        key: const ValueKey('kpi_credit_clients'),
        libelle: l10n.tableauBordCreditClients,
        valeur: v(d?.creditClients),
        suffixe: devise,
        icone: LucideIcons.handCoins,
        info: l10n.tableauBordCreditInfo,
        onTap: () => context.go('/clients'),
      ),
    ];
    final totalPaiements = d?.paiements.fold(0.0, (s, p) => s + p.valeur) ?? 0;
    final maxJour = d == null || d.courant.isEmpty
        ? null
        : d.courant.indexOf(d.courant.reduce((a, b) => a > b ? a : b));

    Widget grille(List<Widget> enfants, List<int> flex, double largeur) {
      if (largeur < 900) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: DsTailles.gridGap, children: enfants);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsTailles.gridGap,
        children: [for (final (i, e) in enfants.indexed) Expanded(flex: flex[i], child: e)],
      );
    }

    return LayoutBuilder(
      builder: (context, contraintes) {
        final l = contraintes.maxWidth;
        final parLigne = l >= 1250 ? 6 : 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsTailles.gridGap,
          children: [
            for (var i = 0; i < kpis.length; i += parLigne)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DsSpacing.s4,
                children: [for (final kpi in kpis.skip(i).take(parLigne)) Expanded(child: kpi)],
              ),
            grille(
              [
                DsCarteGraphique(
                  titre: l10n.tableauBordCourbeVentes,
                  icone: LucideIcons.chartLine,
                  hauteur: 230,
                  actions: tendance == null
                      ? null
                      : DsBadge(
                          libelle: '${tendance >= 0 ? '+' : ''}${formaterNombre(tendance, decimales: 1)} %',
                          ton: tendance >= 0 ? DsBadgeTon.succes : DsBadgeTon.danger,
                          icone: tendance >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        ),
                  child: DsLineChart(
                    etiquettes: d?.jours ?? const [],
                    series: [
                      DsSerie(nom: l10n.tableauBordPeriode, valeurs: d?.courant ?? const []),
                      DsSerie(
                        nom: l10n.tableauBordPeriodePrecedente,
                        valeurs: d?.precedent ?? const [],
                        pointillee: true,
                        couleur: c.textMuted,
                      ),
                    ],
                  ),
                ),
                DsCard(
                  titre: l10n.tableauBordModesPaiement,
                  icone: LucideIcons.wallet,
                  child: SizedBox(
                    height: 230,
                    child: Center(
                      child: DsDonutChart(
                        taille: 180,
                        libelleCentre: l10n.tableauBordTotal,
                        valeurCentre: formaterK(totalPaiements),
                        formater: (x) => formaterMontant(x, devise),
                        donnees: [
                          for (final p in d?.paiements ?? const <PointSerie>[])
                            DsDonnee(libelle: libelleModePaiement(l10n, p.etiquette), valeur: p.valeur),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const [2, 1],
              l,
            ),
            grille(
              [
                DsCarteGraphique(
                  titre: l10n.tableauBordCaParJour,
                  icone: LucideIcons.chartColumn,
                  hauteur: 190,
                  child: DsBarChart(
                    miseEnAvant: maxJour,
                    formater: formaterK,
                    donnees: [
                      for (final (i, j) in (d?.jours ?? const <String>[]).indexed)
                        DsDonnee(libelle: j.substring(0, 2), valeur: d!.courant[i]),
                    ],
                  ),
                ),
                DsCard(
                  titre: l10n.tableauBordVentesCaissier,
                  icone: LucideIcons.users,
                  child: _ouVide(
                    context,
                    d?.caissiers.isEmpty ?? true,
                    DsRankedBars(
                      formater: k,
                      donnees: [
                        for (final x in d?.caissiers ?? const <({String nom, int tickets, double total})>[])
                          DsDonnee(libelle: x.nom, valeur: x.total, legende: l10n.tableauBordTickets(x.tickets)),
                      ],
                    ),
                  ),
                ),
                DsCard(
                  titre: l10n.tableauBordTopProduits,
                  icone: LucideIcons.trophy,
                  child: _ouVide(
                    context,
                    d?.topProduits.isEmpty ?? true,
                    DsRankedBars(
                      formater: k,
                      couleur: c.accent,
                      donnees: [
                        for (final x in d?.topProduits ?? const <({String nom, double quantite, double total})>[])
                          DsDonnee(
                            libelle: x.nom,
                            valeur: x.total,
                            legende: l10n.tableauBordUnites(formaterNombre(x.quantite)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const [1, 1, 1],
              l,
            ),
            grille(
              [
                DsCard(
                  titre: l10n.tableauBordDernieresVentes,
                  icone: LucideIcons.receiptText,
                  padding: EdgeInsets.zero,
                  child: DsDataTable<LigneSituation>(
                    encadre: false,
                    pagine: false,
                    lignes: d?.dernieresVentes ?? const [],
                    cle: (r) => r['code']!,
                    messageVide: l10n.dsAucunElement,
                    colonnes: [
                      DsColonne(
                        id: 'code',
                        libelle: l10n.tableauBordPanier,
                        valeur: (r) => r['code'] as Comparable?,
                        attenue: true,
                      ),
                      DsColonne(
                        id: 'heure',
                        libelle: l10n.tableauBordHeure,
                        valeur: (r) => r['date'] as Comparable?,
                        attenue: true,
                        cellule: (_, r) => Text(DateFormat('dd/MM HH:mm').format(r['date']! as DateTime)),
                      ),
                      DsColonne(
                        id: 'client',
                        libelle: l10n.tiersEntiteClientMaj,
                        valeur: (r) => r['client'] as Comparable?,
                        fort: true,
                      ),
                      DsColonne(
                        id: 'mode',
                        libelle: l10n.tableauBordPaiement,
                        valeur: (r) => r['mode'] == null ? '—' : libelleModePaiement(l10n, r['mode']! as String),
                      ),
                      DsColonne(
                        id: 'montant',
                        libelle: l10n.versementMontant,
                        numerique: true,
                        valeur: (r) => r['montant'] as Comparable?,
                        cellule: (_, r) => Text(formaterMontant(r['montant']! as double, devise)),
                      ),
                      DsColonne(
                        id: 'statut',
                        libelle: l10n.tiersStatut,
                        valeur: (r) => r['statut'] as Comparable?,
                        cellule: (_, r) => BadgeStatut(r['statut']! as String),
                      ),
                    ],
                  ),
                ),
                DsCard(
                  titre: l10n.tableauBordRuptures,
                  icone: LucideIcons.packageX,
                  padding: EdgeInsets.zero,
                  child: DsDataTable<({String code, String nom, double stock})>(
                    encadre: false,
                    pagine: false,
                    dense: true,
                    lignes: d?.ruptures ?? const [],
                    cle: (r) => r.code,
                    messageVide: l10n.tableauBordAucuneRupture,
                    colonnes: [
                      DsColonne(id: 'nom', libelle: l10n.tableauBordProduit, valeur: (r) => r.nom, fort: true, flex: 2),
                      DsColonne(
                        id: 'stock',
                        libelle: l10n.tableauBordStock,
                        numerique: true,
                        valeur: (r) => r.stock,
                        cellule: (_, r) => const BadgeStatut('rupture', petit: true),
                      ),
                    ],
                  ),
                ),
              ],
              const [2, 1],
              l,
            ),
          ],
        );
      },
    );
  }

  Widget _ouVide(BuildContext context, bool vide, Widget enfant) => vide
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.s6),
          child: Center(
            child: Text(
              AppLocalizations.of(context).dsAucunElement,
              style: context.ds.typo.body.copyWith(color: context.ds.colors.textMuted),
            ),
          ),
        )
      : enfant;
}
