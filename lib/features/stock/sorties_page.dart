import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/stock.dart';
import '../../domain/referentiel/referentiel.dart';
import '../produits/produits_providers.dart';
import 'lignes_stock_editeur.dart';
import 'stock_providers.dart';

/// Sorties de stock (motifs §13) + onglet Ventes (mouvements de type Vente).
class SortiesPage extends ConsumerStatefulWidget {
  const SortiesPage({super.key});

  @override
  ConsumerState<SortiesPage> createState() => _SortiesPageState();
}

class _SortiesPageState extends ConsumerState<SortiesPage> {
  int _onglet = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    final produits = ref.watch(produitsProvider).value ?? const [];
    String nomMagasin(String code) => magasins.where((m) => m.code == code).firstOrNull?.nom ?? code;
    String nomProduit(String code) => produits.where((p) => p.code == code).firstOrNull?.designation ?? code;
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return DsPage(
      titre: l10n.sortiesTitre,
      actions: [
        if (_onglet == 0)
          DsButton(
            libelle: l10n.sortieNouvelle,
            icone: LucideIcons.plus,
            onPressed: () {
              _nouvelle();
            },
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsOnglets(
            onglets: [l10n.sortiesOngletSorties, l10n.sortiesOngletVentes],
            courant: _onglet,
            onChanged: (i) => setState(() => _onglet = i),
          ),
          const SizedBox(height: DsSpacing.lg),
          Expanded(
            child: _onglet == 0
                ? DsDataTable<SortieStock>(
                    colonnes: [
                      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (s) => s.code, largeur: 100),
                      DsColonne(
                        id: 'd',
                        libelle: l10n.communDate,
                        valeur: (s) => s.date,
                        largeur: 150,
                        cellule: (_, s) => Text(df.format(s.date)),
                      ),
                      DsColonne(
                        id: 'm',
                        libelle: l10n.stockColMagasin,
                        valeur: (s) => nomMagasin(s.magasinCode),
                        flex: 2,
                      ),
                      DsColonne(
                        id: 'mo',
                        libelle: l10n.sortieMotif,
                        valeur: (s) => s.motif,
                        flex: 2,
                        cellule: (_, s) => DsBadge(libelle: libelleMotif(l10n, s.motif), ton: DsBadgeTon.avertissement),
                      ),
                      DsColonne(
                        id: 'n',
                        libelle: l10n.transfertLignes,
                        valeur: (s) => s.lignes.length,
                        numerique: true,
                        cellule: (_, s) => Text(l10n.communLignes(s.lignes.length)),
                      ),
                      DsColonne(id: 'c', libelle: l10n.communCommentaire, valeur: (s) => s.commentaire, flex: 2),
                    ],
                    lignes: ref.watch(sortiesProvider).value ?? const [],
                    cle: (s) => s.code,
                    messageVide: l10n.sortieAucune,
                  )
                : DsDataTable<MouvementStock>(
                    colonnes: [
                      DsColonne(
                        id: 'd',
                        libelle: l10n.communDate,
                        valeur: (m) => m.date,
                        largeur: 150,
                        cellule: (_, m) => Text(df.format(m.date)),
                      ),
                      DsColonne(
                        id: 'p',
                        libelle: l10n.stockColProduit,
                        valeur: (m) => nomProduit(m.produitCode),
                        flex: 3,
                      ),
                      DsColonne(
                        id: 'm',
                        libelle: l10n.stockColMagasin,
                        valeur: (m) => nomMagasin(m.magasinCode),
                        flex: 2,
                      ),
                      DsColonne(
                        id: 'q',
                        libelle: l10n.stockColQuantite,
                        valeur: (m) => -m.quantite,
                        numerique: true,
                        cellule: (_, m) => Text((-m.quantite).toStringAsFixed(0)),
                      ),
                      DsColonne(id: 'ref', libelle: l10n.stockColReference, valeur: (m) => m.referenceCode, flex: 2),
                    ],
                    lignes: ref.watch(mouvementsVenteProvider).value ?? const [],
                    cle: (m) => m.id ?? m.hashCode,
                    messageVide: l10n.stockAucunMouvement,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _nouvelle() async {
    final l10n = AppLocalizations.of(context);
    final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
    final produits = await ref.read(produitsProvider.future);
    if (!context.mounted) return;
    if (magasins.isEmpty) return;
    var magasin = await ref.read(magasinPrincipalProvider.future);
    var motif = Referentiel.motifsSortie.valeurs.first.stocke;
    var lignes = <LigneStock>[];
    final commentaire = TextEditingController();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: l10n.sortieNouvelle,
          largeur: 640,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communValider,
              icone: LucideIcons.packageMinus,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.stockColMagasin,
                      valeur: magasin,
                      options: magasins.map((m) => m.code).toList(),
                      libelle: (c) => magasins.firstWhere((m) => m.code == c).nom,
                      onChanged: (v) => setState(() => magasin = v ?? magasin),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.sortieMotif,
                      valeur: motif,
                      options: Referentiel.motifsSortie.valeurs.map((v) => v.stocke).toList(),
                      libelle: (m) => libelleMotif(l10n, m),
                      onChanged: (v) => setState(() => motif = v ?? motif),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.lg),
              LignesStockEditeur(produits: produits, lignes: lignes, onChanged: (l) => setState(() => lignes = l)),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref
          .read(stockServiceProvider)
          .sortir(
            magasinCode: magasin,
            motif: motif,
            lignes: lignes,
            commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
          );
      rafraichirStock(ref);
    } on StockException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.sortieNouvelle,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
  }
}
