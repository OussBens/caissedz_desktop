// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CaisseDZ';

  @override
  String get shellNavGeneral => 'Général';

  @override
  String get shellNavStock => 'Stock';

  @override
  String get shellNavTiers => 'Tiers';

  @override
  String get shellNavGestion => 'Gestion';

  @override
  String get shellFavoris => 'Favoris';

  @override
  String get shellFavorisVide =>
      'Aucun favori. Clic droit sur un module pour l\'ajouter.';

  @override
  String get shellFavorisMax => '7 favoris maximum';

  @override
  String get shellFavorisAjouter => 'Ajouter aux favoris';

  @override
  String get shellFavorisRetirer => 'Retirer des favoris';

  @override
  String get shellMenuModules => 'Modules';

  @override
  String get shellMenuModulesRaccourci => 'Ctrl+M';

  @override
  String get shellMenuModulesRecherche => 'Rechercher un module…';

  @override
  String get shellMenuModulesAucun => 'Aucun module ne correspond.';

  @override
  String get shellAlertes => 'Alertes';

  @override
  String get shellAlertesAucune => 'Aucune alerte';

  @override
  String get shellInternetConnecte => 'Internet : connecté';

  @override
  String get shellInternetDeconnecte => 'Internet : hors ligne';

  @override
  String get shellFenetreReduire => 'Réduire';

  @override
  String get shellFenetreAgrandir => 'Agrandir';

  @override
  String get shellFenetreRestaurer => 'Restaurer';

  @override
  String get shellFenetreFermer => 'Fermer';

  @override
  String get shellReduireSidebar => 'Réduire le menu';

  @override
  String get shellEtendreSidebar => 'Étendre le menu';

  @override
  String get shellGalerie => 'Galerie du design system';

  @override
  String modulePlaceholder(String nom) {
    return 'Module « $nom » : disponible dans un prochain lot.';
  }

  @override
  String get moduleTableauBord => 'Tableau de bord';

  @override
  String get moduleCaisse => 'Caisse';

  @override
  String get moduleVentes => 'Ventes';

  @override
  String get moduleRetours => 'Retours';

  @override
  String get moduleHistorique => 'Historique';

  @override
  String get moduleProduits => 'Produits';

  @override
  String get moduleStock => 'Stock';

  @override
  String get moduleEntrees => 'Entrées / Achats';

  @override
  String get moduleTransferts => 'Transferts';

  @override
  String get moduleBesoins => 'Besoins';

  @override
  String get moduleSorties => 'Sorties';

  @override
  String get moduleClients => 'Clients';

  @override
  String get moduleFournisseurs => 'Fournisseurs';

  @override
  String get moduleVersements => 'Versements';

  @override
  String get moduleGestionCaisse => 'Gestion caisse';

  @override
  String get moduleClotures => 'Clôtures';

  @override
  String get moduleSituation => 'Situation';

  @override
  String get moduleZakat => 'Zakat';

  @override
  String get moduleParametres => 'Paramètres';

  @override
  String get moduleMonCompte => 'Mon compte';

  @override
  String get communOk => 'OK';

  @override
  String get communAnnuler => 'Annuler';

  @override
  String get communConfirmer => 'Confirmer';

  @override
  String get communFermer => 'Fermer';

  @override
  String get communEnregistrer => 'Enregistrer';

  @override
  String get communSupprimer => 'Supprimer';

  @override
  String get communRechercher => 'Rechercher';

  @override
  String get communChargement => 'Chargement…';

  @override
  String get communAucunResultat => 'Aucun résultat';

  @override
  String get communSelectionner => 'Sélectionner';

  @override
  String get communTotal => 'Total';

  @override
  String get communColonnes => 'Colonnes';

  @override
  String get communToutSelectionner => 'Tout sélectionner';

  @override
  String get communLignesParPage => 'Lignes par page';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin sur $total';
  }

  @override
  String get communPagePrecedente => 'Page précédente';

  @override
  String get communPageSuivante => 'Page suivante';

  @override
  String communSelectionnes(int n) {
    return '$n sélectionné(s)';
  }

  @override
  String get galerieTitre => 'Galerie du design system';

  @override
  String get galerieTheme => 'Thème';

  @override
  String get galerieLangue => 'Langue';

  @override
  String get galerieClair => 'Clair';

  @override
  String get galerieSombre => 'Sombre';
}
