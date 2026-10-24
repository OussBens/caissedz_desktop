import 'package:sqflite_common/sqlite_api.dart';

import '../data/archivage_repository.dart';
import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../domain/archivage.dart';
import '../domain/models/panier.dart';
import '../domain/permissions.dart';

/// Suppression des fiches (produit, pack, client, fournisseur, magasin, caisse, utilisateur, rôle) : une fiche
/// sans historique est supprimée ; une fiche référencée (ventes, achats, mouvements, versements, journal…) est
/// archivée à la place. L'archive garde la ligne en base : anciens documents, rapports et soldes ne bougent pas ;
/// la fiche disparaît des listes de gestion et des sélecteurs et peut être restaurée.
class ArchivageService {
  const ArchivageService(
    this.db, {
    required this.utilisateurCode,
    this.maxMagasins,
    this.maxCaisses,
    this.maxCaissiers,
  });

  final Database db;
  final String utilisateurCode;

  /// Places du palier de la licence (null : sans limite), vérifiées à la restauration.
  final int? maxMagasins;
  final int? maxCaisses;
  final int? maxCaissiers;

  /// Ce que [supprimer] fera de chaque fiche : suppression, archivage, ou blocage (motif).
  Future<List<IssueSuppression>> analyser(EntiteArchivable e, List<String> codes) async =>
      (await _analyser(db, e, codes)).issues;

  /// Supprime les fiches sans historique et archive les autres, en UNE transaction ; refus global si l'une est
  /// bloquée ([ArchivageException]).
  Future<({int supprimes, int archives})> supprimer(EntiteArchivable e, List<String> codes) =>
      db.transaction((txn) async {
        final (:issues, :fiches) = await _analyser(txn, e, codes);
        final bloquee = issues.where((i) => i.blocage != null).firstOrNull;
        if (bloquee != null) throw ArchivageException(bloquee.blocage!, bloquee.code);
        final repo = ArchivageRepository(txn);
        final possedees = await repo.colonnesPossedees(e);
        final historique = HistoriqueRepository(txn);
        var supprimes = 0;
        var archives = 0;
        for (final i in issues) {
          final nom = _nom(fiches[i.code]!);
          if (i.archivage) {
            await repo.archiver(e, i.code, par: utilisateurCode);
            archives++;
          } else {
            await repo.supprimer(e, i.code, possedees);
            supprimes++;
          }
          await historique.journaliser(
            utilisateurCode: utilisateurCode,
            action: i.archivage ? 'Archivage' : 'Suppression',
            entite: e.table,
            entiteCode: i.code,
            detail: nom,
          );
        }
        return (supprimes: supprimes, archives: archives);
      });

  /// Motif empêchant de restaurer chaque fiche (`null` : restaurable).
  Future<Map<String, BlocageArchivage?>> analyserRestauration(EntiteArchivable e, List<String> codes) =>
      _analyserRestauration(db, e, codes);

  /// Restaure des fiches archivées (actives à nouveau), en UNE transaction ; refus global si l'une est bloquée.
  Future<int> restaurer(EntiteArchivable e, List<String> codes) => db.transaction((txn) async {
    final blocages = await _analyserRestauration(txn, e, codes);
    for (final MapEntry(key: code, value: b) in blocages.entries) {
      if (b != null) throw ArchivageException(b, code);
    }
    final repo = ArchivageRepository(txn);
    final fiches = await repo.fiches(e, codes);
    for (final code in codes) {
      await repo.restaurer(e, code);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Restauration',
        entite: e.table,
        entiteCode: code,
        detail: _nom(fiches[code]!),
      );
    }
    return codes.length;
  });

  // ---------------------------------------------------------------- Règles

  Future<({List<IssueSuppression> issues, Map<String, Map<String, Object?>> fiches})> _analyser(
    DatabaseExecutor ex,
    EntiteArchivable e,
    List<String> codes,
  ) async {
    final repo = ArchivageRepository(ex);
    final fiches = await repo.fiches(e, codes);
    final references = await repo.codesReferences(e, codes);
    final produit = e == EntiteArchivable.produit;
    final avecStock = produit ? await repo.produitsAvecStock(codes) : const <String>{};
    final enPack = produit ? await repo.produitsEnPack(codes) : const <String>{};
    return (
      issues: [
        for (final code in codes)
          IssueSuppression(
            code: code,
            archivage: references.contains(code),
            blocage: await _blocage(ex, e, code, fiches[code], avecStock: avecStock, enPack: enPack),
          ),
      ],
      fiches: fiches,
    );
  }

  Future<BlocageArchivage?> _blocage(
    DatabaseExecutor ex,
    EntiteArchivable e,
    String code,
    Map<String, Object?>? f, {
    required Set<String> avecStock,
    required Set<String> enPack,
  }) async {
    final repo = ArchivageRepository(ex);
    if (f == null) return BlocageArchivage.inconnu;
    if (f['archive_le'] != null) return BlocageArchivage.etatInchange;
    if (f['systeme'] == 1) return BlocageArchivage.systeme;
    switch (e) {
      case EntiteArchivable.produit:
        // Produit de la vente au montant (caisse) : produit système.
        if (code == PanierLigne.codeMontant) return BlocageArchivage.systeme;
        if (avecStock.contains(code)) return BlocageArchivage.stockNonNul;
        if (enPack.contains(code)) return BlocageArchivage.dansPack;
      case EntiteArchivable.client || EntiteArchivable.fournisseur:
        final type = e == EntiteArchivable.client ? 'Client' : 'Fournisseur';
        if ((await repo.soldeTiers(type, code)).abs() >= 0.005) return BlocageArchivage.soldeNonNul;
      case EntiteArchivable.magasin:
        if (await repo.magasinPrincipal(code)) return BlocageArchivage.magasinPrincipal;
        if (await repo.magasinAvecStock(code)) return BlocageArchivage.stockNonNul;
      case EntiteArchivable.caisse:
        if (await repo.sessionOuverte(code)) return BlocageArchivage.sessionOuverte;
        if ((await CaisseRepository(ex).solde(code)).total.abs() >= 0.005) return BlocageArchivage.soldeCaisse;
      case EntiteArchivable.utilisateur:
        if (code == utilisateurCode) return BlocageArchivage.compteCourant;
      case EntiteArchivable.role:
        if (await repo.utilisateursDuRole(code) > 0) return BlocageArchivage.utilisateursRattaches;
      case EntiteArchivable.pack:
        break;
    }
    return null;
  }

  Future<Map<String, BlocageArchivage?>> _analyserRestauration(
    DatabaseExecutor ex,
    EntiteArchivable e,
    List<String> codes,
  ) async {
    final repo = ArchivageRepository(ex);
    // Places libres du palier, consommées dans l'ordre de [codes].
    var places = switch (e) {
      EntiteArchivable.magasin when maxMagasins != null => maxMagasins! - await repo.nbActifs('magasin'),
      EntiteArchivable.caisse when maxCaisses != null => maxCaisses! - await repo.nbActifs('caisse', 'coffre = 0'),
      EntiteArchivable.utilisateur when maxCaissiers != null =>
        maxCaissiers! - await repo.nbActifs('utilisateur', 'systeme = 0 AND role_code <> ?', [Roles.admin]),
      _ => null,
    };
    final fiches = await repo.fiches(e, codes);
    final r = <String, BlocageArchivage?>{};
    for (final code in codes) {
      final f = fiches[code];
      if (f == null) {
        r[code] = BlocageArchivage.inconnu;
      } else if (f['archive_le'] == null) {
        r[code] = BlocageArchivage.etatInchange;
      } else if (places != null && _comptePlace(e, f)) {
        r[code] = places > 0 ? null : BlocageArchivage.limiteLicence;
        places--;
      } else {
        r[code] = null;
      }
    }
    return r;
  }

  /// La fiche occupe-t-elle une place du palier une fois active ? (le coffre et les administrateurs non).
  static bool _comptePlace(EntiteArchivable e, Map<String, Object?> f) => switch (e) {
    EntiteArchivable.caisse => f['coffre'] != 1,
    EntiteArchivable.utilisateur => f['role_code'] != Roles.admin,
    _ => true,
  };

  /// Libellé journalisé de la fiche (désignation, nom ou identifiant).
  static String? _nom(Map<String, Object?> f) => (f['designation'] ?? f['nom'] ?? f['identifiant']) as String?;
}
