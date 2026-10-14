import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/cloture_service.dart';
import '../../application/session_caisse_service.dart';
import '../../application/vente_service.dart';
import '../../data/catalogue_repository.dart';
import '../../data/stock_repository.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/vente.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';

/// Nombre maximal de ventes en parallèle.
const int maxPaniers = 5;

enum ErreurPos { stockInsuffisant, produitInconnu, maxPaniers, sessionRequise }

class PosException implements Exception {
  const PosException(this.erreur, [this.detail]);
  final ErreurPos erreur;
  final String? detail;
}

/// État du point de vente : jusqu'à 5 paniers, panier courant, session.
@immutable
class PosEtat {
  const PosEtat({
    required this.paniers,
    this.courant = 0,
    this.session,
    this.magasinCode = 'MAG0000',
    this.derniereVente,
  });
  final List<Panier> paniers;
  final int courant;
  final SessionCaisse? session;
  final String magasinCode;
  final Vente? derniereVente;

  Panier get panier => paniers[courant];

  PosEtat copyWith({
    List<Panier>? paniers,
    int? courant,
    SessionCaisse? session,
    bool effacerSession = false,
    String? magasinCode,
    Vente? derniereVente,
  }) => PosEtat(
    paniers: paniers ?? this.paniers,
    courant: courant ?? this.courant,
    session: effacerSession ? null : (session ?? this.session),
    magasinCode: magasinCode ?? this.magasinCode,
    derniereVente: derniereVente ?? this.derniereVente,
  );

  PosEtat remplacerPanier(Panier p) {
    final copie = [...paniers];
    copie[courant] = p;
    return copyWith(paniers: copie);
  }

  /// Unités réservées pour un produit dans TOUS les paniers ouverts.
  double unitesReservees(String produitCode) => paniers.fold(0.0, (s, p) => s + p.unitesReservees(produitCode));
  double nombreReserve(String produitCode) => paniers.fold(0.0, (s, p) => s + p.nombreReserve(produitCode));
}

final sessionCaisseServiceProvider = Provider<SessionCaisseService>(
  (ref) => SessionCaisseService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
  ),
);

final venteServiceProvider = Provider<VenteService>(
  (ref) => VenteService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    parametres: ref.watch(parametresVenteProvider).value ?? const ParametresVente(),
    periodeCloturee: ClotureService.periodeCloturee,
  ),
);

class PosController extends Notifier<PosEtat> {
  int _prochainId = 1;

  @override
  PosEtat build() => PosEtat(paniers: [Panier(id: _prochainId++)]);

  /// Charge la session ouverte et le magasin principal de l'utilisateur.
  Future<void> initialiser() async {
    final session = await ref.read(sessionCaisseServiceProvider).courante();
    final magasin = await ref.read(stockServiceProvider).magasinPrincipal(ref.read(utilisateurCourantCodeProvider));
    state = state.copyWith(session: session, effacerSession: session == null, magasinCode: magasin);
  }

  // ---------------- Sessions ----------------
  Future<SessionCaisse> ouvrirSession({required String caisseCode, required double fondInitial}) async {
    final s = await ref.read(sessionCaisseServiceProvider).ouvrir(caisseCode: caisseCode, fondInitial: fondInitial);
    state = state.copyWith(session: s);
    return s;
  }

  Future<SessionCaisse> fermerSession({required double montantCompte}) async {
    final s = await ref.read(sessionCaisseServiceProvider).fermer(montantCompte: montantCompte);
    state = state.copyWith(effacerSession: true);
    return s;
  }

  // ---------------- Paniers ----------------
  void nouveauPanier() {
    if (state.paniers.length >= maxPaniers) throw const PosException(ErreurPos.maxPaniers);
    state = state.copyWith(
      paniers: [
        ...state.paniers,
        Panier(id: _prochainId++),
      ],
      courant: state.paniers.length,
    );
  }

  void selectionnerPanier(int index) {
    if (index >= 0 && index < state.paniers.length) state = state.copyWith(courant: index);
  }

  void panierSuivant() => selectionnerPanier((state.courant + 1) % state.paniers.length);

  void fermerPanier(int index) {
    if (state.paniers.length == 1) {
      state = state.remplacerPanier(state.panier.vider());
      return;
    }
    final copie = [...state.paniers]..removeAt(index);
    state = state.copyWith(paniers: copie, courant: state.courant.clamp(0, copie.length - 1));
  }

  void viderPanier() => state = state.remplacerPanier(state.panier.vider());

  // ---------------- Lignes ----------------
  Future<void> _verifierDisponibilite(Produit produit, {double unites = 0, double nombre = 0}) async {
    final niveau = await StockRepository(ref.read(appDatabaseProvider).db).niveau(produit.code, state.magasinCode);
    final dispoUnites = niveau.quantite - state.unitesReservees(produit.code);
    final dispoNombre = niveau.nombre - state.nombreReserve(produit.code);
    if (unites > dispoUnites + 1e-9 || nombre > dispoNombre + 1e-9) {
      throw PosException(ErreurPos.stockInsuffisant, '${produit.designation} : ${dispoUnites.toStringAsFixed(0)}');
    }
  }

  /// Ajoute un produit (ou un colis / pack) au panier courant, après contrôle du stock réservé.
  Future<void> ajouter(Produit produit, {Colis? colis, Pack? pack, bool nombre = false, double quantite = 1}) async {
    if (pack != null) {
      final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
      for (final c in pack.lignes) {
        final p = await catalogue.produitParCode(c.produitCode);
        if (p == null) throw PosException(ErreurPos.produitInconnu, c.produitCode);
        await _verifierDisponibilite(p, unites: c.quantite * quantite);
      }
      state = state.remplacerPanier(
        state.panier.ajouter(
          PanierLigne(produit: produit, pack: pack, quantite: quantite, prixUnitaire: pack.prixVente),
        ),
      );
      return;
    }
    if (nombre) {
      await _verifierDisponibilite(produit, nombre: quantite);
      final prixPiece = produit.nombreParUnite > 0 ? produit.prixVente / produit.nombreParUnite : produit.prixVente;
      state = state.remplacerPanier(
        state.panier.ajouter(
          PanierLigne(
            produit: produit,
            quantite: quantite,
            uniteVente: UniteVente.nombre,
            prixUnitaire: double.parse(prixPiece.toStringAsFixed(2)),
          ),
        ),
      );
      return;
    }
    await _verifierDisponibilite(produit, unites: quantite * (colis?.quantite ?? 1));
    final remise = await ref.read(catalogueServiceProvider).remiseApplicable(produit, produit.prixVente);
    final remisePct = colis == null && remise > 0 && produit.prixVente > 0
        ? double.parse((remise / produit.prixVente * 100).toStringAsFixed(2))
        : 0.0;
    state = state.remplacerPanier(
      state.panier.ajouter(
        PanierLigne(
          produit: produit,
          colis: colis,
          quantite: quantite,
          prixUnitaire: colis?.prixVente ?? produit.prixVente,
          remisePct: remisePct,
        ),
      ),
    );
  }

  /// Scan : QR produit, code-barres produit, colis ou pack.
  Future<bool> scanner(String code) async {
    final c = code.trim();
    if (c.isEmpty) return false;
    final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
    final qr = CodesBarres.codeProduitDepuisQr(c);
    Produit? produit = qr != null ? await catalogue.produitParCode(qr) : await catalogue.produitParCodeBarres(c);
    produit ??= await catalogue.produitParCode(c.toUpperCase());
    if (produit != null) {
      if (!produit.actif) return false;
      await ajouter(produit);
      return true;
    }
    final colis = await catalogue.colisParCodeBarres(c);
    if (colis != null) {
      final p = await catalogue.produitParCode(colis.produitCode);
      if (p == null) return false;
      await ajouter(p, colis: colis);
      return true;
    }
    final pack = await catalogue.packParCodeBarres(c);
    if (pack != null && pack.lignes.isNotEmpty) {
      final p = await catalogue.produitParCode(pack.lignes.first.produitCode);
      if (p == null) return false;
      await ajouter(p, pack: pack);
      return true;
    }
    return false;
  }

  Future<void> modifierQuantite(int index, double quantite) async {
    final l = state.panier.lignes[index];
    if (quantite > l.quantite) {
      final delta = quantite - l.quantite;
      if (l.pack != null) {
        final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
        for (final c in l.pack!.lignes) {
          final p = await catalogue.produitParCode(c.produitCode);
          if (p != null) await _verifierDisponibilite(p, unites: c.quantite * delta);
        }
      } else if (l.uniteVente == UniteVente.nombre) {
        await _verifierDisponibilite(l.produit, nombre: delta);
      } else {
        await _verifierDisponibilite(l.produit, unites: delta * (l.colis?.quantite ?? 1));
      }
    }
    state = state.remplacerPanier(state.panier.modifierQuantite(index, quantite));
  }

  void retirerLigne(int index) => state = state.remplacerPanier(state.panier.retirer(index));

  void remiseLigne(int index, double pct) => state = state.remplacerPanier(
    state.panier.modifierLigne(index, state.panier.lignes[index].copyWith(remisePct: pct.clamp(0, 100))),
  );

  void prixLigne(int index, double prix) => state = state.remplacerPanier(
    state.panier.modifierLigne(index, state.panier.lignes[index].copyWith(prixUnitaire: prix < 0 ? 0 : prix)),
  );

  void remiseGlobale(double pct) =>
      state = state.remplacerPanier(state.panier.copyWith(remiseGlobalePct: pct.clamp(0, 100)));

  void choisirClient(String code) => state = state.remplacerPanier(state.panier.copyWith(clientCode: code));

  // ---------------- Paiements ----------------
  void ajouterPaiement(String mode, double montant, {String? reference}) {
    if (montant <= 0) return;
    state = state.remplacerPanier(
      state.panier.ajouterPaiement(Paiement(mode: mode, montant: montant, reference: reference)),
    );
  }

  void retirerPaiement(int index) => state = state.remplacerPanier(state.panier.retirerPaiement(index));

  /// Encaisse le panier courant ; le panier est vidé et la vente mémorisée pour l'impression.
  Future<Vente> encaisser({bool creditAutorise = false}) async {
    final session = state.session;
    if (session == null) throw const PosException(ErreurPos.sessionRequise);
    final v = await ref
        .read(venteServiceProvider)
        .encaisser(state.panier, session: session, magasinCode: state.magasinCode, creditAutorise: creditAutorise);
    state = state.remplacerPanier(state.panier.vider()).copyWith(derniereVente: v);
    ref.read(stockVersionProvider.notifier).incrementer();
    return v;
  }
}

final posControllerProvider = NotifierProvider<PosController, PosEtat>(PosController.new);

/// Produits actifs pour la grille du POS.
final produitsPosProvider = FutureProvider<List<Produit>>((ref) {
  ref.watch(catalogueVersionProvider);
  return ref.watch(catalogueRepositoryProvider).produits(actifsSeulement: true);
});

/// Caisses actives (ouverture de session).
final caissesProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(appDatabaseProvider).db.query('caisse', where: 'actif = 1', orderBy: 'code'),
);
