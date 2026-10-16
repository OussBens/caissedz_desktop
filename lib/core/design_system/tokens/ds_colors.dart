import 'package:flutter/material.dart';

/// Tokens de couleur sémantiques du design system CaisseDZ v2.2.
///
/// Traduction 1:1 des alias CSS de `docs/design/CaisseDZ-DS-v2.2/CaisseDZ-DS-v2.2.html`
/// (`:root,[data-theme="light"]` et `[data-theme="dark"]`). Chaque champ porte le nom de
/// l'alias CSS (`--surface-app` → [surfaceApp]). Les widgets n'accèdent JAMAIS à `Colors.*`.
@immutable
class DsColors extends ThemeExtension<DsColors> {
  const DsColors({
    required this.surfaceApp,
    required this.surfaceSidebar,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.surfaceInverse,
    required this.surfaceOverlay,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderFocus,
    required this.textPrimary,
    required this.textBody,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textInverse,
    required this.textLink,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primaryFg,
    required this.primaryTint,
    required this.primaryTintFg,
    required this.primaryTintHover,
    required this.brand,
    required this.accent,
    required this.accentFg,
    required this.accentTint,
    required this.accentTintFg,
    required this.accentHover,
    required this.success,
    required this.successTint,
    required this.successFg,
    required this.warning,
    required this.warningTint,
    required this.warningFg,
    required this.danger,
    required this.dangerTint,
    required this.dangerFg,
    required this.dangerHover,
    required this.info,
    required this.infoTint,
    required this.infoFg,
    required this.iconDefault,
    required this.iconMuted,
    required this.iconActive,
    required this.chartTrack,
    required this.ringFocus,
    required this.shadowXs,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
  });

  // ---- Surfaces ----
  final Color surfaceApp;
  final Color surfaceSidebar;
  final Color surfaceCard;

  /// Popovers, dialogs, menus.
  final Color surfaceRaised;

  /// En-têtes de tableau, pistes des segmented, champs au repos.
  final Color surfaceSunken;
  final Color surfaceHover;

  /// Ligne / entrée de navigation sélectionnée.
  final Color surfaceActive;
  final Color surfaceInverse;
  final Color surfaceOverlay;

  // ---- Bordures ----
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderStrong;
  final Color borderFocus;

  // ---- Texte ----
  final Color textPrimary;
  final Color textBody;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textInverse;
  final Color textLink;

  // ---- Marque ----
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color primaryFg;
  final Color primaryTint;
  final Color primaryTintFg;

  /// Survol des surfaces teintées (`--violet-100`).
  final Color primaryTintHover;
  final Color brand;

  // ---- Accent (teal) ----
  final Color accent;
  final Color accentFg;
  final Color accentTint;
  final Color accentTintFg;

  /// Survol du bouton accent (`--teal-600`).
  final Color accentHover;

  // ---- Statuts ----
  final Color success;
  final Color successTint;
  final Color successFg;
  final Color warning;
  final Color warningTint;
  final Color warningFg;
  final Color danger;
  final Color dangerTint;
  final Color dangerFg;

  /// Survol du bouton danger (`--red-700`).
  final Color dangerHover;
  final Color info;
  final Color infoTint;
  final Color infoFg;

  // ---- Icônes, graphiques, focus, ombres ----
  final Color iconDefault;
  final Color iconMuted;
  final Color iconActive;
  final Color chartTrack;

  /// Anneau de focus (`--ring-focus`, 3 px).
  final Color ringFocus;
  final List<BoxShadow> shadowXs;
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  // ---- Primitives communes aux deux thèmes ----
  static const Color violet25 = Color(0xFFFAF7FF);
  static const Color violet50 = Color(0xFFF4EFFF);
  static const Color violet100 = Color(0xFFEBE1FF);
  static const Color violet200 = Color(0xFFD9C6FF);
  static const Color violet300 = Color(0xFFC2A3FF);
  static const Color violet400 = Color(0xFFB38DFF);
  static const Color violet500 = Color(0xFFA577FF);
  static const Color violet600 = Color(0xFF8B5CF0);
  static const Color violet700 = Color(0xFF7543DB);
  static const Color violet800 = Color(0xFF5F33BD);
  static const Color violet900 = Color(0xFF3F2185);
  static const Color ink950 = Color(0xFF0A0619);
  static const Color ink900 = Color(0xFF150A35);
  static const Color ink850 = Color(0xFF1A1238);
  static const Color ink800 = Color(0xFF211842);
  static const Color ink750 = Color(0xFF2A2150);
  static const Color ink700 = Color(0xFF372D61);
  static const Color ink600 = Color(0xFF4D4478);
  static const Color teal50 = Color(0xFFE6FAF7);
  static const Color teal100 = Color(0xFFC7F3EC);
  static const Color teal300 = Color(0xFF6EE2D4);
  static const Color teal500 = Color(0xFF14C2B0);
  static const Color teal600 = Color(0xFF0EA595);
  static const Color teal700 = Color(0xFF0B7F73);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color noirTicket = Color(0xFF111111);

  /// Palette des graphiques (`--chart-1` … `--chart-6`), identique clair / sombre.
  static const List<Color> chart = [
    Color(0xFF5F33BD),
    Color(0xFF8B5CF0),
    Color(0xFFB38DFF),
    Color(0xFF4C8DF6),
    Color(0xFF14C2B0),
    Color(0xFF6EE2D4),
  ];

  /// Palette des avatars / tuiles produit (`chart-1, chart-4, chart-5, chart-2, teal-700, violet-900`).
  static const List<Color> teintes = [
    Color(0xFF5F33BD),
    Color(0xFF4C8DF6),
    Color(0xFF14C2B0),
    Color(0xFF8B5CF0),
    teal700,
    violet900,
  ];

  /// `--gradient-brand` : logo.
  static const LinearGradient gradientBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet500, violet800, ink900],
    stops: [0, .5, 1],
  );

  /// `--gradient-night` : bandeaux (total à payer, licence).
  static const RadialGradient gradientNight = RadialGradient(
    center: Alignment(0.6, 1.2),
    radius: 1.1,
    colors: [violet500, violet800, ink900, ink950],
    stops: [0, .35, .75, 1],
  );

  /// `--gradient-bar` : barres de graphique.
  static const LinearGradient gradientBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [violet800, violet400],
  );

  static const DsColors clair = DsColors(
    surfaceApp: Color(0xFFF6F7FB),
    surfaceSidebar: Color(0xFFFFFFFF),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF2F3F8),
    surfaceHover: Color(0xFFF4F5F9),
    surfaceActive: Color(0xFFF4EFFF),
    surfaceInverse: Color(0xFF150A35),
    surfaceOverlay: Color(0x730A0619),
    borderDefault: Color(0xFFE7E8EF),
    borderSubtle: Color(0xFFEFF0F5),
    borderStrong: Color(0xFFD4D6E1),
    borderFocus: Color(0xFFA577FF),
    textPrimary: Color(0xFF150A35),
    textBody: Color(0xFF2A2D40),
    textSecondary: Color(0xFF61657D),
    textMuted: Color(0xFF8C90A6),
    textDisabled: Color(0xFFB4B7C8),
    textInverse: Color(0xFFFFFFFF),
    textLink: Color(0xFF7543DB),
    primary: Color(0xFF7543DB),
    primaryHover: Color(0xFF6438C6),
    primaryPressed: Color(0xFF5F33BD),
    primaryFg: Color(0xFFFFFFFF),
    primaryTint: Color(0xFFF4EFFF),
    primaryTintFg: Color(0xFF5F33BD),
    primaryTintHover: violet100,
    brand: Color(0xFFA577FF),
    accent: Color(0xFF14C2B0),
    accentFg: Color(0xFF06312C),
    accentTint: Color(0xFFE6FAF7),
    accentTintFg: Color(0xFF0B7F73),
    accentHover: teal600,
    success: Color(0xFF17936A),
    successTint: Color(0xFFE8F8F1),
    successFg: Color(0xFF0F7553),
    warning: Color(0xFFD98E1F),
    warningTint: Color(0xFFFEF5E6),
    warningFg: Color(0xFF985F0C),
    danger: Color(0xFFD93A45),
    dangerTint: Color(0xFFFEEEEE),
    dangerFg: Color(0xFFB02731),
    dangerHover: Color(0xFFB02731),
    info: Color(0xFF3672DB),
    infoTint: Color(0xFFECF3FF),
    infoFg: Color(0xFF2556B0),
    iconDefault: Color(0xFF61657D),
    iconMuted: Color(0xFF8C90A6),
    iconActive: Color(0xFF7543DB),
    chartTrack: Color(0xFFEEEFF5),
    ringFocus: Color(0x59A577FF),
    shadowXs: [BoxShadow(color: Color(0x0D150A35), blurRadius: 2, offset: Offset(0, 1))],
    shadowSm: [
      BoxShadow(color: Color(0x0F150A35), blurRadius: 3, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0A150A35), blurRadius: 2, offset: Offset(0, 1)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x1F150A35), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -6),
      BoxShadow(color: Color(0x0D150A35), blurRadius: 6, offset: Offset(0, 2)),
    ],
    shadowLg: [BoxShadow(color: Color(0x38150A35), blurRadius: 48, offset: Offset(0, 24), spreadRadius: -12)],
  );

  static const DsColors sombre = DsColors(
    surfaceApp: Color(0xFF0B0719),
    surfaceSidebar: Color(0xFF100A24),
    surfaceCard: Color(0xFF130D2A),
    surfaceRaised: Color(0xFF1A1336),
    surfaceSunken: Color(0xFF0F0A22),
    surfaceHover: Color(0xFF1C1538),
    surfaceActive: Color(0x24A577FF),
    surfaceInverse: Color(0xFFF4F1FB),
    surfaceOverlay: Color(0xA804020C),
    borderDefault: Color(0xFF261F45),
    borderSubtle: Color(0xFF1E1839),
    borderStrong: Color(0xFF3A3262),
    borderFocus: Color(0xFFB38DFF),
    textPrimary: Color(0xFFF4F1FB),
    textBody: Color(0xFFDAD5EC),
    textSecondary: Color(0xFFA9A3C6),
    textMuted: Color(0xFF7C7699),
    textDisabled: Color(0xFF544E73),
    textInverse: Color(0xFF150A35),
    textLink: Color(0xFFC2A3FF),
    primary: Color(0xFFA577FF),
    primaryHover: Color(0xFFB38DFF),
    primaryPressed: Color(0xFF8B5CF0),
    primaryFg: Color(0xFF150A35),
    primaryTint: Color(0x24A577FF),
    primaryTintFg: Color(0xFFC9AEFF),
    primaryTintHover: Color(0x3DA577FF),
    brand: Color(0xFFA577FF),
    accent: Color(0xFF2BD3C0),
    accentFg: Color(0xFF04221F),
    accentTint: Color(0x2414C2B0),
    accentTintFg: Color(0xFF6EE2D4),
    accentHover: teal300,
    success: Color(0xFF2FC48D),
    successTint: Color(0x2622B07D),
    successFg: Color(0xFF5FDCAB),
    warning: Color(0xFFF2A93B),
    warningTint: Color(0x26F2A93B),
    warningFg: Color(0xFFF7C373),
    danger: Color(0xFFF2626A),
    dangerTint: Color(0x26EF4D56),
    dangerFg: Color(0xFFFF8F95),
    dangerHover: Color(0xFFD93A45),
    info: Color(0xFF5C99F8),
    infoTint: Color(0x264C8DF6),
    infoFg: Color(0xFF93BBFB),
    iconDefault: Color(0xFFA9A3C6),
    iconMuted: Color(0xFF7C7699),
    iconActive: Color(0xFFC2A3FF),
    chartTrack: Color(0xFF211A3D),
    ringFocus: Color(0x73A577FF),
    shadowXs: [BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))],
    shadowSm: [BoxShadow(color: Color(0x73000000), blurRadius: 3, offset: Offset(0, 1))],
    shadowMd: [BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, 10), spreadRadius: -6)],
    shadowLg: [BoxShadow(color: Color(0xBF000000), blurRadius: 56, offset: Offset(0, 28), spreadRadius: -12)],
  );

  @override
  DsColors copyWith({Color? primary}) => this;

  @override
  DsColors lerp(ThemeExtension<DsColors>? other, double t) {
    if (other is! DsColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    List<BoxShadow> s(List<BoxShadow> a, List<BoxShadow> b) => t < 0.5 ? a : b;
    return DsColors(
      surfaceApp: l(surfaceApp, other.surfaceApp),
      surfaceSidebar: l(surfaceSidebar, other.surfaceSidebar),
      surfaceCard: l(surfaceCard, other.surfaceCard),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      surfaceHover: l(surfaceHover, other.surfaceHover),
      surfaceActive: l(surfaceActive, other.surfaceActive),
      surfaceInverse: l(surfaceInverse, other.surfaceInverse),
      surfaceOverlay: l(surfaceOverlay, other.surfaceOverlay),
      borderDefault: l(borderDefault, other.borderDefault),
      borderSubtle: l(borderSubtle, other.borderSubtle),
      borderStrong: l(borderStrong, other.borderStrong),
      borderFocus: l(borderFocus, other.borderFocus),
      textPrimary: l(textPrimary, other.textPrimary),
      textBody: l(textBody, other.textBody),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      textDisabled: l(textDisabled, other.textDisabled),
      textInverse: l(textInverse, other.textInverse),
      textLink: l(textLink, other.textLink),
      primary: l(primary, other.primary),
      primaryHover: l(primaryHover, other.primaryHover),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      primaryFg: l(primaryFg, other.primaryFg),
      primaryTint: l(primaryTint, other.primaryTint),
      primaryTintFg: l(primaryTintFg, other.primaryTintFg),
      primaryTintHover: l(primaryTintHover, other.primaryTintHover),
      brand: l(brand, other.brand),
      accent: l(accent, other.accent),
      accentFg: l(accentFg, other.accentFg),
      accentTint: l(accentTint, other.accentTint),
      accentTintFg: l(accentTintFg, other.accentTintFg),
      accentHover: l(accentHover, other.accentHover),
      success: l(success, other.success),
      successTint: l(successTint, other.successTint),
      successFg: l(successFg, other.successFg),
      warning: l(warning, other.warning),
      warningTint: l(warningTint, other.warningTint),
      warningFg: l(warningFg, other.warningFg),
      danger: l(danger, other.danger),
      dangerTint: l(dangerTint, other.dangerTint),
      dangerFg: l(dangerFg, other.dangerFg),
      dangerHover: l(dangerHover, other.dangerHover),
      info: l(info, other.info),
      infoTint: l(infoTint, other.infoTint),
      infoFg: l(infoFg, other.infoFg),
      iconDefault: l(iconDefault, other.iconDefault),
      iconMuted: l(iconMuted, other.iconMuted),
      iconActive: l(iconActive, other.iconActive),
      chartTrack: l(chartTrack, other.chartTrack),
      ringFocus: l(ringFocus, other.ringFocus),
      shadowXs: s(shadowXs, other.shadowXs),
      shadowSm: s(shadowSm, other.shadowSm),
      shadowMd: s(shadowMd, other.shadowMd),
      shadowLg: s(shadowLg, other.shadowLg),
    );
  }
}
