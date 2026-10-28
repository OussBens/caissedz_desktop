import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/models/vente.dart';
import 'caisse_service.dart';

enum ErreurSession { dejaOuverte, aucuneOuverte, caisseInconnue, montantInvalide }

class SessionException implements Exception {
  const SessionException(this.erreur);
  final ErreurSession erreur;
  @override
  String toString() => 'SessionException($erreur)';
}

/// Sessions de caisse : ouverture (fond initial) et fermeture (montant compté, écart).
class SessionCaisseService {
  const SessionCaisseService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  VenteRepository get _repo => VenteRepository(db);

  /// §8.4 : aucun achat, retour ni versement n'est enregistré sans session `Ouverte` accessible à l'utilisateur
  /// (la sienne ou celle de sa caisse attachée, ouverte par un collègue).
  static Future<bool> sessionOuverte(DatabaseExecutor db, String utilisateurCode) async =>
      await VenteRepository(db).sessionAccessible(utilisateurCode) != null;

  /// Session courante : celle de l'utilisateur, sinon celle de sa caisse attachée déjà ouverte par un autre
  /// utilisateur, qu'il continue (ventes, versements et fermeture sur la même session).
  Future<SessionCaisse?> courante() => _repo.sessionAccessible(utilisateurCode);

  Future<SessionCaisse> ouvrir({required String caisseCode, required double fondInitial}) async {
    if (fondInitial < 0) throw const SessionException(ErreurSession.montantInvalide);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      if (await repo.sessionAccessible(utilisateurCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      if (await repo.sessionOuverte(caisseCode: caisseCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      final caisse = await txn.query('caisse', where: 'code = ? AND actif = 1 AND coffre = 0', whereArgs: [caisseCode]);
      if (caisse.isEmpty) throw const SessionException(ErreurSession.caisseInconnue);
      final code = await repo.prochainCode('session_caisse', CodeGenerator.sessionCaisse);
      final s = SessionCaisse(
        code: code,
        caisseCode: caisseCode,
        utilisateurCode: utilisateurCode,
        ouverteLe: DateTime.now(),
        fondInitial: fondInitial,
      );
      await repo.insererSession(s);
      await CaisseService.journaliser(
        txn,
        caisseCode: caisseCode,
        type: TypesMouvementCaisse.fondInitial,
        sens: SensMouvementCaisse.entree,
        montant: fondInitial,
        referenceType: 'session_caisse',
        referenceCode: code,
        utilisateurCode: utilisateurCode,
        date: s.ouverteLe,
      );
      // Le fond de caisse est pris au coffre, dans la limite de ses espèces (le surplus est un apport externe).
      final caisses = CaisseRepository(txn);
      final coffre = await caisses.coffre();
      if (coffre != null && fondInitial > 0) {
        final dispo = (await caisses.solde(coffre)).parMode['Espèces'] ?? 0;
        final pris = CalculsPrix.arrondir(fondInitial < dispo ? fondInitial : (dispo > 0 ? dispo : 0));
        if (pris > 0) {
          await CaisseService.journaliser(
            txn,
            caisseCode: coffre,
            type: TypesMouvementCaisse.coffre,
            sens: SensMouvementCaisse.sortie,
            montant: pris,
            referenceType: 'session_caisse',
            referenceCode: code,
            utilisateurCode: utilisateurCode,
            date: s.ouverteLe,
            commentaire: 'Fond de caisse $caisseCode',
          );
        }
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Ouverture',
        entite: 'session_caisse',
        entiteCode: code,
        detail: 'fond $fondInitial',
      );
      return s;
    });
  }

  /// Historique des sessions, plus récentes d'abord.
  Future<List<SessionCaisse>> sessions() => _repo.sessions();

  /// Ferme la session courante de l'utilisateur (la sienne ou celle partagée de sa caisse), ou la session
  /// [sessionCode] (Gestion caisse).
  /// Écart = compté − espèces attendues ([especesAttendues] : grand-livre Espèces de la caisse depuis la
  /// fermeture précédente).
  Future<SessionCaisse> fermer({required double montantCompte, String? sessionCode}) async {
    if (montantCompte < 0) throw const SessionException(ErreurSession.montantInvalide);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final trouvee = sessionCode == null
          ? await repo.sessionAccessible(utilisateurCode)
          : await repo.session(sessionCode);
      final s = trouvee != null && trouvee.statut == StatutsSession.ouverte ? trouvee : null;
      if (s == null) throw const SessionException(ErreurSession.aucuneOuverte);
      final attendu = await CaisseRepository(txn).especesSession(s.caisseCode, s.code);
      final ecart = montantCompte - attendu;
      final fermeeLe = DateTime.now();
      await repo.fermerSession(s.code, fermeeLe: fermeeLe, montant: montantCompte, ecart: ecart);
      // Journal de caisse : l'écart constaté puis le retrait des espèces comptées (la caisse physique est vidée).
      await CaisseService.journaliser(
        txn,
        caisseCode: s.caisseCode,
        type: TypesMouvementCaisse.ecart,
        sens: ecart > 0 ? SensMouvementCaisse.entree : SensMouvementCaisse.sortie,
        montant: ecart.abs(),
        referenceType: 'session_caisse',
        referenceCode: s.code,
        utilisateurCode: utilisateurCode,
        date: fermeeLe,
      );
      await CaisseService.journaliser(
        txn,
        caisseCode: s.caisseCode,
        type: TypesMouvementCaisse.retrait,
        sens: SensMouvementCaisse.sortie,
        montant: montantCompte,
        referenceType: 'session_caisse',
        referenceCode: s.code,
        utilisateurCode: utilisateurCode,
        date: fermeeLe,
      );
      // Les espèces retirées vont au coffre (remise en banque ensuite par transfert vers une caisse Compte).
      final coffre = await CaisseRepository(txn).coffre();
      if (coffre != null && coffre != s.caisseCode && montantCompte > 0) {
        await CaisseService.journaliser(
          txn,
          caisseCode: coffre,
          type: TypesMouvementCaisse.coffre,
          sens: SensMouvementCaisse.entree,
          montant: montantCompte,
          referenceType: 'session_caisse',
          referenceCode: s.code,
          utilisateurCode: utilisateurCode,
          date: fermeeLe,
          commentaire: 'Fermeture ${s.caisseCode}',
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Fermeture',
        entite: 'session_caisse',
        entiteCode: s.code,
        detail: 'compté $montantCompte, écart $ecart',
      );
      return (await repo.session(s.code))!;
    });
  }

  /// Montant d'espèces attendu en caisse : fond initial et tous les mouvements d'espèces du tiroir depuis la
  /// fermeture précédente (ventes nettes de la monnaie, versements, paiements, remboursements, dépenses…).
  Future<double> especesAttendues(String sessionCode) async {
    final s = await _repo.session(sessionCode);
    if (s == null) return 0;
    return CaisseRepository(db).especesSession(s.caisseCode, s.code);
  }

  /// [especesAttendues] détaillées par type de mouvement (fond initial, ventes, versements, dépenses…).
  Future<Map<String, double>> especesAttenduesParType(String sessionCode) async {
    final s = await _repo.session(sessionCode);
    if (s == null) return const {};
    return CaisseRepository(db).especesSessionParType(s.caisseCode, s.code);
  }
}
