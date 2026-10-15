import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../application/catalogue_service.dart';
import '../../application/import_produits_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/etiquettes_pdf.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/export_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../stock/stock_providers.dart';
import 'produits_donnees.dart';
import 'produits_providers.dart';

String messageErreurCatalogue(AppLocalizations l10n, ErreurCatalogue e) => switch (e) {
  ErreurCatalogue.designationVide => l10n.produitErreurDesignation,
  ErreurCatalogue.codeBarresInvalide => l10n.produitErreurCodeBarres,
  ErreurCatalogue.codeBarresDejaUtilise => l10n.produitErreurCodeBarresPris,
  ErreurCatalogue.prixInvalide => l10n.produitErreurPrix,
  ErreurCatalogue.quantiteInvalide => l10n.produitErreurQuantite,
  ErreurCatalogue.categorieSysteme => l10n.categorieErreurSysteme,
  ErreurCatalogue.categorieUtilisee => l10n.categorieErreurUtilisee,
  ErreurCatalogue.lignesVides => l10n.packErreurLignes,
  ErreurCatalogue.produitUtilise => l10n.produitErreurUtilise,
  ErreurCatalogue.nomDejaUtilise => l10n.catalogueErreurNomPris,
};

// ============================================================ Détail

/// Fiche produit (`ProduitDetailDialog`, 1120 px) : stats, informations, stock par magasin, code-barres,
/// derniers mouvements.
Future<void> afficherDetailProduit(
  BuildContext context,
  WidgetRef ref,
  Produit p, {
  VoidCallback? onModifier,
  VoidCallback? onEtiquette,
}) async {
  final repartition = await ref.read(stockRepositoryProvider).repartition(p.code);
  final magasins = await ref.read(magasinsProvider.future);
  final mouvements = await ref.read(stockRepositoryProvider).mouvements(produitCode: p.code, limite: 8);
  final stats = await ref
      .read(catalogueRepositoryProvider)
      .statsProduit(p.code, DateTime.now().subtract(const Duration(days: 30)));
  final emballages = await ref.read(catalogueServiceProvider).emballages(p.code);
  final categories = await ref.read(categoriesProvider.future);
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (_) => _DetailProduit(
      produit: p,
      repartition: repartition,
      magasins: magasins,
      mouvements: mouvements,
      prixMoyen: stats.prixMoyenAchat,
      vendus: stats.vendus,
      emballages: emballages,
      categorie: categories.where((c) => c.code == p.categorieCode).firstOrNull?.nom ?? '',
      onModifier: onModifier,
      onEtiquette: onEtiquette,
    ),
  );
}

class _DetailProduit extends ConsumerWidget {
  const _DetailProduit({
    required this.produit,
    required this.repartition,
    required this.magasins,
    required this.mouvements,
    required this.prixMoyen,
    required this.vendus,
    required this.emballages,
    required this.categorie,
    this.onModifier,
    this.onEtiquette,
  });
  final Produit produit;
  final List<NiveauStock> repartition;
  final List<Magasin> magasins;
  final List<MouvementStock> mouvements;
  final double? prixMoyen;
  final double vendus;
  final List<Colis> emballages;
  final String categorie;
  final VoidCallback? onModifier;
  final VoidCallback? onEtiquette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final p = produit;
    final devise = ref.watch(deviseProvider);
    final voirAchat = permissionsSession(ref).contains(Permission.voirPrixAchat.code);
    final seuil = seuilDe(p, ref.watch(parametresVenteProvider).value?.seuilStockGlobal ?? 5);
    final stock = repartition.fold(0.0, (s, n) => s + n.quantite);
    final etat = etatStockProduit(p, stock, seuil);
    final nomsMag = {for (final m in magasins) m.code: m.nom};
    final lignesMag = [
      for (final m in magasins.where((m) => m.actif || repartition.any((n) => n.magasinCode == m.code)))
        (code: m.code, nom: m.nom, q: repartition.where((n) => n.magasinCode == m.code).firstOrNull?.quantite ?? 0),
    ];
    String emb(int i) => i < emballages.length
        ? '${l10n.prdEmballagePieces(emballages[i].quantite)} · ${formaterMontant(emballages[i].prixVente, devise)}'
        : '—';
    void fermerPuis(VoidCallback? f) {
      Navigator.of(context).pop();
      f?.call();
    }

    return DsDialog(
      titre: p.designation,
      iconeData: LucideIcons.package,
      description: [p.code, categorie, if ((p.marque ?? '').isNotEmpty) p.marque!].join(' · '),
      largeur: 1120,
      actions: [
        if (onEtiquette != null)
          DsButton(
            libelle: l10n.prdEtiquette,
            icone: LucideIcons.barcode,
            variante: DsButtonVariante.secondaire,
            onPressed: () => fermerPuis(onEtiquette),
          ),
        if (onModifier != null)
          DsButton(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            variante: DsButtonVariante.secondaire,
            onPressed: () => fermerPuis(onModifier),
          ),
        DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(context).pop()),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsStatsStrip(
            items: [
              DsStatItem(
                libelle: l10n.prdStockTotal,
                valeur: formaterNombre(stock),
                suffixe: l10n.prdPcs,
                icone: LucideIcons.boxes,
                ton: etat == 'actif' ? DsBadgeTon.primaire : DsBadgeTon.danger,
                tonValeur: stock <= 0 && !p.service ? DsBadgeTon.danger : null,
              ),
              if (voirAchat) ...[
                DsStatItem(
                  libelle: l10n.prdKpiValeurStock,
                  valeur: f2(stock > 0 ? stock * p.prixAchat : 0),
                  suffixe: devise,
                  icone: LucideIcons.wallet,
                ),
                DsStatItem(
                  libelle: l10n.prdPrixMoyenAchat,
                  valeur: f2(prixMoyen ?? p.prixAchat),
                  suffixe: devise,
                  icone: LucideIcons.shoppingCart,
                ),
              ],
              DsStatItem(
                libelle: l10n.produitChampPrixVente,
                valeur: f2(p.prixVente),
                suffixe: devise,
                icone: LucideIcons.tag,
              ),
              if (voirAchat)
                DsStatItem(
                  libelle: l10n.prdMarge,
                  valeur: formaterNombre(margeProduit(p), decimales: 1),
                  suffixe: '%',
                  icone: LucideIcons.trendingUp,
                  ton: DsBadgeTon.succes,
                ),
              DsStatItem(libelle: l10n.prdVendus30, valeur: formaterNombre(vendus), icone: LucideIcons.receipt),
            ],
          ),
          LayoutBuilder(
            builder: (context, contraintes) {
              final gauche = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14,
                children: [
                  DsDetailSection(
                    titre: l10n.prdInformations,
                    icone: LucideIcons.info,
                    child: DsKeyValueGrid(
                      dense: true,
                      items: [
                        DsKeyValue(l10n.produitsColCode, p.code, mono: true),
                        DsKeyValue(l10n.produitsColCategorie, categorie),
                        DsKeyValue(l10n.prdMarque, p.marque),
                        DsKeyValue(l10n.produitChampUnite, libelleRef(context, Referentiel.unitesMesure, p.unite)),
                        DsKeyValue(l10n.prdTva, '${formaterNombre(p.tvaPct)} %'),
                        DsKeyValue(l10n.retoursEtat, null, widget: BadgeStatut(etat)),
                        DsKeyValue(l10n.prdEmballageN(1), emb(0)),
                        DsKeyValue(l10n.prdEmballageN(2), emb(1)),
                        DsKeyValue(l10n.prdSeuilAlerte, '$seuil ${l10n.prdPcs}'),
                        if (p.dateExpiration != null) DsKeyValue(l10n.prdDateExpiration, dateOuTiret(p.dateExpiration)),
                        if ((p.taille ?? '').isNotEmpty) DsKeyValue(l10n.prdTaille, p.taille),
                        if ((p.couleur ?? '').isNotEmpty) DsKeyValue(l10n.prdCouleur, p.couleur),
                      ],
                    ),
                  ),
                  DsDetailSection(
                    titre: l10n.prdStockParMagasin,
                    icone: LucideIcons.store,
                    compte: lignesMag.length,
                    padding: EdgeInsets.zero,
                    child: DsDataTable<({String code, String nom, double q})>(
                      dense: true,
                      encadre: false,
                      pagine: false,
                      cle: (m) => m.code,
                      lignes: lignesMag,
                      messageVide: l10n.dsAucunElement,
                      colonnes: [
                        DsColonne(id: 'nom', libelle: l10n.dsMagasin, valeur: (m) => m.nom, fort: true, flex: 2),
                        DsColonne(
                          id: 'q',
                          libelle: l10n.communQuantite,
                          numerique: true,
                          valeur: (m) => m.q,
                          cellule: (_, m) => Text(formaterNombre(m.q)),
                          total: (_) => formaterNombre(stock),
                        ),
                        if (voirAchat)
                          DsColonne(
                            id: 'v',
                            libelle: l10n.prdValeur,
                            numerique: true,
                            valeur: (m) => m.q * p.prixAchat,
                            cellule: (_, m) => Text(formaterMontant(m.q * p.prixAchat, devise)),
                            total: (_) => formaterMontant(stock * p.prixAchat, devise),
                          ),
                      ],
                    ),
                  ),
                ],
              );
              final carte = DsBarcodeCard(
                valeur: p.codeBarres,
                nom: p.designation,
                prix: p.prixVente,
                devise: devise,
                compact: true,
                onImprimer: onEtiquette == null ? null : () => fermerPuis(onEtiquette),
              );
              if (contraintes.maxWidth < 760) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [gauche, carte]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  Expanded(child: gauche),
                  SizedBox(width: 300, child: carte),
                ],
              );
            },
          ),
          DsDetailSection(
            titre: l10n.prdDerniersMouvements,
            icone: LucideIcons.arrowLeftRight,
            compte: mouvements.length,
            padding: EdgeInsets.zero,
            child: DsDataTable<MouvementStock>(
              dense: true,
              encadre: false,
              pagine: false,
              cle: (m) => m.id ?? m.hashCode,
              lignes: mouvements,
              messageVide: l10n.dsAucunElement,
              colonnes: [
                DsColonne(
                  id: 'd',
                  libelle: l10n.communDate,
                  attenue: true,
                  valeur: (m) => m.date,
                  cellule: (_, m) => Text(formatDate.format(m.date)),
                ),
                DsColonne(
                  id: 't',
                  libelle: l10n.remiseType,
                  valeur: (m) => libelleRef(context, Referentiel.typesMouvement, m.type),
                ),
                DsColonne(id: 'r', libelle: l10n.prdReference, attenue: true, valeur: (m) => m.referenceCode ?? ''),
                DsColonne(id: 'mag', libelle: l10n.dsMagasin, valeur: (m) => nomsMag[m.magasinCode] ?? m.magasinCode),
                DsColonne(
                  id: 'q',
                  libelle: l10n.communQuantite,
                  numerique: true,
                  valeur: (m) => m.quantite,
                  cellule: (_, m) => Text(
                    m.quantite > 0 ? '+${formaterNombre(m.quantite)}' : formaterNombre(m.quantite),
                    style: t.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: m.quantite > 0 ? c.successFg : c.dangerFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================ Code-barres & étiquettes

enum FormatEtiquette { a4, rouleau40, rouleau58 }

/// Code-barres & étiquettes (`CodeBarreDialog`, 760 px) : EAN-13 ou code interne, nombre, format, aperçu.
Future<void> afficherCodeBarre(BuildContext context, Produit p) =>
    afficherDialog<void>(context, builder: (_) => _CodeBarreDialog(p));

class _CodeBarreDialog extends ConsumerStatefulWidget {
  const _CodeBarreDialog(this.produit);
  final Produit produit;

  @override
  ConsumerState<_CodeBarreDialog> createState() => _CodeBarreDialogState();
}

class _CodeBarreDialogState extends ConsumerState<_CodeBarreDialog> {
  late final _code = TextEditingController(text: widget.produit.codeBarres ?? '');
  final _nombre = TextEditingController(text: '12');
  late bool _ean = widget.produit.codeBarres == null || CodesBarres.ean13Valide(widget.produit.codeBarres!);
  FormatEtiquette _format = FormatEtiquette.a4;
  String? _erreur;

  @override
  void dispose() {
    _code.dispose();
    _nombre.dispose();
    super.dispose();
  }

  int get _n => int.tryParse(_nombre.text.trim()) ?? 0;

  Future<void> _generer() async {
    if (_ean) {
      setState(() => _code.text = CodesBarres.genererEan13());
    } else {
      final maj = await ref.read(catalogueServiceProvider).genererCodeBarresInterne(widget.produit.code);
      rafraichirCatalogue(ref);
      if (mounted) setState(() => _code.text = maj.codeBarres ?? '');
    }
  }

  /// Enregistre le code saisi s'il a changé ; renvoie le produit à imprimer ou `null` (erreur).
  Future<Produit?> _produitAJour() async {
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim();
    if (code == (widget.produit.codeBarres ?? '')) return widget.produit;
    try {
      final maj = await ref.read(catalogueServiceProvider).modifierProduit(widget.produit.copyWith(codeBarres: code));
      rafraichirCatalogue(ref);
      return maj;
    } on CatalogueException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCatalogue(l10n, e.erreur));
      return null;
    }
  }

  Future<Uint8List?> _pdf() async {
    final p = await _produitAJour();
    if (p == null) return null;
    final devise = ref.read(deviseProvider);
    final etiquettes = [Etiquette(produit: p, quantite: _n)];
    return switch (_format) {
      FormatEtiquette.a4 => EtiquettesPdf(largeurMm: 38, hauteurMm: 21, devise: devise).plancheA4(etiquettes),
      FormatEtiquette.rouleau40 => EtiquettesPdf(largeurMm: 40, hauteurMm: 30, devise: devise).rouleau(etiquettes),
      FormatEtiquette.rouleau58 => EtiquettesPdf(largeurMm: 58, hauteurMm: 40, devise: devise).rouleau(etiquettes),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final v = _code.text.trim();
    final champs = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        DsChoiceCards<bool>(
          petit: true,
          colonnes: 1,
          valeur: _ean,
          onChanged: (x) => setState(() => _ean = x),
          options: [
            DsOption(true, libelle: 'EAN-13', description: l10n.prdEanAide),
            DsOption(false, libelle: l10n.prdCodeInterne, description: l10n.prdCodeInterneAide),
          ],
        ),
        DsFormRow(
          libelle: l10n.produitsColCode,
          obligatoire: true,
          largeurLibelle: 96,
          erreur: _erreur,
          child: Row(
            spacing: 6,
            children: [
              Expanded(
                child: DsTextField(
                  key: const ValueKey('etiquette_code'),
                  controller: _code,
                  iconePrefixe: LucideIcons.barcode,
                  onChanged: (_) => setState(() => _erreur = null),
                ),
              ),
              DsButton(
                libelle: l10n.dsBarcodeGenerer,
                icone: LucideIcons.wandSparkles,
                variante: DsButtonVariante.doux,
                onPressed: _generer,
              ),
            ],
          ),
        ),
        DsFormRow(
          libelle: l10n.prdEtiquettes,
          largeurLibelle: 96,
          child: DsTextField(
            key: const ValueKey('etiquette_nombre'),
            controller: _nombre,
            numerique: true,
            suffixeTexte: l10n.prdPcs,
            onChanged: (_) => setState(() {}),
          ),
        ),
        DsFormRow(
          libelle: l10n.prdFormat,
          largeurLibelle: 96,
          child: DsSelect<FormatEtiquette>(
            valeur: _format,
            options: FormatEtiquette.values,
            libelle: (f) => switch (f) {
              FormatEtiquette.a4 => l10n.prdFormatA4,
              FormatEtiquette.rouleau40 => l10n.prdFormatRouleau40,
              FormatEtiquette.rouleau58 => l10n.prdFormatRouleau58,
            },
            onChanged: (f) => setState(() => _format = f ?? _format),
          ),
        ),
      ],
    );
    final apercu = DsBarcodeCard(
      valeur: v.isEmpty ? null : v,
      nom: widget.produit.designation,
      prix: widget.produit.prixVente,
      devise: devise,
      onGenerer: _generer,
    );
    return DsDialog(
      titre: l10n.prdCodeBarreTitre,
      iconeData: LucideIcons.barcode,
      description: '${widget.produit.designation} · ${widget.produit.code}',
      largeur: 760,
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          libelle: 'PDF',
          icone: LucideIcons.fileDown,
          variante: DsButtonVariante.secondaire,
          onPressed: v.isEmpty || _n <= 0
              ? null
              : () async {
                  final octets = await _pdf();
                  if (octets != null) await Printing.sharePdf(bytes: octets, filename: 'etiquettes.pdf');
                },
        ),
        DsButton(
          key: const ValueKey('etiquette_imprimer'),
          libelle: l10n.prdImprimerEtiquettes(_n),
          icone: LucideIcons.printer,
          onPressed: v.isEmpty || _n <= 0
              ? null
              : () async {
                  final octets = await _pdf();
                  if (octets != null) await Printing.layoutPdf(onLayout: (_) async => octets, name: 'etiquettes.pdf');
                },
        ),
      ],
      contenu: LayoutBuilder(
        builder: (context, contraintes) => contraintes.maxWidth < 600
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 20, children: [champs, apercu])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Expanded(child: champs),
                  SizedBox(width: 260, child: apercu),
                ],
              ),
      ),
    );
  }
}

// ============================================================ Affecter

enum _CibleAffectation { categorie, remise, pack }

/// Affectation en lot (`AffecterDialog`, 640 px) : catégorie / sous-catégorie, remise « Par Produit » ou pack.
Future<void> afficherAffecter(BuildContext context, WidgetRef ref, List<Produit> choix, VoidCallback effacer) async {
  final ok = await afficherDialog<bool>(context, builder: (_) => _AffecterDialog(choix));
  if (ok == true) effacer();
}

class _AffecterDialog extends ConsumerStatefulWidget {
  const _AffecterDialog(this.produits);
  final List<Produit> produits;

  @override
  ConsumerState<_AffecterDialog> createState() => _AffecterDialogState();
}

class _AffecterDialogState extends ConsumerState<_AffecterDialog> {
  _CibleAffectation _cible = _CibleAffectation.categorie;
  String? _valeur;
  String? _sous;
  bool _remplacer = true;

  Future<void> _affecter() async {
    final l10n = AppLocalizations.of(context);
    final codes = [for (final p in widget.produits) p.code];
    final service = ref.read(catalogueServiceProvider);
    String libelle = '';
    switch (_cible) {
      case _CibleAffectation.categorie:
        final sc = _sous ?? (await ref.read(catalogueRepositoryProvider).sousCategories(_valeur)).first.code;
        await service.affecter(codes, sousCategorieCode: sc, remplacer: _remplacer);
        libelle =
            (ref.read(categoriesProvider).value ?? const []).where((c) => c.code == _valeur).firstOrNull?.nom ?? '';
      case _CibleAffectation.remise:
        await service.affecter(codes, remiseCode: _valeur, remplacer: _remplacer);
        libelle =
            (ref.read(remisesProvider).value ?? const []).where((r) => r.code == _valeur).firstOrNull?.designation ??
            '';
      case _CibleAffectation.pack:
        await service.affecter(codes, packCode: _valeur, remplacer: _remplacer);
        libelle =
            (ref.read(packsProvider).value ?? const []).where((k) => k.code == _valeur).firstOrNull?.designation ?? '';
    }
    rafraichirCatalogue(ref);
    if (!mounted) return;
    Navigator.of(context).pop(true);
    afficherToast(
      context,
      titre: l10n.prdToastAffectation,
      description: l10n.prdToastAffectationDesc(codes.length, libelle),
      ton: DsToastTon.succes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = (ref.watch(categoriesProvider).value ?? const <Categorie>[]).where((c) => c.actif).toList();
    final sous = (ref.watch(sousCategoriesProvider).value ?? const <SousCategorie>[])
        .where((s) => s.actif && s.categorieCode == _valeur)
        .toList();
    final remises = (ref.watch(remisesProvider).value ?? const <Remise>[])
        .where((r) => r.actif && !r.parMontant)
        .toList();
    final packs = (ref.watch(packsProvider).value ?? const <Pack>[]).where((k) => k.actif).toList();
    final options = switch (_cible) {
      _CibleAffectation.categorie => {for (final c in categories) c.code: c.nom},
      _CibleAffectation.remise => {for (final r in remises) r.code: r.designation},
      _CibleAffectation.pack => {for (final k in packs) k.code: k.designation},
    };
    if (_valeur == null || !options.containsKey(_valeur)) _valeur = options.keys.firstOrNull;
    final n = widget.produits.length;
    final noms = widget.produits.take(3).map((p) => p.designation).join(', ');
    return DsDialog(
      titre: l10n.prdAffecterN(n),
      iconeData: LucideIcons.tags,
      description: n > 3 ? '$noms… +${n - 3}' : noms,
      largeur: 640,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('affecter_valider'),
          libelle: l10n.prdAffecter,
          icone: LucideIcons.check,
          onPressed: _valeur == null ? null : _affecter,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsChoiceCards<_CibleAffectation>(
            petit: true,
            valeur: _cible,
            onChanged: (v) => setState(() {
              _cible = v;
              _valeur = null;
              _sous = null;
            }),
            options: [
              DsOption(_CibleAffectation.categorie, libelle: l10n.produitsColCategorie, icone: LucideIcons.folder),
              DsOption(_CibleAffectation.remise, libelle: l10n.prdRemise, icone: LucideIcons.percent),
              DsOption(_CibleAffectation.pack, libelle: l10n.prdPack, icone: LucideIcons.gift),
            ],
          ),
          DsFormRow(
            libelle: switch (_cible) {
              _CibleAffectation.categorie => l10n.produitsColCategorie,
              _CibleAffectation.remise => l10n.prdRemise,
              _CibleAffectation.pack => l10n.prdPack,
            },
            obligatoire: true,
            child: DsSelect<String>(
              cle: const ValueKey('affecter_cible'),
              valeur: _valeur,
              options: options.keys.toList(),
              libelle: (k) => options[k] ?? k,
              placeholder: l10n.communAucune,
              onChanged: (v) => setState(() {
                _valeur = v;
                _sous = null;
              }),
            ),
          ),
          if (_cible == _CibleAffectation.categorie)
            DsFormRow(
              libelle: l10n.produitChampSousCategorie,
              child: DsSelect<String?>(
                valeur: _sous,
                options: [null, for (final s in sous) s.code],
                libelle: (k) => k == null ? l10n.communAucune : (sous.where((s) => s.code == k).firstOrNull?.nom ?? k),
                onChanged: (v) => setState(() => _sous = v),
              ),
            ),
          DsSwitch(
            valeur: _remplacer,
            libelle: l10n.prdRemplacerAffectation,
            aide: switch (_cible) {
              _CibleAffectation.pack => l10n.prdRemplacerPackAide,
              _CibleAffectation.categorie => l10n.prdRemplacerCategorieAide,
              _CibleAffectation.remise => l10n.prdRemplacerRemiseAide,
            },
            onChanged: (v) => setState(() => _remplacer = v),
          ),
        ],
      ),
    );
  }
}

// ============================================================ Suppression

/// Suppression en lot (`BulkActionDialog delete`) : bloquée si stock ou mouvements liés (désactiver).
Future<void> supprimerProduits(
  BuildContext context,
  WidgetRef ref,
  List<Produit> choix,
  VoidCallback effacer, {
  required Map<String, double> stocks,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: l10n.prdEntiteProduit,
    entitePluriel: l10n.prdEntiteProduits,
    elements: [
      for (final p in choix)
        DsElementLot(
          id: p.code,
          titre: p.designation,
          sousTitre: p.code,
          meta: l10n.prdStockN(formaterNombre(stocks[p.code] ?? 0)),
          motifBlocage: (stocks[p.code] ?? 0) != 0 ? l10n.prdSuppressionBloquee : null,
        ),
    ],
  );
  if (ok == null) return;
  final service = ref.read(catalogueServiceProvider);
  var supprimes = 0;
  var refuses = 0;
  for (final p in choix.where((p) => (stocks[p.code] ?? 0) == 0)) {
    try {
      await service.supprimerProduits([p.code]);
      supprimes++;
    } on CatalogueException {
      refuses++;
    }
  }
  rafraichirCatalogue(ref);
  effacer();
  if (!context.mounted) return;
  afficherToast(
    context,
    titre: l10n.prdToastSupprimes(supprimes),
    description: refuses > 0 ? l10n.prdToastRefuses(refuses) : null,
    ton: refuses > 0 ? DsToastTon.avertissement : DsToastTon.succes,
  );
}

// ============================================================ Import Excel

/// Import de produits (`ImportExcelDialog`, 900 px) : Fichier → Colonnes → Aperçu.
Future<void> afficherImportProduits(BuildContext context) =>
    afficherDialog<void>(context, fermableParVoile: false, builder: (_) => const _ImportDialog());

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();
  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  int _etape = 1;
  Uint8List? _octets;
  String? _fichier;
  int _taille = 0;
  List<String> _entetes = const [];

  /// Champ choisi pour chaque colonne du fichier (`null` = ignorée).
  List<String?> _champs = const [];
  List<LigneImport>? _lignes;
  String? _erreur;
  bool _occupe = false;

  Future<void> _choisir() async {
    final l10n = AppLocalizations.of(context);
    final f = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Excel', extensions: ['xlsx']),
      ],
    );
    if (f == null) return;
    try {
      final octets = await f.readAsBytes();
      final service = ref.read(importProduitsServiceProvider);
      final entetes = service.entetes(octets);
      final auto = service.correspondanceAuto(entetes);
      setState(() {
        _octets = octets;
        _fichier = f.name;
        _taille = octets.length;
        _entetes = entetes;
        _champs = [for (var i = 0; i < entetes.length; i++) auto.entries.where((e) => e.value == i).firstOrNull?.key];
        _lignes = null;
        _erreur = null;
      });
    } on Object catch (e) {
      setState(() => _erreur = l10n.importErreurFichier(e.toString()));
    }
  }

  Future<void> _modele() async {
    final emplacement = await getSaveLocation(suggestedName: 'modele_produits.xlsx');
    if (emplacement == null) return;
    await File(emplacement.path).writeAsBytes(ImportProduitsService.modele());
  }

  Future<void> _analyser() async {
    final l10n = AppLocalizations.of(context);
    final map = <String, int?>{
      for (final c in ImportProduitsService.colonnes)
        c: switch (_champs.indexOf(c)) {
          < 0 => null,
          final i => i,
        },
    };
    try {
      final lignes = await ref.read(importProduitsServiceProvider).analyser(_octets!, correspondance: map);
      setState(() {
        _lignes = lignes;
        _etape = 3;
        _erreur = null;
      });
    } on FormatException {
      setState(() => _erreur = l10n.prdImportDesignationRequise);
    }
  }

  Future<void> _importer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final magasin = await ref.read(magasinPrincipalProvider.future);
    final r = await ref.read(importProduitsServiceProvider).importer(_lignes!, magasinCode: magasin);
    rafraichirCatalogue(ref);
    rafraichirStock(ref);
    if (!mounted) return;
    Navigator.of(context).pop();
    afficherToast(
      context,
      titre: l10n.prdImportTermine,
      description: l10n.importResultat(r.importees, r.ignorees),
      ton: DsToastTon.succes,
    );
  }

  String _libelleChamp(AppLocalizations l10n, String? champ) => switch (champ) {
    'designation' => l10n.produitsColDesignation,
    'code_barres' => l10n.produitsColCodeBarres,
    'categorie' => l10n.produitsColCategorie,
    'prix_achat' => l10n.produitChampPrixAchat,
    'prix_vente' => l10n.produitChampPrixVente,
    'stock' => l10n.prdStockInitial,
    _ => l10n.prdIgnorer,
  };

  String _libelleErreur(AppLocalizations l10n, String? e) => switch (e) {
    'designation_vide' => l10n.importErreurDesignationVide,
    'code_barres_deja_utilise' => l10n.importErreurCodeBarresPris,
    'prix_invalide' => l10n.importErreurPrix,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final valides = _lignes?.where((l) => l.valide).length ?? 0;
    return DsDialog(
      titre: l10n.importTitre,
      iconeData: LucideIcons.fileSpreadsheet,
      largeur: 900,
      piedDebut: _etape > 1
          ? DsButton(
              libelle: l10n.dsRetour,
              icone: LucideIcons.arrowLeft,
              variante: DsButtonVariante.secondaire,
              onPressed: () => setState(() => _etape--),
            )
          : null,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        if (_etape < 3)
          DsButton(
            key: const ValueKey('import_suivant'),
            libelle: l10n.prdSuivant,
            iconeDroite: LucideIcons.arrowRight,
            onPressed: _octets == null
                ? null
                : _etape == 1
                ? () => setState(() => _etape = 2)
                : _analyser,
          )
        else
          DsButton(
            key: const ValueKey('import_lancer'),
            libelle: l10n.prdImporterN(valides),
            icone: LucideIcons.check,
            chargement: _occupe,
            onPressed: valides > 0 ? _importer : null,
          ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          DsStepper(
            courante: _etape - 1,
            etapes: [l10n.prdImportFichier, l10n.prdImportColonnes, l10n.communApercu],
            descriptions: [l10n.prdImportFichierDesc, l10n.prdImportColonnesDesc, l10n.prdImportApercuDesc],
            onEtape: (i) {
              if (i + 1 < _etape) setState(() => _etape = i + 1);
            },
          ),
          if (_etape == 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: DsRadius.borderLg,
                border: Border.all(color: c.borderStrong, width: 1.5),
              ),
              child: Column(
                spacing: 10,
                children: [
                  Icon(LucideIcons.fileUp, size: 28, color: c.iconActive),
                  Text(
                    _fichier ?? l10n.importChoisirFichier,
                    style: t.body.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                  ),
                  Text(
                    _fichier == null ? l10n.importIntro : l10n.prdImportInfos(_entetes.length, (_taille / 1024).ceil()),
                    textAlign: TextAlign.center,
                    style: t.bodySm.copyWith(color: c.textSecondary),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      DsButton(
                        key: const ValueKey('import_choisir'),
                        libelle: _fichier == null ? l10n.importChoisirFichier : l10n.prdChangerFichier,
                        icone: LucideIcons.folderOpen,
                        taille: DsButtonTaille.sm,
                        variante: DsButtonVariante.secondaire,
                        onPressed: _choisir,
                      ),
                      DsButton(
                        libelle: l10n.prdTelechargerModele,
                        icone: LucideIcons.download,
                        taille: DsButtonTaille.sm,
                        variante: DsButtonVariante.fantome,
                        onPressed: _modele,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_etape == 2)
            DsGrilleFormulaire(
              espaceY: 10,
              children: [
                for (final (i, e) in _entetes.indexed)
                  Row(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          l10n.prdColonneN(String.fromCharCode(65 + i), e),
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySm.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(LucideIcons.arrowRight, size: 14, color: c.iconMuted),
                      Expanded(
                        child: DsSelect<String?>(
                          valeur: _champs[i],
                          options: const [null, ...ImportProduitsService.colonnes],
                          libelle: (x) => _libelleChamp(l10n, x),
                          onChanged: (v) => setState(() {
                            _champs = [
                              for (final (j, x) in _champs.indexed) j == i ? v : (x == v && v != null ? null : x),
                            ];
                          }),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          if (_etape == 3 && _lignes != null)
            DsDataTable<LigneImport>(
              dense: true,
              hauteurMax: 320,
              cle: (l) => l.numero,
              lignes: _lignes!,
              taillePage: 50,
              colonnes: [
                DsColonne(
                  id: 'd',
                  libelle: l10n.produitsColDesignation,
                  valeur: (l) => l.designation,
                  fort: true,
                  flex: 3,
                ),
                DsColonne(
                  id: 'cb',
                  libelle: l10n.produitsColCodeBarres,
                  attenue: true,
                  flex: 2,
                  valeur: (l) => l.codeBarres ?? l10n.prdGenere,
                ),
                DsColonne(id: 'cat', libelle: l10n.produitsColCategorie, valeur: (l) => l.categorie ?? '', flex: 2),
                DsColonne(
                  id: 'pa',
                  libelle: l10n.prdAchat,
                  numerique: true,
                  valeur: (l) => l.prixAchat,
                  cellule: (_, l) => Text(l.prixAchat == null ? '' : formaterNombre(l.prixAchat!, decimales: 2)),
                ),
                DsColonne(
                  id: 'pv',
                  libelle: l10n.prdVente,
                  numerique: true,
                  valeur: (l) => l.prixVente,
                  cellule: (_, l) => Text(l.prixVente == null ? '' : formaterNombre(l.prixVente!, decimales: 2)),
                ),
                DsColonne(
                  id: 'q',
                  libelle: l10n.retoursQte,
                  numerique: true,
                  valeur: (l) => l.stock,
                  cellule: (_, l) => Text(l.stock == null ? '' : formaterNombre(l.stock!)),
                ),
                DsColonne(
                  id: 'e',
                  libelle: l10n.prdControle,
                  flex: 2,
                  valeur: (l) => l.erreur ?? '',
                  cellule: (_, l) => l.valide
                      ? const BadgeStatut('valide')
                      : DsStatusBadge(statut: 'erreur', libelle: _libelleErreur(l10n, l.erreur)),
                ),
              ],
            ),
          if (_erreur != null) Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
        ],
      ),
    );
  }
}
