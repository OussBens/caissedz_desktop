import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/caisse_service.dart';
import '../../application/cloture_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/vente.dart';
import '../caisse/pos_controller.dart';
import '../produits/produits_providers.dart';

final caisseServiceProvider = Provider<CaisseService>(
  (ref) => CaisseService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

final clotureServiceProvider = Provider<ClotureService>(
  (ref) =>
      ClotureService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Version des données de caisse (caisses, mouvements, transferts, clôtures).
final caisseVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirCaisse(WidgetRef ref) => ref.read(caisseVersionProvider.notifier).incrementer();

final caissesListeProvider = FutureProvider<List<Caisse>>((ref) {
  ref.watch(caisseVersionProvider);
  return ref.watch(caisseServiceProvider).caisses();
});

final soldesCaissesProvider = FutureProvider<Map<String, SoldeCaisse>>((ref) async {
  ref.watch(caisseVersionProvider);
  final s = ref.watch(caisseServiceProvider);
  return {for (final c in await s.caisses()) c.code: await s.solde(c.code)};
});

final mouvementsCaisseProvider = FutureProvider<List<MouvementCaisse>>((ref) {
  ref.watch(caisseVersionProvider);
  return ref.watch(caisseServiceProvider).mouvements();
});

final transfertsCaisseProvider = FutureProvider<List<TransfertCaisse>>((ref) {
  ref.watch(caisseVersionProvider);
  return ref.watch(caisseServiceProvider).transferts();
});

final cloturesProvider = FutureProvider<List<Cloture>>((ref) {
  ref.watch(caisseVersionProvider);
  return ref.watch(clotureServiceProvider).clotures();
});

/// Historique des sessions de caisse, plus récentes d'abord.
final sessionsCaisseProvider = FutureProvider<List<SessionCaisse>>((ref) {
  ref.watch(caisseVersionProvider);
  return ref.watch(sessionCaisseServiceProvider).sessions();
});

/// Choix de l'emplacement d'enregistrement d'un export (remplacé dans les tests).
final selecteurExportProvider = Provider<Future<String?> Function(String nomSuggere)>(
  (_) =>
      (nom) async => (await getSaveLocation(suggestedName: nom))?.path,
);

/// Écriture d'un export sur disque (remplacée dans les tests : les E/S fichier ne s'achèvent pas en zone de test).
final ecrivainExportProvider = Provider<Future<void> Function(String chemin, Uint8List octets)>(
  (_) =>
      (chemin, octets) => File(chemin).writeAsBytes(octets, flush: true),
);

/// Choix d'une archive fiscale à vérifier (remplacé dans les tests).
final selecteurArchiveProvider = Provider<Future<XFile?> Function()>(
  (_) =>
      () => openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'ZIP / JSON', extensions: ['zip', 'json']),
        ],
      ),
);

String libelleTypeCaisse(AppLocalizations l10n, String type) =>
    type == TypesCaisse.compte ? l10n.caisseTypeCompte : l10n.caisseTypePhysique;

String libelleTypeMouvementCaisse(AppLocalizations l10n, String type) => switch (type) {
  TypesMouvementCaisse.vente => l10n.mvtVente,
  TypesMouvementCaisse.annulation => l10n.mvtAnnulation,
  TypesMouvementCaisse.remboursement => l10n.mvtRemboursement,
  TypesMouvementCaisse.encaissement => l10n.mvtEncaissement,
  TypesMouvementCaisse.decaissement => l10n.mvtDecaissement,
  TypesMouvementCaisse.apport => l10n.mvtApport,
  TypesMouvementCaisse.depense => l10n.mvtDepense,
  TypesMouvementCaisse.transfert => l10n.mvtTransfert,
  TypesMouvementCaisse.fondInitial => l10n.mvtFondInitial,
  TypesMouvementCaisse.retrait => l10n.mvtRetrait,
  TypesMouvementCaisse.ecart => l10n.mvtEcart,
  _ => type,
};

String messageErreurCaisse(AppLocalizations l10n, ErreurCaisse e) => switch (e) {
  ErreurCaisse.nomVide => l10n.caisseErreurNom,
  ErreurCaisse.typeInvalide => l10n.caisseErreurType,
  ErreurCaisse.magasinInconnu => l10n.caisseErreurMagasin,
  ErreurCaisse.caisseInconnue => l10n.caisseErreurInconnue,
  ErreurCaisse.caisseInactive => l10n.caisseErreurInactive,
  ErreurCaisse.caisseSysteme => l10n.caisseErreurSysteme,
  ErreurCaisse.montantInvalide => l10n.caisseErreurMontant,
  ErreurCaisse.modeInvalide => l10n.caisseErreurMode,
  ErreurCaisse.memeCaisse => l10n.caisseErreurMemeCaisse,
  ErreurCaisse.soldeInsuffisant => l10n.caisseErreurSolde,
  ErreurCaisse.sessionOuverte => l10n.caisseErreurSessionOuverte,
  ErreurCaisse.soldeNonNul => l10n.gcErreurSoldeNonNul,
  ErreurCaisse.transfertInconnu => l10n.gcErreurTransfertInconnu,
  ErreurCaisse.dejaAnnule => l10n.gcErreurDejaAnnule,
  ErreurCaisse.motifObligatoire => l10n.entErreurMotif,
  ErreurCaisse.periodeCloturee => l10n.gcErreurPeriodeCloturee,
};

String messageErreurCloture(AppLocalizations l10n, ErreurCloture e) => switch (e) {
  ErreurCloture.caisseInconnue => l10n.caisseErreurInconnue,
  ErreurCloture.rienACloturer => l10n.clotureErreurRien,
};
