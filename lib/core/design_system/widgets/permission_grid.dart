import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Ligne de la grille : une permission (ou un module) et son libellé.
class PermissionGridLigne {
  const PermissionGridLigne({required this.id, required this.libelle, this.icone});
  final String id;
  final String libelle;
  final IconData? icone;
}

/// Colonne de la grille : un rôle.
class PermissionGridColonne {
  const PermissionGridColonne({required this.id, required this.libelle, this.verrouillee = false, this.infoVerrou});
  final String id;
  final String libelle;

  /// Colonne non modifiable (ex. Admin : tous les droits).
  final bool verrouillee;
  final String? infoVerrou;
}

/// Grille rôles × permissions avec cases à cocher.
class PermissionGrid extends StatelessWidget {
  const PermissionGrid({
    super.key,
    required this.lignes,
    required this.colonnes,
    required this.estCoche,
    required this.onBasculer,
    this.lectureSeule = false,
  });

  final List<PermissionGridLigne> lignes;
  final List<PermissionGridColonne> colonnes;
  final bool Function(String colonneId, String ligneId) estCoche;
  final void Function(String colonneId, String ligneId) onBasculer;
  final bool lectureSeule;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    const largeurColonne = 120.0;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.bordure),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 52,
            color: c.surfaceAttenuee,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                for (final col in colonnes)
                  SizedBox(
                    width: largeurColonne,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col.libelle,
                          style: t.petitFort.copyWith(color: c.texteSecondaire, height: 1.2),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (col.verrouillee && col.infoVerrou != null)
                          Text(
                            col.infoVerrou!,
                            style: t.legende.copyWith(color: c.texteAttenue, height: 1.2),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          for (final (i, ligne) in lignes.indexed)
            Container(
              height: DsTailles.ligneTable,
              decoration: BoxDecoration(
                color: i.isOdd ? c.surfaceAttenuee.withValues(alpha: 0.4) : c.surface,
                border: Border(top: BorderSide(color: c.bordure)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.lg),
                      child: Row(
                        children: [
                          if (ligne.icone != null) ...[
                            Icon(ligne.icone, size: DsTailles.iconeSm, color: c.texteSecondaire),
                            const SizedBox(width: DsSpacing.sm),
                          ],
                          Expanded(
                            child: Text(ligne.libelle, style: t.corps, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (final col in colonnes)
                    SizedBox(
                      width: largeurColonne,
                      child: Center(
                        child: col.verrouillee
                            ? Icon(LucideIcons.check, size: DsTailles.icone, color: c.succes)
                            : Checkbox(
                                key: ValueKey('perm_${col.id}_${ligne.id}'),
                                value: estCoche(col.id, ligne.id),
                                activeColor: c.primaire,
                                onChanged: lectureSeule ? null : (_) => onBasculer(col.id, ligne.id),
                              ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Élément d'une [DsPermissionTiles] (module ou permission spéciale).
class DsPermissionItem {
  const DsPermissionItem({
    required this.cle,
    required this.libelle,
    required this.icone,
    this.verrouille = false,
    this.description,
  });
  final String cle;
  final String libelle;
  final IconData icone;

  /// Réservé à l'administrateur (affiché, non modifiable).
  final bool verrouille;
  final String? description;
}

/// Grille de tuiles de permissions (`PermissionGrid` v2.2) : tuiles 48 px cochables,
/// compteur « n / total », bouton « Tout sélectionner ».
class DsPermissionTiles extends StatelessWidget {
  const DsPermissionTiles({
    super.key,
    required this.items,
    required this.valeurs,
    this.onChanged,
    this.colonnes = 3,
    this.titre,
    this.description,
    this.lectureSeule = false,
  });
  final List<DsPermissionItem> items;
  final Set<String> valeurs;
  final ValueChanged<Set<String>>? onChanged;
  final int colonnes;
  final String? titre;
  final String? description;
  final bool lectureSeule;

  /// Modules du DS (`PermissionGrid.MODULES`) : clé stockée, icône, verrou.
  static const List<(String, IconData, bool)> modules = [
    ('dash', LucideIcons.layoutDashboard, false),
    ('caisse', LucideIcons.monitorSmartphone, false),
    ('produit', LucideIcons.package, false),
    ('pannier', LucideIcons.receiptText, false),
    ('client', LucideIcons.users, false),
    ('fournisseur', LucideIcons.truck, false),
    ('entree', LucideIcons.scanLine, false),
    ('sortie', LucideIcons.packageMinus, false),
    ('retour', LucideIcons.undo2, false),
    ('stock', LucideIcons.boxes, false),
    ('besoin', LucideIcons.clipboardList, false),
    ('utilisateur', LucideIcons.userCog, false),
    ('gestionCaisse', LucideIcons.wallet, false),
    ('zakat', LucideIcons.handCoins, false),
    ('parametre', LucideIcons.settings, true),
    ('historique', LucideIcons.history, true),
  ];

  /// Permissions spéciales du DS (`PermissionGrid.SPECIAL`).
  static const List<(String, IconData)> speciales = [
    ('voirPrixAchat', LucideIcons.eye),
    ('voirMarge', LucideIcons.trendingUp),
    ('modifierPrixVente', LucideIcons.tag),
    ('annulerOperations', LucideIcons.ban),
    ('changerCaisseMagasin', LucideIcons.repeat),
    ('gererTransfertsCaisse', LucideIcons.arrowLeftRight),
    ('voirStockTousMagasins', LucideIcons.store),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final modifiables = items.where((i) => !i.verrouille).toList();
    final tous = modifiables.isNotEmpty && modifiables.every((i) => valeurs.contains(i.cle));
    final n = items.where((i) => valeurs.contains(i.cle)).length;
    void basculerTout() {
      final s = {...valeurs};
      for (final i in modifiables) {
        tous ? s.remove(i.cle) : s.add(i.cle);
      }
      onChanged?.call(s);
    }

    const gap = 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        if (titre != null || description != null || !lectureSeule)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: DsSpacing.s3,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titre != null)
                      Text.rich(
                        TextSpan(
                          text: titre,
                          children: [
                            TextSpan(
                              text: ' · $n / ${items.length}',
                              style: TextStyle(fontWeight: FontWeight.w500, color: c.textMuted),
                            ),
                          ],
                        ),
                        style: t.cardTitle,
                      ),
                    if (description != null)
                      Text(description!, style: t.bodySm.copyWith(height: 1.45, color: c.textSecondary)),
                  ],
                ),
              ),
              if (!lectureSeule)
                DsButton(
                  libelle: tous ? l10n.dsPermRien : l10n.dsPermTout,
                  icone: tous ? LucideIcons.square : LucideIcons.checkCheck,
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.fantome,
                  delaiGarde: Duration.zero,
                  onPressed: basculerTout,
                ),
            ],
          ),
        LayoutBuilder(
          builder: (context, contraintes) {
            final nb = colonnes.clamp(1, 12);
            final largeur = ((contraintes.maxWidth - gap * (nb - 1)) / nb).clamp(190.0, contraintes.maxWidth);
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final i in items)
                  SizedBox(
                    width: largeur,
                    child: _TuilePermission(
                      item: i,
                      actif: valeurs.contains(i.cle),
                      lectureSeule: lectureSeule,
                      onTap: i.verrouille || lectureSeule || onChanged == null
                          ? null
                          : () {
                              final s = {...valeurs};
                              s.contains(i.cle) ? s.remove(i.cle) : s.add(i.cle);
                              onChanged!(s);
                            },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TuilePermission extends StatefulWidget {
  const _TuilePermission({required this.item, required this.actif, required this.lectureSeule, this.onTap});
  final DsPermissionItem item;
  final bool actif;
  final bool lectureSeule;
  final VoidCallback? onTap;
  @override
  State<_TuilePermission> createState() => _TuilePermissionState();
}

class _TuilePermissionState extends State<_TuilePermission> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final i = widget.item;
    final on = widget.actif;
    final inactif = widget.onTap == null;
    return Tooltip(
      message: i.verrouille ? l10n.dsPermReserve : (i.description ?? ''),
      child: MouseRegion(
        cursor: inactif ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _survol = true),
        onExit: (_) => setState(() => _survol = false),
        child: GestureDetector(
          key: ValueKey('perm_tuile_${i.cle}'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Opacity(
            opacity: i.verrouille ? .6 : 1,
            child: AnimatedContainer(
              duration: DsMotion.fast,
              curve: DsMotion.standard,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: on ? c.primaryTint : (_survol && !inactif ? c.surfaceHover : c.surfaceCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? c.primary : c.borderDefault),
              ),
              child: Row(
                spacing: 10,
                children: [
                  AnimatedContainer(
                    duration: DsMotion.fast,
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: on ? c.primary : c.surfaceSunken, borderRadius: DsRadius.borderMd),
                    child: Icon(i.icone, size: 16, color: on ? c.primaryFg : c.iconDefault),
                  ),
                  Expanded(
                    child: Text(
                      i.libelle,
                      style: t.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: on ? c.primaryTintFg : c.textPrimary,
                      ),
                    ),
                  ),
                  if (i.verrouille)
                    Icon(LucideIcons.lock, size: 14, color: c.iconMuted)
                  else
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: on ? c.primary : DsColors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: on ? c.primary : c.borderStrong, width: 1.5),
                      ),
                      child: on ? Icon(LucideIcons.check, size: 12, color: c.primaryFg) : null,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
