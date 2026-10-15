/// Les 7 permissions d'action du rôle (§6.2, `roledetail`), vérifiées dans tous les modules.
/// L'identifiant [code] est la valeur stockée en base (jamais le libellé). L'Admin les a toutes.
enum Permission {
  voirPrixAchat('voirPrixAchat'),
  voirMarge('voirMarge'),
  modifierPrixVente('modifierPrixVente'),
  annulerOperations('annulerOperations'),
  changerCaisseMagasin('changerCaisseMagasin'),
  gererTransfertsCaisse('gererTransfertsCaisse'),
  voirStockTousMagasins('voirStockTousMagasins');

  const Permission(this.code);
  final String code;

  static Permission? parCode(String code) => values.where((p) => p.code == code).firstOrNull;
}

/// Codes des rôles créés par le seed (table `role`, §6.2). Seul l'Admin est un rôle système :
/// accès complet, non modifiable, non assignable (§15 « admin unique non assignable »).
class Roles {
  const Roles._();
  static const String admin = 'ROL0000';
  static const String caissier = 'ROL0001';
  static const String magasinier = 'ROL0002';
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
