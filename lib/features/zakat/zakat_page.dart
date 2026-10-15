import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/zakat.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import 'zakat_dialogs.dart';

/// Écran Zakat (`ZakatScreen` du DS v2.2, §9.15) : calculs annuels enregistrés, KPI provisoires de l'année.
class ZakatPage extends ConsumerWidget {
  const ZakatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final calculs = ref.watch(calculsZakatProvider).value ?? const <Zakat>[];
    final patrimoine = ref.watch(patrimoineZakatProvider).value ?? const PatrimoineZakat();
    final parametres = ref.watch(parametresZakatProvider).value;
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final annee = DateTime.now().year;
    final nissab = parametres?.nissab ?? 0;
    final taux = parametres?.tauxPct ?? CalculZakat.tauxDefautPct;
    final aujourdhui = DateUtils.dateOnly(DateTime.now());
    final prochaine = calculs.where((z) => z.actif && !z.estPayee && z.obligatoire).toList()
      ..sort((a, b) => a.dateDue.compareTo(b.dateDue));
    String da(double v) => formaterMontant(v, devise);
    final colonnes = <DsColonne<Zakat>>[
      DsColonne(id: 'code', libelle: l10n.zkColCode, attenue: true, valeur: (z) => z.code),
      DsColonne(id: 'annee', libelle: l10n.zkColAnnee, fort: true, valeur: (z) => z.annee),
      DsColonne(
        id: 'capital',
        libelle: l10n.zkColCapital,
        numerique: true,
        valeur: (z) => z.capital,
        cellule: (_, z) => Text(da(z.capital)),
      ),
      DsColonne(
        id: 'nissab',
        libelle: l10n.zkColNissab,
        numerique: true,
        valeur: (z) => z.nissab,
        cellule: (_, z) => Text(da(z.nissab)),
      ),
      DsColonne(
        id: 'obligatoire',
        libelle: l10n.zkColObligatoire,
        valeur: (z) => z.obligatoire ? 1 : 0,
        cellule: (_, z) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: DsBadge(
            libelle: z.obligatoire ? l10n.zkOui : l10n.zkNon,
            ton: z.obligatoire ? DsBadgeTon.succes : DsBadgeTon.neutre,
            point: true,
          ),
        ),
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.zkColZakat,
        numerique: true,
        fort: true,
        valeur: (z) => z.montant,
        cellule: (_, z) => Text(z.montant > 0 ? da(z.montant) : '—'),
        total: (zs) => da(zs.where((z) => z.actif).fold(0.0, (a, z) => a + z.montant)),
      ),
      DsColonne(
        id: 'due',
        libelle: l10n.zkColDue,
        attenue: true,
        valeur: (z) => z.dateDue,
        cellule: (_, z) => Text(formatJour.format(z.dateDue)),
      ),
      DsColonne(
        id: 'payee',
        libelle: l10n.zkColPayee,
        attenue: true,
        valeur: (z) => z.datePaiement,
        cellule: (_, z) => Text(z.datePaiement == null ? '—' : formatJour.format(z.datePaiement!)),
      ),
      DsColonne(
        id: 'statut',
        libelle: l10n.zkColStatut,
        valeur: cleStatutZakat,
        cellule: (context, z) =>
            Align(alignment: AlignmentDirectional.centerStart, child: badgeStatutZakat(context, z)),
      ),
      for (final (id, libelle, valeur) in [
        ('stock', l10n.zkColStock, (Zakat z) => z.stock),
        ('liquidites', l10n.zkColLiquidites, (Zakat z) => z.liquidites),
        ('creances', l10n.zkColCreances, (Zakat z) => z.creances),
        ('dettes', l10n.zkColDettes, (Zakat z) => z.dettes),
      ])
        DsColonne(
          id: id,
          libelle: libelle,
          numerique: true,
          visibleParDefaut: false,
          valeur: valeur,
          cellule: (_, z) => Text(da(valeur(z))),
        ),
      DsColonne(
        id: 'taux',
        libelle: l10n.zkColTaux,
        numerique: true,
        visibleParDefaut: false,
        valeur: (z) => z.tauxPct,
        cellule: (_, z) => Text('${formaterNombre(z.tauxPct, decimales: 1)} %'),
      ),
      DsColonne(
        id: 'hawl',
        libelle: l10n.zkColHawl,
        attenue: true,
        visibleParDefaut: false,
        valeur: (z) => z.debutHawl,
        cellule: (_, z) => Text(formatJour.format(z.debutHawl)),
      ),
      DsColonne(id: 'obs', libelle: l10n.zkColObservation, visibleParDefaut: false, valeur: (z) => z.observation),
      DsColonne(
        id: 'cree_par',
        libelle: l10n.zkColCreePar,
        visibleParDefaut: false,
        valeur: (z) => z.creePar == null ? '' : (noms[z.creePar] ?? z.creePar!),
      ),
    ];
    return PageModule(
      moduleId: 'zakat',
      sousTitre: l10n.zkDescription,
      child: DsModuleTable<Zakat>(
        key: const ValueKey('zakat'),
        entite: l10n.zkEntite,
        lignes: calculs,
        colonnes: colonnes,
        cle: (z) => z.code,
        afficherTotaux: true,
        permissions: permissionsSession(ref),
        messageVide: l10n.zkAucun,
        kpis: [
          DsStatCard(
            libelle: l10n.zkKpiCapital(annee),
            valeur: f2(patrimoine.capital),
            suffixe: devise,
            icone: LucideIcons.scale,
          ),
          DsStatCard(libelle: l10n.zkKpiNissab, valeur: f2(nissab), suffixe: devise, icone: LucideIcons.gem),
          DsStatCard(
            libelle: l10n.zkKpiEstimee(annee),
            valeur: f2(CalculZakat.montant(patrimoine.capital, nissab, taux)),
            suffixe: devise,
            icone: LucideIcons.handCoins,
          ),
          DsStatCard(
            libelle: l10n.zkKpiEcheance,
            valeur: prochaine.isEmpty ? '—' : '${prochaine.first.dateDue.difference(aujourdhui).inDays}',
            suffixe: prochaine.isEmpty ? null : l10n.zkJours,
            icone: LucideIcons.calendarClock,
          ),
        ],
        texteRecherche: (z) => '${z.code} ${z.annee} ${z.observation}',
        onExport: peutExporter(ref)
            ? (format, zs) => exporterTableau(
                context,
                ref,
                id: 'zakat',
                titre: l10n.moduleZakat,
                colonnes: colonnes,
                lignes: zs,
                format: format,
              )
            : null,
        onOuvrir: (z) => afficherDetailZakat(context, ref, z),
        actions: [
          DsActionModule(
            libelle: l10n.tiersDetail,
            icone: LucideIcons.eye,
            regle: DsRegleSelection.une,
            detail: true,
            onPressed: (choix, _) => afficherDetailZakat(context, ref, choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('zakat_modifier'),
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && (choix.first.estPayee || !choix.first.actif),
            onPressed: (choix, _) => afficherFormulaireZakat(context, ref, zakat: choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('zakat_payee'),
            libelle: l10n.zkMarquerPayee,
            icone: LucideIcons.circleCheck,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && (choix.first.estPayee || !choix.first.actif),
            onPressed: (choix, _) => marquerZakatPayee(context, ref, choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('zakat_annuler'),
            libelle: l10n.zkAnnuler,
            icone: LucideIcons.ban,
            danger: true,
            onPressed: (choix, effacer) => annulerZakats(context, ref, choix, effacer),
          ),
        ],
        primaire: DsButton(
          key: const ValueKey('zakat_nouveau'),
          libelle: l10n.zkNouveau,
          icone: LucideIcons.calculator,
          onPressed: () => afficherFormulaireZakat(context, ref),
        ),
      ),
    );
  }
}
