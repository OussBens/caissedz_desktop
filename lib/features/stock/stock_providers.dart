import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/stock_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/stock_repository.dart';
import '../../domain/models/stock.dart';
import '../../domain/referentiel/referentiel.dart';
import '../produits/produits_providers.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) => StockRepository(ref.watch(appDatabaseProvider).db));

final stockServiceProvider = Provider<StockService>(
  (ref) => StockService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Version du stock : incrémentée après chaque écriture (mouvements, magasins, besoins…).
final stockVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirStock(WidgetRef ref) => ref.read(stockVersionProvider.notifier).incrementer();

final magasinsProvider = FutureProvider<List<Magasin>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).magasins();
});

/// Magasins de l'utilisateur connecté (le premier est le principal).
final mesMagasinsProvider = FutureProvider<List<String>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).magasinsUtilisateur(ref.watch(utilisateurCourantCodeProvider));
});

final magasinPrincipalProvider = FutureProvider<String>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockServiceProvider).magasinPrincipal(ref.watch(utilisateurCourantCodeProvider));
});

/// Filtre magasin des écrans de stock (`null` = tous).
class FiltreMagasinNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void changer(String? v) => state = v;
}

final filtreMagasinProvider = NotifierProvider<FiltreMagasinNotifier, String?>(FiltreMagasinNotifier.new);

final niveauxStockProvider = FutureProvider<List<NiveauStock>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).niveaux(magasinCode: ref.watch(filtreMagasinProvider));
});

final mouvementsProvider = FutureProvider<List<MouvementStock>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).mouvements(magasinCode: ref.watch(filtreMagasinProvider));
});

final transfertsProvider = FutureProvider<List<TransfertStock>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).transferts();
});

final besoinsProvider = FutureProvider<List<Besoin>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).besoins();
});

final sortiesProvider = FutureProvider<List<SortieStock>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).sorties();
});

/// Mouvements de type Vente (onglet « Ventes » des sorties).
final mouvementsVenteProvider = FutureProvider<List<MouvementStock>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).mouvements(type: TypesMouvement.vente);
});

String libelleTypeMouvement(AppLocalizations l10n, String type) => switch (type) {
  TypesMouvement.entree => l10n.typeMouvementEntree,
  TypesMouvement.sortie => l10n.typeMouvementSortie,
  TypesMouvement.vente => l10n.typeMouvementVente,
  TypesMouvement.retour => l10n.typeMouvementRetour,
  TypesMouvement.transfert => l10n.typeMouvementTransfert,
  TypesMouvement.inventaire => l10n.typeMouvementInventaire,
  TypesMouvement.initial => l10n.typeMouvementInitial,
  _ => type,
};

String libelleMotif(AppLocalizations l10n, String motif) => switch (motif) {
  'Casse' => l10n.motifCasse,
  'Périmé' => l10n.motifPerime,
  'Perte/vol' => l10n.motifPerteVol,
  'Consommation interne' => l10n.motifConsommationInterne,
  'Don' => l10n.motifDon,
  'Échantillon' => l10n.motifEchantillon,
  _ => Referentiel.motifsSortie.libelle(motif, const Locale('fr')),
};

String libelleStatutBesoin(AppLocalizations l10n, String statut) => switch (statut) {
  StatutsBesoin.enAttente => l10n.statutBesoinEnAttente,
  StatutsBesoin.commande => l10n.statutBesoinCommande,
  StatutsBesoin.disponible => l10n.statutBesoinDisponible,
  _ => statut,
};

String messageErreurStock(AppLocalizations l10n, ErreurStock e) => switch (e) {
  ErreurStock.quantiteInvalide => l10n.stockErreurQuantite,
  ErreurStock.stockInsuffisant => l10n.stockErreurInsuffisant,
  ErreurStock.memeMagasin => l10n.stockErreurMemeMagasin,
  ErreurStock.lignesVides => l10n.stockErreurLignes,
  ErreurStock.motifInvalide => l10n.stockErreurMotif,
  ErreurStock.magasinInactif => l10n.stockErreurMagasinInactif,
  ErreurStock.magasinSysteme => l10n.stockErreurMagasinSysteme,
  ErreurStock.produitInconnu => l10n.stockErreurProduit,
  ErreurStock.statutInvalide => l10n.stockErreurStatut,
};
