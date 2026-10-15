import 'referentiel/referentiel.dart';

/// Les 7 permissions d'action (§8, rôles).
///
/// ⚠️ PROVISOIRE : seule `voirPrixAchat` est nommée dans la commande ; les six
/// autres sont une hypothèse à confirmer avec la spec 06. L'identifiant [code]
/// est la valeur stockée en base (jamais le libellé).
enum Permission {
  voirPrixAchat('voirPrixAchat'),
  modifierPrix('modifierPrix'),
  appliquerRemise('appliquerRemise'),
  annulerVente('annulerVente'),
  supprimerDocument('supprimerDocument'),
  exporterDonnees('exporterDonnees'),
  gererUtilisateurs('gererUtilisateurs');

  const Permission(this.code);
  final String code;

  static Permission? parCode(String code) => values.where((p) => p.code == code).firstOrNull;
}

/// Rôles : valeurs stockées du référentiel (`Admin`, `Caissier`, `Magasinier`).
class Roles {
  const Roles._();
  static const String admin = 'Admin';
  static const String caissier = 'Caissier';
  static const String magasinier = 'Magasinier';
  static List<String> get tous => Referentiel.roles.valeurs.map((v) => v.stocke).toList();

  /// Permissions accordées par défaut (seed, modifiables par l'Admin).
  static const Map<String, Set<Permission>> permissionsParDefaut = {
    admin: {
      Permission.voirPrixAchat,
      Permission.modifierPrix,
      Permission.appliquerRemise,
      Permission.annulerVente,
      Permission.supprimerDocument,
      Permission.exporterDonnees,
      Permission.gererUtilisateurs,
    },
    caissier: {Permission.appliquerRemise},
    magasinier: {Permission.voirPrixAchat},
  };

  /// Modules accessibles par défaut (seed, modifiables par l'Admin).
  /// L'Admin accède à tout ; cette carte ne liste que les autres rôles.
  static const Map<String, Set<String>> modulesParDefaut = {
    caissier: {'tableau_bord', 'caisse', 'ventes', 'retours', 'clients', 'historique'},
    magasinier: {'tableau_bord', 'produits', 'stock', 'magasins', 'entrees', 'besoins', 'sorties', 'fournisseurs'},
  };
}

/// Niveaux de licence (valeur stockée FR du référentiel).
enum NiveauLicence {
  basic('Basic'),
  avance('Avancé');

  const NiveauLicence(this.stocke);
  final String stocke;

  static NiveauLicence? parValeur(String? v) => values.where((n) => n.stocke == v).firstOrNull;

  bool couvre(NiveauLicence requis) => index >= requis.index;
}
