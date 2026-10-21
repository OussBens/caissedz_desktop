/// Les permissions d'action du rôle (§6.2, `roledetail`), vérifiées dans tous les modules.
/// L'identifiant [code] est la valeur stockée en base (jamais le libellé). L'Admin les a toutes.
enum Permission {
  voirPrixAchat('voirPrixAchat'),
  voirMarge('voirMarge'),
  modifierPrixVente('modifierPrixVente'),
  annulerOperations('annulerOperations'),
  changerCaisseMagasin('changerCaisseMagasin'),
  gererTransfertsCaisse('gererTransfertsCaisse'),
  voirStockTousMagasins('voirStockTousMagasins'),

  /// Vendre à crédit au-delà du plafond de crédit du client (audit M7).
  depasserPlafondCredit('depasserPlafondCredit'),

  /// Se connecter depuis l'application mobile CaisseDZ Scan (téléphone appairé au poste).
  utiliserMobile('utiliserMobile');

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

/// Paliers de licence (Desktop — Plans & Pricing). Le palier signé dans la licence BENS est
/// l'index : 0 Basic, 1 Advanced, 2 Ultra (les paliers du produit `caissedz-desktop`, dans cet ordre).
/// L'essai de 14 jours est le palier choisi à l'inscription, jusqu'à sa date de fin.
enum NiveauLicence {
  basic('Basic', 'DSK-BASIC', magasins: 1, caisses: 1, caissiers: 5),
  avance('Avancé', 'DSK-ADV', magasins: 1, caisses: 5, caissiers: 5),
  ultra('Ultra', 'DSK-ULTRA', magasins: 15, caisses: 15, caissiers: 15);

  const NiveauLicence(
    this.stocke,
    this.offre, {
    required this.magasins,
    required this.caisses,
    required this.caissiers,
  });

  final String stocke;

  /// Code de l'offre bensdsRev qui le vend.
  final String offre;

  /// Magasins, caisses (points de vente actifs, coffre non compté) et comptes caissiers du palier
  /// (l'essai a ceux du palier choisi). Desktop — Plans & Pricing : Basic 1 / 1, Advanced 1 / 5,
  /// Ultra 15 / 15 (magasins / caisses).
  final int magasins;
  final int caisses;
  final int caissiers;

  /// Transferts entre caisses : seulement avec plusieurs caisses (pas en Basic, une seule caisse).
  bool get transfertsCaisse => caisses > 1;

  static NiveauLicence? parValeur(String? v) => values.where((n) => n.stocke == v).firstOrNull;

  /// Le palier d'une licence signée (son numéro), ou null s'il est inconnu.
  static NiveauLicence? parNumero(int? n) => n != null && n >= 0 && n < values.length ? values[n] : null;

  static NiveauLicence? parOffre(String? code) => values.where((n) => n.offre == code).firstOrNull;

  bool couvre(NiveauLicence requis) => index >= requis.index;
}
