import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/stock.dart';
import '../produits/produits_providers.dart';
import 'lignes_stock_editeur.dart';
import 'stock_providers.dart';

/// Transferts TRM entre magasins.
class TransfertsPage extends ConsumerWidget {
  const TransfertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transferts = ref.watch(transfertsProvider).value ?? const [];
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    String nomMagasin(String code) => magasins.where((m) => m.code == code).firstOrNull?.nom ?? code;
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return DsPage(
      titre: l10n.transfertsTitre,
      actions: [
        DsButton(
          libelle: l10n.transfertNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            _nouveau(context, ref);
          },
        ),
      ],
      child: DsDataTable<TransfertStock>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (t) => t.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (t) => t.date,
            largeur: 150,
            cellule: (_, t) => Text(df.format(t.date)),
          ),
          DsColonne(id: 's', libelle: l10n.transfertSource, valeur: (t) => nomMagasin(t.magasinSource), flex: 2),
          DsColonne(
            id: 'dest',
            libelle: l10n.transfertDestination,
            valeur: (t) => nomMagasin(t.magasinDestination),
            flex: 2,
          ),
          DsColonne(
            id: 'n',
            libelle: l10n.transfertLignes,
            valeur: (t) => t.lignes.length,
            numerique: true,
            cellule: (_, t) => Text(l10n.communLignes(t.lignes.length)),
          ),
          DsColonne(id: 'c', libelle: l10n.communCommentaire, valeur: (t) => t.commentaire, flex: 2),
        ],
        lignes: transferts,
        cle: (t) => t.code,
        messageVide: l10n.transfertAucun,
      ),
    );
  }

  Future<void> _nouveau(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
    final produits = await ref.read(produitsProvider.future);
    if (!context.mounted) return;
    if (magasins.length < 2) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.info,
          titre: l10n.transfertNouveau,
          message: l10n.stockErreurMemeMagasin,
        ),
      );
      return;
    }
    var source = await ref.read(magasinPrincipalProvider.future);
    var destination = magasins.firstWhere((m) => m.code != source).code;
    var lignes = <LigneStock>[];
    final commentaire = TextEditingController();
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: l10n.transfertNouveau,
          largeur: 640,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communValider,
              icone: LucideIcons.arrowLeftRight,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.transfertSource,
                      valeur: source,
                      options: magasins.map((m) => m.code).toList(),
                      libelle: (c) => magasins.firstWhere((m) => m.code == c).nom,
                      onChanged: (v) => setState(() => source = v ?? source),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.transfertDestination,
                      valeur: destination,
                      options: magasins.map((m) => m.code).toList(),
                      libelle: (c) => magasins.firstWhere((m) => m.code == c).nom,
                      onChanged: (v) => setState(() => destination = v ?? destination),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.lg),
              LignesStockEditeur(produits: produits, lignes: lignes, onChanged: (l) => setState(() => lignes = l)),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final t = await ref
          .read(stockServiceProvider)
          .transferer(
            magasinSource: source,
            magasinDestination: destination,
            lignes: lignes,
            commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
          );
      rafraichirStock(ref);
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.transfertNouveau,
          message: l10n.transfertCree(t.code),
        ),
      );
    } on StockException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.transfertNouveau,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
  }
}
