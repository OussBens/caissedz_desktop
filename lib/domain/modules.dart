import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/i18n/generated/app_localizations.dart';
import 'permissions.dart';

/// Groupes de la barre latérale (DS v2.2 : Général, Stock, Tiers, Gestion).
enum GroupeModule { general, stock, tiers, gestion }

/// Déclaration d'un module de l'application.
@immutable
class ModuleApp {
  const ModuleApp({
    required this.id,
    required this.groupe,
    required this.icone,
    required this.route,
    required this.libelle,
    this.niveauRequis = NiveauLicence.basic,
    this.parentId,
    this.badgeTexte,
  });

  /// Identifiant stable (stocké en base pour les favoris et les accès des rôles : relation par code).
  final String id;
  final GroupeModule groupe;
  final IconData icone;
  final String route;
  final String Function(AppLocalizations l10n) libelle;

  /// Niveau de licence nécessaire (§6.1 : seul le multi-magasin est réservé au palier Avancé).
  final NiveauLicence niveauRequis;

  /// Page rattachée à un module : l'accès du rôle est celui du module parent.
  final String? parentId;

  /// Étiquette de la barre latérale (« IA » sur Entrées).
  final String? badgeTexte;

  /// Identifiant utilisé pour les droits d'accès du rôle.
  String get idAcces => parentId ?? id;

  @override
  bool operator ==(Object other) => other is ModuleApp && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// Les 17 modules du DS v2.2 (`data.v2.2.js`, `sections`) et les pages rattachées.
class Modules {
  const Modules._();

  static const int maxFavoris = 7;

  /// Module ouvert après la connexion (§4.5).
  static const String accueil = 'caisse';

  static final List<ModuleApp> tous = [
    // Général
    ModuleApp(
      id: 'tableau_bord',
      groupe: GroupeModule.general,
      icone: LucideIcons.layoutDashboard,
      route: '/tableau-de-bord',
      libelle: (l) => l.moduleTableauBord,
    ),
    ModuleApp(
      id: 'caisse',
      groupe: GroupeModule.general,
      icone: LucideIcons.monitorSmartphone,
      route: '/caisse',
      libelle: (l) => l.moduleCaisse,
    ),
    ModuleApp(
      id: 'ventes',
      groupe: GroupeModule.general,
      icone: LucideIcons.receiptText,
      route: '/ventes',
      libelle: (l) => l.moduleVentes,
    ),
    ModuleApp(
      id: 'documents',
      groupe: GroupeModule.general,
      icone: LucideIcons.fileText,
      route: '/documents',
      libelle: (l) => l.moduleDocuments,
    ),
    ModuleApp(
      id: 'retours',
      groupe: GroupeModule.general,
      icone: LucideIcons.undo2,
      route: '/retours',
      libelle: (l) => l.moduleRetours,
    ),
    // Stock
    ModuleApp(
      id: 'produits',
      groupe: GroupeModule.stock,
      icone: LucideIcons.package,
      route: '/produits',
      libelle: (l) => l.moduleProduits,
    ),
    ModuleApp(
      id: 'stock',
      groupe: GroupeModule.stock,
      icone: LucideIcons.boxes,
      route: '/stock',
      libelle: (l) => l.moduleStock,
    ),
    ModuleApp(
      id: 'entrees',
      groupe: GroupeModule.stock,
      icone: LucideIcons.scanLine,
      route: '/entrees',
      libelle: (l) => l.moduleEntrees,
      badgeTexte: 'IA',
    ),
    ModuleApp(
      id: 'commandes_fournisseurs',
      groupe: GroupeModule.stock,
      icone: LucideIcons.clipboardList,
      route: '/commandes-fournisseurs',
      libelle: (l) => l.moduleCommandesFournisseurs,
    ),
    ModuleApp(
      id: 'sorties',
      groupe: GroupeModule.stock,
      icone: LucideIcons.packageMinus,
      route: '/sorties',
      libelle: (l) => l.moduleSorties,
    ),
    ModuleApp(
      id: 'magasins',
      groupe: GroupeModule.stock,
      icone: LucideIcons.store,
      route: '/magasins',
      libelle: (l) => l.moduleMagasins,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'besoins',
      groupe: GroupeModule.stock,
      icone: LucideIcons.triangleAlert,
      route: '/besoins',
      libelle: (l) => l.moduleBesoins,
    ),
    // Tiers
    ModuleApp(
      id: 'clients',
      groupe: GroupeModule.tiers,
      icone: LucideIcons.users,
      route: '/clients',
      libelle: (l) => l.moduleClients,
    ),
    ModuleApp(
      id: 'fournisseurs',
      groupe: GroupeModule.tiers,
      icone: LucideIcons.truck,
      route: '/fournisseurs',
      libelle: (l) => l.moduleFournisseurs,
    ),
    // Gestion
    ModuleApp(
      id: 'gestion_caisse',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.wallet,
      route: '/gestion-caisse',
      libelle: (l) => l.moduleGestionCaisse,
    ),
    ModuleApp(
      id: 'utilisateurs',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.userCog,
      route: '/utilisateurs',
      libelle: (l) => l.moduleUtilisateurs,
    ),
    ModuleApp(
      id: 'zakat',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.handCoins,
      route: '/zakat',
      libelle: (l) => l.moduleZakat,
    ),
    ModuleApp(
      id: 'historique',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.history,
      route: '/historique',
      libelle: (l) => l.moduleHistorique,
    ),
    ModuleApp(
      id: 'parametres',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.settings,
      route: '/parametres',
      libelle: (l) => l.moduleParametres,
    ),
  ];

  /// Écrans des lots 0 à 9 hors de la liste du DS, rattachés à un module jusqu'à leur intégration
  /// en onglets (phase D) : ils n'apparaissent ni dans la barre latérale ni dans le menu des modules.
  static final List<ModuleApp> rattachees = [
    ModuleApp(
      id: 'transferts',
      parentId: 'magasins',
      groupe: GroupeModule.stock,
      icone: LucideIcons.arrowLeftRight,
      route: '/transferts',
      libelle: (l) => l.moduleTransferts,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'versements',
      parentId: 'clients',
      groupe: GroupeModule.tiers,
      icone: LucideIcons.handCoins,
      route: '/versements',
      libelle: (l) => l.moduleVersements,
    ),
    ModuleApp(
      id: 'clotures',
      parentId: 'gestion_caisse',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.lock,
      route: '/clotures',
      libelle: (l) => l.moduleClotures,
    ),
    ModuleApp(
      id: 'situation',
      parentId: 'tableau_bord',
      groupe: GroupeModule.general,
      icone: LucideIcons.chartBar,
      route: '/situation',
      libelle: (l) => l.moduleSituation,
    ),
  ];

  /// Ancien identifiant (lots 0 à 9) → module du DS, pour migrer favoris et accès des rôles.
  static const Map<String, String> anciensIdentifiants = {
    'transferts': 'magasins',
    'versements': 'clients',
    'clotures': 'gestion_caisse',
    'situation': 'tableau_bord',
  };

  static ModuleApp? parId(String id) =>
      tous.where((m) => m.id == id).firstOrNull ?? rattachees.where((m) => m.id == id).firstOrNull;

  /// Module (ou page rattachée) servi par [route].
  static ModuleApp? parRoute(String route) =>
      tous.where((m) => m.route == route).firstOrNull ?? rattachees.where((m) => m.route == route).firstOrNull;

  static List<ModuleApp> parGroupe(GroupeModule groupe) => tous.where((m) => m.groupe == groupe).toList();
}
