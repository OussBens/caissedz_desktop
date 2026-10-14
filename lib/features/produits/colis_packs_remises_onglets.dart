import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import 'produit_dialogs.dart';
import 'produits_providers.dart';

Future<void> _executer(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    rafraichirCatalogue(ref);
  } on CatalogueException catch (e) {
    if (!context.mounted) return;
    await afficherResultat(
      context,
      type: DsResultatType.erreur,
      titre: l10n.produitsTitre,
      message: messageErreurCatalogue(l10n, e.erreur),
    );
  }
}

// ---------------------------------------------------------------- Colis
class ColisOnglet extends ConsumerWidget {
  const ColisOnglet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colis = ref.watch(colisProvider).value ?? const [];
    final produits = ref.watch(produitsProvider).value ?? const [];
    final devise = ref.watch(deviseProvider);
    String nomProduit(String code) => produits.where((p) => p.code == code).firstOrNull?.designation ?? code;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Spacer(),
            DsButton(
              libelle: l10n.colisNouveau,
              icone: LucideIcons.plus,
              onPressed: () {
                _formulaireColis(context, ref);
              },
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.md),
        Expanded(
          child: DsDataTable<Colis>(
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (x) => x.code, largeur: 100),
              DsColonne(id: 'd', libelle: l10n.produitsColDesignation, valeur: (x) => x.designation, flex: 3),
              DsColonne(id: 'p', libelle: l10n.colisProduit, valeur: (x) => nomProduit(x.produitCode), flex: 3),
              DsColonne(id: 'q', libelle: l10n.colisQuantite, valeur: (x) => x.quantite, numerique: true),
              DsColonne(id: 'cb', libelle: l10n.produitsColCodeBarres, valeur: (x) => x.codeBarres, flex: 2),
              DsColonne(
                id: 'pv',
                libelle: l10n.produitsColPrixVente,
                valeur: (x) => x.prixVente,
                numerique: true,
                cellule: (_, x) => Text(formaterMontant(x.prixVente, devise)),
              ),
            ],
            lignes: colis,
            cle: (x) => x.code,
            messageVide: l10n.colisAucun,
            onDoubleClic: (x) => _formulaireColis(context, ref, colis: x),
            actionsContextuelles: [
              DsActionContextuelle(
                libelle: l10n.communModifier,
                icone: LucideIcons.pencil,
                onSelected: (x) => _formulaireColis(context, ref, colis: x),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _formulaireColis(BuildContext context, WidgetRef ref, {Colis? colis}) async {
    final l10n = AppLocalizations.of(context);
    final produits = ref.read(produitsProvider).value ?? const [];
    if (produits.isEmpty) return;
    final designation = TextEditingController(text: colis?.designation ?? '');
    final quantite = TextEditingController(text: (colis?.quantite ?? 6).toString());
    final codeBarres = TextEditingController(text: colis?.codeBarres ?? '');
    final prix = TextEditingController(text: colis?.prixVente.toString() ?? '');
    var produitCode = colis?.produitCode ?? produits.first.code;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: colis == null ? l10n.colisNouveau : l10n.communModifier,
          largeur: 520,
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
                titre: l10n.colisProduit,
                valeur: produitCode,
                options: produits.map((p) => p.code).toList(),
                libelle: (c) => produits.firstWhere((p) => p.code == c).designation,
                onChanged: (v) => setState(() => produitCode = v ?? produitCode),
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: designation, libelle: l10n.produitsColDesignation, autofocus: true),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsTextField(
                      controller: quantite,
                      libelle: l10n.colisQuantite,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsTextField(
                      controller: prix,
                      libelle: l10n.produitsColPrixVente,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(
                controller: codeBarres,
                libelle: l10n.produitChampCodeBarres,
                iconePrefixe: LucideIcons.barcode,
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final c = Colis(
      code: colis?.code ?? '',
      produitCode: produitCode,
      designation: designation.text,
      quantite: int.tryParse(quantite.text.trim()) ?? 0,
      codeBarres: codeBarres.text.trim().isEmpty ? null : codeBarres.text.trim(),
      prixVente: lireNombre(prix.text) ?? 0,
    );
    final service = ref.read(catalogueServiceProvider);
    await _executer(context, ref, () => colis == null ? service.creerColis(c) : service.modifierColis(c));
  }
}

// ---------------------------------------------------------------- Packs
class PacksOnglet extends ConsumerWidget {
  const PacksOnglet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final packs = ref.watch(packsProvider).value ?? const [];
    final devise = ref.watch(deviseProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Spacer(),
            DsButton(
              libelle: l10n.packNouveau,
              icone: LucideIcons.plus,
              onPressed: () {
                _formulairePack(context, ref);
              },
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.md),
        Expanded(
          child: DsDataTable<Pack>(
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (x) => x.code, largeur: 100),
              DsColonne(id: 'd', libelle: l10n.produitsColDesignation, valeur: (x) => x.designation, flex: 3),
              DsColonne(id: 'n', libelle: l10n.packLignes, valeur: (x) => x.lignes.length, numerique: true),
              DsColonne(id: 'cb', libelle: l10n.produitsColCodeBarres, valeur: (x) => x.codeBarres, flex: 2),
              DsColonne(
                id: 'pv',
                libelle: l10n.produitsColPrixVente,
                valeur: (x) => x.prixVente,
                numerique: true,
                cellule: (_, x) => Text(formaterMontant(x.prixVente, devise)),
              ),
            ],
            lignes: packs,
            cle: (x) => x.code,
            messageVide: l10n.packAucun,
            onDoubleClic: (x) => _formulairePack(context, ref, pack: x),
            actionsContextuelles: [
              DsActionContextuelle(
                libelle: l10n.communModifier,
                icone: LucideIcons.pencil,
                onSelected: (x) => _formulairePack(context, ref, pack: x),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _formulairePack(BuildContext context, WidgetRef ref, {Pack? pack}) async {
    final l10n = AppLocalizations.of(context);
    final produits = ref.read(produitsProvider).value ?? const [];
    if (produits.isEmpty) return;
    final designation = TextEditingController(text: pack?.designation ?? '');
    final codeBarres = TextEditingController(text: pack?.codeBarres ?? '');
    final prix = TextEditingController(text: pack?.prixVente.toString() ?? '');
    final lignes = [...?pack?.lignes];
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final c = ctx.ds.colors;
          final t = ctx.ds.typo;
          return DsDialog(
            titre: pack == null ? l10n.packNouveau : l10n.communModifier,
            largeur: 600,
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
                DsTextField(controller: designation, libelle: l10n.produitsColDesignation, autofocus: true),
                const SizedBox(height: DsSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DsTextField(
                        controller: prix,
                        libelle: l10n.produitsColPrixVente,
                        typeClavier: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.md),
                    Expanded(
                      child: DsTextField(
                        controller: codeBarres,
                        libelle: l10n.produitChampCodeBarres,
                        iconePrefixe: LucideIcons.barcode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DsSpacing.lg),
                Row(
                  children: [
                    Expanded(child: Text(l10n.packLignes, style: t.titreSm)),
                    DsButton(
                      libelle: l10n.packAjouterProduit,
                      icone: LucideIcons.plus,
                      taille: DsButtonTaille.sm,
                      variante: DsButtonVariante.secondaire,
                      onPressed: () async {
                        final p = await afficherSelecteur<Produit>(
                          ctx,
                          titre: l10n.packAjouterProduit,
                          elements: produits,
                          libelle: (p) => p.designation,
                          sousLibelle: (p) => p.code,
                        );
                        if (p == null) return;
                        setState(() {
                          final i = lignes.indexWhere((l) => l.produitCode == p.code);
                          if (i >= 0) {
                            lignes[i] = PackLigne(produitCode: p.code, quantite: lignes[i].quantite + 1);
                          } else {
                            lignes.add(PackLigne(produitCode: p.code, quantite: 1));
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DsSpacing.sm),
                for (final (i, l) in lignes.indexed)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produits.where((p) => p.code == l.produitCode).firstOrNull?.designation ?? l.produitCode,
                          style: t.corps,
                        ),
                      ),
                      DsIconButton(
                        icone: LucideIcons.minus,
                        tooltip: '-',
                        onPressed: () => setState(
                          () => l.quantite > 1
                              ? lignes[i] = PackLigne(produitCode: l.produitCode, quantite: l.quantite - 1)
                              : lignes.removeAt(i),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text('${l.quantite}', style: t.corpsFort, textAlign: TextAlign.center),
                      ),
                      DsIconButton(
                        icone: LucideIcons.plus,
                        tooltip: '+',
                        onPressed: () =>
                            setState(() => lignes[i] = PackLigne(produitCode: l.produitCode, quantite: l.quantite + 1)),
                      ),
                      DsIconButton(
                        icone: LucideIcons.trash2,
                        tooltip: l10n.communSupprimer,
                        couleur: c.danger,
                        onPressed: () => setState(() => lignes.removeAt(i)),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
    if (ok != true || !context.mounted) return;
    final p = Pack(
      code: pack?.code ?? '',
      designation: designation.text,
      codeBarres: codeBarres.text.trim().isEmpty ? null : codeBarres.text.trim(),
      prixVente: lireNombre(prix.text) ?? 0,
      lignes: lignes,
    );
    final service = ref.read(catalogueServiceProvider);
    await _executer(context, ref, () => pack == null ? service.creerPack(p) : service.modifierPack(p));
  }
}

// ---------------------------------------------------------------- Remises
class RemisesOnglet extends ConsumerWidget {
  const RemisesOnglet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final remises = ref.watch(remisesProvider).value ?? const [];
    final produits = ref.watch(produitsProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    String portee(Remise r) {
      if (r.produitCode != null) {
        return produits.where((p) => p.code == r.produitCode).firstOrNull?.designation ?? r.produitCode!;
      }
      if (r.categorieCode != null) {
        return categories.where((c) => c.code == r.categorieCode).firstOrNull?.nom ?? r.categorieCode!;
      }
      return l10n.remisePorteeGlobale;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Spacer(),
            DsButton(
              libelle: l10n.remiseNouvelle,
              icone: LucideIcons.plus,
              onPressed: () {
                _formulaireRemise(context, ref);
              },
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.md),
        Expanded(
          child: DsDataTable<Remise>(
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (x) => x.code, largeur: 100),
              DsColonne(id: 'd', libelle: l10n.produitsColDesignation, valeur: (x) => x.designation, flex: 3),
              DsColonne(
                id: 't',
                libelle: l10n.remiseType,
                valeur: (x) => x.type,
                cellule: (_, x) => Text(x.type == 'Pourcentage' ? l10n.remiseTypePourcentage : l10n.remiseTypeMontant),
              ),
              DsColonne(id: 'v', libelle: l10n.remiseValeur, valeur: (x) => x.valeur, numerique: true),
              DsColonne(id: 'p', libelle: l10n.remisePortee, valeur: (x) => portee(x), flex: 2),
              DsColonne(
                id: 'a',
                libelle: l10n.communActif,
                valeur: (x) => x.actif ? 1 : 0,
                largeur: 90,
                cellule: (_, x) => DsBadge(
                  libelle: x.actif ? l10n.communActif : l10n.communInactif,
                  ton: x.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
                ),
              ),
            ],
            lignes: remises,
            cle: (x) => x.code,
            messageVide: l10n.remiseAucune,
            onDoubleClic: (x) => _formulaireRemise(context, ref, remise: x),
            actionsContextuelles: [
              DsActionContextuelle(
                libelle: l10n.communModifier,
                icone: LucideIcons.pencil,
                onSelected: (x) => _formulaireRemise(context, ref, remise: x),
              ),
              DsActionContextuelle(
                libelle: l10n.communSupprimer,
                icone: LucideIcons.trash2,
                destructif: true,
                onSelected: (x) =>
                    _executer(context, ref, () => ref.read(catalogueServiceProvider).supprimerRemise(x.code)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _formulaireRemise(BuildContext context, WidgetRef ref, {Remise? remise}) async {
    final l10n = AppLocalizations.of(context);
    final produits = ref.read(produitsProvider).value ?? const [];
    final categories = ref.read(categoriesProvider).value ?? const [];
    final designation = TextEditingController(text: remise?.designation ?? '');
    final valeur = TextEditingController(text: remise?.valeur.toString() ?? '');
    var type = remise?.type ?? 'Pourcentage';
    var portee = remise?.produitCode != null ? 'produit' : (remise?.categorieCode != null ? 'categorie' : 'globale');
    String? produitCode = remise?.produitCode;
    String? categorieCode = remise?.categorieCode;
    var actif = remise?.actif ?? true;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: remise == null ? l10n.remiseNouvelle : l10n.communModifier,
          largeur: 520,
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
              DsTextField(controller: designation, libelle: l10n.produitsColDesignation, autofocus: true),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.remiseType,
                      valeur: type,
                      options: const ['Pourcentage', 'Montant'],
                      libelle: (v) => v == 'Pourcentage' ? l10n.remiseTypePourcentage : l10n.remiseTypeMontant,
                      onChanged: (v) => setState(() => type = v ?? type),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsTextField(
                      controller: valeur,
                      libelle: l10n.remiseValeur,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              DsSelect<String>(
                titre: l10n.remisePortee,
                valeur: portee,
                options: const ['globale', 'categorie', 'produit'],
                libelle: (v) => switch (v) {
                  'categorie' => l10n.remisePorteeCategorie,
                  'produit' => l10n.remisePorteeProduit,
                  _ => l10n.remisePorteeGlobale,
                },
                onChanged: (v) => setState(() => portee = v ?? portee),
              ),
              const SizedBox(height: DsSpacing.md),
              if (portee == 'categorie')
                DsSelect<String>(
                  titre: l10n.produitChampCategorie,
                  valeur: categorieCode ?? categories.firstOrNull?.code,
                  options: categories.map((c) => c.code).toList(),
                  libelle: (c) => categories.firstWhere((x) => x.code == c).nom,
                  onChanged: (v) => setState(() => categorieCode = v),
                ),
              if (portee == 'produit')
                DsSelect<String>(
                  titre: l10n.colisProduit,
                  valeur: produitCode ?? produits.firstOrNull?.code,
                  options: produits.map((p) => p.code).toList(),
                  libelle: (c) => produits.firstWhere((x) => x.code == c).designation,
                  onChanged: (v) => setState(() => produitCode = v),
                ),
              const SizedBox(height: DsSpacing.sm),
              DsSwitch(valeur: actif, libelle: l10n.communActif, onChanged: (v) => setState(() => actif = v)),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = Remise(
      code: remise?.code ?? '',
      designation: designation.text,
      type: type,
      valeur: lireNombre(valeur.text) ?? 0,
      produitCode: portee == 'produit' ? (produitCode ?? produits.firstOrNull?.code) : null,
      categorieCode: portee == 'categorie' ? (categorieCode ?? categories.firstOrNull?.code) : null,
      dateDebut: remise?.dateDebut,
      dateFin: remise?.dateFin,
      actif: actif,
    );
    final service = ref.read(catalogueServiceProvider);
    await _executer(context, ref, () => remise == null ? service.creerRemise(r) : service.modifierRemise(r));
  }
}
