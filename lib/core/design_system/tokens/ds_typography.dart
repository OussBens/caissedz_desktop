import 'package:flutter/material.dart';

/// Typographie du DS v2.2 : Plus Jakarta Sans (latin) et Cairo (arabe), échelle `--type-*`.
///
/// | Token DS        | Champ        | Style                       |
/// |-----------------|--------------|-----------------------------|
/// | type-display    | [display]    | 700 36/1.1                  |
/// | type-page-title | [pageTitle]  | 700 24/1.2, −0.02em         |
/// | type-heading    | [heading]    | 600 20/1.2                  |
/// | type-card-title | [cardTitle]  | 600 14/1.35                 |
/// | type-kpi        | [kpi]        | 700 28/1.1, −0.02em, tabular|
/// | type-body       | [body]       | 400 14/1.5                  |
/// | type-body-sm    | [bodySm]     | 400 13/1.5                  |
/// | type-label      | [label]      | 500 13/1.35                 |
/// | type-caption    | [caption]    | 400 12/1.35                 |
/// | type-overline   | [overline]   | 600 11/1.2, +0.06em, CAPS   |
@immutable
class DsTypography extends ThemeExtension<DsTypography> {
  const DsTypography({
    required this.famille,
    required this.display,
    required this.pageTitle,
    required this.heading,
    required this.cardTitle,
    required this.kpi,
    required this.montantXl,
    required this.body,
    required this.bodyStrong,
    required this.bodySm,
    required this.bodySmStrong,
    required this.label,
    required this.caption,
    required this.overline,
    required this.mono,
  });

  static const String familleLatin = 'PlusJakartaSans';
  static const String familleArabe = 'Cairo';

  /// Chiffres à largeur fixe (`font-variant-numeric: tabular-nums`).
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  final String famille;
  final TextStyle display;
  final TextStyle pageTitle;
  final TextStyle heading;
  final TextStyle cardTitle;
  final TextStyle kpi;

  /// Total à payer de la caisse (700 32/1).
  final TextStyle montantXl;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle bodySm;
  final TextStyle bodySmStrong;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle mono;

  static String familleParLocale(Locale locale) => locale.languageCode == 'ar' ? familleArabe : familleLatin;

  factory DsTypography.pour(Locale locale, Color couleurTexte) {
    final famille = familleParLocale(locale);
    final arabe = famille == familleArabe;
    // Cairo a une hauteur de ligne naturelle plus grande que Plus Jakarta Sans.
    double h(double v) => arabe ? v + 0.15 : v;
    TextStyle s(
      double taille,
      FontWeight poids,
      double hauteur, {
      double? espacement,
      bool tabulaire = false,
      Color? couleur,
    }) => TextStyle(
      fontFamily: famille,
      fontFamilyFallback: const [familleLatin, familleArabe],
      fontSize: taille,
      fontWeight: poids,
      height: h(hauteur),
      letterSpacing: espacement,
      color: couleur ?? couleurTexte,
      fontFeatures: tabulaire ? tabular : null,
    );
    return DsTypography(
      famille: famille,
      display: s(36, FontWeight.w700, 1.1, espacement: -0.72),
      pageTitle: s(24, FontWeight.w700, 1.2, espacement: -0.48),
      heading: s(20, FontWeight.w600, 1.2),
      cardTitle: s(14, FontWeight.w600, 1.35),
      kpi: s(28, FontWeight.w700, 1.1, espacement: -0.56, tabulaire: true),
      montantXl: s(32, FontWeight.w700, 1.0, espacement: -0.64, tabulaire: true),
      body: s(14, FontWeight.w400, 1.5),
      bodyStrong: s(14, FontWeight.w600, 1.5),
      bodySm: s(13, FontWeight.w400, 1.5),
      bodySmStrong: s(13, FontWeight.w600, 1.5),
      label: s(13, FontWeight.w500, 1.35),
      caption: s(12, FontWeight.w400, 1.35),
      overline: s(11, FontWeight.w600, 1.2, espacement: 0.66),
      mono: TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const [familleLatin],
        fontSize: 13,
        height: 1.4,
        color: couleurTexte,
        fontFeatures: tabular,
      ),
    );
  }

  @override
  DsTypography copyWith({String? famille}) => this;

  @override
  DsTypography lerp(ThemeExtension<DsTypography>? other, double t) {
    if (other is! DsTypography) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return DsTypography(
      famille: t < 0.5 ? famille : other.famille,
      display: l(display, other.display),
      pageTitle: l(pageTitle, other.pageTitle),
      heading: l(heading, other.heading),
      cardTitle: l(cardTitle, other.cardTitle),
      kpi: l(kpi, other.kpi),
      montantXl: l(montantXl, other.montantXl),
      body: l(body, other.body),
      bodyStrong: l(bodyStrong, other.bodyStrong),
      bodySm: l(bodySm, other.bodySm),
      bodySmStrong: l(bodySmStrong, other.bodySmStrong),
      label: l(label, other.label),
      caption: l(caption, other.caption),
      overline: l(overline, other.overline),
      mono: l(mono, other.mono),
    );
  }
}
