import 'package:barcode/barcode.dart' as bc;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';
import 'ds_page.dart';

/// Formats de code-barres pris en charge par [DsBarcode].
enum DsBarcodeFormat { ean13, code128, qr }

/// Code-barres vectoriel (EAN-13, CODE128, QR) tracé aux dimensions données, toujours en noir
/// sur fond clair (étiquette imprimable).
class DsBarcode extends StatelessWidget {
  const DsBarcode({
    super.key,
    required this.valeur,
    this.format = DsBarcodeFormat.code128,
    this.hauteur = 40,
    this.largeurModule = 1.4,
    this.couleur = DsColors.noirTicket,
    this.tailleQr = 120,
  });
  final String valeur;
  final DsBarcodeFormat format;
  final double hauteur;

  /// Largeur d'un module (barre la plus fine) pour les codes 1D.
  final double largeurModule;
  final Color couleur;
  final double tailleQr;

  /// Validité d'un EAN-13 (13 chiffres + somme de contrôle).
  static bool ean13Valide(String v) => RegExp(r'^\d{13}$').hasMatch(v) && _controle12(v.substring(0, 12)) == v[12];

  /// Génère un EAN-13 à partir d'un préfixe (613 = Algérie) et d'un suffixe aléatoire.
  static String genererEan13({String prefixe = '613', int? graine}) {
    var s = prefixe;
    var x = graine ?? DateTime.now().microsecondsSinceEpoch;
    while (s.length < 12) {
      x = (x * 1103515245 + 12345) & 0x7fffffff;
      s += ((x >> 16) % 10).toString();
    }
    return s + _controle12(s);
  }

  /// Code automatique §8.10 : `CAISSEDZ` + date `AAAAMMJJ` + séquence sur 4 chiffres.
  static String codeAuto(int sequence, [DateTime? date]) {
    final d = date ?? DateTime.now();
    final ymd = '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return 'CAISSEDZ$ymd${sequence.toString().padLeft(4, '0')}';
  }

  static String _controle12(String s) {
    var t = 0;
    for (var i = 0; i < 12; i++) {
      t += int.parse(s[i]) * (i.isOdd ? 3 : 1);
    }
    return ((10 - t % 10) % 10).toString();
  }

  @override
  Widget build(BuildContext context) {
    if (format == DsBarcodeFormat.qr) {
      return SizedBox(
        width: tailleQr,
        height: tailleQr,
        child: CustomPaint(painter: _PeintreBarcode(bc.Barcode.qrCode(), valeur, couleur, carre: true)),
      );
    }
    final codeur = format == DsBarcodeFormat.ean13 ? bc.Barcode.ean13() : bc.Barcode.code128();
    final modules = format == DsBarcodeFormat.ean13 ? 95 : (11 * (valeur.length + 2) + 13);
    return SizedBox(
      width: modules * largeurModule,
      height: hauteur,
      child: CustomPaint(painter: _PeintreBarcode(codeur, valeur, couleur)),
    );
  }
}

class _PeintreBarcode extends CustomPainter {
  const _PeintreBarcode(this.codeur, this.valeur, this.couleur, {this.carre = false});
  final bc.Barcode codeur;
  final String valeur;
  final Color couleur;
  final bool carre;

  @override
  void paint(Canvas canvas, Size size) {
    final peinture = Paint()..color = couleur;
    Iterable<bc.BarcodeElement> elements;
    try {
      elements = codeur.make(valeur, width: size.width, height: size.height, drawText: false);
    } catch (_) {
      return;
    }
    for (final e in elements) {
      if (e is bc.BarcodeBar && e.black) {
        canvas.drawRect(Rect.fromLTWH(e.left, e.top, e.width, e.height), peinture);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PeintreBarcode old) =>
      old.valeur != valeur || old.couleur != couleur || old.codeur.name != codeur.name;
}

/// Carte code-barres (`BarcodeCard`) : fond blanc imprimable, nom, code, valeur monospace, prix,
/// actions « Copier » / « Imprimer l'étiquette ». Sans [valeur] : panneau « pas de code-barres » + « Générer ».
class DsBarcodeCard extends StatelessWidget {
  const DsBarcodeCard({
    super.key,
    this.valeur,
    this.nom,
    this.prix,
    this.devise = 'DA',
    this.format,
    this.onImprimer,
    this.onGenerer,
    this.onCopier,
    this.hauteur = 64,
    this.compact = false,
  });
  final String? valeur;
  final String? nom;
  final double? prix;
  final String devise;

  /// Format forcé ; sinon EAN-13 si valide, CODE128 pour tout autre texte.
  final DsBarcodeFormat? format;
  final VoidCallback? onImprimer;
  final VoidCallback? onGenerer;
  final VoidCallback? onCopier;
  final double hauteur;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final v = valeur;
    if (v == null || v.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          borderRadius: DsRadius.borderLg,
          border: Border.all(color: c.borderStrong, width: 1.5),
        ),
        child: Row(
          spacing: 12,
          children: [
            Icon(LucideIcons.barcode, size: 22, color: c.iconMuted),
            Expanded(
              child: Text(l10n.dsBarcodeAucun, style: t.label.copyWith(color: c.textSecondary)),
            ),
            if (onGenerer != null)
              DsButton(
                libelle: l10n.dsBarcodeGenerer,
                icone: LucideIcons.wandSparkles,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.doux,
                onPressed: onGenerer,
              ),
          ],
        ),
      );
    }
    final fmt = format ?? (DsBarcode.ean13Valide(v) ? DsBarcodeFormat.ean13 : DsBarcodeFormat.code128);
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: DsColors.blanc,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (nom != null)
            Text(
              nom!,
              textAlign: TextAlign.center,
              style: t.bodySmStrong.copyWith(height: 1.3, color: DsColors.noirTicket),
            ),
          if (fmt == DsBarcodeFormat.qr)
            DsBarcode(valeur: v, format: fmt, tailleQr: compact ? 96 : 112)
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: DsBarcode(valeur: v, format: fmt, hauteur: hauteur, largeurModule: compact ? 1.5 : 2),
            ),
          Text(
            v,
            style: t.mono.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: DsColors.noirTicket,
            ),
          ),
          if (prix != null)
            Text(
              formaterMontant(prix!, devise),
              style: t.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DsColors.noirTicket,
                fontFeatures: DsTypography.tabular,
              ),
            ),
          if (onImprimer != null || onCopier != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (onCopier != null)
                    DsButton(
                      libelle: l10n.dsBarcodeCopier,
                      icone: LucideIcons.copy,
                      taille: DsButtonTaille.sm,
                      variante: DsButtonVariante.secondaire,
                      onPressed: onCopier,
                    ),
                  if (onImprimer != null)
                    DsButton(
                      libelle: l10n.dsBarcodeImprimer,
                      icone: LucideIcons.printer,
                      taille: DsButtonTaille.sm,
                      variante: DsButtonVariante.secondaire,
                      onPressed: onImprimer,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
