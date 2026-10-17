import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_forms.dart';
import 'ds_page.dart';
import 'ds_primitives.dart';

/// Largeurs des colonnes de la grille du panier (`CART_COLS` : produit, colis 72, qté 80, pièces 44, montant 88, 18).
class DsCartColonnes {
  const DsCartColonnes._();
  static const double colis = 72;
  static const double qte = 92; // − n + : jusqu'à 4 chiffres sans débordement
  static const double pieces = 44;
  static const double montant = 88;
  static const double action = 18;
  static const double gap = 6;
}

/// En-tête de la grille du panier (`CartLineHeader`) : Produit · Colis · Qté · Pièces · Montant.
class DsCartLineHeader extends StatelessWidget {
  const DsCartLineHeader({super.key, this.libelles});
  final List<String>? libelles;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final l = libelles ?? [l10n.dsPosProduit, l10n.dsPosColis, l10n.dsPosQte, l10n.dsPosPieces, l10n.dsPosMontant];
    final s = t.overline.copyWith(fontSize: 10.5, letterSpacing: .5, color: c.textMuted);
    Widget col(String texte, double largeur, TextAlign a) => SizedBox(
      width: largeur,
      child: Text(texte.toUpperCase(), style: s, textAlign: a, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Row(
        spacing: DsCartColonnes.gap,
        children: [
          Expanded(child: Text(l[0].toUpperCase(), style: s)),
          col(l[1], DsCartColonnes.colis, TextAlign.start),
          col(l[2], DsCartColonnes.qte, TextAlign.center),
          col(l[3], DsCartColonnes.pieces, TextAlign.end),
          col(l[4], DsCartColonnes.montant, TextAlign.end),
          const SizedBox(width: DsCartColonnes.action),
        ],
      ),
    );
  }
}

/// Ligne du panier (`CartLine`) : nom + code · prix, colis cliquable, compteur − n +, pièces, montant,
/// corbeille au survol. Sans [colis] ni [pieces] : rendu simple (liste).
class DsCartLine extends StatefulWidget {
  const DsCartLine({
    super.key,
    required this.nom,
    required this.prix,
    this.code,
    this.qte = 1,
    this.devise = 'DA',
    this.colis,
    this.pieces,
    this.uniteLibelle,
    this.onPlus,
    this.onMoins,
    this.onRetirer,
    this.onColis,
    this.selectionnee = false,
    this.onTap,
  });
  final String nom;
  final String? code;
  final double prix;
  final double qte;
  final String devise;
  final String? colis;
  final double? pieces;
  final String? uniteLibelle;
  final VoidCallback? onPlus;
  final VoidCallback? onMoins;
  final VoidCallback? onRetirer;
  final VoidCallback? onColis;
  final bool selectionnee;
  final VoidCallback? onTap;

  @override
  State<DsCartLine> createState() => _DsCartLineState();
}

class _DsCartLineState extends State<DsCartLine> {
  bool _survol = false;

  String _q(double v) => v == v.roundToDouble() ? v.toInt().toString() : formaterNombre(v, decimales: 2);

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final w = widget;
    final tableau = w.colis != null || w.pieces != null;
    final total = w.prix * w.qte;
    final num = t.bodySm.copyWith(fontFeatures: DsTypography.tabular);

    Widget bouton(IconData icone, String tooltip, VoidCallback? onTap) => Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: DsRadius.borderSm,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: DsRadius.borderSm,
            border: Border.all(color: c.borderDefault),
          ),
          child: Icon(icone, size: 12, color: c.textSecondary),
        ),
      ),
    );
    final compteur = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        bouton(LucideIcons.minus, l10n.dsPosMoins, w.onMoins),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 22),
          child: Text(
            _q(w.qte),
            textAlign: TextAlign.center,
            style: num.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
        ),
        bouton(LucideIcons.plus, l10n.dsPosPlus, w.onPlus),
      ],
    );
    final corbeille = AnimatedOpacity(
      opacity: _survol ? 1 : 0,
      duration: DsMotion.fast,
      child: Tooltip(
        message: l10n.dsPosRetirer,
        child: InkWell(
          onTap: w.onRetirer,
          child: Icon(LucideIcons.trash2, size: 15, color: c.iconMuted),
        ),
      ),
    );
    final sousTitre =
        '${w.code != null ? '${w.code} · ' : ''}${formaterMontant(w.prix, w.devise)}${w.uniteLibelle != null ? ' / ${w.uniteLibelle}' : ''}';

    Widget contenu;
    if (tableau) {
      contenu = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          spacing: DsCartColonnes.gap,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.nom,
                    style: t.bodySmStrong.copyWith(height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sousTitre,
                    style: t.caption.copyWith(fontSize: 11.5, color: c.textMuted, fontFeatures: DsTypography.tabular),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: DsCartColonnes.colis,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tooltip(
                  message: w.onColis != null ? l10n.dsPosChangerColis : '',
                  child: InkWell(
                    onTap: w.onColis,
                    borderRadius: DsRadius.borderSm,
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.surfaceSunken,
                        borderRadius: DsRadius.borderSm,
                        border: Border.all(color: c.borderSubtle),
                      ),
                      child: Text(
                        w.colis ?? '',
                        style: t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: DsCartColonnes.qte, child: compteur),
            SizedBox(
              width: DsCartColonnes.pieces,
              child: Text(
                _q(w.pieces ?? w.qte),
                textAlign: TextAlign.end,
                style: num.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary),
              ),
            ),
            SizedBox(
              width: DsCartColonnes.montant,
              child: Text(
                formaterNombre(total, decimales: 2),
                textAlign: TextAlign.end,
                style: num.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                maxLines: 1,
              ),
            ),
            SizedBox(width: DsCartColonnes.action, child: corbeille),
          ],
        ),
      );
    } else {
      contenu = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.nom,
                    style: t.bodySmStrong.copyWith(height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sousTitre,
                    style: t.caption.copyWith(color: c.textMuted, fontFeatures: DsTypography.tabular),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            compteur,
            SizedBox(
              width: 92,
              child: Text(
                formaterMontant(total, w.devise),
                textAlign: TextAlign.end,
                style: num.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                maxLines: 1,
              ),
            ),
            corbeille,
          ],
        ),
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: w.onTap,
        child: AnimatedContainer(
          duration: DsMotion.fast,
          decoration: BoxDecoration(
            color: w.selectionnee ? c.surfaceActive : (_survol ? c.surfaceHover : DsColors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: contenu,
        ),
      ),
    );
  }
}

/// Ligne de panier « quantité + nombre » (`CartLineQN`) : 2ᵉ stock saisi en plus de la quantité.
class DsCartLineQN extends StatelessWidget {
  const DsCartLineQN({
    super.key,
    required this.nom,
    required this.prix,
    this.code,
    this.qte = 1,
    this.nombre = '',
    this.uniteNombre = 'nb',
    this.colis,
    this.reserves,
    this.devise = 'DA',
    this.onPlus,
    this.onMoins,
    this.onNombre,
    this.onRetirer,
  });
  final String nom;
  final String? code;
  final double prix;
  final double qte;
  final String nombre;
  final String uniteNombre;
  final String? colis;
  final int? reserves;
  final String devise;
  final VoidCallback? onPlus;
  final VoidCallback? onMoins;
  final ValueChanged<String>? onNombre;
  final VoidCallback? onRetirer;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final q = qte == qte.roundToDouble() ? qte.toInt().toString() : formaterNombre(qte, decimales: 2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 6,
                  children: [
                    Text(
                      '${code ?? ''} · ${colis ?? ''}',
                      style: t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w500, color: c.textMuted),
                    ),
                    if (reserves != null)
                      Row(
                        spacing: 3,
                        children: [
                          Icon(LucideIcons.lock, size: 11, color: c.warningFg),
                          Text(
                            '$reserves',
                            style: t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w500, color: c.warningFg),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 92,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: DsRadius.borderMd,
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              children: [
                DsIconButton(icone: LucideIcons.minus, tooltip: l10n.dsPosMoins, taille: 30, onPressed: onMoins),
                Expanded(
                  child: Text(
                    q,
                    textAlign: TextAlign.center,
                    style: t.bodySm.copyWith(fontWeight: FontWeight.w700, fontFeatures: DsTypography.tabular),
                  ),
                ),
                DsIconButton(icone: LucideIcons.plus, tooltip: l10n.dsPosPlus, taille: 30, onPressed: onPlus),
              ],
            ),
          ),
          Container(
            width: 82,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: c.surfaceCard,
              borderRadius: DsRadius.borderMd,
              border: Border.all(color: nombre.isEmpty ? c.danger : c.borderDefault),
            ),
            child: Row(
              spacing: 4,
              children: [
                Icon(LucideIcons.hash, size: 13, color: c.iconMuted),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: nombre)
                      ..selection = TextSelection.collapsed(offset: nombre.length),
                    onChanged: onNombre,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    style: t.bodySm.copyWith(fontWeight: FontWeight.w700, fontFeatures: DsTypography.tabular),
                    decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
                  ),
                ),
                Text(
                  uniteNombre,
                  style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: c.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              formaterMontant(qte * prix, devise),
              textAlign: TextAlign.end,
              style: t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700, fontFeatures: DsTypography.tabular),
              maxLines: 1,
            ),
          ),
          DsIconButton(icone: LucideIcons.trash2, tooltip: l10n.dsPosRetirer, taille: 28, onPressed: onRetirer),
        ],
      ),
    );
  }
}

/// Carte de session de caisse (`CashSessionCard`) : état ouvert / fermé, solde, actions.
class DsCashSessionCard extends StatelessWidget {
  const DsCashSessionCard({
    super.key,
    required this.ouverte,
    required this.caisse,
    this.code,
    this.ouvertureHeure,
    this.ouverturePar,
    this.solde,
    this.devise = 'DA',
    this.onOuvrir,
    this.onCloturer,
    this.onMouvement,
    this.compact = false,
  });
  final bool ouverte;
  final String caisse;
  final String? code;
  final String? ouvertureHeure;
  final String? ouverturePar;
  final double? solde;
  final String devise;
  final VoidCallback? onOuvrir;
  final VoidCallback? onCloturer;
  final VoidCallback? onMouvement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final fond = ouverte ? c.successTint : c.surfaceSunken;
    final couleur = ouverte ? c.successFg : c.textSecondary;
    if (compact) {
      return Container(
        height: 40,
        padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.borderDefault),
          boxShadow: c.shadowXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ouverte ? c.success : c.textDisabled,
                shape: BoxShape.circle,
                boxShadow: ouverte ? [BoxShadow(color: c.successTint, spreadRadius: 3)] : null,
              ),
            ),
            Text(
              '$caisse · ${ouverte ? '${l10n.dsPosOuverte} ${ouvertureHeure ?? ''}' : l10n.dsPosFermee}',
              style: t.bodySmStrong,
            ),
            if (ouverte && solde != null)
              Container(
                padding: const EdgeInsetsDirectional.only(start: 10),
                decoration: BoxDecoration(
                  border: BorderDirectional(start: BorderSide(color: c.borderDefault)),
                ),
                child: Text(
                  formaterMontant(solde!, devise),
                  style: t.bodySmStrong.copyWith(color: c.textSecondary, fontFeatures: DsTypography.tabular),
                ),
              ),
            if (ouverte) ...[
              if (onMouvement != null)
                DsButton(
                  libelle: l10n.dsPosMouvement,
                  icone: LucideIcons.arrowLeftRight,
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.fantome,
                  onPressed: onMouvement,
                ),
              if (onCloturer != null)
                DsButton(
                  libelle: l10n.dsPosCloturer,
                  icone: LucideIcons.lock,
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.fantome,
                  onPressed: onCloturer,
                ),
            ] else if (onOuvrir != null)
              DsButton(
                libelle: l10n.dsPosOuvrir,
                icone: LucideIcons.lockOpen,
                taille: DsButtonTaille.sm,
                onPressed: onOuvrir,
              ),
          ],
        ),
      );
    }
    final detail = ouverte
        ? [
            if (ouvertureHeure != null) l10n.dsPosOuverteA(ouvertureHeure!) else l10n.dsPosOuverte,
            if (ouverturePar != null) l10n.dsPosPar(ouverturePar!),
          ].join(' ')
        : l10n.dsPosAucuneSession;
    return Container(
      padding: const EdgeInsets.all(DsSpacing.s4),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderDefault),
        boxShadow: c.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(10)),
                child: Icon(ouverte ? LucideIcons.lockOpen : LucideIcons.lock, size: 20, color: couleur),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caisse, style: t.cardTitle.copyWith(fontSize: 15)),
                    Text(
                      '$detail${code != null ? ' · $code' : ''}',
                      style: t.bodySm.copyWith(fontSize: 12.5, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderPill),
                child: Text(
                  ouverte ? l10n.dsPosOuverte : l10n.dsPosFermee,
                  style: t.caption.copyWith(fontWeight: FontWeight.w600, color: couleur),
                ),
              ),
            ],
          ),
          if (ouverte && solde != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dsPosSoldeCourant,
                  style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                ),
                Text.rich(
                  TextSpan(
                    text: formaterNombre(solde!, decimales: 2),
                    children: [
                      TextSpan(
                        text: ' $devise',
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                  style: t.pageTitle.copyWith(fontFeatures: DsTypography.tabular),
                ),
              ],
            ),
          Wrap(
            spacing: DsSpacing.s2,
            runSpacing: DsSpacing.s2,
            children: [
              if (ouverte) ...[
                if (onMouvement != null)
                  DsButton(
                    libelle: l10n.dsPosMouvement,
                    icone: LucideIcons.arrowLeftRight,
                    variante: DsButtonVariante.secondaire,
                    onPressed: onMouvement,
                  ),
                if (onCloturer != null)
                  DsButton(
                    libelle: l10n.dsPosCloturer,
                    icone: LucideIcons.lock,
                    variante: DsButtonVariante.secondaire,
                    onPressed: onCloturer,
                  ),
              ] else if (onOuvrir != null)
                DsButton(libelle: l10n.dsPosOuvrirCaisse, icone: LucideIcons.lockOpen, onPressed: onOuvrir),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pavé numérique (`Numpad`) : touches 48 px (sm 40, lg 56), montants rapides teintés, ⌫, C.
class DsNumpad extends StatelessWidget {
  const DsNumpad({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.montantsRapides = const [],
    this.onEffacer,
    this.hauteurTouche = 48,
    this.decimales = true,
  });

  /// Valeur saisie (chaîne avec virgule décimale).
  final String valeur;
  final ValueChanged<String> onChanged;
  final List<double> montantsRapides;
  final VoidCallback? onEffacer;
  final double hauteurTouche;
  final bool decimales;

  static const _touches = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '00', '0', ','];

  void _presser(String k) {
    var v = valeur;
    if (k == 'back') {
      v = v.isEmpty ? '' : v.substring(0, v.length - 1);
    } else if (k == ',') {
      if (!decimales || v.contains(',')) return;
      v = '${v.isEmpty ? '0' : v},';
    } else {
      if (v == '0') v = '';
      final parties = v.split(',');
      if (parties.length > 1 && parties[1].length >= 2) return;
      v = v + k;
    }
    onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: DsSpacing.s2,
      children: [
        if (montantsRapides.isNotEmpty)
          Row(
            spacing: 6,
            children: [
              for (final a in montantsRapides)
                Expanded(
                  child: _Touche(
                    hauteur: 32,
                    doux: true,
                    onTap: () => onChanged(
                      a == a.roundToDouble() ? a.toInt().toString() : formaterNombre(a, decimales: 2, grouper: false),
                    ),
                    child: Text(formaterNombre(a)),
                  ),
                ),
            ],
          ),
        for (final rangee in [
          [..._touches.sublist(0, 3), 'back'],
          [..._touches.sublist(3, 6), 'C'],
          [..._touches.sublist(6, 9), null],
          [..._touches.sublist(9, 12), null],
        ])
          Row(
            spacing: 6,
            children: [
              for (final k in rangee)
                if (k == null)
                  const Expanded(child: SizedBox.shrink())
                else if (k == 'back')
                  Expanded(
                    child: _Touche(
                      hauteur: hauteurTouche,
                      tooltip: l10n.dsPosEffacer,
                      cle: const ValueKey('numpad_back'),
                      onTap: () => _presser('back'),
                      child: const Icon(LucideIcons.delete, size: 20),
                    ),
                  )
                else if (k == 'C')
                  Expanded(
                    child: _Touche(
                      hauteur: hauteurTouche,
                      danger: true,
                      tooltip: l10n.dsPosToutEffacer,
                      cle: const ValueKey('numpad_c'),
                      onTap: onEffacer ?? () => onChanged(''),
                      child: const Text('C'),
                    ),
                  )
                else
                  Expanded(
                    child: _Touche(
                      hauteur: hauteurTouche,
                      cle: ValueKey('numpad_$k'),
                      desactive: k == ',' && !decimales,
                      onTap: () => _presser(k),
                      child: Text(k),
                    ),
                  ),
            ],
          ),
      ],
    );
  }
}

class _Touche extends StatefulWidget {
  const _Touche({
    required this.child,
    required this.hauteur,
    required this.onTap,
    this.doux = false,
    this.danger = false,
    this.tooltip,
    this.desactive = false,
    this.cle,
  });
  final Widget child;
  final double hauteur;
  final VoidCallback onTap;
  final bool doux;
  final bool danger;
  final String? tooltip;
  final bool desactive;
  final Key? cle;
  @override
  State<_Touche> createState() => _ToucheState();
}

class _ToucheState extends State<_Touche> {
  bool _survol = false;
  bool _presse = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final fond = widget.doux
        ? (_survol ? c.primaryTintHover : c.primaryTint)
        : (_survol ? c.surfaceHover : c.surfaceCard);
    final couleur = widget.danger ? c.dangerFg : (widget.doux ? c.primaryTintFg : c.textPrimary);
    final touche = MouseRegion(
      cursor: widget.desactive ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() {
        _survol = false;
        _presse = false;
      }),
      child: GestureDetector(
        key: widget.cle,
        onTapDown: (_) => setState(() => _presse = true),
        onTapUp: (_) => setState(() => _presse = false),
        onTapCancel: () => setState(() => _presse = false),
        onTap: widget.desactive ? null : widget.onTap,
        child: AnimatedScale(
          scale: _presse ? .96 : 1,
          duration: DsMotion.fast,
          child: Opacity(
            opacity: widget.desactive ? .4 : 1,
            child: AnimatedContainer(
              duration: DsMotion.fast,
              height: widget.hauteur,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fond,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.borderDefault),
              ),
              child: DefaultTextStyle(
                style: t.body.copyWith(
                  fontSize: widget.doux ? 13 : 18,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: couleur,
                  fontFeatures: DsTypography.tabular,
                ),
                child: IconTheme(
                  data: IconThemeData(color: couleur),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip == null) return touche;
    return Tooltip(message: widget.tooltip!, child: touche);
  }
}

/// Information affichée au-dessus du panneau de paiement (client, caisse…).
class DsInfoPaiement {
  const DsInfoPaiement(this.libelle, this.valeur);
  final String libelle;
  final String valeur;
}

/// Panneau de paiement (`PaymentPanel`) : infos, sous-total / remise, bandeau « Total à payer »
/// (dégradé nuit), case « Paiement complet », montant payé 24 px, à rendre / reste, pavé.
class DsPaymentPanel extends StatelessWidget {
  const DsPaymentPanel({
    super.key,
    required this.total,
    required this.paye,
    required this.onPayeChanged,
    required this.paiementComplet,
    required this.onPaiementCompletChanged,
    this.sousTotal,
    this.remise = 0,
    this.devise = 'DA',
    this.infos = const [],
    this.creditAutorise = true,
    this.libelleCredit,
    this.numpad = true,
    this.montantsRapides,
  });
  final double total;
  final double? sousTotal;
  final double remise;
  final String devise;
  final List<DsInfoPaiement> infos;

  /// Montant payé saisi (chaîne, virgule décimale).
  final String paye;
  final ValueChanged<String> onPayeChanged;
  final bool paiementComplet;
  final ValueChanged<bool> onPaiementCompletChanged;
  final bool creditAutorise;
  final String? libelleCredit;
  final bool numpad;
  final List<double>? montantsRapides;

  static double lire(String s) => lireNombre(s) ?? 0;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final payeN = paiementComplet ? total : lire(paye);
    final diff = payeN - total;
    final mauvais = !creditAutorise && diff < 0;
    final rapides =
        montantsRapides ??
        {
          (total / 500).ceil() * 500.0,
          (total / 1000).ceil() * 1000.0,
          (total / 1000).ceil() * 1000.0 + 1000,
        }.where((v) => v > total).take(3).toList();
    final (fondDiff, couleurDiff, iconeDiff, texteDiff) = diff > 0
        ? (c.successTint, c.successFg, LucideIcons.handCoins, l10n.dsPosARendre)
        : diff < 0
        ? (
            mauvais ? c.dangerTint : c.warningTint,
            mauvais ? c.dangerFg : c.warningFg,
            mauvais ? LucideIcons.circleAlert : LucideIcons.clockAlert,
            mauvais ? l10n.dsPosPartielImpossible : (libelleCredit ?? l10n.dsPosResteCredit),
          )
        : (c.surfaceSunken, c.textSecondary, LucideIcons.circleCheck, l10n.dsPosMontantExact);

    final gauche = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 14,
      children: [
        if (infos.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(10)),
            child: Row(
              spacing: 16,
              children: [
                for (final i in infos)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.libelle,
                          style: t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w500, color: c.textMuted),
                        ),
                        Text(
                          i.valeur,
                          style: t.body.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            fontFeatures: DsTypography.tabular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (sousTotal != null || remise > 0)
          Column(
            spacing: 6,
            children: [
              if (sousTotal != null) _LignePaiement(l10n.dsPosTotalAvantRemise, formaterMontant(sousTotal!, devise)),
              if (remise > 0)
                _LignePaiement(l10n.dsPosRemise, '− ${formaterMontant(remise, devise)}', couleur: c.successFg),
            ],
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(gradient: DsColors.gradientNight, borderRadius: DsRadius.borderLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  l10n.dsPosTotalAPayer,
                  style: t.bodySmStrong.copyWith(color: DsColors.blanc.withValues(alpha: .8)),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: formaterNombre(total, decimales: 2),
                  children: [
                    TextSpan(
                      text: ' $devise',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: DsColors.blanc.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
                key: const ValueKey('paiement_total'),
                style: t.montantXl.copyWith(fontSize: 30, color: DsColors.blanc),
              ),
            ],
          ),
        ),
        DsCheckbox(
          cle: const ValueKey('paiement_complet'),
          libelle: l10n.dsPosPaiementComplet,
          valeur: paiementComplet,
          onChanged: onPaiementCompletChanged,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(l10n.dsPosMontantPaye, style: t.label.copyWith(color: c.textSecondary)),
            AnimatedContainer(
              duration: DsMotion.fast,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: paiementComplet ? c.surfaceSunken : c.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: paiementComplet ? c.borderDefault : c.borderFocus),
                boxShadow: paiementComplet ? null : [BoxShadow(color: c.ringFocus, spreadRadius: 3)],
              ),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      paiementComplet ? formaterNombre(total, decimales: 2) : (paye.isEmpty ? '0' : paye),
                      key: const ValueKey('montant_saisi'),
                      style: t.pageTitle.copyWith(
                        fontFeatures: DsTypography.tabular,
                        color: paiementComplet ? c.textSecondary : c.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    devise,
                    style: t.body.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: c.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        AnimatedContainer(
          duration: DsMotion.base,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: fondDiff, borderRadius: BorderRadius.circular(10)),
          child: Row(
            spacing: 10,
            children: [
              Icon(iconeDiff, size: 18, color: couleurDiff),
              Expanded(
                child: Text(
                  texteDiff,
                  style: t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600, color: couleurDiff),
                ),
              ),
              if (diff != 0)
                Text(
                  formaterMontant(diff.abs(), devise),
                  key: const ValueKey('paiement_difference'),
                  style: t.heading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: couleurDiff,
                    fontFeatures: DsTypography.tabular,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    if (!numpad) return gauche;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DsSpacing.s5,
      children: [
        Expanded(child: gauche),
        SizedBox(
          width: 248,
          child: IgnorePointer(
            ignoring: paiementComplet,
            child: AnimatedOpacity(
              opacity: paiementComplet ? .45 : 1,
              duration: DsMotion.base,
              child: DsNumpad(valeur: paye, onChanged: onPayeChanged, montantsRapides: rapides),
            ),
          ),
        ),
      ],
    );
  }
}

class _LignePaiement extends StatelessWidget {
  const _LignePaiement(this.libelle, this.valeur, {this.couleur});
  final String libelle;
  final String valeur;
  final Color? couleur;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final s = t.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500, color: c.textSecondary);
    return Row(
      spacing: 12,
      children: [
        Expanded(child: Text(libelle, style: s)),
        Text(
          valeur,
          style: s.copyWith(color: couleur ?? c.textPrimary, fontFeatures: DsTypography.tabular),
        ),
      ],
    );
  }
}

/// Tuile produit (`ProductTile`) : vignette teintée 72 px, nom, prix, stock ; bouton « Entrée »
/// au survol. [enLigne] : rendu en rangée (liste).
class DsProductTile extends StatefulWidget {
  const DsProductTile({
    super.key,
    required this.nom,
    required this.prix,
    this.code,
    this.stock,
    this.categorie,
    this.image,
    this.devise = 'DA',
    this.onAjouter,
    this.onEntree,
    this.seuilBas = 5,
    this.enLigne = false,
    this.ruptureCliquable = false,
  });
  final String nom;
  final String? code;
  final double prix;
  final double? stock;
  final String? categorie;
  final ImageProvider? image;
  final String devise;
  final VoidCallback? onAjouter;
  final VoidCallback? onEntree;
  final double seuilBas;
  final bool enLigne;

  /// En rupture, la tuile reste cliquable (admin : la caisse propose un transfert depuis un autre magasin).
  final bool ruptureCliquable;

  @override
  State<DsProductTile> createState() => _DsProductTileState();
}

class _DsProductTileState extends State<DsProductTile> {
  bool _survol = false;
  bool _presse = false;

  /// Bouton « Entrée » flottant au-dessus de la carte (grille) : il reste affiché un court instant après la
  /// sortie du pointeur pour pouvoir l'atteindre.
  final _lien = LayerLink();
  final _portail = OverlayPortalController();
  bool _survolEntree = false;
  Timer? _delai;

  static const _delaiMasquage = Duration(milliseconds: 450);

  @override
  void dispose() {
    _delai?.cancel();
    super.dispose();
  }

  void _entrerCarte() {
    _delai?.cancel();
    if (widget.onEntree != null && !widget.enLigne && !_portail.isShowing) _portail.show();
    setState(() => _survol = true);
  }

  void _quitterCarte() {
    setState(() {
      _survol = false;
      _presse = false;
    });
    _planifierMasquage();
  }

  void _planifierMasquage() {
    _delai?.cancel();
    _delai = Timer(_delaiMasquage, () {
      if (!mounted || _survol || _survolEntree) return;
      if (_portail.isShowing) _portail.hide();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final w = widget;
    final teinte = teintePour(w.categorie ?? w.nom);
    final rupture = w.stock != null && w.stock! <= 0;
    final stockTexte = w.stock == null
        ? null
        : Text(
            rupture ? l10n.dsPosRupture : l10n.dsPosEnStock(formaterNombre(w.stock!)),
            style: t.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: rupture ? c.dangerFg : (w.stock! <= w.seuilBas ? c.warningFg : c.textMuted),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    final prixTexte = Text.rich(
      TextSpan(
        text: formaterNombre(w.prix, decimales: 2),
        children: [
          TextSpan(
            text: ' ${w.devise}',
            style: t.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: c.textMuted),
          ),
        ],
      ),
      style: t.bodyStrong.copyWith(fontWeight: FontWeight.w700, fontFeatures: DsTypography.tabular),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    Widget vignette(double taille) => Container(
      width: w.enLigne ? taille : null,
      height: taille,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: w.image != null ? c.surfaceSunken : Color.alphaBlend(teinte.withValues(alpha: .14), c.surfaceCard),
        borderRadius: DsRadius.borderMd,
        image: w.image != null ? DecorationImage(image: w.image!, fit: BoxFit.cover) : null,
      ),
      child: w.image == null ? Icon(LucideIcons.package, size: w.enLigne ? 18 : 36, color: teinte) : null,
    );
    final entree = w.onEntree == null
        ? null
        : Tooltip(
            message: l10n.dsPosEntreeRapide,
            child: DsButton(
              libelle: l10n.dsPosEntree,
              icone: LucideIcons.packagePlus,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.secondaire,
              pleineLargeur: !w.enLigne,
              onPressed: w.onEntree,
            ),
          );

    if (w.enLigne) {
      return MouseRegion(
        cursor: rupture && !w.ruptureCliquable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _survol = true),
        onExit: (_) => setState(() => _survol = false),
        child: GestureDetector(
          onTap: rupture && !w.ruptureCliquable ? null : w.onAjouter,
          child: Opacity(
            opacity: rupture ? .55 : 1,
            child: AnimatedContainer(
              duration: DsMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _survol && !rupture ? c.surfaceHover : DsColors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                spacing: 12,
                children: [
                  vignette(40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.nom,
                          style: t.bodySmStrong.copyWith(height: 1.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (w.code != null)
                          Text(w.code!, style: t.caption.copyWith(fontSize: 11.5, color: c.textMuted)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      w.categorie ?? '',
                      style: t.bodySm.copyWith(fontSize: 12.5, color: c.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 90, child: stockTexte ?? const SizedBox.shrink()),
                  SizedBox(
                    width: 96,
                    child: Align(alignment: AlignmentDirectional.centerEnd, child: prixTexte),
                  ),
                  SizedBox(
                    width: 92,
                    child: AnimatedOpacity(
                      opacity: _survol ? 1 : 0,
                      duration: DsMotion.base,
                      child: Align(alignment: AlignmentDirectional.centerEnd, child: entree ?? const SizedBox.shrink()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final actif = _survol && !rupture;
    final carte = MouseRegion(
      cursor: rupture && !w.ruptureCliquable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => _entrerCarte(),
      onExit: (_) => _quitterCarte(),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _presse = true),
        onTapUp: (_) => setState(() => _presse = false),
        onTapCancel: () => setState(() => _presse = false),
        onTap: rupture && !w.ruptureCliquable ? null : w.onAjouter,
        child: AnimatedScale(
          scale: _presse ? .98 : 1,
          duration: DsMotion.fast,
          child: Opacity(
            opacity: rupture ? .55 : 1,
            child: AnimatedContainer(
              duration: DsMotion.base,
              curve: DsMotion.standard,
              padding: const EdgeInsets.all(8),
              transform: Matrix4.translationValues(0, actif ? -2 : 0, 0),
              decoration: BoxDecoration(
                color: actif ? Color.alphaBlend(c.primaryTint.withValues(alpha: .45), c.surfaceCard) : c.surfaceCard,
                borderRadius: DsRadius.borderLg,
                border: Border.all(color: actif ? c.primary : c.borderDefault, width: actif ? 1.5 : 1),
                boxShadow: actif ? [...c.shadowMd, BoxShadow(color: c.ringFocus, spreadRadius: 2)] : c.shadowXs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  vignette(104),
                  Text(
                    w.nom,
                    style: t.bodySmStrong.copyWith(height: 1.25),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Expanded(child: prixTexte),
                      ?stockTexte,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (w.onEntree == null) return carte;
    return OverlayPortal(
      controller: _portail,
      overlayChildBuilder: (_) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: _lien,
          showWhenUnlinked: false,
          // À cheval sur le bord supérieur, côté fin de lecture : hors de la carte, sans en changer la taille.
          targetAnchor: rtl ? Alignment.topLeft : Alignment.topRight,
          followerAnchor: rtl ? Alignment.centerLeft : Alignment.centerRight,
          offset: Offset(rtl ? -6 : 6, -4),
          child: MouseRegion(
            onEnter: (_) {
              _delai?.cancel();
              _survolEntree = true;
            },
            onExit: (_) {
              _survolEntree = false;
              _planifierMasquage();
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: DsMotion.base,
              curve: DsMotion.standard,
              builder: (context, v, child) => Opacity(
                opacity: v,
                child: Transform.scale(scale: .9 + .1 * v, child: child),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: DecoratedBox(
                  decoration: BoxDecoration(borderRadius: DsRadius.borderMd, boxShadow: c.shadowMd),
                  child: Tooltip(
                    message: l10n.dsPosEntreeRapide,
                    child: DsButton(
                      key: ValueKey('${w.key is ValueKey ? (w.key! as ValueKey).value : w.nom}_entree'),
                      libelle: l10n.dsPosEntree,
                      icone: LucideIcons.packagePlus,
                      taille: DsButtonTaille.sm,
                      onPressed: () {
                        _delai?.cancel();
                        _survolEntree = false;
                        if (_portail.isShowing) _portail.hide();
                        w.onEntree!();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(link: _lien, child: carte),
    );
  }
}

/// Carte de quota Smart Scan (`QuotaCard`) : utilisés / limite, barre, restants, renouvellement.
class DsQuotaCard extends StatelessWidget {
  const DsQuotaCard({
    super.key,
    required this.utilises,
    required this.limite,
    this.plan = 'Standard',
    this.renouvellement,
    this.horsLigne = false,
    this.onActualiser,
  });
  final int utilises;
  final int limite;
  final String plan;
  final String? renouvellement;
  final bool horsLigne;
  final VoidCallback? onActualiser;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final p = limite == 0 ? 0.0 : utilises / limite;
    final ton = p >= 1 ? DsProgressTon.danger : (p >= .8 ? DsProgressTon.avertissement : DsProgressTon.primaire);
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DsSpacing.s3,
        children: [
          Row(
            spacing: 10,
            children: [
              DsIconBox(LucideIcons.scanText, fond: c.primaryTint, couleur: c.primaryTintFg),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: l10n.dsPosSmartScan,
                    children: [
                      TextSpan(
                        text: '  $plan',
                        style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                      ),
                    ],
                  ),
                  style: t.cardTitle,
                ),
              ),
              if (onActualiser != null)
                DsIconButton(
                  icone: LucideIcons.refreshCw,
                  tooltip: l10n.dsPosActualiser,
                  taille: 28,
                  couleur: c.iconMuted,
                  onPressed: onActualiser,
                ),
            ],
          ),
          if (horsLigne)
            Row(
              spacing: 8,
              children: [
                Icon(LucideIcons.cloudOff, size: 16, color: c.textSecondary),
                Expanded(
                  child: Text(l10n.dsPosQuotaHorsLigne, style: t.label.copyWith(color: c.textSecondary)),
                ),
              ],
            )
          else ...[
            Text.rich(
              TextSpan(
                text: '$utilises',
                children: [
                  TextSpan(
                    text: ' ${l10n.dsPosScansMois(limite)}',
                    style: t.body.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                  ),
                ],
              ),
              style: t.pageTitle.copyWith(fontFeatures: DsTypography.tabular),
            ),
            DsProgressBar(
              valeur: utilises.toDouble(),
              max: limite.toDouble(),
              ton: horsLigne ? DsProgressTon.primaire : ton,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.dsPosRestants((limite - utilises).clamp(0, limite)),
                    style: t.caption.copyWith(color: c.textMuted),
                  ),
                ),
                if (renouvellement != null)
                  Text(l10n.dsPosRenouvellement(renouvellement!), style: t.caption.copyWith(color: c.textMuted)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Onglet de vente parallèle.
class DsOngletVente {
  const DsOngletVente({required this.cle, required this.libelle, this.meta, this.compte = 0, this.icone});
  final Object cle;
  final String libelle;
  final String? meta;
  final int compte;
  final IconData? icone;
}

/// Onglets des ventes en parallèle (`SaleTabs`) : onglets 40 px, bouton « + » pointillé, compteur n / max.
class DsSaleTabs extends StatelessWidget {
  const DsSaleTabs({
    super.key,
    required this.onglets,
    required this.courant,
    required this.onChanged,
    this.onAjouter,
    this.onFermer,
    this.max = 5,
  });
  final List<DsOngletVente> onglets;
  final Object? courant;
  final ValueChanged<Object> onChanged;
  final VoidCallback? onAjouter;
  final ValueChanged<Object>? onFermer;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final plein = onglets.length >= max;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        spacing: 6,
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 4,
                children: [
                  for (final o in onglets)
                    _OngletVente(
                      onglet: o,
                      actif: o.cle == courant,
                      fermable: onglets.length > 1 && onFermer != null,
                      onTap: () => onChanged(o.cle),
                      onFermer: () => onFermer?.call(o.cle),
                    ),
                ],
              ),
            ),
          ),
          Tooltip(
            message: plein ? l10n.dsPosMaxVentes(max) : '${l10n.dsPosNouvelleVente} (Ctrl+T)',
            child: InkWell(
              key: const ValueKey('vente_ajouter'),
              onTap: plein ? null : onAjouter,
              borderRadius: BorderRadius.circular(9),
              hoverColor: c.primaryTint,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: plein ? c.borderDefault : c.borderStrong),
                ),
                child: Icon(LucideIcons.plus, size: 16, color: plein ? c.textDisabled : c.primaryTintFg),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${onglets.length} / $max ${l10n.dsPosVentes}',
              style: t.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: plein ? c.warningFg : c.textMuted,
                fontFeatures: DsTypography.tabular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OngletVente extends StatefulWidget {
  const _OngletVente({
    required this.onglet,
    required this.actif,
    required this.fermable,
    required this.onTap,
    required this.onFermer,
  });
  final DsOngletVente onglet;
  final bool actif;
  final bool fermable;
  final VoidCallback onTap;
  final VoidCallback onFermer;
  @override
  State<_OngletVente> createState() => _OngletVenteState();
}

class _OngletVenteState extends State<_OngletVente> {
  bool _survol = false;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final on = widget.actif;
    final o = widget.onglet;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        key: ValueKey('vente_onglet_${o.cle}'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DsMotion.fast,
          curve: DsMotion.standard,
          height: 40,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          decoration: BoxDecoration(
            color: on ? c.primary : (_survol ? c.surfaceHover : c.surfaceCard),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: on ? c.primary : (_survol ? c.borderStrong : c.borderDefault)),
            boxShadow: on ? c.shadowSm : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(o.icone ?? LucideIcons.receipt, size: 15, color: on ? c.primaryFg : c.iconMuted),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.libelle,
                    style: t.bodySm.copyWith(
                      fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                      height: 1.15,
                      color: on ? c.primaryFg : c.textSecondary,
                    ),
                  ),
                  if (o.meta != null)
                    Text(
                      o.meta!,
                      style: t.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                        color: on ? c.primaryFg.withValues(alpha: .85) : c.textMuted,
                        fontFeatures: DsTypography.tabular,
                      ),
                    ),
                ],
              ),
              if (o.compte > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? c.primaryFg : c.surfaceSunken,
                    borderRadius: BorderRadius.circular(10),
                    border: on ? null : Border.all(color: c.borderDefault),
                  ),
                  child: Text(
                    '${o.compte}',
                    style: t.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: on ? c.primary : c.textSecondary,
                      fontFeatures: DsTypography.tabular,
                    ),
                  ),
                ),
              if (widget.fermable)
                Opacity(
                  opacity: on || _survol ? 1 : .4,
                  child: Tooltip(
                    message: l10n.dsPosFermerVente,
                    child: InkWell(
                      onTap: widget.onFermer,
                      borderRadius: DsRadius.borderSm,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Icon(LucideIcons.x, size: 14, color: on ? c.primaryFg : c.iconMuted),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau total (`TotalPanel`) : dégradé nuit, articles / sous-total, remise, « TOTAL À PAYER » 32 px.
class DsTotalPanel extends StatefulWidget {
  const DsTotalPanel({
    super.key,
    required this.total,
    this.sousTotal,
    this.remise = 0,
    this.articles = 0,
    this.devise = 'DA',
    this.libelle,
  });
  final double total;
  final double? sousTotal;
  final double remise;
  final int articles;
  final String devise;
  final String? libelle;

  @override
  State<DsTotalPanel> createState() => _DsTotalPanelState();
}

class _DsTotalPanelState extends State<DsTotalPanel> {
  bool _bump = false;

  @override
  void didUpdateWidget(covariant DsTotalPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.total != widget.total) {
      setState(() => _bump = true);
      Future<void>.delayed(DsMotion.base, () {
        if (mounted) setState(() => _bump = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final w = widget;
    final ligne = t.bodySm.copyWith(fontWeight: FontWeight.w500, color: DsColors.blanc.withValues(alpha: .72));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: DsColors.gradientNight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DsColors.violet500.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shoppingBasket, size: 15, color: ligne.color),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.dsPosArticles(w.articles), style: ligne)),
              if (w.sousTotal != null)
                Text(
                  '${l10n.dsPosSousTotal} ${formaterMontant(w.sousTotal!, w.devise)}',
                  style: ligne.copyWith(fontFeatures: DsTypography.tabular),
                ),
            ],
          ),
          if (w.remise > 0)
            Row(
              children: [
                Expanded(child: Text(l10n.dsPosRemise, style: ligne)),
                Text(
                  '− ${formaterMontant(w.remise, w.devise)}',
                  style: ligne.copyWith(color: DsColors.teal300, fontFeatures: DsTypography.tabular),
                ),
              ],
            ),
          Container(height: 1, color: DsColors.blanc.withValues(alpha: .12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  (w.libelle ?? l10n.dsPosTotalAPayer).toUpperCase(),
                  style: t.overline.copyWith(fontSize: 12, color: DsColors.violet300),
                ),
              ),
              AnimatedScale(
                scale: _bump ? 1.03 : 1,
                duration: DsMotion.base,
                curve: DsMotion.emphasized,
                alignment: Directionality.of(context) == TextDirection.rtl
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    text: formaterNombre(w.total, decimales: 2),
                    children: [
                      TextSpan(
                        text: '  ${w.devise}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DsColors.violet300),
                      ),
                    ],
                  ),
                  key: const ValueKey('pos_total'),
                  style: t.montantXl.copyWith(color: DsColors.blanc),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Calculatrice (`Calculator` v2.2) : historique, expression, résultat 28 px, grille 4 colonnes.
class DsCalculator extends StatefulWidget {
  const DsCalculator({super.key, this.onUtiliser, this.libelleUtiliser});
  final ValueChanged<double>? onUtiliser;
  final String? libelleUtiliser;

  @override
  State<DsCalculator> createState() => _DsCalculatorState();

  /// Évalue une expression (+ − × ÷ % parenthèses) ; `null` si invalide.
  static double? evaluer(String expr) {
    final e = expr
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    if (e.isEmpty) return null;
    final p = _Parseur(e);
    try {
      final v = p.expression();
      if (p.pos != e.length) return null;
      if (v.isNaN || v.isInfinite) return null;
      return (v * 100).round() / 100;
    } catch (_) {
      return null;
    }
  }
}

class _Parseur {
  _Parseur(this.s);
  final String s;
  int pos = 0;

  double expression() {
    var v = terme();
    while (pos < s.length && (s[pos] == '+' || s[pos] == '-')) {
      final op = s[pos++];
      final r = terme();
      v = op == '+' ? v + r : v - r;
    }
    return v;
  }

  double terme() {
    var v = facteur();
    while (pos < s.length && (s[pos] == '*' || s[pos] == '/')) {
      final op = s[pos++];
      final r = facteur();
      v = op == '*' ? v * r : v / r;
    }
    return v;
  }

  double facteur() {
    if (pos < s.length && s[pos] == '-') {
      pos++;
      return -facteur();
    }
    if (pos < s.length && s[pos] == '(') {
      pos++;
      final v = expression();
      if (pos >= s.length || s[pos] != ')') throw const FormatException();
      pos++;
      return pourcent(v);
    }
    final debut = pos;
    while (pos < s.length && (RegExp(r'[0-9.]').hasMatch(s[pos]))) {
      pos++;
    }
    if (debut == pos) throw const FormatException();
    final v = double.parse(s.substring(debut, pos));
    return pourcent(v);
  }

  double pourcent(double v) {
    if (pos < s.length && s[pos] == '%') {
      pos++;
      return v / 100;
    }
    return v;
  }
}

class _DsCalculatorState extends State<DsCalculator> {
  String _expr = '';
  final List<(String, double)> _hist = [];
  final _focus = FocusNode();

  double? get _resultat => DsCalculator.evaluer(_expr);

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _presser(String k) {
    setState(() {
      if (k == 'C') {
        _expr = '';
      } else if (k == '⌫') {
        _expr = _expr.isEmpty ? '' : _expr.substring(0, _expr.length - 1);
      } else if (k == '=') {
        final r = _resultat;
        if (r != null) {
          _hist.insert(0, (_expr, r));
          if (_hist.length > 4) _hist.removeLast();
          _expr = formaterNombre(r, decimales: r == r.roundToDouble() ? 0 : 2, grouper: false);
        }
      } else {
        _expr += k;
      }
    });
  }

  KeyEventResult _clavier(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    const map = {'*': '×', '/': '÷', '-': '−', '.': ','};
    final k = e.logicalKey;
    String? touche;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      touche = '=';
    } else if (k == LogicalKeyboardKey.backspace) {
      touche = '⌫';
    } else if (k == LogicalKeyboardKey.escape) {
      touche = 'C';
    } else if (e.character != null && e.character!.isNotEmpty) {
      final ch = map[e.character] ?? e.character!;
      if (RegExp(r'^[0-9+%(),]$').hasMatch(ch) || '×÷−'.contains(ch)) touche = ch;
    }
    if (touche == null) return KeyEventResult.ignored;
    _presser(touche);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final r = _resultat;
    const touches = [
      'C',
      '(',
      ')',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '−',
      '1',
      '2',
      '3',
      '+',
      '%',
      '0',
      ',',
      '=',
    ];
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _clavier,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DsSpacing.s3,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: DsRadius.borderLg,
              border: Border.all(color: c.borderSubtle),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  for (final (e, v) in _hist.take(2))
                    Text(
                      '$e = ${formaterNombre(v, decimales: 2)}',
                      style: t.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.textMuted,
                        fontFeatures: DsTypography.tabular,
                      ),
                    ),
                  Text(
                    _expr.isEmpty ? '0' : _expr,
                    key: const ValueKey('calc_expr'),
                    style: t.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                      fontFeatures: DsTypography.tabular,
                    ),
                  ),
                  Text(
                    r != null ? formaterNombre(r, decimales: 2) : '—',
                    key: const ValueKey('calc_resultat'),
                    style: t.kpi,
                  ),
                ],
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              spacing: 8,
              children: [
                for (var i = 0; i < touches.length; i += 4)
                  Row(
                    spacing: 8,
                    children: [
                      for (final k in touches.sublist(i, i + 4))
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final op = '÷×−+%()'.contains(k);
                              final eq = k == '=';
                              final clr = k == 'C';
                              return Material(
                                color: eq ? c.primary : (op ? c.primaryTint : (clr ? c.dangerTint : c.surfaceCard)),
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  key: ValueKey('calc_$k'),
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _presser(k),
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: eq ? null : Border.all(color: c.borderDefault),
                                      boxShadow: eq ? null : c.shadowXs,
                                    ),
                                    child: Text(
                                      k,
                                      style: t.heading.copyWith(
                                        fontSize: 18,
                                        color: eq
                                            ? c.primaryFg
                                            : (op ? c.primaryTintFg : (clr ? c.dangerFg : c.textPrimary)),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            spacing: DsSpacing.s2,
            children: [
              DsButton(
                libelle: l10n.dsPosEffacer,
                icone: LucideIcons.delete,
                variante: DsButtonVariante.secondaire,
                delaiGarde: Duration.zero,
                onPressed: () => _presser('⌫'),
              ),
              if (widget.onUtiliser != null)
                Expanded(
                  child: DsButton(
                    libelle: widget.libelleUtiliser ?? l10n.dsCalcUtiliser,
                    icone: LucideIcons.check,
                    pleineLargeur: true,
                    onPressed: r == null ? null : () => widget.onUtiliser!(r),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
