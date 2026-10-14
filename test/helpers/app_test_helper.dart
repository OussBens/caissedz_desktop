import 'dart:typed_data';

import 'package:caissedz_desktop/app/app.dart';
import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/configuration_initiale_service.dart';
import 'package:caissedz_desktop/application/import_produits_service.dart';
import 'package:caissedz_desktop/application/licence_service.dart';
import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:caissedz_desktop/core/licence/cle_activation.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/utilisateur.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bases.dart';

/// Clique un bouton du DS en respectant sa garde anti double-clic (600 ms).
Future<void> clic(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Identifiant machine fixe des tests.
const String machineTest = 'POSTE-TEST';

class MachineTest implements MachineIdentifiant {
  const MachineTest();
  @override
  Future<String> lire() async => machineTest;
}

/// Hachage rapide pour les tests.
const MotDePasse hachageTest = MotDePasse(iterations: 300);

String cleTest(NiveauLicence n) => CleActivation.cleAttendue(n, machineTest);

/// État de départ de l'application dans un test.
enum EtatApp { vierge, activeeBasic, demo, configuree, connecteeAdmin, connecteeDemo, connecteeCaissier }

/// Monte l'application complète sur une base en mémoire, dans l'état voulu.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  EtatApp etat = EtatApp.connecteeAdmin,
  Locale locale = const Locale('fr'),
  String? routeInitiale,
  Size taille = const Size(1280, 800),
  bool settle = true,
  List<Override> overrides = const [],
}) async {
  final base = await ouvrirBaseEnMemoire();
  await tester.binding.setSurfaceSize(taille);
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1;
  addTearDown(() => tester.view.reset());
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(base),
      controlesFenetreProvider.overrideWithValue(false),
      licenceServiceProvider.overrideWithValue(LicenceService(base.db, identifiant: const MachineTest())),
      authServiceProvider.overrideWithValue(AuthService(base.db, hachage: hachageTest)),
      configurationServiceProvider.overrideWithValue(ConfigurationInitialeService(base.db, hachage: hachageTest)),
      if (routeInitiale != null) routeInitialeProvider.overrideWithValue(routeInitiale),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await container.read(localeProvider.notifier).changer(locale);

  final licence = container.read(licenceProvider.notifier);
  final config = container.read(configurationTermineeProvider.notifier);
  final session = container.read(sessionProvider.notifier);
  switch (etat) {
    case EtatApp.vierge:
      break;
    case EtatApp.activeeBasic:
      await licence.activer(cleTest(NiveauLicence.basic));
    case EtatApp.demo:
      await licence.activerDemo();
    case EtatApp.configuree:
      await licence.activer(cleTest(NiveauLicence.basic));
      await config.terminer(configurationTest());
    case EtatApp.connecteeAdmin:
      await licence.activer(cleTest(NiveauLicence.avance));
      await config.terminer(configurationTest());
      await session.connecter('gerant', 'azerty');
    case EtatApp.connecteeDemo:
      await licence.activerDemo();
      await config.terminer(configurationTest());
      await session.connecter('demo', 'demo');
    case EtatApp.connecteeCaissier:
      await licence.activer(cleTest(NiveauLicence.basic));
      await config.terminer(configurationTest());
      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', role: Roles.caissier),
        hachageTest.hacher('1234'),
      );
      await session.connecter('amina', '1234');
  }
  await chargerEtatDemarrage(container);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const CaisseDzApp()));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
  return container;
}

ConfigurationInitiale configurationTest() => const ConfigurationInitiale(
  boutique: Boutique(nom: 'Superette El Baraka', rc: '16/00-123456'),
  adminIdentifiant: 'gerant',
  adminNom: 'Karim',
  adminMotDePasse: 'azerty',
  parametres: ParametresVente(margeDefautPct: 25),
);

/// Modèle Excel d'import (raccourci de test).
Uint8List importModele() => ImportProduitsService.modele();
