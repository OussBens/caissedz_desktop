import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Élément de la grille : un module ou une permission spéciale.
class PermissionItem {
  const PermissionItem({
    required this.cle,
    required this.libelle,
    this.icone,
    this.description,
    this.verrouille = false,
  });
  final String cle;
  final String libelle;
  final IconData? icone;
  final String? description;

  /// Réservé à l'administrateur : non modifiable.
  final bool verrouille;
}

/// Grille de permissions (`PermissionGrid` du DS v2.2) : tuiles cochables (icône, libellé, case),
/// en-tête « titre · n / total » et bouton Tout sélectionner / Tout désélectionner.
class PermissionGrid extends StatelessWidget {
  const PermissionGrid({
    super.key,
    required this.items,
    required this.valeur,
    this.onChanged,
    this.colonnes = 3,
    this.titre,
    this.description,
    this.lectureSeule = false,
    this.prefixeCle,
  });

  final List<PermissionItem> items;
  final Set<String> valeur;
  final ValueChanged<Set<String>>? onChanged;
  final int colonnes;
  final String? titre;
  final String? description;
  final bool lectureSeule;

  /// Préfixe des clés des tuiles (`<prefixe>_<cle>`), pour les tests.
  final String? prefixeCle;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final editables = items.where((i) => !i.verrouille).toList();
    final tout = editables.isNotEmpty && editables.every((i) => valeur.contains(i.cle));
    final n = items.where((i) => valeur.contains(i.cle)).length;
    void basculerTout() {
      final s = {...valeur};
      for (final i in editables) {
        tout ? s.remove(i.cle) : s.add(i.cle);
      }
      onChanged?.call(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
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
                          text: '$titre ',
                          children: [
                            TextSpan(
                              text: '· $n / ${items.length}',
                              style: t.bodyStrong.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                            ),
                          ],
                        ),
                        style: t.bodyStrong.copyWith(color: c.textPrimary),
                      ),
                    if (description != null)
                      Text(description!, style: t.bodySm.copyWith(color: c.textSecondary, height: 1.45)),
                  ],
                ),
              ),
              if (!lectureSeule)
                DsButton(
                  libelle: tout ? l10n.dsPermRien : l10n.dsPermTout,
                  icone: tout ? LucideIcons.square : LucideIcons.checkCheck,
                  variante: DsButtonVariante.fantome,
                  taille: DsButtonTaille.sm,
                  onPressed: onChanged == null ? null : basculerTout,
                ),
            ],
          ),
        LayoutBuilder(
          builder: (context, contraintes) {
            const ecart = DsSpacing.s2;
            final parLigne = ((contraintes.maxWidth + ecart) / (190 + ecart)).floor().clamp(1, colonnes);
            final largeur = (contraintes.maxWidth - ecart * (parLigne - 1)) / parLigne;
            return Wrap(
              spacing: ecart,
              runSpacing: ecart,
              children: [
                for (final i in items)
                  SizedBox(
                    width: largeur,
                    child: _Tuile(
                      key: prefixeCle == null ? null : ValueKey('${prefixeCle}_${i.cle}'),
                      item: i,
                      coche: valeur.contains(i.cle),
                      lectureSeule: lectureSeule || onChanged == null,
                      onTap: () {
                        final s = {...valeur};
                        s.contains(i.cle) ? s.remove(i.cle) : s.add(i.cle);
                        onChanged?.call(s);
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

class _Tuile extends StatefulWidget {
  const _Tuile({super.key, required this.item, required this.coche, required this.lectureSeule, required this.onTap});
  final PermissionItem item;
  final bool coche;
  final bool lectureSeule;
  final VoidCallback onTap;

  @override
  State<_Tuile> createState() => _TuileState();
}

class _TuileState extends State<_Tuile> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final i = widget.item;
    final on = widget.coche;
    final inactif = i.verrouille || widget.lectureSeule;
    final tuile = AnimatedContainer(
      duration: DsMotion.fast,
      curve: DsMotion.standard,
      constraints: const BoxConstraints(minHeight: DsSpacing.s12),
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: 10),
      decoration: BoxDecoration(
        color: on
            ? c.primaryTint
            : _survol && !inactif
            ? c.surfaceHover
            : c.surfaceCard,
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
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? c.primary : c.surfaceSunken, borderRadius: DsRadius.borderMd),
            child: Icon(
              i.icone ?? LucideIcons.shield,
              size: DsTailles.iconeSm,
              color: on ? c.primaryFg : c.iconDefault,
            ),
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? c.primary : null,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: on ? c.primary : c.borderStrong, width: 1.5),
              ),
              child: on ? Icon(LucideIcons.check, size: DsTailles.iconeXs, color: c.primaryFg) : null,
            ),
        ],
      ),
    );
    final message = i.verrouille ? AppLocalizations.of(context).dsPermReserve : i.description;
    final zone = MouseRegion(
      cursor: inactif ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: inactif ? null : widget.onTap,
        child: Opacity(opacity: i.verrouille ? .6 : 1, child: tuile),
      ),
    );
    return Semantics(
      checked: on,
      enabled: !inactif,
      child: message == null ? zone : Tooltip(message: message, child: zone),
    );
  }
}
