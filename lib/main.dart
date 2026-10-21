import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/demarrage_providers.dart';
import 'app/mobile_providers.dart';
import 'app/providers.dart';
import 'application/sauvegarde_service.dart';
import 'core/db/app_database.dart';
import 'core/design_system/design_system.dart';
import 'features/tableau_bord/alertes_produits_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      minimumSize: Size(DsTailles.fenetreMinLargeur, DsTailles.fenetreMinHauteur),
      size: Size(1440, 860),
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
  await chargerEtatDemarrage(container);
  unawaited(sauvegardeAutomatique(base));
  container.read(internetProvider.notifier).demarrer();
  // Alertes produits recalculées toutes les 15 minutes pour l'utilisateur connecté.
  container.read(alertesProduitsProvider.notifier).demarrer();
  // CaisseDZ Scan : le service des téléphones reprend s'il était activé.
  unawaited(container.read(mobileProvider.notifier).demarrerSiActif());

  runApp(UncontrolledProviderScope(container: container, child: const CaisseDzApp()));
}

/// Sauvegarde automatique au démarrage si elle est due (§4.1 étape 8) ; un échec ne bloque jamais l'ouverture.
Future<void> sauvegardeAutomatique(AppDatabase base) async {
  try {
    final chemin = await SauvegardeService(
      base,
      utilisateurCode: SauvegardeService.utilisateurSysteme,
    ).sauvegarderAutoSiDue();
    if (chemin != null) developer.log('Sauvegarde automatique : $chemin', name: 'caissedz.sauvegarde');
  } on Object catch (e, pile) {
    developer.log('Sauvegarde automatique impossible', name: 'caissedz.sauvegarde', error: e, stackTrace: pile);
  }
}
