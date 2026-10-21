import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/boutique.dart';
import '../../domain/models/facture.dart';
import '../../domain/models/vente.dart';
import 'texte_pdf.dart';
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
  const DocumentsPdf({
    required this.libelles,
    this.devise = 'DA',
    this.police,
    this.policeGras,
    this.secours = const [],
    this.logo,
    this.couleur,
    this.nomsAr = const {},
  });

  final LibellesTicket libelles;

  /// Noms arabes des produits (par code), imprimés à la place des désignations sur un ticket ou une facture en
  /// arabe (les factures fiscales scellées gardent leurs désignations).
  final Map<String, String> nomsAr;

  String _nom(VenteLigne l) => libelles.rtl ? l.nomImprime(nomsAr) : l.designation;

  /// Le nom d'un produit sur un document commercial : son nom arabe sur un document en arabe.
  String nomProduit(String code, String designation) => libelles.rtl ? (nomsAr[code] ?? designation) : designation;

  /// Logo de la boutique (PNG / JPEG), en tête des documents ; `null` si aucun.
  final Uint8List? logo;

  /// Couleur des documents (ARGB, voir `couleurDominante`) ; `null` : violet du DS.
  final int? couleur;
  final String devise;
  final pw.Font? police;
  final pw.Font? policeGras;

  /// Polices de secours (Cairo sous une interface latine, latine sous l'arabe) : un nom de client en arabe
  /// s'affiche dans un document en français, et inversement.
  final List<pw.Font> secours;

  pw.TextStyle _s(double taille, {bool gras = false}) => pw.TextStyle(
    font: gras ? (policeGras ?? police) : police,
    fontFallback: secours,
    fontSize: taille,
    fontWeight: gras ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  String montant(double v) => '${v.toStringAsFixed(2)} $devise';

  pw.TextDirection get _dir => libelles.rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  pw.Widget _ligneCle(String cle, String valeur, {double taille = 8, bool gras = false}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      textePdf(cle, style: _s(taille, gras: gras)),
      textePdf(valeur, style: _s(taille, gras: gras)),
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
    final hauteur = 90 + v.lignes.length * 9.0 + v.paiements.length * 5.0 + v.parTaux.length * 4.0 + 64;
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
              if (_image() case final image?)
                pw.Center(
                  child: pw.Container(
                    height: 36,
                    margin: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                ),
              pw.Center(child: textePdf(boutique.nom, style: _s(11, gras: true))),
              if (boutique.adresse.isNotEmpty) pw.Center(child: textePdf(boutique.adresse, style: _s(7))),
              if (boutique.telephone.isNotEmpty) pw.Center(child: textePdf(boutique.telephone, style: _s(7))),
              pw.Divider(thickness: 0.5),
              if (v.statut == 'Annulée') pw.Center(child: textePdf(libelles.annule, style: _s(9, gras: true))),
              textePdf('${libelles.ticket} ${v.code}', style: _s(8)),
              textePdf('${libelles.date} ${_date(v.date)}', style: _s(8)),
              if (nomClient != null) textePdf('${libelles.client} $nomClient', style: _s(8)),
              pw.Divider(thickness: 0.5),
              for (final l in v.lignes) ...[
                textePdf(_nom(l), style: _s(8)),
                _ligneCle('  ${_q(l.quantite)} x ${l.prixUnitaire.toStringAsFixed(2)}', l.total.toStringAsFixed(2)),
              ],
              pw.Divider(thickness: 0.5),
              if (v.totalRemise > 0) _ligneCle(libelles.remise, '-${montant(v.totalRemise)}'),
              _ligneCle(libelles.netAPayer, montant(v.totalNet), taille: 10, gras: true),
              if (v.totalTva > 0.004) ...[
                for (final MapEntry(key: taux, value: t) in v.parTaux.entries)
                  if (t.tva > 0.004)
                    _ligneCle(
                      '${libelles.tva} ${taux == taux.roundToDouble() ? taux.toInt() : taux}% '
                      '(${libelles.ht} ${montant(t.ht)})',
                      montant(t.tva),
                      taille: 7,
                    ),
                _ligneCle('${libelles.total} ${libelles.ht}', montant(v.totalHt), taille: 7),
              ],
              for (final p in v.paiements) _ligneCle(p.mode, montant(p.montant)),
              _ligneCle(libelles.verse, montant(v.verse)),
              if (v.monnaie > 0) _ligneCle(libelles.monnaie, montant(v.monnaie)),
              if (v.reste > 0) _ligneCle(libelles.resteDu, montant(v.reste)),
              if (v.pointsGagnes > 0 || v.pointsUtilises > 0)
                _ligneCle(libelles.points, '+${v.pointsGagnes} / -${v.pointsUtilises}'),
              pw.Divider(thickness: 0.5),
              pw.Center(child: textePdf(libelles.merci, style: _s(8))),
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
              pw.Center(child: textePdf(v.hash.substring(0, 16), style: _s(6))),
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
                        textePdf(boutique.nom, style: _s(16, gras: true)),
                        if (boutique.adresse.isNotEmpty) textePdf(boutique.adresse, style: _s(9)),
                        if (boutique.telephone.isNotEmpty) textePdf('Tél. ${boutique.telephone}', style: _s(9)),
                        if (boutique.rc.isNotEmpty) textePdf('RC ${boutique.rc}', style: _s(9)),
                        if (boutique.nif.isNotEmpty) textePdf('NIF ${boutique.nif}', style: _s(9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        textePdf(titre, style: _s(18, gras: true)),
                        textePdf('N° ${v.code}', style: _s(10)),
                        textePdf(_date(v.date), style: _s(10)),
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
                      textePdf('${libelles.client} : $nomClient', style: _s(10, gras: true)),
                      if (adresseClient != null && adresseClient.isNotEmpty) textePdf(adresseClient, style: _s(9)),
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
                        _nom(l),
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
                textePdf('${libelles.ticket} ${v.code} · SHA-256 ${v.hash}', style: _s(7)),
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
      String t(double taux) => '${_q(taux)} %';
      doc.addPage(
        _pageA4(
          titre: f.estAvoir ? mentions.avoir : mentions.facture,
          numero: f.code,
          date: f.date,
          references: [
            (mentions.ticket, f.venteCode),
            if (f.factureOrigine != null) (mentions.surFacture, f.factureOrigine!),
            (mentions.mode, f.modePaiement),
          ],
          emetteur: f.vendeur,
          libelleTiers: mentions.client,
          tiers: f.client,
          filigrane: duplicata ? mentions.duplicata : null,
          pied: 'SHA-256 ${f.hash}',
          corps: [
            _tableau(
              entetes: [
                mentions.designation,
                mentions.qte,
                mentions.puTtc,
                mentions.tva,
                mentions.ht,
                mentions.tva,
                mentions.ttc,
              ],
              lignes: [
                for (final l in f.lignes)
                  [
                    l.designation,
                    _q(l.quantite),
                    _n(l.prixUnitaire),
                    t(l.tauxTva),
                    _n(l.montantHt),
                    _n(l.montantTva),
                    _n(l.montantTtc),
                  ],
              ],
              colonneLarge: 0,
              texte: 1,
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _tableau(
                        entetes: [mentions.tva, mentions.ht, mentions.tva],
                        lignes: [
                          for (final e in f.parTaux.entries) [t(e.key), _n(e.value.ht), _n(e.value.tva)],
                        ],
                        texte: 0,
                        compact: true,
                      ),
                      pw.SizedBox(height: 10),
                      _enLettres('${f.estAvoir ? mentions.arreteeAvoir : mentions.arretee} :', f.montantLettres),
                    ],
                  ),
                ),
                pw.SizedBox(width: 18),
                _totaux(
                  [
                    (mentions.totalHt, montant(f.totalHt)),
                    (mentions.totalTva, montant(f.totalTva)),
                    (mentions.totalTtc, montant(f.totalTtc)),
                    if (f.timbre > 0) (mentions.timbre, montant(f.timbre)),
                    (mentions.netAPayer, montant(f.netAPayer)),
                  ],
                  apres: [
                    if (!f.estAvoir && resteDu > 0) ('${mentions.resteAu} ${_date(DateTime.now())}', montant(resteDu)),
                  ],
                ),
              ],
            ),
            if (f.motif != null) ...[pw.SizedBox(height: 10), _encadre('${mentions.motif} : ${f.motif}')],
          ],
        ),
      );
    }
    return doc.save();
  }

  // Palette des documents A4, alignée sur les tokens du DS (primary violet700, encre ink900).
  /// Violet du DS, quand la boutique n'a pas de logo (ou un logo sans couleur franche).
  static const _violet = PdfColor.fromInt(0xFF7543DB);

  /// Couleur des documents : la plus utilisée du logo, sinon le violet ; ses teintes claires pour les fonds.
  PdfColor get _accent => couleur == null ? _violet : PdfColor.fromInt(couleur!);
  PdfColor get _accentClair => _teinte(.08);
  static const _encre = PdfColor.fromInt(0xFF150A35);
  static const _attenue = PdfColor.fromInt(0xFF6B6385);
  PdfColor get _trait => _teinte(.18);
  PdfColor get _zebre => _teinte(.03);

  /// Logo décodé, `null` si absent ou illisible (le document s'imprime alors sans logo).
  pw.ImageProvider? _image() {
    if (logo == null || logo!.isEmpty) return null;
    try {
      return pw.MemoryImage(logo!);
    } on Object {
      return null;
    }
  }

  /// [part] de la couleur des documents mêlée au blanc.
  PdfColor _teinte(double part) {
    final a = _accent;
    return PdfColor(1 - (1 - a.red) * part, 1 - (1 - a.green) * part, 1 - (1 - a.blue) * part);
  }

  static const _alerte = PdfColor.fromInt(0xFFFFF4E0);
  static const _alerteTrait = PdfColor.fromInt(0xFFE6A23C);

  pw.TextStyle _c(double taille, {bool gras = false, PdfColor couleur = _encre}) =>
      _s(taille, gras: gras).copyWith(color: couleur);

  static String _n(double v) => v.toStringAsFixed(2);

  List<String> _lignesIdentite(IdentiteFiscale i) => [
    if (i.adresse.isNotEmpty) i.adresse,
    if (i.telephone.isNotEmpty) 'Tél. ${i.telephone}',
    [if (i.rc.isNotEmpty) 'RC ${i.rc}', if (i.nif.isNotEmpty) 'NIF ${i.nif}'].join('   '),
    [if (i.nis.isNotEmpty) 'NIS ${i.nis}', if (i.ai.isNotEmpty) 'AI ${i.ai}'].join('   '),
  ].where((l) => l.isNotEmpty).toList();

  /// Page A4 commune aux factures, avoirs, devis, proformas, commandes et bons de livraison : en-tête de
  /// l'émetteur et cartouche du document, carte du tiers et références, corps, pied de page numéroté.
  pw.MultiPage _pageA4({
    required String titre,
    required String numero,
    required DateTime date,
    required List<(String, String)> references,
    required IdentiteFiscale emetteur,
    required String libelleTiers,
    required IdentiteFiscale tiers,
    required List<pw.Widget> corps,
    String? filigrane,
    String? pied,
  }) => pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(
        14 * PdfPageFormat.mm,
        12 * PdfPageFormat.mm,
        14 * PdfPageFormat.mm,
        10 * PdfPageFormat.mm,
      ),
      textDirection: _dir,
      buildForeground: filigrane == null
          ? null
          : (ctx) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Center(
                child: pw.Transform.rotate(
                  angle: 0.6,
                  child: pw.Opacity(
                    opacity: 0.08,
                    child: textePdf(filigrane.toUpperCase(), style: _c(72, gras: true, couleur: _accent)),
                  ),
                ),
              ),
            ),
    ),
    header: (ctx) => ctx.pageNumber == 1
        ? _entete(titre, numero, date, emetteur)
        : pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                textePdf(emetteur.nom, style: _c(9, gras: true, couleur: _accent)),
                textePdf('$titre  N° $numero', style: _c(9, gras: true)),
              ],
            ),
          ),
    footer: (ctx) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _trait, width: 0.8)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                textePdf(
                  [emetteur.nom, ..._lignesIdentite(emetteur).skip(emetteur.adresse.isEmpty ? 0 : 1)].join('  ·  '),
                  style: _c(6.5, couleur: _attenue),
                ),
                if (pied != null) textePdf(pied, style: _c(5.5, couleur: _attenue)),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          textePdf('$numero  ·  ${ctx.pageNumber} / ${ctx.pagesCount}', style: _c(7, gras: true, couleur: _attenue)),
        ],
      ),
    ),
    build: (ctx) => [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: references.isEmpty
                ? pw.SizedBox()
                : pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: _accentClair,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        for (final (cle, valeur) in references)
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                            child: pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 95,
                                  child: textePdf(cle, style: _c(8, couleur: _attenue)),
                                ),
                                pw.Expanded(child: textePdf(valeur, style: _c(8.5, gras: true))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _trait, width: 0.8),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  textePdf(libelleTiers.toUpperCase(), style: _c(7, gras: true, couleur: _accent)),
                  pw.SizedBox(height: 3),
                  textePdf(tiers.nom, style: _c(11.5, gras: true)),
                  for (final l in _lignesIdentite(tiers)) textePdf(l, style: _c(8, couleur: _attenue)),
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      ...corps,
    ],
  );

  pw.Widget _entete(String titre, String numero, DateTime date, IdentiteFiscale emetteur) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (_image() case final image?) ...[
            pw.Container(
              width: 64,
              height: 64,
              alignment: pw.Alignment.center,
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 12),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                textePdf(emetteur.nom, style: _c(17, gras: true, couleur: _accent)),
                pw.SizedBox(height: 3),
                for (final l in _lignesIdentite(emetteur)) textePdf(l, style: _c(8, couleur: _attenue)),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: _accent,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: textePdf(titre.toUpperCase(), style: _c(13, gras: true, couleur: PdfColors.white)),
              ),
              pw.SizedBox(height: 6),
              textePdf('N° $numero', style: _c(11, gras: true)),
              textePdf(_date(date), style: _c(8.5, couleur: _attenue)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Container(height: 2, color: _accent),
      pw.SizedBox(height: 14),
    ],
  );

  /// Tableau des lignes : en-tête violet, lignes zébrées ; colonnes à partir de [texte] alignées à droite
  /// (chiffres), [colonneLarge] prend la place restante.
  pw.Widget _tableau({
    required List<String> entetes,
    required List<List<String>> lignes,
    int? colonneLarge,
    int texte = 2,
    bool compact = false,
  }) {
    final pad = pw.EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 3 : 5);
    pw.Alignment align(int i) => i >= texte ? pw.Alignment.centerRight : pw.Alignment.centerLeft;
    return pw.Table(
      columnWidths: {
        for (var i = 0; i < entetes.length; i++)
          i: i == colonneLarge
              ? const pw.FlexColumnWidth()
              : colonneLarge == null
              ? const pw.FlexColumnWidth(0.5)
              : const pw.IntrinsicColumnWidth(),
      },
      border: pw.TableBorder(bottom: pw.BorderSide(color: _trait, width: 0.8)),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _accent),
          children: [
            for (final (i, e) in entetes.indexed)
              pw.Container(
                padding: pad,
                alignment: align(i),
                child: textePdf(e, style: _c(compact ? 7 : 7.5, gras: true, couleur: PdfColors.white)),
              ),
          ],
        ),
        for (final (n, l) in lignes.indexed)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: n.isOdd ? _zebre : PdfColors.white),
            children: [
              for (final (i, v) in l.indexed)
                pw.Container(
                  padding: pad,
                  alignment: align(i),
                  child: textePdf(v, style: _c(compact ? 7.5 : 8.5, gras: i == colonneLarge)),
                ),
            ],
          ),
      ],
    );
  }

  /// Bloc des totaux : la dernière ligne de [lignes] est mise en évidence (fond violet) ; [apres] en dessous.
  pw.Widget _totaux(List<(String, String)> lignes, {List<(String, String)> apres = const []}) => pw.SizedBox(
    width: 220,
    child: pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _trait, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          for (final (i, (cle, valeur)) in lignes.indexed)
            i == lignes.length - 1
                ? pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    color: _accent,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        textePdf(cle, style: _c(10, gras: true, couleur: PdfColors.white)),
                        textePdf(valeur, style: _c(11, gras: true, couleur: PdfColors.white)),
                      ],
                    ),
                  )
                : pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        textePdf(cle, style: _c(8.5, couleur: _attenue)),
                        textePdf(valeur, style: _c(9, gras: true)),
                      ],
                    ),
                  ),
          for (final (cle, valeur) in apres)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  textePdf(cle, style: _c(8.5, gras: true)),
                  textePdf(valeur, style: _c(9, gras: true, couleur: _accent)),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  pw.Widget _enLettres(String libelle, String lettres) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(color: _accentClair, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        textePdf(libelle, style: _c(7.5, couleur: _attenue)),
        pw.SizedBox(height: 2),
        textePdf(lettres, style: _c(9.5, gras: true)),
      ],
    ),
  );

  pw.Widget _encadre(String texte, {bool alerte = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: pw.BoxDecoration(
      color: alerte ? _alerte : null,
      border: pw.Border.all(color: alerte ? _alerteTrait : _trait, width: 0.8),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: textePdf(texte, style: _c(8.5, gras: alerte)),
  );

  /// Document commercial A4 (devis, proforma, bon de commande, bon de livraison, commande fournisseur) : en-tête
  /// de l'émetteur, carte du tiers, tableau des lignes, totaux, montant en lettres, mentions et signatures.
  Future<Uint8List> documentCommercial({
    required String titre,
    required String numero,
    required DateTime date,
    List<(String, String)> references = const [],
    required IdentiteFiscale emetteur,
    required String libelleTiers,
    required IdentiteFiscale tiers,
    required List<String> entetes,
    required List<List<String>> lignes,
    List<(String, String)> totaux = const [],
    String? arretee,
    String? montantLettres,
    String? observation,
    List<String> signatures = const [],
    String? mention,
    String? filigrane,
  }) async {
    final doc = pw.Document();
    final lettres = montantLettres == null ? null : _enLettres('${arretee ?? ''} :', montantLettres);
    doc.addPage(
      _pageA4(
        titre: titre,
        numero: numero,
        date: date,
        references: references,
        emetteur: emetteur,
        libelleTiers: libelleTiers,
        tiers: tiers,
        filigrane: filigrane,
        corps: [
          _tableau(entetes: entetes, lignes: lignes, colonneLarge: 1, texte: 2),
          if (totaux.isNotEmpty || lettres != null) ...[
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: lettres ?? pw.SizedBox()),
                if (totaux.isNotEmpty) ...[pw.SizedBox(width: 18), _totaux(totaux)],
              ],
            ),
          ],
          if (mention != null) ...[pw.SizedBox(height: 10), _encadre(mention, alerte: true)],
          if (observation != null && observation.isNotEmpty) ...[pw.SizedBox(height: 10), _encadre(observation)],
          if (signatures.isNotEmpty) ...[
            pw.SizedBox(height: 26),
            pw.Row(
              mainAxisAlignment: signatures.length == 1 ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.spaceBetween,
              children: [
                for (final sig in signatures)
                  pw.Container(
                    width: 190,
                    height: 70,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _trait, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: textePdf(sig, style: _c(8, gras: true, couleur: _attenue)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }

  static String _q(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
