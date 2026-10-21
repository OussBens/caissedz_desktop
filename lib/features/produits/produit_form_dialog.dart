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
import '../../domain/fiscalite.dart';
import '../../domain/models/parametres_vente.dart';
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

/// Valeurs proposées à la création d'un produit (Reçu IA : la ligne lue sur la facture du fournisseur).
@immutable
class ProduitPropose {
  const ProduitPropose({
    required this.designation,
    this.codeBarres,
    this.fournisseurCode,
    this.prixAchat,
    this.quantiteEntree,
  });
  final String designation;
  final String? codeBarres;
  final String? fournisseurCode;
  final double? prixAchat;

  /// Quantité lue sur la facture : elle entre en stock avec l'entrée du bon, le stock initial reste donc à 0.
  final double? quantiteEntree;
}

/// Formulaire produit (`ProduitFormDialog` du DS v2.2, 960 px) : création ou modification.
Future<Produit?> afficherFormulaireProduit(
  BuildContext context, {
  Produit? produit,
  bool detaille = false,
  ModeFormulaireProduit? mode,
  FicheProduitIa? fiche,
  ProduitPropose? propose,
}) => afficherDialog<Produit>(
  context,
  fermableParVoile: false,
  builder: (_) => ProduitFormDialog(
    produit: produit,
    mode: mode ?? (detaille ? ModeFormulaireProduit.detaille : ModeFormulaireProduit.rapide),
    fiche: fiche,
    propose: propose,
  ),
);

class ProduitFormDialog extends ConsumerStatefulWidget {
  const ProduitFormDialog({
    super.key,
    this.produit,
    this.mode = ModeFormulaireProduit.rapide,
    this.fiche,
    this.propose,
  });
  final Produit? produit;
  final ModeFormulaireProduit mode;
  final FicheProduitIa? fiche;
  final ProduitPropose? propose;

  @override
  ConsumerState<ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends ConsumerState<ProduitFormDialog> {
  late ModeFormulaireProduit _mode = widget.mode;
  int _etape = 1;
  late int _vu = _edition ? 3 : 1;
  bool _occupe = false;
  String? _erreur;
  String? _erreurCode;

  final _designation = TextEditingController();
  final _designationAr = TextEditingController();
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
      _designationAr.text = p.designationAr ?? '';
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
      final pr = widget.propose;
      if (pr != null) {
        _designation.text = pr.designation;
        _codeBarres.text = pr.codeBarres ?? '';
        _fournisseur = pr.fournisseurCode;
        if (pr.prixAchat != null && pr.prixAchat! > 0) _achat.text = _nb(pr.prixAchat!);
      }
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
    if (f.designationAr != null && _designationAr.text.trim().isEmpty) _designationAr.text = f.designationAr!;
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
      _designationAr,
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
  static double _d(String s) => lireNombre(s) ?? 0;

  double get _a => _d(_achat.text);
  double get _m => _d(_marge.text);

  /// Taux de TVA appliqué au prix de vente HT (IFU : sans TVA).
  double get _tauxTva =>
      Fiscalite.taux(_tva, ref.watch(parametresVenteProvider).value?.regimeFiscal ?? RegimesFiscaux.reel);

  double get _vente =>
      _modeMarge == '%' ? CalculsPrix.prixVenteDepuisMarge(_a, _m) : CalculsPrix.prixVenteDepuisMontant(_a, _m);

  /// Règle « vente sous achat » des Paramètres : `Interdire`, `Avertir` ou `Autoriser`.
  String get _regleSousAchat =>
      ref.read(parametresVenteProvider).value?.venteSousAchat ?? ParametresVente.venteSousAchatAvertir;
  bool get _interdit => _regleSousAchat == ParametresVente.venteSousAchatInterdire;

  bool _estSousAchat(double prix) => _a > 0 && prix < _a - 0.004;
  bool get _sousAchat => _estSousAchat(_vente);

  /// Prix par pièce d'un emballage (prix du colis ÷ nombre de pièces), `null` tant qu'il n'est pas saisi.
  double? _prixPiece(TextEditingController q, TextEditingController p) {
    final n = int.tryParse(q.text.trim()) ?? 0;
    final prix = _d(p.text);
    return n > 1 && prix > 0 ? prix / n : null;
  }

  /// Prix par pièce des emballages (boîte, carton) inférieurs au prix d'achat ; contrôlés en mode détaillé, où ils
  /// sont visibles.
  List<double> get _piecesSousAchat => [
    if (_detaille)
      for (final (q, p) in [(_boiteQ, _boiteP), (_cartonQ, _cartonP)])
        if (_prixPiece(q, p) case final piece? when _estSousAchat(piece)) piece,
  ];

  bool get _ok1 => _designation.text.trim().isNotEmpty && _a > 0 && !(_interdit && _sousAchat);
  bool get _okEnregistrer => _ok1 && !(_interdit && _piecesSousAchat.isNotEmpty);

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
    if (!_okEnregistrer) return;
    // « Avertir » : un prix de vente ou un prix par pièce d'emballage sous le prix d'achat est confirmé avant
    // l'enregistrement (« Interdire » bloque déjà le bouton, « Autoriser » passe sans question).
    final sous = [if (_sousAchat) _vente, ..._piecesSousAchat];
    if (sous.isNotEmpty && _regleSousAchat == ParametresVente.venteSousAchatAvertir) {
      final devise = ref.read(deviseProvider);
      final confirme = await afficherConfirmation(
        context,
        titre: l10n.posPrixSousAchatTitre,
        message: [
          for (final v in sous) l10n.posPrixSousAchatMsg(formaterMontant(_a, devise), formaterMontant(v, devise)),
        ].join('\n'),
        libelleConfirmer: l10n.communEnregistrer,
        genre: DsConfirmGenre.avertissement,
      );
      if (!confirme || !mounted) return;
    }
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
      designationAr: _designationAr.text.trim().isEmpty ? null : _designationAr.text.trim(),
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
          stockInitial: _service || widget.propose?.quantiteEntree != null ? 0 : _d(_stock.text),
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
    ref.watch(parametresVenteProvider); // règle « vente sous achat » (_regleSousAchat)
    final det = _detaille;
    final s1 = !det || _etape == 1;
    final s2 = !det || _etape == 2;
    final s3 = det && _etape == 3;
    final dernier = !det || _etape == 3;
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
            onPressed: _occupe || !_okEnregistrer ? null : () => _enregistrer(nouveau: true),
          ),
        DsButton(
          key: const ValueKey('produit_enregistrer'),
          libelle: l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: !_okEnregistrer ? null : _enregistrer,
        ),
      ] else ...[
        if (_edition)
          DsButton(
            libelle: l10n.communEnregistrer,
            variante: DsButtonVariante.secondaire,
            chargement: _occupe,
            onPressed: !_okEnregistrer ? null : _enregistrer,
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
      largeur: 1040,
      piedDebut: Text(
        det ? l10n.prdEtapeObligatoire(_etape) : l10n.prdObligatoire,
        style: t.caption.copyWith(color: c.textMuted, fontWeight: FontWeight.w500),
      ),
      actions: pied,
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          Row(
            spacing: DsSpacing.s6,
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
                Expanded(
                  child: DsStepper(
                    petit: true,
                    courante: _etape - 1,
                    etapes: [l10n.prdEtape1, l10n.prdEtape2, l10n.prdEtape3],
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
          if (_mode != ModeFormulaireProduit.ia) ...[
            if (s1) ..._etape1(l10n, devise, eanInvalide),
            if (s2) ..._etape2(l10n, devise),
            if (s3) ..._etape3(l10n),
          ],
          if (_erreur != null) Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
        ],
      ),
    );
  }

  /// Bloc du formulaire : un titre sobre puis ses rangées de champs, sur une surface encadrée.
  Widget _bloc(String titre, List<Widget> rangees) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      padding: const EdgeInsets.all(DsSpacing.s4),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderMd,
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            titre,
            style: t.label.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600),
          ),
          ...rangees,
        ],
      ),
    );
  }

  /// Champs répartis en rangées de [colonnes] cases de même largeur (la dernière rangée garde l'alignement).
  List<Widget> _grille(List<Widget> champs, {int colonnes = 2}) => [
    for (var i = 0; i < champs.length; i += colonnes)
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.s4,
        children: [
          for (var j = i; j < i + colonnes; j++) Expanded(child: j < champs.length ? champs[j] : const SizedBox()),
        ],
      ),
  ];

  /// Une rangée de champs aux largeurs relatives [flex].
  Widget _rangee(List<Widget> champs, {required List<int> flex}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: DsSpacing.s4,
    children: [for (final (i, x) in champs.indexed) Expanded(flex: flex[i], child: x)],
  );

  /// Interrupteur dans une case encadrée (libellé à gauche, bascule à droite).
  Widget _option(Widget interrupteur) {
    final c = context.ds.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: 10),
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderMd),
      child: interrupteur,
    );
  }

  /// Champ à libellé au-dessus.
  DsFormRow _champ(String libelle, Widget child, {bool obligatoire = false, String? aide, String? erreur}) =>
      DsFormRow(libelle: libelle, obligatoire: obligatoire, aide: aide, erreur: erreur, empile: true, child: child);

  /// Code-barres interne `CDZ` + date + séquence (CODE128), réservé auprès du catalogue.
  Future<void> _genererCodeBarres() async {
    final code = await ref.read(catalogueServiceProvider).reserverCodeBarresInterne();
    if (!mounted) return;
    setState(() {
      _codeBarres.text = code;
      _erreurCode = null;
    });
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
    final identification = _bloc(l10n.prdIdentification, [
      ..._grille([
        _champ(
          l10n.produitsColDesignation,
          obligatoire: true,
          DsTextField(
            key: const ValueKey('produit_designation'),
            controller: _designation,
            autofocus: !_edition,
            indice: l10n.prdDesignationIndice,
            onChanged: (_) => setState(() {}),
          ),
        ),
        // Nom arabe : saisi de droite à gauche quelle que soit la langue de l'interface.
        _champ(
          l10n.prdDesignationAr,
          Directionality(
            textDirection: TextDirection.rtl,
            child: DsTextField(
              key: const ValueKey('produit_designation_ar'),
              controller: _designationAr,
              indice: l10n.prdDesignationArIndice,
            ),
          ),
        ),
      ]),
      ..._grille([
        if (_edition) ...[
          _champ(l10n.produitsColCode, DsTextField(valeurInitiale: widget.produit!.code, actif: false)),
          _champ(
            l10n.retoursEtat,
            _option(DsSwitch(valeur: _actif, libelle: l10n.communActif, onChanged: (v) => setState(() => _actif = v))),
          ),
        ],
        _champ(
          l10n.produitsColCodeBarres,
          erreur: _erreurCode,
          aide: eanInvalide ? l10n.prdEanInvalide : null,
          Row(
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
                key: const ValueKey('produit_generer_code'),
                icone: LucideIcons.wandSparkles,
                tooltip: l10n.prdGenererCodeBarres,
                onPressed: _genererCodeBarres,
              ),
            ],
          ),
        ),
        if (det) _champ(l10n.prdMarque, DsTextField(controller: _marque, indice: l10n.prdMarqueIndice)),
        _champ(
          l10n.produitsColCategorie,
          obligatoire: true,
          DsSelect<String>(
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
        _champ(
          l10n.produitChampSousCategorie,
          DsSelect<String?>(
            valeur: _sousCategorie,
            options: [null, for (final s in sous) s.code],
            libelle: (code) =>
                code == null ? l10n.communAucune : (sous.where((s) => s.code == code).firstOrNull?.nom ?? code),
            recherche: rechercheListe(context, ref, ListeMetier.sousCategorie),
            onChanged: (v) => setState(() => _sousCategorie = v),
          ),
        ),
        if (det)
          _champ(
            l10n.prdFournisseur,
            DsSelect<String?>(
              valeur: _fournisseur,
              options: [null, for (final f in fournisseurs) f.code],
              libelle: (code) => code == null
                  ? l10n.communAucune
                  : (fournisseurs.where((f) => f.code == code).firstOrNull?.nom ?? code),
              recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
              onChanged: (v) => setState(() => _fournisseur = v),
            ),
          ),
      ]),
    ]);
    final photos = _bloc(l10n.prdPhotos, [
      DsPhotoUploader(
        photos: _photos,
        onAjouter: _ajouterPhoto,
        onRetirer: (x) => setState(() => _photos = _photos.where((y) => y != x).toList()),
        libelleAjouter: l10n.dsAjouter,
        libellePrincipale: l10n.prdPrincipale,
        aide: l10n.prdPhotosFormat,
        libelleFin: l10n.prdPhotosFin,
      ),
    ]);
    final prix = _bloc(l10n.prdPrix, [
      _rangee(
        flex: [5, 6, 5, if (det) 3, 5],
        [
          _champ(
            l10n.produitChampPrixAchat,
            obligatoire: true,
            DsTextField(
              key: const ValueKey('produit_achat'),
              controller: _achat,
              numerique: true,
              suffixeTexte: devise,
              indice: '0,00',
              onChanged: (_) => setState(() {}),
            ),
          ),
          _champ(
            l10n.prdMarge,
            Row(
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
          _champ(
            l10n.produitChampPrixVente,
            obligatoire: true,
            // Sous le prix d'achat selon les Paramètres : erreur bloquante (Interdire), avertissement (Avertir) ou
            // simple marge négative (Autoriser).
            erreur: _sousAchat && _interdit ? l10n.posPrixSousAchatInterdit : null,
            aide: _a <= 0 || (_sousAchat && _interdit)
                ? null
                : _sousAchat && _regleSousAchat == ParametresVente.venteSousAchatAvertir
                ? l10n.prdSousAchat
                : l10n.prdMargeUnitaire(formaterMontant(_vente - _a, devise)),
            DsTextField(
              key: ValueKey('produit_vente_${f2(_vente)}'),
              valeurInitiale: f2(_vente),
              suffixeTexte: devise,
              actif: false,
            ),
          ),
          if (det)
            _champ(
              l10n.prdTva,
              DsSelect<double>(
                valeur: _tva,
                options: const [0, 9, 19],
                libelle: (v) => '${_nb(v)} %',
                onChanged: (v) => setState(() => _tva = v ?? _tva),
              ),
            ),
          _champ(
            l10n.prdPrixTtc,
            aide: det ? null : '${l10n.prdTva} ${_nb(_tauxTva)} %',
            DsTextField(
              key: ValueKey('produit_ttc_${f2(Fiscalite.ttc(_vente, _tauxTva))}'),
              valeurInitiale: f2(Fiscalite.ttc(_vente, _tauxTva)),
              suffixeTexte: devise,
              actif: false,
            ),
          ),
        ],
      ),
    ]);
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.s4,
        children: [
          Expanded(child: identification),
          SizedBox(width: 232, child: photos),
        ],
      ),
      prix,
    ];
  }

  List<Widget> _etape2(AppLocalizations l10n, String devise) {
    final det = _detaille;
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    _magasin ??= ref.watch(magasinPrincipalProvider).value;
    final stock = _edition ? (ref.watch(stocksProduitsProvider).value?[widget.produit!.code] ?? 0) : null;
    // Prix par pièce affiché sous l'emballage et contrôlé contre le prix d'achat selon la règle des Paramètres.
    Widget emballage(String libelle, TextEditingController q, TextEditingController p, String cle) {
      final piece = _prixPiece(q, p);
      final sous = piece != null && _estSousAchat(piece);
      final parPiece = piece == null ? null : l10n.posSelParPiece(formaterMontant(piece, devise));
      return _champ(
        libelle,
        erreur: sous && _interdit ? '$parPiece · ${l10n.posPrixSousAchatInterdit}' : null,
        aide: sous && _regleSousAchat == ParametresVente.venteSousAchatAvertir
            ? '$parPiece · ${l10n.prdSousAchat}'
            : parPiece,
        Row(
          spacing: 6,
          children: [
            Expanded(
              child: DsTextField(
                key: ValueKey('${cle}_q'),
                controller: q,
                numerique: true,
                indice: l10n.dsPosPieces,
                suffixeTexte: l10n.prdPcs,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: DsTextField(
                key: ValueKey('${cle}_p'),
                controller: p,
                numerique: true,
                indice: l10n.dsPosPrix,
                suffixeTexte: devise,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      );
    }

    return [
      _bloc(l10n.produitsColStock, [
        ..._grille(colonnes: 4, [
          _champ(
            _edition ? l10n.prdStockActuel : l10n.prdStockInitial,
            aide: _edition || widget.propose?.quantiteEntree == null
                ? null
                : l10n.prdStockViaEntree(formaterNombre(widget.propose!.quantiteEntree!)),
            _edition
                ? DsTextField(
                    key: const ValueKey('produit_stock_actuel'),
                    valeurInitiale: formaterNombre(stock!),
                    actif: false,
                  )
                : DsTextField(
                    key: const ValueKey('produit_stock_initial'),
                    controller: _stock,
                    numerique: true,
                    actif: !_service && widget.propose?.quantiteEntree == null,
                  ),
          ),
          _champ(l10n.prdSeuilAlerte, DsTextField(controller: _seuil, numerique: true)),
          if (det)
            _champ(
              l10n.produitChampUnite,
              DsSelectReferentiel(
                liste: Referentiel.unitesMesure,
                valeur: _unite,
                onChanged: (v) => setState(() => _unite = v ?? _unite),
              ),
            ),
          if (ref.watch(plusieursMagasinsProvider))
            _champ(
              l10n.dsMagasin,
              DsSelect<String>(
                valeur: _magasin,
                actif: !_edition,
                options: [for (final m in magasins) m.code],
                libelle: (code) => magasins.where((m) => m.code == code).firstOrNull?.nom ?? code,
                recherche: rechercheListe(context, ref, ListeMetier.magasin),
                onChanged: (v) => setState(() => _magasin = v),
              ),
            ),
        ]),
      ]),
      if (det)
        _bloc(l10n.prdEmballages, [
          ..._grille([
            emballage(l10n.prdBoite, _boiteQ, _boiteP, 'produit_boite'),
            emballage(l10n.prdCarton, _cartonQ, _cartonP, 'produit_carton'),
          ]),
        ]),
    ];
  }

  List<Widget> _etape3(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final tailles = _typeTaille == null ? const <String>[] : taillesParType[_typeTaille]!;
    return [
      _bloc(l10n.prdVariantes, [
        ..._grille(colonnes: 3, [
          _champ(
            l10n.prdTypeTaille,
            DsSelect<String?>(
              valeur: _typeTaille,
              options: [null, ...taillesParType.keys],
              libelle: (v) => v == null ? l10n.communAucune : libelleRef(context, Referentiel.typesTaille, v),
              onChanged: (v) => setState(() {
                _typeTaille = v;
                _tailles = v == 'Taille unique' ? {'Taille unique'} : {};
              }),
            ),
          ),
        ]),
        if (tailles.isNotEmpty && _typeTaille != 'Taille unique')
          _champ(
            l10n.prdTailles,
            aide: _tailles.isEmpty ? null : l10n.prdTaillesN(_tailles.length),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DsChipGroup<String>(
                  petit: true,
                  options: [for (final x in tailles) DsOption(x, libelle: x)],
                  selection: _tailles,
                  onChanged: (v) => setState(() => _tailles = v),
                ),
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
          ),
        _champ(
          l10n.prdCouleurs,
          DsChipGroup<String>(
            petit: true,
            options: [
              for (final e in pastillesCouleurs.entries)
                DsOption(e.key, libelle: libelleRef(context, Referentiel.couleursProduit, e.key), couleur: e.value),
            ],
            selection: _couleurs,
            onChanged: (v) => setState(() => _couleurs = v),
          ),
        ),
      ]),
      _bloc(l10n.prdOptions, [
        _champ(
          l10n.prdCodesMultiples,
          Wrap(
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
        ..._grille(colonnes: 3, [
          _option(DsSwitch(valeur: _serie, libelle: l10n.prdSuiviSerie, onChanged: (v) => setState(() => _serie = v))),
          _option(
            DsSwitch(
              cle: const ValueKey('produit_service'),
              valeur: _service,
              libelle: l10n.prdServiceSansStock,
              onChanged: (v) => setState(() => _service = v),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              _option(
                DsSwitch(
                  valeur: _expiration,
                  libelle: l10n.prdDateExpiration,
                  onChanged: (v) => setState(() {
                    _expiration = v;
                    _dateExpiration ??= DateTime(DateTime.now().year, 12, 31);
                  }),
                ),
              ),
              if (_expiration)
                DsDateField(valeur: _dateExpiration, onChanged: (d) => setState(() => _dateExpiration = d)),
            ],
          ),
        ]),
        ..._grille([
          _champ(l10n.prdDescriptionChamp, DsTextField(controller: _description, multiligne: true, lignes: 2)),
          _champ(
            l10n.retoursObservation,
            DsTextField(controller: _observation, multiligne: true, lignes: 2, indice: l10n.prdNoteInterne),
          ),
        ]),
      ]),
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
