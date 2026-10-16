import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/boutique.dart';
import '../../domain/models/facture.dart';
import '../../domain/models/vente.dart';
import 'ticket_escpos.dart';

/// Mentions de la facture fiscale et de l'avoir (FR / AR).
class LibellesFacture {
  const LibellesFacture({
    required this.facture,
    required this.avoir,
    required this.duplicata,
    required this.vendeur,
    required this.client,
    required this.ticket,
    required this.surFacture,
    required this.designation,
    required this.qte,
    required this.puTtc,
    required this.tva,
    required this.ht,
    required this.ttc,
    required this.totalHt,
    required this.totalTva,
    required this.totalTtc,
    required this.timbre,
    required this.netAPayer,
    required this.mode,
    required this.arretee,
    required this.arreteeAvoir,
    required this.resteAu,
    required this.motif,
  });
  final String facture,
      avoir,
      duplicata,
      vendeur,
      client,
      ticket,
      surFacture,
      designation,
      qte,
      puTtc,
      tva,
      ht,
      ttc,
      totalHt,
      totalTva,
      totalTtc,
      timbre,
      netAPayer,
      mode,
      arretee,
      arreteeAvoir,
      resteAu,
      motif;

  static const LibellesFacture fr = LibellesFacture(
    facture: 'FACTURE',
    avoir: "FACTURE D'AVOIR",
    duplicata: 'DUPLICATA',
    vendeur: 'Vendeur',
    client: 'Client',
    ticket: 'Ticket',
    surFacture: 'Sur facture',
    designation: 'Désignation',
    qte: 'Qté',
    puTtc: 'P.U. TTC',
    tva: 'TVA',
    ht: 'HT',
    ttc: 'TTC',
    totalHt: 'Total HT',
    totalTva: 'Total TVA',
    totalTtc: 'Total TTC',
    timbre: 'Droit de timbre',
    netAPayer: 'NET A PAYER',
    mode: 'Mode de paiement',
    arretee: 'Arrêtée la présente facture à la somme de',
    arreteeAvoir: 'Arrêté le présent avoir à la somme de',
    resteAu: 'Reste dû au',
    motif: 'Motif',
  );
  static const LibellesFacture ar = LibellesFacture(
    facture: 'فاتورة',
    avoir: 'فاتورة تخفيض',
    duplicata: 'نسخة',
    vendeur: 'البائع',
    client: 'الزبون',
    ticket: 'تذكرة',
    surFacture: 'على الفاتورة',
    designation: 'التعيين',
    qte: 'الكمية',
    puTtc: 'السعر بالرسوم',
    tva: 'ر.ق.م',
    ht: 'دون رسوم',
    ttc: 'بالرسوم',
    totalHt: 'المجموع دون رسوم',
    totalTva: 'مجموع ر.ق.م',
    totalTtc: 'المجموع بالرسوم',
    timbre: 'حق الطابع',
    netAPayer: 'الصافي للدفع',
    mode: 'طريقة الدفع',
    arretee: 'أوقفت هذه الفاتورة بمبلغ',
    arreteeAvoir: 'أوقف هذا التخفيض بمبلغ',
    resteAu: 'المتبقي بتاريخ',
    motif: 'السبب',
  );
}

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

  /// Factures fiscales et avoirs A4 (un document par page) : identités fiscales figées, TVA par taux, timbre,
  /// montant en lettres. [duplicata] pour une réimpression ; [resteDu] : reste dû à la date du jour (m15).
  Future<Uint8List> facturesFiscales(
    List<Facture> documents, {
    LibellesFacture mentions = LibellesFacture.fr,
    bool duplicata = false,
    double resteDu = 0,
  }) async {
    final doc = pw.Document();
    for (final f in documents) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
          build: (ctx) => [
            pw.Directionality(textDirection: _dir, child: _factureFiscale(f, mentions, duplicata, resteDu)),
          ],
        ),
      );
    }
    return doc.save();
  }

  pw.Widget _identite(String titre, IdentiteFiscale i) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500, width: 0.5)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titre, style: _s(8)),
          pw.Text(i.nom, style: _s(11, gras: true)),
          if (i.adresse.isNotEmpty) pw.Text(i.adresse, style: _s(8)),
          if (i.telephone.isNotEmpty) pw.Text('Tél. ${i.telephone}', style: _s(8)),
          if (i.rc.isNotEmpty) pw.Text('RC ${i.rc}', style: _s(8)),
          if (i.nif.isNotEmpty) pw.Text('NIF ${i.nif}', style: _s(8)),
          if (i.nis.isNotEmpty) pw.Text('NIS ${i.nis}', style: _s(8)),
          if (i.ai.isNotEmpty) pw.Text('AI ${i.ai}', style: _s(8)),
        ],
      ),
    ),
  );

  pw.Widget _factureFiscale(Facture f, LibellesFacture m, bool duplicata, double resteDu) {
    String t(double taux) => '${_q(taux)} %';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(f.estAvoir ? m.avoir : m.facture, style: _s(18, gras: true)),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('N° ${f.code}', style: _s(11, gras: true)),
                pw.Text(_date(f.date), style: _s(9)),
                pw.Text('${m.ticket} ${f.venteCode}', style: _s(8)),
                if (f.factureOrigine != null) pw.Text('${m.surFacture} ${f.factureOrigine}', style: _s(8)),
                if (duplicata) pw.Text(m.duplicata, style: _s(9, gras: true)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [_identite(m.vendeur, f.vendeur), pw.SizedBox(width: 12), _identite(m.client, f.client)],
        ),
        pw.SizedBox(height: 14),
        pw.TableHelper.fromTextArray(
          headerStyle: _s(8, gras: true),
          cellStyle: _s(8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignments: {for (var i = 1; i < 7; i++) i: pw.Alignment.centerRight, 0: pw.Alignment.centerLeft},
          headers: [m.designation, m.qte, m.puTtc, m.tva, m.ht, m.tva, m.ttc],
          data: [
            for (final l in f.lignes)
              [
                l.designation,
                _q(l.quantite),
                l.prixUnitaire.toStringAsFixed(2),
                t(l.tauxTva),
                l.montantHt.toStringAsFixed(2),
                l.montantTva.toStringAsFixed(2),
                l.montantTtc.toStringAsFixed(2),
              ],
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(
              width: 220,
              child: pw.TableHelper.fromTextArray(
                headerStyle: _s(8, gras: true),
                cellStyle: _s(8),
                headers: [m.tva, m.ht, m.tva],
                data: [
                  for (final e in f.parTaux.entries)
                    [t(e.key), e.value.ht.toStringAsFixed(2), e.value.tva.toStringAsFixed(2)],
                ],
              ),
            ),
            pw.SizedBox(
              width: 230,
              child: pw.Column(
                children: [
                  _ligneCle(m.totalHt, montant(f.totalHt), taille: 9),
                  _ligneCle(m.totalTva, montant(f.totalTva), taille: 9),
                  _ligneCle(m.totalTtc, montant(f.totalTtc), taille: 9),
                  if (f.timbre > 0) _ligneCle(m.timbre, montant(f.timbre), taille: 9),
                  pw.Divider(thickness: 0.5),
                  _ligneCle(m.netAPayer, montant(f.netAPayer), taille: 12, gras: true),
                  _ligneCle(m.mode, f.modePaiement, taille: 9),
                  if (!f.estAvoir && resteDu > 0)
                    _ligneCle('${m.resteAu} ${_date(DateTime.now())}', montant(resteDu), taille: 9, gras: true),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Text('${f.estAvoir ? m.arreteeAvoir : m.arretee} :', style: _s(9)),
        pw.Text(f.montantLettres, style: _s(10, gras: true)),
        if (f.motif != null) ...[pw.SizedBox(height: 6), pw.Text('${m.motif} : ${f.motif}', style: _s(8))],
        pw.SizedBox(height: 24),
        pw.Text('${f.code} · SHA-256 ${f.hash}', style: _s(6)),
      ],
    );
  }

  static String _q(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
