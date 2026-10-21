import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/stock_service.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/stock_repository.dart';
import '../../domain/models/stock.dart';
import '../../domain/referentiel/referentiel.dart';
import '../produits/produits_providers.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) => StockRepository(ref.watch(appDatabaseProvider).db));

final stockServiceProvider = Provider<StockService>(
  (ref) => StockService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    maxMagasins: ref.watch(licenceProvider).niveau?.magasins,
  ),
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

/// Périmètre « magasins » des alertes et indicateurs de stock : tous pour un administrateur, sinon ceux de
/// l'utilisateur connecté (même règle que les alertes, m5).
Future<List<String>?> magasinsDeLaSession(Ref ref) async {
  final session = ref.read(sessionProvider);
  if (session == null || session.estAdmin) return null;
  return ref.read(mesMagasinsProvider.future);
}

/// Le palier a-t-il plusieurs magasins (Ultra) ? Basic et Avancé : un seul magasin, aucun choix de magasin
/// dans les formulaires ni les filtres (tout va au magasin principal).
final plusieursMagasinsProvider = Provider<bool>((ref) => (ref.watch(licenceProvider).niveau?.magasins ?? 2) > 1);

final magasinPrincipalProvider = FutureProvider<String>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockServiceProvider).magasinPrincipal(ref.watch(utilisateurCourantCodeProvider));
});

/// Journal complet des mouvements (les filtres sont appliqués à l'écran).
final mouvementsProvider = FutureProvider<List<MouvementStock>>((ref) {
  ref.watch(stockVersionProvider);
  ref.watch(catalogueVersionProvider);
  return ref.watch(stockRepositoryProvider).mouvements(limite: 5000);
});

/// Quantités par produit et par magasin : `{produit: {magasin: quantité}}`.
final stocksParMagasinProvider = FutureProvider<Map<String, Map<String, double>>>((ref) {
  ref.watch(stockVersionProvider);
  ref.watch(catalogueVersionProvider);
  return ref.watch(stockRepositoryProvider).stocksParMagasin();
});

/// Pièces (2ᵉ stock « nombre ») par produit et par magasin.
final nombresParMagasinProvider = FutureProvider<Map<String, Map<String, double>>>((ref) {
  ref.watch(stockVersionProvider);
  ref.watch(catalogueVersionProvider);
  return ref.watch(stockRepositoryProvider).nombresParMagasin();
});

final utilisateursParMagasinProvider = FutureProvider<Map<String, List<String>>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).utilisateursParMagasin();
});

final caissesParMagasinProvider = FutureProvider<Map<String, List<String>>>((ref) {
  ref.watch(stockVersionProvider);
  return ref.watch(stockRepositoryProvider).caissesParMagasin();
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

String libelleTypeMouvement(AppLocalizations l10n, String type) => switch (type) {
  TypesMouvement.entree => l10n.typeMouvementEntree,
  TypesMouvement.sortie => l10n.typeMouvementSortie,
  TypesMouvement.vente => l10n.typeMouvementVente,
  TypesMouvement.retour => l10n.typeMouvementRetour,
  TypesMouvement.transfert => l10n.typeMouvementTransfert,
  TypesMouvement.inventaire => l10n.typeMouvementInventaire,
  TypesMouvement.initial => l10n.typeMouvementInitial,
  TypesMouvement.annulation => l10n.typeMouvementAnnulation,
  _ => type,
};

String libelleMotif(AppLocalizations l10n, String motif) => switch (motif) {
  'Casse' => l10n.motifCasse,
  'Périmé' => l10n.motifPerime,
  'Perte / vol' => l10n.motifPerteVol,
  'Consommation interne' => l10n.motifConsommationInterne,
  'Don' => l10n.motifDon,
  'Échantillon' => l10n.motifEchantillon,
  _ => Referentiel.motifsSortie.libelle(motif, const Locale('fr')),
};

/// Statut du DS (`StatusBadge`) d'une liste de besoins.
String statutBesoinDs(Besoin b) => !b.actif
    ? 'annule'
    : switch (b.statut) {
        StatutsBesoin.commande => 'commande',
        StatutsBesoin.disponible => 'disponible',
        _ => 'enAttente',
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
  ErreurStock.nomPris => l10n.stkErreurNomPris,
  ErreurStock.magasinPrincipal => l10n.stkBloqueMagasinPrincipal,
  ErreurStock.stockNonNul => l10n.stkBloqueStockNonNul,
  ErreurStock.dejaAnnule => l10n.stkBloqueDejaAnnule,
  ErreurStock.documentInconnu => l10n.stkErreurDocumentInconnu,
  ErreurStock.motifObligatoire => l10n.stkErreurMotifObligatoire,
  ErreurStock.fournisseurObligatoire => l10n.stkErreurFournisseur,
  ErreurStock.besoinRecu => l10n.stkBloqueBesoinRecu,
  ErreurStock.aucunChangement => l10n.stkAucunChangement,
  ErreurStock.nombreObligatoire => l10n.communNombreObligatoire,
  ErreurStock.sortieRetour => l10n.stkErreurSortieRetour,
  ErreurStock.limiteMagasins => l10n.limiteMagasins,
};
