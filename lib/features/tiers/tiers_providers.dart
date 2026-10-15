import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/cloture_service.dart';
import '../../application/retour_service.dart';
import '../../application/tiers_service.dart';
import '../../application/versement_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/client_repository.dart';
import '../../data/tiers_repository.dart';
import '../../data/vente_repository.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../produits/produits_providers.dart';

final tiersRepositoryProvider = Provider<TiersRepository>((ref) => TiersRepository(ref.watch(appDatabaseProvider).db));
final clientRepositoryProvider = Provider<ClientRepository>(
  (ref) => ClientRepository(ref.watch(appDatabaseProvider).db),
);
final venteRepositoryProvider = Provider<VenteRepository>((ref) => VenteRepository(ref.watch(appDatabaseProvider).db));

final tiersServiceProvider = Provider<TiersService>(
  (ref) => TiersService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);
final versementServiceProvider = Provider<VersementService>(
  (ref) =>
      VersementService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);
final retourServiceProvider = Provider<RetourService>(
  (ref) => RetourService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    periodeCloturee: ClotureService.periodeCloturee,
  ),
);

/// Version des données commerciales (ventes, retours, versements, tiers).
final commerceVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirCommerce(WidgetRef ref) => ref.read(commerceVersionProvider.notifier).incrementer();

final clientsProvider = FutureProvider<List<Client>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(clientRepositoryProvider).tous();
});

final fournisseursProvider = FutureProvider<List<Fournisseur>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).fournisseurs();
});

final ventesProvider = FutureProvider<List<Vente>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(venteRepositoryProvider).ventes(limite: 1000);
});

final retoursProvider = FutureProvider<List<Retour>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).retours();
});

final versementsProvider = FutureProvider<List<Versement>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).versements();
});

/// Statistiques calculées des clients (total achats, crédit, avance…), par code.
final statsClientsProvider = FutureProvider<Map<String, StatsTiers>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).statistiques(TypesTiers.client);
});

/// Statistiques calculées des fournisseurs, par code.
final statsFournisseursProvider = FutureProvider<Map<String, StatsTiers>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).statistiques(TypesTiers.fournisseur);
});

final soldeClientProvider = FutureProvider.family<double, String>((ref, code) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).soldeClient(code);
});

final soldeFournisseurProvider = FutureProvider.family<double, String>((ref, code) {
  ref.watch(commerceVersionProvider);
  return ref.watch(tiersRepositoryProvider).soldeFournisseur(code);
});

String messageErreurVersement(AppLocalizations l10n, ErreurVersement e) => switch (e) {
  ErreurVersement.montantInvalide => l10n.versementErreurMontant,
  ErreurVersement.modeInvalide => l10n.versementErreurMode,
  ErreurVersement.tiersSysteme => l10n.versementErreurSysteme,
  ErreurVersement.verrouille => l10n.versementErreurVerrouille,
  ErreurVersement.inconnu => l10n.versementErreurInconnu,
  ErreurVersement.tiersInvalide => l10n.versementErreurTiers,
  ErreurVersement.motifObligatoire => l10n.dsMotifAnnulation,
  ErreurVersement.dejaAnnule => l10n.tiersBloqueDejaAnnule,
};

String messageErreurRetour(AppLocalizations l10n, ErreurRetour e) => switch (e) {
  ErreurRetour.venteInconnue => l10n.retourErreurVenteInconnue,
  ErreurRetour.venteAnnulee => l10n.retourErreurVenteAnnulee,
  ErreurRetour.lignesVides => l10n.retourErreurLignes,
  ErreurRetour.quantiteInvalide => l10n.retourErreurQuantite,
  ErreurRetour.quantiteDepasse => l10n.retourErreurDepasse,
  ErreurRetour.periodeCloturee => l10n.retourErreurPeriode,
  ErreurRetour.modeInvalide => l10n.versementErreurMode,
};

String messageErreurTiers(AppLocalizations l10n, ErreurTiers e) => switch (e) {
  ErreurTiers.nomVide => l10n.tiersErreurNom,
  ErreurTiers.systeme => l10n.tiersErreurSysteme,
  ErreurTiers.inconnu => l10n.communAucunResultat,
  ErreurTiers.nomExistant => l10n.tiersErreurNomExistant,
  ErreurTiers.telephoneInvalide => l10n.tiersFormatTelephone,
  ErreurTiers.nifInvalide => l10n.tiersFormatNif,
  ErreurTiers.motifObligatoire => l10n.dsMotifAnnulation,
};
