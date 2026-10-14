import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/achat.dart';
import '../domain/models/retour.dart';
import '../domain/models/stock.dart';
import 'stock_service.dart';
import 'vente_service.dart';

enum ErreurAchat {
  lignesVides,
  quantiteInvalide,
  prixInvalide,
  produitInconnu,
  fournisseurInconnu,
  achatInconnu,
  dejaAnnule,
  periodeCloturee,
  stockInsuffisant,
}

class AchatException implements Exception {
  const AchatException(this.erreur, [this.detail]);
  final ErreurAchat erreur;
  final String? detail;
  @override
  String toString() => 'AchatException($erreur)';
}

/// Entrées / achats fournisseur : en UNE transaction — achat, lignes, mouvements d'entrée,
/// mise à jour du prix d'achat (et de vente si demandé), versement immédiat imputé.
class AchatService {
  const AchatService(this.db, {required this.utilisateurCode, this.periodeCloturee});

  final Database db;
  final String utilisateurCode;
  final VerificateurCloture? periodeCloturee;

  Future<Achat> enregistrer({
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeAchatLigne> lignes,
    String? reference,
    double verse = 0,
    String modePaiement = 'Espèces',
    String source = 'Manuel',
    String? commentaire,
    DateTime? date,
    bool mettreAJourPrixAchat = true,
  }) async {
    if (lignes.isEmpty) throw const AchatException(ErreurAchat.lignesVides);
    if (lignes.any((l) => l.quantite <= 0 && l.nombre <= 0)) throw const AchatException(ErreurAchat.quantiteInvalide);
    if (lignes.any((l) => l.prixAchat < 0) || verse < 0) throw const AchatException(ErreurAchat.prixInvalide);
    return db.transaction((txn) async {
      final tiers = TiersRepository(txn);
      if (await tiers.fournisseur(fournisseurCode) == null) throw const AchatException(ErreurAchat.fournisseurInconnu);
      final catalogue = CatalogueRepository(txn);
      final code = await tiers.prochainCode('achat', CodeGenerator.achat);
      final d = date ?? DateTime.now();
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      final lignesAchat = <AchatLigne>[];
      for (final l in lignes) {
        final p = await catalogue.produitParCode(l.produitCode);
        if (p == null) throw AchatException(ErreurAchat.produitInconnu, l.produitCode);
        final total = CalculsPrix.arrondir(l.prixAchat * (l.quantite > 0 ? l.quantite : 1));
        lignesAchat.add(
          AchatLigne(
            produitCode: p.code,
            designation: p.designation,
            quantite: l.quantite,
            nombre: l.nombre,
            prixAchat: l.prixAchat,
            total: total,
          ),
        );
        await stock.entrerDansTransaction(
          txn,
          produitCode: p.code,
          magasinCode: magasinCode,
          quantite: l.quantite,
          nombre: l.nombre,
          type: TypesMouvement.entree,
          referenceType: 'achat',
          referenceCode: code,
          date: d,
        );
        if (mettreAJourPrixAchat || l.nouveauPrixVente != null) {
          var maj = p;
          if (mettreAJourPrixAchat && l.prixAchat > 0) {
            maj = maj.copyWith(
              prixAchat: l.prixAchat,
              margePct: CalculsPrix.margeDepuisPrix(l.prixAchat, l.nouveauPrixVente ?? p.prixVente),
            );
          }
          if (l.nouveauPrixVente != null) {
            maj = maj.copyWith(
              prixVente: l.nouveauPrixVente,
              margePct: CalculsPrix.margeDepuisPrix(maj.prixAchat, l.nouveauPrixVente!),
            );
          }
          await catalogue.mettreAJourProduit(maj);
        }
      }
      final total = CalculsPrix.arrondir(lignesAchat.fold(0.0, (s, l) => s + l.total));
      final paye = CalculsPrix.arrondir(verse > total ? total : verse);
      await txn.insert('achat', {
        'code': code,
        'date': d.toUtc().toIso8601String(),
        'fournisseur_code': fournisseurCode,
        'magasin_code': magasinCode,
        'utilisateur_code': utilisateurCode,
        'reference': reference,
        'total': total,
        'verse': paye,
        'reste': total,
        'statut': StatutsAchat.valide,
        'source': source,
        'commentaire': commentaire,
      });
      for (final (i, l) in lignesAchat.indexed) {
        await txn.insert('achat_ligne', {
          'achat_code': code,
          'ordre': i,
          'produit_code': l.produitCode,
          'designation': l.designation,
          'quantite': l.quantite,
          'nombre': l.nombre,
          'prix_achat': l.prixAchat,
          'total': l.total,
        });
      }
      // Paiement immédiat : versement fournisseur imputé à cet achat (le reste lu = total − imputations).
      if (paye > 0 && fournisseurCode != CodeGenerator.systeme(CodeGenerator.fournisseur)) {
        final codeV = await tiers.prochainCode('versement', CodeGenerator.versement);
        await tiers.insererVersement(
          Versement(
            code: codeV,
            date: d,
            tiersType: TypesTiers.fournisseur,
            tiersCode: fournisseurCode,
            sens: SensVersement.decaissement,
            montant: paye,
            mode: modePaiement,
            utilisateurCode: utilisateurCode,
            commentaire: 'Paiement $code',
            imputations: [Imputation(versementCode: codeV, documentType: 'achat', documentCode: code, montant: paye)],
          ),
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Achat',
        entite: 'achat',
        entiteCode: code,
        detail: '$fournisseurCode $total',
      );
      return (await achat(code, txn))!;
    });
  }

  Future<Achat?> achat(String code, [DatabaseExecutor? ex]) async {
    final e = ex ?? db;
    final rows = await e.query('achat', where: 'code = ?', whereArgs: [code]);
    if (rows.isEmpty) return null;
    final lignes = (await e.query(
      'achat_ligne',
      where: 'achat_code = ?',
      whereArgs: [code],
      orderBy: 'ordre',
    )).map(AchatLigne.depuisLigne).toList();
    final r = Map<String, Object?>.of(rows.first);
    final total = (r['total'] as num).toDouble();
    r['reste'] = r['statut'] == StatutsAchat.annule
        ? 0.0
        : CalculsPrix.arrondir(total - await TiersRepository(e).imputeSur('achat', code));
    return Achat.depuisLigne(r, lignes);
  }

  Future<List<Achat>> achats({String? fournisseurCode, int limite = 500}) async {
    final rows = await db.query(
      'achat',
      where: fournisseurCode == null ? null : 'fournisseur_code = ?',
      whereArgs: fournisseurCode == null ? null : [fournisseurCode],
      orderBy: 'date DESC',
      limit: limite,
    );
    return [for (final r in rows) (await achat(r['code'] as String))!];
  }

  /// Annule un achat : sortie du stock (garde active), statut Annulé.
  Future<Achat> annuler(String code) async {
    return db.transaction((txn) async {
      final a = await achat(code, txn);
      if (a == null) throw const AchatException(ErreurAchat.achatInconnu);
      if (a.statut == StatutsAchat.annule) throw const AchatException(ErreurAchat.dejaAnnule);
      if (periodeCloturee != null && await periodeCloturee!(txn, a.date)) {
        throw const AchatException(ErreurAchat.periodeCloturee);
      }
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      try {
        for (final l in a.lignes) {
          await stock.sortirDansTransaction(
            txn,
            produitCode: l.produitCode,
            magasinCode: a.magasinCode,
            quantite: l.quantite,
            nombre: l.nombre,
            type: TypesMouvement.sortie,
            referenceType: 'annulation_achat',
            referenceCode: code,
            motif: 'Annulation',
          );
        }
      } on StockException catch (e) {
        throw AchatException(ErreurAchat.stockInsuffisant, e.detail);
      }
      await txn.update('achat', {'statut': StatutsAchat.annule, 'reste': 0}, where: 'code = ?', whereArgs: [code]);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Annulation', entite: 'achat', entiteCode: code);
      return (await achat(code, txn))!;
    });
  }
}
