import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/rapport.dart';
import 'texte_pdf.dart';

/// Rapport tabulaire en PDF A4 paysage (aperçu et impression « normale »).
class RapportPdf {
  const RapportPdf({this.police, this.policeGras, this.rtl = false, this.devise = 'DA', this.secours = const []});
  final pw.Font? police;
  final pw.Font? policeGras;

  /// Polices de secours pour l'autre écriture (arabe / latin) dans les cellules.
  final List<pw.Font> secours;
  final bool rtl;
  final String devise;

  String _format(Object? v, RapportColonne c) => switch (v) {
    null => '',
    final double d => c.monetaire ? '${_milliers(d.toStringAsFixed(2))} $devise' : _milliers(_sansZeros(d)),
    final int i => '$i',
    _ => v.toString(),
  };

  static String _sansZeros(double d) => d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(2);

  static String _milliers(String s) {
    final parties = s.split('.');
    final entier = parties[0];
    final signe = entier.startsWith('-') ? '-' : '';
    final chiffres = signe.isEmpty ? entier : entier.substring(1);
    final b = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      if (i > 0 && (chiffres.length - i) % 3 == 0) b.write(' ');
      b.write(chiffres[i]);
    }
    return '$signe$b${parties.length > 1 ? ',${parties[1]}' : ''}';
  }

  Future<Uint8List> generer(Rapport r, {required String boutique, String? periode, DateTime? genereLe}) async {
    final doc = pw.Document();
    final style = pw.TextStyle(fontFallback: secours, font: police, fontSize: 8);
    final gras = pw.TextStyle(
      fontFallback: secours,
      font: policeGras ?? police,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );
    // Une cellule en arabe devient un texte de droite à gauche, lettres liées.
    Object cellule(String v) => contientArabe(v) ? textePdf(v, style: style) : v;
    final donnees = [
      for (final l in r.lignes) [for (final (i, v) in l.indexed) cellule(_format(v, r.colonnes[i]))],
      if (r.totaux != null) [for (final (i, v) in r.totaux!.indexed) cellule(_format(v, r.colonnes[i]))],
    ];
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            textePdf(
              boutique,
              style: pw.TextStyle(
                fontFallback: secours,
                font: policeGras ?? police,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            textePdf(
              r.titre,
              style: pw.TextStyle(fontFallback: secours, font: police, fontSize: 11),
            ),
            if (periode != null) textePdf(periode, style: style),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            textePdf(
              'CaisseDZ Desktop — ${(genereLe ?? DateTime.now()).toLocal().toString().substring(0, 16)}',
              style: style,
            ),
            textePdf('${ctx.pageNumber} / ${ctx.pagesCount}', style: style),
          ],
        ),
        build: (ctx) => [
          if (donnees.isEmpty)
            textePdf('—', style: style)
          else
            pw.TableHelper.fromTextArray(
              headers: [for (final c in r.colonnes) c.libelle],
              data: donnees,
              headerStyle: gras,
              cellStyle: style,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignments: {
                for (final (i, c) in r.colonnes.indexed)
                  i: c.numerique ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
              },
              border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.3),
            ),
        ],
      ),
    );
    return doc.save();
  }
}
