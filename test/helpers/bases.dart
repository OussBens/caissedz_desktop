import 'dart:io';

import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ouvre une base chiffrée de test dans un dossier temporaire, supprimé à la fin.
/// Réservé aux tests unitaires (`test`) : voir [ouvrirBaseEnMemoire] pour `testWidgets`.
Future<AppDatabase> ouvrirBaseDeTest({String? cleHex}) async {
  AppDatabase.initialiserMoteur();
  final dossier = Directory.systemTemp.createTempSync('caissedz_test_');
  final base = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleHex ?? cleTestHex);
  addTearDown(() async {
    await base.fermer();
    if (dossier.existsSync()) dossier.deleteSync(recursive: true);
  });
  return base;
}

/// Base en mémoire pour les tests de widgets (`testWidgets` : zone asynchrone
/// simulée, les E/S fichier réelles ne se terminent jamais).
Future<AppDatabase> ouvrirBaseEnMemoire() async {
  final base = await AppDatabase.ouvrirEnMemoire(cleHex: cleTestHex);
  addTearDown(base.fermer);
  return base;
}

final String cleTestHex = DerivationCle.deriver('machine-de-test', 'sel-de-test');
