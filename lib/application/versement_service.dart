import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/models/retour.dart';
import '../domain/referentiel/referentiel.dart';

import 'caisse_service.dart';

enum ErreurVersement { montantInvalide, modeInvalide, tiersSysteme, verrouille, inconnu, tiersInvalide }

class VersementException implements Exception {
  const VersementException(this.erreur);
  final ErreurVersement erreur;
  @override
  String toString() => 'VersementException($erreur)';
}

/// Versements des tiers, imputés automatiquement aux documents ouverts (plus ancien d'abord).
class VersementService {
  const VersementService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  /// Répartit [montant] sur les documents ouverts dans l'ordre (plus ancien d'abord).
  static List<Imputation> repartir(String versementCode, double montant, List<DocumentOuvert> docs) {
    final imputations = <Imputation>[];
    var reste = montant;
    for (final d in docs) {
      if (reste <= 0.0001) break;
      final m = CalculsPrix.arrondir(reste < d.reste ? reste : d.reste);
      if (m <= 0) continue;
      imputations.add(Imputation(versementCode: versementCode, documentType: d.type, documentCode: d.code, montant: m));
      reste = CalculsPrix.arrondir(reste - m);
    }
    return imputations;
  }

  /// Enregistre un versement et ses imputations dans UNE transaction.
  Future<Versement> imputer({
    required String tiersType,
    required String tiersCode,
    required double montant,
    required String mode,
    String? caisseCode,
    String? reference,
    String? commentaire,
    DateTime? date,
    String? sens,
  }) async {
    if (montant <= 0) throw const VersementException(ErreurVersement.montantInvalide);
    if (!Referentiel.modesPaiement.contient(mode) || mode == 'Points') {
      throw const VersementException(ErreurVersement.modeInvalide);
    }
    if (tiersType != TypesTiers.client && tiersType != TypesTiers.fournisseur) {
      throw const VersementException(ErreurVersement.tiersInvalide);
    }
    if (tiersCode == CodeGenerator.systeme(CodeGenerator.client) ||
        tiersCode == CodeGenerator.systeme(CodeGenerator.fournisseur)) {
      throw const VersementException(ErreurVersement.tiersSysteme);
    }
    final s = sens ?? (tiersType == TypesTiers.client ? SensVersement.encaissement : SensVersement.decaissement);
    return db.transaction((txn) async {
      final repo = TiersRepository(txn);
      final code = await repo.prochainCode('versement', CodeGenerator.versement);
      final docs = tiersType == TypesTiers.client
          ? await repo.documentsOuvertsClient(tiersCode)
          : await repo.documentsOuvertsFournisseur(tiersCode);
      final imputations = repartir(code, montant, docs);
      final caisse = caisseCode ?? await CaisseRepository(txn).caisseParDefaut(utilisateurCode);
      final v = Versement(
        code: code,
        date: date ?? DateTime.now(),
        tiersType: tiersType,
        tiersCode: tiersCode,
        sens: s,
        montant: CalculsPrix.arrondir(montant),
        mode: mode,
        utilisateurCode: utilisateurCode,
        caisseCode: caisse,
        reference: reference,
        commentaire: commentaire,
        imputations: imputations,
      );
      await repo.insererVersement(v);
      await journaliserVersement(txn, v);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Versement',
        entite: 'versement',
        entiteCode: code,
        detail: '$tiersType $tiersCode $montant',
      );
      return v;
    });
  }

  /// Versement de remboursement lié à un retour : créé verrouillé, non modifiable ni supprimable.
  Future<Versement> rembourserRetourDansTransaction(
    Transaction txn, {
    required Retour retour,
    required double montant,
    required String mode,
    String? caisseCode,
  }) async {
    final repo = TiersRepository(txn);
    final code = await repo.prochainCode('versement', CodeGenerator.versement);
    final v = Versement(
      code: code,
      date: retour.date,
      tiersType: TypesTiers.client,
      tiersCode: retour.clientCode,
      sens: SensVersement.decaissement,
      montant: CalculsPrix.arrondir(montant),
      mode: mode,
      utilisateurCode: utilisateurCode,
      caisseCode: caisseCode ?? await CaisseRepository(txn).caisseParDefaut(utilisateurCode),
      commentaire: 'Remboursement ${retour.code}',
      retourCode: retour.code,
      verrouille: true,
    );
    await repo.insererVersement(v);
    await repo.lierVersementRetour(retour.code, code);
    await journaliserVersement(txn, v, type: TypesMouvementCaisse.remboursement);
    return v;
  }

  /// Suppression refusée pour un versement verrouillé (lié à un retour).
  Future<void> supprimer(String code) async {
    await db.transaction((txn) async {
      final repo = TiersRepository(txn);
      final v = await repo.versement(code);
      if (v == null) throw const VersementException(ErreurVersement.inconnu);
      if (v.verrouille) throw const VersementException(ErreurVersement.verrouille);
      await repo.supprimerVersement(code);
      await CaisseRepository(txn).supprimerMouvementsReference('versement', code);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Suppression', entite: 'versement', entiteCode: code);
    });
  }

  /// Journal de caisse : entrée (encaissement) ou sortie (décaissement) sur la caisse du versement.
  static Future<void> journaliserVersement(Transaction txn, Versement v, {String? type}) async {
    if (v.mode == 'Avoir' || v.mode == 'Points' || v.caisseCode == null) return;
    final encaissement = v.sens == SensVersement.encaissement;
    await CaisseService.journaliser(
      txn,
      caisseCode: v.caisseCode!,
      type: type ?? (encaissement ? TypesMouvementCaisse.encaissement : TypesMouvementCaisse.decaissement),
      sens: encaissement ? SensMouvementCaisse.entree : SensMouvementCaisse.sortie,
      montant: v.montant,
      mode: v.mode,
      referenceType: 'versement',
      referenceCode: v.code,
      utilisateurCode: v.utilisateurCode,
      commentaire: v.commentaire,
      date: v.date,
    );
  }
}
