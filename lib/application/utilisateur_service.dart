import 'dart:math';

import 'package:sqflite_common/sqlite_api.dart';

import '../core/securite/mot_de_passe.dart';
import '../data/historique_repository.dart';
import '../data/permissions_repository.dart';
import '../data/stock_repository.dart';
import '../data/utilisateur_repository.dart';
import '../domain/models/utilisateur.dart';
import '../domain/permissions.dart';
import 'auth_service.dart';
import 'tiers_service.dart';

enum ErreurUtilisateur {
  utilisateurInconnu,
  identifiantInvalide,
  identifiantPris,
  motDePasseFaible,
  telephoneObligatoire,
  telephoneInvalide,
  roleInvalide,
  magasinsObligatoires,
  compteAdministrateur,
  compteCourant,
  dejaInactif,

  /// Le palier de la licence n'a plus de place pour un caissier (Desktop — Plans & Pricing).
  limiteCaissiers,
}

class UtilisateurException implements Exception {
  const UtilisateurException(this.erreur);
  final ErreurUtilisateur erreur;
  @override
  String toString() => 'UtilisateurException($erreur)';
}

/// Comptes utilisateurs (§9.12) : identifiant unique, mot de passe haché, rôle assignable (jamais Admin),
/// caisse attachée (sauf Admin), magasins ordonnés (le premier est le magasin par défaut).
class UtilisateurService {
  const UtilisateurService(
    this.db, {
    required this.utilisateurCode,
    this.hachage = const MotDePasse(),
    this.maxCaissiers,
  });

  final Database db;
  final String utilisateurCode;
  final MotDePasse hachage;

  /// Comptes actifs autres que l'administrateur permis par le palier (null : sans limite).
  final int? maxCaissiers;

  /// Comptes actifs comptés dans la limite : tous sauf l'administrateur et les comptes système.
  static Future<int> nombreCaissiers(DatabaseExecutor db) async {
    final r = await db.rawQuery(
      'SELECT COUNT(*) n FROM utilisateur WHERE actif = 1 AND systeme = 0 AND role_code <> ?',
      [Roles.admin],
    );
    return r.first['n'] as int;
  }

  Future<void> _verifierPlace(DatabaseExecutor txn) async {
    final max = maxCaissiers;
    if (max != null && await nombreCaissiers(txn) >= max) {
      throw const UtilisateurException(ErreurUtilisateur.limiteCaissiers);
    }
  }

  /// Force d'un mot de passe, de 0 à 4 (longueur ≥ 8, majuscules et minuscules, chiffre, symbole).
  static int force(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp('[A-Z]').hasMatch(p) && RegExp('[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp('[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  /// Force minimale exigée à la création d'un compte.
  static const int forceMinimale = 2;

  static bool motDePasseAcceptable(String p) =>
      p.length >= AuthService.longueurMinMotDePasse && force(p) >= forceMinimale;

  Future<String> prochainCode() => UtilisateurRepository(db).prochainCode();

  Future<List<String>> magasins(String code) => StockRepository(db).magasinsUtilisateur(code);

  Future<Utilisateur> creer({
    required String identifiant,
    required String motDePasse,
    String prenom = '',
    String nom = '',
    required String telephone,
    required String roleCode,
    String? caisseCode,
    required List<String> magasins,
    String observation = '',
  }) => db.transaction((txn) async {
    final repo = UtilisateurRepository(txn);
    await _valider(txn, identifiant: identifiant, telephone: telephone, magasins: magasins);
    if (!motDePasseAcceptable(motDePasse)) throw const UtilisateurException(ErreurUtilisateur.motDePasseFaible);
    await _validerRole(txn, roleCode, actuel: null);
    await _verifierPlace(txn);
    final code = await repo.prochainCode();
    await repo.inserer(
      Utilisateur(
        code: code,
        identifiant: identifiant.trim(),
        nom: nom.trim(),
        prenom: prenom.trim(),
        telephone: telephone.trim(),
        roleCode: roleCode,
        caisseCode: caisseCode,
        observation: observation.trim(),
        creePar: utilisateurCode,
      ),
      hachage.hacher(motDePasse),
    );
    await StockRepository(txn).definirMagasinsUtilisateur(code, magasins);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Création',
      entite: 'utilisateur',
      entiteCode: code,
      detail: identifiant.trim(),
    );
    return (await repo.parCode(code))!;
  });

  /// Modifie un compte ; [nouveauMotDePasse] vide = inchangé. Le rôle de l'Admin ne change pas.
  Future<Utilisateur> modifier(
    String code, {
    required String identifiant,
    String? nouveauMotDePasse,
    String prenom = '',
    String nom = '',
    required String telephone,
    required String roleCode,
    String? caisseCode,
    required List<String> magasins,
    String observation = '',
    bool actif = true,
  }) => db.transaction((txn) async {
    final repo = UtilisateurRepository(txn);
    final u = await repo.parCode(code);
    if (u == null) throw const UtilisateurException(ErreurUtilisateur.utilisateurInconnu);
    await _valider(txn, identifiant: identifiant, telephone: telephone, magasins: magasins, saufCode: code);
    await _validerRole(txn, roleCode, actuel: u);
    // Réactiver un compte reprend une place du palier.
    if (actif && !u.actif && !u.estAdmin) await _verifierPlace(txn);
    if (!actif && u.actif) {
      final blocage = blocageDesactivation(u);
      if (blocage != null) throw UtilisateurException(blocage);
    }
    final mdp = nouveauMotDePasse ?? '';
    if (mdp.isNotEmpty && mdp.length < AuthService.longueurMinMotDePasse) {
      throw const UtilisateurException(ErreurUtilisateur.motDePasseFaible);
    }
    await repo.mettreAJour(code, {
      'identifiant': identifiant.trim(),
      'prenom': prenom.trim(),
      'nom': nom.trim(),
      'telephone': telephone.trim(),
      'role_code': roleCode,
      'caisse_code': roleCode == Roles.admin ? null : caisseCode,
      'observation': observation.trim(),
      'actif': actif ? 1 : 0,
      'modifie_par': utilisateurCode,
      if (mdp.isNotEmpty) 'mot_de_passe': hachage.hacher(mdp),
    });
    await StockRepository(txn).definirMagasinsUtilisateur(code, magasins);
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Modification',
      entite: 'utilisateur',
      entiteCode: code,
      detail: identifiant.trim(),
    );
    return (await repo.parCode(code))!;
  });

  /// Remplace le mot de passe par un mot de passe temporaire (renvoyé pour être communiqué à l'utilisateur).
  Future<String> reinitialiserMotDePasse(String code, {Random? alea}) => db.transaction((txn) async {
    final repo = UtilisateurRepository(txn);
    final u = await repo.parCode(code);
    if (u == null) throw const UtilisateurException(ErreurUtilisateur.utilisateurInconnu);
    final r = alea ?? Random.secure();
    const lettres = 'abcdefghjkmnpqrstuvwxyz';
    const chiffres = '23456789';
    final temporaire = [
      lettres[r.nextInt(lettres.length)].toUpperCase(),
      for (var i = 0; i < 5; i++) lettres[r.nextInt(lettres.length)],
      for (var i = 0; i < 3; i++) chiffres[r.nextInt(chiffres.length)],
    ].join();
    await repo.mettreAJour(code, {'mot_de_passe': hachage.hacher(temporaire), 'modifie_par': utilisateurCode});
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Réinitialisation du mot de passe',
      entite: 'utilisateur',
      entiteCode: code,
      detail: u.identifiant,
    );
    return temporaire;
  });

  /// Motif de blocage de la désactivation, ou `null`.
  ErreurUtilisateur? blocageDesactivation(Utilisateur u) {
    if (u.systeme && u.estAdmin) return ErreurUtilisateur.compteAdministrateur;
    if (u.code == utilisateurCode) return ErreurUtilisateur.compteCourant;
    if (!u.actif) return ErreurUtilisateur.dejaInactif;
    return null;
  }

  Future<void> desactiver(List<String> codes) => db.transaction((txn) async {
    final repo = UtilisateurRepository(txn);
    for (final code in codes) {
      final u = await repo.parCode(code);
      if (u == null) throw const UtilisateurException(ErreurUtilisateur.utilisateurInconnu);
      final blocage = blocageDesactivation(u);
      if (blocage != null) throw UtilisateurException(blocage);
      await repo.mettreAJour(code, {'actif': 0, 'modifie_par': utilisateurCode});
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Désactivation',
        entite: 'utilisateur',
        entiteCode: code,
        detail: u.identifiant,
      );
    }
  });

  Future<void> _valider(
    DatabaseExecutor txn, {
    required String identifiant,
    required String telephone,
    required List<String> magasins,
    String? saufCode,
  }) async {
    if (!AuthService.identifiantValide(identifiant)) {
      throw const UtilisateurException(ErreurUtilisateur.identifiantInvalide);
    }
    if (!await UtilisateurRepository(txn).identifiantDisponible(identifiant, saufCode: saufCode)) {
      throw const UtilisateurException(ErreurUtilisateur.identifiantPris);
    }
    if (telephone.trim().isEmpty) throw const UtilisateurException(ErreurUtilisateur.telephoneObligatoire);
    if (!TiersService.telephoneValide(telephone.trim())) {
      throw const UtilisateurException(ErreurUtilisateur.telephoneInvalide);
    }
    if (magasins.isEmpty) throw const UtilisateurException(ErreurUtilisateur.magasinsObligatoires);
  }

  /// Rôle actif ; Admin seulement s'il est déjà celui du compte (admin unique, non assignable).
  Future<void> _validerRole(DatabaseExecutor txn, String roleCode, {required Utilisateur? actuel}) async {
    if (actuel != null && actuel.estAdmin) {
      if (roleCode != Roles.admin) throw const UtilisateurException(ErreurUtilisateur.roleInvalide);
      return;
    }
    final r = await PermissionsRepository(txn).role(roleCode);
    if (r == null || r.estAdmin || (!r.actif && actuel?.roleCode != roleCode)) {
      throw const UtilisateurException(ErreurUtilisateur.roleInvalide);
    }
  }
}
