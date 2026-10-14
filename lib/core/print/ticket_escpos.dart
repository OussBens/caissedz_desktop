import 'dart:convert';
import 'dart:typed_data';

import '../../domain/models/boutique.dart';
import '../../domain/models/vente.dart';

/// Largeur de papier des tickets.
enum LargeurTicket { mm58, mm80 }

/// Libellés du ticket (fournis par l'écran selon la langue).
class LibellesTicket {
  const LibellesTicket({
    required this.ticket,
    required this.date,
    required this.caisse,
    required this.vendeur,
    required this.client,
    required this.article,
    required this.qte,
    required this.prix,
    required this.total,
    required this.remise,
    required this.netAPayer,
    required this.verse,
    required this.monnaie,
    required this.resteDu,
    required this.points,
    required this.merci,
    required this.annule,
    this.rtl = false,
  });
  final String ticket,
      date,
      caisse,
      vendeur,
      client,
      article,
      qte,
      prix,
      total,
      remise,
      netAPayer,
      verse,
      monnaie,
      resteDu,
      points,
      merci,
      annule;

  /// Arabe : lignes alignées à droite (le texte reste en codage CP1256).
  final bool rtl;

  static const LibellesTicket fr = LibellesTicket(
    ticket: 'TICKET',
    date: 'Date',
    caisse: 'Caisse',
    vendeur: 'Vendeur',
    client: 'Client',
    article: 'Article',
    qte: 'Qté',
    prix: 'Prix',
    total: 'TOTAL',
    remise: 'Remise',
    netAPayer: 'NET A PAYER',
    verse: 'Versé',
    monnaie: 'Monnaie',
    resteDu: 'Reste dû',
    points: 'Points',
    merci: 'Merci de votre visite',
    annule: 'TICKET ANNULE',
  );
  static const LibellesTicket ar = LibellesTicket(
    ticket: 'تذكرة',
    date: 'التاريخ',
    caisse: 'الصندوق',
    vendeur: 'البائع',
    client: 'الزبون',
    article: 'المنتج',
    qte: 'الكمية',
    prix: 'السعر',
    total: 'المجموع',
    remise: 'تخفيض',
    netAPayer: 'الصافي',
    verse: 'المدفوع',
    monnaie: 'الباقي',
    resteDu: 'المتبقي',
    points: 'النقاط',
    merci: 'شكرا لزيارتكم',
    annule: 'تذكرة ملغاة',
    rtl: true,
  );
}

/// Générateur de commandes ESC/POS pour tickets 58 / 80 mm.
///
/// ⚠️ PROVISOIRE : mise en page à aligner sur le §11. L'arabe est émis en
/// page de codes CP1256 (ESC t 22 sur la plupart des imprimantes Epson-compatibles).
class TicketEscPos {
  const TicketEscPos({required this.largeur, required this.libelles, this.devise = 'DA'});

  final LargeurTicket largeur;
  final LibellesTicket libelles;
  final String devise;

  int get colonnes => largeur == LargeurTicket.mm58 ? 32 : 48;

  static const _esc = 0x1B;
  static const _gs = 0x1D;

  List<int> _init() => [_esc, 0x40, _esc, 0x74, libelles.rtl ? 22 : 16]; // ESC @ ; ESC t (CP1256 / CP1252)
  List<int> _aligner(int n) => [_esc, 0x61, n]; // 0 gauche, 1 centre, 2 droite
  List<int> _gras(bool on) => [_esc, 0x45, on ? 1 : 0];
  List<int> _double(bool on) => [_gs, 0x21, on ? 0x11 : 0x00];
  List<int> _couper() => [0x0A, 0x0A, 0x0A, _gs, 0x56, 0x00];
  List<int> _tiroir() => [_esc, 0x70, 0x00, 0x19, 0xFA];

  /// Encodage texte : CP1252 (latin) ou CP1256 (arabe) ; caractères inconnus → '?'.
  List<int> _texte(String s) {
    final b = <int>[];
    for (final r in s.runes) {
      if (r < 0x80) {
        b.add(r);
      } else if (libelles.rtl && r >= 0x0600 && r <= 0x06FF) {
        b.add(_cp1256[r] ?? 0x3F);
      } else {
        b.add(_cp1252[r] ?? 0x3F);
      }
    }
    return b;
  }

  List<int> _ligne(String s) => [..._texte(s), 0x0A];

  String _gauchDroite(String g, String d) {
    final place = colonnes - d.length;
    final gg = g.length > place - 1 ? g.substring(0, place - 1) : g;
    return gg.padRight(place) + d;
  }

  String montant(double v) => '${v.toStringAsFixed(2)} $devise';

  Uint8List generer(
    Vente vente, {
    required Boutique boutique,
    String? nomClient,
    String? nomVendeur,
    bool ouvrirTiroir = false,
  }) {
    final b = BytesBuilder();
    b.add(_init());
    b.add(_aligner(1));
    b.add(_gras(true));
    b.add(_double(true));
    b.add(_ligne(boutique.nom));
    b.add(_double(false));
    b.add(_gras(false));
    if (boutique.adresse.isNotEmpty) b.add(_ligne(boutique.adresse));
    if (boutique.telephone.isNotEmpty) b.add(_ligne(boutique.telephone));
    if (boutique.rc.isNotEmpty) b.add(_ligne('RC ${boutique.rc}'));
    b.add(_ligne('-' * colonnes));
    b.add(_aligner(libelles.rtl ? 2 : 0));
    if (vente.statut == 'Annulée') {
      b.add(_gras(true));
      b.add(_ligne(libelles.annule));
      b.add(_gras(false));
    }
    b.add(_ligne('${libelles.ticket} ${vente.code}'));
    final d = vente.date;
    b.add(
      _ligne(
        '${libelles.date} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
      ),
    );
    b.add(_ligne('${libelles.caisse} ${vente.caisseCode}  ${libelles.vendeur} ${nomVendeur ?? vente.utilisateurCode}'));
    if (nomClient != null) b.add(_ligne('${libelles.client} $nomClient'));
    b.add(_ligne('-' * colonnes));
    for (final l in vente.lignes) {
      b.add(_ligne(l.designation.length > colonnes ? l.designation.substring(0, colonnes) : l.designation));
      final q = l.quantite == l.quantite.roundToDouble()
          ? l.quantite.toInt().toString()
          : l.quantite.toStringAsFixed(2);
      b.add(_ligne(_gauchDroite('  $q x ${l.prixUnitaire.toStringAsFixed(2)}', l.total.toStringAsFixed(2))));
    }
    b.add(_ligne('-' * colonnes));
    if (vente.totalRemise > 0) b.add(_ligne(_gauchDroite(libelles.remise, '-${montant(vente.totalRemise)}')));
    b.add(_gras(true));
    b.add(_double(true));
    b.add(_ligne(_gauchDroite(libelles.netAPayer, montant(vente.totalNet))));
    b.add(_double(false));
    b.add(_gras(false));
    for (final p in vente.paiements) {
      b.add(_ligne(_gauchDroite(p.mode, montant(p.montant))));
    }
    b.add(_ligne(_gauchDroite(libelles.verse, montant(vente.verse))));
    if (vente.monnaie > 0) b.add(_ligne(_gauchDroite(libelles.monnaie, montant(vente.monnaie))));
    if (vente.reste > 0) b.add(_ligne(_gauchDroite(libelles.resteDu, montant(vente.reste))));
    if (vente.pointsGagnes > 0 || vente.pointsUtilises > 0) {
      b.add(_ligne(_gauchDroite(libelles.points, '+${vente.pointsGagnes} / -${vente.pointsUtilises}')));
    }
    b.add(_ligne('-' * colonnes));
    b.add(_aligner(1));
    b.add(_ligne(libelles.merci));
    b.add(_ligne(vente.hash.substring(0, 16)));
    // Code-barres CODE128 du numéro de ticket (GS k 73).
    final code = ascii.encode(vente.code);
    b.add([_gs, 0x68, 50, _gs, 0x48, 2, _gs, 0x6B, 73, code.length + 2, 0x7B, 0x42, ...code]);
    b.add([0x0A]);
    if (ouvrirTiroir) b.add(_tiroir());
    b.add(_couper());
    return b.toBytes();
  }

  static const Map<int, int> _cp1252 = {
    0xE9: 0xE9,
    0xE8: 0xE8,
    0xEA: 0xEA,
    0xEB: 0xEB,
    0xE0: 0xE0,
    0xE2: 0xE2,
    0xE7: 0xE7,
    0xF9: 0xF9,
    0xFB: 0xFB,
    0xEE: 0xEE,
    0xEF: 0xEF,
    0xF4: 0xF4,
    0xF6: 0xF6,
    0xC9: 0xC9,
    0xC8: 0xC8,
    0xCA: 0xCA,
    0xC0: 0xC0,
    0xC7: 0xC7,
    0x20AC: 0x80,
    0x153: 0x9C,
    0x152: 0x8C,
    0xB0: 0xB0,
  };

  static Map<int, int> get _cp1256 => {
    for (var i = 0; i < 26; i++) 0x0621 + i: 0xC1 + i, // ء..غ → 0xC1..0xDA
    0x0640: 0xDC,
    0x0641: 0xDD,
    0x0642: 0xDE,
    0x0643: 0xDF,
    0x0644: 0xE1,
    0x0645: 0xE3,
    0x0646: 0xE4,
    0x0647: 0xE5,
    0x0648: 0xE6,
    0x0649: 0xEC,
    0x064A: 0xED,
    0x064B: 0xF0,
    0x064C: 0xF1,
    0x064D: 0xF2,
    0x064E: 0xF3,
    0x064F: 0xF5,
    0x0650: 0xF6,
    0x0651: 0xF8,
    0x0652: 0xFA,
    0x060C: 0xA1,
    0x061B: 0xBA,
    0x061F: 0xBF,
  };
}
