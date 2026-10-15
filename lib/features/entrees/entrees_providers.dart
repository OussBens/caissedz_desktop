import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/achat_service.dart';
import '../../application/cloture_service.dart';
import '../../application/smart_scan_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/achat.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

final achatServiceProvider = Provider<AchatService>(
  (ref) => AchatService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    periodeCloturee: ClotureService.periodeCloturee,
  ),
);

/// Entrées (bons d'achat), plus récentes d'abord.
final achatsProvider = FutureProvider<List<Achat>>((ref) {
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  return ref.watch(achatServiceProvider).achats();
});

/// File des bons de réception (Mode IA).
final bonsReceptionProvider = FutureProvider<List<BonReception>>((ref) {
  ref.watch(commerceVersionProvider);
  return ref.watch(achatServiceProvider).bonsReception();
});

final smartScanServiceProvider = Provider<SmartScanService>((ref) {
  final s = ref.watch(serveurCaisseDzProvider).value;
  return SmartScanService(client: ref.watch(httpClientProvider), baseUrl: s?.url ?? '', cleApi: s?.cle);
});

/// Quota Smart Scan du serveur (erreur si non configuré ou hors ligne).
final quotaSmartScanProvider = FutureProvider<QuotaSmartScan>((ref) async {
  await ref.watch(serveurCaisseDzProvider.future);
  return ref.watch(smartScanServiceProvider).quota();
});

/// Sélecteur de fichier (image ou PDF) ; remplacé dans les tests.
final selecteurFactureProvider = Provider<Future<XFile?> Function()>(
  (_) =>
      () => openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Factures', extensions: ['jpg', 'jpeg', 'png', 'pdf']),
        ],
      ),
);

void rafraichirEntrees(WidgetRef ref) {
  rafraichirCommerce(ref);
  rafraichirStock(ref);
  rafraichirCatalogue(ref);
}

String messageErreurAchat(AppLocalizations l10n, ErreurAchat e) => switch (e) {
  ErreurAchat.lignesVides => l10n.achatErreurLignes,
  ErreurAchat.quantiteInvalide => l10n.achatErreurQuantite,
  ErreurAchat.prixInvalide => l10n.achatErreurPrix,
  ErreurAchat.produitInconnu => l10n.achatErreurProduit,
  ErreurAchat.fournisseurInconnu => l10n.achatErreurFournisseur,
  ErreurAchat.achatInconnu => l10n.achatErreurInconnu,
  ErreurAchat.dejaAnnule => l10n.achatErreurAnnule,
  ErreurAchat.periodeCloturee => l10n.achatErreurPeriode,
  ErreurAchat.stockInsuffisant => l10n.achatErreurStock,
  ErreurAchat.retourLie => l10n.achatErreurRetourLie,
  ErreurAchat.motifObligatoire => l10n.entErreurMotif,
  ErreurAchat.repartitionIncomplete => l10n.entRepartitionIncomplete,
  ErreurAchat.bonInconnu => l10n.entErreurBonInconnu,
  ErreurAchat.bonTraite => l10n.entErreurBonTraite,
};

String messageErreurSmartScan(AppLocalizations l10n, SmartScanException e) => switch (e.erreur) {
  ErreurSmartScan.nonConfigure => l10n.smartScanNonConfigure,
  ErreurSmartScan.quotaAtteint => l10n.smartScanQuotaAtteintDetail,
  ErreurSmartScan.reseau => l10n.smartScanErreurReseau(e.detail ?? ''),
  ErreurSmartScan.serveur => l10n.smartScanErreurServeur(e.detail ?? ''),
  ErreurSmartScan.fichierInvalide => l10n.smartScanErreurFichier,
};

/// Libellé localisé de l'origine d'une entrée.
String libelleSourceAchat(AppLocalizations l10n, Achat a) => switch (a.source) {
  SourcesAchat.rapide => l10n.entSourceRapide,
  SourcesAchat.ia => l10n.entSourceIa,
  _ => l10n.sourceSmartScan,
};
