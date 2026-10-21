import 'dart:convert';

import 'package:http/http.dart' as http;

import 'license_config.dart';

/// Ce qui peut empêcher une opération du compte BENS.
enum ErreurCompteBens {
  /// Pas d'internet, serveur injoignable ou trop lent.
  reseau,

  /// Numéro ou mot de passe incorrect (`bad_login`).
  identifiants,

  /// Ce numéro a déjà un compte (`taken`).
  numeroPris,

  /// Aucun compte avec ce numéro (`no_account`).
  aucunCompte,

  /// Code de réinitialisation faux ou expiré (`bad_code`).
  codeInvalide,

  /// Trop d'essais : réessayer plus tard (`too_many`).
  tropDEssais,

  /// Déconnecté du compte (un autre poste s'y est connecté, ou le mot de passe a été réinitialisé).
  deconnecte,

  /// Saisie refusée par le serveur (numéro, nom, mot de passe trop court…), voir [CompteBensException.champ].
  saisie,

  /// Autre erreur du serveur.
  serveur,
}

class CompteBensException implements Exception {
  const CompteBensException(this.erreur, {this.champ, this.message});

  final ErreurCompteBens erreur;

  /// Pour [ErreurCompteBens.saisie] : `phone`, `name`, `password`, `offer`…
  final String? champ;

  /// Message du serveur (anglais), pour le journal.
  final String? message;

  @override
  String toString() => 'CompteBensException($erreur${champ == null ? '' : ', $champ'})';
}

/// Le compte BENS du client (téléphone + mot de passe) sur l'API bens_ds (docs/rev.md → Accounts with
/// a password). Les réponses sont celles du check-in : code du poste, clé signée, droits, essai, offres.
class CompteBensApi {
  CompteBensApi({required this.client, this.baseUrl = bensApiUrl, this.produit = licenseSlug});

  final http.Client client;
  final String baseUrl;
  final String produit;

  static const Duration _delai = Duration(seconds: 20);

  Uri _uri(String chemin) => Uri.parse('$baseUrl/app/$produit/$chemin');

  Map<String, String> _entetes(String? jeton) => {
    'Content-Type': 'application/json',
    'X-Requested-With': 'bens',
    if (jeton != null) 'Authorization': 'Bearer $jeton',
  };

  Future<Map<String, Object?>> _envoyer(
    String methode,
    String chemin, {
    Map<String, Object?>? corps,
    String? jeton,
  }) async {
    final http.Response r;
    try {
      r =
          await (methode == 'GET'
                  ? client.get(_uri(chemin), headers: _entetes(jeton))
                  : client.post(_uri(chemin), headers: _entetes(jeton), body: jsonEncode(corps ?? const {})))
              .timeout(_delai);
    } on Object catch (e) {
      throw CompteBensException(ErreurCompteBens.reseau, message: '$e');
    }
    Map<String, Object?> j;
    try {
      j = (jsonDecode(utf8.decode(r.bodyBytes)) as Map).cast<String, Object?>();
    } on Object {
      j = const {};
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return j;
    final code = j['error'] as String? ?? '';
    final message = j['message'] as String?;
    throw CompteBensException(
      switch ((r.statusCode, code)) {
        (401, 'bad_login') => ErreurCompteBens.identifiants,
        (401, _) => ErreurCompteBens.deconnecte,
        (409, 'taken') => ErreurCompteBens.numeroPris,
        (404, 'no_account') => ErreurCompteBens.aucunCompte,
        (400, 'bad_code') => ErreurCompteBens.codeInvalide,
        (429, _) => ErreurCompteBens.tropDEssais,
        (400, _) => ErreurCompteBens.saisie,
        _ => ErreurCompteBens.serveur,
      },
      champ: code.startsWith('bad_') ? code.substring(4) : null,
      message: message,
    );
  }

  /// Les offres en vente et la durée de l'essai, sans compte : `{trialDays, offers}`.
  Future<Map<String, Object?>> offres() => _envoyer('GET', 'offers');

  /// Inscription avec l'offre choisie (son essai commence) : `{token, trialGiven, device, key, entitlements, trial, offers}`.
  Future<Map<String, Object?>> inscrire({
    required String telephone,
    required String nom,
    required String commerce,
    required String motDePasse,
    required String poste,
    required String offre,
    required String version,
  }) => _envoyer(
    'POST',
    'register',
    corps: {
      'phone': telephone,
      'name': nom,
      'business': commerce,
      'password': motDePasse,
      'device': poste,
      'offer': offre,
      'platform': 'windows',
      'version': version,
    },
  );

  /// Connexion sur ce poste (le compte y est déplacé s'il était sur un autre) : `{token, …check-in}`.
  Future<Map<String, Object?>> connecter({
    required String telephone,
    required String motDePasse,
    required String poste,
    required String version,
  }) => _envoyer(
    'POST',
    'login',
    corps: {'phone': telephone, 'password': motDePasse, 'device': poste, 'platform': 'windows', 'version': version},
  );

  /// Au lancement, connecté : la licence de ce poste, les droits, l'essai, les offres.
  Future<Map<String, Object?>> checkIn(String jeton, {required String version}) =>
      _envoyer('POST', 'check-in', corps: {'platform': 'windows', 'version': version}, jeton: jeton);

  /// Déconnexion de ce poste (la session seulement).
  Future<void> deconnecter(String jeton) => _envoyer('POST', 'forget', jeton: jeton);

  /// Mot de passe oublié : le code de récupération (`RC-XXXX-XXXX`) à envoyer à BENS.
  Future<String> demanderRecuperation({required String telephone, required String poste}) async =>
      (await _envoyer('POST', 'recover', corps: {'phone': telephone, 'device': poste}))['code'] as String;

  /// Le code de réinitialisation reçu de BENS et le nouveau mot de passe : connecté comme [connecter].
  Future<Map<String, Object?>> reinitialiser({
    required String telephone,
    required String code,
    required String motDePasse,
    required String poste,
    required String version,
  }) => _envoyer(
    'POST',
    'reset',
    corps: {
      'phone': telephone,
      'code': code,
      'password': motDePasse,
      'device': poste,
      'platform': 'windows',
      'version': version,
    },
  );

  /// Rayons du catalogue choisis à l'accueil et produits téléchargés (tableau de bord BENS › Catalogue) :
  /// `rayons` = `[{code, name, available, downloaded}]`.
  Future<void> envoyerChoixCatalogue(String jeton, List<Map<String, Object?>> rayons) =>
      _envoyer('POST', 'catalog-choice', corps: {'rayons': rayons}, jeton: jeton);

  /// Demande d'achat d'une offre (BENS rappelle) : `{ok, already}`.
  Future<bool> demanderOffre(String jeton, String offre) async =>
      (await _envoyer('POST', 'request', corps: {'offer': offre}, jeton: jeton))['already'] == true;
}
