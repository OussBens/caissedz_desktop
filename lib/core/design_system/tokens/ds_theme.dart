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
      theme.extension<DsTypography>() ?? DsTypography.pour(const Locale('fr'), DsColors.clair.textPrimary),
    );
  }
}

/// Construit le [ThemeData] clair ou sombre pour une locale donnée.
///
/// Le thème Material n'est qu'un support : tous les widgets du DS lisent
/// `context.ds` et non `Theme.of(context).colorScheme`.
ThemeData construireTheme({required Brightness brightness, required Locale locale}) {
  final couleurs = brightness == Brightness.dark ? DsColors.sombre : DsColors.clair;
  final typo = DsTypography.pour(locale, couleurs.textPrimary);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: couleurs.primary,
    onPrimary: couleurs.primaryFg,
    secondary: couleurs.accent,
    onSecondary: couleurs.accentFg,
    error: couleurs.danger,
    onError: couleurs.textInverse,
    surface: couleurs.surfaceCard,
    onSurface: couleurs.textPrimary,
    outline: couleurs.borderDefault,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: typo.famille,
    scaffoldBackgroundColor: couleurs.surfaceApp,
    canvasColor: couleurs.surfaceCard,
    dividerColor: couleurs.borderDefault,
    focusColor: couleurs.borderFocus,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.compact,
    textTheme: TextTheme(
      displayLarge: typo.display,
      headlineLarge: typo.pageTitle,
      headlineMedium: typo.heading,
      headlineSmall: typo.cardTitle,
      titleMedium: typo.cardTitle,
      bodyMedium: typo.body,
      bodySmall: typo.bodySm,
      labelMedium: typo.label,
      labelSmall: typo.caption,
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(color: couleurs.surfaceInverse, borderRadius: DsRadius.borderSm),
      textStyle: typo.bodySm.copyWith(color: couleurs.textInverse),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: couleurs.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: DsRadius.borderXl),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: couleurs.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: DsRadius.borderLg,
        side: BorderSide(color: couleurs.borderDefault),
      ),
      textStyle: typo.body,
    ),
    extensions: [couleurs, typo],
  );
}
