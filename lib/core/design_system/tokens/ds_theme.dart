import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_metrics.dart';
import 'ds_typography.dart';

export 'ds_colors.dart';
export 'ds_metrics.dart';
export 'ds_typography.dart';

/// Accès aux tokens sémantiques depuis un [BuildContext] : `context.ds.colors`.
class DsTokens {
  const DsTokens(this.colors, this.typo);
  final DsColors colors;
  final DsTypography typo;
}

extension DsContext on BuildContext {
  DsTokens get ds {
    final theme = Theme.of(this);
    return DsTokens(
      theme.extension<DsColors>() ?? DsColors.clair,
      theme.extension<DsTypography>() ?? DsTypography.pour(const Locale('fr'), DsColors.clair.texte),
    );
  }
}

/// Construit le [ThemeData] clair ou sombre pour une locale donnée.
///
/// Le thème Material n'est qu'un support : tous les widgets du DS lisent
/// `context.ds` et non `Theme.of(context).colorScheme`.
ThemeData construireTheme({required Brightness brightness, required Locale locale}) {
  final couleurs = brightness == Brightness.dark ? DsColors.sombre : DsColors.clair;
  final typo = DsTypography.pour(locale, couleurs.texte);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: couleurs.primaire,
    onPrimary: couleurs.surPrimaire,
    secondary: couleurs.info,
    onSecondary: couleurs.texteInverse,
    error: couleurs.danger,
    onError: couleurs.texteInverse,
    surface: couleurs.surface,
    onSurface: couleurs.texte,
    outline: couleurs.bordure,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: typo.famille,
    scaffoldBackgroundColor: couleurs.fond,
    canvasColor: couleurs.surface,
    dividerColor: couleurs.bordure,
    focusColor: couleurs.focus,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.compact,
    textTheme: TextTheme(
      headlineLarge: typo.titreXl,
      headlineMedium: typo.titreLg,
      headlineSmall: typo.titreMd,
      titleMedium: typo.titreSm,
      bodyMedium: typo.corps,
      bodySmall: typo.petit,
      labelSmall: typo.legende,
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(color: couleurs.texte, borderRadius: DsRadius.borderSm),
      textStyle: typo.petit.copyWith(color: couleurs.texteInverse),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: couleurs.surfaceElevee,
      shape: RoundedRectangleBorder(borderRadius: DsRadius.borderLg),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: couleurs.surfaceElevee,
      shape: RoundedRectangleBorder(
        borderRadius: DsRadius.borderMd,
        side: BorderSide(color: couleurs.bordure),
      ),
      textStyle: typo.corps,
    ),
    extensions: [couleurs, typo],
  );
}
