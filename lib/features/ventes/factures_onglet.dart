import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/facture.dart';
import '../../domain/models/tiers.dart';
import '../caisse/pos_controller.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/chargement.dart';
import '../commun/export_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';
import 'ventes_providers.dart';

/// Factures (FAC) et factures d'avoir (AVO) d'une période, dans l'ordre d'émission.
final facturesProvider = FutureProvider.family<List<Facture>, (DateTime, DateTime)>((ref, bornes) {
  ref.watch(commerceVersionProvider);
  return ref.watch(factureServiceProvider).factures(debut: bornes.$1, fin: bornes.$2);
});

/// Onglet « Factures & avoirs » du module Ventes : numérotation continue FAC / AVO, identités fiscales figées,
/// HT / TVA / timbre / net, réimpression (duplicata avec ses avoirs) et vérification de la chaîne scellée.
class FacturesOnglet extends ConsumerStatefulWidget {
  const FacturesOnglet({super.key});

  @override
  ConsumerState<FacturesOnglet> createState() => _FacturesOngletState();
}

class _FacturesOngletState extends ConsumerState<FacturesOnglet> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _type;
  String? _client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final tous = (ref.watch(facturesProvider(bornesPeriode(_periode))).value ?? const <Facture>[]).reversed.toList();
    final noms = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    String client(Facture f) => f.client.nom.isNotEmpty ? f.client.nom : (noms[f.clientCode] ?? f.clientCode);
    final lignes = tous
        .where((f) => (_type == null || f.type == _type) && (_client == null || f.clientCode == _client))
        .toList();
    // Un avoir vient en déduction : montants signés pour les totaux.
    double signe(Facture f) => f.estAvoir ? -1 : 1;
    double somme(Iterable<Facture> fs, double Function(Facture) v) => fs.fold(0.0, (s, f) => s + signe(f) * v(f));
    final colonnes = <DsColonne<Facture>>[
      DsColonne(id: 'code', libelle: l10n.factureNumero, valeur: (f) => f.code, fort: true),
      DsColonne(
        id: 'type',
        libelle: l10n.tiersType,
        valeur: (f) => f.type,
        cellule: (_, f) => DsBadge(
          libelle: f.estAvoir ? l10n.factureTypeAvoir : l10n.factureTypeFacture,
          ton: f.estAvoir ? DsBadgeTon.avertissement : DsBadgeTon.primaire,
        ),
      ),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (f) => f.date,
        cellule: (_, f) => Text(formatDateHeure.format(f.date)),
      ),
      DsColonne(id: 'client', libelle: l10n.ventesClient, flex: 2, valeur: client),
      DsColonne(id: 'vente', libelle: l10n.factureVente, attenue: true, valeur: (f) => f.venteCode),
      DsColonne(id: 'origine', libelle: l10n.factureOrigine, attenue: true, valeur: (f) => f.factureOrigine ?? ''),
      DsColonne(
        id: 'ht',
        libelle: l10n.tvaHt,
        numerique: true,
        valeur: (f) => f.totalHt,
        cellule: (_, f) => Text(da(signe(f) * f.totalHt)),
        total: (fs) => da(somme(fs, (f) => f.totalHt)),
      ),
      DsColonne(
        id: 'tva',
        libelle: l10n.tvaMontant,
        numerique: true,
        valeur: (f) => f.totalTva,
        cellule: (_, f) => Text(da(signe(f) * f.totalTva)),
        total: (fs) => da(somme(fs, (f) => f.totalTva)),
      ),
      DsColonne(
        id: 'timbre',
        libelle: l10n.factureTimbre,
        numerique: true,
        valeur: (f) => f.timbre,
        cellule: (_, f) => Text(da(f.timbre)),
        total: (fs) => da(fs.fold(0.0, (s, f) => s + f.timbre)),
      ),
      DsColonne(
        id: 'net',
        libelle: l10n.factureNet,
        numerique: true,
        fort: true,
        valeur: (f) => f.netAPayer,
        cellule: (_, f) => Text(da(signe(f) * f.netAPayer)),
        total: (fs) => da(somme(fs, (f) => f.netAPayer)),
      ),
      DsColonne(id: 'mode', libelle: l10n.ventesPaiement, visibleParDefaut: false, valeur: (f) => f.modePaiement),
      DsColonne(id: 'motif', libelle: l10n.auditMotif, visibleParDefaut: false, valeur: (f) => f.motif ?? ''),
      DsColonne(id: 'nif', libelle: 'NIF', visibleParDefaut: false, valeur: (f) => f.client.nif),
      DsColonne(id: 'hash', libelle: l10n.gcColEmpreinte, visibleParDefaut: false, valeur: (f) => f.hash),
    ];
    final factures = lignes.where((f) => !f.estAvoir);
    final avoirs = lignes.where((f) => f.estAvoir);
    return DsModuleTable<Facture>(
      key: const ValueKey('ventes_factures'),
      entite: l10n.factureEntites,
      lignes: lignes,
      chargement: enChargement(ref.watch(facturesProvider(bornesPeriode(_periode)))),
      colonnes: colonnes,
      cle: (f) => f.code,
      afficherTotaux: true,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      messageVide: l10n.factureAucune,
      texteRecherche: (f) => '${f.code} ${f.venteCode} ${client(f)}',
      nbFiltresActifs: [_type, _client].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _type = null;
        _client = null;
        _periode = DsPeriode.calculer('month');
      }),
      kpis: [
        DsStatCard(libelle: l10n.factureKpiFactures, valeur: '${factures.length}', icone: LucideIcons.fileText),
        DsStatCard(
          libelle: l10n.factureKpiFacture,
          valeur: f2(factures.fold(0.0, (s, f) => s + f.netAPayer)),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
        DsStatCard(
          libelle: l10n.factureKpiAvoirs,
          valeur: f2(avoirs.fold(0.0, (s, f) => s + f.netAPayer)),
          suffixe: devise,
          icone: LucideIcons.fileMinus,
        ),
        DsStatCard(
          libelle: l10n.tvaCollectee,
          valeur: f2(somme(lignes, (f) => f.totalTva)),
          suffixe: devise,
          icone: LucideIcons.percent,
        ),
      ],
      filtres: [
        DsFormRow(
          libelle: l10n.tiersType,
          largeurLibelle: 64,
          child: DsSelect<String?>(
            cle: const ValueKey('factures_filtre_type'),
            valeur: _type,
            options: const [null, TypesFacture.facture, TypesFacture.avoir],
            libelle: (t) => switch (t) {
              null => l10n.tiersTous,
              TypesFacture.avoir => l10n.factureTypeAvoir,
              _ => l10n.factureTypeFacture,
            },
            onChanged: (t) => setState(() => _type = t),
          ),
        ),
        DsFormRow(
          libelle: l10n.ventesClient,
          largeurLibelle: 64,
          child: DsSelect<String?>(
            valeur: _client,
            options: [
              null,
              ...{for (final f in tous) f.clientCode},
            ],
            libelle: (c) => c == null ? l10n.tiersTous : (noms[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.client),
            onChanged: (c) => setState(() => _client = c),
          ),
        ),
      ],
      onOuvrir: _imprimer,
      onExport: peutExporter(ref)
          ? (format, fs) => exporterTableau(
              context,
              ref,
              id: 'factures',
              titre: l10n.factureEntites,
              colonnes: colonnes,
              lignes: fs,
              format: format,
            )
          : null,
      actions: [
        DsActionModule(
          cle: const ValueKey('facture_imprimer'),
          libelle: l10n.factureImprimer,
          icone: LucideIcons.printer,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => _imprimer(choix.first),
        ),
      ],
      secondaire: DsButton(
        key: const ValueKey('factures_verifier_chaine'),
        libelle: l10n.ventesVerifierChaine,
        icone: LucideIcons.shieldCheck,
        variante: DsButtonVariante.secondaire,
        onPressed: _verifierChaine,
      ),
    );
  }

  /// Réimpression : la facture (ou celle d'origine d'un avoir) en duplicata, suivie de ses avoirs.
  Future<void> _imprimer(Facture f) async {
    final vente = await ref.read(venteRepositoryProvider).vente(f.venteCode);
    if (vente == null || !mounted) return;
    await imprimerFactureVente(context, ref, vente);
  }

  Future<void> _verifierChaine() async {
    final l10n = AppLocalizations.of(context);
    final ko = await ref.read(factureServiceProvider).verifierChaine();
    if (!mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: ko == null ? DsResultatType.succes : DsResultatType.erreur,
        titre: l10n.ventesVerifierChaine,
        message: ko == null ? l10n.factureChaineOk : l10n.ventesChaineKo(ko),
      ),
    );
  }
}
