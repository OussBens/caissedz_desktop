import 'package:sqflite_common/sqlite_api.dart';

import '../data/historique_repository.dart';
import '../data/vente_repository.dart';
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

  Future<SessionCaisse?> courante() => _repo.sessionOuverte(utilisateurCode: utilisateurCode);

  Future<SessionCaisse> ouvrir({required String caisseCode, required double fondInitial}) async {
    if (fondInitial < 0) throw const SessionException(ErreurSession.montantInvalide);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      if (await repo.sessionOuverte(utilisateurCode: utilisateurCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      if (await repo.sessionOuverte(caisseCode: caisseCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      final caisse = await txn.query('caisse', where: 'code = ? AND actif = 1', whereArgs: [caisseCode]);
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

  /// Ferme la session ouverte de l'utilisateur, ou la session [sessionCode] (Gestion caisse).
  /// Écart = compté − (fond + espèces encaissées − monnaie rendue).
  Future<SessionCaisse> fermer({required double montantCompte, String? sessionCode}) async {
    if (montantCompte < 0) throw const SessionException(ErreurSession.montantInvalide);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final trouvee = sessionCode == null
          ? await repo.sessionOuverte(utilisateurCode: utilisateurCode)
          : await repo.session(sessionCode);
      final s = trouvee != null && trouvee.statut == StatutsSession.ouverte ? trouvee : null;
      if (s == null) throw const SessionException(ErreurSession.aucuneOuverte);
      final especes = (await repo.encaissementsSession(s.code))['Espèces'] ?? 0;
      final attendu = s.fondInitial + especes - await repo.monnaieRendueSession(s.code);
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

  /// Montant d'espèces attendu en caisse (fond + espèces encaissées).
  Future<double> especesAttendues(String sessionCode) async {
    final s = await _repo.session(sessionCode);
    if (s == null) return 0;
    return s.fondInitial +
        ((await _repo.encaissementsSession(sessionCode))['Espèces'] ?? 0) -
        await _repo.monnaieRendueSession(sessionCode);
  }
}
