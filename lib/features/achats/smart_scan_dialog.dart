import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/smart_scan_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../produits/produits_providers.dart';
import 'achats_page.dart';

final smartScanServiceProvider = Provider<SmartScanService>((ref) {
  final s = ref.watch(serveurCaisseDzProvider).value;
  return SmartScanService(client: ref.watch(httpClientProvider), baseUrl: s?.url ?? '', cleApi: s?.cle);
});

/// Sélecteur de fichier (image ou PDF) ; remplacé dans les tests.
final selecteurFactureProvider = Provider<Future<XFile?> Function()>(
  (_) =>
      () => openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Factures', extensions: ['jpg', 'jpeg', 'png', 'pdf']),
        ],
      ),
);

String messageErreurSmartScan(AppLocalizations l10n, SmartScanException e) => switch (e.erreur) {
  ErreurSmartScan.nonConfigure => l10n.smartScanNonConfigure,
  ErreurSmartScan.quotaAtteint => l10n.smartScanQuotaAtteintDetail,
  ErreurSmartScan.reseau => l10n.smartScanErreurReseau(e.detail ?? ''),
  ErreurSmartScan.serveur => l10n.smartScanErreurServeur(e.detail ?? ''),
  ErreurSmartScan.fichierInvalide => l10n.smartScanErreurFichier,
};

/// Lignes rapprochées et référence renvoyées par le dialog Smart Scan.
typedef EntreeSmartScan = ({List<LigneAchatEdition> lignes, String? reference});

/// Smart Scan IA : choix du fichier, quota, analyse, rapprochement, puis formulaire d'entrée pré-rempli.
Future<void> afficherSmartScan(BuildContext context, WidgetRef ref) async {
  final r = await showDialog<EntreeSmartScan>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (_) => const SmartScanDialog(),
  );
  if (r == null || !context.mounted) return;
  await afficherFormulaireAchat(
    context,
    ref,
    lignesInitiales: r.lignes,
    referenceInitiale: r.reference,
    source: 'Smart Scan',
  );
}

class SmartScanDialog extends ConsumerStatefulWidget {
  const SmartScanDialog({super.key});

  @override
  ConsumerState<SmartScanDialog> createState() => _SmartScanDialogState();
}

class _SmartScanDialogState extends ConsumerState<SmartScanDialog> {
  QuotaSmartScan? _quota;
  String? _erreur;
  bool _quotaAtteint = false;
  bool _enCours = false;
  XFile? _fichier;
  ResultatSmartScan? _resultat;
  List<LigneSmartScan> _lignes = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_chargerQuota());
  }

  Future<void> _chargerQuota() async {
    try {
      await ref.read(serveurCaisseDzProvider.future);
      final q = await ref.read(smartScanServiceProvider).quota();
      if (!mounted) return;
      setState(() {
        _quota = q;
        _quotaAtteint = q.atteint;
        _erreur = null;
      });
    } on SmartScanException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = messageErreurSmartScan(AppLocalizations.of(context), e));
    }
  }

  Future<void> _choisir() async {
    final f = await ref.read(selecteurFactureProvider)();
    if (f == null || !mounted) return;
    setState(() {
      _fichier = f;
      _resultat = null;
    });
  }

  Future<void> _analyser() async {
    final l10n = AppLocalizations.of(context);
    final f = _fichier;
    if (f == null) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final r = await ref.read(smartScanServiceProvider).analyser(await f.readAsBytes(), nomFichier: f.name);
      final produits = await ref.read(produitsProvider.future);
      final lignes = [
        for (final l in r.lignes)
          l.copyWith(
            produitCode: produits
                .where(
                  (p) =>
                      (l.codeBarres != null && p.codeBarres == l.codeBarres) ||
                      p.designation.toLowerCase() == l.designation.toLowerCase(),
                )
                .firstOrNull
                ?.code,
          ),
      ];
      if (!mounted) return;
      setState(() {
        _resultat = r;
        _lignes = lignes;
        _quota = r.quota;
        _quotaAtteint = r.quota.atteint && lignes.isEmpty;
      });
    } on SmartScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = messageErreurSmartScan(l10n, e);
        _quotaAtteint = e.erreur == ErreurSmartScan.quotaAtteint;
      });
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _demanderOffre() async {
    final l10n = AppLocalizations.of(context);
    final email = TextEditingController();
    final message = TextEditingController(text: 'Je souhaite augmenter mon quota Smart Scan.');
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: l10n.smartScanDemandeOffre,
        largeur: 440,
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: l10n.smartScanDemandeOffre,
            icone: LucideIcons.send,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsTextField(
              controller: email,
              libelle: l10n.smartScanEmail,
              autofocus: true,
              typeClavier: TextInputType.emailAddress,
            ),
            const SizedBox(height: DsSpacing.md),
            DsTextField(controller: message, libelle: l10n.smartScanMessage),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(smartScanServiceProvider).demanderOffre(email: email.text.trim(), message: message.text.trim());
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.smartScanDemandeOffre,
          message: l10n.smartScanOffreEnvoyee,
        ),
      );
    } on SmartScanException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.smartScanDemandeOffre,
          message: messageErreurSmartScan(l10n, e),
        ),
      );
    }
  }

  Future<void> _rapprocher(int i) async {
    final l10n = AppLocalizations.of(context);
    final produits = await ref.read(produitsProvider.future);
    if (!mounted) return;
    final p = await afficherSelecteur<Produit>(
      context,
      titre: l10n.smartScanRapprocher,
      elements: produits,
      libelle: (p) => p.designation,
      sousLibelle: (p) => p.code,
    );
    if (p == null) return;
    setState(() => _lignes = [..._lignes]..[i] = _lignes[i].copyWith(produitCode: p.code));
  }

  Future<void> _creerEntree() async {
    final produits = await ref.read(produitsProvider.future);
    final lignes = [
      for (final l in _lignes)
        if (l.produitCode != null)
          LigneAchatEdition(
            produit: produits.firstWhere((p) => p.code == l.produitCode),
            quantite: l.quantite,
            prixAchat: l.prixAchat,
          ),
    ];
    if (!mounted) return;
    Navigator.of(context).pop<EntreeSmartScan>((lignes: lignes, reference: _resultat?.reference));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final q = _quota;
    final rapprochees = _lignes.where((l) => l.produitCode != null).length;
    return DsDialog(
      titre: l10n.smartScanTitre,
      largeur: 720,
      icone: Icon(LucideIcons.sparkles, color: c.primaire),
      actions: [
        if (_quotaAtteint)
          DsButton(
            libelle: l10n.smartScanDemandeOffre,
            icone: LucideIcons.mail,
            variante: DsButtonVariante.secondaire,
            onPressed: _demanderOffre,
          ),
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          libelle: l10n.smartScanCreerEntree,
          icone: LucideIcons.packagePlus,
          onPressed: rapprochees == 0 ? null : _creerEntree,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.smartScanIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.md),
          if (q != null)
            DsBadge(
              libelle: l10n.smartScanQuota(q.restant, q.total),
              ton: q.atteint ? DsBadgeTon.danger : DsBadgeTon.info,
              icone: LucideIcons.gauge,
            ),
          if (_quotaAtteint) ...[
            const SizedBox(height: DsSpacing.md),
            DsCard(
              child: Row(
                children: [
                  Icon(LucideIcons.circleAlert, color: c.danger),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.smartScanQuotaAtteint, style: t.corpsFort),
                        Text(l10n.smartScanQuotaAtteintDetail, style: t.petit.copyWith(color: c.texteSecondaire)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_erreur != null) ...[
            const SizedBox(height: DsSpacing.md),
            Text(_erreur!, style: t.petit.copyWith(color: c.danger)),
          ],
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              DsButton(
                libelle: l10n.smartScanChoisir,
                icone: LucideIcons.folderOpen,
                variante: DsButtonVariante.secondaire,
                onPressed: _choisir,
              ),
              const SizedBox(width: DsSpacing.sm),
              DsButton(
                libelle: l10n.smartScanAnalyser,
                icone: LucideIcons.scanLine,
                chargement: _enCours,
                onPressed: _fichier == null || _quotaAtteint ? null : _analyser,
              ),
              const SizedBox(width: DsSpacing.md),
              if (_fichier != null)
                Expanded(
                  child: Text(
                    _fichier!.name,
                    style: t.petit.copyWith(color: c.texteAttenue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (_resultat != null) ...[
            const SizedBox(height: DsSpacing.lg),
            if (_resultat!.fournisseur != null)
              Text('${l10n.achatFournisseur} : ${_resultat!.fournisseur}', style: t.corpsFort),
            if (_lignes.isEmpty) Text(l10n.smartScanAucuneLigne, style: t.petit.copyWith(color: c.texteAttenue)),
            for (final (i, l) in _lignes.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l.designation, style: t.corps, overflow: TextOverflow.ellipsis),
                    ),
                    Text('${l.quantite} × ${l.prixAchat.toStringAsFixed(2)}', style: t.petit),
                    const SizedBox(width: DsSpacing.md),
                    l.produitCode != null
                        ? DsBadge(libelle: l.produitCode!, ton: DsBadgeTon.succes, icone: LucideIcons.link)
                        : DsBadge(libelle: l10n.smartScanLigneNonRapprochee, ton: DsBadgeTon.avertissement),
                    DsIconButton(
                      icone: LucideIcons.link,
                      tooltip: l10n.smartScanRapprocher,
                      onPressed: () => _rapprocher(i),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
