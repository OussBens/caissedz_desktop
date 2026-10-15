import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import 'catalogue_dialogs.dart';
import 'produit_dialogs.dart';
import 'produit_form_dialog.dart';
import 'produits_donnees.dart';
import 'produits_providers.dart';

/// Écran Produits (`ProduitsScreen` du DS v2.2) : onglets Produits · Catégories · Sous-catégories ·
/// Remises · Packs (avec compteurs), chacun en `ModuleTable` (KPIs, filtres, actions, export).
class ProduitsPage extends ConsumerStatefulWidget {
  const ProduitsPage({super.key, this.ongletInitial = 0});

  /// 0 produits, 1 catégories, 2 sous-catégories, 3 remises, 4 packs.
  final int ongletInitial;

  @override
  ConsumerState<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends ConsumerState<ProduitsPage> {
  late int _onglet = widget.ongletInitial;

  // Filtres de l'onglet Produits.
  String? _categorie;
  String? _etat;
  DsIntervalle _prix = const DsIntervalle();
  DsIntervalle _prixAchat = const DsIntervalle();
  DsIntervalle _quantite = const DsIntervalle();
  String? _marque;

  // Filtre de l'onglet Sous-catégories.
  String? _categorieSc;

  void _reinitialiser() => setState(() {
    _categorie = null;
    _etat = null;
    _prix = const DsIntervalle();
    _prixAchat = const DsIntervalle();
    _quantite = const DsIntervalle();
    _marque = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final produits = ref.watch(produitsProvider).value ?? const <Produit>[];
    final categories = ref.watch(categoriesProvider).value ?? const <Categorie>[];
    final sous = ref.watch(sousCategoriesProvider).value ?? const <SousCategorie>[];
    final remises = ref.watch(remisesProvider).value ?? const <Remise>[];
    final packs = ref.watch(packsProvider).value ?? const <Pack>[];
    return PageModule(
      moduleId: 'produits',
      sousTitre: l10n.prdDescription,
      onglets: [
        l10n.produitsOngletProduits,
        l10n.produitsOngletCategories,
        l10n.prdOngletSousCategories,
        l10n.produitsOngletRemises,
        l10n.produitsOngletPacks,
      ],
      comptes: [produits.length, categories.length, sous.length, remises.length, packs.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: switch (_onglet) {
        0 => _produits(l10n, produits, categories, sous, remises),
        1 => _categories(l10n, produits, categories, sous),
        2 => _sousCategories(l10n, produits, categories, sous),
        3 => _remises(l10n, produits, remises),
        _ => _packs(l10n, produits, packs),
      },
    );
  }

  // ---------------------------------------------------------------- Produits
  Widget _produits(
    AppLocalizations l10n,
    List<Produit> tous,
    List<Categorie> categories,
    List<SousCategorie> sous,
    List<Remise> remises,
  ) {
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final stocks = ref.watch(stocksProduitsProvider).value ?? const <String, double>{};
    final seuilGlobal = ref.watch(parametresVenteProvider).value?.seuilStockGlobal ?? 5;
    final colis = ref.watch(colisProvider).value ?? const <Colis>[];
    final nbCodes = ref.watch(nbCodesSecondairesProvider).value ?? const <String, int>{};
    final nbPhotos = ref.watch(nbPhotosProvider).value ?? const <String, int>{};
    final nomsCat = {for (final c in categories) c.code: c.nom};
    final nomsSc = {for (final s in sous) s.code: s.nom};
    final nomsRem = {for (final r in remises) r.code: r.designation};
    double stock(Produit p) => stocks[p.code] ?? 0;
    String etat(Produit p) => etatStockProduit(p, stock(p), seuilGlobal);
    List<Colis> emb(Produit p) =>
        (colis.where((c) => c.produitCode == p.code && c.actif).toList()..sort((a, b) => a.quantite - b.quantite));
    String embLib(Produit p, int i) {
      final e = emb(p);
      return i < e.length ? l10n.prdEmballagePieces(e[i].quantite) : '';
    }

    double embPrix(Produit p, int i) {
      final e = emb(p);
      return i < e.length ? e[i].prixVente : 0;
    }

    final marques = {
      for (final p in tous)
        if ((p.marque ?? '').isNotEmpty) p.marque!,
    }.toList()..sort();
    final lignes = tous
        .where(
          (p) =>
              (_categorie == null || p.categorieCode == _categorie) &&
              (_marque == null || p.marque == _marque) &&
              (_prix.min == null || p.prixVente >= _prix.min!) &&
              (_prix.max == null || p.prixVente <= _prix.max!) &&
              (_prixAchat.min == null || p.prixAchat >= _prixAchat.min!) &&
              (_prixAchat.max == null || p.prixAchat <= _prixAchat.max!) &&
              (_quantite.min == null || stock(p) >= _quantite.min!) &&
              (_quantite.max == null || stock(p) <= _quantite.max!) &&
              switch (_etat) {
                'rupture' => !p.service && stock(p) <= 0,
                'seuil' => etat(p) == 'seuil',
                'disponible' => p.service || stock(p) > seuilDe(p, seuilGlobal),
                _ => true,
              },
        )
        .toList();
    final actifs = tous.where((p) => p.actif).toList();
    final valeur = actifs.fold(0.0, (s, p) => s + (stock(p) > 0 ? stock(p) * p.prixAchat : 0));
    final voirAchat = permissionsSession(ref).contains(Permission.voirPrixAchat.code);

    final colonnes = <DsColonne<Produit>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.produitsColDesignation, valeur: (p) => p.designation, fort: true, flex: 3),
      DsColonne(id: 'cat', libelle: l10n.produitsColCategorie, valeur: (p) => nomsCat[p.categorieCode] ?? '', flex: 2),
      DsColonne(id: 'marque', libelle: l10n.prdMarque, valeur: (p) => p.marque ?? ''),
      DsColonne(
        id: 'stock',
        libelle: l10n.produitsColStock,
        numerique: true,
        valeur: stock,
        cellule: (context, p) => Text(
          p.service ? '—' : formaterNombre(stock(p)),
          style: context.ds.typo.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: switch (etat(p)) {
              'rupture' => context.ds.colors.dangerFg,
              'seuil' => context.ds.colors.warningFg,
              _ => context.ds.colors.textPrimary,
            },
          ),
        ),
        total: (ps) => formaterNombre(ps.fold(0.0, (s, p) => s + (p.service ? 0 : stock(p)))),
      ),
      DsColonne(
        id: 'achat',
        libelle: l10n.prdAchat,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: (p) => p.prixAchat,
        cellule: (_, p) => Text(da(p.prixAchat)),
      ),
      DsColonne(
        id: 'vente',
        libelle: l10n.prdVente,
        numerique: true,
        valeur: (p) => p.prixVente,
        cellule: (_, p) => Text(da(p.prixVente)),
      ),
      DsColonne(
        id: 'marge',
        libelle: l10n.prdMarge,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: margeProduit,
        cellule: (_, p) => Text('${margeProduit(p).round()} %'),
      ),
      DsColonne(id: 'etat', libelle: l10n.retoursEtat, valeur: etat, cellule: (_, p) => BadgeStatut(etat(p))),
      DsColonne(
        id: 'description',
        libelle: l10n.prdDescriptionChamp,
        visibleParDefaut: false,
        valeur: (p) => p.description ?? '',
      ),
      DsColonne(id: 'taille', libelle: l10n.prdTaille, visibleParDefaut: false, valeur: (p) => p.taille ?? ''),
      DsColonne(id: 'couleur', libelle: l10n.prdCouleur, visibleParDefaut: false, valeur: (p) => p.couleur ?? ''),
      DsColonne(
        id: 'sousCat',
        libelle: l10n.produitChampSousCategorie,
        visibleParDefaut: false,
        valeur: (p) => nomsSc[p.sousCategorieCode] ?? '',
      ),
      DsColonne(
        id: 'remise',
        libelle: l10n.prdRemise,
        visibleParDefaut: false,
        valeur: (p) => nomsRem[p.remiseCode] ?? '',
      ),
      DsColonne(
        id: 'service',
        libelle: l10n.prdService,
        visibleParDefaut: false,
        valeur: (p) => p.service ? 1 : 0,
        cellule: (_, p) => Text(p.service ? l10n.communOui : l10n.communNon),
      ),
      DsColonne(
        id: 'unite',
        libelle: l10n.produitChampUnite,
        visibleParDefaut: false,
        valeur: (p) => libelleRef(context, Referentiel.unitesMesure, p.unite),
      ),
      DsColonne(id: 'emb1', libelle: l10n.prdEmballageN(1), visibleParDefaut: false, valeur: (p) => embLib(p, 0)),
      DsColonne(
        id: 'embP1',
        libelle: l10n.prdPrixEmballageN(1),
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => embPrix(p, 0),
        cellule: (_, p) => Text(embLib(p, 0).isEmpty ? '' : da(embPrix(p, 0))),
      ),
      DsColonne(id: 'emb2', libelle: l10n.prdEmballageN(2), visibleParDefaut: false, valeur: (p) => embLib(p, 1)),
      DsColonne(
        id: 'embP2',
        libelle: l10n.prdPrixEmballageN(2),
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => embPrix(p, 1),
        cellule: (_, p) => Text(embLib(p, 1).isEmpty ? '' : da(embPrix(p, 1))),
      ),
      DsColonne(
        id: 'codeBarre',
        libelle: l10n.produitsColCodeBarres,
        visibleParDefaut: false,
        attenue: true,
        mono: true,
        valeur: (p) => p.codeBarres ?? '',
      ),
      DsColonne(
        id: 'numeroSerie',
        libelle: l10n.prdNumeroSerie,
        visibleParDefaut: false,
        valeur: (p) => p.suiviSerie ? 1 : 0,
        cellule: (_, p) => Text(p.suiviSerie ? l10n.communOui : l10n.communNon),
      ),
      DsColonne(
        id: 'multicode',
        libelle: l10n.prdMultiCodes,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => nbCodes[p.code] ?? 0,
      ),
      DsColonne(
        id: 'photos',
        libelle: l10n.prdPhotos,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => nbPhotos[p.code] ?? 0,
      ),
      DsColonne(
        id: 'tva',
        libelle: l10n.prdTva,
        numerique: true,
        visibleParDefaut: false,
        valeur: (p) => p.tvaPct,
        cellule: (_, p) => Text('${formaterNombre(p.tvaPct)} %'),
      ),
      DsColonne(
        id: 'expiration',
        libelle: l10n.prdDateExpiration,
        visibleParDefaut: false,
        attenue: true,
        valeur: (p) => p.dateExpiration,
        cellule: (_, p) => Text(dateOuTiret(p.dateExpiration)),
      ),
      ...colonnesAudit(context, ref, (Produit x) => x.audit),
    ];

    Future<void> modifier(Produit p) => afficherFormulaireProduit(context, produit: p, detaille: true);
    Future<void> etiquette(Produit p) => afficherCodeBarre(context, p);
    Future<void> detail(Produit p) =>
        afficherDetailProduit(context, ref, p, onModifier: () => modifier(p), onEtiquette: () => etiquette(p));

    return DsModuleTable<Produit>(
      key: const ValueKey('produits_produits'),
      entite: l10n.prdEntiteProduits,
      lignes: lignes,
      colonnes: colonnes,
      cle: (p) => p.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.produitsAucun,
      filtresOuverts: true,
      colonnesFiltres: 4,
      nbFiltresActifs:
          [_categorie, _etat, _marque].where((f) => f != null).length +
          [_prix, _prixAchat, _quantite].where((i) => !i.estVide).length,
      onReinitialiser: _reinitialiser,
      kpis: [
        DsStatCard(libelle: l10n.prdKpiActifs, valeur: '${actifs.length}', icone: LucideIcons.package),
        if (voirAchat)
          DsStatCard(libelle: l10n.prdKpiValeurStock, valeur: f2(valeur), suffixe: devise, icone: LucideIcons.wallet),
        DsStatCard(
          libelle: l10n.prdKpiSousSeuil,
          valeur: '${actifs.where((p) => etat(p) == 'seuil').length}',
          icone: LucideIcons.triangleAlert,
          ton: DsBadgeTon.avertissement,
        ),
        DsStatCard(
          libelle: l10n.prdKpiRupture,
          valeur: '${actifs.where((p) => etat(p) == 'rupture').length}',
          icone: LucideIcons.circleX,
          ton: DsBadgeTon.danger,
        ),
      ],
      filtres: [
        DsFormRow(
          libelle: l10n.produitsColCategorie,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            key: const ValueKey('filtre_categorie'),
            valeur: _categorie,
            options: [null, for (final c in categories) c.code],
            libelle: (c) => c == null ? l10n.prdToutes : (nomsCat[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.categorie),
            onChanged: (v) => setState(() => _categorie = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.produitsColStock,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            key: const ValueKey('filtre_stock'),
            valeur: _etat,
            options: const [null, 'disponible', 'seuil', 'rupture'],
            libelle: (e) => switch (e) {
              'disponible' => l10n.prdDisponible,
              'seuil' => l10n.prdKpiSousSeuil,
              'rupture' => l10n.statutRupture,
              _ => l10n.retoursTous,
            },
            onChanged: (v) => setState(() => _etat = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.produitsColPrixVente,
          largeurLibelle: 90,
          child: DsRangeFilter(
            valeur: _prix,
            unite: devise,
            libelleEffacer: l10n.dsEffacer,
            libelleValider: l10n.communValider,
            onChanged: (v) => setState(() => _prix = v),
          ),
        ),
        if (voirAchat)
          DsFormRow(
            libelle: l10n.produitsColPrixAchat,
            largeurLibelle: 90,
            child: DsRangeFilter(
              key: const ValueKey('filtre_prix_achat'),
              valeur: _prixAchat,
              unite: devise,
              libelleEffacer: l10n.dsEffacer,
              libelleValider: l10n.communValider,
              onChanged: (v) => setState(() => _prixAchat = v),
            ),
          ),
        DsFormRow(
          libelle: l10n.prdFiltreQuantite,
          largeurLibelle: 90,
          child: DsRangeFilter(
            key: const ValueKey('filtre_quantite'),
            valeur: _quantite,
            libelleEffacer: l10n.dsEffacer,
            libelleValider: l10n.communValider,
            onChanged: (v) => setState(() => _quantite = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.prdMarque,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            valeur: _marque,
            options: [null, ...marques],
            libelle: (m) => m ?? l10n.prdToutes,
            onChanged: (v) => setState(() => _marque = v),
          ),
        ),
      ],
      indiceRecherche: l10n.prdRechercheProduits,
      texteRecherche: (p) => '${p.code} ${p.designation} ${p.codeBarres ?? ''} ${p.marque ?? ''}',
      onExport: peutExporter(ref)
          ? (format, ps) => exporterTableau(
              context,
              ref,
              id: 'produits',
              titre: l10n.produitsOngletProduits,
              colonnes: colonnes,
              lignes: ps,
              format: format,
            )
          : null,
      carte: (context, p, etatCarte) => _CarteProduit(
        produit: p,
        categorie: nomsCat[p.categorieCode] ?? '',
        stock: stock(p),
        etat: etat(p),
        devise: devise,
        voirAchat: voirAchat,
        etatCarte: etatCarte,
      ),
      vueParDefaut: DsVueModule.grille,
      onOuvrir: detail,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => detail(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.prdEtiquette,
          icone: LucideIcons.barcode,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => etiquette(choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('produits_affecter'),
          libelle: l10n.prdAffecter,
          icone: LucideIcons.tags,
          onPressed: (choix, effacer) => afficherAffecter(context, ref, choix, effacer),
        ),
        DsActionModule(
          cle: const ValueKey('produits_supprimer'),
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerProduits(context, ref, choix, effacer, stocks: stocks),
        ),
      ],
      secondaire: DsButton(
        key: const ValueKey('produits_importer'),
        libelle: l10n.prdImporter,
        icone: LucideIcons.fileSpreadsheet,
        variante: DsButtonVariante.secondaire,
        onPressed: () => afficherImportProduits(context),
      ),
      primaire: DsButton(
        key: const ValueKey('produit_nouveau'),
        libelle: l10n.produitsNouveau,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireProduit(context),
      ),
    );
  }

  // ---------------------------------------------------------------- Catégories
  Widget _categories(
    AppLocalizations l10n,
    List<Produit> produits,
    List<Categorie> categories,
    List<SousCategorie> sous,
  ) {
    int nbProduits(Categorie c) => produits.where((p) => p.categorieCode == c.code).length;
    int nbSous(Categorie c) => sous.where((s) => s.categorieCode == c.code).length;
    final colonnes = <DsColonne<Categorie>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (c) => c.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.produitsColCategorie, valeur: (c) => c.nom, fort: true, flex: 2),
      DsColonne(id: 'sous', libelle: l10n.prdOngletSousCategories, numerique: true, valeur: nbSous),
      DsColonne(id: 'produits', libelle: l10n.produitsOngletProduits, numerique: true, valeur: nbProduits),
      DsColonne(
        id: 'desc',
        libelle: l10n.prdDescriptionChamp,
        attenue: true,
        flex: 2,
        valeur: (c) => c.description ?? '',
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (c) => c.actif ? 1 : 0,
        cellule: (_, c) => BadgeStatut(c.actif ? 'actif' : 'inactif'),
      ),
      ...colonnesAudit(context, ref, (Categorie x) => x.audit),
    ];
    Future<void> modifier(Categorie c) => afficherFormulaireCategorie(context, ref, categorie: c);
    Future<void> detail(Categorie c) =>
        afficherDetailCategorie(context, ref, c, onModifier: c.systeme ? null : () => modifier(c));
    return DsModuleTable<Categorie>(
      key: const ValueKey('produits_categories'),
      entite: l10n.prdEntiteCategories,
      lignes: categories,
      colonnes: colonnes,
      cle: (c) => c.code,
      permissions: permissionsSession(ref),
      indiceRecherche: l10n.prdRechercheCategorie,
      texteRecherche: (c) => '${c.code} ${c.nom}',
      onExport: _export(l10n.produitsOngletCategories, 'categories', colonnes),
      onOuvrir: detail,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => detail(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && choix.first.systeme,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerCategories(context, ref, choix, effacer, nbProduits: nbProduits),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('categorie_nouvelle'),
        libelle: l10n.categoriesNouvelle,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireCategorie(context, ref),
      ),
    );
  }

  // ---------------------------------------------------------------- Sous-catégories
  Widget _sousCategories(
    AppLocalizations l10n,
    List<Produit> produits,
    List<Categorie> categories,
    List<SousCategorie> sous,
  ) {
    final nomsCat = {for (final c in categories) c.code: c.nom};
    int nbProduits(SousCategorie s) => produits.where((p) => p.sousCategorieCode == s.code).length;
    final lignes = sous.where((s) => _categorieSc == null || s.categorieCode == _categorieSc).toList();
    final colonnes = <DsColonne<SousCategorie>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (s) => s.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.produitChampSousCategorie, valeur: (s) => s.nom, fort: true, flex: 2),
      DsColonne(id: 'cat', libelle: l10n.produitsColCategorie, valeur: (s) => nomsCat[s.categorieCode] ?? ''),
      DsColonne(id: 'produits', libelle: l10n.produitsOngletProduits, numerique: true, valeur: nbProduits),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (s) => s.actif ? 1 : 0,
        cellule: (_, s) => BadgeStatut(s.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (s) => s.description ?? '',
      ),
      ...colonnesAudit(context, ref, (SousCategorie x) => x.audit),
    ];
    Future<void> modifier(SousCategorie s) => afficherFormulaireSousCategorie(context, ref, sousCategorie: s);
    Future<void> detail(SousCategorie s) => afficherDetailSousCategorie(
      context,
      s,
      nomCategorie: nomsCat[s.categorieCode] ?? '',
      nbProduits: nbProduits(s),
      onModifier: s.systeme ? null : () => modifier(s),
    );
    return DsModuleTable<SousCategorie>(
      key: const ValueKey('produits_sous'),
      entite: l10n.prdEntiteSousCategories,
      lignes: lignes,
      colonnes: colonnes,
      cle: (s) => s.code,
      permissions: permissionsSession(ref),
      indiceRecherche: l10n.prdRechercheSousCategorie,
      texteRecherche: (s) => '${s.code} ${s.nom}',
      filtresOuverts: true,
      nbFiltresActifs: _categorieSc == null ? 0 : 1,
      onReinitialiser: () => setState(() => _categorieSc = null),
      filtres: [
        DsFormRow(
          libelle: l10n.produitsColCategorie,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            valeur: _categorieSc,
            options: [null, for (final c in categories) c.code],
            libelle: (c) => c == null ? l10n.prdToutes : (nomsCat[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.categorie),
            onChanged: (v) => setState(() => _categorieSc = v),
          ),
        ),
      ],
      onExport: _export(l10n.prdOngletSousCategories, 'sous_categories', colonnes),
      onOuvrir: detail,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => detail(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && choix.first.systeme,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerSousCategories(context, ref, choix, effacer, nbProduits: nbProduits),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('sous_categorie_nouvelle'),
        libelle: l10n.categoriesNouvelleSous,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireSousCategorie(context, ref, categorieCode: _categorieSc),
      ),
    );
  }

  // ---------------------------------------------------------------- Remises
  Widget _remises(AppLocalizations l10n, List<Produit> produits, List<Remise> remises) {
    final devise = ref.watch(deviseProvider);
    final maintenant = DateTime.now();
    int nbProduits(Remise r) =>
        produits.where((p) => p.remiseCode == r.code || (r.produitCode != null && p.code == r.produitCode)).length;
    final colonnes = <DsColonne<Remise>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (r) => r.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.prdRemise, valeur: (r) => r.designation, fort: true, flex: 2),
      DsColonne(
        id: 'valeur',
        libelle: l10n.remiseValeur,
        numerique: true,
        valeur: (r) => r.valeur,
        cellule: (_, r) => Text(libelleValeurRemise(r, devise)),
      ),
      DsColonne(
        id: 'du',
        libelle: l10n.dsDu,
        attenue: true,
        valeur: (r) => r.dateDebut,
        cellule: (_, r) => Text(dateOuTiret(r.dateDebut)),
      ),
      DsColonne(
        id: 'au',
        libelle: l10n.dsAu,
        attenue: true,
        valeur: (r) => r.dateFin,
        cellule: (_, r) => Text(dateOuTiret(r.dateFin)),
      ),
      DsColonne(id: 'produits', libelle: l10n.produitsOngletProduits, numerique: true, valeur: nbProduits),
      DsColonne(
        id: 'statut',
        libelle: l10n.prdStatut,
        valeur: (r) => r.statut(maintenant),
        cellule: (_, r) => BadgeStatutRemise(r.statut(maintenant)),
      ),
      DsColonne(
        id: 'type',
        libelle: l10n.remiseType,
        visibleParDefaut: false,
        valeur: (r) => libellePorteeRemise(l10n, r.portee),
      ),
      DsColonne(
        id: 'tauxType',
        libelle: l10n.prdTypeTaux,
        visibleParDefaut: false,
        valeur: (r) => libelleRef(context, Referentiel.typesCalcul, r.type),
      ),
      DsColonne(
        id: 'seuil',
        libelle: l10n.prdSeuilMontant,
        numerique: true,
        visibleParDefaut: false,
        valeur: (r) => r.seuil,
        cellule: (_, r) => Text(r.parMontant ? formaterMontant(r.seuil, devise) : '—'),
      ),
      DsColonne(id: 'obs', libelle: l10n.retoursObservation, visibleParDefaut: false, valeur: (r) => r.observation),
      ...colonnesAudit(context, ref, (Remise x) => x.audit),
    ];
    Future<void> modifier(Remise r) => afficherFormulaireRemise(context, ref, remise: r);
    Future<void> detail(Remise r) => afficherDetailRemise(context, ref, r, onModifier: () => modifier(r));
    return DsModuleTable<Remise>(
      key: const ValueKey('produits_remises'),
      entite: l10n.prdEntiteRemises,
      lignes: remises,
      colonnes: colonnes,
      cle: (r) => r.code,
      permissions: permissionsSession(ref),
      indiceRecherche: l10n.prdRechercheRemise,
      texteRecherche: (r) => '${r.code} ${r.designation}',
      onExport: _export(l10n.produitsOngletRemises, 'remises', colonnes),
      onOuvrir: detail,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => detail(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerRemises(context, ref, choix, effacer, nbProduits: nbProduits),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('remise_nouvelle'),
        libelle: l10n.remiseNouvelle,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireRemise(context, ref),
      ),
    );
  }

  // ---------------------------------------------------------------- Packs
  Widget _packs(AppLocalizations l10n, List<Produit> produits, List<Pack> packs) {
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final stocks = ref.watch(stocksProduitsProvider).value ?? const <String, double>{};
    final parCode = {for (final p in produits) p.code: p};
    double valeur(Pack k) => valeurSeparee(k, parCode);
    int possibles(Pack k) => packsPossibles(k, stocks);
    final colonnes = <DsColonne<Pack>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (k) => k.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.prdPack, valeur: (k) => k.designation, fort: true, flex: 2),
      DsColonne(id: 'comp', libelle: l10n.prdComposants, numerique: true, valeur: (k) => k.lignes.length),
      DsColonne(
        id: 'v',
        libelle: l10n.prdValeurSeparee,
        numerique: true,
        valeur: valeur,
        cellule: (_, k) => Text(da(valeur(k))),
      ),
      DsColonne(
        id: 'prix',
        libelle: l10n.prdPrixPack,
        numerique: true,
        valeur: (k) => k.prixVente,
        cellule: (context, k) =>
            Text(da(k.prixVente), style: context.ds.typo.bodySm.copyWith(fontWeight: FontWeight.w600)),
      ),
      DsColonne(
        id: 'e',
        libelle: l10n.prdEconomie,
        numerique: true,
        valeur: (k) => valeur(k) - k.prixVente,
        cellule: (context, k) => Text(
          da(valeur(k) - k.prixVente),
          style: context.ds.typo.bodySm.copyWith(color: context.ds.colors.successFg),
        ),
      ),
      DsColonne(id: 'stock', libelle: l10n.prdDisponibles, numerique: true, valeur: possibles),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (k) => k.actif ? 1 : 0,
        cellule: (_, k) => BadgeStatut(k.actif ? 'actif' : 'inactif'),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (k) => k.description ?? '',
      ),
      ...colonnesAudit(context, ref, (Pack x) => x.audit),
    ];
    Future<void> modifier(Pack k) => afficherFormulairePack(context, ref, pack: k);
    Future<void> detail(Pack k) => afficherDetailPack(context, ref, k, onModifier: () => modifier(k));
    return DsModuleTable<Pack>(
      key: const ValueKey('produits_packs'),
      entite: l10n.prdEntitePacks,
      lignes: packs,
      colonnes: colonnes,
      cle: (k) => k.code,
      permissions: permissionsSession(ref),
      indiceRecherche: l10n.prdRecherchePack,
      texteRecherche: (k) => '${k.code} ${k.designation}',
      onExport: _export(l10n.produitsOngletPacks, 'packs', colonnes),
      onOuvrir: detail,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => detail(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.communSupprimer,
          icone: LucideIcons.trash2,
          danger: true,
          onPressed: (choix, effacer) => supprimerPacks(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('pack_nouveau'),
        libelle: l10n.packNouveau,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulairePack(context, ref),
      ),
    );
  }

  void Function(DsFormatExport, List<T>)? _export<T>(String titre, String id, List<DsColonne<T>> colonnes) =>
      peutExporter(ref)
      ? (format, lignes) =>
            exporterTableau(context, ref, id: id, titre: titre, colonnes: colonnes, lignes: lignes, format: format)
      : null;
}

/// Carte produit de la vue grille (`ProduitCard`) : vignette teintée ou photo, état, prix, stock, marge.
class _CarteProduit extends StatelessWidget {
  const _CarteProduit({
    required this.produit,
    required this.categorie,
    required this.stock,
    required this.etat,
    required this.devise,
    required this.voirAchat,
    required this.etatCarte,
  });
  final Produit produit;
  final String categorie;
  final double stock;
  final String etat;
  final String devise;
  final bool voirAchat;
  final DsEtatCarte etatCarte;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final teinte = teintePour(categorie);
    final photo = imageProduit(produit.image);
    return DsGridCard(
      etat: etatCarte,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                height: 112,
                decoration: BoxDecoration(
                  color: photo != null
                      ? c.surfaceSunken
                      : Color.alphaBlend(teinte.withValues(alpha: .14), c.surfaceCard),
                  image: photo != null ? DecorationImage(image: photo, fit: BoxFit.cover) : null,
                  border: Border(bottom: BorderSide(color: c.borderSubtle)),
                ),
                alignment: Alignment.center,
                child: photo == null ? Icon(LucideIcons.package, size: 36, color: teinte) : null,
              ),
              PositionedDirectional(top: 10, end: 10, child: BadgeStatut(etat, petit: true)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(
                        produit.designation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySm.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${produit.code} · $categorie',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        formaterMontant(produit.prixVente, devise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.body.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                      ),
                    ),
                    if (voirAchat) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.prdAchatMontant(formaterMontant(produit.prixAchat, devise)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: t.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.borderSubtle)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          produit.service ? l10n.prdService : l10n.prdStockN(formaterNombre(stock)),
                          overflow: TextOverflow.ellipsis,
                          style: t.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: switch (etat) {
                              'rupture' => c.dangerFg,
                              'seuil' => c.warningFg,
                              _ => c.textSecondary,
                            },
                          ),
                        ),
                      ),
                      if (voirAchat)
                        Text(
                          l10n.prdMargeN(margeProduit(produit).round()),
                          style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.successFg),
                        ),
                    ],
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
