import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import 'statuts.dart';

/// Carte d'une entité (client, fournisseur, vente, utilisateur…) pour les vues grille des modules et des
/// dialogs de sélection : bandeau teinté avec avatar, titre, sous-titre, montant et deux lignes d'information.
class CarteEntite extends StatelessWidget {
  const CarteEntite({
    super.key,
    required this.etat,
    required this.titre,
    required this.icone,
    this.sousTitre,
    this.image,
    this.statut,
    this.montant,
    this.libelleMontant,
    this.couleurMontant,
    this.lignes = const [],
    this.initiales = true,
  });

  final DsEtatCarte etat;
  final String titre;
  final IconData icone;
  final String? sousTitre;
  final ImageProvider? image;

  /// Statut du DS (`actif`, `credit`, `annule`…) affiché en pastille.
  final String? statut;
  final String? montant;
  final String? libelleMontant;
  final Color? couleurMontant;

  /// Lignes d'information (icône + texte), deux au plus.
  final List<(IconData, String)> lignes;

  /// Avatar : initiales du titre (sinon l'icône).
  final bool initiales;

  static String _initiales(String texte) {
    final mots = texte.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    return mots.take(2).map((m) => m.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final teinte = teintePour(titre);
    return LayoutBuilder(builder: (context, contraintes) => _carte(context, contraintes.hasBoundedHeight, teinte));
  }

  /// Corps de la carte : dans une grille à hauteur fixe (dialog de sélection), il prend la place restante et
  /// coupe ce qui dépasse (police arabe plus haute) au lieu de déborder ; ailleurs, il garde sa hauteur.
  Widget _corps(bool borne, Widget corps) => borne
      ? Flexible(
          child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: corps),
        )
      : corps;

  Widget _carte(BuildContext context, bool borne, Color teinte) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return DsGridCard(
      etat: etat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsetsDirectional.only(start: 40, end: 12),
            decoration: BoxDecoration(
              color: Color.alphaBlend(teinte.withValues(alpha: .12), c.surfaceCard),
              border: Border(bottom: BorderSide(color: c.borderSubtle)),
            ),
            child: Row(
              children: [
                if (statut != null) BadgeStatut(statut!, petit: true),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: image != null
                        ? c.surfaceSunken
                        : Color.alphaBlend(teinte.withValues(alpha: .22), c.surfaceCard),
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surfaceCard, width: 2),
                    image: image != null ? DecorationImage(image: image!, fit: BoxFit.cover) : null,
                  ),
                  child: image != null
                      ? null
                      : initiales
                      ? Text(
                          _initiales(titre),
                          style: t.caption.copyWith(fontWeight: FontWeight.w700, color: teinte),
                        )
                      : Icon(icone, size: 17, color: teinte),
                ),
              ],
            ),
          ),
          _corps(
            borne,
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySm.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                      ),
                      if (sousTitre != null)
                        Text(
                          sousTitre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.caption.copyWith(color: c.textMuted),
                        ),
                    ],
                  ),
                  if (montant != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Text(
                            montant!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.body.copyWith(fontWeight: FontWeight.w700, color: couleurMontant ?? c.textPrimary),
                          ),
                        ),
                        if (libelleMontant != null)
                          Text(libelleMontant!, style: t.caption.copyWith(color: c.textMuted)),
                      ],
                    ),
                  for (final (ic, texte) in lignes.take(2))
                    Row(
                      spacing: 6,
                      children: [
                        Icon(ic, size: 13, color: c.iconMuted),
                        Expanded(
                          child: Text(
                            texte.isEmpty ? '—' : texte,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.caption.copyWith(color: c.textSecondary),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
