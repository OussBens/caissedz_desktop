import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../produits/produits_providers.dart';
import 'stock_providers.dart';

/// Besoins : En attente → Commande → Disponible, génération automatique sous seuil.
class BesoinsPage extends ConsumerStatefulWidget {
  const BesoinsPage({super.key});

  @override
  ConsumerState<BesoinsPage> createState() => _BesoinsPageState();
}

class _BesoinsPageState extends ConsumerState<BesoinsPage> {
  String? _statut;

  Future<void> _executer(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      rafraichirStock(ref);
    } on StockException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.besoinsTitre,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final besoins = (ref.watch(besoinsProvider).value ?? const [])
        .where((b) => _statut == null || b.statut == _statut)
        .toList();
    final produits = ref.watch(produitsProvider).value ?? const [];
    final service = ref.read(stockServiceProvider);
    final df = DateFormat('dd/MM/yyyy');
    String nomProduit(String code) => produits.where((p) => p.code == code).firstOrNull?.designation ?? code;
    DsBadgeTon ton(String s) => switch (s) {
      StatutsBesoin.commande => DsBadgeTon.info,
      StatutsBesoin.disponible => DsBadgeTon.succes,
      _ => DsBadgeTon.avertissement,
    };
    return DsPage(
      titre: l10n.besoinsTitre,
      actions: [
        DsButton(
          libelle: l10n.besoinGenerer,
          icone: LucideIcons.wand,
          variante: DsButtonVariante.secondaire,
          onPressed: () async {
            final seuil = ref.read(parametresVenteProvider).value?.seuilStockGlobal ?? 5;
            final crees = await service.genererBesoinsSousSeuil(seuilGlobal: seuil);
            rafraichirStock(ref);
            if (!context.mounted) return;
            unawaited(
              afficherResultat(
                context,
                type: DsResultatType.info,
                titre: l10n.besoinGenerer,
                message: l10n.besoinGeneres(crees.length),
              ),
            );
          },
        ),
        DsButton(
          libelle: l10n.besoinNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            _nouveau(produits);
          },
        ),
      ],
      filtres: Row(
        children: [
          for (final s in [null, ...StatutsBesoin.tous]) ...[
            DsButton(
              libelle: s == null ? l10n.communTotal : libelleStatutBesoin(l10n, s),
              taille: DsButtonTaille.sm,
              variante: _statut == s ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
              onPressed: () => setState(() => _statut = s),
            ),
            const SizedBox(width: DsSpacing.xs),
          ],
        ],
      ),
      child: DsDataTable<Besoin>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (b) => b.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (b) => b.date,
            largeur: 110,
            cellule: (_, b) => Text(df.format(b.date)),
          ),
          DsColonne(id: 'p', libelle: l10n.stockColProduit, valeur: (b) => nomProduit(b.produitCode), flex: 3),
          DsColonne(id: 'q', libelle: l10n.communQuantite, valeur: (b) => b.quantite, numerique: true),
          DsColonne(
            id: 's',
            libelle: l10n.besoinStatut,
            valeur: (b) => b.statut,
            cellule: (_, b) => DsBadge(libelle: libelleStatutBesoin(l10n, b.statut), ton: ton(b.statut)),
          ),
          DsColonne(id: 'c', libelle: l10n.communCommentaire, valeur: (b) => b.commentaire, flex: 2),
        ],
        lignes: besoins,
        cle: (b) => b.code,
        messageVide: l10n.besoinAucun,
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.besoinPasserCommande,
            icone: LucideIcons.shoppingCart,
            onSelected: (b) => _executer(() => service.changerStatutBesoin(b.code, StatutsBesoin.commande)),
          ),
          DsActionContextuelle(
            libelle: l10n.besoinPasserDisponible,
            icone: LucideIcons.packageCheck,
            onSelected: (b) => _executer(() => service.changerStatutBesoin(b.code, StatutsBesoin.disponible)),
          ),
          DsActionContextuelle(
            libelle: l10n.besoinRemettreAttente,
            icone: LucideIcons.clock,
            onSelected: (b) => _executer(() => service.changerStatutBesoin(b.code, StatutsBesoin.enAttente)),
          ),
          DsActionContextuelle(
            libelle: l10n.communSupprimer,
            icone: LucideIcons.trash2,
            destructif: true,
            onSelected: (b) => _executer(() => service.supprimerBesoin(b.code)),
          ),
        ],
      ),
    );
  }

  Future<void> _nouveau(List<Produit> produits) async {
    final l10n = AppLocalizations.of(context);
    if (produits.isEmpty) return;
    var produitCode = produits.first.code;
    final quantite = TextEditingController(text: '10');
    final commentaire = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: l10n.besoinNouveau,
          largeur: 480,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(libelle: l10n.communEnregistrer, onPressed: () => Navigator.of(ctx).pop(true)),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsSelect<String>(
                titre: l10n.stockColProduit,
                valeur: produitCode,
                options: produits.map((p) => p.code).toList(),
                libelle: (c) => produits.firstWhere((p) => p.code == c).designation,
                onChanged: (v) => setState(() => produitCode = v ?? produitCode),
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(
                controller: quantite,
                libelle: l10n.communQuantite,
                typeClavier: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await _executer(
      () => ref
          .read(stockServiceProvider)
          .creerBesoin(
            produitCode: produitCode,
            quantite: double.tryParse(quantite.text.replaceAll(',', '.')) ?? 0,
            commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
          ),
    );
  }
}
