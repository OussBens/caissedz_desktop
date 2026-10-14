import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import 'produit_dialogs.dart';
import 'produits_providers.dart';

/// Saisie d'un nom (création / renommage).
Future<String?> demanderNom(BuildContext context, {required String titre, String? initial}) {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => DsDialog(
      titre: titre,
      largeur: 420,
      contenu: DsTextField(
        controller: ctrl,
        libelle: l10n.categorieNom,
        autofocus: true,
        onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
      ),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        DsButton(libelle: l10n.communEnregistrer, onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim())),
      ],
    ),
  );
}

class CategoriesOnglet extends ConsumerStatefulWidget {
  const CategoriesOnglet({super.key});
  @override
  ConsumerState<CategoriesOnglet> createState() => _CategoriesOngletState();
}

class _CategoriesOngletState extends ConsumerState<CategoriesOnglet> {
  String? _courante;

  Future<void> _executer(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      rafraichirCatalogue(ref);
    } on CatalogueException catch (e) {
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.produitsOngletCategories,
        message: messageErreurCatalogue(l10n, e.erreur),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final sous = ref.watch(sousCategoriesProvider).value ?? const [];
    final service = ref.read(catalogueServiceProvider);
    final courante = categories.where((x) => x.code == _courante).firstOrNull ?? categories.firstOrNull;
    final sousCourantes = sous.where((s) => s.categorieCode == courante?.code).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.produitsOngletCategories, style: t.titreSm)),
                  DsButton(
                    libelle: l10n.categoriesNouvelle,
                    icone: LucideIcons.plus,
                    taille: DsButtonTaille.sm,
                    onPressed: () async {
                      final nom = await demanderNom(context, titre: l10n.categoriesNouvelle);
                      if (nom == null || nom.isEmpty) return;
                      await _executer(() async {
                        final cat = await service.creerCategorie(nom);
                        _courante = cat.code;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              Expanded(
                child: DsDataTable<Categorie>(
                  colonnes: [
                    DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (x) => x.code, largeur: 110),
                    DsColonne(id: 'nom', libelle: l10n.categorieNom, valeur: (x) => x.nom, flex: 3),
                    DsColonne(
                      id: 'n',
                      libelle: l10n.categorieSousCategories,
                      valeur: (x) => sous.where((s) => s.categorieCode == x.code).length,
                      numerique: true,
                    ),
                  ],
                  lignes: categories,
                  cle: (x) => x.code,
                  selection: courante == null ? const {} : {courante.code},
                  onSelectionChanged: (s) => setState(() => _courante = s.isEmpty ? null : s.last as String),
                  pagine: false,
                  actionsContextuelles: [
                    DsActionContextuelle(
                      libelle: l10n.categorieRenommer,
                      icone: LucideIcons.pencil,
                      onSelected: (x) async {
                        final nom = await demanderNom(context, titre: l10n.categorieRenommer, initial: x.nom);
                        if (nom == null || nom.isEmpty) return;
                        await _executer(() => service.renommerCategorie(x.code, nom));
                      },
                    ),
                    DsActionContextuelle(
                      libelle: l10n.categorieSupprimer,
                      icone: LucideIcons.trash2,
                      destructif: true,
                      onSelected: (x) async {
                        if (!await afficherConfirmation(
                          context,
                          titre: l10n.categorieSupprimer,
                          message: l10n.categorieConfirmerSuppression(x.nom),
                          destructif: true,
                        )) {
                          return;
                        }
                        await _executer(() => service.supprimerCategorie(x.code));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DsSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.categorieSousCategories}${courante == null ? '' : ' — ${courante.nom}'}',
                      style: t.titreSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DsButton(
                    libelle: l10n.categoriesNouvelleSous,
                    icone: LucideIcons.plus,
                    taille: DsButtonTaille.sm,
                    variante: DsButtonVariante.secondaire,
                    onPressed: courante == null
                        ? null
                        : () async {
                            final nom = await demanderNom(context, titre: l10n.categoriesNouvelleSous);
                            if (nom == null || nom.isEmpty) return;
                            await _executer(() => service.creerSousCategorie(courante.code, nom));
                          },
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              Expanded(
                child: DsDataTable<SousCategorie>(
                  colonnes: [
                    DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (x) => x.code, largeur: 110),
                    DsColonne(id: 'nom', libelle: l10n.categorieNom, valeur: (x) => x.nom, flex: 3),
                  ],
                  lignes: sousCourantes,
                  cle: (x) => x.code,
                  pagine: false,
                  messageVide: l10n.communAucune,
                  actionsContextuelles: [
                    DsActionContextuelle(
                      libelle: l10n.categorieRenommer,
                      icone: LucideIcons.pencil,
                      onSelected: (x) async {
                        final nom = await demanderNom(context, titre: l10n.categorieRenommer, initial: x.nom);
                        if (nom == null || nom.isEmpty) return;
                        await _executer(() => service.renommerSousCategorie(x.code, nom));
                      },
                    ),
                    DsActionContextuelle(
                      libelle: l10n.categorieSupprimer,
                      icone: LucideIcons.trash2,
                      destructif: true,
                      onSelected: (x) => _executer(() => service.supprimerSousCategorie(x.code)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DsSpacing.sm),
              Text(l10n.categorieErreurSysteme, style: t.legende.copyWith(color: c.texteAttenue)),
            ],
          ),
        ),
      ],
    );
  }
}
