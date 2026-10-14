import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/cloture_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/export/export_fiscal.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_dialogs.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';

/// Choix de l'emplacement d'enregistrement de l'archive (remplacé dans les tests).
final selecteurExportProvider = Provider<Future<String?> Function(String nomSuggere)>(
  (_) =>
      (nom) async => (await getSaveLocation(
        suggestedName: nom,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'ZIP', extensions: ['zip']),
        ],
      ))?.path,
);

/// Écriture de l'archive sur disque (remplacée dans les tests : les E/S fichier ne s'achèvent pas en zone de test).
final ecrivainExportProvider = Provider<Future<void> Function(String chemin, Uint8List octets)>(
  (_) =>
      (chemin, octets) => File(chemin).writeAsBytes(octets, flush: true),
);

/// Choix d'une archive à vérifier (remplacé dans les tests).
final selecteurArchiveProvider = Provider<Future<XFile?> Function()>(
  (_) =>
      () => openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'ZIP / JSON', extensions: ['zip', 'json']),
        ],
      ),
);

/// Module Clôtures Z : liste chaînée immuable, clôture avec aperçu, vérification, export fiscal (§12).
class CloturesPage extends ConsumerWidget {
  const CloturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final clotures = ref.watch(cloturesProvider).value ?? const [];
    final session = ref.watch(sessionProvider);
    final peutExporter = session?.a(Permission.exporterDonnees) ?? false;
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final derniere = clotures.firstOrNull;
    return DsPage(
      titre: l10n.cloturesTitre,
      actions: [
        DsButton(
          libelle: l10n.clotureVerifier,
          icone: LucideIcons.shieldCheck,
          variante: DsButtonVariante.secondaire,
          onPressed: () async {
            final ko = await ref.read(clotureServiceProvider).verifierChaine();
            if (!context.mounted) return;
            unawaited(
              afficherResultat(
                context,
                type: ko == null ? DsResultatType.succes : DsResultatType.erreur,
                titre: l10n.clotureVerifier,
                message: ko == null ? l10n.clotureChaineOk : l10n.clotureChaineKo(ko),
              ),
            );
          },
        ),
        DsButton(
          libelle: l10n.exportFiscalVerifier,
          icone: LucideIcons.fileCheck,
          variante: DsButtonVariante.secondaire,
          onPressed: () {
            _verifierArchive(context, ref);
          },
        ),
        DsButton(
          libelle: l10n.exportFiscalTitre,
          icone: LucideIcons.fileArchive,
          variante: DsButtonVariante.secondaire,
          onPressed: peutExporter
              ? () {
                  _exportFiscal(context, ref);
                }
              : null,
        ),
        DsButton(
          libelle: l10n.clotureNouvelle,
          icone: LucideIcons.lock,
          onPressed: () {
            _cloturer(context, ref);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DsStatCard(
                  libelle: l10n.clotureColVentes,
                  valeur: derniere == null ? '—' : '${derniere.nbVentes}',
                  icone: LucideIcons.receipt,
                  sousTexte: derniere?.code,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsStatCard(
                  libelle: l10n.clotureColTotalVentes,
                  valeur: derniere == null ? '—' : formaterMontant(derniere.totalVentes, devise),
                  icone: LucideIcons.banknote,
                  ton: DsBadgeTon.succes,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsStatCard(
                  libelle: l10n.clotureColEncaissements,
                  valeur: derniere == null ? '—' : formaterMontant(derniere.totalEncaissements, devise),
                  icone: LucideIcons.arrowDownToLine,
                  ton: DsBadgeTon.info,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsStatCard(
                  libelle: l10n.clotureFin,
                  valeur: derniere == null ? '—' : df.format(derniere.fin),
                  icone: LucideIcons.calendarCheck,
                  ton: DsBadgeTon.neutre,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.md),
          Text(l10n.clotureAvertissementImmuable, style: t.petit.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.md),
          Expanded(
            child: DsDataTable<Cloture>(
              colonnes: [
                DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (z) => z.code, largeur: 100),
                DsColonne(
                  id: 'd',
                  libelle: l10n.communDate,
                  valeur: (z) => z.date,
                  largeur: 150,
                  cellule: (_, z) => Text(df.format(z.date)),
                ),
                DsColonne(
                  id: 'p',
                  libelle: l10n.cloturePeriode,
                  valeur: (z) => z.debut,
                  flex: 3,
                  cellule: (_, z) => Text('${df.format(z.debut)} → ${df.format(z.fin)}'),
                ),
                DsColonne(id: 'n', libelle: l10n.clotureColVentes, valeur: (z) => z.nbVentes, numerique: true),
                DsColonne(
                  id: 'na',
                  libelle: l10n.clotureColAnnulations,
                  valeur: (z) => z.nbAnnulations,
                  numerique: true,
                  visibleParDefaut: false,
                ),
                DsColonne(
                  id: 't',
                  libelle: l10n.clotureColTotalVentes,
                  valeur: (z) => z.totalVentes,
                  numerique: true,
                  cellule: (_, z) => Text(formaterMontant(z.totalVentes, devise)),
                ),
                DsColonne(
                  id: 'e',
                  libelle: l10n.clotureColEncaissements,
                  valeur: (z) => z.totalEncaissements,
                  numerique: true,
                  cellule: (_, z) => Text(formaterMontant(z.totalEncaissements, devise)),
                ),
                DsColonne(
                  id: 'dec',
                  libelle: l10n.clotureColDecaissements,
                  valeur: (z) => z.totalDecaissements,
                  numerique: true,
                  cellule: (_, z) => Text(formaterMontant(z.totalDecaissements, devise)),
                ),
                DsColonne(
                  id: 'h',
                  libelle: l10n.clotureColHash,
                  valeur: (z) => z.hash,
                  flex: 2,
                  triable: false,
                  cellule: (_, z) =>
                      DsBadge(libelle: '${z.hash.substring(0, 12)}…', ton: DsBadgeTon.neutre, icone: LucideIcons.lock),
                ),
                DsColonne(
                  id: 'u',
                  libelle: l10n.clotureColUtilisateur,
                  valeur: (z) => z.utilisateurCode,
                  visibleParDefaut: false,
                ),
              ],
              lignes: clotures,
              cle: (z) => z.code,
              messageVide: l10n.clotureAucune,
              onDoubleClic: (z) => _detail(context, ref, z),
              actionsContextuelles: [
                DsActionContextuelle(
                  libelle: l10n.clotureDetail,
                  icone: LucideIcons.eye,
                  onSelected: (z) => _detail(context, ref, z),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recap(BuildContext context, Cloture z, String devise) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final df = DateFormat('dd/MM/yyyy HH:mm');
    Widget ligne(String libelle, String valeur, {bool fort = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(libelle, style: t.petit.copyWith(color: c.texteSecondaire)),
          ),
          const SizedBox(width: DsSpacing.md),
          Flexible(
            flex: 2,
            child: Text(valeur, style: fort ? t.corpsFort : t.corps, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ligne(l10n.cloturePeriode, '${df.format(z.debut)} → ${df.format(z.fin)}'),
        ligne(l10n.clotureColVentes, '${z.nbVentes}'),
        ligne(l10n.clotureColAnnulations, '${z.nbAnnulations}'),
        ligne(l10n.clotureColTotalVentes, formaterMontant(z.totalVentes, devise), fort: true),
        ligne(l10n.clotureColRemises, formaterMontant(z.totalRemises, devise)),
        ligne(l10n.clotureColRetours, formaterMontant(z.totalRetours, devise)),
        ligne(l10n.clotureColEncaissements, formaterMontant(z.totalEncaissements, devise), fort: true),
        ligne(l10n.clotureColDecaissements, formaterMontant(z.totalDecaissements, devise)),
        const DsDivider(),
        Text(l10n.clotureParMode, style: t.petitFort),
        for (final e in z.encaissementsParMode.entries)
          ligne(libelleModePaiement(l10n, e.key), formaterMontant(e.value, devise)),
        const DsDivider(),
        Text(l10n.clotureSoldes, style: t.petitFort),
        for (final e in z.soldesCaisses.entries) ligne(e.key, formaterMontant(e.value, devise)),
        const DsDivider(),
        ligne(l10n.clotureDerniereVente, z.derniereVente ?? '—'),
        ligne(l10n.clotureHashPrecedent, '${z.hashPrecedent.substring(0, 16)}…'),
        if (z.hash.isNotEmpty) ligne(l10n.clotureHash, '${z.hash.substring(0, 16)}…'),
      ],
    );
  }

  Future<void> _detail(BuildContext context, WidgetRef ref, Cloture z) async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    await showDialog<void>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: '${l10n.clotureDetail} — ${z.code}',
        largeur: 520,
        icone: Icon(LucideIcons.lock, color: ctx.ds.colors.primaire),
        actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop())],
        contenu: SelectableRegion(
          selectionControls: materialTextSelectionControls,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _recap(ctx, z, devise),
              const SizedBox(height: DsSpacing.sm),
              Text(z.hash, style: ctx.ds.typo.legende.copyWith(color: ctx.ds.colors.texteAttenue)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cloturer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final service = ref.read(clotureServiceProvider);
    Cloture apercu;
    try {
      apercu = await service.apercu();
    } on ClotureException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.clotureNouvelle,
          message: messageErreurCloture(l10n, e.erreur),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: l10n.clotureApercuTitre,
        largeur: 520,
        icone: Icon(LucideIcons.lock, color: ctx.ds.colors.avertissement),
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: l10n.clotureConfirmer,
            icone: LucideIcons.lock,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _recap(ctx, apercu, devise),
            const SizedBox(height: DsSpacing.md),
            Text(
              l10n.clotureAvertissementImmuable,
              style: ctx.ds.typo.petit.copyWith(color: ctx.ds.colors.avertissement),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final z = await service.cloturer();
      rafraichirCaisse(ref);
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.clotureNouvelle,
          message: l10n.clotureCreee(z.code, '${z.hash.substring(0, 16)}…'),
        ),
      );
    } on ClotureException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.clotureNouvelle,
          message: messageErreurCloture(l10n, e.erreur),
        ),
      );
    }
  }

  Future<void> _exportFiscal(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final dfJour = DateFormat('dd/MM/yyyy');
    final clotures = await ref.read(cloturesProvider.future);
    if (!context.mounted) return;
    final maintenant = DateTime.now();
    final debut = TextEditingController(
      text: dfJour.format(
        clotures.isEmpty
            ? DateTime(maintenant.year, maintenant.month)
            : clotures.last.debut.add(const Duration(seconds: 1)),
      ),
    );
    final fin = TextEditingController(text: dfJour.format(maintenant));
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: l10n.exportFiscalTitre,
        largeur: 440,
        icone: Icon(LucideIcons.fileArchive, color: ctx.ds.colors.primaire),
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: l10n.exportFiscalGenerer,
            icone: LucideIcons.download,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Row(
          children: [
            Expanded(
              child: DsTextField(controller: debut, libelle: l10n.exportFiscalDebut, autofocus: true),
            ),
            const SizedBox(width: DsSpacing.md),
            Expanded(
              child: DsTextField(controller: fin, libelle: l10n.exportFiscalFin),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    DateTime d1;
    DateTime d2;
    try {
      d1 = dfJour.parseStrict(debut.text.trim());
      d2 = dfJour.parseStrict(fin.text.trim()).add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    } on FormatException {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.exportFiscalTitre,
          message: l10n.exportFiscalErreurDates,
        ),
      );
      return;
    }
    if (d2.isBefore(d1)) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.exportFiscalTitre,
          message: l10n.exportFiscalErreurDates,
        ),
      );
      return;
    }
    final nom = 'export_fiscal_${DateFormat('yyyyMMdd').format(d1)}_${DateFormat('yyyyMMdd').format(d2)}.zip';
    final chemin = await ref.read(selecteurExportProvider)(nom);
    if (chemin == null || !context.mounted) return;
    final export = ExportFiscal(ref.read(appDatabaseProvider).db);
    final zip = await export.generer(debut: d1, fin: d2, utilisateurCode: ref.read(utilisateurCourantCodeProvider));
    await ref.read(ecrivainExportProvider)(chemin, zip);
    final verif = ExportFiscal.verifier(zip);
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: verif.valide ? DsResultatType.succes : DsResultatType.erreur,
        titre: l10n.exportFiscalTitre,
        message: verif.valide
            ? l10n.exportFiscalOk(chemin, verif.nbVentes, verif.nbClotures)
            : l10n.exportFiscalVerifKo(verif.erreurs.join(', ')),
      ),
    );
  }

  Future<void> _verifierArchive(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final f = await ref.read(selecteurArchiveProvider)();
    if (f == null) return;
    final verif = ExportFiscal.verifier(await f.readAsBytes());
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: verif.valide ? DsResultatType.succes : DsResultatType.erreur,
        titre: l10n.exportFiscalVerifier,
        message: verif.valide
            ? l10n.exportFiscalVerifOk(verif.nbVentes, verif.nbClotures)
            : l10n.exportFiscalVerifKo(verif.erreurs.join(', ')),
      ),
    );
  }
}
