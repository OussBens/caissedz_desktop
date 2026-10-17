import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final _arabe = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]');
final _couvreArabe = Expando<bool>();

/// Le texte contient-il de l'arabe ?
bool contientArabe(String texte) => _arabe.hasMatch(texte);

bool _arabeDessinable(pw.Font? f) =>
    f is pw.TtfFont && (_couvreArabe[f] ??= TtfParser(f.data).charToGlyphIndexMap.containsKey(0x0644));

/// Style d'un texte arabe : si la police du document (latine) ne dessine pas l'arabe, la police de secours arabe
/// (régulière ou grasse) devient la police principale ; sinon les lettres, prises une à une dans la police de
/// secours, ne seraient pas liées.
pw.TextStyle? styleArabe(pw.TextStyle? style) {
  if (style == null || _arabeDessinable(style.font)) return style;
  final arabes = style.fontFallback.where(_arabeDessinable).toList();
  if (arabes.isEmpty) return style;
  final police = arabes[style.fontWeight == pw.FontWeight.bold && arabes.length > 1 ? 1 : 0];
  return style.copyWith(
    font: police,
    fontNormal: police,
    fontBold: police,
    fontFallback: [?style.font, ...style.fontFallback.where((f) => f != police)],
  );
}

/// Texte PDF : un texte contenant de l'arabe (nom de client, désignation…) s'écrit de droite à gauche, lettres
/// liées, même dans un document latin ; sinon il suit le sens du document.
pw.Text textePdf(String texte, {pw.TextStyle? style, pw.TextAlign? textAlign, int? maxLines}) {
  final arabe = contientArabe(texte);
  return pw.Text(
    texte,
    style: arabe ? styleArabe(style) : style,
    textAlign: textAlign,
    maxLines: maxLines,
    textDirection: arabe ? pw.TextDirection.rtl : null,
  );
}
