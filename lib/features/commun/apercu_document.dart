import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../caisse/pos_dialogs.dart';
import '../rapports/rapports_providers.dart';

/// Aperçu A4 d'un document (facture, avoir, devis, proforma, commande, bon de livraison) avant impression :
/// le rendu tel qu'il sera imprimé, puis Enregistrer en PDF, Imprimer ou Fermer. Le PDF n'est généré qu'une fois.
Future<void> afficherApercuDocument(
  BuildContext context,
  WidgetRef ref, {
  required String titre,
  required String nom,
  required Future<Uint8List> Function() pdf,
}) async {
  final l10n = AppLocalizations.of(context);
  Future<Uint8List>? octets;
  Future<Uint8List> document() => octets ??= pdf();
  final apercu = ref.read(apercuPdfProvider);
  final hauteur = (MediaQuery.sizeOf(context).height - 260).clamp(360.0, 760.0);
  await afficherDialog<void>(
    context,
    builder: (ctx) => DsDialog(
      titre: '${l10n.situationApercuPdf} — $titre',
      iconeData: LucideIcons.fileText,
      largeur: 900,
      actions: [
        DsButton(
          key: const ValueKey('apercu_enregistrer'),
          libelle: l10n.apercuEnregistrerPdf,
          icone: LucideIcons.download,
          variante: DsButtonVariante.secondaire,
          onPressed: () async {
            final chemin = await ref.read(selecteurEnregistrementProvider)('$nom.pdf', 'pdf');
            if (chemin == null) return;
            await ref.read(ecrivainFichierProvider)(chemin, await document());
            if (!ctx.mounted) return;
            unawaited(
              afficherResultat(
                ctx,
                type: DsResultatType.succes,
                titre: l10n.apercuEnregistrerPdf,
                message: l10n.situationExportOk(chemin),
              ),
            );
          },
        ),
        DsButton(
          key: const ValueKey('apercu_imprimer'),
          libelle: l10n.posImprimer,
          icone: LucideIcons.printer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Printing.layoutPdf(onLayout: (_) => document(), name: '$nom.pdf'),
        ),
        DsButton(
          key: const ValueKey('apercu_fermer'),
          libelle: l10n.communFermer,
          icone: LucideIcons.x,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
      contenu: SizedBox(height: hauteur, child: apercu(const ValueKey('apercu_document'), document, '$nom.pdf')),
    ),
  );
}
