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
  String get shellFavorisVide => 'Aucun favori. Clic droit sur un module pour l\'ajouter.';

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
  String get activationTitre => 'Activer CaisseDZ';

  @override
  String get activationIntro =>
      'Envoyez l\'identifiant de ce poste à votre revendeur ; il vous remettra une clé liée à cet ordinateur.';

  @override
  String get activationIdentifiantMachine => 'Identifiant du poste';

  @override
  String get activationCopierIdentifiant => 'Copier';

  @override
  String get activationIdentifiantCopie => 'Copié';

  @override
  String get activationCle => 'Clé de licence';

  @override
  String get activationCleIndice => 'Collez la clé complète dans la première case.';

  @override
  String get activationBouton => 'Activer';

  @override
  String get activationDemo => 'Essayer en mode démo';

  @override
  String get activationDemoAide =>
      'Le mode démo ouvre toutes les fonctions (licence Avancé) avec le compte demo / demo. Les données saisies ne sont pas destinées à la production.';

  @override
  String get activationErreurFormat => 'La clé doit contenir exactement 64 caractères hexadécimaux (0-9, a-f).';

  @override
  String get activationErreurInconnue => 'Clé invalide pour ce poste — vérifiez l\'identifiant envoyé.';

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
  String get connexionTitre => 'Bon retour';

  @override
  String get connexionIdentifiant => 'Nom d\'utilisateur';

  @override
  String get connexionMotDePasse => 'Mot de passe';

  @override
  String get connexionBouton => 'Se connecter';

  @override
  String get connexionErreurIdentifiants => 'Identifiant ou mot de passe incorrect.';

  @override
  String get connexionErreurInactif => 'Ce compte est désactivé.';

  @override
  String get connexionErreurNonConfigure =>
      'Ce compte n\'a pas encore de mot de passe : terminez la configuration initiale.';

  @override
  String get connexionErreurDemo => 'Le compte demo/demo n\'est disponible qu\'en mode démo.';

  @override
  String get connexionDemoIndice => 'Mode démo : nom d\'utilisateur demo, mot de passe demo.';

  @override
  String get connexionSaisirCle => 'Saisir une clé d\'activation';

  @override
  String get connexionDeconnecter => 'Se déconnecter';

  @override
  String get configTitre => 'Bienvenue dans CaisseDZ';

  @override
  String configEtape(int n, int total) {
    return 'Étape $n sur $total';
  }

  @override
  String get configEtapeBoutique => 'Boutique';

  @override
  String get configEtapeAdmin => 'Administrateur';

  @override
  String get configEtapeVente => 'Marge et stock';

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
  String get configMarge => 'Marge par défaut';

  @override
  String get configMargeAide => 'Appliquée au calcul du prix de vente à partir du prix d\'achat des nouveaux produits.';

  @override
  String get configSeuil => 'Seuil de rupture';

  @override
  String get configFidelite => 'Fidélité';

  @override
  String get configPointsParDinar => 'Points gagnés par dinar';

  @override
  String get configDevise => 'Devise';

  @override
  String get configLangue => 'Langue';

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
  String get configErreurIdentifiant => '3 à 32 caractères : lettres, chiffres, point, tiret, tiret bas.';

  @override
  String get configErreurMotDePasseCourt => 'Au moins 4 caractères.';

  @override
  String get configErreurConfirmation => 'Les mots de passe ne correspondent pas.';

  @override
  String get configErreurIdentifiantPris => 'Cet identifiant est déjà utilisé.';

  @override
  String get configErreurMarge => 'Valeur entre 0 et 1000.';

  @override
  String get configErreurNombre => 'Nombre invalide.';

  @override
  String get configReussie => 'Configuration terminée. Connectez-vous avec votre compte administrateur.';

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
  String get compteDemoLectureSeule => 'Le compte de démonstration ne peut pas être modifié.';

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
  String get parametresRolesCarteDetail => 'Permissions d\'action et modules accessibles par rôle.';

  @override
  String get parametresLicenceCarte => 'Licence';

  @override
  String get shellBandeauDemo => 'Mode démo — les données ne sont pas destinées à la production';

  @override
  String get shellMenuUtilisateur => 'Menu utilisateur';

  @override
  String get shellVerrouille => 'Réservé à la licence Avancé';

  @override
  String get shellAccesRestreint => 'Accès non autorisé pour votre rôle';

  @override
  String get produitsTitre => 'Produits';

  @override
  String get produitsOngletProduits => 'Produits';

  @override
  String get produitsOngletCategories => 'Catégories';

  @override
  String get produitsOngletColis => 'Colis';

  @override
  String get produitsOngletPacks => 'Packs';

  @override
  String get produitsOngletRemises => 'Remises';

  @override
  String get produitsNouveau => 'Nouveau produit';

  @override
  String get produitsModeIa => 'Mode IA';

  @override
  String get produitsImporter => 'Importer Excel';

  @override
  String get produitsEtiquettes => 'Étiquettes';

  @override
  String get produitsSynchro => 'Synchro catalogue';

  @override
  String get produitsRecherche => 'Rechercher par désignation, code ou code-barres…';

  @override
  String get produitsColCode => 'Code';

  @override
  String get produitsColDesignation => 'Désignation';

  @override
  String get produitsColCodeBarres => 'Code-barres';

  @override
  String get produitsColCategorie => 'Catégorie';

  @override
  String get produitsColPrixAchat => 'Prix d\'achat';

  @override
  String get produitsColPrixVente => 'Prix de vente';

  @override
  String get produitsColMarge => 'Marge %';

  @override
  String get produitsColActif => 'Actif';

  @override
  String get produitsColStock => 'Stock';

  @override
  String get produitsAucun => 'Aucun produit. Créez-en un ou importez un fichier Excel.';

  @override
  String get produitModifier => 'Modifier le produit';

  @override
  String get produitDesactiver => 'Désactiver';

  @override
  String get produitActiver => 'Activer';

  @override
  String get produitGenererCodeBarres => 'Générer un code-barres interne';

  @override
  String get produitChampDesignation => 'Désignation';

  @override
  String get produitChampCodeBarres => 'Code-barres (EAN-13 ou interne)';

  @override
  String get produitChampCategorie => 'Catégorie';

  @override
  String get produitChampSousCategorie => 'Sous-catégorie';

  @override
  String get produitChampPrixAchat => 'Prix d\'achat';

  @override
  String get produitChampPrixVente => 'Prix de vente';

  @override
  String get produitChampMarge => 'Marge (%)';

  @override
  String get produitChampUnite => 'Unité';

  @override
  String get produitChampTva => 'TVA (%)';

  @override
  String get produitChampSeuil => 'Seuil d\'alerte (vide = seuil global)';

  @override
  String get produitChampSuiviNombre => 'Suivre un 2ᵉ stock « nombre » (pièces)';

  @override
  String get produitChampSuiviNombreAide =>
      'Le produit se vend à l\'unité ou à la pièce ; le stock est tenu dans les deux.';

  @override
  String get produitChampNombreParUnite => 'Pièces par unité';

  @override
  String get produitPrixAuto => 'Le prix de vente est calculé depuis la marge si vous le laissez vide.';

  @override
  String get produitErreurDesignation => 'La désignation est obligatoire.';

  @override
  String get produitErreurCodeBarres => 'Code-barres invalide.';

  @override
  String get produitErreurCodeBarresPris => 'Ce code-barres est déjà utilisé.';

  @override
  String get produitErreurPrix => 'Prix invalide.';

  @override
  String get produitErreurQuantite => 'Quantité invalide.';

  @override
  String produitCree(String nom, String code) {
    return 'Produit « $nom » créé ($code).';
  }

  @override
  String get iaTitre => 'Nouveau produit en mode IA';

  @override
  String get iaIntro =>
      'Scannez ou saisissez un code-barres : la fiche est recherchée dans CaisseDZ, puis Mantouj, Open Food Facts et Open Beauty Facts.';

  @override
  String get iaRechercher => 'Rechercher';

  @override
  String get iaRechercheEnCours => 'Recherche en cours…';

  @override
  String get iaAucun => 'Aucune fiche trouvée pour ce code-barres : passez en saisie détaillée.';

  @override
  String iaTrouve(String source) {
    return 'Fiche trouvée via $source';
  }

  @override
  String get iaMarque => 'Marque';

  @override
  String get iaCreer => 'Créer le produit';

  @override
  String get iaSaisieDetaillee => 'Saisie détaillée';

  @override
  String get importTitre => 'Importer des produits depuis Excel';

  @override
  String get importIntro =>
      'Colonnes attendues en ligne 1 : designation (obligatoire), code_barres, categorie, prix_achat, prix_vente.';

  @override
  String get importChoisirFichier => 'Choisir un fichier .xlsx';

  @override
  String get importTelechargerModele => 'Enregistrer le modèle';

  @override
  String importLignesValides(int n) {
    return '$n ligne(s) valide(s)';
  }

  @override
  String importLignesInvalides(int n) {
    return '$n ligne(s) ignorée(s)';
  }

  @override
  String get importColLigne => 'Ligne';

  @override
  String get importColErreur => 'Erreur';

  @override
  String get importLancer => 'Importer';

  @override
  String importResultat(int importees, int ignorees) {
    return '$importees produit(s) importé(s), $ignorees ignoré(s).';
  }

  @override
  String importErreurFichier(String detail) {
    return 'Fichier illisible : $detail';
  }

  @override
  String get importErreurDesignationVide => 'Désignation vide';

  @override
  String get importErreurCodeBarresPris => 'Code-barres déjà utilisé';

  @override
  String get importErreurPrix => 'Prix invalide';

  @override
  String get etiquettesTitre => 'Imprimer des étiquettes';

  @override
  String get etiquettesQuantite => 'Quantité';

  @override
  String get etiquettesFormatA4 => 'Planche A4';

  @override
  String get etiquettesFormatRouleau => 'Rouleau';

  @override
  String get etiquettesAfficherPrix => 'Afficher le prix';

  @override
  String get etiquettesQr => 'Code QR au lieu du code-barres';

  @override
  String get etiquettesGenerer => 'Générer le PDF';

  @override
  String get etiquettesAucuneSelection => 'Sélectionnez au moins un produit dans la liste.';

  @override
  String synchroResultat(int envoyes, int recus) {
    return 'Synchronisation : $envoyes envoyé(s), $recus mis à jour.';
  }

  @override
  String get synchroNonConfiguree =>
      'Renseignez l\'URL du serveur CaisseDZ dans Paramètres pour synchroniser le catalogue.';

  @override
  String synchroErreur(String detail) {
    return 'Échec de la synchronisation : $detail';
  }

  @override
  String get categoriesNouvelle => 'Nouvelle catégorie';

  @override
  String get categoriesNouvelleSous => 'Nouvelle sous-catégorie';

  @override
  String get categorieNom => 'Nom';

  @override
  String get categorieRenommer => 'Renommer';

  @override
  String get categorieSupprimer => 'Supprimer';

  @override
  String get categorieSousCategories => 'Sous-catégories';

  @override
  String get categorieErreurSysteme => 'La catégorie système ne peut pas être modifiée.';

  @override
  String get categorieErreurUtilisee => 'Des produits sont rattachés à cette catégorie.';

  @override
  String categorieConfirmerSuppression(String nom) {
    return 'Supprimer la catégorie « $nom » et ses sous-catégories ?';
  }

  @override
  String get colisNouveau => 'Nouveau colis';

  @override
  String get colisProduit => 'Produit';

  @override
  String get colisQuantite => 'Unités par colis';

  @override
  String get colisAucun => 'Aucun colis.';

  @override
  String get packNouveau => 'Nouveau pack';

  @override
  String get packLignes => 'Composition';

  @override
  String get packAjouterProduit => 'Ajouter un produit';

  @override
  String get packAucun => 'Aucun pack.';

  @override
  String get packErreurLignes => 'Ajoutez au moins un produit au pack.';

  @override
  String get remiseNouvelle => 'Nouvelle remise';

  @override
  String get remiseType => 'Type';

  @override
  String get remiseTypePourcentage => 'Pourcentage';

  @override
  String get remiseTypeMontant => 'Montant';

  @override
  String get remiseValeur => 'Valeur';

  @override
  String get remisePortee => 'Portée';

  @override
  String get remisePorteeGlobale => 'Tous les produits';

  @override
  String get remisePorteeCategorie => 'Une catégorie';

  @override
  String get remisePorteeProduit => 'Un produit';

  @override
  String get remiseDebut => 'Début';

  @override
  String get remiseFin => 'Fin';

  @override
  String get remiseAucune => 'Aucune remise.';

  @override
  String get communNouveau => 'Nouveau';

  @override
  String get communModifier => 'Modifier';

  @override
  String get communActif => 'Actif';

  @override
  String get communInactif => 'Inactif';

  @override
  String get communOui => 'Oui';

  @override
  String get communNon => 'Non';

  @override
  String get communValider => 'Valider';

  @override
  String get communApercu => 'Aperçu';

  @override
  String get communImprimer => 'Imprimer';

  @override
  String get communAucune => 'Aucune';

  @override
  String get stockTitre => 'Stock';

  @override
  String get stockOngletNiveaux => 'Niveaux';

  @override
  String get stockOngletJournal => 'Journal des mouvements';

  @override
  String get stockColProduit => 'Produit';

  @override
  String get stockColMagasin => 'Magasin';

  @override
  String get stockColQuantite => 'Quantité';

  @override
  String get stockColNombre => 'Nombre (pièces)';

  @override
  String get stockColSeuil => 'Seuil';

  @override
  String get stockColDate => 'Date';

  @override
  String get stockColType => 'Type';

  @override
  String get stockColMotif => 'Motif';

  @override
  String get stockColReference => 'Référence';

  @override
  String get stockColUtilisateur => 'Utilisateur';

  @override
  String get stockColCommentaire => 'Commentaire';

  @override
  String get stockColValeur => 'Valeur (PA)';

  @override
  String get stockTousMagasins => 'Tous les magasins';

  @override
  String get stockSousSeuil => 'Sous seuil';

  @override
  String get stockEntreeManuelle => 'Entrée manuelle';

  @override
  String get stockInventaire => 'Inventaire';

  @override
  String get stockQuantiteConstatee => 'Quantité constatée';

  @override
  String get stockNombreConstate => 'Nombre constaté';

  @override
  String get stockAucunMouvement => 'Aucun mouvement.';

  @override
  String get stockErreurQuantite => 'Quantité invalide.';

  @override
  String get stockErreurInsuffisant => 'Stock insuffisant : la garde de stock refuse cette sortie.';

  @override
  String get stockErreurMemeMagasin => 'Le magasin de destination doit être différent.';

  @override
  String get stockErreurLignes => 'Ajoutez au moins une ligne.';

  @override
  String get stockErreurMotif => 'Motif invalide.';

  @override
  String get stockErreurMagasinInactif => 'Magasin inactif ou inconnu.';

  @override
  String get stockErreurMagasinSysteme => 'Le magasin principal ne peut pas être désactivé.';

  @override
  String get stockErreurProduit => 'Produit inconnu.';

  @override
  String get stockErreurStatut => 'Statut invalide.';

  @override
  String get typeMouvementEntree => 'Entrée';

  @override
  String get typeMouvementSortie => 'Sortie';

  @override
  String get typeMouvementVente => 'Vente';

  @override
  String get typeMouvementRetour => 'Retour';

  @override
  String get typeMouvementTransfert => 'Transfert';

  @override
  String get typeMouvementInventaire => 'Inventaire';

  @override
  String get typeMouvementInitial => 'Stock initial';

  @override
  String get magasinsTitre => 'Magasins';

  @override
  String get magasinNouveau => 'Nouveau magasin';

  @override
  String get magasinNom => 'Nom';

  @override
  String get magasinAdresse => 'Adresse';

  @override
  String get magasinPrincipal => 'Principal';

  @override
  String get magasinMesMagasins => 'Mes magasins (le premier est le principal)';

  @override
  String get magasinAjouterAuxMiens => 'Ajouter à mes magasins';

  @override
  String get magasinRetirerDesMiens => 'Retirer de mes magasins';

  @override
  String get magasinDefinirPrincipal => 'Définir comme principal';

  @override
  String get transfertsTitre => 'Transferts';

  @override
  String get transfertNouveau => 'Nouveau transfert';

  @override
  String get transfertSource => 'Magasin source';

  @override
  String get transfertDestination => 'Magasin destination';

  @override
  String get transfertLignes => 'Lignes';

  @override
  String get transfertAjouterLigne => 'Ajouter un produit';

  @override
  String get transfertAucun => 'Aucun transfert.';

  @override
  String transfertCree(String code) {
    return 'Transfert $code enregistré : 2 mouvements par ligne.';
  }

  @override
  String get besoinsTitre => 'Besoins';

  @override
  String get besoinNouveau => 'Nouveau besoin';

  @override
  String get besoinGenerer => 'Générer sous seuil';

  @override
  String besoinGeneres(int n) {
    return '$n besoin(s) généré(s).';
  }

  @override
  String get besoinStatut => 'Statut';

  @override
  String get besoinPasserCommande => 'Passer en Commande';

  @override
  String get besoinPasserDisponible => 'Passer en Disponible';

  @override
  String get besoinRemettreAttente => 'Remettre En attente';

  @override
  String get besoinAucun => 'Aucun besoin.';

  @override
  String get statutBesoinEnAttente => 'En attente';

  @override
  String get statutBesoinCommande => 'Commande';

  @override
  String get statutBesoinDisponible => 'Disponible';

  @override
  String get sortiesTitre => 'Sorties';

  @override
  String get sortiesOngletSorties => 'Sorties';

  @override
  String get sortiesOngletVentes => 'Ventes';

  @override
  String get sortieNouvelle => 'Nouvelle sortie';

  @override
  String get sortieMotif => 'Motif';

  @override
  String get sortieAucune => 'Aucune sortie.';

  @override
  String get motifCasse => 'Casse';

  @override
  String get motifPerime => 'Périmé';

  @override
  String get motifPerteVol => 'Perte/vol';

  @override
  String get motifConsommationInterne => 'Consommation interne';

  @override
  String get motifDon => 'Don';

  @override
  String get motifEchantillon => 'Échantillon';

  @override
  String communLignes(int n) {
    return '$n ligne(s)';
  }

  @override
  String get communCommentaire => 'Commentaire';

  @override
  String get communDate => 'Date';

  @override
  String get communQuantite => 'Quantité';

  @override
  String get moduleMagasins => 'Magasins';

  @override
  String get posTitre => 'Caisse';

  @override
  String get posScan => 'Scanner ou rechercher un produit (F1)';

  @override
  String posPanier(int n) {
    return 'Panier $n';
  }

  @override
  String get posNouveauPanier => 'Nouveau panier (Ctrl+N)';

  @override
  String get posMaxPaniers => '5 ventes en parallèle au maximum.';

  @override
  String get posPanierVide => 'Panier vide : scannez un code-barres ou cliquez sur un produit.';

  @override
  String get posSousTotal => 'Sous-total';

  @override
  String get posRemise => 'Remise';

  @override
  String get posTotal => 'Total';

  @override
  String get posVerse => 'Versé';

  @override
  String get posReste => 'Reste';

  @override
  String get posMonnaie => 'Monnaie à rendre';

  @override
  String get posPointsGagnes => 'Points gagnés';

  @override
  String get posClient => 'Client (F2)';

  @override
  String get posClientPassage => 'Client de passage';

  @override
  String get posChoisirClient => 'Choisir un client';

  @override
  String get posRemiseGlobale => 'Remise globale (F3)';

  @override
  String get posRemisePct => 'Remise (%)';

  @override
  String get posPaiement => 'Paiement';

  @override
  String get posMontant => 'Montant';

  @override
  String get posEncaisser => 'Encaisser (F12)';

  @override
  String get posVider => 'Vider (F10)';

  @override
  String get posCalculatrice => 'Calculatrice (F9)';

  @override
  String get posAide => 'Aide (F11)';

  @override
  String get posSessionOuvrir => 'Ouvrir la session';

  @override
  String get posSessionFermer => 'Fermer la session';

  @override
  String get posSessionAucune => 'Aucune session de caisse ouverte : ouvrez une session pour encaisser.';

  @override
  String posSessionOuverte(String code, String caisse) {
    return 'Session $code · $caisse';
  }

  @override
  String get posSessionCaisse => 'Caisse';

  @override
  String get posSessionFond => 'Fond de caisse initial';

  @override
  String get posSessionMontantCompte => 'Montant compté';

  @override
  String get posSessionAttendu => 'Espèces attendues';

  @override
  String get posSessionEcart => 'Écart';

  @override
  String posSessionFermee(String code, String ecart) {
    return 'Session $code fermée. Écart : $ecart.';
  }

  @override
  String get posErreurSessionDejaOuverte => 'Une session est déjà ouverte (utilisateur ou caisse).';

  @override
  String get posErreurSessionAucune => 'Aucune session ouverte.';

  @override
  String get posErreurCaisse => 'Caisse inconnue ou inactive.';

  @override
  String get posErreurMontant => 'Montant invalide.';

  @override
  String posErreurStock(String detail) {
    return 'Stock insuffisant (réservé par les paniers ouverts) : $detail';
  }

  @override
  String posErreurProduitInconnu(String code) {
    return 'Code inconnu : $code';
  }

  @override
  String get posErreurPanierVide => 'Le panier est vide.';

  @override
  String posErreurPaiementInsuffisant(String reste) {
    return 'Paiement insuffisant. Reste : $reste';
  }

  @override
  String get posErreurModePaiement => 'Mode de paiement invalide.';

  @override
  String get posErreurPoints => 'Points insuffisants.';

  @override
  String get posErreurCredit => 'Vente à crédit non autorisée pour ce client.';

  @override
  String get posErreurQuantite => 'Quantité invalide.';

  @override
  String get posErreurPeriodeCloturee => 'Opération refusée : période clôturée.';

  @override
  String posVenteEnregistree(String code, String monnaie) {
    return 'Vente $code encaissée. Monnaie à rendre : $monnaie';
  }

  @override
  String get posImprimerTicket => 'Imprimer le ticket';

  @override
  String get posImprimerFacture => 'Facture A4';

  @override
  String get posTicket58 => 'Ticket 58 mm';

  @override
  String get posTicket80 => 'Ticket 80 mm';

  @override
  String get posApercuTicket => 'Aperçu du ticket';

  @override
  String get posImpressionOk => 'Ticket envoyé à l\'imprimante.';

  @override
  String posImpressionErreur(String detail) {
    return 'Impression impossible : $detail';
  }

  @override
  String get posCreditAutoriser => 'Vendre à crédit (reste dû)';

  @override
  String get posRaccourcisTitre => 'Raccourcis clavier';

  @override
  String get posRaccourciF1 => 'Rechercher / scanner';

  @override
  String get posRaccourciF2 => 'Choisir le client';

  @override
  String get posRaccourciF3 => 'Remise globale';

  @override
  String get posRaccourciF4 => 'Espèces : montant exact';

  @override
  String get posRaccourciF5 => 'Carte : montant exact';

  @override
  String get posRaccourciF6 => 'Chèque : montant exact';

  @override
  String get posRaccourciF7 => 'Virement : montant exact';

  @override
  String get posRaccourciF8 => 'Points de fidélité';

  @override
  String get posRaccourciF9 => 'Calculatrice';

  @override
  String get posRaccourciF10 => 'Vider le panier';

  @override
  String get posRaccourciF11 => 'Cette aide';

  @override
  String get posRaccourciF12 => 'Encaisser';

  @override
  String get posRaccourciCtrlN => 'Nouveau panier';

  @override
  String get posRaccourciCtrlTab => 'Panier suivant';

  @override
  String get posRaccourciSuppr => 'Retirer la ligne sélectionnée';

  @override
  String get posRaccourciPlusMoins => 'Quantité +1 / −1 sur la ligne sélectionnée';

  @override
  String get posLigneQuantite => 'Qté';

  @override
  String get posLignePrix => 'P.U.';

  @override
  String get posLigneRemise => 'Rem.';

  @override
  String get posLigneTotal => 'Total';

  @override
  String get posVendreNombre => 'Vendre à la pièce';

  @override
  String get posColis => 'Colis';

  @override
  String get posPack => 'Pack';

  @override
  String get posCategoriesToutes => 'Toutes';

  @override
  String get posAucunProduit => 'Aucun produit actif.';

  @override
  String get calcTitre => 'Calculatrice';

  @override
  String get calcUtiliser => 'Utiliser comme montant';

  @override
  String get modePaiementEspeces => 'Espèces';

  @override
  String get modePaiementCarte => 'Carte';

  @override
  String get modePaiementCheque => 'Chèque';

  @override
  String get modePaiementVirement => 'Virement';

  @override
  String get modePaiementPoints => 'Points';

  @override
  String get ventesTitre => 'Ventes';

  @override
  String get ventesColTicket => 'Ticket';

  @override
  String get ventesColClient => 'Client';

  @override
  String get ventesColNet => 'Net';

  @override
  String get ventesColVerse => 'Versé';

  @override
  String get ventesColReste => 'Reste dû';

  @override
  String get ventesColStatut => 'Statut';

  @override
  String get ventesColCaisse => 'Caisse';

  @override
  String get ventesColVendeur => 'Vendeur';

  @override
  String get ventesAucune => 'Aucune vente.';

  @override
  String get ventesVoirTicket => 'Voir le ticket';

  @override
  String get ventesAnnuler => 'Annuler la vente';

  @override
  String ventesConfirmerAnnulation(String code) {
    return 'Annuler la vente $code ? Le stock et les points seront restitués ; le ticket scellé est conservé.';
  }

  @override
  String get ventesCreerRetour => 'Créer un retour';

  @override
  String get ventesVerifierChaine => 'Vérifier le scellement';

  @override
  String get ventesChaineOk => 'Chaîne de tickets intacte.';

  @override
  String ventesChaineKo(String code) {
    return 'Chaîne altérée à partir du ticket $code.';
  }

  @override
  String get ventesFiltreToutes => 'Toutes';

  @override
  String get ventesFiltreValidees => 'Validées';

  @override
  String get ventesFiltreAnnulees => 'Annulées';

  @override
  String get ventesFiltreCredit => 'À crédit';

  @override
  String get statutVenteValidee => 'Validée';

  @override
  String get statutVenteAnnulee => 'Annulée';

  @override
  String ticketDetail(String code) {
    return 'Ticket $code';
  }

  @override
  String get retoursTitre => 'Retours';

  @override
  String get retourNouveau => 'Nouveau retour';

  @override
  String get retourVente => 'Vente d\'origine';

  @override
  String get retourMotif => 'Motif';

  @override
  String get retourRembourser => 'Montant remboursé';

  @override
  String get retourModeRemboursement => 'Mode de remboursement';

  @override
  String get retourAvoir => 'Le reste est porté en avoir sur le compte du client.';

  @override
  String get retourAucun => 'Aucun retour.';

  @override
  String get retourColTotal => 'Total retourné';

  @override
  String get retourColRembourse => 'Remboursé';

  @override
  String retourQuantiteMax(String max) {
    return 'Quantité retournée (max $max)';
  }

  @override
  String get retourErreurVenteInconnue => 'Vente introuvable.';

  @override
  String get retourErreurVenteAnnulee => 'Cette vente est annulée.';

  @override
  String get retourErreurLignes => 'Indiquez au moins une quantité à retourner.';

  @override
  String get retourErreurQuantite => 'Quantité invalide.';

  @override
  String get retourErreurDepasse => 'Quantité supérieure à la quantité vendue (déjà retournée incluse).';

  @override
  String get retourErreurPeriode => 'Période clôturée : retour impossible.';

  @override
  String retourCree(String code, String total, String rembourse) {
    return 'Retour $code enregistré : $total (remboursé $rembourse).';
  }

  @override
  String get clientsTitre => 'Clients';

  @override
  String get clientNouveau => 'Nouveau client';

  @override
  String get clientNom => 'Nom';

  @override
  String get clientTelephone => 'Téléphone';

  @override
  String get clientAdresse => 'Adresse';

  @override
  String get clientEmail => 'E-mail';

  @override
  String get clientPoints => 'Points';

  @override
  String get clientPlafond => 'Plafond de crédit';

  @override
  String get clientSolde => 'Solde dû';

  @override
  String get clientAucun => 'Aucun client.';

  @override
  String get clientFiche => 'Fiche client';

  @override
  String get clientDocumentsOuverts => 'Documents ouverts';

  @override
  String get clientVersements => 'Versements';

  @override
  String get clientNouveauVersement => 'Encaisser un versement';

  @override
  String get fournisseursTitre => 'Fournisseurs';

  @override
  String get fournisseurNouveau => 'Nouveau fournisseur';

  @override
  String get fournisseurAucun => 'Aucun fournisseur.';

  @override
  String get fournisseurFiche => 'Fiche fournisseur';

  @override
  String get fournisseurNouveauVersement => 'Régler un versement';

  @override
  String get versementsTitre => 'Versements';

  @override
  String get versementNouveau => 'Nouveau versement';

  @override
  String get versementTiers => 'Tiers';

  @override
  String get versementTiersClient => 'Client';

  @override
  String get versementTiersFournisseur => 'Fournisseur';

  @override
  String get versementMontant => 'Montant';

  @override
  String get versementMode => 'Mode';

  @override
  String get versementReference => 'Référence';

  @override
  String get versementAucun => 'Aucun versement.';

  @override
  String get versementColSens => 'Sens';

  @override
  String get versementColImpute => 'Imputé';

  @override
  String get versementColNonImpute => 'Non imputé';

  @override
  String versementVerrouille(String retour) {
    return 'Verrouillé (lié au retour $retour)';
  }

  @override
  String get versementImputations => 'Imputations (plus ancien d\'abord)';

  @override
  String get versementSupprimer => 'Supprimer le versement';

  @override
  String versementConfirmerSuppression(String code) {
    return 'Supprimer le versement $code ? Les imputations seront annulées.';
  }

  @override
  String get versementErreurMontant => 'Montant invalide.';

  @override
  String get versementErreurMode => 'Mode de paiement invalide.';

  @override
  String get versementErreurSysteme => 'Impossible pour le tiers système.';

  @override
  String get versementErreurVerrouille =>
      'Versement verrouillé : lié à un retour, il ne peut être ni modifié ni supprimé.';

  @override
  String get versementErreurInconnu => 'Versement introuvable.';

  @override
  String get versementErreurTiers => 'Tiers invalide.';

  @override
  String versementEnregistre(String code, String impute, String reste) {
    return 'Versement $code enregistré : $impute imputé(s), $reste en avance.';
  }

  @override
  String get sensEncaissement => 'Encaissement';

  @override
  String get sensDecaissement => 'Décaissement';

  @override
  String get tiersErreurNom => 'Le nom est obligatoire.';

  @override
  String get tiersErreurSysteme => 'Le tiers système ne peut pas être modifié.';

  @override
  String get achatsTitre => 'Entrées / Achats';

  @override
  String get achatNouveau => 'Nouvelle entrée';

  @override
  String get achatSmartScan => 'Smart Scan IA';

  @override
  String get achatFournisseur => 'Fournisseur';

  @override
  String get achatReference => 'Référence facture';

  @override
  String get achatMagasin => 'Magasin';

  @override
  String get achatLignes => 'Lignes';

  @override
  String get achatPrixAchat => 'Prix d\'achat';

  @override
  String get achatNouveauPrixVente => 'Nouveau prix de vente';

  @override
  String get achatVerse => 'Versé';

  @override
  String get achatModePaiement => 'Mode de paiement';

  @override
  String get achatMettreAJourPrix => 'Mettre à jour le prix d\'achat des produits';

  @override
  String get achatAucun => 'Aucune entrée.';

  @override
  String get achatColTotal => 'Total';

  @override
  String get achatColVerse => 'Versé';

  @override
  String get achatColReste => 'Reste';

  @override
  String get achatColSource => 'Source';

  @override
  String get achatColStatut => 'Statut';

  @override
  String get achatAnnuler => 'Annuler l\'entrée';

  @override
  String achatConfirmerAnnulation(String code) {
    return 'Annuler l\'entrée $code ? Le stock sera ressorti.';
  }

  @override
  String achatEnregistre(String code, String total, String reste) {
    return 'Entrée $code enregistrée : $total, reste dû $reste.';
  }

  @override
  String get achatErreurLignes => 'Ajoutez au moins une ligne.';

  @override
  String get achatErreurQuantite => 'Quantité invalide.';

  @override
  String get achatErreurPrix => 'Prix ou montant invalide.';

  @override
  String get achatErreurProduit => 'Produit inconnu.';

  @override
  String get achatErreurFournisseur => 'Fournisseur inconnu.';

  @override
  String get achatErreurInconnu => 'Entrée introuvable.';

  @override
  String get achatErreurAnnule => 'Entrée déjà annulée.';

  @override
  String get achatErreurPeriode => 'Période clôturée : annulation impossible.';

  @override
  String get achatErreurStock => 'Stock insuffisant pour annuler (déjà vendu).';

  @override
  String get statutAchatValide => 'Validé';

  @override
  String get statutAchatAnnule => 'Annulé';

  @override
  String get sourceManuel => 'Manuel';

  @override
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanTitre => 'Smart Scan IA — facture fournisseur';

  @override
  String get smartScanIntro =>
      'Prenez en photo ou choisissez la facture (image ou PDF) : les lignes sont reconnues par le serveur CaisseDZ et rapprochées de votre catalogue.';

  @override
  String smartScanQuota(int restant, int total) {
    return 'Quota : $restant analyse(s) restante(s) sur $total';
  }

  @override
  String get smartScanChoisir => 'Choisir une facture';

  @override
  String get smartScanAnalyser => 'Analyser';

  @override
  String get smartScanAnalyse => 'Analyse en cours…';

  @override
  String get smartScanAucuneLigne => 'Aucune ligne reconnue.';

  @override
  String get smartScanLigneNonRapprochee => 'Non rapprochée';

  @override
  String get smartScanRapprocher => 'Associer un produit';

  @override
  String get smartScanCreerEntree => 'Créer l\'entrée';

  @override
  String get smartScanQuotaAtteint => 'Quota Smart Scan atteint';

  @override
  String get smartScanQuotaAtteintDetail => 'Vous avez utilisé toutes vos analyses. Demandez une offre pour continuer.';

  @override
  String get smartScanDemandeOffre => 'Demander une offre';

  @override
  String get smartScanEmail => 'Votre e-mail';

  @override
  String get smartScanMessage => 'Message';

  @override
  String get smartScanOffreEnvoyee => 'Demande envoyée, nous vous contacterons rapidement.';

  @override
  String get smartScanNonConfigure => 'Renseignez l\'URL du serveur CaisseDZ dans Paramètres pour utiliser Smart Scan.';

  @override
  String smartScanErreurReseau(String detail) {
    return 'Serveur injoignable : $detail';
  }

  @override
  String smartScanErreurServeur(String detail) {
    return 'Erreur du serveur : $detail';
  }

  @override
  String get smartScanErreurFichier => 'Fichier invalide.';

  @override
  String get gestionCaisseTitre => 'Gestion de caisse';

  @override
  String get gestionCaisseOngletCaisses => 'Caisses';

  @override
  String get gestionCaisseOngletMouvements => 'Mouvements';

  @override
  String get gestionCaisseOngletTransferts => 'Transferts entre caisses';

  @override
  String get caisseNouvelle => 'Nouvelle caisse';

  @override
  String get caisseModifier => 'Modifier la caisse';

  @override
  String get caisseNom => 'Nom';

  @override
  String get caisseType => 'Type';

  @override
  String get caisseMagasin => 'Magasin';

  @override
  String get caisseSansMagasin => 'Sans magasin';

  @override
  String get caisseActive => 'Active';

  @override
  String get caisseInactive => 'Inactive';

  @override
  String get caisseSoldeEspeces => 'Solde espèces';

  @override
  String get caisseSoldeTotal => 'Solde total';

  @override
  String get caisseTypePhysique => 'Physique';

  @override
  String get caisseTypeCompte => 'Compte';

  @override
  String get caisseAucune => 'Aucune caisse.';

  @override
  String get caisseDesactiver => 'Désactiver';

  @override
  String get caisseActiver => 'Activer';

  @override
  String get mouvementApport => 'Apport';

  @override
  String get mouvementDepense => 'Dépense';

  @override
  String get mouvementColType => 'Type';

  @override
  String get mouvementColSens => 'Sens';

  @override
  String get mouvementColMontant => 'Montant';

  @override
  String get mouvementColMode => 'Mode';

  @override
  String get mouvementColReference => 'Référence';

  @override
  String get mouvementAucun => 'Aucun mouvement.';

  @override
  String get mouvementToutesCaisses => 'Toutes les caisses';

  @override
  String get mouvementCaisse => 'Caisse';

  @override
  String get mvtVente => 'Vente';

  @override
  String get mvtAnnulation => 'Annulation';

  @override
  String get mvtRemboursement => 'Remboursement';

  @override
  String get mvtEncaissement => 'Encaissement';

  @override
  String get mvtDecaissement => 'Décaissement';

  @override
  String get mvtApport => 'Apport';

  @override
  String get mvtDepense => 'Dépense';

  @override
  String get mvtTransfert => 'Transfert';

  @override
  String get mvtFondInitial => 'Fond initial';

  @override
  String get mvtRetrait => 'Retrait';

  @override
  String get mvtEcart => 'Écart';

  @override
  String get sensEntree => 'Entrée';

  @override
  String get sensSortie => 'Sortie';

  @override
  String get transfertCaisseNouveau => 'Nouveau transfert';

  @override
  String get transfertCaisseSource => 'Caisse source';

  @override
  String get transfertCaisseDestination => 'Caisse destination';

  @override
  String get transfertCaisseAucun => 'Aucun transfert.';

  @override
  String transfertCaisseCree(String code) {
    return 'Transfert $code enregistré (2 mouvements).';
  }

  @override
  String get caisseErreurNom => 'Le nom est obligatoire.';

  @override
  String get caisseErreurType => 'Type de caisse invalide.';

  @override
  String get caisseErreurMagasin => 'Magasin inconnu.';

  @override
  String get caisseErreurInconnue => 'Caisse introuvable.';

  @override
  String get caisseErreurInactive => 'Caisse inactive.';

  @override
  String get caisseErreurSysteme => 'La caisse principale ne peut pas être désactivée.';

  @override
  String get caisseErreurMontant => 'Montant invalide.';

  @override
  String get caisseErreurMode => 'Mode de paiement invalide.';

  @override
  String get caisseErreurMemeCaisse => 'Choisissez deux caisses différentes.';

  @override
  String get caisseErreurSolde => 'Solde insuffisant dans la caisse source.';

  @override
  String get caisseErreurSessionOuverte => 'Une session est ouverte sur cette caisse.';

  @override
  String get cloturesTitre => 'Clôtures Z';

  @override
  String get clotureNouvelle => 'Clôturer (Z)';

  @override
  String get clotureApercuTitre => 'Clôture Z — aperçu de la période';

  @override
  String get cloturePeriode => 'Période';

  @override
  String get clotureDebut => 'Début';

  @override
  String get clotureFin => 'Fin';

  @override
  String get clotureColVentes => 'Ventes';

  @override
  String get clotureColAnnulations => 'Annulations';

  @override
  String get clotureColTotalVentes => 'Total ventes';

  @override
  String get clotureColRemises => 'Remises';

  @override
  String get clotureColRetours => 'Retours';

  @override
  String get clotureColEncaissements => 'Encaissements';

  @override
  String get clotureColDecaissements => 'Décaissements';

  @override
  String get clotureColHash => 'Scellement';

  @override
  String get clotureColUtilisateur => 'Utilisateur';

  @override
  String get clotureAucune => 'Aucune clôture.';

  @override
  String get clotureConfirmer => 'Sceller la clôture';

  @override
  String clotureCreee(String code, String hash) {
    return 'Clôture $code scellée. Hash : $hash';
  }

  @override
  String get clotureDetail => 'Détail de la clôture';

  @override
  String get clotureParMode => 'Encaissements par mode';

  @override
  String get clotureSoldes => 'Soldes des caisses';

  @override
  String get clotureDerniereVente => 'Dernier ticket';

  @override
  String get clotureHashPrecedent => 'Hash précédent';

  @override
  String get clotureHash => 'Hash';

  @override
  String get clotureVerifier => 'Vérifier la chaîne';

  @override
  String get clotureChaineOk => 'Chaîne des clôtures intacte.';

  @override
  String clotureChaineKo(String code) {
    return 'Chaîne altérée à partir de la clôture $code.';
  }

  @override
  String get clotureErreurSession => 'Fermez toutes les sessions de caisse avant de clôturer.';

  @override
  String get clotureErreurRien => 'Rien à clôturer depuis la dernière clôture.';

  @override
  String get clotureAvertissementImmuable =>
      'Une clôture est définitive : elle ne peut être ni modifiée ni supprimée, et les documents de la période ne pourront plus être annulés.';

  @override
  String get exportFiscalTitre => 'Export fiscal';

  @override
  String get exportFiscalDebut => 'Du (jj/mm/aaaa)';

  @override
  String get exportFiscalFin => 'Au (jj/mm/aaaa)';

  @override
  String get exportFiscalGenerer => 'Générer l\'archive';

  @override
  String exportFiscalOk(String chemin, int ventes, int clotures) {
    return 'Archive enregistrée : $chemin ($ventes ventes, $clotures clôtures, empreinte vérifiée).';
  }

  @override
  String get exportFiscalErreurDates => 'Dates invalides.';

  @override
  String get exportFiscalVerifier => 'Vérifier une archive';

  @override
  String exportFiscalVerifOk(int ventes, int clotures) {
    return 'Archive valide : $ventes ventes, $clotures clôtures.';
  }

  @override
  String exportFiscalVerifKo(String erreurs) {
    return 'Archive invalide : $erreurs';
  }

  @override
  String get exportFiscalPermission => 'Permission « exporter les données » requise.';

  @override
  String get tableauBordTitre => 'Tableau de bord';

  @override
  String get tableauBordCaJour => 'CA du jour';

  @override
  String get tableauBordTicketsJour => 'Tickets du jour';

  @override
  String get tableauBordPanierMoyen => 'Panier moyen';

  @override
  String get tableauBordCaMois => 'CA du mois';

  @override
  String get tableauBordSousSeuil => 'Produits sous seuil';

  @override
  String get tableauBordCreances => 'Créances clients';

  @override
  String get tableauBordCa30Jours => 'Chiffre d\'affaires des 30 derniers jours';

  @override
  String get tableauBordPaiements => 'Encaissements par mode (30 jours)';

  @override
  String get tableauBordTopProduits => 'Top 5 produits (30 jours)';

  @override
  String get tableauBordCategories => 'Ventes par catégorie (30 jours)';

  @override
  String get tableauBordCaMensuel => 'Chiffre d\'affaires mensuel (12 mois)';

  @override
  String get tableauBordActualiser => 'Actualiser';

  @override
  String get situationTitre => 'Situation';

  @override
  String get situationRapport => 'Rapport';

  @override
  String get situationDu => 'Du (jj/mm/aaaa)';

  @override
  String get situationAu => 'Au (jj/mm/aaaa)';

  @override
  String get situationAfficher => 'Afficher';

  @override
  String get situationExportExcel => 'Exporter Excel';

  @override
  String get situationApercuPdf => 'Aperçu PDF';

  @override
  String get situationAucuneLigne => 'Aucune donnée sur la période.';

  @override
  String get situationDatesInvalides => 'Dates invalides.';

  @override
  String situationExportOk(String chemin) {
    return 'Fichier enregistré : $chemin';
  }

  @override
  String situationPeriode(String debut, String fin) {
    return 'Période du $debut au $fin';
  }

  @override
  String get rapportVentesJour => 'Ventes par jour';

  @override
  String get rapportVentesProduit => 'Ventes par produit';

  @override
  String get rapportVentesCategorie => 'Ventes par catégorie';

  @override
  String get rapportVentesClient => 'Ventes par client';

  @override
  String get rapportVentesVendeur => 'Ventes par vendeur et caisse';

  @override
  String get rapportEncaissementsMode => 'Encaissements par mode';

  @override
  String get rapportAchatsFournisseur => 'Achats par fournisseur';

  @override
  String get rapportRetours => 'Retours clients';

  @override
  String get rapportEtatStock => 'État du stock valorisé';

  @override
  String get rapportCreancesDettes => 'Créances et dettes';

  @override
  String get zakatTitre => 'Zakat';

  @override
  String get zakatIntro =>
      'Zakat sur les biens commerciaux : 2,5 % de l\'assiette si elle atteint le nissab (85 g d\'or).';

  @override
  String zakatPrixOr(String devise) {
    return 'Prix du gramme d\'or ($devise)';
  }

  @override
  String get zakatEnregistrerPrix => 'Enregistrer le cours';

  @override
  String get zakatStock => 'Stock (prix d\'achat)';

  @override
  String get zakatCaisses => 'Caisses';

  @override
  String get zakatCreances => 'Créances clients';

  @override
  String get zakatDettes => 'Dettes fournisseurs';

  @override
  String get zakatAssiette => 'Assiette';

  @override
  String get zakatNissab => 'Nissab (85 g)';

  @override
  String get zakatMontant => 'Zakat due (2,5 %)';

  @override
  String get zakatAssujetti => 'Assujetti : l\'assiette atteint le nissab.';

  @override
  String get zakatNonAssujetti => 'Non assujetti : l\'assiette est inférieure au nissab.';

  @override
  String get zakatPrixManquant => 'Renseignez le cours de l\'or pour calculer le nissab.';

  @override
  String get historiqueTitre => 'Historique';

  @override
  String get historiqueColUtilisateur => 'Utilisateur';

  @override
  String get historiqueColAction => 'Action';

  @override
  String get historiqueColEntite => 'Entité';

  @override
  String get historiqueColDetail => 'Détail';

  @override
  String get historiqueToutesEntites => 'Toutes les entités';

  @override
  String get historiqueAucun => 'Aucune opération.';

  @override
  String get parametresTitre => 'Paramètres';

  @override
  String get parametresOngletGeneral => 'Général';

  @override
  String get parametresOngletBoutique => 'Boutique';

  @override
  String get parametresOngletVente => 'Vente';

  @override
  String get parametresOngletImpression => 'Impression';

  @override
  String get parametresOngletServeur => 'Serveurs';

  @override
  String get parametresOngletSauvegarde => 'Sauvegarde';

  @override
  String get parametresEnregistre => 'Paramètres enregistrés.';

  @override
  String get parametresBoutiqueNom => 'Nom de la boutique';

  @override
  String get parametresBoutiqueRc => 'Registre de commerce (RC)';

  @override
  String get parametresBoutiqueNif => 'NIF';

  @override
  String get parametresBoutiqueAdresse => 'Adresse';

  @override
  String get parametresBoutiqueTelephone => 'Téléphone';

  @override
  String get parametresBoutiqueEmail => 'E-mail';

  @override
  String get parametresMarge => 'Marge par défaut (%)';

  @override
  String get parametresDevise => 'Devise';

  @override
  String get parametresSeuil => 'Seuil de stock global';

  @override
  String get parametresFidelite => 'Programme de fidélité';

  @override
  String get parametresPoints => 'Points par dinar';

  @override
  String get parametresGardeStock => 'Garde de stock : toujours active (aucune vente sans stock).';

  @override
  String get parametresImprimanteType => 'Type d\'imprimante';

  @override
  String get parametresImprimanteAdresse => 'File d\'attente Windows ou adresse IP:port';

  @override
  String get parametresImprimanteLargeur => 'Largeur du ticket';

  @override
  String get parametresImprimanteNormale => 'Normale (dialogue d\'impression)';

  @override
  String get parametresImprimanteUsb => 'USB (spouleur Windows)';

  @override
  String get parametresImprimanteReseau => 'Réseau (IP:port)';

  @override
  String get parametresImprimanteBluetooth => 'Bluetooth';

  @override
  String get parametresServeurUrl => 'URL du serveur CaisseDZ';

  @override
  String get parametresServeurCle => 'Clé API';

  @override
  String get parametresMantoujUrl => 'URL du catalogue Mantouj';

  @override
  String get parametresErreurNom => 'Le nom de la boutique est obligatoire.';

  @override
  String get parametresErreurValeur => 'Valeur invalide.';

  @override
  String get parametresErreurImprimanteType => 'Type d\'imprimante invalide.';

  @override
  String get parametresErreurImprimanteAdresse => 'Indiquez la file d\'attente ou l\'adresse de l\'imprimante.';

  @override
  String get sauvegardeIntro =>
      'La sauvegarde est chiffrée avec le mot de passe choisi : conservez-le, il sera demandé à la restauration.';

  @override
  String get sauvegardeCreer => 'Créer une sauvegarde';

  @override
  String get sauvegardeRestaurer => 'Restaurer une sauvegarde';

  @override
  String get sauvegardeMotDePasse => 'Mot de passe de la sauvegarde';

  @override
  String get sauvegardeFichier => 'Fichier de sauvegarde';

  @override
  String get sauvegardeChoisirFichier => 'Choisir le fichier…';

  @override
  String sauvegardeOk(String chemin) {
    return 'Sauvegarde enregistrée : $chemin';
  }

  @override
  String sauvegardeInfo(String boutique, int ventes, int produits, int version) {
    return 'Boutique « $boutique », $ventes ventes, $produits produits, schéma v$version.';
  }

  @override
  String get sauvegardeConfirmerRestauration =>
      'Restaurer cette sauvegarde ? Les données actuelles seront remplacées au prochain démarrage.';

  @override
  String get sauvegardeRestaurationPreparee => 'Restauration prête : fermez puis relancez CaisseDZ pour l\'appliquer.';

  @override
  String get sauvegardeRestaurationEnAttente =>
      'Une restauration est en attente : elle sera appliquée au prochain démarrage.';

  @override
  String get sauvegardeAnnulerRestauration => 'Annuler la restauration';

  @override
  String get sauvegardeErreurMotDePasse => 'Mot de passe invalide ou fichier corrompu.';

  @override
  String get sauvegardeErreurMotDePasseVide => 'Saisissez un mot de passe.';

  @override
  String get sauvegardeErreurFichier => 'Fichier introuvable.';

  @override
  String sauvegardeErreurChemin(String detail) {
    return 'Emplacement invalide : $detail';
  }

  @override
  String get dsContinuer => 'Continuer';

  @override
  String get dsCompris => 'Compris';

  @override
  String get dsLibelle => 'Libellé';

  @override
  String get dsCochezLignes => 'Cochez une ou plusieurs lignes';

  @override
  String get dsCliquezLigne => 'Cliquez une ligne · double-clic pour valider';

  @override
  String get dsAjouter => 'Ajouter';

  @override
  String get dsChoisir => 'Choisir';

  @override
  String get dsAnnules => 'annulés';

  @override
  String get dsSupprimes => 'supprimés';

  @override
  String get dsActiver => 'Activer';

  @override
  String get dsActives => 'activés';

  @override
  String get dsDesactiver => 'Désactiver';

  @override
  String get dsDesactives => 'désactivés';

  @override
  String dsLotPartiel(String ok, int total, String participe) {
    return '$ok sur $total seront $participe.';
  }

  @override
  String get dsLotVerifier => 'Vérifiez la sélection avant de confirmer.';

  @override
  String dsLotBloques(String n, String motif) {
    return '$n ne peuvent pas être traités : $motif.';
  }

  @override
  String get dsMotifAnnulation => 'Motif d\'annulation';

  @override
  String get dsMotifIndice => 'Ex. erreur de saisie, client absent…';

  @override
  String get dsObligatoires => 'Obligatoires';

  @override
  String get dsToujoursAffichees => 'Toujours affichées';

  @override
  String get dsColonnesParDefaut => 'Colonnes par défaut';

  @override
  String get dsAutresColonnes => 'Autres colonnes';

  @override
  String get dsColonnesTitre => 'Afficher / masquer les colonnes';

  @override
  String dsColonnesVisibles(int n, int total) {
    return '$n sur $total colonnes visibles';
  }

  @override
  String get dsAppliquer => 'Appliquer';

  @override
  String get dsRechercherColonne => 'Rechercher une colonne…';

  @override
  String get dsAfficherTout => 'Afficher tout';

  @override
  String get dsMasquerTout => 'Masquer tout';

  @override
  String get dsParDefaut => 'Par défaut';

  @override
  String get dsAucuneColonne => 'Aucune colonne trouvée';

  @override
  String get dsGarderSelection => 'Garder ma sélection';

  @override
  String get dsGarderSelectionAide => 'Sinon, les colonnes par défaut sont rétablies à la prochaine ouverture';

  @override
  String get dsParPage => 'par page';

  @override
  String get dsToutDeselectionner => 'Tout désélectionner';

  @override
  String dsSelectionneSur(int n, int total) {
    return '$n / $total sélectionné(s)';
  }

  @override
  String get dsSelectionnezUne => 'Sélectionnez une seule ligne';

  @override
  String get dsSelectionnezAuMoins => 'Sélectionnez au moins une ligne';

  @override
  String get dsAucunElement => 'Aucun élément';

  @override
  String get dsDoubleClicDetail => 'Double-clic : afficher le détail';

  @override
  String dsColonnesMasquees(int n, int total) {
    return 'Afficher / masquer les colonnes · $n/$total';
  }

  @override
  String get dsFiltres => 'Filtres';

  @override
  String get dsFiltrer => 'Filtrer';

  @override
  String get dsReinitialiser => 'Réinitialiser';

  @override
  String dsActifs(int n) {
    return '$n actif(s)';
  }

  @override
  String get dsExporter => 'Exporter';

  @override
  String get dsToutExporter => 'Tout exporter';

  @override
  String get dsSelectionSeulement => 'Sélection seulement';

  @override
  String get dsRetour => 'Retour';

  @override
  String get dsEffacer => 'Effacer';

  @override
  String get dsThemeClair => 'Thème clair';

  @override
  String get dsThemeSombre => 'Thème sombre';

  @override
  String get dsEnLigne => 'En ligne';

  @override
  String get dsHorsLigne => 'Hors ligne';

  @override
  String get dsSynchronise => 'Synchronisé';

  @override
  String get dsHorsLigneLocal => 'Hors ligne — les données restent locales';

  @override
  String get dsAlertes => 'Alertes';

  @override
  String get dsMenuModules => 'Menu des modules (Ctrl M)';

  @override
  String get dsReplier => 'Replier';

  @override
  String get dsDeplier => 'Déplier';

  @override
  String get dsFavori => 'Favori';

  @override
  String get dsAjouterFavoris => 'Ajouter aux favoris';

  @override
  String get dsRetirerFavoris => 'Retirer des favoris';

  @override
  String get dsFavorisComplets => 'Favoris complets';

  @override
  String get dsAucunModule => 'Aucun module';

  @override
  String get dsModules => 'Modules';

  @override
  String get dsRechercherModule => 'Rechercher un module…';

  @override
  String get dsMagasin => 'Magasin';

  @override
  String get dsPagePrecedente => 'Page précédente';

  @override
  String get dsPageSuivante => 'Page suivante';

  @override
  String get dsChoisirListe => 'Choisir dans la liste';

  @override
  String get dsRechercher => 'Rechercher';

  @override
  String get dsSelectionner => 'Sélectionner';

  @override
  String get dsAucunResultat => 'Aucun résultat';

  @override
  String get dsGateLicenceTitre => 'Disponible avec le palier Avancé';

  @override
  String get dsGateLicenceAction => 'Passer au palier Avancé';

  @override
  String get dsGateRoleTitre => 'Accès non autorisé';

  @override
  String get dsGateRoleAction => 'Demander l\'accès';

  @override
  String get dsGateRefuseTitre => 'Accès refusé';

  @override
  String get dsGateRefuseAction => 'Retour au tableau de bord';

  @override
  String get dsGateActivationTitre => 'Application non activée';

  @override
  String get dsGateActivationAction => 'Activer';

  @override
  String dsGateRefuseDetail(String module) {
    return 'Votre rôle ne donne pas accès au module $module. Demandez à l\'administrateur de modifier vos permissions.';
  }

  @override
  String get dsPermTout => 'Tout sélectionner';

  @override
  String get dsPermRien => 'Tout désélectionner';

  @override
  String get dsPermReserve => 'Réservé à l\'administrateur';

  @override
  String get dsPosProduit => 'Produit';

  @override
  String get dsPosColis => 'Colis';

  @override
  String get dsPosQte => 'Qté';

  @override
  String get dsPosPieces => 'Pièces';

  @override
  String get dsPosMontant => 'Montant';

  @override
  String get dsPosMoins => 'Moins';

  @override
  String get dsPosPlus => 'Plus';

  @override
  String get dsPosRetirer => 'Retirer';

  @override
  String get dsPosChangerColis => 'Changer le colis';

  @override
  String get dsPosOuverte => 'Ouverte';

  @override
  String get dsPosFermee => 'Fermée';

  @override
  String get dsPosAucuneSession => 'Aucune session ouverte';

  @override
  String dsPosOuverteA(String heure) {
    return 'Ouverte à $heure';
  }

  @override
  String dsPosPar(String nom) {
    return 'par $nom';
  }

  @override
  String get dsPosSoldeCourant => 'Solde courant';

  @override
  String get dsPosMouvement => 'Mouvement';

  @override
  String get dsPosCloturer => 'Clôturer';

  @override
  String get dsPosOuvrir => 'Ouvrir';

  @override
  String get dsPosOuvrirCaisse => 'Ouvrir la caisse';

  @override
  String get dsPosEffacer => 'Effacer';

  @override
  String get dsPosToutEffacer => 'Tout effacer';

  @override
  String get dsPosTotalAvantRemise => 'Total avant remise';

  @override
  String get dsPosRemise => 'Remise';

  @override
  String get dsPosTotalAPayer => 'Total à payer';

  @override
  String get dsPosPaiementComplet => 'Paiement complet';

  @override
  String get dsPosMontantPaye => 'Montant payé';

  @override
  String get dsPosARendre => 'À rendre';

  @override
  String get dsPosMontantExact => 'Montant exact';

  @override
  String get dsPosPartielImpossible => 'Paiement partiel impossible pour le client comptoir';

  @override
  String get dsPosResteCredit => 'Reste (crédit client)';

  @override
  String get dsPosRupture => 'Rupture';

  @override
  String dsPosEnStock(String n) {
    return '$n en stock';
  }

  @override
  String get dsPosEntree => 'Entrée';

  @override
  String get dsPosEntreeRapide => 'Nouvelle entrée rapide de ce produit';

  @override
  String get dsPosSmartScan => 'Smart Scan';

  @override
  String dsPosScansMois(int n) {
    return '/ $n scans ce mois';
  }

  @override
  String dsPosRestants(int n) {
    return '$n restants';
  }

  @override
  String dsPosRenouvellement(String date) {
    return 'Renouvellement $date';
  }

  @override
  String get dsPosQuotaHorsLigne => 'Hors ligne — quota indisponible, la caisse continue de fonctionner.';

  @override
  String get dsPosActualiser => 'Actualiser';

  @override
  String get dsPosNouvelleVente => 'Nouvelle vente';

  @override
  String get dsPosVentes => 'ventes';

  @override
  String get dsPosFermerVente => 'Fermer cette vente';

  @override
  String dsPosMaxVentes(int n) {
    return 'Maximum $n ventes en parallèle';
  }

  @override
  String dsPosArticles(int n) {
    return '$n article(s)';
  }

  @override
  String get dsPosSousTotal => 'Sous-total';

  @override
  String get dsPosLigneArticles => 'Articles';

  @override
  String get dsPosLigneQuantite => 'Quantité';

  @override
  String get dsPosLigneAjouter => 'Ajouter des produits';

  @override
  String get dsPosLigneVide => 'Aucun produit — ajoutez-en avec le bouton ci-dessous.';

  @override
  String get dsPosLigneRetirer => 'Retirer la ligne';

  @override
  String get dsPosCode => 'Code';

  @override
  String get dsPosPrix => 'Prix';

  @override
  String get dsCalcUtiliser => 'Utiliser le résultat';

  @override
  String get dsBarcodeAucun => 'Ce produit n\'a pas de code-barres.';

  @override
  String get dsBarcodeGenerer => 'Générer';

  @override
  String get dsBarcodeFormatLibre => 'Format libre (non EAN-13)';

  @override
  String get dsBarcodeCopier => 'Copier';

  @override
  String get dsBarcodeImprimer => 'Imprimer l\'étiquette';

  @override
  String get moduleUtilisateurs => 'Utilisateurs';

  @override
  String get connexionSousTitre => 'Connectez-vous pour ouvrir votre caisse.';

  @override
  String get connexionAfficher => 'Afficher';

  @override
  String get connexionMasquer => 'Masquer';

  @override
  String get connexionResterConnecte => 'Rester connecté';

  @override
  String get connexionMotDePasseOublie => 'Mot de passe oublié ? Voyez l\'administrateur';

  @override
  String get connexionHorsLigne => 'Fonctionne hors ligne · données stockées sur ce poste';

  @override
  String get connexionDemoNonActivee =>
      'Application non activée : connectez-vous avec demo / demo pour l\'essayer, ou saisissez une clé.';

  @override
  String get connexionErreurNonActivee => 'Application non activée : seul le compte demo / demo est disponible.';

  @override
  String get connexionNonActivee => 'Non activée';

  @override
  String connexionVersion(String version, String licence) {
    return 'Version $version · $licence';
  }

  @override
  String get connexionNouveaute => 'Nouveau · Smart Scan IA';

  @override
  String get connexionAccroche => 'Ventes, stock et caisse — simple, rapide et sécurisé.';

  @override
  String get connexionAccrocheDetail =>
      'Scannez vos bons d\'achat, suivez plusieurs magasins et encaissez en français, arabe ou anglais.';

  @override
  String get connexionAtoutHorsLigne => 'Hors ligne';

  @override
  String get connexionAtoutMultiMagasin => 'Multi-magasin';

  @override
  String get activationNonActivee => 'Non activée';

  @override
  String activationPalierDetecte(String palier) {
    return 'Palier détecté : $palier';
  }

  @override
  String get activationPalierBasic => 'Basic (1 magasin, 1 caisse)';

  @override
  String get activationPalierAvance => 'Avancé (multi-magasins, multi-caisses)';

  @override
  String get activationUnMagasin => '1 magasin';

  @override
  String get activationUneCaisse => '1 caisse';

  @override
  String get activationMagasinsIllimites => 'Magasins illimités et transferts';

  @override
  String get activationPlusieursCaisses => 'Plusieurs caisses';

  @override
  String get activationSmartScanQuota => 'Smart Scan IA selon quota serveur';

  @override
  String get activationRetourConnexion => 'Connexion';

  @override
  String get activationReussieTitre => 'Application activée';

  @override
  String activationReussieDetail(String palier, String poste) {
    return 'Palier $palier · lié au poste $poste.';
  }

  @override
  String get activationContinuer => 'Continuer';

  @override
  String get configDescription => 'Quatre étapes pour configurer la boutique. Tout reste modifiable dans Paramètres.';

  @override
  String get configEtapeLangue => 'Langue & devise';

  @override
  String get configEtapeLangueDetail => 'Affichage';

  @override
  String get configEtapeBoutiqueDetail => 'Ticket et mentions';

  @override
  String get configEtapePaiements => 'Paiements';

  @override
  String get configEtapePaiementsDetail => 'Moyens acceptés';

  @override
  String get configEtapeVenteDetail => 'Prix et alertes';

  @override
  String get configDecimales => 'Décimales des quantités';

  @override
  String get configDecimalesAide => '3 pour la vente au poids';

  @override
  String get configBoutiqueNomIndice => 'Ex. Supérette Benali';

  @override
  String get configBoutiqueAdresseIndice => 'Rue, commune, wilaya';

  @override
  String get configBoutiqueNis => 'NIS';

  @override
  String get configBoutiqueArticle => 'Article d\'imposition';

  @override
  String get configBoutiqueMessage => 'Message du ticket';

  @override
  String get configBoutiqueMessageIndice => 'Merci de votre visite !';

  @override
  String get configSeuilAide => 'Seuil global, remplacé par celui du produit s\'il est défini';

  @override
  String get configFideliteActive => 'Points de fidélité';

  @override
  String get configPlusTard => 'Plus tard';

  @override
  String get compteIdentifiant => 'Nom d\'utilisateur';

  @override
  String compteIdentite(String identifiant, String acces) {
    return '@$identifiant · dernier accès $acces';
  }

  @override
  String get compteJamaisConnecte => 'première connexion';

  @override
  String get compteOngletProfil => 'Profil';

  @override
  String get compteOngletMotDePasse => 'Mot de passe';

  @override
  String get compteCode => 'Code';

  @override
  String get compteMagasinDefaut => 'Magasin par défaut';

  @override
  String get compteConfirmer => 'Confirmer';

  @override
  String compteMotDePasseAide(int n) {
    return '$n caractères minimum';
  }

  @override
  String get comptePreferencesAide => 'Ces préférences s\'appliquent à ce poste.';

  @override
  String get alertesTitre => 'Alertes du jour';

  @override
  String alertesResume(int urgentes, int surveiller) {
    String _temp0 = intl.Intl.pluralLogic(urgentes, locale: localeName, other: '$urgentes urgentes', one: '1 urgente');
    return '$_temp0 · $surveiller à surveiller';
  }

  @override
  String get alertesToutTraite => 'Tout est traité';

  @override
  String get alertesUrgent => 'Urgent';

  @override
  String get alertesASurveiller => 'À surveiller';

  @override
  String get alertesNePlusAfficher => 'Ne plus afficher aujourd\'hui';

  @override
  String get alertesLienParametres => 'Paramètres › Alertes';

  @override
  String get alertesOuvrirModule => 'Ouvrir le module';

  @override
  String get alertesMarquerTraite => 'Marquer comme traité';

  @override
  String get alertesRienTitre => 'Rien à signaler';

  @override
  String get alertesRienDetail => 'Cette famille d\'alertes est traitée.';

  @override
  String get alertesMesureRupture => 'Rupture';

  @override
  String alertesOuverteDepuis(String date) {
    return 'Ouverte depuis le $date';
  }

  @override
  String alertesJours(int n) {
    return 'J−$n';
  }

  @override
  String alertesDernierDocument(String code, String date) {
    return '$code · dernier document le $date';
  }

  @override
  String get alertesRupture => 'Ruptures et seuils';

  @override
  String get alertesRuptureAide => 'Produits épuisés ou sous leur seuil d\'alerte.';

  @override
  String get alertesRuptureAction => 'Créer une liste de besoins';

  @override
  String get alertesRuptureLigne => 'Commander';

  @override
  String get alertesExpire => 'Produits expirés';

  @override
  String get alertesExpireAide => 'Lots périmés encore en stock — à sortir avant la vente.';

  @override
  String get alertesExpireAction => 'Sortie « Périmé »';

  @override
  String get alertesExpireLigne => 'Sortir';

  @override
  String get alertesSessions => 'Sessions ouvertes';

  @override
  String get alertesSessionsAide => 'Sessions de caisse ouvertes depuis un jour précédent.';

  @override
  String get alertesSessionsAction => 'Clôturer';

  @override
  String get alertesBientot => 'Bientôt expirés';

  @override
  String get alertesBientotAide => 'Lots qui expirent dans les 30 prochains jours.';

  @override
  String get alertesBientotAction => 'Créer une remise';

  @override
  String get alertesBientotLigne => 'Remise';

  @override
  String get alertesClients => 'Crédits clients';

  @override
  String get alertesClientsAide => 'Les plus gros crédits en cours.';

  @override
  String get alertesClientsAction => 'Nouveau versement';

  @override
  String get alertesClientsLigne => 'Encaisser';

  @override
  String get alertesFournisseurs => 'Dettes fournisseurs';

  @override
  String get alertesFournisseursAide => 'Les plus grosses dettes et leur dernier achat.';

  @override
  String get alertesFournisseursAction => 'Nouveau règlement';

  @override
  String get alertesFournisseursLigne => 'Régler';

  @override
  String get dsPeriodeAujourdhui => 'Aujourd\'hui';

  @override
  String get dsPeriodeHier => 'Hier';

  @override
  String get dsPeriodeSemaine => 'Cette semaine';

  @override
  String get dsPeriodeSemaineDerniere => 'Semaine dernière';

  @override
  String get dsPeriodeMois => 'Ce mois';

  @override
  String get dsPeriodeMoisDernier => 'Mois dernier';

  @override
  String get dsPeriode7Jours => '7 derniers jours';

  @override
  String get dsPeriode30Jours => '30 derniers jours';

  @override
  String get dsPeriodeAnnee => 'Cette année';

  @override
  String get dsPeriodeAnneeDerniere => 'Année dernière';

  @override
  String get dsDu => 'Du';

  @override
  String get dsAu => 'Au';

  @override
  String get dsPeriodeRapide => 'Période rapide';

  @override
  String get dsRechercherIndice => 'Rechercher…';

  @override
  String get dsAffichageGrille => 'Affichage grille';

  @override
  String get dsAffichageListe => 'Affichage liste';

  @override
  String get dsModifiezRecherche => 'Modifiez la recherche ou les filtres.';

  @override
  String get auditTitre => 'Traçabilité';

  @override
  String get auditCreePar => 'Créé par';

  @override
  String get auditAnnuleLe => 'Annulé le';

  @override
  String get auditAnnulePar => 'Annulé par';

  @override
  String get auditMotif => 'Motif';

  @override
  String get dsAnnuler => 'Annuler';

  @override
  String get dsValider => 'Valider';

  @override
  String get statutActif => 'Actif';

  @override
  String get statutInactif => 'Inactif';

  @override
  String get statutPaye => 'Payé';

  @override
  String get statutPartiel => 'Partiel';

  @override
  String get statutCredit => 'Crédit';

  @override
  String get statutAnnule => 'Annulé';

  @override
  String get statutOuverte => 'Ouverte';

  @override
  String get statutFermee => 'Fermée';

  @override
  String get statutCloturee => 'Clôturée';

  @override
  String get statutRupture => 'Rupture';

  @override
  String get statutSeuil => 'Sous seuil';

  @override
  String get statutExpire => 'Expiré';

  @override
  String get statutBientotExpire => 'Expire bientôt';

  @override
  String get statutBrouillon => 'Brouillon';

  @override
  String get statutValide => 'Validé';

  @override
  String get statutEntree => 'Entrée';

  @override
  String get statutSortie => 'Sortie';

  @override
  String get statutRetourne => 'Retourné';

  @override
  String get statutClient => 'Client';

  @override
  String get statutFournisseur => 'Fournisseur';

  @override
  String get statutRecu => 'Reçu';

  @override
  String get statutTraite => 'Traité';

  @override
  String get tiers15Chiffres => '15 chiffres';

  @override
  String get tiers20Chiffres => '20 chiffres';

  @override
  String get tiersActivite => 'Activité';

  @override
  String get tiersActiviteIndice => 'Ex. alimentation générale';

  @override
  String get tiersAdministratifBanque => 'Administratif & banque';

  @override
  String get tiersAdresseIndice => 'Rue, commune';

  @override
  String get tiersAvance => 'Avance';

  @override
  String get tiersBanque => 'Banque';

  @override
  String get tiersBloqueCredit => 'Crédit en cours — soldez-le d\'abord';

  @override
  String get tiersBloqueDejaAnnule => 'Déjà annulé';

  @override
  String get tiersBloqueSysteme => 'Élément système';

  @override
  String get tiersChampsObligatoires => 'Les champs marqués * sont obligatoires';

  @override
  String get tiersChoisir => 'Choisir…';

  @override
  String get tiersChoisirClient => 'Choisir un client';

  @override
  String get tiersChoisirFournisseur => 'Choisir un fournisseur';

  @override
  String get tiersCodeAuto => 'Généré automatiquement';

  @override
  String get tiersContact => 'Contact';

  @override
  String get tiersCredit => 'Crédit';

  @override
  String get tiersCreditAide => 'Crédit (achats)';

  @override
  String get tiersDebit => 'Débit';

  @override
  String get tiersDebitAide => 'Débit (paiements, retours)';

  @override
  String get tiersDernierAchat => 'Dernier achat';

  @override
  String get tiersDerniereEntree => 'Dernière entrée';

  @override
  String get tiersDernieresEntrees => 'Dernières entrées';

  @override
  String get tiersDerniersPaniers => 'Derniers paniers';

  @override
  String tiersDescriptionClients(int n, int nb) {
    return '$n clients · $nb avec un crédit en cours';
  }

  @override
  String tiersDescriptionFournisseurs(int n, int nb) {
    return '$n fournisseurs · $nb avec un crédit en cours';
  }

  @override
  String get tiersDetail => 'Détail';

  @override
  String get tiersEntiteClient => 'client';

  @override
  String get tiersEntiteClientMaj => 'Client';

  @override
  String get tiersEntiteClients => 'clients';

  @override
  String get tiersEntiteFournisseur => 'fournisseur';

  @override
  String get tiersEntiteFournisseurMaj => 'Fournisseur';

  @override
  String get tiersEntiteFournisseurs => 'fournisseurs';

  @override
  String get tiersErreurNomExistant => 'Ce nom existe déjà';

  @override
  String get tiersEtat => 'État';

  @override
  String get tiersFax => 'Fax';

  @override
  String get tiersFormatNif => 'Le NIF doit contenir 15 chiffres';

  @override
  String get tiersFormatTelephone => 'Format attendu : 0X XX XX XX XX';

  @override
  String get tiersInfosAdministratives => 'Informations administratives';

  @override
  String get tiersInfosBancaires => 'Informations bancaires';

  @override
  String get tiersInfosGenerales => 'Informations générales';

  @override
  String get tiersKpiClientsActifs => 'Clients actifs';

  @override
  String get tiersKpiCreditClients => 'Crédit clients';

  @override
  String get tiersKpiCreditFournisseurs => 'Crédit fournisseurs';

  @override
  String get tiersKpiFournisseursActifs => 'Fournisseurs actifs';

  @override
  String get tiersKpiPoints => 'Points fidélité';

  @override
  String get tiersModifierClient => 'Modifier le client';

  @override
  String get tiersModifierFournisseur => 'Modifier le fournisseur';

  @override
  String get tiersNatureAchat => 'Achat';

  @override
  String get tiersNatureRetour => 'Retour';

  @override
  String get tiersNatureVente => 'Vente';

  @override
  String get tiersNatureVersement => 'Versement';

  @override
  String get tiersNatureVersementRetour => 'Versement retour';

  @override
  String get tiersNomIndice => 'Nom ou raison sociale';

  @override
  String get tiersNoteInterne => 'Note interne';

  @override
  String get tiersNrc => 'N° RC';

  @override
  String get tiersObservation => 'Observation';

  @override
  String get tiersPanier => 'Panier';

  @override
  String tiersPoints(int n) {
    return '$n points';
  }

  @override
  String get tiersRechercheIndice => 'Nom, code ou téléphone…';

  @override
  String get tiersReference => 'Référence';

  @override
  String get tiersReleveClient => 'Relevé client';

  @override
  String get tiersReleveFournisseur => 'Relevé fournisseur';

  @override
  String get tiersReste => 'Reste';

  @override
  String get tiersSituation => 'Situation';

  @override
  String tiersSituationDe(String nom) {
    return 'Situation — $nom';
  }

  @override
  String get tiersSolde => 'Solde';

  @override
  String get tiersSoldeDu => 'Solde dû';

  @override
  String get tiersStatut => 'Statut';

  @override
  String get tiersTotalAchats => 'Total achats';

  @override
  String get tiersTotalPaye => 'Total payé';

  @override
  String get tiersTotalRetours => 'Total retours';

  @override
  String get tiersTous => 'Tous';

  @override
  String get tiersToutes => 'Toutes';

  @override
  String get tiersType => 'Type';

  @override
  String get tiersVersement => 'Versement';

  @override
  String get tiersWilaya => 'Wilaya';

  @override
  String get versementAideClient =>
      'Le montant est imputé sur les paniers à crédit du client, du plus ancien au plus récent.';

  @override
  String get versementAideFournisseur =>
      'Le montant est imputé sur les entrées à crédit du fournisseur, de la plus ancienne à la plus récente.';

  @override
  String get versementAideRetourClient => 'Argent rendu au client (avance ou trop-perçu) : sortie de caisse.';

  @override
  String get versementAideRetourFournisseur => 'Argent remboursé par le fournisseur : entrée en caisse.';

  @override
  String get versementAucunBeneficiaire => 'Aucun bénéficiaire choisi';

  @override
  String get versementAvanceTropPercu => 'Avance / trop-perçu après ce versement';

  @override
  String get versementBeneficiaire => 'Bénéficiaire';

  @override
  String get versementCaisse => 'Caisse';

  @override
  String get versementCliquezChoisir => 'Cliquez pour choisir';

  @override
  String get versementCompteSolde => 'Compte soldé après ce versement';

  @override
  String versementCreditActuel(String montant) {
    return 'Crédit actuel : $montant';
  }

  @override
  String get versementCreditRestant => 'Crédit restant après ce versement';

  @override
  String get versementEntite => 'versement';

  @override
  String get versementEntites => 'versements';

  @override
  String get versementKpiEncaisse => 'Montant encaissé';

  @override
  String get versementKpiNombre => 'Versements';

  @override
  String get versementKpiPaye => 'Montant payé';

  @override
  String get versementKpiRetour => 'Versements retour';

  @override
  String get versementModifier => 'Modifier le versement';

  @override
  String get versementNumero => 'Numéro';

  @override
  String get versementObsIndice => 'Observation (facultatif)';

  @override
  String get versementRetourModifier => 'Modifier le versement retour';

  @override
  String get versementRetourNouveau => 'Versement retour';

  @override
  String get versementRetourTitre => 'Versement retour';

  @override
  String get versementSens => 'Sens';

  @override
  String get versementSensPaye => 'Payé';

  @override
  String get versementSensRecu => 'Reçu';

  @override
  String get versementSensRetour => 'Retour';

  @override
  String get versementTitre => 'Versement';

  @override
  String get versementType => 'Type';

  @override
  String get dsChargement => 'Chargement…';

  @override
  String get tableauBordOnglet => 'Tableau de bord';

  @override
  String get situationOnglet => 'Situation';

  @override
  String tableauBordDescription(String au, String du, int n) {
    return 'Du $du au $au, comparé aux $n jours précédents.';
  }

  @override
  String get situationDescription => 'Analyses détaillées sur la période — chaque vue est exportable en Excel et PDF.';

  @override
  String get tableauBordJour => 'Jour';

  @override
  String get tableauBordSemaine => 'Semaine';

  @override
  String get tableauBordMois => 'Mois';

  @override
  String get tableauBordPeriode => 'Période';

  @override
  String get tableauBordChoisirPeriode => 'Choisir la période';

  @override
  String get tableauBordIndicateur => 'Indicateur';

  @override
  String get tableauBordPeriodeCourante => 'Période';

  @override
  String get tableauBordPeriodePrecedente => 'Période précédente';

  @override
  String get tableauBordVentes => 'Ventes';

  @override
  String get tableauBordVentesInfo => 'Total des paniers encaissés sur la période';

  @override
  String get tableauBordVsPrecedente => 'vs période précédente';

  @override
  String get tableauBordPrecedenteInfo => 'Même nombre de jours, juste avant la période';

  @override
  String get tableauBordAchats => 'Achats';

  @override
  String get tableauBordAchatsInfo => 'Entrées validées (bons d\'achat)';

  @override
  String get tableauBordNet => 'Net';

  @override
  String get tableauBordNetInfo => 'Ventes − achats de la période';

  @override
  String get tableauBordDetteFournisseurs => 'Dette fournisseurs';

  @override
  String get tableauBordDetteInfo => 'Restes à payer sur les entrées';

  @override
  String get tableauBordCreditClients => 'Crédit clients';

  @override
  String get tableauBordCreditInfo => 'Restes dus sur les paniers';

  @override
  String get tableauBordCourbeVentes => 'Courbe des ventes';

  @override
  String get tableauBordModesPaiement => 'Modes de paiement';

  @override
  String get tableauBordTotal => 'Total';

  @override
  String get tableauBordCaParJour => 'Chiffre d\'affaires par jour';

  @override
  String get tableauBordVentesCaissier => 'Ventes par caissier';

  @override
  String tableauBordTickets(int n) {
    return '$n tickets';
  }

  @override
  String tableauBordUnites(String qte) {
    return '$qte u.';
  }

  @override
  String get tableauBordDernieresVentes => 'Dernières ventes';

  @override
  String get tableauBordPanier => 'N° panier';

  @override
  String get tableauBordHeure => 'Heure';

  @override
  String get tableauBordPaiement => 'Paiement';

  @override
  String get tableauBordRuptures => 'Produits en rupture';

  @override
  String get tableauBordAucuneRupture => 'Aucun produit en rupture';

  @override
  String get tableauBordProduit => 'Produit';

  @override
  String get tableauBordStock => 'Stock';

  @override
  String get situationGroupeTresorerie => 'Trésorerie';

  @override
  String get situationGroupeStock => 'Stock';

  @override
  String get situationGroupeVentes => 'Ventes';

  @override
  String get situationGroupeMarges => 'Marges';

  @override
  String get situationGroupeTiers => 'Tiers';

  @override
  String get situationMvc => 'Mouvement caisse';

  @override
  String get situationMvp => 'Mouvement produit';

  @override
  String get situationRcp => 'Recette par panier';

  @override
  String get situationRcpr => 'Recette par produit';

  @override
  String get situationMgp => 'Marge par panier';

  @override
  String get situationMgper => 'Marge par période';

  @override
  String get situationInv => 'Inventaire';

  @override
  String get situationCout => 'Coût produit';

  @override
  String get situationScli => 'Situation client';

  @override
  String get situationSfrn => 'Situation fournisseur';

  @override
  String get situationEntrees => 'Entrées';

  @override
  String get situationSorties => 'Sorties';

  @override
  String get situationSoldeNet => 'Solde net';

  @override
  String get situationRetours => 'Retours';

  @override
  String get situationStockInitial => 'Stock initial';

  @override
  String get situationStockFinal => 'Stock final';

  @override
  String get situationCaissier => 'Caissier';

  @override
  String get situationPaye => 'Payé';

  @override
  String get situationPaniers => 'Paniers';

  @override
  String get situationRecette => 'Recette';

  @override
  String get situationPanierMoyen => 'Panier moyen';

  @override
  String get situationCategorie => 'Catégorie';

  @override
  String get situationQuantite => 'Quantité';

  @override
  String get situationPrixMoyen => 'Prix moyen';

  @override
  String get situationProduitsVendus => 'Produits vendus';

  @override
  String get situationVente => 'Vente';

  @override
  String get situationCoutLibelle => 'Coût';

  @override
  String get situationMarge => 'Marge';

  @override
  String get situationTaux => 'Taux';

  @override
  String get situationCa => 'CA';

  @override
  String get situationTauxMoyen => 'Taux moyen';

  @override
  String get situationMargeParPeriode => 'Marge par période';

  @override
  String get situationRegrouper => 'Regrouper';

  @override
  String get situationParJour => 'Par jour';

  @override
  String get situationParSemaine => 'Par semaine';

  @override
  String get situationParMois => 'Par mois';

  @override
  String get situationMagasin => 'Magasin';

  @override
  String get situationTheorique => 'Théorique';

  @override
  String get situationCompte => 'Compté';

  @override
  String get situationEcart => 'Écart';

  @override
  String get situationValeur => 'Valeur';

  @override
  String get situationProduitsComptes => 'Produits comptés';

  @override
  String get situationEcarts => 'Écarts';

  @override
  String get situationValeurEcart => 'Valeur de l\'écart';

  @override
  String get situationValiderInventaire => 'Valider l\'inventaire';

  @override
  String get situationInventaireMagasin => 'Choisissez un magasin pour valider l\'inventaire.';

  @override
  String get situationAucunEcart => 'Aucun écart à enregistrer.';

  @override
  String situationConfirmerInventaire(int n) {
    return '$n produit(s) seront ajustés au stock compté. Continuer ?';
  }

  @override
  String get situationInventaireValide => 'Inventaire validé';

  @override
  String situationProduitsAjustes(int n) {
    return '$n produit(s) ajusté(s)';
  }

  @override
  String get situationDernierAchat => 'Dernier achat';

  @override
  String get situationCmp => 'Coût moyen pondéré';

  @override
  String get situationMin => 'Min';

  @override
  String get situationMax => 'Max';

  @override
  String get situationPrixVente => 'Prix de vente';

  @override
  String get situationProduits => 'Produits';

  @override
  String get situationMargeMoyenne => 'Marge moyenne';

  @override
  String get situationSous15 => 'Sous 15 %';

  @override
  String get situationAchats => 'Achats';

  @override
  String get situationDette => 'Dette';

  @override
  String get situationDettes => 'Dettes';

  @override
  String get situationCreditTotal => 'Crédit total';
}
