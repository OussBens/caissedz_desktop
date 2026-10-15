import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/permissions.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/statuts.dart';
import '../historique/historique_page.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../retours/retours_dialogs.dart';
import '../tiers/tiers_providers.dart';
import 'stock_dialogs.dart';
import 'stock_providers.dart';

/// Produit sous le seuil (onglet Ruptures & seuils).
class _Rupture {
  const _Rupture(this.produit, this.stock, this.seuil);
  final Produit produit;
  final double stock;
  final int seuil;
  double get suggestion => StockService.suggestion(stock, seuil);
}

/// Produit expiré ou proche de l'expiration (onglet Expirés).
class _Expire {
  const _Expire(this.produit, this.stock, this.jours);
  final Produit produit;
  final double stock;
  final int jours;
}

/// Écran Besoins (`BesoinsScreen` du DS v2.2) : listes de besoins fournisseurs, ruptures & seuils, expirés.
class BesoinsPage extends ConsumerStatefulWidget {
  const BesoinsPage({super.key, this.ongletInitial = 0});
  final int ongletInitial;

  /// Fenêtre d'alerte des produits bientôt expirés (jours).
  static const int joursAlerteExpiration = 30;

  @override
  ConsumerState<BesoinsPage> createState() => _BesoinsPageState();
}

class _BesoinsPageState extends ConsumerState<BesoinsPage> {
  late int _onglet = widget.ongletInitial;
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _statut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final besoins = ref.watch(besoinsProvider).value ?? const <Besoin>[];
    final produits = (ref.watch(produitsProvider).value ?? const <Produit>[]).where((p) => p.actif && !p.service);
    final stocks = ref.watch(stocksProduitsProvider).value ?? const <String, double>{};
    final seuilGlobal = ref.watch(parametresVenteProvider).value?.seuilStockGlobal ?? 5;
    final ruptures = [
      for (final p in produits)
        if ((stocks[p.code] ?? 0) <= seuilDe(p, seuilGlobal)) _Rupture(p, stocks[p.code] ?? 0, seuilDe(p, seuilGlobal)),
    ];
    final aujourdhui = DateTime.now();
    final jour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    final expires = [
      for (final p in produits)
        if (p.dateExpiration != null && (stocks[p.code] ?? 0) > 0)
          _Expire(
            p,
            stocks[p.code] ?? 0,
            DateTime(p.dateExpiration!.year, p.dateExpiration!.month, p.dateExpiration!.day).difference(jour).inDays,
          ),
    ].where((e) => e.jours <= BesoinsPage.joursAlerteExpiration).toList()..sort((a, b) => a.jours - b.jours);
    return PageModule(
      moduleId: 'besoins',
      sousTitre: l10n.stkDescriptionBesoins,
      onglets: [l10n.stkOngletListes, l10n.stkOngletRuptures, l10n.stkOngletExpires],
      comptes: [besoins.length, ruptures.length, expires.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: switch (_onglet) {
        0 => _listes(l10n, besoins),
        1 => _ruptures(l10n, ruptures),
        _ => _expires(l10n, expires),
      },
    );
  }

  Widget _listes(AppLocalizations l10n, List<Besoin> tous) {
    final devise = ref.watch(deviseProvider);
    final fournisseurs = {
      for (final f in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[]) f.code: f.nom,
    };
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final lignes = tous
        .where((b) => dansPeriode(b.date, _periode) && (_statut == null || statutBesoinDs(b) == _statut))
        .toList();
    final colonnes = <DsColonne<Besoin>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (b) => b.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (b) => b.date,
        cellule: (_, b) => Text(formatDate.format(b.date)),
      ),
      DsColonne(
        id: 'frn',
        libelle: l10n.retoursFournisseur,
        fort: true,
        flex: 2,
        valeur: (b) => fournisseurs[b.fournisseurCode] ?? b.fournisseurCode,
      ),
      DsColonne(id: 'n', libelle: l10n.stkArticles, numerique: true, valeur: (b) => b.lignes.length),
      DsColonne(
        id: 'montant',
        libelle: l10n.stkMontantEstime,
        numerique: true,
        valeur: (b) => b.montant,
        cellule: (_, b) => Text(formaterMontant(b.montant, devise)),
        total: (bs) => formaterMontant(bs.where((b) => b.actif).fold(0.0, (a, b) => a + b.montant), devise),
      ),
      DsColonne(
        id: 'statut',
        libelle: l10n.stkStatut,
        valeur: statutBesoinDs,
        cellule: (_, b) => BadgeStatut(statutBesoinDs(b)),
      ),
      DsColonne(
        id: 'q',
        libelle: l10n.stockColQuantite,
        numerique: true,
        visibleParDefaut: false,
        valeur: (b) => b.quantite,
        cellule: (_, b) => Text(formaterNombre(b.quantite)),
      ),
      DsColonne(
        id: 'livraison',
        libelle: l10n.stkLivraison,
        visibleParDefaut: false,
        valeur: (b) => b.dateLivraison ?? DateTime(0),
        cellule: (_, b) => Text(dateOuTiret(b.dateLivraison)),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (b) => b.observation ?? '',
      ),
      DsColonne(
        id: 'cree_par',
        libelle: l10n.ventesCreePar,
        visibleParDefaut: false,
        valeur: (b) => utilisateurs[b.utilisateurCode] ?? b.utilisateurCode,
      ),
    ];
    bool fige(Besoin b) => !b.actif || b.statut == StatutsBesoin.disponible;
    return DsModuleTable<Besoin>(
      key: const ValueKey('besoins_listes'),
      entite: l10n.stkEntiteListes,
      lignes: lignes,
      colonnes: colonnes,
      cle: (b) => b.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.stkAucuneListe,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      texteRecherche: (b) => '${b.code} ${fournisseurs[b.fournisseurCode] ?? ''}',
      nbFiltresActifs: _statut == null ? 0 : 1,
      onReinitialiser: () => setState(() {
        _statut = null;
        _periode = DsPeriode.calculer('month');
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.stkStatut,
          largeurLibelle: 80,
          child: DsSelect<String?>(
            cle: const ValueKey('besoins_filtre_statut'),
            valeur: _statut,
            options: const [null, 'enAttente', 'commande', 'disponible', 'annule'],
            libelle: (s) => s == null ? l10n.retoursTous : libelleStatut(l10n, s),
            onChanged: (v) => setState(() => _statut = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, bs) => exporterTableau(
              context,
              ref,
              id: 'besoins',
              titre: l10n.stkOngletListes,
              colonnes: colonnes,
              lignes: bs,
              format: format,
            )
          : null,
      onOuvrir: (b) => afficherDetailBesoin(context, ref, b),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailBesoin(context, ref, choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && fige(choix.first),
          onPressed: (choix, _) => afficherFormulaireBesoin(context, ref, besoin: choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('besoins_annuler'),
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.ban,
          danger: true,
          onPressed: (choix, effacer) => annulerBesoins(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: const ValueKey('besoin_nouveau'),
        libelle: l10n.stkNouvelleListe,
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireBesoin(context, ref),
      ),
    );
  }

  Widget _ruptures(AppLocalizations l10n, List<_Rupture> lignes) {
    final devise = ref.watch(deviseProvider);
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Categorie>[]) c.code: c.nom};
    final achat = permissionsSession(ref).contains(Permission.voirPrixAchat.code);
    return DsModuleTable<_Rupture>(
      key: const ValueKey('besoins_ruptures'),
      entite: l10n.prdEntiteProduits,
      lignes: lignes,
      cle: (r) => r.produit.code,
      permissions: permissionsSession(ref),
      messageVide: l10n.stkAucuneRupture,
      kpis: [
        DsStatCard(
          libelle: l10n.stkKpiEnRupture,
          valeur: '${lignes.where((r) => r.stock <= 0).length}',
          icone: LucideIcons.circleX,
        ),
        DsStatCard(
          libelle: l10n.stkKpiSousSeuil,
          valeur: '${lignes.where((r) => r.stock > 0).length}',
          icone: LucideIcons.triangleAlert,
        ),
        if (achat)
          DsStatCard(
            libelle: l10n.stkKpiCoutReassort,
            valeur: f2(lignes.fold(0.0, (a, r) => a + r.suggestion * r.produit.prixAchat)),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
      ],
      texteRecherche: (r) => '${r.produit.code} ${r.produit.designation}',
      colonnes: [
        DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (r) => r.produit.code, attenue: true),
        DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (r) => r.produit.designation, fort: true, flex: 3),
        DsColonne(
          id: 'cat',
          libelle: l10n.produitsColCategorie,
          flex: 2,
          valeur: (r) => categories[r.produit.categorieCode] ?? '',
        ),
        DsColonne(
          id: 'stock',
          libelle: l10n.produitsColStock,
          numerique: true,
          valeur: (r) => r.stock,
          cellule: (_, r) => Text(formaterNombre(r.stock)),
        ),
        DsColonne(id: 'seuil', libelle: l10n.stockColSeuil, numerique: true, valeur: (r) => r.seuil),
        DsColonne(
          id: 'sugg',
          libelle: l10n.stkSuggestion,
          numerique: true,
          fort: true,
          valeur: (r) => r.suggestion,
          cellule: (_, r) => Text(formaterNombre(r.suggestion)),
        ),
        DsColonne(
          id: 'etat',
          libelle: l10n.retoursEtat,
          valeur: (r) => r.stock <= 0 ? 0 : 1,
          cellule: (_, r) => BadgeStatut(r.stock <= 0 ? 'rupture' : 'seuil'),
        ),
      ],
      actions: [
        DsActionModule(
          cle: const ValueKey('ruptures_creer_liste'),
          libelle: l10n.stkCreerListe,
          icone: LucideIcons.clipboardList,
          onPressed: (choix, effacer) async {
            await afficherFormulaireBesoin(context, ref, proposes: [for (final r in choix) r.produit]);
            effacer();
          },
        ),
      ],
    );
  }

  Widget _expires(AppLocalizations l10n, List<_Expire> lignes) => DsModuleTable<_Expire>(
    key: const ValueKey('besoins_expires'),
    entite: l10n.prdEntiteProduits,
    lignes: lignes,
    cle: (e) => e.produit.code,
    permissions: permissionsSession(ref),
    messageVide: l10n.stkAucunExpire,
    texteRecherche: (e) => '${e.produit.code} ${e.produit.designation}',
    colonnes: [
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (e) => e.produit.code, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (e) => e.produit.designation, fort: true, flex: 3),
      DsColonne(
        id: 'dt',
        libelle: l10n.stkExpiration,
        valeur: (e) => e.produit.dateExpiration!,
        cellule: (_, e) => Text(formatDate.format(e.produit.dateExpiration!)),
      ),
      DsColonne(
        id: 'j',
        libelle: l10n.stkJours,
        numerique: true,
        valeur: (e) => e.jours,
        cellule: (context, e) => Text(
          e.jours < 0 ? l10n.stkExpireDepuis(-e.jours) : l10n.stkJMoins(e.jours),
          style: context.ds.typo.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: e.jours < 0 ? context.ds.colors.dangerFg : context.ds.colors.warningFg,
          ),
        ),
      ),
      DsColonne(
        id: 'q',
        libelle: l10n.stockColQuantite,
        numerique: true,
        valeur: (e) => e.stock,
        cellule: (_, e) => Text(formaterNombre(e.stock)),
      ),
      DsColonne(
        id: 'st',
        libelle: l10n.retoursEtat,
        valeur: (e) => e.jours,
        cellule: (_, e) => BadgeStatut(e.jours < 0 ? 'expire' : 'bientotExpire'),
      ),
    ],
    actions: [
      DsActionModule(
        cle: const ValueKey('expires_sortie'),
        libelle: l10n.stkSortiePerime,
        icone: LucideIcons.packageMinus,
        danger: true,
        onPressed: (choix, effacer) async {
          await afficherFormulaireSortie(context, ref, motif: 'Périmé', produits: [for (final e in choix) e.produit]);
          effacer();
        },
      ),
      DsActionModule(
        libelle: l10n.stkRetourFournisseur,
        icone: LucideIcons.undo2,
        regle: DsRegleSelection.une,
        onPressed: (choix, _) => afficherFormulaireRetour(context, ref, type: TypesTiers.fournisseur),
      ),
    ],
  );
}
