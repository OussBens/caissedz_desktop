import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/versement_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import 'tiers_providers.dart';

/// Nouveau versement d'un tiers ; imputation automatique aux documents ouverts.
Future<void> afficherNouveauVersement(
  BuildContext context,
  WidgetRef ref, {
  required String tiersType,
  required String tiersCode,
  required String nomTiers,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final repo = ref.read(tiersRepositoryProvider);
  final docs = tiersType == TypesTiers.client
      ? await repo.documentsOuvertsClient(tiersCode)
      : await repo.documentsOuvertsFournisseur(tiersCode);
  if (!context.mounted) return;
  final montant = TextEditingController(text: docs.fold(0.0, (s, d) => s + d.reste).toStringAsFixed(2));
  final reference = TextEditingController();
  var mode = 'Espèces';
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final c = ctx.ds.colors;
        final t = ctx.ds.typo;
        final saisi = double.tryParse(montant.text.replaceAll(',', '.')) ?? 0;
        final apercu = VersementService.repartir('APERCU', saisi, docs);
        return DsDialog(
          titre: tiersType == TypesTiers.client ? l10n.clientNouveauVersement : l10n.fournisseurNouveauVersement,
          largeur: 560,
          icone: Icon(LucideIcons.handCoins, color: c.primaire),
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
              Text('${l10n.versementTiers} : $nomTiers', style: t.corpsFort),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsTextField(
                      controller: montant,
                      libelle: l10n.versementMontant,
                      typeClavier: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.versementMode,
                      valeur: mode,
                      options: const ['Espèces', 'Carte', 'Chèque', 'Virement'],
                      libelle: (m) => libelleModePaiement(l10n, m),
                      onChanged: (v) => setState(() => mode = v ?? mode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: reference, libelle: l10n.versementReference),
              const SizedBox(height: DsSpacing.lg),
              Text(l10n.versementImputations, style: t.petitFort.copyWith(color: c.texteSecondaire)),
              const SizedBox(height: DsSpacing.xs),
              if (docs.isEmpty) Text(l10n.communAucune, style: t.petit.copyWith(color: c.texteAttenue)),
              for (final d in docs)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${d.code} · ${d.date.day.toString().padLeft(2, '0')}/${d.date.month.toString().padLeft(2, '0')}/${d.date.year}',
                        style: t.petit,
                      ),
                    ),
                    Text(formaterMontant(d.reste, devise), style: t.petit.copyWith(color: c.texteSecondaire)),
                    const SizedBox(width: DsSpacing.md),
                    SizedBox(
                      width: 110,
                      child: Text(
                        formaterMontant(
                          apercu.where((i) => i.documentCode == d.code).firstOrNull?.montant ?? 0,
                          devise,
                        ),
                        textAlign: TextAlign.end,
                        style: t.petitFort.copyWith(color: c.primaire),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final v = await ref
        .read(versementServiceProvider)
        .imputer(
          tiersType: tiersType,
          tiersCode: tiersCode,
          montant: double.tryParse(montant.text.replaceAll(',', '.')) ?? 0,
          mode: mode,
          reference: reference.text.trim().isEmpty ? null : reference.text.trim(),
        );
    rafraichirCommerce(ref);
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.versementNouveau,
        message: l10n.versementEnregistre(
          v.code,
          formaterMontant(v.impute, devise),
          formaterMontant(v.nonImpute, devise),
        ),
      ),
    );
  } on VersementException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.versementNouveau,
        message: messageErreurVersement(l10n, e.erreur),
      ),
    );
  }
}
