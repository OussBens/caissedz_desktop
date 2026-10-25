// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get shellNavGeneral => 'Général';

  @override
  String get shellNavStock => 'Stock';

  @override
  String get shellNavTiers => 'Tiers';

  @override
  String get shellNavGestion => 'Gestion';

  @override
  String get shellMenuModules => 'Modules';

  @override
  String get shellFenetreReduire => 'Réduire';

  @override
  String get shellFenetreAgrandir => 'Agrandir';

  @override
  String get shellFenetreRestaurer => 'Restaurer';

  @override
  String get shellFenetreFermer => 'Fermer';

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
  String get communAucunResultat => 'Aucun résultat';

  @override
  String get communTotal => 'Total';

  @override
  String get communToutSelectionner => 'Tout sélectionner';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin sur $total';
  }

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
  String get activationErreurInconnue => 'Clé invalide pour ce poste — vérifiez l\'identifiant envoyé.';

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
  String get licenceRequiseDetail =>
      'Votre licence actuelle est Basic. Activez une licence Avancé pour accéder à ce module.';

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
      'Ce compte n\'a pas encore de mot de passe : connectez-vous au compte BENS de ce poste.';

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
  String get configEtapeBoutique => 'Boutique';

  @override
  String get configEtapeVente => 'Marge et stock';

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
  String get compteTitre => 'Mon compte';

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
  String get permVoirPrixAchat => 'Voir le prix d\'achat';

  @override
  String get shellBandeauDemo => 'Mode démo — les données ne sont pas destinées à la production';

  @override
  String get shellVerrouille => 'Réservé à la licence Avancé';

  @override
  String get shellAccesRestreint => 'Accès non autorisé';

  @override
  String get produitsOngletProduits => 'Produits';

  @override
  String get produitsOngletCategories => 'Catégories';

  @override
  String get produitsOngletPacks => 'Packs';

  @override
  String get produitsOngletRemises => 'Remises';

  @override
  String get produitsNouveau => 'Nouveau produit';

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
  String get produitsColPrixVente => 'Prix de vente HT';

  @override
  String get produitsColStock => 'Stock';

  @override
  String get produitsAucun => 'Aucun produit. Créez-en un ou importez un fichier Excel.';

  @override
  String get produitModifier => 'Modifier le produit';

  @override
  String get produitChampSousCategorie => 'Sous-catégorie';

  @override
  String get produitChampPrixAchat => 'Prix d\'achat';

  @override
  String get produitChampPrixVente => 'Prix de vente HT';

  @override
  String get produitChampUnite => 'Unité';

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
  String get iaIntro => 'Scannez un code-barres : la fiche est retrouvée automatiquement.';

  @override
  String get iaRechercher => 'Rechercher';

  @override
  String get iaAucun => 'Aucune fiche trouvée.';

  @override
  String iaTrouve(String source) {
    return 'Fiche trouvée via $source';
  }

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
  String synchroResultat(int envoyes, int recus) {
    return 'Synchronisation : $envoyes envoyé(s), $recus mis à jour.';
  }

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
  String get categorieErreurSysteme => 'La catégorie système ne peut pas être modifiée.';

  @override
  String get categorieErreurUtilisee => 'Des produits sont rattachés à cette catégorie.';

  @override
  String get packNouveau => 'Nouveau pack';

  @override
  String get packErreurLignes => 'Ajoutez au moins un produit au pack.';

  @override
  String get remiseNouvelle => 'Nouvelle remise';

  @override
  String get remiseType => 'Type';

  @override
  String get remiseValeur => 'Valeur';

  @override
  String get communNouveau => 'Nouveau';

  @override
  String get communModifier => 'Modifier';

  @override
  String get communActif => 'Actif';

  @override
  String get communOui => 'Oui';

  @override
  String get communNon => 'Non';

  @override
  String get communValider => 'Valider';

  @override
  String get communApercu => 'Aperçu';

  @override
  String get communAucune => 'Aucune';

  @override
  String get stockTitre => 'Stock';

  @override
  String get stockColMagasin => 'Magasin';

  @override
  String get stockColQuantite => 'Quantité';

  @override
  String get stockColSeuil => 'Seuil';

  @override
  String get stockColType => 'Type';

  @override
  String get stockColMotif => 'Motif';

  @override
  String get stockColUtilisateur => 'Utilisateur';

  @override
  String get stockColValeur => 'Valeur (PA)';

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
  String get magasinPrincipal => 'Principal';

  @override
  String get statutBesoinEnAttente => 'En attente';

  @override
  String get statutBesoinCommande => 'Commande';

  @override
  String get statutBesoinDisponible => 'Disponible';

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
  String get posRuptureTitre => 'Produit en rupture';

  @override
  String posRuptureMessage(String nom) {
    return '« $nom » n\'est plus disponible dans ce magasin : il ne peut pas être ajouté au panier.';
  }

  @override
  String get posRuptureQuantite => 'Quantité disponible';

  @override
  String posRuptureAilleurs(String magasin, String quantite) {
    return 'Disponible dans « $magasin » : $quantite';
  }

  @override
  String get posRuptureTransferer => 'Transférer';

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
  String get ventesAucune => 'Aucune vente.';

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
  String get retourErreurQuantite => 'Quantité invalide.';

  @override
  String get retourErreurDepasse => 'Quantité supérieure à la quantité vendue (déjà retournée incluse).';

  @override
  String get retourErreurPeriode => 'Période clôturée : retour impossible.';

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
  String get fournisseurNouveau => 'Nouveau fournisseur';

  @override
  String get versementNouveau => 'Nouveau versement';

  @override
  String get versementMontant => 'Montant';

  @override
  String get versementMode => 'Mode';

  @override
  String versementVerrouille(String retour) {
    return 'Verrouillé (lié au retour $retour)';
  }

  @override
  String get versementImputations => 'Imputations (plus ancien d\'abord)';

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
  String get tiersErreurNom => 'Le nom est obligatoire.';

  @override
  String get tiersErreurSysteme => 'Le tiers système ne peut pas être modifié.';

  @override
  String get achatNouveau => 'Nouvelle entrée';

  @override
  String get achatFournisseur => 'Fournisseur';

  @override
  String get achatAucun => 'Aucune entrée.';

  @override
  String get achatColVerse => 'Versé';

  @override
  String get achatColReste => 'Reste';

  @override
  String get achatColSource => 'Source';

  @override
  String get achatColStatut => 'Statut';

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
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanAucuneLigne => 'Aucune ligne reconnue.';

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
  String get caisseActive => 'Active';

  @override
  String get caisseInactive => 'Inactive';

  @override
  String get caisseTypePhysique => 'Physique';

  @override
  String get caisseTypeCompte => 'Compte';

  @override
  String get caisseAucune => 'Aucune caisse.';

  @override
  String get caisseDesactiver => 'Désactiver';

  @override
  String get mouvementColMontant => 'Montant';

  @override
  String get mouvementAucun => 'Aucun mouvement.';

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
  String get transfertCaisseNouveau => 'Nouveau transfert';

  @override
  String get transfertCaisseAucun => 'Aucun transfert.';

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
  String get cloturePeriode => 'Période';

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
  String get clotureAucune => 'Aucune clôture.';

  @override
  String get clotureDerniereVente => 'Dernier ticket';

  @override
  String get clotureErreurRien => 'Rien à clôturer depuis la dernière clôture.';

  @override
  String get exportFiscalGenerer => 'Générer l\'archive';

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
  String get tableauBordTopProduits => 'Top 5 produits (30 jours)';

  @override
  String get situationExportExcel => 'Exporter Excel';

  @override
  String get situationApercuPdf => 'Aperçu PDF';

  @override
  String situationExportOk(String chemin) {
    return 'Fichier enregistré : $chemin';
  }

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
  String get sauvegardeRestaurer => 'Restaurer une sauvegarde';

  @override
  String get sauvegardeMotDePasse => 'Mot de passe de la sauvegarde';

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
  String get dsZoomAvant => 'Zoom avant';

  @override
  String get dsZoomArriere => 'Zoom arrière';

  @override
  String get dsZoomAjuster => 'Image entière';

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
  String get dsChiffresCles => 'Chiffres clés';

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
  String get dsAjouterFavoris => 'Ajouter aux favoris';

  @override
  String get dsRetirerFavoris => 'Retirer des favoris';

  @override
  String get dsFavorisComplets => 'Favoris complets';

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
  String get dsBarcodeCopier => 'Copier';

  @override
  String get dsBarcodeImprimer => 'Imprimer l\'étiquette';

  @override
  String get moduleUtilisateurs => 'Utilisateurs';

  @override
  String get connexionSousTitre => 'Connectez-vous pour ouvrir votre caisse.';

  @override
  String get connexionChoisirCompte => 'Choisissez votre compte';

  @override
  String get connexionChoisirSousTitre => 'Les comptes de ce poste : cliquez sur le vôtre.';

  @override
  String get connexionAutreCompte => 'Autre compte';

  @override
  String get connexionPasVous => 'Ce n\'est pas vous ? Changer de compte';

  @override
  String get connexionVoirComptes => 'Voir les comptes de ce poste';

  @override
  String connexionCompteBens(String telephone) {
    return 'Compte BENS $telephone';
  }

  @override
  String get connexionSansAdmin =>
      'L\'administrateur se connecte avec le compte BENS de ce poste : créez-le, ou connectez-vous s\'il existe déjà. Son mot de passe devient celui de l\'administrateur.';

  @override
  String get connexionMotDePasseBens => 'Par défaut : le mot de passe de votre compte BENS.';

  @override
  String get connexionIdentifiantOuTelephone =>
      'Nom d\'utilisateur, ou le téléphone du compte BENS pour l\'administrateur';

  @override
  String get connexionAfficher => 'Afficher';

  @override
  String get connexionMasquer => 'Masquer';

  @override
  String get connexionResterConnecte => 'Rester connecté';

  @override
  String get connexionMotDePasseOublie => 'Mot de passe oublié ?';

  @override
  String get connexionMotDePasseOublieAide => 'Demandez à l\'administrateur de le réinitialiser.';

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
  String get configEtapeLangue => 'Langue & devise';

  @override
  String get configEtapePaiements => 'Paiements';

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
  String get alertesVoirAnalyse => 'Voir l\'analyse';

  @override
  String get alertesMarquerTraite => 'Marquer comme traité';

  @override
  String get alertesRienTitre => 'Rien à signaler';

  @override
  String get alertesRienDetail => 'Cette famille d\'alertes est traitée.';

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
  String get alertesVoirStock => 'Voir le stock';

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
  String get tiersReste => 'Reste';

  @override
  String get tiersSituation => 'Situation';

  @override
  String tiersSituationDe(String nom) {
    return 'Situation — $nom';
  }

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
  String get ventesClientScelle =>
      'Pour changer de client, utilisez « Ajouter des produits » : la vente est rouverte dans la caisse.';

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
  String get posErreurMotif => 'Le motif est obligatoire.';

  @override
  String posErreurMontantPaye(String montant) {
    return 'Le montant payé ne peut pas baisser (déjà payé : $montant). Utilisez un retour.';
  }

  @override
  String get posErreurRetourLie => 'Un retour est lié à ce panier : annulation impossible.';

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
  String get retoursModifierTitre => 'Modifier le retour';

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
  String get posFavoris => 'Favoris';

  @override
  String get posFavorisVide =>
      'Aucun favori. Ajoutez-en depuis Produits (Favori caisse) ou depuis l\'alerte « Bonne marge, peu vendus ».';

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
  String get posEncaisserBouton => 'Encaisser';

  @override
  String get posEncTicketTitre => 'Encaisser le ticket';

  @override
  String get posEncSaveTitre => 'Enregistrer le ticket';

  @override
  String get posEncTicketOk => 'Encaisser et imprimer';

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
  String get posClotureFond => 'Fond de départ';

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
  String get posRecIndice => 'Produit, code ou panier…';

  @override
  String get posRecLignes => 'Lignes vendues';

  @override
  String get posRecQuantite => 'Quantité';

  @override
  String get posRecAucune => 'Aucune ligne vendue';

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
  String get catalogueErreurNomPris => 'Ce nom est déjà utilisé.';

  @override
  String get prdOngletSousCategories => 'Sous-catégories';

  @override
  String get prdAchat => 'Achat';

  @override
  String get prdVente => 'Vente HT';

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
  String get prdFavoriCaisse => 'Favori caisse';

  @override
  String prdFavoriAjoute(int n) {
    return '$n produit(s) ajouté(s) aux favoris de la caisse';
  }

  @override
  String prdFavoriRetire(int n) {
    return '$n produit(s) retiré(s) des favoris de la caisse';
  }

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
  String get prdModeRapide => 'Rapide';

  @override
  String get prdModeDetaille => 'Détaillé · 3 étapes';

  @override
  String get prdModeIa => 'IA';

  @override
  String get prdEtape1 => 'Produit et prix';

  @override
  String get prdEtape2 => 'Stock';

  @override
  String get prdEtape3 => 'Variantes';

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
  String get prdFournisseur => 'Fournisseur';

  @override
  String get prdGenererCodeBarres => 'Générer un code-barres CDZ';

  @override
  String get prdPrix => 'Prix';

  @override
  String get prdSousAchat => 'Inférieur au prix d\'achat';

  @override
  String get prdPrixAchatNonNul => 'Le prix d\'achat doit être supérieur à 0';

  @override
  String prdMargeUnitaire(String montant) {
    return 'Marge unitaire : $montant';
  }

  @override
  String get prdStockActuel => 'Stock actuel';

  @override
  String get prdStockInitial => 'Stock initial';

  @override
  String prdStockViaEntree(String quantite) {
    return '$quantite entreront en stock avec l\'entrée du bon.';
  }

  @override
  String get prdSeuilAlerte => 'Seuil d\'alerte';

  @override
  String get prdEmballages => 'Emballages';

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
  String prdTaillesN(int n) {
    return '$n taille(s) sélectionnée(s)';
  }

  @override
  String get prdCouleurs => 'Couleurs';

  @override
  String get prdOptions => 'Options';

  @override
  String get prdCodesMultiples => 'Codes multiples';

  @override
  String get prdAjouterCode => 'Ajouter un code';

  @override
  String get prdSuiviSerie => 'Suivi par n° de série';

  @override
  String get prdServiceSansStock => 'Service (sans stock)';

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
  String get prdPorteeProduit => 'Par produit';

  @override
  String get prdPorteeMontant => 'Par montant (panier)';

  @override
  String get prdProgrammee => 'Programmée';

  @override
  String get prdModifierRemise => 'Modifier la remise';

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
  String get prdSeuilAide => 'La remise s\'active quand le sous-total atteint ce montant';

  @override
  String get prdToastRemise => 'Remise enregistrée';

  @override
  String get prdToastRemiseDesc => 'Appliquée en caisse pendant sa période';

  @override
  String get prdVentesRemisees => 'Ventes remisées';

  @override
  String get prdModifierPack => 'Modifier le pack';

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
  String get prdImportFichier => 'Fichier';

  @override
  String get prdImportColonnes => 'Colonnes';

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
  String get stkDispoSource => 'Qté (Depuis)';

  @override
  String stkDisponible(String quantite) {
    return 'Disponible : $quantite';
  }

  @override
  String get stkDisponibleEtat => 'Disponible';

  @override
  String get stkDistribuer => 'Distribuer';

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
  String stkListeTitre(String code) {
    return 'Liste $code';
  }

  @override
  String get stkLivraison => 'Livraison souhaitée';

  @override
  String get stkMagasin => 'Magasin';

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
  String get entEtapeProduits => 'Produits reçus';

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
  String get entIaDetecte => 'Détecté sur le bon';

  @override
  String get entIaEtapeFournisseur => 'Fournisseur & paiement';

  @override
  String get entIaEtapeLignes => 'Lignes détectées';

  @override
  String get entIaEtapePhoto => 'Photo du bon';

  @override
  String get entIaJoindre => 'Joindre un bon';

  @override
  String get entIaLecture => 'Lecture du bon en cours…';

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
  String get entNouvelleTitre => 'Nouvelle entrée · Smart Scan';

  @override
  String get entNumFacture => 'N° facture / BL';

  @override
  String get entNumFactureIndice => 'Ex. FAC-24-1187';

  @override
  String get entOffreMessage => 'Je souhaite augmenter mon quota Smart Scan.';

  @override
  String get entOngletEntree => 'Entrée';

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
    return 'Créer le produit « $nom »';
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
  String get usrConfirmerMotDePasse => 'Confirmer le mot de passe';

  @override
  String get usrMdpConfirmationIndice => 'Retapez le mot de passe';

  @override
  String get usrMdpDifferent => 'Les mots de passe ne correspondent pas';

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
  String get usrPrecedent => 'Précédent';

  @override
  String get usrSuivant => 'Suivant';

  @override
  String get usrEnregistrerRole => 'Enregistrer le rôle';

  @override
  String get usrEtapeInfos => 'Informations';

  @override
  String get usrEtapePermissions => 'Permissions';

  @override
  String get usrEtapeSpeciales => 'Permissions spéciales';

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

  @override
  String get zkEntite => 'calculs';

  @override
  String get zkEntiteUn => 'calcul';

  @override
  String zkKpiCapital(int annee) {
    return 'Capital $annee (provisoire)';
  }

  @override
  String get zkKpiNissab => 'Nissab actuel';

  @override
  String zkKpiEstimee(int annee) {
    return 'Zakat estimée $annee';
  }

  @override
  String get zkKpiEcheance => 'Échéance';

  @override
  String get zkJours => 'jours';

  @override
  String get zkColCode => 'Code';

  @override
  String get zkColAnnee => 'Année';

  @override
  String get zkColCapital => 'Capital';

  @override
  String get zkColNissab => 'Nissab';

  @override
  String get zkColObligatoire => 'Obligatoire';

  @override
  String get zkOui => 'Oui';

  @override
  String get zkNon => 'Non';

  @override
  String get zkColZakat => 'Zakat';

  @override
  String get zkColDue => 'Due le';

  @override
  String get zkColPayee => 'Payée le';

  @override
  String get zkColStatut => 'Statut';

  @override
  String get zkColStock => 'Stock';

  @override
  String get zkColLiquidites => 'Liquidités';

  @override
  String get zkColCreances => 'Créances';

  @override
  String get zkColDettes => 'Dettes';

  @override
  String get zkColTaux => 'Taux';

  @override
  String get zkColHawl => 'Début du hawl';

  @override
  String get zkColObservation => 'Observation';

  @override
  String get zkColCreePar => 'Créé par';

  @override
  String get zkExoneree => 'Exonérée';

  @override
  String get zkAnnulee => 'Annulée';

  @override
  String get zkMarquerPayee => 'Marquer payée';

  @override
  String get zkAnnuler => 'Annuler';

  @override
  String get zkNouveau => 'Nouveau calcul';

  @override
  String get zkNouveauTitre => 'Nouveau calcul de zakat';

  @override
  String get zkModifierTitre => 'Modifier la zakat';

  @override
  String get zkSectionPeriode => 'Période (hawl)';

  @override
  String get zkSectionPatrimoine => 'Patrimoine';

  @override
  String get zkDebutHawl => 'Début du hawl';

  @override
  String get zkDueLe => 'Zakat due le';

  @override
  String get zkDueIndice => 'Début + 354 jours (année lunaire)';

  @override
  String get zkValeurStock => 'Valeur du stock';

  @override
  String get zkStockIndice => 'Au prix d\'achat';

  @override
  String get zkLiquiditesIndice => 'Caisses + banque';

  @override
  String get zkCreancesIndice => 'Crédits clients recouvrables';

  @override
  String get zkDettesCourt => 'Dettes à court terme';

  @override
  String get zkDettesIndice => 'Crédits fournisseurs';

  @override
  String get zkNissabIndice => '85 g d\'or × cours du jour';

  @override
  String zkReprendre(String libelle) {
    return 'Reprendre : $libelle';
  }

  @override
  String get zkRepValeurStock => 'valeur du stock';

  @override
  String get zkRepSoldes => 'soldes des caisses';

  @override
  String get zkRepCreances => 'crédits clients';

  @override
  String get zkRepDettes => 'crédits fournisseurs';

  @override
  String get zkCapitalSoumis => 'Capital soumis';

  @override
  String get zkAuDessus => 'Au-dessus du nissab';

  @override
  String get zkEnDessous => 'En dessous du nissab';

  @override
  String get zkObligatoire => 'Zakat obligatoire';

  @override
  String get zkMontant => 'Montant de la zakat';

  @override
  String zkFormule(String taux) {
    return 'Capital = stock + liquidités + créances − dettes. Montant = capital × $taux % si capital ≥ nissab.';
  }

  @override
  String get zkEnregistre => 'Calcul enregistré';

  @override
  String get zkPayeeToast => 'Zakat marquée payée';

  @override
  String get zkAnnules => 'Calculs annulés';

  @override
  String zkDetailTitre(int annee) {
    return 'Zakat $annee';
  }

  @override
  String zkDetailDescription(String code, String debut, String fin) {
    return '$code · hawl $debut → $fin';
  }

  @override
  String get zkCalcul => 'Calcul';

  @override
  String get zkPoste => 'Poste';

  @override
  String get zkMontantCol => 'Montant';

  @override
  String get zkAudit => 'Audit';

  @override
  String get zkMotif => 'Motif';

  @override
  String get zkBloqueePayee => 'Déjà payée';

  @override
  String get zkBloqueeAnnulee => 'Déjà annulée';

  @override
  String get zkErrValeur => 'Valeurs invalides (montants positifs, échéance après le début du hawl)';

  @override
  String get zkErrInconnue => 'Calcul introuvable';

  @override
  String get zkErrMotif => 'Motif obligatoire';

  @override
  String get zkAucun => 'Aucun calcul de zakat.';

  @override
  String get hiEntite => 'actions';

  @override
  String get hiKpiActions => 'Actions (7 j)';

  @override
  String get hiKpiCreations => 'Créations';

  @override
  String get hiKpiModifications => 'Modifications';

  @override
  String get hiKpiAnnulations => 'Annulations';

  @override
  String get hiModule => 'Module';

  @override
  String get hiAction => 'Action';

  @override
  String get hiUtilisateur => 'Utilisateur';

  @override
  String get hiPoste => 'Poste';

  @override
  String get hiTous => 'Tous';

  @override
  String get hiToutes => 'Toutes';

  @override
  String get hiRecherche => 'Réf. ou description…';

  @override
  String get hiColDate => 'Date';

  @override
  String get hiColRef => 'Réf.';

  @override
  String get hiColDescription => 'Description';

  @override
  String get hiColCode => 'Code';

  @override
  String get hiAucun => 'Aucune action sur la période.';

  @override
  String get hiDetail => 'Détail';

  @override
  String get hiSectionAction => 'Action';

  @override
  String get hiSectionContexte => 'Contexte';

  @override
  String get hiReference => 'Référence';

  @override
  String get hiEntiteTechnique => 'Entité';

  @override
  String get hiModuleConnexion => 'Connexion';

  @override
  String get hiCatCreation => 'Création';

  @override
  String get hiCatModification => 'Modification';

  @override
  String get hiCatAnnulation => 'Annulation';

  @override
  String get hiCatConnexion => 'Connexion';

  @override
  String get hiCatExport => 'Export';

  @override
  String get hiActCreation => 'Création';

  @override
  String get hiActModification => 'Modification';

  @override
  String get hiActAnnulation => 'Annulation';

  @override
  String get hiActDesactivation => 'Désactivation';

  @override
  String get hiActActivation => 'Activation';

  @override
  String get hiActSuppression => 'Suppression';

  @override
  String get hiActVersement => 'Versement';

  @override
  String get hiActTransfert => 'Transfert';

  @override
  String get hiActReinitialisation => 'Réinitialisation du mot de passe';

  @override
  String get hiActRetour => 'Retour';

  @override
  String get hiActParametres => 'Paramètres';

  @override
  String get hiActOuverture => 'Ouverture';

  @override
  String get hiActFermeture => 'Fermeture';

  @override
  String get hiActEncaissement => 'Encaissement';

  @override
  String get hiActConnexion => 'Connexion';

  @override
  String get hiActDeconnexion => 'Déconnexion';

  @override
  String get hiActConfiguration => 'Configuration initiale';

  @override
  String get hiActClotureZ => 'Clôture Z';

  @override
  String get hiActAffectation => 'Affectation';

  @override
  String get hiActAchat => 'Achat';

  @override
  String get hiActApport => 'Apport';

  @override
  String get hiActDepense => 'Dépense';

  @override
  String get hiActPaiement => 'Paiement';

  @override
  String get hiActExport => 'Export';

  @override
  String get pmNonEnregistre => 'Modifications non enregistrées';

  @override
  String get pmEnregistrer => 'Enregistrer';

  @override
  String get pmEnregistre => 'Paramètres enregistrés';

  @override
  String get pmGrpSysteme => 'Système';

  @override
  String get pmGrpBoutique => 'Boutique';

  @override
  String get pmGrpCaisse => 'Caisse et ventes';

  @override
  String get pmGrpImpression => 'Impression';

  @override
  String get pmGrpAlertes => 'Alertes';

  @override
  String get pmGrpSauvegarde => 'Sauvegarde';

  @override
  String get pmGrpLicence => 'Licence';

  @override
  String get pmTheme => 'Thème';

  @override
  String get pmThemeDesc => 'Clair pour la journée, sombre pour les écrans de caisse en faible lumière.';

  @override
  String get pmClair => 'Clair';

  @override
  String get pmSombre => 'Sombre';

  @override
  String get pmLangue => 'Langue de l\'interface';

  @override
  String get pmLangueDesc => 'L\'arabe active la mise en page de droite à gauche et la police Cairo.';

  @override
  String get pmDevise => 'Devise';

  @override
  String get pmDeviseDesc => 'Affichée sur les montants, tickets et factures.';

  @override
  String get pmDecimales => 'Décimales des quantités';

  @override
  String get pmDecimalesDesc => '0 pour les articles à l\'unité, 3 pour la vente au poids (kg).';

  @override
  String get pmMargeTitre => 'Marge par défaut';

  @override
  String get pmMargeInfo => 'Appliquée aux nouveaux produits et proposée dans l\'entrée';

  @override
  String get pmMargeType => 'Type de marge';

  @override
  String get pmMargeTypeDesc => 'En montant fixe ou en pourcentage du prix d\'achat.';

  @override
  String get pmMontant => 'Montant';

  @override
  String get pmPourcentage => 'Pourcentage';

  @override
  String get pmMargeValeur => 'Marge';

  @override
  String get pmMargeValeurDesc => 'Prix de vente = achat + marge.';

  @override
  String get pmSeuilsTitre => 'Seuils de stock globaux';

  @override
  String get pmSeuilsInfo => 'Valeurs par défaut, modifiables produit par produit';

  @override
  String get pmSeuilMin => 'Seuil minimum (rupture)';

  @override
  String get pmSeuilMinDesc => 'Alerte quand le stock passe sous ce seuil.';

  @override
  String get pmSeuilMax => 'Seuil maximum';

  @override
  String get pmSeuilMaxDesc => 'Signale un sur-stock ; 0 pour aucun.';

  @override
  String get pmPieces => 'pcs';

  @override
  String get pmGarde => 'Garde de stock';

  @override
  String get pmGardeDesc => 'Toujours active : le stock ne devient jamais négatif.';

  @override
  String get pmGardeCaisseDesc =>
      'Toujours active : le stock ne devient jamais négatif, un produit à 0 ne s\'encaisse pas.';

  @override
  String get pmNonDesactivable => 'Non désactivable';

  @override
  String get pmZakatTitre => 'Zakat';

  @override
  String get pmNissab => 'Nissab';

  @override
  String get pmNissabDesc => 'Valeur de 85 g d\'or ; proposée à chaque calcul.';

  @override
  String get pmTaux => 'Taux';

  @override
  String get pmTauxDesc => 'Taux appliqué à l\'assiette.';

  @override
  String get pmServeursTitre => 'Services en ligne';

  @override
  String get pmServeursInfo => 'Catalogue partagé et recherche de produits par code-barres';

  @override
  String get pmServeurUrl => 'URL du serveur CaisseDZ';

  @override
  String get pmServeurCle => 'Clé d\'API';

  @override
  String get pmMantouj => 'URL Mantouj';

  @override
  String get pmCatalogueRayonsDesc =>
      'Téléchargez les produits les plus demandés de vos rayons : code-barres, nom et photo.';

  @override
  String get pmCatalogueRayonsBouton => 'Choisir les rayons';

  @override
  String get pmImportProduits => 'Importer des produits';

  @override
  String get pmImportProduitsDesc =>
      'Ajoutez vos produits depuis un fichier Excel (.xlsx) : désignation, code-barres, prix…';

  @override
  String get pmSynchro => 'Synchroniser le catalogue';

  @override
  String get pmSynchroDesc => 'Envoie vos fiches et récupère les fiches enrichies du catalogue partagé.';

  @override
  String get pmSynchroBouton => 'Synchroniser';

  @override
  String get pmLogo => 'Logo';

  @override
  String get pmLogoAide => 'PNG transparent · imprimé en haut du ticket';

  @override
  String get pmRaisonSociale => 'Raison sociale';

  @override
  String get pmTelephone => 'Téléphone';

  @override
  String get pmAdresse => 'Adresse';

  @override
  String get pmRc => 'RC';

  @override
  String get pmNif => 'NIF';

  @override
  String get pmNis => 'NIS';

  @override
  String get pmArticle => 'Article d\'imposition';

  @override
  String get pmEmail => 'E-mail';

  @override
  String get pmMessage => 'Message du ticket';

  @override
  String get pmMessageAide => 'Imprimé en bas de chaque ticket';

  @override
  String get pmModesTitre => 'Moyens de paiement';

  @override
  String get pmModesInfo =>
      'Proposés dans le dialog d\'encaissement ; les espèces sont toujours acceptées, les points seulement avec le bonus fidélité actif et un client identifié';

  @override
  String get pmReglesTitre => 'Règles de vente';

  @override
  String get pmSousAchat => 'Vente sous le prix d\'achat';

  @override
  String get pmSousAchatDesc => 'Autoriser, avertir ou interdire un prix de vente inférieur au prix d\'achat.';

  @override
  String get pmFideliteTitre => 'Fidélité';

  @override
  String get pmBonus => 'Bonus fidélité';

  @override
  String get pmBonusDesc => 'Les clients identifiés gagnent des points à chaque encaissement.';

  @override
  String get pmTauxGain => 'Taux de gain';

  @override
  String get pmTauxGainDesc => 'Points gagnés par tranche d\'achat.';

  @override
  String get pmPointPar => 'point /';

  @override
  String get pmImprimanteTitre => 'Imprimante ticket';

  @override
  String get pmTypeBluetooth => 'Bluetooth';

  @override
  String get pmTypeBluetoothDesc => 'Appairée sous Windows';

  @override
  String get pmTypeUsb => 'USB';

  @override
  String get pmTypeUsbDesc => 'File d\'attente Windows (ESC/POS)';

  @override
  String get pmTypeReseau => 'Réseau';

  @override
  String get pmTypeReseauDesc => 'Adresse IP et port';

  @override
  String get pmTypeNormale => 'Normale';

  @override
  String get pmTypeNormaleDesc => 'Imprimante Windows';

  @override
  String get pmAdresseIp => 'Adresse IP:port';

  @override
  String get pmAdresseBluetooth => 'File d\'attente Bluetooth';

  @override
  String get pmFileUsb => 'File d\'attente Windows';

  @override
  String get pmLargeur => 'Largeur';

  @override
  String get pmTest => 'Imprimer un test';

  @override
  String pmTestOk(String cible) {
    return 'Test envoyé : la page de test est sortie sur $cible.';
  }

  @override
  String get pmAlertesConnexion => 'Afficher les alertes à la connexion';

  @override
  String get pmAlertesConnexionDesc => 'Ruptures, crédits élevés, sessions non clôturées.';

  @override
  String get pmSeuilCredit => 'Seuil de crédit client';

  @override
  String get pmSeuilCreditDesc => 'Signale les clients au-delà de ce montant ; 0 pour tous.';

  @override
  String get pmSauverMaintenant => 'Sauvegarder maintenant';

  @override
  String get pmSauvegardeTerminee => 'Sauvegarde terminée';

  @override
  String get pmRestaurerDesc => 'Remplace toutes les données actuelles par celles d\'un fichier.';

  @override
  String get pmRestaurerBouton => 'Restaurer…';

  @override
  String get pmRestaurerConfirmTitre => 'Restaurer une sauvegarde ?';

  @override
  String get pmRestaurerConfirmMsg =>
      'Toutes les données actuelles (ventes, stock, clients…) seront remplacées au prochain démarrage.';

  @override
  String get pmRestaurerConfirmOk => 'Choisir le fichier et restaurer';

  @override
  String get pmPalierAvance => 'Palier Avancé';

  @override
  String get pmPalierAvanceDesc => 'Un magasin, 5 caissiers : devis, commandes, commandes fournisseurs et besoins.';

  @override
  String get pmPalierBasic => 'Palier Basic';

  @override
  String get pmPalierBasicDesc => 'Un magasin, 5 caissiers : caisse, ventes, stock, clients et fournisseurs.';

  @override
  String get pmPalierDemo => 'Mode démo';

  @override
  String get pmPalierDemoDesc => 'Données fictives, réinitialisées à la fermeture';

  @override
  String get pmPalierAucun => 'Application non activée';

  @override
  String get pmPalierAucunDesc => 'Choisissez une formule, connectez-vous à votre compte ou collez une clé.';

  @override
  String get pmActive => 'Active';

  @override
  String get pmCle => 'Clé de licence';

  @override
  String get pmCleDesc => 'Liée à ce poste.';

  @override
  String pmActiveeLe(String date) {
    return 'Activée le $date.';
  }

  @override
  String get pmGererLicence => 'Gérer la licence';

  @override
  String get pmGererLicenceDesc => 'Coller une clé reçue de BENS (secours hors ligne).';

  @override
  String get posPrixSousAchatInterdit => 'Prix inférieur au prix d\'achat : interdit par les paramètres.';

  @override
  String alertesExpireDepuis(int n) {
    return 'Expiré depuis $n j';
  }

  @override
  String get communSessionRequise => 'Aucune session de caisse ouverte : ouvrez une session avant d\'enregistrer.';

  @override
  String communFermeeDesc(String caisse) {
    return 'Ouvrez une session pour « $caisse » avant d\'enregistrer cette opération.';
  }

  @override
  String get posRaccourciE => 'Entrée rapide (achat d’un produit)';

  @override
  String get hiActSauvegarde => 'Sauvegarde';

  @override
  String get hiActRestauration => 'Restauration';

  @override
  String get posApercuTicket => 'Aperçu du ticket';

  @override
  String get posImprimer => 'Imprimer';

  @override
  String get posGabaritLatin => 'Latin';

  @override
  String get pmApercuAucuneVente => 'Aucune vente enregistrée : l’aperçu utilise un ticket d’exemple.';

  @override
  String get pmSauvegardeIncomplete => 'Sauvegarde automatique : choisissez un dossier et un mot de passe.';

  @override
  String get pmSauvegardeDossier => 'Dossier de sauvegarde';

  @override
  String get pmSauvegardeDossierDesc => 'Disque local, clé USB ou dossier synchronisé (Google Drive, OneDrive).';

  @override
  String get pmSauvegardeChanger => 'Changer';

  @override
  String get pmSauvegardeAuto => 'Sauvegarde automatique';

  @override
  String get pmSauvegardeAutoDesc => 'Faite à l’ouverture de l’application ; les 30 dernières sont conservées.';

  @override
  String get pmFrequenceDesactivee => 'Désactivée';

  @override
  String get pmFrequenceDemarrage => 'À chaque démarrage';

  @override
  String get pmFrequenceQuotidienne => 'Quotidienne';

  @override
  String get pmSauvegardeMdp => 'Mot de passe des sauvegardes';

  @override
  String get pmSauvegardeMdpDesc => 'Demandé pour restaurer une sauvegarde automatique.';

  @override
  String get pmSauvegardeMdpDefinir => 'Définir';

  @override
  String get pmSauvegardeMdpChanger => 'Changer';

  @override
  String pmSauvegardeDerniere(String date) {
    return 'Dernière sauvegarde automatique : $date';
  }

  @override
  String get communModifiePar => 'Modifié par';

  @override
  String get communModifieLe => 'Modifié le';

  @override
  String get communNombreObligatoire => 'Le nombre de pièces (2ᵉ stock) est obligatoire pour ce produit.';

  @override
  String get stkNombre => 'Nombre';

  @override
  String get stkNombreObligatoire => 'Nombre obligatoire';

  @override
  String get pmNombreActif => '2ᵉ stock « nombre » pour tous les produits';

  @override
  String get pmNombreActifDesc =>
      'Nombre de pièces saisi en plus de la quantité (ex. boucherie : kg + pièces), obligatoire à chaque mouvement.';

  @override
  String dsFavorisAide(int max) {
    return 'Cliquez sur un module pour l\'ajouter à vos favoris ou l\'en retirer ($max au maximum).';
  }

  @override
  String dsFavorisAideComplets(int max) {
    return 'Vos $max favoris sont choisis : retirez-en un pour en ajouter un autre.';
  }

  @override
  String get shellChoisirFavoris => 'Choisir les favoris';

  @override
  String get communTermine => 'Terminé';

  @override
  String get posRechMin => 'Min';

  @override
  String get posRechMax => 'Max';

  @override
  String get posRechToutesCategories => 'Toutes les catégories';

  @override
  String get posMontantTitre => 'Vente au montant';

  @override
  String get posMontantColis => 'Montant';

  @override
  String get posMontantAide =>
      'Article pesé ou non codifié : le montant s\'ajoute à une seule ligne du panier (200 puis 500 = 700).';

  @override
  String get posMontantAutre => 'Autre montant';

  @override
  String get posMontantModifier => 'Modifier le montant';

  @override
  String get posMontantChamp => 'Montant';

  @override
  String get posMontantInvalide => 'Saisissez un montant supérieur à 0.';

  @override
  String get posMontantLigneAide => 'Double-clic : modifier le montant';

  @override
  String get ventesListeProduits => 'Liste des produits';

  @override
  String ventesListeProduitsTitre(String code) {
    return 'Produits du panier $code';
  }

  @override
  String get ventesColis => 'Colis';

  @override
  String get selRechercherListe => 'Rechercher dans la liste';

  @override
  String get selProduit => 'Choisir un produit';

  @override
  String get selCategorie => 'Choisir une catégorie';

  @override
  String get selSousCategorie => 'Choisir une sous-catégorie';

  @override
  String get selRemise => 'Choisir une remise';

  @override
  String get selPack => 'Choisir un pack';

  @override
  String get selClient => 'Choisir un client';

  @override
  String get selFournisseur => 'Choisir un fournisseur';

  @override
  String get selMagasin => 'Choisir un magasin';

  @override
  String get selCaisse => 'Choisir une caisse';

  @override
  String get selSession => 'Choisir une session';

  @override
  String get selUtilisateur => 'Choisir un utilisateur';

  @override
  String get selVente => 'Choisir une vente';

  @override
  String get selColCode => 'Code';

  @override
  String get selColNom => 'Nom';

  @override
  String get selColDesignation => 'Désignation';

  @override
  String get selColCategorie => 'Catégorie';

  @override
  String get selColStock => 'Stock';

  @override
  String get selColPrix => 'Prix';

  @override
  String get selColTelephone => 'Téléphone';

  @override
  String get selColAdresse => 'Adresse';

  @override
  String get selColType => 'Type';

  @override
  String get selColValeur => 'Valeur';

  @override
  String get selColMagasin => 'Magasin';

  @override
  String get selColCaisse => 'Caisse';

  @override
  String get selColUtilisateur => 'Utilisateur';

  @override
  String get selColOuverture => 'Ouverture';

  @override
  String get selColStatut => 'Statut';

  @override
  String get selColDate => 'Date';

  @override
  String get selColClient => 'Client';

  @override
  String get selColTotal => 'Total';

  @override
  String get selColProduits => 'Produits';

  @override
  String get selColDescription => 'Description';

  @override
  String get selFiltreEtat => 'État';

  @override
  String get selTous => 'Tous';

  @override
  String selPoints(int n) {
    return '$n points';
  }

  @override
  String selNbProduits(int n) {
    return '$n produits';
  }

  @override
  String get retoursNouveauClient => 'Nouveau retour client';

  @override
  String get retoursNouveauFournisseur => 'Nouveau retour fournisseur';

  @override
  String get prdPorteeProduitAide => 'Appliquée automatiquement aux produits choisis, pendant sa période.';

  @override
  String get prdPorteeMontantAide => 'Choisie sur le panier en caisse, dès que le sous-total atteint le seuil.';

  @override
  String prdMontantPanierAide(String devise) {
    return 'Ex. −500 $devise sur le panier';
  }

  @override
  String get auditCreeLe => 'Créé le';

  @override
  String get auditModifieLe => 'Modifié le';

  @override
  String get auditModifiePar => 'Modifié par';

  @override
  String get prdFiltreQuantite => 'Quantité';

  @override
  String get prdToastSuppression => 'Suppression effectuée';

  @override
  String prdVersSansCategorie(int n) {
    return '$n produit(s) → Sans catégorie';
  }

  @override
  String stkNombreDispo(String quantite) {
    return 'Pièces : $quantite';
  }

  @override
  String get stkListeProduits => 'Liste des produits';

  @override
  String stkListeProduitsTitre(String code) {
    return 'Produits de $code';
  }

  @override
  String get stkAjouterSousSeuil => 'Produits sous le seuil';

  @override
  String get stkAjouterRuptures => 'Produits en rupture';

  @override
  String get stkAucunProduitAjoute => 'Aucun nouveau produit à ajouter.';

  @override
  String stkProduitsAjoutes(int n) {
    return '$n produit(s) ajouté(s)';
  }

  @override
  String get entFiltreType => 'Type d\'entrée';

  @override
  String get entTypeNormale => 'Entrée normale';

  @override
  String get tiersSoldeAvant => 'Solde avant';

  @override
  String get tiersSoldeApres => 'Solde après';

  @override
  String get stkErreurSortieRetour => 'Sortie liée à un retour : modifiez ou annulez le retour.';

  @override
  String get remiseSectionType => 'Type de remise';

  @override
  String get remiseSectionInfos => 'Informations générales';

  @override
  String get remiseSectionCalcul => 'Valeur de la remise';

  @override
  String get remiseSectionPeriode => 'Période de validité';

  @override
  String stkQteDansMagasin(String magasin) {
    return 'Qté dans $magasin';
  }

  @override
  String stkStockMagasinN(String magasin, String quantite) {
    return '$magasin : $quantite';
  }

  @override
  String get versementErreurPeriode =>
      'Période clôturée : ce versement ne peut plus être modifié. Annulez-le puis saisissez un nouveau versement.';

  @override
  String get retoursDateDuJour => 'Daté du jour, même après la clôture Z du jour de la vente.';

  @override
  String get situationCasse => 'Casse (perte)';

  @override
  String get situationPiecesTheoriques => 'Pièces théoriques';

  @override
  String get situationPiecesComptees => 'Pièces comptées';

  @override
  String get permDepasserPlafondCredit => 'Dépasser le plafond de crédit';

  @override
  String posErreurPlafondCredit(String plafond, String solde) {
    return 'Plafond de crédit du client dépassé ($plafond, crédit actuel $solde).';
  }

  @override
  String get tiersPlafondCredit => 'Plafond de crédit';

  @override
  String get tiersPlafondCreditAide => 'Vide ou 0 : sans plafond.';

  @override
  String get mvtCoffre => 'Coffre';

  @override
  String get mvtTimbre => 'Droit de timbre';

  @override
  String get retoursAvoirEmis =>
      'Un avoir a été émis pour ce retour (vente facturée) : il ne peut plus être modifié ni annulé.';

  @override
  String get tiersArticleImposition => 'Article d\'imposition';

  @override
  String get pmRegimeFiscal => 'Régime fiscal';

  @override
  String get pmRegimeFiscalDesc =>
      'Réel : TVA collectée sur les ventes et déductible sur les entrées. IFU : ventes sans TVA.';

  @override
  String get pmRegimeReel => 'Réel';

  @override
  String get pmRegimeIfu => 'IFU';

  @override
  String get pmTimbre => 'Droit de timbre';

  @override
  String get pmTimbreDesc => 'Ajouté aux factures sur la part payée en espèces (1 % à 2 %, minimum 5 DA).';

  @override
  String get factureVenteAnnulee => 'Vente annulée : aucune facture ne peut être émise.';

  @override
  String get exportFiscalG50 => 'Déclaration G50 (Excel)';

  @override
  String get exportFiscalG50Desc => 'TVA collectée et déductible par taux, timbre, TVA à payer';

  @override
  String get typeMouvementAnnulation => 'Annulation de vente';

  @override
  String get posErreurMonnaieSansEspeces =>
      'La monnaie rendue dépasse les espèces reçues : une carte, un chèque ou des points ne rendent pas de monnaie.';

  @override
  String get tiersSoldeInitial => 'Solde initial';

  @override
  String get tiersSoldeInitialAideClient => 'Reprise : montant dû par le client avant le logiciel (négatif = avance).';

  @override
  String get tiersSoldeInitialAideFournisseur =>
      'Reprise : montant dû au fournisseur avant le logiciel (négatif = avance).';

  @override
  String get tvaRecapitulatif => 'Récapitulatif TVA';

  @override
  String get tvaTaux => 'Taux TVA';

  @override
  String get tvaBaseHt => 'Base HT';

  @override
  String get tvaMontant => 'TVA';

  @override
  String get tvaTtc => 'TTC';

  @override
  String get tvaCollectee => 'TVA collectée';

  @override
  String get tvaDeductible => 'TVA déductible';

  @override
  String get tvaNette => 'TVA à payer';

  @override
  String get tvaHt => 'HT';

  @override
  String get situationTva => 'TVA par taux';

  @override
  String get situationGroupeFiscalite => 'Fiscalité';

  @override
  String get ventesOngletPaniers => 'Paniers';

  @override
  String get ventesOngletFactures => 'Factures & avoirs';

  @override
  String get factureNumero => 'N° facture';

  @override
  String get factureTypeFacture => 'Facture';

  @override
  String get factureTypeAvoir => 'Avoir';

  @override
  String get factureVente => 'Ticket';

  @override
  String get factureOrigine => 'Facture d\'origine';

  @override
  String get factureTimbre => 'Timbre';

  @override
  String get factureNet => 'Net à payer';

  @override
  String get factureEntites => 'Factures et avoirs';

  @override
  String get factureAucune => 'Aucune facture sur la période';

  @override
  String get factureKpiFactures => 'Factures émises';

  @override
  String get factureKpiFacture => 'Total facturé';

  @override
  String get factureKpiAvoirs => 'Total des avoirs';

  @override
  String get factureImprimer => 'Imprimer (duplicata)';

  @override
  String get factureChaineOk => 'Chaîne des factures intacte';

  @override
  String get achatErreurCommandeInconnue => 'Commande fournisseur introuvable pour ce fournisseur';

  @override
  String get achatErreurCommandeCloturee => 'Commande fournisseur annulée ou soldée : réception impossible';

  @override
  String get moduleDocuments => 'Devis & commandes';

  @override
  String get moduleCommandesFournisseurs => 'Commandes fournisseurs';

  @override
  String get docOngletDevis => 'Devis';

  @override
  String get docOngletProformas => 'Proformas';

  @override
  String get docOngletCommandes => 'Commandes clients';

  @override
  String get docOngletLivraisons => 'Bons de livraison';

  @override
  String get docTypeDevis => 'Devis';

  @override
  String get docTypeProforma => 'Proforma';

  @override
  String get docTypeCommande => 'Commande';

  @override
  String get docBonLivraison => 'Bon de livraison';

  @override
  String get docStatutEnCours => 'En cours';

  @override
  String get docStatutAccepte => 'Accepté';

  @override
  String get docStatutRefuse => 'Refusé';

  @override
  String get docStatutTransforme => 'Transformé en commande';

  @override
  String get docStatutExpire => 'Expiré';

  @override
  String get docStatutPartielle => 'Partiellement livrée';

  @override
  String get docStatutLivree => 'Livrée';

  @override
  String get docStatutAnnule => 'Annulé';

  @override
  String get docValidite => 'Validité';

  @override
  String get docOrigine => 'Origine';

  @override
  String get docLivre => 'Livré';

  @override
  String get docResteALivrer => 'Reste à livrer';

  @override
  String get docALivrer => 'À livrer';

  @override
  String get docQuantiteLivree => 'Quantité livrée';

  @override
  String get docPuTtc => 'P.U. TTC';

  @override
  String get docTotalTtc => 'Total TTC';

  @override
  String get docAucun => 'Aucun document sur la période';

  @override
  String get docKpiNombre => 'Documents';

  @override
  String get docKpiMontant => 'Montant total';

  @override
  String get docKpiALivrer => 'À livrer';

  @override
  String get docKpiTransformes => 'Transformés en commande';

  @override
  String get docImprimer => 'Imprimer (A4)';

  @override
  String get docAccepter => 'Accepter';

  @override
  String get docRefuser => 'Refuser';

  @override
  String get docTransformer => 'Transformer en commande';

  @override
  String get docLivrer => 'Livrer';

  @override
  String get docNouveauDevis => 'Nouveau devis';

  @override
  String get docNouvelleProforma => 'Nouvelle proforma';

  @override
  String get docNouvelleCommande => 'Nouvelle commande';

  @override
  String docNouveauTitre(String type) {
    return 'Nouveau document : $type';
  }

  @override
  String docModifierTitre(String type) {
    return 'Modifier : $type';
  }

  @override
  String get docChoisirClient => 'Choisir un client';

  @override
  String get docToastEnregistre => 'Document enregistré';

  @override
  String get docToastTransforme => 'Commande créée';

  @override
  String get docToastLivre => 'Livraison enregistrée';

  @override
  String docLivrerTitre(String code) {
    return 'Livrer la commande $code';
  }

  @override
  String get docMontantPaye => 'Montant payé';

  @override
  String get docMontantPayeAide => 'Laisser vide : livraison à crédit';

  @override
  String get docValiderLivraison => 'Valider la livraison';

  @override
  String get docPdfDevis => 'DEVIS';

  @override
  String get docPdfProforma => 'FACTURE PROFORMA';

  @override
  String get docPdfCommande => 'BON DE COMMANDE';

  @override
  String get docPdfLivraison => 'BON DE LIVRAISON';

  @override
  String docArretee(String type) {
    return 'Arrêté(e) le présent document ($type) à la somme de';
  }

  @override
  String get docMentionProforma => 'Document sans valeur comptable : ne vaut pas facture.';

  @override
  String get docSignatureClient => 'Bon pour accord (client)';

  @override
  String get docSignatureVendeur => 'Cachet et signature';

  @override
  String get docSignatureLivreur => 'Livré par';

  @override
  String get docSignatureReception => 'Reçu par (nom, signature)';

  @override
  String get docErreurClient => 'Client inconnu';

  @override
  String get docErreurInconnu => 'Document introuvable';

  @override
  String get docErreurNonModifiable =>
      'Ce document ne peut plus être modifié (transformé, refusé, annulé ou déjà livré)';

  @override
  String get docErreurDejaAnnule => 'Document déjà annulé';

  @override
  String get docErreurLivraisonLiee => 'Commande déjà livrée : annulez d\'abord la vente du bon de livraison';

  @override
  String get docErreurRienALivrer => 'Aucune quantité à livrer';

  @override
  String get docErreurQuantiteExcessive => 'Quantité supérieure au reste à livrer';

  @override
  String get docErreurLivraisonExistante => 'Cette vente a déjà un bon de livraison';

  @override
  String get docErreurVenteInconnue => 'Vente introuvable';

  @override
  String get cmdfNouvelle => 'Nouvelle commande fournisseur';

  @override
  String get cmdfModifier => 'Modifier la commande fournisseur';

  @override
  String cmdfTitre(String code) {
    return 'Commande fournisseur $code';
  }

  @override
  String get cmdfCommande => 'Commande fournisseur';

  @override
  String get cmdfPrix => 'Prix d\'achat';

  @override
  String get cmdfRecu => 'Reçu';

  @override
  String get cmdfReste => 'Reste à recevoir';

  @override
  String get cmdfReceptions => 'Entrées de réception';

  @override
  String get cmdfReceptionner => 'Réceptionner';

  @override
  String get cmdfSolder => 'Solder';

  @override
  String cmdfSolderMessage(String code) {
    return 'Solder la commande $code ? Le reliquat ne sera plus attendu.';
  }

  @override
  String get cmdfKpiAttendues => 'En attente de réception';

  @override
  String get cmdfStatutPartielle => 'Partiellement reçue';

  @override
  String get cmdfStatutRecue => 'Reçue';

  @override
  String get cmdfStatutSoldee => 'Soldée';

  @override
  String get cmdfPdfTitre => 'BON DE COMMANDE FOURNISSEUR';

  @override
  String get cmdfDepuisBesoin => 'Créer une commande fournisseur';

  @override
  String get cmdfErreurReceptionLiee => 'Commande déjà réceptionnée : annulez d\'abord les entrées liées';

  @override
  String get cmdfErreurDejaSoldee => 'Commande déjà soldée';

  @override
  String get apercuEnregistrerPdf => 'Enregistrer en PDF';

  @override
  String get rechercheGlobaleTitre => 'Recherche globale';

  @override
  String get rechercheGlobaleIndice => 'Rechercher dans tout le système…';

  @override
  String get rechercheGlobaleAide =>
      'Code, nom, téléphone, code-barres, référence : produits, clients, fournisseurs, ventes, factures, devis, livraisons, entrées, retours, versements…';

  @override
  String rechercheGlobaleAucun(String texte) {
    return 'Aucun résultat pour « $texte »';
  }

  @override
  String get prdPrixTtc => 'Prix de vente TTC';

  @override
  String get prdVenteTtc => 'Vente TTC';

  @override
  String get posClotureNegatif =>
      'Solde théorique négatif : il est sorti de cette caisse plus d\'espèces qu\'il n\'en est entré depuis l\'ouverture (voir le détail ci-dessus). Une caisse ne peut pas contenir moins de 0 : comptez les espèces réellement présentes (0 si le tiroir est vide), l\'écart sera enregistré comme manquant.';

  @override
  String get posTransfertTitre => 'Stock insuffisant dans ce magasin';

  @override
  String get posTransfertConfirmer => 'Transférer et ajouter';

  @override
  String posTransfertFait(String code) {
    return 'Transfert $code créé';
  }

  @override
  String get posTransfertQuestion => 'Transférer le manque pour compléter le panier ?';

  @override
  String get posTransfertDepuis => 'Depuis';

  @override
  String get posTransfertVers => 'Vers la caisse';

  @override
  String posTransfertStock(String stock) {
    return 'Stock : $stock';
  }

  @override
  String posTransfertManque(String quantite) {
    return 'Manque $quantite';
  }

  @override
  String get pmTvaCaisse => 'Vente en caisse avec TVA';

  @override
  String get pmTvaCaisseDesc => 'Oui : prix TTC (prix de vente HT + TVA du produit). Non : prix HT, ticket sans TVA.';

  @override
  String get pmTvaDocuments => 'Devis, proformas et commandes avec TVA';

  @override
  String get pmTvaDocumentsDesc => 'Même choix pour les devis, proformas, commandes clients et leurs livraisons.';

  @override
  String get docPuHt => 'P.U. HT';

  @override
  String get retoursMontantRetour => 'Montant retour';

  @override
  String get retoursMontantRetourAideClient => 'Rendu au client en espèces ; le reste va en avoir sur son solde.';

  @override
  String get retoursMontantRetourAideFournisseur =>
      'Versé par le fournisseur en espèces ; le reste est déduit de ce que vous lui devez.';

  @override
  String get retoursMontantRetourPassage => 'Client de passage : il récupère tout le montant du retour.';

  @override
  String retoursMontantRetourMax(String plafond) {
    return 'Entre 0 et $plafond';
  }

  @override
  String get retoursErreurMontant => 'Montant retour invalide : il doit être compris entre 0 et le montant du retour.';

  @override
  String retoursRepartition(String avoir, String versement) {
    return 'Versement $versement · Avoir $avoir';
  }

  @override
  String get retoursMontantComplet => 'Montant complet';

  @override
  String get offresTitre => 'Choisissez votre formule';

  @override
  String offresSousTitre(int jours) {
    return 'Chaque formule commence par $jours jours d\'essai gratuit. Ensuite, un paiement unique : la licence est à vous, à vie, sans abonnement.';
  }

  @override
  String offresEssaiGratuit(int jours) {
    return '$jours jours d\'essai gratuit';
  }

  @override
  String offresPrix(String prix) {
    return '$prix DA';
  }

  @override
  String get offresPaiementUnique => 'paiement unique, à vie';

  @override
  String offresMagasins(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n magasins', one: '1 magasin');
    return '$_temp0';
  }

  @override
  String offresScans(int n, int mois) {
    return '$n Smart Scans inclus ($mois mois)';
  }

  @override
  String get offresAtoutStock => 'Produits, stock, entrées / sorties et inventaire';

  @override
  String get offresAtoutPdv => 'Caisse : ventes, scan, tickets, multi-paniers';

  @override
  String get offresAtoutVentes => 'Ventes, factures, avoirs et retours';

  @override
  String get offresAtoutGestionCaisse => 'Gestion de caisse, clôtures et coffre';

  @override
  String get offresAtoutRapports => 'Tableau de bord, situation, zakat et historique';

  @override
  String get offresAtoutCommandesClients => 'Commandes clients et bons de livraison';

  @override
  String get offresAtoutBesoins => 'Listes de besoins';

  @override
  String get offresAtoutTransferts => 'Transferts entre magasins';

  @override
  String offresToutPlus(String formule) {
    return 'Tout $formule, plus :';
  }

  @override
  String offresCaisses(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n caisses', one: '1 caisse');
    return '$_temp0';
  }

  @override
  String get offresAtoutTiers => 'Clients, fournisseurs, versements et crédit';

  @override
  String get offresAtoutDevis => 'Devis et proformas';

  @override
  String get offresAtoutAchats => 'Commandes fournisseurs (réception partielle)';

  @override
  String get offresAtoutMultiMagasin => 'Multi-magasin (stock par magasin)';

  @override
  String get offresIdealBasic => 'Petit commerce, une seule caisse';

  @override
  String get offresIdealAvance => 'Commerce qui fait des devis et passe des commandes';

  @override
  String get offresIdealUltra => 'Plusieurs magasins, gestion complète';

  @override
  String get offresTout => 'Tous les modules';

  @override
  String offresEssayer(int jours) {
    return 'Essayer $jours jours';
  }

  @override
  String offresChoisir(String formule) {
    return 'Choisir $formule';
  }

  @override
  String get offresDejaCompte => 'Vous avez déjà un compte ?';

  @override
  String get offresSeConnecter => 'Se connecter';

  @override
  String get offresJaiUneCle => 'J\'ai une clé d\'activation';

  @override
  String offresEssaiTermine(String date) {
    return 'Votre essai s\'est terminé le $date. Choisissez une formule : BENS vous contacte pour le paiement, puis l\'application se débloque d\'elle-même. Vos données sont gardées.';
  }

  @override
  String get offresSansFormule =>
      'Aucune formule active sur ce poste. Choisissez une formule : BENS vous contacte pour le paiement.';

  @override
  String get offresLicenceRefuseeInvalide =>
      'BENS a bien envoyé votre licence, mais cette version de CaisseDZ la refuse (clé prévue pour une autre application ou une autre version). Installez la dernière version de CaisseDZ puis cliquez sur Actualiser ; sinon, contactez BENS.';

  @override
  String get offresLicenceRefuseeAutrePoste =>
      'BENS a envoyé une licence prévue pour un autre PC. Cliquez sur Changer de compte et reconnectez-vous sur ce PC ; sinon, contactez BENS.';

  @override
  String get offresLicenceRefuseeDate =>
      'La date de ce PC a été reculée : la licence envoyée par BENS est refusée. Remettez la date et l\'heure du PC à jour, puis cliquez sur Actualiser.';

  @override
  String get offresDemandeTitre => 'Demande envoyée';

  @override
  String offresDemandeDetail(String telephone, String formule) {
    return 'BENS Digital Solutions vous rappelle au $telephone pour le paiement de la formule $formule. Vous pouvez aussi nous écrire sur WhatsApp.';
  }

  @override
  String get offresWhatsApp => 'Écrire sur WhatsApp';

  @override
  String offresWhatsAppMessage(String formule, String telephone) {
    return 'Bonjour, je souhaite acheter CaisseDZ Desktop $formule (compte $telephone).';
  }

  @override
  String get offresHorsLigne => 'Hors ligne : prix indicatifs. Connectez le poste à internet pour créer votre compte.';

  @override
  String get offresSeDeconnecter => 'Changer de compte';

  @override
  String get compteCreerTitre => 'Créer votre compte';

  @override
  String compteCreerSousTitre(String formule, int jours) {
    return 'Formule $formule · $jours jours d\'essai gratuit';
  }

  @override
  String get compteChangerFormule => 'Changer de formule';

  @override
  String compteFormule(String formule) {
    return 'Formule $formule';
  }

  @override
  String get offresSelectionnee => 'Formule sélectionnée';

  @override
  String get offresSelectionner => 'Sélectionner cette formule';

  @override
  String get compteNom => 'Nom et prénom';

  @override
  String get compteCommerce => 'Nom du commerce';

  @override
  String get compteFacultatif => 'Facultatif';

  @override
  String get compteTelephone => 'Numéro de téléphone';

  @override
  String get compteMotDePasse => 'Mot de passe';

  @override
  String get compteBensMotDePasseAide =>
      '8 caractères au moins. Sur un poste neuf, il devient aussi celui de l\'administrateur (identifiant admin).';

  @override
  String get compteBensConfirmer => 'Confirmer le mot de passe';

  @override
  String get compteCreerBouton => 'Créer mon compte et commencer l\'essai';

  @override
  String get compteEssaiDejaUtilise =>
      'Compte créé. L\'essai gratuit a déjà été utilisé sur ce poste ou avec ce numéro : choisissez une formule pour continuer.';

  @override
  String get compteConnexionTitre => 'Connexion à votre compte';

  @override
  String get compteConnexionSousTitre =>
      'Le compte BENS de votre commerce : votre formule et votre licence. Se connecter ici déplace la licence sur ce poste.';

  @override
  String get compteConnexionBouton => 'Se connecter';

  @override
  String get compteMotDePasseOublie => 'Mot de passe oublié ?';

  @override
  String get comptePasEncore => 'Pas encore de compte ?';

  @override
  String get compteVoirFormules => 'Voir les formules';

  @override
  String get compteRetour => 'Retour';

  @override
  String get compteErrTelephone => 'Numéro invalide : 10 chiffres commençant par 05, 06 ou 07.';

  @override
  String get compteErrNom => 'Indiquez votre nom (2 caractères au moins).';

  @override
  String get compteErrMotDePasse => 'Le mot de passe fait 8 caractères au moins.';

  @override
  String get compteErrConfirmation => 'Les deux mots de passe ne sont pas identiques.';

  @override
  String get compteErrNumeroPris => 'Ce numéro a déjà un compte : connectez-vous.';

  @override
  String get compteErrIdentifiants => 'Numéro ou mot de passe incorrect.';

  @override
  String get compteErrReseau => 'Pas de connexion à BENS. Vérifiez internet et réessayez.';

  @override
  String get compteErrTropDEssais => 'Trop d\'essais. Réessayez dans 15 minutes.';

  @override
  String get compteErrAucunCompte => 'Aucun compte avec ce numéro.';

  @override
  String get compteErrCode => 'Code incorrect ou expiré. Demandez-en un nouveau à BENS.';

  @override
  String get compteErrServeur => 'Le serveur BENS n\'a pas pu répondre. Réessayez plus tard.';

  @override
  String get oubliTitre => 'Mot de passe oublié';

  @override
  String get oubliIntro =>
      'Obtenez un code de récupération et envoyez-le à BENS sur WhatsApp. Après vérification, BENS vous envoie un code de réinitialisation, valable 48 heures.';

  @override
  String get oubliDemander => 'Obtenir mon code de récupération';

  @override
  String get oubliVotreCode => 'Votre code de récupération';

  @override
  String get oubliCopier => 'Copier';

  @override
  String get oubliCopie => 'Copié';

  @override
  String get oubliEnvoyer => 'Envoyer sur WhatsApp';

  @override
  String oubliMessage(String telephone, String code) {
    return 'Bonjour, j\'ai oublié le mot de passe de mon compte CaisseDZ ($telephone). Mon code de récupération : $code';
  }

  @override
  String get oubliRecu => 'J\'ai reçu mon code';

  @override
  String get oubliCodeReset => 'Code de réinitialisation';

  @override
  String get oubliNouveau => 'Nouveau mot de passe';

  @override
  String get oubliValider => 'Changer le mot de passe';

  @override
  String get activationColler => 'Coller';

  @override
  String get activationWhatsApp => 'Envoyer sur WhatsApp';

  @override
  String get activationCleSignee =>
      'Envoyez le code de ce poste à BENS, puis collez ici la clé reçue (132 caractères).';

  @override
  String get activationErrVide => 'Collez la clé reçue.';

  @override
  String get activationErrInvalide => 'Clé invalide. Vérifiez qu\'elle a été copiée en entier.';

  @override
  String get activationErrAutrePoste => 'Cette clé est pour un autre poste. Envoyez-nous le code ci-dessus.';

  @override
  String activationErrExpiree(String date) {
    return 'Votre licence a expiré le $date. Contactez-nous pour la renouveler.';
  }

  @override
  String get activationErrDate => 'La date du poste semble incorrecte. Corrigez la date et l\'heure.';

  @override
  String get activationPoste => 'Code de ce poste';

  @override
  String get activationRetourOffres => 'Retour aux formules';

  @override
  String get licenceUltra => 'Ultra';

  @override
  String licenceEssai(String palier) {
    return 'Essai $palier';
  }

  @override
  String shellBandeauEssai(String palier, int jours) {
    String _temp0 = intl.Intl.pluralLogic(
      jours,
      locale: localeName,
      other: '$jours jours restants',
      one: 'dernier jour',
    );
    return 'Essai $palier : $_temp0';
  }

  @override
  String get shellVoirFormules => 'Choisir une formule';

  @override
  String get pmPalierUltra => 'Palier Ultra';

  @override
  String get pmPalierUltraDesc => 'Jusqu\'à 15 magasins et 15 caissiers, transferts, tous les modules.';

  @override
  String pmPalierEssai(String palier) {
    return 'Essai $palier';
  }

  @override
  String pmPalierEssaiDesc(String date) {
    return 'Essai gratuit jusqu\'au $date, puis lecture seule tant qu\'aucune formule n\'est achetée.';
  }

  @override
  String pmValableJusquAu(String date) {
    return 'Valable jusqu\'au $date';
  }

  @override
  String get pmLicencePermanente => 'Licence permanente';

  @override
  String get pmCodePoste => 'Code de ce poste';

  @override
  String get pmCompteBens => 'Compte BENS';

  @override
  String get pmCompteBensDesc => 'Le compte de votre commerce : la licence de ce poste en vient.';

  @override
  String get pmAucunCompte => 'Aucun compte BENS sur ce poste';

  @override
  String get pmDeconnecterCompte => 'Déconnecter ce poste';

  @override
  String get pmDeconnecterCompteConfirme =>
      'La licence venue du compte est retirée de ce poste : il faudra se reconnecter pour l\'utiliser. Vos données restent sur le poste.';

  @override
  String get pmVoirFormules => 'Formules et mises à niveau';

  @override
  String shellReservePalier(String palier) {
    return 'Réservé au palier $palier';
  }

  @override
  String dsGatePalierTitre(String palier) {
    return 'Disponible avec le palier $palier';
  }

  @override
  String dsGatePalierAction(String palier) {
    return 'Passer au palier $palier';
  }

  @override
  String get lectureSeuleTitre => 'Lecture seule';

  @override
  String get lectureSeuleCourt => 'Lecture seule (essai terminé)';

  @override
  String get lectureSeuleDetail =>
      'L\'essai est terminé : ce module attend l\'achat d\'une formule. Ventes, produits, stock et rapports restent consultables, vos données sont gardées.';

  @override
  String lectureSeuleBandeau(String date) {
    return 'Essai terminé le $date : lecture seule. Vos données sont gardées ; choisissez une formule pour continuer à vendre.';
  }

  @override
  String get limiteCaissiers =>
      'Votre formule ne permet pas d\'autre caissier. Passez à la formule supérieure (Paramètres › Licence).';

  @override
  String get limiteMagasins =>
      'Votre formule ne permet pas d\'autre magasin : le multi-magasin est dans la formule Ultra.';

  @override
  String get limiteCaisses =>
      'Votre formule ne permet pas d\'autre caisse. Passez à la formule supérieure (Paramètres › Licence).';

  @override
  String get limiteTransfertsCaisse =>
      'Votre formule n\'a qu\'une caisse : les transferts entre caisses sont dans les formules Advanced et Ultra.';

  @override
  String get smartScanErreurLicence =>
      'La licence de ce poste n\'est pas reconnue par Smart Scan. Vérifiez votre formule (Paramètres › Licence).';

  @override
  String get smartScanPacksTitre => 'Acheter un pack Smart Scan';

  @override
  String smartScanPackLigne(String nom, int scans, String prix) {
    return '$nom · $scans scans · $prix';
  }

  @override
  String get smartScanPackCompte =>
      'Connectez ce poste à votre compte BENS pour acheter des packs (Paramètres › Licence).';

  @override
  String smartScanExpiration(int scans, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      scans,
      locale: localeName,
      other: '$scans Smart Scans expirent',
      one: '1 Smart Scan expire',
    );
    return '$_temp0 le $date : utilisez-les ou ajoutez un pack.';
  }

  @override
  String get permUtiliserMobile => 'Application mobile (CaisseDZ Scan)';

  @override
  String get mobileBouton => 'Application mobile';

  @override
  String get mobileTitre => 'Application mobile CaisseDZ Scan';

  @override
  String get mobileEtape1 => 'Installez CaisseDZ Scan.';

  @override
  String get mobileEtape2 => 'Connectez-vous au même Wi-Fi.';

  @override
  String get mobileEtape3 => 'Scannez ce QR code.';

  @override
  String get mobileEtape4 => 'Le téléphone est prêt.';

  @override
  String get mobileAucunReseau =>
      'Aucun réseau local détecté : connectez cet ordinateur au Wi-Fi ou au réseau de la boutique.';

  @override
  String mobileErreurDemarrage(String detail) {
    return 'Le service mobile n\'a pas pu démarrer : $detail';
  }

  @override
  String mobileQrExpire(String heure) {
    return 'Code valable jusqu\'à $heure';
  }

  @override
  String get mobileNouveauQr => 'Nouveau QR code';

  @override
  String get mobileActiver => 'Activer l\'application mobile';

  @override
  String mobileQrDe(String nom) {
    return 'QR code de $nom';
  }

  @override
  String get mobileDesactiver => 'Désactiver';

  @override
  String mobileAppareils(int nombre) {
    return 'Téléphones appairés ($nombre)';
  }

  @override
  String mobileMesAppareils(int nombre) {
    return 'Mes téléphones ($nombre)';
  }

  @override
  String get mobileAucunAppareil => 'Aucun téléphone appairé pour l\'instant.';

  @override
  String mobileAppaireLe(String date) {
    return 'Appairé le $date';
  }

  @override
  String mobileDernierAcces(String date) {
    return 'Dernier accès $date';
  }

  @override
  String get mobileConnecte => 'Connecté';

  @override
  String get mobileFactureRecueTitre => 'Facture reçue du téléphone';

  @override
  String mobileFactureRecueMessage(String nom, String bon) {
    return '$nom a envoyé une photo de facture ($bon).';
  }

  @override
  String get mobileOuvrirSmartScan => 'Ouvrir Smart Scan';

  @override
  String get mobileRevoquer => 'Révoquer';

  @override
  String mobileRevoquerTitre(String nom) {
    return 'Révoquer « $nom » ?';
  }

  @override
  String get mobileRevoquerMessage =>
      'Ce téléphone ne pourra plus se connecter à ce poste tant qu\'il n\'aura pas scanné un nouveau QR code.';

  @override
  String get catalogueRayonsTitre => 'Choisissez vos rayons';

  @override
  String get catalogueRayonsSousTitre =>
      'Selon votre activité, téléchargez les produits les plus demandés de chaque rayon : code-barres, nom et photo, sans prix ni stock. Vous pourrez en ajouter d\'autres plus tard depuis Paramètres.';

  @override
  String catalogueRayonsNbProduits(String nombre) {
    return '$nombre produits';
  }

  @override
  String get catalogueRayonsBientot => 'Bientôt';

  @override
  String get catalogueRayonsDejaTelecharge => 'Déjà téléchargé';

  @override
  String get catalogueRayonsToutSelectionner => 'Tout sélectionner';

  @override
  String get catalogueRayonsToutDeselectionner => 'Tout désélectionner';

  @override
  String catalogueRayonsSelection(int rayons, String produits) {
    String _temp0 = intl.Intl.pluralLogic(
      rayons,
      locale: localeName,
      other: '$rayons rayons · $produits produits',
      one: '1 rayon · $produits produits',
      zero: 'Aucun rayon choisi',
    );
    return '$_temp0';
  }

  @override
  String get catalogueRayonsPlusTard => 'Plus tard';

  @override
  String get catalogueRayonsAppliquer => 'Appliquer';

  @override
  String get catalogueRayonsChargement => 'Chargement des rayons…';

  @override
  String get catalogueRayonsHorsLigne =>
      'Le catalogue BENS est injoignable. Vérifiez la connexion internet, puis réessayez.';

  @override
  String get catalogueRayonsReessayer => 'Réessayer';

  @override
  String catalogueRayonsTelechargement(String rayon) {
    return 'Téléchargement : $rayon…';
  }

  @override
  String catalogueRayonsProgres(String recus, String attendus) {
    return '$recus / $attendus produits reçus';
  }

  @override
  String get catalogueRayonsEchec =>
      'Le téléchargement a échoué : rien n\'a été ajouté. Vérifiez la connexion internet, puis réessayez.';

  @override
  String get catalogueRayonsResultatTitre => 'Produits téléchargés';

  @override
  String catalogueRayonsResultatMessage(String telecharges, String pourcentage) {
    return '$telecharges produits ajoutés à votre catalogue : $pourcentage % des produits des rayons choisis.';
  }

  @override
  String catalogueRayonsDejaPresents(String nombre) {
    return '$nombre produits étaient déjà dans votre catalogue (même code-barres) : ils sont restés tels quels.';
  }

  @override
  String get catalogueRayonsSansPrix =>
      'Ces produits n\'ont ni prix ni stock : renseignez le prix dans la fiche produit ou à la première entrée en stock.';

  @override
  String catalogueRayonsLigne(String telecharges, String disponibles, String pourcentage) {
    return '$telecharges / $disponibles · $pourcentage %';
  }

  @override
  String get catalogueRayonsContinuer => 'Continuer';

  @override
  String get catalogueRayonsBouton => 'Catalogue BENS';

  @override
  String get prdDesignationAr => 'Nom arabe';

  @override
  String get prdDesignationArIndice => 'Ex. زيت إليو 1 ل';

  @override
  String get posCatalogueTrouveTitre => 'Trouvé dans le catalogue BENS';

  @override
  String get posCatalogueCreer => 'Créer depuis le catalogue';

  @override
  String get posCatalogueRecherche => 'Recherche dans le catalogue BENS…';

  @override
  String catalogueRayonsNbTendances(String nombre) {
    return '$nombre en tendance';
  }

  @override
  String get posCatalogueAConfirmerTitre => 'Produit proposé par une boutique';

  @override
  String posCatalogueAConfirmerQuestion(int score, int seuil) {
    return 'Est-ce bien ce produit ? Votre réponse aide à confirmer le catalogue ($score sur $seuil).';
  }

  @override
  String get posCatalogueOui => 'Oui, c\'est ce produit';

  @override
  String get posCatalogueNon => 'Ce n\'est pas ce produit';

  @override
  String prixDetailHt(String montant) {
    return 'HT $montant';
  }

  @override
  String prixDetailTva(String taux, String montant) {
    return 'TVA $taux $montant';
  }

  @override
  String prixDetailTtc(String montant) {
    return 'TTC $montant';
  }

  @override
  String get pmAffichagePrix => 'Affichage des prix';

  @override
  String get pmAffichagePrixDesc =>
      'Lignes du panier, devis, proformas et commandes quand la TVA s\'applique. Les cartes produits de la caisse montrent le seul prix de vente, sans TVA.';

  @override
  String get pmAffichageTtc => 'HT et TTC';

  @override
  String get pmAffichageTva => 'HT et TVA';

  @override
  String get pmAffichageTous => 'HT, TVA et TTC';

  @override
  String get docTvaUnitaire => 'TVA unitaire';

  @override
  String get docTotalHt => 'Total HT';

  @override
  String get entManuel => 'Manuel';

  @override
  String get entManuelTitre => 'Ajouter un produit';

  @override
  String get entManuelAjouter => 'Ajouter à l\'entrée';

  @override
  String get mobileChoixTitre => 'Nouveau téléphone à connecter';

  @override
  String get mobileChoixMessage =>
      'Ce téléphone a scanné votre QR code. Choisissez l\'utilisateur qui ouvrira CaisseDZ Scan sur ce téléphone : il s\'y connectera avec son compte et ses droits.';

  @override
  String get mobileChoixRefuser => 'Refuser';

  @override
  String get mobileChoixConnecter => 'Connecter ce téléphone';

  @override
  String get mobileChoixNonAutorise => 'Sans autorisation mobile (rôle ou mot de passe)';

  @override
  String mobileChoixVersion(String version) {
    return 'version $version';
  }

  @override
  String get prdPalette => 'Palette';

  @override
  String prdColisN(int n) {
    return 'Colis $n';
  }

  @override
  String get prdColisNom => 'Nom du colis';

  @override
  String get prdColisQuantite => 'Pièces par colis';

  @override
  String get prdColisPrix => 'Prix du colis';

  @override
  String get prdColisRetirer => 'Retirer ce colis';

  @override
  String get prdColisAjouter => 'Ajouter un colis';

  @override
  String prdColisAide(int max) {
    return 'Jusqu\'à $max colis, chacun avec son nom (boîte, carton, palette…), ses pièces et son prix ; vendus tels quels en caisse.';
  }

  @override
  String get produitErreurTropDeColis => '5 colis au plus par produit.';

  @override
  String get alpGroupeVentes => 'Ventes';

  @override
  String get alpGroupeStock => 'Stock';

  @override
  String get alpGroupePrix => 'Prix';

  @override
  String get alpGroupeQualite => 'Qualité';

  @override
  String get alpGroupeMarche => 'Marché';

  @override
  String get alpMeilleuresVentes => 'Meilleures ventes';

  @override
  String get alpStockDormant => 'Stock dormant';

  @override
  String get alpCandidatsRemise => 'Candidats à une remise';

  @override
  String get alpMargeFaible => 'Marge faible ou vente à perte';

  @override
  String get alpRetoursEleves => 'Retours élevés';

  @override
  String get alpEnHausse => 'Produits en hausse';

  @override
  String get alpStockLent => 'Stock lent';

  @override
  String get alpJamaisVendus => 'Jamais vendus';

  @override
  String get alpRemisesInefficaces => 'Remises sans effet';

  @override
  String get alpStockAnormal => 'Stock anormal';

  @override
  String get alpHausseFournisseur => 'Hausse du prix fournisseur';

  @override
  String get alpAchetesEnsemble => 'Achetés ensemble';

  @override
  String get alpStockDesequilibre => 'Stock déséquilibré entre magasins';

  @override
  String get alpRuptureSansCommande => 'Rupture sans commande';

  @override
  String get alpSaisonniers => 'Produits de saison';

  @override
  String get alpRupturesFrequentes => 'Ruptures fréquentes';

  @override
  String get alpFicheIncomplete => 'Fiche produit incomplète';

  @override
  String get alpBonneMargePeuVendus => 'Bonne marge, peu vendu';

  @override
  String get alpNouveautesMarche => 'Nouveautés du marché';

  @override
  String get alpTendancesMarche => 'Tendances du marché que vous n\'avez pas';

  @override
  String get alpRegleMeilleuresVentes =>
      'Les N produits les plus vendus sur la période (nets des retours) ; à réapprovisionner quand le stock couvre moins de Y jours de ventes.';

  @override
  String get alpRegleStockDormant => 'En stock, aucune vente depuis plus de X jours ; classés par valeur immobilisée.';

  @override
  String get alpRegleCandidatsRemise =>
      'Dormants ou ventes en baisse de plus de X %, avec une marge encore au-dessus de Y % : une remise est conseillée.';

  @override
  String get alpRegleMargeFaible =>
      'Prix de vente HT proche du dernier prix d\'achat HT (marge sous X %) ou en dessous.';

  @override
  String get alpRegleRetoursEleves =>
      'Plus de X % des quantités vendues sur la période sont revenues en retour (5 vendus au moins).';

  @override
  String get alpRegleEnHausse => 'Ventes des X derniers jours plus de Y % au-dessus des X jours d\'avant.';

  @override
  String get alpRegleStockLent => 'Au rythme des ventes de la période, le stock mettrait plus de X jours à s\'écouler.';

  @override
  String get alpRegleJamaisVendus => 'En stock depuis plus de X jours, jamais vendu.';

  @override
  String get alpRegleRemisesInefficaces =>
      'Remise active depuis au moins 7 jours : les ventes n\'ont pas augmenté par rapport au même nombre de jours avant elle.';

  @override
  String get alpRegleStockAnormal =>
      'Stock négatif, sorties « Casse » répétées ou gros écart d\'inventaire sur la période.';

  @override
  String get alpRegleHausseFournisseur =>
      'Dernier prix d\'achat plus de X % au-dessus du précédent : prix de vente conseillé à marge égale.';

  @override
  String get alpRegleAchetesEnsemble =>
      'Deux produits sur le même ticket dans plus de X % des ventes du moins vendu des deux : à proposer en pack.';

  @override
  String get alpRegleStockDesequilibre =>
      'Bas ou en rupture dans un magasin, largement au-dessus du seuil dans un autre : transfert conseillé.';

  @override
  String get alpRegleRuptureSansCommande =>
      'Rupture ou sous le seuil sans commande fournisseur ouverte, ou avec une commande en retard de plus de X jours.';

  @override
  String get alpRegleSaisonniers => 'Vendu l\'an passé dans les X prochains jours plus que le stock actuel.';

  @override
  String get alpRegleRupturesFrequentes => 'Plus de X jours en rupture sur la période ; ventes perdues estimées.';

  @override
  String get alpRegleFicheIncomplete =>
      'Sans code-barres, sans photo, rangé dans la catégorie Divers ou sans prix de vente.';

  @override
  String get alpRegleBonneMargePeuVendus =>
      'Dans les X % des meilleures marges, mais dans la moitié la moins vendue (hors favoris de la caisse).';

  @override
  String get alpRegleNouveautesMarche =>
      'Produits confirmés nouveaux sur le marché par le catalogue BENS (apportés par une boutique CaisseDZ) depuis moins de X jours, que vous n\'avez jamais eus en stock.';

  @override
  String get alpRegleTendancesMarche =>
      'Produits qui se vendent dans plusieurs boutiques CaisseDZ (catalogue BENS) et que vous n\'avez jamais eus en stock.';

  @override
  String get alpActionBesoin => 'Créer un besoin';

  @override
  String get alpActionRemise => 'Créer une remise';

  @override
  String get alpActionPrix => 'Modifier le prix';

  @override
  String get alpActionRetours => 'Voir les retours';

  @override
  String get alpActionModifierRemise => 'Modifier la remise';

  @override
  String get alpActionMouvements => 'Voir les mouvements';

  @override
  String get alpActionPack => 'Créer un pack';

  @override
  String get alpActionTransfert => 'Créer un transfert';

  @override
  String get alpActionCommande => 'Commander';

  @override
  String get alpActionSeuil => 'Ajuster le seuil';

  @override
  String get alpActionFiche => 'Compléter la fiche';

  @override
  String get alpActionFavori => 'Ajouter aux favoris caisse';

  @override
  String alpFavoriAjoute(String produit) {
    return '« $produit » est dans les favoris de la caisse';
  }

  @override
  String get alpActionCreerProduit => 'Créer le produit';

  @override
  String get alpSeuilPeriode => 'Période d\'analyse des ventes';

  @override
  String get alpSeuilTopN => 'Nombre de produits';

  @override
  String get alpSeuilCouverture => 'Couverture minimale';

  @override
  String get alpSeuilDormant => 'Sans vente depuis';

  @override
  String get alpSeuilBaisse => 'Baisse des ventes';

  @override
  String get alpSeuilMargeRemise => 'Marge gardée';

  @override
  String get alpSeuilMargeFaible => 'Marge minimale';

  @override
  String get alpSeuilRetours => 'Taux de retour';

  @override
  String get alpSeuilHausseJours => 'Période comparée';

  @override
  String get alpSeuilHaussePct => 'Hausse des ventes';

  @override
  String get alpSeuilLent => 'Écoulement au-delà de';

  @override
  String get alpSeuilJamaisVendu => 'En stock depuis';

  @override
  String get alpSeuilCasse => 'Sorties « Casse »';

  @override
  String get alpSeuilEcart => 'Écart d\'inventaire';

  @override
  String get alpSeuilHausseAchat => 'Hausse du prix d\'achat';

  @override
  String get alpSeuilEnsemble => 'Sur le même ticket';

  @override
  String get alpSeuilRetard => 'Commande en retard de';

  @override
  String get alpSeuilSaison => 'Jours à venir (an passé)';

  @override
  String get alpSeuilRuptures => 'Jours en rupture';

  @override
  String get alpSeuilBonneMarge => 'Meilleures marges';

  @override
  String get alpSeuilNouveautes => 'Arrivés depuis';

  @override
  String get alpJours => 'jours';

  @override
  String get alpFois => 'fois';

  @override
  String get alpProduits => 'produits';

  @override
  String alpDStock(String stock) {
    return 'stock $stock';
  }

  @override
  String alpDVendus(String quantite) {
    return '$quantite vendus';
  }

  @override
  String alpDCouverture(String jours) {
    return '$jours j de ventes en stock';
  }

  @override
  String alpDSansVente(String jours) {
    return 'aucune vente depuis $jours j';
  }

  @override
  String alpDValeur(String montant) {
    return '$montant immobilisés';
  }

  @override
  String alpDBaisse(String pct) {
    return 'ventes $pct %';
  }

  @override
  String alpDMarge(String pct) {
    return 'marge $pct %';
  }

  @override
  String alpDRemiseConseillee(String pct) {
    return 'remise conseillée $pct %';
  }

  @override
  String alpDDernierAchat(String montant) {
    return 'dernier achat $montant';
  }

  @override
  String get alpDPerte => 'vendu à perte';

  @override
  String alpDPrixConseille(String montant) {
    return 'prix conseillé $montant';
  }

  @override
  String alpDRetours(String retournes, String vendus, String pct) {
    return '$retournes retournés sur $vendus vendus ($pct %)';
  }

  @override
  String alpDHausse(String quantite, String avant, String pct) {
    return '$quantite vendus contre $avant ($pct %)';
  }

  @override
  String alpDEcoulement(String jours) {
    return 'écoulé en $jours j au rythme actuel';
  }

  @override
  String alpDJamaisVendu(String jours) {
    return 'jamais vendu, en stock depuis $jours j';
  }

  @override
  String alpDRemise(String remise, String apres, String jours, String avant) {
    return '$remise : $apres vendus en $jours j contre $avant avant';
  }

  @override
  String get alpDNegatif => 'stock négatif';

  @override
  String alpDCasses(String nombre) {
    return '$nombre sorties « Casse »';
  }

  @override
  String alpDEcart(String quantite) {
    return 'écart d\'inventaire $quantite';
  }

  @override
  String alpDHausseAchat(String avant, String apres, String pct) {
    return 'achat $avant → $apres ($pct %)';
  }

  @override
  String alpDEnsemble(String produit, String tickets, String pct) {
    return 'avec $produit sur $tickets tickets ($pct %)';
  }

  @override
  String alpDTransfert(String quantite, String depuis, String stockDepuis, String vers, String stockVers) {
    return 'transférer $quantite de $depuis ($stockDepuis) vers $vers ($stockVers)';
  }

  @override
  String alpDCommandeRetard(String jours) {
    return 'commande en retard de $jours j';
  }

  @override
  String get alpDAucuneCommande => 'aucune commande fournisseur';

  @override
  String alpDSaison(String quantite, String jours) {
    return '$quantite vendus l\'an passé dans les $jours prochains jours';
  }

  @override
  String alpDRuptures(String jours, String perdues) {
    return '$jours j en rupture · environ $perdues ventes perdues';
  }

  @override
  String get alpDSansCodeBarres => 'sans code-barres';

  @override
  String get alpDSansPhoto => 'sans photo';

  @override
  String get alpDCategorieDivers => 'catégorie Divers';

  @override
  String get alpDSansPrix => 'sans prix de vente';

  @override
  String alpDArrive(String jours) {
    return 'arrivé du catalogue BENS il y a $jours j';
  }

  @override
  String alpDTendance(String jours) {
    return 'tendance depuis $jours j';
  }

  @override
  String get situationAlp => 'Alertes produits';

  @override
  String get situationGroupeAlertes => 'Alertes';

  @override
  String get alpFiltreType => 'Alerte';

  @override
  String get alpToutes => 'Toutes les alertes';

  @override
  String get alpColAlerte => 'Alerte';

  @override
  String get alpColDetail => 'Détail';

  @override
  String get alpColAction => 'Action';

  @override
  String get alpCarteTitre => 'Alertes produits';

  @override
  String get alpCarteAucune => 'Aucune alerte produit.';

  @override
  String get alpCarteInfo =>
      'Calculées sur les ventes nettes des retours et le journal du stock (Paramètres › Alertes). Cliquez sur une alerte pour la voir dans la Situation.';

  @override
  String alpCarteCritiques(int nombre) {
    return '$nombre à traiter';
  }

  @override
  String get alpCarteNouvelles => 'Nouvelles alertes';

  @override
  String get alpActualiser => 'Actualiser';

  @override
  String get alpParamTitre => 'Alertes produits';

  @override
  String get alpParamDesc =>
      'Vingt alertes calculées sur les ventes (nettes des retours), le journal du stock, les achats et le catalogue BENS. Désactivez celles qui ne vous servent pas et ajustez leurs seuils.';

  @override
  String alpParamActive(String alerte) {
    return 'Activer « $alerte »';
  }

  @override
  String get alpCritiques => 'À traiter';

  @override
  String get dsRestaurer => 'Restaurer';

  @override
  String get dsRestaures => 'restaurés';

  @override
  String archArchives(int nombre) {
    return 'Archives ($nombre)';
  }

  @override
  String get archRetourListe => 'Retour à la liste';

  @override
  String get archBandeau =>
      'Éléments archivés : gardés pour l\'historique (anciens documents, rapports, soldes), absents des listes et des sélecteurs. Restaurez-les pour les réutiliser.';

  @override
  String get archAucune => 'Aucun élément archivé.';

  @override
  String get archDescription =>
      'Les éléments qui ont un historique (ventes, achats, mouvements…) sont archivés au lieu d\'être supprimés : ils disparaissent des listes, l\'historique et les calculs restent intacts, et vous pourrez les restaurer.';

  @override
  String get archSeraSupprime => 'Sera supprimé';

  @override
  String get archSeraArchive => 'Sera archivé (a un historique)';

  @override
  String archToast(int supprimes, int archives) {
    return '$supprimes supprimé(s), $archives archivé(s)';
  }

  @override
  String archToastRestaures(int nombre) {
    return '$nombre restauré(s)';
  }

  @override
  String get archErreur => 'Opération impossible';

  @override
  String get archColArchiveLe => 'Archivé le';

  @override
  String get archColArchivePar => 'Archivé par';

  @override
  String get archBloqueSysteme => 'Élément système';

  @override
  String get archBloqueInconnu => 'Introuvable';

  @override
  String get archBloqueStock => 'Stock non nul : ramenez-le à zéro (inventaire) d\'abord';

  @override
  String get archBloqueDansPack => 'Composant d\'un pack : retirez-le du pack d\'abord';

  @override
  String get archBloqueSolde => 'Solde non nul : réglez le crédit ou l\'avance d\'abord';

  @override
  String get archBloqueMagasinPrincipal => 'Magasin principal d\'un utilisateur';

  @override
  String get archBloqueSession => 'Session de caisse ouverte';

  @override
  String get archBloqueSoldeCaisse => 'Solde de caisse non nul : transférez-le d\'abord';

  @override
  String get archBloqueCompteCourant => 'Compte connecté';

  @override
  String get archBloqueRoleUtilise => 'Rôle attribué à des utilisateurs';

  @override
  String get archBloqueLimite => 'Limite de la licence atteinte';

  @override
  String get archBloqueEtat => 'Déjà traité';

  @override
  String get hiActArchivage => 'Archivage';

  @override
  String get caisseErreurNomPris => 'Une autre caisse porte déjà ce nom.';

  @override
  String get archBloqueNomPris => 'Nom déjà pris par une fiche active : renommez l\'une des deux d\'abord';

  @override
  String get importErreurNomPris => 'Nom déjà utilisé';

  @override
  String get iaFicheTitre => 'Produit reconnu';

  @override
  String get iaFicheQuestion => 'Est-ce bien ce produit ? Votre réponse est envoyée au catalogue pour le confirmer.';

  @override
  String get iaFicheOui => 'C\'est ça';

  @override
  String get iaFicheNon => 'Ce n\'est pas ça';

  @override
  String get iaFicheMarque => 'Marque';

  @override
  String get iaFicheQuantite => 'Quantité';

  @override
  String get iaFicheCategorie => 'Catégorie';

  @override
  String get iaFichePrix => 'Prix de vente';

  @override
  String iaFicheAConfirmer(int score, int seuil) {
    return 'Ajouté par une boutique, pas encore confirmé par les autres ($score sur $seuil).';
  }

  @override
  String get posVenteAvecTva => 'Vente avec TVA';

  @override
  String get posLigneReprise => 'Ligne de la vente modifiée : elle ne peut être ni retirée ni modifiée';

  @override
  String get posLigneRepriseCourt => 'déjà vendu';

  @override
  String posModificationVente(String code, String paye) {
    return 'Modification de la vente $code (déjà payé $paye) : changez le client ou ajoutez des produits. À l\'encaissement, elle est remplacée par un nouveau ticket.';
  }

  @override
  String get posModificationAbandonner => 'Abandonner';

  @override
  String posModificationAbandonnerTitre(String code) {
    return 'Abandonner la modification de $code ?';
  }

  @override
  String get posModificationAbandonnerMsg => 'La vente reste telle qu\'elle a été enregistrée.';

  @override
  String posVenteModifiee(String code) {
    return 'Modification $code';
  }

  @override
  String get posInfoRemplace => 'Remplace';

  @override
  String get posInfoTotalTicket => 'Total du ticket';

  @override
  String get posInfoDejaPaye => 'Déjà payé';

  @override
  String get posVdjEditer => 'Éditer';

  @override
  String get ventesAjouterProduits => 'Ajouter des produits';
}
