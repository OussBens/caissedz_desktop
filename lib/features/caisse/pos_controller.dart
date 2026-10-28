import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/cloture_service.dart';
import '../../application/facture_service.dart';
import '../../application/session_caisse_service.dart';
import '../../application/vente_service.dart';
import '../../data/catalogue_repository.dart';
import '../../data/stock_repository.dart';
import '../../data/utilisateur_repository.dart';
import '../../domain/calculs_prix.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';

/// Nombre maximal de ventes en parallèle.
const int maxPaniers = 5;

enum ErreurPos { stockInsuffisant, produitInconnu, maxPaniers, sessionRequise }

class PosException implements Exception {
  const PosException(this.erreur, [this.detail, this.manque]);
  final ErreurPos erreur;
  final String? detail;

  /// Stock insuffisant : produit et quantités manquantes dans le magasin de la caisse (unités, pièces).
  final ManqueStock? manque;
}

/// Quantités qui manquent dans le magasin de la caisse pour ajouter un produit au panier.
typedef ManqueStock = ({Produit produit, double unites, double nombre});

/// Magasin pouvant fournir le manque par un transfert, avec son stock du produit.
typedef SourceTransfert = ({Magasin magasin, double quantite});

/// État du point de vente : jusqu'à 5 paniers, panier courant, session.
@immutable
class PosEtat {
  const PosEtat({
    required this.paniers,
    this.courant = 0,
    this.session,
    this.magasinCode = 'MAG0000',
    this.caisseCode,
    this.derniereVente,
  });
  final List<Panier> paniers;
  final int courant;
  final SessionCaisse? session;
  final String magasinCode;

  /// Caisse de ce poste (Paramètres de la caisse), proposée à l'ouverture de session.
  final String? caisseCode;
  final Vente? derniereVente;

  Panier get panier => paniers[courant];

  PosEtat copyWith({
    List<Panier>? paniers,
    int? courant,
    SessionCaisse? session,
    bool effacerSession = false,
    String? magasinCode,
    String? caisseCode,
    Vente? derniereVente,
  }) => PosEtat(
    paniers: paniers ?? this.paniers,
    courant: courant ?? this.courant,
    session: effacerSession ? null : (session ?? this.session),
    magasinCode: magasinCode ?? this.magasinCode,
    caisseCode: caisseCode ?? this.caisseCode,
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

  /// Charge la session ouverte (la sienne ou celle de sa caisse ouverte par un collègue, qu'il continue), la caisse
  /// attachée (§5 : caisse courante d'un non-Admin) et le magasin principal de l'utilisateur.
  Future<void> initialiser() async {
    final code = ref.read(utilisateurCourantCodeProvider);
    final session = await ref.read(sessionCaisseServiceProvider).courante();
    final magasin = await ref.read(stockServiceProvider).magasinPrincipal(code);
    final u = await UtilisateurRepository(ref.read(appDatabaseProvider).db).parCode(code);
    final attachee = u?.caisseCode;
    // Après un changement d'utilisateur, un non-Admin reprend sa caisse attachée (pas celle du précédent).
    final admin = u?.estAdmin ?? false;
    state = state.copyWith(
      session: session,
      effacerSession: session == null,
      magasinCode: magasin,
      caisseCode: session?.caisseCode ?? (admin ? state.caisseCode ?? attachee : attachee ?? state.caisseCode),
    );
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

  /// Ferme le panier [index] ; la modification d'une vente chargée est abandonnée (la vente ne change pas).
  void fermerPanier(int index) {
    if (state.paniers.length == 1) {
      final p = state.panier;
      _poser(p.remplacement == null ? p.vider() : p.reinitialiser());
      return;
    }
    final copie = [...state.paniers]..removeAt(index);
    state = state.copyWith(paniers: copie, courant: state.courant.clamp(0, copie.length - 1));
  }

  /// Vide le panier courant ; une vente modifiée garde ses lignes reprises.
  void viderPanier() => _poser(state.panier.vider());

  /// Charge la vente [code] dans un panier pour la modifier : ses lignes y sont reprises verrouillées (ni retirées
  /// ni modifiées), on peut changer le client et ajouter des produits ; à l'encaissement, elle est annulée et
  /// remplacée par un nouveau ticket ([VenteService.encaisser]). Le panier courant est utilisé s'il est vide,
  /// sinon un nouveau panier ; une vente déjà chargée redevient le panier courant.
  Future<void> modifierVente(String code) async {
    final deja = state.paniers.indexWhere((p) => p.remplacement?.code == code);
    if (deja >= 0) return selectionnerPanier(deja);
    final m = await ref.read(venteServiceProvider).preparerModification(code);
    final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
    final packs = {for (final p in await catalogue.packs()) p.code: p};
    final lignes = <PanierLigne>[];
    for (final l in m.vente.lignes) {
      final p = await catalogue.produitParCode(l.produitCode);
      if (p == null) throw PosException(ErreurPos.produitInconnu, l.produitCode);
      final colis = l.colisCode == null
          ? null
          : (await catalogue.colis(produitCode: p.code)).where((c) => c.code == l.colisCode).firstOrNull;
      lignes.add(PanierLigne.reprise(l, p, colis: colis, pack: packs[l.packCode]));
    }
    final v = m.vente;
    final courantVide = state.panier.estVide && state.panier.remplacement == null;
    if (!courantVide && state.paniers.length >= maxPaniers) throw const PosException(ErreurPos.maxPaniers);
    final panier = Panier(
      id: courantVide ? state.panier.id : _prochainId++,
      lignes: lignes,
      clientCode: v.clientCode,
      commentaire: v.commentaire,
      modePaiement: v.paiements.where((p) => p.mode != 'Points').firstOrNull?.mode ?? 'Espèces',
      remplacement: m.remplacement,
    );
    _remises.remove(panier.id);
    state = courantVide
        ? state.remplacerPanier(panier)
        : state.copyWith(paniers: [...state.paniers, panier], courant: state.paniers.length);
  }

  // ---------------- Lignes ----------------
  Future<void> _verifierDisponibilite(Produit produit, {double unites = 0, double nombre = 0}) async {
    if (produit.service) return;
    final niveau = await StockRepository(ref.read(appDatabaseProvider).db).niveau(produit.code, state.magasinCode);
    final dispoUnites = niveau.quantite - state.unitesReservees(produit.code);
    final dispoNombre = niveau.nombre - state.nombreReserve(produit.code);
    if (unites > dispoUnites + 1e-9 || nombre > dispoNombre + 1e-9) {
      throw PosException(ErreurPos.stockInsuffisant, '${produit.designation} : ${dispoUnites.toStringAsFixed(0)}', (
        produit: produit,
        unites: unites > dispoUnites ? unites - (dispoUnites < 0 ? 0 : dispoUnites) : 0,
        nombre: nombre > dispoNombre ? nombre - (dispoNombre < 0 ? 0 : dispoNombre) : 0,
      ));
    }
  }

  /// Autre magasin actif pouvant couvrir [manque] (le mieux pourvu), ou `null`. L'Admin puise dans tous les
  /// magasins ; un autre utilisateur seulement dans ses magasins (`utilisateur_magasin`). Les transferts entre
  /// magasins sont dans la formule Ultra seulement.
  Future<SourceTransfert?> sourceTransfert(ManqueStock manque) async {
    if (!ref.read(licenceProvider).couvre(NiveauLicence.ultra)) return null;
    final repo = StockRepository(ref.read(appDatabaseProvider).db);
    final admin = ref.read(sessionProvider)?.estAdmin ?? false;
    final siens = admin ? null : (await repo.magasinsUtilisateur(ref.read(utilisateurCourantCodeProvider))).toSet();
    SourceTransfert? meilleure;
    for (final m in await repo.magasins(actifsSeulement: true)) {
      if (m.code == state.magasinCode || (siens != null && !siens.contains(m.code))) continue;
      final n = await repo.niveau(manque.produit.code, m.code);
      if (n.quantite + 1e-9 < manque.unites || n.nombre + 1e-9 < manque.nombre) continue;
      if (meilleure == null || n.quantite > meilleure.quantite) meilleure = (magasin: m, quantite: n.quantite);
    }
    return meilleure;
  }

  /// Une quantité au-delà du stock du magasin reste validable (le transfert du manque est proposé ensuite) :
  /// toujours pour l'Admin ; pour un autre utilisateur, s'il a un autre magasin d'où transférer (formule Ultra).
  Future<bool> depassementPermis() async {
    if (ref.read(sessionProvider)?.estAdmin ?? false) return true;
    if (!ref.read(licenceProvider).couvre(NiveauLicence.ultra)) return false;
    final siens = await StockRepository(ref.read(appDatabaseProvider).db)
        .magasinsUtilisateur(ref.read(utilisateurCourantCodeProvider));
    return siens.any((m) => m != state.magasinCode);
  }

  /// Transfère [manque] de [source] vers le magasin de la caisse (document TRF, en UNE transaction).
  Future<String> transfererManque(ManqueStock manque, String source) async {
    final t = await ref
        .read(stockServiceProvider)
        .transferer(
          magasinSource: source,
          magasinDestination: state.magasinCode,
          lignes: [LigneStock(produitCode: manque.produit.code, quantite: manque.unites, nombre: manque.nombre)],
          commentaire: 'Caisse : stock insuffisant',
        );
    return t.code;
  }

  /// Ajoute un produit (ou un colis / pack) au panier courant, après contrôle du stock réservé.
  Future<void> ajouter(Produit produit, {Colis? colis, Pack? pack, bool nombre = false, double quantite = 1}) async {
    if (pack != null) return ajouterPack(pack, quantite: quantite);
    if (nombre) {
      await _verifierDisponibilite(produit, nombre: quantite);
      // Prix de vente HT du produit + TVA ; à la pièce : prix TTC de l'unité / pièces par unité.
      final prixUnite = ref.read(prixCaisseProvider)(produit);
      final prixPiece = produit.nombreParUnite > 0 ? prixUnite / produit.nombreParUnite : prixUnite;
      _poser(
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
    final unites = quantite * (colis?.quantite ?? 1);
    final nombreExige = produit.exigeNombre(global: ref.read(parametresVenteProvider).value?.nombreActif ?? false);
    await _verifierDisponibilite(produit, unites: unites, nombre: nombreExige ? unites * produit.nombreParUnite : 0);
    final ttc = ref.read(prixCaisseProvider);
    final prixUnite = ttc(produit);
    final remise = await ref.read(catalogueServiceProvider).remiseApplicable(produit, prixUnite);
    final remisePct = colis == null && remise > 0 && prixUnite > 0
        ? double.parse((remise / prixUnite * 100).toStringAsFixed(2))
        : 0.0;
    _poser(
      state.panier.ajouter(
        PanierLigne(
          produit: produit,
          colis: colis,
          quantite: quantite,
          prixUnitaire: colis == null ? prixUnite : ttc(produit, colis.prixVente),
          remisePct: remisePct,
          nombreExige: nombreExige,
        ),
      ),
    );
  }

  /// Ajoute [quantite] packs, éclatés en une ligne par produit (quantité dans le pack × [quantite], prix réparti :
  /// [Panier.prixComposantsPack]). Tout ou rien : si un seul produit manque de stock, aucun n'est ajouté.
  Future<void> ajouterPack(Pack pack, {double quantite = 1}) async {
    final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
    final global = ref.read(parametresVenteProvider).value?.nombreActif ?? false;
    final produits = <String, Produit>{};
    for (final c in pack.lignes) {
      final p = await catalogue.produitParCode(c.produitCode);
      if (p == null) throw PosException(ErreurPos.produitInconnu, c.produitCode);
      produits[p.code] = p;
    }
    if (produits.isEmpty) throw PosException(ErreurPos.produitInconnu, pack.code);
    final lignes = [
      for (final c in pack.lignes)
        if (c.quantite > 0) (produit: produits[c.produitCode]!, unites: c.quantite * quantite),
    ];
    for (final l in lignes) {
      final exige = l.produit.exigeNombre(global: global);
      await _verifierDisponibilite(
        l.produit,
        unites: l.unites,
        nombre: exige ? l.unites * l.produit.nombreParUnite : 0,
      );
    }
    final prix = Panier.prixComposantsPack(pack, produits);
    var panier = state.panier;
    for (final l in lignes) {
      panier = panier.ajouter(
        PanierLigne(
          produit: l.produit,
          pack: pack,
          quantite: l.unites,
          prixUnitaire: prix[l.produit.code] ?? 0,
          nombreExige: l.produit.exigeNombre(global: global),
        ),
      );
    }
    _poser(panier);
  }

  /// Ajoute [montant] à la ligne de montant libre (une seule par panier : 200 puis 500 ⇒ 700), créée au besoin
  /// sur le produit système « Vente au montant » (service, sans stock).
  Future<void> ajouterMontant(double montant) async {
    if (montant <= 0) return;
    final i = state.panier.lignes.indexWhere((l) => l.estMontant && !l.verrouillee);
    if (i >= 0) {
      final l = state.panier.lignes[i];
      _poser(state.panier.modifierLigne(i, l.copyWith(prixUnitaire: CalculsPrix.arrondir(l.prixUnitaire + montant))));
      return;
    }
    final p = await CatalogueRepository(ref.read(appDatabaseProvider).db).produitParCode(PanierLigne.codeMontant);
    if (p == null) throw const PosException(ErreurPos.produitInconnu, PanierLigne.codeMontant);
    _poser(state.panier.ajouter(PanierLigne(produit: p, quantite: 1, prixUnitaire: CalculsPrix.arrondir(montant))));
  }

  /// Remplace le montant de la ligne de montant libre ([montant] ≤ 0 la retire).
  void modifierMontant(int index, double montant) => montant <= 0
      ? retirerLigne(index)
      : _poser(
          state.panier.modifierLigne(
            index,
            state.panier.lignes[index].copyWith(prixUnitaire: CalculsPrix.arrondir(montant)),
          ),
        );

  /// Résout un code scanné : QR produit, code-barres ou code produit, colis ou pack. `null` si inconnu.
  Future<({Produit produit, Colis? colis, Pack? pack})?> resoudre(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final catalogue = CatalogueRepository(ref.read(appDatabaseProvider).db);
    final qr = CodesBarres.codeProduitDepuisQr(c);
    Produit? produit = qr != null ? await catalogue.produitParCode(qr) : await catalogue.produitParCodeBarres(c);
    produit ??= await catalogue.produitParCode(c.toUpperCase());
    if (produit != null) return produit.actif ? (produit: produit, colis: null, pack: null) : null;
    final colis = await catalogue.colisParCodeBarres(c);
    if (colis != null) {
      final p = await catalogue.produitParCode(colis.produitCode);
      return p == null ? null : (produit: p, colis: colis, pack: null);
    }
    final pack = await catalogue.packParCodeBarres(c);
    if (pack != null && pack.lignes.isNotEmpty) {
      final p = await catalogue.produitParCode(pack.lignes.first.produitCode);
      return p == null ? null : (produit: p, colis: null, pack: pack);
    }
    return null;
  }

  /// Scan direct : ajoute le produit, le colis ou le pack résolu. `false` si le code est inconnu.
  Future<bool> scanner(String code) async {
    final r = await resoudre(code);
    if (r == null) return false;
    await ajouter(r.produit, colis: r.colis, pack: r.pack);
    return true;
  }

  Future<void> modifierQuantite(int index, double quantite) async {
    final l = state.panier.lignes[index];
    if (l.verrouillee) return;
    if (l.pack != null) return _modifierPack(l, quantite);
    if (quantite > l.quantite) {
      final delta = quantite - l.quantite;
      if (l.uniteVente == UniteVente.nombre) {
        await _verifierDisponibilite(l.produit, nombre: delta);
      } else {
        final unites = delta * (l.colis?.quantite ?? 1);
        await _verifierDisponibilite(
          l.produit,
          unites: unites,
          nombre: l.nombreExige ? unites * l.produit.nombreParUnite : 0,
        );
      }
    }
    _poser(state.panier.modifierQuantite(index, quantite));
  }

  /// Les lignes d'un pack vont ensemble : la quantité saisie sur l'une est ramenée à un nombre entier de packs
  /// (arrondi vers le haut en hausse, vers le bas en baisse) appliqué à toutes ; 0 retire le pack.
  Future<void> _modifierPack(PanierLigne l, double quantite) async {
    final pack = l.pack!;
    final parPack = Panier.quantiteDansPack(pack, l.produit.code);
    if (parPack <= 0) return _poser(state.panier.modifierQuantite(state.panier.lignes.indexOf(l), quantite));
    final brut = quantite / parPack;
    final nombre = quantite > l.quantite ? brut.ceilToDouble() : brut.floorToDouble();
    for (final x in state.panier.lignes.where((x) => x.pack?.code == pack.code && !x.verrouillee)) {
      final delta = Panier.quantiteDansPack(pack, x.produit.code) * nombre - x.quantite;
      if (delta > 0) {
        await _verifierDisponibilite(
          x.produit,
          unites: delta,
          nombre: x.nombreExige ? delta * x.produit.nombreParUnite : 0,
        );
      }
    }
    _poser(state.panier.quantitePack(pack, nombre));
  }

  void retirerLigne(int index) => _poser(state.panier.retirer(index));

  void remiseLigne(int index, double pct) =>
      _poser(state.panier.modifierLigne(index, state.panier.lignes[index].copyWith(remisePct: pct.clamp(0, 100))));

  void prixLigne(int index, double prix) =>
      _poser(state.panier.modifierLigne(index, state.panier.lignes[index].copyWith(prixUnitaire: prix < 0 ? 0 : prix)));

  /// Remise globale (sauf sur une vente modifiée : ses lignes reprises ont déjà leur remise).
  void remiseGlobale(double pct) {
    if (state.panier.remplacement != null) return;
    state = state.remplacerPanier(state.panier.copyWith(remiseGlobalePct: pct.clamp(0, 100), effacerRemise: true));
  }

  /// Remise globale choisie dans le référentiel (`null` = aucune). Une remise en montant est convertie
  /// en pourcentage du sous-total (plafonnée au sous-total) et recalculée à chaque changement de lignes. Pas de
  /// remise globale sur une vente modifiée.
  void appliquerRemise(Remise? remise) {
    if (state.panier.remplacement != null) return;
    if (remise == null) {
      _remises.remove(state.panier.id);
      state = state.remplacerPanier(state.panier.copyWith(remiseGlobalePct: 0, effacerRemise: true));
      return;
    }
    _remises[state.panier.id] = remise;
    state = state.remplacerPanier(_recalculer(state.panier.copyWith(remiseCode: remise.code)));
  }

  final Map<int, Remise> _remises = {};

  void _poser(Panier p) => state = state.remplacerPanier(_recalculer(p));

  Panier _recalculer(Panier p) {
    final r = _remises[p.id];
    if (r == null || p.remiseCode != r.code) return p;
    // Remise conditionnelle (§8.9) : inactive tant que le sous-total n'atteint pas le seuil.
    if (p.sousTotal < r.seuil) return p.copyWith(remiseGlobalePct: 0);
    if (r.type == 'Pourcentage') return p.copyWith(remiseGlobalePct: r.valeur.clamp(0, 100).toDouble());
    final sous = p.sousTotal;
    final pct = sous <= 0 ? 0.0 : (r.valeur.clamp(0, sous) / sous * 100);
    return p.copyWith(remiseGlobalePct: pct.toDouble());
  }

  void choisirClient(String code) => state = state.remplacerPanier(state.panier.copyWith(clientCode: code));

  void choisirModePaiement(String mode) => state = state.remplacerPanier(state.panier.copyWith(modePaiement: mode));

  /// Paramètres du poste (caisse, magasin) jusqu'à la déconnexion.
  void parametrer({String? caisseCode, String? magasinCode}) =>
      state = state.copyWith(caisseCode: caisseCode, magasinCode: magasinCode);

  /// Remplace une ligne (changement de colis ou de quantité depuis le dialog) ; la ligne est restaurée
  /// si le stock ne suffit pas.
  Future<void> remplacerLigne(
    int index,
    Produit produit, {
    Colis? colis,
    bool nombre = false,
    double quantite = 1,
  }) async {
    final avant = state.panier;
    if (avant.lignes[index].verrouillee) return;
    state = state.remplacerPanier(avant.retirer(index));
    try {
      await ajouter(produit, colis: colis, nombre: nombre, quantite: quantite);
    } on Object {
      state = state.remplacerPanier(avant);
      rethrow;
    }
  }

  // ---------------- Paiements ----------------
  void ajouterPaiement(String mode, double montant, {String? reference}) {
    if (montant <= 0) return;
    state = state.remplacerPanier(
      state.panier.ajouterPaiement(Paiement(mode: mode, montant: montant, reference: reference)),
    );
  }

  void retirerPaiement(int index) => state = state.remplacerPanier(state.panier.retirerPaiement(index));

  /// Encaisse le panier courant ; le panier est vidé et la vente mémorisée pour l'impression.
  ///
  /// [montantPaye] (dialog Encaisser du DS) remplace les paiements saisis par un paiement unique dans le mode
  /// du panier ; un trop-perçu en espèces devient la monnaie rendue. Vente modifiée : [montantPaye] est ce qui
  /// est payé en plus de ce qui l'était déjà ([Panier.dejaPaye]).
  Future<Vente> encaisser({bool creditAutorise = false, double? montantPaye, String? mode}) async {
    final session = state.session;
    if (session == null) throw const PosException(ErreurPos.sessionRequise);
    var panier = mode == null ? state.panier : state.panier.copyWith(modePaiement: mode);
    if (montantPaye != null) {
      final mode = panier.modePaiement;
      final m = mode == 'Espèces' ? montantPaye : montantPaye.clamp(0, panier.aPayer).toDouble();
      panier = panier.copyWith(
        paiements: [if (m > 0) Paiement(mode: mode, montant: m)],
      );
    }
    final v = await ref
        .read(venteServiceProvider)
        .encaisser(
          panier,
          session: session,
          magasinCode: state.magasinCode,
          creditAutorise: creditAutorise,
          depassementPlafond: ref.read(permissionProvider(Permission.depasserPlafondCredit)),
        );
    _remises.remove(panier.id);
    state = state.remplacerPanier(panier.reinitialiser()).copyWith(derniereVente: v);
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

/// Facturation conforme (factures FAC, avoirs AVO).
final factureServiceProvider = Provider<FactureService>(
  (ref) =>
      FactureService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

/// Caisses actives (ouverture de session), hors coffre.
final caissesProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(appDatabaseProvider).db.query('caisse', where: 'actif = 1 AND coffre = 0', orderBy: 'code'),
);
