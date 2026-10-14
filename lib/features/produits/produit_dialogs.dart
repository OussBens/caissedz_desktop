import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../application/catalogue_ia_service.dart';
import '../../application/catalogue_service.dart';
import '../../application/import_produits_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/etiquettes_pdf.dart';
import '../../domain/calculs_prix.dart';
import '../../domain/code_generator.dart';
import '../../domain/models/produit.dart';
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
};

double? lireNombre(String s) => s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));

/// Formulaire détaillé de produit (création ou modification).
Future<Produit?> afficherFormulaireProduit(BuildContext context, {Produit? produit, FicheProduitIa? fiche}) {
  return showDialog<Produit>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (_) => _ProduitFormDialog(produit: produit, fiche: fiche),
  );
}

class _ProduitFormDialog extends ConsumerStatefulWidget {
  const _ProduitFormDialog({this.produit, this.fiche});
  final Produit? produit;
  final FicheProduitIa? fiche;

  @override
  ConsumerState<_ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends ConsumerState<_ProduitFormDialog> {
  late final TextEditingController _designation;
  late final TextEditingController _codeBarres;
  late final TextEditingController _prixAchat;
  late final TextEditingController _prixVente;
  late final TextEditingController _marge;
  late final TextEditingController _unite;
  late final TextEditingController _tva;
  late final TextEditingController _seuil;
  late final TextEditingController _nombreParUnite;
  String? _categorie;
  String? _sousCategorie;
  bool _suiviNombre = false;
  final Map<String, String> _erreurs = {};

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    final f = widget.fiche;
    _designation = TextEditingController(text: p?.designation ?? f?.designation ?? '');
    _codeBarres = TextEditingController(text: p?.codeBarres ?? f?.codeBarres ?? '');
    _prixAchat = TextEditingController(text: p == null ? '' : p.prixAchat.toString());
    _prixVente = TextEditingController(text: p == null ? (f?.prixVente?.toString() ?? '') : p.prixVente.toString());
    _marge = TextEditingController(text: p == null ? '' : p.margePct.toString());
    _unite = TextEditingController(text: p?.unite ?? 'Pièce');
    _tva = TextEditingController(text: (p?.tvaPct ?? 19).toString());
    _seuil = TextEditingController(text: p?.seuilStock?.toString() ?? '');
    _nombreParUnite = TextEditingController(text: (p?.nombreParUnite ?? 1).toString());
    _categorie = p?.categorieCode ?? CodeGenerator.systeme(CodeGenerator.categorie);
    _sousCategorie = p?.sousCategorieCode ?? CodeGenerator.systeme(CodeGenerator.sousCategorie);
    _suiviNombre = p?.suiviNombre ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _designation,
      _codeBarres,
      _prixAchat,
      _prixVente,
      _marge,
      _unite,
      _tva,
      _seuil,
      _nombreParUnite,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _recalculerPrixVente() {
    final pa = lireNombre(_prixAchat.text);
    final m = lireNombre(_marge.text);
    if (pa != null && m != null) _prixVente.text = CalculsPrix.prixVenteDepuisMarge(pa, m).toString();
  }

  Future<void> _valider() async {
    final l10n = AppLocalizations.of(context);
    _erreurs.clear();
    if (_designation.text.trim().isEmpty) _erreurs['designation'] = l10n.produitErreurDesignation;
    final pa = lireNombre(_prixAchat.text) ?? 0;
    final pv = lireNombre(_prixVente.text) ?? 0;
    if (pa < 0 || pv < 0 || (_prixAchat.text.trim().isNotEmpty && lireNombre(_prixAchat.text) == null)) {
      _erreurs['prix'] = l10n.produitErreurPrix;
    }
    final npu = int.tryParse(_nombreParUnite.text.trim()) ?? 0;
    if (_suiviNombre && npu <= 0) _erreurs['npu'] = l10n.produitErreurQuantite;
    if (_erreurs.isNotEmpty) {
      setState(() {});
      return;
    }
    final base =
        widget.produit ??
        Produit(
          code: '',
          designation: '',
          categorieCode: _categorie!,
          sousCategorieCode: _sousCategorie!,
          source: widget.fiche != null ? 'IA' : 'Manuel',
        );
    final produit = base.copyWith(
      designation: _designation.text,
      codeBarres: _codeBarres.text.trim().isEmpty ? null : _codeBarres.text.trim(),
      effacerCodeBarres: _codeBarres.text.trim().isEmpty,
      categorieCode: _categorie,
      sousCategorieCode: _sousCategorie,
      prixAchat: pa,
      prixVente: pv,
      margePct: lireNombre(_marge.text) ?? 0,
      unite: _unite.text.trim().isEmpty ? 'Pièce' : _unite.text.trim(),
      tvaPct: lireNombre(_tva.text) ?? 19,
      seuilStock: int.tryParse(_seuil.text.trim()),
      effacerSeuil: _seuil.text.trim().isEmpty,
      suiviNombre: _suiviNombre,
      nombreParUnite: _suiviNombre ? npu : 1,
      image: widget.fiche?.image ?? widget.produit?.image,
    );
    try {
      final service = ref.read(catalogueServiceProvider);
      final marge = ref.read(parametresVenteProvider).value?.margeDefautPct;
      final resultat = widget.produit == null
          ? await service.creerProduit(produit, margeDefautPct: marge)
          : await service.modifierProduit(produit, margeDefautPct: marge);
      rafraichirCatalogue(ref);
      if (!mounted) return;
      Navigator.of(context).pop(resultat);
    } on CatalogueException catch (e) {
      setState(() {
        final cle = switch (e.erreur) {
          ErreurCatalogue.codeBarresInvalide || ErreurCatalogue.codeBarresDejaUtilise => 'codeBarres',
          ErreurCatalogue.prixInvalide => 'prix',
          _ => 'designation',
        };
        _erreurs[cle] = messageErreurCatalogue(l10n, e.erreur);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final sousCategories = (ref.watch(sousCategoriesProvider).value ?? const [])
        .where((s) => s.categorieCode == _categorie)
        .toList();
    if (sousCategories.isNotEmpty && !sousCategories.any((s) => s.code == _sousCategorie)) {
      _sousCategorie = sousCategories.first.code;
    }
    return DsDialog(
      titre: widget.produit == null ? l10n.produitsNouveau : l10n.produitModifier,
      largeur: 720,
      icone: Icon(LucideIcons.package, color: c.primaire),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(libelle: l10n.communEnregistrer, icone: LucideIcons.check, onPressed: _valider),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.fiche != null) ...[
            DsBadge(libelle: l10n.iaTrouve(widget.fiche!.source), ton: DsBadgeTon.info, icone: LucideIcons.sparkles),
            const SizedBox(height: DsSpacing.md),
          ],
          DsTextField(
            controller: _designation,
            libelle: l10n.produitChampDesignation,
            erreur: _erreurs['designation'],
            autofocus: true,
          ),
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  controller: _codeBarres,
                  libelle: l10n.produitChampCodeBarres,
                  erreur: _erreurs['codeBarres'],
                  iconePrefixe: LucideIcons.barcode,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsTextField(controller: _unite, libelle: l10n.produitChampUnite),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              Expanded(
                child: DsSelect<String>(
                  titre: l10n.produitChampCategorie,
                  valeur: _categorie,
                  options: categories.map((c) => c.code).toList(),
                  libelle: (code) => categories.firstWhere((c) => c.code == code).nom,
                  onChanged: (v) => setState(() => _categorie = v),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsSelect<String>(
                  titre: l10n.produitChampSousCategorie,
                  valeur: _sousCategorie,
                  options: sousCategories.map((s) => s.code).toList(),
                  libelle: (code) => sousCategories.firstWhere((s) => s.code == code).nom,
                  onChanged: (v) => setState(() => _sousCategorie = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  controller: _prixAchat,
                  libelle: l10n.produitChampPrixAchat,
                  erreur: _erreurs['prix'],
                  typeClavier: TextInputType.number,
                  onChanged: (_) => _recalculerPrixVente(),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsTextField(
                  controller: _marge,
                  libelle: l10n.produitChampMarge,
                  typeClavier: TextInputType.number,
                  onChanged: (_) => _recalculerPrixVente(),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsTextField(
                  controller: _prixVente,
                  libelle: l10n.produitChampPrixVente,
                  typeClavier: TextInputType.number,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsTextField(controller: _tva, libelle: l10n.produitChampTva, typeClavier: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.xs),
          Text(l10n.produitPrixAuto, style: t.legende.copyWith(color: c.texteAttenue)),
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  controller: _seuil,
                  libelle: l10n.produitChampSeuil,
                  typeClavier: TextInputType.number,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              Expanded(
                child: DsTextField(
                  controller: _nombreParUnite,
                  libelle: l10n.produitChampNombreParUnite,
                  erreur: _erreurs['npu'],
                  actif: _suiviNombre,
                  typeClavier: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.sm),
          DsSwitch(
            valeur: _suiviNombre,
            libelle: l10n.produitChampSuiviNombre,
            aide: l10n.produitChampSuiviNombreAide,
            onChanged: (v) => setState(() => _suiviNombre = v),
          ),
        ],
      ),
    );
  }
}

/// Mode IA : code-barres → cascade de sources → formulaire pré-rempli.
Future<void> afficherProduitIa(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: context.ds.colors.overlay,
  builder: (_) => const _ProduitIaDialog(),
);

class _ProduitIaDialog extends ConsumerStatefulWidget {
  const _ProduitIaDialog();
  @override
  ConsumerState<_ProduitIaDialog> createState() => _ProduitIaDialogState();
}

class _ProduitIaDialogState extends ConsumerState<_ProduitIaDialog> {
  final _code = TextEditingController();
  bool _enCours = false;
  bool _cherche = false;
  FicheProduitIa? _fiche;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _rechercher() async {
    if (_code.text.trim().isEmpty) return;
    setState(() {
      _enCours = true;
      _fiche = null;
      _cherche = false;
    });
    final f = await ref.read(catalogueIaServiceProvider).rechercher(_code.text);
    if (!mounted) return;
    setState(() {
      _enCours = false;
      _cherche = true;
      _fiche = f;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final fiche = _fiche;
    return DsDialog(
      titre: l10n.iaTitre,
      largeur: 560,
      icone: Icon(LucideIcons.sparkles, color: c.primaire),
      actions: [
        DsButton(
          libelle: l10n.iaSaisieDetaillee,
          variante: DsButtonVariante.secondaire,
          onPressed: () {
            Navigator.of(context).pop();
            afficherFormulaireProduit(
              context,
              fiche:
                  fiche ??
                  (_code.text.trim().isEmpty
                      ? null
                      : FicheProduitIa(codeBarres: _code.text.trim(), designation: '', source: '')),
            );
          },
        ),
        DsButton(
          libelle: l10n.iaCreer,
          icone: LucideIcons.check,
          onPressed: fiche == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  afficherFormulaireProduit(context, fiche: fiche);
                },
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.iaIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  controller: _code,
                  libelle: l10n.produitChampCodeBarres,
                  iconePrefixe: LucideIcons.scanBarcode,
                  autofocus: true,
                  onSubmitted: (_) => _rechercher(),
                ),
              ),
              const SizedBox(width: DsSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: DsButton(
                  libelle: l10n.iaRechercher,
                  icone: LucideIcons.search,
                  chargement: _enCours,
                  onPressed: _rechercher,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          if (_enCours) Text(l10n.iaRechercheEnCours, style: t.petit.copyWith(color: c.texteAttenue)),
          if (_cherche && fiche == null)
            DsBadge(libelle: l10n.iaAucun, ton: DsBadgeTon.avertissement, icone: LucideIcons.circleAlert),
          if (fiche != null)
            DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DsBadge(libelle: l10n.iaTrouve(fiche.source), ton: DsBadgeTon.succes, icone: LucideIcons.badgeCheck),
                  const SizedBox(height: DsSpacing.sm),
                  Text(fiche.designation, style: t.titreSm),
                  if (fiche.marque != null)
                    Text('${l10n.iaMarque} : ${fiche.marque}', style: t.petit.copyWith(color: c.texteSecondaire)),
                  if (fiche.categorie != null)
                    Text(
                      '${l10n.produitChampCategorie} : ${fiche.categorie}',
                      style: t.petit.copyWith(color: c.texteSecondaire),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Import Excel : choix du fichier, analyse, import.
Future<void> afficherImportProduits(BuildContext context) =>
    showDialog<void>(context: context, barrierColor: context.ds.colors.overlay, builder: (_) => const _ImportDialog());

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();
  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  List<LigneImport>? _lignes;
  String? _erreur;
  String? _fichier;

  Future<void> _choisir() async {
    final l10n = AppLocalizations.of(context);
    final f = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Excel', extensions: ['xlsx']),
      ],
    );
    if (f == null) return;
    try {
      final lignes = await ref.read(importProduitsServiceProvider).analyser(await f.readAsBytes());
      setState(() {
        _lignes = lignes;
        _fichier = f.name;
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

  Future<void> _importer() async {
    final l10n = AppLocalizations.of(context);
    final r = await ref.read(importProduitsServiceProvider).importer(_lignes!);
    rafraichirCatalogue(ref);
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.importTitre,
        message: l10n.importResultat(r.importees, r.ignorees),
      ),
    );
  }

  String _libelleErreur(AppLocalizations l10n, String? e) => switch (e) {
    'designation_vide' => l10n.importErreurDesignationVide,
    'code_barres_deja_utilise' => l10n.importErreurCodeBarresPris,
    'prix_invalide' => l10n.importErreurPrix,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final lignes = _lignes;
    final valides = lignes?.where((l) => l.valide).length ?? 0;
    return DsDialog(
      titre: l10n.importTitre,
      largeur: 760,
      icone: Icon(LucideIcons.fileSpreadsheet, color: c.primaire),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(libelle: l10n.importLancer, icone: LucideIcons.download, onPressed: valides > 0 ? _importer : null),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.importIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.lg),
          Row(
            children: [
              DsButton(
                libelle: l10n.importChoisirFichier,
                icone: LucideIcons.folderOpen,
                variante: DsButtonVariante.secondaire,
                onPressed: _choisir,
              ),
              const SizedBox(width: DsSpacing.sm),
              DsButton(
                libelle: l10n.importTelechargerModele,
                icone: LucideIcons.fileDown,
                variante: DsButtonVariante.fantome,
                onPressed: _modele,
              ),
              const Spacer(),
              if (_fichier != null) Text(_fichier!, style: t.petit.copyWith(color: c.texteAttenue)),
            ],
          ),
          if (_erreur != null) ...[
            const SizedBox(height: DsSpacing.md),
            Text(_erreur!, style: t.petit.copyWith(color: c.danger)),
          ],
          if (lignes != null) ...[
            const SizedBox(height: DsSpacing.lg),
            Row(
              children: [
                DsBadge(libelle: l10n.importLignesValides(valides), ton: DsBadgeTon.succes),
                const SizedBox(width: DsSpacing.sm),
                DsBadge(libelle: l10n.importLignesInvalides(lignes.length - valides), ton: DsBadgeTon.avertissement),
              ],
            ),
            const SizedBox(height: DsSpacing.md),
            SizedBox(
              height: 320,
              child: DsDataTable<LigneImport>(
                colonnes: [
                  DsColonne(
                    id: 'n',
                    libelle: l10n.importColLigne,
                    valeur: (l) => l.numero,
                    largeur: 70,
                    numerique: true,
                  ),
                  DsColonne(id: 'd', libelle: l10n.produitsColDesignation, valeur: (l) => l.designation, flex: 3),
                  DsColonne(id: 'cb', libelle: l10n.produitsColCodeBarres, valeur: (l) => l.codeBarres, flex: 2),
                  DsColonne(id: 'cat', libelle: l10n.produitsColCategorie, valeur: (l) => l.categorie, flex: 2),
                  DsColonne(id: 'pv', libelle: l10n.produitsColPrixVente, valeur: (l) => l.prixVente, numerique: true),
                  DsColonne(
                    id: 'e',
                    libelle: l10n.importColErreur,
                    valeur: (l) => l.erreur,
                    flex: 2,
                    cellule: (_, l) => l.valide
                        ? const SizedBox.shrink()
                        : DsBadge(libelle: _libelleErreur(l10n, l.erreur), ton: DsBadgeTon.danger),
                  ),
                ],
                lignes: lignes,
                cle: (l) => l.numero,
                taillePage: 50,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Étiquettes : quantité par produit, format, aperçu / impression PDF.
Future<void> afficherEtiquettes(BuildContext context, List<Produit> produits) => showDialog<void>(
  context: context,
  barrierColor: context.ds.colors.overlay,
  builder: (_) => _EtiquettesDialog(produits: produits),
);

class _EtiquettesDialog extends ConsumerStatefulWidget {
  const _EtiquettesDialog({required this.produits});
  final List<Produit> produits;
  @override
  ConsumerState<_EtiquettesDialog> createState() => _EtiquettesDialogState();
}

class _EtiquettesDialogState extends ConsumerState<_EtiquettesDialog> {
  late final Map<String, TextEditingController> _quantites = {
    for (final p in widget.produits) p.code: TextEditingController(text: '1'),
  };
  bool _a4 = true;
  bool _prix = true;
  bool _qr = false;

  @override
  void dispose() {
    for (final c in _quantites.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Etiquette> get _etiquettes => [
    for (final p in widget.produits)
      Etiquette(produit: p, quantite: int.tryParse(_quantites[p.code]!.text) ?? 1, prixAffiche: _prix, qr: _qr),
  ];

  Future<void> _generer() async {
    final gen = EtiquettesPdf(devise: ref.read(deviseProvider));
    final octets = _a4 ? await gen.plancheA4(_etiquettes) : await gen.rouleau(_etiquettes);
    await Printing.layoutPdf(onLayout: (_) async => octets, name: 'etiquettes.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return DsDialog(
      titre: l10n.etiquettesTitre,
      largeur: 560,
      icone: Icon(LucideIcons.tag, color: c.primaire),
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(libelle: l10n.etiquettesGenerer, icone: LucideIcons.printer, onPressed: _generer),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in widget.produits)
            Padding(
              padding: const EdgeInsets.only(bottom: DsSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(p.designation, style: t.corps, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(
                    width: 100,
                    child: DsTextField(
                      controller: _quantites[p.code],
                      indice: l10n.etiquettesQuantite,
                      typeClavier: TextInputType.number,
                      alignement: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          const DsDivider(),
          const SizedBox(height: DsSpacing.sm),
          Row(
            children: [
              DsButton(
                libelle: l10n.etiquettesFormatA4,
                taille: DsButtonTaille.sm,
                variante: _a4 ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                onPressed: () => setState(() => _a4 = true),
              ),
              const SizedBox(width: DsSpacing.xs),
              DsButton(
                libelle: l10n.etiquettesFormatRouleau,
                taille: DsButtonTaille.sm,
                variante: !_a4 ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                onPressed: () => setState(() => _a4 = false),
              ),
            ],
          ),
          DsSwitch(valeur: _prix, libelle: l10n.etiquettesAfficherPrix, onChanged: (v) => setState(() => _prix = v)),
          DsSwitch(valeur: _qr, libelle: l10n.etiquettesQr, onChanged: (v) => setState(() => _qr = v)),
        ],
      ),
    );
  }
}
