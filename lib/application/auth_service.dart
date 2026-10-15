import 'package:sqflite_common/sqlite_api.dart';

import '../core/securite/mot_de_passe.dart';
import '../data/historique_repository.dart';
import '../data/licence_repository.dart';
import '../data/permissions_repository.dart';
import '../data/utilisateur_repository.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';

enum ErreurConnexion {
  identifiantsInvalides,
  compteInactif,
  motDePasseNonDefini,

  /// Le compte demo/demo n'est disponible qu'en mode démo.
  demoIndisponible,

  /// Application non activée : seul le compte demo/demo est accepté (§4.3).
  nonActivee,
}

class ConnexionException implements Exception {
  const ConnexionException(this.erreur);
  final ErreurConnexion erreur;
  @override
  String toString() => 'ConnexionException($erreur)';
}

enum ErreurCompte { motDePasseActuelIncorrect, identifiantPris, identifiantInvalide, motDePasseTropCourt }

class CompteException implements Exception {
  const CompteException(this.erreur);
  final ErreurCompte erreur;
  @override
  String toString() => 'CompteException($erreur)';
}

/// Connexion et gestion du compte (identifiant, mot de passe).
class AuthService {
  const AuthService(this.db, {this.hachage = const MotDePasse()});

  final Database db;
  final MotDePasse hachage;

  static const int longueurMinMotDePasse = 4;
  static final RegExp _identifiantValide = RegExp(r'^[A-Za-z0-9._-]{3,32}$');

  UtilisateurRepository get _utilisateurs => UtilisateurRepository(db);

  static bool identifiantValide(String identifiant) => _identifiantValide.hasMatch(identifiant.trim());

  /// Identifiant du compte de démonstration (demo / demo).
  static const String identifiantDemo = 'demo';

  static bool estIdentifiantDemo(String identifiant) => identifiant.trim().toLowerCase() == identifiantDemo;

  /// Vérifie identifiant + mot de passe et construit la session avec les droits du rôle.
  Future<Session> connecter(String identifiant, String motDePasse) async {
    final u = await _utilisateurs.parIdentifiant(identifiant);
    if (u == null) throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    final licence = await LicenceRepository(db).lire();
    final estDemo = estIdentifiantDemo(u.identifiant) && u.systeme;
    if (!licence.estActivee && !estDemo) throw const ConnexionException(ErreurConnexion.nonActivee);
    if (estDemo && !licence.demo) throw const ConnexionException(ErreurConnexion.demoIndisponible);
    if (!u.actif) throw const ConnexionException(ErreurConnexion.compteInactif);
    final empreinte = await _utilisateurs.empreinte(u.code);
    if (empreinte == null) throw const ConnexionException(ErreurConnexion.motDePasseNonDefini);
    if (!MotDePasse.verifier(motDePasse, empreinte)) {
      throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    }
    return _ouvrir(u, demo: licence.demo);
  }

  /// Reprend la session mémorisée par « Rester connecté » (§4.1, `tryAutoLogin`) : `null` si le compte
  /// n'existe plus, est inactif, ou si la licence ne l'autorise plus.
  Future<Session?> reprendreSession(String code) async {
    final u = await _utilisateurs.parCode(code);
    if (u == null || !u.actif) return null;
    final licence = await LicenceRepository(db).lire();
    final estDemo = estIdentifiantDemo(u.identifiant) && u.systeme;
    if (!licence.estActivee || estDemo != licence.demo) return null;
    return _ouvrir(u, demo: licence.demo);
  }

  /// Journalise la déconnexion (§4.4).
  Future<void> deconnecter(String code) =>
      HistoriqueRepository(db)
          .journaliser(utilisateurCode: code, action: 'Déconnexion', entite: 'utilisateur', entiteCode: code);

  Future<Session> _ouvrir(Utilisateur u, {required bool demo}) async {
    final maintenant = DateTime.now();
    await db.transaction((txn) async {
      await UtilisateurRepository(txn).enregistrerAcces(u.code, maintenant);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: u.code, action: 'Connexion', entite: 'utilisateur', entiteCode: u.code);
    });
    return construireSession(u, demo: demo);
  }

  Future<Session> construireSession(Utilisateur u, {required bool demo}) async {
    final perms = PermissionsRepository(db);
    final permissions = await perms.permissionsDe(u.role);
    final modules = u.role == Roles.admin ? null : await perms.modulesDe(u.role);
    return Session(utilisateur: u, permissions: permissions, modulesAutorises: modules, demo: demo);
  }

  /// Change l'identifiant de connexion (Mon compte). Le mot de passe actuel est exigé.
  Future<Utilisateur> changerIdentifiant(String code, String nouvelIdentifiant, String motDePasseActuel) async {
    final u = await _exiger(code, motDePasseActuel);
    final nouveau = nouvelIdentifiant.trim();
    if (!identifiantValide(nouveau)) throw const CompteException(ErreurCompte.identifiantInvalide);
    if (!await _utilisateurs.identifiantDisponible(nouveau, saufCode: code)) {
      throw const CompteException(ErreurCompte.identifiantPris);
    }
    await _utilisateurs.mettreAJour(code, {'identifiant': nouveau});
    return u.copyWith(identifiant: nouveau);
  }

  Future<void> changerMotDePasse(String code, String motDePasseActuel, String nouveau) async {
    await _exiger(code, motDePasseActuel);
    if (nouveau.length < longueurMinMotDePasse) throw const CompteException(ErreurCompte.motDePasseTropCourt);
    await _utilisateurs.mettreAJour(code, {'mot_de_passe': hachage.hacher(nouveau)});
  }

  /// Vérifie le mot de passe d'un utilisateur (ex. modification de prix en caisse).
  Future<bool> verifierMotDePasse(String code, String motDePasse) async {
    final empreinte = await _utilisateurs.empreinte(code);
    return empreinte != null && MotDePasse.verifier(motDePasse, empreinte);
  }

  Future<Utilisateur> _exiger(String code, String motDePasseActuel) async {
    final u = await _utilisateurs.parCode(code);
    final empreinte = await _utilisateurs.empreinte(code);
    if (u == null || empreinte == null || !MotDePasse.verifier(motDePasseActuel, empreinte)) {
      throw const CompteException(ErreurCompte.motDePasseActuelIncorrect);
    }
    return u;
  }
}
