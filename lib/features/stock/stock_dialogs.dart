import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/doc_form.dart';
import '../commun/export_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';
import 'stock_providers.dart';

const double _lw = 112;

/// Quantité signée colorée (`qCell` du DS) : vert si entrée, rouge si sortie.
class QuantiteSignee extends StatelessWidget {
  const QuantiteSignee(this.valeur, {super.key});
  final double valeur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    return Text(
      valeur > 0 ? '+${formaterNombre(valeur)}' : formaterNombre(valeur),
      style: context.ds.typo.bodySm.copyWith(fontWeight: FontWeight.w600, color: valeur > 0 ? c.successFg : c.dangerFg),
    );
  }
}

bool voitPrixAchat(WidgetRef ref) => ref.read(sessionProvider)?.a(Permission.voirPrixAchat) ?? false;

/// Exécute une écriture de stock ; affiche l'erreur métier et renvoie `false` en cas d'échec.
Future<bool> executerStock(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    rafraichirStock(ref);
    return true;
  } on StockException catch (e) {
    if (context.mounted) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.stockTitre,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
    return false;
  }
}

/// Libellés localisés du `SplitAllocator`.
Map<String, String> libellesRepartition(AppLocalizations l10n) => {
  'total': l10n.communTotal,
  'reparti': l10n.stkReparti,
  'reste': l10n.stkReste,
  'principal': l10n.stkPrincipal,
  'enStock': l10n.stkEnStock,
  'toutPrincipal': l10n.stkToutPrincipal,
  'repartir': l10n.stkRepartirEgalement,
  'restePrincipal': l10n.stkRestePrincipal,
};

Map<String, String> _nomsMagasins(List<Magasin> ms) => {for (final m in ms) m.code: m.nom};

// ———————————————————————————— Stock ————————————————————————————

/// Détail du stock d'un produit (`StockDetailDialog` 1000 px) : stats, répartition par magasin, mouvements récents.
Future<void> afficherDetailStock(BuildContext context, WidgetRef ref, Produit p) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final magasins = await ref.read(magasinsProvider.future);
  final parMagasin = (await ref.read(stocksParMagasinProvider.future))[p.code] ?? const {};
  final mouvements = (await ref.read(mouvementsProvider.future)).where((m) => m.produitCode == p.code).take(5).toList();
  final seuilGlobal = (await ref.read(parametresVenteProvider.future)).seuilStockGlobal;
  if (!context.mounted) return;
  final achat = voitPrixAchat(ref);
  final total = parMagasin.values.fold(0.0, (a, b) => a + b);
  final noms = _nomsMagasins(magasins);
  final lignes = [
    for (final m in magasins)
      if (m.actif || (parMagasin[m.code] ?? 0) != 0) (m, parMagasin[m.code] ?? 0.0),
  ];
  final unite = l10n.stkPcs;
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 1000,
      icone: LucideIcons.boxes,
      titre: p.designation,
      description: p.code,
      stats: [
        DsStatItem(
          libelle: l10n.stkStockTotal,
          valeur: formaterNombre(total),
          suffixe: unite,
          icone: LucideIcons.boxes,
        ),
        DsStatItem(
          libelle: l10n.stkSeuilAlerte,
          valeur: '${seuilDe(p, seuilGlobal)}',
          suffixe: unite,
          icone: LucideIcons.bell,
        ),
        if (achat)
          DsStatItem(
            libelle: l10n.stkValeurAchat,
            valeur: f2(total * p.prixAchat),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
        DsStatItem(
          libelle: l10n.stkValeurVente,
          valeur: f2(total * p.prixVente),
          suffixe: devise,
          icone: LucideIcons.tag,
          ton: DsBadgeTon.succes,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.stkRepartition,
          icone: LucideIcons.store,
          nbLignes: lignes.length,
          tableau: DsDataTable<(Magasin, double)>(
            dense: true,
            encadre: false,
            pagine: false,
            afficherTotaux: true,
            cle: (l) => l.$1.code,
            lignes: lignes,
            colonnes: [
              DsColonne(id: 'nom', libelle: l10n.stockColMagasin, valeur: (l) => l.$1.nom, fort: true, flex: 3),
              DsColonne(
                id: 'q',
                libelle: l10n.stockColQuantite,
                numerique: true,
                valeur: (l) => l.$2,
                cellule: (_, l) => Text(formaterNombre(l.$2)),
                total: (ls) => formaterNombre(ls.fold(0.0, (s, l) => s + l.$2)),
              ),
              if (achat)
                DsColonne(
                  id: 'v',
                  libelle: l10n.stockColValeur,
                  numerique: true,
                  valeur: (l) => l.$2 * p.prixAchat,
                  cellule: (_, l) => Text(formaterMontant(l.$2 * p.prixAchat, devise)),
                  total: (ls) => formaterMontant(ls.fold(0.0, (s, l) => s + l.$2 * p.prixAchat), devise),
                ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.stkMouvementsRecents,
          icone: LucideIcons.arrowLeftRight,
          nbLignes: mouvements.length,
          tableau: DsDataTable<MouvementStock>(
            dense: true,
            encadre: false,
            pagine: false,
            cle: (m) => m.id ?? m.hashCode,
            lignes: mouvements,
            messageVide: l10n.stockAucunMouvement,
            colonnes: [
              DsColonne(
                id: 'd',
                libelle: l10n.communDate,
                attenue: true,
                valeur: (m) => m.date,
                cellule: (_, m) => Text(formatDateHeure.format(m.date)),
              ),
              DsColonne(id: 't', libelle: l10n.stockColType, valeur: (m) => libelleTypeMouvement(l10n, m.type)),
              DsColonne(id: 'r', libelle: l10n.stkReference, attenue: true, valeur: (m) => m.referenceCode ?? ''),
              DsColonne(id: 'mag', libelle: l10n.stockColMagasin, valeur: (m) => noms[m.magasinCode] ?? m.magasinCode),
              DsColonne(
                id: 'q',
                libelle: l10n.stkQte,
                numerique: true,
                valeur: (m) => m.quantite,
                cellule: (_, m) => QuantiteSignee(m.quantite),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Distribution du stock d'un produit entre les magasins (`DistributionDialog` 680 px, licence Avancé).
Future<void> afficherDistribution(BuildContext context, WidgetRef ref, Produit p) async {
  final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
  final parMagasin = (await ref.read(stocksParMagasinProvider.future))[p.code] ?? const {};
  final principal = await ref.read(magasinPrincipalProvider.future);
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    fermableParVoile: false,
    builder: (_) => _DistributionDialog(p, magasins, parMagasin, principal),
  );
}

class _DistributionDialog extends ConsumerStatefulWidget {
  const _DistributionDialog(this.produit, this.magasins, this.stocks, this.principal);
  final Produit produit;
  final List<Magasin> magasins;
  final Map<String, double> stocks;
  final String principal;

  @override
  ConsumerState<_DistributionDialog> createState() => _DistributionDialogState();
}

class _DistributionDialogState extends ConsumerState<_DistributionDialog> {
  late Map<String, double> _valeur = {for (final m in widget.magasins) m.code: widget.stocks[m.code] ?? 0};
  final _motif = TextEditingController();
  bool _occupe = false;

  double get _total => widget.stocks.values.fold(0.0, (a, b) => a + b);
  double get _deplace =>
      widget.magasins.fold(0.0, (a, m) => a + ((_valeur[m.code] ?? 0) - (widget.stocks[m.code] ?? 0)).clamp(0, 1e12));

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final ok = await executerStock(
      context,
      ref,
      () => ref.read(stockServiceProvider).distribuer(widget.produit.code, cible: _valeur, motif: _motif.text),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      afficherToast(
        context,
        titre: l10n.stkToastDistribue,
        description: widget.produit.designation,
        ton: DsToastTon.succes,
      );
    } else {
      setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final equilibre = DsSplitAllocator.equilibre(_total, _valeur);
    final deplace = _deplace;
    return DsDialog(
      titre: l10n.stkDistribuerTitre,
      iconeData: LucideIcons.split,
      description: l10n.stkDistribuerDescription(widget.produit.designation, formaterNombre(_total)),
      largeur: 680,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('distribution_valider'),
          libelle: deplace > 0 ? l10n.stkTransfererPieces(formaterNombre(deplace)) : l10n.stkAucunChangement,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: equilibre && deplace > 0 ? _valider : null,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsSplitAllocator(
            total: _total,
            unite: l10n.stkPcs,
            magasins: [
              for (final m in widget.magasins)
                DsMagasinRepartition(
                  code: m.code,
                  nom: m.nom,
                  principal: m.code == widget.principal,
                  stock: widget.stocks[m.code] ?? 0,
                ),
            ],
            valeur: _valeur,
            onChanged: (v) => setState(() => _valeur = v),
            libelles: libellesRepartition(l10n),
          ),
          DsFormRow(
            libelle: l10n.stkMotif,
            child: DsTextField(controller: _motif, indice: l10n.stkMotifDistributionIndice),
          ),
        ],
      ),
    );
  }
}

// ———————————————————————————— Sorties ————————————————————————————

/// Formulaire de sortie (`SortieFormDialog`, DocForm) : code, date, type, magasin, motif ; lignes
/// produit / stock / quantité / prix d'achat ; quantité plafonnée au stock du magasin.
Future<void> afficherFormulaireSortie(
  BuildContext context,
  WidgetRef ref, {
  SortieStock? sortie,
  String? motif,
  List<Produit> produits = const [],
}) async {
  final catalogue = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final principal = await ref.read(magasinPrincipalProvider.future);
  final stocks = await ref.read(stocksParMagasinProvider.future);
  final nombreGlobal = (await ref.read(parametresVenteProvider.future)).nombreActif;
  if (!context.mounted) return;
  final lignes = sortie != null
      ? [
          for (final l in sortie.lignes)
            if (catalogue[l.produitCode] != null)
              LigneDoc(produit: catalogue[l.produitCode]!, quantite: l.quantite, prix: l.prix, nombre: l.nombre),
        ]
      : proposerNombres([
          for (final p in produits)
            LigneDoc(produit: p, quantite: (stocks[p.code]?[principal] ?? 0) > 0 ? stocks[p.code]![principal]! : 1),
        ], global: nombreGlobal);
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _SortieForm(sortie, lignes, principal, motif),
  );
}

class _SortieForm extends ConsumerStatefulWidget {
  const _SortieForm(this.sortie, this.lignesInitiales, this.principal, this.motif);
  final SortieStock? sortie;
  final List<LigneDoc> lignesInitiales;
  final String principal;
  final String? motif;

  @override
  ConsumerState<_SortieForm> createState() => _SortieFormState();
}

class _SortieFormState extends ConsumerState<_SortieForm> {
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  late DateTime? _date = widget.sortie?.date ?? DateTime.now();
  late String _type = widget.sortie?.motif ?? widget.motif ?? Referentiel.motifsSortie.valeurs.first.stocke;
  late String _magasin = widget.sortie?.magasinCode ?? widget.principal;
  late final _motif = TextEditingController(text: widget.sortie?.commentaire ?? '');

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  /// Disponible = stock du magasin + ce que la sortie modifiée en a déjà retiré.
  double _dispo(String produit, Map<String, Map<String, double>> stocks) {
    final s = widget.sortie;
    final deja = s != null && s.magasinCode == _magasin
        ? s.lignes.where((l) => l.produitCode == produit).fold(0.0, (a, l) => a + l.quantite)
        : 0.0;
    return (stocks[produit]?[_magasin] ?? 0) + deja;
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final s = ref.read(stockServiceProvider);
    final lignes = [
      for (final l in _lignes)
        LigneStock(produitCode: l.produit.code, quantite: l.quantite, nombre: l.nombre, prix: l.prix),
    ];
    final commentaire = _motif.text.trim().isEmpty ? null : _motif.text.trim();
    final ok = await executerStock(context, ref, () async {
      if (widget.sortie == null) {
        await s.sortir(magasinCode: _magasin, motif: _type, lignes: lignes, commentaire: commentaire, date: _date);
      } else {
        await s.modifierSortie(
          widget.sortie!.code,
          magasinCode: _magasin,
          motif: _type,
          lignes: lignes,
          commentaire: commentaire,
          date: _date,
        );
      }
    });
    if (ok && mounted) {
      afficherToast(context, titre: l10n.stkToastSortie, description: l10n.stkToastStockAJour, ton: DsToastTon.succes);
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final stocks = ref.watch(stocksParMagasinProvider).value ?? const {};
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[])
        .where((m) => m.actif || m.code == _magasin)
        .toList();
    final erreurs = <Object, Map<String, String>>{
      for (final l in _lignes)
        if (l.quantite > _dispo(l.produit.code, stocks) + 1e-9)
          l.produit.code: {'qte': l10n.stkStockDispo(formaterNombre(_dispo(l.produit.code, stocks)))},
    };
    return DocFormDialog(
      titre: widget.sortie == null ? l10n.stkNouvelleSortie : l10n.stkModifierSortie,
      icone: LucideIcons.packageMinus,
      description: widget.sortie?.code ?? l10n.stkSortieDescription,
      cleEnregistrer: const ValueKey('sortie_enregistrer'),
      saisieNombre: true,
      lignes: _lignes,
      onLignes: (l) => setState(() => _lignes = l),
      erreurs: erreurs,
      peutEnregistrer: _date != null && _lignes.every((l) => l.quantite > 0),
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * l.prix,
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
          id: 'stock',
          libelle: l10n.produitsColStock,
          numerique: true,
          largeur: 80,
          valeur: (l) => formaterNombre(_dispo(l.produit.code, stocks)),
        ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.stkQte,
          numerique: true,
          editable: true,
          largeur: 96,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'prix',
          libelle: l10n.produitsColPrixAchat,
          numerique: true,
          valeur: (l) => formaterMontant(l.prix, devise),
        ),
      ],
      entete: [
        DsFormRow(
          libelle: l10n.produitsColCode,
          largeurLibelle: _lw,
          child: DsTextField(valeurInitiale: widget.sortie?.code ?? l10n.prdCodeAuto, actif: false),
        ),
        DsFormRow(
          libelle: l10n.communDate,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d)),
        ),
        DsFormRow(
          libelle: l10n.stockColType,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String>(
            cle: const ValueKey('sortie_type'),
            valeur: _type,
            options: [for (final v in Referentiel.motifsSortie.valeurs) v.stocke],
            libelle: (v) => libelleMotif(l10n, v),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
        ),
        DsFormRow(
          libelle: l10n.stockColMagasin,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String>(
            cle: const ValueKey('sortie_magasin'),
            valeur: _magasin,
            options: [for (final m in magasins) m.code],
            libelle: (c) => magasins.where((m) => m.code == c).firstOrNull?.nom ?? c,
            recherche: rechercheListe(context, ref, ListeMetier.magasin),
            onChanged: (v) => setState(() => _magasin = v ?? _magasin),
          ),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.stkMotif,
            largeurLibelle: _lw,
            alignerDebut: true,
            child: DsTextField(controller: _motif, multiligne: true, lignes: 2, indice: l10n.stkMotifSortieIndice),
          ),
        ),
      ],
    );
  }
}

Widget _tableLignes(
  AppLocalizations l10n,
  List<LigneStock> lignes,
  Map<String, Produit> produits,
  String devise, {
  required bool prix,
  String? libelleQte,
  String? libellePrix,
}) => DsDataTable<LigneStock>(
  dense: true,
  encadre: false,
  pagine: false,
  hauteurMax: 320,
  cle: (l) => l.produitCode,
  lignes: lignes,
  colonnes: [
    DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
    DsColonne(
      id: 'nom',
      libelle: l10n.dsPosProduit,
      valeur: (l) => produits[l.produitCode]?.designation ?? l.produitCode,
      fort: true,
      flex: 3,
    ),
    DsColonne(
      id: 'qte',
      libelle: libelleQte ?? l10n.stkQte,
      numerique: true,
      valeur: (l) => l.quantite,
      cellule: (_, l) => Text(formaterNombre(l.quantite)),
    ),
    if (prix)
      DsColonne(
        id: 'prix',
        libelle: libellePrix ?? l10n.produitsColPrixAchat,
        numerique: true,
        valeur: (l) => l.prix,
        cellule: (_, l) => Text(formaterMontant(l.prix, devise)),
      ),
  ],
);

/// Détail d'une sortie (`EntityDetailDialog` 940 px).
Future<void> afficherDetailSortie(BuildContext context, WidgetRef ref, SortieStock s) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final noms = _nomsMagasins(await ref.read(magasinsProvider.future));
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final achat = voitPrixAchat(ref);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.packageMinus,
      titre: l10n.stkSortieTitre(s.code),
      description:
          '${formatDate.format(s.date)} · ${libelleMotif(l10n, s.motif)} · ${noms[s.magasinCode] ?? s.magasinCode}',
      badges: [BadgeStatut(s.actif ? 'actif' : 'annule')],
      onModifier: () => afficherFormulaireSortie(context, ref, sortie: s),
      modifierDesactive: !s.actif,
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${s.lignes.length}', icone: LucideIcons.package),
        if (achat)
          DsStatItem(
            libelle: l10n.stockColValeur,
            valeur: f2(s.valeur),
            suffixe: devise,
            icone: LucideIcons.wallet,
            ton: DsBadgeTon.danger,
          ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.stkProduitsSortis,
          icone: LucideIcons.package,
          nbLignes: s.lignes.length,
          tableau: _tableLignes(l10n, s.lignes, produits, devise, prix: achat),
        ),
        DsSectionDetail(
          titre: l10n.stkMotif,
          icone: LucideIcons.messageSquareText,
          contenu: Text(s.commentaire ?? '—', style: context.ds.typo.body),
        ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: _audit(l10n, s.utilisateurCode, s.date, s.annulation, utilisateurs),
        ),
      ],
    ),
  );
}

List<DsKeyValue> _audit(
  AppLocalizations l10n,
  String creePar,
  DateTime date,
  Annulation? annulation,
  Map<String, String> utilisateurs,
) => [
  DsKeyValue(l10n.ventesCreePar, utilisateurs[creePar] ?? creePar),
  DsKeyValue(l10n.stkValideLe, formatDateHeure.format(date)),
  if (annulation != null) ...[
    DsKeyValue(l10n.ventesAnnulePar, utilisateurs[annulation.par] ?? annulation.par),
    DsKeyValue(l10n.ventesMotifAnnulation, annulation.motif),
  ],
];

/// Annulation en lot des sorties (motif obligatoire ; le stock est réintégré).
Future<void> annulerSorties(BuildContext context, WidgetRef ref, List<SortieStock> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final noms = _nomsMagasins(await ref.read(magasinsProvider.future));
  if (!context.mounted) return;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.stkEntiteSortie,
    entitePluriel: l10n.stkEntiteSorties,
    motifRequis: true,
    elements: [
      for (final s in choix)
        DsElementLot(
          id: s.code,
          titre: '${s.code} · ${libelleMotif(l10n, s.motif)}',
          sousTitre: noms[s.magasinCode] ?? s.magasinCode,
          meta: formaterMontant(s.valeur, devise),
          motifBlocage: s.actif ? null : l10n.stkBloqueDejaAnnulee,
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final ok = await executerStock(
    context,
    ref,
    () => ref.read(stockServiceProvider).annulerSorties([
      for (final s in choix.where((s) => s.actif)) s.code,
    ], motif: motif),
  );
  effacer();
  if (ok && context.mounted) {
    afficherToast(context, titre: l10n.stkToastSortiesAnnulees, description: l10n.stkToastStockReintegre);
  }
}

// ———————————————————————————— Transferts ————————————————————————————

/// Formulaire de transfert (`TransfertFormDialog`, DocForm) : depuis / vers, lignes avec disponible source.
Future<void> afficherFormulaireTransfert(BuildContext context, WidgetRef ref, {TransfertStock? transfert}) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final principal = await ref.read(magasinPrincipalProvider.future);
  final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
  if (!context.mounted) return;
  final lignes = [
    for (final l in transfert?.lignes ?? const <LigneStock>[])
      if (produits[l.produitCode] != null)
        LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite, nombre: l.nombre),
  ];
  final destination =
      transfert?.magasinDestination ?? magasins.where((m) => m.code != principal).firstOrNull?.code ?? principal;
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _TransfertForm(transfert, lignes, transfert?.magasinSource ?? principal, destination),
  );
}

class _TransfertForm extends ConsumerStatefulWidget {
  const _TransfertForm(this.transfert, this.lignesInitiales, this.source, this.destination);
  final TransfertStock? transfert;
  final List<LigneDoc> lignesInitiales;
  final String source;
  final String destination;

  @override
  ConsumerState<_TransfertForm> createState() => _TransfertFormState();
}

class _TransfertFormState extends ConsumerState<_TransfertForm> {
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  late DateTime? _date = widget.transfert?.date ?? DateTime.now();
  late String _source = widget.source;
  late String _destination = widget.destination;
  late final _observation = TextEditingController(text: widget.transfert?.commentaire ?? '');

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  double _dispo(String produit, Map<String, Map<String, double>> stocks) {
    final t = widget.transfert;
    final deja = t != null && t.magasinSource == _source
        ? t.lignes.where((l) => l.produitCode == produit).fold(0.0, (a, l) => a + l.quantite)
        : 0.0;
    return (stocks[produit]?[_source] ?? 0) + deja;
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final s = ref.read(stockServiceProvider);
    final lignes = [
      for (final l in _lignes) LigneStock(produitCode: l.produit.code, quantite: l.quantite, nombre: l.nombre),
    ];
    final obs = _observation.text.trim().isEmpty ? null : _observation.text.trim();
    String code = widget.transfert?.code ?? '';
    final ok = await executerStock(context, ref, () async {
      if (widget.transfert == null) {
        code = (await s.transferer(
          magasinSource: _source,
          magasinDestination: _destination,
          lignes: lignes,
          commentaire: obs,
          date: _date,
        )).code;
      } else {
        await s.modifierTransfert(
          code,
          magasinSource: _source,
          magasinDestination: _destination,
          lignes: lignes,
          commentaire: obs,
          date: _date,
        );
      }
    });
    if (ok && mounted) {
      afficherToast(context, titre: l10n.stkToastTransfert, description: code, ton: DsToastTon.succes);
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final stocks = ref.watch(stocksParMagasinProvider).value ?? const {};
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    final meme = _source == _destination;
    final erreurs = <Object, Map<String, String>>{
      for (final l in _lignes)
        if (l.quantite > _dispo(l.produit.code, stocks) + 1e-9)
          l.produit.code: {'qte': l10n.stkDisponible(formaterNombre(_dispo(l.produit.code, stocks)))},
    };
    String nom(String c) => magasins.where((m) => m.code == c).firstOrNull?.nom ?? c;
    return DocFormDialog(
      titre: widget.transfert == null ? l10n.stkNouveauTransfert : l10n.stkModifierTransfert,
      icone: LucideIcons.truck,
      description: widget.transfert?.code ?? l10n.stkTransfertDescription,
      cleEnregistrer: const ValueKey('transfert_enregistrer'),
      libelleEnregistrer: l10n.stkValiderTransfert,
      saisieNombre: true,
      lignes: _lignes,
      onLignes: (l) => setState(() => _lignes = l),
      erreurs: erreurs,
      peutEnregistrer: !meme && _date != null && _lignes.every((l) => l.quantite > 0),
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * l.prix,
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
          id: 'stock',
          libelle: l10n.stkDispoSource,
          numerique: true,
          largeur: 110,
          valeur: (l) => formaterNombre(_dispo(l.produit.code, stocks)),
        ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.stkQte,
          numerique: true,
          editable: true,
          largeur: 96,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'prix',
          libelle: l10n.produitsColPrixAchat,
          numerique: true,
          valeur: (l) => formaterMontant(l.prix, devise),
        ),
      ],
      entete: [
        DsFormRow(
          libelle: l10n.produitsColCode,
          largeurLibelle: _lw,
          child: DsTextField(valeurInitiale: widget.transfert?.code ?? l10n.prdCodeAuto, actif: false),
        ),
        DsFormRow(
          libelle: l10n.communDate,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d)),
        ),
        DsFormRow(
          libelle: l10n.stkDepuis,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String>(
            cle: const ValueKey('transfert_source'),
            valeur: _source,
            options: [for (final m in magasins) m.code],
            libelle: nom,
            recherche: rechercheListe(context, ref, ListeMetier.magasin),
            onChanged: (v) => setState(() => _source = v ?? _source),
          ),
        ),
        DsFormRow(
          libelle: l10n.stkVers,
          obligatoire: true,
          largeurLibelle: _lw,
          erreur: meme ? l10n.stkMagasinDifferent : null,
          child: DsSelect<String>(
            cle: const ValueKey('transfert_destination'),
            valeur: _destination,
            options: [for (final m in magasins) m.code],
            libelle: nom,
            recherche: rechercheListe(context, ref, ListeMetier.magasin),
            onChanged: (v) => setState(() => _destination = v ?? _destination),
          ),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.retoursObservation,
            largeurLibelle: _lw,
            child: DsTextField(controller: _observation, indice: l10n.stkObservationTransfertIndice),
          ),
        ),
      ],
    );
  }
}

/// Détail d'un transfert (`EntityDetailDialog` 940 px).
Future<void> afficherDetailTransfert(BuildContext context, WidgetRef ref, TransfertStock t) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final noms = _nomsMagasins(await ref.read(magasinsProvider.future));
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final achat = voitPrixAchat(ref);
  final lignes = [
    for (final l in t.lignes)
      LigneStock(produitCode: l.produitCode, quantite: l.quantite, prix: produits[l.produitCode]?.prixAchat ?? 0),
  ];
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.truck,
      titre: l10n.stkTransfertTitre(t.code),
      description:
          '${formatDate.format(t.date)} · ${noms[t.magasinSource] ?? t.magasinSource} → '
          '${noms[t.magasinDestination] ?? t.magasinDestination}',
      badges: [BadgeStatut(t.actif ? 'valide' : 'annule')],
      onModifier: () => afficherFormulaireTransfert(context, ref, transfert: t),
      modifierDesactive: !t.actif,
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${t.lignes.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.stockColQuantite, valeur: formaterNombre(t.quantite), icone: LucideIcons.boxes),
        if (achat)
          DsStatItem(
            libelle: l10n.stockColValeur,
            valeur: f2(lignes.fold(0.0, (s, l) => s + l.montant)),
            suffixe: devise,
            icone: LucideIcons.wallet,
          ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.stkProduitsTransferes,
          icone: LucideIcons.package,
          nbLignes: lignes.length,
          tableau: _tableLignes(l10n, lignes, produits, devise, prix: achat),
        ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: _audit(l10n, t.utilisateurCode, t.date, t.annulation, utilisateurs),
        ),
      ],
    ),
  );
}

/// Annulation en lot des transferts (motif obligatoire ; chaque magasin récupère ce qui en est sorti).
Future<void> annulerTransferts(
  BuildContext context,
  WidgetRef ref,
  List<TransfertStock> choix,
  VoidCallback effacer,
) async {
  final l10n = AppLocalizations.of(context);
  final noms = _nomsMagasins(await ref.read(magasinsProvider.future));
  if (!context.mounted) return;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.stkEntiteTransfert,
    entitePluriel: l10n.stkEntiteTransferts,
    motifRequis: true,
    elements: [
      for (final t in choix)
        DsElementLot(
          id: t.code,
          titre: t.code,
          sousTitre:
              '${noms[t.magasinSource] ?? t.magasinSource} → ${noms[t.magasinDestination] ?? t.magasinDestination}',
          motifBlocage: t.actif ? null : l10n.stkBloqueDejaAnnule,
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final ok = await executerStock(
    context,
    ref,
    () => ref.read(stockServiceProvider).annulerTransferts([
      for (final t in choix.where((t) => t.actif)) t.code,
    ], motif: motif),
  );
  effacer();
  if (ok && context.mounted) afficherToast(context, titre: l10n.stkToastTransfertsAnnules);
}

// ———————————————————————————— Magasins ————————————————————————————

/// Formulaire magasin (`MagasinFormDialog` 640 px).
Future<void> afficherFormulaireMagasin(BuildContext context, WidgetRef ref, {Magasin? magasin}) =>
    afficherDialog<void>(context, fermableParVoile: false, builder: (_) => _MagasinForm(magasin));

class _MagasinForm extends ConsumerStatefulWidget {
  const _MagasinForm(this.magasin);
  final Magasin? magasin;

  @override
  ConsumerState<_MagasinForm> createState() => _MagasinFormState();
}

class _MagasinFormState extends ConsumerState<_MagasinForm> {
  late final _nom = TextEditingController(text: widget.magasin?.nom ?? '');
  late final _adresse = TextEditingController(text: widget.magasin?.adresse ?? '');
  late final _telephone = TextEditingController(text: widget.magasin?.telephone ?? '');
  late final _observation = TextEditingController(text: widget.magasin?.observation ?? '');
  late String? _responsable = widget.magasin?.responsableCode;
  late bool _actif = widget.magasin?.actif ?? true;
  bool _occupe = false;
  String? _erreurNom;

  @override
  void dispose() {
    _nom.dispose();
    _adresse.dispose();
    _telephone.dispose();
    _observation.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _occupe = true;
      _erreurNom = null;
    });
    final s = ref.read(stockServiceProvider);
    try {
      if (widget.magasin == null) {
        await s.creerMagasin(
          _nom.text,
          adresse: _adresse.text,
          telephone: _telephone.text,
          responsableCode: _responsable,
          observation: _observation.text,
        );
      } else {
        await s.modifierMagasin(
          widget.magasin!.copyWith(
            nom: _nom.text.trim(),
            adresse: _adresse.text.trim(),
            telephone: _telephone.text.trim(),
            responsableCode: () => _responsable,
            observation: _observation.text.trim(),
            actif: _actif,
          ),
        );
      }
      rafraichirStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(context, titre: l10n.stkToastMagasin, ton: DsToastTon.succes);
    } on StockException catch (e) {
      if (!mounted) return;
      setState(() {
        _occupe = false;
        _erreurNom = messageErreurStock(l10n, e.erreur);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final utilisateurs = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    final m = widget.magasin;
    return DsDialog(
      titre: m == null ? l10n.stkNouveauMagasin : l10n.stkModifierMagasin,
      iconeData: LucideIcons.store,
      description: m?.code ?? l10n.stkMagasinDescription,
      largeur: 640,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('magasin_enregistrer'),
          libelle: l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: _nom.text.trim().isEmpty ? null : _enregistrer,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          DsFormRow(
            libelle: l10n.produitsColCode,
            child: DsTextField(valeurInitiale: m?.code ?? l10n.prdCodeAuto, actif: false),
          ),
          DsFormRow(
            libelle: l10n.stkNom,
            obligatoire: true,
            erreur: _erreurNom,
            child: DsTextField(
              key: const ValueKey('magasin_nom'),
              controller: _nom,
              autofocus: true,
              indice: l10n.stkNomMagasinIndice,
              onChanged: (_) => setState(() => _erreurNom = null),
            ),
          ),
          DsFormRow(
            libelle: l10n.stkAdresse,
            alignerDebut: true,
            child: DsTextField(controller: _adresse, multiligne: true, lignes: 2),
          ),
          DsFormRow(
            libelle: l10n.stkTelephone,
            child: DsTextField(controller: _telephone, indice: '0xx xx xx xx', typeClavier: TextInputType.phone),
          ),
          DsFormRow(
            libelle: l10n.stkResponsable,
            child: DsSelect<String?>(
              valeur: _responsable,
              options: [null, ...utilisateurs.keys],
              libelle: (c) => c == null ? l10n.stkAucun : (utilisateurs[c] ?? c),
              recherche: rechercheListe(context, ref, ListeMetier.utilisateur),
              onChanged: (v) => setState(() => _responsable = v),
            ),
          ),
          DsFormRow(
            libelle: l10n.retoursObservation,
            child: DsTextField(controller: _observation),
          ),
          if (m != null)
            DsFormRow(
              libelle: l10n.retoursEtat,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: DsSwitch(
                  valeur: _actif,
                  libelle: _actif ? l10n.statutActif : l10n.statutInactif,
                  actif: !m.systeme,
                  onChanged: (v) => setState(() => _actif = v),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Détail d'un magasin (`EntityDetailDialog` 1000 px) : stock du magasin, utilisateurs et caisses.
Future<void> afficherDetailMagasin(BuildContext context, WidgetRef ref, Magasin m) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = await ref.read(produitsProvider.future);
  final stocks = await ref.read(stocksParMagasinProvider.future);
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  final rattaches = (await ref.read(utilisateursParMagasinProvider.future))[m.code] ?? const [];
  final caisses = (await ref.read(caissesParMagasinProvider.future))[m.code] ?? const [];
  final transferts = (await ref.read(transfertsProvider.future))
      .where((t) => t.magasinSource == m.code || t.magasinDestination == m.code)
      .length;
  if (!context.mounted) return;
  final achat = voitPrixAchat(ref);
  final enStock = [
    for (final p in produits)
      if ((stocks[p.code]?[m.code] ?? 0) != 0) (p, stocks[p.code]![m.code]!),
  ];
  final valeur = enStock.fold(0.0, (s, l) => s + l.$2 * l.$1.prixAchat);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 1000,
      icone: LucideIcons.store,
      titre: m.nom,
      description: m.adresse.isEmpty ? m.code : '${m.code} · ${m.adresse}',
      badges: [BadgeStatut(m.actif ? 'actif' : 'inactif')],
      onModifier: () => afficherFormulaireMagasin(context, ref, magasin: m),
      stats: [
        DsStatItem(libelle: l10n.stkProduitsEnStock, valeur: '${enStock.length}', icone: LucideIcons.package),
        if (achat)
          DsStatItem(libelle: l10n.stkValeurStock, valeur: f2(valeur), suffixe: devise, icone: LucideIcons.wallet),
        DsStatItem(libelle: l10n.stkUtilisateurs, valeur: '${rattaches.length}', icone: LucideIcons.users),
        DsStatItem(libelle: l10n.stkOngletTransferts, valeur: '$transferts', icone: LucideIcons.truck),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.stkStockDuMagasin,
          icone: LucideIcons.boxes,
          nbLignes: enStock.length,
          tableau: DsDataTable<(Produit, double)>(
            dense: true,
            encadre: false,
            pagine: false,
            hauteurMax: 240,
            cle: (l) => l.$1.code,
            lignes: enStock,
            messageVide: l10n.dsAucunElement,
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.$1.code, attenue: true),
              DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.$1.designation, fort: true, flex: 3),
              DsColonne(
                id: 'q',
                libelle: l10n.stockColQuantite,
                numerique: true,
                valeur: (l) => l.$2,
                cellule: (_, l) => Text(formaterNombre(l.$2)),
              ),
              if (achat)
                DsColonne(
                  id: 'v',
                  libelle: l10n.stockColValeur,
                  numerique: true,
                  valeur: (l) => l.$2 * l.$1.prixAchat,
                  cellule: (_, l) => Text(formaterMontant(l.$2 * l.$1.prixAchat, devise)),
                ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.stkUtilisateursCaisses,
          icone: LucideIcons.users,
          items: [
            DsKeyValue(
              l10n.stkResponsable,
              m.responsableCode == null ? '—' : (utilisateurs[m.responsableCode] ?? m.responsableCode),
            ),
            DsKeyValue(
              l10n.stkUtilisateurs,
              rattaches.isEmpty ? '—' : rattaches.map((u) => utilisateurs[u] ?? u).join(', '),
            ),
            DsKeyValue(l10n.stkCaisses, caisses.isEmpty ? '—' : caisses.join(', ')),
          ],
        ),
      ],
    ),
  );
}

/// Désactivation en lot (`BulkActionDialog` deactivate) : bloquée pour un magasin principal ou avec du stock.
Future<void> desactiverMagasins(BuildContext context, WidgetRef ref, List<Magasin> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final service = ref.read(stockServiceProvider);
  final valeurs = await _valeursMagasins(ref);
  final blocages = {for (final m in choix) m.code: await service.blocageDesactivation(m)};
  if (!context.mounted) return;
  String? motif(Magasin m) {
    if (!m.actif) return l10n.stkBloqueDejaInactif;
    return switch (blocages[m.code]) {
      ErreurStock.magasinSysteme => l10n.stockErreurMagasinSysteme,
      ErreurStock.magasinPrincipal => l10n.stkBloqueMagasinPrincipal,
      ErreurStock.stockNonNul => l10n.stkBloqueStockNonNul,
      _ => null,
    };
  }

  final ok = await afficherActionLot(
    context,
    action: DsActionLot.desactiver,
    entite: l10n.stkEntiteMagasin,
    entitePluriel: l10n.stkEntiteMagasins,
    elements: [
      for (final m in choix)
        DsElementLot(
          id: m.code,
          titre: m.nom,
          sousTitre: m.code,
          meta: formaterMontant(valeurs[m.code] ?? 0, devise),
          motifBlocage: motif(m),
        ),
    ],
  );
  if (ok == null || !context.mounted) return;
  final codes = [
    for (final m in choix)
      if (motif(m) == null) m.code,
  ];
  final fait = await executerStock(context, ref, () => service.changerEtatMagasins(codes, actif: false));
  effacer();
  if (fait && context.mounted) afficherToast(context, titre: l10n.stkToastMagasinsDesactives);
}

/// Valeur d'achat du stock par magasin.
Future<Map<String, double>> _valeursMagasins(WidgetRef ref) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final stocks = await ref.read(stocksParMagasinProvider.future);
  final r = <String, double>{};
  for (final MapEntry(key: p, value: parMagasin) in stocks.entries) {
    for (final MapEntry(key: m, value: q) in parMagasin.entries) {
      r[m] = (r[m] ?? 0) + q * (produits[p]?.prixAchat ?? 0);
    }
  }
  return r;
}

// ———————————————————————————— Besoins ————————————————————————————

/// Formulaire de liste de besoins (`BesoinFormDialog`, DocForm) : fournisseur, livraison souhaitée ; lignes
/// stock / à commander / prix estimé. Les produits proposés sont pré-remplis avec la suggestion 2 × seuil − stock.
Future<void> afficherFormulaireBesoin(
  BuildContext context,
  WidgetRef ref, {
  Besoin? besoin,
  List<Produit> proposes = const [],
}) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final stocks = await ref.read(stocksProduitsProvider.future);
  final parametres = await ref.read(parametresVenteProvider.future);
  final seuilGlobal = parametres.seuilStockGlobal;
  if (!context.mounted) return;
  final lignes = besoin != null
      ? [
          for (final l in besoin.lignes)
            if (produits[l.produitCode] != null)
              LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite, prix: l.prix),
        ]
      : [
          for (final p in proposes)
            LigneDoc(
              produit: p,
              quantite: StockService.suggestion(
                stocks[p.code] ?? 0,
                seuilDe(p, seuilGlobal),
                maximum: parametres.seuilStockMax,
              ),
            ),
        ];
  final fournisseur = besoin?.fournisseurCode ?? proposes.map((p) => p.fournisseurCode).nonNulls.firstOrNull;
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _BesoinForm(besoin, lignes, fournisseur),
  );
}

class _BesoinForm extends ConsumerStatefulWidget {
  const _BesoinForm(this.besoin, this.lignesInitiales, this.fournisseur);
  final Besoin? besoin;
  final List<LigneDoc> lignesInitiales;
  final String? fournisseur;

  @override
  ConsumerState<_BesoinForm> createState() => _BesoinFormState();
}

class _BesoinFormState extends ConsumerState<_BesoinForm> {
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  late DateTime? _date = widget.besoin?.date ?? DateTime.now();
  late DateTime? _livraison = widget.besoin?.dateLivraison;
  late String? _fournisseur = widget.fournisseur;
  late final _observation = TextEditingController(text: widget.besoin?.observation ?? '');

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final s = ref.read(stockServiceProvider);
    final lignes = [
      for (final l in _lignes) LigneStock(produitCode: l.produit.code, quantite: l.quantite, prix: l.prix),
    ];
    final obs = _observation.text.trim().isEmpty ? null : _observation.text.trim();
    var code = widget.besoin?.code ?? '';
    final ok = await executerStock(context, ref, () async {
      if (widget.besoin == null) {
        code = (await s.creerBesoin(
          fournisseurCode: _fournisseur!,
          lignes: lignes,
          date: _date,
          dateLivraison: _livraison,
          observation: obs,
        )).code;
      } else {
        await s.modifierBesoin(
          code,
          fournisseurCode: _fournisseur!,
          lignes: lignes,
          date: _date,
          dateLivraison: _livraison,
          observation: obs,
        );
      }
    });
    if (ok && mounted) {
      afficherToast(
        context,
        titre: l10n.stkToastListe,
        description: l10n.stkToastListeDesc(code),
        ton: DsToastTon.succes,
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final stocks = ref.watch(stocksProduitsProvider).value ?? const <String, double>{};
    final fournisseurs = (ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        .where((f) => f.actif || f.code == _fournisseur)
        .toList();
    final b = widget.besoin;
    final c = context.ds.colors;
    return DocFormDialog(
      titre: b == null ? l10n.stkNouvelleListe : l10n.stkModifierListe,
      icone: LucideIcons.clipboardList,
      description: b == null
          ? l10n.stkListeDescription
          : '${b.code} · ${fournisseurs.where((f) => f.code == b.fournisseurCode).firstOrNull?.nom ?? b.fournisseurCode}',
      cleEnregistrer: const ValueKey('besoin_enregistrer'),
      libelleEnregistrer: l10n.stkEnregistrerListe,
      lignes: _lignes,
      onLignes: (l) => setState(() => _lignes = l),
      peutEnregistrer: _fournisseur != null && _date != null && _lignes.every((l) => l.quantite > 0),
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * l.prix,
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
          id: 'stock',
          libelle: l10n.produitsColStock,
          numerique: true,
          largeur: 80,
          valeur: (l) => formaterNombre(stocks[l.produit.code] ?? 0),
          cellule: (context, l) {
            final s = stocks[l.produit.code] ?? 0;
            return Text(
              formaterNombre(s),
              style: context.ds.typo.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: s <= 0 ? c.dangerFg : c.warningFg,
              ),
            );
          },
        ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.stkACommander,
          numerique: true,
          editable: true,
          largeur: 116,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'prix',
          libelle: l10n.stkPrixEstime,
          numerique: true,
          editable: true,
          largeur: 140,
          suffixe: devise,
          valeur: (l) => texteQuantite(l.prix),
          onEdition: (l, v) => setState(() => l.prix = nombreSaisi(v)),
        ),
      ],
      entete: [
        DsFormRow(
          libelle: l10n.produitsColCode,
          largeurLibelle: _lw,
          child: DsTextField(valeurInitiale: b?.code ?? l10n.prdCodeAuto, actif: false),
        ),
        DsFormRow(
          libelle: l10n.communDate,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d)),
        ),
        DsFormRow(
          libelle: l10n.retoursFournisseur,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String?>(
            cle: const ValueKey('besoin_fournisseur'),
            valeur: _fournisseur,
            placeholder: l10n.stkChoisirFournisseur,
            options: [for (final f in fournisseurs) f.code],
            libelle: (c) => fournisseurs.where((f) => f.code == c).firstOrNull?.nom ?? (c ?? ''),
            recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
            onChanged: (v) => setState(() => _fournisseur = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.stkLivraison,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _livraison, onChanged: (d) => setState(() => _livraison = d)),
        ),
        DsSpan(
          child: DsFormRow(
            libelle: l10n.retoursObservation,
            largeurLibelle: _lw,
            child: DsTextField(controller: _observation),
          ),
        ),
      ],
    );
  }
}

/// Détail d'une liste de besoins (`EntityDetailDialog` 960 px) avec « PDF fournisseur ».
Future<void> afficherDetailBesoin(BuildContext context, WidgetRef ref, Besoin b) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final fournisseurs = {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final nomFrn = fournisseurs[b.fournisseurCode] ?? b.fournisseurCode;
  final colonnesPdf = <DsColonne<LigneStock>>[
    DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode),
    DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => produits[l.produitCode]?.designation ?? ''),
    DsColonne(id: 'qte', libelle: l10n.stkACommander, numerique: true, valeur: (l) => l.quantite),
    DsColonne(id: 'prix', libelle: l10n.stkPrixEstime, numerique: true, valeur: (l) => l.prix),
    DsColonne(id: 'montant', libelle: l10n.retoursMontant, numerique: true, valeur: (l) => l.montant),
  ];
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 960,
      icone: LucideIcons.clipboardList,
      titre: l10n.stkListeTitre(b.code),
      description: '${formatDate.format(b.date)} · $nomFrn',
      badges: [BadgeStatut(statutBesoinDs(b))],
      onModifier: () => afficherFormulaireBesoin(context, ref, besoin: b),
      modifierDesactive: !b.actif || b.statut == StatutsBesoin.disponible,
      piedSupplementaire: [
        DsButton(
          libelle: l10n.stkPdfFournisseur,
          icone: LucideIcons.fileDown,
          variante: DsButtonVariante.secondaire,
          onPressed: () => exporterTableau(
            context,
            ref,
            id: 'besoin_${b.code}',
            titre: '${l10n.stkListeTitre(b.code)} · $nomFrn',
            colonnes: colonnesPdf,
            lignes: b.lignes,
            format: DsFormatExport.pdf,
          ),
        ),
      ],
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${b.lignes.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.stkMontantEstime, valeur: f2(b.montant), suffixe: devise, icone: LucideIcons.wallet),
        if (b.dateLivraison != null)
          DsStatItem(libelle: l10n.stkLivraison, valeur: formatDate.format(b.dateLivraison!), icone: LucideIcons.truck),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.produitsOngletProduits,
          icone: LucideIcons.package,
          nbLignes: b.lignes.length,
          tableau: _tableLignes(
            l10n,
            b.lignes,
            produits,
            devise,
            prix: true,
            libelleQte: l10n.stkACommander,
            libellePrix: l10n.stkPrixEstime,
          ),
        ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            ..._audit(l10n, b.utilisateurCode, b.date, b.annulation, utilisateurs),
            if (b.observation != null) DsKeyValue(l10n.retoursObservation, b.observation),
          ],
        ),
      ],
    ),
  );
}

/// Annulation en lot des listes de besoins (une liste reçue en entrée est bloquée).
Future<void> annulerBesoins(BuildContext context, WidgetRef ref, List<Besoin> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final fournisseurs = {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
  if (!context.mounted) return;
  String? blocage(Besoin b) => !b.actif
      ? l10n.stkBloqueDejaAnnulee
      : b.statut == StatutsBesoin.disponible
      ? l10n.stkBloqueBesoinRecu
      : null;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.stkEntiteListe,
    entitePluriel: l10n.stkEntiteListes,
    elements: [
      for (final b in choix)
        DsElementLot(
          id: b.code,
          titre: '${b.code} · ${fournisseurs[b.fournisseurCode] ?? b.fournisseurCode}',
          meta: formaterMontant(b.montant, devise),
          motifBlocage: blocage(b),
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final ok = await executerStock(
    context,
    ref,
    () => ref.read(stockServiceProvider).annulerBesoins([
      for (final b in choix)
        if (blocage(b) == null) b.code,
    ], motif: motif),
  );
  effacer();
  if (ok && context.mounted) afficherToast(context, titre: l10n.stkToastListesAnnulees);
}
