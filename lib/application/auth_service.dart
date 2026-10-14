import 'package:sqflite_common/sqlite_api.dart';

import '../core/securite/mot_de_passe.dart';
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

  /// Vérifie identifiant + mot de passe et construit la session avec les droits du rôle.
  Future<Session> connecter(String identifiant, String motDePasse) async {
    final u = await _utilisateurs.parIdentifiant(identifiant);
    if (u == null) throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    final licence = await LicenceRepository(db).lire();
    final estDemo = u.identifiant.toLowerCase() == 'demo' && u.systeme;
    if (estDemo && !licence.demo) throw const ConnexionException(ErreurConnexion.demoIndisponible);
    if (!u.actif) throw const ConnexionException(ErreurConnexion.compteInactif);
    final empreinte = await _utilisateurs.empreinte(u.code);
    if (empreinte == null) throw const ConnexionException(ErreurConnexion.motDePasseNonDefini);
    if (!MotDePasse.verifier(motDePasse, empreinte)) {
      throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    }
    return construireSession(u, demo: licence.demo);
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

  Future<Utilisateur> _exiger(String code, String motDePasseActuel) async {
    final u = await _utilisateurs.parCode(code);
    final empreinte = await _utilisateurs.empreinte(code);
    if (u == null || empreinte == null || !MotDePasse.verifier(motDePasseActuel, empreinte)) {
      throw const CompteException(ErreurCompte.motDePasseActuelIncorrect);
    }
    return u;
  }
}
