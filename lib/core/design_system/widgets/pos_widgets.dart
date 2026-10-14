import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_page.dart';

/// Ligne de panier (POS).
class CartLine extends StatelessWidget {
  const CartLine({
    super.key,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    required this.total,
    this.remisePct = 0,
    this.sousTitre,
    this.selectionnee = false,
    this.devise = 'DA',
    this.onTap,
    this.onPlus,
    this.onMoins,
    this.onSupprimer,
  });

  final String designation;
  final String? sousTitre;
  final double quantite;
  final double prixUnitaire;
  final double remisePct;
  final double total;
  final bool selectionnee;
  final String devise;
  final VoidCallback? onTap;
  final VoidCallback? onPlus;
  final VoidCallback? onMoins;
  final VoidCallback? onSupprimer;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final q = quantite == quantite.roundToDouble() ? quantite.toInt().toString() : quantite.toStringAsFixed(2);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
        decoration: BoxDecoration(
          color: selectionnee ? c.selection : c.surface,
          border: Border(
            bottom: BorderSide(color: c.bordure),
            left: BorderSide(color: selectionnee ? c.primaire : const Color(0x00000000), width: 3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(designation, style: t.corpsFort, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    '${formaterMontant(prixUnitaire, devise)}${remisePct > 0 ? '  −${remisePct.toStringAsFixed(0)} %' : ''}${sousTitre == null ? '' : '  ·  $sousTitre'}',
                    style: t.petit.copyWith(color: c.texteSecondaire),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            DsIconButton(icone: LucideIcons.minus, tooltip: '−1', taille: 28, onPressed: onMoins),
            SizedBox(
              width: 40,
              child: Text(q, textAlign: TextAlign.center, style: t.corpsFort),
            ),
            DsIconButton(icone: LucideIcons.plus, tooltip: '+1', taille: 28, onPressed: onPlus),
            const SizedBox(width: DsSpacing.md),
            SizedBox(
              width: 110,
              child: Text(
                formaterMontant(total, devise),
                textAlign: TextAlign.end,
                style: t.corpsFort.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(width: DsSpacing.xs),
            DsIconButton(icone: LucideIcons.x, tooltip: '×', taille: 28, couleur: c.danger, onPressed: onSupprimer),
          ],
        ),
      ),
    );
  }
}

/// Pavé numérique (montants, quantités).
class Numpad extends StatelessWidget {
  const Numpad({super.key, required this.onTouche, this.onEffacer, this.onValider, this.touchesRapides = const []});

  final ValueChanged<String> onTouche;
  final VoidCallback? onEffacer;
  final VoidCallback? onValider;

  /// Montants rapides (billets) affichés sous le pavé.
  final List<double> touchesRapides;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    Widget touche(String s, {VoidCallback? action, Color? fond, IconData? icone, Key? cle}) => Expanded(
      child: Padding(
        key: cle,
        padding: const EdgeInsets.all(2),
        child: Material(
          color: fond ?? c.surfaceAttenuee,
          borderRadius: DsRadius.borderMd,
          child: InkWell(
            onTap: action ?? () => onTouche(s),
            borderRadius: DsRadius.borderMd,
            child: SizedBox(
              height: 44,
              child: Center(
                child: icone != null ? Icon(icone, size: DsTailles.icone, color: c.texte) : Text(s, style: t.titreSm),
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final rangee in const [
          ['7', '8', '9'],
          ['4', '5', '6'],
          ['1', '2', '3'],
        ])
          Row(children: [for (final s in rangee) touche(s)]),
        Row(
          children: [
            touche('0'),
            touche('.'),
            touche('⌫', action: onEffacer, icone: LucideIcons.delete),
          ],
        ),
        if (touchesRapides.isNotEmpty)
          Row(
            children: [
              for (final m in touchesRapides)
                touche(m.toStringAsFixed(0), action: () => onTouche('+${m.toStringAsFixed(0)}'), fond: c.primaireDoux),
            ],
          ),
        if (onValider != null)
          Row(
            children: [
              touche(
                'OK',
                action: onValider,
                fond: c.primaire,
                icone: LucideIcons.check,
                cle: const ValueKey('numpad_ok'),
              ),
            ],
          ),
      ],
    );
  }
}

/// Calculatrice simple (+ − × ÷), résultat réutilisable comme montant.
class Calculator extends StatefulWidget {
  const Calculator({super.key, this.onUtiliser, this.libelleUtiliser});
  final ValueChanged<double>? onUtiliser;
  final String? libelleUtiliser;

  @override
  State<Calculator> createState() => _CalculatorState();

  /// Évalue une expression simple (gauche à droite avec priorité × ÷).
  static double? evaluer(String expr) {
    final e = expr
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    if (e.isEmpty) return null;
    final tokens = RegExp(r'(\d+\.?\d*|[+\-*/])').allMatches(e).map((m) => m.group(0)!).toList();
    if (tokens.isEmpty) return null;
    final valeurs = <double>[];
    final ops = <String>[];
    var attendNombre = true;
    for (final t in tokens) {
      if (attendNombre) {
        if (t == '-') {
          valeurs.add(0);
          ops.add('-');
          continue;
        }
        final v = double.tryParse(t);
        if (v == null) return null;
        valeurs.add(v);
        attendNombre = false;
      } else {
        if (!'+-*/'.contains(t)) return null;
        ops.add(t);
        attendNombre = true;
      }
    }
    if (attendNombre) return null;
    // × ÷ d'abord
    for (var i = 0; i < ops.length;) {
      if (ops[i] == '*' || ops[i] == '/') {
        final r = ops[i] == '*'
            ? valeurs[i] * valeurs[i + 1]
            : (valeurs[i + 1] == 0 ? double.nan : valeurs[i] / valeurs[i + 1]);
        valeurs[i] = r;
        valeurs.removeAt(i + 1);
        ops.removeAt(i);
      } else {
        i++;
      }
    }
    var r = valeurs.first;
    for (var i = 0; i < ops.length; i++) {
      r = ops[i] == '+' ? r + valeurs[i + 1] : r - valeurs[i + 1];
    }
    return r.isNaN ? null : r;
  }
}

class _CalculatorState extends State<Calculator> {
  String _expr = '';

  double? get _resultat => Calculator.evaluer(_expr);

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    Widget touche(String s, {VoidCallback? action, Color? fond}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: fond ?? c.surfaceAttenuee,
          borderRadius: DsRadius.borderMd,
          child: InkWell(
            onTap: action ?? () => setState(() => _expr += s),
            borderRadius: DsRadius.borderMd,
            child: SizedBox(
              height: 44,
              child: Center(child: Text(s, style: t.titreSm)),
            ),
          ),
        ),
      ),
    );
    final r = _resultat;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(DsSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceAttenuee,
            borderRadius: DsRadius.borderMd,
            border: Border.all(color: c.bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _expr.isEmpty ? '0' : _expr,
                style: t.corps.copyWith(color: c.texteSecondaire),
                key: const ValueKey('calc_expr'),
              ),
              Text(r == null ? '' : r.toStringAsFixed(2), style: t.chiffreLg, key: const ValueKey('calc_resultat')),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.sm),
        for (final rangee in const [
          ['7', '8', '9', '÷'],
          ['4', '5', '6', '×'],
          ['1', '2', '3', '−'],
          ['0', '.', '%', '+'],
        ])
          Row(
            children: [
              for (final s in rangee)
                touche(
                  s,
                  fond: '÷×−+'.contains(s) ? c.primaireDoux : null,
                  action: s == '%'
                      ? () => setState(() => r == null ? null : _expr = (r / 100).toStringAsFixed(2))
                      : null,
                ),
            ],
          ),
        Row(
          children: [
            touche('C', fond: c.dangerDoux, action: () => setState(() => _expr = '')),
            touche(
              '⌫',
              action: () => setState(() => _expr = _expr.isEmpty ? '' : _expr.substring(0, _expr.length - 1)),
            ),
            touche(
              '=',
              fond: c.primaire,
              action: () => setState(() => r == null ? null : _expr = r.toStringAsFixed(2)),
            ),
          ],
        ),
        if (widget.onUtiliser != null) ...[
          const SizedBox(height: DsSpacing.sm),
          DsButton(
            libelle: widget.libelleUtiliser ?? 'OK',
            icone: LucideIcons.check,
            pleineLargeur: true,
            onPressed: r == null ? null : () => widget.onUtiliser!(r),
          ),
        ],
      ],
    );
  }
}

/// Panneau de paiement : modes, montant, versé / reste / monnaie.
class PaymentPanel extends StatelessWidget {
  const PaymentPanel({
    super.key,
    required this.modes,
    required this.modeCourant,
    required this.onMode,
    required this.montantSaisi,
    required this.onMontantChange,
    required this.onAjouter,
    required this.paiements,
    required this.onRetirerPaiement,
    required this.totalNet,
    required this.verse,
    required this.reste,
    required this.monnaie,
    this.devise = 'DA',
    this.libelleAjouter = 'OK',
    required this.libelleVerse,
    required this.libelleReste,
    required this.libelleMonnaie,
    this.touchesRapides = const [100, 200, 500, 1000, 2000],
  });

  final List<(String code, String libelle)> modes;
  final String modeCourant;
  final ValueChanged<String> onMode;
  final String montantSaisi;
  final ValueChanged<String> onMontantChange;
  final VoidCallback onAjouter;
  final List<(String mode, double montant)> paiements;
  final ValueChanged<int> onRetirerPaiement;
  final double totalNet;
  final double verse;
  final double reste;
  final double monnaie;
  final String devise;
  final String libelleAjouter;
  final String libelleVerse;
  final String libelleReste;
  final String libelleMonnaie;
  final List<double> touchesRapides;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: DsSpacing.xs,
          runSpacing: DsSpacing.xs,
          children: [
            for (final (code, libelle) in modes)
              DsButton(
                libelle: libelle,
                taille: DsButtonTaille.sm,
                variante: modeCourant == code ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                delaiGarde: Duration.zero,
                onPressed: () => onMode(code),
              ),
          ],
        ),
        const SizedBox(height: DsSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
          decoration: BoxDecoration(
            color: c.surfaceAttenuee,
            borderRadius: DsRadius.borderMd,
            border: Border.all(color: c.bordureForte),
          ),
          child: Text(
            montantSaisi.isEmpty ? reste.toStringAsFixed(2) : montantSaisi,
            key: const ValueKey('montant_saisi'),
            textAlign: TextAlign.end,
            style: t.chiffreLg.copyWith(color: montantSaisi.isEmpty ? c.texteAttenue : c.texte),
          ),
        ),
        const SizedBox(height: DsSpacing.xs),
        Numpad(
          onTouche: (s) {
            if (s.startsWith('+')) {
              final v = double.tryParse(s.substring(1)) ?? 0;
              final actuel = double.tryParse(montantSaisi) ?? 0;
              onMontantChange((actuel + v).toStringAsFixed(0));
            } else {
              onMontantChange(montantSaisi + s);
            }
          },
          onEffacer: () =>
              onMontantChange(montantSaisi.isEmpty ? '' : montantSaisi.substring(0, montantSaisi.length - 1)),
          onValider: onAjouter,
          touchesRapides: touchesRapides,
        ),
        if (paiements.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.sm),
          for (final (i, p) in paiements.indexed)
            Row(
              children: [
                Expanded(child: Text(p.$1, style: t.petit)),
                Text(formaterMontant(p.$2, devise), style: t.petitFort),
                DsIconButton(
                  icone: LucideIcons.x,
                  tooltip: '×',
                  taille: 24,
                  couleur: c.danger,
                  onPressed: () => onRetirerPaiement(i),
                ),
              ],
            ),
        ],
        const SizedBox(height: DsSpacing.sm),
        _ligne(context, libelleVerse, formaterMontant(verse, devise)),
        _ligne(
          context,
          libelleReste,
          formaterMontant(reste, devise),
          fort: true,
          couleur: reste > 0 ? c.danger : c.succes,
        ),
        if (monnaie > 0) _ligne(context, libelleMonnaie, formaterMontant(monnaie, devise), fort: true, couleur: c.info),
      ],
    );
  }

  Widget _ligne(BuildContext context, String l, String v, {bool fort = false, Color? couleur}) {
    final t = context.ds.typo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(l, style: fort ? t.corpsFort : t.corps)),
          Text(v, style: (fort ? t.titreSm : t.corps).copyWith(color: couleur)),
        ],
      ),
    );
  }
}
