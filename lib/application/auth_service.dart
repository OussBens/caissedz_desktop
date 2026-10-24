import 'package:sqflite_common/sqlite_api.dart';

import '../core/db/migrations/v002_demarrage.dart';
import '../core/db/migrations/v008_shell_ds.dart';
import '../core/securite/mot_de_passe.dart';
import '../data/historique_repository.dart';
import '../data/permissions_repository.dart';
import '../data/utilisateur_repository.dart';
import '../domain/models/session.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import 'licence_service.dart';

enum ErreurConnexion {
  identifiantsInvalides,
  compteInactif,
  motDePasseNonDefini,

  /// Pas de licence valable sur ce poste (essai terminé, aucune licence) : voir les offres.
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

  /// Vérifie identifiant + mot de passe et construit la session avec les droits du rôle. La licence est
  /// vérifiée avant (SessionNotifier : pas de connexion sans licence valable sur ce poste).
  /// [telephoneCompte] : le numéro du compte BENS de ce poste ; tapé à la place de l'identifiant, il
  /// désigne l'administrateur (celui qui a créé le compte).
  Future<Session> connecter(String identifiant, String motDePasse, {String? telephoneCompte}) async {
    final u = await _utilisateurs.parIdentifiant(identifiant) ?? await _adminDuCompte(identifiant, telephoneCompte);
    if (u == null) throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    if (!u.actif) throw const ConnexionException(ErreurConnexion.compteInactif);
    final empreinte = await _utilisateurs.empreinte(u.code);
    if (empreinte == null) throw const ConnexionException(ErreurConnexion.motDePasseNonDefini);
    if (!MotDePasse.verifier(motDePasse, empreinte)) {
      throw const ConnexionException(ErreurConnexion.identifiantsInvalides);
    }
    return _ouvrir(u);
  }

  /// Reprend la session mémorisée par « Rester connecté » (§4.1, `tryAutoLogin`) : `null` si le compte
  /// n'existe plus ou est inactif (la licence est vérifiée avant, par SessionNotifier).
  Future<Session?> reprendreSession(String code) async {
    final u = await _utilisateurs.parCode(code);
    if (u == null || !u.actif) return null;
    return _ouvrir(u);
  }

  /// Les comptes proposés à l'écran de connexion (comme les « comptes récents ») : actifs, avec un
  /// mot de passe ; le dernier connecté d'abord, l'administrateur devant les autres à égalité.
  Future<List<Utilisateur>> comptesConnexion() async {
    final comptes = <Utilisateur>[];
    for (final u in await _utilisateurs.tous()) {
      if (u.actif && await _utilisateurs.empreinte(u.code) != null) comptes.add(u);
    }
    comptes.sort((a, b) {
      final da = a.dernierAcces, db = b.dernierAcces;
      if (da != db) {
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      }
      if (a.estAdmin != b.estAdmin) return a.estAdmin ? -1 : 1;
      return a.code.compareTo(b.code);
    });
    return comptes;
  }

  /// Le numéro du compte BENS tapé comme identifiant : l'administrateur (`admin` s'il l'est encore,
  /// sinon le premier administrateur actif). Null pour tout autre texte.
  Future<Utilisateur?> _adminDuCompte(String identifiant, String? telephoneCompte) async {
    if (telephoneCompte == null || !RegExp(r'\d{6}').hasMatch(identifiant.replaceAll(RegExp(r'\D'), ''))) {
      return null;
    }
    if (LicenceService.telephoneE164(identifiant) != telephoneCompte) return null;
    return _administrateurDuCompte();
  }

  /// L'administrateur du compte BENS : `admin` s'il l'est encore, sinon le premier administrateur actif.
  Future<Utilisateur?> _administrateurDuCompte() async {
    final admin = await _utilisateurs.parIdentifiant(MigrationV008ShellDs.identifiantAdmin);
    if (admin != null && admin.estAdmin) return admin;
    return (await _utilisateurs.tous()).where((u) => u.estAdmin && u.actif).firstOrNull;
  }

  /// Après l'inscription ou la connexion au compte BENS, que la licence soit déjà valable ou non (essai
  /// refusé, paiement attendu, clé) : sur un poste neuf, l'administrateur n'a pas encore de mot de passe
  /// et prend celui du compte (et son nom). Il se connecte ensuite avec ce compte (numéro ou `admin`).
  /// Renvoie l'administrateur mis à jour ; null s'il était déjà configuré (rien ne change).
  Future<Utilisateur?> adminPrendCompteBens({required String nom, required String motDePasse}) async {
    final u = await _utilisateurs.parCode(MigrationV002Demarrage.codeAdmin);
    if (u == null || !u.estAdmin || !u.actif || await _utilisateurs.empreinte(u.code) != null) return null;
    await _utilisateurs.mettreAJour(u.code, {
      'mot_de_passe': hachage.hacher(motDePasse),
      if (nom.trim().isNotEmpty) 'nom': nom.trim(),
    });
    return _utilisateurs.parCode(u.code);
  }

  /// Après la réinitialisation du mot de passe du compte BENS (le code de BENS prouve que c'est le
  /// gérant) : l'administrateur du compte prend le nouveau mot de passe, même déjà configuré.
  /// Null sans administrateur actif.
  Future<Utilisateur?> adminPrendMotDePasseReinitialise(String motDePasse) async {
    final u = await _administrateurDuCompte();
    if (u == null || !u.actif) return null;
    await _utilisateurs.mettreAJour(u.code, {'mot_de_passe': hachage.hacher(motDePasse)});
    return _utilisateurs.parCode(u.code);
  }

  /// Ouvre la session de [u] sans mot de passe : juste après qu'il a pris celui du compte BENS.
  Future<Session> ouvrirSans(Utilisateur u) => _ouvrir(u);

  /// Journalise la déconnexion (§4.4).
  Future<void> deconnecter(String code) => db.transaction((txn) async {
    await UtilisateurRepository(txn).definirAuditContexte(null);
    await HistoriqueRepository(txn)
        .journaliser(utilisateurCode: code, action: 'Déconnexion', entite: 'utilisateur', entiteCode: code);
  });

  Future<Session> _ouvrir(Utilisateur u) async {
    final maintenant = DateTime.now();
    await db.transaction((txn) async {
      await UtilisateurRepository(txn).enregistrerAcces(u.code, maintenant);
      await UtilisateurRepository(txn).definirAuditContexte(u.code);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: u.code, action: 'Connexion', entite: 'utilisateur', entiteCode: u.code);
    });
    return construireSession(u);
  }

  Future<Session> construireSession(Utilisateur u) async {
    final perms = PermissionsRepository(db);
    final permissions = u.estAdmin ? Permission.values.toSet() : await perms.permissionsDe(u.roleCode);
    final modules = u.estAdmin ? null : await perms.modulesDe(u.roleCode);
    return Session(utilisateur: u, permissions: permissions, modulesAutorises: modules);
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
