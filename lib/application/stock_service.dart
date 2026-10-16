import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../data/stock_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/parametres_vente.dart';
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
  nomPris,
  magasinPrincipal,
  stockNonNul,
  dejaAnnule,
  documentInconnu,
  motifObligatoire,
  fournisseurObligatoire,
  besoinRecu,
  aucunChangement,
  nombreObligatoire,
  sortieRetour,
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
  Future<Magasin> creerMagasin(
    String nom, {
    String adresse = '',
    String telephone = '',
    String? responsableCode,
    String observation = '',
  }) async {
    if (nom.trim().isEmpty) throw ArgumentError('nom');
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      if (await repo.nomMagasinPris(nom)) throw const StockException(ErreurStock.nomPris);
      final code = await repo.prochainCode('magasin', CodeGenerator.magasin);
      final m = Magasin(
        code: code,
        nom: nom.trim(),
        adresse: adresse.trim(),
        telephone: telephone.trim(),
        responsableCode: responsableCode,
        observation: observation.trim(),
      );
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

  Future<void> modifierMagasin(Magasin m) => db.transaction((txn) async {
    final repo = StockRepository(txn);
    final avant = await repo.magasin(m.code);
    if (avant == null) throw StockException(ErreurStock.documentInconnu, m.code);
    if (m.nom.trim().isEmpty) throw ArgumentError('nom');
    if (await repo.nomMagasinPris(m.nom, sauf: m.code)) throw const StockException(ErreurStock.nomPris);
    if (avant.actif && !m.actif) await _verifierDesactivable(repo, avant);
    await repo.mettreAJourMagasin(m.copyWith(nom: m.nom.trim()));
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Modification',
      entite: 'magasin',
      entiteCode: m.code,
      detail: m.nom.trim(),
    );
  });

  /// Motif de blocage d'une désactivation : magasin système, principal d'un utilisateur, stock non nul.
  Future<ErreurStock?> blocageDesactivation(Magasin m) async {
    try {
      await _verifierDesactivable(_repo, m);
      return null;
    } on StockException catch (e) {
      return e.erreur;
    }
  }

  Future<void> _verifierDesactivable(StockRepository repo, Magasin m) async {
    if (m.systeme) throw const StockException(ErreurStock.magasinSysteme);
    if ((await repo.utilisateursPrincipal(m.code)).isNotEmpty) throw const StockException(ErreurStock.magasinPrincipal);
    final stocks = await repo.stocksParMagasin();
    if (stocks.values.any((parMagasin) => (parMagasin[m.code] ?? 0).abs() > 1e-9)) {
      throw const StockException(ErreurStock.stockNonNul);
    }
  }

  /// Active ou désactive des magasins, en UNE transaction (chacun est vérifié).
  Future<void> changerEtatMagasins(List<String> codes, {required bool actif}) => db.transaction((txn) async {
    final repo = StockRepository(txn);
    for (final code in codes) {
      final m = await repo.magasin(code);
      if (m == null || m.actif == actif) continue;
      if (!actif) await _verifierDesactivable(repo, m);
      await repo.mettreAJourMagasin(m.copyWith(actif: actif));
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: actif ? 'Activation' : 'Désactivation',
        entite: 'magasin',
        entiteCode: code,
        detail: m.nom,
      );
    }
  });

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

  /// Produit existant ; si [nombre] est fourni, le 2ᵉ stock « nombre » est exigé (> 0) quand il est actif (§8.1).
  Future<void> _verifierProduit(Transaction txn, String produitCode, {double? nombre}) async {
    final p = await CatalogueRepository(txn).produitParCode(produitCode);
    if (p == null) throw StockException(ErreurStock.produitInconnu, produitCode);
    if (nombre != null && nombre <= 0 && p.exigeNombre(global: await nombreGlobalActif(txn))) {
      throw StockException(ErreurStock.nombreObligatoire, produitCode);
    }
  }

  /// Nombre à contrôler pour une ligne qui sort de [magasin] : `null` (non exigé) quand il ne reste plus de pièces,
  /// pour que la quantité restante puisse sortir seule.
  Future<double?> _nombreExigible(StockRepository repo, LigneStock l, String magasin) async =>
      (await repo.niveau(l.produitCode, magasin)).nombre > 1e-9 ? l.nombre : null;

  /// Paramètres › Nombre et quantité : 2ᵉ stock « nombre » exigé pour tous les produits.
  static Future<bool> nombreGlobalActif(DatabaseExecutor db) async =>
      await ParametreRepository(db).lire(ParametresVente.cleNombre) == '1';

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
      await _verifierProduit(txn, produitCode, nombre: nombre);
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

  /// Inventaire d'un magasin (document INV, audit m8) : un mouvement d'écart par produit compté (unités et
  /// pièces du 2ᵉ stock), dans UNE transaction. L'écart se calcule sur le théorique figé au début du comptage
  /// ([theoriques] / [theoriquesNombre], lus à l'ouverture de l'écran) : une vente faite pendant le comptage
  /// n'est pas effacée. Sans théorique figé, le stock actuel sert de théorique. Un produit absent d'une des
  /// deux listes garde son théorique pour cette grandeur. Retourne le code INV (null sans écart) et le nombre
  /// de produits ajustés.
  Future<({String? code, int ajustes})> inventorierLot({
    required String magasinCode,
    required Map<String, double> quantitesConstatees,
    Map<String, double> nombresConstates = const {},
    Map<String, double> theoriques = const {},
    Map<String, double> theoriquesNombre = const {},
    DateTime? debutComptage,
    String? commentaire,
  }) => db.transaction((txn) async {
    final repo = StockRepository(txn);
    final maintenant = DateTime.now();
    final lignes = <Map<String, Object?>>[];
    for (final produitCode in {...quantitesConstatees.keys, ...nombresConstates.keys}) {
      await _verifierProduit(txn, produitCode);
      final niveau = await repo.niveau(produitCode, magasinCode);
      final theoQ = theoriques[produitCode] ?? niveau.quantite;
      final theoN = theoriquesNombre[produitCode] ?? niveau.nombre;
      final constQ = quantitesConstatees[produitCode] ?? theoQ;
      final constN = nombresConstates[produitCode] ?? theoN;
      final ecart = constQ - theoQ;
      final ecartNombre = constN - theoN;
      if (ecart.abs() < 1e-9 && ecartNombre.abs() < 1e-9) continue;
      lignes.add({
        'produit_code': produitCode,
        'theorique': theoQ,
        'constate': constQ,
        'ecart': ecart,
        'theorique_nombre': theoN,
        'constate_nombre': constN,
        'ecart_nombre': ecartNombre,
      });
    }
    if (lignes.isEmpty) return (code: null, ajustes: 0);
    final code = await repo.prochainCode('inventaire', CodeGenerator.inventaire);
    await repo.insererInventaire({
      'code': code,
      'date': maintenant.toUtc().toIso8601String(),
      'debut_comptage': (debutComptage ?? maintenant).toUtc().toIso8601String(),
      'magasin_code': magasinCode,
      'utilisateur_code': utilisateurCode,
      'commentaire': commentaire,
    }, lignes);
    for (final l in lignes) {
      await repo.insererMouvement(
        MouvementStock(
          date: maintenant,
          produitCode: l['produit_code']! as String,
          magasinCode: magasinCode,
          type: TypesMouvement.inventaire,
          quantite: l['ecart']! as double,
          nombre: l['ecart_nombre']! as double,
          referenceType: 'inventaire',
          referenceCode: code,
          utilisateurCode: utilisateurCode,
          commentaire: commentaire,
        ),
      );
    }
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Inventaire',
      entite: 'inventaire',
      entiteCode: code,
      detail: '$magasinCode · ${lignes.length} produits ajustés',
    );
    return (code: code, ajustes: lignes.length);
  });

  /// Annule un inventaire (motif obligatoire) : contre-mouvements des écarts, document marqué « Annulé ».
  Future<void> annulerInventaire(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const StockException(ErreurStock.motifObligatoire);
    await db.transaction((txn) async {
      final repo = StockRepository(txn);
      final inv = await repo.inventaire(code);
      if (inv == null) throw const StockException(ErreurStock.documentInconnu);
      if (inv['statut'] == 'Annulé') throw const StockException(ErreurStock.dejaAnnule);
      final maintenant = DateTime.now();
      for (final l in await repo.lignesInventaire(code)) {
        await repo.insererMouvement(
          MouvementStock(
            date: maintenant,
            produitCode: l['produit_code']! as String,
            magasinCode: inv['magasin_code']! as String,
            type: TypesMouvement.inventaire,
            quantite: -(l['ecart']! as num).toDouble(),
            nombre: -(l['ecart_nombre']! as num).toDouble(),
            referenceType: 'inventaire',
            referenceCode: code,
            utilisateurCode: utilisateurCode,
            commentaire: 'Annulation $code : ${motif.trim()}',
          ),
        );
      }
      await repo.annulerInventaire(code, par: utilisateurCode, motif: motif.trim(), le: maintenant);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'inventaire',
        entiteCode: code,
        detail: motif.trim(),
      );
    });
  }

  /// Un service (dont le produit système « Vente au montant ») ne passe jamais par le journal de stock.
  static Future<bool> _estService(DatabaseExecutor db, String produitCode) async {
    final r = await db.query('produit', columns: ['service'], where: 'code = ?', whereArgs: [produitCode]);
    return r.isNotEmpty && (r.first['service'] as int? ?? 0) == 1;
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
    if (await _estService(txn, produitCode)) return;
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
    if (await _estService(txn, produitCode)) return;
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

  /// Défait les mouvements d'un document : mouvements inverses du net passé par produit et par magasin.
  Future<void> defaireDansTransaction(
    Transaction txn,
    String referenceType,
    String code,
    String type, {
    String? motif,
  }) async {
    final net = await txn.rawQuery(
      '''
      SELECT produit_code p, magasin_code m, SUM(quantite) q, SUM(nombre) n FROM mouvement_stock
      WHERE reference_type = ? AND reference_code = ? GROUP BY produit_code, magasin_code
      ''',
      [referenceType, code],
    );
    // Les retours en stock d'abord : une sortie inverse peut dépendre d'une entrée inverse du même document.
    final tries = [...net]..sort((a, b) => (a['q']! as num).compareTo(b['q']! as num));
    for (final m in tries) {
      final q = (m['q']! as num).toDouble();
      final n = (m['n']! as num).toDouble();
      if (q.abs() < 1e-9 && n.abs() < 1e-9) continue;
      if (q < 0 || n < 0) {
        await entrerDansTransaction(
          txn,
          produitCode: m['p']! as String,
          magasinCode: m['m']! as String,
          quantite: -q,
          nombre: -n,
          type: type,
          referenceType: referenceType,
          referenceCode: code,
          motif: motif,
        );
      } else {
        await sortirDansTransaction(
          txn,
          produitCode: m['p']! as String,
          magasinCode: m['m']! as String,
          quantite: q,
          nombre: n,
          type: type,
          referenceType: referenceType,
          referenceCode: code,
          motif: motif,
        );
      }
    }
  }

  // ---------------- Transferts TRM ----------------
  void _validerTransfert(String source, String destination, List<LigneStock> lignes) {
    if (source == destination) throw const StockException(ErreurStock.memeMagasin);
    if (lignes.isEmpty) throw const StockException(ErreurStock.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const StockException(ErreurStock.quantiteInvalide);
  }

  /// Mouvements d'un transfert : pour chaque ligne, sortie de la source puis entrée dans la destination.
  Future<void> _mouvementsTransfert(Transaction txn, TransfertStock t) async {
    final repo = StockRepository(txn);
    for (final m in [t.magasinSource, t.magasinDestination]) {
      final mag = await repo.magasin(m);
      if (mag == null || !mag.actif) throw StockException(ErreurStock.magasinInactif, m);
    }
    for (final l in t.lignes) {
      await _verifierProduit(txn, l.produitCode, nombre: await _nombreExigible(repo, l, t.magasinSource));
      await sortirDansTransaction(
        txn,
        produitCode: l.produitCode,
        magasinCode: t.magasinSource,
        quantite: l.quantite,
        nombre: l.nombre,
        type: TypesMouvement.transfert,
        referenceType: 'transfert',
        referenceCode: t.code,
        date: t.date,
      );
      await entrerDansTransaction(
        txn,
        produitCode: l.produitCode,
        magasinCode: t.magasinDestination,
        quantite: l.quantite,
        nombre: l.nombre,
        type: TypesMouvement.transfert,
        referenceType: 'transfert',
        referenceCode: t.code,
        date: t.date,
      );
    }
  }

  Future<TransfertStock> _creerTransfert(
    Transaction txn, {
    required String magasinSource,
    required String magasinDestination,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    final repo = StockRepository(txn);
    final code = await repo.prochainCode('transfert_stock', CodeGenerator.transfertStock);
    final t = TransfertStock(
      code: code,
      date: date ?? DateTime.now(),
      magasinSource: magasinSource,
      magasinDestination: magasinDestination,
      utilisateurCode: utilisateurCode,
      commentaire: commentaire,
      lignes: lignes,
    );
    await repo.insererTransfert(t);
    await _mouvementsTransfert(txn, t);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Création',
      entite: 'transfert_stock',
      entiteCode: code,
      detail: '$magasinSource → $magasinDestination',
    );
    return t;
  }

  /// Transfert = pour chaque ligne, 2 mouvements (sortie source, entrée destination), en UNE transaction.
  Future<TransfertStock> transferer({
    required String magasinSource,
    required String magasinDestination,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    _validerTransfert(magasinSource, magasinDestination, lignes);
    return db.transaction(
      (txn) => _creerTransfert(
        txn,
        magasinSource: magasinSource,
        magasinDestination: magasinDestination,
        lignes: lignes,
        commentaire: commentaire,
        date: date,
      ),
    );
  }

  Future<TransfertStock> _transfertActif(StockRepository repo, String code) async {
    final t = await repo.transfert(code);
    if (t == null) throw StockException(ErreurStock.documentInconnu, code);
    if (!t.actif) throw const StockException(ErreurStock.dejaAnnule);
    return t;
  }

  /// Modification : les mouvements du transfert sont défaits puis réécrits (§8.3), en UNE transaction.
  Future<TransfertStock> modifierTransfert(
    String code, {
    required String magasinSource,
    required String magasinDestination,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    _validerTransfert(magasinSource, magasinDestination, lignes);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final avant = await _transfertActif(repo, code);
      await defaireDansTransaction(txn, 'transfert', code, TypesMouvement.transfert, motif: 'Modification');
      final t = TransfertStock(
        code: code,
        date: date ?? avant.date,
        magasinSource: magasinSource,
        magasinDestination: magasinDestination,
        utilisateurCode: avant.utilisateurCode,
        commentaire: commentaire,
        lignes: lignes,
      );
      await repo.remplacerTransfert(t);
      await _mouvementsTransfert(txn, t);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'transfert_stock',
        entiteCode: code,
        detail: '$magasinSource → $magasinDestination',
      );
      return t;
    });
  }

  /// Annulation douce avec motif : chaque magasin récupère ce qui en est sorti.
  Future<void> annulerTransferts(List<String> codes, {required String motif}) async {
    if (motif.trim().isEmpty) throw const StockException(ErreurStock.motifObligatoire);
    await db.transaction((txn) async {
      final repo = StockRepository(txn);
      for (final code in codes) {
        await _transfertActif(repo, code);
        await defaireDansTransaction(txn, 'transfert', code, TypesMouvement.transfert, motif: motif.trim());
        await repo.annulerDocument('transfert_stock', code, par: utilisateurCode, motif: motif.trim());
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Annulation',
          entite: 'transfert_stock',
          entiteCode: code,
          detail: motif.trim(),
        );
      }
    });
  }

  /// Distribution (licence Avancé) : répartit le stock d'un produit entre les magasins, total conservé.
  /// Les écarts sont soldés par des transferts (magasin excédentaire → magasin déficitaire), en UNE transaction.
  Future<List<TransfertStock>> distribuer(String produitCode, {required Map<String, double> cible, String? motif}) =>
      db.transaction((txn) async {
        final repo = StockRepository(txn);
        final actuel = {for (final n in await repo.repartition(produitCode)) n.magasinCode: n.quantite};
        final codes = {...actuel.keys, ...cible.keys};
        final total = actuel.values.fold(0.0, (a, b) => a + b);
        final totalCible = cible.values.fold(0.0, (a, b) => a + b);
        if ((total - totalCible).abs() > 1e-6) throw const StockException(ErreurStock.quantiteInvalide);
        final surplus = <String, double>{};
        final deficit = <String, double>{};
        for (final c in codes) {
          final ecart = (actuel[c] ?? 0) - (cible[c] ?? 0);
          if (ecart > 1e-9) surplus[c] = ecart;
          if (ecart < -1e-9) deficit[c] = -ecart;
        }
        if (surplus.isEmpty) throw const StockException(ErreurStock.aucunChangement);
        final crees = <TransfertStock>[];
        for (final s in surplus.keys) {
          for (final d in deficit.keys) {
            final q = surplus[s]! < deficit[d]! ? surplus[s]! : deficit[d]!;
            if (q <= 1e-9) continue;
            crees.add(
              await _creerTransfert(
                txn,
                magasinSource: s,
                magasinDestination: d,
                lignes: [LigneStock(produitCode: produitCode, quantite: q)],
                commentaire: motif?.trim().isEmpty ?? true ? null : motif!.trim(),
              ),
            );
            surplus[s] = surplus[s]! - q;
            deficit[d] = deficit[d]! - q;
          }
        }
        return crees;
      });

  // ---------------- Sorties ----------------
  void _validerSortie(String motif, List<LigneStock> lignes) {
    if (!Referentiel.motifsSortie.contient(motif)) throw const StockException(ErreurStock.motifInvalide);
    if (lignes.isEmpty) throw const StockException(ErreurStock.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const StockException(ErreurStock.quantiteInvalide);
  }

  /// Lignes valorisées au prix d'achat du produit quand aucun prix n'est fourni.
  Future<List<LigneStock>> _valoriser(Transaction txn, List<LigneStock> lignes) async {
    final catalogue = CatalogueRepository(txn);
    return [
      for (final l in lignes)
        if (l.prix > 0)
          l
        else
          LigneStock(
            produitCode: l.produitCode,
            quantite: l.quantite,
            nombre: l.nombre,
            prix: (await catalogue.produitParCode(l.produitCode))?.prixAchat ?? 0,
          ),
    ];
  }

  Future<void> _mouvementsSortie(Transaction txn, SortieStock s) async {
    final mag = await StockRepository(txn).magasin(s.magasinCode);
    if (mag == null || !mag.actif) throw StockException(ErreurStock.magasinInactif, s.magasinCode);
    final repo = StockRepository(txn);
    for (final l in s.lignes) {
      await _verifierProduit(txn, l.produitCode, nombre: await _nombreExigible(repo, l, s.magasinCode));
      await sortirDansTransaction(
        txn,
        produitCode: l.produitCode,
        magasinCode: s.magasinCode,
        quantite: l.quantite,
        nombre: l.nombre,
        type: TypesMouvement.sortie,
        referenceType: 'sortie',
        referenceCode: s.code,
        motif: s.motif,
        date: s.date,
      );
    }
  }

  Future<SortieStock> sortir({
    required String magasinCode,
    required String motif,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    return db.transaction(
      (txn) => creerSortieDansTransaction(
        txn,
        magasinCode: magasinCode,
        motif: motif,
        lignes: lignes,
        commentaire: commentaire,
        date: date,
      ),
    );
  }

  /// Sortie SRT dans une transaction existante (document, mouvements, journal) ; [retourCode] lie la sortie
  /// « Casse » d'un retour client non remis en stock.
  Future<SortieStock> creerSortieDansTransaction(
    Transaction txn, {
    required String magasinCode,
    required String motif,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
    String? retourCode,
  }) async {
    _validerSortie(motif, lignes);
    final repo = StockRepository(txn);
    final code = await repo.prochainCode('sortie_stock', CodeGenerator.sortie);
    final s = SortieStock(
      code: code,
      date: date ?? DateTime.now(),
      magasinCode: magasinCode,
      motif: motif,
      utilisateurCode: utilisateurCode,
      commentaire: commentaire,
      retourCode: retourCode,
      lignes: await _valoriser(txn, lignes),
    );
    await repo.insererSortie(s);
    await _mouvementsSortie(txn, s);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Création',
      entite: 'sortie_stock',
      entiteCode: code,
      detail: retourCode == null ? motif : '$motif · $retourCode',
    );
    return s;
  }

  /// Annule dans une transaction existante les sorties liées au retour [retourCode] (stock réintégré).
  Future<void> annulerSortiesRetourDansTransaction(Transaction txn, String retourCode, {required String motif}) async {
    final repo = StockRepository(txn);
    final codes = await txn.query(
      'sortie_stock',
      columns: ['code'],
      where: 'retour_code = ? AND actif = 1',
      whereArgs: [retourCode],
    );
    for (final r in codes) {
      final code = r['code']! as String;
      await defaireDansTransaction(txn, 'sortie', code, TypesMouvement.sortie, motif: motif);
      await repo.annulerDocument('sortie_stock', code, par: utilisateurCode, motif: motif);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'sortie_stock',
        entiteCode: code,
        detail: '$motif · $retourCode',
      );
    }
  }

  /// Sortie active et indépendante : une sortie liée à un retour se modifie / s'annule avec le retour.
  Future<SortieStock> _sortieActive(StockRepository repo, String code) async {
    final s = await repo.sortie(code);
    if (s == null) throw StockException(ErreurStock.documentInconnu, code);
    if (!s.actif) throw const StockException(ErreurStock.dejaAnnule);
    if (s.retourCode != null) throw StockException(ErreurStock.sortieRetour, s.retourCode);
    return s;
  }

  Future<SortieStock> modifierSortie(
    String code, {
    required String magasinCode,
    required String motif,
    required List<LigneStock> lignes,
    String? commentaire,
    DateTime? date,
  }) async {
    _validerSortie(motif, lignes);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final avant = await _sortieActive(repo, code);
      await defaireDansTransaction(txn, 'sortie', code, TypesMouvement.sortie, motif: 'Modification');
      final s = SortieStock(
        code: code,
        date: date ?? avant.date,
        magasinCode: magasinCode,
        motif: motif,
        utilisateurCode: avant.utilisateurCode,
        commentaire: commentaire,
        lignes: await _valoriser(txn, lignes),
      );
      await repo.remplacerSortie(s);
      await _mouvementsSortie(txn, s);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'sortie_stock',
        entiteCode: code,
        detail: motif,
      );
      return s;
    });
  }

  /// Annulation douce avec motif : le stock sorti est réintégré.
  Future<void> annulerSorties(List<String> codes, {required String motif}) async {
    if (motif.trim().isEmpty) throw const StockException(ErreurStock.motifObligatoire);
    await db.transaction((txn) async {
      final repo = StockRepository(txn);
      for (final code in codes) {
        await _sortieActive(repo, code);
        await defaireDansTransaction(txn, 'sortie', code, TypesMouvement.sortie, motif: motif.trim());
        await repo.annulerDocument('sortie_stock', code, par: utilisateurCode, motif: motif.trim());
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Annulation',
          entite: 'sortie_stock',
          entiteCode: code,
          detail: motif.trim(),
        );
      }
    });
  }

  // ---------------- Listes de besoins BL ----------------
  /// Quantité suggérée pour un produit sous le seuil : de quoi remonter au seuil [maximum] (`parametre.maximum`)
  /// quand il est renseigné et supérieur au seuil, sinon à 2 × seuil (au moins 1).
  static double suggestion(double stock, int seuil, {int maximum = 0}) {
    final s = (maximum > seuil ? maximum : 2 * seuil) - stock;
    return s < 1 ? 1 : s;
  }

  void _validerBesoin(String fournisseurCode, List<LigneStock> lignes) {
    if (fournisseurCode.isEmpty) throw const StockException(ErreurStock.fournisseurObligatoire);
    if (lignes.isEmpty) throw const StockException(ErreurStock.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 || l.prix < 0)) throw const StockException(ErreurStock.quantiteInvalide);
  }

  Future<Besoin> creerBesoin({
    required String fournisseurCode,
    required List<LigneStock> lignes,
    DateTime? date,
    DateTime? dateLivraison,
    String? observation,
  }) async {
    _validerBesoin(fournisseurCode, lignes);
    return db.transaction((txn) async {
      for (final l in lignes) {
        await _verifierProduit(txn, l.produitCode);
      }
      final repo = StockRepository(txn);
      final code = await repo.prochainCode('besoin', CodeGenerator.besoin);
      final b = Besoin(
        code: code,
        date: date ?? DateTime.now(),
        fournisseurCode: fournisseurCode,
        dateLivraison: dateLivraison,
        observation: observation,
        utilisateurCode: utilisateurCode,
        lignes: lignes,
      );
      await repo.insererBesoin(b);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'besoin',
        entiteCode: code,
        detail: fournisseurCode,
      );
      return b;
    });
  }

  Future<Besoin> _besoinModifiable(StockRepository repo, String code) async {
    final b = await repo.besoin(code);
    if (b == null) throw StockException(ErreurStock.documentInconnu, code);
    if (!b.actif) throw const StockException(ErreurStock.dejaAnnule);
    if (b.statut == StatutsBesoin.disponible) throw const StockException(ErreurStock.besoinRecu);
    return b;
  }

  Future<Besoin> modifierBesoin(
    String code, {
    required String fournisseurCode,
    required List<LigneStock> lignes,
    DateTime? date,
    DateTime? dateLivraison,
    String? observation,
  }) async {
    _validerBesoin(fournisseurCode, lignes);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final avant = await _besoinModifiable(repo, code);
      final b = Besoin(
        code: code,
        date: date ?? avant.date,
        fournisseurCode: fournisseurCode,
        statut: avant.statut,
        dateLivraison: dateLivraison,
        observation: observation,
        utilisateurCode: avant.utilisateurCode,
        lignes: lignes,
      );
      await repo.remplacerBesoin(b);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'besoin',
        entiteCode: code,
        detail: fournisseurCode,
      );
      return b;
    });
  }

  /// Transition : En Attente → Commande → Disponible (reçue en entrée).
  Future<Besoin> changerStatutBesoin(String code, String statut) async {
    if (!StatutsBesoin.tous.contains(statut)) throw const StockException(ErreurStock.statutInvalide);
    return db.transaction((txn) async {
      final repo = StockRepository(txn);
      final b = await repo.besoin(code);
      if (b == null) throw StockException(ErreurStock.documentInconnu, code);
      if (!b.actif) throw const StockException(ErreurStock.dejaAnnule);
      await repo.changerStatutBesoin(code, statut);
      return b.copyWith(statut: statut);
    });
  }

  /// Annulation douce des listes (une liste déjà reçue en entrée ne s'annule pas).
  Future<void> annulerBesoins(List<String> codes, {String motif = ''}) => db.transaction((txn) async {
    final repo = StockRepository(txn);
    for (final code in codes) {
      await _besoinModifiable(repo, code);
      await repo.annulerDocument('besoin', code, par: utilisateurCode, motif: motif.trim());
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'besoin',
        entiteCode: code,
        detail: motif.trim(),
      );
    }
  });
}
