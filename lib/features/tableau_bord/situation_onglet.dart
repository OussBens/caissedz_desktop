import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/situation_repository.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../../domain/referentiel/wilayas.dart';
import '../commun/export_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_dialogs.dart';
import '../tiers/tiers_providers.dart';
import 'tableau_bord_page.dart';

/// Groupe d'analyses de la navigation de la Situation.
enum GroupeSituation { tresorerie, stock, ventes, marges, tiers }

/// Filtre proposé par une analyse.
enum FiltreSituation { caisse, typeCaisse, produit, magasin, caissier, categorie, client, regrouper, typeTiers, wilaya }

/// Déclaration d'une analyse (`SituationScreen.VIEWS`).
class AnalyseSituation {
  const AnalyseSituation(this.id, this.groupe, this.icone, this.filtres, {this.periode = true});
  final String id;
  final GroupeSituation groupe;
  final IconData icone;
  final List<FiltreSituation> filtres;
  final bool periode;

  static const List<AnalyseSituation> toutes = [
    AnalyseSituation('mvc', GroupeSituation.tresorerie, LucideIcons.wallet, [
      FiltreSituation.caisse,
      FiltreSituation.typeCaisse,
    ]),
    AnalyseSituation('mvp', GroupeSituation.stock, LucideIcons.arrowLeftRight, [
      FiltreSituation.produit,
      FiltreSituation.magasin,
    ]),
    AnalyseSituation('inv', GroupeSituation.stock, LucideIcons.clipboardCheck, [
      FiltreSituation.magasin,
      FiltreSituation.categorie,
    ], periode: false),
    AnalyseSituation('cout', GroupeSituation.stock, LucideIcons.tag, [FiltreSituation.categorie], periode: false),
    AnalyseSituation('rcp', GroupeSituation.ventes, LucideIcons.receiptText, [
      FiltreSituation.caisse,
      FiltreSituation.caissier,
    ]),
    AnalyseSituation('rcpr', GroupeSituation.ventes, LucideIcons.package, [
      FiltreSituation.categorie,
      FiltreSituation.caisse,
    ]),
    AnalyseSituation('mgp', GroupeSituation.marges, LucideIcons.percent, [
      FiltreSituation.caissier,
      FiltreSituation.client,
    ]),
    AnalyseSituation('mgper', GroupeSituation.marges, LucideIcons.chartColumn, [FiltreSituation.regrouper]),
    AnalyseSituation('scli', GroupeSituation.tiers, LucideIcons.users, [
      FiltreSituation.typeTiers,
      FiltreSituation.wilaya,
    ], periode: false),
    AnalyseSituation('sfrn', GroupeSituation.tiers, LucideIcons.truck, [
      FiltreSituation.typeTiers,
      FiltreSituation.wilaya,
    ], periode: false),
  ];
}

String libelleAnalyse(AppLocalizations l10n, String id) => switch (id) {
  'mvc' => l10n.situationMvc,
  'mvp' => l10n.situationMvp,
  'rcp' => l10n.situationRcp,
  'rcpr' => l10n.situationRcpr,
  'mgp' => l10n.situationMgp,
  'mgper' => l10n.situationMgper,
  'inv' => l10n.situationInv,
  'cout' => l10n.situationCout,
  'scli' => l10n.situationScli,
  'sfrn' => l10n.situationSfrn,
  _ => id,
};

String libelleGroupeSituation(AppLocalizations l10n, GroupeSituation g) => switch (g) {
  GroupeSituation.tresorerie => l10n.situationGroupeTresorerie,
  GroupeSituation.stock => l10n.situationGroupeStock,
  GroupeSituation.ventes => l10n.situationGroupeVentes,
  GroupeSituation.marges => l10n.situationGroupeMarges,
  GroupeSituation.tiers => l10n.situationGroupeTiers,
};

/// Onglet Situation du tableau de bord : navigation par groupes (220 px) et vue de l'analyse.
class SituationOnglet extends ConsumerStatefulWidget {
  const SituationOnglet({super.key});

  @override
  ConsumerState<SituationOnglet> createState() => _SituationOngletState();
}

class _SituationOngletState extends ConsumerState<SituationOnglet> {
  String _id = 'mvc';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final cout = ref.watch(sessionProvider)?.a(Permission.voirPrixAchat) ?? false;
    final analyses = [
      for (final a in AnalyseSituation.toutes)
        if (cout || !SituationRepository.analysesCout.contains(a.id)) a,
    ];
    final courante = analyses.firstWhere((a) => a.id == _id, orElse: () => analyses.first);
    final nav = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        for (final g in GroupeSituation.values)
          if (analyses.any((a) => a.groupe == g)) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 10, 4),
              child: Text(
                libelleGroupeSituation(l10n, g).toUpperCase(),
                style: t.overline.copyWith(color: c.textMuted),
              ),
            ),
            for (final a in analyses.where((a) => a.groupe == g))
              _EntreeNav(
                key: ValueKey('situation_nav_${a.id}'),
                libelle: libelleAnalyse(l10n, a.id),
                icone: a.icone,
                actif: a.id == courante.id,
                onTap: () => setState(() => _id = a.id),
              ),
          ],
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        SizedBox(width: 220, child: nav),
        Expanded(
          child: _VueAnalyse(key: ValueKey(courante.id), analyse: courante),
        ),
      ],
    );
  }
}

class _EntreeNav extends StatefulWidget {
  const _EntreeNav({super.key, required this.libelle, required this.icone, required this.actif, required this.onTap});
  final String libelle;
  final IconData icone;
  final bool actif;
  final VoidCallback onTap;

  @override
  State<_EntreeNav> createState() => _EntreeNavState();
}

class _EntreeNavState extends State<_EntreeNav> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final a = widget.actif;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DsMotion.fast,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: a ? c.surfaceCard : (_survol ? c.surfaceHover : DsColors.transparent),
            borderRadius: DsRadius.borderMd,
            border: Border.all(color: a ? c.borderDefault : DsColors.transparent),
            boxShadow: a ? DsShadows.xs : null,
          ),
          child: Row(
            spacing: 10,
            children: [
              Icon(widget.icone, size: 16, color: a ? c.iconActive : c.textSecondary),
              Expanded(
                child: Text(
                  widget.libelle,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(
                    fontSize: 13,
                    fontWeight: a ? FontWeight.w600 : FontWeight.w500,
                    color: a ? c.textPrimary : c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vue d'une analyse : carte de filtres (période, filtres, export), bandeau de stats, graphique, tableau.
class _VueAnalyse extends ConsumerStatefulWidget {
  const _VueAnalyse({super.key, required this.analyse});
  final AnalyseSituation analyse;

  @override
  ConsumerState<_VueAnalyse> createState() => _VueAnalyseState();
}

class _VueAnalyseState extends ConsumerState<_VueAnalyse> {
  DsPeriode _periode = DsPeriode.calculer('month');
  final Map<FiltreSituation, String?> _f = {};
  Regroupement _regroupement = Regroupement.jour;
  List<LigneSituation> _lignes = const [];
  bool _charge = false;
  int _version = -1;

  /// Quantités et pièces (2ᵉ stock) comptées (inventaire), par code produit.
  final Map<String, TextEditingController> _comptes = {};
  final Map<String, TextEditingController> _comptesNombre = {};

  String get _id => widget.analyse.id;

  @override
  void dispose() {
    for (final c in [..._comptes.values, ..._comptesNombre.values]) {
      c.dispose();
    }
    super.dispose();
  }

  FiltresSituation get _filtres => FiltresSituation(
    caisse: _f[FiltreSituation.caisse],
    typeMouvement: _f[FiltreSituation.typeCaisse],
    produit: _f[FiltreSituation.produit],
    magasin: _f[FiltreSituation.magasin],
    caissier: _f[FiltreSituation.caissier],
    categorie: _f[FiltreSituation.categorie],
    client: _f[FiltreSituation.client],
    regroupement: _regroupement,
  );

  Future<void> _charger() async {
    final r = ref.read(situationRepositoryProvider);
    final du = _periode.du, au = _periode.au;
    final f = _filtres;
    final lignes = switch (_id) {
      'mvc' => await r.mouvementCaisse(du, au, f),
      'mvp' => await r.mouvementProduit(du, au, f),
      'rcp' => await r.recetteParPanier(du, au, f),
      'rcpr' => await r.recetteParProduit(du, au, f),
      'mgp' => await r.margeParPanier(du, au, f),
      'mgper' => await r.margeParPeriode(du, au, f),
      'inv' => await r.inventaire(f),
      'cout' => await r.coutProduit(f),
      _ => const <LigneSituation>[],
    };
    if (!mounted) return;
    setState(() {
      _lignes = lignes;
      _charge = true;
      if (_id == 'inv') {
        for (final c in [..._comptes.values, ..._comptesNombre.values]) {
          c.dispose();
        }
        TextEditingController champ(LigneSituation l, String cle) =>
            TextEditingController(text: formaterNombre(l[cle]! as double, decimales: 2, grouper: false));
        _comptes
          ..clear()
          ..addAll({for (final l in lignes) l['code']! as String: champ(l, 'theorique')});
        _comptesNombre
          ..clear()
          ..addAll({for (final l in lignes) l['code']! as String: champ(l, 'theoriqueNombre')});
      }
    });
  }

  void _maj(VoidCallback f) {
    setState(f);
    unawaited(_charger());
  }

  /// Lignes des analyses de tiers, calculées depuis les statistiques des tiers.
  List<LigneSituation> _lignesTiers() {
    final client = _id == 'scli';
    final stats = ref.watch(client ? statsClientsProvider : statsFournisseursProvider).value ?? const {};
    final tiers = client
        ? [
            for (final c in ref.watch(clientsProvider).value ?? const <Client>[])
              LigneTiers.client(c, stats[c.code] ?? StatsTiers.vide),
          ]
        : [
            for (final f in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
              LigneTiers.fournisseur(f, stats[f.code] ?? StatsTiers.vide),
          ];
    return [
      for (final t in tiers)
        if ((_f[FiltreSituation.typeTiers] == null || t.fiche.type == _f[FiltreSituation.typeTiers]) &&
            (_f[FiltreSituation.wilaya] == null || t.fiche.wilaya == _f[FiltreSituation.wilaya]))
          {
            'code': t.code,
            'nom': t.nom,
            'type': t.fiche.type,
            'achats': t.stats.achats,
            'paye': t.stats.paye,
            'credit': t.stats.credit,
            'dernier': t.stats.dernier,
          },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final tiers = _id == 'scli' || _id == 'sfrn';
    // Recharge après toute écriture métier (ventes, stock, caisse).
    final version =
        ref.watch(rapportsVersionProvider) +
        ref.watch(commerceVersionProvider) +
        ref.watch(stockVersionProvider) +
        ref.watch(caisseVersionProvider);
    if (!tiers && version != _version) {
      _version = version.toInt();
      WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
    }
    final lignes = tiers ? _lignesTiers() : _lignes;
    final colonnes = _colonnes(l10n, devise);
    final inventaire = _id == 'inv';
    final filtresActifs = [
      for (final f in widget.analyse.filtres)
        if (f == FiltreSituation.regrouper ? _regroupement != Regroupement.jour : _f[f] != null) f,
    ];
    return DsModuleTable<LigneSituation>(
      cleTable: ValueKey('situation_table_$_id'),
      entite: libelleAnalyse(l10n, _id).toLowerCase(),
      lignes: lignes,
      colonnes: colonnes,
      cle: (r) => r['code'] ?? r['periode'] ?? '${r['date']}|${r['caisse']}|${r['type']}',
      kpis: [DsStatsStrip(items: _stats(l10n, devise, lignes))],
      periode: widget.analyse.periode ? _periode : null,
      onPeriode: (p) => _maj(() => _periode = p),
      filtresOuverts: true,
      colonnesFiltres: 3,
      nbFiltresActifs: filtresActifs.length,
      onReinitialiser: _reinitialiser,
      filtres: [
        for (final f in widget.analyse.filtres) _filtre(l10n, f),
        if (inventaire && _f[FiltreSituation.magasin] == null)
          DsSpan(
            child: Text(
              l10n.situationInventaireMagasin,
              style: context.ds.typo.caption.copyWith(color: context.ds.colors.textMuted),
            ),
          ),
      ],
      apresFiltres: _id == 'mgper' && lignes.isNotEmpty
          ? DsCarteGraphique(
              titre: l10n.situationMargeParPeriode,
              icone: LucideIcons.chartColumn,
              hauteur: 180,
              child: DsBarChart(
                miseEnAvant: lignes.length - 1,
                formater: (x) => formaterMontant(x, devise),
                donnees: [
                  for (final r in lignes)
                    DsDonnee(libelle: _periodeCourte(r['periode']! as String), valeur: r['marge']! as double),
                ],
              ),
            )
          : null,
      primaire: inventaire
          ? DsButton(
              key: const ValueKey('inventaire_valider'),
              libelle: l10n.situationValiderInventaire,
              icone: LucideIcons.checkCheck,
              onPressed: _f[FiltreSituation.magasin] == null ? null : _validerInventaire,
            )
          : null,
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: 'situation_$_id',
              titre: libelleAnalyse(l10n, _id),
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      afficherTotaux: colonnes.any((c) => c.total != null),
      permissions: permissionsSession(ref),
      messageVide: !_charge && !tiers ? l10n.dsChargement : l10n.dsAucunElement,
    );
  }

  /// « Effacer les filtres » : période du mois, aucun filtre, regroupement par jour.
  void _reinitialiser() => _maj(() {
    _periode = DsPeriode.calculer('month');
    _f.clear();
    _regroupement = Regroupement.jour;
  });

  String _periodeCourte(String p) => p.length == 10 ? '${p.substring(8, 10)}/${p.substring(5, 7)}' : p;

  Widget _filtre(AppLocalizations l10n, FiltreSituation f) {
    Widget select<T>(String libelle, List<T> options, String Function(T) nom, {String? tous}) => DsFormRow(
      libelle: libelle,
      largeurLibelle: 80,
      child: DsSelect<String?>(
        key: ValueKey('situation_filtre_${f.name}'),
        valeur: _f[f],
        options: [null, ...options.map((o) => _code(o))],
        libelle: (code) => code == null ? (tous ?? l10n.tiersTous) : nom(options.firstWhere((o) => _code(o) == code)),
        recherche: switch (f) {
          FiltreSituation.caisse => rechercheListe(context, ref, ListeMetier.caisse),
          FiltreSituation.produit => rechercheListe(context, ref, ListeMetier.produit),
          FiltreSituation.magasin => rechercheListe(context, ref, ListeMetier.magasin),
          FiltreSituation.caissier => rechercheListe(context, ref, ListeMetier.utilisateur),
          FiltreSituation.categorie => rechercheListe(context, ref, ListeMetier.categorie),
          FiltreSituation.client => rechercheListe(context, ref, ListeMetier.client),
          _ => null,
        },
        onChanged: (v) => _maj(() => _f[f] = v),
      ),
    );
    switch (f) {
      case FiltreSituation.caisse:
        return select<Caisse>(
          l10n.versementCaisse,
          ref.watch(caissesListeProvider).value ?? const [],
          (c) => c.nom,
          tous: l10n.tiersToutes,
        );
      case FiltreSituation.typeCaisse:
        return select<String>(l10n.tiersType, TypesMouvementCaisse.tous, (t) => t);
      case FiltreSituation.produit:
        return select<Produit>(
          l10n.tableauBordProduit,
          ref.watch(produitsProvider).value ?? const [],
          (p) => p.designation,
        );
      case FiltreSituation.magasin:
        return select<Magasin>(l10n.situationMagasin, ref.watch(magasinsProvider).value ?? const [], (m) => m.nom);
      case FiltreSituation.caissier:
        final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
        return select<String>(l10n.situationCaissier, noms.keys.toList(), (k) => noms[k] ?? k);
      case FiltreSituation.categorie:
        return select<Categorie>(
          l10n.situationCategorie,
          ref.watch(categoriesProvider).value ?? const [],
          (c) => c.nom,
          tous: l10n.tiersToutes,
        );
      case FiltreSituation.client:
        return select<Client>(l10n.tiersEntiteClientMaj, ref.watch(clientsProvider).value ?? const [], (c) => c.nom);
      case FiltreSituation.regrouper:
        return DsFormRow(
          libelle: l10n.situationRegrouper,
          largeurLibelle: 80,
          child: DsSelect<Regroupement>(
            valeur: _regroupement,
            options: Regroupement.values,
            libelle: (r) => switch (r) {
              Regroupement.jour => l10n.situationParJour,
              Regroupement.semaine => l10n.situationParSemaine,
              Regroupement.mois => l10n.situationParMois,
            },
            onChanged: (r) => _maj(() => _regroupement = r ?? Regroupement.jour),
          ),
        );
      case FiltreSituation.typeTiers:
        return DsFormRow(
          libelle: l10n.tiersType,
          largeurLibelle: 80,
          child: DsSelectReferentiel(
            liste: _id == 'scli' ? Referentiel.typesClient : Referentiel.typesFournisseur,
            valeur: _f[f],
            placeholder: l10n.tiersTous,
            onChanged: (v) => setState(() => _f[f] = v),
          ),
        );
      case FiltreSituation.wilaya:
        return DsFormRow(
          libelle: l10n.tiersWilaya,
          largeurLibelle: 80,
          child: DsSelectReferentiel(
            liste: wilayas,
            valeur: _f[f],
            placeholder: l10n.tiersToutes,
            onChanged: (v) => setState(() => _f[f] = v),
          ),
        );
    }
  }

  String _code(Object? o) => switch (o) {
    final Caisse c => c.code,
    final Produit p => p.code,
    final Magasin m => m.code,
    final Categorie c => c.code,
    final Client c => c.code,
    _ => o.toString(),
  };

  Future<void> _validerInventaire() async {
    final l10n = AppLocalizations.of(context);
    final magasin = _f[FiltreSituation.magasin]!;
    final comptes = <String, double>{
      for (final l in _lignes)
        if (lireNombre(_comptes[l['code']]?.text ?? '') case final q?)
          if ((q - (l['theorique']! as double)).abs() > 1e-9) l['code']! as String: q,
    };
    final pieces = <String, double>{
      for (final l in _lignes)
        if (lireNombre(_comptesNombre[l['code']]?.text ?? '') case final n?)
          if ((n - (l['theoriqueNombre']! as double)).abs() > 1e-9) l['code']! as String: n,
    };
    final produits = {...comptes.keys, ...pieces.keys};
    if (produits.isEmpty) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.info,
          titre: l10n.situationInv,
          message: l10n.situationAucunEcart,
        ),
      );
      return;
    }
    final ok = await afficherConfirmation(
      context,
      titre: l10n.situationValiderInventaire,
      message: l10n.situationConfirmerInventaire(produits.length),
    );
    if (ok != true || !mounted) return;
    final n = await ref
        .read(stockServiceProvider)
        .inventorierLot(magasinCode: magasin, quantitesConstatees: comptes, nombresConstates: pieces);
    ref.read(stockVersionProvider.notifier).incrementer();
    rafraichirRapports(ref);
    if (!mounted) return;
    afficherToast(context, titre: l10n.situationInventaireValide, description: l10n.situationProduitsAjustes(n));
  }

  // ------------------------------------------------------------ Colonnes et stats

  List<DsColonne<LigneSituation>> _colonnes(AppLocalizations l10n, String devise) {
    String da(Object? v) => formaterMontant((v as num? ?? 0).toDouble(), devise);
    String q(Object? v) => formaterNombre((v as num? ?? 0).toDouble(), decimales: 2);
    double s(List<LigneSituation> ls, String k) => ls.fold(0.0, (a, r) => a + ((r[k] as num?) ?? 0).toDouble());
    DsColonne<LigneSituation> texte(
      String id,
      String libelle, {
      bool fort = false,
      bool attenue = false,
      int flex = 1,
    }) => DsColonne(
      id: id,
      libelle: libelle,
      valeur: (r) => r[id] as Comparable?,
      fort: fort,
      attenue: attenue,
      flex: flex,
    );
    DsColonne<LigneSituation> montant(String id, String libelle, {bool total = true, bool danger = false}) => DsColonne(
      id: id,
      libelle: libelle,
      numerique: true,
      valeur: (r) => r[id] as Comparable?,
      cellule: (context, r) {
        final v = ((r[id] as num?) ?? 0).toDouble();
        if (v == 0) return const Text('—');
        return Text(
          da(v),
          style: danger ? TextStyle(fontWeight: FontWeight.w600, color: context.ds.colors.dangerFg) : null,
        );
      },
      total: total ? (ls) => da(s(ls, id)) : null,
    );
    DsColonne<LigneSituation> quantite(String id, String libelle, {bool total = false}) => DsColonne(
      id: id,
      libelle: libelle,
      numerique: true,
      valeur: (r) => r[id] as Comparable?,
      cellule: (_, r) => Text(q(r[id])),
      total: total ? (ls) => q(s(ls, id)) : null,
    );
    DsColonne<LigneSituation> date(String id, String libelle, {bool heure = false}) => DsColonne(
      id: id,
      libelle: libelle,
      attenue: true,
      valeur: (r) => r[id] as Comparable?,
      cellule: (_, r) => Text(r[id] == null ? '—' : (heure ? formatDateHeure : formatDate).format(r[id]! as DateTime)),
    );
    DsColonne<LigneSituation> taux(String id, String libelle) => DsColonne(
      id: id,
      libelle: libelle,
      numerique: true,
      valeur: (r) => r[id] as Comparable?,
      cellule: (context, r) {
        final v = r[id] as double?;
        if (v == null) return const Text('—');
        final c = context.ds.colors;
        return Text(
          '${formaterNombre(v, decimales: 1)} %',
          style: TextStyle(fontWeight: FontWeight.w600, color: v < 15 ? c.warningFg : c.successFg),
        );
      },
    );
    final code = texte('code', l10n.produitsColCode, attenue: true);
    return switch (_id) {
      'mvc' => [
        date('date', l10n.communDate),
        texte('caisse', l10n.versementCaisse),
        texte('type', l10n.tiersType, fort: true),
        montant('entrees', l10n.situationEntrees),
        montant('sorties', l10n.situationSorties),
      ],
      'mvp' => [
        code,
        texte('nom', l10n.tableauBordProduit, fort: true, flex: 2),
        quantite('initial', l10n.situationStockInitial),
        quantite('entrees', l10n.situationEntrees, total: true),
        quantite('sorties', l10n.situationSorties, total: true),
        quantite('retours', l10n.situationRetours, total: true),
        quantite('final', l10n.situationStockFinal),
      ],
      'rcp' => [
        texte('code', l10n.tableauBordPanier, attenue: true),
        date('date', l10n.communDate, heure: true),
        texte('client', l10n.tiersEntiteClientMaj, fort: true),
        texte('caissier', l10n.situationCaissier),
        montant('montant', l10n.versementMontant),
        montant('paye', l10n.situationPaye),
        montant('reste', l10n.tiersReste, danger: true),
      ],
      'rcpr' => [
        code,
        texte('nom', l10n.tableauBordProduit, fort: true, flex: 2),
        texte('categorie', l10n.situationCategorie),
        quantite('quantite', l10n.situationQuantite, total: true),
        montant('prixMoyen', l10n.situationPrixMoyen, total: false),
        montant('recette', l10n.situationRecette),
      ],
      'mgp' => [
        texte('code', l10n.tableauBordPanier, attenue: true),
        texte('client', l10n.tiersEntiteClientMaj, fort: true),
        montant('montant', l10n.situationVente),
        montant('cout', l10n.situationCoutLibelle),
        montant('marge', l10n.situationMarge),
        taux('taux', l10n.situationTaux),
        montant('retours', l10n.situationRetours),
        montant('casse', l10n.situationCasse, danger: true),
      ],
      'mgper' => [
        DsColonne(
          id: 'periode',
          libelle: switch (_regroupement) {
            Regroupement.jour => l10n.tableauBordJour,
            Regroupement.semaine => l10n.tableauBordSemaine,
            Regroupement.mois => l10n.tableauBordMois,
          },
          attenue: true,
          valeur: (r) => r['periode'] as Comparable?,
        ),
        montant('montant', l10n.situationCa),
        montant('cout', l10n.situationCoutLibelle),
        montant('marge', l10n.situationMarge),
        taux('taux', l10n.situationTaux),
        montant('retours', l10n.situationRetours),
        montant('casse', l10n.situationCasse, danger: true),
      ],
      'inv' => [
        code,
        texte('nom', l10n.tableauBordProduit, fort: true, flex: 2),
        quantite('theorique', l10n.situationTheorique),
        DsColonne(
          id: 'compte',
          libelle: l10n.situationCompte,
          numerique: true,
          triable: false,
          valeur: (r) => _comptes[r['code']]?.text,
          cellule: (_, r) => SizedBox(
            width: 100,
            child: DsTextField(
              key: ValueKey('inventaire_${r['code']}'),
              controller: _comptes[r['code']],
              numerique: true,
              taille: DsTailles.controleSm,
              alignement: TextAlign.end,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        DsColonne(
          id: 'ecart',
          libelle: l10n.situationEcart,
          numerique: true,
          triable: false,
          valeur: (r) => _ecart(r),
          cellule: (context, r) {
            final e = _ecart(r);
            final c = context.ds.colors;
            return Text(
              e == 0 ? '0' : '${e > 0 ? '+' : ''}${formaterNombre(e, decimales: 2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: e > 0 ? c.successFg : (e < 0 ? c.dangerFg : c.textSecondary),
              ),
            );
          },
        ),
        quantite('theoriqueNombre', l10n.situationPiecesTheoriques),
        DsColonne(
          id: 'compteNombre',
          libelle: l10n.situationPiecesComptees,
          numerique: true,
          triable: false,
          valeur: (r) => _comptesNombre[r['code']]?.text,
          cellule: (_, r) => SizedBox(
            width: 100,
            child: DsTextField(
              key: ValueKey('inventaire_nombre_${r['code']}'),
              controller: _comptesNombre[r['code']],
              numerique: true,
              taille: DsTailles.controleSm,
              alignement: TextAlign.end,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        DsColonne(
          id: 'valeur',
          libelle: l10n.situationValeur,
          numerique: true,
          permission: Permission.voirPrixAchat.code,
          valeur: (r) => r['valeur'] as Comparable?,
          cellule: (_, r) => Text(da(r['valeur'])),
          total: (ls) => da(s(ls, 'valeur')),
        ),
      ],
      'cout' => [
        code,
        texte('nom', l10n.tableauBordProduit, fort: true, flex: 2),
        montant('dernier', l10n.situationDernierAchat, total: false),
        montant('moyen', l10n.situationCmp, total: false),
        montant('min', l10n.situationMin, total: false),
        montant('max', l10n.situationMax, total: false),
        montant('prixVente', l10n.situationPrixVente, total: false),
        taux('taux', l10n.situationMarge),
      ],
      _ => [
        texte('nom', _id == 'scli' ? l10n.tiersEntiteClientMaj : l10n.tiersEntiteFournisseurMaj, fort: true, flex: 2),
        DsColonne(
          id: 'type',
          libelle: l10n.tiersType,
          valeur: (r) => libelleRef(
            context,
            _id == 'scli' ? Referentiel.typesClient : Referentiel.typesFournisseur,
            r['type']! as String,
          ),
        ),
        montant('achats', l10n.situationAchats),
        montant('paye', l10n.situationPaye),
        montant('credit', _id == 'scli' ? l10n.tiersCredit : l10n.situationDette, danger: true),
        date('dernier', _id == 'scli' ? l10n.tiersDernierAchat : l10n.tiersDerniereEntree),
      ],
    };
  }

  double _ecart(LigneSituation r) {
    final compte = lireNombre(_comptes[r['code']]?.text ?? '');
    return compte == null ? 0 : compte - (r['theorique']! as double);
  }

  double _ecartNombre(LigneSituation r) {
    final compte = lireNombre(_comptesNombre[r['code']]?.text ?? '');
    return compte == null ? 0 : compte - (r['theoriqueNombre']! as double);
  }

  List<DsStatItem> _stats(AppLocalizations l10n, String devise, List<LigneSituation> ls) {
    double s(String k) => ls.fold(0.0, (a, r) => a + ((r[k] as num?) ?? 0).toDouble());
    DsStatItem m(String libelle, double v, IconData icone, [DsBadgeTon? ton]) =>
        DsStatItem(libelle: libelle, valeur: f2(v), suffixe: devise, icone: icone, ton: ton);
    DsStatItem n(String libelle, num v, IconData icone, [DsBadgeTon? ton]) =>
        DsStatItem(libelle: libelle, valeur: formaterNombre(v.toDouble()), icone: icone, ton: ton);
    DsStatItem pct(String libelle, double cout, double marge) => DsStatItem(
      libelle: libelle,
      valeur: cout <= 0 ? '—' : '${formaterNombre(marge / cout * 100, decimales: 1)} %',
      icone: LucideIcons.percent,
      ton: DsBadgeTon.info,
    );
    return switch (_id) {
      'mvc' => [
        m(l10n.situationEntrees, s('entrees'), LucideIcons.arrowDownLeft, DsBadgeTon.succes),
        m(l10n.situationSorties, s('sorties'), LucideIcons.arrowUpRight, DsBadgeTon.danger),
        m(l10n.situationSoldeNet, s('entrees') - s('sorties'), LucideIcons.scale, DsBadgeTon.primaire),
      ],
      'mvp' => [
        n(l10n.situationEntrees, s('entrees'), LucideIcons.arrowDownLeft, DsBadgeTon.succes),
        n(l10n.situationSorties, s('sorties'), LucideIcons.arrowUpRight, DsBadgeTon.danger),
        n(l10n.situationRetours, s('retours'), LucideIcons.undo2, DsBadgeTon.avertissement),
      ],
      'rcp' => [
        n(l10n.situationPaniers, ls.length, LucideIcons.receiptText),
        m(l10n.situationRecette, s('montant'), LucideIcons.banknote, DsBadgeTon.succes),
        m(l10n.situationPanierMoyen, ls.isEmpty ? 0 : s('montant') / ls.length, LucideIcons.shoppingBasket),
      ],
      'rcpr' => [
        n(l10n.situationProduitsVendus, ls.length, LucideIcons.package),
        n(l10n.situationQuantite, s('quantite'), LucideIcons.hash),
        m(l10n.situationRecette, s('recette'), LucideIcons.banknote, DsBadgeTon.succes),
      ],
      'mgp' || 'mgper' => [
        m(l10n.situationCa, s('montant'), LucideIcons.banknote),
        m(l10n.situationCoutLibelle, s('cout'), LucideIcons.shoppingCart),
        m(l10n.situationMarge, s('marge'), LucideIcons.trendingUp, DsBadgeTon.succes),
        pct(l10n.situationTauxMoyen, s('cout'), s('marge')),
        m(l10n.situationRetours, s('retours'), LucideIcons.undo2, DsBadgeTon.avertissement),
        m(l10n.situationCasse, s('casse'), LucideIcons.packageX, DsBadgeTon.danger),
      ],
      'inv' => [
        n(l10n.situationProduitsComptes, ls.length, LucideIcons.clipboardCheck),
        n(
          l10n.situationEcarts,
          ls.where((r) => _ecart(r) != 0 || _ecartNombre(r) != 0).length,
          LucideIcons.triangleAlert,
          DsBadgeTon.avertissement,
        ),
        m(
          l10n.situationValeurEcart,
          ls.fold(0.0, (a, r) => a + _ecart(r) * (r['prixAchat']! as double)),
          LucideIcons.scale,
          DsBadgeTon.primaire,
        ),
      ],
      'cout' => [
        n(l10n.situationProduits, ls.length, LucideIcons.package),
        DsStatItem(
          libelle: l10n.situationMargeMoyenne,
          valeur: () {
            final t = [for (final r in ls) ?r['taux'] as double?];
            return t.isEmpty ? '—' : '${formaterNombre(t.reduce((a, b) => a + b) / t.length, decimales: 1)} %';
          }(),
          icone: LucideIcons.percent,
          ton: DsBadgeTon.info,
        ),
        n(
          l10n.situationSous15,
          ls.where((r) => ((r['taux'] as double?) ?? 100) < 15).length,
          LucideIcons.triangleAlert,
          DsBadgeTon.avertissement,
        ),
      ],
      _ => [
        n(
          _id == 'scli' ? l10n.moduleClients : l10n.moduleFournisseurs,
          ls.length,
          _id == 'scli' ? LucideIcons.users : LucideIcons.truck,
        ),
        m(l10n.situationAchats, s('achats'), LucideIcons.shoppingCart),
        m(
          _id == 'scli' ? l10n.situationCreditTotal : l10n.situationDettes,
          s('credit'),
          LucideIcons.handCoins,
          DsBadgeTon.avertissement,
        ),
      ],
    };
  }
}
