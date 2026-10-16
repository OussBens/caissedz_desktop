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
import 'session_caisse_service.dart';

enum ErreurVersement {
  montantInvalide,
  modeInvalide,
  tiersSysteme,
  verrouille,
  inconnu,
  tiersInvalide,
  motifObligatoire,
  dejaAnnule,
  sessionRequise,
  periodeCloturee,
}

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
    String type = TypesVersement.paiement,
    String? documentCible,
  }) async {
    _controler(tiersType: tiersType, tiersCode: tiersCode, montant: montant, mode: mode);
    return db.transaction((txn) async {
      if (!await SessionCaisseService.sessionOuverte(txn, utilisateurCode)) {
        throw const VersementException(ErreurVersement.sessionRequise);
      }
      final caisses = CaisseRepository(txn);
      final caisse = caisseCode ?? await caisses.caisseParDefaut(utilisateurCode);
      if (date != null && await caisses.periodeCloturee(date, caisseCode: caisse)) {
        throw const VersementException(ErreurVersement.periodeCloturee);
      }
      return imputerDansTransaction(
        txn,
        tiersType: tiersType,
        tiersCode: tiersCode,
        montant: montant,
        mode: mode,
        caisseCode: caisse,
        reference: reference,
        commentaire: commentaire,
        date: date,
        sens: sens,
        type: type,
        documentCible: documentCible,
      );
    });
  }

  void _controler({
    required String tiersType,
    required String tiersCode,
    required double montant,
    required String mode,
  }) {
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
  }

  /// Versement imputé (plus ancien d'abord, [documentCible] en premier) dans la transaction d'un autre service.
  Future<Versement> imputerDansTransaction(
    Transaction txn, {
    required String tiersType,
    required String tiersCode,
    required double montant,
    required String mode,
    String? caisseCode,
    String? reference,
    String? commentaire,
    DateTime? date,
    String? sens,
    String type = TypesVersement.paiement,
    String? documentCible,
  }) async {
    _controler(tiersType: tiersType, tiersCode: tiersCode, montant: montant, mode: mode);
    final s = sens ?? (tiersType == TypesTiers.client ? SensVersement.encaissement : SensVersement.decaissement);
    {
      final repo = TiersRepository(txn);
      final code = await repo.prochainCode('versement', CodeGenerator.versement);
      final retour = s != (tiersType == TypesTiers.client ? SensVersement.encaissement : SensVersement.decaissement);
      // Un versement « retour » (argent rendu) n'est imputé sur aucun document.
      final docs = retour
          ? const <DocumentOuvert>[]
          : tiersType == TypesTiers.client
          ? await repo.documentsOuvertsClient(tiersCode)
          : await repo.documentsOuvertsFournisseur(tiersCode);
      if (documentCible != null && !retour) {
        docs.sort((a, b) => (a.code == documentCible ? 0 : 1).compareTo(b.code == documentCible ? 0 : 1));
      }
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
        type: type,
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
    }
  }

  /// Annulation douce (motif obligatoire) : refusée pour un versement verrouillé (lié à un retour) ;
  /// les imputations sont libérées et le mouvement de caisse contre-passé (écriture inverse datée du jour).
  Future<void> annuler(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const VersementException(ErreurVersement.motifObligatoire);
    await db.transaction((txn) async {
      final repo = TiersRepository(txn);
      final v = await repo.versement(code);
      if (v == null) throw const VersementException(ErreurVersement.inconnu);
      if (v.verrouille) throw const VersementException(ErreurVersement.verrouille);
      if (!v.actif) throw const VersementException(ErreurVersement.dejaAnnule);
      await repo.annulerVersement(code, par: utilisateurCode, motif: motif.trim());
      await CaisseRepository(txn).contrePasserReference(
        'versement',
        code,
        utilisateurCode: utilisateurCode,
        commentaire: 'Annulation $code : ${motif.trim()}',
      );
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Annulation',
        entite: 'versement',
        entiteCode: code,
        detail: motif.trim(),
      );
    });
  }

  /// Modification d'un versement non verrouillé : montant, mode, date, caisse, type, observation.
  /// Les imputations sont recalculées (plus ancien d'abord) ; l'ancien mouvement de caisse est contre-passé
  /// puis le nouveau journalisé. Refusée si l'ancienne ou la nouvelle date est dans une période clôturée.
  Future<Versement> modifier(
    String code, {
    required double montant,
    required String mode,
    required DateTime date,
    String? caisseCode,
    String? type,
    String? commentaire,
  }) async {
    if (montant <= 0) throw const VersementException(ErreurVersement.montantInvalide);
    if (!Referentiel.modesPaiement.contient(mode) || mode == 'Points') {
      throw const VersementException(ErreurVersement.modeInvalide);
    }
    return db.transaction((txn) async {
      final repo = TiersRepository(txn);
      final ancien = await repo.versement(code);
      if (ancien == null) throw const VersementException(ErreurVersement.inconnu);
      if (ancien.verrouille) throw const VersementException(ErreurVersement.verrouille);
      if (!ancien.actif) throw const VersementException(ErreurVersement.dejaAnnule);
      final caisses = CaisseRepository(txn);
      if (await caisses.periodeCloturee(ancien.date, caisseCode: ancien.caisseCode) ||
          await caisses.periodeCloturee(date, caisseCode: caisseCode ?? ancien.caisseCode)) {
        throw const VersementException(ErreurVersement.periodeCloturee);
      }
      await txn.delete('versement_imputation', where: 'versement_code = ?', whereArgs: [code]);
      await caisses.contrePasserReference(
        'versement',
        code,
        utilisateurCode: utilisateurCode,
        commentaire: 'Modification $code',
      );
      final docs = ancien.estRetour
          ? const <DocumentOuvert>[]
          : ancien.tiersType == TypesTiers.client
          ? await repo.documentsOuvertsClient(ancien.tiersCode)
          : await repo.documentsOuvertsFournisseur(ancien.tiersCode);
      final v = Versement(
        code: code,
        date: date,
        tiersType: ancien.tiersType,
        tiersCode: ancien.tiersCode,
        sens: ancien.sens,
        montant: CalculsPrix.arrondir(montant),
        mode: mode,
        utilisateurCode: ancien.utilisateurCode,
        caisseCode: caisseCode ?? ancien.caisseCode,
        reference: ancien.reference,
        commentaire: commentaire ?? ancien.commentaire,
        type: type ?? ancien.type,
        imputations: repartir(code, montant, docs),
      );
      await repo.remplacerVersement(v);
      await journaliserVersement(txn, v);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'versement',
        entiteCode: code,
        detail: '${ancien.montant} → ${v.montant}',
      );
      return v;
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
