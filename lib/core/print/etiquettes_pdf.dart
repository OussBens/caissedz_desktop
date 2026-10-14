import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/codes_barres.dart';
import '../../domain/models/produit.dart';

/// Une étiquette à imprimer.
class Etiquette {
  const Etiquette({required this.produit, required this.quantite, this.prixAffiche = true, this.qr = false});
  final Produit produit;
  final int quantite;
  final bool prixAffiche;
  final bool qr;
}

/// Génération PDF des étiquettes (planche A4 ou rouleau), CODE128 / EAN-13 / QR.
///
/// ⚠️ PROVISOIRE : dimensions à aligner sur le §11 de la spec.
class EtiquettesPdf {
  const EtiquettesPdf({this.largeurMm = 50, this.hauteurMm = 30, this.colonnesA4 = 4, this.devise = 'DA'});

  final double largeurMm;
  final double hauteurMm;
  final int colonnesA4;
  final String devise;

  static String formaterPrix(double v, String devise) => '${v.toStringAsFixed(2).replaceAll('.', ',')} $devise';

  pw.Widget _etiquette(Etiquette e) {
    final p = e.produit;
    final code = p.codeBarres ?? p.code;
    final ean = p.codeBarres != null && CodesBarres.ean13Valide(p.codeBarres!);
    return pw.Container(
      width: largeurMm * PdfPageFormat.mm,
      height: hauteurMm * PdfPageFormat.mm,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 0.3)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(p.designation, style: const pw.TextStyle(fontSize: 7), maxLines: 2, textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 2),
          pw.Expanded(
            child: e.qr
                ? pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: CodesBarres.contenuQr(p.code), drawText: false)
                : pw.BarcodeWidget(
                    barcode: ean ? pw.Barcode.ean13() : pw.Barcode.code128(),
                    data: code,
                    textStyle: const pw.TextStyle(fontSize: 6),
                  ),
          ),
          if (e.prixAffiche)
            pw.Text(
              formaterPrix(p.prixVente, devise),
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
        ],
      ),
    );
  }

  /// Planche A4 : les étiquettes sont répétées selon leur quantité.
  Future<Uint8List> plancheA4(List<Etiquette> etiquettes) async {
    final doc = pw.Document();
    final toutes = [
      for (final e in etiquettes)
        for (var i = 0; i < e.quantite; i++) e,
    ];
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(8 * PdfPageFormat.mm),
        build: (_) => [
          pw.Wrap(spacing: 2, runSpacing: 2, children: [for (final e in toutes) _etiquette(e)]),
        ],
      ),
    );
    return doc.save();
  }

  /// Rouleau : une page par étiquette, au format exact de l'étiquette.
  Future<Uint8List> rouleau(List<Etiquette> etiquettes) async {
    final doc = pw.Document();
    for (final e in etiquettes) {
      for (var i = 0; i < e.quantite; i++) {
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(largeurMm * PdfPageFormat.mm, hauteurMm * PdfPageFormat.mm),
            build: (_) => _etiquette(e),
          ),
        );
      }
    }
    return doc.save();
  }
}
