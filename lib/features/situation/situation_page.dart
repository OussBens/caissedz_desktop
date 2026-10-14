import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/export/export_excel.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/rapport_pdf.dart';
import '../../data/statistiques_repository.dart';
import '../../domain/models/rapport.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';

/// Situation : 10 rapports sur une période, exports Excel et PDF avec aperçu.
class SituationPage extends ConsumerStatefulWidget {
  const SituationPage({super.key});

  @override
  ConsumerState<SituationPage> createState() => _SituationPageState();
}

class _SituationPageState extends ConsumerState<SituationPage> {
  static final _df = DateFormat('dd/MM/yyyy');
  String _rapportId = StatistiquesRepository.rapports.first;
  late final TextEditingController _debut;
  late final TextEditingController _fin;
  Rapport? _rapport;
  bool _chargement = false;

  @override
  void initState() {
    super.initState();
    final m = DateTime.now();
    _debut = TextEditingController(text: _df.format(DateTime(m.year, m.month)));
    _fin = TextEditingController(text: _df.format(m));
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  @override
  void dispose() {
    _debut.dispose();
    _fin.dispose();
    super.dispose();
  }

  (DateTime, DateTime)? _periode() {
    try {
      final d1 = _df.parseStrict(_debut.text.trim());
      final d2 = _df.parseStrict(_fin.text.trim()).add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
      if (d2.isBefore(d1)) return null;
      return (d1, d2);
    } on FormatException {
      return null;
    }
  }

  Future<void> _charger() async {
    final l10n = AppLocalizations.of(context);
    final p = _periode();
    if (p == null) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.situationTitre,
          message: l10n.situationDatesInvalides,
        ),
      );
      return;
    }
    setState(() => _chargement = true);
    final seuil = (await ref.read(parametresVenteProvider.future)).seuilStockGlobal;
    final r = await ref
        .read(statistiquesRepositoryProvider)
        .rapport(_rapportId, debut: p.$1, fin: p.$2, seuilGlobal: seuil);
    if (!mounted) return;
    setState(() {
      _rapport = r;
      _chargement = false;
    });
  }

  String _periodeTexte(AppLocalizations l10n) => l10n.situationPeriode(_debut.text.trim(), _fin.text.trim());

  Future<void> _exportExcel() async {
    final l10n = AppLocalizations.of(context);
    final r = _rapport;
    if (r == null) return;
    final nom = '${r.id}_${_debut.text.replaceAll('/', '')}_${_fin.text.replaceAll('/', '')}.xlsx';
    final chemin = await ref.read(selecteurEnregistrementProvider)(nom, 'xlsx');
    if (chemin == null || !mounted) return;
    final octets = ExportExcel.rapport(r, sousTitre: _periodeTexte(l10n));
    await ref.read(ecrivainFichierProvider)(chemin, octets);
    if (!mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.situationExportExcel,
        message: l10n.situationExportOk(chemin),
      ),
    );
  }

  Future<void> _apercuPdf() async {
    final l10n = AppLocalizations.of(context);
    final r = _rapport;
    if (r == null) return;
    final arabe = ref.read(localeProvider).languageCode == 'ar';
    final boutique = (await ref.read(parametresServiceProvider).lireBoutique())?.nom ?? '';
    final devise = ref.read(deviseProvider);
    final police = await policePdf(arabe);
    if (!mounted) return;
    final periode = _periodeTexte(l10n);
    await showDialog<void>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: '${l10n.situationApercuPdf} — ${libelleRapport(l10n, r.id)}',
        largeur: 900,
        actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop())],
        contenu: SizedBox(
          height: 560,
          child: PdfPreview(
            build: (_) => RapportPdf(police: police, rtl: arabe, devise: devise).generer(
              Rapport(
                id: r.id,
                titre: libelleRapport(l10n, r.id),
                colonnes: r.colonnes,
                lignes: r.lignes,
                totaux: r.totaux,
              ),
              boutique: boutique,
              periode: periode,
            ),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: false,
            pdfFileName: '${r.id}.pdf',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final session = ref.watch(sessionProvider);
    final peutExporter = session?.a(Permission.exporterDonnees) ?? false;
    final r = _rapport;
    return DsPage(
      titre: l10n.situationTitre,
      sousTitre: r == null ? null : libelleRapport(l10n, r.id),
      actions: [
        DsButton(
          libelle: l10n.situationExportExcel,
          icone: LucideIcons.fileSpreadsheet,
          variante: DsButtonVariante.secondaire,
          onPressed: peutExporter && r != null && !r.estVide
              ? () {
                  _exportExcel();
                }
              : null,
        ),
        DsButton(
          libelle: l10n.situationApercuPdf,
          icone: LucideIcons.fileText,
          variante: DsButtonVariante.secondaire,
          onPressed: peutExporter && r != null && !r.estVide
              ? () {
                  _apercuPdf();
                }
              : null,
        ),
      ],
      filtres: Wrap(
        spacing: DsSpacing.md,
        runSpacing: DsSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 280,
            child: DsSelect<String>(
              titre: l10n.situationRapport,
              valeur: _rapportId,
              options: StatistiquesRepository.rapports,
              libelle: (id) => libelleRapport(l10n, id),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _rapportId = v);
                _charger();
              },
            ),
          ),
          SizedBox(
            width: 150,
            child: DsTextField(controller: _debut, libelle: l10n.situationDu),
          ),
          SizedBox(
            width: 150,
            child: DsTextField(controller: _fin, libelle: l10n.situationAu),
          ),
          DsButton(
            libelle: l10n.situationAfficher,
            icone: LucideIcons.search,
            chargement: _chargement,
            onPressed: () {
              _charger();
            },
          ),
        ],
      ),
      child: r == null
          ? const SizedBox.shrink()
          : DsDataTable<List<Object?>>(
              key: ValueKey(r.id),
              colonnes: [
                for (final (i, col) in r.colonnes.indexed)
                  DsColonne<List<Object?>>(
                    id: '$i',
                    libelle: col.libelle,
                    valeur: (l) => l[i] is Comparable ? l[i] as Comparable : l[i]?.toString(),
                    flex: col.flex,
                    numerique: col.numerique,
                    total: r.totaux == null ? null : (_) => _formater(r.totaux![i], col, devise),
                    cellule: (_, l) => Text(_formater(l[i], col, devise)),
                  ),
              ],
              lignes: r.lignes,
              cle: (l) => r.lignes.indexOf(l),
              afficherTotaux: r.totaux != null,
              messageVide: l10n.situationAucuneLigne,
            ),
    );
  }

  static String _formater(Object? v, RapportColonne col, String devise) => switch (v) {
    null => '',
    final double d =>
      col.monetaire
          ? formaterMontant(d, devise)
          : (d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(2)),
    _ => v.toString(),
  };
}
