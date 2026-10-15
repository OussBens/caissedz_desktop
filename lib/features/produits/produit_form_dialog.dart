import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_ia_service.dart';
import '../../application/catalogue_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/calculs_prix.dart';
import '../../domain/code_generator.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'produit_dialogs.dart';
import 'produits_donnees.dart';
import 'produits_providers.dart';

/// Tailles proposées par type de taille (`SIZE_TYPES` du DS v2.2).
const Map<String, List<String>> taillesParType = {
  'Lettres (vêtements)': ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL'],
  'Pointure': ['35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46'],
  'Numérique (pantalon)': ['34', '36', '38', '40', '42', '44', '46', '48', '50', '52', '54'],
  'Enfant (âge)': [
    '0-3 mois',
    '3-6 mois',
    '6-12 mois',
    '2 ans',
    '4 ans',
    '6 ans',
    '8 ans',
    '10 ans',
    '12 ans',
    '14 ans',
  ],
  'Contenance': ['250 ml', '330 ml', '500 ml', '1 L', '1,5 L', '2 L', '5 L'],
  'Poids': ['100 g', '250 g', '500 g', '1 kg', '2 kg', '5 kg', '10 kg'],
  'Taille unique': ['Taille unique'],
};

/// Pastilles des 16 couleurs produit (`PRODUCT_COLORS`) : couleurs propres au produit, pas des tokens d'UI.
const Map<String, Color> pastillesCouleurs = {
  'Blanc': Color(0xFFFFFFFF),
  'Noir': Color(0xFF1A1A1F),
  'Gris': Color(0xFF8A8A94),
  'Beige': Color(0xFFE6D3B3),
  'Marron': Color(0xFF7A4B2A),
  'Rouge': Color(0xFFD92D20),
  'Bordeaux': Color(0xFF7A1E2E),
  'Rose': Color(0xFFF17AB0),
  'Orange': Color(0xFFF38744),
  'Jaune': Color(0xFFF5C518),
  'Vert': Color(0xFF2E9E5B),
  'Kaki': Color(0xFF6B6B3A),
  'Bleu ciel': Color(0xFF6CB6F0),
  'Bleu': Color(0xFF2563EB),
  'Marine': Color(0xFF1E2A5A),
  'Violet': Color(0xFF7C4DDB),
};

List<String> _liste(String? s) =>
    s == null ? const [] : s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

/// Mode du formulaire : Rapide (une page), Détaillé (3 étapes) ou IA (recherche par code-barres, §10.1).
enum ModeFormulaireProduit { rapide, detaille, ia }

/// Formulaire produit (`ProduitFormDialog` du DS v2.2, 960 px) : création ou modification.
Future<Produit?> afficherFormulaireProduit(
  BuildContext context, {
  Produit? produit,
  bool detaille = false,
  ModeFormulaireProduit? mode,
  FicheProduitIa? fiche,
}) => afficherDialog<Produit>(
  context,
  fermableParVoile: false,
  builder: (_) => ProduitFormDialog(
    produit: produit,
    mode: mode ?? (detaille ? ModeFormulaireProduit.detaille : ModeFormulaireProduit.rapide),
    fiche: fiche,
  ),
);

class ProduitFormDialog extends ConsumerStatefulWidget {
  const ProduitFormDialog({super.key, this.produit, this.mode = ModeFormulaireProduit.rapide, this.fiche});
  final Produit? produit;
  final ModeFormulaireProduit mode;
  final FicheProduitIa? fiche;

  @override
  ConsumerState<ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends ConsumerState<ProduitFormDialog> {
  static const double _lw = 128;

  late ModeFormulaireProduit _mode = widget.mode;
  int _etape = 1;
  late int _vu = _edition ? 3 : 1;
  bool _occupe = false;
  String? _erreur;
  String? _erreurCode;

  final _designation = TextEditingController();
  final _codeBarres = TextEditingController();
  final _marque = TextEditingController();
  final _achat = TextEditingController();
  final _marge = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _seuil = TextEditingController();
  final _boiteQ = TextEditingController();
  final _boiteP = TextEditingController();
  final _cartonQ = TextEditingController();
  final _cartonP = TextEditingController();
  final _description = TextEditingController();
  final _observation = TextEditingController();
  final _codeIa = TextEditingController();

  String _categorie = CodeGenerator.systeme(CodeGenerator.categorie);
  String? _sousCategorie;
  String? _fournisseur;
  String _modeMarge = '%';
  double _tva = 19;
  String? _magasin;
  String _unite = 'Pièce';
  bool _actif = true;
  bool _serie = false;
  bool _service = false;
  bool _expiration = false;
  DateTime? _dateExpiration;
  String? _typeTaille;
  Set<String> _tailles = {};
  Set<String> _couleurs = {};
  List<String> _codes = [];
  List<DsPhoto> _photos = [];
  bool _iaEnCours = false;
  bool _iaCherche = false;
  FicheProduitIa? _fiche;

  bool get _edition => widget.produit != null;
  bool get _detaille => _mode == ModeFormulaireProduit.detaille;

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    final marge = ref.read(parametresVenteProvider).value?.margeDefautPct ?? 25;
    if (p != null) {
      _designation.text = p.designation;
      _codeBarres.text = p.codeBarres ?? '';
      _marque.text = p.marque ?? '';
      _achat.text = _nb(p.prixAchat);
      _marge.text = p.prixAchat > 0 ? '${margeProduit(p).round()}' : _nb(marge);
      _seuil.text = p.seuilStock?.toString() ?? '';
      _description.text = p.description ?? '';
      _observation.text = p.observation ?? '';
      _categorie = p.categorieCode;
      _sousCategorie = p.sousCategorieCode;
      _fournisseur = p.fournisseurCode;
      _tva = p.tvaPct;
      _unite = p.unite;
      _actif = p.actif;
      _serie = p.suiviSerie;
      _service = p.service;
      _expiration = p.dateExpiration != null;
      _dateExpiration = p.dateExpiration;
      _tailles = _liste(p.taille).toSet();
      _couleurs = _liste(p.couleur).toSet();
      _typeTaille = _tailles.isEmpty
          ? null
          : taillesParType.entries.where((e) => _tailles.every(e.value.contains)).firstOrNull?.key;
      _chargerFiche(p.code);
    } else {
      // Marge par défaut des Paramètres : en pourcentage ou en montant fixe.
      final pv = ref.read(parametresVenteProvider).value;
      if (pv != null && pv.margeEnMontant) {
        _modeMarge = 'DA';
        _marge.text = _nb(pv.margeMontant);
      } else {
        _marge.text = _nb(marge);
      }
      final seuil = pv?.seuilStockGlobal;
      _seuil.text = seuil?.toString() ?? '';
      final f = widget.fiche;
      if (f != null) _appliquerFiche(f);
    }
  }

  Future<void> _chargerFiche(String code) async {
    final service = ref.read(catalogueServiceProvider);
    final emb = await service.emballages(code);
    final codes = await service.codesSecondaires(code);
    final photos = await service.photos(code);
    if (!mounted) return;
    setState(() {
      if (emb.isNotEmpty) {
        _boiteQ.text = '${emb[0].quantite}';
        _boiteP.text = _nb(emb[0].prixVente);
      }
      if (emb.length > 1) {
        _cartonQ.text = '${emb[1].quantite}';
        _cartonP.text = _nb(emb[1].prixVente);
      }
      _codes = codes;
      _photos = [
        for (final (i, c) in photos.indexed) DsPhoto(id: '$i', nom: c.split(RegExp(r'[\\/]')).last, chemin: c),
      ];
    });
  }

  void _appliquerFiche(FicheProduitIa f) {
    _fiche = f;
    if (f.designation.isNotEmpty) _designation.text = f.designation;
    _codeBarres.text = f.codeBarres;
    _marque.text = f.marque ?? _marque.text;
    final nomCat = f.categorie?.toLowerCase();
    if (nomCat != null) {
      final cat = (ref.read(categoriesProvider).value ?? const <Categorie>[])
          .where((c) => c.nom.toLowerCase() == nomCat)
          .firstOrNull;
      if (cat != null) {
        _categorie = cat.code;
        _sousCategorie = null;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _designation,
      _codeBarres,
      _marque,
      _achat,
      _marge,
      _stock,
      _seuil,
      _boiteQ,
      _boiteP,
      _cartonQ,
      _cartonP,
      _description,
      _observation,
      _codeIa,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _nb(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  static double _d(String s) => double.tryParse(s.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;

  double get _a => _d(_achat.text);
  double get _m => _d(_marge.text);
  double get _vente =>
      _modeMarge == '%' ? CalculsPrix.prixVenteDepuisMarge(_a, _m) : CalculsPrix.prixVenteDepuisMontant(_a, _m);
  bool get _sousAchat => _a > 0 && _vente < _a;
  bool get _ok1 => _designation.text.trim().isNotEmpty && _a > 0 && !_sousAchat;

  void _changerModeMarge(String v) {
    if (v == _modeMarge) return;
    final vente = _vente;
    setState(() {
      _marge.text = v == '%'
          ? (_a > 0 ? '${((vente - _a) / _a * 100).round()}' : _marge.text)
          : '${(vente - _a).round()}';
      _modeMarge = v;
    });
  }

  Future<void> _rechercherIa() async {
    final code = _codeIa.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _iaEnCours = true;
      _iaCherche = false;
    });
    final existant = await ref.read(catalogueRepositoryProvider).produitParCodeBarres(code);
    if (!mounted) return;
    if (existant != null) {
      // Trouvé en local : orienter vers la fiche existante (§9.4).
      setState(() => _iaEnCours = false);
      Navigator.of(context).pop();
      await afficherFormulaireProduit(context, produit: existant, detaille: true);
      return;
    }
    final f = await ref.read(catalogueIaServiceProvider).rechercher(code);
    if (!mounted) return;
    setState(() {
      _iaEnCours = false;
      _iaCherche = true;
      if (f != null) {
        _appliquerFiche(f);
        _mode = ModeFormulaireProduit.rapide;
      } else {
        _codeBarres.text = code;
      }
    });
  }

  Future<void> _ajouterPhoto() async {
    final fichiers = await openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png']),
      ],
    );
    if (fichiers.isEmpty) return;
    final dossier = ref.read(dossierPhotosProvider);
    final ajouts = <DsPhoto>[];
    for (final f in fichiers.take(4 - _photos.length)) {
      final chemin = await importerPhoto(dossier, f.path);
      ajouts.add(DsPhoto(id: chemin, nom: f.name, chemin: chemin));
    }
    if (mounted) setState(() => _photos = [..._photos, ...ajouts]);
  }

  EmballageProduit? _emballage(TextEditingController q, TextEditingController p) {
    final n = int.tryParse(q.text.trim()) ?? 0;
    return n > 1 ? EmballageProduit(quantite: n, prixVente: _d(p.text)) : null;
  }

  Future<void> _enregistrer({bool nouveau = false}) async {
    final l10n = AppLocalizations.of(context);
    if (!_ok1) return;
    setState(() {
      _occupe = true;
      _erreur = null;
      _erreurCode = null;
    });
    final base = widget.produit;
    final seuil = int.tryParse(_seuil.text.trim());
    final produit = Produit(
      code: base?.code ?? '',
      designation: _designation.text.trim(),
      codeBarres: _codeBarres.text.trim().isEmpty ? null : _codeBarres.text.trim(),
      categorieCode: _categorie,
      sousCategorieCode: _sousCategorie ?? await _sousCategorieParDefaut(),
      prixAchat: _a,
      prixVente: double.parse(_vente.toStringAsFixed(2)),
      unite: _unite,
      tvaPct: _tva,
      seuilStock: seuil,
      suiviNombre: base?.suiviNombre ?? false,
      nombreParUnite: base?.nombreParUnite ?? 1,
      source: _fiche != null ? 'IA' : (base?.source ?? 'Manuel'),
      actif: _actif,
      image: base?.image ?? _fiche?.image,
      marque: _marque.text.trim().isEmpty ? null : _marque.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      fournisseurCode: _fournisseur,
      dateExpiration: _expiration ? _dateExpiration : null,
      service: _service,
      taille: _tailles.isEmpty ? null : _tailles.join(', '),
      couleur: _couleurs.isEmpty ? null : _couleurs.join(', '),
      observation: _observation.text.trim().isEmpty ? null : _observation.text.trim(),
      suiviSerie: _serie,
      remiseCode: base?.remiseCode,
    );
    final service = ref.read(catalogueServiceProvider);
    final emballages = [_emballage(_boiteQ, _boiteP), _emballage(_cartonQ, _cartonP)];
    final photos = [
      for (final p in _photos)
        if (p.chemin != null) p.chemin!,
    ];
    try {
      final Produit enregistre;
      if (base == null) {
        enregistre = await service.creerProduit(
          produit,
          codesSecondaires: _codes,
          emballages: emballages,
          stockInitial: _service ? 0 : _d(_stock.text),
          magasinCode: _magasin ?? await ref.read(magasinPrincipalProvider.future),
          photos: photos,
        );
      } else {
        enregistre = await service.modifierProduit(
          produit,
          codesSecondaires: _codes,
          emballages: _detaille || emballages.any((e) => e != null) ? emballages : null,
          photos: photos,
        );
      }
      rafraichirCatalogue(ref);
      rafraichirStock(ref);
      if (!mounted) return;
      afficherToast(
        context,
        titre: base == null ? l10n.prdToastEnregistre : l10n.prdToastModifie,
        description: base == null ? l10n.prdToastAjoute(enregistre.code) : enregistre.designation,
        ton: DsToastTon.succes,
      );
      if (nouveau) {
        Navigator.of(context).pop(enregistre);
        await afficherFormulaireProduit(context, mode: _mode);
      } else {
        Navigator.of(context).pop(enregistre);
      }
    } on CatalogueException catch (e) {
      if (!mounted) return;
      setState(() {
        _occupe = false;
        final m = messageErreurCatalogue(l10n, e.erreur);
        if (e.erreur == ErreurCatalogue.codeBarresDejaUtilise || e.erreur == ErreurCatalogue.codeBarresInvalide) {
          _erreurCode = m;
        } else {
          _erreur = m;
        }
      });
    }
  }

  Future<String> _sousCategorieParDefaut() async {
    final scs = await ref.read(catalogueRepositoryProvider).sousCategories(_categorie);
    return scs.firstOrNull?.code ?? CodeGenerator.systeme(CodeGenerator.sousCategorie);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final det = _detaille;
    final s1 = !det || _etape == 1;
    final s2 = !det || _etape == 2;
    final s3 = det && _etape == 3;
    final dernier = !det || _etape == 3;
    final p = widget.produit;
    final cb = _codeBarres.text.trim();
    final eanInvalide = cb.length == 13 && RegExp(r'^\d{13}$').hasMatch(cb) && !CodesBarres.ean13Valide(cb);

    final pied = <Widget>[
      if (det && _etape > 1)
        DsButton(
          libelle: l10n.dsRetour,
          icone: LucideIcons.arrowLeft,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => setState(() => _etape--),
        ),
      DsButton(
        libelle: l10n.communAnnuler,
        variante: DsButtonVariante.secondaire,
        onPressed: _occupe ? null : () => Navigator.of(context).pop(),
      ),
      if (dernier) ...[
        if (!_edition)
          DsButton(
            key: const ValueKey('produit_enregistrer_nouveau'),
            libelle: l10n.prdEnregistrerNouveau,
            variante: DsButtonVariante.secondaire,
            onPressed: _occupe || !_ok1 ? null : () => _enregistrer(nouveau: true),
          ),
        DsButton(
          key: const ValueKey('produit_enregistrer'),
          libelle: l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: !_ok1 ? null : _enregistrer,
        ),
      ] else ...[
        if (_edition)
          DsButton(
            libelle: l10n.communEnregistrer,
            variante: DsButtonVariante.secondaire,
            chargement: _occupe,
            onPressed: !_ok1 ? null : _enregistrer,
          ),
        DsButton(
          key: const ValueKey('produit_suivant'),
          libelle: l10n.prdSuivant,
          icone: LucideIcons.arrowRight,
          onPressed: _etape == 1 && !_ok1
              ? null
              : () => setState(() {
                  _etape++;
                  if (_etape > _vu) _vu = _etape;
                }),
        ),
      ],
    ];

    return DsDialog(
      titre: _edition ? l10n.produitModifier : l10n.produitsNouveau,
      iconeData: _edition ? LucideIcons.pencil : LucideIcons.packagePlus,
      description: _edition
          ? '${p!.designation} · ${p.code}'
          : switch (_mode) {
              ModeFormulaireProduit.rapide => l10n.prdDescRapide,
              ModeFormulaireProduit.detaille => l10n.prdDescDetaille,
              ModeFormulaireProduit.ia => l10n.prdDescIa,
            },
      largeur: 960,
      piedDebut: Text(
        det ? l10n.prdEtapeObligatoire(_etape) : l10n.prdObligatoire,
        style: t.caption.copyWith(color: c.textMuted, fontWeight: FontWeight.w500),
      ),
      actions: pied,
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DsSegmentedControl<ModeFormulaireProduit>(
                valeur: _mode,
                onChanged: (v) => setState(() {
                  _mode = v;
                  _etape = 1;
                }),
                options: [
                  DsOption(ModeFormulaireProduit.rapide, libelle: l10n.prdModeRapide, icone: LucideIcons.zap),
                  DsOption(ModeFormulaireProduit.detaille, libelle: l10n.prdModeDetaille, icone: LucideIcons.listTree),
                  if (!_edition)
                    DsOption(ModeFormulaireProduit.ia, libelle: l10n.prdModeIa, icone: LucideIcons.sparkles),
                ],
              ),
              if (det)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 360, maxWidth: 560),
                  child: DsStepper(
                    petit: true,
                    courante: _etape - 1,
                    etapes: [l10n.prdEtape1, l10n.prdEtape2, l10n.prdEtape3],
                    descriptions: [l10n.prdEtape1Desc, l10n.prdEtape2Desc, l10n.prdEtape3Desc],
                    onEtape: (i) {
                      final n = i + 1;
                      if (n <= _vu && (n < _etape || _ok1)) setState(() => _etape = n);
                    },
                  ),
                ),
            ],
          ),
          if (_mode == ModeFormulaireProduit.ia) _blocIa(l10n),
          if (_fiche != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DsBadge(libelle: l10n.iaTrouve(_fiche!.source), ton: DsBadgeTon.info, icone: LucideIcons.sparkles),
            ),
          if (_mode != ModeFormulaireProduit.ia)
            DsGrilleFormulaire(
              colonnes: 2,
              children: [
                if (s1) ..._etape1(l10n, devise, eanInvalide),
                if (s2) ..._etape2(l10n, devise),
                if (s3) ..._etape3(l10n),
              ],
            ),
          if (_erreur != null) Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
        ],
      ),
    );
  }

  Widget _blocIa(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(l10n.iaIntro, style: t.bodySm.copyWith(color: c.textSecondary)),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: DsTextField(
                key: const ValueKey('produit_ia_code'),
                controller: _codeIa,
                iconePrefixe: LucideIcons.scanBarcode,
                indice: l10n.prdScannerOuSaisir,
                autofocus: true,
                onSubmitted: (_) => _rechercherIa(),
              ),
            ),
            DsButton(
              key: const ValueKey('produit_ia_rechercher'),
              libelle: l10n.iaRechercher,
              icone: LucideIcons.search,
              chargement: _iaEnCours,
              onPressed: _rechercherIa,
            ),
          ],
        ),
        if (_iaCherche && _fiche == null)
          Row(
            spacing: 8,
            children: [
              DsBadge(libelle: l10n.iaAucun, ton: DsBadgeTon.avertissement, icone: LucideIcons.circleAlert),
              DsButton(
                libelle: l10n.iaSaisieDetaillee,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                onPressed: () => setState(() => _mode = ModeFormulaireProduit.detaille),
              ),
            ],
          ),
      ],
    );
  }

  List<Widget> _etape1(AppLocalizations l10n, String devise, bool eanInvalide) {
    final det = _detaille;
    final categories = (ref.watch(categoriesProvider).value ?? const <Categorie>[])
        .where((x) => x.actif || x.code == _categorie)
        .toList();
    final sous = (ref.watch(sousCategoriesProvider).value ?? const <SousCategorie>[])
        .where((s) => s.categorieCode == _categorie && (s.actif || s.code == _sousCategorie))
        .toList();
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const <Fournisseur>[];
    return [
      DsSpan(child: DsSubHead(l10n.prdPhotos, icone: LucideIcons.image)),
      DsSpan(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: DsPhotoUploader(
            photos: _photos,
            onAjouter: _ajouterPhoto,
            onRetirer: (x) => setState(() => _photos = _photos.where((y) => y != x).toList()),
            libelleAjouter: l10n.dsAjouter,
            libellePrincipale: l10n.prdPrincipale,
            aide: l10n.prdPhotosFormat,
            libelleFin: l10n.prdPhotosFin,
          ),
        ),
      ),
      DsSpan(child: DsSubHead(l10n.prdIdentification, icone: LucideIcons.tag)),
      DsFormRow(
        libelle: l10n.produitsColCode,
        largeurLibelle: _lw,
        child: DsTextField(valeurInitiale: widget.produit?.code ?? l10n.prdCodeAuto, actif: false),
      ),
      if (_edition)
        DsFormRow(
          libelle: l10n.retoursEtat,
          largeurLibelle: _lw,
          child: DsSwitch(valeur: _actif, libelle: l10n.communActif, onChanged: (v) => setState(() => _actif = v)),
        )
      else
        const SizedBox.shrink(),
      DsSpan(
        child: DsFormRow(
          libelle: l10n.produitsColDesignation,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsTextField(
            key: const ValueKey('produit_designation'),
            controller: _designation,
            autofocus: !_edition,
            indice: l10n.prdDesignationIndice,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      DsFormRow(
        libelle: l10n.produitsColCodeBarres,
        largeurLibelle: _lw,
        erreur: _erreurCode,
        aide: eanInvalide ? l10n.prdEanInvalide : null,
        child: Row(
          spacing: 6,
          children: [
            Expanded(
              child: DsTextField(
                key: const ValueKey('produit_code_barres'),
                controller: _codeBarres,
                iconePrefixe: LucideIcons.barcode,
                indice: l10n.prdScannerOuSaisir,
                onChanged: (_) => setState(() => _erreurCode = null),
              ),
            ),
            DsIconButton(
              icone: LucideIcons.wandSparkles,
              tooltip: l10n.prdGenererEan,
              onPressed: () => setState(() => _codeBarres.text = CodesBarres.genererEan13()),
            ),
          ],
        ),
      ),
      DsFormRow(
        libelle: l10n.produitsColCategorie,
        obligatoire: true,
        largeurLibelle: _lw,
        child: DsSelect<String>(
          cle: const ValueKey('produit_categorie'),
          valeur: _categorie,
          options: [for (final x in categories) x.code],
          libelle: (code) => categories.where((x) => x.code == code).firstOrNull?.nom ?? code,
          recherche: rechercheListe(context, ref, ListeMetier.categorie),
          onChanged: (v) => setState(() {
            _categorie = v ?? _categorie;
            _sousCategorie = null;
          }),
        ),
      ),
      DsFormRow(
        libelle: l10n.produitChampSousCategorie,
        largeurLibelle: _lw,
        child: DsSelect<String?>(
          valeur: _sousCategorie,
          options: [null, for (final s in sous) s.code],
          libelle: (code) =>
              code == null ? l10n.communAucune : (sous.where((s) => s.code == code).firstOrNull?.nom ?? code),
          recherche: rechercheListe(context, ref, ListeMetier.sousCategorie),
          onChanged: (v) => setState(() => _sousCategorie = v),
        ),
      ),
      if (det)
        DsFormRow(
          libelle: l10n.prdMarque,
          largeurLibelle: _lw,
          child: DsTextField(controller: _marque, indice: l10n.prdMarqueIndice),
        )
      else
        const SizedBox.shrink(),
      if (det) ...[
        DsFormRow(
          libelle: l10n.prdFournisseur,
          largeurLibelle: _lw,
          child: DsSelect<String?>(
            valeur: _fournisseur,
            options: [null, for (final f in fournisseurs) f.code],
            libelle: (code) =>
                code == null ? l10n.communAucune : (fournisseurs.where((f) => f.code == code).firstOrNull?.nom ?? code),
            recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
            onChanged: (v) => setState(() => _fournisseur = v),
          ),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.prdDescriptionChamp,
            largeurLibelle: _lw,
            alignerDebut: true,
            child: DsTextField(controller: _description, multiligne: true, lignes: 2),
          ),
        ),
      ],
      DsSpan(child: DsSubHead(l10n.prdPrix, icone: LucideIcons.banknote)),
      DsFormRow(
        libelle: l10n.produitChampPrixAchat,
        obligatoire: true,
        largeurLibelle: _lw,
        child: DsTextField(
          key: const ValueKey('produit_achat'),
          controller: _achat,
          numerique: true,
          suffixeTexte: devise,
          indice: '0,00',
          onChanged: (_) => setState(() {}),
        ),
      ),
      DsFormRow(
        libelle: l10n.prdMarge,
        largeurLibelle: _lw,
        child: Row(
          spacing: 6,
          children: [
            Expanded(
              child: DsTextField(
                key: const ValueKey('produit_marge'),
                controller: _marge,
                numerique: true,
                suffixeTexte: _modeMarge == '%' ? '%' : devise,
                onChanged: (_) => setState(() {}),
              ),
            ),
            DsSegmentedControl<String>(
              petit: true,
              valeur: _modeMarge,
              onChanged: _changerModeMarge,
              options: [
                const DsOption('%', libelle: '%'),
                DsOption('DA', libelle: devise),
              ],
            ),
          ],
        ),
      ),
      DsFormRow(
        libelle: l10n.produitChampPrixVente,
        obligatoire: true,
        largeurLibelle: _lw,
        erreur: _sousAchat ? l10n.prdSousAchat : null,
        aide: !_sousAchat && _a > 0 ? l10n.prdMargeUnitaire(formaterMontant(_vente - _a, devise)) : null,
        child: DsTextField(
          key: ValueKey('produit_vente_${f2(_vente)}'),
          valeurInitiale: f2(_vente),
          suffixeTexte: devise,
          actif: false,
        ),
      ),
      if (det)
        DsFormRow(
          libelle: l10n.prdTva,
          largeurLibelle: _lw,
          child: DsSelect<double>(
            valeur: _tva,
            options: const [0, 9, 19],
            libelle: (v) => '${_nb(v)} %',
            onChanged: (v) => setState(() => _tva = v ?? _tva),
          ),
        )
      else
        const SizedBox.shrink(),
    ];
  }

  List<Widget> _etape2(AppLocalizations l10n, String devise) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final det = _detaille;
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    _magasin ??= ref.watch(magasinPrincipalProvider).value;
    final stock = _edition ? (ref.watch(stocksProduitsProvider).value?[widget.produit!.code] ?? 0) : null;
    Widget emballage(String libelle, TextEditingController q, TextEditingController p, String cle) => DsFormRow(
      libelle: libelle,
      largeurLibelle: _lw,
      child: Row(
        spacing: 6,
        children: [
          Expanded(
            child: DsTextField(
              key: ValueKey('${cle}_q'),
              controller: q,
              numerique: true,
              indice: l10n.dsPosPieces,
              suffixeTexte: l10n.prdPcs,
            ),
          ),
          Expanded(
            child: DsTextField(
              key: ValueKey('${cle}_p'),
              controller: p,
              numerique: true,
              indice: l10n.dsPosPrix,
              suffixeTexte: devise,
            ),
          ),
        ],
      ),
    );
    return [
      DsSpan(child: DsSubHead(l10n.produitsColStock, icone: LucideIcons.boxes)),
      DsFormRow(
        libelle: _edition ? l10n.prdStockActuel : l10n.prdStockInitial,
        largeurLibelle: _lw,
        aide: _edition ? l10n.prdStockAide : null,
        child: _edition
            ? DsTextField(
                key: const ValueKey('produit_stock_actuel'),
                valeurInitiale: formaterNombre(stock!),
                actif: false,
              )
            : DsTextField(
                key: const ValueKey('produit_stock_initial'),
                controller: _stock,
                numerique: true,
                actif: !_service,
              ),
      ),
      DsFormRow(
        libelle: l10n.prdSeuilAlerte,
        largeurLibelle: _lw,
        child: DsTextField(controller: _seuil, numerique: true),
      ),
      DsFormRow(
        libelle: l10n.dsMagasin,
        largeurLibelle: _lw,
        child: DsSelect<String>(
          valeur: _magasin,
          actif: !_edition,
          options: [for (final m in magasins) m.code],
          libelle: (code) => magasins.where((m) => m.code == code).firstOrNull?.nom ?? code,
          recherche: rechercheListe(context, ref, ListeMetier.magasin),
          onChanged: (v) => setState(() => _magasin = v),
        ),
      ),
      if (det)
        DsFormRow(
          libelle: l10n.produitChampUnite,
          largeurLibelle: _lw,
          child: DsSelectReferentiel(
            liste: Referentiel.unitesMesure,
            valeur: _unite,
            onChanged: (v) => setState(() => _unite = v ?? _unite),
          ),
        )
      else
        const SizedBox.shrink(),
      if (det) ...[
        DsSpan(child: DsSubHead(l10n.prdEmballages, icone: LucideIcons.package)),
        DsSpan(
          child: Text(l10n.prdEmballagesAide, style: t.bodySm.copyWith(color: c.textMuted, height: 1.5)),
        ),
        emballage(l10n.prdBoite, _boiteQ, _boiteP, 'produit_boite'),
        emballage(l10n.prdCarton, _cartonQ, _cartonP, 'produit_carton'),
      ],
    ];
  }

  List<Widget> _etape3(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final tailles = _typeTaille == null ? const <String>[] : taillesParType[_typeTaille]!;
    return [
      DsSpan(child: DsSubHead(l10n.prdVariantes, icone: LucideIcons.layers)),
      DsSpan(
        child: DsFormRow(
          libelle: l10n.prdTypeTaille,
          largeurLibelle: _lw,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: 320,
              child: DsSelect<String?>(
                valeur: _typeTaille,
                options: [null, ...taillesParType.keys],
                libelle: (v) => v == null ? l10n.communAucune : libelleRef(context, Referentiel.typesTaille, v),
                onChanged: (v) => setState(() {
                  _typeTaille = v;
                  _tailles = v == 'Taille unique' ? {'Taille unique'} : {};
                }),
              ),
            ),
          ),
        ),
      ),
      if (tailles.isNotEmpty && _typeTaille != 'Taille unique')
        DsSpan(
          child: DsFormRow(
            libelle: l10n.prdTailles,
            largeurLibelle: _lw,
            alignerDebut: true,
            aide: _tailles.isEmpty ? l10n.prdTaillesAide : l10n.prdTaillesN(_tailles.length),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                DsChipGroup<String>(
                  petit: true,
                  options: [for (final x in tailles) DsOption(x, libelle: x)],
                  selection: _tailles,
                  onChanged: (v) => setState(() => _tailles = v),
                ),
                Row(
                  spacing: 8,
                  children: [
                    DsButton(
                      libelle: l10n.communToutSelectionner,
                      taille: DsButtonTaille.sm,
                      variante: DsButtonVariante.fantome,
                      onPressed: () => setState(() => _tailles = tailles.toSet()),
                    ),
                    if (_tailles.isNotEmpty)
                      DsButton(
                        libelle: l10n.dsEffacer,
                        taille: DsButtonTaille.sm,
                        variante: DsButtonVariante.fantome,
                        onPressed: () => setState(() => _tailles = {}),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      DsSpan(
        child: DsFormRow(
          libelle: l10n.prdCouleurs,
          largeurLibelle: _lw,
          alignerDebut: true,
          aide: _couleurs.isEmpty
              ? l10n.prdCouleursAide
              : _couleurs.map((x) => libelleRef(context, Referentiel.couleursProduit, x)).join(', '),
          child: DsChipGroup<String>(
            petit: true,
            options: [
              for (final e in pastillesCouleurs.entries)
                DsOption(e.key, libelle: libelleRef(context, Referentiel.couleursProduit, e.key), couleur: e.value),
            ],
            selection: _couleurs,
            onChanged: (v) => setState(() => _couleurs = v),
          ),
        ),
      ),
      DsSpan(child: DsSubHead(l10n.prdOptions, icone: LucideIcons.settings2)),
      DsSpan(
        child: DsFormRow(
          libelle: l10n.prdCodesMultiples,
          largeurLibelle: _lw,
          alignerDebut: true,
          aide: l10n.prdCodesMultiplesAide,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final code in _codes)
                Container(
                  key: ValueKey('code_secondaire_$code'),
                  height: 28,
                  padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
                  decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(DsRadius.sm)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(code, style: t.mono.copyWith(color: c.textPrimary)),
                      Tooltip(
                        message: l10n.dsPosRetirer,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(DsRadius.xs),
                          onTap: () => setState(() => _codes = _codes.where((x) => x != code).toList()),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(LucideIcons.x, size: 13, color: c.iconMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              DsButton(
                key: const ValueKey('produit_ajouter_code'),
                libelle: l10n.prdAjouterCode,
                icone: LucideIcons.plus,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                onPressed: () async {
                  final code = await _saisirCode(l10n);
                  if (code != null && code.isNotEmpty && !_codes.contains(code)) {
                    setState(() => _codes = [..._codes, code]);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          DsSwitch(
            valeur: _serie,
            libelle: l10n.prdSuiviSerie,
            aide: l10n.prdSuiviSerieAide,
            onChanged: (v) => setState(() => _serie = v),
          ),
          DsSwitch(
            cle: const ValueKey('produit_service'),
            valeur: _service,
            libelle: l10n.prdServiceSansStock,
            aide: l10n.prdServiceAide,
            onChanged: (v) => setState(() => _service = v),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          DsSwitch(
            valeur: _expiration,
            libelle: l10n.prdDateExpiration,
            aide: l10n.prdExpirationAide,
            onChanged: (v) => setState(() {
              _expiration = v;
              _dateExpiration ??= DateTime(DateTime.now().year, 12, 31);
            }),
          ),
          if (_expiration) DsDateField(valeur: _dateExpiration, onChanged: (d) => setState(() => _dateExpiration = d)),
        ],
      ),
      DsSpan(
        child: DsFormRow(
          libelle: l10n.retoursObservation,
          largeurLibelle: _lw,
          alignerDebut: true,
          child: DsTextField(controller: _observation, multiligne: true, lignes: 2, indice: l10n.prdNoteInterne),
        ),
      ),
    ];
  }

  Future<String?> _saisirCode(AppLocalizations l10n) {
    final ctrl = TextEditingController(text: CodesBarres.genererEan13());
    return afficherDialog<String>(
      context,
      builder: (ctx) => DsDialog(
        titre: l10n.prdAjouterCode,
        iconeData: LucideIcons.barcode,
        largeur: 420,
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          DsButton(
            key: const ValueKey('code_secondaire_valider'),
            libelle: l10n.dsAjouter,
            icone: LucideIcons.check,
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
          ),
        ],
        contenu: DsTextField(
          key: const ValueKey('code_secondaire_saisie'),
          controller: ctrl,
          iconePrefixe: LucideIcons.barcode,
          autofocus: true,
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }
}
