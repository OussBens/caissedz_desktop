import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/boutique.dart';
import '../../domain/models/vente.dart';
import 'ticket_escpos.dart';

/// Tickets (58 / 80 mm) et factures A4 en PDF (imprimante « normale », aperçu).
///
/// [police] : police TTF embarquée (Cairo pour l'arabe, Plus Jakarta Sans sinon) ;
/// sans police fournie, la police par défaut du PDF est utilisée (latin seulement).
class DocumentsPdf {
  const DocumentsPdf({required this.libelles, this.devise = 'DA', this.police, this.policeGras});

  final LibellesTicket libelles;
  final String devise;
  final pw.Font? police;
  final pw.Font? policeGras;

  pw.TextStyle _s(double taille, {bool gras = false}) => pw.TextStyle(
    font: gras ? (policeGras ?? police) : police,
    fontSize: taille,
    fontWeight: gras ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  String montant(double v) => '${v.toStringAsFixed(2)} $devise';

  pw.TextDirection get _dir => libelles.rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  pw.Widget _ligneCle(String cle, String valeur, {double taille = 8, bool gras = false}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(cle, style: _s(taille, gras: gras)),
      pw.Text(valeur, style: _s(taille, gras: gras)),
    ],
  );

  /// Ticket de caisse au format rouleau.
  Future<Uint8List> ticket(
    Vente v, {
    required Boutique boutique,
    required LargeurTicket largeur,
    String? nomClient,
    String? nomVendeur,
  }) async {
    final doc = pw.Document();
    final largeurMm = largeur == LargeurTicket.mm58 ? 58.0 : 80.0;
    final hauteur = 90 + v.lignes.length * 9.0 + v.paiements.length * 5.0 + 60;
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          largeurMm * PdfPageFormat.mm,
          hauteur * PdfPageFormat.mm,
          marginAll: 3 * PdfPageFormat.mm,
        ),
        build: (ctx) => pw.Directionality(
          textDirection: _dir,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(child: pw.Text(boutique.nom, style: _s(11, gras: true))),
              if (boutique.adresse.isNotEmpty) pw.Center(child: pw.Text(boutique.adresse, style: _s(7))),
              if (boutique.telephone.isNotEmpty) pw.Center(child: pw.Text(boutique.telephone, style: _s(7))),
              pw.Divider(thickness: 0.5),
              if (v.statut == 'Annulée') pw.Center(child: pw.Text(libelles.annule, style: _s(9, gras: true))),
              pw.Text('${libelles.ticket} ${v.code}', style: _s(8)),
              pw.Text('${libelles.date} ${_date(v.date)}', style: _s(8)),
              if (nomClient != null) pw.Text('${libelles.client} $nomClient', style: _s(8)),
              pw.Divider(thickness: 0.5),
              for (final l in v.lignes) ...[
                pw.Text(l.designation, style: _s(8)),
                _ligneCle('  ${_q(l.quantite)} x ${l.prixUnitaire.toStringAsFixed(2)}', l.total.toStringAsFixed(2)),
              ],
              pw.Divider(thickness: 0.5),
              if (v.totalRemise > 0) _ligneCle(libelles.remise, '-${montant(v.totalRemise)}'),
              _ligneCle(libelles.netAPayer, montant(v.totalNet), taille: 10, gras: true),
              for (final p in v.paiements) _ligneCle(p.mode, montant(p.montant)),
              _ligneCle(libelles.verse, montant(v.verse)),
              if (v.monnaie > 0) _ligneCle(libelles.monnaie, montant(v.monnaie)),
              if (v.reste > 0) _ligneCle(libelles.resteDu, montant(v.reste)),
              if (v.pointsGagnes > 0 || v.pointsUtilises > 0)
                _ligneCle(libelles.points, '+${v.pointsGagnes} / -${v.pointsUtilises}'),
              pw.Divider(thickness: 0.5),
              pw.Center(child: pw.Text(libelles.merci, style: _s(8))),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: v.code,
                  width: 40 * PdfPageFormat.mm,
                  height: 10 * PdfPageFormat.mm,
                  textStyle: _s(6),
                ),
              ),
              pw.Center(child: pw.Text(v.hash.substring(0, 16), style: _s(6))),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  /// Facture A4.
  Future<Uint8List> factureA4(
    Vente v, {
    required Boutique boutique,
    required String nomClient,
    String? adresseClient,
    String titre = 'FACTURE',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
        build: (ctx) => [
          pw.Directionality(
            textDirection: _dir,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(boutique.nom, style: _s(16, gras: true)),
                        if (boutique.adresse.isNotEmpty) pw.Text(boutique.adresse, style: _s(9)),
                        if (boutique.telephone.isNotEmpty) pw.Text('Tél. ${boutique.telephone}', style: _s(9)),
                        if (boutique.rc.isNotEmpty) pw.Text('RC ${boutique.rc}', style: _s(9)),
                        if (boutique.nif.isNotEmpty) pw.Text('NIF ${boutique.nif}', style: _s(9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(titre, style: _s(18, gras: true)),
                        pw.Text('N° ${v.code}', style: _s(10)),
                        pw.Text(_date(v.date), style: _s(10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500, width: 0.5)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${libelles.client} : $nomClient', style: _s(10, gras: true)),
                      if (adresseClient != null && adresseClient.isNotEmpty) pw.Text(adresseClient, style: _s(9)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  headerStyle: _s(9, gras: true),
                  cellStyle: _s(9),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                  headers: [libelles.article, libelles.qte, libelles.prix, libelles.remise, libelles.total],
                  data: [
                    for (final l in v.lignes)
                      [
                        l.designation,
                        _q(l.quantite),
                        l.prixUnitaire.toStringAsFixed(2),
                        l.remise.toStringAsFixed(2),
                        l.total.toStringAsFixed(2),
                      ],
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 220,
                      child: pw.Column(
                        children: [
                          _ligneCle(libelles.total, montant(v.totalBrut), taille: 10),
                          if (v.totalRemise > 0) _ligneCle(libelles.remise, '-${montant(v.totalRemise)}', taille: 10),
                          pw.Divider(thickness: 0.5),
                          _ligneCle(libelles.netAPayer, montant(v.totalNet), taille: 12, gras: true),
                          _ligneCle(libelles.verse, montant(v.verse), taille: 10),
                          if (v.reste > 0) _ligneCle(libelles.resteDu, montant(v.reste), taille: 10, gras: true),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('${libelles.ticket} ${v.code} · SHA-256 ${v.hash}', style: _s(7)),
              ],
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static String _q(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
