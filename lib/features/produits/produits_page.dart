import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/permissions.dart';
import 'categories_onglet.dart';
import 'colis_packs_remises_onglets.dart';
import 'produit_dialogs.dart';
import 'produits_providers.dart';

/// Module Produits : onglets Produits / Catégories / Colis / Packs / Remises.
class ProduitsPage extends ConsumerStatefulWidget {
  const ProduitsPage({super.key});

  @override
  ConsumerState<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends ConsumerState<ProduitsPage> {
  int _onglet = 0;
  Set<Object> _selection = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onglets = [
      l10n.produitsOngletProduits,
      l10n.produitsOngletCategories,
      l10n.produitsOngletColis,
      l10n.produitsOngletPacks,
      l10n.produitsOngletRemises,
    ];
    return DsPage(
      titre: l10n.produitsTitre,
      actions: _onglet == 0 ? _actionsProduits(l10n) : const [],
      onRecherche: _onglet == 0 ? (v) => ref.read(rechercheProduitsProvider.notifier).changer(v) : null,
      indiceRecherche: l10n.produitsRecherche,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsOnglets(onglets: onglets, courant: _onglet, onChanged: (i) => setState(() => _onglet = i)),
          const SizedBox(height: DsSpacing.lg),
          Expanded(
            child: switch (_onglet) {
              0 => _tableProduits(l10n),
              1 => const CategoriesOnglet(),
              2 => const ColisOnglet(),
              3 => const PacksOnglet(),
              _ => const RemisesOnglet(),
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _actionsProduits(AppLocalizations l10n) => [
    DsButton(
      libelle: l10n.produitsEtiquettes,
      icone: LucideIcons.tag,
      variante: DsButtonVariante.secondaire,
      onPressed: () => _etiquettes(l10n),
    ),
    DsButton(
      libelle: l10n.produitsSynchro,
      icone: LucideIcons.refreshCw,
      variante: DsButtonVariante.secondaire,
      onPressed: _synchroniser,
    ),
    DsButton(
      libelle: l10n.produitsImporter,
      icone: LucideIcons.fileSpreadsheet,
      variante: DsButtonVariante.secondaire,
      onPressed: () {
        afficherImportProduits(context);
      },
    ),
    DsButton(
      libelle: l10n.produitsModeIa,
      icone: LucideIcons.sparkles,
      variante: DsButtonVariante.secondaire,
      onPressed: () {
        afficherProduitIa(context);
      },
    ),
    DsButton(
      libelle: l10n.produitsNouveau,
      icone: LucideIcons.plus,
      onPressed: () {
        afficherFormulaireProduit(context);
      },
    ),
  ];

  Future<void> _etiquettes(AppLocalizations l10n) async {
    final produits = ref.read(produitsProvider).value ?? [];
    final choisis = produits.where((p) => _selection.contains(p.code)).toList();
    if (choisis.isEmpty) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.info,
          titre: l10n.etiquettesTitre,
          message: l10n.etiquettesAucuneSelection,
        ),
      );
      return;
    }
    unawaited(afficherEtiquettes(context, choisis));
  }

  Future<void> _synchroniser() async {
    final l10n = AppLocalizations.of(context);
    final r = await ref.read(synchroCatalogueServiceProvider).synchroniser();
    if (!mounted) return;
    if (r.erreur == 'non_configuree') {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.info,
          titre: l10n.produitsSynchro,
          message: l10n.synchroNonConfiguree,
        ),
      );
    } else if (!r.ok) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.produitsSynchro,
          message: l10n.synchroErreur(r.erreur!),
        ),
      );
    } else {
      rafraichirCatalogue(ref);
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.produitsSynchro,
          message: l10n.synchroResultat(r.envoyes, r.recus),
        ),
      );
    }
  }

  Widget _tableProduits(AppLocalizations l10n) {
    final produits = ref.watch(produitsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final session = ref.watch(sessionProvider);
    final devise = ref.watch(deviseProvider);
    return produits.when(
      loading: () => Center(child: Text(l10n.communChargement)),
      error: (e, _) => Center(child: Text('$e')),
      data: (liste) => liste.isEmpty && ref.read(rechercheProduitsProvider).isEmpty
          ? DsVide(
              message: l10n.produitsAucun,
              icone: LucideIcons.package,
              action: DsButton(
                libelle: l10n.produitsNouveau,
                icone: LucideIcons.plus,
                onPressed: () {
                  afficherFormulaireProduit(context);
                },
              ),
            )
          : DsDataTable<Produit>(
              colonnes: [
                DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.code, largeur: 100),
                DsColonne(
                  id: 'designation',
                  libelle: l10n.produitsColDesignation,
                  valeur: (p) => p.designation,
                  flex: 3,
                ),
                DsColonne(id: 'cb', libelle: l10n.produitsColCodeBarres, valeur: (p) => p.codeBarres, flex: 2),
                DsColonne(
                  id: 'cat',
                  libelle: l10n.produitsColCategorie,
                  valeur: (p) => categories.where((c) => c.code == p.categorieCode).firstOrNull?.nom ?? p.categorieCode,
                  flex: 2,
                ),
                DsColonne(
                  id: 'pa',
                  libelle: l10n.produitsColPrixAchat,
                  valeur: (p) => p.prixAchat,
                  numerique: true,
                  permission: Permission.voirPrixAchat.code,
                  cellule: (_, p) => Text(formaterMontant(p.prixAchat, devise)),
                ),
                DsColonne(
                  id: 'pv',
                  libelle: l10n.produitsColPrixVente,
                  valeur: (p) => p.prixVente,
                  numerique: true,
                  cellule: (_, p) => Text(formaterMontant(p.prixVente, devise)),
                ),
                DsColonne(
                  id: 'marge',
                  libelle: l10n.produitsColMarge,
                  valeur: (p) => p.margePct,
                  numerique: true,
                  permission: Permission.voirPrixAchat.code,
                  visibleParDefaut: false,
                ),
                DsColonne(
                  id: 'actif',
                  libelle: l10n.produitsColActif,
                  valeur: (p) => p.actif ? 1 : 0,
                  largeur: 90,
                  cellule: (_, p) => DsBadge(
                    libelle: p.actif ? l10n.communActif : l10n.communInactif,
                    ton: p.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
                  ),
                ),
              ],
              lignes: liste,
              cle: (p) => p.code,
              permissions: session?.permissions.map((p) => p.code).toSet() ?? const {},
              onSelectionChanged: (s) => setState(() => _selection = s),
              onDoubleClic: (p) => afficherFormulaireProduit(context, produit: p),
              actionsContextuelles: [
                DsActionContextuelle(
                  libelle: l10n.produitModifier,
                  icone: LucideIcons.pencil,
                  onSelected: (p) => afficherFormulaireProduit(context, produit: p),
                ),
                DsActionContextuelle(
                  libelle: l10n.produitGenererCodeBarres,
                  icone: LucideIcons.barcode,
                  onSelected: (p) async {
                    await ref.read(catalogueServiceProvider).genererCodeBarresInterne(p.code);
                    rafraichirCatalogue(ref);
                  },
                ),
                DsActionContextuelle(
                  libelle: l10n.produitDesactiver,
                  icone: LucideIcons.ban,
                  destructif: true,
                  onSelected: (p) async {
                    await ref.read(catalogueServiceProvider).activerProduit(p.code, !p.actif);
                    rafraichirCatalogue(ref);
                  },
                ),
              ],
              messageVide: l10n.communAucunResultat,
              hauteurLigne: DsTailles.ligneTable,
            ),
    );
  }
}
