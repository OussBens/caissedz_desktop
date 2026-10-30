import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../data/permissions_repository.dart';
import '../data/utilisateur_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/models/vente.dart';
import '../domain/permissions.dart';
import 'caisse_service.dart';

enum ErreurSession {
  dejaOuverte,
  aucuneOuverte,
  caisseInconnue,
  montantInvalide,

  /// La caisse n'est pas parmi celles de l'utilisateur (`utilisateur_caisse`).
  caisseNonAutorisee,
}

class SessionException implements Exception {
  const SessionException(this.erreur);
  final ErreurSession erreur;
  @override
  String toString() => 'SessionException($erreur)';
}

/// Sessions de caisse : ouverture (fond initial) et fermeture (montant compté, écart).
class SessionCaisseService {
  const SessionCaisseService(this.db, {required this.utilisateurCode, this.avecCoffre = true});

  final Database db;
  final String utilisateurCode;

  /// Le coffre fournit le fond et reçoit les espèces de la fermeture ; sans coffre (Basic, une seule caisse), le
  /// fond est un apport et les espèces retirées quittent la caisse ([NiveauLicence.avecCoffre]).
  final bool avecCoffre;

  VenteRepository get _repo => VenteRepository(db);

  /// §8.4 : aucun achat, retour ni versement n'est enregistré sans session `Ouverte` accessible à l'utilisateur
  /// (la sienne ou celle de sa caisse courante, ouverte par un collègue).
  static Future<bool> sessionOuverte(DatabaseExecutor db, String utilisateurCode) async =>
      await VenteRepository(db).sessionAccessible(utilisateurCode) != null;

  /// Session courante : celle de l'utilisateur, sinon celle de sa caisse courante déjà ouverte par un autre
  /// utilisateur, qu'il continue (ventes, versements et fermeture sur la même session).
  Future<SessionCaisse?> courante() => _repo.sessionAccessible(utilisateurCode);

  /// Caisses où [utilisateurCode] peut encaisser (actives, hors coffre), sa caisse par défaut en premier : toutes
  /// pour l'Admin et la permission `changerCaisseMagasin` (les siennes d'abord), sinon les siennes
  /// (`utilisateur_caisse`).
  static Future<List<String>> caissesAccessibles(DatabaseExecutor db, String utilisateurCode) async {
    final u = await UtilisateurRepository(db).parCode(utilisateurCode);
    if (u == null) return const [];
    final caisses = CaisseRepository(db);
    final actives = [
      for (final c in await caisses.caisses(actives: true))
        if (!c.coffre) c.code,
    ];
    final siennes = [
      for (final c in await caisses.caissesUtilisateur(utilisateurCode))
        if (actives.contains(c)) c,
    ];
    final role = await PermissionsRepository(db).role(u.roleCode);
    if (!u.estAdmin && !(role?.aPermission(Permission.changerCaisseMagasin) ?? false)) return siennes;
    return [
      ...siennes,
      for (final c in actives)
        if (!siennes.contains(c)) c,
    ];
  }

  Future<List<String>> caisses() => caissesAccessibles(db, utilisateurCode);

  /// Caisse choisie dans l'écran Caisse (la dernière choisie si elle est toujours accessible, sinon la caisse par
  /// défaut), ou `null` sans caisse accessible.
  Future<String?> caisseCourante() async {
    final accessibles = await caisses();
    final courante = await CaisseRepository(db).caisseCourante(utilisateurCode);
    return accessibles.contains(courante) ? courante : accessibles.firstOrNull;
  }

  /// Choisit la caisse où l'utilisateur encaisse et décaisse, parmi les siennes : il continue la session qu'un
  /// collègue y a ouverte, sinon il l'ouvrira. Impossible tant que sa propre session est ouverte sur une autre
  /// caisse. Retourne la session désormais courante.
  Future<SessionCaisse?> choisirCaisse(String caisseCode) => db.transaction((txn) async {
    if (!(await caissesAccessibles(txn, utilisateurCode)).contains(caisseCode)) {
      throw const SessionException(ErreurSession.caisseNonAutorisee);
    }
    final repo = VenteRepository(txn);
    final sienne = await repo.sessionOuverte(utilisateurCode: utilisateurCode);
    if (sienne != null && sienne.caisseCode != caisseCode) throw const SessionException(ErreurSession.dejaOuverte);
    await CaisseRepository(txn).definirCaisseCourante(utilisateurCode, caisseCode);
    return repo.sessionAccessible(utilisateurCode);
  });

  /// Ouvre une session sur [caisseCode], qui devient la caisse courante de l'utilisateur. Une seule session
  /// ouverte par utilisateur et par caisse ; la caisse doit être parmi les siennes ([caissesAccessibles]).
  Future<SessionCaisse> ouvrir({required String caisseCode, required double fondInitial}) async {
    if (fondInitial < 0) throw const SessionException(ErreurSession.montantInvalide);
    return db.transaction((txn) async {
      final repo = VenteRepository(txn);
      final caisse = await txn.query('caisse', where: 'code = ? AND actif = 1 AND coffre = 0', whereArgs: [caisseCode]);
      if (caisse.isEmpty) throw const SessionException(ErreurSession.caisseInconnue);
      if (!(await caissesAccessibles(txn, utilisateurCode)).contains(caisseCode)) {
        throw const SessionException(ErreurSession.caisseNonAutorisee);
      }
      if (await repo.sessionOuverte(utilisateurCode: utilisateurCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      if (await repo.sessionOuverte(caisseCode: caisseCode) != null) {
        throw const SessionException(ErreurSession.dejaOuverte);
      }
      await CaisseRepository(txn).definirCaisseCourante(utilisateurCode, caisseCode);
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
      final coffre = avecCoffre ? await caisses.coffre() : null;
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
      final coffre = avecCoffre ? await CaisseRepository(txn).coffre() : null;
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
