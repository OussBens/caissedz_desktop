import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/chargement.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../retours/retours_dialogs.dart';
import '../tiers/tiers_providers.dart';
import '../ventes/ventes_dialogs.dart';
import 'stock_dialogs.dart';
import 'stock_providers.dart';

/// Ligne du tableau Stock : produit, quantités par magasin consultable, total.
class _LigneStock {
  const _LigneStock(this.produit, this.parMagasin, this.total, this.etat);
  final Produit produit;
  final Map<String, double> parMagasin;
  final double total;
  final String etat;
}

/// Écran Stock (`StockScreen` du DS v2.2) : onglets Stock (quantités par magasin, KPI, détail, distribution)
/// et Mouvements (journal filtrable, « Voir la pièce »).
class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key, this.ongletInitial = 0});
  final int ongletInitial;

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  late int _onglet = widget.ongletInitial;
  String? _magasin;
  String? _categorie;
  String? _etat;
  String? _produit;
  String? _marque;
  String? _type;
  String? _produitMvt;
  String? _magasinMvt;
  String? _utilisateur;
  DsPeriode _periode = DsPeriode.calculer('month');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final magasins = ref.watch(magasinsProvider).value ?? const <Magasin>[];
    final mes = ref.watch(mesMagasinsProvider).value ?? const <String>[];
    final session = ref.watch(sessionProvider);
    // §6.2 : magasins consultables = tous pour l'Admin ou `voirStockTousMagasins`, sinon ceux de l'utilisateur.
    final tous = mes.isEmpty || (session?.estAdmin ?? false) || (session?.a(Permission.voirStockTousMagasins) ?? false);
    final consultables = [
      for (final m in magasins)
        if (m.actif && (tous || mes.contains(m.code))) m,
    ];
    final produits = (ref.watch(produitsProvider).value ?? const <Produit>[]).where((p) => !p.service).toList();
    final mouvements = ref.watch(mouvementsProvider).value ?? const <MouvementStock>[];
    return PageModule(
      moduleId: 'stock',
      onglets: [l10n.stockTitre, l10n.stkOngletMouvements],
      comptes: [produits.length, mouvements.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0 ? _stock(l10n, consultables, produits) : _mouvements(l10n, magasins, mouvements),
    );
  }

  Widget _stock(AppLocalizations l10n, List<Magasin> consultables, List<Produit> produits) {
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final stocks = ref.watch(stocksParMagasinProvider).value ?? const <String, Map<String, double>>{};
    final seuilGlobal = ref.watch(parametresVenteProvider).value?.seuilStockGlobal ?? 5;
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Categorie>[]) c.code: c.nom};
    final sousCategories = {
      for (final s in ref.watch(sousCategoriesProvider).value ?? const <SousCategorie>[]) s.code: s.nom,
    };
    final remises = {for (final r in ref.watch(remisesProvider).value ?? const <Remise>[]) r.code: r.designation};
    final licence = ref.watch(licenceProvider);
    final multiMagasin = licence.couvre(NiveauLicence.ultra);
    final colonnesMagasins = _magasin == null ? consultables : consultables.where((m) => m.code == _magasin).toList();
    final toutes = [
      for (final p in produits)
        () {
          final par = {for (final m in colonnesMagasins) m.code: stocks[p.code]?[m.code] ?? 0.0};
          // Le total reste celui de tous les magasins consultables, même filtré sur un magasin.
          final total = consultables.fold(0.0, (a, m) => a + (stocks[p.code]?[m.code] ?? 0.0));
          return _LigneStock(p, par, total, etatStockProduit(p, total, seuilGlobal));
        }(),
    ];
    final lignes = toutes
        .where(
          (l) =>
              (_categorie == null || l.produit.categorieCode == _categorie) &&
              (_etat == null || (_etat == 'actif' ? l.etat == 'actif' : l.etat == _etat)) &&
              (_produit == null || l.produit.code == _produit) &&
              (_marque == null || (l.produit.marque ?? '').trim() == _marque),
        )
        .toList();
    double valeurAchat(_LigneStock l) => l.total * l.produit.prixAchat;
    final colis = ref.watch(colisProvider).value ?? const <Colis>[];
    String embLib(Produit p, int i) {
      final e = colis.where((c) => c.produitCode == p.code && c.actif).toList()
        ..sort((a, b) => a.quantite - b.quantite);
      return i < e.length ? l10n.prdEmballagePieces(e[i].quantite) : '';
    }

    final colonnes = <DsColonne<_LigneStock>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produit.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.produit.designation, fort: true, flex: 3),
      DsColonne(
        id: 'cat',
        libelle: l10n.produitsColCategorie,
        valeur: (l) => categories[l.produit.categorieCode] ?? '',
        flex: 2,
      ),
      for (final m in colonnesMagasins)
        DsColonne(
          id: 'mag_${m.code}',
          libelle: m.nom,
          numerique: true,
          valeur: (l) => l.parMagasin[m.code] ?? 0,
          cellule: (_, l) => Text(formaterNombre(l.parMagasin[m.code] ?? 0)),
          total: (ls) => formaterNombre(ls.fold(0.0, (s, l) => s + (l.parMagasin[m.code] ?? 0))),
        ),
      DsColonne(
        id: 'total',
        libelle: l10n.communTotal,
        numerique: true,
        fort: true,
        valeur: (l) => l.total,
        cellule: (_, l) => Text(formaterNombre(l.total)),
        total: (ls) => formaterNombre(ls.fold(0.0, (s, l) => s + l.total)),
      ),
      DsColonne(
        id: 'val',
        libelle: l10n.stockColValeur,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: valeurAchat,
        cellule: (_, l) => Text(da(valeurAchat(l))),
        total: (ls) => da(ls.fold(0.0, (s, l) => s + valeurAchat(l))),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.retoursEtat,
        valeur: (l) => l.etat,
        cellule: (_, l) =>
            l.etat == 'actif' ? DsStatusBadge(statut: 'actif', libelle: l10n.stkDisponibleEtat) : BadgeStatut(l.etat),
      ),
      DsColonne(id: 'marque', libelle: l10n.prdMarque, visibleParDefaut: false, valeur: (l) => l.produit.marque ?? ''),
      DsColonne(
        id: 'description',
        libelle: l10n.prdDescriptionChamp,
        visibleParDefaut: false,
        valeur: (l) => l.produit.description ?? '',
      ),
      DsColonne(id: 'taille', libelle: l10n.prdTaille, visibleParDefaut: false, valeur: (l) => l.produit.taille ?? ''),
      DsColonne(
        id: 'couleur',
        libelle: l10n.prdCouleur,
        visibleParDefaut: false,
        valeur: (l) => l.produit.couleur ?? '',
      ),
      DsColonne(
        id: 'achat',
        libelle: l10n.produitsColPrixAchat,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (l) => l.produit.prixAchat,
        cellule: (_, l) => Text(da(l.produit.prixAchat)),
      ),
      DsColonne(
        id: 'vente',
        libelle: l10n.produitsColPrixVente,
        numerique: true,
        visibleParDefaut: false,
        valeur: (l) => l.produit.prixVente,
        cellule: (_, l) => Text(da(l.produit.prixVente)),
      ),
      DsColonne(
        id: 'sousCat',
        libelle: l10n.produitChampSousCategorie,
        visibleParDefaut: false,
        valeur: (l) => sousCategories[l.produit.sousCategorieCode] ?? '',
      ),
      DsColonne(
        id: 'remise',
        libelle: l10n.prdRemise,
        visibleParDefaut: false,
        valeur: (l) => remises[l.produit.remiseCode] ?? '',
      ),
      DsColonne(
        id: 'unite',
        libelle: l10n.produitChampUnite,
        visibleParDefaut: false,
        valeur: (l) => libelleRef(context, Referentiel.unitesMesure, l.produit.unite),
      ),
      DsColonne(
        id: 'emb1',
        libelle: l10n.prdEmballageN(1),
        visibleParDefaut: false,
        valeur: (l) => embLib(l.produit, 0),
      ),
      DsColonne(
        id: 'emb2',
        libelle: l10n.prdEmballageN(2),
        visibleParDefaut: false,
        valeur: (l) => embLib(l.produit, 1),
      ),
      DsColonne(
        id: 'codeBarre',
        libelle: l10n.produitsColCodeBarres,
        visibleParDefaut: false,
        attenue: true,
        mono: true,
        valeur: (l) => l.produit.codeBarres ?? '',
      ),
      DsColonne(
        id: 'numeroSerie',
        libelle: l10n.prdNumeroSerie,
        visibleParDefaut: false,
        valeur: (l) => l.produit.suiviSerie ? 1 : 0,
        cellule: (_, l) => Text(l.produit.suiviSerie ? l10n.communOui : l10n.communNon),
      ),
      DsColonne(
        id: 'tva',
        libelle: l10n.prdTva,
        numerique: true,
        visibleParDefaut: false,
        valeur: (l) => l.produit.tvaPct,
        cellule: (_, l) => Text('${formaterNombre(l.produit.tvaPct)} %'),
      ),
    ];
    final marques = {
      for (final p in produits)
        if ((p.marque ?? '').trim().isNotEmpty) p.marque!.trim(),
    }.toList()..sort();
    final sousSeuil = toutes.where((l) => l.etat == 'rupture' || l.etat == 'seuil').length;
    final achat = ref.watch(sessionProvider)?.a(Permission.voirPrixAchat) ?? false;
    return DsModuleTable<_LigneStock>(
      key: const ValueKey('stock_produits'),
      entite: l10n.prdEntiteProduits,
      lignes: lignes,
      chargement: enChargement(ref.watch(produitsProvider)),
      colonnes: colonnes,
      cle: (l) => l.produit.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      kpis: [
        DsStatCard(
          libelle: l10n.stkQuantiteTotale,
          valeur: formaterNombre(toutes.fold(0.0, (s, l) => s + l.total)),
          icone: LucideIcons.boxes,
        ),
        if (achat)
          DsStatCard(
            libelle: l10n.stkValeurAchat,
            valeur: f2(toutes.fold(0.0, (s, l) => s + valeurAchat(l))),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
        DsStatCard(
          libelle: l10n.stkValeurVente,
          valeur: f2(toutes.fold(0.0, (s, l) => s + l.total * l.produit.prixVente)),
          suffixe: devise,
          icone: LucideIcons.tag,
        ),
        DsStatCard(libelle: l10n.stkAReapprovisionner, valeur: '$sousSeuil', icone: LucideIcons.triangleAlert),
      ],
      indiceRecherche: l10n.prdRechercheProduits,
      texteRecherche: (l) => '${l.produit.code} ${l.produit.designation} ${l.produit.codeBarres ?? ''}',
      nbFiltresActifs: [_magasin, _categorie, _etat, _produit, _marque].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _magasin = null;
        _categorie = null;
        _etat = null;
        _produit = null;
        _marque = null;
      }),
      filtres: [
        if (ref.watch(plusieursMagasinsProvider))
          DsFormRow(
            libelle: l10n.stockColMagasin,
            largeurLibelle: 80,
            child: DsSelect<String?>(
              cle: const ValueKey('stock_filtre_magasin'),
              valeur: _magasin,
              options: [null, for (final m in consultables) m.code],
              libelle: (c) => c == null ? l10n.retoursTous : consultables.firstWhere((m) => m.code == c).nom,
              recherche: rechercheListe(context, ref, ListeMetier.magasin),
              onChanged: (v) => setState(() => _magasin = v),
            ),
          ),
        DsFormRow(
          libelle: l10n.produitsColCategorie,
          largeurLibelle: 80,
          child: DsSelect<String?>(
            valeur: _categorie,
            options: [null, ...categories.keys],
            libelle: (c) => c == null ? l10n.prdToutes : (categories[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.categorie),
            onChanged: (v) => setState(() => _categorie = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.retoursEtat,
          largeurLibelle: 80,
          child: DsSelect<String?>(
            cle: const ValueKey('stock_filtre_etat'),
            valeur: _etat,
            options: const [null, 'actif', 'seuil', 'rupture'],
            libelle: (e) => switch (e) {
              null => l10n.retoursTous,
              'actif' => l10n.stkDisponibleEtat,
              'seuil' => l10n.stkSousSeuilEtat,
              _ => libelleStatut(l10n, e),
            },
            onChanged: (v) => setState(() => _etat = v),
          ),
        ),
        filtreProduit(
          context,
          ref,
          cle: const ValueKey('stock_filtre_produit'),
          valeur: _produit,
          onChanged: (v) => setState(() => _produit = v),
        ),
        DsFormRow(
          libelle: l10n.prdMarque,
          child: DsSelect<String?>(
            cle: const ValueKey('stock_filtre_marque'),
            valeur: _marque,
            options: [null, ...marques],
            libelle: (m) => m ?? l10n.prdToutes,
            onChanged: (v) => setState(() => _marque = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: 'stock',
              titre: l10n.stockTitre,
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      onOuvrir: (l) => afficherDetailStock(context, ref, l.produit),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailStock(context, ref, choix.first.produit),
        ),
        if (multiMagasin)
          DsActionModule(
            cle: const ValueKey('stock_distribuer'),
            libelle: l10n.stkDistribuer,
            icone: LucideIcons.split,
            regle: DsRegleSelection.une,
            desactive: (choix) =>
                choix.isNotEmpty &&
                (stocks[choix.first.produit.code]?.values ?? const <double>[]).fold(0.0, (a, b) => a + b) <= 0,
            onPressed: (choix, _) => afficherDistribution(context, ref, choix.first.produit),
          ),
      ],
      primaire: DsButton(
        key: const ValueKey('stock_voir_mouvements'),
        libelle: l10n.stkVoirMouvements,
        icone: LucideIcons.arrowLeftRight,
        variante: DsButtonVariante.secondaire,
        onPressed: () => setState(() => _onglet = 1),
      ),
    );
  }

  Widget _mouvements(AppLocalizations l10n, List<Magasin> magasins, List<MouvementStock> tous) {
    final devise = ref.watch(deviseProvider);
    final produits = {for (final p in ref.watch(produitsProvider).value ?? const <Produit>[]) p.code: p};
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final noms = {for (final m in magasins) m.code: m.nom};
    final lignes = tous
        .where(
          (m) =>
              dansPeriode(m.date, _periode) &&
              (_type == null || m.type == _type) &&
              (_magasinMvt == null || m.magasinCode == _magasinMvt) &&
              (_utilisateur == null || m.utilisateurCode == _utilisateur) &&
              (_produitMvt == null || m.produitCode == _produitMvt),
        )
        .toList();
    String nomProduit(MouvementStock m) => produits[m.produitCode]?.designation ?? m.produitCode;
    final colonnes = <DsColonne<MouvementStock>>[
      DsColonne(
        id: 'd',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (m) => m.date,
        cellule: (_, m) => Text(formatDateHeure.format(m.date)),
      ),
      DsColonne(id: 't', libelle: l10n.stockColType, valeur: (m) => libelleTypeMouvement(l10n, m.type)),
      DsColonne(id: 'r', libelle: l10n.stkReference, attenue: true, valeur: (m) => m.referenceCode ?? ''),
      DsColonne(id: 'nom', libelle: l10n.dsPosProduit, fort: true, flex: 3, valeur: nomProduit),
      DsColonne(id: 'mag', libelle: l10n.stockColMagasin, flex: 2, valeur: (m) => noms[m.magasinCode] ?? m.magasinCode),
      DsColonne(
        id: 'q',
        libelle: l10n.stockColQuantite,
        numerique: true,
        valeur: (m) => m.quantite,
        cellule: (_, m) => QuantiteSignee(m.quantite),
      ),
      DsColonne(
        id: 'u',
        libelle: l10n.stockColUtilisateur,
        valeur: (m) => utilisateurs[m.utilisateurCode] ?? m.utilisateurCode,
      ),
      DsColonne(
        id: 'achat',
        libelle: l10n.produitsColPrixAchat,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (m) => produits[m.produitCode]?.prixAchat ?? 0,
        cellule: (_, m) => Text(formaterMontant(produits[m.produitCode]?.prixAchat ?? 0, devise)),
      ),
      DsColonne(
        id: 'vente',
        libelle: l10n.produitsColPrixVente,
        numerique: true,
        visibleParDefaut: false,
        valeur: (m) => produits[m.produitCode]?.prixVente ?? 0,
        cellule: (_, m) => Text(formaterMontant(produits[m.produitCode]?.prixVente ?? 0, devise)),
      ),
      DsColonne(
        id: 'motif',
        libelle: l10n.stockColMotif,
        visibleParDefaut: false,
        valeur: (m) => m.motif == null ? '' : libelleMotif(l10n, m.motif!),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (m) => m.commentaire ?? '',
      ),
      ...colonnesAudit(context, ref, (MouvementStock x) => x.audit),
    ];
    final codesUtilisateurs = tous.map((m) => m.utilisateurCode).toSet().toList()..sort();
    return DsModuleTable<MouvementStock>(
      key: const ValueKey('stock_mouvements'),
      entite: l10n.stkEntiteMouvements,
      lignes: lignes,
      chargement: enChargement(ref.watch(mouvementsProvider)),
      colonnes: colonnes,
      cle: (m) => m.id ?? m.hashCode,
      permissions: permissionsSession(ref),
      messageVide: l10n.stockAucunMouvement,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      colonnesFiltres: 4,
      indiceRecherche: l10n.stkRechercheMouvement,
      texteRecherche: (m) => '${m.referenceCode ?? ''} ${nomProduit(m)}',
      nbFiltresActifs: [_type, _magasinMvt, _utilisateur, _produitMvt].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _type = null;
        _magasinMvt = null;
        _utilisateur = null;
        _produitMvt = null;
        _periode = DsPeriode.calculer('month');
      }),
      // 1re ligne : Du, Au, Période rapide et Produit ; 2e ligne : type, magasin, utilisateur.
      filtres: [
        filtreProduit(
          context,
          ref,
          cle: const ValueKey('mouvement_filtre_produit'),
          valeur: _produitMvt,
          onChanged: (v) => setState(() => _produitMvt = v),
        ),
        const DsFinLigne(),
        DsFormRow(
          libelle: l10n.stockColType,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            cle: const ValueKey('mouvement_filtre_type'),
            valeur: _type,
            options: const [
              null,
              TypesMouvement.vente,
              TypesMouvement.entree,
              TypesMouvement.sortie,
              TypesMouvement.transfert,
              TypesMouvement.retour,
              TypesMouvement.inventaire,
              TypesMouvement.initial,
              TypesMouvement.annulation,
            ],
            libelle: (t) => t == null ? l10n.retoursTous : libelleTypeMouvement(l10n, t),
            onChanged: (v) => setState(() => _type = v),
          ),
        ),
        if (ref.watch(plusieursMagasinsProvider))
          DsFormRow(
            libelle: l10n.stockColMagasin,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              valeur: _magasinMvt,
              options: [null, for (final m in magasins) m.code],
              libelle: (c) => c == null ? l10n.retoursTous : (noms[c] ?? c),
              recherche: rechercheListe(context, ref, ListeMetier.magasin),
              onChanged: (v) => setState(() => _magasinMvt = v),
            ),
          ),
        DsFormRow(
          libelle: l10n.stockColUtilisateur,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            valeur: _utilisateur,
            options: [null, ...codesUtilisateurs],
            libelle: (c) => c == null ? l10n.retoursTous : (utilisateurs[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.utilisateur),
            onChanged: (v) => setState(() => _utilisateur = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: 'mouvements',
              titre: l10n.stkOngletMouvements,
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      onOuvrir: _voirPiece,
      actions: [
        DsActionModule(
          libelle: l10n.stkVoirPiece,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          desactive: (choix) => choix.isNotEmpty && choix.first.referenceCode == null,
          onPressed: (choix, _) => _voirPiece(choix.first),
        ),
      ],
    );
  }

  /// Ouvre le détail de la pièce d'origine d'un mouvement (vente, retour, sortie, transfert).
  Future<void> _voirPiece(MouvementStock m) async {
    final code = m.referenceCode;
    if (code == null) return;
    final repo = ref.read(stockRepositoryProvider);
    switch (m.referenceType) {
      case 'sortie':
        final s = await repo.sortie(code);
        if (s != null && mounted) await afficherDetailSortie(context, ref, s);
      case 'transfert':
        final t = await repo.transfert(code);
        if (t != null && mounted) await afficherDetailTransfert(context, ref, t);
      case 'vente':
        final d = m.date;
        final paniers = await ref
            .read(venteRepositoryProvider)
            .paniers(depuis: d.subtract(const Duration(days: 366)), jusqua: DateTime(d.year, d.month, d.day + 1));
        final p = paniers.where((x) => x.vente.code == code).firstOrNull;
        final clients = {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom};
        if (p != null && mounted) await afficherDetailPanier(context, ref, p, nomsClients: clients);
      case 'retour':
        final r = await ref.read(tiersRepositoryProvider).retour(code);
        if (r == null) return;
        final noms = r.estClient
            ? {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom}
            : {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
        if (mounted) await afficherDetailRetour(context, ref, r, nomsTiers: noms);
      default:
        if (mounted) {
          afficherToast(context, titre: code, description: libelleTypeMouvement(AppLocalizations.of(context), m.type));
        }
    }
  }
}
