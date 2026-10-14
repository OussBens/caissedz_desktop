import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/stock_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/stock.dart';
import '../domain/referentiel/referentiel.dart';

enum ErreurStock {
  quantiteInvalide,
  stockInsuffisant,
  memeMagasin,
  lignesVides,
  motifInvalide,
  magasinInactif,
  magasinSysteme,
  produitInconnu,
  statutInvalide,
}

class StockException implements Exception {
  const StockException(this.erreur, [this.detail]);
  final ErreurStock erreur;
  final String? detail;
  @override
  String toString() => 'StockException($erreur${detail == null ? '' : ', $detail'})';
}

/// Cas d'usage du stock. Le stock est TOUJOURS le journal des mouvements ;
/// chaque document (transfert, sortie, entrée…) écrit ses mouvements dans UNE transaction.
class StockService {
  const StockService(this.db, {required this.utilisateurCode, this.gardeStock = true});

  final Database db;
  final String utilisateurCode;

  /// Garde de stock : refuse toute sortie qui rendrait le stock négatif (toujours active, §8).
  final bool gardeStock;

  StockRepository get _repo => StockRepository(db);

  // ---------------- Magasins ----------------
  Future<Magasin> creerMagasin(String nom, {String adresse = ''}) async {
    if (nom.trim().isEmpty) throw ArgumentError('nom');
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final code = await repo.prochainCode('magasin', CodeGenerator.magasin);
      final m = Magasin(code: code, nom: nom.trim(), adresse: adresse.trim());
      await repo.insererMagasin(m);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'magasin',
        entiteCode: code,
        detail: m.nom,
      );
      return m;
    });
  }

  Future<void> modifierMagasin(Magasin m) async {
    if (m.systeme && !m.actif) throw const StockException(ErreurStock.magasinSysteme);
    await _repo.mettreAJourMagasin(m);
  }

  /// Magasin principal d'un utilisateur = premier de sa liste ; à défaut, le magasin système.
  Future<String> magasinPrincipal(String utilisateur) async {
    final liste = await _repo.magasinsUtilisateur(utilisateur);
    return liste.isEmpty ? CodeGenerator.systeme(CodeGenerator.magasin) : liste.first;
  }

  Future<void> definirMagasinsUtilisateur(String utilisateur, List<String> codes) =>
      db.transaction((txn) => StockRepository(txn).definirMagasinsUtilisateur(utilisateur, codes));

  // ---------------- Mouvements ----------------
  Future<void> _verifierDisponibilite(
    StockRepository repo,
    String produitCode,
    String magasinCode,
    double quantite,
    double nombre,
  ) async {
    if (!gardeStock) return;
    final n = await repo.niveau(produitCode, magasinCode);
    if (n.quantite - quantite < -1e-9 || n.nombre - nombre < -1e-9) {
      throw StockException(ErreurStock.stockInsuffisant, '$produitCode@$magasinCode : ${n.quantite} < $quantite');
    }
  }

  Future<void> _verifierProduit(Transaction txn, String produitCode) async {
    if (await CatalogueRepository(txn).produitParCode(produitCode) == null) {
      throw StockException(ErreurStock.produitInconnu, produitCode);
    }
  }

  /// Entrée manuelle (stock initial, régularisation).
  Future<MouvementStock> entrerStock({
    required String produitCode,
    required String magasinCode,
    required double quantite,
    double nombre = 0,
    String type = TypesMouvement.entree,
    String? referenceType,
    String? referenceCode,
    String? commentaire,
    DateTime? date,
  }) async {
    if (quantite <= 0 && nombre <= 0) throw const StockException(ErreurStock.quantiteInvalide);
    return db.transaction((txn) async {
      await _verifierProduit(txn, produitCode);
      final m = MouvementStock(
        date: date ?? DateTime.now(),
        produitCode: produitCode,
        magasinCode: magasinCode,
        type: type,
        quantite: quantite,
        nombre: nombre,
        referenceType: referenceType,
        referenceCode: referenceCode,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
      );
      final id = await StockRepository(txn).insererMouvement(m);
      return MouvementStock(
        id: id,
        date: m.date,
        produitCode: m.produitCode,
        magasinCode: m.magasinCode,
        type: m.type,
        quantite: m.quantite,
        nombre: m.nombre,
        referenceType: m.referenceType,
        referenceCode: m.referenceCode,
        utilisateurCode: m.utilisateurCode,
        commentaire: m.commentaire,
      );
    });
  }

  /// Inventaire : fixe le stock constaté en écrivant le mouvement d'écart.
  Future<void> inventorier({
    required String produitCode,
    required String magasinCode,
    required double quantiteConstatee,
    double? nombreConstate,
    String? commentaire,
  }) async {
    await db.transaction((txn) async {
      await _verifierProduit(txn, produitCode);
      final repo = StockRepository(txn);
      final n = await repo.niveau(produitCode, magasinCode);
      final ecartQ = quantiteConstatee - n.quantite;
      final ecartN = nombreConstate == null ? 0.0 : nombreConstate - n.nombre;
      if (ecartQ.abs() < 1e-9 && ecartN.abs() < 1e-9) return;
      await repo.insererMouvement(
        MouvementStock(
          date: DateTime.now(),
          produitCode: produitCode,
          magasinCode: magasinCode,
          type: TypesMouvement.inventaire,
          quantite: ecartQ,
          nombre: ecartN,
          utilisateurCode: utilisateurCode,
          commentaire: commentaire,
        ),
      );
    });
  }

  /// Sortie de stock liée à un document (vente, sortie…) — utilisée par les autres services dans leur transaction.
  Future<void> sortirDansTransaction(
    Transaction txn, {
    required String produitCode,
    required String magasinCode,
    required double quantite,
    double nombre = 0,
    required String type,
    String? referenceType,
    String? referenceCode,
    String? motif,
    DateTime? date,
  }) async {
    final repo = StockRepository(txn);
    await _verifierDisponibilite(repo, produitCode, magasinCode, quantite, nombre);
    await repo.insererMouvement(
      MouvementStock(
        date: date ?? DateTime.now(),
        produitCode: produitCode,
        magasinCode: magasinCode,
        type: type,
        quantite: -quantite,
        nombre: -nombre,
        referenceType: referenceType,
        referenceCode: referenceCode,
        motif: motif,
        utilisateurCode: utilisateurCode,
      ),
    );
  }

  Future<void> entrerDansTransaction(
    Transaction txn, {
    required String produitCode,
    required String magasinCode,
    required double quantite,
    double nombre = 0,
    required String type,
    String? referenceType,
    String? referenceCode,
    String? motif,
    DateTime? date,
  }) async {
    await StockRepository(txn).insererMouvement(
      MouvementStock(
        date: date ?? DateTime.now(),
        produitCode: produitCode,
        magasinCode: magasinCode,
        type: type,
        quantite: quantite,
        nombre: nombre,
        referenceType: referenceType,
        referenceCode: referenceCode,
        motif: motif,
        utilisateurCode: utilisateurCode,
      ),
    );
  }

  // ---------------- Transferts TRM ----------------
  /// Transfert = pour chaque ligne, 2 mouvements (sortie source, entrée destination), en UNE transaction.
  Future<TransfertStock> transferer({
    required String magasinSource,
    required String magasinDestination,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    if (magasinSource == magasinDestination) throw const StockException(ErreurStock.memeMagasin);
    if (lignes.isEmpty) throw const StockException(ErreurStock.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const StockException(ErreurStock.quantiteInvalide);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      for (final m in [magasinSource, magasinDestination]) {
        final mag = await repo.magasin(m);
        if (mag == null || !mag.actif) throw StockException(ErreurStock.magasinInactif, m);
      }
      final code = await repo.prochainCode('transfert_stock', CodeGenerator.transfertStock);
      final d = date ?? DateTime.now();
      final t = TransfertStock(
        code: code,
        date: d,
        magasinSource: magasinSource,
        magasinDestination: magasinDestination,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
        lignes: lignes,
      );
      await repo.insererTransfert(t);
      for (final l in lignes) {
        await _verifierProduit(txn, l.produitCode);
        await sortirDansTransaction(
          txn,
          produitCode: l.produitCode,
          magasinCode: magasinSource,
          quantite: l.quantite,
          nombre: l.nombre,
          type: TypesMouvement.transfert,
          referenceType: 'transfert',
          referenceCode: code,
          date: d,
        );
        await entrerDansTransaction(
          txn,
          produitCode: l.produitCode,
          magasinCode: magasinDestination,
          quantite: l.quantite,
          nombre: l.nombre,
          type: TypesMouvement.transfert,
          referenceType: 'transfert',
          referenceCode: code,
          date: d,
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'transfert_stock',
        entiteCode: code,
        detail: '$magasinSource → $magasinDestination',
      );
      return t;
    });
  }

  // ---------------- Sorties ----------------
  Future<SortieStock> sortir({
    required String magasinCode,
    required String motif,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    if (!Referentiel.motifsSortie.contient(motif)) throw const StockException(ErreurStock.motifInvalide);
    if (lignes.isEmpty) throw const StockException(ErreurStock.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const StockException(ErreurStock.quantiteInvalide);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final code = await repo.prochainCode('sortie_stock', CodeGenerator.sortie);
      final d = date ?? DateTime.now();
      final s = SortieStock(
        code: code,
        date: d,
        magasinCode: magasinCode,
        motif: motif,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
        lignes: lignes,
      );
      await repo.insererSortie(s);
      for (final l in lignes) {
        await _verifierProduit(txn, l.produitCode);
        await sortirDansTransaction(
          txn,
          produitCode: l.produitCode,
          magasinCode: magasinCode,
          quantite: l.quantite,
          nombre: l.nombre,
          type: TypesMouvement.sortie,
          referenceType: 'sortie',
          referenceCode: code,
          motif: motif,
          date: d,
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'sortie_stock',
        entiteCode: code,
        detail: motif,
      );
      return s;
    });
  }

  // ---------------- Besoins ----------------
  Future<Besoin> creerBesoin({
    required String produitCode,
    required double quantite,
    String? magasinCode,
    String? commentaire,
  }) async {
    if (quantite <= 0) throw const StockException(ErreurStock.quantiteInvalide);
    return db.transaction((txn) async {
      await _verifierProduit(txn, produitCode);
      final repo = StockRepository(txn);
      final code = await repo.prochainCode('besoin', CodeGenerator.besoin);
      final b = Besoin(
        code: code,
        date: DateTime.now(),
        produitCode: produitCode,
        quantite: quantite,
        magasinCode: magasinCode,
        commentaire: commentaire,
        utilisateurCode: utilisateurCode,
      );
      await repo.insererBesoin(b);
      return b;
    });
  }

  /// Transition : En attente → Commande → Disponible (ou retour arrière).
  Future<Besoin> changerStatutBesoin(String code, String statut) async {
    if (!StatutsBesoin.tous.contains(statut)) throw const StockException(ErreurStock.statutInvalide);
    final b = await _repo.besoin(code);
    if (b == null) throw StockException(ErreurStock.produitInconnu, code);
    final maj = b.copyWith(statut: statut);
    await _repo.mettreAJourBesoin(maj);
    return maj;
  }

  Future<void> supprimerBesoin(String code) => _repo.supprimerBesoin(code);

  /// Besoins automatiques : produits sous leur seuil (propre ou global) sans besoin ouvert.
  Future<List<Besoin>> genererBesoinsSousSeuil({required int seuilGlobal}) async {
    final produits = await CatalogueRepository(db).produits(actifsSeulement: true);
    final niveaux = {for (final n in await _repo.niveaux()) n.produitCode: n};
    final ouverts = (await _repo.besoins())
        .where((b) => b.statut != StatutsBesoin.disponible)
        .map((b) => b.produitCode)
        .toSet();
    final crees = <Besoin>[];
    for (final p in produits) {
      final seuil = p.seuilStock ?? seuilGlobal;
      final stock = niveaux[p.code]?.quantite ?? 0;
      if (stock <= seuil && !ouverts.contains(p.code)) {
        crees.add(
          await creerBesoin(
            produitCode: p.code,
            quantite: (seuil - stock) + seuil,
            commentaire: 'Sous seuil ($stock ≤ $seuil)',
          ),
        );
      }
    }
    return crees;
  }
}
