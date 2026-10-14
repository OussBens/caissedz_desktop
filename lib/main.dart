import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/db/app_database.dart';
import 'core/design_system/design_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      minimumSize: Size(DsTailles.fenetreMinLargeur, DsTailles.fenetreMinHauteur),
      size: Size(1280, 800),
      center: true,
      title: 'CaisseDZ',
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final dossierDonnees = p.join((await getApplicationSupportDirectory()).path, 'data');
  final base = await AppDatabase.ouvrirAvecCleMachine(dossier: dossierDonnees);

  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(base)]);
  await container.read(localeProvider.notifier).charger();
  await container.read(themeModeProvider.notifier).charger();
  await container.read(sidebarReduiteProvider.notifier).charger();
  await container.read(favorisProvider.notifier).charger();
  container.read(internetProvider.notifier).demarrer();

  runApp(UncontrolledProviderScope(container: container, child: const CaisseDzApp()));
}
