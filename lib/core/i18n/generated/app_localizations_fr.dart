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

  @override
  String get activationTitre => 'Activation de CaisseDZ';

  @override
  String get activationIntro =>
      'Saisissez la clé d\'activation fournie pour cette machine, ou essayez le mode démo.';

  @override
  String get activationIdentifiantMachine => 'Identifiant de cette machine';

  @override
  String get activationCopierIdentifiant => 'Copier l\'identifiant';

  @override
  String get activationIdentifiantCopie => 'Identifiant copié';

  @override
  String get activationCle => 'Clé d\'activation (64 caractères)';

  @override
  String get activationCleIndice => 'Clé SHA-256 de 64 caractères hexadécimaux';

  @override
  String get activationBouton => 'Activer';

  @override
  String get activationDemo => 'Essayer en mode démo';

  @override
  String get activationDemoAide =>
      'Le mode démo ouvre toutes les fonctions (licence Avancé) avec le compte demo / demo. Les données saisies ne sont pas destinées à la production.';

  @override
  String get activationErreurFormat =>
      'La clé doit contenir exactement 64 caractères hexadécimaux (0-9, a-f).';

  @override
  String get activationErreurInconnue =>
      'Cette clé ne correspond pas à cette machine. Vérifiez la clé ou contactez votre revendeur.';

  @override
  String activationReussie(String niveau) {
    return 'Licence $niveau activée.';
  }

  @override
  String get licenceBasic => 'Basic';

  @override
  String get licenceAvance => 'Avancé';

  @override
  String get licenceDemo => 'Mode démo';

  @override
  String licenceNiveau(String niveau) {
    return 'Licence $niveau';
  }

  @override
  String get licenceRequise => 'Fonction disponible avec la licence Avancé';

  @override
  String get licenceRequiseDetail =>
      'Votre licence actuelle est Basic. Activez une licence Avancé pour accéder à ce module.';

  @override
  String get licenceGererCle => 'Activer une autre clé';

  @override
  String get connexionTitre => 'Connexion';

  @override
  String get connexionIdentifiant => 'Identifiant';

  @override
  String get connexionMotDePasse => 'Mot de passe';

  @override
  String get connexionBouton => 'Se connecter';

  @override
  String get connexionErreurIdentifiants =>
      'Identifiant ou mot de passe incorrect.';

  @override
  String get connexionErreurInactif => 'Ce compte est désactivé.';

  @override
  String get connexionErreurNonConfigure =>
      'Ce compte n\'a pas encore de mot de passe : terminez la configuration initiale.';

  @override
  String get connexionErreurDemo =>
      'Le compte demo/demo n\'est disponible qu\'en mode démo.';

  @override
  String get connexionDemoIndice =>
      'Mode démo : identifiant demo, mot de passe demo';

  @override
  String get connexionDeconnecter => 'Se déconnecter';

  @override
  String get configTitre => 'Configuration initiale';

  @override
  String configEtape(int n, int total) {
    return 'Étape $n sur $total';
  }

  @override
  String get configEtapeBoutique => 'Boutique';

  @override
  String get configEtapeAdmin => 'Administrateur';

  @override
  String get configEtapeVente => 'Marge et vente';

  @override
  String get configEtapeRecap => 'Récapitulatif';

  @override
  String get configBoutiqueNom => 'Nom de la boutique';

  @override
  String get configBoutiqueRc => 'Registre de commerce (RC)';

  @override
  String get configBoutiqueNif => 'NIF';

  @override
  String get configBoutiqueAdresse => 'Adresse';

  @override
  String get configBoutiqueTelephone => 'Téléphone';

  @override
  String get configBoutiqueEmail => 'E-mail';

  @override
  String get configAdminIntro =>
      'Ce compte administrateur aura tous les droits. Choisissez un identifiant et un mot de passe.';

  @override
  String get configAdminNom => 'Nom affiché';

  @override
  String get configAdminMotDePasseConfirmation => 'Confirmer le mot de passe';

  @override
  String get configMarge => 'Marge par défaut (%)';

  @override
  String get configMargeAide =>
      'Appliquée au calcul du prix de vente à partir du prix d\'achat des nouveaux produits.';

  @override
  String get configSeuil => 'Seuil d\'alerte de stock (global)';

  @override
  String get configFidelite => 'Activer la fidélité (points)';

  @override
  String get configPointsParDinar => 'Points gagnés par dinar';

  @override
  String get configDevise => 'Devise';

  @override
  String get configLangue => 'Langue de l\'application';

  @override
  String get configRecapIntro =>
      'Vérifiez les informations avant de terminer. Vous pourrez les modifier plus tard dans Paramètres.';

  @override
  String get configPrecedent => 'Précédent';

  @override
  String get configSuivant => 'Suivant';

  @override
  String get configTerminer => 'Terminer';

  @override
  String get configErreurObligatoire => 'Champ obligatoire';

  @override
  String get configErreurIdentifiant =>
      '3 à 32 caractères : lettres, chiffres, point, tiret, tiret bas.';

  @override
  String get configErreurMotDePasseCourt => 'Au moins 4 caractères.';

  @override
  String get configErreurConfirmation =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get configErreurIdentifiantPris => 'Cet identifiant est déjà utilisé.';

  @override
  String get configErreurMarge => 'Valeur entre 0 et 1000.';

  @override
  String get configErreurNombre => 'Nombre invalide.';

  @override
  String get configReussie =>
      'Configuration terminée. Connectez-vous avec votre compte administrateur.';

  @override
  String get compteTitre => 'Mon compte';

  @override
  String get compteRole => 'Rôle';

  @override
  String get compteIdentifiantActuel => 'Identifiant actuel';

  @override
  String get compteNouvelIdentifiant => 'Nouvel identifiant';

  @override
  String get compteMotDePasseActuel => 'Mot de passe actuel';

  @override
  String get compteNouveauMotDePasse => 'Nouveau mot de passe';

  @override
  String get compteChangerIdentifiant => 'Changer l\'identifiant';

  @override
  String get compteChangerMotDePasse => 'Changer le mot de passe';

  @override
  String compteIdentifiantChange(String identifiant) {
    return 'Identifiant modifié : connectez-vous désormais avec « $identifiant ».';
  }

  @override
  String get compteMotDePasseChange => 'Mot de passe modifié.';

  @override
  String get compteErreurMotDePasseActuel => 'Mot de passe actuel incorrect.';

  @override
  String get comptePreferences => 'Préférences';

  @override
  String get compteDemoLectureSeule =>
      'Le compte de démonstration ne peut pas être modifié.';

  @override
  String get accesRefuseTitre => 'Accès refusé';

  @override
  String accesRefuseMessage(String role, String module) {
    return 'Votre rôle « $role » n\'a pas accès au module « $module ». Demandez à un administrateur.';
  }

  @override
  String get accesRefuseRetour => 'Retour au tableau de bord';

  @override
  String get rolesTitre => 'Rôles et permissions';

  @override
  String get rolesIntro =>
      'Cochez les permissions d\'action et les modules accessibles pour chaque rôle. L\'administrateur conserve toujours tous les droits.';

  @override
  String get rolesPermissions => 'Permissions d\'action';

  @override
  String get rolesModules => 'Modules accessibles';

  @override
  String get rolesEnregistre => 'Grille des rôles enregistrée.';

  @override
  String get rolesAdminTotal => 'Tous les droits';

  @override
  String get permVoirPrixAchat => 'Voir le prix d\'achat';

  @override
  String get permModifierPrix => 'Modifier le prix en caisse';

  @override
  String get permAppliquerRemise => 'Appliquer une remise';

  @override
  String get permAnnulerVente => 'Annuler une vente';

  @override
  String get permSupprimerDocument => 'Supprimer un document';

  @override
  String get permExporterDonnees => 'Exporter les données';

  @override
  String get permGererUtilisateurs => 'Gérer les utilisateurs';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleCaissier => 'Caissier';

  @override
  String get roleMagasinier => 'Magasinier';

  @override
  String get parametresRolesCarte => 'Rôles et permissions';

  @override
  String get parametresRolesCarteDetail =>
      'Permissions d\'action et modules accessibles par rôle.';

  @override
  String get parametresLicenceCarte => 'Licence';

  @override
  String get shellBandeauDemo =>
      'Mode démo — les données ne sont pas destinées à la production';

  @override
  String get shellMenuUtilisateur => 'Menu utilisateur';

  @override
  String get shellVerrouille => 'Réservé à la licence Avancé';

  @override
  String get shellAccesRestreint => 'Accès non autorisé pour votre rôle';
}
