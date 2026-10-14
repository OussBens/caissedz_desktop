import 'package:flutter/material.dart';

/// Espacements, rayons, ombres et motion du design system.
///
/// ⚠️ PROVISOIRE : échelle neutre en attendant les tokens exacts du DS v2.2.
@immutable
class DsSpacing {
  const DsSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

@immutable
class DsRadius {
  const DsRadius._();
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
}

@immutable
class DsShadows {
  const DsShadows._();
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

@immutable
class DsMotion {
  const DsMotion._();
  static const Duration rapide = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration lent = Duration(milliseconds: 320);
  static const Curve courbe = Curves.easeOutCubic;
}

/// Dimensions structurelles du shell et des contrôles.
@immutable
class DsTailles {
  const DsTailles._();
  static const double fenetreMinLargeur = 1000;
  static const double fenetreMinHauteur = 700;
  static const double barreTitre = 40;
  static const double sidebarLargeur = 240;
  static const double sidebarLargeurReduite = 64;
  static const double controleSm = 32;
  static const double controleMd = 40;
  static const double controleLg = 48;
  static const double icone = 18;
  static const double iconeSm = 16;
  static const double iconeLg = 22;
  static const double ligneTable = 40;
  static const double enTeteTable = 44;
}
