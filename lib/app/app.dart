import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system/design_system.dart';
import '../core/i18n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class CaisseDzApp extends ConsumerWidget {
  const CaisseDzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CaisseDZ',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: localesSupportees,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: mode,
      theme: construireTheme(brightness: Brightness.light, locale: locale),
      darkTheme: construireTheme(brightness: Brightness.dark, locale: locale),
    );
  }
}
