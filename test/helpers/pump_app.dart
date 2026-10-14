import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/core/i18n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monte un widget dans un MaterialApp localisé et thématisé aux tokens du DS.
Future<void> pumpDs(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('fr'),
  Brightness brightness = Brightness.light,
  List<Override> overrides = const [],
  Size taille = const Size(1280, 800),
}) async {
  await tester.binding.setSurfaceSize(taille);
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1;
  addTearDown(() => tester.view.reset());
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        supportedLocales: localesSupportees,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: construireTheme(brightness: brightness, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
