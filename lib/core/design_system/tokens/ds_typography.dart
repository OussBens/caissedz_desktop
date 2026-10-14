import 'package:flutter/material.dart';

/// Typographie du design system : Plus Jakarta Sans (latin) et Cairo (arabe).
///
/// ⚠️ PROVISOIRE : échelle neutre en attendant les tailles exactes du DS v2.2.
@immutable
class DsTypography extends ThemeExtension<DsTypography> {
  const DsTypography({
    required this.famille,
    required this.titreXl,
    required this.titreLg,
    required this.titreMd,
    required this.titreSm,
    required this.corps,
    required this.corpsFort,
    required this.petit,
    required this.petitFort,
    required this.legende,
    required this.chiffreXl,
    required this.chiffreLg,
    required this.mono,
  });

  static const String familleLatin = 'PlusJakartaSans';
  static const String familleArabe = 'Cairo';

  final String famille;
  final TextStyle titreXl;
  final TextStyle titreLg;
  final TextStyle titreMd;
  final TextStyle titreSm;
  final TextStyle corps;
  final TextStyle corpsFort;
  final TextStyle petit;
  final TextStyle petitFort;
  final TextStyle legende;
  final TextStyle chiffreXl;
  final TextStyle chiffreLg;
  final TextStyle mono;

  static String familleParLocale(Locale locale) =>
      locale.languageCode == 'ar' ? familleArabe : familleLatin;

  factory DsTypography.pour(Locale locale, Color couleurTexte) {
    final famille = familleParLocale(locale);
    final arabe = famille == familleArabe;
    // Cairo a une hauteur de ligne naturelle plus grande que Plus Jakarta Sans.
    final hauteur = arabe ? 1.6 : 1.4;
    TextStyle s(double taille, FontWeight poids, {double? h, double? espacement}) =>
        TextStyle(
          fontFamily: famille,
          fontSize: taille,
          fontWeight: poids,
          height: h ?? hauteur,
          letterSpacing: espacement,
          color: couleurTexte,
        );
    return DsTypography(
      famille: famille,
      titreXl: s(28, FontWeight.w800, h: 1.2, espacement: -0.5),
      titreLg: s(22, FontWeight.w700, h: 1.25, espacement: -0.3),
      titreMd: s(18, FontWeight.w700, h: 1.3),
      titreSm: s(15, FontWeight.w600, h: 1.35),
      corps: s(14, FontWeight.w400),
      corpsFort: s(14, FontWeight.w600),
      petit: s(12.5, FontWeight.w400),
      petitFort: s(12.5, FontWeight.w600),
      legende: s(11, FontWeight.w500, espacement: 0.3),
      chiffreXl: s(32, FontWeight.w800, h: 1.1, espacement: -0.8),
      chiffreLg: s(20, FontWeight.w700, h: 1.2),
      mono: TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: [famille],
        fontSize: 13,
        height: 1.4,
        color: couleurTexte,
      ),
    );
  }

  @override
  DsTypography copyWith({
    String? famille,
    TextStyle? titreXl,
    TextStyle? titreLg,
    TextStyle? titreMd,
    TextStyle? titreSm,
    TextStyle? corps,
    TextStyle? corpsFort,
    TextStyle? petit,
    TextStyle? petitFort,
    TextStyle? legende,
    TextStyle? chiffreXl,
    TextStyle? chiffreLg,
    TextStyle? mono,
  }) {
    return DsTypography(
      famille: famille ?? this.famille,
      titreXl: titreXl ?? this.titreXl,
      titreLg: titreLg ?? this.titreLg,
      titreMd: titreMd ?? this.titreMd,
      titreSm: titreSm ?? this.titreSm,
      corps: corps ?? this.corps,
      corpsFort: corpsFort ?? this.corpsFort,
      petit: petit ?? this.petit,
      petitFort: petitFort ?? this.petitFort,
      legende: legende ?? this.legende,
      chiffreXl: chiffreXl ?? this.chiffreXl,
      chiffreLg: chiffreLg ?? this.chiffreLg,
      mono: mono ?? this.mono,
    );
  }

  @override
  DsTypography lerp(ThemeExtension<DsTypography>? other, double t) {
    if (other is! DsTypography) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return DsTypography(
      famille: t < 0.5 ? famille : other.famille,
      titreXl: l(titreXl, other.titreXl),
      titreLg: l(titreLg, other.titreLg),
      titreMd: l(titreMd, other.titreMd),
      titreSm: l(titreSm, other.titreSm),
      corps: l(corps, other.corps),
      corpsFort: l(corpsFort, other.corpsFort),
      petit: l(petit, other.petit),
      petitFort: l(petitFort, other.petitFort),
      legende: l(legende, other.legende),
      chiffreXl: l(chiffreXl, other.chiffreXl),
      chiffreLg: l(chiffreLg, other.chiffreLg),
      mono: l(mono, other.mono),
    );
  }
}
