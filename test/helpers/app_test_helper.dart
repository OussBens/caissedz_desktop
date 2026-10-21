import 'dart:typed_data';

import 'package:caissedz_desktop/app/app.dart';
import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/catalogue_rayons_service.dart';
import 'package:caissedz_desktop/application/configuration_initiale_service.dart';
import 'package:caissedz_desktop/application/import_produits_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:caissedz_desktop/core/db/migrations/v008_shell_ds.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/data/parametre_repository.dart';
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
import 'licence_test_helper.dart';

export 'licence_test_helper.dart';

/// Clique un bouton du DS en respectant sa garde anti double-clic (600 ms).
Future<void> clic(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Double-clic sur une ligne de tableau (ouvre le détail d'un `DsModuleTable`).
Future<void> doubleClic(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Identifiant machine fixe des tests (clé de la base).
class MachineTest implements MachineIdentifiant {
  const MachineTest();
  @override
  Future<String> lire() async => machineTest;
}

/// Hachage rapide pour les tests.
const MotDePasse hachageTest = MotDePasse(iterations: 300);

/// État de départ de l'application dans un test.
enum EtatApp {
  vierge,
  activeeBasic,

  /// Essai Avancé en cours (14 jours), venu du compte BENS.
  essai,
  configuree,
  connecteeAdmin,
  connecteeAdminBasic,
  connecteeEssai,

  /// Essai terminé (licence expirée gardée) : lecture seule.
  lectureSeule,
  connecteeLectureSeule,
  connecteeCaissier,
  connecteeMagasinier,
}

/// L'essai terminé : sa licence (expirée) reste gardée, l'application s'ouvre en lecture seule.
Future<void> _essaiTermine(AppDatabase base, ProviderContainer container) async {
  await LicenceRepository(base.db).ecrireDroits({
    'app': {'active': false, 'until': '2026-09-30'},
  });
  await LicenceRepository(base.db)
      .ecrireValeur('license_key', await cleTest(NiveauLicence.avance, fin: DateTime.utc(2026, 9, 30)));
  await container.read(licenceProvider.notifier).charger();
}

/// L'essai Avancé, comme le compte BENS le donne : une licence de 14 jours, ses droits `trial`.
Future<void> _essai(AppDatabase base, ProviderContainer container) async {
  await LicenceRepository(base.db).ecrireDroits({
    'app': {'active': true, 'source': 'trial', 'tier': 1},
  });
  final fin = DateTime.now().toUtc().add(const Duration(days: 13));
  await container.read(licenceProvider.notifier).activer(await cleTest(NiveauLicence.avance, fin: fin));
}

/// Monte l'application complète sur une base en mémoire, dans l'état voulu.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  EtatApp etat = EtatApp.connecteeAdmin,
  Locale locale = const Locale('fr'),
  String? routeInitiale,
  Size taille = const Size(1280, 800),
  bool settle = true,
  bool sequence = false,
  bool catalogueRayons = false,
  List<Override> overrides = const [],
}) async {
  final base = await ouvrirBaseEnMemoire();
  // Les rayons du catalogue BENS (internet) ne sont proposés à la connexion que si le test le demande.
  if (!catalogueRayons) await ParametreRepository(base.db).ecrire(CatalogueRayonsService.clePropose, '1');
  // Les cartes de chiffres se replient par défaut ; leur état ouvert est gardé le temps de la session.
  DsChiffresRepliables.ouverts.clear();
  await tester.binding.setSurfaceSize(taille);
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1;
  addTearDown(() => tester.view.reset());
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(base),
      controlesFenetreProvider.overrideWithValue(false),
      licenceServiceProvider.overrideWithValue(await licenceServiceTest(base)),
      authServiceProvider.overrideWithValue(AuthService(base.db, hachage: hachageTest)),
      sequencePostConnexionProvider.overrideWithValue(sequence),
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
      await licence.activer(await cleTest(NiveauLicence.basic));
    case EtatApp.essai:
      await _essai(base, container);
    case EtatApp.configuree:
      await licence.activer(await cleTest(NiveauLicence.basic));
      await config.terminer(configurationTest());
    case EtatApp.connecteeAdmin:
      // Ultra : tous les modules (multi-magasin compris).
      await licence.activer(await cleTest(NiveauLicence.ultra));
      await config.terminer(configurationTest());
      await session.connecter(identifiantAdmin, motDePasseAdmin);
    case EtatApp.connecteeAdminBasic:
      await licence.activer(await cleTest(NiveauLicence.basic));
      await config.terminer(configurationTest());
      await session.connecter(identifiantAdmin, motDePasseAdmin);
    case EtatApp.connecteeEssai:
      await _essai(base, container);
      await config.terminer(configurationTest());
      await session.connecter(identifiantAdmin, motDePasseAdmin);
    case EtatApp.lectureSeule:
      await _essaiTermine(base, container);
    case EtatApp.connecteeLectureSeule:
      await _essaiTermine(base, container);
      await config.terminer(configurationTest());
      await session.connecter(identifiantAdmin, motDePasseAdmin);
    case EtatApp.connecteeMagasinier:
      await licence.activer(await cleTest(NiveauLicence.ultra));
      await config.terminer(configurationTest());
      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0003', identifiant: 'yacine', nom: 'Yacine', roleCode: Roles.magasinier),
        hachageTest.hacher('1234'),
      );
      await session.connecter('yacine', '1234');
    case EtatApp.connecteeCaissier:
      await licence.activer(await cleTest(NiveauLicence.basic));
      await config.terminer(configurationTest());
      await UtilisateurRepository(base.db).inserer(
        const Utilisateur(code: 'USR0002', identifiant: 'amina', nom: 'Amina', roleCode: Roles.caissier),
        hachageTest.hacher('1234'),
      );
      await session.connecter('amina', '1234');
  }
  await chargerEtatDemarrage(container, synchroniser: false);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const CaisseDzApp()));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
  return container;
}

/// Ouvre les cartes de chiffres du module affiché (repliées par défaut).
Future<void> ouvrirChiffres(WidgetTester tester) => clic(tester, find.byKey(const ValueKey('module_chiffres')).first);

/// Ouvre le panneau de filtres du module affiché (fermé par défaut).
Future<void> ouvrirFiltres(WidgetTester tester) => clic(tester, find.byKey(const ValueKey('panneau_filtres')).first);

/// Administrateur système provisoire (migration v008).
/// À l'écran de connexion : clique le compte [identifiant] puis tape [motDePasse] (sans valider).
Future<void> choisirCompte(WidgetTester tester, String motDePasse, {String identifiant = identifiantAdmin}) async {
  await clic(tester, find.byKey(ValueKey('compte_$identifiant')));
  await tester.enterText(find.byKey(const ValueKey('connexion_mot_de_passe')), motDePasse);
}

const String identifiantAdmin = MigrationV008ShellDs.identifiantAdmin;
const String motDePasseAdmin = MigrationV008ShellDs.motDePasseAdmin;

ConfigurationInitiale configurationTest() => const ConfigurationInitiale(
  boutique: Boutique(nom: 'Superette El Baraka', rc: '16/00-123456'),
  parametres: ParametresVente(margeDefautPct: 25),
);

/// Modèle Excel d'import (raccourci de test).
Uint8List importModele() => ImportProduitsService.modele();

/// Services de test (hachage rapide) sur une base donnée ; la licence : licenceServiceTest.
AuthService authServiceTest(AppDatabase base) => AuthService(base.db, hachage: hachageTest);
ConfigurationInitialeService configurationServiceTest(AppDatabase base) => ConfigurationInitialeService(base.db);

/// Chemin courant du routeur.
String routeCourante(ProviderContainer c) => c.read(routerProvider).routeInformationProvider.value.uri.path;
