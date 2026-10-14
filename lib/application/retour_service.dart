import 'package:sqflite_common/sqlite_api.dart';

import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/retour.dart';
import '../domain/models/stock.dart';
import '../domain/models/vente.dart';
import 'stock_service.dart';
import 'vente_service.dart';
import 'versement_service.dart';

enum ErreurRetour {
  venteInconnue,
  venteAnnulee,
  lignesVides,
  quantiteInvalide,
  quantiteDepasse,
  periodeCloturee,
  modeInvalide,
}

class RetourException implements Exception {
  const RetourException(this.erreur, [this.detail]);
  final ErreurRetour erreur;
  final String? detail;
  @override
  String toString() => 'RetourException($erreur)';
}

/// Ligne demandée pour un retour (produit de la vente + quantité).
class DemandeRetourLigne {
  const DemandeRetourLigne({required this.produitCode, required this.quantite});
  final String produitCode;
  final double quantite;
}

/// Retours clients : stock restitué, avoir remboursé (versement verrouillé) ou laissé en crédit.
class RetourService {
  const RetourService(this.db, {required this.utilisateurCode, this.periodeCloturee});

  final Database db;
  final String utilisateurCode;
  final VerificateurCloture? periodeCloturee;

  /// Crée un retour en UNE transaction. [rembourser] : montant rendu au client (versement verrouillé) ;
  /// le reste de l'avoir est imputé sur les documents ouverts du client, ou conservé en avance.
  Future<Retour> creer({
    required String venteCode,
    required List<DemandeRetourLigne> lignes,
    String? motif,
    double rembourser = 0,
    String modeRemboursement = 'Espèces',
    String? caisseCode,
    DateTime? date,
  }) async {
    if (lignes.isEmpty) throw const RetourException(ErreurRetour.lignesVides);
    if (lignes.any((l) => l.quantite <= 0)) throw const RetourException(ErreurRetour.quantiteInvalide);
    if (rembourser < 0) throw const RetourException(ErreurRetour.quantiteInvalide);
    return db.transaction((txn) async {
      final ventes = VenteRepository(txn);
      final v = await ventes.vente(venteCode);
      if (v == null) throw const RetourException(ErreurRetour.venteInconnue);
      if (v.statut == StatutsVente.annulee) throw const RetourException(ErreurRetour.venteAnnulee);
      if (periodeCloturee != null && await periodeCloturee!(txn, v.date)) {
        throw const RetourException(ErreurRetour.periodeCloturee);
      }
      final repo = TiersRepository(txn);
      final deja = await repo.quantitesRetournees(venteCode);
      final code = await repo.prochainCode('retour', CodeGenerator.retour);
      final d = date ?? DateTime.now();
      final stock = StockService(txn.database, utilisateurCode: utilisateurCode);
      final lignesRetour = <RetourLigne>[];
      for (final dl in lignes) {
        final vl = v.lignes.where((l) => l.produitCode == dl.produitCode && l.packCode == null).firstOrNull;
        if (vl == null) throw RetourException(ErreurRetour.quantiteDepasse, dl.produitCode);
        final vendue = vl.quantite;
        if ((deja[dl.produitCode] ?? 0) + dl.quantite > vendue + 1e-9) {
          throw RetourException(ErreurRetour.quantiteDepasse, dl.produitCode);
        }
        // Prix net unitaire effectivement payé sur la ligne.
        final prixNet = vl.quantite == 0 ? 0.0 : CalculsPrix.arrondir(vl.total / vl.quantite);
        final total = CalculsPrix.arrondir(prixNet * dl.quantite);
        lignesRetour.add(
          RetourLigne(
            produitCode: dl.produitCode,
            designation: vl.designation,
            quantite: dl.quantite,
            nombre: vl.uniteVente == 'Nombre' ? dl.quantite : 0,
            prixUnitaire: prixNet,
            total: total,
          ),
        );
        final unites = vl.uniteVente == 'Nombre'
            ? 0.0
            : dl.quantite * (vl.colisCode == null ? 1 : await _quantiteColis(txn, vl.colisCode!));
        await stock.entrerDansTransaction(
          txn,
          produitCode: dl.produitCode,
          magasinCode: v.magasinCode,
          quantite: unites,
          nombre: vl.uniteVente == 'Nombre' ? dl.quantite : 0,
          type: TypesMouvement.retour,
          referenceType: 'retour',
          referenceCode: code,
          date: d,
        );
      }
      final total = CalculsPrix.arrondir(lignesRetour.fold(0.0, (s, l) => s + l.total));
      final montantRembourse = CalculsPrix.arrondir(rembourser > total ? total : rembourser);
      var retour = Retour(
        code: code,
        date: d,
        venteCode: venteCode,
        clientCode: v.clientCode,
        magasinCode: v.magasinCode,
        utilisateurCode: utilisateurCode,
        total: total,
        rembourse: montantRembourse,
        motif: motif,
        lignes: lignesRetour,
      );
      await repo.insererRetour(retour);
      final versements = VersementService(txn.database, utilisateurCode: utilisateurCode);
      if (montantRembourse > 0) {
        final ver = await versements.rembourserRetourDansTransaction(
          txn,
          retour: retour,
          montant: montantRembourse,
          mode: modeRemboursement,
          caisseCode: caisseCode,
        );
        retour = Retour(
          code: code,
          date: d,
          venteCode: venteCode,
          clientCode: v.clientCode,
          magasinCode: v.magasinCode,
          utilisateurCode: utilisateurCode,
          total: total,
          rembourse: montantRembourse,
          motif: motif,
          versementCode: ver.code,
          lignes: lignesRetour,
        );
      }
      // Avoir non remboursé : crédit client imputé aux documents ouverts (plus ancien d'abord), sinon avance.
      final avoir = CalculsPrix.arrondir(total - montantRembourse);
      if (avoir > 0 && v.clientCode != CodeGenerator.systeme(CodeGenerator.client)) {
        final codeV = await repo.prochainCode('versement', CodeGenerator.versement);
        final docs = await repo.documentsOuvertsClient(v.clientCode);
        await repo.insererVersement(
          Versement(
            code: codeV,
            date: d,
            tiersType: TypesTiers.client,
            tiersCode: v.clientCode,
            sens: SensVersement.encaissement,
            montant: avoir,
            mode: 'Avoir',
            utilisateurCode: utilisateurCode,
            commentaire: 'Avoir $code',
            retourCode: code,
            verrouille: true,
            imputations: VersementService.repartir(codeV, avoir, docs),
          ),
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Retour',
        entite: 'retour',
        entiteCode: code,
        detail: 'vente $venteCode, total $total',
      );
      return retour;
    });
  }

  Future<double> _quantiteColis(Transaction txn, String colisCode) async {
    final rows = await txn.query('colis', columns: ['quantite'], where: 'code = ?', whereArgs: [colisCode]);
    return rows.isEmpty ? 1 : (rows.first['quantite'] as num).toDouble();
  }
}
