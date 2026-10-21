import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/doc_form.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import 'produit_dialogs.dart';
import 'produits_donnees.dart';
import 'produits_providers.dart';

// ============================================================ Catégories

/// Formulaire catégorie (`CategorieFormDialog`, 600 px) : code, nom unique, description, état.
Future<void> afficherFormulaireCategorie(BuildContext context, WidgetRef ref, {Categorie? categorie}) =>
    afficherDialog<void>(context, builder: (_) => _CategorieForm(categorie: categorie));

/// Formulaire sous-catégorie (`CategorieFormDialog sous`) : catégorie parente, nom, état.
Future<void> afficherFormulaireSousCategorie(
  BuildContext context,
  WidgetRef ref, {
  SousCategorie? sousCategorie,
  String? categorieCode,
}) => afficherDialog<void>(
  context,
  builder: (_) => _CategorieForm(sous: true, sousCategorie: sousCategorie, categorieParente: categorieCode),
);

class _CategorieForm extends ConsumerStatefulWidget {
  const _CategorieForm({this.categorie, this.sous = false, this.sousCategorie, this.categorieParente});
  final Categorie? categorie;
  final bool sous;
  final SousCategorie? sousCategorie;
  final String? categorieParente;

  @override
  ConsumerState<_CategorieForm> createState() => _CategorieFormState();
}

class _CategorieFormState extends ConsumerState<_CategorieForm> {
  late final _nom = TextEditingController(text: widget.categorie?.nom ?? widget.sousCategorie?.nom ?? '');
  late final _description = TextEditingController(
    text: widget.categorie?.description ?? widget.sousCategorie?.description ?? '',
  );
  late bool _actif = widget.categorie?.actif ?? widget.sousCategorie?.actif ?? true;
  late String? _parente = widget.sousCategorie?.categorieCode ?? widget.categorieParente;
  bool _occupe = false;
  String? _erreur;

  bool get _edition => widget.categorie != null || widget.sousCategorie != null;
  String? get _code => widget.categorie?.code ?? widget.sousCategorie?.code;

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  bool _doublon(List<Categorie> categories, List<SousCategorie> sous) {
    final n = _nom.text.trim().toLowerCase();
    if (n.isEmpty) return false;
    return widget.sous
        ? sous.any((s) => s.categorieCode == _parente && s.nom.toLowerCase() == n && s.code != _code)
        : categories.any((c) => c.nom.toLowerCase() == n && c.code != _code);
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final s = ref.read(catalogueServiceProvider);
    try {
      if (widget.sous) {
        final base = widget.sousCategorie;
        if (base == null) {
          await s.creerSousCategorie(_parente!, _nom.text, description: _description.text, actif: _actif);
        } else {
          await s.modifierSousCategorie(
            SousCategorie(
              code: base.code,
              categorieCode: _parente!,
              nom: _nom.text,
              description: _description.text,
              actif: _actif,
            ),
          );
        }
      } else {
        final base = widget.categorie;
        if (base == null) {
          await s.creerCategorie(_nom.text, description: _description.text, actif: _actif);
        } else {
          await s.modifierCategorie(
            Categorie(code: base.code, nom: _nom.text, description: _description.text, actif: _actif),
          );
        }
      }
      rafraichirCatalogue(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(
        context,
        titre: widget.sous ? l10n.prdToastSousCategorie : l10n.prdToastCategorie,
        ton: DsToastTon.succes,
      );
    } on CatalogueException catch (e) {
      if (mounted) {
        setState(() {
          _occupe = false;
          _erreur = messageErreurCatalogue(l10n, e.erreur);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const <Categorie>[];
    final sous = ref.watch(sousCategoriesProvider).value ?? const <SousCategorie>[];
    final parentes = categories.where((c) => c.actif || c.code == _parente).toList();
    _parente ??= parentes.where((c) => !c.systeme).firstOrNull?.code ?? parentes.firstOrNull?.code;
    final doublon = _doublon(categories, sous);
    final ok = _nom.text.trim().isNotEmpty && !doublon && (!widget.sous || _parente != null);
    return DsDialog(
      titre: widget.sous
          ? (_edition ? l10n.prdModifierSousCategorie : l10n.categoriesNouvelleSous)
          : (_edition ? l10n.prdModifierCategorie : l10n.categoriesNouvelle),
      iconeData: widget.sous ? LucideIcons.folderTree : LucideIcons.folder,
      largeur: 600,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('categorie_enregistrer'),
          libelle: l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: ok ? _enregistrer : null,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (_code != null)
            DsFormRow(
              libelle: l10n.produitsColCode,
              child: DsTextField(valeurInitiale: _code ?? l10n.prdCodeAuto, actif: false),
            ),
          if (widget.sous)
            DsFormRow(
              libelle: l10n.prdCategorieParente,
              obligatoire: true,
              child: DsSelect<String>(
                valeur: _parente,
                options: [for (final c in parentes) c.code],
                libelle: (code) => parentes.where((c) => c.code == code).firstOrNull?.nom ?? code,
                recherche: rechercheListe(context, ref, ListeMetier.categorie),
                onChanged: (v) => setState(() => _parente = v),
              ),
            ),
          DsFormRow(
            libelle: l10n.categorieNom,
            obligatoire: true,
            erreur: doublon ? (widget.sous ? l10n.prdSousCategorieExiste : l10n.prdCategorieExiste) : _erreur,
            child: DsTextField(
              key: const ValueKey('categorie_nom'),
              controller: _nom,
              autofocus: true,
              indice: widget.sous ? l10n.prdSousCategorieIndice : l10n.prdCategorieIndice,
              onChanged: (_) => setState(() => _erreur = null),
            ),
          ),
          if (!widget.sous)
            DsFormRow(
              libelle: l10n.prdDescriptionChamp,
              alignerDebut: true,
              child: DsTextField(controller: _description, multiligne: true, lignes: 2),
            ),
          if (_edition)
            DsFormRow(
              libelle: l10n.retoursEtat,
              child: DsSwitch(
                valeur: _actif,
                libelle: l10n.prdVisibleCaisse,
                actif: !(widget.categorie?.systeme ?? widget.sousCategorie?.systeme ?? false),
                onChanged: (v) => setState(() => _actif = v),
              ),
            ),
        ],
      ),
    );
  }
}

/// Détail d'une catégorie (`EntityDetailDialog` 900 px) : stats et produits.
Future<void> afficherDetailCategorie(
  BuildContext context,
  WidgetRef ref,
  Categorie c, {
  VoidCallback? onModifier,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = (await ref.read(produitsProvider.future)).where((p) => p.categorieCode == c.code).toList();
  final sous = (await ref.read(sousCategoriesProvider.future)).where((s) => s.categorieCode == c.code).length;
  final stocks = await ref.read(stocksProduitsProvider.future);
  if (!context.mounted) return;
  final valeur = produits.fold(
    0.0,
    (s, p) => s + ((stocks[p.code] ?? 0) > 0 ? (stocks[p.code] ?? 0) * p.prixAchat : 0),
  );
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 900,
      icone: LucideIcons.folder,
      titre: c.nom,
      description: c.code,
      onModifier: onModifier,
      badges: [BadgeStatut(c.actif ? 'actif' : 'inactif')],
      stats: [
        DsStatItem(libelle: l10n.prdOngletSousCategories, valeur: '$sous', icone: LucideIcons.folderTree),
        DsStatItem(libelle: l10n.produitsOngletProduits, valeur: '${produits.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.prdKpiValeurStock, valeur: f2(valeur), suffixe: devise, icone: LucideIcons.wallet),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.produitsOngletProduits,
          icone: LucideIcons.package,
          nbLignes: produits.length,
          tableau: _tableProduits(l10n, produits, stocks, devise),
        ),
      ],
    ),
  );
}

Widget _tableProduits(AppLocalizations l10n, List<Produit> produits, Map<String, double> stocks, String devise) =>
    DsDataTable<Produit>(
      dense: true,
      encadre: false,
      pagine: false,
      reserveEcran: 360,
      cle: (p) => p.code,
      lignes: produits,
      messageVide: l10n.dsAucunElement,
      colonnes: [
        DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true),
        DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (p) => p.designation, fort: true, flex: 3),
        DsColonne(
          id: 'stock',
          libelle: l10n.produitsColStock,
          numerique: true,
          valeur: (p) => stocks[p.code] ?? 0,
          cellule: (_, p) => Text(formaterNombre(stocks[p.code] ?? 0)),
        ),
        DsColonne(
          id: 'vente',
          libelle: l10n.prdVente,
          numerique: true,
          valeur: (p) => p.prixVente,
          cellule: (_, p) => Text(formaterMontant(p.prixVente, devise)),
        ),
      ],
    );

/// Détail d'une sous-catégorie (`EntityDetailDialog` 800 px).
Future<void> afficherDetailSousCategorie(
  BuildContext context,
  SousCategorie s, {
  required String nomCategorie,
  required int nbProduits,
  VoidCallback? onModifier,
}) {
  final l10n = AppLocalizations.of(context);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 800,
      icone: LucideIcons.folderTree,
      titre: s.nom,
      description: '${s.code} · $nomCategorie',
      onModifier: onModifier,
      sections: [
        DsSectionDetail(
          titre: l10n.prdInformations,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.produitsColCode, s.code, mono: true),
            DsKeyValue(l10n.produitsColCategorie, nomCategorie),
            DsKeyValue(l10n.produitsOngletProduits, '$nbProduits'),
            DsKeyValue(l10n.retoursObservation, s.description, span: 3),
          ],
        ),
      ],
    ),
  );
}

/// Suppression en lot de catégories (la catégorie système est bloquée) : leurs produits passent dans
/// « Sans catégorie ».
Future<void> supprimerCategories(
  BuildContext context,
  WidgetRef ref,
  List<Categorie> choix,
  VoidCallback effacer, {
  required int Function(Categorie) nbProduits,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: l10n.prdEntiteCategorie,
    entitePluriel: l10n.prdEntiteCategories,
    elements: [
      for (final c in choix)
        DsElementLot(
          id: c.code,
          titre: c.nom,
          sousTitre: c.code,
          meta: nbProduits(c) > 0 ? l10n.prdVersSansCategorie(nbProduits(c)) : l10n.prdNProduits(0),
          motifBlocage: c.systeme ? l10n.categorieErreurSysteme : null,
        ),
    ],
  );
  if (ok == null) return;
  await ref.read(catalogueServiceProvider).supprimerCategories([
    for (final c in choix)
      if (!c.systeme) c.code,
  ]);
  rafraichirCatalogue(ref);
  effacer();
  if (context.mounted) afficherToast(context, titre: l10n.prdToastSuppression, ton: DsToastTon.succes);
}

/// Suppression en lot de sous-catégories (la sous-catégorie système est bloquée) : leurs produits passent dans
/// « Sans catégorie ».
Future<void> supprimerSousCategories(
  BuildContext context,
  WidgetRef ref,
  List<SousCategorie> choix,
  VoidCallback effacer, {
  required int Function(SousCategorie) nbProduits,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: l10n.prdEntiteSousCategorie,
    entitePluriel: l10n.prdEntiteSousCategories,
    elements: [
      for (final s in choix)
        DsElementLot(
          id: s.code,
          titre: s.nom,
          sousTitre: s.code,
          meta: nbProduits(s) > 0 ? l10n.prdVersSansCategorie(nbProduits(s)) : l10n.prdNProduits(0),
          motifBlocage: s.systeme ? l10n.categorieErreurSysteme : null,
        ),
    ],
  );
  if (ok == null) return;
  await ref.read(catalogueServiceProvider).supprimerSousCategories([
    for (final s in choix)
      if (!s.systeme) s.code,
  ]);
  rafraichirCatalogue(ref);
  effacer();
  if (context.mounted) afficherToast(context, titre: l10n.prdToastSuppression, ton: DsToastTon.succes);
}

// ============================================================ Remises

String libelleValeurRemise(Remise r, String devise) =>
    r.estPourcentage ? '− ${formaterNombre(r.valeur)} %' : '− ${formaterMontant(r.valeur, devise)}';

String libellePorteeRemise(AppLocalizations l10n, String portee) =>
    portee == Remise.porteeMontant ? l10n.prdPorteeMontant : l10n.prdPorteeProduit;

/// Statut d'une remise ; « enAttente » s'affiche « Programmée ».
class BadgeStatutRemise extends StatelessWidget {
  const BadgeStatutRemise(this.statut, {super.key});
  final String statut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return statut == 'enAttente' ? DsStatusBadge(statut: statut, libelle: l10n.prdProgrammee) : BadgeStatut(statut);
  }
}

/// Formulaire remise (`RemiseFormDialog`, `DocFormDialog` 980 px) : nom, type de taux (Pourcentage /
/// Montant fixe), valeur, période, type de remise (§8.9, en tête) et produits concernés (remise par produit).
/// Nouvelle remise, ou modification de [remise]. Une alerte produit propose les [proposes] et le [pourcentage]
/// conseillé.
Future<void> afficherFormulaireRemise(
  BuildContext context,
  WidgetRef ref, {
  Remise? remise,
  List<Produit> proposes = const [],
  double? pourcentage,
}) async {
  final produits = await ref.read(produitsProvider.future);
  if (!context.mounted) return;
  final lignes = remise == null
      ? [for (final p in proposes) LigneDoc(produit: p)]
      : [
          for (final p in produits)
            if (p.remiseCode == remise.code || p.code == remise.produitCode) LigneDoc(produit: p),
        ];
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _RemiseForm(remise, lignes, pourcentage: pourcentage),
  );
}

class _RemiseForm extends ConsumerStatefulWidget {
  const _RemiseForm(this.remise, this.lignesInitiales, {this.pourcentage});
  final Remise? remise;
  final List<LigneDoc> lignesInitiales;

  /// Pourcentage proposé à une nouvelle remise.
  final double? pourcentage;

  @override
  ConsumerState<_RemiseForm> createState() => _RemiseFormState();
}

class _RemiseFormState extends ConsumerState<_RemiseForm> {
  late final _nom = TextEditingController(text: widget.remise?.designation ?? '');
  late final _valeur = TextEditingController(
    text: widget.remise == null ? texteQuantite(widget.pourcentage ?? 10) : texteQuantite(widget.remise!.valeur),
  );
  late final _seuil = TextEditingController(text: widget.remise == null ? '' : texteQuantite(widget.remise!.seuil));
  late final _observation = TextEditingController(text: widget.remise?.observation ?? '');
  late String _type = widget.remise?.type ?? 'Pourcentage';
  late String _portee = widget.remise?.portee ?? Remise.porteeProduit;
  late DateTime? _du = widget.remise?.dateDebut ?? DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime? _au = widget.remise?.dateFin ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _valeur.dispose();
    _seuil.dispose();
    _observation.dispose();
    super.dispose();
  }

  double get _v => nombreSaisi(_valeur.text);
  bool get _pct => _type == 'Pourcentage';
  double _remise(Produit p) {
    final prix = ref.read(prixTtcProvider)(p);
    return _pct ? prix * (1 - _v / 100) : (prix - _v).clamp(0, double.infinity);
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final r = Remise(
      code: widget.remise?.code ?? '',
      designation: _nom.text.trim(),
      type: _type,
      valeur: _v,
      dateDebut: _du,
      dateFin: _au == null ? null : DateTime(_au!.year, _au!.month, _au!.day, 23, 59, 59),
      actif: widget.remise?.actif ?? true,
      observation: _observation.text.trim().isEmpty ? null : _observation.text.trim(),
      portee: _portee,
      seuil: _portee == Remise.porteeMontant ? nombreSaisi(_seuil.text) : 0,
    );
    final codes = [for (final l in _lignes) l.produit.code];
    final s = ref.read(catalogueServiceProvider);
    try {
      if (widget.remise == null) {
        await s.creerRemise(r, produits: codes);
      } else {
        await s.modifierRemise(r, produits: codes);
      }
      rafraichirCatalogue(ref);
      if (mounted) {
        afficherToast(
          context,
          titre: l10n.prdToastRemise,
          description: l10n.prdToastRemiseDesc,
          ton: DsToastTon.succes,
        );
      }
      return true;
    } on CatalogueException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCatalogue(l10n, e.erreur));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final parMontant = _portee == Remise.porteeMontant;
    const lw = 112.0;
    return DocFormDialog(
      titre: widget.remise == null ? l10n.remiseNouvelle : l10n.prdModifierRemise,
      icone: LucideIcons.percent,
      largeur: 980,
      cleEnregistrer: const ValueKey('remise_enregistrer'),
      lignes: parMontant ? const [] : _lignes,
      sansLignes: parMontant,
      onLignes: (l) => setState(() => _lignes = l),
      peutEnregistrer: _v > 0 && _nom.text.trim().isNotEmpty && _du != null && _au != null,
      titreSelecteur: l10n.prdProduitsConcernes,
      titreLignes: l10n.prdProduitsConcernes,
      iconeLignes: LucideIcons.package,
      prixVenteSelecteur: true,
      libelleTotal: l10n.prdRemiseAccordee,
      onEnregistrer: _enregistrer,
      totalLigne: (l) => ref.read(prixTtcProvider)(l.produit) - _remise(l.produit),
      colonnes: [
        DsColonneLigne(
          id: 'code',
          libelle: l10n.produitsColCode,
          valeur: (l) => l.produit.code,
          attenue: true,
          largeur: 110,
        ),
        DsColonneLigne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.produit.designation, fort: true),
        DsColonneLigne(
          id: 'vente',
          libelle: l10n.prdPrixNormal,
          numerique: true,
          valeur: (l) => formaterMontant(ref.read(prixTtcProvider)(l.produit), devise),
        ),
        DsColonneLigne(
          id: 'pr',
          libelle: l10n.prdPrixRemise,
          numerique: true,
          valeur: (l) => formaterMontant(_remise(l.produit), devise),
          cellule: (context, l) => Text(
            formaterMontant(_remise(l.produit), devise),
            style: context.ds.typo.bodySm.copyWith(color: context.ds.colors.successFg, fontWeight: FontWeight.w600),
          ),
        ),
      ],
      entete: [
        // Type de remise en premier : il décide de la suite du formulaire (produits ou seuil du panier).
        DsSpan(child: DsSubHead(l10n.remiseSectionType, icone: LucideIcons.layers)),
        DsSpan(
          child: DsChoiceCards<String>(
            key: const ValueKey('remise_portee'),
            petit: true,
            valeur: _portee,
            onChanged: (v) => setState(() => _portee = v),
            options: [
              DsOption(
                Remise.porteeProduit,
                libelle: l10n.prdPorteeProduit,
                icone: LucideIcons.package,
                description: l10n.prdPorteeProduitAide,
              ),
              DsOption(
                Remise.porteeMontant,
                libelle: l10n.prdPorteeMontant,
                icone: LucideIcons.shoppingCart,
                description: l10n.prdPorteeMontantAide,
              ),
            ],
          ),
        ),
        DsSpan(child: DsSubHead(l10n.remiseSectionInfos, icone: LucideIcons.info)),
        if (widget.remise != null)
          DsFormRow(
            libelle: l10n.produitsColCode,
            largeurLibelle: lw,
            child: DsTextField(valeurInitiale: widget.remise?.code ?? l10n.prdCodeAuto, actif: false),
          ),
        DsFormRow(
          libelle: l10n.categorieNom,
          obligatoire: true,
          largeurLibelle: lw,
          erreur: _erreur,
          child: DsTextField(
            key: const ValueKey('remise_nom'),
            controller: _nom,
            autofocus: true,
            indice: l10n.prdRemiseNomIndice,
            onChanged: (_) => setState(() => _erreur = null),
          ),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.retoursObservation,
            largeurLibelle: lw,
            child: DsTextField(key: const ValueKey('remise_observation'), controller: _observation),
          ),
        ),
        DsSpan(child: DsSubHead(l10n.remiseSectionCalcul, icone: LucideIcons.calculator)),
        DsSpan(
          child: DsChoiceCards<String>(
            key: const ValueKey('remise_type_taux'),
            petit: true,
            valeur: _type,
            onChanged: (v) => setState(() => _type = v),
            options: [
              DsOption(
                'Pourcentage',
                libelle: libelleRef(context, Referentiel.typesCalcul, 'Pourcentage'),
                icone: LucideIcons.percent,
                description: l10n.prdPourcentageAide,
              ),
              DsOption(
                'Montant',
                libelle: l10n.prdMontantFixe,
                icone: LucideIcons.banknote,
                description: parMontant ? l10n.prdMontantPanierAide(devise) : l10n.prdMontantFixeAide(devise),
              ),
            ],
          ),
        ),
        DsFormRow(
          libelle: l10n.remiseValeur,
          obligatoire: true,
          largeurLibelle: lw,
          child: DsTextField(
            key: const ValueKey('remise_valeur'),
            controller: _valeur,
            numerique: true,
            suffixeTexte: _pct ? '%' : devise,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (parMontant)
          DsFormRow(
            libelle: l10n.prdSeuilMontant,
            largeurLibelle: lw,
            aide: l10n.prdSeuilAide,
            child: DsTextField(
              key: const ValueKey('remise_seuil'),
              controller: _seuil,
              numerique: true,
              suffixeTexte: devise,
            ),
          )
        else
          const SizedBox.shrink(),
        DsSpan(child: DsSubHead(l10n.remiseSectionPeriode, icone: LucideIcons.calendarRange)),
        DsFormRow(
          libelle: l10n.dsDu,
          obligatoire: true,
          largeurLibelle: lw,
          child: DsDateField(valeur: _du, onChanged: (d) => setState(() => _du = d)),
        ),
        DsFormRow(
          libelle: l10n.dsAu,
          obligatoire: true,
          largeurLibelle: lw,
          child: DsDateField(valeur: _au, min: _du, onChanged: (d) => setState(() => _au = d)),
        ),
      ],
    );
  }
}

/// Détail d'une remise (`EntityDetailDialog` 980 px) : valeur, produits, ventes remisées.
Future<void> afficherDetailRemise(BuildContext context, WidgetRef ref, Remise r, {VoidCallback? onModifier}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = (await ref.read(produitsProvider.future))
      .where((p) => p.remiseCode == r.code || p.code == r.produitCode)
      .toList();
  final ventes = await ref.read(catalogueRepositoryProvider).statsRemise(r.code);
  if (!context.mounted) return;
  final statut = r.statut(DateTime.now());
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 980,
      icone: LucideIcons.percent,
      titre: r.designation,
      description: '${r.code} · ${dateOuTiret(r.dateDebut)} → ${dateOuTiret(r.dateFin)}',
      badges: [
        BadgeStatutRemise(statut),
        DsBadge(libelle: libellePorteeRemise(l10n, r.portee), ton: DsBadgeTon.info),
      ],
      onModifier: onModifier,
      stats: [
        DsStatItem(libelle: l10n.remiseValeur, valeur: libelleValeurRemise(r, devise), icone: LucideIcons.percent),
        DsStatItem(libelle: l10n.produitsOngletProduits, valeur: '${produits.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.prdVentesRemisees, valeur: '${ventes.nombre}', icone: LucideIcons.receipt),
        DsStatItem(
          libelle: l10n.prdRemiseAccordee,
          valeur: f2(ventes.montant),
          suffixe: devise,
          icone: LucideIcons.handCoins,
          ton: DsBadgeTon.avertissement,
        ),
      ],
      sections: [
        if (!r.parMontant)
          DsSectionDetail(
            titre: l10n.prdProduitsConcernes,
            icone: LucideIcons.package,
            nbLignes: produits.length,
            tableau: DsDataTable<Produit>(
              dense: true,
              encadre: false,
              pagine: false,
              reserveEcran: 360,
              cle: (p) => p.code,
              lignes: produits,
              messageVide: l10n.dsAucunElement,
              colonnes: [
                DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true),
                DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (p) => p.designation, fort: true, flex: 3),
                DsColonne(
                  id: 'vente',
                  libelle: l10n.prdPrixNormal,
                  numerique: true,
                  valeur: (p) => ref.read(prixTtcProvider)(p),
                  cellule: (_, p) => Text(formaterMontant(ref.read(prixTtcProvider)(p), devise)),
                ),
                DsColonne(
                  id: 'r',
                  libelle: l10n.prdPrixRemise,
                  numerique: true,
                  valeur: (p) => r.appliquer(ref.read(prixTtcProvider)(p)),
                  cellule: (_, p) => Text(formaterMontant(r.appliquer(ref.read(prixTtcProvider)(p)), devise)),
                ),
              ],
            ),
          )
        else
          DsSectionDetail(
            titre: l10n.prdInformations,
            icone: LucideIcons.info,
            items: [
              DsKeyValue(l10n.remiseType, libellePorteeRemise(l10n, r.portee)),
              DsKeyValue(l10n.prdSeuilMontant, formaterMontant(r.seuil, devise)),
              DsKeyValue(l10n.retoursObservation, r.observation, span: 3),
            ],
          ),
      ],
    ),
  );
}

/// Suppression en lot de remises : les produits qui la portaient n'ont plus de remise.
Future<void> supprimerRemises(
  BuildContext context,
  WidgetRef ref,
  List<Remise> choix,
  VoidCallback effacer, {
  required int Function(Remise) nbProduits,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: l10n.prdEntiteRemise,
    entitePluriel: l10n.prdEntiteRemises,
    elements: [
      for (final r in choix)
        DsElementLot(id: r.code, titre: r.designation, sousTitre: r.code, meta: l10n.prdNProduits(nbProduits(r))),
    ],
  );
  if (ok == null) return;
  await ref.read(catalogueServiceProvider).supprimerRemises([for (final r in choix) r.code]);
  rafraichirCatalogue(ref);
  effacer();
  if (context.mounted) afficherToast(context, titre: l10n.prdToastSuppression, ton: DsToastTon.succes);
}

// ============================================================ Packs

/// Valeur des composants vendus séparément, au [prix] TTC de chacun.
double valeurSeparee(Pack k, Map<String, Produit> produits, double Function(Produit) prix) => k.lignes.fold(
  0.0,
  (s, l) => s + (produits[l.produitCode] == null ? 0 : prix(produits[l.produitCode]!)) * l.quantite,
);

/// Packs possibles selon le stock du composant le plus limitant.
int packsPossibles(Pack k, Map<String, double> stocks) {
  if (k.lignes.isEmpty) return 0;
  return k.lignes
      .map((l) => ((stocks[l.produitCode] ?? 0) / (l.quantite <= 0 ? 1 : l.quantite)).floor())
      .reduce((a, b) => a < b ? a : b)
      .clamp(0, 1 << 31);
}

/// Formulaire pack (`PackFormDialog`, `DocFormDialog` 940 px) : code-barres, nom, prix, composants.
/// Nouveau pack (avec les [proposes] d'une alerte « Achetés ensemble »), ou modification de [pack].
Future<void> afficherFormulairePack(
  BuildContext context,
  WidgetRef ref, {
  Pack? pack,
  List<Produit> proposes = const [],
}) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  if (!context.mounted) return;
  final lignes = [
    for (final l in pack?.lignes ?? const <PackLigne>[])
      if (produits[l.produitCode] != null) LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite.toDouble()),
    if (pack == null)
      for (final p in proposes) LigneDoc(produit: p),
  ];
  await afficherDialog<bool>(context, fermableParVoile: false, builder: (_) => _PackForm(pack, lignes));
}

class _PackForm extends ConsumerStatefulWidget {
  const _PackForm(this.pack, this.lignesInitiales);
  final Pack? pack;
  final List<LigneDoc> lignesInitiales;

  @override
  ConsumerState<_PackForm> createState() => _PackFormState();
}

class _PackFormState extends ConsumerState<_PackForm> {
  late final _nom = TextEditingController(text: widget.pack?.designation ?? '');
  late final _codeBarres = TextEditingController(text: widget.pack?.codeBarres ?? '');
  late final _prix = TextEditingController(text: widget.pack == null ? '' : texteQuantite(widget.pack!.prixVente));
  late final _description = TextEditingController(text: widget.pack?.description ?? '');
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _codeBarres.dispose();
    _prix.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final cb = _codeBarres.text.trim();
    final pack = Pack(
      code: widget.pack?.code ?? '',
      designation: _nom.text.trim(),
      codeBarres: cb.isEmpty ? null : cb,
      prixVente: nombreSaisi(_prix.text),
      actif: widget.pack?.actif ?? true,
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      lignes: [for (final l in _lignes) PackLigne(produitCode: l.produit.code, quantite: l.quantite.round())],
    );
    final s = ref.read(catalogueServiceProvider);
    try {
      if (widget.pack == null) {
        await s.creerPack(pack);
      } else {
        await s.modifierPack(pack);
      }
      rafraichirCatalogue(ref);
      if (mounted) afficherToast(context, titre: l10n.prdToastPack, ton: DsToastTon.succes);
      return true;
    } on CatalogueException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCatalogue(l10n, e.erreur));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final stocks = ref.watch(stocksProduitsProvider).value ?? const <String, double>{};
    final valeur = _lignes.fold(0.0, (s, l) => s + l.quantite * ref.read(prixTtcProvider)(l.produit));
    final prix = nombreSaisi(_prix.text);
    final eco = valeur - prix;
    final dispo = _lignes.isEmpty
        ? 0
        : _lignes
              .map((l) => ((stocks[l.produit.code] ?? 0) / (l.quantite <= 0 ? 1 : l.quantite)).floor())
              .reduce((a, b) => a < b ? a : b)
              .clamp(0, 1 << 31);
    const lw = 112.0;
    final erreurs = <Object, Map<String, String>>{
      for (final l in _lignes)
        if (l.quantite <= 0) l.produit.code: {'qte': l10n.produitErreurQuantite},
    };
    return DocFormDialog(
      titre: widget.pack == null ? l10n.packNouveau : l10n.prdModifierPack,
      icone: LucideIcons.gift,
      largeur: 940,
      cleEnregistrer: const ValueKey('pack_enregistrer'),
      libelleEnregistrer: l10n.prdEnregistrerPack,
      lignes: _lignes,
      onLignes: (l) => setState(() => _lignes = l),
      erreurs: erreurs,
      peutEnregistrer: prix > 0 && _nom.text.trim().isNotEmpty,
      titreSelecteur: l10n.prdComposantsPack,
      prixVenteSelecteur: true,
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * ref.read(prixTtcProvider)(l.produit),
      colonnes: [
        DsColonneLigne(
          id: 'code',
          libelle: l10n.produitsColCode,
          valeur: (l) => l.produit.code,
          attenue: true,
          largeur: 110,
        ),
        DsColonneLigne(id: 'nom', libelle: l10n.prdComposant, valeur: (l) => l.produit.designation, fort: true),
        DsColonneLigne(
          id: 'stock',
          libelle: l10n.produitsColStock,
          numerique: true,
          largeur: 80,
          valeur: (l) => formaterNombre(stocks[l.produit.code] ?? 0),
        ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.prdQteParPack,
          numerique: true,
          editable: true,
          largeur: 100,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'vente',
          libelle: l10n.prdPrixUnitaire,
          numerique: true,
          valeur: (l) => formaterMontant(ref.read(prixTtcProvider)(l.produit), devise),
        ),
      ],
      entete: [
        if (widget.pack != null)
          DsFormRow(
            libelle: l10n.produitsColCode,
            largeurLibelle: lw,
            child: DsTextField(valeurInitiale: widget.pack?.code ?? l10n.prdCodeAuto, actif: false),
          ),
        DsFormRow(
          libelle: l10n.produitsColCodeBarres,
          largeurLibelle: lw,
          child: DsTextField(controller: _codeBarres, iconePrefixe: LucideIcons.barcode, indice: l10n.prdOptionnel),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.prdNomPack,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _erreur,
            child: DsTextField(
              key: const ValueKey('pack_nom'),
              controller: _nom,
              autofocus: true,
              indice: l10n.prdPackNomIndice,
              onChanged: (_) => setState(() => _erreur = null),
            ),
          ),
        ),
        DsFormRow(
          libelle: l10n.prdPrixPack,
          obligatoire: true,
          largeurLibelle: lw,
          child: DsTextField(
            key: const ValueKey('pack_prix'),
            controller: _prix,
            numerique: true,
            suffixeTexte: devise,
            onChanged: (_) => setState(() {}),
          ),
        ),
        DsFormRow(
          libelle: l10n.prdPacksPossibles,
          largeurLibelle: lw,
          aide: l10n.prdPacksPossiblesAide,
          child: DsTextField(key: ValueKey('pack_dispo_$dispo'), valeurInitiale: '$dispo', actif: false),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.prdDescriptionChamp,
            largeurLibelle: lw,
            alignerDebut: true,
            child: DsTextField(controller: _description, multiligne: true, lignes: 2),
          ),
        ),
      ],
      apres: prix > 0
          ? Container(
              key: const ValueKey('pack_economie'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: eco >= 0 ? c.successTint : c.dangerTint,
                borderRadius: DsRadius.borderMd,
              ),
              child: Row(
                spacing: 10,
                children: [
                  Icon(
                    eco >= 0 ? LucideIcons.piggyBank : LucideIcons.circleAlert,
                    size: 18,
                    color: eco >= 0 ? c.successFg : c.dangerFg,
                  ),
                  Expanded(
                    child: Text(
                      '${eco >= 0 ? l10n.prdEconomieClient : l10n.prdPackPlusCher} · '
                      '${l10n.prdValeurSepareeMontant(formaterMontant(valeur, devise))}',
                      style: t.bodySm.copyWith(fontWeight: FontWeight.w600, color: eco >= 0 ? c.successFg : c.dangerFg),
                    ),
                  ),
                  Text(
                    formaterMontant(eco.abs(), devise),
                    style: t.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: eco >= 0 ? c.successFg : c.dangerFg,
                      fontFeatures: DsTypography.tabular,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

/// Détail d'un pack (`EntityDetailDialog` 980 px) : composants, valeur séparée, économie, packs possibles.
Future<void> afficherDetailPack(BuildContext context, WidgetRef ref, Pack k, {VoidCallback? onModifier}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final stocks = await ref.read(stocksProduitsProvider.future);
  if (!context.mounted) return;
  final valeur = valeurSeparee(k, produits, ref.read(prixTtcProvider));
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 980,
      icone: LucideIcons.gift,
      titre: k.designation,
      description: k.code,
      badges: [BadgeStatut(k.actif ? 'actif' : 'inactif')],
      onModifier: onModifier,
      stats: [
        DsStatItem(libelle: l10n.prdComposants, valeur: '${k.lignes.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.prdValeurSeparee, valeur: f2(valeur), suffixe: devise, icone: LucideIcons.calculator),
        DsStatItem(libelle: l10n.prdPrixPack, valeur: f2(k.prixVente), suffixe: devise, icone: LucideIcons.tag),
        DsStatItem(
          libelle: l10n.prdEconomieClient,
          valeur: f2(valeur - k.prixVente),
          suffixe: devise,
          icone: LucideIcons.piggyBank,
          ton: DsBadgeTon.succes,
        ),
        DsStatItem(libelle: l10n.prdPacksPossibles, valeur: '${packsPossibles(k, stocks)}', icone: LucideIcons.boxes),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.prdComposants,
          icone: LucideIcons.package,
          nbLignes: k.lignes.length,
          tableau: DsDataTable<PackLigne>(
            dense: true,
            encadre: false,
            pagine: false,
            cle: (l) => l.produitCode,
            lignes: k.lignes,
            messageVide: l10n.dsAucunElement,
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
              DsColonne(
                id: 'nom',
                libelle: l10n.prdComposant,
                valeur: (l) => produits[l.produitCode]?.designation ?? '',
                fort: true,
                flex: 3,
              ),
              DsColonne(
                id: 'q',
                libelle: l10n.prdQteParPack,
                numerique: true,
                valeur: (l) => l.quantite,
                cellule: (_, l) => Text(formaterNombre(l.quantite.toDouble())),
              ),
              DsColonne(
                id: 's',
                libelle: l10n.produitsColStock,
                numerique: true,
                valeur: (l) => stocks[l.produitCode] ?? 0,
                cellule: (_, l) => Text(formaterNombre(stocks[l.produitCode] ?? 0)),
              ),
              DsColonne(
                id: 'v',
                libelle: l10n.prdValeur,
                numerique: true,
                valeur: (l) =>
                    (produits[l.produitCode] == null ? 0 : ref.read(prixTtcProvider)(produits[l.produitCode]!)) *
                    l.quantite,
                cellule: (_, l) =>
                    Text(formaterMontant((produits[l.produitCode]?.prixVente ?? 0) * l.quantite, devise)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Suppression en lot de packs ; un pack déjà vendu est bloqué (ventes scellées).
Future<void> supprimerPacks(BuildContext context, WidgetRef ref, List<Pack> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(catalogueServiceProvider);
  final vendus = await service.packsVendus();
  if (!context.mounted) return;
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: l10n.prdEntitePack,
    entitePluriel: l10n.prdEntitePacks,
    elements: [
      for (final k in choix)
        DsElementLot(
          id: k.code,
          titre: k.designation,
          sousTitre: k.code,
          meta: l10n.prdNComposants(k.lignes.length),
          motifBlocage: vendus.contains(k.code) ? l10n.prdPackVendu : null,
        ),
    ],
  );
  if (ok == null) return;
  await service.supprimerPacks([
    for (final k in choix)
      if (!vendus.contains(k.code)) k.code,
  ]);
  rafraichirCatalogue(ref);
  effacer();
  if (context.mounted) afficherToast(context, titre: l10n.prdToastSuppression, ton: DsToastTon.succes);
}
