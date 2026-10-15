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
  String get permVoirPrixAchat => 'Voir le prix d\'achat';

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
  String get posMaxPaniers => '5 ventes en parallèle au maximum.';

  @override
  String get posReste => 'Reste';

  @override
  String get posPointsGagnes => 'Points gagnés';

  @override
  String get posClientPassage => 'Client de passage';

  @override
  String get posChoisirClient => 'Choisir un client';

  @override
  String get posCalculatrice => 'Calculatrice (F9)';

  @override
  String get posAide => 'Raccourcis clavier (F1)';

  @override
  String get posSessionAucune => 'Aucune session de caisse ouverte : ouvrez une session pour encaisser.';

  @override
  String get posSessionCaisse => 'Caisse';

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
  String get posImpressionOk => 'Ticket envoyé à l\'imprimante.';

  @override
  String posImpressionErreur(String detail) {
    return 'Impression impossible : $detail';
  }

  @override
  String get posRaccourcisTitre => 'Raccourcis clavier';

  @override
  String get posRaccourciF1 => 'Aide des raccourcis';

  @override
  String get posRaccourciF2 => 'Rechercher / scanner';

  @override
  String get posRaccourciF3 => 'Recherche avancée';

  @override
  String get posRaccourciF4 => 'Encaisser le ticket';

  @override
  String get posRaccourciF5 => 'Encaisser BL / SC';

  @override
  String get posRaccourciF6 => 'Enregistrer le ticket (crédit)';

  @override
  String get posRaccourciF7 => 'Choisir le client';

  @override
  String get posRaccourciF8 => 'Choisir une remise';

  @override
  String get posRaccourciF9 => 'Calculatrice';

  @override
  String get posRaccourciF10 => 'Vider le panier';

  @override
  String get posRaccourciF11 => 'Masquer / afficher les produits';

  @override
  String get posRaccourciF12 => 'Ventes du jour';

  @override
  String get posRaccourciCtrlN => 'Nouveau panier';

  @override
  String get posRaccourciCtrlTab => 'Panier suivant';

  @override
  String get posRaccourciSuppr => 'Retirer la ligne sélectionnée';

  @override
  String get posRaccourciPlusMoins => 'Quantité +1 / −1 sur la ligne sélectionnée';

  @override
  String get posVendreNombre => 'Vendre à la pièce';

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
  String get mvtAnnulation => 'Annulation vente';

  @override
  String get mvtRemboursement => 'Remboursement retour';

  @override
  String get mvtEncaissement => 'Versement client';

  @override
  String get mvtDecaissement => 'Versement fournisseur';

  @override
  String get mvtApport => 'Entrée manuelle';

  @override
  String get mvtDepense => 'Sortie manuelle';

  @override
  String get mvtTransfert => 'Transfert';

  @override
  String get mvtFondInitial => 'Ouverture';

  @override
  String get mvtRetrait => 'Retrait de clôture';

  @override
  String get mvtEcart => 'Écart de clôture';

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

  @override
  String get ventesDescription => 'Tous les paniers encaissés — tickets et BL / SC';

  @override
  String get ventesKpiNombre => 'Nombre de ventes';

  @override
  String get ventesKpiCa => 'Chiffre d\'affaires';

  @override
  String get ventesKpiMarge => 'Marge';

  @override
  String get ventesKpiEncaisse => 'Encaissé';

  @override
  String get ventesKpiCredit => 'Crédit clients';

  @override
  String get ventesType => 'Type';

  @override
  String get ventesTous => 'Tous';

  @override
  String get ventesToutes => 'Toutes';

  @override
  String get ventesStatut => 'Statut';

  @override
  String get ventesCaissier => 'Caissier';

  @override
  String get ventesClient => 'Client';

  @override
  String get ventesCaisse => 'Caisse';

  @override
  String get ventesSession => 'Session';

  @override
  String get ventesMontant => 'Montant';

  @override
  String get ventesPaye => 'Payé';

  @override
  String get ventesReste => 'Reste';

  @override
  String get ventesPaiement => 'Paiement';

  @override
  String get ventesArticles => 'Articles';

  @override
  String get ventesQuantite => 'Quantité';

  @override
  String get ventesNbVersements => 'Nb versements';

  @override
  String get ventesMontantAchat => 'Montant achat';

  @override
  String get ventesAnnuleLe => 'Annulé le';

  @override
  String get ventesAnnulePar => 'Annulé par';

  @override
  String get ventesRechercheIndice => 'N° panier ou client…';

  @override
  String get ventesNouvelle => 'Nouvelle vente';

  @override
  String get ventesEntite => 'panier';

  @override
  String get ventesEntitePluriel => 'paniers';

  @override
  String ventesPanierTitre(String code) {
    return 'Panier $code';
  }

  @override
  String get ventesReimprimer => 'Réimprimer';

  @override
  String get ventesMontantTotal => 'Montant total';

  @override
  String get ventesVersements => 'Versements';

  @override
  String get ventesInfosGenerales => 'Informations générales';

  @override
  String get ventesPaiementMarge => 'Paiement & marge';

  @override
  String get ventesTotalAchat => 'Total achat';

  @override
  String get ventesMontantPaye => 'Montant payé';

  @override
  String get ventesNombreVersements => 'Nombre de versements';

  @override
  String get ventesModePaiement => 'Mode de paiement';

  @override
  String get ventesProduitsPanier => 'Produits du panier';

  @override
  String get ventesProduits => 'Produits';

  @override
  String get ventesProduit => 'Produit';

  @override
  String get ventesQte => 'Qté';

  @override
  String get ventesNumSerie => 'N° série';

  @override
  String get ventesPrix => 'Prix';

  @override
  String get ventesTotal => 'Total';

  @override
  String get ventesAudit => 'Audit';

  @override
  String get ventesCreePar => 'Créé par';

  @override
  String get ventesCreeLe => 'Créé le';

  @override
  String get ventesMotifAnnulation => 'Motif d\'annulation';

  @override
  String get ventesEmpreinte => 'Empreinte fiscale';

  @override
  String get ventesModifierTitre => 'Modifier le panier';

  @override
  String ventesModifierDescription(String code) {
    return '$code · les lignes ne sont pas modifiables — utilisez un retour.';
  }

  @override
  String get ventesClientScelle =>
      'Client du ticket scellé : pour un autre client, faites un retour puis une nouvelle vente.';

  @override
  String get ventesComplementIndice => 'Le complément sera enregistré comme versement imputé sur ce panier.';

  @override
  String get ventesNoteInterne => 'Note interne';

  @override
  String get ventesModifie => 'Panier modifié';

  @override
  String get ventesBloqueDejaAnnule => 'Déjà annulé';

  @override
  String get ventesBloqueRetour => 'Un retour est lié à ce panier';

  @override
  String get ventesAnnulesTitre => 'Paniers annulés';

  @override
  String get ventesAnnulesMessage => 'Le stock des produits a été réintégré et les montants retirés de la session.';

  @override
  String ventesAnnulesPartiel(String detail, int ok) {
    return '$ok panier(s) annulé(s). Échec : $detail';
  }

  @override
  String get statutTicket => 'Ticket';

  @override
  String get statutFacture => 'BL / SC';

  @override
  String get posErreurMotif => 'Le motif est obligatoire.';

  @override
  String posErreurMontantPaye(String montant) {
    return 'Le montant payé ne peut pas baisser (déjà payé : $montant). Utilisez un retour.';
  }

  @override
  String get posErreurRetourLie => 'Un retour est lié à ce panier : annulation impossible.';

  @override
  String get retoursDescription => 'Retours clients (remise en stock, remboursement) et retours fournisseurs';

  @override
  String get retoursOngletClients => 'Retours clients';

  @override
  String get retoursOngletFournisseurs => 'Retours fournisseurs';

  @override
  String get retoursKpiNombre => 'Retours de la période';

  @override
  String get retoursKpiQuantite => 'Quantité retournée';

  @override
  String get retoursKpiRembourse => 'Montant remboursé';

  @override
  String get retoursKpiDeduit => 'Déduit des crédits';

  @override
  String get retoursClient => 'Client';

  @override
  String get retoursFournisseur => 'Fournisseur';

  @override
  String get retoursRemboursement => 'Remboursement';

  @override
  String get retoursReglement => 'Règlement';

  @override
  String get retoursEtat => 'État';

  @override
  String get retoursTous => 'Tous';

  @override
  String get retoursRecherche => 'Code, tiers ou produit…';

  @override
  String get retoursOrigine => 'Origine';

  @override
  String get retoursProduit => 'Produit';

  @override
  String get retoursQte => 'Qté';

  @override
  String get retoursMontant => 'Montant';

  @override
  String get retoursPrixAchat => 'Prix d\'achat';

  @override
  String get retoursPrixVente => 'Prix de vente';

  @override
  String get retoursObservation => 'Observation';

  @override
  String get retoursRegEspeces => 'Espèces';

  @override
  String get retoursRegCarte => 'Carte CIB';

  @override
  String get retoursRegAvoir => 'Avoir client';

  @override
  String get retoursRegDeduit => 'Déduit du crédit';

  @override
  String get retoursRegRembEspeces => 'Remboursement espèces';

  @override
  String get retoursNouveau => 'Nouveau retour';

  @override
  String get retoursModifierTitre => 'Modifier le retour';

  @override
  String get retoursFormDescription =>
      'Retour d\'un produit vendu (client) ou reçu (fournisseur). Le stock est réintégré ou déduit.';

  @override
  String get retoursChoixClient => 'Retour client';

  @override
  String get retoursChoixClientDesc => 'Remet en stock, rembourse ou crée un avoir';

  @override
  String get retoursChoixFournisseur => 'Retour fournisseur';

  @override
  String get retoursChoixFournisseurDesc => 'Sort du stock, déduit du crédit fournisseur';

  @override
  String get retoursTicketOrigine => 'Ticket d\'origine';

  @override
  String get retoursEntreeOrigine => 'Entrée d\'origine';

  @override
  String get retoursChoisirClientIndice => 'Choisir un client ≡';

  @override
  String get retoursChoisirFournisseurIndice => 'Choisir un fournisseur ≡';

  @override
  String get retoursChoisirPanierIndice => 'Choisir un panier ≡';

  @override
  String get retoursChoisirEntreeIndice => 'Choisir une entrée ≡';

  @override
  String get retoursChoisirTicket => 'Choisir le ticket d\'origine';

  @override
  String get retoursChoisirEntree => 'Choisir l\'entrée d\'origine';

  @override
  String get retoursProduitIndice => 'Produit de la pièce d\'origine';

  @override
  String get retoursProduitAideTicket => 'Choisissez d\'abord le ticket d\'origine';

  @override
  String get retoursProduitAideEntree => 'Choisissez d\'abord l\'entrée d\'origine';

  @override
  String retoursOptionVendu(String nom, String prix, String qte) {
    return '$nom — $qte vendus à $prix';
  }

  @override
  String retoursOptionRecu(String nom, String prix, String qte) {
    return '$nom — $qte reçus à $prix';
  }

  @override
  String get retoursQuantite => 'Quantité';

  @override
  String retoursQuantiteMax(String maximum) {
    return 'Maximum : $maximum';
  }

  @override
  String retoursQuantiteDepasse(String maximum) {
    return 'Maximum $maximum (quantité de la pièce d\'origine)';
  }

  @override
  String get retoursNumSerie => 'N° de série';

  @override
  String get retoursNumSerieIndice => 'Si le produit est suivi';

  @override
  String get retoursRemiseStock => 'Remise en stock';

  @override
  String get retoursRemiseOui => 'Oui — produit revendable';

  @override
  String get retoursRemiseNon => 'Non — défectueux, sortie « Casse »';

  @override
  String get retoursMotifIndice => 'Motif du retour';

  @override
  String get retoursARembourser => 'À rembourser au client';

  @override
  String get retoursAvoirClient => 'Avoir au compte du client';

  @override
  String get retoursADeduire => 'À déduire du crédit fournisseur';

  @override
  String get retoursRembourseFournisseur => 'À rembourser par le fournisseur';

  @override
  String get retoursEnregistre => 'Retour enregistré';

  @override
  String retoursEnregistreDetail(String code) {
    return '$code · stock mis à jour';
  }

  @override
  String get retoursModifie => 'Retour modifié';

  @override
  String get retoursAnnulesTitre => 'Retours annulés';

  @override
  String get retoursAnnulesDetail => 'Le stock a été rétabli';

  @override
  String get retoursEntite => 'retour';

  @override
  String get retoursEntitePluriel => 'retours';

  @override
  String retoursDetailTitre(String code) {
    return 'Retour $code';
  }

  @override
  String get retoursPieceOrigine => 'Pièce d\'origine';

  @override
  String get retoursBloqueDejaAnnule => 'Déjà annulé';

  @override
  String get retoursAucun => 'Aucun retour sur la période.';

  @override
  String get retourErreurDocumentInconnu => 'Pièce d\'origine introuvable.';

  @override
  String get retourErreurDocumentAnnule => 'La pièce d\'origine est annulée.';

  @override
  String get retourErreurProduitAbsent => 'Ce produit n\'est pas dans la pièce d\'origine.';

  @override
  String get retourErreurReglement => 'Règlement invalide (pas d\'avoir pour le client de passage).';

  @override
  String get retourErreurStock => 'Stock insuffisant pour ce retour.';

  @override
  String get retourErreurInconnu => 'Retour introuvable.';

  @override
  String get retourErreurDejaAnnule => 'Retour déjà annulé.';

  @override
  String get retourErreurMotif => 'Le motif est obligatoire.';

  @override
  String get achatErreurRetourLie => 'Un retour fournisseur est lié à cette entrée : annulation impossible.';

  @override
  String get posVentesDuJour => 'Ventes du jour';

  @override
  String get posRecetteProduit => 'Recette produit';

  @override
  String get posMasquerProduits => 'Masquer les produits';

  @override
  String get posAfficherProduits => 'Afficher les produits';

  @override
  String get posParametres => 'Paramètres de la caisse';

  @override
  String get posScanIndice => 'Scanner un code-barres ou rechercher…';

  @override
  String get posRecherche => 'Recherche';

  @override
  String get posProduits => 'Produits';

  @override
  String get posPacks => 'Packs';

  @override
  String get posAffichageGrille => 'Affichage grille';

  @override
  String get posAffichageListe => 'Affichage liste';

  @override
  String posVente(int n) {
    return 'Vente $n';
  }

  @override
  String get posVenteVide => 'Vide';

  @override
  String posVenteMeta(String montant, String pieces) {
    return '$pieces pcs · $montant';
  }

  @override
  String get posPanierTitre => 'Panier';

  @override
  String get posNouveauProduit => 'Nouveau produit';

  @override
  String get posNouveauClient => 'Nouveau client';

  @override
  String get posViderPanier => 'Vider le panier (F10)';

  @override
  String get posClientLabel => 'Client';

  @override
  String get posModePaiement => 'Mode de paiement';

  @override
  String get posChoisirRemise => 'Choisir une remise';

  @override
  String get posAucuneRemise => 'Aucune remise';

  @override
  String get posPanierVideTitre => 'Panier vide';

  @override
  String get posPanierVideDesc => 'Scannez un code-barres ou touchez un produit.';

  @override
  String get posLigneAide => 'Double-clic : modifier le prix · clic sur le colis : changer le colis';

  @override
  String get posEnregistrer => 'Enregistrer';

  @override
  String get posBlSc => 'BL / SC';

  @override
  String get posEncaisserBouton => 'Encaisser';

  @override
  String get posEncTicketTitre => 'Encaisser le ticket';

  @override
  String get posEncBlscTitre => 'Encaisser BL / SC';

  @override
  String get posEncSaveTitre => 'Enregistrer le ticket';

  @override
  String get posEncTicketDesc => 'Vérifiez le montant reçu puis validez : le ticket est imprimé.';

  @override
  String get posEncBlscDesc => 'Bon de livraison sans cachet, avec mentions légales.';

  @override
  String get posEncSaveDesc => 'Le ticket est enregistré : le reste est porté au crédit du client.';

  @override
  String get posEncTicketOk => 'Encaisser et imprimer';

  @override
  String get posEncBlscOk => 'Encaisser le BL / SC';

  @override
  String get posInfoVente => 'Vente';

  @override
  String get posInfoDate => 'Date';

  @override
  String get posInfoProduits => 'Produits';

  @override
  String get posInfoPieces => 'Pièces';

  @override
  String get posInfoPaiement => 'Paiement';

  @override
  String get posInfoCaissier => 'Caissier';

  @override
  String get posSortieImprimer => 'Imprimer';

  @override
  String get posSortieImprimerDesc => 'Imprimante A4 par défaut';

  @override
  String get posSortiePdf => 'Enregistrer en PDF';

  @override
  String get posSortiePdfDesc => 'Enregistrer ou partager le document';

  @override
  String posToastEncaisse(String code, String type) {
    return '$type $code encaissé';
  }

  @override
  String posToastEnregistre(String code) {
    return 'Ticket $code enregistré';
  }

  @override
  String posToastResteCredit(String montant) {
    return 'Reste au crédit : $montant';
  }

  @override
  String posToastRendu(String montant, String rendu) {
    return 'Total $montant · rendu $rendu';
  }

  @override
  String get posReimprimer => 'Réimprimer';

  @override
  String get posTicket => 'Ticket';

  @override
  String get posSelTitre => 'Quantité et colis';

  @override
  String get posSelTitreModif => 'Modifier la quantité et le colis';

  @override
  String posSelScanne(String code) {
    return 'Produit scanné · $code';
  }

  @override
  String posSelAuto(String detail, String secondes) {
    return 'Ajout automatique de $detail dans $secondes s · touchez pour modifier';
  }

  @override
  String get posSelAutoAnnule => 'Ajout automatique annulé — validez avec Entrée';

  @override
  String posSelParPiece(String prix) {
    return '$prix / pièce';
  }

  @override
  String posSelStock(String quantite) {
    return 'Stock : $quantite pièces';
  }

  @override
  String get posSelColis => 'Colis';

  @override
  String get posSelUnite => 'À l\'unité';

  @override
  String posSelParColis(String nom, String quantite) {
    return '$nom ($quantite pièces)';
  }

  @override
  String get posSelQuantite => 'Quantité';

  @override
  String get posSelPieces => 'Pièces';

  @override
  String posSelStockInsuffisant(String quantite) {
    return 'Stock insuffisant ($quantite pièces)';
  }

  @override
  String posSelAjouter(String montant) {
    return 'Ajouter · $montant';
  }

  @override
  String posSelModifier(String montant) {
    return 'Modifier · $montant';
  }

  @override
  String get posPrixTitre => 'Modifier le prix du produit';

  @override
  String get posPrixDesc => 'Réservé aux rôles autorisés — mot de passe requis.';

  @override
  String get posPrixAchat => 'Prix d\'achat';

  @override
  String get posPrixVente => 'Prix de vente';

  @override
  String get posPrixMotDePasse => 'Mot de passe';

  @override
  String get posPrixMotDePasseIndice => 'Votre mot de passe';

  @override
  String get posPrixPortee => 'Portée';

  @override
  String get posPrixPorteeTicket => 'Ce ticket uniquement';

  @override
  String get posPrixPorteeTicketDesc => 'Le prix catalogue ne change pas';

  @override
  String get posPrixPorteeProduit => 'Tout le produit';

  @override
  String get posPrixPorteeProduitDesc => 'Met à jour le prix de vente';

  @override
  String get posPrixInvalide => 'Prix invalide';

  @override
  String get posPrixMdpRequis => 'Mot de passe requis';

  @override
  String get posPrixMdpIncorrect => 'Mot de passe incorrect';

  @override
  String get posPrixSousAchat => 'En dessous du prix d\'achat';

  @override
  String posPrixMarge(String montant) {
    return 'Marge : $montant';
  }

  @override
  String get posPrixSousAchatTitre => 'Vendre sous le prix d\'achat ?';

  @override
  String posPrixSousAchatMsg(String achat, String vente) {
    return 'Prix de vente $vente inférieur au prix d\'achat $achat.';
  }

  @override
  String get posPrixSousAchatOk => 'Vendre quand même';

  @override
  String get posPrixModifie => 'Prix modifié';

  @override
  String posPrixModifieTicket(String nom) {
    return '$nom · ce ticket uniquement';
  }

  @override
  String posPrixModifieProduit(String nom) {
    return '$nom · prix catalogue mis à jour';
  }

  @override
  String get posRechTitre => 'Rechercher un produit';

  @override
  String get posRechDesc => 'Filtrez puis cochez les produits à ajouter au panier.';

  @override
  String get posRechAjouter => 'Ajouter au panier';

  @override
  String get posRechIndice => 'Nom, code ou code-barres…';

  @override
  String posRechAjoutes(int n) {
    return '$n produit(s) ajouté(s)';
  }

  @override
  String get posIntrouvableTitre => 'Produit introuvable';

  @override
  String get posIntrouvableDesc => 'Aucun produit actif ne correspond à ce code-barres.';

  @override
  String get posIntrouvableCreer => 'Créer le produit';

  @override
  String get posFermeeTitre => 'Aucune session ouverte';

  @override
  String posFermeeDesc(String caisse) {
    return 'Ouvrez une session pour « $caisse » avant de vendre.';
  }

  @override
  String get posOuvrirCaisse => 'Ouvrir la caisse';

  @override
  String posOuvertureTitre(String caisse) {
    return 'Ouvrir $caisse';
  }

  @override
  String get posOuvertureDesc => 'Comptez le fond de caisse avant de commencer.';

  @override
  String get posOuvertureSolde => 'Solde d\'ouverture';

  @override
  String get posOuverturePar => 'Ouverte par';

  @override
  String get posOuvertureOk => 'Ouvrir la session';

  @override
  String get posCaisseOuverte => 'Caisse ouverte';

  @override
  String posCaisseOuverteDesc(String montant) {
    return 'Fond de caisse : $montant';
  }

  @override
  String posClotureTitre(String caisse) {
    return 'Clôturer $caisse';
  }

  @override
  String posClotureDesc(String code, String heure) {
    return 'Session $code · ouverte à $heure';
  }

  @override
  String get posClotureFond => 'Fond de départ';

  @override
  String get posClotureVentesEspeces => 'Ventes en espèces (monnaie déduite)';

  @override
  String get posClotureTheorique => 'Solde théorique';

  @override
  String get posClotureReel => 'Solde réel compté';

  @override
  String posClotureEcart(String etat) {
    return 'Écart de caisse · $etat';
  }

  @override
  String get posClotureJuste => 'Caisse juste';

  @override
  String get posClotureExcedent => 'Excédent';

  @override
  String get posClotureManquant => 'Manquant';

  @override
  String get posClotureOk => 'Clôturer la session';

  @override
  String get posClotureFaite => 'Session clôturée';

  @override
  String posClotureEcartToast(String montant) {
    return 'Écart : $montant';
  }

  @override
  String get posMvtTitre => 'Mouvement manuel';

  @override
  String get posMvtDesc => 'Entrée ou sortie hors vente : dépôt de fond, prélèvement, frais divers.';

  @override
  String get posMvtType => 'Type';

  @override
  String get posMvtEntree => 'Entrée manuelle';

  @override
  String get posMvtSortie => 'Sortie manuelle';

  @override
  String get posMvtMotif => 'Motif';

  @override
  String get posMvtFait => 'Mouvement enregistré';

  @override
  String posMvtFaitDesc(String montant, String sens) {
    return '$sens de $montant';
  }

  @override
  String posVdjTitre(String caisse) {
    return 'Recette caisse — $caisse';
  }

  @override
  String posVdjDesc(String date) {
    return 'Ventes du $date';
  }

  @override
  String get posVdjIndice => 'N° panier ou client…';

  @override
  String get posVdjNombre => 'Nombre de ventes';

  @override
  String get posVdjTotal => 'Total ventes';

  @override
  String get posVdjEncaisse => 'Encaissé';

  @override
  String get posVdjReste => 'Reste (crédit)';

  @override
  String get posVdjAucune => 'Aucune vente trouvée';

  @override
  String get posVdjHeure => 'Heure';

  @override
  String posRecTitre(String caisse) {
    return 'Recette par produit — $caisse';
  }

  @override
  String posRecDesc(String date) {
    return 'Lignes vendues le $date';
  }

  @override
  String get posRecIndice => 'Produit, code ou panier…';

  @override
  String get posRecLignes => 'Lignes vendues';

  @override
  String get posRecQuantite => 'Quantité';

  @override
  String get posRecAucune => 'Aucune ligne vendue';

  @override
  String get posParamDesc => 'S\'applique à ce poste jusqu\'à la déconnexion.';

  @override
  String get posParamMagasin => 'Magasin';

  @override
  String get posParamFait => 'Paramètres enregistrés';

  @override
  String posFermerVenteTitre(int n) {
    return 'Fermer la vente $n ?';
  }

  @override
  String posFermerVenteMsg(String lignes) {
    return 'Le panier ($lignes ligne(s)) sera abandonné. Encaissez-le ou enregistrez-le d\'abord pour le garder.';
  }

  @override
  String get posFermerVenteOk => 'Fermer sans enregistrer';

  @override
  String get posEntreeTitre => 'Entrée rapide';

  @override
  String posEntreeDesc(String magasin, String nom) {
    return '$nom · $magasin';
  }

  @override
  String get posEntreeFaite => 'Entrée rapide enregistrée';

  @override
  String posEntreeFaiteDesc(String nom) {
    return '$nom · stock mis à jour';
  }

  @override
  String get produitErreurUtilise => 'Ce produit est utilisé (ventes, achats ou stock) : il ne peut pas être supprimé.';

  @override
  String get catalogueErreurNomPris => 'Ce nom est déjà utilisé.';

  @override
  String get prdDescription => 'Catalogue, catégories, remises et packs';

  @override
  String get prdOngletSousCategories => 'Sous-catégories';

  @override
  String get prdAchat => 'Achat';

  @override
  String get prdVente => 'Vente';

  @override
  String get prdMarge => 'Marge';

  @override
  String get prdMarque => 'Marque';

  @override
  String get prdMarqueIndice => 'Ex. Elio';

  @override
  String get prdDescriptionChamp => 'Description';

  @override
  String get prdTaille => 'Taille';

  @override
  String get prdCouleur => 'Couleur';

  @override
  String get prdRemise => 'Remise';

  @override
  String get prdService => 'Service';

  @override
  String prdEmballageN(int n) {
    return 'Emballage $n';
  }

  @override
  String prdPrixEmballageN(int n) {
    return 'Prix emballage $n';
  }

  @override
  String prdEmballagePieces(int n) {
    return '$n pcs';
  }

  @override
  String get prdNumeroSerie => 'N° série';

  @override
  String get prdMultiCodes => 'Multi code-barres';

  @override
  String get prdPhotos => 'Photos';

  @override
  String get prdTva => 'TVA';

  @override
  String get prdDateExpiration => 'Date d\'expiration';

  @override
  String get prdEntiteProduits => 'produits';

  @override
  String get prdEntiteProduit => 'produit';

  @override
  String get prdEntiteCategories => 'catégories';

  @override
  String get prdEntiteCategorie => 'catégorie';

  @override
  String get prdEntiteSousCategories => 'sous-catégories';

  @override
  String get prdEntiteSousCategorie => 'sous-catégorie';

  @override
  String get prdEntiteRemises => 'remises';

  @override
  String get prdEntiteRemise => 'remise';

  @override
  String get prdEntitePacks => 'packs';

  @override
  String get prdEntitePack => 'pack';

  @override
  String get prdKpiActifs => 'Produits actifs';

  @override
  String get prdKpiValeurStock => 'Valeur du stock';

  @override
  String get prdKpiSousSeuil => 'Sous le seuil';

  @override
  String get prdKpiRupture => 'En rupture';

  @override
  String get prdToutes => 'Toutes';

  @override
  String get prdDisponible => 'Disponible';

  @override
  String get prdRechercheProduits => 'Nom, code ou code-barres…';

  @override
  String get prdRechercheCategorie => 'Rechercher une catégorie…';

  @override
  String get prdRechercheSousCategorie => 'Rechercher une sous-catégorie…';

  @override
  String get prdRechercheRemise => 'Rechercher une remise…';

  @override
  String get prdRecherchePack => 'Rechercher un pack…';

  @override
  String get prdEtiquette => 'Étiquette';

  @override
  String get prdEtiquettes => 'Étiquettes';

  @override
  String get prdAffecter => 'Affecter';

  @override
  String get prdImporter => 'Importer';

  @override
  String prdAchatMontant(String montant) {
    return 'Achat $montant';
  }

  @override
  String prdStockN(String quantite) {
    return 'Stock $quantite';
  }

  @override
  String prdMargeN(int n) {
    return 'Marge $n %';
  }

  @override
  String get prdStatut => 'Statut';

  @override
  String get prdTypeTaux => 'Type de taux';

  @override
  String get prdSeuilMontant => 'Seuil du panier';

  @override
  String get prdPack => 'Pack';

  @override
  String get prdComposants => 'Composants';

  @override
  String get prdComposant => 'Composant';

  @override
  String get prdValeurSeparee => 'Valeur séparée';

  @override
  String get prdPrixPack => 'Prix du pack';

  @override
  String get prdEconomie => 'Économie';

  @override
  String get prdDisponibles => 'Disponibles';

  @override
  String get prdFormDescription =>
      'Rapide : une page pour l\'essentiel. Détaillé : 3 étapes (photos, identification et prix · stock et emballages · variantes et options). IA : fiche retrouvée par le code-barres.';

  @override
  String get prdModeRapide => 'Rapide';

  @override
  String get prdModeDetaille => 'Détaillé · 3 étapes';

  @override
  String get prdModeIa => 'IA';

  @override
  String get prdEtape1 => 'Photos, identification et prix';

  @override
  String get prdEtape1Desc => 'Photos, nom, codes, marge';

  @override
  String get prdEtape2 => 'Stock et emballages';

  @override
  String get prdEtape2Desc => 'Magasin, seuil, boîte, carton';

  @override
  String get prdEtape3 => 'Variantes et options';

  @override
  String get prdEtape3Desc => 'Tailles, couleurs, séries';

  @override
  String prdEtapeObligatoire(int n) {
    return 'Étape $n / 3 · * obligatoire';
  }

  @override
  String get prdObligatoire => '* obligatoire';

  @override
  String get prdEnregistrerNouveau => 'Enregistrer et nouveau';

  @override
  String get prdSuivant => 'Suivant';

  @override
  String get prdPrincipale => 'Principale';

  @override
  String get prdPhotosFormat => 'JPG ou PNG · 4 max';

  @override
  String get prdPhotosFin => 'la première est la photo principale';

  @override
  String get prdPhotosAide =>
      'La 1re photo s\'affiche en caisse (carte produit et dialog Quantité et colis). JPG ou PNG, 4 max.';

  @override
  String get prdIdentification => 'Identification';

  @override
  String get prdCodeAuto => 'Attribué à l\'enregistrement';

  @override
  String get prdDesignationIndice => 'Ex. Huile Elio 1 L';

  @override
  String get prdEanInvalide => 'Clé de contrôle EAN-13 invalide';

  @override
  String get prdScannerOuSaisir => 'Scanner ou saisir';

  @override
  String get prdGenererEan => 'Générer un EAN-13';

  @override
  String get prdFournisseur => 'Fournisseur';

  @override
  String get prdPrix => 'Prix';

  @override
  String get prdSousAchat => 'Inférieur au prix d\'achat';

  @override
  String prdMargeUnitaire(String montant) {
    return 'Marge unitaire : $montant';
  }

  @override
  String get prdStockActuel => 'Stock actuel';

  @override
  String get prdStockInitial => 'Stock initial';

  @override
  String get prdStockAide => 'Modifiable via Entrées / Sorties';

  @override
  String get prdSeuilAlerte => 'Seuil d\'alerte';

  @override
  String get prdEmballages => 'Emballages';

  @override
  String get prdEmballagesAide =>
      'Colis proposés en caisse (dialog Quantité et colis) : nombre de pièces par colis et prix du colis.';

  @override
  String get prdBoite => 'Boîte';

  @override
  String get prdCarton => 'Carton';

  @override
  String get prdPcs => 'pcs';

  @override
  String get prdVariantes => 'Variantes';

  @override
  String get prdTypeTaille => 'Type de taille';

  @override
  String get prdTailles => 'Tailles';

  @override
  String get prdTaillesAide => 'Cliquez les tailles disponibles';

  @override
  String prdTaillesN(int n) {
    return '$n taille(s) sélectionnée(s)';
  }

  @override
  String get prdCouleurs => 'Couleurs';

  @override
  String get prdCouleursAide => '16 couleurs · plusieurs choix possibles';

  @override
  String get prdOptions => 'Options';

  @override
  String get prdCodesMultiples => 'Codes multiples';

  @override
  String get prdCodesMultiplesAide => 'Autres codes-barres reconnus en caisse pour ce produit';

  @override
  String get prdAjouterCode => 'Ajouter un code';

  @override
  String get prdSuiviSerie => 'Suivi par n° de série';

  @override
  String get prdSuiviSerieAide => 'Saisie obligatoire à la vente';

  @override
  String get prdServiceSansStock => 'Service (sans stock)';

  @override
  String get prdServiceAide => 'Réparation, livraison, main d\'œuvre';

  @override
  String get prdExpirationAide => 'Alerte avant péremption';

  @override
  String get prdNoteInterne => 'Note interne';

  @override
  String get prdToastEnregistre => 'Produit enregistré';

  @override
  String get prdToastModifie => 'Produit modifié';

  @override
  String prdToastAjoute(String code) {
    return '$code · ajouté au catalogue';
  }

  @override
  String get prdModifierCategorie => 'Modifier la catégorie';

  @override
  String get prdModifierSousCategorie => 'Modifier la sous-catégorie';

  @override
  String get prdCategorieParente => 'Catégorie parente';

  @override
  String get prdCategorieExiste => 'Cette catégorie existe déjà';

  @override
  String get prdSousCategorieExiste => 'Cette sous-catégorie existe déjà';

  @override
  String get prdCategorieIndice => 'Ex. Épicerie';

  @override
  String get prdSousCategorieIndice => 'Ex. Huiles';

  @override
  String get prdVisibleCaisse => 'Visible en caisse';

  @override
  String get prdToastCategorie => 'Catégorie enregistrée';

  @override
  String get prdToastSousCategorie => 'Sous-catégorie enregistrée';

  @override
  String get prdInformations => 'Informations';

  @override
  String prdNProduits(int n) {
    return '$n produit(s)';
  }

  @override
  String prdNComposants(int n) {
    return '$n composant(s)';
  }

  @override
  String get prdContientProduits => 'Contient des produits — réaffectez-les d\'abord';

  @override
  String get prdDejaInactif => 'Déjà inactif';

  @override
  String get prdToastAnnulation => 'Annulation effectuée';

  @override
  String get prdPorteeProduit => 'Par produit';

  @override
  String get prdPorteeMontant => 'Par montant (panier)';

  @override
  String get prdProgrammee => 'Programmée';

  @override
  String get prdModifierRemise => 'Modifier la remise';

  @override
  String get prdRemiseDescription => 'Une remise s\'applique automatiquement en caisse pendant sa période.';

  @override
  String get prdProduitsConcernes => 'Produits concernés';

  @override
  String get prdRemiseAccordee => 'Remise accordée';

  @override
  String get prdPrixNormal => 'Prix normal';

  @override
  String get prdPrixRemise => 'Prix remisé';

  @override
  String get prdRemiseNomIndice => 'Ex. Fin de série';

  @override
  String get prdPourcentageAide => 'Ex. −10 % sur le prix';

  @override
  String get prdMontantFixe => 'Montant fixe';

  @override
  String prdMontantFixeAide(String devise) {
    return 'Ex. −50 $devise par article';
  }

  @override
  String get prdCumulable => 'Cumulable';

  @override
  String get prdAvecRemiseTicket => 'Avec la remise ticket';

  @override
  String get prdSeuilAide => 'La remise s\'active quand le sous-total atteint ce montant';

  @override
  String get prdParMontantAide =>
      'Remise « Par montant » : choisie sur le panier en caisse (Ctrl+R / F8), sans liste de produits.';

  @override
  String get prdToastRemise => 'Remise enregistrée';

  @override
  String get prdToastRemiseDesc => 'Appliquée en caisse pendant sa période';

  @override
  String get prdVentesRemisees => 'Ventes remisées';

  @override
  String get prdModifierPack => 'Modifier le pack';

  @override
  String get prdPackDescription => 'Un pack se vend comme un seul article et déstocke chaque composant.';

  @override
  String get prdEnregistrerPack => 'Enregistrer le pack';

  @override
  String get prdComposantsPack => 'Composants du pack';

  @override
  String get prdQteParPack => 'Qté / pack';

  @override
  String get prdPrixUnitaire => 'Prix unitaire';

  @override
  String get prdOptionnel => 'Optionnel';

  @override
  String get prdNomPack => 'Nom du pack';

  @override
  String get prdPackNomIndice => 'Ex. Pack petit-déjeuner';

  @override
  String get prdPacksPossibles => 'Packs possibles';

  @override
  String get prdPacksPossiblesAide => 'Selon le stock du composant le plus limitant';

  @override
  String get prdEconomieClient => 'Économie pour le client';

  @override
  String get prdPackPlusCher => 'Le pack coûte plus cher que ses composants';

  @override
  String prdValeurSepareeMontant(String montant) {
    return 'valeur séparée $montant';
  }

  @override
  String get prdToastPack => 'Pack enregistré';

  @override
  String get prdValeur => 'Valeur';

  @override
  String get prdStockTotal => 'Stock total';

  @override
  String get prdPrixMoyenAchat => 'Prix moyen d\'achat';

  @override
  String get prdVendus30 => 'Vendus (30 j)';

  @override
  String get prdStockParMagasin => 'Stock par magasin';

  @override
  String get prdDerniersMouvements => 'Derniers mouvements';

  @override
  String get prdReference => 'Réf.';

  @override
  String get prdCodeBarreTitre => 'Code-barres & étiquettes';

  @override
  String get prdEanAide => 'Standard commerce — préfixe 613 (Algérie)';

  @override
  String get prdCodeInterne => 'Code interne';

  @override
  String get prdCodeInterneAide => 'Pour les produits sans code fabricant';

  @override
  String get prdFormat => 'Format';

  @override
  String get prdFormatA4 => 'A4 · 3 × 8 (38 × 21 mm)';

  @override
  String get prdFormatRouleau40 => 'Rouleau 40 × 30 mm';

  @override
  String get prdFormatRouleau58 => 'Rouleau 58 mm';

  @override
  String prdImprimerEtiquettes(int n) {
    return 'Imprimer $n étiquette(s)';
  }

  @override
  String prdAffecterN(int n) {
    return 'Affecter $n produit(s)';
  }

  @override
  String get prdRemplacerAffectation => 'Remplacer l\'affectation existante';

  @override
  String get prdRemplacerPackAide => 'Sinon le produit est ajouté au pack avec la quantité 1';

  @override
  String get prdRemplacerCategorieAide => 'Sinon seuls les produits sans catégorie sont modifiés';

  @override
  String get prdRemplacerRemiseAide => 'Sinon seuls les produits sans remise sont modifiés';

  @override
  String get prdToastAffectation => 'Affectation enregistrée';

  @override
  String prdToastAffectationDesc(int n, String nom) {
    return '$n produit(s) · $nom';
  }

  @override
  String get prdSuppressionBloquee => 'Stock ou mouvements liés — désactivez-le plutôt';

  @override
  String prdToastSupprimes(int n) {
    return '$n produit(s) supprimé(s)';
  }

  @override
  String prdToastRefuses(int n) {
    return '$n refusé(s) : mouvements liés';
  }

  @override
  String get prdImportFichier => 'Fichier';

  @override
  String get prdImportFichierDesc => '.xlsx';

  @override
  String get prdImportColonnes => 'Colonnes';

  @override
  String get prdImportColonnesDesc => 'Correspondance';

  @override
  String get prdImportApercuDesc => 'Contrôle';

  @override
  String prdImportInfos(int n, int total) {
    return '$n colonne(s) · $total Ko';
  }

  @override
  String get prdChangerFichier => 'Changer de fichier';

  @override
  String get prdTelechargerModele => 'Télécharger le modèle';

  @override
  String prdColonneN(String lettre, String nom) {
    return 'Colonne $lettre · $nom';
  }

  @override
  String get prdIgnorer => '— Ignorer —';

  @override
  String get prdImportDesignationRequise => 'Associez une colonne à la désignation.';

  @override
  String get prdGenere => '— généré —';

  @override
  String get prdControle => 'Contrôle';

  @override
  String prdImporterN(int n) {
    return 'Importer $n produit(s)';
  }

  @override
  String get prdImportTermine => 'Import terminé';

  @override
  String get stkACommander => 'À commander';

  @override
  String get stkAReapprovisionner => 'À réapprovisionner';

  @override
  String get stkAdresse => 'Adresse';

  @override
  String get stkArticles => 'Articles';

  @override
  String get stkAucun => 'Aucun';

  @override
  String get stkAucunChangement => 'Aucun changement';

  @override
  String get stkAucunExpire => 'Aucun produit expiré ou proche de l\'expiration.';

  @override
  String get stkAucunTransfert => 'Aucun transfert sur la période.';

  @override
  String get stkAucuneListe => 'Aucune liste de besoins sur la période.';

  @override
  String get stkAucuneRupture => 'Aucun produit sous le seuil.';

  @override
  String get stkAucuneSortie => 'Aucune sortie sur la période.';

  @override
  String get stkAudit => 'Audit';

  @override
  String get stkBloqueBesoinRecu => 'Déjà reçue en entrée';

  @override
  String get stkBloqueDejaAnnule => 'Déjà annulé';

  @override
  String get stkBloqueDejaAnnulee => 'Déjà annulée';

  @override
  String get stkBloqueDejaInactif => 'Déjà inactif';

  @override
  String get stkBloqueMagasinPrincipal => 'Magasin principal d\'un utilisateur';

  @override
  String get stkBloqueStockNonNul => 'Stock non nul — transférez-le d\'abord';

  @override
  String get stkCaisses => 'Caisses';

  @override
  String get stkChoisirFournisseur => 'Choisir un fournisseur';

  @override
  String get stkCreerListe => 'Créer une liste de besoins';

  @override
  String get stkDepuis => 'Depuis';

  @override
  String get stkDesactiver => 'Désactiver';

  @override
  String get stkDescriptionBesoins => 'Réapprovisionnement : listes fournisseurs, ruptures et produits expirés';

  @override
  String get stkDescriptionMagasins => 'Points de stock, transferts et rattachements';

  @override
  String get stkDescriptionSorties => 'Sorties de stock hors vente : casse, périmé, perte, consommation interne, don';

  @override
  String stkDescriptionStock(int n) {
    return 'Quantités par magasin · $n magasins actifs';
  }

  @override
  String get stkDispoSource => 'Dispo. source';

  @override
  String stkDisponible(String quantite) {
    return 'Disponible : $quantite';
  }

  @override
  String get stkDisponibleEtat => 'Disponible';

  @override
  String get stkDistribuer => 'Distribuer';

  @override
  String stkDistribuerDescription(String nom, String quantite) {
    return '$nom · $quantite pièces à répartir entre les magasins';
  }

  @override
  String get stkDistribuerTitre => 'Distribuer le stock';

  @override
  String get stkEnStock => 'en stock';

  @override
  String get stkEnregistrerListe => 'Enregistrer la liste';

  @override
  String get stkEntiteListe => 'liste';

  @override
  String get stkEntiteListes => 'listes';

  @override
  String get stkEntiteMagasin => 'magasin';

  @override
  String get stkEntiteMagasins => 'magasins';

  @override
  String get stkEntiteMouvements => 'mouvements';

  @override
  String get stkEntiteSortie => 'sortie';

  @override
  String get stkEntiteSorties => 'sorties';

  @override
  String get stkEntiteTransfert => 'transfert';

  @override
  String get stkEntiteTransferts => 'transferts';

  @override
  String get stkErreurDocumentInconnu => 'Document introuvable.';

  @override
  String get stkErreurFournisseur => 'Choisissez un fournisseur.';

  @override
  String get stkErreurMotifObligatoire => 'Le motif est obligatoire.';

  @override
  String get stkErreurNomPris => 'Un magasin porte déjà ce nom.';

  @override
  String get stkExpiration => 'Expiration';

  @override
  String stkExpireDepuis(int jours) {
    return 'Expiré depuis $jours j';
  }

  @override
  String stkJMoins(int jours) {
    return 'J−$jours';
  }

  @override
  String get stkJours => 'Jours';

  @override
  String get stkKpiArticlesSortis => 'Articles sortis';

  @override
  String get stkKpiCoutReassort => 'Coût de réassort estimé';

  @override
  String get stkKpiEnRupture => 'En rupture';

  @override
  String get stkKpiMagasinsActifs => 'Magasins actifs';

  @override
  String get stkKpiSorties => 'Sorties de la période';

  @override
  String get stkKpiSousSeuil => 'Sous le seuil';

  @override
  String get stkKpiUtilisateursRattaches => 'Utilisateurs rattachés';

  @override
  String get stkKpiValeurPerdue => 'Valeur perdue';

  @override
  String get stkKpiValeurTotale => 'Valeur totale du stock';

  @override
  String get stkListeDescription => 'Quantités suggérées = 2 × seuil − stock. Ajustez avant d\'envoyer au fournisseur.';

  @override
  String stkListeTitre(String code) {
    return 'Liste $code';
  }

  @override
  String get stkLivraison => 'Livraison souhaitée';

  @override
  String get stkMagasin => 'Magasin';

  @override
  String get stkMagasinDescription => 'Un magasin a son propre stock ; les caisses et utilisateurs y sont rattachés.';

  @override
  String get stkMagasinDifferent => 'Choisissez un magasin différent';

  @override
  String get stkModifierListe => 'Modifier la liste de besoins';

  @override
  String get stkModifierMagasin => 'Modifier le magasin';

  @override
  String get stkModifierSortie => 'Modifier la sortie';

  @override
  String get stkModifierTransfert => 'Modifier le transfert';

  @override
  String get stkMontantEstime => 'Montant estimé';

  @override
  String get stkMotif => 'Motif';

  @override
  String get stkMotifDistributionIndice => 'Ex. réassort boutique';

  @override
  String get stkMotifSortieIndice => 'Ex. carton tombé lors de la mise en rayon';

  @override
  String get stkMouvementsRecents => 'Mouvements récents';

  @override
  String get stkNom => 'Nom';

  @override
  String get stkNomMagasinIndice => 'Ex. Boutique Hydra';

  @override
  String get stkNouveauMagasin => 'Nouveau magasin';

  @override
  String get stkNouveauTransfert => 'Nouveau transfert';

  @override
  String get stkNouvelleListe => 'Nouvelle liste';

  @override
  String get stkNouvelleSortie => 'Nouvelle sortie';

  @override
  String get stkObservationTransfertIndice => 'Ex. réassort hebdomadaire';

  @override
  String get stkOngletExpires => 'Expirés';

  @override
  String get stkOngletListes => 'Listes de besoins';

  @override
  String get stkOngletMagasins => 'Magasins';

  @override
  String get stkOngletMouvements => 'Mouvements';

  @override
  String get stkOngletRuptures => 'Ruptures & seuils';

  @override
  String get stkOngletTransferts => 'Transferts';

  @override
  String get stkPalierAvance => 'Palier Avancé';

  @override
  String get stkPcs => 'pcs';

  @override
  String get stkPdfFournisseur => 'PDF fournisseur';

  @override
  String get stkPrincipal => 'Principal';

  @override
  String get stkPrixEstime => 'Prix estimé';

  @override
  String get stkProduitsEnStock => 'Produits en stock';

  @override
  String get stkProduitsSortis => 'Produits sortis';

  @override
  String get stkProduitsTransferes => 'Produits transférés';

  @override
  String get stkQte => 'Qté';

  @override
  String get stkQuantiteTotale => 'Quantité totale';

  @override
  String get stkRechercheMouvement => 'Réf. ou produit…';

  @override
  String get stkReference => 'Réf.';

  @override
  String get stkReparti => 'Réparti';

  @override
  String get stkRepartirEgalement => 'Répartir également';

  @override
  String get stkRepartition => 'Répartition par magasin';

  @override
  String get stkResponsable => 'Responsable';

  @override
  String get stkReste => 'Reste';

  @override
  String get stkRestePrincipal => 'Reste au principal';

  @override
  String get stkRetourFournisseur => 'Retour fournisseur';

  @override
  String get stkSeuilAlerte => 'Seuil d\'alerte';

  @override
  String get stkSortieDescription => 'Sortie de stock hors vente — valorisée au prix d\'achat.';

  @override
  String get stkSortiePerime => 'Sortie « Périmé »';

  @override
  String stkSortieTitre(String code) {
    return 'Sortie $code';
  }

  @override
  String get stkSousSeuilEtat => 'Sous le seuil';

  @override
  String get stkStatut => 'Statut';

  @override
  String stkStockDispo(String quantite) {
    return 'Stock : $quantite';
  }

  @override
  String get stkStockDuMagasin => 'Stock du magasin';

  @override
  String get stkStockTotal => 'Stock total';

  @override
  String get stkSuggestion => 'Suggestion';

  @override
  String get stkTelephone => 'Téléphone';

  @override
  String get stkToastDistribue => 'Stock distribué';

  @override
  String get stkToastListe => 'Liste enregistrée';

  @override
  String stkToastListeDesc(String code) {
    return '$code · prête à envoyer';
  }

  @override
  String get stkToastListesAnnulees => 'Listes annulées';

  @override
  String get stkToastMagasin => 'Magasin enregistré';

  @override
  String get stkToastMagasinsDesactives => 'Magasins désactivés';

  @override
  String get stkToastSortie => 'Sortie enregistrée';

  @override
  String get stkToastSortiesAnnulees => 'Sorties annulées';

  @override
  String get stkToastStockAJour => 'Stock mis à jour';

  @override
  String get stkToastStockReintegre => 'Le stock a été réintégré';

  @override
  String get stkToastTransfert => 'Transfert validé';

  @override
  String get stkToastTransfertsAnnules => 'Transferts annulés';

  @override
  String get stkToutPrincipal => 'Tout au principal';

  @override
  String stkTransfererPieces(String quantite) {
    return 'Transférer $quantite pièce(s)';
  }

  @override
  String get stkTransfertDescription => 'Déplacer du stock d\'un magasin à un autre.';

  @override
  String stkTransfertTitre(String code) {
    return 'Transfert $code';
  }

  @override
  String get stkUtilisateurs => 'Utilisateurs';

  @override
  String get stkUtilisateursCaisses => 'Utilisateurs & caisses';

  @override
  String get stkValeurAchat => 'Valeur d\'achat';

  @override
  String get stkValeurStock => 'Valeur du stock';

  @override
  String get stkValeurVente => 'Valeur de vente';

  @override
  String get stkValideLe => 'Validé le';

  @override
  String get stkValiderTransfert => 'Valider le transfert';

  @override
  String get stkVers => 'Vers';

  @override
  String get stkVoirMouvements => 'Voir les mouvements';

  @override
  String get stkVoirPiece => 'Voir la pièce';

  @override
  String get entAucunBon => 'Aucun bon reçu.';

  @override
  String get entAucunFournisseur => 'Aucun (achat comptant)';

  @override
  String get entAucunProduit => 'Scannez ou ajoutez les produits reçus.';

  @override
  String get entBloqueDejaAnnulee => 'Déjà annulée';

  @override
  String get entBloqueVendus => 'Des produits ont déjà été vendus';

  @override
  String get entBonReception => 'Bon de réception';

  @override
  String get entChoisirProduit => 'Choisir un produit';

  @override
  String get entDescription => 'Réceptions fournisseurs — scan, lecture IA des bons, entrée rapide';

  @override
  String get entEntite => 'Entrée';

  @override
  String get entEntiteBon => 'bon';

  @override
  String get entEntiteBons => 'bons';

  @override
  String get entEntitePluriel => 'entrées';

  @override
  String get entEntreeLiee => 'Entrée liée';

  @override
  String get entErreurBonInconnu => 'Bon de réception introuvable.';

  @override
  String get entErreurBonTraite => 'Bon déjà traité';

  @override
  String get entErreurMotif => 'Le motif est obligatoire.';

  @override
  String get entEtapeBon => 'Bon & fournisseur';

  @override
  String get entEtapeBonDetail => 'En-tête, paiement';

  @override
  String get entEtapeProduits => 'Produits reçus';

  @override
  String get entEtapeProduitsDetail => 'Scan et quantités';

  @override
  String get entFichier => 'Fichier';

  @override
  String get entFournisseurDetecte => 'Fournisseur détecté';

  @override
  String get entIaAnalyser => 'Analyser le bon';

  @override
  String get entIaApercu => 'Aperçu du bon';

  @override
  String get entIaAucunFichier => 'Aucun fichier choisi';

  @override
  String get entIaBandeauDetail => 'Les bons envoyés depuis le téléphone arrivent ici avec le statut « Reçu ».';

  @override
  String get entIaBandeauTitre => 'Photographiez le bon, l\'IA remplit l\'entrée';

  @override
  String get entIaConfiance => 'Confiance';

  @override
  String get entIaDepuisDisque => 'Depuis le disque';

  @override
  String get entIaDepuisTelephone => 'Depuis le téléphone';

  @override
  String get entIaDescription =>
      'Photo ou PDF d\'une facture fournisseur : les lignes sont détectées puis rapprochées du catalogue.';

  @override
  String get entIaDetecte => 'Détecté sur le bon';

  @override
  String get entIaEtapeFournisseur => 'Fournisseur & paiement';

  @override
  String get entIaEtapeFournisseurDetail => 'Valider';

  @override
  String get entIaEtapeLignes => 'Lignes détectées';

  @override
  String get entIaEtapeLignesDetail => 'Vérifier, rapprocher';

  @override
  String get entIaEtapePhoto => 'Photo du bon';

  @override
  String get entIaEtapePhotoDetail => 'Image ou PDF';

  @override
  String get entIaFormats => 'JPG, PNG ou PDF';

  @override
  String get entIaJoindre => 'Joindre un bon';

  @override
  String get entIaLecture => 'Lecture du bon en cours…';

  @override
  String get entIaLectureDetail => 'Détection des lignes, quantités et prix';

  @override
  String get entIaLignes => 'Lignes';

  @override
  String get entIaLignesLues => 'Lignes lues';

  @override
  String get entIaLu => 'Lu sur le bon';

  @override
  String get entIaProduitCatalogue => 'Produit du catalogue';

  @override
  String get entIaRapprocher => 'Rapprocher…';

  @override
  String get entIaRecuPar => 'Reçu par';

  @override
  String get entIaRemplacer => 'Remplacer le produit';

  @override
  String get entIaTelephoneAide => 'Les bons envoyés depuis l\'application mobile apparaissent dans la file Mode IA.';

  @override
  String get entIaTitre => 'Reçu IA · lecture automatique du bon';

  @override
  String get entIaTraitePar => 'Traité par';

  @override
  String get entIaTraiter => 'Traiter';

  @override
  String get entIaVideAide => 'Joignez un bon (photo ou PDF) pour que l\'IA prépare l\'entrée.';

  @override
  String get entIaVoirBon => 'Voir le bon';

  @override
  String get entImprimer => 'Imprimer';

  @override
  String get entInformations => 'Informations';

  @override
  String get entKpiEntrees => 'Entrées du mois';

  @override
  String get entListe => 'Liste';

  @override
  String get entListeBesoins => 'Liste de besoins';

  @override
  String get entMagasinAide => 'Par défaut : votre magasin principal';

  @override
  String get entMajDernier => 'Dernier prix d\'achat';

  @override
  String get entMajGarder => 'Garder le prix d\'achat actuel';

  @override
  String get entMajMoyen => 'Prix moyen pondéré';

  @override
  String get entMajPrix => 'Mise à jour prix';

  @override
  String get entMode => 'Mode';

  @override
  String get entModifierTitre => 'Modifier l\'entrée';

  @override
  String get entMontantPaye => 'Montant payé';

  @override
  String get entNbVersements => 'Nb versements';

  @override
  String get entNouvelleDescription => 'Scannez les produits reçus : chaque scan ajoute 1 à la quantité.';

  @override
  String get entNouvelleTitre => 'Nouvelle entrée · Smart Scan';

  @override
  String get entNumFacture => 'N° facture / BL';

  @override
  String get entNumFactureIndice => 'Ex. FAC-24-1187';

  @override
  String get entOffreMessage => 'Je souhaite augmenter mon quota Smart Scan.';

  @override
  String get entOngletIa => 'Mode IA';

  @override
  String get entPaiement => 'Paiement';

  @override
  String get entPaye => 'Payé';

  @override
  String get entPayeTotalite => 'Payé en totalité';

  @override
  String get entProduitsRecus => 'Produits reçus';

  @override
  String get entQteRecue => 'Qté reçue';

  @override
  String get entRapideDescription => 'Réception d\'un seul produit, sans bon fournisseur détaillé.';

  @override
  String get entRapideTitre => 'Entrée rapide';

  @override
  String get entRecherche => 'Code, fournisseur ou n° facture…';

  @override
  String get entRechercheBons => 'Fichier ou fournisseur…';

  @override
  String get entRecuLe => 'Reçu le';

  @override
  String get entRepartitionIncomplete => 'Répartition incomplète';

  @override
  String get entRepartitionOption => 'Répartition (option)';

  @override
  String get entResteAide => 'Ajouté au crédit du fournisseur';

  @override
  String get entResteCredit => 'Reste (crédit)';

  @override
  String get entRetour => 'Retour';

  @override
  String get entScanAjoute => 'ajouté';

  @override
  String get entScanIndice => 'Scanner un code-barres puis Entrée (ou code produit)…';

  @override
  String get entSourceIa => 'Reçu IA';

  @override
  String get entSourceRapide => 'Entrée rapide';

  @override
  String get entSuivant => 'Suivant';

  @override
  String get entToastAnnulees => 'Entrées annulées';

  @override
  String get entToastAnnuleesDetail => 'Stock et crédit fournisseur corrigés';

  @override
  String get entToastBonsSupprimes => 'Bons supprimés';

  @override
  String get entToastDepuisBon => 'Entrée créée depuis le bon';

  @override
  String get entToastEnregistree => 'Entrée enregistrée';

  @override
  String get entToastModifiee => 'Entrée modifiée';

  @override
  String get entToastRapide => 'Entrée rapide enregistrée';

  @override
  String get entToastReparti => 'Stock réparti entre les magasins';

  @override
  String get entVenteSousAchat => 'Prix de vente ≤ prix d\'achat';

  @override
  String entCreerProduit(String nom) {
    return '+ Créer « $nom »';
  }

  @override
  String entDepuisListe(String code) {
    return 'Réception de la liste de besoins $code';
  }

  @override
  String entDetailTitre(String code) {
    return 'Entrée $code';
  }

  @override
  String entIaARapprocher(int n) {
    return '$n ligne(s) à rapprocher';
  }

  @override
  String entIaCreer(String montant) {
    return 'Créer l\'entrée · $montant';
  }

  @override
  String entValider(String montant) {
    return 'Valider l\'entrée · $montant';
  }

  @override
  String entRapideDescriptionProduit(String code, String stock) {
    return '$code · stock actuel $stock pièces — réception sans bon détaillé.';
  }

  @override
  String entRapideTitreProduit(String nom) {
    return 'Entrée rapide · $nom';
  }

  @override
  String entScanInconnu(String code) {
    return 'Code inconnu : $code';
  }

  @override
  String entToastBonsDetail(int n) {
    return '$n fichier(s)';
  }

  @override
  String get entCreerEntree => 'Créer l\'entrée';

  @override
  String get statutErreur => 'Erreur';

  @override
  String get gcDescription => 'Caisses, transferts, clôtures Z, mouvements et sessions';

  @override
  String get gcOngletCaisses => 'Caisses';

  @override
  String get gcOngletTransferts => 'Transferts';

  @override
  String get gcOngletClotures => 'Clôtures Z';

  @override
  String get gcOngletMouvements => 'Mouvements';

  @override
  String get gcOngletSessions => 'Sessions';

  @override
  String get gcEntiteCaisse => 'caisse';

  @override
  String get gcEntiteCaisses => 'caisses';

  @override
  String get gcEntiteTransfert => 'transfert';

  @override
  String get gcEntiteTransferts => 'transferts';

  @override
  String get gcEntiteClotures => 'clôtures';

  @override
  String get gcEntiteMouvements => 'mouvements';

  @override
  String get gcEntiteSessions => 'sessions';

  @override
  String get gcColCaisse => 'Caisse';

  @override
  String get gcColSoldeInitial => 'Solde initial';

  @override
  String get gcColSoldeActuel => 'Solde actuel';

  @override
  String get gcColSession => 'Session';

  @override
  String get gcColEtat => 'État';

  @override
  String get gcColStatut => 'Statut';

  @override
  String get gcColDepuis => 'Depuis';

  @override
  String get gcColVers => 'Vers';

  @override
  String get gcColTickets => 'Tickets';

  @override
  String get gcColAnnules => 'Annulés';

  @override
  String get gcColTotalAnnule => 'Annulé';

  @override
  String get gcColPar => 'Par';

  @override
  String get gcColEmpreinte => 'Empreinte';

  @override
  String get gcColCreeLe => 'Créé le';

  @override
  String get gcColReference => 'Réf.';

  @override
  String get gcColEntree => 'Entrée';

  @override
  String get gcColSortie => 'Sortie';

  @override
  String get gcColUtilisateur => 'Utilisateur';

  @override
  String get gcColMode => 'Mode';

  @override
  String get gcColOuverture => 'Ouverture';

  @override
  String get gcColCloture => 'Clôture';

  @override
  String get gcColFond => 'Fond';

  @override
  String get gcColTheorique => 'Théorique';

  @override
  String get gcColReel => 'Réel';

  @override
  String get gcColEcart => 'Écart';

  @override
  String get gcColOuvertePar => 'Ouverte par';

  @override
  String get gcToutesCaisses => 'Toutes caisses';

  @override
  String get gcRechercheCaisses => 'Rechercher une caisse…';

  @override
  String get gcRechercheTransferts => 'Rechercher un transfert…';

  @override
  String get gcRechercheClotures => 'Rechercher une clôture…';

  @override
  String get gcRechercheMouvements => 'Rechercher un mouvement…';

  @override
  String get gcRechercheSessions => 'Rechercher une session…';

  @override
  String get gcAucuneSession => 'Aucune session.';

  @override
  String get gcExportFiscal => 'Export contrôle fiscal';

  @override
  String get gcNouvelleClotureZ => 'Nouvelle clôture Z';

  @override
  String get gcMouvementManuel => 'Mouvement manuel';

  @override
  String get gcVoirMouvements => 'Voir les mouvements';

  @override
  String get gcCloturer => 'Clôturer';

  @override
  String get gcOuvrirSession => 'Ouvrir une session';

  @override
  String get gcFormDescription => 'Une caisse (tiroir, coffre) a son propre solde et ses sessions.';

  @override
  String get gcFormNomIndice => 'Ex. Caisse 3';

  @override
  String get gcFormSoldeInitialAide => 'Proposé comme fond de caisse à chaque ouverture';

  @override
  String get gcCaisseEnregistree => 'Caisse enregistrée';

  @override
  String get gcSessions30j => 'Sessions (30 j)';

  @override
  String get gcEcartCumule => 'Écart cumulé';

  @override
  String get gcDernieresSessions => 'Dernières sessions';

  @override
  String get gcBloqueSession => 'Session ouverte — clôturez-la d\'abord';

  @override
  String get gcBloqueSolde => 'Solde non nul — transférez-le';

  @override
  String get gcBloqueSysteme => 'Caisse principale';

  @override
  String get gcBloqueInactive => 'Déjà inactive';

  @override
  String get gcErreurSoldeNonNul => 'Le solde de la caisse doit être nul : transférez-le d\'abord.';

  @override
  String get gcToastDesactivees => 'Caisses désactivées';

  @override
  String get gcTrfTitre => 'Transfert entre caisses';

  @override
  String get gcTrfDescription => 'Ex. remise de la recette au coffre en fin de journée.';

  @override
  String gcTrfDisponible(String montant) {
    return 'Solde disponible : $montant';
  }

  @override
  String get gcTrfMemeCaisse => 'Choisissez une caisse différente';

  @override
  String gcTrfSuperieur(String caisse) {
    return 'Supérieur au solde de $caisse';
  }

  @override
  String get gcTrfMotifIndice => 'Ex. remise de recette';

  @override
  String gcTrfValider(String montant) {
    return 'Transférer $montant';
  }

  @override
  String get gcToastTransfert => 'Transfert enregistré';

  @override
  String get gcToastTransfertsAnnules => 'Transferts annulés';

  @override
  String get gcToastSoldesRetablis => 'Soldes rétablis';

  @override
  String get gcBloqueDejaAnnule => 'Déjà annulé';

  @override
  String get gcErreurDejaAnnule => 'Ce transfert est déjà annulé.';

  @override
  String get gcErreurTransfertInconnu => 'Transfert introuvable.';

  @override
  String get gcErreurPeriodeCloturee => 'Cette date appartient à une période clôturée.';

  @override
  String get gcZDescription => 'Rapport figé de la période : une fois créé, il ne peut plus être modifié ni supprimé.';

  @override
  String gcZPeriodeValeur(String debut) {
    return '$debut → maintenant';
  }

  @override
  String gcZDepuisDerniere(String code) {
    return 'Depuis la dernière clôture ($code)';
  }

  @override
  String get gcZPremiere => 'Première clôture de cette caisse';

  @override
  String get gcZTicketsAnnules => 'Tickets annulés';

  @override
  String get gcZTotalAnnule => 'Total annulé';

  @override
  String get gcZMoyen => 'Moyen de paiement';

  @override
  String get gcZPart => 'Part';

  @override
  String gcZChainee(String code) {
    return 'Chaînée à $code · empreinte précédente';
  }

  @override
  String get gcZGenese => 'Début de la chaîne de cette caisse · empreinte de genèse';

  @override
  String get gcZConfirmer => 'Je confirme les totaux : la clôture sera définitive et signée.';

  @override
  String gcZCreer(String code) {
    return 'Créer la clôture $code';
  }

  @override
  String gcZCreee(String code) {
    return 'Clôture $code créée';
  }

  @override
  String get gcZCreeeDetail => 'Rapport signé et chaîné';

  @override
  String get gcZAucunPaiement => 'Aucun paiement sur la période.';

  @override
  String gcZDetailTitre(String code) {
    return 'Clôture $code';
  }

  @override
  String gcZDetailDescription(String au, String caisse, String du, String par) {
    return '$caisse · $du → $au · par $par';
  }

  @override
  String get gcZDefinitive => 'Définitive';

  @override
  String get gcZEmpreinteValide => 'Empreinte valide';

  @override
  String get gcZEmpreinteAlteree => 'Empreinte altérée';

  @override
  String get gcZRepartition => 'Répartition des paiements';

  @override
  String get gcZIntegrite => 'Intégrité';

  @override
  String get gcZEmpreintePrecedente => 'Empreinte précédente';

  @override
  String get gcZTotaux => 'Totaux de la période';

  @override
  String get gcZSoldeFin => 'Solde en fin de période';

  @override
  String get gcFiscalTitre => 'Export pour contrôle fiscal';

  @override
  String get gcFiscalDescription =>
      'Archive des clôtures Z et des tickets de la période, avec la chaîne d\'empreintes vérifiée.';

  @override
  String get gcFiscalZip => 'Archive complète';

  @override
  String get gcFiscalZipDesc => 'JSON de contrôle + CSV + empreintes (.zip)';

  @override
  String get gcFiscalJson => 'JSON de contrôle';

  @override
  String get gcFiscalJsonDesc => 'Chaîne vérifiable (§12.3)';

  @override
  String get gcFiscalPdf => 'Rapport PDF';

  @override
  String get gcFiscalPdfDesc => 'Clôtures Z uniquement';

  @override
  String get gcFiscalCsv => 'CSV';

  @override
  String get gcFiscalCsvDesc => 'Tickets ligne à ligne';

  @override
  String gcFiscalChaineOk(int n) {
    return 'Chaîne d\'empreintes intègre · $n clôtures, aucune rupture';
  }

  @override
  String gcFiscalChaineKo(String code) {
    return 'Chaîne rompue à la clôture $code';
  }

  @override
  String get gcFiscalGenere => 'Archive générée';

  @override
  String gcSesMvtTitre(String code) {
    return 'Mouvements · $code';
  }

  @override
  String gcSesMvtOuverte(String caisse, String ouverture) {
    return '$caisse · ouverte $ouverture';
  }

  @override
  String gcSesMvtCloturee(String caisse, String cloture, String ouverture) {
    return '$caisse · ouverte $ouverture · clôturée $cloture';
  }

  @override
  String get gcEntrees => 'Entrées';

  @override
  String get gcSorties => 'Sorties';

  @override
  String get gcSolde => 'Solde';

  @override
  String get permVoirMarge => 'Voir la marge / taux de marge';

  @override
  String get permModifierPrixVente => 'Modifier le prix de vente';

  @override
  String get permAnnulerOperations => 'Annuler des opérations';

  @override
  String get permChangerCaisseMagasin => 'Changer sa caisse / son magasin';

  @override
  String get permGererTransfertsCaisse => 'Gérer les transferts entre caisses';

  @override
  String get permVoirStockTousMagasins => 'Voir le stock de tous les magasins';

  @override
  String get usrDescription => 'Comptes, rôles et permissions';

  @override
  String get usrOngletUtilisateurs => 'Utilisateurs';

  @override
  String get usrOngletRoles => 'Rôles';

  @override
  String get usrEntiteUtilisateurs => 'utilisateurs';

  @override
  String get usrEntiteUtilisateur => 'utilisateur';

  @override
  String get usrEntiteRoles => 'rôles';

  @override
  String get usrEntiteRole => 'rôle';

  @override
  String get usrKpiActifs => 'Utilisateurs actifs';

  @override
  String get usrKpiVentes => 'Ventes (30 j)';

  @override
  String get usrKpiTotal => 'Total vendu';

  @override
  String get usrRole => 'Rôle';

  @override
  String get usrEtat => 'État';

  @override
  String get usrActif => 'Actif';

  @override
  String get usrInactif => 'Inactif';

  @override
  String get usrRecherche => 'Nom, identifiant ou téléphone…';

  @override
  String get usrColUtilisateur => 'Utilisateur';

  @override
  String get usrColCaisse => 'Caisse';

  @override
  String get usrColMagasins => 'Magasins';

  @override
  String get usrColVentes => 'Ventes';

  @override
  String get usrColDernierAcces => 'Dernier accès';

  @override
  String get usrTelephone => 'Téléphone';

  @override
  String get usrLibre => 'Libre';

  @override
  String get usrReinitialiser => 'Réinitialiser le mot de passe';

  @override
  String get usrDesactiver => 'Désactiver';

  @override
  String get usrNouvel => 'Nouvel utilisateur';

  @override
  String get usrModifierTitre => 'Modifier l\'utilisateur';

  @override
  String get usrFormDescription =>
      'Le rôle définit les modules visibles ; la caisse attachée verrouille l\'écran Caisse.';

  @override
  String get usrSectionCompte => 'Compte';

  @override
  String get usrSectionAcces => 'Accès';

  @override
  String get usrCode => 'Code';

  @override
  String get usrIdentifiant => 'Identifiant';

  @override
  String get usrIdentifiantIndice => 'ex. amina';

  @override
  String get usrIdentifiantPris => 'Identifiant déjà utilisé';

  @override
  String get usrIdentifiantInvalide => '3 à 32 caractères : lettres, chiffres, . _ -';

  @override
  String get usrMotDePasse => 'Mot de passe';

  @override
  String get usrNouveauMotDePasse => 'Nouveau mot de passe';

  @override
  String get usrMdpIndice => '8 caractères minimum';

  @override
  String get usrMdpVide => 'Laisser vide pour ne pas changer';

  @override
  String get usrForce0 => 'Très faible';

  @override
  String get usrForce1 => 'Faible';

  @override
  String get usrForce2 => 'Moyen';

  @override
  String get usrForce3 => 'Bon';

  @override
  String get usrForce4 => 'Fort';

  @override
  String get usrPrenom => 'Prénom';

  @override
  String get usrNom => 'Nom';

  @override
  String get usrTelephoneIndice => '05xx xx xx xx';

  @override
  String get usrAdminRole => 'Accès complet, ne peut pas être restreint';

  @override
  String usrNbPermissions(int n) {
    return '$n permissions';
  }

  @override
  String get usrCaisseAttachee => 'Caisse attachée';

  @override
  String get usrCaisseAdmin => 'L\'admin choisit sa caisse librement';

  @override
  String get usrCaisseIndice => 'Verrouille la caisse de l\'écran Caisse';

  @override
  String get usrAucune => 'Aucune';

  @override
  String get usrMagasinsIndice => 'Le premier est le magasin par défaut à la connexion';

  @override
  String get usrObservation => 'Observation';

  @override
  String get usrCree => 'Utilisateur créé';

  @override
  String get usrModifie => 'Utilisateur modifié';

  @override
  String get usrErrTelephone => 'Téléphone obligatoire';

  @override
  String get usrErrMotDePasse => 'Mot de passe trop faible';

  @override
  String get usrErrRole => 'Rôle non assignable';

  @override
  String get usrErrMagasins => 'Choisissez au moins un magasin';

  @override
  String get usrErrInconnu => 'Utilisateur introuvable';

  @override
  String get usrInfos => 'Informations générales';

  @override
  String get usrPermissionsRole => 'Permissions du rôle';

  @override
  String get usrAudit => 'Audit';

  @override
  String get usrCreePar => 'Créé par';

  @override
  String get usrCreeLe => 'Créé le';

  @override
  String get usrModifiePar => 'Modifié par';

  @override
  String get usrModifieLe => 'Modifié le';

  @override
  String get usrLibreAdmin => 'Libre (admin)';

  @override
  String get usrDefaut => '(défaut)';

  @override
  String get usrMdpReinitTitre => 'Mot de passe réinitialisé';

  @override
  String usrMdpReinitMessage(String identifiant, String mdp) {
    return 'Communiquez ce mot de passe temporaire à @$identifiant : $mdp. Il pourra le changer dans Mon compte.';
  }

  @override
  String get usrBloqueAdmin => 'Compte administrateur principal';

  @override
  String get usrBloqueCourant => 'Votre propre compte';

  @override
  String get usrBloqueInactif => 'Déjà inactif';

  @override
  String get usrDesactives => 'Utilisateurs désactivés';

  @override
  String get usrDesactivesDetail => 'Ils ne peuvent plus se connecter';

  @override
  String get usrColModules => 'Modules';

  @override
  String get usrColSpeciales => 'Spéciales';

  @override
  String get usrTous => 'Tous';

  @override
  String get usrToutes => 'Toutes';

  @override
  String get usrSysteme => 'Système';

  @override
  String get usrDupliquer => 'Dupliquer';

  @override
  String get usrNouveauRole => 'Nouveau rôle';

  @override
  String get usrModifierRole => 'Modifier le rôle';

  @override
  String get usrRoleDescription => 'Informations, modules accessibles, puis actions sensibles.';

  @override
  String usrRoleConcernes(String code, int n) {
    return '$code · $n utilisateur(s) concerné(s)';
  }

  @override
  String get usrPrecedent => 'Précédent';

  @override
  String get usrSuivant => 'Suivant';

  @override
  String get usrEnregistrerRole => 'Enregistrer le rôle';

  @override
  String get usrEtapeInfos => 'Informations';

  @override
  String get usrEtapeInfosDesc => 'Nom, état';

  @override
  String get usrEtapePermissions => 'Permissions';

  @override
  String usrEtapeModules(int n) {
    return '$n modules';
  }

  @override
  String get usrEtapeSpeciales => 'Permissions spéciales';

  @override
  String get usrEtapeSpecialesDesc => 'Actions sensibles';

  @override
  String get usrNomRole => 'Nom du rôle';

  @override
  String get usrNomRoleIndice => 'Ex. Caissier senior';

  @override
  String get usrNomRolePris => 'Ce nom de rôle existe déjà';

  @override
  String get usrObsRoleIndice => 'À quoi sert ce rôle ?';

  @override
  String get usrModulesTitre => 'Modules accessibles';

  @override
  String get usrModulesDesc =>
      'Le rôle ne voit dans la barre latérale et le menu que les modules cochés. Paramètres et Historique s\'attribuent comme les autres modules.';

  @override
  String get usrSpecialesDesc =>
      'Actions transversales, vérifiées dans tous les modules (affichage des prix d\'achat, annulations, changement de caisse…).';

  @override
  String get usrConfirmRoleTitre => 'Modifier ce rôle ?';

  @override
  String usrConfirmRoleMessage(int n) {
    return '$n utilisateur(s) verront leurs accès changer à la prochaine connexion.';
  }

  @override
  String get usrRoleEnregistre => 'Rôle enregistré';

  @override
  String get usrRoleEnregistreDetail => 'Permissions appliquées';

  @override
  String usrRoleTitre(String nom) {
    return 'Rôle $nom';
  }

  @override
  String get usrAdminBloqueTitre => 'Modification impossible';

  @override
  String get usrAdminBloqueMessage =>
      'Le rôle Admin est un rôle système : ses permissions ne peuvent pas être modifiées.';

  @override
  String get usrRoleBloqueSysteme => 'Rôle système Admin';

  @override
  String get usrRoleBloqueUtilisateurs => 'Des utilisateurs ont ce rôle : réaffectez-les';

  @override
  String get usrRolesDesactives => 'Rôles désactivés';

  @override
  String usrNbUtilisateurs(int n) {
    return '$n utilisateur(s)';
  }

  @override
  String usrCopie(String nom) {
    return '$nom (copie)';
  }

  @override
  String get usrRoleErrModules => 'Cochez au moins un module';

  @override
  String get usrRoleErrInconnu => 'Rôle introuvable';

  @override
  String get usrAucunUtilisateur => 'Aucun utilisateur.';

  @override
  String get usrAucunRole => 'Aucun rôle.';
}
