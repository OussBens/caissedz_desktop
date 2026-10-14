import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';

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
