import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_service.dart';
import '../../application/smart_scan_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/achat.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../caisse/caisse_dialogs.dart';
import '../commun/doc_form.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_providers.dart';
import '../produits/produit_dialogs.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'entree_dialogs.dart';
import 'entrees_providers.dart';

const double _lw = 112;
const String _creer = '__creer__';

/// Ligne détectée en cours de rapprochement (étape 2 du Reçu IA).
class _LigneIa {
  _LigneIa(this.id, this.lu, {this.produit, required this.quantite, required this.prix, this.confiance})
    : prixVente = produit?.prixVente ?? 0;
  final int id;
  final String lu;
  Produit? produit;
  double quantite;
  double prix;
  double prixVente;
  final double? confiance;
}

/// Similarité de deux désignations (coefficient de Dice sur les bigrammes, 0–1).
double similarite(String a, String b) {
  Set<String> bigrammes(String s) {
    final t = s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return {for (var i = 0; i < t.length - 1; i++) t.substring(i, i + 2)};
  }

  final x = bigrammes(a);
  final y = bigrammes(b);
  if (x.isEmpty || y.isEmpty) return a.trim().toLowerCase() == b.trim().toLowerCase() ? 1 : 0;
  return 2 * x.intersection(y).length / (x.length + y.length);
}

/// `RecuIADialog` (1040 px, 3 étapes) : photo du bon → lignes détectées et rapprochées → fournisseur & paiement.
/// Un bon reçu (file Mode IA) s'ouvre directement à l'étape 2 avec ses lignes détectées.
Future<void> afficherRecuIA(BuildContext context, WidgetRef ref, {BonReception? bon}) async {
  if (!await exigerSessionCaisse(context, ref)) return;
  if (!context.mounted) return;
  await ref.read(produitsProvider.future);
  await ref.read(fournisseursProvider.future);
  await ref.read(caissesListeProvider.future);
  final principal = await ref.read(magasinPrincipalProvider.future);
  if (!context.mounted) return;
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => RecuIADialog(bon: bon, principal: principal),
  );
}

class RecuIADialog extends ConsumerStatefulWidget {
  const RecuIADialog({super.key, this.bon, required this.principal});
  final BonReception? bon;
  final String principal;

  @override
  ConsumerState<RecuIADialog> createState() => _RecuIADialogState();
}

class _RecuIADialogState extends ConsumerState<RecuIADialog> {
  int _etape = 0;
  XFile? _fichier;
  BonReception? _bon;
  bool _analyse = false;
  bool _occupe = false;
  String? _erreur;
  bool _quotaAtteint = false;
  List<_LigneIa> _lignes = [];
  int _id = 0;
  String? _fournisseur;
  String? _fournisseurDetecte;
  final _reference = TextEditingController();
  DateTime? _date = DateTime.now();
  late String _magasin = widget.principal;
  final _paiement = EtatPaiement();

  @override
  void initState() {
    super.initState();
    final b = widget.bon;
    if (b == null) return;
    _bon = b;
    if (b.chemin != null && File(b.chemin!).existsSync()) _fichier = XFile(b.chemin!, name: b.fichier);
    if (b.statut == StatutsBon.recu && b.lignes.isNotEmpty) {
      _charger(b.lignes, fournisseur: b.fournisseurDetecte, reference: b.numBon);
      _etape = 1;
    }
  }

  @override
  void dispose() {
    _reference.dispose();
    _paiement.dispose();
    super.dispose();
  }

  /// Rapproche chaque ligne détectée : code-barres, puis désignation identique.
  void _charger(List<LigneDetectee> detectees, {String? fournisseur, String? reference}) {
    final produits = (ref.read(produitsProvider).value ?? const <Produit>[]).where((p) => p.actif).toList();
    final fournisseurs = ref.read(fournisseursProvider).value ?? const <Fournisseur>[];
    _lignes = [
      for (final l in detectees)
        _LigneIa(
          _id++,
          l.designation,
          produit: produits
              .where(
                (p) =>
                    (l.codeBarres != null && l.codeBarres!.isNotEmpty && p.codeBarres == l.codeBarres) ||
                    p.designation.trim().toLowerCase() == l.designation.trim().toLowerCase(),
              )
              .firstOrNull,
          quantite: l.quantite,
          prix: l.prixAchat,
          confiance: l.confiance,
        ),
    ];
    _fournisseurDetecte = fournisseur;
    if (fournisseur != null) {
      _fournisseur = fournisseurs
          .where((f) => f.actif && f.nom.trim().toLowerCase() == fournisseur.trim().toLowerCase())
          .firstOrNull
          ?.code;
    }
    _reference.text = reference ?? '';
  }

  Future<void> _choisirFichier() async {
    final f = await ref.read(selecteurFactureProvider)();
    if (f == null || !mounted) return;
    setState(() {
      _fichier = f;
      _erreur = null;
    });
  }

  Future<void> _analyser() async {
    final l10n = AppLocalizations.of(context);
    final f = _fichier;
    if (f == null) return;
    setState(() {
      _analyse = true;
      _erreur = null;
    });
    final service = ref.read(achatServiceProvider);
    try {
      await ref.read(serveurCaisseDzProvider.future);
      final r = await ref.read(smartScanServiceProvider).analyser(await f.readAsBytes(), nomFichier: f.name);
      final detectees = [
        for (final l in r.lignes)
          LigneDetectee(
            designation: l.designation,
            codeBarres: l.codeBarres,
            quantite: l.quantite,
            prixAchat: l.prixAchat,
            confiance: l.confiance,
          ),
      ];
      final bon = await service.deposerBon(
        code: _bon?.code,
        fichier: f.name,
        chemin: f.path.isEmpty ? null : f.path,
        fournisseurDetecte: r.fournisseur,
        numBon: r.reference,
        lignes: detectees,
      );
      ref.invalidate(quotaSmartScanProvider);
      rafraichirEntrees(ref);
      if (!mounted) return;
      setState(() {
        _bon = bon;
        _charger(detectees, fournisseur: r.fournisseur, reference: r.reference);
        _etape = 1;
      });
    } on SmartScanException catch (e) {
      if (e.erreur == ErreurSmartScan.serveur || e.erreur == ErreurSmartScan.fichierInvalide) {
        final bon = await service.deposerBon(
          code: _bon?.code,
          fichier: f.name,
          chemin: f.path.isEmpty ? null : f.path,
          erreur: true,
          commentaire: e.detail,
        );
        rafraichirEntrees(ref);
        _bon = bon;
      }
      if (!mounted) return;
      setState(() {
        _erreur = messageErreurSmartScan(l10n, e);
        _quotaAtteint = e.erreur == ErreurSmartScan.quotaAtteint;
      });
    } finally {
      if (mounted) setState(() => _analyse = false);
    }
  }

  Future<void> _rapprocher(_LigneIa l, String? choix) async {
    if (choix == null) return;
    if (choix != _creer) {
      final p = (ref.read(produitsProvider).value ?? const <Produit>[]).where((p) => p.code == choix).firstOrNull;
      setState(() {
        l.produit = p;
        l.prixVente = p?.prixVente ?? 0;
      });
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      final p = await ref
          .read(catalogueServiceProvider)
          .creerProduit(
            Produit(
              code: '',
              designation: l.lu,
              categorieCode: 'CATE0000',
              sousCategorieCode: 'SC0000',
              prixAchat: l.prix,
              prixVente: 0,
            ),
            margeDefautPct: 30,
          );
      rafraichirCatalogue(ref);
      if (!mounted) return;
      setState(() {
        l.produit = p;
        l.prixVente = p.prixVente;
      });
    } on CatalogueException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.entCreerProduit(l.lu),
          message: messageErreurCatalogue(l10n, e.erreur),
        ),
      );
    }
  }

  Future<void> _ajouter() async {
    final choix = await choisirProduits(context, ref);
    if (choix.isEmpty) return;
    setState(
      () => _lignes = [
        ..._lignes,
        for (final p in choix) _LigneIa(_id++, '—', produit: p, quantite: 1, prix: p.prixAchat),
      ],
    );
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final total = _total;
    final caisse = _paiement.caisse ?? ref.read(caissesListeProvider).value?.where((c) => c.actif).firstOrNull?.code;
    final nombreGlobal = ref.read(parametresVenteProvider).value?.nombreActif ?? false;
    Achat? a;
    final ok = await executerEntree(context, ref, () async {
      a = await ref
          .read(achatServiceProvider)
          .enregistrer(
            fournisseurCode: _fournisseur!,
            magasinCode: _magasin,
            lignes: [
              for (final l in _lignes)
                DemandeAchatLigne(
                  produitCode: l.produit!.code,
                  quantite: l.quantite,
                  // 2ᵉ stock « nombre » (§8.1) : pièces déduites du reçu (quantité × pièces par unité).
                  nombre: l.produit!.exigeNombre(global: nombreGlobal) ? l.quantite * l.produit!.nombreParUnite : 0,
                  prixAchat: l.prix,
                  nouveauPrixVente: l.prixVente != l.produit!.prixVente ? l.prixVente : null,
                ),
            ],
            reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            verse: _paiement.verse(total),
            modePaiement: _paiement.mode,
            caisseCode: caisse,
            date: _date,
            source: SourcesAchat.ia,
            bonCode: _bon?.code,
          );
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _occupe = false);
      return;
    }
    Navigator.of(context).pop(true);
    afficherToast(
      context,
      titre: l10n.entToastDepuisBon,
      description: '${a!.code} · ${l10n.stkToastStockAJour}',
      ton: DsToastTon.succes,
    );
  }

  double get _total => _lignes.fold(0.0, (a, l) => a + l.quantite * l.prix);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final aRapprocher = _lignes.where((l) => l.produit == null).length;
    final erreurs = <Object, Map<String, String>>{
      for (final l in _lignes)
        if (l.produit != null && !l.produit!.service && l.prixVente <= l.prix) l.id: {'vente': l10n.entVenteSousAchat},
    };
    final total = _total;
    return DsDialog(
      titre: l10n.entIaTitre,
      iconeData: LucideIcons.sparkles,
      description: l10n.entIaDescription,
      largeur: 1040,
      fermable: !_occupe && !_analyse,
      piedDebut: _etape > 0
          ? DsButton(
              libelle: l10n.entRetour,
              icone: LucideIcons.arrowLeft,
              variante: DsButtonVariante.secondaire,
              onPressed: _occupe ? null : () => setState(() => _etape--),
            )
          : null,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe || _analyse ? null : () => Navigator.of(context).pop(),
        ),
        switch (_etape) {
          0 => DsButton(
            key: const ValueKey('ia_analyser'),
            libelle: l10n.entIaAnalyser,
            icone: LucideIcons.sparkles,
            chargement: _analyse,
            onPressed: _fichier == null || _quotaAtteint ? null : _analyser,
          ),
          1 => DsButton(
            key: const ValueKey('ia_suivant'),
            libelle: aRapprocher > 0 ? l10n.entIaARapprocher(aRapprocher) : l10n.entSuivant,
            iconeDroite: LucideIcons.arrowRight,
            onPressed: aRapprocher == 0 && _lignes.isNotEmpty && erreurs.isEmpty && _lignes.every((l) => l.quantite > 0)
                ? () => setState(() => _etape = 2)
                : null,
          ),
          _ => DsButton(
            key: const ValueKey('ia_creer'),
            libelle: l10n.entIaCreer(formaterMontant(total, devise)),
            icone: LucideIcons.check,
            chargement: _occupe,
            onPressed: _fournisseur != null && _date != null ? _enregistrer : null,
          ),
        },
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          DsStepper(
            etapes: [l10n.entIaEtapePhoto, l10n.entIaEtapeLignes, l10n.entIaEtapeFournisseur],
            descriptions: [l10n.entIaEtapePhotoDetail, l10n.entIaEtapeLignesDetail, l10n.entIaEtapeFournisseurDetail],
            courante: _etape,
            onEtape: (i) => setState(() => _etape = i),
          ),
          if (_etape == 0) _etapePhoto(l10n),
          if (_etape == 1) _etapeLignes(l10n, devise, erreurs),
          if (_etape == 2) _etapeFournisseur(l10n, devise, total),
        ],
      ),
    );
  }

  Widget _etapePhoto(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final quota = ref.watch(quotaSmartScanProvider);
    final q = quota.value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              AnimatedContainer(
                duration: DsMotion.base,
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _analyse ? c.primaryTint : c.surfaceSunken,
                  borderRadius: BorderRadius.circular(DsRadius.lg),
                  border: Border.all(color: _analyse ? c.primary : c.borderStrong, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    if (_analyse)
                      SizedBox.square(
                        dimension: 30,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: c.iconActive),
                      )
                    else
                      Icon(LucideIcons.fileImage, size: 30, color: c.iconActive),
                    Text(
                      _analyse ? l10n.entIaLecture : (_fichier?.name ?? l10n.entIaAucunFichier),
                      style: t.body.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _analyse ? l10n.entIaLectureDetail : l10n.entIaFormats,
                      style: t.bodySm.copyWith(color: c.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    if (!_analyse)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          DsButton(
                            key: const ValueKey('ia_disque'),
                            libelle: l10n.entIaDepuisDisque,
                            icone: LucideIcons.folderOpen,
                            taille: DsButtonTaille.sm,
                            variante: DsButtonVariante.secondaire,
                            onPressed: _choisirFichier,
                          ),
                          DsButton(
                            libelle: l10n.entIaDepuisTelephone,
                            icone: LucideIcons.smartphone,
                            taille: DsButtonTaille.sm,
                            variante: DsButtonVariante.fantome,
                            tooltip: l10n.entIaTelephoneAide,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (_erreur != null)
                Row(
                  spacing: 8,
                  children: [
                    Icon(LucideIcons.circleAlert, size: 16, color: c.dangerFg),
                    Expanded(
                      child: Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
                    ),
                  ],
                ),
            ],
          ),
        ),
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              DsQuotaCard(
                utilises: q?.utilise ?? 0,
                limite: q?.total ?? 0,
                horsLigne: quota.hasError,
                onActualiser: () => ref.invalidate(quotaSmartScanProvider),
              ),
              if (_quotaAtteint || (q?.atteint ?? false))
                DsButton(
                  key: const ValueKey('ia_offre'),
                  libelle: l10n.smartScanDemandeOffre,
                  icone: LucideIcons.mail,
                  variante: DsButtonVariante.secondaire,
                  onPressed: () => afficherDemandeOffre(context, ref),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _etapeLignes(AppLocalizations l10n, String devise, Map<Object, Map<String, String>> erreurs) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final produits = (ref.watch(produitsProvider).value ?? const <Produit>[]).where((p) => p.actif).toList();
    return DsLineItemsEditor<_LigneIa>(
      lignes: _lignes,
      cle: (l) => l.id,
      devise: devise,
      erreurs: erreurs,
      hauteurMax: 320,
      totalLigne: (l) => l.quantite * l.prix,
      quantite: (l) => l.quantite,
      libelleAjouter: l10n.dsPosLigneAjouter,
      onAjouter: _ajouter,
      texteVide: l10n.smartScanAucuneLigne,
      onSupprimer: (l) => setState(() => _lignes = _lignes.where((x) => x != l).toList()),
      colonnes: [
        DsColonneLigne(id: 'lu', libelle: l10n.entIaLu, valeur: (l) => l.lu, attenue: true),
        DsColonneLigne(
          id: 'nom',
          libelle: l10n.entIaProduitCatalogue,
          valeur: (l) => l.produit?.designation ?? '',
          cellule: (_, l) {
            if (l.produit != null) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      l.produit!.designation,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySm.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                    ),
                  ),
                  DsIconButton(
                    icone: LucideIcons.replace,
                    tooltip: l10n.entIaRemplacer,
                    taille: 26,
                    onPressed: () => setState(() => l.produit = null),
                  ),
                ],
              );
            }
            final tries = [...produits]
              ..sort((a, b) => similarite(b.designation, l.lu).compareTo(similarite(a.designation, l.lu)));
            return ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200),
              child: DsSelect<String>(
                cle: ValueKey('ia_rapprocher_${l.id}'),
                valeur: null,
                taille: DsTailles.controleSm,
                placeholder: l10n.entIaRapprocher,
                options: [for (final p in tries) p.code, _creer],
                libelle: (code) => code == _creer
                    ? l10n.entCreerProduit(l.lu)
                    : produits.where((p) => p.code == code).firstOrNull?.designation ?? code,
                onChanged: (v) => _rapprocher(l, v),
              ),
            );
          },
        ),
        DsColonneLigne(
          id: 'conf',
          libelle: l10n.entIaConfiance,
          largeur: 96,
          valeur: (l) => l.confiance == null ? '—' : '${l.confiance!.round()} %',
          cellule: (_, l) => l.confiance == null
              ? Text('—', style: t.bodySm.copyWith(color: c.textMuted))
              : DsBadge(
                  libelle: '${l.confiance!.round()} %',
                  ton: l.confiance! >= 90
                      ? DsBadgeTon.succes
                      : l.confiance! >= 75
                      ? DsBadgeTon.avertissement
                      : DsBadgeTon.danger,
                ),
        ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.stkQte,
          numerique: true,
          editable: true,
          largeur: 90,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'prix',
          libelle: l10n.produitsColPrixAchat,
          numerique: true,
          editable: true,
          largeur: 130,
          suffixe: devise,
          valeur: (l) => montantLigne(l.prix),
          onEdition: (l, v) => setState(() => l.prix = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'vente',
          libelle: l10n.produitsColPrixVente,
          numerique: true,
          editable: true,
          largeur: 130,
          suffixe: devise,
          valeur: (l) => montantLigne(l.prixVente),
          onEdition: (l, v) => setState(() => l.prixVente = nombreSaisi(v)),
        ),
      ],
    );
  }

  Widget _etapeFournisseur(AppLocalizations l10n, String devise, double total) {
    final fournisseurs = (ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        .where((f) => f.actif)
        .toList();
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    final caisses = (ref.watch(caissesListeProvider).value ?? const <Caisse>[]).where((c) => c.actif).toList();
    final detecte = _fournisseurDetecte != null && _fournisseur != null;
    return DsGrilleFormulaire(
      children: [
        DsFormRow(
          libelle: l10n.achatFournisseur,
          obligatoire: true,
          largeurLibelle: _lw,
          aide: detecte ? l10n.entIaDetecte : null,
          child: DsSelect<String>(
            cle: const ValueKey('ia_fournisseur'),
            valeur: _fournisseur,
            placeholder: _fournisseurDetecte ?? l10n.stkChoisirFournisseur,
            options: [for (final f in fournisseurs) f.code],
            libelle: (c) => fournisseurs.where((f) => f.code == c).firstOrNull?.nom ?? c,
            onChanged: (v) => setState(() => _fournisseur = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.entNumFacture,
          largeurLibelle: _lw,
          aide: _bon?.numBon != null ? l10n.entIaDetecte : null,
          child: DsTextField(controller: _reference, indice: l10n.entNumFactureIndice),
        ),
        DsFormRow(
          libelle: l10n.communDate,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d)),
        ),
        DsFormRow(
          libelle: l10n.stockColMagasin,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String>(
            valeur: _magasin,
            options: [for (final m in magasins) m.code],
            libelle: (c) => magasins.where((m) => m.code == c).firstOrNull?.nom ?? c,
            onChanged: (v) => setState(() => _magasin = v ?? _magasin),
          ),
        ),
        ...lignesPaiement(
          context,
          etat: _paiement,
          total: total,
          devise: devise,
          caisses: caisses,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
}

/// Demande d'offre Smart Scan (quota atteint).
Future<void> afficherDemandeOffre(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final email = TextEditingController();
  final message = TextEditingController(text: l10n.entOffreMessage);
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.smartScanDemandeOffre,
      iconeData: LucideIcons.mail,
      largeur: 480,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        DsButton(
          key: const ValueKey('offre_envoyer'),
          libelle: l10n.smartScanDemandeOffre,
          icone: LucideIcons.send,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          DsFormRow(
            libelle: l10n.smartScanEmail,
            obligatoire: true,
            largeurLibelle: 100,
            child: DsTextField(
              key: const ValueKey('offre_email'),
              controller: email,
              autofocus: true,
              typeClavier: TextInputType.emailAddress,
            ),
          ),
          DsFormRow(
            libelle: l10n.smartScanMessage,
            largeurLibelle: 100,
            alignerDebut: true,
            child: DsTextField(controller: message, multiligne: true, lignes: 3),
          ),
        ],
      ),
    ),
  );
  final e = email.text.trim();
  final m = message.text.trim();
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(smartScanServiceProvider).demanderOffre(email: e, message: m);
    if (!context.mounted) return;
    afficherToast(
      context,
      titre: l10n.smartScanDemandeOffre,
      description: l10n.smartScanOffreEnvoyee,
      ton: DsToastTon.succes,
    );
  } on SmartScanException catch (x) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.smartScanDemandeOffre,
        message: messageErreurSmartScan(l10n, x),
      ),
    );
  }
}

/// Aperçu d'un bon de réception : image (si disponible), fournisseur détecté, lignes lues, entrée liée.
Future<void> afficherBon(BuildContext context, WidgetRef ref, BonReception b) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final chemin = b.chemin;
  final image =
      chemin != null && RegExp(r'\.(jpe?g|png)$', caseSensitive: false).hasMatch(chemin) && File(chemin).existsSync();
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 900,
      icone: LucideIcons.image,
      titre: '${b.code} · ${b.fichier}',
      description: '${formatDateHeure.format(b.date)} · ${b.fournisseurDetecte ?? '—'}',
      badges: [BadgeStatut(b.statutDs)],
      stats: [
        DsStatItem(libelle: l10n.entIaLignes, valeur: '${b.lignes.length}', icone: LucideIcons.listChecks),
        DsStatItem(libelle: l10n.entEntite, valeur: b.achatCode ?? '—', icone: LucideIcons.packagePlus),
      ],
      sections: [
        if (image)
          DsSectionDetail(
            titre: l10n.entIaApercu,
            icone: LucideIcons.image,
            contenu: ClipRRect(
              borderRadius: BorderRadius.circular(DsRadius.md),
              child: Image.file(File(chemin), height: 320, fit: BoxFit.contain),
            ),
          ),
        if (b.lignes.isNotEmpty)
          DsSectionDetail(
            titre: l10n.entIaLignesLues,
            icone: LucideIcons.scanText,
            nbLignes: b.lignes.length,
            tableau: DsDataTable<LigneDetectee>(
              dense: true,
              encadre: false,
              pagine: false,
              hauteurMax: 280,
              cle: (l) => '${b.lignes.indexOf(l)}',
              lignes: b.lignes,
              colonnes: [
                DsColonne(id: 'lu', libelle: l10n.entIaLu, valeur: (l) => l.designation, fort: true, flex: 3),
                DsColonne(
                  id: 'cb',
                  libelle: l10n.produitsColCodeBarres,
                  valeur: (l) => l.codeBarres ?? '',
                  attenue: true,
                ),
                DsColonne(
                  id: 'qte',
                  libelle: l10n.stkQte,
                  numerique: true,
                  valeur: (l) => l.quantite,
                  cellule: (_, l) => Text(formaterNombre(l.quantite)),
                ),
                DsColonne(
                  id: 'prix',
                  libelle: l10n.produitsColPrixAchat,
                  numerique: true,
                  valeur: (l) => l.prixAchat,
                  cellule: (_, l) => Text(formaterMontant(l.prixAchat, devise)),
                ),
              ],
            ),
          ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.entIaRecuPar, utilisateurs[b.utilisateurCode] ?? b.utilisateurCode),
            if (b.traitePar != null) DsKeyValue(l10n.entIaTraitePar, utilisateurs[b.traitePar] ?? b.traitePar),
            if (b.commentaire != null) DsKeyValue(l10n.retoursObservation, b.commentaire),
          ],
        ),
      ],
    ),
  );
}
