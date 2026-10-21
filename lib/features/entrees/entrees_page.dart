import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/achat_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/achat.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/permissions.dart';
import '../commun/chargement.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tableau_bord/tableau_bord_page.dart';
import '../tiers/tiers_providers.dart';
import 'entree_dialogs.dart';
import 'entrees_providers.dart';
import 'recu_ia_dialog.dart';

/// Écran Entrées (`EntreesScreen` du DS v2.2, §9.6) : onglets Entrée (bons d'achat) et Smart Scan (bons de
/// réception lus par l'IA) ; nouvelle entrée en 2 étapes, entrée rapide répartie, détail, modification, annulation.
class EntreesPage extends ConsumerStatefulWidget {
  const EntreesPage({super.key, this.ongletInitial = 0});

  /// 0 : Entrée, 1 : Smart Scan (factures lues par l'IA, photos envoyées par le téléphone).
  final int ongletInitial;

  @override
  ConsumerState<EntreesPage> createState() => _EntreesPageState();
}

class _EntreesPageState extends ConsumerState<EntreesPage> {
  late int _onglet = widget.ongletInitial;
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _fournisseur;
  String? _paiement;
  String? _magasin;
  String? _typeEntree;
  String? _produit;
  String? _statutBon;
  String? _fournisseurBon;
  String? _entreeBon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achats = ref.watch(achatsProvider).value ?? const <Achat>[];
    final bons = ref.watch(bonsReceptionProvider).value ?? const <BonReception>[];
    return PageModule(
      moduleId: 'entrees',
      onglets: [l10n.entOngletEntree, l10n.sourceSmartScan],
      comptes: [achats.length, bons.length],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0 ? _entrees(l10n, achats) : _bons(l10n, bons, achats),
    );
  }

  Widget _entrees(AppLocalizations l10n, List<Achat> toutes) {
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const <Fournisseur>[];
    final nomsFrn = {for (final f in fournisseurs) f.code: f.nom};
    final magasins = ref.watch(magasinsProvider).value ?? const <Magasin>[];
    final nomsMag = {for (final m in magasins) m.code: m.nom};
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final lignes = toutes
        .where(
          (a) =>
              dansPeriode(a.date, _periode) &&
              (_fournisseur == null || a.fournisseurCode == _fournisseur) &&
              (_paiement == null || a.statutPaiement == _paiement) &&
              (_magasin == null || a.magasinCode == _magasin) &&
              (_typeEntree == null || (a.source == SourcesAchat.rapide) == (_typeEntree == 'rapide')) &&
              (_produit == null || a.lignes.any((l) => l.produitCode == _produit)),
        )
        .toList();
    final actives = lignes.where((a) => a.actif).toList();
    final (duAvant, auAvant) = periodePrecedente(_periode.du, _periode.au);
    final avant = toutes.where((a) => a.actif && dansPeriode(a.date, DsPeriode(du: duAvant, au: auAvant))).toList();
    double somme(Iterable<Achat> as, double Function(Achat) f) => as.fold(0.0, (x, a) => x + f(a));
    double? tendance(double v, double avant) => avant <= 0 ? null : (v - avant) / avant * 100;
    final totalAchats = somme(actives, (a) => a.total);
    final reste = somme(actives, (a) => a.reste);
    final peutAnnuler = ref.watch(sessionProvider)?.a(Permission.annulerOperations) ?? false;

    final colonnes = <DsColonne<Achat>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (a) => a.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (a) => a.date,
        cellule: (_, a) => Text(formatDateHeure.format(a.date)),
      ),
      DsColonne(
        id: 'frn',
        libelle: l10n.achatFournisseur,
        fort: true,
        flex: 2,
        valeur: (a) => nomsFrn[a.fournisseurCode] ?? a.fournisseurCode,
      ),
      DsColonne(id: 'ref', libelle: l10n.entNumFacture, attenue: true, valeur: (a) => a.reference ?? ''),
      DsColonne(
        id: 'n',
        libelle: l10n.stkArticles,
        numerique: true,
        valeur: (a) => a.lignes.length,
        total: (as) => '${as.fold(0, (x, a) => x + a.lignes.length)}',
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.retoursMontant,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: (a) => a.total,
        cellule: (_, a) => Text(da(a.total)),
        total: (as) => da(somme(as.where((a) => a.actif), (a) => a.total)),
      ),
      DsColonne(
        id: 'reste',
        libelle: l10n.achatColReste,
        numerique: true,
        permission: Permission.voirPrixAchat.code,
        valeur: (a) => a.reste,
        cellule: (ctx, a) => a.reste > 0.005
            ? Text(
                da(a.reste),
                style: ctx.ds.typo.bodySm.copyWith(fontWeight: FontWeight.w600, color: ctx.ds.colors.warningFg),
              )
            : const Text('—'),
        total: (as) => da(somme(as.where((a) => a.actif), (a) => a.reste)),
      ),
      DsColonne(id: 'mag', libelle: l10n.stockColMagasin, valeur: (a) => nomsMag[a.magasinCode] ?? a.magasinCode),
      DsColonne(
        id: 'statut',
        libelle: l10n.achatColStatut,
        valeur: (a) => a.statutPaiement,
        cellule: (_, a) => BadgeStatut(a.statutPaiement),
      ),
      DsColonne(
        id: 'verse',
        libelle: l10n.achatColVerse,
        numerique: true,
        visibleParDefaut: false,
        permission: Permission.voirPrixAchat.code,
        valeur: (a) => a.verse,
        cellule: (_, a) => Text(da(a.verse)),
      ),
      DsColonne(
        id: 'nbv',
        libelle: l10n.entNbVersements,
        numerique: true,
        visibleParDefaut: false,
        valeur: (a) => a.nbVersements,
      ),
      DsColonne(
        id: 'source',
        libelle: l10n.achatColSource,
        visibleParDefaut: false,
        valeur: (a) => libelleSourceAchat(l10n, a),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (a) => a.commentaire ?? '',
      ),
      DsColonne(
        id: 'annule_par',
        libelle: l10n.ventesAnnulePar,
        visibleParDefaut: false,
        valeur: (a) => a.annulation == null ? '' : (utilisateurs[a.annulation!.par] ?? a.annulation!.par),
      ),
      DsColonne(
        id: 'motif_annulation',
        libelle: l10n.ventesMotifAnnulation,
        visibleParDefaut: false,
        valeur: (a) => a.annulation?.motif ?? '',
      ),
      ...colonnesAudit(context, ref, (Achat x) => x.audit),
    ];

    return DsModuleTable<Achat>(
      entite: l10n.entEntitePluriel,
      lignes: lignes,
      chargement: enChargement(ref.watch(achatsProvider)),
      colonnes: colonnes,
      cle: (a) => a.code,
      afficherTotaux: true,
      permissions: permissionsSession(ref),
      messageVide: l10n.achatAucun,
      kpis: [
        DsStatCard(libelle: l10n.entKpiEntrees, valeur: '${actives.length}', icone: LucideIcons.packagePlus),
        DsStatCard(
          libelle: l10n.tiersTotalAchats,
          valeur: f2(totalAchats),
          suffixe: devise,
          icone: LucideIcons.shoppingCart,
          tendance: tendance(totalAchats, somme(avant, (a) => a.total)),
        ),
        DsStatCard(
          libelle: l10n.entPaye,
          valeur: f2(somme(actives, (a) => a.verse)),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
        DsStatCard(
          libelle: l10n.entResteCredit,
          valeur: f2(reste),
          suffixe: devise,
          icone: LucideIcons.handCoins,
          tendance: tendance(reste, somme(avant, (a) => a.reste)),
          tendanceInverser: true,
        ),
      ],
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      periodeSeule: true,
      indiceRecherche: l10n.entRecherche,
      texteRecherche: (a) => '${a.code} ${nomsFrn[a.fournisseurCode] ?? ''} ${a.reference ?? ''}',
      nbFiltresActifs: [_typeEntree, _fournisseur, _paiement, _magasin, _produit].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _typeEntree = null;
        _fournisseur = null;
        _paiement = null;
        _magasin = null;
        _produit = null;
        _periode = DsPeriode.calculer('month');
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.entFiltreType,
          child: DsSelect<String?>(
            cle: const ValueKey('entrees_filtre_type'),
            valeur: _typeEntree,
            options: const [null, 'normale', 'rapide'],
            libelle: (t) => switch (t) {
              null => l10n.retoursTous,
              'rapide' => l10n.entRapideTitre,
              _ => l10n.entTypeNormale,
            },
            onChanged: (v) => setState(() => _typeEntree = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.achatFournisseur,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            valeur: _fournisseur,
            options: [null, for (final f in fournisseurs) f.code],
            libelle: (c) => c == null ? l10n.retoursTous : (nomsFrn[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
            onChanged: (v) => setState(() => _fournisseur = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.entPaiement,
          largeurLibelle: 90,
          child: DsSelect<String?>(
            cle: const ValueKey('entrees_filtre_paiement'),
            valeur: _paiement,
            options: const [null, 'paye', 'partiel', 'credit', 'annule'],
            libelle: (s) => s == null ? l10n.retoursTous : libelleStatut(l10n, s),
            onChanged: (v) => setState(() => _paiement = v),
          ),
        ),
        if (ref.watch(plusieursMagasinsProvider))
          DsFormRow(
            libelle: l10n.stockColMagasin,
            largeurLibelle: 90,
            child: DsSelect<String?>(
              valeur: _magasin,
              options: [null, for (final m in magasins) m.code],
              libelle: (c) => c == null ? l10n.retoursTous : (nomsMag[c] ?? c),
              recherche: rechercheListe(context, ref, ListeMetier.magasin),
              onChanged: (v) => setState(() => _magasin = v),
            ),
          ),
        filtreProduit(
          context,
          ref,
          cle: const ValueKey('entrees_filtre_produit'),
          valeur: _produit,
          onChanged: (v) => setState(() => _produit = v),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, as) => exporterTableau(
              context,
              ref,
              id: 'entrees',
              titre: l10n.entEntitePluriel,
              colonnes: colonnes,
              lignes: as,
              format: format,
            )
          : null,
      onOuvrir: (a) => afficherDetailEntree(context, ref, a),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailEntree(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('entrees_liste_produits'),
          libelle: l10n.stkListeProduits,
          icone: LucideIcons.listOrdered,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => afficherProduitsEntree(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('entrees_modifier'),
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          iconeSeule: true,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && !choix.first.actif,
          onPressed: (choix, _) => modifierEntree(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('entrees_annuler'),
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.x,
          iconeSeule: true,
          danger: true,
          desactive: (_) => !peutAnnuler,
          onPressed: (choix, effacer) => annulerEntrees(context, ref, choix, effacer),
        ),
      ],
      secondaire: DsButton(
        key: const ValueKey('entree_rapide'),
        libelle: l10n.entRapideTitre,
        icone: LucideIcons.zap,
        variante: DsButtonVariante.secondaire,
        onPressed: () => afficherEntreeRapide(context, ref),
      ),
      primaire: DsButton(
        key: const ValueKey('entree_nouvelle'),
        libelle: l10n.achatNouveau,
        icone: LucideIcons.scanLine,
        onPressed: () => afficherFormulaireEntree(context, ref),
      ),
    );
  }

  Widget _bons(AppLocalizations l10n, List<BonReception> tous, List<Achat> achats) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const <Fournisseur>[];
    final nomsFrn = {for (final f in fournisseurs) f.code: f.nom};
    final quota = ref.watch(quotaSmartScanProvider);
    String frn(BonReception b) =>
        b.fournisseurCode != null ? (nomsFrn[b.fournisseurCode] ?? b.fournisseurCode!) : (b.fournisseurDetecte ?? '—');
    final lignes = tous
        .where(
          (b) =>
              (_statutBon == null || b.statut == _statutBon) &&
              (_fournisseurBon == null || b.fournisseurCode == _fournisseurBon) &&
              (_entreeBon == null || b.achatCode == _entreeBon),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsTailles.gridGap,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: DsColors.gradientNight, borderRadius: DsRadius.borderXl),
                  child: Row(
                    spacing: 16,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DsColors.blanc.withValues(alpha: .12),
                          borderRadius: DsRadius.borderLg,
                        ),
                        child: const Icon(LucideIcons.sparkles, size: 24, color: DsColors.blanc),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 2,
                          children: [
                            Text(
                              l10n.entIaBandeauTitre,
                              style: t.cardTitle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: DsColors.blanc,
                              ),
                            ),
                            Text(
                              l10n.entIaBandeauDetail,
                              style: t.bodySm.copyWith(color: DsColors.blanc.withValues(alpha: .8)),
                            ),
                          ],
                        ),
                      ),
                      DsButton(
                        key: const ValueKey('ia_joindre'),
                        libelle: l10n.entIaJoindre,
                        icone: LucideIcons.fileUp,
                        onPressed: () => afficherRecuIA(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 320,
                child: DsQuotaCard(
                  utilises: quota.value?.utilise ?? 0,
                  limite: quota.value?.total ?? 0,
                  horsLigne: quota.hasError,
                  onActualiser: () => ref.invalidate(quotaSmartScanProvider),
                ),
              ),
            ],
          ),
        ),
        DsModuleTable<BonReception>(
          entite: l10n.entEntiteBons,
          lignes: lignes,
          chargement: enChargement(ref.watch(bonsReceptionProvider)),
          cle: (b) => b.code,
          permissions: permissionsSession(ref),
          messageVide: l10n.entAucunBon,
          indiceRecherche: l10n.entRechercheBons,
          texteRecherche: (b) => '${b.code} ${b.fichier} ${frn(b)}',
          nbFiltresActifs: [_statutBon, _fournisseurBon, _entreeBon].where((f) => f != null).length,
          onReinitialiser: () => setState(() {
            _statutBon = null;
            _fournisseurBon = null;
            _entreeBon = null;
          }),
          filtres: [
            DsFormRow(
              libelle: l10n.achatColStatut,
              largeurLibelle: 90,
              child: DsSelect<String?>(
                valeur: _statutBon,
                options: const [null, ...StatutsBon.tous],
                libelle: (s) => s == null ? l10n.retoursTous : libelleStatut(l10n, _statutDsBon(s)),
                onChanged: (v) => setState(() => _statutBon = v),
              ),
            ),
            DsFormRow(
              libelle: l10n.achatFournisseur,
              largeurLibelle: 90,
              child: DsSelect<String?>(
                valeur: _fournisseurBon,
                options: [null, for (final f in fournisseurs) f.code],
                libelle: (code) => code == null ? l10n.retoursTous : (nomsFrn[code] ?? code),
                recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
                onChanged: (v) => setState(() => _fournisseurBon = v),
              ),
            ),
            DsFormRow(
              libelle: l10n.entEntreeLiee,
              largeurLibelle: 90,
              child: DsSelect<String?>(
                valeur: _entreeBon,
                options: [null, for (final b in tous) ?b.achatCode],
                libelle: (code) => code ?? l10n.tiersToutes,
                onChanged: (v) => setState(() => _entreeBon = v),
              ),
            ),
          ],
          colonnes: [
            DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (b) => b.code, attenue: true),
            DsColonne(
              id: 'date',
              libelle: l10n.entRecuLe,
              attenue: true,
              valeur: (b) => b.date,
              cellule: (_, b) => Text(formatDateHeure.format(b.date)),
            ),
            DsColonne(id: 'fichier', libelle: l10n.entFichier, fort: true, flex: 2, valeur: (b) => b.fichier),
            DsColonne(id: 'frn', libelle: l10n.entFournisseurDetecte, flex: 2, valeur: frn),
            DsColonne(id: 'n', libelle: l10n.entIaLignes, numerique: true, valeur: (b) => b.lignes.length),
            DsColonne(id: 'entree', libelle: l10n.entEntite, attenue: true, valeur: (b) => b.achatCode ?? '—'),
            DsColonne(
              id: 'statut',
              libelle: l10n.achatColStatut,
              valeur: (b) => b.statut,
              cellule: (_, b) => BadgeStatut(b.statutDs),
            ),
            DsColonne(
              id: 'obs',
              libelle: l10n.retoursObservation,
              visibleParDefaut: false,
              valeur: (b) => b.commentaire ?? '',
            ),
            ...colonnesAudit(context, ref, (BonReception x) => x.audit),
          ],
          onOuvrir: (b) => afficherBon(context, ref, b),
          actions: [
            DsActionModule(
              cle: const ValueKey('bons_traiter'),
              libelle: l10n.entIaTraiter,
              icone: LucideIcons.sparkles,
              regle: DsRegleSelection.une,
              // En violet, tout à droite : l'action phare de Smart Scan.
              genre: DsGenreAction.principale,
              desactive: (choix) => choix.isNotEmpty && choix.first.statut == StatutsBon.traite,
              onPressed: (choix, _) => afficherRecuIA(context, ref, bon: choix.first),
            ),
            DsActionModule(
              libelle: l10n.entIaVoirBon,
              icone: LucideIcons.image,
              regle: DsRegleSelection.une,
              detail: true,
              onPressed: (choix, _) => afficherBon(context, ref, choix.first),
            ),
            DsActionModule(
              cle: const ValueKey('bons_supprimer'),
              libelle: l10n.communSupprimer,
              icone: LucideIcons.trash2,
              danger: true,
              onPressed: (choix, effacer) => _supprimerBons(l10n, choix, effacer, frn),
            ),
          ],
        ),
        if (lignes.isEmpty && tous.isEmpty)
          Text(
            l10n.entIaVideAide,
            style: t.bodySm.copyWith(color: c.textMuted),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  static String _statutDsBon(String s) => switch (s) {
    StatutsBon.traite => 'traite',
    StatutsBon.erreur => 'erreur',
    _ => 'recu',
  };

  Future<void> _supprimerBons(
    AppLocalizations l10n,
    List<BonReception> choix,
    VoidCallback effacer,
    String Function(BonReception) frn,
  ) async {
    final ok = await afficherActionLot(
      context,
      action: DsActionLot.supprimer,
      entite: l10n.entEntiteBon,
      entitePluriel: l10n.entEntiteBons,
      elements: [
        for (final b in choix)
          DsElementLot(
            id: b.code,
            titre: '${b.code} · ${b.fichier}',
            sousTitre: frn(b),
            motifBlocage: b.statut == StatutsBon.traite ? l10n.entErreurBonTraite : null,
          ),
      ],
    );
    if (ok == null || !mounted) return;
    try {
      await ref.read(achatServiceProvider).supprimerBons([
        for (final b in choix)
          if (b.statut != StatutsBon.traite) b.code,
      ]);
      rafraichirEntrees(ref);
      effacer();
      if (mounted) {
        afficherToast(context, titre: l10n.entToastBonsSupprimes, description: l10n.entToastBonsDetail(choix.length));
      }
    } on AchatException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.entEntiteBons,
          message: messageErreurAchat(l10n, e.erreur),
        ),
      );
    }
  }
}
