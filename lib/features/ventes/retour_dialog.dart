import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/retour_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/vente.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';

/// Dialogue de création d'un retour à partir d'une vente.
Future<void> afficherNouveauRetour(BuildContext context, WidgetRef ref, {String? venteCode}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final repo = ref.read(venteRepositoryProvider);
  Vente? vente;
  if (venteCode != null) {
    vente = await repo.vente(venteCode);
  } else {
    final ventes = await repo.ventes(statut: StatutsVente.validee, limite: 300);
    if (!context.mounted) return;
    final choix = await afficherSelecteur<Vente>(
      context,
      titre: l10n.retourVente,
      elements: ventes,
      libelle: (v) => '${v.code} · ${formaterMontant(v.totalNet, devise)}',
      sousLibelle: (v) => v.clientCode,
    );
    if (choix == null) return;
    vente = await repo.vente(choix.code);
  }
  if (vente == null || !context.mounted) return;
  final deja = await ref.read(tiersRepositoryProvider).quantitesRetournees(vente.code);
  if (!context.mounted) return;
  final quantites = {
    for (final l in vente.lignes.where((l) => l.packCode == null)) l.produitCode: TextEditingController(text: '0'),
  };
  final motif = TextEditingController();
  final rembourser = TextEditingController(text: '0');
  var mode = 'Espèces';
  final v = vente;
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final c = ctx.ds.colors;
        final t = ctx.ds.typo;
        return DsDialog(
          titre: l10n.retourNouveau,
          largeur: 640,
          icone: Icon(LucideIcons.undo2, color: c.primaire),
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communValider,
              icone: LucideIcons.check,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${l10n.retourVente} : ${v.code} · ${formaterMontant(v.totalNet, devise)}', style: t.corpsFort),
              const SizedBox(height: DsSpacing.md),
              for (final l in v.lignes.where((l) => l.packCode == null))
                Padding(
                  padding: const EdgeInsets.only(bottom: DsSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(child: Text(l.designation, style: t.corps)),
                      SizedBox(
                        width: 200,
                        child: DsTextField(
                          key: ValueKey('retour_${l.produitCode}'),
                          controller: quantites[l.produitCode],
                          indice: l10n.retourQuantiteMax((l.quantite - (deja[l.produitCode] ?? 0)).toStringAsFixed(0)),
                          typeClavier: TextInputType.number,
                          alignement: TextAlign.end,
                          taille: DsTailles.controleSm,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsTextField(
                      controller: rembourser,
                      libelle: l10n.retourRembourser,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.retourModeRemboursement,
                      valeur: mode,
                      options: const ['Espèces', 'Carte', 'Chèque', 'Virement'],
                      libelle: (m) => libelleModePaiement(l10n, m),
                      onChanged: (x) => setState(() => mode = x ?? mode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(l10n.retourAvoir, style: t.legende.copyWith(color: c.texteAttenue)),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: motif, libelle: l10n.retourMotif),
            ],
          ),
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  final lignes = [
    for (final e in quantites.entries)
      if ((double.tryParse(e.value.text.replaceAll(',', '.')) ?? 0) > 0)
        DemandeRetourLigne(produitCode: e.key, quantite: double.parse(e.value.text.replaceAll(',', '.'))),
  ];
  try {
    final r = await ref
        .read(retourServiceProvider)
        .creer(
          venteCode: v.code,
          lignes: lignes,
          motif: motif.text.trim().isEmpty ? null : motif.text.trim(),
          rembourser: double.tryParse(rembourser.text.replaceAll(',', '.')) ?? 0,
          modeRemboursement: mode,
        );
    rafraichirCommerce(ref);
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.retourNouveau,
        message: l10n.retourCree(r.code, formaterMontant(r.total, devise), formaterMontant(r.rembourse, devise)),
      ),
    );
  } on RetourException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.retourNouveau,
        message: messageErreurRetour(l10n, e.erreur),
      ),
    );
  }
}

/// Liste des retours.
class RetoursPage extends ConsumerWidget {
  const RetoursPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final retours = ref.watch(retoursProvider).value ?? const [];
    final clients = ref.watch(clientsProvider).value ?? const [];
    return DsPage(
      titre: l10n.retoursTitre,
      actions: [
        DsButton(
          libelle: l10n.retourNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            afficherNouveauRetour(context, ref);
          },
        ),
      ],
      child: DsDataTable<Retour>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (r) => r.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (r) => r.date,
            largeur: 110,
            cellule: (_, r) => Text(
              '${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}/${r.date.year}',
            ),
          ),
          DsColonne(id: 'v', libelle: l10n.retourVente, valeur: (r) => r.venteCode, largeur: 110),
          DsColonne(
            id: 'c',
            libelle: l10n.ventesColClient,
            valeur: (r) => clients.where((c) => c.code == r.clientCode).firstOrNull?.nom ?? r.clientCode,
            flex: 2,
          ),
          DsColonne(
            id: 't',
            libelle: l10n.retourColTotal,
            valeur: (r) => r.total,
            numerique: true,
            cellule: (_, r) => Text(formaterMontant(r.total, devise)),
          ),
          DsColonne(
            id: 'rb',
            libelle: l10n.retourColRembourse,
            valeur: (r) => r.rembourse,
            numerique: true,
            cellule: (_, r) => Text(formaterMontant(r.rembourse, devise)),
          ),
          DsColonne(id: 'm', libelle: l10n.retourMotif, valeur: (r) => r.motif, flex: 2),
        ],
        lignes: retours,
        cle: (r) => r.code,
        messageVide: l10n.retourAucun,
      ),
    );
  }
}
