/// Journal d'audit (§9.17, table `historique`) : une ligne par action, écrite dans la transaction de l'action.
class EntreeHistorique {
  const EntreeHistorique({
    required this.id,
    required this.date,
    required this.utilisateurCode,
    required this.action,
    required this.entite,
    this.entiteCode,
    this.detail,
    this.poste,
  });

  final int id;
  final DateTime date;
  final String utilisateurCode;

  /// Valeur stockée FR (`Création`, `Modification`, `Annulation`, `Connexion`…), traduite à l'affichage.
  final String action;

  /// Entité technique (`produit`, `vente`, `caisse`…) ; le module affiché s'en déduit.
  final String entite;
  final String? entiteCode;
  final String? detail;

  /// Nom de la machine qui a écrit la ligne (absent avant la v19).
  final String? poste;

  /// Code affiché `H…` (§8.10, format fixe), dérivé de l'identifiant séquentiel.
  String get code => 'H${id.toString().padLeft(6, '0')}';

  String get module => ModulesHistorique.module(entite, action);

  CategorieAction get categorie => ModulesHistorique.categorie(action);

  factory EntreeHistorique.depuisLigne(Map<String, Object?> r) => EntreeHistorique(
    id: r['id'] as int,
    date: DateTime.parse(r['date'] as String).toLocal(),
    utilisateurCode: r['utilisateur_code'] as String,
    action: r['action'] as String,
    entite: r['entite'] as String,
    entiteCode: r['entite_code'] as String?,
    detail: r['detail'] as String?,
    poste: r['poste'] as String?,
  );
}

/// Familles d'actions du DS (filtre « Action », tons des badges, KPI).
enum CategorieAction { creation, modification, annulation, connexion, export }

abstract final class ModulesHistorique {
  /// Pseudo-module des connexions / déconnexions.
  static const String connexion = 'connexion';

  static const Map<String, String> _parEntite = {
    'utilisateur': 'utilisateurs',
    'role': 'utilisateurs',
    'produit': 'produits',
    'categorie': 'produits',
    'sous_categorie': 'produits',
    'remise': 'produits',
    'pack': 'produits',
    'vente': 'ventes',
    'retour': 'retours',
    'achat': 'entrees',
    'sortie_stock': 'sorties',
    'magasin': 'magasins',
    'transfert_stock': 'magasins',
    'besoin': 'besoins',
    'client': 'clients',
    'fournisseur': 'fournisseurs',
    'versement': 'versements',
    'caisse': 'gestion_caisse',
    'transfert_caisse': 'gestion_caisse',
    'session_caisse': 'gestion_caisse',
    'mouvement_caisse': 'gestion_caisse',
    'cloture': 'gestion_caisse',
    'zakat': 'zakat',
    'parametre': 'parametres',
  };

  /// Identifiant du module (§5) auquel rattacher une ligne ; l'entité brute si elle est inconnue.
  static String module(String entite, String action) =>
      action == 'Connexion' || action == 'Déconnexion' ? connexion : (_parEntite[entite] ?? entite);

  static const Map<String, CategorieAction> _parAction = {
    'Modification': CategorieAction.modification,
    'Paramètres': CategorieAction.modification,
    'Réinitialisation du mot de passe': CategorieAction.modification,
    'Annulation': CategorieAction.annulation,
    'Suppression': CategorieAction.annulation,
    'Désactivation': CategorieAction.annulation,
    'Connexion': CategorieAction.connexion,
    'Déconnexion': CategorieAction.connexion,
    'Fermeture': CategorieAction.connexion,
    'Clôture Z': CategorieAction.connexion,
    'Export': CategorieAction.export,
  };

  /// Famille d'une action ; toute autre action (création, encaissement, versement, ouverture…) est une création.
  static CategorieAction categorie(String action) => _parAction[action] ?? CategorieAction.creation;
}
