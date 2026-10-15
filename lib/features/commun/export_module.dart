import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/export/export_excel.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/rapport_pdf.dart';
import '../../domain/models/rapport.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';

/// Permissions de la session (codes) : filtrent les colonnes à permission des tableaux.
Set<String> permissionsSession(WidgetRef ref) =>
    ref.watch(sessionProvider)?.permissions.map((p) => p.code).toSet() ?? const {};

/// `true` si la session peut exporter (`exporterDonnees`).
bool peutExporter(WidgetRef ref) => ref.watch(sessionProvider)?.a(Permission.exporterDonnees) ?? false;

/// Rapport tabulaire construit depuis les colonnes d'un tableau de module (colonnes visibles par
/// défaut et autorisées, valeurs brutes des cellules).
Rapport rapportDepuisTableau<T>({
  required String id,
  required String titre,
  required List<DsColonne<T>> colonnes,
  required List<T> lignes,
  Set<String> permissions = const {},
}) {
  final cols = colonnes
      .where((c) => c.visibleParDefaut && (c.permission == null || permissions.contains(c.permission)))
      .toList();
  Object? brut(Object? v) => switch (v) {
    null => null,
    final num n => n,
    final DateTime d => DateFormat('dd/MM/yyyy HH:mm').format(d),
    _ => v.toString(),
  };
  return Rapport(
    id: id,
    titre: titre,
    colonnes: [for (final c in cols) RapportColonne(c.libelle, numerique: c.numerique, flex: c.flex)],
    lignes: [
      for (final l in lignes) [for (final c in cols) brut(c.valeur(l))],
    ],
    totaux: cols.any((c) => c.total != null)
        ? [for (final (i, c) in cols.indexed) c.total != null ? c.total!(lignes) : (i == 0 ? 'Total' : null)]
        : null,
  );
}

/// Export Excel (enregistrement) ou PDF (aperçu) d'un rapport de module (§12.1).
Future<void> exporterRapport(BuildContext context, WidgetRef ref, Rapport r, DsFormatExport format) async {
  final l10n = AppLocalizations.of(context);
  final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  if (format == DsFormatExport.excel) {
    final chemin = await ref.read(selecteurEnregistrementProvider)('${r.id}_$date.xlsx', 'xlsx');
    if (chemin == null || !context.mounted) return;
    await ref.read(ecrivainFichierProvider)(chemin, ExportExcel.rapport(r));
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.situationExportExcel,
        message: l10n.situationExportOk(chemin),
      ),
    );
    return;
  }
  final arabe = ref.read(localeProvider).languageCode == 'ar';
  final boutique = (await ref.read(parametresServiceProvider).lireBoutique())?.nom ?? '';
  final devise = ref.read(deviseProvider);
  final police = await policePdf(arabe);
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (ctx) => DsDialog(
      titre: '${l10n.situationApercuPdf} — ${r.titre}',
      largeur: 900,
      actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop())],
      contenu: SizedBox(
        height: 560,
        child: PdfPreview(
          build: (_) => RapportPdf(
            police: police,
            rtl: arabe,
            devise: devise,
          ).generer(r, boutique: boutique, periode: DateFormat('dd/MM/yyyy').format(DateTime.now())),
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          allowSharing: false,
          pdfFileName: '${r.id}_$date.pdf',
        ),
      ),
    ),
  );
}

/// Raccourci : export des lignes d'un [DsModuleTable].
Future<void> exporterTableau<T>(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String titre,
  required List<DsColonne<T>> colonnes,
  required List<T> lignes,
  required DsFormatExport format,
}) => exporterRapport(
  context,
  ref,
  rapportDepuisTableau(
    id: id,
    titre: titre,
    colonnes: colonnes,
    lignes: lignes,
    permissions: ref.read(sessionProvider)?.permissions.map((p) => p.code).toSet() ?? const {},
  ),
  format,
);
