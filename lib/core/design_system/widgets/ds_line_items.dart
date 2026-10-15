import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_page.dart';

/// Colonne d'un [DsLineItemsEditor].
class DsColonneLigne<T> {
  const DsColonneLigne({
    required this.id,
    required this.libelle,
    required this.valeur,
    this.editable = false,
    this.onEdition,
    this.numerique = false,
    this.largeur,
    this.fort = false,
    this.attenue = false,
    this.suffixe,
    this.cellule,
  });
  final String id;
  final String libelle;
  final String Function(T ligne) valeur;

  /// Cellule éditable (quantité, prix) : [onEdition] reçoit la ligne et le texte saisi.
  final bool editable;
  final void Function(T ligne, String texte)? onEdition;
  final bool numerique;
  final double? largeur;
  final bool fort;
  final bool attenue;
  final String? suffixe;
  final Widget Function(BuildContext, T)? cellule;
}

/// Éditeur de lignes (`LineItemsEditor`) : tableau compact 44 px avec cellules éditables,
/// total de ligne, suppression, pied « Ajouter des produits » + compteurs.
class DsLineItemsEditor<T> extends StatelessWidget {
  const DsLineItemsEditor({
    super.key,
    required this.lignes,
    required this.colonnes,
    required this.totalLigne,
    required this.quantite,
    this.cle,
    this.onSupprimer,
    this.onAjouter,
    this.devise = 'DA',
    this.libelleAjouter,
    this.texteVide,
    this.lectureSeule = false,
    this.hauteurMax = 300,
    this.afficherTotaux = true,
    this.erreurs = const {},
    this.libelleTotal,
    this.actionsAjout = const [],
  });
  final List<T> lignes;
  final List<DsColonneLigne<T>> colonnes;
  final double Function(T) totalLigne;
  final double Function(T) quantite;
  final Object Function(T)? cle;
  final ValueChanged<T>? onSupprimer;
  final VoidCallback? onAjouter;
  final String devise;
  final String? libelleAjouter;
  final String? texteVide;
  final bool lectureSeule;
  final double hauteurMax;
  final bool afficherTotaux;

  /// Erreurs par clé de ligne puis par identifiant de colonne.
  final Map<Object, Map<String, String>> erreurs;
  final String? libelleTotal;

  /// Boutons placés après « Ajouter des produits » (ajouts groupés).
  final List<Widget> actionsAjout;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final total = lignes.fold(0.0, (a, l) => a + totalLigne(l));
    final qte = lignes.fold(0.0, (a, l) => a + quantite(l));
    final styleEnTete = t.overline.copyWith(color: c.textMuted);

    Widget cell(DsColonneLigne<T>? col, Widget enfant, {double? largeur, bool fin = false}) {
      final w = largeur ?? col?.largeur;
      final padded = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Align(
          alignment: (col?.numerique ?? fin) ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: enfant,
        ),
      );
      return w != null ? SizedBox(width: w, child: padded) : Expanded(child: padded);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              border: Border(bottom: BorderSide(color: c.borderDefault)),
            ),
            child: Row(
              children: [
                for (final col in colonnes)
                  cell(
                    col,
                    Text(col.libelle.toUpperCase(), style: styleEnTete, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                cell(
                  null,
                  Text((libelleTotal ?? l10n.communTotal).toUpperCase(), style: styleEnTete),
                  largeur: 130,
                  fin: true,
                ),
                if (!lectureSeule) const SizedBox(width: 44),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: hauteurMax),
            child: lignes.isEmpty
                ? SizedBox(
                    height: 72,
                    child: Center(
                      child: Text(texteVide ?? l10n.dsPosLigneVide, style: t.bodySm.copyWith(color: c.textMuted)),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final l in lignes)
                        Container(
                          key: cle == null ? null : ValueKey(cle!(l)),
                          constraints: const BoxConstraints(minHeight: 44),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: c.borderSubtle)),
                          ),
                          child: Row(
                            children: [
                              for (final col in colonnes)
                                cell(
                                  col,
                                  col.cellule != null
                                      ? col.cellule!(context, l)
                                      : col.editable && !lectureSeule
                                      ? _CelluleEditable(
                                          valeur: col.valeur(l),
                                          numerique: col.numerique,
                                          suffixe: col.suffixe,
                                          erreur: erreurs[cle?.call(l) ?? l]?[col.id],
                                          onChanged: (v) => col.onEdition?.call(l, v),
                                        )
                                      : Text(
                                          col.valeur(l),
                                          style: t.bodySm.copyWith(
                                            fontSize: 13.5,
                                            fontWeight: col.fort ? FontWeight.w600 : FontWeight.w400,
                                            color: col.fort ? c.textPrimary : (col.attenue ? c.textMuted : c.textBody),
                                            fontFeatures: DsTypography.tabular,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                              cell(
                                null,
                                Text(
                                  formaterNombre(totalLigne(l), decimales: 2),
                                  style: t.bodySm.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: DsTypography.tabular,
                                  ),
                                ),
                                largeur: 130,
                                fin: true,
                              ),
                              if (!lectureSeule)
                                SizedBox(
                                  width: 44,
                                  child: Center(
                                    child: DsIconButton(
                                      icone: LucideIcons.x,
                                      tooltip: l10n.dsPosLigneRetirer,
                                      taille: 30,
                                      couleur: c.iconMuted,
                                      couleurSurvol: c.dangerTint,
                                      onPressed: onSupprimer == null ? null : () => onSupprimer!(l),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          if (onAjouter != null || afficherTotaux)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                border: Border(top: BorderSide(color: c.borderDefault)),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (onAjouter != null && !lectureSeule)
                    DsButton(
                      libelle: libelleAjouter ?? l10n.dsPosLigneAjouter,
                      icone: LucideIcons.plus,
                      taille: DsButtonTaille.sm,
                      variante: DsButtonVariante.doux,
                      onPressed: onAjouter,
                    ),
                  if (!lectureSeule) ...actionsAjout,
                  if (afficherTotaux) ...[
                    _Stat(l10n.dsPosLigneArticles, '${lignes.length}'),
                    _Stat(l10n.dsPosLigneQuantite, formaterNombre(qte, decimales: qte == qte.roundToDouble() ? 0 : 2)),
                    _Stat(libelleTotal ?? l10n.communTotal, formaterMontant(total, devise), fort: true),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.libelle, this.valeur, {this.fort = false});
  final String libelle;
  final String valeur;
  final bool fort;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: 6,
      children: [
        Text(
          libelle,
          style: t.caption.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500, color: c.textSecondary),
        ),
        Text(
          valeur,
          style: t.body.copyWith(
            fontSize: fort ? 15 : 13.5,
            fontWeight: fort ? FontWeight.w700 : FontWeight.w600,
            fontFeatures: DsTypography.tabular,
          ),
        ),
      ],
    );
  }
}

class _CelluleEditable extends StatefulWidget {
  const _CelluleEditable({
    required this.valeur,
    required this.onChanged,
    this.numerique = false,
    this.suffixe,
    this.erreur,
  });
  final String valeur;
  final ValueChanged<String> onChanged;
  final bool numerique;
  final String? suffixe;
  final String? erreur;
  @override
  State<_CelluleEditable> createState() => _CelluleEditableState();
}

class _CelluleEditableState extends State<_CelluleEditable> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.valeur);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _CelluleEditable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.valeur != _ctrl.text) _ctrl.text = widget.valeur;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: DsRadius.borderSm,
            border: Border.all(
              color: widget.erreur != null ? c.danger : (_focus.hasFocus ? c.borderFocus : c.borderDefault),
            ),
            boxShadow: _focus.hasFocus ? [BoxShadow(color: c.ringFocus, spreadRadius: 3)] : null,
          ),
          child: Row(
            spacing: 4,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  textAlign: widget.numerique ? TextAlign.end : TextAlign.start,
                  keyboardType: widget.numerique ? const TextInputType.numberWithOptions(decimal: true) : null,
                  style: t.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    fontFeatures: DsTypography.tabular,
                  ),
                  decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
                ),
              ),
              if (widget.suffixe != null)
                Text(
                  widget.suffixe!,
                  style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                ),
            ],
          ),
        ),
        if (widget.erreur != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              widget.erreur!,
              style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: c.dangerFg),
            ),
          ),
      ],
    );
  }
}
