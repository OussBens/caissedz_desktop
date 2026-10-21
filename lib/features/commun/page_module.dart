import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/modules.dart';
import '../../domain/pastilles.dart';
import '../shell/app_shell.dart';
import 'pastilles_providers.dart';

/// Gabarit des 17 écrans de module : `PageHeader` (fil d'Ariane groupe › module, description,
/// étoile des favoris) puis onglets éventuels et contenu défilant (`ModuleTable`…).
class PageModule extends ConsumerWidget {
  const PageModule({
    super.key,
    required this.moduleId,
    required this.child,
    this.titre,
    this.onglets,
    this.comptes,
    this.ongletCourant = 0,
    this.onOnglet,
    this.actions = const [],
    this.defilable = true,
  });

  final String moduleId;
  final Widget child;

  /// Titre (par défaut : libellé du module).
  final String? titre;
  final List<String>? onglets;
  final List<int?>? comptes;
  final int ongletCourant;
  final ValueChanged<int>? onOnglet;
  final List<Widget> actions;

  /// `false` : le contenu gère son propre défilement (navigation latérale fixe, tableaux).
  final bool defilable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final module = Modules.tous.where((m) => m.id == moduleId).firstOrNull;
    final favori = ref.watch(favorisProvider).contains(moduleId);
    // Points rouges : l'onglet affiché est consulté (son point s'éteint), les autres gardent le leur.
    final pastilles = ref.watch(pastillesProvider);
    if (pastilles.contains(PastillesModules.cible(moduleId, ongletCourant))) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(pastillesProvider.notifier).marquerVu(moduleId, ongletCourant),
      );
    }
    final nom = titre ?? module?.libelle(l10n) ?? moduleId;
    return DsPage(
      titre: nom,
      filAriane: module == null ? null : [libelleGroupe(l10n, module.groupe), module.libelle(l10n)],
      defilable: defilable,
      actions: [
        ...actions,
        if (module != null)
          DsIconButton(
            key: const ValueKey('page_favori'),
            icone: LucideIcons.star,
            tooltip: favori ? l10n.dsRetirerFavoris : l10n.dsAjouterFavoris,
            contour: true,
            actif: favori,
            onPressed: () async {
              final ok = await ref.read(favorisProvider.notifier).basculer(moduleId);
              if (!ok && context.mounted) {
                afficherToast(context, titre: l10n.dsFavorisComplets, ton: DsToastTon.avertissement);
              }
            },
          ),
      ],
      barre: onglets == null
          ? null
          : DsOnglets(
              onglets: onglets!,
              courant: ongletCourant,
              comptes: comptes,
              points: [
                for (var i = 0; i < onglets!.length; i++)
                  i != ongletCourant && pastilles.contains(PastillesModules.cible(moduleId, i)),
              ],
              onChanged: onOnglet ?? (_) {},
            ),
      child: child,
    );
  }
}
