import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/i18n/generated/app_localizations.dart';
import 'permissions.dart';

/// Groupes de la barre latérale.
enum GroupeModule { general, stock, tiers, gestion }

/// Déclaration d'un module de l'application.
///
/// ⚠️ PROVISOIRE : la liste des 17 modules, leur ordre, leurs icônes et leur
/// groupe seront alignés sur le DS v2.2 (§9 de la spec) dès réception.
@immutable
class ModuleApp {
  const ModuleApp({
    required this.id,
    required this.groupe,
    required this.icone,
    required this.route,
    required this.libelle,
    this.niveauRequis = NiveauLicence.basic,
  });

  /// Identifiant stable (stocké en base pour les favoris : relation par code).
  final String id;
  final GroupeModule groupe;
  final IconData icone;
  final String route;
  final String Function(AppLocalizations l10n) libelle;

  /// Niveau de licence nécessaire. ⚠️ PROVISOIRE : répartition Basic/Avancé à confirmer (§8).
  final NiveauLicence niveauRequis;

  @override
  bool operator ==(Object other) => other is ModuleApp && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class Modules {
  const Modules._();

  static const int maxFavoris = 7;

  static final List<ModuleApp> tous = [
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
      icone: LucideIcons.monitor,
      route: '/caisse',
      libelle: (l) => l.moduleCaisse,
    ),
    ModuleApp(
      id: 'ventes',
      groupe: GroupeModule.general,
      icone: LucideIcons.receipt,
      route: '/ventes',
      libelle: (l) => l.moduleVentes,
    ),
    ModuleApp(
      id: 'retours',
      groupe: GroupeModule.general,
      icone: LucideIcons.undo2,
      route: '/retours',
      libelle: (l) => l.moduleRetours,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'historique',
      groupe: GroupeModule.general,
      icone: LucideIcons.history,
      route: '/historique',
      libelle: (l) => l.moduleHistorique,
    ),
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
      icone: LucideIcons.warehouse,
      route: '/stock',
      libelle: (l) => l.moduleStock,
    ),
    ModuleApp(
      id: 'entrees',
      groupe: GroupeModule.stock,
      icone: LucideIcons.packagePlus,
      route: '/entrees',
      libelle: (l) => l.moduleEntrees,
    ),
    ModuleApp(
      id: 'transferts',
      groupe: GroupeModule.stock,
      icone: LucideIcons.arrowLeftRight,
      route: '/transferts',
      libelle: (l) => l.moduleTransferts,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'besoins',
      groupe: GroupeModule.stock,
      icone: LucideIcons.clipboardList,
      route: '/besoins',
      libelle: (l) => l.moduleBesoins,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'sorties',
      groupe: GroupeModule.stock,
      icone: LucideIcons.packageMinus,
      route: '/sorties',
      libelle: (l) => l.moduleSorties,
      niveauRequis: NiveauLicence.avance,
    ),
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
    ModuleApp(
      id: 'versements',
      groupe: GroupeModule.tiers,
      icone: LucideIcons.handCoins,
      route: '/versements',
      libelle: (l) => l.moduleVersements,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'gestion_caisse',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.wallet,
      route: '/gestion-caisse',
      libelle: (l) => l.moduleGestionCaisse,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'clotures',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.lock,
      route: '/clotures',
      libelle: (l) => l.moduleClotures,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'situation',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.chartBar,
      route: '/situation',
      libelle: (l) => l.moduleSituation,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'zakat',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.heartHandshake,
      route: '/zakat',
      libelle: (l) => l.moduleZakat,
      niveauRequis: NiveauLicence.avance,
    ),
    ModuleApp(
      id: 'parametres',
      groupe: GroupeModule.gestion,
      icone: LucideIcons.settings,
      route: '/parametres',
      libelle: (l) => l.moduleParametres,
    ),
  ];

  static ModuleApp? parId(String id) => tous.where((m) => m.id == id).firstOrNull;

  static List<ModuleApp> parGroupe(GroupeModule groupe) => tous.where((m) => m.groupe == groupe).toList();
}
