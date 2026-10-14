import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/statistiques_repository.dart';
import '../caisse/pos_dialogs.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

/// Données du tableau de bord : 6 KPI + 5 séries.
class DonneesTableauBord {
  const DonneesTableauBord({
    required this.kpi,
    required this.ca30Jours,
    required this.paiements,
    required this.topProduits,
    required this.categories,
    required this.caMensuel,
  });
  final Kpi kpi;
  final List<PointSerie> ca30Jours;
  final List<PointSerie> paiements;
  final List<PointSerie> topProduits;
  final List<PointSerie> categories;
  final List<PointSerie> caMensuel;
}

final tableauBordProvider = FutureProvider<DonneesTableauBord>((ref) async {
  ref.watch(rapportsVersionProvider);
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  ref.watch(caisseVersionProvider);
  final stats = ref.watch(statistiquesRepositoryProvider);
  final seuil = (await ref.watch(parametresVenteProvider.future)).seuilStockGlobal;
  final maintenant = DateTime.now();
  final debut = DateTime(maintenant.year, maintenant.month, maintenant.day).subtract(const Duration(days: 29));
  final fin = DateTime(maintenant.year, maintenant.month, maintenant.day + 1);
  return DonneesTableauBord(
    kpi: await stats.kpi(jour: maintenant, seuilGlobal: seuil),
    ca30Jours: await stats.caParJour(debut, maintenant),
    paiements: await stats.paiementsParMode(debut, fin),
    topProduits: await stats.topProduits(debut, fin),
    categories: await stats.ventesParCategorie(debut, fin),
    caMensuel: await stats.caParMois(maintenant),
  );
});

/// Tableau de bord : 6 indicateurs, 5 graphiques (fl_chart habillé aux tokens).
class TableauBordPage extends ConsumerWidget {
  const TableauBordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final devise = ref.watch(deviseProvider);
    final donnees = ref.watch(tableauBordProvider).value;
    final k = donnees?.kpi;
    String m(double? v) => v == null ? '—' : formaterMontant(v, devise);
    return DsPage(
      titre: l10n.tableauBordTitre,
      defilable: true,
      actions: [
        DsButton(
          libelle: l10n.tableauBordActualiser,
          icone: LucideIcons.refreshCw,
          variante: DsButtonVariante.secondaire,
          onPressed: () => rafraichirRapports(ref),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, contraintes) {
          final largeur = contraintes.maxWidth;
          final colonnes = largeur >= 1100 ? 3 : 2;
          final largeurKpi = (largeur - DsSpacing.md * (colonnes * 2 - 1)) / (colonnes * 2);
          final largeurGraphique = (largeur - DsSpacing.md * (colonnes - 1)) / colonnes;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: DsSpacing.md,
                runSpacing: DsSpacing.md,
                children: [
                  for (final (libelle, valeur, icone, ton) in [
                    (l10n.tableauBordCaJour, m(k?.caJour), LucideIcons.banknote, DsBadgeTon.primaire),
                    (
                      l10n.tableauBordTicketsJour,
                      k == null ? '—' : '${k.ticketsJour}',
                      LucideIcons.receipt,
                      DsBadgeTon.info,
                    ),
                    (l10n.tableauBordPanierMoyen, m(k?.panierMoyen), LucideIcons.shoppingBasket, DsBadgeTon.succes),
                    (l10n.tableauBordCaMois, m(k?.caMois), LucideIcons.calendarDays, DsBadgeTon.primaire),
                    (
                      l10n.tableauBordSousSeuil,
                      k == null ? '—' : '${k.produitsSousSeuil}',
                      LucideIcons.triangleAlert,
                      (k?.produitsSousSeuil ?? 0) > 0 ? DsBadgeTon.avertissement : DsBadgeTon.neutre,
                    ),
                    (l10n.tableauBordCreances, m(k?.creancesClients), LucideIcons.handCoins, DsBadgeTon.danger),
                  ])
                    SizedBox(
                      width: largeurKpi,
                      child: DsStatCard(libelle: libelle, valeur: valeur, icone: icone, ton: ton),
                    ),
                ],
              ),
              const SizedBox(height: DsSpacing.lg),
              Wrap(
                spacing: DsSpacing.md,
                runSpacing: DsSpacing.md,
                children: [
                  SizedBox(
                    width: largeurGraphique * 2 + DsSpacing.md,
                    child: DsCarteGraphique(
                      titre: l10n.tableauBordCa30Jours,
                      child: DsGraphiqueLignes(points: donnees?.ca30Jours ?? const []),
                    ),
                  ),
                  SizedBox(
                    width: largeurGraphique,
                    child: DsCarteGraphique(
                      titre: l10n.tableauBordPaiements,
                      child: DsGraphiqueSecteurs(
                        parts: [
                          for (final p in donnees?.paiements ?? const <PointSerie>[])
                            (etiquette: libelleModePaiement(l10n, p.etiquette), valeur: p.valeur),
                        ],
                        formatValeur: (v) => formaterMontant(v, devise),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: largeurGraphique,
                    child: DsCarteGraphique(
                      titre: l10n.tableauBordTopProduits,
                      child: DsGraphiqueBarres(barres: donnees?.topProduits ?? const [], couleur: c.succes),
                    ),
                  ),
                  SizedBox(
                    width: largeurGraphique,
                    child: DsCarteGraphique(
                      titre: l10n.tableauBordCategories,
                      child: DsGraphiqueBarres(barres: donnees?.categories ?? const [], couleur: c.info),
                    ),
                  ),
                  SizedBox(
                    width: largeurGraphique,
                    child: DsCarteGraphique(
                      titre: l10n.tableauBordCaMensuel,
                      child: DsGraphiqueBarres(barres: donnees?.caMensuel ?? const [], largeurEtiquette: 5),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
