import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/journal_service.dart';
import '../../application/parametres_service.dart';
import '../../application/sauvegarde_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/statistiques_repository.dart';
import '../produits/produits_providers.dart';

final statistiquesRepositoryProvider = Provider<StatistiquesRepository>(
  (ref) => StatistiquesRepository(ref.watch(appDatabaseProvider).db),
);

final parametresServiceProvider = Provider<ParametresService>(
  (ref) =>
      ParametresService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

final sauvegardeServiceProvider = Provider<SauvegardeService>(
  (ref) =>
      SauvegardeService(ref.watch(appDatabaseProvider), utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

final journalServiceProvider = Provider<JournalService>(
  (ref) =>
      JournalService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Version des données de rapport (incrémentée après toute écriture métier pour recalculer).
final rapportsVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirRapports(WidgetRef ref) => ref.read(rapportsVersionProvider.notifier).incrementer();

/// Choix d'un emplacement d'enregistrement (remplacé dans les tests).
final selecteurEnregistrementProvider = Provider<Future<String?> Function(String nomSuggere, String extension)>(
  (_) =>
      (nom, ext) async => (await getSaveLocation(
        suggestedName: nom,
        acceptedTypeGroups: [
          XTypeGroup(label: ext.toUpperCase(), extensions: [ext]),
        ],
      ))?.path,
);

/// Choix d'un dossier (remplacé dans les tests).
final selecteurDossierProvider = Provider<Future<String?> Function()>(
  (_) =>
      () => getDirectoryPath(),
);

/// Choix d'un fichier existant (remplacé dans les tests).
final selecteurFichierProvider = Provider<Future<String?> Function(List<String> extensions)>(
  (_) =>
      (exts) async => (await openFile(
        acceptedTypeGroups: [XTypeGroup(label: exts.join(', ').toUpperCase(), extensions: exts)],
      ))?.path,
);

/// Écriture d'un fichier (remplacée dans les tests : les E/S fichier ne s'achèvent pas en zone de test).
final ecrivainFichierProvider = Provider<Future<void> Function(String chemin, Uint8List octets)>(
  (_) =>
      (chemin, octets) => File(chemin).writeAsBytes(octets, flush: true),
);

String messageErreurParametres(AppLocalizations l10n, ErreurParametres e) => switch (e) {
  ErreurParametres.nomBoutiqueVide => l10n.parametresErreurNom,
  ErreurParametres.valeurInvalide => l10n.parametresErreurValeur,
  ErreurParametres.typeImprimanteInvalide => l10n.parametresErreurImprimanteType,
  ErreurParametres.adresseImprimanteRequise => l10n.parametresErreurImprimanteAdresse,
  ErreurParametres.sauvegardeIncomplete => l10n.pmSauvegardeIncomplete,
  ErreurParametres.raccourciInvalide => l10n.pmRaccourciInvalide,
};

String messageErreurSauvegarde(AppLocalizations l10n, SauvegardeException e) => switch (e.erreur) {
  ErreurSauvegarde.motDePasseVide => l10n.sauvegardeErreurMotDePasseVide,
  ErreurSauvegarde.fichierIntrouvable => l10n.sauvegardeErreurFichier,
  ErreurSauvegarde.motDePasseInvalide => l10n.sauvegardeErreurMotDePasse,
  ErreurSauvegarde.cheminInvalide => l10n.sauvegardeErreurChemin(e.detail ?? ''),
};
