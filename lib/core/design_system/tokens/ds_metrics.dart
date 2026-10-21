import 'package:flutter/material.dart';

/// Espacements du DS v2.2 (`--space-*`).
@immutable
class DsSpacing {
  const DsSpacing._();
  static const double s0 = 0;
  static const double s0_5 = 2;
  static const double s1 = 4;
  static const double s1_5 = 6;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// Rayons du DS v2.2 (`--radius-*`).
@immutable
class DsRadius {
  const DsRadius._();

  /// Barres de progression, kbd.
  static const double xs = 4;

  /// Badges, chips, cases à cocher.
  static const double sm = 6;

  /// Boutons, champs, entrées de navigation, boutons icône.
  static const double md = 8;

  /// Cartes, tableaux, popovers.
  static const double lg = 12;

  /// Dialogs, panneau de connexion.
  static const double xl = 16;

  /// Bandeaux hero.
  static const double xxl = 24;
  static const double pill = 999;

  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
}

/// Ombres : valeurs du thème clair. Préférer `context.ds.colors.shadow*` (dépend du thème).
@immutable
class DsShadows {
  const DsShadows._();
  static const List<BoxShadow> xs = [BoxShadow(color: Color(0x0D150A35), blurRadius: 2, offset: Offset(0, 1))];
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F150A35), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A150A35), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1F150A35), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -6),
    BoxShadow(color: Color(0x0D150A35), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x38150A35), blurRadius: 48, offset: Offset(0, 24), spreadRadius: -12),
  ];
}

/// Mouvement du DS v2.2 (`--dur-*`, `--ease-*`) : discret et fluide.
@immutable
class DsMotion {
  const DsMotion._();
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240);
  static const Duration slower = Duration(milliseconds: 400);
  static const Curve standard = Cubic(.2, 0, 0, 1);
  static const Curve emphasized = Cubic(.16, 1, .3, 1);
  static const Curve exit = Cubic(.4, 0, 1, 1);

  /// Échelle d'enfoncement des boutons (`--press-scale`).
  static const double pressScale = .98;
}

/// Dimensions structurelles du DS v2.2 (contrôles, lignes, shell, page).
@immutable
class DsTailles {
  const DsTailles._();
  static const double fenetreMinLargeur = 1400; // 1000 × 1,4
  static const double fenetreMinHauteur = 700;

  // Contrôles (`--control-*`).
  static const double controleSm = 32;
  static const double controleMd = 36;
  static const double controleLg = 44;

  /// Hauteur d'une ligne de tableau (`--row-h`) ; 40 en mode dense.
  static const double ligneTable = 52;
  static const double ligneTableDense = 40;
  static const double enTeteTable = 40;
  static const double navItem = 36;

  // Shell (`--sidebar-w`, `--topbar-h`, `--titlebar-h`).
  static const double sidebarLargeur = 248;
  static const double sidebarLargeurReduite = 72;
  static const double topbar = 60;
  static const double barreTitre = 32;

  // Page (`--page-pad-*`, `--card-pad`, `--grid-gap`).
  static const double pagePaddingX = 32;
  static const double pagePaddingY = 24;
  static const double cardPadding = 20;
  static const double gridGap = 16;

  // Icônes Lucide.
  static const double iconeXs = 12;
  static const double iconeSm = 16;
  static const double icone = 18;
  static const double iconeLg = 22;
  static const double iconeXl = 26;
}
