import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import '../core/i18n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class CaisseDzApp extends ConsumerStatefulWidget {
  const CaisseDzApp({super.key, this.routeInitiale = '/tableau-de-bord'});

  final String routeInitiale;

  @override
  ConsumerState<CaisseDzApp> createState() => _CaisseDzAppState();
}

class _CaisseDzAppState extends ConsumerState<CaisseDzApp> {
  late final GoRouter _router = construireRouter(routeInitiale: widget.routeInitiale);

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'CaisseDZ',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
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
