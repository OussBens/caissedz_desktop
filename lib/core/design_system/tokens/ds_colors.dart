import 'package:flutter/material.dart';

/// Tokens de couleur sémantiques du design system.
///
/// ⚠️ PROVISOIRE : les valeurs ci-dessous sont un jeu neutre en attendant la
/// traduction exacte des tokens de `docs/design/CaisseDZ-DS-v2.2/` (clair et
/// sombre). Les widgets n'accèdent JAMAIS à `Colors.*` : uniquement à ces tokens.
@immutable
class DsColors extends ThemeExtension<DsColors> {
  const DsColors({
    required this.fond,
    required this.surface,
    required this.surfaceElevee,
    required this.surfaceAttenuee,
    required this.bordure,
    required this.bordureForte,
    required this.texte,
    required this.texteSecondaire,
    required this.texteAttenue,
    required this.texteInverse,
    required this.primaire,
    required this.primaireSurvol,
    required this.primaireActif,
    required this.primaireDoux,
    required this.surPrimaire,
    required this.succes,
    required this.succesDoux,
    required this.avertissement,
    required this.avertissementDoux,
    required this.danger,
    required this.dangerDoux,
    required this.info,
    required this.infoDoux,
    required this.sidebarFond,
    required this.sidebarTexte,
    required this.sidebarTexteActif,
    required this.sidebarActif,
    required this.focus,
    required this.selection,
    required this.overlay,
  });

  final Color fond;
  final Color surface;
  final Color surfaceElevee;
  final Color surfaceAttenuee;
  final Color bordure;
  final Color bordureForte;
  final Color texte;
  final Color texteSecondaire;
  final Color texteAttenue;
  final Color texteInverse;
  final Color primaire;
  final Color primaireSurvol;
  final Color primaireActif;
  final Color primaireDoux;
  final Color surPrimaire;
  final Color succes;
  final Color succesDoux;
  final Color avertissement;
  final Color avertissementDoux;
  final Color danger;
  final Color dangerDoux;
  final Color info;
  final Color infoDoux;
  final Color sidebarFond;
  final Color sidebarTexte;
  final Color sidebarTexteActif;
  final Color sidebarActif;
  final Color focus;
  final Color selection;
  final Color overlay;

  static const DsColors clair = DsColors(
    fond: Color(0xFFF4F6F8),
    surface: Color(0xFFFFFFFF),
    surfaceElevee: Color(0xFFFFFFFF),
    surfaceAttenuee: Color(0xFFF0F2F5),
    bordure: Color(0xFFE2E6EB),
    bordureForte: Color(0xFFC8CFD8),
    texte: Color(0xFF14191F),
    texteSecondaire: Color(0xFF4B5563),
    texteAttenue: Color(0xFF8A94A3),
    texteInverse: Color(0xFFFFFFFF),
    primaire: Color(0xFF0F766E),
    primaireSurvol: Color(0xFF0D655E),
    primaireActif: Color(0xFF0B544E),
    primaireDoux: Color(0xFFE0F2F0),
    surPrimaire: Color(0xFFFFFFFF),
    succes: Color(0xFF15803D),
    succesDoux: Color(0xFFDCFCE7),
    avertissement: Color(0xFFB45309),
    avertissementDoux: Color(0xFFFEF3C7),
    danger: Color(0xFFB91C1C),
    dangerDoux: Color(0xFFFEE2E2),
    info: Color(0xFF1D4ED8),
    infoDoux: Color(0xFFDBEAFE),
    sidebarFond: Color(0xFF111827),
    sidebarTexte: Color(0xFFB7C0CE),
    sidebarTexteActif: Color(0xFFFFFFFF),
    sidebarActif: Color(0xFF1F2A3D),
    focus: Color(0xFF2DD4BF),
    selection: Color(0xFFE0F2F0),
    overlay: Color(0x66000000),
  );

  static const DsColors sombre = DsColors(
    fond: Color(0xFF0F141A),
    surface: Color(0xFF171E26),
    surfaceElevee: Color(0xFF1E2731),
    surfaceAttenuee: Color(0xFF1B232C),
    bordure: Color(0xFF2A3440),
    bordureForte: Color(0xFF3B4756),
    texte: Color(0xFFEDF1F5),
    texteSecondaire: Color(0xFFB4BECA),
    texteAttenue: Color(0xFF7C8796),
    texteInverse: Color(0xFF0F141A),
    primaire: Color(0xFF2DD4BF),
    primaireSurvol: Color(0xFF5EEAD4),
    primaireActif: Color(0xFF14B8A6),
    primaireDoux: Color(0xFF123D3A),
    surPrimaire: Color(0xFF0F141A),
    succes: Color(0xFF4ADE80),
    succesDoux: Color(0xFF14321F),
    avertissement: Color(0xFFFBBF24),
    avertissementDoux: Color(0xFF3B2A09),
    danger: Color(0xFFF87171),
    dangerDoux: Color(0xFF3F1414),
    info: Color(0xFF60A5FA),
    infoDoux: Color(0xFF14264A),
    sidebarFond: Color(0xFF0B1017),
    sidebarTexte: Color(0xFF9AA6B5),
    sidebarTexteActif: Color(0xFFFFFFFF),
    sidebarActif: Color(0xFF1A2331),
    focus: Color(0xFF5EEAD4),
    selection: Color(0xFF123D3A),
    overlay: Color(0x99000000),
  );

  @override
  DsColors copyWith({
    Color? fond,
    Color? surface,
    Color? surfaceElevee,
    Color? surfaceAttenuee,
    Color? bordure,
    Color? bordureForte,
    Color? texte,
    Color? texteSecondaire,
    Color? texteAttenue,
    Color? texteInverse,
    Color? primaire,
    Color? primaireSurvol,
    Color? primaireActif,
    Color? primaireDoux,
    Color? surPrimaire,
    Color? succes,
    Color? succesDoux,
    Color? avertissement,
    Color? avertissementDoux,
    Color? danger,
    Color? dangerDoux,
    Color? info,
    Color? infoDoux,
    Color? sidebarFond,
    Color? sidebarTexte,
    Color? sidebarTexteActif,
    Color? sidebarActif,
    Color? focus,
    Color? selection,
    Color? overlay,
  }) {
    return DsColors(
      fond: fond ?? this.fond,
      surface: surface ?? this.surface,
      surfaceElevee: surfaceElevee ?? this.surfaceElevee,
      surfaceAttenuee: surfaceAttenuee ?? this.surfaceAttenuee,
      bordure: bordure ?? this.bordure,
      bordureForte: bordureForte ?? this.bordureForte,
      texte: texte ?? this.texte,
      texteSecondaire: texteSecondaire ?? this.texteSecondaire,
      texteAttenue: texteAttenue ?? this.texteAttenue,
      texteInverse: texteInverse ?? this.texteInverse,
      primaire: primaire ?? this.primaire,
      primaireSurvol: primaireSurvol ?? this.primaireSurvol,
      primaireActif: primaireActif ?? this.primaireActif,
      primaireDoux: primaireDoux ?? this.primaireDoux,
      surPrimaire: surPrimaire ?? this.surPrimaire,
      succes: succes ?? this.succes,
      succesDoux: succesDoux ?? this.succesDoux,
      avertissement: avertissement ?? this.avertissement,
      avertissementDoux: avertissementDoux ?? this.avertissementDoux,
      danger: danger ?? this.danger,
      dangerDoux: dangerDoux ?? this.dangerDoux,
      info: info ?? this.info,
      infoDoux: infoDoux ?? this.infoDoux,
      sidebarFond: sidebarFond ?? this.sidebarFond,
      sidebarTexte: sidebarTexte ?? this.sidebarTexte,
      sidebarTexteActif: sidebarTexteActif ?? this.sidebarTexteActif,
      sidebarActif: sidebarActif ?? this.sidebarActif,
      focus: focus ?? this.focus,
      selection: selection ?? this.selection,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  DsColors lerp(ThemeExtension<DsColors>? other, double t) {
    if (other is! DsColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DsColors(
      fond: l(fond, other.fond),
      surface: l(surface, other.surface),
      surfaceElevee: l(surfaceElevee, other.surfaceElevee),
      surfaceAttenuee: l(surfaceAttenuee, other.surfaceAttenuee),
      bordure: l(bordure, other.bordure),
      bordureForte: l(bordureForte, other.bordureForte),
      texte: l(texte, other.texte),
      texteSecondaire: l(texteSecondaire, other.texteSecondaire),
      texteAttenue: l(texteAttenue, other.texteAttenue),
      texteInverse: l(texteInverse, other.texteInverse),
      primaire: l(primaire, other.primaire),
      primaireSurvol: l(primaireSurvol, other.primaireSurvol),
      primaireActif: l(primaireActif, other.primaireActif),
      primaireDoux: l(primaireDoux, other.primaireDoux),
      surPrimaire: l(surPrimaire, other.surPrimaire),
      succes: l(succes, other.succes),
      succesDoux: l(succesDoux, other.succesDoux),
      avertissement: l(avertissement, other.avertissement),
      avertissementDoux: l(avertissementDoux, other.avertissementDoux),
      danger: l(danger, other.danger),
      dangerDoux: l(dangerDoux, other.dangerDoux),
      info: l(info, other.info),
      infoDoux: l(infoDoux, other.infoDoux),
      sidebarFond: l(sidebarFond, other.sidebarFond),
      sidebarTexte: l(sidebarTexte, other.sidebarTexte),
      sidebarTexteActif: l(sidebarTexteActif, other.sidebarTexteActif),
      sidebarActif: l(sidebarActif, other.sidebarActif),
      focus: l(focus, other.focus),
      selection: l(selection, other.selection),
      overlay: l(overlay, other.overlay),
    );
  }
}
