import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en'), Locale('fr')];

  /// No description provided for @shellNavGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get shellNavGeneral;

  /// No description provided for @shellNavStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get shellNavStock;

  /// No description provided for @shellNavTiers.
  ///
  /// In fr, this message translates to:
  /// **'Tiers'**
  String get shellNavTiers;

  /// No description provided for @shellNavGestion.
  ///
  /// In fr, this message translates to:
  /// **'Gestion'**
  String get shellNavGestion;

  /// No description provided for @shellMenuModules.
  ///
  /// In fr, this message translates to:
  /// **'Modules'**
  String get shellMenuModules;

  /// No description provided for @shellFenetreReduire.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get shellFenetreReduire;

  /// No description provided for @shellFenetreAgrandir.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir'**
  String get shellFenetreAgrandir;

  /// No description provided for @shellFenetreRestaurer.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get shellFenetreRestaurer;

  /// No description provided for @shellFenetreFermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get shellFenetreFermer;

  /// No description provided for @moduleTableauBord.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get moduleTableauBord;

  /// No description provided for @moduleCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get moduleCaisse;

  /// No description provided for @moduleVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get moduleVentes;

  /// No description provided for @moduleRetours.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get moduleRetours;

  /// No description provided for @moduleHistorique.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get moduleHistorique;

  /// No description provided for @moduleProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get moduleProduits;

  /// No description provided for @moduleStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get moduleStock;

  /// No description provided for @moduleEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées / Achats'**
  String get moduleEntrees;

  /// No description provided for @moduleTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Transferts'**
  String get moduleTransferts;

  /// No description provided for @moduleBesoins.
  ///
  /// In fr, this message translates to:
  /// **'Besoins'**
  String get moduleBesoins;

  /// No description provided for @moduleSorties.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get moduleSorties;

  /// No description provided for @moduleClients.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get moduleClients;

  /// No description provided for @moduleFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get moduleFournisseurs;

  /// No description provided for @moduleVersements.
  ///
  /// In fr, this message translates to:
  /// **'Versements'**
  String get moduleVersements;

  /// No description provided for @moduleGestionCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Gestion caisse'**
  String get moduleGestionCaisse;

  /// No description provided for @moduleClotures.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures'**
  String get moduleClotures;

  /// No description provided for @moduleSituation.
  ///
  /// In fr, this message translates to:
  /// **'Situation'**
  String get moduleSituation;

  /// No description provided for @moduleZakat.
  ///
  /// In fr, this message translates to:
  /// **'Zakat'**
  String get moduleZakat;

  /// No description provided for @moduleParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get moduleParametres;

  /// No description provided for @communAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get communAnnuler;

  /// No description provided for @communConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get communConfirmer;

  /// No description provided for @communFermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get communFermer;

  /// No description provided for @communEnregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get communEnregistrer;

  /// No description provided for @communSupprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get communSupprimer;

  /// No description provided for @communRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get communRechercher;

  /// No description provided for @communAucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get communAucunResultat;

  /// No description provided for @communTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get communTotal;

  /// No description provided for @communToutSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get communToutSelectionner;

  /// No description provided for @communPagination.
  ///
  /// In fr, this message translates to:
  /// **'{debut}–{fin} sur {total}'**
  String communPagination(int debut, int fin, int total);

  /// No description provided for @communSelectionnes.
  ///
  /// In fr, this message translates to:
  /// **'{n} sélectionné(s)'**
  String communSelectionnes(int n);

  /// No description provided for @galerieTitre.
  ///
  /// In fr, this message translates to:
  /// **'Galerie du design system'**
  String get galerieTitre;

  /// No description provided for @galerieTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get galerieTheme;

  /// No description provided for @galerieLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get galerieLangue;

  /// No description provided for @galerieClair.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get galerieClair;

  /// No description provided for @galerieSombre.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get galerieSombre;

  /// No description provided for @activationTitre.
  ///
  /// In fr, this message translates to:
  /// **'Activer CaisseDZ'**
  String get activationTitre;

  /// No description provided for @activationIntro.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez l\'identifiant de ce poste à votre revendeur ; il vous remettra une clé liée à cet ordinateur.'**
  String get activationIntro;

  /// No description provided for @activationIdentifiantMachine.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant du poste'**
  String get activationIdentifiantMachine;

  /// No description provided for @activationCopierIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get activationCopierIdentifiant;

  /// No description provided for @activationIdentifiantCopie.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get activationIdentifiantCopie;

  /// No description provided for @activationCle.
  ///
  /// In fr, this message translates to:
  /// **'Clé de licence'**
  String get activationCle;

  /// No description provided for @activationCleIndice.
  ///
  /// In fr, this message translates to:
  /// **'Collez la clé complète dans la première case.'**
  String get activationCleIndice;

  /// No description provided for @activationBouton.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get activationBouton;

  /// No description provided for @activationErreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Clé invalide pour ce poste — vérifiez l\'identifiant envoyé.'**
  String get activationErreurInconnue;

  /// No description provided for @licenceBasic.
  ///
  /// In fr, this message translates to:
  /// **'Basic'**
  String get licenceBasic;

  /// No description provided for @licenceAvance.
  ///
  /// In fr, this message translates to:
  /// **'Avancé'**
  String get licenceAvance;

  /// No description provided for @licenceDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo'**
  String get licenceDemo;

  /// No description provided for @licenceNiveau.
  ///
  /// In fr, this message translates to:
  /// **'Licence {niveau}'**
  String licenceNiveau(String niveau);

  /// No description provided for @licenceRequiseDetail.
  ///
  /// In fr, this message translates to:
  /// **'Votre licence actuelle est Basic. Activez une licence Avancé pour accéder à ce module.'**
  String get licenceRequiseDetail;

  /// No description provided for @connexionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get connexionTitre;

  /// No description provided for @connexionIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get connexionIdentifiant;

  /// No description provided for @connexionMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get connexionMotDePasse;

  /// No description provided for @connexionBouton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get connexionBouton;

  /// No description provided for @connexionErreurIdentifiants.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect.'**
  String get connexionErreurIdentifiants;

  /// No description provided for @connexionErreurInactif.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est désactivé.'**
  String get connexionErreurInactif;

  /// No description provided for @connexionErreurNonConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte n\'a pas encore de mot de passe : terminez la configuration initiale.'**
  String get connexionErreurNonConfigure;

  /// No description provided for @connexionErreurDemo.
  ///
  /// In fr, this message translates to:
  /// **'Le compte demo/demo n\'est disponible qu\'en mode démo.'**
  String get connexionErreurDemo;

  /// No description provided for @connexionDemoIndice.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo : nom d\'utilisateur demo, mot de passe demo.'**
  String get connexionDemoIndice;

  /// No description provided for @connexionSaisirCle.
  ///
  /// In fr, this message translates to:
  /// **'Saisir une clé d\'activation'**
  String get connexionSaisirCle;

  /// No description provided for @connexionDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get connexionDeconnecter;

  /// No description provided for @configTitre.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans CaisseDZ'**
  String get configTitre;

  /// No description provided for @configEtapeBoutique.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get configEtapeBoutique;

  /// No description provided for @configEtapeVente.
  ///
  /// In fr, this message translates to:
  /// **'Marge et stock'**
  String get configEtapeVente;

  /// No description provided for @configBoutiqueNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la boutique'**
  String get configBoutiqueNom;

  /// No description provided for @configBoutiqueRc.
  ///
  /// In fr, this message translates to:
  /// **'Registre de commerce (RC)'**
  String get configBoutiqueRc;

  /// No description provided for @configBoutiqueNif.
  ///
  /// In fr, this message translates to:
  /// **'NIF'**
  String get configBoutiqueNif;

  /// No description provided for @configBoutiqueAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get configBoutiqueAdresse;

  /// No description provided for @configBoutiqueTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get configBoutiqueTelephone;

  /// No description provided for @configBoutiqueEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get configBoutiqueEmail;

  /// No description provided for @configMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge par défaut'**
  String get configMarge;

  /// No description provided for @configMargeAide.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée au calcul du prix de vente à partir du prix d\'achat des nouveaux produits.'**
  String get configMargeAide;

  /// No description provided for @configSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de rupture'**
  String get configSeuil;

  /// No description provided for @configFidelite.
  ///
  /// In fr, this message translates to:
  /// **'Fidélité'**
  String get configFidelite;

  /// No description provided for @configPointsParDinar.
  ///
  /// In fr, this message translates to:
  /// **'Points gagnés par dinar'**
  String get configPointsParDinar;

  /// No description provided for @configDevise.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get configDevise;

  /// No description provided for @configLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get configLangue;

  /// No description provided for @configPrecedent.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get configPrecedent;

  /// No description provided for @configSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get configSuivant;

  /// No description provided for @configTerminer.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get configTerminer;

  /// No description provided for @configErreurObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get configErreurObligatoire;

  /// No description provided for @configErreurIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'3 à 32 caractères : lettres, chiffres, point, tiret, tiret bas.'**
  String get configErreurIdentifiant;

  /// No description provided for @configErreurMotDePasseCourt.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 4 caractères.'**
  String get configErreurMotDePasseCourt;

  /// No description provided for @configErreurConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get configErreurConfirmation;

  /// No description provided for @configErreurIdentifiantPris.
  ///
  /// In fr, this message translates to:
  /// **'Cet identifiant est déjà utilisé.'**
  String get configErreurIdentifiantPris;

  /// No description provided for @configErreurMarge.
  ///
  /// In fr, this message translates to:
  /// **'Valeur entre 0 et 1000.'**
  String get configErreurMarge;

  /// No description provided for @configErreurNombre.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide.'**
  String get configErreurNombre;

  /// No description provided for @compteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get compteTitre;

  /// No description provided for @compteMotDePasseActuel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get compteMotDePasseActuel;

  /// No description provided for @compteNouveauMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get compteNouveauMotDePasse;

  /// No description provided for @compteChangerIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'identifiant'**
  String get compteChangerIdentifiant;

  /// No description provided for @compteChangerMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get compteChangerMotDePasse;

  /// No description provided for @compteIdentifiantChange.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant modifié : connectez-vous désormais avec « {identifiant} ».'**
  String compteIdentifiantChange(String identifiant);

  /// No description provided for @compteMotDePasseChange.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get compteMotDePasseChange;

  /// No description provided for @compteErreurMotDePasseActuel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect.'**
  String get compteErreurMotDePasseActuel;

  /// No description provided for @comptePreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get comptePreferences;

  /// No description provided for @compteDemoLectureSeule.
  ///
  /// In fr, this message translates to:
  /// **'Le compte de démonstration ne peut pas être modifié.'**
  String get compteDemoLectureSeule;

  /// No description provided for @permVoirPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Voir le prix d\'achat'**
  String get permVoirPrixAchat;

  /// No description provided for @shellBandeauDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo — les données ne sont pas destinées à la production'**
  String get shellBandeauDemo;

  /// No description provided for @shellVerrouille.
  ///
  /// In fr, this message translates to:
  /// **'Réservé à la licence Avancé'**
  String get shellVerrouille;

  /// No description provided for @shellAccesRestreint.
  ///
  /// In fr, this message translates to:
  /// **'Accès non autorisé'**
  String get shellAccesRestreint;

  /// No description provided for @produitsOngletProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get produitsOngletProduits;

  /// No description provided for @produitsOngletCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get produitsOngletCategories;

  /// No description provided for @produitsOngletPacks.
  ///
  /// In fr, this message translates to:
  /// **'Packs'**
  String get produitsOngletPacks;

  /// No description provided for @produitsOngletRemises.
  ///
  /// In fr, this message translates to:
  /// **'Remises'**
  String get produitsOngletRemises;

  /// No description provided for @produitsNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get produitsNouveau;

  /// No description provided for @produitsColCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get produitsColCode;

  /// No description provided for @produitsColDesignation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get produitsColDesignation;

  /// No description provided for @produitsColCodeBarres.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get produitsColCodeBarres;

  /// No description provided for @produitsColCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get produitsColCategorie;

  /// No description provided for @produitsColPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get produitsColPrixAchat;

  /// No description provided for @produitsColPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente HT'**
  String get produitsColPrixVente;

  /// No description provided for @produitsColStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get produitsColStock;

  /// No description provided for @produitsAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit. Créez-en un ou importez un fichier Excel.'**
  String get produitsAucun;

  /// No description provided for @produitModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get produitModifier;

  /// No description provided for @produitChampSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégorie'**
  String get produitChampSousCategorie;

  /// No description provided for @produitChampPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get produitChampPrixAchat;

  /// No description provided for @produitChampPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente HT'**
  String get produitChampPrixVente;

  /// No description provided for @produitChampUnite.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get produitChampUnite;

  /// No description provided for @produitErreurDesignation.
  ///
  /// In fr, this message translates to:
  /// **'La désignation est obligatoire.'**
  String get produitErreurDesignation;

  /// No description provided for @produitErreurCodeBarres.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres invalide.'**
  String get produitErreurCodeBarres;

  /// No description provided for @produitErreurCodeBarresPris.
  ///
  /// In fr, this message translates to:
  /// **'Ce code-barres est déjà utilisé.'**
  String get produitErreurCodeBarresPris;

  /// No description provided for @produitErreurPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix invalide.'**
  String get produitErreurPrix;

  /// No description provided for @produitErreurQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get produitErreurQuantite;

  /// No description provided for @iaIntro.
  ///
  /// In fr, this message translates to:
  /// **'Scannez un code-barres : la fiche est retrouvée automatiquement.'**
  String get iaIntro;

  /// No description provided for @iaRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get iaRechercher;

  /// No description provided for @iaAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune fiche trouvée.'**
  String get iaAucun;

  /// No description provided for @iaTrouve.
  ///
  /// In fr, this message translates to:
  /// **'Fiche trouvée via {source}'**
  String iaTrouve(String source);

  /// No description provided for @iaSaisieDetaillee.
  ///
  /// In fr, this message translates to:
  /// **'Saisie détaillée'**
  String get iaSaisieDetaillee;

  /// No description provided for @importTitre.
  ///
  /// In fr, this message translates to:
  /// **'Importer des produits depuis Excel'**
  String get importTitre;

  /// No description provided for @importIntro.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes attendues en ligne 1 : designation (obligatoire), code_barres, categorie, prix_achat, prix_vente.'**
  String get importIntro;

  /// No description provided for @importChoisirFichier.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier .xlsx'**
  String get importChoisirFichier;

  /// No description provided for @importResultat.
  ///
  /// In fr, this message translates to:
  /// **'{importees} produit(s) importé(s), {ignorees} ignoré(s).'**
  String importResultat(int importees, int ignorees);

  /// No description provided for @importErreurFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier illisible : {detail}'**
  String importErreurFichier(String detail);

  /// No description provided for @importErreurDesignationVide.
  ///
  /// In fr, this message translates to:
  /// **'Désignation vide'**
  String get importErreurDesignationVide;

  /// No description provided for @importErreurCodeBarresPris.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres déjà utilisé'**
  String get importErreurCodeBarresPris;

  /// No description provided for @importErreurPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix invalide'**
  String get importErreurPrix;

  /// No description provided for @synchroResultat.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation : {envoyes} envoyé(s), {recus} mis à jour.'**
  String synchroResultat(int envoyes, int recus);

  /// No description provided for @synchroErreur.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la synchronisation : {detail}'**
  String synchroErreur(String detail);

  /// No description provided for @categoriesNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get categoriesNouvelle;

  /// No description provided for @categoriesNouvelleSous.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sous-catégorie'**
  String get categoriesNouvelleSous;

  /// No description provided for @categorieNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get categorieNom;

  /// No description provided for @categorieErreurSysteme.
  ///
  /// In fr, this message translates to:
  /// **'La catégorie système ne peut pas être modifiée.'**
  String get categorieErreurSysteme;

  /// No description provided for @categorieErreurUtilisee.
  ///
  /// In fr, this message translates to:
  /// **'Des produits sont rattachés à cette catégorie.'**
  String get categorieErreurUtilisee;

  /// No description provided for @packNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau pack'**
  String get packNouveau;

  /// No description provided for @packErreurLignes.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un produit au pack.'**
  String get packErreurLignes;

  /// No description provided for @remiseNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle remise'**
  String get remiseNouvelle;

  /// No description provided for @remiseType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get remiseType;

  /// No description provided for @remiseValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get remiseValeur;

  /// No description provided for @communNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get communNouveau;

  /// No description provided for @communModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get communModifier;

  /// No description provided for @communActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get communActif;

  /// No description provided for @communOui.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get communOui;

  /// No description provided for @communNon.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get communNon;

  /// No description provided for @communValider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get communValider;

  /// No description provided for @communApercu.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get communApercu;

  /// No description provided for @communAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get communAucune;

  /// No description provided for @stockTitre.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get stockTitre;

  /// No description provided for @stockColMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get stockColMagasin;

  /// No description provided for @stockColQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get stockColQuantite;

  /// No description provided for @stockColSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil'**
  String get stockColSeuil;

  /// No description provided for @stockColType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get stockColType;

  /// No description provided for @stockColMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get stockColMotif;

  /// No description provided for @stockColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get stockColUtilisateur;

  /// No description provided for @stockColValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur (PA)'**
  String get stockColValeur;

  /// No description provided for @stockAucunMouvement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get stockAucunMouvement;

  /// No description provided for @stockErreurQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get stockErreurQuantite;

  /// No description provided for @stockErreurInsuffisant.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant : la garde de stock refuse cette sortie.'**
  String get stockErreurInsuffisant;

  /// No description provided for @stockErreurMemeMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Le magasin de destination doit être différent.'**
  String get stockErreurMemeMagasin;

  /// No description provided for @stockErreurLignes.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins une ligne.'**
  String get stockErreurLignes;

  /// No description provided for @stockErreurMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif invalide.'**
  String get stockErreurMotif;

  /// No description provided for @stockErreurMagasinInactif.
  ///
  /// In fr, this message translates to:
  /// **'Magasin inactif ou inconnu.'**
  String get stockErreurMagasinInactif;

  /// No description provided for @stockErreurMagasinSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Le magasin principal ne peut pas être désactivé.'**
  String get stockErreurMagasinSysteme;

  /// No description provided for @stockErreurProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit inconnu.'**
  String get stockErreurProduit;

  /// No description provided for @stockErreurStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut invalide.'**
  String get stockErreurStatut;

  /// No description provided for @typeMouvementEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get typeMouvementEntree;

  /// No description provided for @typeMouvementSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get typeMouvementSortie;

  /// No description provided for @typeMouvementVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get typeMouvementVente;

  /// No description provided for @typeMouvementRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get typeMouvementRetour;

  /// No description provided for @typeMouvementTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get typeMouvementTransfert;

  /// No description provided for @typeMouvementInventaire.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get typeMouvementInventaire;

  /// No description provided for @typeMouvementInitial.
  ///
  /// In fr, this message translates to:
  /// **'Stock initial'**
  String get typeMouvementInitial;

  /// No description provided for @magasinPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Principal'**
  String get magasinPrincipal;

  /// No description provided for @statutBesoinEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statutBesoinEnAttente;

  /// No description provided for @statutBesoinCommande.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get statutBesoinCommande;

  /// No description provided for @statutBesoinDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get statutBesoinDisponible;

  /// No description provided for @motifCasse.
  ///
  /// In fr, this message translates to:
  /// **'Casse'**
  String get motifCasse;

  /// No description provided for @motifPerime.
  ///
  /// In fr, this message translates to:
  /// **'Périmé'**
  String get motifPerime;

  /// No description provided for @motifPerteVol.
  ///
  /// In fr, this message translates to:
  /// **'Perte/vol'**
  String get motifPerteVol;

  /// No description provided for @motifConsommationInterne.
  ///
  /// In fr, this message translates to:
  /// **'Consommation interne'**
  String get motifConsommationInterne;

  /// No description provided for @motifDon.
  ///
  /// In fr, this message translates to:
  /// **'Don'**
  String get motifDon;

  /// No description provided for @motifEchantillon.
  ///
  /// In fr, this message translates to:
  /// **'Échantillon'**
  String get motifEchantillon;

  /// No description provided for @communDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get communDate;

  /// No description provided for @communQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get communQuantite;

  /// No description provided for @moduleMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Magasins'**
  String get moduleMagasins;

  /// No description provided for @posTitre.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get posTitre;

  /// No description provided for @posMaxPaniers.
  ///
  /// In fr, this message translates to:
  /// **'5 ventes en parallèle au maximum.'**
  String get posMaxPaniers;

  /// No description provided for @posReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get posReste;

  /// No description provided for @posPointsGagnes.
  ///
  /// In fr, this message translates to:
  /// **'Points gagnés'**
  String get posPointsGagnes;

  /// No description provided for @posClientPassage.
  ///
  /// In fr, this message translates to:
  /// **'Client de passage'**
  String get posClientPassage;

  /// No description provided for @posChoisirClient.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client'**
  String get posChoisirClient;

  /// No description provided for @posCalculatrice.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice (F9)'**
  String get posCalculatrice;

  /// No description provided for @posAide.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis clavier (F1)'**
  String get posAide;

  /// No description provided for @posSessionAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session de caisse ouverte : ouvrez une session pour encaisser.'**
  String get posSessionAucune;

  /// No description provided for @posSessionCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get posSessionCaisse;

  /// No description provided for @posErreurSessionDejaOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Une session est déjà ouverte (utilisateur ou caisse).'**
  String get posErreurSessionDejaOuverte;

  /// No description provided for @posErreurSessionAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session ouverte.'**
  String get posErreurSessionAucune;

  /// No description provided for @posErreurCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse inconnue ou inactive.'**
  String get posErreurCaisse;

  /// No description provided for @posErreurMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide.'**
  String get posErreurMontant;

  /// No description provided for @posErreurStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant (réservé par les paniers ouverts) : {detail}'**
  String posErreurStock(String detail);

  /// No description provided for @posErreurProduitInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Code inconnu : {code}'**
  String posErreurProduitInconnu(String code);

  /// No description provided for @posErreurPanierVide.
  ///
  /// In fr, this message translates to:
  /// **'Le panier est vide.'**
  String get posErreurPanierVide;

  /// No description provided for @posErreurPaiementInsuffisant.
  ///
  /// In fr, this message translates to:
  /// **'Paiement insuffisant. Reste : {reste}'**
  String posErreurPaiementInsuffisant(String reste);

  /// No description provided for @posErreurModePaiement.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement invalide.'**
  String get posErreurModePaiement;

  /// No description provided for @posErreurPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points insuffisants.'**
  String get posErreurPoints;

  /// No description provided for @posErreurCredit.
  ///
  /// In fr, this message translates to:
  /// **'Vente à crédit non autorisée pour ce client.'**
  String get posErreurCredit;

  /// No description provided for @posErreurQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get posErreurQuantite;

  /// No description provided for @posErreurPeriodeCloturee.
  ///
  /// In fr, this message translates to:
  /// **'Opération refusée : période clôturée.'**
  String get posErreurPeriodeCloturee;

  /// No description provided for @posVenteEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Vente {code} encaissée. Monnaie à rendre : {monnaie}'**
  String posVenteEnregistree(String code, String monnaie);

  /// No description provided for @posImprimerTicket.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer le ticket'**
  String get posImprimerTicket;

  /// No description provided for @posImprimerFacture.
  ///
  /// In fr, this message translates to:
  /// **'Facture A4'**
  String get posImprimerFacture;

  /// No description provided for @posTicket58.
  ///
  /// In fr, this message translates to:
  /// **'Ticket 58 mm'**
  String get posTicket58;

  /// No description provided for @posTicket80.
  ///
  /// In fr, this message translates to:
  /// **'Ticket 80 mm'**
  String get posTicket80;

  /// No description provided for @posImpressionOk.
  ///
  /// In fr, this message translates to:
  /// **'Ticket envoyé à l\'imprimante.'**
  String get posImpressionOk;

  /// No description provided for @posImpressionErreur.
  ///
  /// In fr, this message translates to:
  /// **'Impression impossible : {detail}'**
  String posImpressionErreur(String detail);

  /// No description provided for @posRaccourcisTitre.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis clavier'**
  String get posRaccourcisTitre;

  /// No description provided for @posRaccourciF1.
  ///
  /// In fr, this message translates to:
  /// **'Aide des raccourcis'**
  String get posRaccourciF1;

  /// No description provided for @posRaccourciF2.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher / scanner'**
  String get posRaccourciF2;

  /// No description provided for @posRaccourciF3.
  ///
  /// In fr, this message translates to:
  /// **'Recherche avancée'**
  String get posRaccourciF3;

  /// No description provided for @posRaccourciF4.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser le ticket'**
  String get posRaccourciF4;

  /// No description provided for @posRaccourciF6.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le ticket (crédit)'**
  String get posRaccourciF6;

  /// No description provided for @posRaccourciF7.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le client'**
  String get posRaccourciF7;

  /// No description provided for @posRaccourciF8.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une remise'**
  String get posRaccourciF8;

  /// No description provided for @posRaccourciF9.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice'**
  String get posRaccourciF9;

  /// No description provided for @posRaccourciF10.
  ///
  /// In fr, this message translates to:
  /// **'Vider le panier'**
  String get posRaccourciF10;

  /// No description provided for @posRaccourciF11.
  ///
  /// In fr, this message translates to:
  /// **'Masquer / afficher les produits'**
  String get posRaccourciF11;

  /// No description provided for @posRaccourciF12.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du jour'**
  String get posRaccourciF12;

  /// No description provided for @posRaccourciCtrlN.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau panier'**
  String get posRaccourciCtrlN;

  /// No description provided for @posRaccourciCtrlTab.
  ///
  /// In fr, this message translates to:
  /// **'Panier suivant'**
  String get posRaccourciCtrlTab;

  /// No description provided for @posRaccourciSuppr.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la ligne sélectionnée'**
  String get posRaccourciSuppr;

  /// No description provided for @posRaccourciPlusMoins.
  ///
  /// In fr, this message translates to:
  /// **'Quantité +1 / −1 sur la ligne sélectionnée'**
  String get posRaccourciPlusMoins;

  /// No description provided for @posVendreNombre.
  ///
  /// In fr, this message translates to:
  /// **'Vendre à la pièce'**
  String get posVendreNombre;

  /// No description provided for @posPack.
  ///
  /// In fr, this message translates to:
  /// **'Pack'**
  String get posPack;

  /// No description provided for @posCategoriesToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get posCategoriesToutes;

  /// No description provided for @posAucunProduit.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit actif.'**
  String get posAucunProduit;

  /// No description provided for @calcTitre.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice'**
  String get calcTitre;

  /// No description provided for @calcUtiliser.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser comme montant'**
  String get calcUtiliser;

  /// No description provided for @modePaiementEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get modePaiementEspeces;

  /// No description provided for @modePaiementCarte.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get modePaiementCarte;

  /// No description provided for @modePaiementCheque.
  ///
  /// In fr, this message translates to:
  /// **'Chèque'**
  String get modePaiementCheque;

  /// No description provided for @modePaiementVirement.
  ///
  /// In fr, this message translates to:
  /// **'Virement'**
  String get modePaiementVirement;

  /// No description provided for @modePaiementPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points'**
  String get modePaiementPoints;

  /// No description provided for @ventesAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente.'**
  String get ventesAucune;

  /// No description provided for @ventesCreerRetour.
  ///
  /// In fr, this message translates to:
  /// **'Créer un retour'**
  String get ventesCreerRetour;

  /// No description provided for @ventesVerifierChaine.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le scellement'**
  String get ventesVerifierChaine;

  /// No description provided for @ventesChaineOk.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne de tickets intacte.'**
  String get ventesChaineOk;

  /// No description provided for @ventesChaineKo.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne altérée à partir du ticket {code}.'**
  String ventesChaineKo(String code);

  /// No description provided for @retourErreurQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get retourErreurQuantite;

  /// No description provided for @retourErreurDepasse.
  ///
  /// In fr, this message translates to:
  /// **'Quantité supérieure à la quantité vendue (déjà retournée incluse).'**
  String get retourErreurDepasse;

  /// No description provided for @retourErreurPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période clôturée : retour impossible.'**
  String get retourErreurPeriode;

  /// No description provided for @clientNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get clientNouveau;

  /// No description provided for @clientNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get clientNom;

  /// No description provided for @clientTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get clientTelephone;

  /// No description provided for @clientAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get clientAdresse;

  /// No description provided for @clientEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get clientEmail;

  /// No description provided for @clientPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points'**
  String get clientPoints;

  /// No description provided for @fournisseurNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fournisseur'**
  String get fournisseurNouveau;

  /// No description provided for @versementNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau versement'**
  String get versementNouveau;

  /// No description provided for @versementMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get versementMontant;

  /// No description provided for @versementMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get versementMode;

  /// No description provided for @versementVerrouille.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillé (lié au retour {retour})'**
  String versementVerrouille(String retour);

  /// No description provided for @versementImputations.
  ///
  /// In fr, this message translates to:
  /// **'Imputations (plus ancien d\'abord)'**
  String get versementImputations;

  /// No description provided for @versementErreurMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide.'**
  String get versementErreurMontant;

  /// No description provided for @versementErreurMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement invalide.'**
  String get versementErreurMode;

  /// No description provided for @versementErreurSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Impossible pour le tiers système.'**
  String get versementErreurSysteme;

  /// No description provided for @versementErreurVerrouille.
  ///
  /// In fr, this message translates to:
  /// **'Versement verrouillé : lié à un retour, il ne peut être ni modifié ni supprimé.'**
  String get versementErreurVerrouille;

  /// No description provided for @versementErreurInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Versement introuvable.'**
  String get versementErreurInconnu;

  /// No description provided for @versementErreurTiers.
  ///
  /// In fr, this message translates to:
  /// **'Tiers invalide.'**
  String get versementErreurTiers;

  /// No description provided for @tiersErreurNom.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get tiersErreurNom;

  /// No description provided for @tiersErreurSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Le tiers système ne peut pas être modifié.'**
  String get tiersErreurSysteme;

  /// No description provided for @achatNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle entrée'**
  String get achatNouveau;

  /// No description provided for @achatFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get achatFournisseur;

  /// No description provided for @achatAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune entrée.'**
  String get achatAucun;

  /// No description provided for @achatColVerse.
  ///
  /// In fr, this message translates to:
  /// **'Versé'**
  String get achatColVerse;

  /// No description provided for @achatColReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get achatColReste;

  /// No description provided for @achatColSource.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get achatColSource;

  /// No description provided for @achatColStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get achatColStatut;

  /// No description provided for @achatErreurLignes.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins une ligne.'**
  String get achatErreurLignes;

  /// No description provided for @achatErreurQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get achatErreurQuantite;

  /// No description provided for @achatErreurPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix ou montant invalide.'**
  String get achatErreurPrix;

  /// No description provided for @achatErreurProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit inconnu.'**
  String get achatErreurProduit;

  /// No description provided for @achatErreurFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur inconnu.'**
  String get achatErreurFournisseur;

  /// No description provided for @achatErreurInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Entrée introuvable.'**
  String get achatErreurInconnu;

  /// No description provided for @achatErreurAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Entrée déjà annulée.'**
  String get achatErreurAnnule;

  /// No description provided for @achatErreurPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période clôturée : annulation impossible.'**
  String get achatErreurPeriode;

  /// No description provided for @achatErreurStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant pour annuler (déjà vendu).'**
  String get achatErreurStock;

  /// No description provided for @sourceSmartScan.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan'**
  String get sourceSmartScan;

  /// No description provided for @smartScanAucuneLigne.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ligne reconnue.'**
  String get smartScanAucuneLigne;

  /// No description provided for @smartScanQuotaAtteintDetail.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez utilisé toutes vos analyses. Demandez une offre pour continuer.'**
  String get smartScanQuotaAtteintDetail;

  /// No description provided for @smartScanDemandeOffre.
  ///
  /// In fr, this message translates to:
  /// **'Demander une offre'**
  String get smartScanDemandeOffre;

  /// No description provided for @smartScanEmail.
  ///
  /// In fr, this message translates to:
  /// **'Votre e-mail'**
  String get smartScanEmail;

  /// No description provided for @smartScanMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get smartScanMessage;

  /// No description provided for @smartScanOffreEnvoyee.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée, nous vous contacterons rapidement.'**
  String get smartScanOffreEnvoyee;

  /// No description provided for @smartScanNonConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez l\'URL du serveur CaisseDZ dans Paramètres pour utiliser Smart Scan.'**
  String get smartScanNonConfigure;

  /// No description provided for @smartScanErreurReseau.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable : {detail}'**
  String smartScanErreurReseau(String detail);

  /// No description provided for @smartScanErreurServeur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur du serveur : {detail}'**
  String smartScanErreurServeur(String detail);

  /// No description provided for @smartScanErreurFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier invalide.'**
  String get smartScanErreurFichier;

  /// No description provided for @caisseNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle caisse'**
  String get caisseNouvelle;

  /// No description provided for @caisseModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la caisse'**
  String get caisseModifier;

  /// No description provided for @caisseNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get caisseNom;

  /// No description provided for @caisseType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get caisseType;

  /// No description provided for @caisseMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get caisseMagasin;

  /// No description provided for @caisseActive.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get caisseActive;

  /// No description provided for @caisseInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactive'**
  String get caisseInactive;

  /// No description provided for @caisseTypePhysique.
  ///
  /// In fr, this message translates to:
  /// **'Physique'**
  String get caisseTypePhysique;

  /// No description provided for @caisseTypeCompte.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get caisseTypeCompte;

  /// No description provided for @caisseAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune caisse.'**
  String get caisseAucune;

  /// No description provided for @caisseDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get caisseDesactiver;

  /// No description provided for @mouvementColMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get mouvementColMontant;

  /// No description provided for @mouvementAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get mouvementAucun;

  /// No description provided for @mouvementCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get mouvementCaisse;

  /// No description provided for @mvtVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get mvtVente;

  /// No description provided for @mvtAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annulation vente'**
  String get mvtAnnulation;

  /// No description provided for @mvtRemboursement.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement retour'**
  String get mvtRemboursement;

  /// No description provided for @mvtEncaissement.
  ///
  /// In fr, this message translates to:
  /// **'Versement client'**
  String get mvtEncaissement;

  /// No description provided for @mvtDecaissement.
  ///
  /// In fr, this message translates to:
  /// **'Versement fournisseur'**
  String get mvtDecaissement;

  /// No description provided for @mvtApport.
  ///
  /// In fr, this message translates to:
  /// **'Entrée manuelle'**
  String get mvtApport;

  /// No description provided for @mvtDepense.
  ///
  /// In fr, this message translates to:
  /// **'Sortie manuelle'**
  String get mvtDepense;

  /// No description provided for @mvtTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get mvtTransfert;

  /// No description provided for @mvtFondInitial.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get mvtFondInitial;

  /// No description provided for @mvtRetrait.
  ///
  /// In fr, this message translates to:
  /// **'Retrait de clôture'**
  String get mvtRetrait;

  /// No description provided for @mvtEcart.
  ///
  /// In fr, this message translates to:
  /// **'Écart de clôture'**
  String get mvtEcart;

  /// No description provided for @transfertCaisseNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau transfert'**
  String get transfertCaisseNouveau;

  /// No description provided for @transfertCaisseAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun transfert.'**
  String get transfertCaisseAucun;

  /// No description provided for @caisseErreurNom.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get caisseErreurNom;

  /// No description provided for @caisseErreurType.
  ///
  /// In fr, this message translates to:
  /// **'Type de caisse invalide.'**
  String get caisseErreurType;

  /// No description provided for @caisseErreurMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin inconnu.'**
  String get caisseErreurMagasin;

  /// No description provided for @caisseErreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Caisse introuvable.'**
  String get caisseErreurInconnue;

  /// No description provided for @caisseErreurInactive.
  ///
  /// In fr, this message translates to:
  /// **'Caisse inactive.'**
  String get caisseErreurInactive;

  /// No description provided for @caisseErreurSysteme.
  ///
  /// In fr, this message translates to:
  /// **'La caisse principale ne peut pas être désactivée.'**
  String get caisseErreurSysteme;

  /// No description provided for @caisseErreurMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide.'**
  String get caisseErreurMontant;

  /// No description provided for @caisseErreurMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement invalide.'**
  String get caisseErreurMode;

  /// No description provided for @caisseErreurMemeCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez deux caisses différentes.'**
  String get caisseErreurMemeCaisse;

  /// No description provided for @caisseErreurSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde insuffisant dans la caisse source.'**
  String get caisseErreurSolde;

  /// No description provided for @caisseErreurSessionOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Une session est ouverte sur cette caisse.'**
  String get caisseErreurSessionOuverte;

  /// No description provided for @cloturePeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get cloturePeriode;

  /// No description provided for @clotureColTotalVentes.
  ///
  /// In fr, this message translates to:
  /// **'Total ventes'**
  String get clotureColTotalVentes;

  /// No description provided for @clotureColRemises.
  ///
  /// In fr, this message translates to:
  /// **'Remises'**
  String get clotureColRemises;

  /// No description provided for @clotureColRetours.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get clotureColRetours;

  /// No description provided for @clotureColEncaissements.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements'**
  String get clotureColEncaissements;

  /// No description provided for @clotureColDecaissements.
  ///
  /// In fr, this message translates to:
  /// **'Décaissements'**
  String get clotureColDecaissements;

  /// No description provided for @clotureAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clôture.'**
  String get clotureAucune;

  /// No description provided for @clotureDerniereVente.
  ///
  /// In fr, this message translates to:
  /// **'Dernier ticket'**
  String get clotureDerniereVente;

  /// No description provided for @clotureErreurRien.
  ///
  /// In fr, this message translates to:
  /// **'Rien à clôturer depuis la dernière clôture.'**
  String get clotureErreurRien;

  /// No description provided for @exportFiscalGenerer.
  ///
  /// In fr, this message translates to:
  /// **'Générer l\'archive'**
  String get exportFiscalGenerer;

  /// No description provided for @exportFiscalErreurDates.
  ///
  /// In fr, this message translates to:
  /// **'Dates invalides.'**
  String get exportFiscalErreurDates;

  /// No description provided for @exportFiscalVerifier.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier une archive'**
  String get exportFiscalVerifier;

  /// No description provided for @exportFiscalVerifOk.
  ///
  /// In fr, this message translates to:
  /// **'Archive valide : {ventes} ventes, {clotures} clôtures.'**
  String exportFiscalVerifOk(int ventes, int clotures);

  /// No description provided for @exportFiscalVerifKo.
  ///
  /// In fr, this message translates to:
  /// **'Archive invalide : {erreurs}'**
  String exportFiscalVerifKo(String erreurs);

  /// No description provided for @tableauBordTopProduits.
  ///
  /// In fr, this message translates to:
  /// **'Top 5 produits (30 jours)'**
  String get tableauBordTopProduits;

  /// No description provided for @situationExportExcel.
  ///
  /// In fr, this message translates to:
  /// **'Exporter Excel'**
  String get situationExportExcel;

  /// No description provided for @situationApercuPdf.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu PDF'**
  String get situationApercuPdf;

  /// No description provided for @situationExportOk.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {chemin}'**
  String situationExportOk(String chemin);

  /// No description provided for @parametresErreurNom.
  ///
  /// In fr, this message translates to:
  /// **'Le nom de la boutique est obligatoire.'**
  String get parametresErreurNom;

  /// No description provided for @parametresErreurValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur invalide.'**
  String get parametresErreurValeur;

  /// No description provided for @parametresErreurImprimanteType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'imprimante invalide.'**
  String get parametresErreurImprimanteType;

  /// No description provided for @parametresErreurImprimanteAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez la file d\'attente ou l\'adresse de l\'imprimante.'**
  String get parametresErreurImprimanteAdresse;

  /// No description provided for @sauvegardeIntro.
  ///
  /// In fr, this message translates to:
  /// **'La sauvegarde est chiffrée avec le mot de passe choisi : conservez-le, il sera demandé à la restauration.'**
  String get sauvegardeIntro;

  /// No description provided for @sauvegardeRestaurer.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde'**
  String get sauvegardeRestaurer;

  /// No description provided for @sauvegardeMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe de la sauvegarde'**
  String get sauvegardeMotDePasse;

  /// No description provided for @sauvegardeInfo.
  ///
  /// In fr, this message translates to:
  /// **'Boutique « {boutique} », {ventes} ventes, {produits} produits, schéma v{version}.'**
  String sauvegardeInfo(String boutique, int ventes, int produits, int version);

  /// No description provided for @sauvegardeConfirmerRestauration.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette sauvegarde ? Les données actuelles seront remplacées au prochain démarrage.'**
  String get sauvegardeConfirmerRestauration;

  /// No description provided for @sauvegardeRestaurationPreparee.
  ///
  /// In fr, this message translates to:
  /// **'Restauration prête : fermez puis relancez CaisseDZ pour l\'appliquer.'**
  String get sauvegardeRestaurationPreparee;

  /// No description provided for @sauvegardeRestaurationEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'Une restauration est en attente : elle sera appliquée au prochain démarrage.'**
  String get sauvegardeRestaurationEnAttente;

  /// No description provided for @sauvegardeAnnulerRestauration.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la restauration'**
  String get sauvegardeAnnulerRestauration;

  /// No description provided for @sauvegardeErreurMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe invalide ou fichier corrompu.'**
  String get sauvegardeErreurMotDePasse;

  /// No description provided for @sauvegardeErreurMotDePasseVide.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un mot de passe.'**
  String get sauvegardeErreurMotDePasseVide;

  /// No description provided for @sauvegardeErreurFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier introuvable.'**
  String get sauvegardeErreurFichier;

  /// No description provided for @sauvegardeErreurChemin.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement invalide : {detail}'**
  String sauvegardeErreurChemin(String detail);

  /// No description provided for @dsContinuer.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get dsContinuer;

  /// No description provided for @dsCompris.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get dsCompris;

  /// No description provided for @dsLibelle.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get dsLibelle;

  /// No description provided for @dsZoomAvant.
  ///
  /// In fr, this message translates to:
  /// **'Zoom avant'**
  String get dsZoomAvant;

  /// No description provided for @dsZoomArriere.
  ///
  /// In fr, this message translates to:
  /// **'Zoom arrière'**
  String get dsZoomArriere;

  /// No description provided for @dsZoomAjuster.
  ///
  /// In fr, this message translates to:
  /// **'Image entière'**
  String get dsZoomAjuster;

  /// No description provided for @dsCochezLignes.
  ///
  /// In fr, this message translates to:
  /// **'Cochez une ou plusieurs lignes'**
  String get dsCochezLignes;

  /// No description provided for @dsCliquezLigne.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez une ligne · double-clic pour valider'**
  String get dsCliquezLigne;

  /// No description provided for @dsAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get dsAjouter;

  /// No description provided for @dsChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get dsChoisir;

  /// No description provided for @dsAnnules.
  ///
  /// In fr, this message translates to:
  /// **'annulés'**
  String get dsAnnules;

  /// No description provided for @dsSupprimes.
  ///
  /// In fr, this message translates to:
  /// **'supprimés'**
  String get dsSupprimes;

  /// No description provided for @dsActiver.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get dsActiver;

  /// No description provided for @dsActives.
  ///
  /// In fr, this message translates to:
  /// **'activés'**
  String get dsActives;

  /// No description provided for @dsDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get dsDesactiver;

  /// No description provided for @dsDesactives.
  ///
  /// In fr, this message translates to:
  /// **'désactivés'**
  String get dsDesactives;

  /// No description provided for @dsLotPartiel.
  ///
  /// In fr, this message translates to:
  /// **'{ok} sur {total} seront {participe}.'**
  String dsLotPartiel(String ok, int total, String participe);

  /// No description provided for @dsLotBloques.
  ///
  /// In fr, this message translates to:
  /// **'{n} ne peuvent pas être traités : {motif}.'**
  String dsLotBloques(String n, String motif);

  /// No description provided for @dsMotifAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Motif d\'annulation'**
  String get dsMotifAnnulation;

  /// No description provided for @dsMotifIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. erreur de saisie, client absent…'**
  String get dsMotifIndice;

  /// No description provided for @dsObligatoires.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoires'**
  String get dsObligatoires;

  /// No description provided for @dsToujoursAffichees.
  ///
  /// In fr, this message translates to:
  /// **'Toujours affichées'**
  String get dsToujoursAffichees;

  /// No description provided for @dsColonnesParDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes par défaut'**
  String get dsColonnesParDefaut;

  /// No description provided for @dsAutresColonnes.
  ///
  /// In fr, this message translates to:
  /// **'Autres colonnes'**
  String get dsAutresColonnes;

  /// No description provided for @dsColonnesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Afficher / masquer les colonnes'**
  String get dsColonnesTitre;

  /// No description provided for @dsAppliquer.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get dsAppliquer;

  /// No description provided for @dsRechercherColonne.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une colonne…'**
  String get dsRechercherColonne;

  /// No description provided for @dsAfficherTout.
  ///
  /// In fr, this message translates to:
  /// **'Afficher tout'**
  String get dsAfficherTout;

  /// No description provided for @dsMasquerTout.
  ///
  /// In fr, this message translates to:
  /// **'Masquer tout'**
  String get dsMasquerTout;

  /// No description provided for @dsParDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get dsParDefaut;

  /// No description provided for @dsAucuneColonne.
  ///
  /// In fr, this message translates to:
  /// **'Aucune colonne trouvée'**
  String get dsAucuneColonne;

  /// No description provided for @dsGarderSelection.
  ///
  /// In fr, this message translates to:
  /// **'Garder ma sélection'**
  String get dsGarderSelection;

  /// No description provided for @dsGarderSelectionAide.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, les colonnes par défaut sont rétablies à la prochaine ouverture'**
  String get dsGarderSelectionAide;

  /// No description provided for @dsParPage.
  ///
  /// In fr, this message translates to:
  /// **'par page'**
  String get dsParPage;

  /// No description provided for @dsToutDeselectionner.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get dsToutDeselectionner;

  /// No description provided for @dsSelectionneSur.
  ///
  /// In fr, this message translates to:
  /// **'{n} / {total} sélectionné(s)'**
  String dsSelectionneSur(int n, int total);

  /// No description provided for @dsSelectionnezUne.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une seule ligne'**
  String get dsSelectionnezUne;

  /// No description provided for @dsSelectionnezAuMoins.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins une ligne'**
  String get dsSelectionnezAuMoins;

  /// No description provided for @dsAucunElement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élément'**
  String get dsAucunElement;

  /// No description provided for @dsDoubleClicDetail.
  ///
  /// In fr, this message translates to:
  /// **'Double-clic : afficher le détail'**
  String get dsDoubleClicDetail;

  /// No description provided for @dsColonnesMasquees.
  ///
  /// In fr, this message translates to:
  /// **'Afficher / masquer les colonnes · {n}/{total}'**
  String dsColonnesMasquees(int n, int total);

  /// No description provided for @dsFiltres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get dsFiltres;

  /// No description provided for @dsChiffresCles.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres clés'**
  String get dsChiffresCles;

  /// No description provided for @dsFiltrer.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get dsFiltrer;

  /// No description provided for @dsReinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get dsReinitialiser;

  /// No description provided for @dsActifs.
  ///
  /// In fr, this message translates to:
  /// **'{n} actif(s)'**
  String dsActifs(int n);

  /// No description provided for @dsExporter.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get dsExporter;

  /// No description provided for @dsToutExporter.
  ///
  /// In fr, this message translates to:
  /// **'Tout exporter'**
  String get dsToutExporter;

  /// No description provided for @dsSelectionSeulement.
  ///
  /// In fr, this message translates to:
  /// **'Sélection seulement'**
  String get dsSelectionSeulement;

  /// No description provided for @dsRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get dsRetour;

  /// No description provided for @dsEffacer.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get dsEffacer;

  /// No description provided for @dsThemeClair.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get dsThemeClair;

  /// No description provided for @dsThemeSombre.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get dsThemeSombre;

  /// No description provided for @dsEnLigne.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get dsEnLigne;

  /// No description provided for @dsHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get dsHorsLigne;

  /// No description provided for @dsSynchronise.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get dsSynchronise;

  /// No description provided for @dsHorsLigneLocal.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — les données restent locales'**
  String get dsHorsLigneLocal;

  /// No description provided for @dsAlertes.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get dsAlertes;

  /// No description provided for @dsMenuModules.
  ///
  /// In fr, this message translates to:
  /// **'Menu des modules (Ctrl M)'**
  String get dsMenuModules;

  /// No description provided for @dsReplier.
  ///
  /// In fr, this message translates to:
  /// **'Replier'**
  String get dsReplier;

  /// No description provided for @dsDeplier.
  ///
  /// In fr, this message translates to:
  /// **'Déplier'**
  String get dsDeplier;

  /// No description provided for @dsAjouterFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get dsAjouterFavoris;

  /// No description provided for @dsRetirerFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get dsRetirerFavoris;

  /// No description provided for @dsFavorisComplets.
  ///
  /// In fr, this message translates to:
  /// **'Favoris complets'**
  String get dsFavorisComplets;

  /// No description provided for @dsModules.
  ///
  /// In fr, this message translates to:
  /// **'Modules'**
  String get dsModules;

  /// No description provided for @dsRechercherModule.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un module…'**
  String get dsRechercherModule;

  /// No description provided for @dsMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get dsMagasin;

  /// No description provided for @dsPagePrecedente.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get dsPagePrecedente;

  /// No description provided for @dsPageSuivante.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get dsPageSuivante;

  /// No description provided for @dsAucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get dsAucunResultat;

  /// No description provided for @dsGateLicenceTitre.
  ///
  /// In fr, this message translates to:
  /// **'Disponible avec le palier Avancé'**
  String get dsGateLicenceTitre;

  /// No description provided for @dsGateLicenceAction.
  ///
  /// In fr, this message translates to:
  /// **'Passer au palier Avancé'**
  String get dsGateLicenceAction;

  /// No description provided for @dsGateRoleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Accès non autorisé'**
  String get dsGateRoleTitre;

  /// No description provided for @dsGateRoleAction.
  ///
  /// In fr, this message translates to:
  /// **'Demander l\'accès'**
  String get dsGateRoleAction;

  /// No description provided for @dsGateRefuseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé'**
  String get dsGateRefuseTitre;

  /// No description provided for @dsGateRefuseAction.
  ///
  /// In fr, this message translates to:
  /// **'Retour au tableau de bord'**
  String get dsGateRefuseAction;

  /// No description provided for @dsGateActivationTitre.
  ///
  /// In fr, this message translates to:
  /// **'Application non activée'**
  String get dsGateActivationTitre;

  /// No description provided for @dsGateActivationAction.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get dsGateActivationAction;

  /// No description provided for @dsGateRefuseDetail.
  ///
  /// In fr, this message translates to:
  /// **'Votre rôle ne donne pas accès au module {module}. Demandez à l\'administrateur de modifier vos permissions.'**
  String dsGateRefuseDetail(String module);

  /// No description provided for @dsPermTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get dsPermTout;

  /// No description provided for @dsPermRien.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get dsPermRien;

  /// No description provided for @dsPermReserve.
  ///
  /// In fr, this message translates to:
  /// **'Réservé à l\'administrateur'**
  String get dsPermReserve;

  /// No description provided for @dsPosProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get dsPosProduit;

  /// No description provided for @dsPosColis.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get dsPosColis;

  /// No description provided for @dsPosQte.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get dsPosQte;

  /// No description provided for @dsPosPieces.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get dsPosPieces;

  /// No description provided for @dsPosMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get dsPosMontant;

  /// No description provided for @dsPosMoins.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get dsPosMoins;

  /// No description provided for @dsPosPlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get dsPosPlus;

  /// No description provided for @dsPosRetirer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get dsPosRetirer;

  /// No description provided for @dsPosChangerColis.
  ///
  /// In fr, this message translates to:
  /// **'Changer le colis'**
  String get dsPosChangerColis;

  /// No description provided for @dsPosOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get dsPosOuverte;

  /// No description provided for @dsPosFermee.
  ///
  /// In fr, this message translates to:
  /// **'Fermée'**
  String get dsPosFermee;

  /// No description provided for @dsPosAucuneSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session ouverte'**
  String get dsPosAucuneSession;

  /// No description provided for @dsPosOuverteA.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte à {heure}'**
  String dsPosOuverteA(String heure);

  /// No description provided for @dsPosPar.
  ///
  /// In fr, this message translates to:
  /// **'par {nom}'**
  String dsPosPar(String nom);

  /// No description provided for @dsPosSoldeCourant.
  ///
  /// In fr, this message translates to:
  /// **'Solde courant'**
  String get dsPosSoldeCourant;

  /// No description provided for @dsPosMouvement.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement'**
  String get dsPosMouvement;

  /// No description provided for @dsPosCloturer.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer'**
  String get dsPosCloturer;

  /// No description provided for @dsPosOuvrir.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get dsPosOuvrir;

  /// No description provided for @dsPosOuvrirCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la caisse'**
  String get dsPosOuvrirCaisse;

  /// No description provided for @dsPosEffacer.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get dsPosEffacer;

  /// No description provided for @dsPosToutEffacer.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get dsPosToutEffacer;

  /// No description provided for @dsPosTotalAvantRemise.
  ///
  /// In fr, this message translates to:
  /// **'Total avant remise'**
  String get dsPosTotalAvantRemise;

  /// No description provided for @dsPosRemise.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get dsPosRemise;

  /// No description provided for @dsPosTotalAPayer.
  ///
  /// In fr, this message translates to:
  /// **'Total à payer'**
  String get dsPosTotalAPayer;

  /// No description provided for @dsPosPaiementComplet.
  ///
  /// In fr, this message translates to:
  /// **'Paiement complet'**
  String get dsPosPaiementComplet;

  /// No description provided for @dsPosMontantPaye.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get dsPosMontantPaye;

  /// No description provided for @dsPosARendre.
  ///
  /// In fr, this message translates to:
  /// **'À rendre'**
  String get dsPosARendre;

  /// No description provided for @dsPosMontantExact.
  ///
  /// In fr, this message translates to:
  /// **'Montant exact'**
  String get dsPosMontantExact;

  /// No description provided for @dsPosPartielImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Paiement partiel impossible pour le client comptoir'**
  String get dsPosPartielImpossible;

  /// No description provided for @dsPosResteCredit.
  ///
  /// In fr, this message translates to:
  /// **'Reste (crédit client)'**
  String get dsPosResteCredit;

  /// No description provided for @dsPosRupture.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get dsPosRupture;

  /// No description provided for @dsPosEnStock.
  ///
  /// In fr, this message translates to:
  /// **'{n} en stock'**
  String dsPosEnStock(String n);

  /// No description provided for @dsPosEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get dsPosEntree;

  /// No description provided for @dsPosEntreeRapide.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle entrée rapide de ce produit'**
  String get dsPosEntreeRapide;

  /// No description provided for @dsPosSmartScan.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan'**
  String get dsPosSmartScan;

  /// No description provided for @dsPosScansMois.
  ///
  /// In fr, this message translates to:
  /// **'/ {n} scans ce mois'**
  String dsPosScansMois(int n);

  /// No description provided for @dsPosRestants.
  ///
  /// In fr, this message translates to:
  /// **'{n} restants'**
  String dsPosRestants(int n);

  /// No description provided for @dsPosRenouvellement.
  ///
  /// In fr, this message translates to:
  /// **'Renouvellement {date}'**
  String dsPosRenouvellement(String date);

  /// No description provided for @dsPosQuotaHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — quota indisponible, la caisse continue de fonctionner.'**
  String get dsPosQuotaHorsLigne;

  /// No description provided for @dsPosActualiser.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get dsPosActualiser;

  /// No description provided for @dsPosNouvelleVente.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente'**
  String get dsPosNouvelleVente;

  /// No description provided for @dsPosVentes.
  ///
  /// In fr, this message translates to:
  /// **'ventes'**
  String get dsPosVentes;

  /// No description provided for @dsPosFermerVente.
  ///
  /// In fr, this message translates to:
  /// **'Fermer cette vente'**
  String get dsPosFermerVente;

  /// No description provided for @dsPosMaxVentes.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {n} ventes en parallèle'**
  String dsPosMaxVentes(int n);

  /// No description provided for @dsPosArticles.
  ///
  /// In fr, this message translates to:
  /// **'{n} article(s)'**
  String dsPosArticles(int n);

  /// No description provided for @dsPosSousTotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get dsPosSousTotal;

  /// No description provided for @dsPosLigneArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get dsPosLigneArticles;

  /// No description provided for @dsPosLigneQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get dsPosLigneQuantite;

  /// No description provided for @dsPosLigneAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des produits'**
  String get dsPosLigneAjouter;

  /// No description provided for @dsPosLigneVide.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit — ajoutez-en avec le bouton ci-dessous.'**
  String get dsPosLigneVide;

  /// No description provided for @dsPosLigneRetirer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la ligne'**
  String get dsPosLigneRetirer;

  /// No description provided for @dsPosCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get dsPosCode;

  /// No description provided for @dsPosPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get dsPosPrix;

  /// No description provided for @dsCalcUtiliser.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser le résultat'**
  String get dsCalcUtiliser;

  /// No description provided for @dsBarcodeAucun.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'a pas de code-barres.'**
  String get dsBarcodeAucun;

  /// No description provided for @dsBarcodeGenerer.
  ///
  /// In fr, this message translates to:
  /// **'Générer'**
  String get dsBarcodeGenerer;

  /// No description provided for @dsBarcodeCopier.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get dsBarcodeCopier;

  /// No description provided for @dsBarcodeImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer l\'étiquette'**
  String get dsBarcodeImprimer;

  /// No description provided for @moduleUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get moduleUtilisateurs;

  /// No description provided for @connexionSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour ouvrir votre caisse.'**
  String get connexionSousTitre;

  /// No description provided for @connexionChoisirCompte.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre compte'**
  String get connexionChoisirCompte;

  /// No description provided for @connexionChoisirSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Les comptes de ce poste : cliquez sur le vôtre.'**
  String get connexionChoisirSousTitre;

  /// No description provided for @connexionAutreCompte.
  ///
  /// In fr, this message translates to:
  /// **'Autre compte'**
  String get connexionAutreCompte;

  /// No description provided for @connexionPasVous.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas vous ? Changer de compte'**
  String get connexionPasVous;

  /// No description provided for @connexionVoirComptes.
  ///
  /// In fr, this message translates to:
  /// **'Voir les comptes de ce poste'**
  String get connexionVoirComptes;

  /// No description provided for @connexionCompteBens.
  ///
  /// In fr, this message translates to:
  /// **'Compte BENS {telephone}'**
  String connexionCompteBens(String telephone);

  /// No description provided for @connexionMotDePasseBens.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut : le mot de passe de votre compte BENS.'**
  String get connexionMotDePasseBens;

  /// No description provided for @connexionIdentifiantOuTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur, ou le téléphone du compte BENS pour l\'administrateur'**
  String get connexionIdentifiantOuTelephone;

  /// No description provided for @connexionAfficher.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get connexionAfficher;

  /// No description provided for @connexionMasquer.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get connexionMasquer;

  /// No description provided for @connexionResterConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Rester connecté'**
  String get connexionResterConnecte;

  /// No description provided for @connexionMotDePasseOublie.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get connexionMotDePasseOublie;

  /// No description provided for @connexionMotDePasseOublieAide.
  ///
  /// In fr, this message translates to:
  /// **'Demandez à l\'administrateur de le réinitialiser.'**
  String get connexionMotDePasseOublieAide;

  /// No description provided for @connexionHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionne hors ligne · données stockées sur ce poste'**
  String get connexionHorsLigne;

  /// No description provided for @connexionDemoNonActivee.
  ///
  /// In fr, this message translates to:
  /// **'Application non activée : connectez-vous avec demo / demo pour l\'essayer, ou saisissez une clé.'**
  String get connexionDemoNonActivee;

  /// No description provided for @connexionErreurNonActivee.
  ///
  /// In fr, this message translates to:
  /// **'Application non activée : seul le compte demo / demo est disponible.'**
  String get connexionErreurNonActivee;

  /// No description provided for @connexionNonActivee.
  ///
  /// In fr, this message translates to:
  /// **'Non activée'**
  String get connexionNonActivee;

  /// No description provided for @connexionVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version} · {licence}'**
  String connexionVersion(String version, String licence);

  /// No description provided for @connexionNouveaute.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau · Smart Scan IA'**
  String get connexionNouveaute;

  /// No description provided for @connexionAccroche.
  ///
  /// In fr, this message translates to:
  /// **'Ventes, stock et caisse — simple, rapide et sécurisé.'**
  String get connexionAccroche;

  /// No description provided for @connexionAccrocheDetail.
  ///
  /// In fr, this message translates to:
  /// **'Scannez vos bons d\'achat, suivez plusieurs magasins et encaissez en français, arabe ou anglais.'**
  String get connexionAccrocheDetail;

  /// No description provided for @connexionAtoutHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get connexionAtoutHorsLigne;

  /// No description provided for @connexionAtoutMultiMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Multi-magasin'**
  String get connexionAtoutMultiMagasin;

  /// No description provided for @activationNonActivee.
  ///
  /// In fr, this message translates to:
  /// **'Non activée'**
  String get activationNonActivee;

  /// No description provided for @activationPalierDetecte.
  ///
  /// In fr, this message translates to:
  /// **'Palier détecté : {palier}'**
  String activationPalierDetecte(String palier);

  /// No description provided for @activationPalierBasic.
  ///
  /// In fr, this message translates to:
  /// **'Basic (1 magasin, 1 caisse)'**
  String get activationPalierBasic;

  /// No description provided for @activationPalierAvance.
  ///
  /// In fr, this message translates to:
  /// **'Avancé (multi-magasins, multi-caisses)'**
  String get activationPalierAvance;

  /// No description provided for @activationUnMagasin.
  ///
  /// In fr, this message translates to:
  /// **'1 magasin'**
  String get activationUnMagasin;

  /// No description provided for @activationUneCaisse.
  ///
  /// In fr, this message translates to:
  /// **'1 caisse'**
  String get activationUneCaisse;

  /// No description provided for @activationMagasinsIllimites.
  ///
  /// In fr, this message translates to:
  /// **'Magasins illimités et transferts'**
  String get activationMagasinsIllimites;

  /// No description provided for @activationPlusieursCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs caisses'**
  String get activationPlusieursCaisses;

  /// No description provided for @activationSmartScanQuota.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan IA selon quota serveur'**
  String get activationSmartScanQuota;

  /// No description provided for @activationRetourConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get activationRetourConnexion;

  /// No description provided for @activationReussieTitre.
  ///
  /// In fr, this message translates to:
  /// **'Application activée'**
  String get activationReussieTitre;

  /// No description provided for @activationReussieDetail.
  ///
  /// In fr, this message translates to:
  /// **'Palier {palier} · lié au poste {poste}.'**
  String activationReussieDetail(String palier, String poste);

  /// No description provided for @activationContinuer.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get activationContinuer;

  /// No description provided for @configEtapeLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue & devise'**
  String get configEtapeLangue;

  /// No description provided for @configEtapePaiements.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get configEtapePaiements;

  /// No description provided for @configDecimales.
  ///
  /// In fr, this message translates to:
  /// **'Décimales des quantités'**
  String get configDecimales;

  /// No description provided for @configDecimalesAide.
  ///
  /// In fr, this message translates to:
  /// **'3 pour la vente au poids'**
  String get configDecimalesAide;

  /// No description provided for @configBoutiqueNomIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Supérette Benali'**
  String get configBoutiqueNomIndice;

  /// No description provided for @configBoutiqueAdresseIndice.
  ///
  /// In fr, this message translates to:
  /// **'Rue, commune, wilaya'**
  String get configBoutiqueAdresseIndice;

  /// No description provided for @configBoutiqueNis.
  ///
  /// In fr, this message translates to:
  /// **'NIS'**
  String get configBoutiqueNis;

  /// No description provided for @configBoutiqueArticle.
  ///
  /// In fr, this message translates to:
  /// **'Article d\'imposition'**
  String get configBoutiqueArticle;

  /// No description provided for @configBoutiqueMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message du ticket'**
  String get configBoutiqueMessage;

  /// No description provided for @configBoutiqueMessageIndice.
  ///
  /// In fr, this message translates to:
  /// **'Merci de votre visite !'**
  String get configBoutiqueMessageIndice;

  /// No description provided for @configSeuilAide.
  ///
  /// In fr, this message translates to:
  /// **'Seuil global, remplacé par celui du produit s\'il est défini'**
  String get configSeuilAide;

  /// No description provided for @configFideliteActive.
  ///
  /// In fr, this message translates to:
  /// **'Points de fidélité'**
  String get configFideliteActive;

  /// No description provided for @configPlusTard.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get configPlusTard;

  /// No description provided for @compteIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get compteIdentifiant;

  /// No description provided for @compteIdentite.
  ///
  /// In fr, this message translates to:
  /// **'@{identifiant} · dernier accès {acces}'**
  String compteIdentite(String identifiant, String acces);

  /// No description provided for @compteJamaisConnecte.
  ///
  /// In fr, this message translates to:
  /// **'première connexion'**
  String get compteJamaisConnecte;

  /// No description provided for @compteOngletProfil.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get compteOngletProfil;

  /// No description provided for @compteOngletMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get compteOngletMotDePasse;

  /// No description provided for @compteCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get compteCode;

  /// No description provided for @compteMagasinDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Magasin par défaut'**
  String get compteMagasinDefaut;

  /// No description provided for @compteConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get compteConfirmer;

  /// No description provided for @compteMotDePasseAide.
  ///
  /// In fr, this message translates to:
  /// **'{n} caractères minimum'**
  String compteMotDePasseAide(int n);

  /// No description provided for @comptePreferencesAide.
  ///
  /// In fr, this message translates to:
  /// **'Ces préférences s\'appliquent à ce poste.'**
  String get comptePreferencesAide;

  /// No description provided for @alertesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Alertes du jour'**
  String get alertesTitre;

  /// No description provided for @alertesUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgent'**
  String get alertesUrgent;

  /// No description provided for @alertesASurveiller.
  ///
  /// In fr, this message translates to:
  /// **'À surveiller'**
  String get alertesASurveiller;

  /// No description provided for @alertesNePlusAfficher.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus afficher aujourd\'hui'**
  String get alertesNePlusAfficher;

  /// No description provided for @alertesLienParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres › Alertes'**
  String get alertesLienParametres;

  /// No description provided for @alertesOuvrirModule.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le module'**
  String get alertesOuvrirModule;

  /// No description provided for @alertesMarquerTraite.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme traité'**
  String get alertesMarquerTraite;

  /// No description provided for @alertesRienTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rien à signaler'**
  String get alertesRienTitre;

  /// No description provided for @alertesRienDetail.
  ///
  /// In fr, this message translates to:
  /// **'Cette famille d\'alertes est traitée.'**
  String get alertesRienDetail;

  /// No description provided for @alertesMesureRupture.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get alertesMesureRupture;

  /// No description provided for @alertesOuverteDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte depuis le {date}'**
  String alertesOuverteDepuis(String date);

  /// No description provided for @alertesJours.
  ///
  /// In fr, this message translates to:
  /// **'J−{n}'**
  String alertesJours(int n);

  /// No description provided for @alertesDernierDocument.
  ///
  /// In fr, this message translates to:
  /// **'{code} · dernier document le {date}'**
  String alertesDernierDocument(String code, String date);

  /// No description provided for @alertesRupture.
  ///
  /// In fr, this message translates to:
  /// **'Ruptures et seuils'**
  String get alertesRupture;

  /// No description provided for @alertesRuptureAide.
  ///
  /// In fr, this message translates to:
  /// **'Produits épuisés ou sous leur seuil d\'alerte.'**
  String get alertesRuptureAide;

  /// No description provided for @alertesRuptureAction.
  ///
  /// In fr, this message translates to:
  /// **'Créer une liste de besoins'**
  String get alertesRuptureAction;

  /// No description provided for @alertesRuptureLigne.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get alertesRuptureLigne;

  /// No description provided for @alertesVoirStock.
  ///
  /// In fr, this message translates to:
  /// **'Voir le stock'**
  String get alertesVoirStock;

  /// No description provided for @alertesExpire.
  ///
  /// In fr, this message translates to:
  /// **'Produits expirés'**
  String get alertesExpire;

  /// No description provided for @alertesExpireAide.
  ///
  /// In fr, this message translates to:
  /// **'Lots périmés encore en stock — à sortir avant la vente.'**
  String get alertesExpireAide;

  /// No description provided for @alertesExpireAction.
  ///
  /// In fr, this message translates to:
  /// **'Sortie « Périmé »'**
  String get alertesExpireAction;

  /// No description provided for @alertesExpireLigne.
  ///
  /// In fr, this message translates to:
  /// **'Sortir'**
  String get alertesExpireLigne;

  /// No description provided for @alertesSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions ouvertes'**
  String get alertesSessions;

  /// No description provided for @alertesSessionsAide.
  ///
  /// In fr, this message translates to:
  /// **'Sessions de caisse ouvertes depuis un jour précédent.'**
  String get alertesSessionsAide;

  /// No description provided for @alertesSessionsAction.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer'**
  String get alertesSessionsAction;

  /// No description provided for @alertesBientot.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt expirés'**
  String get alertesBientot;

  /// No description provided for @alertesBientotAide.
  ///
  /// In fr, this message translates to:
  /// **'Lots qui expirent dans les 30 prochains jours.'**
  String get alertesBientotAide;

  /// No description provided for @alertesBientotAction.
  ///
  /// In fr, this message translates to:
  /// **'Créer une remise'**
  String get alertesBientotAction;

  /// No description provided for @alertesBientotLigne.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get alertesBientotLigne;

  /// No description provided for @alertesClients.
  ///
  /// In fr, this message translates to:
  /// **'Crédits clients'**
  String get alertesClients;

  /// No description provided for @alertesClientsAide.
  ///
  /// In fr, this message translates to:
  /// **'Les plus gros crédits en cours.'**
  String get alertesClientsAide;

  /// No description provided for @alertesClientsAction.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau versement'**
  String get alertesClientsAction;

  /// No description provided for @alertesClientsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get alertesClientsLigne;

  /// No description provided for @alertesFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Dettes fournisseurs'**
  String get alertesFournisseurs;

  /// No description provided for @alertesFournisseursAide.
  ///
  /// In fr, this message translates to:
  /// **'Les plus grosses dettes et leur dernier achat.'**
  String get alertesFournisseursAide;

  /// No description provided for @alertesFournisseursAction.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau règlement'**
  String get alertesFournisseursAction;

  /// No description provided for @alertesFournisseursLigne.
  ///
  /// In fr, this message translates to:
  /// **'Régler'**
  String get alertesFournisseursLigne;

  /// No description provided for @dsPeriodeAujourdhui.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get dsPeriodeAujourdhui;

  /// No description provided for @dsPeriodeHier.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get dsPeriodeHier;

  /// No description provided for @dsPeriodeSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get dsPeriodeSemaine;

  /// No description provided for @dsPeriodeSemaineDerniere.
  ///
  /// In fr, this message translates to:
  /// **'Semaine dernière'**
  String get dsPeriodeSemaineDerniere;

  /// No description provided for @dsPeriodeMois.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get dsPeriodeMois;

  /// No description provided for @dsPeriodeMoisDernier.
  ///
  /// In fr, this message translates to:
  /// **'Mois dernier'**
  String get dsPeriodeMoisDernier;

  /// No description provided for @dsPeriode7Jours.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get dsPeriode7Jours;

  /// No description provided for @dsPeriode30Jours.
  ///
  /// In fr, this message translates to:
  /// **'30 derniers jours'**
  String get dsPeriode30Jours;

  /// No description provided for @dsPeriodeAnnee.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get dsPeriodeAnnee;

  /// No description provided for @dsPeriodeAnneeDerniere.
  ///
  /// In fr, this message translates to:
  /// **'Année dernière'**
  String get dsPeriodeAnneeDerniere;

  /// No description provided for @dsDu.
  ///
  /// In fr, this message translates to:
  /// **'Du'**
  String get dsDu;

  /// No description provided for @dsAu.
  ///
  /// In fr, this message translates to:
  /// **'Au'**
  String get dsAu;

  /// No description provided for @dsPeriodeRapide.
  ///
  /// In fr, this message translates to:
  /// **'Période rapide'**
  String get dsPeriodeRapide;

  /// No description provided for @dsRechercherIndice.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher…'**
  String get dsRechercherIndice;

  /// No description provided for @dsAffichageGrille.
  ///
  /// In fr, this message translates to:
  /// **'Affichage grille'**
  String get dsAffichageGrille;

  /// No description provided for @dsAffichageListe.
  ///
  /// In fr, this message translates to:
  /// **'Affichage liste'**
  String get dsAffichageListe;

  /// No description provided for @dsModifiezRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Modifiez la recherche ou les filtres.'**
  String get dsModifiezRecherche;

  /// No description provided for @auditTitre.
  ///
  /// In fr, this message translates to:
  /// **'Traçabilité'**
  String get auditTitre;

  /// No description provided for @auditCreePar.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get auditCreePar;

  /// No description provided for @auditAnnuleLe.
  ///
  /// In fr, this message translates to:
  /// **'Annulé le'**
  String get auditAnnuleLe;

  /// No description provided for @auditAnnulePar.
  ///
  /// In fr, this message translates to:
  /// **'Annulé par'**
  String get auditAnnulePar;

  /// No description provided for @auditMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get auditMotif;

  /// No description provided for @dsAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get dsAnnuler;

  /// No description provided for @dsValider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get dsValider;

  /// No description provided for @statutActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statutActif;

  /// No description provided for @statutInactif.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get statutInactif;

  /// No description provided for @statutPaye.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get statutPaye;

  /// No description provided for @statutPartiel.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get statutPartiel;

  /// No description provided for @statutCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get statutCredit;

  /// No description provided for @statutAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get statutAnnule;

  /// No description provided for @statutOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get statutOuverte;

  /// No description provided for @statutFermee.
  ///
  /// In fr, this message translates to:
  /// **'Fermée'**
  String get statutFermee;

  /// No description provided for @statutCloturee.
  ///
  /// In fr, this message translates to:
  /// **'Clôturée'**
  String get statutCloturee;

  /// No description provided for @statutRupture.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get statutRupture;

  /// No description provided for @statutSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Sous seuil'**
  String get statutSeuil;

  /// No description provided for @statutExpire.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get statutExpire;

  /// No description provided for @statutBientotExpire.
  ///
  /// In fr, this message translates to:
  /// **'Expire bientôt'**
  String get statutBientotExpire;

  /// No description provided for @statutBrouillon.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get statutBrouillon;

  /// No description provided for @statutValide.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get statutValide;

  /// No description provided for @statutEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get statutEntree;

  /// No description provided for @statutSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get statutSortie;

  /// No description provided for @statutRetourne.
  ///
  /// In fr, this message translates to:
  /// **'Retourné'**
  String get statutRetourne;

  /// No description provided for @statutClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get statutClient;

  /// No description provided for @statutFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get statutFournisseur;

  /// No description provided for @statutRecu.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get statutRecu;

  /// No description provided for @statutTraite.
  ///
  /// In fr, this message translates to:
  /// **'Traité'**
  String get statutTraite;

  /// No description provided for @tiers15Chiffres.
  ///
  /// In fr, this message translates to:
  /// **'15 chiffres'**
  String get tiers15Chiffres;

  /// No description provided for @tiers20Chiffres.
  ///
  /// In fr, this message translates to:
  /// **'20 chiffres'**
  String get tiers20Chiffres;

  /// No description provided for @tiersActivite.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get tiersActivite;

  /// No description provided for @tiersActiviteIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. alimentation générale'**
  String get tiersActiviteIndice;

  /// No description provided for @tiersAdministratifBanque.
  ///
  /// In fr, this message translates to:
  /// **'Administratif & banque'**
  String get tiersAdministratifBanque;

  /// No description provided for @tiersAdresseIndice.
  ///
  /// In fr, this message translates to:
  /// **'Rue, commune'**
  String get tiersAdresseIndice;

  /// No description provided for @tiersAvance.
  ///
  /// In fr, this message translates to:
  /// **'Avance'**
  String get tiersAvance;

  /// No description provided for @tiersBanque.
  ///
  /// In fr, this message translates to:
  /// **'Banque'**
  String get tiersBanque;

  /// No description provided for @tiersBloqueCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit en cours — soldez-le d\'abord'**
  String get tiersBloqueCredit;

  /// No description provided for @tiersBloqueDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulé'**
  String get tiersBloqueDejaAnnule;

  /// No description provided for @tiersBloqueSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Élément système'**
  String get tiersBloqueSysteme;

  /// No description provided for @tiersChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Choisir…'**
  String get tiersChoisir;

  /// No description provided for @tiersChoisirClient.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client'**
  String get tiersChoisirClient;

  /// No description provided for @tiersChoisirFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fournisseur'**
  String get tiersChoisirFournisseur;

  /// No description provided for @tiersCodeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Généré automatiquement'**
  String get tiersCodeAuto;

  /// No description provided for @tiersContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get tiersContact;

  /// No description provided for @tiersCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get tiersCredit;

  /// No description provided for @tiersCreditAide.
  ///
  /// In fr, this message translates to:
  /// **'Crédit (achats)'**
  String get tiersCreditAide;

  /// No description provided for @tiersDebit.
  ///
  /// In fr, this message translates to:
  /// **'Débit'**
  String get tiersDebit;

  /// No description provided for @tiersDebitAide.
  ///
  /// In fr, this message translates to:
  /// **'Débit (paiements, retours)'**
  String get tiersDebitAide;

  /// No description provided for @tiersDernierAchat.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat'**
  String get tiersDernierAchat;

  /// No description provided for @tiersDerniereEntree.
  ///
  /// In fr, this message translates to:
  /// **'Dernière entrée'**
  String get tiersDerniereEntree;

  /// No description provided for @tiersDernieresEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Dernières entrées'**
  String get tiersDernieresEntrees;

  /// No description provided for @tiersDerniersPaniers.
  ///
  /// In fr, this message translates to:
  /// **'Derniers paniers'**
  String get tiersDerniersPaniers;

  /// No description provided for @tiersDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get tiersDetail;

  /// No description provided for @tiersEntiteClient.
  ///
  /// In fr, this message translates to:
  /// **'client'**
  String get tiersEntiteClient;

  /// No description provided for @tiersEntiteClientMaj.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get tiersEntiteClientMaj;

  /// No description provided for @tiersEntiteClients.
  ///
  /// In fr, this message translates to:
  /// **'clients'**
  String get tiersEntiteClients;

  /// No description provided for @tiersEntiteFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'fournisseur'**
  String get tiersEntiteFournisseur;

  /// No description provided for @tiersEntiteFournisseurMaj.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get tiersEntiteFournisseurMaj;

  /// No description provided for @tiersEntiteFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'fournisseurs'**
  String get tiersEntiteFournisseurs;

  /// No description provided for @tiersErreurNomExistant.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom existe déjà'**
  String get tiersErreurNomExistant;

  /// No description provided for @tiersEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get tiersEtat;

  /// No description provided for @tiersFax.
  ///
  /// In fr, this message translates to:
  /// **'Fax'**
  String get tiersFax;

  /// No description provided for @tiersFormatNif.
  ///
  /// In fr, this message translates to:
  /// **'Le NIF doit contenir 15 chiffres'**
  String get tiersFormatNif;

  /// No description provided for @tiersFormatTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Format attendu : 0X XX XX XX XX'**
  String get tiersFormatTelephone;

  /// No description provided for @tiersInfosAdministratives.
  ///
  /// In fr, this message translates to:
  /// **'Informations administratives'**
  String get tiersInfosAdministratives;

  /// No description provided for @tiersInfosBancaires.
  ///
  /// In fr, this message translates to:
  /// **'Informations bancaires'**
  String get tiersInfosBancaires;

  /// No description provided for @tiersInfosGenerales.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get tiersInfosGenerales;

  /// No description provided for @tiersKpiClientsActifs.
  ///
  /// In fr, this message translates to:
  /// **'Clients actifs'**
  String get tiersKpiClientsActifs;

  /// No description provided for @tiersKpiCreditClients.
  ///
  /// In fr, this message translates to:
  /// **'Crédit clients'**
  String get tiersKpiCreditClients;

  /// No description provided for @tiersKpiCreditFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Crédit fournisseurs'**
  String get tiersKpiCreditFournisseurs;

  /// No description provided for @tiersKpiFournisseursActifs.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs actifs'**
  String get tiersKpiFournisseursActifs;

  /// No description provided for @tiersKpiPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points fidélité'**
  String get tiersKpiPoints;

  /// No description provided for @tiersModifierClient.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le client'**
  String get tiersModifierClient;

  /// No description provided for @tiersModifierFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le fournisseur'**
  String get tiersModifierFournisseur;

  /// No description provided for @tiersNatureAchat.
  ///
  /// In fr, this message translates to:
  /// **'Achat'**
  String get tiersNatureAchat;

  /// No description provided for @tiersNatureRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get tiersNatureRetour;

  /// No description provided for @tiersNatureVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get tiersNatureVente;

  /// No description provided for @tiersNatureVersement.
  ///
  /// In fr, this message translates to:
  /// **'Versement'**
  String get tiersNatureVersement;

  /// No description provided for @tiersNatureVersementRetour.
  ///
  /// In fr, this message translates to:
  /// **'Versement retour'**
  String get tiersNatureVersementRetour;

  /// No description provided for @tiersNomIndice.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou raison sociale'**
  String get tiersNomIndice;

  /// No description provided for @tiersNoteInterne.
  ///
  /// In fr, this message translates to:
  /// **'Note interne'**
  String get tiersNoteInterne;

  /// No description provided for @tiersNrc.
  ///
  /// In fr, this message translates to:
  /// **'N° RC'**
  String get tiersNrc;

  /// No description provided for @tiersObservation.
  ///
  /// In fr, this message translates to:
  /// **'Observation'**
  String get tiersObservation;

  /// No description provided for @tiersPanier.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get tiersPanier;

  /// No description provided for @tiersPoints.
  ///
  /// In fr, this message translates to:
  /// **'{n} points'**
  String tiersPoints(int n);

  /// No description provided for @tiersRechercheIndice.
  ///
  /// In fr, this message translates to:
  /// **'Nom, code ou téléphone…'**
  String get tiersRechercheIndice;

  /// No description provided for @tiersReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get tiersReference;

  /// No description provided for @tiersReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get tiersReste;

  /// No description provided for @tiersSituation.
  ///
  /// In fr, this message translates to:
  /// **'Situation'**
  String get tiersSituation;

  /// No description provided for @tiersSituationDe.
  ///
  /// In fr, this message translates to:
  /// **'Situation — {nom}'**
  String tiersSituationDe(String nom);

  /// No description provided for @tiersSoldeDu.
  ///
  /// In fr, this message translates to:
  /// **'Solde dû'**
  String get tiersSoldeDu;

  /// No description provided for @tiersStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get tiersStatut;

  /// No description provided for @tiersTotalAchats.
  ///
  /// In fr, this message translates to:
  /// **'Total achats'**
  String get tiersTotalAchats;

  /// No description provided for @tiersTotalPaye.
  ///
  /// In fr, this message translates to:
  /// **'Total payé'**
  String get tiersTotalPaye;

  /// No description provided for @tiersTotalRetours.
  ///
  /// In fr, this message translates to:
  /// **'Total retours'**
  String get tiersTotalRetours;

  /// No description provided for @tiersTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tiersTous;

  /// No description provided for @tiersToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get tiersToutes;

  /// No description provided for @tiersType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get tiersType;

  /// No description provided for @tiersVersement.
  ///
  /// In fr, this message translates to:
  /// **'Versement'**
  String get tiersVersement;

  /// No description provided for @tiersWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get tiersWilaya;

  /// No description provided for @versementAucunBeneficiaire.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bénéficiaire choisi'**
  String get versementAucunBeneficiaire;

  /// No description provided for @versementAvanceTropPercu.
  ///
  /// In fr, this message translates to:
  /// **'Avance / trop-perçu après ce versement'**
  String get versementAvanceTropPercu;

  /// No description provided for @versementBeneficiaire.
  ///
  /// In fr, this message translates to:
  /// **'Bénéficiaire'**
  String get versementBeneficiaire;

  /// No description provided for @versementCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get versementCaisse;

  /// No description provided for @versementCliquezChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez pour choisir'**
  String get versementCliquezChoisir;

  /// No description provided for @versementCompteSolde.
  ///
  /// In fr, this message translates to:
  /// **'Compte soldé après ce versement'**
  String get versementCompteSolde;

  /// No description provided for @versementCreditActuel.
  ///
  /// In fr, this message translates to:
  /// **'Crédit actuel : {montant}'**
  String versementCreditActuel(String montant);

  /// No description provided for @versementCreditRestant.
  ///
  /// In fr, this message translates to:
  /// **'Crédit restant après ce versement'**
  String get versementCreditRestant;

  /// No description provided for @versementEntite.
  ///
  /// In fr, this message translates to:
  /// **'versement'**
  String get versementEntite;

  /// No description provided for @versementEntites.
  ///
  /// In fr, this message translates to:
  /// **'versements'**
  String get versementEntites;

  /// No description provided for @versementKpiEncaisse.
  ///
  /// In fr, this message translates to:
  /// **'Montant encaissé'**
  String get versementKpiEncaisse;

  /// No description provided for @versementKpiNombre.
  ///
  /// In fr, this message translates to:
  /// **'Versements'**
  String get versementKpiNombre;

  /// No description provided for @versementKpiPaye.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get versementKpiPaye;

  /// No description provided for @versementKpiRetour.
  ///
  /// In fr, this message translates to:
  /// **'Versements retour'**
  String get versementKpiRetour;

  /// No description provided for @versementModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le versement'**
  String get versementModifier;

  /// No description provided for @versementNumero.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get versementNumero;

  /// No description provided for @versementObsIndice.
  ///
  /// In fr, this message translates to:
  /// **'Observation (facultatif)'**
  String get versementObsIndice;

  /// No description provided for @versementRetourModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le versement retour'**
  String get versementRetourModifier;

  /// No description provided for @versementRetourNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Versement retour'**
  String get versementRetourNouveau;

  /// No description provided for @versementRetourTitre.
  ///
  /// In fr, this message translates to:
  /// **'Versement retour'**
  String get versementRetourTitre;

  /// No description provided for @versementSens.
  ///
  /// In fr, this message translates to:
  /// **'Sens'**
  String get versementSens;

  /// No description provided for @versementSensPaye.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get versementSensPaye;

  /// No description provided for @versementSensRecu.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get versementSensRecu;

  /// No description provided for @versementSensRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get versementSensRetour;

  /// No description provided for @versementTitre.
  ///
  /// In fr, this message translates to:
  /// **'Versement'**
  String get versementTitre;

  /// No description provided for @versementType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get versementType;

  /// No description provided for @dsChargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get dsChargement;

  /// No description provided for @tableauBordOnglet.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get tableauBordOnglet;

  /// No description provided for @situationOnglet.
  ///
  /// In fr, this message translates to:
  /// **'Situation'**
  String get situationOnglet;

  /// No description provided for @tableauBordJour.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get tableauBordJour;

  /// No description provided for @tableauBordSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get tableauBordSemaine;

  /// No description provided for @tableauBordMois.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get tableauBordMois;

  /// No description provided for @tableauBordPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get tableauBordPeriode;

  /// No description provided for @tableauBordChoisirPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la période'**
  String get tableauBordChoisirPeriode;

  /// No description provided for @tableauBordIndicateur.
  ///
  /// In fr, this message translates to:
  /// **'Indicateur'**
  String get tableauBordIndicateur;

  /// No description provided for @tableauBordPeriodeCourante.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get tableauBordPeriodeCourante;

  /// No description provided for @tableauBordPeriodePrecedente.
  ///
  /// In fr, this message translates to:
  /// **'Période précédente'**
  String get tableauBordPeriodePrecedente;

  /// No description provided for @tableauBordVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get tableauBordVentes;

  /// No description provided for @tableauBordVentesInfo.
  ///
  /// In fr, this message translates to:
  /// **'Total des paniers encaissés sur la période'**
  String get tableauBordVentesInfo;

  /// No description provided for @tableauBordPrecedenteInfo.
  ///
  /// In fr, this message translates to:
  /// **'Même nombre de jours, juste avant la période'**
  String get tableauBordPrecedenteInfo;

  /// No description provided for @tableauBordAchats.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get tableauBordAchats;

  /// No description provided for @tableauBordAchatsInfo.
  ///
  /// In fr, this message translates to:
  /// **'Entrées validées (bons d\'achat)'**
  String get tableauBordAchatsInfo;

  /// No description provided for @tableauBordNet.
  ///
  /// In fr, this message translates to:
  /// **'Net'**
  String get tableauBordNet;

  /// No description provided for @tableauBordNetInfo.
  ///
  /// In fr, this message translates to:
  /// **'Ventes − achats de la période'**
  String get tableauBordNetInfo;

  /// No description provided for @tableauBordDetteFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Dette fournisseurs'**
  String get tableauBordDetteFournisseurs;

  /// No description provided for @tableauBordDetteInfo.
  ///
  /// In fr, this message translates to:
  /// **'Restes à payer sur les entrées'**
  String get tableauBordDetteInfo;

  /// No description provided for @tableauBordCreditClients.
  ///
  /// In fr, this message translates to:
  /// **'Crédit clients'**
  String get tableauBordCreditClients;

  /// No description provided for @tableauBordCreditInfo.
  ///
  /// In fr, this message translates to:
  /// **'Restes dus sur les paniers'**
  String get tableauBordCreditInfo;

  /// No description provided for @tableauBordCourbeVentes.
  ///
  /// In fr, this message translates to:
  /// **'Courbe des ventes'**
  String get tableauBordCourbeVentes;

  /// No description provided for @tableauBordModesPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Modes de paiement'**
  String get tableauBordModesPaiement;

  /// No description provided for @tableauBordTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get tableauBordTotal;

  /// No description provided for @tableauBordCaParJour.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires par jour'**
  String get tableauBordCaParJour;

  /// No description provided for @tableauBordVentesCaissier.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par caissier'**
  String get tableauBordVentesCaissier;

  /// No description provided for @tableauBordTickets.
  ///
  /// In fr, this message translates to:
  /// **'{n} tickets'**
  String tableauBordTickets(int n);

  /// No description provided for @tableauBordUnites.
  ///
  /// In fr, this message translates to:
  /// **'{qte} u.'**
  String tableauBordUnites(String qte);

  /// No description provided for @tableauBordDernieresVentes.
  ///
  /// In fr, this message translates to:
  /// **'Dernières ventes'**
  String get tableauBordDernieresVentes;

  /// No description provided for @tableauBordPanier.
  ///
  /// In fr, this message translates to:
  /// **'N° panier'**
  String get tableauBordPanier;

  /// No description provided for @tableauBordHeure.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get tableauBordHeure;

  /// No description provided for @tableauBordPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get tableauBordPaiement;

  /// No description provided for @tableauBordRuptures.
  ///
  /// In fr, this message translates to:
  /// **'Produits en rupture'**
  String get tableauBordRuptures;

  /// No description provided for @tableauBordAucuneRupture.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit en rupture'**
  String get tableauBordAucuneRupture;

  /// No description provided for @tableauBordProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get tableauBordProduit;

  /// No description provided for @tableauBordStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get tableauBordStock;

  /// No description provided for @situationGroupeTresorerie.
  ///
  /// In fr, this message translates to:
  /// **'Trésorerie'**
  String get situationGroupeTresorerie;

  /// No description provided for @situationGroupeStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get situationGroupeStock;

  /// No description provided for @situationGroupeVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get situationGroupeVentes;

  /// No description provided for @situationGroupeMarges.
  ///
  /// In fr, this message translates to:
  /// **'Marges'**
  String get situationGroupeMarges;

  /// No description provided for @situationGroupeTiers.
  ///
  /// In fr, this message translates to:
  /// **'Tiers'**
  String get situationGroupeTiers;

  /// No description provided for @situationMvc.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement caisse'**
  String get situationMvc;

  /// No description provided for @situationMvp.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement produit'**
  String get situationMvp;

  /// No description provided for @situationRcp.
  ///
  /// In fr, this message translates to:
  /// **'Recette par panier'**
  String get situationRcp;

  /// No description provided for @situationRcpr.
  ///
  /// In fr, this message translates to:
  /// **'Recette par produit'**
  String get situationRcpr;

  /// No description provided for @situationMgp.
  ///
  /// In fr, this message translates to:
  /// **'Marge par panier'**
  String get situationMgp;

  /// No description provided for @situationMgper.
  ///
  /// In fr, this message translates to:
  /// **'Marge par période'**
  String get situationMgper;

  /// No description provided for @situationInv.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get situationInv;

  /// No description provided for @situationCout.
  ///
  /// In fr, this message translates to:
  /// **'Coût produit'**
  String get situationCout;

  /// No description provided for @situationScli.
  ///
  /// In fr, this message translates to:
  /// **'Situation client'**
  String get situationScli;

  /// No description provided for @situationSfrn.
  ///
  /// In fr, this message translates to:
  /// **'Situation fournisseur'**
  String get situationSfrn;

  /// No description provided for @situationEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées'**
  String get situationEntrees;

  /// No description provided for @situationSorties.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get situationSorties;

  /// No description provided for @situationSoldeNet.
  ///
  /// In fr, this message translates to:
  /// **'Solde net'**
  String get situationSoldeNet;

  /// No description provided for @situationRetours.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get situationRetours;

  /// No description provided for @situationStockInitial.
  ///
  /// In fr, this message translates to:
  /// **'Stock initial'**
  String get situationStockInitial;

  /// No description provided for @situationStockFinal.
  ///
  /// In fr, this message translates to:
  /// **'Stock final'**
  String get situationStockFinal;

  /// No description provided for @situationCaissier.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get situationCaissier;

  /// No description provided for @situationPaye.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get situationPaye;

  /// No description provided for @situationPaniers.
  ///
  /// In fr, this message translates to:
  /// **'Paniers'**
  String get situationPaniers;

  /// No description provided for @situationRecette.
  ///
  /// In fr, this message translates to:
  /// **'Recette'**
  String get situationRecette;

  /// No description provided for @situationPanierMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Panier moyen'**
  String get situationPanierMoyen;

  /// No description provided for @situationCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get situationCategorie;

  /// No description provided for @situationQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get situationQuantite;

  /// No description provided for @situationPrixMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Prix moyen'**
  String get situationPrixMoyen;

  /// No description provided for @situationProduitsVendus.
  ///
  /// In fr, this message translates to:
  /// **'Produits vendus'**
  String get situationProduitsVendus;

  /// No description provided for @situationVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get situationVente;

  /// No description provided for @situationCoutLibelle.
  ///
  /// In fr, this message translates to:
  /// **'Coût'**
  String get situationCoutLibelle;

  /// No description provided for @situationMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get situationMarge;

  /// No description provided for @situationTaux.
  ///
  /// In fr, this message translates to:
  /// **'Taux'**
  String get situationTaux;

  /// No description provided for @situationCa.
  ///
  /// In fr, this message translates to:
  /// **'CA'**
  String get situationCa;

  /// No description provided for @situationTauxMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Taux moyen'**
  String get situationTauxMoyen;

  /// No description provided for @situationMargeParPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Marge par période'**
  String get situationMargeParPeriode;

  /// No description provided for @situationRegrouper.
  ///
  /// In fr, this message translates to:
  /// **'Regrouper'**
  String get situationRegrouper;

  /// No description provided for @situationParJour.
  ///
  /// In fr, this message translates to:
  /// **'Par jour'**
  String get situationParJour;

  /// No description provided for @situationParSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Par semaine'**
  String get situationParSemaine;

  /// No description provided for @situationParMois.
  ///
  /// In fr, this message translates to:
  /// **'Par mois'**
  String get situationParMois;

  /// No description provided for @situationMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get situationMagasin;

  /// No description provided for @situationTheorique.
  ///
  /// In fr, this message translates to:
  /// **'Théorique'**
  String get situationTheorique;

  /// No description provided for @situationCompte.
  ///
  /// In fr, this message translates to:
  /// **'Compté'**
  String get situationCompte;

  /// No description provided for @situationEcart.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get situationEcart;

  /// No description provided for @situationValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get situationValeur;

  /// No description provided for @situationProduitsComptes.
  ///
  /// In fr, this message translates to:
  /// **'Produits comptés'**
  String get situationProduitsComptes;

  /// No description provided for @situationEcarts.
  ///
  /// In fr, this message translates to:
  /// **'Écarts'**
  String get situationEcarts;

  /// No description provided for @situationValeurEcart.
  ///
  /// In fr, this message translates to:
  /// **'Valeur de l\'écart'**
  String get situationValeurEcart;

  /// No description provided for @situationValiderInventaire.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'inventaire'**
  String get situationValiderInventaire;

  /// No description provided for @situationInventaireMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un magasin pour valider l\'inventaire.'**
  String get situationInventaireMagasin;

  /// No description provided for @situationAucunEcart.
  ///
  /// In fr, this message translates to:
  /// **'Aucun écart à enregistrer.'**
  String get situationAucunEcart;

  /// No description provided for @situationConfirmerInventaire.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) seront ajustés au stock compté. Continuer ?'**
  String situationConfirmerInventaire(int n);

  /// No description provided for @situationInventaireValide.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire validé'**
  String get situationInventaireValide;

  /// No description provided for @situationProduitsAjustes.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) ajusté(s)'**
  String situationProduitsAjustes(int n);

  /// No description provided for @situationDernierAchat.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat'**
  String get situationDernierAchat;

  /// No description provided for @situationCmp.
  ///
  /// In fr, this message translates to:
  /// **'Coût moyen pondéré'**
  String get situationCmp;

  /// No description provided for @situationMin.
  ///
  /// In fr, this message translates to:
  /// **'Min'**
  String get situationMin;

  /// No description provided for @situationMax.
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get situationMax;

  /// No description provided for @situationPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get situationPrixVente;

  /// No description provided for @situationProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get situationProduits;

  /// No description provided for @situationMargeMoyenne.
  ///
  /// In fr, this message translates to:
  /// **'Marge moyenne'**
  String get situationMargeMoyenne;

  /// No description provided for @situationSous15.
  ///
  /// In fr, this message translates to:
  /// **'Sous 15 %'**
  String get situationSous15;

  /// No description provided for @situationAchats.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get situationAchats;

  /// No description provided for @situationDette.
  ///
  /// In fr, this message translates to:
  /// **'Dette'**
  String get situationDette;

  /// No description provided for @situationDettes.
  ///
  /// In fr, this message translates to:
  /// **'Dettes'**
  String get situationDettes;

  /// No description provided for @situationCreditTotal.
  ///
  /// In fr, this message translates to:
  /// **'Crédit total'**
  String get situationCreditTotal;

  /// No description provided for @ventesKpiNombre.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de ventes'**
  String get ventesKpiNombre;

  /// No description provided for @ventesKpiCa.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get ventesKpiCa;

  /// No description provided for @ventesKpiMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get ventesKpiMarge;

  /// No description provided for @ventesKpiEncaisse.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get ventesKpiEncaisse;

  /// No description provided for @ventesKpiCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit clients'**
  String get ventesKpiCredit;

  /// No description provided for @ventesType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get ventesType;

  /// No description provided for @ventesTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get ventesTous;

  /// No description provided for @ventesToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get ventesToutes;

  /// No description provided for @ventesStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get ventesStatut;

  /// No description provided for @ventesCaissier.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get ventesCaissier;

  /// No description provided for @ventesClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get ventesClient;

  /// No description provided for @ventesCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get ventesCaisse;

  /// No description provided for @ventesSession.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get ventesSession;

  /// No description provided for @ventesMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get ventesMontant;

  /// No description provided for @ventesPaye.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get ventesPaye;

  /// No description provided for @ventesReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get ventesReste;

  /// No description provided for @ventesPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get ventesPaiement;

  /// No description provided for @ventesArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get ventesArticles;

  /// No description provided for @ventesQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get ventesQuantite;

  /// No description provided for @ventesNbVersements.
  ///
  /// In fr, this message translates to:
  /// **'Nb versements'**
  String get ventesNbVersements;

  /// No description provided for @ventesMontantAchat.
  ///
  /// In fr, this message translates to:
  /// **'Montant achat'**
  String get ventesMontantAchat;

  /// No description provided for @ventesAnnuleLe.
  ///
  /// In fr, this message translates to:
  /// **'Annulé le'**
  String get ventesAnnuleLe;

  /// No description provided for @ventesAnnulePar.
  ///
  /// In fr, this message translates to:
  /// **'Annulé par'**
  String get ventesAnnulePar;

  /// No description provided for @ventesRechercheIndice.
  ///
  /// In fr, this message translates to:
  /// **'N° panier ou client…'**
  String get ventesRechercheIndice;

  /// No description provided for @ventesNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente'**
  String get ventesNouvelle;

  /// No description provided for @ventesEntite.
  ///
  /// In fr, this message translates to:
  /// **'panier'**
  String get ventesEntite;

  /// No description provided for @ventesEntitePluriel.
  ///
  /// In fr, this message translates to:
  /// **'paniers'**
  String get ventesEntitePluriel;

  /// No description provided for @ventesPanierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Panier {code}'**
  String ventesPanierTitre(String code);

  /// No description provided for @ventesReimprimer.
  ///
  /// In fr, this message translates to:
  /// **'Réimprimer'**
  String get ventesReimprimer;

  /// No description provided for @ventesMontantTotal.
  ///
  /// In fr, this message translates to:
  /// **'Montant total'**
  String get ventesMontantTotal;

  /// No description provided for @ventesVersements.
  ///
  /// In fr, this message translates to:
  /// **'Versements'**
  String get ventesVersements;

  /// No description provided for @ventesInfosGenerales.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get ventesInfosGenerales;

  /// No description provided for @ventesPaiementMarge.
  ///
  /// In fr, this message translates to:
  /// **'Paiement & marge'**
  String get ventesPaiementMarge;

  /// No description provided for @ventesTotalAchat.
  ///
  /// In fr, this message translates to:
  /// **'Total achat'**
  String get ventesTotalAchat;

  /// No description provided for @ventesMontantPaye.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get ventesMontantPaye;

  /// No description provided for @ventesNombreVersements.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de versements'**
  String get ventesNombreVersements;

  /// No description provided for @ventesModePaiement.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get ventesModePaiement;

  /// No description provided for @ventesProduitsPanier.
  ///
  /// In fr, this message translates to:
  /// **'Produits du panier'**
  String get ventesProduitsPanier;

  /// No description provided for @ventesProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get ventesProduits;

  /// No description provided for @ventesProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get ventesProduit;

  /// No description provided for @ventesQte.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get ventesQte;

  /// No description provided for @ventesNumSerie.
  ///
  /// In fr, this message translates to:
  /// **'N° série'**
  String get ventesNumSerie;

  /// No description provided for @ventesPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get ventesPrix;

  /// No description provided for @ventesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get ventesTotal;

  /// No description provided for @ventesAudit.
  ///
  /// In fr, this message translates to:
  /// **'Audit'**
  String get ventesAudit;

  /// No description provided for @ventesCreePar.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get ventesCreePar;

  /// No description provided for @ventesCreeLe.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get ventesCreeLe;

  /// No description provided for @ventesMotifAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Motif d\'annulation'**
  String get ventesMotifAnnulation;

  /// No description provided for @ventesEmpreinte.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte fiscale'**
  String get ventesEmpreinte;

  /// No description provided for @ventesModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le panier'**
  String get ventesModifierTitre;

  /// No description provided for @ventesClientScelle.
  ///
  /// In fr, this message translates to:
  /// **'Client du ticket scellé : pour un autre client, faites un retour puis une nouvelle vente.'**
  String get ventesClientScelle;

  /// No description provided for @ventesComplementIndice.
  ///
  /// In fr, this message translates to:
  /// **'Le complément sera enregistré comme versement imputé sur ce panier.'**
  String get ventesComplementIndice;

  /// No description provided for @ventesNoteInterne.
  ///
  /// In fr, this message translates to:
  /// **'Note interne'**
  String get ventesNoteInterne;

  /// No description provided for @ventesModifie.
  ///
  /// In fr, this message translates to:
  /// **'Panier modifié'**
  String get ventesModifie;

  /// No description provided for @ventesBloqueDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulé'**
  String get ventesBloqueDejaAnnule;

  /// No description provided for @ventesBloqueRetour.
  ///
  /// In fr, this message translates to:
  /// **'Un retour est lié à ce panier'**
  String get ventesBloqueRetour;

  /// No description provided for @ventesAnnulesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Paniers annulés'**
  String get ventesAnnulesTitre;

  /// No description provided for @ventesAnnulesMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le stock des produits a été réintégré et les montants retirés de la session.'**
  String get ventesAnnulesMessage;

  /// No description provided for @ventesAnnulesPartiel.
  ///
  /// In fr, this message translates to:
  /// **'{ok} panier(s) annulé(s). Échec : {detail}'**
  String ventesAnnulesPartiel(String detail, int ok);

  /// No description provided for @posErreurMotif.
  ///
  /// In fr, this message translates to:
  /// **'Le motif est obligatoire.'**
  String get posErreurMotif;

  /// No description provided for @posErreurMontantPaye.
  ///
  /// In fr, this message translates to:
  /// **'Le montant payé ne peut pas baisser (déjà payé : {montant}). Utilisez un retour.'**
  String posErreurMontantPaye(String montant);

  /// No description provided for @posErreurRetourLie.
  ///
  /// In fr, this message translates to:
  /// **'Un retour est lié à ce panier : annulation impossible.'**
  String get posErreurRetourLie;

  /// No description provided for @retoursOngletClients.
  ///
  /// In fr, this message translates to:
  /// **'Retours clients'**
  String get retoursOngletClients;

  /// No description provided for @retoursOngletFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Retours fournisseurs'**
  String get retoursOngletFournisseurs;

  /// No description provided for @retoursKpiNombre.
  ///
  /// In fr, this message translates to:
  /// **'Retours de la période'**
  String get retoursKpiNombre;

  /// No description provided for @retoursKpiQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité retournée'**
  String get retoursKpiQuantite;

  /// No description provided for @retoursKpiRembourse.
  ///
  /// In fr, this message translates to:
  /// **'Montant remboursé'**
  String get retoursKpiRembourse;

  /// No description provided for @retoursKpiDeduit.
  ///
  /// In fr, this message translates to:
  /// **'Déduit des crédits'**
  String get retoursKpiDeduit;

  /// No description provided for @retoursClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get retoursClient;

  /// No description provided for @retoursFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get retoursFournisseur;

  /// No description provided for @retoursRemboursement.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement'**
  String get retoursRemboursement;

  /// No description provided for @retoursReglement.
  ///
  /// In fr, this message translates to:
  /// **'Règlement'**
  String get retoursReglement;

  /// No description provided for @retoursEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get retoursEtat;

  /// No description provided for @retoursTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get retoursTous;

  /// No description provided for @retoursRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Code, tiers ou produit…'**
  String get retoursRecherche;

  /// No description provided for @retoursOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Origine'**
  String get retoursOrigine;

  /// No description provided for @retoursProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get retoursProduit;

  /// No description provided for @retoursQte.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get retoursQte;

  /// No description provided for @retoursMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get retoursMontant;

  /// No description provided for @retoursPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get retoursPrixAchat;

  /// No description provided for @retoursPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get retoursPrixVente;

  /// No description provided for @retoursObservation.
  ///
  /// In fr, this message translates to:
  /// **'Observation'**
  String get retoursObservation;

  /// No description provided for @retoursRegEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get retoursRegEspeces;

  /// No description provided for @retoursRegCarte.
  ///
  /// In fr, this message translates to:
  /// **'Carte CIB'**
  String get retoursRegCarte;

  /// No description provided for @retoursRegAvoir.
  ///
  /// In fr, this message translates to:
  /// **'Avoir client'**
  String get retoursRegAvoir;

  /// No description provided for @retoursRegDeduit.
  ///
  /// In fr, this message translates to:
  /// **'Déduit du crédit'**
  String get retoursRegDeduit;

  /// No description provided for @retoursRegRembEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement espèces'**
  String get retoursRegRembEspeces;

  /// No description provided for @retoursModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le retour'**
  String get retoursModifierTitre;

  /// No description provided for @retoursChoixClient.
  ///
  /// In fr, this message translates to:
  /// **'Retour client'**
  String get retoursChoixClient;

  /// No description provided for @retoursChoixClientDesc.
  ///
  /// In fr, this message translates to:
  /// **'Remet en stock, rembourse ou crée un avoir'**
  String get retoursChoixClientDesc;

  /// No description provided for @retoursChoixFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Retour fournisseur'**
  String get retoursChoixFournisseur;

  /// No description provided for @retoursChoixFournisseurDesc.
  ///
  /// In fr, this message translates to:
  /// **'Sort du stock, déduit du crédit fournisseur'**
  String get retoursChoixFournisseurDesc;

  /// No description provided for @retoursTicketOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Ticket d\'origine'**
  String get retoursTicketOrigine;

  /// No description provided for @retoursEntreeOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Entrée d\'origine'**
  String get retoursEntreeOrigine;

  /// No description provided for @retoursChoisirClientIndice.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client ≡'**
  String get retoursChoisirClientIndice;

  /// No description provided for @retoursChoisirFournisseurIndice.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fournisseur ≡'**
  String get retoursChoisirFournisseurIndice;

  /// No description provided for @retoursChoisirPanierIndice.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un panier ≡'**
  String get retoursChoisirPanierIndice;

  /// No description provided for @retoursChoisirEntreeIndice.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une entrée ≡'**
  String get retoursChoisirEntreeIndice;

  /// No description provided for @retoursChoisirTicket.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le ticket d\'origine'**
  String get retoursChoisirTicket;

  /// No description provided for @retoursChoisirEntree.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'entrée d\'origine'**
  String get retoursChoisirEntree;

  /// No description provided for @retoursProduitIndice.
  ///
  /// In fr, this message translates to:
  /// **'Produit de la pièce d\'origine'**
  String get retoursProduitIndice;

  /// No description provided for @retoursProduitAideTicket.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord le ticket d\'origine'**
  String get retoursProduitAideTicket;

  /// No description provided for @retoursProduitAideEntree.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord l\'entrée d\'origine'**
  String get retoursProduitAideEntree;

  /// No description provided for @retoursOptionVendu.
  ///
  /// In fr, this message translates to:
  /// **'{nom} — {qte} vendus à {prix}'**
  String retoursOptionVendu(String nom, String prix, String qte);

  /// No description provided for @retoursOptionRecu.
  ///
  /// In fr, this message translates to:
  /// **'{nom} — {qte} reçus à {prix}'**
  String retoursOptionRecu(String nom, String prix, String qte);

  /// No description provided for @retoursQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get retoursQuantite;

  /// No description provided for @retoursQuantiteMax.
  ///
  /// In fr, this message translates to:
  /// **'Maximum : {maximum}'**
  String retoursQuantiteMax(String maximum);

  /// No description provided for @retoursQuantiteDepasse.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {maximum} (quantité de la pièce d\'origine)'**
  String retoursQuantiteDepasse(String maximum);

  /// No description provided for @retoursNumSerie.
  ///
  /// In fr, this message translates to:
  /// **'N° de série'**
  String get retoursNumSerie;

  /// No description provided for @retoursNumSerieIndice.
  ///
  /// In fr, this message translates to:
  /// **'Si le produit est suivi'**
  String get retoursNumSerieIndice;

  /// No description provided for @retoursRemiseStock.
  ///
  /// In fr, this message translates to:
  /// **'Remise en stock'**
  String get retoursRemiseStock;

  /// No description provided for @retoursRemiseOui.
  ///
  /// In fr, this message translates to:
  /// **'Oui — produit revendable'**
  String get retoursRemiseOui;

  /// No description provided for @retoursRemiseNon.
  ///
  /// In fr, this message translates to:
  /// **'Non — défectueux, sortie « Casse »'**
  String get retoursRemiseNon;

  /// No description provided for @retoursMotifIndice.
  ///
  /// In fr, this message translates to:
  /// **'Motif du retour'**
  String get retoursMotifIndice;

  /// No description provided for @retoursARembourser.
  ///
  /// In fr, this message translates to:
  /// **'À rembourser au client'**
  String get retoursARembourser;

  /// No description provided for @retoursAvoirClient.
  ///
  /// In fr, this message translates to:
  /// **'Avoir au compte du client'**
  String get retoursAvoirClient;

  /// No description provided for @retoursADeduire.
  ///
  /// In fr, this message translates to:
  /// **'À déduire du crédit fournisseur'**
  String get retoursADeduire;

  /// No description provided for @retoursRembourseFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'À rembourser par le fournisseur'**
  String get retoursRembourseFournisseur;

  /// No description provided for @retoursEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Retour enregistré'**
  String get retoursEnregistre;

  /// No description provided for @retoursEnregistreDetail.
  ///
  /// In fr, this message translates to:
  /// **'{code} · stock mis à jour'**
  String retoursEnregistreDetail(String code);

  /// No description provided for @retoursModifie.
  ///
  /// In fr, this message translates to:
  /// **'Retour modifié'**
  String get retoursModifie;

  /// No description provided for @retoursAnnulesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Retours annulés'**
  String get retoursAnnulesTitre;

  /// No description provided for @retoursAnnulesDetail.
  ///
  /// In fr, this message translates to:
  /// **'Le stock a été rétabli'**
  String get retoursAnnulesDetail;

  /// No description provided for @retoursEntite.
  ///
  /// In fr, this message translates to:
  /// **'retour'**
  String get retoursEntite;

  /// No description provided for @retoursEntitePluriel.
  ///
  /// In fr, this message translates to:
  /// **'retours'**
  String get retoursEntitePluriel;

  /// No description provided for @retoursDetailTitre.
  ///
  /// In fr, this message translates to:
  /// **'Retour {code}'**
  String retoursDetailTitre(String code);

  /// No description provided for @retoursPieceOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d\'origine'**
  String get retoursPieceOrigine;

  /// No description provided for @retoursBloqueDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulé'**
  String get retoursBloqueDejaAnnule;

  /// No description provided for @retoursAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun retour sur la période.'**
  String get retoursAucun;

  /// No description provided for @retourErreurDocumentInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d\'origine introuvable.'**
  String get retourErreurDocumentInconnu;

  /// No description provided for @retourErreurDocumentAnnule.
  ///
  /// In fr, this message translates to:
  /// **'La pièce d\'origine est annulée.'**
  String get retourErreurDocumentAnnule;

  /// No description provided for @retourErreurProduitAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'est pas dans la pièce d\'origine.'**
  String get retourErreurProduitAbsent;

  /// No description provided for @retourErreurReglement.
  ///
  /// In fr, this message translates to:
  /// **'Règlement invalide (pas d\'avoir pour le client de passage).'**
  String get retourErreurReglement;

  /// No description provided for @retourErreurStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant pour ce retour.'**
  String get retourErreurStock;

  /// No description provided for @retourErreurInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Retour introuvable.'**
  String get retourErreurInconnu;

  /// No description provided for @retourErreurDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Retour déjà annulé.'**
  String get retourErreurDejaAnnule;

  /// No description provided for @retourErreurMotif.
  ///
  /// In fr, this message translates to:
  /// **'Le motif est obligatoire.'**
  String get retourErreurMotif;

  /// No description provided for @achatErreurRetourLie.
  ///
  /// In fr, this message translates to:
  /// **'Un retour fournisseur est lié à cette entrée : annulation impossible.'**
  String get achatErreurRetourLie;

  /// No description provided for @posVentesDuJour.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du jour'**
  String get posVentesDuJour;

  /// No description provided for @posRecetteProduit.
  ///
  /// In fr, this message translates to:
  /// **'Recette produit'**
  String get posRecetteProduit;

  /// No description provided for @posMasquerProduits.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les produits'**
  String get posMasquerProduits;

  /// No description provided for @posAfficherProduits.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les produits'**
  String get posAfficherProduits;

  /// No description provided for @posParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de la caisse'**
  String get posParametres;

  /// No description provided for @posScanIndice.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code-barres ou rechercher…'**
  String get posScanIndice;

  /// No description provided for @posRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get posRecherche;

  /// No description provided for @posProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get posProduits;

  /// No description provided for @posPacks.
  ///
  /// In fr, this message translates to:
  /// **'Packs'**
  String get posPacks;

  /// No description provided for @posAffichageGrille.
  ///
  /// In fr, this message translates to:
  /// **'Affichage grille'**
  String get posAffichageGrille;

  /// No description provided for @posAffichageListe.
  ///
  /// In fr, this message translates to:
  /// **'Affichage liste'**
  String get posAffichageListe;

  /// No description provided for @posVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente {n}'**
  String posVente(int n);

  /// No description provided for @posVenteVide.
  ///
  /// In fr, this message translates to:
  /// **'Vide'**
  String get posVenteVide;

  /// No description provided for @posVenteMeta.
  ///
  /// In fr, this message translates to:
  /// **'{pieces} pcs · {montant}'**
  String posVenteMeta(String montant, String pieces);

  /// No description provided for @posPanierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get posPanierTitre;

  /// No description provided for @posNouveauProduit.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get posNouveauProduit;

  /// No description provided for @posNouveauClient.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get posNouveauClient;

  /// No description provided for @posViderPanier.
  ///
  /// In fr, this message translates to:
  /// **'Vider le panier (F10)'**
  String get posViderPanier;

  /// No description provided for @posClientLabel.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get posClientLabel;

  /// No description provided for @posModePaiement.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get posModePaiement;

  /// No description provided for @posChoisirRemise.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une remise'**
  String get posChoisirRemise;

  /// No description provided for @posAucuneRemise.
  ///
  /// In fr, this message translates to:
  /// **'Aucune remise'**
  String get posAucuneRemise;

  /// No description provided for @posPanierVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Panier vide'**
  String get posPanierVideTitre;

  /// No description provided for @posPanierVideDesc.
  ///
  /// In fr, this message translates to:
  /// **'Scannez un code-barres ou touchez un produit.'**
  String get posPanierVideDesc;

  /// No description provided for @posLigneAide.
  ///
  /// In fr, this message translates to:
  /// **'Double-clic : modifier le prix · clic sur le colis : changer le colis'**
  String get posLigneAide;

  /// No description provided for @posEnregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get posEnregistrer;

  /// No description provided for @posEncaisserBouton.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get posEncaisserBouton;

  /// No description provided for @posEncTicketTitre.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser le ticket'**
  String get posEncTicketTitre;

  /// No description provided for @posEncSaveTitre.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le ticket'**
  String get posEncSaveTitre;

  /// No description provided for @posEncTicketOk.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser et imprimer'**
  String get posEncTicketOk;

  /// No description provided for @posInfoVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get posInfoVente;

  /// No description provided for @posInfoDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get posInfoDate;

  /// No description provided for @posInfoProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get posInfoProduits;

  /// No description provided for @posInfoPieces.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get posInfoPieces;

  /// No description provided for @posInfoPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get posInfoPaiement;

  /// No description provided for @posInfoCaissier.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get posInfoCaissier;

  /// No description provided for @posToastEncaisse.
  ///
  /// In fr, this message translates to:
  /// **'{type} {code} encaissé'**
  String posToastEncaisse(String code, String type);

  /// No description provided for @posToastEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Ticket {code} enregistré'**
  String posToastEnregistre(String code);

  /// No description provided for @posToastResteCredit.
  ///
  /// In fr, this message translates to:
  /// **'Reste au crédit : {montant}'**
  String posToastResteCredit(String montant);

  /// No description provided for @posToastRendu.
  ///
  /// In fr, this message translates to:
  /// **'Total {montant} · rendu {rendu}'**
  String posToastRendu(String montant, String rendu);

  /// No description provided for @posReimprimer.
  ///
  /// In fr, this message translates to:
  /// **'Réimprimer'**
  String get posReimprimer;

  /// No description provided for @posTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get posTicket;

  /// No description provided for @posSelTitre.
  ///
  /// In fr, this message translates to:
  /// **'Quantité et colis'**
  String get posSelTitre;

  /// No description provided for @posSelTitreModif.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la quantité et le colis'**
  String get posSelTitreModif;

  /// No description provided for @posSelAuto.
  ///
  /// In fr, this message translates to:
  /// **'Ajout automatique de {detail} dans {secondes} s · touchez pour modifier'**
  String posSelAuto(String detail, String secondes);

  /// No description provided for @posSelAutoAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Ajout automatique annulé — validez avec Entrée'**
  String get posSelAutoAnnule;

  /// No description provided for @posSelParPiece.
  ///
  /// In fr, this message translates to:
  /// **'{prix} / pièce'**
  String posSelParPiece(String prix);

  /// No description provided for @posSelStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {quantite} pièces'**
  String posSelStock(String quantite);

  /// No description provided for @posSelColis.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get posSelColis;

  /// No description provided for @posSelUnite.
  ///
  /// In fr, this message translates to:
  /// **'À l\'unité'**
  String get posSelUnite;

  /// No description provided for @posSelParColis.
  ///
  /// In fr, this message translates to:
  /// **'{nom} ({quantite} pièces)'**
  String posSelParColis(String nom, String quantite);

  /// No description provided for @posSelQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get posSelQuantite;

  /// No description provided for @posSelPieces.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get posSelPieces;

  /// No description provided for @posSelStockInsuffisant.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant ({quantite} pièces)'**
  String posSelStockInsuffisant(String quantite);

  /// No description provided for @posSelAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter · {montant}'**
  String posSelAjouter(String montant);

  /// No description provided for @posSelModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier · {montant}'**
  String posSelModifier(String montant);

  /// No description provided for @posPrixTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le prix du produit'**
  String get posPrixTitre;

  /// No description provided for @posPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get posPrixAchat;

  /// No description provided for @posPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get posPrixVente;

  /// No description provided for @posPrixMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get posPrixMotDePasse;

  /// No description provided for @posPrixMotDePasseIndice.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get posPrixMotDePasseIndice;

  /// No description provided for @posPrixPortee.
  ///
  /// In fr, this message translates to:
  /// **'Portée'**
  String get posPrixPortee;

  /// No description provided for @posPrixPorteeTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ce ticket uniquement'**
  String get posPrixPorteeTicket;

  /// No description provided for @posPrixPorteeTicketDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le prix catalogue ne change pas'**
  String get posPrixPorteeTicketDesc;

  /// No description provided for @posPrixPorteeProduit.
  ///
  /// In fr, this message translates to:
  /// **'Tout le produit'**
  String get posPrixPorteeProduit;

  /// No description provided for @posPrixPorteeProduitDesc.
  ///
  /// In fr, this message translates to:
  /// **'Met à jour le prix de vente'**
  String get posPrixPorteeProduitDesc;

  /// No description provided for @posPrixInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Prix invalide'**
  String get posPrixInvalide;

  /// No description provided for @posPrixMdpRequis.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get posPrixMdpRequis;

  /// No description provided for @posPrixMdpIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get posPrixMdpIncorrect;

  /// No description provided for @posPrixSousAchat.
  ///
  /// In fr, this message translates to:
  /// **'En dessous du prix d\'achat'**
  String get posPrixSousAchat;

  /// No description provided for @posPrixMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge : {montant}'**
  String posPrixMarge(String montant);

  /// No description provided for @posPrixSousAchatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Vendre sous le prix d\'achat ?'**
  String get posPrixSousAchatTitre;

  /// No description provided for @posPrixSousAchatMsg.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente {vente} inférieur au prix d\'achat {achat}.'**
  String posPrixSousAchatMsg(String achat, String vente);

  /// No description provided for @posPrixSousAchatOk.
  ///
  /// In fr, this message translates to:
  /// **'Vendre quand même'**
  String get posPrixSousAchatOk;

  /// No description provided for @posPrixModifie.
  ///
  /// In fr, this message translates to:
  /// **'Prix modifié'**
  String get posPrixModifie;

  /// No description provided for @posPrixModifieTicket.
  ///
  /// In fr, this message translates to:
  /// **'{nom} · ce ticket uniquement'**
  String posPrixModifieTicket(String nom);

  /// No description provided for @posPrixModifieProduit.
  ///
  /// In fr, this message translates to:
  /// **'{nom} · prix catalogue mis à jour'**
  String posPrixModifieProduit(String nom);

  /// No description provided for @posRechTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get posRechTitre;

  /// No description provided for @posRechAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get posRechAjouter;

  /// No description provided for @posRechIndice.
  ///
  /// In fr, this message translates to:
  /// **'Nom, code ou code-barres…'**
  String get posRechIndice;

  /// No description provided for @posRechAjoutes.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) ajouté(s)'**
  String posRechAjoutes(int n);

  /// No description provided for @posIntrouvableTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produit introuvable'**
  String get posIntrouvableTitre;

  /// No description provided for @posIntrouvableCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer le produit'**
  String get posIntrouvableCreer;

  /// No description provided for @posFermeeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session ouverte'**
  String get posFermeeTitre;

  /// No description provided for @posFermeeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez une session pour « {caisse} » avant de vendre.'**
  String posFermeeDesc(String caisse);

  /// No description provided for @posOuvrirCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la caisse'**
  String get posOuvrirCaisse;

  /// No description provided for @posOuvertureTitre.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir {caisse}'**
  String posOuvertureTitre(String caisse);

  /// No description provided for @posOuvertureSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde d\'ouverture'**
  String get posOuvertureSolde;

  /// No description provided for @posOuverturePar.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte par'**
  String get posOuverturePar;

  /// No description provided for @posOuvertureOk.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la session'**
  String get posOuvertureOk;

  /// No description provided for @posCaisseOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Caisse ouverte'**
  String get posCaisseOuverte;

  /// No description provided for @posCaisseOuverteDesc.
  ///
  /// In fr, this message translates to:
  /// **'Fond de caisse : {montant}'**
  String posCaisseOuverteDesc(String montant);

  /// No description provided for @posClotureTitre.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer {caisse}'**
  String posClotureTitre(String caisse);

  /// No description provided for @posClotureFond.
  ///
  /// In fr, this message translates to:
  /// **'Fond de départ'**
  String get posClotureFond;

  /// No description provided for @posClotureTheorique.
  ///
  /// In fr, this message translates to:
  /// **'Solde théorique'**
  String get posClotureTheorique;

  /// No description provided for @posClotureReel.
  ///
  /// In fr, this message translates to:
  /// **'Solde réel compté'**
  String get posClotureReel;

  /// No description provided for @posClotureEcart.
  ///
  /// In fr, this message translates to:
  /// **'Écart de caisse · {etat}'**
  String posClotureEcart(String etat);

  /// No description provided for @posClotureJuste.
  ///
  /// In fr, this message translates to:
  /// **'Caisse juste'**
  String get posClotureJuste;

  /// No description provided for @posClotureExcedent.
  ///
  /// In fr, this message translates to:
  /// **'Excédent'**
  String get posClotureExcedent;

  /// No description provided for @posClotureManquant.
  ///
  /// In fr, this message translates to:
  /// **'Manquant'**
  String get posClotureManquant;

  /// No description provided for @posClotureOk.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer la session'**
  String get posClotureOk;

  /// No description provided for @posClotureFaite.
  ///
  /// In fr, this message translates to:
  /// **'Session clôturée'**
  String get posClotureFaite;

  /// No description provided for @posClotureEcartToast.
  ///
  /// In fr, this message translates to:
  /// **'Écart : {montant}'**
  String posClotureEcartToast(String montant);

  /// No description provided for @posMvtTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement manuel'**
  String get posMvtTitre;

  /// No description provided for @posMvtType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get posMvtType;

  /// No description provided for @posMvtEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée manuelle'**
  String get posMvtEntree;

  /// No description provided for @posMvtSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie manuelle'**
  String get posMvtSortie;

  /// No description provided for @posMvtMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get posMvtMotif;

  /// No description provided for @posMvtFait.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement enregistré'**
  String get posMvtFait;

  /// No description provided for @posMvtFaitDesc.
  ///
  /// In fr, this message translates to:
  /// **'{sens} de {montant}'**
  String posMvtFaitDesc(String montant, String sens);

  /// No description provided for @posVdjTitre.
  ///
  /// In fr, this message translates to:
  /// **'Recette caisse — {caisse}'**
  String posVdjTitre(String caisse);

  /// No description provided for @posVdjIndice.
  ///
  /// In fr, this message translates to:
  /// **'N° panier ou client…'**
  String get posVdjIndice;

  /// No description provided for @posVdjNombre.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de ventes'**
  String get posVdjNombre;

  /// No description provided for @posVdjTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total ventes'**
  String get posVdjTotal;

  /// No description provided for @posVdjEncaisse.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get posVdjEncaisse;

  /// No description provided for @posVdjReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste (crédit)'**
  String get posVdjReste;

  /// No description provided for @posVdjAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente trouvée'**
  String get posVdjAucune;

  /// No description provided for @posVdjHeure.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get posVdjHeure;

  /// No description provided for @posRecTitre.
  ///
  /// In fr, this message translates to:
  /// **'Recette par produit — {caisse}'**
  String posRecTitre(String caisse);

  /// No description provided for @posRecIndice.
  ///
  /// In fr, this message translates to:
  /// **'Produit, code ou panier…'**
  String get posRecIndice;

  /// No description provided for @posRecLignes.
  ///
  /// In fr, this message translates to:
  /// **'Lignes vendues'**
  String get posRecLignes;

  /// No description provided for @posRecQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get posRecQuantite;

  /// No description provided for @posRecAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ligne vendue'**
  String get posRecAucune;

  /// No description provided for @posParamMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get posParamMagasin;

  /// No description provided for @posParamFait.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés'**
  String get posParamFait;

  /// No description provided for @posFermerVenteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la vente {n} ?'**
  String posFermerVenteTitre(int n);

  /// No description provided for @posFermerVenteMsg.
  ///
  /// In fr, this message translates to:
  /// **'Le panier ({lignes} ligne(s)) sera abandonné. Encaissez-le ou enregistrez-le d\'abord pour le garder.'**
  String posFermerVenteMsg(String lignes);

  /// No description provided for @posFermerVenteOk.
  ///
  /// In fr, this message translates to:
  /// **'Fermer sans enregistrer'**
  String get posFermerVenteOk;

  /// No description provided for @produitErreurUtilise.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit est utilisé (ventes, achats ou stock) : il ne peut pas être supprimé.'**
  String get produitErreurUtilise;

  /// No description provided for @catalogueErreurNomPris.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom est déjà utilisé.'**
  String get catalogueErreurNomPris;

  /// No description provided for @prdOngletSousCategories.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégories'**
  String get prdOngletSousCategories;

  /// No description provided for @prdAchat.
  ///
  /// In fr, this message translates to:
  /// **'Achat'**
  String get prdAchat;

  /// No description provided for @prdVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente HT'**
  String get prdVente;

  /// No description provided for @prdMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get prdMarge;

  /// No description provided for @prdMarque.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get prdMarque;

  /// No description provided for @prdMarqueIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Elio'**
  String get prdMarqueIndice;

  /// No description provided for @prdDescriptionChamp.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get prdDescriptionChamp;

  /// No description provided for @prdTaille.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get prdTaille;

  /// No description provided for @prdCouleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get prdCouleur;

  /// No description provided for @prdRemise.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get prdRemise;

  /// No description provided for @prdService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get prdService;

  /// No description provided for @prdEmballageN.
  ///
  /// In fr, this message translates to:
  /// **'Emballage {n}'**
  String prdEmballageN(int n);

  /// No description provided for @prdPrixEmballageN.
  ///
  /// In fr, this message translates to:
  /// **'Prix emballage {n}'**
  String prdPrixEmballageN(int n);

  /// No description provided for @prdEmballagePieces.
  ///
  /// In fr, this message translates to:
  /// **'{n} pcs'**
  String prdEmballagePieces(int n);

  /// No description provided for @prdNumeroSerie.
  ///
  /// In fr, this message translates to:
  /// **'N° série'**
  String get prdNumeroSerie;

  /// No description provided for @prdMultiCodes.
  ///
  /// In fr, this message translates to:
  /// **'Multi code-barres'**
  String get prdMultiCodes;

  /// No description provided for @prdPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get prdPhotos;

  /// No description provided for @prdTva.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get prdTva;

  /// No description provided for @prdDateExpiration.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'expiration'**
  String get prdDateExpiration;

  /// No description provided for @prdEntiteProduits.
  ///
  /// In fr, this message translates to:
  /// **'produits'**
  String get prdEntiteProduits;

  /// No description provided for @prdEntiteProduit.
  ///
  /// In fr, this message translates to:
  /// **'produit'**
  String get prdEntiteProduit;

  /// No description provided for @prdEntiteCategories.
  ///
  /// In fr, this message translates to:
  /// **'catégories'**
  String get prdEntiteCategories;

  /// No description provided for @prdEntiteCategorie.
  ///
  /// In fr, this message translates to:
  /// **'catégorie'**
  String get prdEntiteCategorie;

  /// No description provided for @prdEntiteSousCategories.
  ///
  /// In fr, this message translates to:
  /// **'sous-catégories'**
  String get prdEntiteSousCategories;

  /// No description provided for @prdEntiteSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'sous-catégorie'**
  String get prdEntiteSousCategorie;

  /// No description provided for @prdEntiteRemises.
  ///
  /// In fr, this message translates to:
  /// **'remises'**
  String get prdEntiteRemises;

  /// No description provided for @prdEntiteRemise.
  ///
  /// In fr, this message translates to:
  /// **'remise'**
  String get prdEntiteRemise;

  /// No description provided for @prdEntitePacks.
  ///
  /// In fr, this message translates to:
  /// **'packs'**
  String get prdEntitePacks;

  /// No description provided for @prdEntitePack.
  ///
  /// In fr, this message translates to:
  /// **'pack'**
  String get prdEntitePack;

  /// No description provided for @prdKpiActifs.
  ///
  /// In fr, this message translates to:
  /// **'Produits actifs'**
  String get prdKpiActifs;

  /// No description provided for @prdKpiValeurStock.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock'**
  String get prdKpiValeurStock;

  /// No description provided for @prdKpiSousSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Sous le seuil'**
  String get prdKpiSousSeuil;

  /// No description provided for @prdKpiRupture.
  ///
  /// In fr, this message translates to:
  /// **'En rupture'**
  String get prdKpiRupture;

  /// No description provided for @prdToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get prdToutes;

  /// No description provided for @prdDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get prdDisponible;

  /// No description provided for @prdRechercheProduits.
  ///
  /// In fr, this message translates to:
  /// **'Nom, code ou code-barres…'**
  String get prdRechercheProduits;

  /// No description provided for @prdRechercheCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une catégorie…'**
  String get prdRechercheCategorie;

  /// No description provided for @prdRechercheSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une sous-catégorie…'**
  String get prdRechercheSousCategorie;

  /// No description provided for @prdRechercheRemise.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une remise…'**
  String get prdRechercheRemise;

  /// No description provided for @prdRecherchePack.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un pack…'**
  String get prdRecherchePack;

  /// No description provided for @prdEtiquette.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get prdEtiquette;

  /// No description provided for @prdEtiquettes.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get prdEtiquettes;

  /// No description provided for @prdAffecter.
  ///
  /// In fr, this message translates to:
  /// **'Affecter'**
  String get prdAffecter;

  /// No description provided for @prdImporter.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get prdImporter;

  /// No description provided for @prdAchatMontant.
  ///
  /// In fr, this message translates to:
  /// **'Achat {montant}'**
  String prdAchatMontant(String montant);

  /// No description provided for @prdStockN.
  ///
  /// In fr, this message translates to:
  /// **'Stock {quantite}'**
  String prdStockN(String quantite);

  /// No description provided for @prdMargeN.
  ///
  /// In fr, this message translates to:
  /// **'Marge {n} %'**
  String prdMargeN(int n);

  /// No description provided for @prdStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get prdStatut;

  /// No description provided for @prdTypeTaux.
  ///
  /// In fr, this message translates to:
  /// **'Type de taux'**
  String get prdTypeTaux;

  /// No description provided for @prdSeuilMontant.
  ///
  /// In fr, this message translates to:
  /// **'Seuil du panier'**
  String get prdSeuilMontant;

  /// No description provided for @prdPack.
  ///
  /// In fr, this message translates to:
  /// **'Pack'**
  String get prdPack;

  /// No description provided for @prdComposants.
  ///
  /// In fr, this message translates to:
  /// **'Composants'**
  String get prdComposants;

  /// No description provided for @prdComposant.
  ///
  /// In fr, this message translates to:
  /// **'Composant'**
  String get prdComposant;

  /// No description provided for @prdValeurSeparee.
  ///
  /// In fr, this message translates to:
  /// **'Valeur séparée'**
  String get prdValeurSeparee;

  /// No description provided for @prdPrixPack.
  ///
  /// In fr, this message translates to:
  /// **'Prix du pack'**
  String get prdPrixPack;

  /// No description provided for @prdEconomie.
  ///
  /// In fr, this message translates to:
  /// **'Économie'**
  String get prdEconomie;

  /// No description provided for @prdDisponibles.
  ///
  /// In fr, this message translates to:
  /// **'Disponibles'**
  String get prdDisponibles;

  /// No description provided for @prdModeRapide.
  ///
  /// In fr, this message translates to:
  /// **'Rapide'**
  String get prdModeRapide;

  /// No description provided for @prdModeDetaille.
  ///
  /// In fr, this message translates to:
  /// **'Détaillé · 3 étapes'**
  String get prdModeDetaille;

  /// No description provided for @prdModeIa.
  ///
  /// In fr, this message translates to:
  /// **'IA'**
  String get prdModeIa;

  /// No description provided for @prdEtape1.
  ///
  /// In fr, this message translates to:
  /// **'Produit et prix'**
  String get prdEtape1;

  /// No description provided for @prdEtape2.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get prdEtape2;

  /// No description provided for @prdEtape3.
  ///
  /// In fr, this message translates to:
  /// **'Variantes'**
  String get prdEtape3;

  /// No description provided for @prdEtapeObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Étape {n} / 3 · * obligatoire'**
  String prdEtapeObligatoire(int n);

  /// No description provided for @prdObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'* obligatoire'**
  String get prdObligatoire;

  /// No description provided for @prdEnregistrerNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et nouveau'**
  String get prdEnregistrerNouveau;

  /// No description provided for @prdSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get prdSuivant;

  /// No description provided for @prdPrincipale.
  ///
  /// In fr, this message translates to:
  /// **'Principale'**
  String get prdPrincipale;

  /// No description provided for @prdPhotosFormat.
  ///
  /// In fr, this message translates to:
  /// **'JPG ou PNG · 4 max'**
  String get prdPhotosFormat;

  /// No description provided for @prdPhotosFin.
  ///
  /// In fr, this message translates to:
  /// **'la première est la photo principale'**
  String get prdPhotosFin;

  /// No description provided for @prdIdentification.
  ///
  /// In fr, this message translates to:
  /// **'Identification'**
  String get prdIdentification;

  /// No description provided for @prdCodeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Attribué à l\'enregistrement'**
  String get prdCodeAuto;

  /// No description provided for @prdDesignationIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Huile Elio 1 L'**
  String get prdDesignationIndice;

  /// No description provided for @prdEanInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Clé de contrôle EAN-13 invalide'**
  String get prdEanInvalide;

  /// No description provided for @prdScannerOuSaisir.
  ///
  /// In fr, this message translates to:
  /// **'Scanner ou saisir'**
  String get prdScannerOuSaisir;

  /// No description provided for @prdFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get prdFournisseur;

  /// No description provided for @prdGenererCodeBarres.
  ///
  /// In fr, this message translates to:
  /// **'Générer un code-barres CDZ'**
  String get prdGenererCodeBarres;

  /// No description provided for @prdPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get prdPrix;

  /// No description provided for @prdSousAchat.
  ///
  /// In fr, this message translates to:
  /// **'Inférieur au prix d\'achat'**
  String get prdSousAchat;

  /// No description provided for @prdMargeUnitaire.
  ///
  /// In fr, this message translates to:
  /// **'Marge unitaire : {montant}'**
  String prdMargeUnitaire(String montant);

  /// No description provided for @prdStockActuel.
  ///
  /// In fr, this message translates to:
  /// **'Stock actuel'**
  String get prdStockActuel;

  /// No description provided for @prdStockInitial.
  ///
  /// In fr, this message translates to:
  /// **'Stock initial'**
  String get prdStockInitial;

  /// No description provided for @prdStockViaEntree.
  ///
  /// In fr, this message translates to:
  /// **'{quantite} entreront en stock avec l\'entrée du bon.'**
  String prdStockViaEntree(String quantite);

  /// No description provided for @prdSeuilAlerte.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte'**
  String get prdSeuilAlerte;

  /// No description provided for @prdEmballages.
  ///
  /// In fr, this message translates to:
  /// **'Emballages'**
  String get prdEmballages;

  /// No description provided for @prdBoite.
  ///
  /// In fr, this message translates to:
  /// **'Boîte'**
  String get prdBoite;

  /// No description provided for @prdCarton.
  ///
  /// In fr, this message translates to:
  /// **'Carton'**
  String get prdCarton;

  /// No description provided for @prdPcs.
  ///
  /// In fr, this message translates to:
  /// **'pcs'**
  String get prdPcs;

  /// No description provided for @prdVariantes.
  ///
  /// In fr, this message translates to:
  /// **'Variantes'**
  String get prdVariantes;

  /// No description provided for @prdTypeTaille.
  ///
  /// In fr, this message translates to:
  /// **'Type de taille'**
  String get prdTypeTaille;

  /// No description provided for @prdTailles.
  ///
  /// In fr, this message translates to:
  /// **'Tailles'**
  String get prdTailles;

  /// No description provided for @prdTaillesN.
  ///
  /// In fr, this message translates to:
  /// **'{n} taille(s) sélectionnée(s)'**
  String prdTaillesN(int n);

  /// No description provided for @prdCouleurs.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs'**
  String get prdCouleurs;

  /// No description provided for @prdOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options'**
  String get prdOptions;

  /// No description provided for @prdCodesMultiples.
  ///
  /// In fr, this message translates to:
  /// **'Codes multiples'**
  String get prdCodesMultiples;

  /// No description provided for @prdAjouterCode.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un code'**
  String get prdAjouterCode;

  /// No description provided for @prdSuiviSerie.
  ///
  /// In fr, this message translates to:
  /// **'Suivi par n° de série'**
  String get prdSuiviSerie;

  /// No description provided for @prdServiceSansStock.
  ///
  /// In fr, this message translates to:
  /// **'Service (sans stock)'**
  String get prdServiceSansStock;

  /// No description provided for @prdNoteInterne.
  ///
  /// In fr, this message translates to:
  /// **'Note interne'**
  String get prdNoteInterne;

  /// No description provided for @prdToastEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Produit enregistré'**
  String get prdToastEnregistre;

  /// No description provided for @prdToastModifie.
  ///
  /// In fr, this message translates to:
  /// **'Produit modifié'**
  String get prdToastModifie;

  /// No description provided for @prdToastAjoute.
  ///
  /// In fr, this message translates to:
  /// **'{code} · ajouté au catalogue'**
  String prdToastAjoute(String code);

  /// No description provided for @prdModifierCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get prdModifierCategorie;

  /// No description provided for @prdModifierSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la sous-catégorie'**
  String get prdModifierSousCategorie;

  /// No description provided for @prdCategorieParente.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie parente'**
  String get prdCategorieParente;

  /// No description provided for @prdCategorieExiste.
  ///
  /// In fr, this message translates to:
  /// **'Cette catégorie existe déjà'**
  String get prdCategorieExiste;

  /// No description provided for @prdSousCategorieExiste.
  ///
  /// In fr, this message translates to:
  /// **'Cette sous-catégorie existe déjà'**
  String get prdSousCategorieExiste;

  /// No description provided for @prdCategorieIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Épicerie'**
  String get prdCategorieIndice;

  /// No description provided for @prdSousCategorieIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Huiles'**
  String get prdSousCategorieIndice;

  /// No description provided for @prdVisibleCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Visible en caisse'**
  String get prdVisibleCaisse;

  /// No description provided for @prdToastCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie enregistrée'**
  String get prdToastCategorie;

  /// No description provided for @prdToastSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégorie enregistrée'**
  String get prdToastSousCategorie;

  /// No description provided for @prdInformations.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get prdInformations;

  /// No description provided for @prdNProduits.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s)'**
  String prdNProduits(int n);

  /// No description provided for @prdNComposants.
  ///
  /// In fr, this message translates to:
  /// **'{n} composant(s)'**
  String prdNComposants(int n);

  /// No description provided for @prdPorteeProduit.
  ///
  /// In fr, this message translates to:
  /// **'Par produit'**
  String get prdPorteeProduit;

  /// No description provided for @prdPorteeMontant.
  ///
  /// In fr, this message translates to:
  /// **'Par montant (panier)'**
  String get prdPorteeMontant;

  /// No description provided for @prdProgrammee.
  ///
  /// In fr, this message translates to:
  /// **'Programmée'**
  String get prdProgrammee;

  /// No description provided for @prdModifierRemise.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la remise'**
  String get prdModifierRemise;

  /// No description provided for @prdProduitsConcernes.
  ///
  /// In fr, this message translates to:
  /// **'Produits concernés'**
  String get prdProduitsConcernes;

  /// No description provided for @prdRemiseAccordee.
  ///
  /// In fr, this message translates to:
  /// **'Remise accordée'**
  String get prdRemiseAccordee;

  /// No description provided for @prdPrixNormal.
  ///
  /// In fr, this message translates to:
  /// **'Prix normal'**
  String get prdPrixNormal;

  /// No description provided for @prdPrixRemise.
  ///
  /// In fr, this message translates to:
  /// **'Prix remisé'**
  String get prdPrixRemise;

  /// No description provided for @prdRemiseNomIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Fin de série'**
  String get prdRemiseNomIndice;

  /// No description provided for @prdPourcentageAide.
  ///
  /// In fr, this message translates to:
  /// **'Ex. −10 % sur le prix'**
  String get prdPourcentageAide;

  /// No description provided for @prdMontantFixe.
  ///
  /// In fr, this message translates to:
  /// **'Montant fixe'**
  String get prdMontantFixe;

  /// No description provided for @prdMontantFixeAide.
  ///
  /// In fr, this message translates to:
  /// **'Ex. −50 {devise} par article'**
  String prdMontantFixeAide(String devise);

  /// No description provided for @prdSeuilAide.
  ///
  /// In fr, this message translates to:
  /// **'La remise s\'active quand le sous-total atteint ce montant'**
  String get prdSeuilAide;

  /// No description provided for @prdToastRemise.
  ///
  /// In fr, this message translates to:
  /// **'Remise enregistrée'**
  String get prdToastRemise;

  /// No description provided for @prdToastRemiseDesc.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée en caisse pendant sa période'**
  String get prdToastRemiseDesc;

  /// No description provided for @prdVentesRemisees.
  ///
  /// In fr, this message translates to:
  /// **'Ventes remisées'**
  String get prdVentesRemisees;

  /// No description provided for @prdModifierPack.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le pack'**
  String get prdModifierPack;

  /// No description provided for @prdEnregistrerPack.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le pack'**
  String get prdEnregistrerPack;

  /// No description provided for @prdComposantsPack.
  ///
  /// In fr, this message translates to:
  /// **'Composants du pack'**
  String get prdComposantsPack;

  /// No description provided for @prdQteParPack.
  ///
  /// In fr, this message translates to:
  /// **'Qté / pack'**
  String get prdQteParPack;

  /// No description provided for @prdPrixUnitaire.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire'**
  String get prdPrixUnitaire;

  /// No description provided for @prdOptionnel.
  ///
  /// In fr, this message translates to:
  /// **'Optionnel'**
  String get prdOptionnel;

  /// No description provided for @prdNomPack.
  ///
  /// In fr, this message translates to:
  /// **'Nom du pack'**
  String get prdNomPack;

  /// No description provided for @prdPackNomIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Pack petit-déjeuner'**
  String get prdPackNomIndice;

  /// No description provided for @prdPacksPossibles.
  ///
  /// In fr, this message translates to:
  /// **'Packs possibles'**
  String get prdPacksPossibles;

  /// No description provided for @prdPacksPossiblesAide.
  ///
  /// In fr, this message translates to:
  /// **'Selon le stock du composant le plus limitant'**
  String get prdPacksPossiblesAide;

  /// No description provided for @prdEconomieClient.
  ///
  /// In fr, this message translates to:
  /// **'Économie pour le client'**
  String get prdEconomieClient;

  /// No description provided for @prdPackPlusCher.
  ///
  /// In fr, this message translates to:
  /// **'Le pack coûte plus cher que ses composants'**
  String get prdPackPlusCher;

  /// No description provided for @prdValeurSepareeMontant.
  ///
  /// In fr, this message translates to:
  /// **'valeur séparée {montant}'**
  String prdValeurSepareeMontant(String montant);

  /// No description provided for @prdToastPack.
  ///
  /// In fr, this message translates to:
  /// **'Pack enregistré'**
  String get prdToastPack;

  /// No description provided for @prdValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get prdValeur;

  /// No description provided for @prdStockTotal.
  ///
  /// In fr, this message translates to:
  /// **'Stock total'**
  String get prdStockTotal;

  /// No description provided for @prdPrixMoyenAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix moyen d\'achat'**
  String get prdPrixMoyenAchat;

  /// No description provided for @prdVendus30.
  ///
  /// In fr, this message translates to:
  /// **'Vendus (30 j)'**
  String get prdVendus30;

  /// No description provided for @prdStockParMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Stock par magasin'**
  String get prdStockParMagasin;

  /// No description provided for @prdDerniersMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Derniers mouvements'**
  String get prdDerniersMouvements;

  /// No description provided for @prdReference.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get prdReference;

  /// No description provided for @prdCodeBarreTitre.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres & étiquettes'**
  String get prdCodeBarreTitre;

  /// No description provided for @prdEanAide.
  ///
  /// In fr, this message translates to:
  /// **'Standard commerce — préfixe 613 (Algérie)'**
  String get prdEanAide;

  /// No description provided for @prdCodeInterne.
  ///
  /// In fr, this message translates to:
  /// **'Code interne'**
  String get prdCodeInterne;

  /// No description provided for @prdCodeInterneAide.
  ///
  /// In fr, this message translates to:
  /// **'Pour les produits sans code fabricant'**
  String get prdCodeInterneAide;

  /// No description provided for @prdFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get prdFormat;

  /// No description provided for @prdFormatA4.
  ///
  /// In fr, this message translates to:
  /// **'A4 · 3 × 8 (38 × 21 mm)'**
  String get prdFormatA4;

  /// No description provided for @prdFormatRouleau40.
  ///
  /// In fr, this message translates to:
  /// **'Rouleau 40 × 30 mm'**
  String get prdFormatRouleau40;

  /// No description provided for @prdFormatRouleau58.
  ///
  /// In fr, this message translates to:
  /// **'Rouleau 58 mm'**
  String get prdFormatRouleau58;

  /// No description provided for @prdImprimerEtiquettes.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer {n} étiquette(s)'**
  String prdImprimerEtiquettes(int n);

  /// No description provided for @prdAffecterN.
  ///
  /// In fr, this message translates to:
  /// **'Affecter {n} produit(s)'**
  String prdAffecterN(int n);

  /// No description provided for @prdRemplacerAffectation.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer l\'affectation existante'**
  String get prdRemplacerAffectation;

  /// No description provided for @prdRemplacerPackAide.
  ///
  /// In fr, this message translates to:
  /// **'Sinon le produit est ajouté au pack avec la quantité 1'**
  String get prdRemplacerPackAide;

  /// No description provided for @prdRemplacerCategorieAide.
  ///
  /// In fr, this message translates to:
  /// **'Sinon seuls les produits sans catégorie sont modifiés'**
  String get prdRemplacerCategorieAide;

  /// No description provided for @prdRemplacerRemiseAide.
  ///
  /// In fr, this message translates to:
  /// **'Sinon seuls les produits sans remise sont modifiés'**
  String get prdRemplacerRemiseAide;

  /// No description provided for @prdToastAffectation.
  ///
  /// In fr, this message translates to:
  /// **'Affectation enregistrée'**
  String get prdToastAffectation;

  /// No description provided for @prdToastAffectationDesc.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) · {nom}'**
  String prdToastAffectationDesc(int n, String nom);

  /// No description provided for @prdSuppressionBloquee.
  ///
  /// In fr, this message translates to:
  /// **'Stock ou mouvements liés — désactivez-le plutôt'**
  String get prdSuppressionBloquee;

  /// No description provided for @prdToastSupprimes.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) supprimé(s)'**
  String prdToastSupprimes(int n);

  /// No description provided for @prdToastRefuses.
  ///
  /// In fr, this message translates to:
  /// **'{n} refusé(s) : mouvements liés'**
  String prdToastRefuses(int n);

  /// No description provided for @prdImportFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get prdImportFichier;

  /// No description provided for @prdImportColonnes.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes'**
  String get prdImportColonnes;

  /// No description provided for @prdImportInfos.
  ///
  /// In fr, this message translates to:
  /// **'{n} colonne(s) · {total} Ko'**
  String prdImportInfos(int n, int total);

  /// No description provided for @prdChangerFichier.
  ///
  /// In fr, this message translates to:
  /// **'Changer de fichier'**
  String get prdChangerFichier;

  /// No description provided for @prdTelechargerModele.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le modèle'**
  String get prdTelechargerModele;

  /// No description provided for @prdColonneN.
  ///
  /// In fr, this message translates to:
  /// **'Colonne {lettre} · {nom}'**
  String prdColonneN(String lettre, String nom);

  /// No description provided for @prdIgnorer.
  ///
  /// In fr, this message translates to:
  /// **'— Ignorer —'**
  String get prdIgnorer;

  /// No description provided for @prdImportDesignationRequise.
  ///
  /// In fr, this message translates to:
  /// **'Associez une colonne à la désignation.'**
  String get prdImportDesignationRequise;

  /// No description provided for @prdGenere.
  ///
  /// In fr, this message translates to:
  /// **'— généré —'**
  String get prdGenere;

  /// No description provided for @prdControle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle'**
  String get prdControle;

  /// No description provided for @prdImporterN.
  ///
  /// In fr, this message translates to:
  /// **'Importer {n} produit(s)'**
  String prdImporterN(int n);

  /// No description provided for @prdImportTermine.
  ///
  /// In fr, this message translates to:
  /// **'Import terminé'**
  String get prdImportTermine;

  /// No description provided for @stkACommander.
  ///
  /// In fr, this message translates to:
  /// **'À commander'**
  String get stkACommander;

  /// No description provided for @stkAReapprovisionner.
  ///
  /// In fr, this message translates to:
  /// **'À réapprovisionner'**
  String get stkAReapprovisionner;

  /// No description provided for @stkAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get stkAdresse;

  /// No description provided for @stkArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get stkArticles;

  /// No description provided for @stkAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get stkAucun;

  /// No description provided for @stkAucunChangement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement'**
  String get stkAucunChangement;

  /// No description provided for @stkAucunExpire.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit expiré ou proche de l\'expiration.'**
  String get stkAucunExpire;

  /// No description provided for @stkAucunTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Aucun transfert sur la période.'**
  String get stkAucunTransfert;

  /// No description provided for @stkAucuneListe.
  ///
  /// In fr, this message translates to:
  /// **'Aucune liste de besoins sur la période.'**
  String get stkAucuneListe;

  /// No description provided for @stkAucuneRupture.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit sous le seuil.'**
  String get stkAucuneRupture;

  /// No description provided for @stkAucuneSortie.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sortie sur la période.'**
  String get stkAucuneSortie;

  /// No description provided for @stkAudit.
  ///
  /// In fr, this message translates to:
  /// **'Audit'**
  String get stkAudit;

  /// No description provided for @stkBloqueBesoinRecu.
  ///
  /// In fr, this message translates to:
  /// **'Déjà reçue en entrée'**
  String get stkBloqueBesoinRecu;

  /// No description provided for @stkBloqueDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulé'**
  String get stkBloqueDejaAnnule;

  /// No description provided for @stkBloqueDejaAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulée'**
  String get stkBloqueDejaAnnulee;

  /// No description provided for @stkBloqueDejaInactif.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inactif'**
  String get stkBloqueDejaInactif;

  /// No description provided for @stkBloqueMagasinPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Magasin principal d\'un utilisateur'**
  String get stkBloqueMagasinPrincipal;

  /// No description provided for @stkBloqueStockNonNul.
  ///
  /// In fr, this message translates to:
  /// **'Stock non nul — transférez-le d\'abord'**
  String get stkBloqueStockNonNul;

  /// No description provided for @stkCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Caisses'**
  String get stkCaisses;

  /// No description provided for @stkChoisirFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fournisseur'**
  String get stkChoisirFournisseur;

  /// No description provided for @stkCreerListe.
  ///
  /// In fr, this message translates to:
  /// **'Créer une liste de besoins'**
  String get stkCreerListe;

  /// No description provided for @stkDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Depuis'**
  String get stkDepuis;

  /// No description provided for @stkDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get stkDesactiver;

  /// No description provided for @stkDispoSource.
  ///
  /// In fr, this message translates to:
  /// **'Qté (Depuis)'**
  String get stkDispoSource;

  /// No description provided for @stkDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Disponible : {quantite}'**
  String stkDisponible(String quantite);

  /// No description provided for @stkDisponibleEtat.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get stkDisponibleEtat;

  /// No description provided for @stkDistribuer.
  ///
  /// In fr, this message translates to:
  /// **'Distribuer'**
  String get stkDistribuer;

  /// No description provided for @stkDistribuerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Distribuer le stock'**
  String get stkDistribuerTitre;

  /// No description provided for @stkEnStock.
  ///
  /// In fr, this message translates to:
  /// **'en stock'**
  String get stkEnStock;

  /// No description provided for @stkEnregistrerListe.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la liste'**
  String get stkEnregistrerListe;

  /// No description provided for @stkEntiteListe.
  ///
  /// In fr, this message translates to:
  /// **'liste'**
  String get stkEntiteListe;

  /// No description provided for @stkEntiteListes.
  ///
  /// In fr, this message translates to:
  /// **'listes'**
  String get stkEntiteListes;

  /// No description provided for @stkEntiteMagasin.
  ///
  /// In fr, this message translates to:
  /// **'magasin'**
  String get stkEntiteMagasin;

  /// No description provided for @stkEntiteMagasins.
  ///
  /// In fr, this message translates to:
  /// **'magasins'**
  String get stkEntiteMagasins;

  /// No description provided for @stkEntiteMouvements.
  ///
  /// In fr, this message translates to:
  /// **'mouvements'**
  String get stkEntiteMouvements;

  /// No description provided for @stkEntiteSortie.
  ///
  /// In fr, this message translates to:
  /// **'sortie'**
  String get stkEntiteSortie;

  /// No description provided for @stkEntiteSorties.
  ///
  /// In fr, this message translates to:
  /// **'sorties'**
  String get stkEntiteSorties;

  /// No description provided for @stkEntiteTransfert.
  ///
  /// In fr, this message translates to:
  /// **'transfert'**
  String get stkEntiteTransfert;

  /// No description provided for @stkEntiteTransferts.
  ///
  /// In fr, this message translates to:
  /// **'transferts'**
  String get stkEntiteTransferts;

  /// No description provided for @stkErreurDocumentInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Document introuvable.'**
  String get stkErreurDocumentInconnu;

  /// No description provided for @stkErreurFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un fournisseur.'**
  String get stkErreurFournisseur;

  /// No description provided for @stkErreurMotifObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Le motif est obligatoire.'**
  String get stkErreurMotifObligatoire;

  /// No description provided for @stkErreurNomPris.
  ///
  /// In fr, this message translates to:
  /// **'Un magasin porte déjà ce nom.'**
  String get stkErreurNomPris;

  /// No description provided for @stkExpiration.
  ///
  /// In fr, this message translates to:
  /// **'Expiration'**
  String get stkExpiration;

  /// No description provided for @stkExpireDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Expiré depuis {jours} j'**
  String stkExpireDepuis(int jours);

  /// No description provided for @stkJMoins.
  ///
  /// In fr, this message translates to:
  /// **'J−{jours}'**
  String stkJMoins(int jours);

  /// No description provided for @stkJours.
  ///
  /// In fr, this message translates to:
  /// **'Jours'**
  String get stkJours;

  /// No description provided for @stkKpiArticlesSortis.
  ///
  /// In fr, this message translates to:
  /// **'Articles sortis'**
  String get stkKpiArticlesSortis;

  /// No description provided for @stkKpiCoutReassort.
  ///
  /// In fr, this message translates to:
  /// **'Coût de réassort estimé'**
  String get stkKpiCoutReassort;

  /// No description provided for @stkKpiEnRupture.
  ///
  /// In fr, this message translates to:
  /// **'En rupture'**
  String get stkKpiEnRupture;

  /// No description provided for @stkKpiMagasinsActifs.
  ///
  /// In fr, this message translates to:
  /// **'Magasins actifs'**
  String get stkKpiMagasinsActifs;

  /// No description provided for @stkKpiSorties.
  ///
  /// In fr, this message translates to:
  /// **'Sorties de la période'**
  String get stkKpiSorties;

  /// No description provided for @stkKpiSousSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Sous le seuil'**
  String get stkKpiSousSeuil;

  /// No description provided for @stkKpiUtilisateursRattaches.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs rattachés'**
  String get stkKpiUtilisateursRattaches;

  /// No description provided for @stkKpiValeurPerdue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur perdue'**
  String get stkKpiValeurPerdue;

  /// No description provided for @stkKpiValeurTotale.
  ///
  /// In fr, this message translates to:
  /// **'Valeur totale du stock'**
  String get stkKpiValeurTotale;

  /// No description provided for @stkListeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Liste {code}'**
  String stkListeTitre(String code);

  /// No description provided for @stkLivraison.
  ///
  /// In fr, this message translates to:
  /// **'Livraison souhaitée'**
  String get stkLivraison;

  /// No description provided for @stkMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get stkMagasin;

  /// No description provided for @stkMagasinDifferent.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un magasin différent'**
  String get stkMagasinDifferent;

  /// No description provided for @stkModifierListe.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la liste de besoins'**
  String get stkModifierListe;

  /// No description provided for @stkModifierMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le magasin'**
  String get stkModifierMagasin;

  /// No description provided for @stkModifierSortie.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la sortie'**
  String get stkModifierSortie;

  /// No description provided for @stkModifierTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le transfert'**
  String get stkModifierTransfert;

  /// No description provided for @stkMontantEstime.
  ///
  /// In fr, this message translates to:
  /// **'Montant estimé'**
  String get stkMontantEstime;

  /// No description provided for @stkMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get stkMotif;

  /// No description provided for @stkMotifDistributionIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. réassort boutique'**
  String get stkMotifDistributionIndice;

  /// No description provided for @stkMotifSortieIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. carton tombé lors de la mise en rayon'**
  String get stkMotifSortieIndice;

  /// No description provided for @stkMouvementsRecents.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements récents'**
  String get stkMouvementsRecents;

  /// No description provided for @stkNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get stkNom;

  /// No description provided for @stkNomMagasinIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Boutique Hydra'**
  String get stkNomMagasinIndice;

  /// No description provided for @stkNouveauMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau magasin'**
  String get stkNouveauMagasin;

  /// No description provided for @stkNouveauTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau transfert'**
  String get stkNouveauTransfert;

  /// No description provided for @stkNouvelleListe.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle liste'**
  String get stkNouvelleListe;

  /// No description provided for @stkNouvelleSortie.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sortie'**
  String get stkNouvelleSortie;

  /// No description provided for @stkObservationTransfertIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. réassort hebdomadaire'**
  String get stkObservationTransfertIndice;

  /// No description provided for @stkOngletExpires.
  ///
  /// In fr, this message translates to:
  /// **'Expirés'**
  String get stkOngletExpires;

  /// No description provided for @stkOngletListes.
  ///
  /// In fr, this message translates to:
  /// **'Listes de besoins'**
  String get stkOngletListes;

  /// No description provided for @stkOngletMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Magasins'**
  String get stkOngletMagasins;

  /// No description provided for @stkOngletMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements'**
  String get stkOngletMouvements;

  /// No description provided for @stkOngletRuptures.
  ///
  /// In fr, this message translates to:
  /// **'Ruptures & seuils'**
  String get stkOngletRuptures;

  /// No description provided for @stkOngletTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Transferts'**
  String get stkOngletTransferts;

  /// No description provided for @stkPalierAvance.
  ///
  /// In fr, this message translates to:
  /// **'Palier Avancé'**
  String get stkPalierAvance;

  /// No description provided for @stkPcs.
  ///
  /// In fr, this message translates to:
  /// **'pcs'**
  String get stkPcs;

  /// No description provided for @stkPdfFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'PDF fournisseur'**
  String get stkPdfFournisseur;

  /// No description provided for @stkPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Principal'**
  String get stkPrincipal;

  /// No description provided for @stkPrixEstime.
  ///
  /// In fr, this message translates to:
  /// **'Prix estimé'**
  String get stkPrixEstime;

  /// No description provided for @stkProduitsEnStock.
  ///
  /// In fr, this message translates to:
  /// **'Produits en stock'**
  String get stkProduitsEnStock;

  /// No description provided for @stkProduitsSortis.
  ///
  /// In fr, this message translates to:
  /// **'Produits sortis'**
  String get stkProduitsSortis;

  /// No description provided for @stkProduitsTransferes.
  ///
  /// In fr, this message translates to:
  /// **'Produits transférés'**
  String get stkProduitsTransferes;

  /// No description provided for @stkQte.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get stkQte;

  /// No description provided for @stkQuantiteTotale.
  ///
  /// In fr, this message translates to:
  /// **'Quantité totale'**
  String get stkQuantiteTotale;

  /// No description provided for @stkRechercheMouvement.
  ///
  /// In fr, this message translates to:
  /// **'Réf. ou produit…'**
  String get stkRechercheMouvement;

  /// No description provided for @stkReference.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get stkReference;

  /// No description provided for @stkReparti.
  ///
  /// In fr, this message translates to:
  /// **'Réparti'**
  String get stkReparti;

  /// No description provided for @stkRepartirEgalement.
  ///
  /// In fr, this message translates to:
  /// **'Répartir également'**
  String get stkRepartirEgalement;

  /// No description provided for @stkRepartition.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par magasin'**
  String get stkRepartition;

  /// No description provided for @stkResponsable.
  ///
  /// In fr, this message translates to:
  /// **'Responsable'**
  String get stkResponsable;

  /// No description provided for @stkReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get stkReste;

  /// No description provided for @stkRestePrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Reste au principal'**
  String get stkRestePrincipal;

  /// No description provided for @stkRetourFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Retour fournisseur'**
  String get stkRetourFournisseur;

  /// No description provided for @stkSeuilAlerte.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte'**
  String get stkSeuilAlerte;

  /// No description provided for @stkSortiePerime.
  ///
  /// In fr, this message translates to:
  /// **'Sortie « Périmé »'**
  String get stkSortiePerime;

  /// No description provided for @stkSortieTitre.
  ///
  /// In fr, this message translates to:
  /// **'Sortie {code}'**
  String stkSortieTitre(String code);

  /// No description provided for @stkSousSeuilEtat.
  ///
  /// In fr, this message translates to:
  /// **'Sous le seuil'**
  String get stkSousSeuilEtat;

  /// No description provided for @stkStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get stkStatut;

  /// No description provided for @stkStockDispo.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {quantite}'**
  String stkStockDispo(String quantite);

  /// No description provided for @stkStockDuMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Stock du magasin'**
  String get stkStockDuMagasin;

  /// No description provided for @stkStockTotal.
  ///
  /// In fr, this message translates to:
  /// **'Stock total'**
  String get stkStockTotal;

  /// No description provided for @stkSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion'**
  String get stkSuggestion;

  /// No description provided for @stkTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get stkTelephone;

  /// No description provided for @stkToastDistribue.
  ///
  /// In fr, this message translates to:
  /// **'Stock distribué'**
  String get stkToastDistribue;

  /// No description provided for @stkToastListe.
  ///
  /// In fr, this message translates to:
  /// **'Liste enregistrée'**
  String get stkToastListe;

  /// No description provided for @stkToastListeDesc.
  ///
  /// In fr, this message translates to:
  /// **'{code} · prête à envoyer'**
  String stkToastListeDesc(String code);

  /// No description provided for @stkToastListesAnnulees.
  ///
  /// In fr, this message translates to:
  /// **'Listes annulées'**
  String get stkToastListesAnnulees;

  /// No description provided for @stkToastMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin enregistré'**
  String get stkToastMagasin;

  /// No description provided for @stkToastMagasinsDesactives.
  ///
  /// In fr, this message translates to:
  /// **'Magasins désactivés'**
  String get stkToastMagasinsDesactives;

  /// No description provided for @stkToastSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie enregistrée'**
  String get stkToastSortie;

  /// No description provided for @stkToastSortiesAnnulees.
  ///
  /// In fr, this message translates to:
  /// **'Sorties annulées'**
  String get stkToastSortiesAnnulees;

  /// No description provided for @stkToastStockAJour.
  ///
  /// In fr, this message translates to:
  /// **'Stock mis à jour'**
  String get stkToastStockAJour;

  /// No description provided for @stkToastStockReintegre.
  ///
  /// In fr, this message translates to:
  /// **'Le stock a été réintégré'**
  String get stkToastStockReintegre;

  /// No description provided for @stkToastTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert validé'**
  String get stkToastTransfert;

  /// No description provided for @stkToastTransfertsAnnules.
  ///
  /// In fr, this message translates to:
  /// **'Transferts annulés'**
  String get stkToastTransfertsAnnules;

  /// No description provided for @stkToutPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Tout au principal'**
  String get stkToutPrincipal;

  /// No description provided for @stkTransfererPieces.
  ///
  /// In fr, this message translates to:
  /// **'Transférer {quantite} pièce(s)'**
  String stkTransfererPieces(String quantite);

  /// No description provided for @stkTransfertTitre.
  ///
  /// In fr, this message translates to:
  /// **'Transfert {code}'**
  String stkTransfertTitre(String code);

  /// No description provided for @stkUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get stkUtilisateurs;

  /// No description provided for @stkUtilisateursCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs & caisses'**
  String get stkUtilisateursCaisses;

  /// No description provided for @stkValeurAchat.
  ///
  /// In fr, this message translates to:
  /// **'Valeur d\'achat'**
  String get stkValeurAchat;

  /// No description provided for @stkValeurStock.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock'**
  String get stkValeurStock;

  /// No description provided for @stkValeurVente.
  ///
  /// In fr, this message translates to:
  /// **'Valeur de vente'**
  String get stkValeurVente;

  /// No description provided for @stkValideLe.
  ///
  /// In fr, this message translates to:
  /// **'Validé le'**
  String get stkValideLe;

  /// No description provided for @stkValiderTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Valider le transfert'**
  String get stkValiderTransfert;

  /// No description provided for @stkVers.
  ///
  /// In fr, this message translates to:
  /// **'Vers'**
  String get stkVers;

  /// No description provided for @stkVoirMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Voir les mouvements'**
  String get stkVoirMouvements;

  /// No description provided for @stkVoirPiece.
  ///
  /// In fr, this message translates to:
  /// **'Voir la pièce'**
  String get stkVoirPiece;

  /// No description provided for @entAucunBon.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bon reçu.'**
  String get entAucunBon;

  /// No description provided for @entAucunFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Aucun (achat comptant)'**
  String get entAucunFournisseur;

  /// No description provided for @entAucunProduit.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ou ajoutez les produits reçus.'**
  String get entAucunProduit;

  /// No description provided for @entBloqueDejaAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulée'**
  String get entBloqueDejaAnnulee;

  /// No description provided for @entBloqueVendus.
  ///
  /// In fr, this message translates to:
  /// **'Des produits ont déjà été vendus'**
  String get entBloqueVendus;

  /// No description provided for @entBonReception.
  ///
  /// In fr, this message translates to:
  /// **'Bon de réception'**
  String get entBonReception;

  /// No description provided for @entChoisirProduit.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un produit'**
  String get entChoisirProduit;

  /// No description provided for @entEntite.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get entEntite;

  /// No description provided for @entEntiteBon.
  ///
  /// In fr, this message translates to:
  /// **'bon'**
  String get entEntiteBon;

  /// No description provided for @entEntiteBons.
  ///
  /// In fr, this message translates to:
  /// **'bons'**
  String get entEntiteBons;

  /// No description provided for @entEntitePluriel.
  ///
  /// In fr, this message translates to:
  /// **'entrées'**
  String get entEntitePluriel;

  /// No description provided for @entEntreeLiee.
  ///
  /// In fr, this message translates to:
  /// **'Entrée liée'**
  String get entEntreeLiee;

  /// No description provided for @entErreurBonInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Bon de réception introuvable.'**
  String get entErreurBonInconnu;

  /// No description provided for @entErreurBonTraite.
  ///
  /// In fr, this message translates to:
  /// **'Bon déjà traité'**
  String get entErreurBonTraite;

  /// No description provided for @entErreurMotif.
  ///
  /// In fr, this message translates to:
  /// **'Le motif est obligatoire.'**
  String get entErreurMotif;

  /// No description provided for @entEtapeBon.
  ///
  /// In fr, this message translates to:
  /// **'Bon & fournisseur'**
  String get entEtapeBon;

  /// No description provided for @entEtapeProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits reçus'**
  String get entEtapeProduits;

  /// No description provided for @entFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get entFichier;

  /// No description provided for @entFournisseurDetecte.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur détecté'**
  String get entFournisseurDetecte;

  /// No description provided for @entIaAnalyser.
  ///
  /// In fr, this message translates to:
  /// **'Analyser le bon'**
  String get entIaAnalyser;

  /// No description provided for @entIaApercu.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du bon'**
  String get entIaApercu;

  /// No description provided for @entIaAucunFichier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier choisi'**
  String get entIaAucunFichier;

  /// No description provided for @entIaBandeauDetail.
  ///
  /// In fr, this message translates to:
  /// **'Les bons envoyés depuis le téléphone arrivent ici avec le statut « Reçu ».'**
  String get entIaBandeauDetail;

  /// No description provided for @entIaBandeauTitre.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez le bon, l\'IA remplit l\'entrée'**
  String get entIaBandeauTitre;

  /// No description provided for @entIaConfiance.
  ///
  /// In fr, this message translates to:
  /// **'Confiance'**
  String get entIaConfiance;

  /// No description provided for @entIaDepuisDisque.
  ///
  /// In fr, this message translates to:
  /// **'Depuis le disque'**
  String get entIaDepuisDisque;

  /// No description provided for @entIaDepuisTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Depuis le téléphone'**
  String get entIaDepuisTelephone;

  /// No description provided for @entIaDetecte.
  ///
  /// In fr, this message translates to:
  /// **'Détecté sur le bon'**
  String get entIaDetecte;

  /// No description provided for @entIaEtapeFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur & paiement'**
  String get entIaEtapeFournisseur;

  /// No description provided for @entIaEtapeLignes.
  ///
  /// In fr, this message translates to:
  /// **'Lignes détectées'**
  String get entIaEtapeLignes;

  /// No description provided for @entIaEtapePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo du bon'**
  String get entIaEtapePhoto;

  /// No description provided for @entIaJoindre.
  ///
  /// In fr, this message translates to:
  /// **'Joindre un bon'**
  String get entIaJoindre;

  /// No description provided for @entIaLecture.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du bon en cours…'**
  String get entIaLecture;

  /// No description provided for @entIaLignes.
  ///
  /// In fr, this message translates to:
  /// **'Lignes'**
  String get entIaLignes;

  /// No description provided for @entIaLignesLues.
  ///
  /// In fr, this message translates to:
  /// **'Lignes lues'**
  String get entIaLignesLues;

  /// No description provided for @entIaLu.
  ///
  /// In fr, this message translates to:
  /// **'Lu sur le bon'**
  String get entIaLu;

  /// No description provided for @entIaProduitCatalogue.
  ///
  /// In fr, this message translates to:
  /// **'Produit du catalogue'**
  String get entIaProduitCatalogue;

  /// No description provided for @entIaRapprocher.
  ///
  /// In fr, this message translates to:
  /// **'Rapprocher…'**
  String get entIaRapprocher;

  /// No description provided for @entIaRecuPar.
  ///
  /// In fr, this message translates to:
  /// **'Reçu par'**
  String get entIaRecuPar;

  /// No description provided for @entIaRemplacer.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer le produit'**
  String get entIaRemplacer;

  /// No description provided for @entIaTelephoneAide.
  ///
  /// In fr, this message translates to:
  /// **'Les bons envoyés depuis l\'application mobile apparaissent dans la file Mode IA.'**
  String get entIaTelephoneAide;

  /// No description provided for @entIaTitre.
  ///
  /// In fr, this message translates to:
  /// **'Reçu IA · lecture automatique du bon'**
  String get entIaTitre;

  /// No description provided for @entIaTraitePar.
  ///
  /// In fr, this message translates to:
  /// **'Traité par'**
  String get entIaTraitePar;

  /// No description provided for @entIaTraiter.
  ///
  /// In fr, this message translates to:
  /// **'Traiter'**
  String get entIaTraiter;

  /// No description provided for @entIaVideAide.
  ///
  /// In fr, this message translates to:
  /// **'Joignez un bon (photo ou PDF) pour que l\'IA prépare l\'entrée.'**
  String get entIaVideAide;

  /// No description provided for @entIaVoirBon.
  ///
  /// In fr, this message translates to:
  /// **'Voir le bon'**
  String get entIaVoirBon;

  /// No description provided for @entImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get entImprimer;

  /// No description provided for @entInformations.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get entInformations;

  /// No description provided for @entKpiEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées du mois'**
  String get entKpiEntrees;

  /// No description provided for @entListe.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get entListe;

  /// No description provided for @entListeBesoins.
  ///
  /// In fr, this message translates to:
  /// **'Liste de besoins'**
  String get entListeBesoins;

  /// No description provided for @entMagasinAide.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut : votre magasin principal'**
  String get entMagasinAide;

  /// No description provided for @entMajDernier.
  ///
  /// In fr, this message translates to:
  /// **'Dernier prix d\'achat'**
  String get entMajDernier;

  /// No description provided for @entMajGarder.
  ///
  /// In fr, this message translates to:
  /// **'Garder le prix d\'achat actuel'**
  String get entMajGarder;

  /// No description provided for @entMajMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Prix moyen pondéré'**
  String get entMajMoyen;

  /// No description provided for @entMajPrix.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour prix'**
  String get entMajPrix;

  /// No description provided for @entMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get entMode;

  /// No description provided for @entModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'entrée'**
  String get entModifierTitre;

  /// No description provided for @entMontantPaye.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get entMontantPaye;

  /// No description provided for @entNbVersements.
  ///
  /// In fr, this message translates to:
  /// **'Nb versements'**
  String get entNbVersements;

  /// No description provided for @entNouvelleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle entrée · Smart Scan'**
  String get entNouvelleTitre;

  /// No description provided for @entNumFacture.
  ///
  /// In fr, this message translates to:
  /// **'N° facture / BL'**
  String get entNumFacture;

  /// No description provided for @entNumFactureIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. FAC-24-1187'**
  String get entNumFactureIndice;

  /// No description provided for @entOffreMessage.
  ///
  /// In fr, this message translates to:
  /// **'Je souhaite augmenter mon quota Smart Scan.'**
  String get entOffreMessage;

  /// No description provided for @entOngletEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get entOngletEntree;

  /// No description provided for @entPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get entPaiement;

  /// No description provided for @entPaye.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get entPaye;

  /// No description provided for @entPayeTotalite.
  ///
  /// In fr, this message translates to:
  /// **'Payé en totalité'**
  String get entPayeTotalite;

  /// No description provided for @entProduitsRecus.
  ///
  /// In fr, this message translates to:
  /// **'Produits reçus'**
  String get entProduitsRecus;

  /// No description provided for @entQteRecue.
  ///
  /// In fr, this message translates to:
  /// **'Qté reçue'**
  String get entQteRecue;

  /// No description provided for @entRapideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide'**
  String get entRapideTitre;

  /// No description provided for @entRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Code, fournisseur ou n° facture…'**
  String get entRecherche;

  /// No description provided for @entRechercheBons.
  ///
  /// In fr, this message translates to:
  /// **'Fichier ou fournisseur…'**
  String get entRechercheBons;

  /// No description provided for @entRecuLe.
  ///
  /// In fr, this message translates to:
  /// **'Reçu le'**
  String get entRecuLe;

  /// No description provided for @entRepartitionIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Répartition incomplète'**
  String get entRepartitionIncomplete;

  /// No description provided for @entRepartitionOption.
  ///
  /// In fr, this message translates to:
  /// **'Répartition (option)'**
  String get entRepartitionOption;

  /// No description provided for @entResteAide.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté au crédit du fournisseur'**
  String get entResteAide;

  /// No description provided for @entResteCredit.
  ///
  /// In fr, this message translates to:
  /// **'Reste (crédit)'**
  String get entResteCredit;

  /// No description provided for @entRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get entRetour;

  /// No description provided for @entScanAjoute.
  ///
  /// In fr, this message translates to:
  /// **'ajouté'**
  String get entScanAjoute;

  /// No description provided for @entScanIndice.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code-barres puis Entrée (ou code produit)…'**
  String get entScanIndice;

  /// No description provided for @entSourceIa.
  ///
  /// In fr, this message translates to:
  /// **'Reçu IA'**
  String get entSourceIa;

  /// No description provided for @entSourceRapide.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide'**
  String get entSourceRapide;

  /// No description provided for @entSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get entSuivant;

  /// No description provided for @entToastAnnulees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées annulées'**
  String get entToastAnnulees;

  /// No description provided for @entToastAnnuleesDetail.
  ///
  /// In fr, this message translates to:
  /// **'Stock et crédit fournisseur corrigés'**
  String get entToastAnnuleesDetail;

  /// No description provided for @entToastBonsSupprimes.
  ///
  /// In fr, this message translates to:
  /// **'Bons supprimés'**
  String get entToastBonsSupprimes;

  /// No description provided for @entToastDepuisBon.
  ///
  /// In fr, this message translates to:
  /// **'Entrée créée depuis le bon'**
  String get entToastDepuisBon;

  /// No description provided for @entToastEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée enregistrée'**
  String get entToastEnregistree;

  /// No description provided for @entToastModifiee.
  ///
  /// In fr, this message translates to:
  /// **'Entrée modifiée'**
  String get entToastModifiee;

  /// No description provided for @entToastRapide.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide enregistrée'**
  String get entToastRapide;

  /// No description provided for @entToastReparti.
  ///
  /// In fr, this message translates to:
  /// **'Stock réparti entre les magasins'**
  String get entToastReparti;

  /// No description provided for @entVenteSousAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente ≤ prix d\'achat'**
  String get entVenteSousAchat;

  /// No description provided for @entCreerProduit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le produit « {nom} »'**
  String entCreerProduit(String nom);

  /// No description provided for @entDetailTitre.
  ///
  /// In fr, this message translates to:
  /// **'Entrée {code}'**
  String entDetailTitre(String code);

  /// No description provided for @entIaARapprocher.
  ///
  /// In fr, this message translates to:
  /// **'{n} ligne(s) à rapprocher'**
  String entIaARapprocher(int n);

  /// No description provided for @entIaCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'entrée · {montant}'**
  String entIaCreer(String montant);

  /// No description provided for @entValider.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'entrée · {montant}'**
  String entValider(String montant);

  /// No description provided for @entRapideTitreProduit.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide · {nom}'**
  String entRapideTitreProduit(String nom);

  /// No description provided for @entScanInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Code inconnu : {code}'**
  String entScanInconnu(String code);

  /// No description provided for @entToastBonsDetail.
  ///
  /// In fr, this message translates to:
  /// **'{n} fichier(s)'**
  String entToastBonsDetail(int n);

  /// No description provided for @entCreerEntree.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'entrée'**
  String get entCreerEntree;

  /// No description provided for @statutErreur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get statutErreur;

  /// No description provided for @gcOngletCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Caisses'**
  String get gcOngletCaisses;

  /// No description provided for @gcOngletTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Transferts'**
  String get gcOngletTransferts;

  /// No description provided for @gcOngletClotures.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures Z'**
  String get gcOngletClotures;

  /// No description provided for @gcOngletMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements'**
  String get gcOngletMouvements;

  /// No description provided for @gcOngletSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions'**
  String get gcOngletSessions;

  /// No description provided for @gcEntiteCaisse.
  ///
  /// In fr, this message translates to:
  /// **'caisse'**
  String get gcEntiteCaisse;

  /// No description provided for @gcEntiteCaisses.
  ///
  /// In fr, this message translates to:
  /// **'caisses'**
  String get gcEntiteCaisses;

  /// No description provided for @gcEntiteTransfert.
  ///
  /// In fr, this message translates to:
  /// **'transfert'**
  String get gcEntiteTransfert;

  /// No description provided for @gcEntiteTransferts.
  ///
  /// In fr, this message translates to:
  /// **'transferts'**
  String get gcEntiteTransferts;

  /// No description provided for @gcEntiteClotures.
  ///
  /// In fr, this message translates to:
  /// **'clôtures'**
  String get gcEntiteClotures;

  /// No description provided for @gcEntiteMouvements.
  ///
  /// In fr, this message translates to:
  /// **'mouvements'**
  String get gcEntiteMouvements;

  /// No description provided for @gcEntiteSessions.
  ///
  /// In fr, this message translates to:
  /// **'sessions'**
  String get gcEntiteSessions;

  /// No description provided for @gcColCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get gcColCaisse;

  /// No description provided for @gcColSoldeInitial.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get gcColSoldeInitial;

  /// No description provided for @gcColSoldeActuel.
  ///
  /// In fr, this message translates to:
  /// **'Solde actuel'**
  String get gcColSoldeActuel;

  /// No description provided for @gcColSession.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get gcColSession;

  /// No description provided for @gcColEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get gcColEtat;

  /// No description provided for @gcColStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get gcColStatut;

  /// No description provided for @gcColDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Depuis'**
  String get gcColDepuis;

  /// No description provided for @gcColVers.
  ///
  /// In fr, this message translates to:
  /// **'Vers'**
  String get gcColVers;

  /// No description provided for @gcColTickets.
  ///
  /// In fr, this message translates to:
  /// **'Tickets'**
  String get gcColTickets;

  /// No description provided for @gcColAnnules.
  ///
  /// In fr, this message translates to:
  /// **'Annulés'**
  String get gcColAnnules;

  /// No description provided for @gcColTotalAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get gcColTotalAnnule;

  /// No description provided for @gcColPar.
  ///
  /// In fr, this message translates to:
  /// **'Par'**
  String get gcColPar;

  /// No description provided for @gcColEmpreinte.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte'**
  String get gcColEmpreinte;

  /// No description provided for @gcColCreeLe.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get gcColCreeLe;

  /// No description provided for @gcColReference.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get gcColReference;

  /// No description provided for @gcColEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get gcColEntree;

  /// No description provided for @gcColSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get gcColSortie;

  /// No description provided for @gcColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get gcColUtilisateur;

  /// No description provided for @gcColMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get gcColMode;

  /// No description provided for @gcColOuverture.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get gcColOuverture;

  /// No description provided for @gcColCloture.
  ///
  /// In fr, this message translates to:
  /// **'Clôture'**
  String get gcColCloture;

  /// No description provided for @gcColFond.
  ///
  /// In fr, this message translates to:
  /// **'Fond'**
  String get gcColFond;

  /// No description provided for @gcColTheorique.
  ///
  /// In fr, this message translates to:
  /// **'Théorique'**
  String get gcColTheorique;

  /// No description provided for @gcColReel.
  ///
  /// In fr, this message translates to:
  /// **'Réel'**
  String get gcColReel;

  /// No description provided for @gcColEcart.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get gcColEcart;

  /// No description provided for @gcColOuvertePar.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte par'**
  String get gcColOuvertePar;

  /// No description provided for @gcToutesCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Toutes caisses'**
  String get gcToutesCaisses;

  /// No description provided for @gcRechercheCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une caisse…'**
  String get gcRechercheCaisses;

  /// No description provided for @gcRechercheTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un transfert…'**
  String get gcRechercheTransferts;

  /// No description provided for @gcRechercheClotures.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une clôture…'**
  String get gcRechercheClotures;

  /// No description provided for @gcRechercheMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un mouvement…'**
  String get gcRechercheMouvements;

  /// No description provided for @gcRechercheSessions.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une session…'**
  String get gcRechercheSessions;

  /// No description provided for @gcAucuneSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session.'**
  String get gcAucuneSession;

  /// No description provided for @gcExportFiscal.
  ///
  /// In fr, this message translates to:
  /// **'Export contrôle fiscal'**
  String get gcExportFiscal;

  /// No description provided for @gcNouvelleClotureZ.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle clôture Z'**
  String get gcNouvelleClotureZ;

  /// No description provided for @gcMouvementManuel.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement manuel'**
  String get gcMouvementManuel;

  /// No description provided for @gcVoirMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Voir les mouvements'**
  String get gcVoirMouvements;

  /// No description provided for @gcCloturer.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer'**
  String get gcCloturer;

  /// No description provided for @gcOuvrirSession.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir une session'**
  String get gcOuvrirSession;

  /// No description provided for @gcFormNomIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Caisse 3'**
  String get gcFormNomIndice;

  /// No description provided for @gcFormSoldeInitialAide.
  ///
  /// In fr, this message translates to:
  /// **'Proposé comme fond de caisse à chaque ouverture'**
  String get gcFormSoldeInitialAide;

  /// No description provided for @gcCaisseEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Caisse enregistrée'**
  String get gcCaisseEnregistree;

  /// No description provided for @gcSessions30j.
  ///
  /// In fr, this message translates to:
  /// **'Sessions (30 j)'**
  String get gcSessions30j;

  /// No description provided for @gcEcartCumule.
  ///
  /// In fr, this message translates to:
  /// **'Écart cumulé'**
  String get gcEcartCumule;

  /// No description provided for @gcDernieresSessions.
  ///
  /// In fr, this message translates to:
  /// **'Dernières sessions'**
  String get gcDernieresSessions;

  /// No description provided for @gcBloqueSession.
  ///
  /// In fr, this message translates to:
  /// **'Session ouverte — clôturez-la d\'abord'**
  String get gcBloqueSession;

  /// No description provided for @gcBloqueSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde non nul — transférez-le'**
  String get gcBloqueSolde;

  /// No description provided for @gcBloqueSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Caisse principale'**
  String get gcBloqueSysteme;

  /// No description provided for @gcBloqueInactive.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inactive'**
  String get gcBloqueInactive;

  /// No description provided for @gcErreurSoldeNonNul.
  ///
  /// In fr, this message translates to:
  /// **'Le solde de la caisse doit être nul : transférez-le d\'abord.'**
  String get gcErreurSoldeNonNul;

  /// No description provided for @gcToastDesactivees.
  ///
  /// In fr, this message translates to:
  /// **'Caisses désactivées'**
  String get gcToastDesactivees;

  /// No description provided for @gcTrfTitre.
  ///
  /// In fr, this message translates to:
  /// **'Transfert entre caisses'**
  String get gcTrfTitre;

  /// No description provided for @gcTrfDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Solde disponible : {montant}'**
  String gcTrfDisponible(String montant);

  /// No description provided for @gcTrfMemeCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une caisse différente'**
  String get gcTrfMemeCaisse;

  /// No description provided for @gcTrfSuperieur.
  ///
  /// In fr, this message translates to:
  /// **'Supérieur au solde de {caisse}'**
  String gcTrfSuperieur(String caisse);

  /// No description provided for @gcTrfMotifIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. remise de recette'**
  String get gcTrfMotifIndice;

  /// No description provided for @gcTrfValider.
  ///
  /// In fr, this message translates to:
  /// **'Transférer {montant}'**
  String gcTrfValider(String montant);

  /// No description provided for @gcToastTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert enregistré'**
  String get gcToastTransfert;

  /// No description provided for @gcToastTransfertsAnnules.
  ///
  /// In fr, this message translates to:
  /// **'Transferts annulés'**
  String get gcToastTransfertsAnnules;

  /// No description provided for @gcToastSoldesRetablis.
  ///
  /// In fr, this message translates to:
  /// **'Soldes rétablis'**
  String get gcToastSoldesRetablis;

  /// No description provided for @gcBloqueDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulé'**
  String get gcBloqueDejaAnnule;

  /// No description provided for @gcErreurDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Ce transfert est déjà annulé.'**
  String get gcErreurDejaAnnule;

  /// No description provided for @gcErreurTransfertInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Transfert introuvable.'**
  String get gcErreurTransfertInconnu;

  /// No description provided for @gcErreurPeriodeCloturee.
  ///
  /// In fr, this message translates to:
  /// **'Cette date appartient à une période clôturée.'**
  String get gcErreurPeriodeCloturee;

  /// No description provided for @gcZPeriodeValeur.
  ///
  /// In fr, this message translates to:
  /// **'{debut} → maintenant'**
  String gcZPeriodeValeur(String debut);

  /// No description provided for @gcZDepuisDerniere.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la dernière clôture ({code})'**
  String gcZDepuisDerniere(String code);

  /// No description provided for @gcZPremiere.
  ///
  /// In fr, this message translates to:
  /// **'Première clôture de cette caisse'**
  String get gcZPremiere;

  /// No description provided for @gcZTicketsAnnules.
  ///
  /// In fr, this message translates to:
  /// **'Tickets annulés'**
  String get gcZTicketsAnnules;

  /// No description provided for @gcZTotalAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Total annulé'**
  String get gcZTotalAnnule;

  /// No description provided for @gcZMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Moyen de paiement'**
  String get gcZMoyen;

  /// No description provided for @gcZPart.
  ///
  /// In fr, this message translates to:
  /// **'Part'**
  String get gcZPart;

  /// No description provided for @gcZChainee.
  ///
  /// In fr, this message translates to:
  /// **'Chaînée à {code} · empreinte précédente'**
  String gcZChainee(String code);

  /// No description provided for @gcZGenese.
  ///
  /// In fr, this message translates to:
  /// **'Début de la chaîne de cette caisse · empreinte de genèse'**
  String get gcZGenese;

  /// No description provided for @gcZConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Je confirme les totaux : la clôture sera définitive et signée.'**
  String get gcZConfirmer;

  /// No description provided for @gcZCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer la clôture {code}'**
  String gcZCreer(String code);

  /// No description provided for @gcZCreee.
  ///
  /// In fr, this message translates to:
  /// **'Clôture {code} créée'**
  String gcZCreee(String code);

  /// No description provided for @gcZCreeeDetail.
  ///
  /// In fr, this message translates to:
  /// **'Rapport signé et chaîné'**
  String get gcZCreeeDetail;

  /// No description provided for @gcZAucunPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement sur la période.'**
  String get gcZAucunPaiement;

  /// No description provided for @gcZDetailTitre.
  ///
  /// In fr, this message translates to:
  /// **'Clôture {code}'**
  String gcZDetailTitre(String code);

  /// No description provided for @gcZDetailDescription.
  ///
  /// In fr, this message translates to:
  /// **'{caisse} · {du} → {au} · par {par}'**
  String gcZDetailDescription(String au, String caisse, String du, String par);

  /// No description provided for @gcZDefinitive.
  ///
  /// In fr, this message translates to:
  /// **'Définitive'**
  String get gcZDefinitive;

  /// No description provided for @gcZEmpreinteValide.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte valide'**
  String get gcZEmpreinteValide;

  /// No description provided for @gcZEmpreinteAlteree.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte altérée'**
  String get gcZEmpreinteAlteree;

  /// No description provided for @gcZRepartition.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des paiements'**
  String get gcZRepartition;

  /// No description provided for @gcZIntegrite.
  ///
  /// In fr, this message translates to:
  /// **'Intégrité'**
  String get gcZIntegrite;

  /// No description provided for @gcZEmpreintePrecedente.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte précédente'**
  String get gcZEmpreintePrecedente;

  /// No description provided for @gcZTotaux.
  ///
  /// In fr, this message translates to:
  /// **'Totaux de la période'**
  String get gcZTotaux;

  /// No description provided for @gcZSoldeFin.
  ///
  /// In fr, this message translates to:
  /// **'Solde en fin de période'**
  String get gcZSoldeFin;

  /// No description provided for @gcFiscalTitre.
  ///
  /// In fr, this message translates to:
  /// **'Export pour contrôle fiscal'**
  String get gcFiscalTitre;

  /// No description provided for @gcFiscalZip.
  ///
  /// In fr, this message translates to:
  /// **'Archive complète'**
  String get gcFiscalZip;

  /// No description provided for @gcFiscalZipDesc.
  ///
  /// In fr, this message translates to:
  /// **'JSON de contrôle + CSV + empreintes (.zip)'**
  String get gcFiscalZipDesc;

  /// No description provided for @gcFiscalJson.
  ///
  /// In fr, this message translates to:
  /// **'JSON de contrôle'**
  String get gcFiscalJson;

  /// No description provided for @gcFiscalJsonDesc.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne vérifiable (§12.3)'**
  String get gcFiscalJsonDesc;

  /// No description provided for @gcFiscalPdf.
  ///
  /// In fr, this message translates to:
  /// **'Rapport PDF'**
  String get gcFiscalPdf;

  /// No description provided for @gcFiscalPdfDesc.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures Z uniquement'**
  String get gcFiscalPdfDesc;

  /// No description provided for @gcFiscalCsv.
  ///
  /// In fr, this message translates to:
  /// **'CSV'**
  String get gcFiscalCsv;

  /// No description provided for @gcFiscalCsvDesc.
  ///
  /// In fr, this message translates to:
  /// **'Tickets ligne à ligne'**
  String get gcFiscalCsvDesc;

  /// No description provided for @gcFiscalChaineOk.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne d\'empreintes intègre · {n} clôtures, aucune rupture'**
  String gcFiscalChaineOk(int n);

  /// No description provided for @gcFiscalChaineKo.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne rompue à la clôture {code}'**
  String gcFiscalChaineKo(String code);

  /// No description provided for @gcFiscalGenere.
  ///
  /// In fr, this message translates to:
  /// **'Archive générée'**
  String get gcFiscalGenere;

  /// No description provided for @gcSesMvtTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements · {code}'**
  String gcSesMvtTitre(String code);

  /// No description provided for @gcEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées'**
  String get gcEntrees;

  /// No description provided for @gcSorties.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get gcSorties;

  /// No description provided for @gcSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get gcSolde;

  /// No description provided for @permVoirMarge.
  ///
  /// In fr, this message translates to:
  /// **'Voir la marge / taux de marge'**
  String get permVoirMarge;

  /// No description provided for @permModifierPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le prix de vente'**
  String get permModifierPrixVente;

  /// No description provided for @permAnnulerOperations.
  ///
  /// In fr, this message translates to:
  /// **'Annuler des opérations'**
  String get permAnnulerOperations;

  /// No description provided for @permChangerCaisseMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Changer sa caisse / son magasin'**
  String get permChangerCaisseMagasin;

  /// No description provided for @permGererTransfertsCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les transferts entre caisses'**
  String get permGererTransfertsCaisse;

  /// No description provided for @permVoirStockTousMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Voir le stock de tous les magasins'**
  String get permVoirStockTousMagasins;

  /// No description provided for @usrOngletUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get usrOngletUtilisateurs;

  /// No description provided for @usrOngletRoles.
  ///
  /// In fr, this message translates to:
  /// **'Rôles'**
  String get usrOngletRoles;

  /// No description provided for @usrEntiteUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'utilisateurs'**
  String get usrEntiteUtilisateurs;

  /// No description provided for @usrEntiteUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'utilisateur'**
  String get usrEntiteUtilisateur;

  /// No description provided for @usrEntiteRoles.
  ///
  /// In fr, this message translates to:
  /// **'rôles'**
  String get usrEntiteRoles;

  /// No description provided for @usrEntiteRole.
  ///
  /// In fr, this message translates to:
  /// **'rôle'**
  String get usrEntiteRole;

  /// No description provided for @usrKpiActifs.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs actifs'**
  String get usrKpiActifs;

  /// No description provided for @usrKpiVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes (30 j)'**
  String get usrKpiVentes;

  /// No description provided for @usrKpiTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total vendu'**
  String get usrKpiTotal;

  /// No description provided for @usrRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get usrRole;

  /// No description provided for @usrEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get usrEtat;

  /// No description provided for @usrActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get usrActif;

  /// No description provided for @usrInactif.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get usrInactif;

  /// No description provided for @usrRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Nom, identifiant ou téléphone…'**
  String get usrRecherche;

  /// No description provided for @usrColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get usrColUtilisateur;

  /// No description provided for @usrColCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get usrColCaisse;

  /// No description provided for @usrColMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Magasins'**
  String get usrColMagasins;

  /// No description provided for @usrColVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get usrColVentes;

  /// No description provided for @usrColDernierAcces.
  ///
  /// In fr, this message translates to:
  /// **'Dernier accès'**
  String get usrColDernierAcces;

  /// No description provided for @usrTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get usrTelephone;

  /// No description provided for @usrLibre.
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get usrLibre;

  /// No description provided for @usrReinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get usrReinitialiser;

  /// No description provided for @usrDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get usrDesactiver;

  /// No description provided for @usrNouvel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel utilisateur'**
  String get usrNouvel;

  /// No description provided for @usrModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'utilisateur'**
  String get usrModifierTitre;

  /// No description provided for @usrSectionCompte.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get usrSectionCompte;

  /// No description provided for @usrSectionAcces.
  ///
  /// In fr, this message translates to:
  /// **'Accès'**
  String get usrSectionAcces;

  /// No description provided for @usrCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get usrCode;

  /// No description provided for @usrIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get usrIdentifiant;

  /// No description provided for @usrIdentifiantIndice.
  ///
  /// In fr, this message translates to:
  /// **'ex. amina'**
  String get usrIdentifiantIndice;

  /// No description provided for @usrIdentifiantPris.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant déjà utilisé'**
  String get usrIdentifiantPris;

  /// No description provided for @usrIdentifiantInvalide.
  ///
  /// In fr, this message translates to:
  /// **'3 à 32 caractères : lettres, chiffres, . _ -'**
  String get usrIdentifiantInvalide;

  /// No description provided for @usrMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get usrMotDePasse;

  /// No description provided for @usrNouveauMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get usrNouveauMotDePasse;

  /// No description provided for @usrMdpIndice.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get usrMdpIndice;

  /// No description provided for @usrMdpVide.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour ne pas changer'**
  String get usrMdpVide;

  /// No description provided for @usrForce0.
  ///
  /// In fr, this message translates to:
  /// **'Très faible'**
  String get usrForce0;

  /// No description provided for @usrForce1.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get usrForce1;

  /// No description provided for @usrForce2.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get usrForce2;

  /// No description provided for @usrForce3.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get usrForce3;

  /// No description provided for @usrForce4.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get usrForce4;

  /// No description provided for @usrPrenom.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get usrPrenom;

  /// No description provided for @usrNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get usrNom;

  /// No description provided for @usrAdminRole.
  ///
  /// In fr, this message translates to:
  /// **'Accès complet, ne peut pas être restreint'**
  String get usrAdminRole;

  /// No description provided for @usrNbPermissions.
  ///
  /// In fr, this message translates to:
  /// **'{n} permissions'**
  String usrNbPermissions(int n);

  /// No description provided for @usrCaisseAttachee.
  ///
  /// In fr, this message translates to:
  /// **'Caisse attachée'**
  String get usrCaisseAttachee;

  /// No description provided for @usrCaisseAdmin.
  ///
  /// In fr, this message translates to:
  /// **'L\'admin choisit sa caisse librement'**
  String get usrCaisseAdmin;

  /// No description provided for @usrCaisseIndice.
  ///
  /// In fr, this message translates to:
  /// **'Verrouille la caisse de l\'écran Caisse'**
  String get usrCaisseIndice;

  /// No description provided for @usrAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get usrAucune;

  /// No description provided for @usrMagasinsIndice.
  ///
  /// In fr, this message translates to:
  /// **'Le premier est le magasin par défaut à la connexion'**
  String get usrMagasinsIndice;

  /// No description provided for @usrObservation.
  ///
  /// In fr, this message translates to:
  /// **'Observation'**
  String get usrObservation;

  /// No description provided for @usrCree.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur créé'**
  String get usrCree;

  /// No description provided for @usrModifie.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur modifié'**
  String get usrModifie;

  /// No description provided for @usrErrTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone obligatoire'**
  String get usrErrTelephone;

  /// No description provided for @usrErrMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get usrErrMotDePasse;

  /// No description provided for @usrErrRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle non assignable'**
  String get usrErrRole;

  /// No description provided for @usrErrMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un magasin'**
  String get usrErrMagasins;

  /// No description provided for @usrErrInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur introuvable'**
  String get usrErrInconnu;

  /// No description provided for @usrInfos.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get usrInfos;

  /// No description provided for @usrPermissionsRole.
  ///
  /// In fr, this message translates to:
  /// **'Permissions du rôle'**
  String get usrPermissionsRole;

  /// No description provided for @usrAudit.
  ///
  /// In fr, this message translates to:
  /// **'Audit'**
  String get usrAudit;

  /// No description provided for @usrCreePar.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get usrCreePar;

  /// No description provided for @usrCreeLe.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get usrCreeLe;

  /// No description provided for @usrModifiePar.
  ///
  /// In fr, this message translates to:
  /// **'Modifié par'**
  String get usrModifiePar;

  /// No description provided for @usrModifieLe.
  ///
  /// In fr, this message translates to:
  /// **'Modifié le'**
  String get usrModifieLe;

  /// No description provided for @usrLibreAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Libre (admin)'**
  String get usrLibreAdmin;

  /// No description provided for @usrDefaut.
  ///
  /// In fr, this message translates to:
  /// **'(défaut)'**
  String get usrDefaut;

  /// No description provided for @usrMdpReinitTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé'**
  String get usrMdpReinitTitre;

  /// No description provided for @usrMdpReinitMessage.
  ///
  /// In fr, this message translates to:
  /// **'Communiquez ce mot de passe temporaire à @{identifiant} : {mdp}. Il pourra le changer dans Mon compte.'**
  String usrMdpReinitMessage(String identifiant, String mdp);

  /// No description provided for @usrBloqueAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Compte administrateur principal'**
  String get usrBloqueAdmin;

  /// No description provided for @usrBloqueCourant.
  ///
  /// In fr, this message translates to:
  /// **'Votre propre compte'**
  String get usrBloqueCourant;

  /// No description provided for @usrBloqueInactif.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inactif'**
  String get usrBloqueInactif;

  /// No description provided for @usrDesactives.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs désactivés'**
  String get usrDesactives;

  /// No description provided for @usrDesactivesDetail.
  ///
  /// In fr, this message translates to:
  /// **'Ils ne peuvent plus se connecter'**
  String get usrDesactivesDetail;

  /// No description provided for @usrColModules.
  ///
  /// In fr, this message translates to:
  /// **'Modules'**
  String get usrColModules;

  /// No description provided for @usrColSpeciales.
  ///
  /// In fr, this message translates to:
  /// **'Spéciales'**
  String get usrColSpeciales;

  /// No description provided for @usrTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get usrTous;

  /// No description provided for @usrToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get usrToutes;

  /// No description provided for @usrSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get usrSysteme;

  /// No description provided for @usrDupliquer.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get usrDupliquer;

  /// No description provided for @usrNouveauRole.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau rôle'**
  String get usrNouveauRole;

  /// No description provided for @usrModifierRole.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le rôle'**
  String get usrModifierRole;

  /// No description provided for @usrPrecedent.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get usrPrecedent;

  /// No description provided for @usrSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get usrSuivant;

  /// No description provided for @usrEnregistrerRole.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le rôle'**
  String get usrEnregistrerRole;

  /// No description provided for @usrEtapeInfos.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get usrEtapeInfos;

  /// No description provided for @usrEtapePermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions'**
  String get usrEtapePermissions;

  /// No description provided for @usrEtapeSpeciales.
  ///
  /// In fr, this message translates to:
  /// **'Permissions spéciales'**
  String get usrEtapeSpeciales;

  /// No description provided for @usrNomRole.
  ///
  /// In fr, this message translates to:
  /// **'Nom du rôle'**
  String get usrNomRole;

  /// No description provided for @usrNomRoleIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Caissier senior'**
  String get usrNomRoleIndice;

  /// No description provided for @usrNomRolePris.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom de rôle existe déjà'**
  String get usrNomRolePris;

  /// No description provided for @usrObsRoleIndice.
  ///
  /// In fr, this message translates to:
  /// **'À quoi sert ce rôle ?'**
  String get usrObsRoleIndice;

  /// No description provided for @usrModulesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modules accessibles'**
  String get usrModulesTitre;

  /// No description provided for @usrModulesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le rôle ne voit dans la barre latérale et le menu que les modules cochés. Paramètres et Historique s\'attribuent comme les autres modules.'**
  String get usrModulesDesc;

  /// No description provided for @usrSpecialesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Actions transversales, vérifiées dans tous les modules (affichage des prix d\'achat, annulations, changement de caisse…).'**
  String get usrSpecialesDesc;

  /// No description provided for @usrConfirmRoleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier ce rôle ?'**
  String get usrConfirmRoleTitre;

  /// No description provided for @usrConfirmRoleMessage.
  ///
  /// In fr, this message translates to:
  /// **'{n} utilisateur(s) verront leurs accès changer à la prochaine connexion.'**
  String usrConfirmRoleMessage(int n);

  /// No description provided for @usrRoleEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Rôle enregistré'**
  String get usrRoleEnregistre;

  /// No description provided for @usrRoleEnregistreDetail.
  ///
  /// In fr, this message translates to:
  /// **'Permissions appliquées'**
  String get usrRoleEnregistreDetail;

  /// No description provided for @usrRoleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rôle {nom}'**
  String usrRoleTitre(String nom);

  /// No description provided for @usrAdminBloqueTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modification impossible'**
  String get usrAdminBloqueTitre;

  /// No description provided for @usrAdminBloqueMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le rôle Admin est un rôle système : ses permissions ne peuvent pas être modifiées.'**
  String get usrAdminBloqueMessage;

  /// No description provided for @usrRoleBloqueSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Rôle système Admin'**
  String get usrRoleBloqueSysteme;

  /// No description provided for @usrRoleBloqueUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Des utilisateurs ont ce rôle : réaffectez-les'**
  String get usrRoleBloqueUtilisateurs;

  /// No description provided for @usrRolesDesactives.
  ///
  /// In fr, this message translates to:
  /// **'Rôles désactivés'**
  String get usrRolesDesactives;

  /// No description provided for @usrNbUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'{n} utilisateur(s)'**
  String usrNbUtilisateurs(int n);

  /// No description provided for @usrCopie.
  ///
  /// In fr, this message translates to:
  /// **'{nom} (copie)'**
  String usrCopie(String nom);

  /// No description provided for @usrRoleErrModules.
  ///
  /// In fr, this message translates to:
  /// **'Cochez au moins un module'**
  String get usrRoleErrModules;

  /// No description provided for @usrRoleErrInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Rôle introuvable'**
  String get usrRoleErrInconnu;

  /// No description provided for @usrAucunUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur.'**
  String get usrAucunUtilisateur;

  /// No description provided for @usrAucunRole.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rôle.'**
  String get usrAucunRole;

  /// No description provided for @zkEntite.
  ///
  /// In fr, this message translates to:
  /// **'calculs'**
  String get zkEntite;

  /// No description provided for @zkEntiteUn.
  ///
  /// In fr, this message translates to:
  /// **'calcul'**
  String get zkEntiteUn;

  /// No description provided for @zkKpiCapital.
  ///
  /// In fr, this message translates to:
  /// **'Capital {annee} (provisoire)'**
  String zkKpiCapital(int annee);

  /// No description provided for @zkKpiNissab.
  ///
  /// In fr, this message translates to:
  /// **'Nissab actuel'**
  String get zkKpiNissab;

  /// No description provided for @zkKpiEstimee.
  ///
  /// In fr, this message translates to:
  /// **'Zakat estimée {annee}'**
  String zkKpiEstimee(int annee);

  /// No description provided for @zkKpiEcheance.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get zkKpiEcheance;

  /// No description provided for @zkJours.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get zkJours;

  /// No description provided for @zkColCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get zkColCode;

  /// No description provided for @zkColAnnee.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get zkColAnnee;

  /// No description provided for @zkColCapital.
  ///
  /// In fr, this message translates to:
  /// **'Capital'**
  String get zkColCapital;

  /// No description provided for @zkColNissab.
  ///
  /// In fr, this message translates to:
  /// **'Nissab'**
  String get zkColNissab;

  /// No description provided for @zkColObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get zkColObligatoire;

  /// No description provided for @zkOui.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get zkOui;

  /// No description provided for @zkNon.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get zkNon;

  /// No description provided for @zkColZakat.
  ///
  /// In fr, this message translates to:
  /// **'Zakat'**
  String get zkColZakat;

  /// No description provided for @zkColDue.
  ///
  /// In fr, this message translates to:
  /// **'Due le'**
  String get zkColDue;

  /// No description provided for @zkColPayee.
  ///
  /// In fr, this message translates to:
  /// **'Payée le'**
  String get zkColPayee;

  /// No description provided for @zkColStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get zkColStatut;

  /// No description provided for @zkColStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get zkColStock;

  /// No description provided for @zkColLiquidites.
  ///
  /// In fr, this message translates to:
  /// **'Liquidités'**
  String get zkColLiquidites;

  /// No description provided for @zkColCreances.
  ///
  /// In fr, this message translates to:
  /// **'Créances'**
  String get zkColCreances;

  /// No description provided for @zkColDettes.
  ///
  /// In fr, this message translates to:
  /// **'Dettes'**
  String get zkColDettes;

  /// No description provided for @zkColTaux.
  ///
  /// In fr, this message translates to:
  /// **'Taux'**
  String get zkColTaux;

  /// No description provided for @zkColHawl.
  ///
  /// In fr, this message translates to:
  /// **'Début du hawl'**
  String get zkColHawl;

  /// No description provided for @zkColObservation.
  ///
  /// In fr, this message translates to:
  /// **'Observation'**
  String get zkColObservation;

  /// No description provided for @zkColCreePar.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get zkColCreePar;

  /// No description provided for @zkExoneree.
  ///
  /// In fr, this message translates to:
  /// **'Exonérée'**
  String get zkExoneree;

  /// No description provided for @zkAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get zkAnnulee;

  /// No description provided for @zkMarquerPayee.
  ///
  /// In fr, this message translates to:
  /// **'Marquer payée'**
  String get zkMarquerPayee;

  /// No description provided for @zkAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get zkAnnuler;

  /// No description provided for @zkNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau calcul'**
  String get zkNouveau;

  /// No description provided for @zkNouveauTitre.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau calcul de zakat'**
  String get zkNouveauTitre;

  /// No description provided for @zkModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la zakat'**
  String get zkModifierTitre;

  /// No description provided for @zkSectionPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période (hawl)'**
  String get zkSectionPeriode;

  /// No description provided for @zkSectionPatrimoine.
  ///
  /// In fr, this message translates to:
  /// **'Patrimoine'**
  String get zkSectionPatrimoine;

  /// No description provided for @zkDebutHawl.
  ///
  /// In fr, this message translates to:
  /// **'Début du hawl'**
  String get zkDebutHawl;

  /// No description provided for @zkDueLe.
  ///
  /// In fr, this message translates to:
  /// **'Zakat due le'**
  String get zkDueLe;

  /// No description provided for @zkDueIndice.
  ///
  /// In fr, this message translates to:
  /// **'Début + 354 jours (année lunaire)'**
  String get zkDueIndice;

  /// No description provided for @zkValeurStock.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock'**
  String get zkValeurStock;

  /// No description provided for @zkStockIndice.
  ///
  /// In fr, this message translates to:
  /// **'Au prix d\'achat'**
  String get zkStockIndice;

  /// No description provided for @zkLiquiditesIndice.
  ///
  /// In fr, this message translates to:
  /// **'Caisses + banque'**
  String get zkLiquiditesIndice;

  /// No description provided for @zkCreancesIndice.
  ///
  /// In fr, this message translates to:
  /// **'Crédits clients recouvrables'**
  String get zkCreancesIndice;

  /// No description provided for @zkDettesCourt.
  ///
  /// In fr, this message translates to:
  /// **'Dettes à court terme'**
  String get zkDettesCourt;

  /// No description provided for @zkDettesIndice.
  ///
  /// In fr, this message translates to:
  /// **'Crédits fournisseurs'**
  String get zkDettesIndice;

  /// No description provided for @zkNissabIndice.
  ///
  /// In fr, this message translates to:
  /// **'85 g d\'or × cours du jour'**
  String get zkNissabIndice;

  /// No description provided for @zkReprendre.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre : {libelle}'**
  String zkReprendre(String libelle);

  /// No description provided for @zkRepValeurStock.
  ///
  /// In fr, this message translates to:
  /// **'valeur du stock'**
  String get zkRepValeurStock;

  /// No description provided for @zkRepSoldes.
  ///
  /// In fr, this message translates to:
  /// **'soldes des caisses'**
  String get zkRepSoldes;

  /// No description provided for @zkRepCreances.
  ///
  /// In fr, this message translates to:
  /// **'crédits clients'**
  String get zkRepCreances;

  /// No description provided for @zkRepDettes.
  ///
  /// In fr, this message translates to:
  /// **'crédits fournisseurs'**
  String get zkRepDettes;

  /// No description provided for @zkCapitalSoumis.
  ///
  /// In fr, this message translates to:
  /// **'Capital soumis'**
  String get zkCapitalSoumis;

  /// No description provided for @zkAuDessus.
  ///
  /// In fr, this message translates to:
  /// **'Au-dessus du nissab'**
  String get zkAuDessus;

  /// No description provided for @zkEnDessous.
  ///
  /// In fr, this message translates to:
  /// **'En dessous du nissab'**
  String get zkEnDessous;

  /// No description provided for @zkObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Zakat obligatoire'**
  String get zkObligatoire;

  /// No description provided for @zkMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant de la zakat'**
  String get zkMontant;

  /// No description provided for @zkFormule.
  ///
  /// In fr, this message translates to:
  /// **'Capital = stock + liquidités + créances − dettes. Montant = capital × {taux} % si capital ≥ nissab.'**
  String zkFormule(String taux);

  /// No description provided for @zkEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Calcul enregistré'**
  String get zkEnregistre;

  /// No description provided for @zkPayeeToast.
  ///
  /// In fr, this message translates to:
  /// **'Zakat marquée payée'**
  String get zkPayeeToast;

  /// No description provided for @zkAnnules.
  ///
  /// In fr, this message translates to:
  /// **'Calculs annulés'**
  String get zkAnnules;

  /// No description provided for @zkDetailTitre.
  ///
  /// In fr, this message translates to:
  /// **'Zakat {annee}'**
  String zkDetailTitre(int annee);

  /// No description provided for @zkDetailDescription.
  ///
  /// In fr, this message translates to:
  /// **'{code} · hawl {debut} → {fin}'**
  String zkDetailDescription(String code, String debut, String fin);

  /// No description provided for @zkCalcul.
  ///
  /// In fr, this message translates to:
  /// **'Calcul'**
  String get zkCalcul;

  /// No description provided for @zkPoste.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get zkPoste;

  /// No description provided for @zkMontantCol.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get zkMontantCol;

  /// No description provided for @zkAudit.
  ///
  /// In fr, this message translates to:
  /// **'Audit'**
  String get zkAudit;

  /// No description provided for @zkMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get zkMotif;

  /// No description provided for @zkBloqueePayee.
  ///
  /// In fr, this message translates to:
  /// **'Déjà payée'**
  String get zkBloqueePayee;

  /// No description provided for @zkBloqueeAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Déjà annulée'**
  String get zkBloqueeAnnulee;

  /// No description provided for @zkErrValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs invalides (montants positifs, échéance après le début du hawl)'**
  String get zkErrValeur;

  /// No description provided for @zkErrInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Calcul introuvable'**
  String get zkErrInconnue;

  /// No description provided for @zkErrMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif obligatoire'**
  String get zkErrMotif;

  /// No description provided for @zkAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun calcul de zakat.'**
  String get zkAucun;

  /// No description provided for @hiEntite.
  ///
  /// In fr, this message translates to:
  /// **'actions'**
  String get hiEntite;

  /// No description provided for @hiKpiActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions (7 j)'**
  String get hiKpiActions;

  /// No description provided for @hiKpiCreations.
  ///
  /// In fr, this message translates to:
  /// **'Créations'**
  String get hiKpiCreations;

  /// No description provided for @hiKpiModifications.
  ///
  /// In fr, this message translates to:
  /// **'Modifications'**
  String get hiKpiModifications;

  /// No description provided for @hiKpiAnnulations.
  ///
  /// In fr, this message translates to:
  /// **'Annulations'**
  String get hiKpiAnnulations;

  /// No description provided for @hiModule.
  ///
  /// In fr, this message translates to:
  /// **'Module'**
  String get hiModule;

  /// No description provided for @hiAction.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get hiAction;

  /// No description provided for @hiUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get hiUtilisateur;

  /// No description provided for @hiPoste.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get hiPoste;

  /// No description provided for @hiTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get hiTous;

  /// No description provided for @hiToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get hiToutes;

  /// No description provided for @hiRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Réf. ou description…'**
  String get hiRecherche;

  /// No description provided for @hiColDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get hiColDate;

  /// No description provided for @hiColRef.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get hiColRef;

  /// No description provided for @hiColDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get hiColDescription;

  /// No description provided for @hiColCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get hiColCode;

  /// No description provided for @hiAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune action sur la période.'**
  String get hiAucun;

  /// No description provided for @hiDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get hiDetail;

  /// No description provided for @hiSectionAction.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get hiSectionAction;

  /// No description provided for @hiSectionContexte.
  ///
  /// In fr, this message translates to:
  /// **'Contexte'**
  String get hiSectionContexte;

  /// No description provided for @hiReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get hiReference;

  /// No description provided for @hiEntiteTechnique.
  ///
  /// In fr, this message translates to:
  /// **'Entité'**
  String get hiEntiteTechnique;

  /// No description provided for @hiModuleConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get hiModuleConnexion;

  /// No description provided for @hiCatCreation.
  ///
  /// In fr, this message translates to:
  /// **'Création'**
  String get hiCatCreation;

  /// No description provided for @hiCatModification.
  ///
  /// In fr, this message translates to:
  /// **'Modification'**
  String get hiCatModification;

  /// No description provided for @hiCatAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annulation'**
  String get hiCatAnnulation;

  /// No description provided for @hiCatConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get hiCatConnexion;

  /// No description provided for @hiCatExport.
  ///
  /// In fr, this message translates to:
  /// **'Export'**
  String get hiCatExport;

  /// No description provided for @hiActCreation.
  ///
  /// In fr, this message translates to:
  /// **'Création'**
  String get hiActCreation;

  /// No description provided for @hiActModification.
  ///
  /// In fr, this message translates to:
  /// **'Modification'**
  String get hiActModification;

  /// No description provided for @hiActAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annulation'**
  String get hiActAnnulation;

  /// No description provided for @hiActDesactivation.
  ///
  /// In fr, this message translates to:
  /// **'Désactivation'**
  String get hiActDesactivation;

  /// No description provided for @hiActActivation.
  ///
  /// In fr, this message translates to:
  /// **'Activation'**
  String get hiActActivation;

  /// No description provided for @hiActSuppression.
  ///
  /// In fr, this message translates to:
  /// **'Suppression'**
  String get hiActSuppression;

  /// No description provided for @hiActVersement.
  ///
  /// In fr, this message translates to:
  /// **'Versement'**
  String get hiActVersement;

  /// No description provided for @hiActTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get hiActTransfert;

  /// No description provided for @hiActReinitialisation.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation du mot de passe'**
  String get hiActReinitialisation;

  /// No description provided for @hiActRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get hiActRetour;

  /// No description provided for @hiActParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get hiActParametres;

  /// No description provided for @hiActOuverture.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get hiActOuverture;

  /// No description provided for @hiActFermeture.
  ///
  /// In fr, this message translates to:
  /// **'Fermeture'**
  String get hiActFermeture;

  /// No description provided for @hiActEncaissement.
  ///
  /// In fr, this message translates to:
  /// **'Encaissement'**
  String get hiActEncaissement;

  /// No description provided for @hiActConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get hiActConnexion;

  /// No description provided for @hiActDeconnexion.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get hiActDeconnexion;

  /// No description provided for @hiActConfiguration.
  ///
  /// In fr, this message translates to:
  /// **'Configuration initiale'**
  String get hiActConfiguration;

  /// No description provided for @hiActClotureZ.
  ///
  /// In fr, this message translates to:
  /// **'Clôture Z'**
  String get hiActClotureZ;

  /// No description provided for @hiActAffectation.
  ///
  /// In fr, this message translates to:
  /// **'Affectation'**
  String get hiActAffectation;

  /// No description provided for @hiActAchat.
  ///
  /// In fr, this message translates to:
  /// **'Achat'**
  String get hiActAchat;

  /// No description provided for @hiActApport.
  ///
  /// In fr, this message translates to:
  /// **'Apport'**
  String get hiActApport;

  /// No description provided for @hiActDepense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get hiActDepense;

  /// No description provided for @hiActPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get hiActPaiement;

  /// No description provided for @hiActExport.
  ///
  /// In fr, this message translates to:
  /// **'Export'**
  String get hiActExport;

  /// No description provided for @pmNonEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Modifications non enregistrées'**
  String get pmNonEnregistre;

  /// No description provided for @pmEnregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get pmEnregistrer;

  /// No description provided for @pmEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés'**
  String get pmEnregistre;

  /// No description provided for @pmGrpSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get pmGrpSysteme;

  /// No description provided for @pmGrpBoutique.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get pmGrpBoutique;

  /// No description provided for @pmGrpCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse et ventes'**
  String get pmGrpCaisse;

  /// No description provided for @pmGrpImpression.
  ///
  /// In fr, this message translates to:
  /// **'Impression'**
  String get pmGrpImpression;

  /// No description provided for @pmGrpAlertes.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get pmGrpAlertes;

  /// No description provided for @pmGrpSauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get pmGrpSauvegarde;

  /// No description provided for @pmGrpLicence.
  ///
  /// In fr, this message translates to:
  /// **'Licence'**
  String get pmGrpLicence;

  /// No description provided for @pmTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get pmTheme;

  /// No description provided for @pmThemeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Clair pour la journée, sombre pour les écrans de caisse en faible lumière.'**
  String get pmThemeDesc;

  /// No description provided for @pmClair.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get pmClair;

  /// No description provided for @pmSombre.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get pmSombre;

  /// No description provided for @pmLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'interface'**
  String get pmLangue;

  /// No description provided for @pmLangueDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'arabe active la mise en page de droite à gauche et la police Cairo.'**
  String get pmLangueDesc;

  /// No description provided for @pmDevise.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get pmDevise;

  /// No description provided for @pmDeviseDesc.
  ///
  /// In fr, this message translates to:
  /// **'Affichée sur les montants, tickets et factures.'**
  String get pmDeviseDesc;

  /// No description provided for @pmDecimales.
  ///
  /// In fr, this message translates to:
  /// **'Décimales des quantités'**
  String get pmDecimales;

  /// No description provided for @pmDecimalesDesc.
  ///
  /// In fr, this message translates to:
  /// **'0 pour les articles à l\'unité, 3 pour la vente au poids (kg).'**
  String get pmDecimalesDesc;

  /// No description provided for @pmMargeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Marge par défaut'**
  String get pmMargeTitre;

  /// No description provided for @pmMargeInfo.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée aux nouveaux produits et proposée dans l\'entrée'**
  String get pmMargeInfo;

  /// No description provided for @pmMargeType.
  ///
  /// In fr, this message translates to:
  /// **'Type de marge'**
  String get pmMargeType;

  /// No description provided for @pmMargeTypeDesc.
  ///
  /// In fr, this message translates to:
  /// **'En montant fixe ou en pourcentage du prix d\'achat.'**
  String get pmMargeTypeDesc;

  /// No description provided for @pmMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get pmMontant;

  /// No description provided for @pmPourcentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get pmPourcentage;

  /// No description provided for @pmMargeValeur.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get pmMargeValeur;

  /// No description provided for @pmMargeValeurDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente = achat + marge.'**
  String get pmMargeValeurDesc;

  /// No description provided for @pmSeuilsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Seuils de stock globaux'**
  String get pmSeuilsTitre;

  /// No description provided for @pmSeuilsInfo.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs par défaut, modifiables produit par produit'**
  String get pmSeuilsInfo;

  /// No description provided for @pmSeuilMin.
  ///
  /// In fr, this message translates to:
  /// **'Seuil minimum (rupture)'**
  String get pmSeuilMin;

  /// No description provided for @pmSeuilMinDesc.
  ///
  /// In fr, this message translates to:
  /// **'Alerte quand le stock passe sous ce seuil.'**
  String get pmSeuilMinDesc;

  /// No description provided for @pmSeuilMax.
  ///
  /// In fr, this message translates to:
  /// **'Seuil maximum'**
  String get pmSeuilMax;

  /// No description provided for @pmSeuilMaxDesc.
  ///
  /// In fr, this message translates to:
  /// **'Signale un sur-stock ; 0 pour aucun.'**
  String get pmSeuilMaxDesc;

  /// No description provided for @pmPieces.
  ///
  /// In fr, this message translates to:
  /// **'pcs'**
  String get pmPieces;

  /// No description provided for @pmGarde.
  ///
  /// In fr, this message translates to:
  /// **'Garde de stock'**
  String get pmGarde;

  /// No description provided for @pmGardeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Toujours active : le stock ne devient jamais négatif.'**
  String get pmGardeDesc;

  /// No description provided for @pmGardeCaisseDesc.
  ///
  /// In fr, this message translates to:
  /// **'Toujours active : le stock ne devient jamais négatif, un produit à 0 ne s\'encaisse pas.'**
  String get pmGardeCaisseDesc;

  /// No description provided for @pmNonDesactivable.
  ///
  /// In fr, this message translates to:
  /// **'Non désactivable'**
  String get pmNonDesactivable;

  /// No description provided for @pmZakatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Zakat'**
  String get pmZakatTitre;

  /// No description provided for @pmNissab.
  ///
  /// In fr, this message translates to:
  /// **'Nissab'**
  String get pmNissab;

  /// No description provided for @pmNissabDesc.
  ///
  /// In fr, this message translates to:
  /// **'Valeur de 85 g d\'or ; proposée à chaque calcul.'**
  String get pmNissabDesc;

  /// No description provided for @pmTaux.
  ///
  /// In fr, this message translates to:
  /// **'Taux'**
  String get pmTaux;

  /// No description provided for @pmTauxDesc.
  ///
  /// In fr, this message translates to:
  /// **'Taux appliqué à l\'assiette.'**
  String get pmTauxDesc;

  /// No description provided for @pmServeursTitre.
  ///
  /// In fr, this message translates to:
  /// **'Services en ligne'**
  String get pmServeursTitre;

  /// No description provided for @pmServeursInfo.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue partagé et recherche de produits par code-barres'**
  String get pmServeursInfo;

  /// No description provided for @pmServeurUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du serveur CaisseDZ'**
  String get pmServeurUrl;

  /// No description provided for @pmServeurCle.
  ///
  /// In fr, this message translates to:
  /// **'Clé d\'API'**
  String get pmServeurCle;

  /// No description provided for @pmMantouj.
  ///
  /// In fr, this message translates to:
  /// **'URL Mantouj'**
  String get pmMantouj;

  /// No description provided for @pmSynchro.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser le catalogue'**
  String get pmSynchro;

  /// No description provided for @pmSynchroDesc.
  ///
  /// In fr, this message translates to:
  /// **'Envoie vos fiches et récupère les fiches enrichies du catalogue partagé.'**
  String get pmSynchroDesc;

  /// No description provided for @pmSynchroBouton.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get pmSynchroBouton;

  /// No description provided for @pmLogo.
  ///
  /// In fr, this message translates to:
  /// **'Logo'**
  String get pmLogo;

  /// No description provided for @pmLogoAide.
  ///
  /// In fr, this message translates to:
  /// **'PNG transparent · imprimé en haut du ticket'**
  String get pmLogoAide;

  /// No description provided for @pmRaisonSociale.
  ///
  /// In fr, this message translates to:
  /// **'Raison sociale'**
  String get pmRaisonSociale;

  /// No description provided for @pmTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get pmTelephone;

  /// No description provided for @pmAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get pmAdresse;

  /// No description provided for @pmRc.
  ///
  /// In fr, this message translates to:
  /// **'RC'**
  String get pmRc;

  /// No description provided for @pmNif.
  ///
  /// In fr, this message translates to:
  /// **'NIF'**
  String get pmNif;

  /// No description provided for @pmNis.
  ///
  /// In fr, this message translates to:
  /// **'NIS'**
  String get pmNis;

  /// No description provided for @pmArticle.
  ///
  /// In fr, this message translates to:
  /// **'Article d\'imposition'**
  String get pmArticle;

  /// No description provided for @pmEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get pmEmail;

  /// No description provided for @pmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message du ticket'**
  String get pmMessage;

  /// No description provided for @pmMessageAide.
  ///
  /// In fr, this message translates to:
  /// **'Imprimé en bas de chaque ticket'**
  String get pmMessageAide;

  /// No description provided for @pmModesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get pmModesTitre;

  /// No description provided for @pmModesInfo.
  ///
  /// In fr, this message translates to:
  /// **'Proposés dans le dialog d\'encaissement ; les espèces sont toujours acceptées, les points seulement avec le bonus fidélité actif et un client identifié'**
  String get pmModesInfo;

  /// No description provided for @pmReglesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Règles de vente'**
  String get pmReglesTitre;

  /// No description provided for @pmSousAchat.
  ///
  /// In fr, this message translates to:
  /// **'Vente sous le prix d\'achat'**
  String get pmSousAchat;

  /// No description provided for @pmSousAchatDesc.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser, avertir ou interdire un prix de vente inférieur au prix d\'achat.'**
  String get pmSousAchatDesc;

  /// No description provided for @pmFideliteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Fidélité'**
  String get pmFideliteTitre;

  /// No description provided for @pmBonus.
  ///
  /// In fr, this message translates to:
  /// **'Bonus fidélité'**
  String get pmBonus;

  /// No description provided for @pmBonusDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les clients identifiés gagnent des points à chaque encaissement.'**
  String get pmBonusDesc;

  /// No description provided for @pmTauxGain.
  ///
  /// In fr, this message translates to:
  /// **'Taux de gain'**
  String get pmTauxGain;

  /// No description provided for @pmTauxGainDesc.
  ///
  /// In fr, this message translates to:
  /// **'Points gagnés par tranche d\'achat.'**
  String get pmTauxGainDesc;

  /// No description provided for @pmPointPar.
  ///
  /// In fr, this message translates to:
  /// **'point /'**
  String get pmPointPar;

  /// No description provided for @pmImprimanteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante ticket'**
  String get pmImprimanteTitre;

  /// No description provided for @pmTypeBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get pmTypeBluetooth;

  /// No description provided for @pmTypeBluetoothDesc.
  ///
  /// In fr, this message translates to:
  /// **'Appairée sous Windows'**
  String get pmTypeBluetoothDesc;

  /// No description provided for @pmTypeUsb.
  ///
  /// In fr, this message translates to:
  /// **'USB'**
  String get pmTypeUsb;

  /// No description provided for @pmTypeUsbDesc.
  ///
  /// In fr, this message translates to:
  /// **'File d\'attente Windows (ESC/POS)'**
  String get pmTypeUsbDesc;

  /// No description provided for @pmTypeReseau.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get pmTypeReseau;

  /// No description provided for @pmTypeReseauDesc.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP et port'**
  String get pmTypeReseauDesc;

  /// No description provided for @pmTypeNormale.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get pmTypeNormale;

  /// No description provided for @pmTypeNormaleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante Windows'**
  String get pmTypeNormaleDesc;

  /// No description provided for @pmAdresseIp.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP:port'**
  String get pmAdresseIp;

  /// No description provided for @pmAdresseBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'File d\'attente Bluetooth'**
  String get pmAdresseBluetooth;

  /// No description provided for @pmFileUsb.
  ///
  /// In fr, this message translates to:
  /// **'File d\'attente Windows'**
  String get pmFileUsb;

  /// No description provided for @pmLargeur.
  ///
  /// In fr, this message translates to:
  /// **'Largeur'**
  String get pmLargeur;

  /// No description provided for @pmTest.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer un test'**
  String get pmTest;

  /// No description provided for @pmTestOk.
  ///
  /// In fr, this message translates to:
  /// **'Test envoyé : la page de test est sortie sur {cible}.'**
  String pmTestOk(String cible);

  /// No description provided for @pmAlertesConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les alertes à la connexion'**
  String get pmAlertesConnexion;

  /// No description provided for @pmAlertesConnexionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ruptures, crédits élevés, sessions non clôturées.'**
  String get pmAlertesConnexionDesc;

  /// No description provided for @pmSeuilCredit.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de crédit client'**
  String get pmSeuilCredit;

  /// No description provided for @pmSeuilCreditDesc.
  ///
  /// In fr, this message translates to:
  /// **'Signale les clients au-delà de ce montant ; 0 pour tous.'**
  String get pmSeuilCreditDesc;

  /// No description provided for @pmSauverMaintenant.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder maintenant'**
  String get pmSauverMaintenant;

  /// No description provided for @pmSauvegardeTerminee.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde terminée'**
  String get pmSauvegardeTerminee;

  /// No description provided for @pmRestaurerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Remplace toutes les données actuelles par celles d\'un fichier.'**
  String get pmRestaurerDesc;

  /// No description provided for @pmRestaurerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer…'**
  String get pmRestaurerBouton;

  /// No description provided for @pmRestaurerConfirmTitre.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde ?'**
  String get pmRestaurerConfirmTitre;

  /// No description provided for @pmRestaurerConfirmMsg.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données actuelles (ventes, stock, clients…) seront remplacées au prochain démarrage.'**
  String get pmRestaurerConfirmMsg;

  /// No description provided for @pmRestaurerConfirmOk.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier et restaurer'**
  String get pmRestaurerConfirmOk;

  /// No description provided for @pmPalierAvance.
  ///
  /// In fr, this message translates to:
  /// **'Palier Avancé'**
  String get pmPalierAvance;

  /// No description provided for @pmPalierAvanceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un magasin, 5 caissiers : devis, commandes, commandes fournisseurs et besoins.'**
  String get pmPalierAvanceDesc;

  /// No description provided for @pmPalierBasic.
  ///
  /// In fr, this message translates to:
  /// **'Palier Basic'**
  String get pmPalierBasic;

  /// No description provided for @pmPalierBasicDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un magasin, 5 caissiers : caisse, ventes, stock, clients et fournisseurs.'**
  String get pmPalierBasicDesc;

  /// No description provided for @pmPalierDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo'**
  String get pmPalierDemo;

  /// No description provided for @pmPalierDemoDesc.
  ///
  /// In fr, this message translates to:
  /// **'Données fictives, réinitialisées à la fermeture'**
  String get pmPalierDemoDesc;

  /// No description provided for @pmPalierAucun.
  ///
  /// In fr, this message translates to:
  /// **'Application non activée'**
  String get pmPalierAucun;

  /// No description provided for @pmPalierAucunDesc.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une formule, connectez-vous à votre compte ou collez une clé.'**
  String get pmPalierAucunDesc;

  /// No description provided for @pmActive.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get pmActive;

  /// No description provided for @pmCle.
  ///
  /// In fr, this message translates to:
  /// **'Clé de licence'**
  String get pmCle;

  /// No description provided for @pmCleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Liée à ce poste.'**
  String get pmCleDesc;

  /// No description provided for @pmActiveeLe.
  ///
  /// In fr, this message translates to:
  /// **'Activée le {date}.'**
  String pmActiveeLe(String date);

  /// No description provided for @pmGererLicence.
  ///
  /// In fr, this message translates to:
  /// **'Gérer la licence'**
  String get pmGererLicence;

  /// No description provided for @pmGererLicenceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Coller une clé reçue de BENS (secours hors ligne).'**
  String get pmGererLicenceDesc;

  /// No description provided for @posPrixSousAchatInterdit.
  ///
  /// In fr, this message translates to:
  /// **'Prix inférieur au prix d\'achat : interdit par les paramètres.'**
  String get posPrixSousAchatInterdit;

  /// No description provided for @alertesExpireDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Expiré depuis {n} j'**
  String alertesExpireDepuis(int n);

  /// No description provided for @communSessionRequise.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session de caisse ouverte : ouvrez une session avant d\'enregistrer.'**
  String get communSessionRequise;

  /// No description provided for @communFermeeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez une session pour « {caisse} » avant d\'enregistrer cette opération.'**
  String communFermeeDesc(String caisse);

  /// No description provided for @posRaccourciE.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide (achat d’un produit)'**
  String get posRaccourciE;

  /// No description provided for @hiActSauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get hiActSauvegarde;

  /// No description provided for @hiActRestauration.
  ///
  /// In fr, this message translates to:
  /// **'Restauration'**
  String get hiActRestauration;

  /// No description provided for @posApercuTicket.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du ticket'**
  String get posApercuTicket;

  /// No description provided for @posImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get posImprimer;

  /// No description provided for @posGabaritLatin.
  ///
  /// In fr, this message translates to:
  /// **'Latin'**
  String get posGabaritLatin;

  /// No description provided for @pmApercuAucuneVente.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente enregistrée : l’aperçu utilise un ticket d’exemple.'**
  String get pmApercuAucuneVente;

  /// No description provided for @pmSauvegardeIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique : choisissez un dossier et un mot de passe.'**
  String get pmSauvegardeIncomplete;

  /// No description provided for @pmSauvegardeDossier.
  ///
  /// In fr, this message translates to:
  /// **'Dossier de sauvegarde'**
  String get pmSauvegardeDossier;

  /// No description provided for @pmSauvegardeDossierDesc.
  ///
  /// In fr, this message translates to:
  /// **'Disque local, clé USB ou dossier synchronisé (Google Drive, OneDrive).'**
  String get pmSauvegardeDossierDesc;

  /// No description provided for @pmSauvegardeChanger.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get pmSauvegardeChanger;

  /// No description provided for @pmSauvegardeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique'**
  String get pmSauvegardeAuto;

  /// No description provided for @pmSauvegardeAutoDesc.
  ///
  /// In fr, this message translates to:
  /// **'Faite à l’ouverture de l’application ; les 30 dernières sont conservées.'**
  String get pmSauvegardeAutoDesc;

  /// No description provided for @pmFrequenceDesactivee.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get pmFrequenceDesactivee;

  /// No description provided for @pmFrequenceDemarrage.
  ///
  /// In fr, this message translates to:
  /// **'À chaque démarrage'**
  String get pmFrequenceDemarrage;

  /// No description provided for @pmFrequenceQuotidienne.
  ///
  /// In fr, this message translates to:
  /// **'Quotidienne'**
  String get pmFrequenceQuotidienne;

  /// No description provided for @pmSauvegardeMdp.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe des sauvegardes'**
  String get pmSauvegardeMdp;

  /// No description provided for @pmSauvegardeMdpDesc.
  ///
  /// In fr, this message translates to:
  /// **'Demandé pour restaurer une sauvegarde automatique.'**
  String get pmSauvegardeMdpDesc;

  /// No description provided for @pmSauvegardeMdpDefinir.
  ///
  /// In fr, this message translates to:
  /// **'Définir'**
  String get pmSauvegardeMdpDefinir;

  /// No description provided for @pmSauvegardeMdpChanger.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get pmSauvegardeMdpChanger;

  /// No description provided for @pmSauvegardeDerniere.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde automatique : {date}'**
  String pmSauvegardeDerniere(String date);

  /// No description provided for @communModifiePar.
  ///
  /// In fr, this message translates to:
  /// **'Modifié par'**
  String get communModifiePar;

  /// No description provided for @communModifieLe.
  ///
  /// In fr, this message translates to:
  /// **'Modifié le'**
  String get communModifieLe;

  /// No description provided for @communNombreObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Le nombre de pièces (2ᵉ stock) est obligatoire pour ce produit.'**
  String get communNombreObligatoire;

  /// No description provided for @stkNombre.
  ///
  /// In fr, this message translates to:
  /// **'Nombre'**
  String get stkNombre;

  /// No description provided for @stkNombreObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Nombre obligatoire'**
  String get stkNombreObligatoire;

  /// No description provided for @pmNombreActif.
  ///
  /// In fr, this message translates to:
  /// **'2ᵉ stock « nombre » pour tous les produits'**
  String get pmNombreActif;

  /// No description provided for @pmNombreActifDesc.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pièces saisi en plus de la quantité (ex. boucherie : kg + pièces), obligatoire à chaque mouvement.'**
  String get pmNombreActifDesc;

  /// No description provided for @dsFavorisAide.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez sur un module pour l\'ajouter à vos favoris ou l\'en retirer ({max} au maximum).'**
  String dsFavorisAide(int max);

  /// No description provided for @dsFavorisAideComplets.
  ///
  /// In fr, this message translates to:
  /// **'Vos {max} favoris sont choisis : retirez-en un pour en ajouter un autre.'**
  String dsFavorisAideComplets(int max);

  /// No description provided for @shellChoisirFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les favoris'**
  String get shellChoisirFavoris;

  /// No description provided for @communTermine.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get communTermine;

  /// No description provided for @posRechMin.
  ///
  /// In fr, this message translates to:
  /// **'Min'**
  String get posRechMin;

  /// No description provided for @posRechMax.
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get posRechMax;

  /// No description provided for @posRechToutesCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get posRechToutesCategories;

  /// No description provided for @posMontantTitre.
  ///
  /// In fr, this message translates to:
  /// **'Vente au montant'**
  String get posMontantTitre;

  /// No description provided for @posMontantColis.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get posMontantColis;

  /// No description provided for @posMontantAide.
  ///
  /// In fr, this message translates to:
  /// **'Article pesé ou non codifié : le montant s\'ajoute à une seule ligne du panier (200 puis 500 = 700).'**
  String get posMontantAide;

  /// No description provided for @posMontantAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre montant'**
  String get posMontantAutre;

  /// No description provided for @posMontantModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le montant'**
  String get posMontantModifier;

  /// No description provided for @posMontantChamp.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get posMontantChamp;

  /// No description provided for @posMontantInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un montant supérieur à 0.'**
  String get posMontantInvalide;

  /// No description provided for @posMontantLigneAide.
  ///
  /// In fr, this message translates to:
  /// **'Double-clic : modifier le montant'**
  String get posMontantLigneAide;

  /// No description provided for @ventesListeProduits.
  ///
  /// In fr, this message translates to:
  /// **'Liste des produits'**
  String get ventesListeProduits;

  /// No description provided for @ventesListeProduitsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produits du panier {code}'**
  String ventesListeProduitsTitre(String code);

  /// No description provided for @ventesColis.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get ventesColis;

  /// No description provided for @selRechercherListe.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans la liste'**
  String get selRechercherListe;

  /// No description provided for @selProduit.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un produit'**
  String get selProduit;

  /// No description provided for @selCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get selCategorie;

  /// No description provided for @selSousCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une sous-catégorie'**
  String get selSousCategorie;

  /// No description provided for @selRemise.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une remise'**
  String get selRemise;

  /// No description provided for @selPack.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un pack'**
  String get selPack;

  /// No description provided for @selClient.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client'**
  String get selClient;

  /// No description provided for @selFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fournisseur'**
  String get selFournisseur;

  /// No description provided for @selMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un magasin'**
  String get selMagasin;

  /// No description provided for @selCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une caisse'**
  String get selCaisse;

  /// No description provided for @selSession.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une session'**
  String get selSession;

  /// No description provided for @selUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un utilisateur'**
  String get selUtilisateur;

  /// No description provided for @selVente.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une vente'**
  String get selVente;

  /// No description provided for @selColCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get selColCode;

  /// No description provided for @selColNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get selColNom;

  /// No description provided for @selColDesignation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get selColDesignation;

  /// No description provided for @selColCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get selColCategorie;

  /// No description provided for @selColStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get selColStock;

  /// No description provided for @selColPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get selColPrix;

  /// No description provided for @selColTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get selColTelephone;

  /// No description provided for @selColAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get selColAdresse;

  /// No description provided for @selColType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get selColType;

  /// No description provided for @selColValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get selColValeur;

  /// No description provided for @selColMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get selColMagasin;

  /// No description provided for @selColCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get selColCaisse;

  /// No description provided for @selColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get selColUtilisateur;

  /// No description provided for @selColOuverture.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get selColOuverture;

  /// No description provided for @selColStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get selColStatut;

  /// No description provided for @selColDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get selColDate;

  /// No description provided for @selColClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get selColClient;

  /// No description provided for @selColTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get selColTotal;

  /// No description provided for @selColProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get selColProduits;

  /// No description provided for @selColDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get selColDescription;

  /// No description provided for @selFiltreEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get selFiltreEtat;

  /// No description provided for @selTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get selTous;

  /// No description provided for @selPoints.
  ///
  /// In fr, this message translates to:
  /// **'{n} points'**
  String selPoints(int n);

  /// No description provided for @selNbProduits.
  ///
  /// In fr, this message translates to:
  /// **'{n} produits'**
  String selNbProduits(int n);

  /// No description provided for @retoursNouveauClient.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau retour client'**
  String get retoursNouveauClient;

  /// No description provided for @retoursNouveauFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau retour fournisseur'**
  String get retoursNouveauFournisseur;

  /// No description provided for @prdPorteeProduitAide.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée automatiquement aux produits choisis, pendant sa période.'**
  String get prdPorteeProduitAide;

  /// No description provided for @prdPorteeMontantAide.
  ///
  /// In fr, this message translates to:
  /// **'Choisie sur le panier en caisse, dès que le sous-total atteint le seuil.'**
  String get prdPorteeMontantAide;

  /// No description provided for @prdMontantPanierAide.
  ///
  /// In fr, this message translates to:
  /// **'Ex. −500 {devise} sur le panier'**
  String prdMontantPanierAide(String devise);

  /// No description provided for @auditCreeLe.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get auditCreeLe;

  /// No description provided for @auditModifieLe.
  ///
  /// In fr, this message translates to:
  /// **'Modifié le'**
  String get auditModifieLe;

  /// No description provided for @auditModifiePar.
  ///
  /// In fr, this message translates to:
  /// **'Modifié par'**
  String get auditModifiePar;

  /// No description provided for @prdFiltreQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get prdFiltreQuantite;

  /// No description provided for @prdToastSuppression.
  ///
  /// In fr, this message translates to:
  /// **'Suppression effectuée'**
  String get prdToastSuppression;

  /// No description provided for @prdVersSansCategorie.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) → Sans catégorie'**
  String prdVersSansCategorie(int n);

  /// No description provided for @prdPackVendu.
  ///
  /// In fr, this message translates to:
  /// **'Déjà vendu : conservé pour l\'historique des ventes'**
  String get prdPackVendu;

  /// No description provided for @stkNombreDispo.
  ///
  /// In fr, this message translates to:
  /// **'Pièces : {quantite}'**
  String stkNombreDispo(String quantite);

  /// No description provided for @stkListeProduits.
  ///
  /// In fr, this message translates to:
  /// **'Liste des produits'**
  String get stkListeProduits;

  /// No description provided for @stkListeProduitsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produits de {code}'**
  String stkListeProduitsTitre(String code);

  /// No description provided for @stkAjouterSousSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Produits sous le seuil'**
  String get stkAjouterSousSeuil;

  /// No description provided for @stkAjouterRuptures.
  ///
  /// In fr, this message translates to:
  /// **'Produits en rupture'**
  String get stkAjouterRuptures;

  /// No description provided for @stkAucunProduitAjoute.
  ///
  /// In fr, this message translates to:
  /// **'Aucun nouveau produit à ajouter.'**
  String get stkAucunProduitAjoute;

  /// No description provided for @stkProduitsAjoutes.
  ///
  /// In fr, this message translates to:
  /// **'{n} produit(s) ajouté(s)'**
  String stkProduitsAjoutes(int n);

  /// No description provided for @entFiltreType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'entrée'**
  String get entFiltreType;

  /// No description provided for @entTypeNormale.
  ///
  /// In fr, this message translates to:
  /// **'Entrée normale'**
  String get entTypeNormale;

  /// No description provided for @tiersSoldeAvant.
  ///
  /// In fr, this message translates to:
  /// **'Solde avant'**
  String get tiersSoldeAvant;

  /// No description provided for @tiersSoldeApres.
  ///
  /// In fr, this message translates to:
  /// **'Solde après'**
  String get tiersSoldeApres;

  /// No description provided for @stkErreurSortieRetour.
  ///
  /// In fr, this message translates to:
  /// **'Sortie liée à un retour : modifiez ou annulez le retour.'**
  String get stkErreurSortieRetour;

  /// No description provided for @remiseSectionType.
  ///
  /// In fr, this message translates to:
  /// **'Type de remise'**
  String get remiseSectionType;

  /// No description provided for @remiseSectionInfos.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get remiseSectionInfos;

  /// No description provided for @remiseSectionCalcul.
  ///
  /// In fr, this message translates to:
  /// **'Valeur de la remise'**
  String get remiseSectionCalcul;

  /// No description provided for @remiseSectionPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période de validité'**
  String get remiseSectionPeriode;

  /// No description provided for @stkQteDansMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Qté dans {magasin}'**
  String stkQteDansMagasin(String magasin);

  /// No description provided for @stkStockMagasinN.
  ///
  /// In fr, this message translates to:
  /// **'{magasin} : {quantite}'**
  String stkStockMagasinN(String magasin, String quantite);

  /// No description provided for @versementErreurPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période clôturée : ce versement ne peut plus être modifié. Annulez-le puis saisissez un nouveau versement.'**
  String get versementErreurPeriode;

  /// No description provided for @retoursDateDuJour.
  ///
  /// In fr, this message translates to:
  /// **'Daté du jour, même après la clôture Z du jour de la vente.'**
  String get retoursDateDuJour;

  /// No description provided for @situationCasse.
  ///
  /// In fr, this message translates to:
  /// **'Casse (perte)'**
  String get situationCasse;

  /// No description provided for @situationPiecesTheoriques.
  ///
  /// In fr, this message translates to:
  /// **'Pièces théoriques'**
  String get situationPiecesTheoriques;

  /// No description provided for @situationPiecesComptees.
  ///
  /// In fr, this message translates to:
  /// **'Pièces comptées'**
  String get situationPiecesComptees;

  /// No description provided for @permDepasserPlafondCredit.
  ///
  /// In fr, this message translates to:
  /// **'Dépasser le plafond de crédit'**
  String get permDepasserPlafondCredit;

  /// No description provided for @posErreurPlafondCredit.
  ///
  /// In fr, this message translates to:
  /// **'Plafond de crédit du client dépassé ({plafond}, crédit actuel {solde}).'**
  String posErreurPlafondCredit(String plafond, String solde);

  /// No description provided for @tiersPlafondCredit.
  ///
  /// In fr, this message translates to:
  /// **'Plafond de crédit'**
  String get tiersPlafondCredit;

  /// No description provided for @tiersPlafondCreditAide.
  ///
  /// In fr, this message translates to:
  /// **'Vide ou 0 : sans plafond.'**
  String get tiersPlafondCreditAide;

  /// No description provided for @mvtCoffre.
  ///
  /// In fr, this message translates to:
  /// **'Coffre'**
  String get mvtCoffre;

  /// No description provided for @mvtTimbre.
  ///
  /// In fr, this message translates to:
  /// **'Droit de timbre'**
  String get mvtTimbre;

  /// No description provided for @retoursAvoirEmis.
  ///
  /// In fr, this message translates to:
  /// **'Un avoir a été émis pour ce retour (vente facturée) : il ne peut plus être modifié ni annulé.'**
  String get retoursAvoirEmis;

  /// No description provided for @tiersArticleImposition.
  ///
  /// In fr, this message translates to:
  /// **'Article d\'imposition'**
  String get tiersArticleImposition;

  /// No description provided for @pmRegimeFiscal.
  ///
  /// In fr, this message translates to:
  /// **'Régime fiscal'**
  String get pmRegimeFiscal;

  /// No description provided for @pmRegimeFiscalDesc.
  ///
  /// In fr, this message translates to:
  /// **'Réel : TVA collectée sur les ventes et déductible sur les entrées. IFU : ventes sans TVA.'**
  String get pmRegimeFiscalDesc;

  /// No description provided for @pmRegimeReel.
  ///
  /// In fr, this message translates to:
  /// **'Réel'**
  String get pmRegimeReel;

  /// No description provided for @pmRegimeIfu.
  ///
  /// In fr, this message translates to:
  /// **'IFU'**
  String get pmRegimeIfu;

  /// No description provided for @pmTimbre.
  ///
  /// In fr, this message translates to:
  /// **'Droit de timbre'**
  String get pmTimbre;

  /// No description provided for @pmTimbreDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux factures sur la part payée en espèces (1 % à 2 %, minimum 5 DA).'**
  String get pmTimbreDesc;

  /// No description provided for @factureVenteAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Vente annulée : aucune facture ne peut être émise.'**
  String get factureVenteAnnulee;

  /// No description provided for @exportFiscalG50.
  ///
  /// In fr, this message translates to:
  /// **'Déclaration G50 (Excel)'**
  String get exportFiscalG50;

  /// No description provided for @exportFiscalG50Desc.
  ///
  /// In fr, this message translates to:
  /// **'TVA collectée et déductible par taux, timbre, TVA à payer'**
  String get exportFiscalG50Desc;

  /// No description provided for @typeMouvementAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annulation de vente'**
  String get typeMouvementAnnulation;

  /// No description provided for @posErreurMonnaieSansEspeces.
  ///
  /// In fr, this message translates to:
  /// **'La monnaie rendue dépasse les espèces reçues : une carte, un chèque ou des points ne rendent pas de monnaie.'**
  String get posErreurMonnaieSansEspeces;

  /// No description provided for @tiersSoldeInitial.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get tiersSoldeInitial;

  /// No description provided for @tiersSoldeInitialAideClient.
  ///
  /// In fr, this message translates to:
  /// **'Reprise : montant dû par le client avant le logiciel (négatif = avance).'**
  String get tiersSoldeInitialAideClient;

  /// No description provided for @tiersSoldeInitialAideFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Reprise : montant dû au fournisseur avant le logiciel (négatif = avance).'**
  String get tiersSoldeInitialAideFournisseur;

  /// No description provided for @tvaRecapitulatif.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif TVA'**
  String get tvaRecapitulatif;

  /// No description provided for @tvaTaux.
  ///
  /// In fr, this message translates to:
  /// **'Taux TVA'**
  String get tvaTaux;

  /// No description provided for @tvaBaseHt.
  ///
  /// In fr, this message translates to:
  /// **'Base HT'**
  String get tvaBaseHt;

  /// No description provided for @tvaMontant.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get tvaMontant;

  /// No description provided for @tvaTtc.
  ///
  /// In fr, this message translates to:
  /// **'TTC'**
  String get tvaTtc;

  /// No description provided for @tvaCollectee.
  ///
  /// In fr, this message translates to:
  /// **'TVA collectée'**
  String get tvaCollectee;

  /// No description provided for @tvaDeductible.
  ///
  /// In fr, this message translates to:
  /// **'TVA déductible'**
  String get tvaDeductible;

  /// No description provided for @tvaNette.
  ///
  /// In fr, this message translates to:
  /// **'TVA à payer'**
  String get tvaNette;

  /// No description provided for @tvaHt.
  ///
  /// In fr, this message translates to:
  /// **'HT'**
  String get tvaHt;

  /// No description provided for @situationTva.
  ///
  /// In fr, this message translates to:
  /// **'TVA par taux'**
  String get situationTva;

  /// No description provided for @situationGroupeFiscalite.
  ///
  /// In fr, this message translates to:
  /// **'Fiscalité'**
  String get situationGroupeFiscalite;

  /// No description provided for @ventesOngletPaniers.
  ///
  /// In fr, this message translates to:
  /// **'Paniers'**
  String get ventesOngletPaniers;

  /// No description provided for @ventesOngletFactures.
  ///
  /// In fr, this message translates to:
  /// **'Factures & avoirs'**
  String get ventesOngletFactures;

  /// No description provided for @factureNumero.
  ///
  /// In fr, this message translates to:
  /// **'N° facture'**
  String get factureNumero;

  /// No description provided for @factureTypeFacture.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get factureTypeFacture;

  /// No description provided for @factureTypeAvoir.
  ///
  /// In fr, this message translates to:
  /// **'Avoir'**
  String get factureTypeAvoir;

  /// No description provided for @factureVente.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get factureVente;

  /// No description provided for @factureOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Facture d\'origine'**
  String get factureOrigine;

  /// No description provided for @factureTimbre.
  ///
  /// In fr, this message translates to:
  /// **'Timbre'**
  String get factureTimbre;

  /// No description provided for @factureNet.
  ///
  /// In fr, this message translates to:
  /// **'Net à payer'**
  String get factureNet;

  /// No description provided for @factureEntites.
  ///
  /// In fr, this message translates to:
  /// **'Factures et avoirs'**
  String get factureEntites;

  /// No description provided for @factureAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture sur la période'**
  String get factureAucune;

  /// No description provided for @factureKpiFactures.
  ///
  /// In fr, this message translates to:
  /// **'Factures émises'**
  String get factureKpiFactures;

  /// No description provided for @factureKpiFacture.
  ///
  /// In fr, this message translates to:
  /// **'Total facturé'**
  String get factureKpiFacture;

  /// No description provided for @factureKpiAvoirs.
  ///
  /// In fr, this message translates to:
  /// **'Total des avoirs'**
  String get factureKpiAvoirs;

  /// No description provided for @factureImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer (duplicata)'**
  String get factureImprimer;

  /// No description provided for @factureChaineOk.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne des factures intacte'**
  String get factureChaineOk;

  /// No description provided for @achatErreurCommandeInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Commande fournisseur introuvable pour ce fournisseur'**
  String get achatErreurCommandeInconnue;

  /// No description provided for @achatErreurCommandeCloturee.
  ///
  /// In fr, this message translates to:
  /// **'Commande fournisseur annulée ou soldée : réception impossible'**
  String get achatErreurCommandeCloturee;

  /// No description provided for @moduleDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Devis & commandes'**
  String get moduleDocuments;

  /// No description provided for @moduleCommandesFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'Commandes fournisseurs'**
  String get moduleCommandesFournisseurs;

  /// No description provided for @docOngletDevis.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get docOngletDevis;

  /// No description provided for @docOngletProformas.
  ///
  /// In fr, this message translates to:
  /// **'Proformas'**
  String get docOngletProformas;

  /// No description provided for @docOngletCommandes.
  ///
  /// In fr, this message translates to:
  /// **'Commandes clients'**
  String get docOngletCommandes;

  /// No description provided for @docOngletLivraisons.
  ///
  /// In fr, this message translates to:
  /// **'Bons de livraison'**
  String get docOngletLivraisons;

  /// No description provided for @docTypeDevis.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get docTypeDevis;

  /// No description provided for @docTypeProforma.
  ///
  /// In fr, this message translates to:
  /// **'Proforma'**
  String get docTypeProforma;

  /// No description provided for @docTypeCommande.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get docTypeCommande;

  /// No description provided for @docBonLivraison.
  ///
  /// In fr, this message translates to:
  /// **'Bon de livraison'**
  String get docBonLivraison;

  /// No description provided for @docStatutEnCours.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get docStatutEnCours;

  /// No description provided for @docStatutAccepte.
  ///
  /// In fr, this message translates to:
  /// **'Accepté'**
  String get docStatutAccepte;

  /// No description provided for @docStatutRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get docStatutRefuse;

  /// No description provided for @docStatutTransforme.
  ///
  /// In fr, this message translates to:
  /// **'Transformé en commande'**
  String get docStatutTransforme;

  /// No description provided for @docStatutExpire.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get docStatutExpire;

  /// No description provided for @docStatutPartielle.
  ///
  /// In fr, this message translates to:
  /// **'Partiellement livrée'**
  String get docStatutPartielle;

  /// No description provided for @docStatutLivree.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get docStatutLivree;

  /// No description provided for @docStatutAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get docStatutAnnule;

  /// No description provided for @docValidite.
  ///
  /// In fr, this message translates to:
  /// **'Validité'**
  String get docValidite;

  /// No description provided for @docOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Origine'**
  String get docOrigine;

  /// No description provided for @docLivre.
  ///
  /// In fr, this message translates to:
  /// **'Livré'**
  String get docLivre;

  /// No description provided for @docResteALivrer.
  ///
  /// In fr, this message translates to:
  /// **'Reste à livrer'**
  String get docResteALivrer;

  /// No description provided for @docALivrer.
  ///
  /// In fr, this message translates to:
  /// **'À livrer'**
  String get docALivrer;

  /// No description provided for @docQuantiteLivree.
  ///
  /// In fr, this message translates to:
  /// **'Quantité livrée'**
  String get docQuantiteLivree;

  /// No description provided for @docPuTtc.
  ///
  /// In fr, this message translates to:
  /// **'P.U. TTC'**
  String get docPuTtc;

  /// No description provided for @docTotalTtc.
  ///
  /// In fr, this message translates to:
  /// **'Total TTC'**
  String get docTotalTtc;

  /// No description provided for @docAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document sur la période'**
  String get docAucun;

  /// No description provided for @docKpiNombre.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get docKpiNombre;

  /// No description provided for @docKpiMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant total'**
  String get docKpiMontant;

  /// No description provided for @docKpiALivrer.
  ///
  /// In fr, this message translates to:
  /// **'À livrer'**
  String get docKpiALivrer;

  /// No description provided for @docKpiTransformes.
  ///
  /// In fr, this message translates to:
  /// **'Transformés en commande'**
  String get docKpiTransformes;

  /// No description provided for @docImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer (A4)'**
  String get docImprimer;

  /// No description provided for @docAccepter.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get docAccepter;

  /// No description provided for @docRefuser.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get docRefuser;

  /// No description provided for @docTransformer.
  ///
  /// In fr, this message translates to:
  /// **'Transformer en commande'**
  String get docTransformer;

  /// No description provided for @docLivrer.
  ///
  /// In fr, this message translates to:
  /// **'Livrer'**
  String get docLivrer;

  /// No description provided for @docNouveauDevis.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau devis'**
  String get docNouveauDevis;

  /// No description provided for @docNouvelleProforma.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle proforma'**
  String get docNouvelleProforma;

  /// No description provided for @docNouvelleCommande.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande'**
  String get docNouvelleCommande;

  /// No description provided for @docNouveauTitre.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau document : {type}'**
  String docNouveauTitre(String type);

  /// No description provided for @docModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier : {type}'**
  String docModifierTitre(String type);

  /// No description provided for @docChoisirClient.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client'**
  String get docChoisirClient;

  /// No description provided for @docToastEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Document enregistré'**
  String get docToastEnregistre;

  /// No description provided for @docToastTransforme.
  ///
  /// In fr, this message translates to:
  /// **'Commande créée'**
  String get docToastTransforme;

  /// No description provided for @docToastLivre.
  ///
  /// In fr, this message translates to:
  /// **'Livraison enregistrée'**
  String get docToastLivre;

  /// No description provided for @docLivrerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Livrer la commande {code}'**
  String docLivrerTitre(String code);

  /// No description provided for @docMontantPaye.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get docMontantPaye;

  /// No description provided for @docMontantPayeAide.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide : livraison à crédit'**
  String get docMontantPayeAide;

  /// No description provided for @docValiderLivraison.
  ///
  /// In fr, this message translates to:
  /// **'Valider la livraison'**
  String get docValiderLivraison;

  /// No description provided for @docPdfDevis.
  ///
  /// In fr, this message translates to:
  /// **'DEVIS'**
  String get docPdfDevis;

  /// No description provided for @docPdfProforma.
  ///
  /// In fr, this message translates to:
  /// **'FACTURE PROFORMA'**
  String get docPdfProforma;

  /// No description provided for @docPdfCommande.
  ///
  /// In fr, this message translates to:
  /// **'BON DE COMMANDE'**
  String get docPdfCommande;

  /// No description provided for @docPdfLivraison.
  ///
  /// In fr, this message translates to:
  /// **'BON DE LIVRAISON'**
  String get docPdfLivraison;

  /// No description provided for @docArretee.
  ///
  /// In fr, this message translates to:
  /// **'Arrêté(e) le présent document ({type}) à la somme de'**
  String docArretee(String type);

  /// No description provided for @docMentionProforma.
  ///
  /// In fr, this message translates to:
  /// **'Document sans valeur comptable : ne vaut pas facture.'**
  String get docMentionProforma;

  /// No description provided for @docSignatureClient.
  ///
  /// In fr, this message translates to:
  /// **'Bon pour accord (client)'**
  String get docSignatureClient;

  /// No description provided for @docSignatureVendeur.
  ///
  /// In fr, this message translates to:
  /// **'Cachet et signature'**
  String get docSignatureVendeur;

  /// No description provided for @docSignatureLivreur.
  ///
  /// In fr, this message translates to:
  /// **'Livré par'**
  String get docSignatureLivreur;

  /// No description provided for @docSignatureReception.
  ///
  /// In fr, this message translates to:
  /// **'Reçu par (nom, signature)'**
  String get docSignatureReception;

  /// No description provided for @docErreurClient.
  ///
  /// In fr, this message translates to:
  /// **'Client inconnu'**
  String get docErreurClient;

  /// No description provided for @docErreurInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Document introuvable'**
  String get docErreurInconnu;

  /// No description provided for @docErreurNonModifiable.
  ///
  /// In fr, this message translates to:
  /// **'Ce document ne peut plus être modifié (transformé, refusé, annulé ou déjà livré)'**
  String get docErreurNonModifiable;

  /// No description provided for @docErreurDejaAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Document déjà annulé'**
  String get docErreurDejaAnnule;

  /// No description provided for @docErreurLivraisonLiee.
  ///
  /// In fr, this message translates to:
  /// **'Commande déjà livrée : annulez d\'abord la vente du bon de livraison'**
  String get docErreurLivraisonLiee;

  /// No description provided for @docErreurRienALivrer.
  ///
  /// In fr, this message translates to:
  /// **'Aucune quantité à livrer'**
  String get docErreurRienALivrer;

  /// No description provided for @docErreurQuantiteExcessive.
  ///
  /// In fr, this message translates to:
  /// **'Quantité supérieure au reste à livrer'**
  String get docErreurQuantiteExcessive;

  /// No description provided for @docErreurLivraisonExistante.
  ///
  /// In fr, this message translates to:
  /// **'Cette vente a déjà un bon de livraison'**
  String get docErreurLivraisonExistante;

  /// No description provided for @docErreurVenteInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Vente introuvable'**
  String get docErreurVenteInconnue;

  /// No description provided for @cmdfNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande fournisseur'**
  String get cmdfNouvelle;

  /// No description provided for @cmdfModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la commande fournisseur'**
  String get cmdfModifier;

  /// No description provided for @cmdfTitre.
  ///
  /// In fr, this message translates to:
  /// **'Commande fournisseur {code}'**
  String cmdfTitre(String code);

  /// No description provided for @cmdfCommande.
  ///
  /// In fr, this message translates to:
  /// **'Commande fournisseur'**
  String get cmdfCommande;

  /// No description provided for @cmdfPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get cmdfPrix;

  /// No description provided for @cmdfRecu.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get cmdfRecu;

  /// No description provided for @cmdfReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste à recevoir'**
  String get cmdfReste;

  /// No description provided for @cmdfReceptions.
  ///
  /// In fr, this message translates to:
  /// **'Entrées de réception'**
  String get cmdfReceptions;

  /// No description provided for @cmdfReceptionner.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get cmdfReceptionner;

  /// No description provided for @cmdfSolder.
  ///
  /// In fr, this message translates to:
  /// **'Solder'**
  String get cmdfSolder;

  /// No description provided for @cmdfSolderMessage.
  ///
  /// In fr, this message translates to:
  /// **'Solder la commande {code} ? Le reliquat ne sera plus attendu.'**
  String cmdfSolderMessage(String code);

  /// No description provided for @cmdfKpiAttendues.
  ///
  /// In fr, this message translates to:
  /// **'En attente de réception'**
  String get cmdfKpiAttendues;

  /// No description provided for @cmdfStatutPartielle.
  ///
  /// In fr, this message translates to:
  /// **'Partiellement reçue'**
  String get cmdfStatutPartielle;

  /// No description provided for @cmdfStatutRecue.
  ///
  /// In fr, this message translates to:
  /// **'Reçue'**
  String get cmdfStatutRecue;

  /// No description provided for @cmdfStatutSoldee.
  ///
  /// In fr, this message translates to:
  /// **'Soldée'**
  String get cmdfStatutSoldee;

  /// No description provided for @cmdfPdfTitre.
  ///
  /// In fr, this message translates to:
  /// **'BON DE COMMANDE FOURNISSEUR'**
  String get cmdfPdfTitre;

  /// No description provided for @cmdfDepuisBesoin.
  ///
  /// In fr, this message translates to:
  /// **'Créer une commande fournisseur'**
  String get cmdfDepuisBesoin;

  /// No description provided for @cmdfErreurReceptionLiee.
  ///
  /// In fr, this message translates to:
  /// **'Commande déjà réceptionnée : annulez d\'abord les entrées liées'**
  String get cmdfErreurReceptionLiee;

  /// No description provided for @cmdfErreurDejaSoldee.
  ///
  /// In fr, this message translates to:
  /// **'Commande déjà soldée'**
  String get cmdfErreurDejaSoldee;

  /// No description provided for @apercuEnregistrerPdf.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer en PDF'**
  String get apercuEnregistrerPdf;

  /// No description provided for @rechercheGlobaleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Recherche globale'**
  String get rechercheGlobaleTitre;

  /// No description provided for @rechercheGlobaleIndice.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans tout le système…'**
  String get rechercheGlobaleIndice;

  /// No description provided for @rechercheGlobaleAide.
  ///
  /// In fr, this message translates to:
  /// **'Code, nom, téléphone, code-barres, référence : produits, clients, fournisseurs, ventes, factures, devis, livraisons, entrées, retours, versements…'**
  String get rechercheGlobaleAide;

  /// No description provided for @rechercheGlobaleAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour « {texte} »'**
  String rechercheGlobaleAucun(String texte);

  /// No description provided for @prdPrixTtc.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente TTC'**
  String get prdPrixTtc;

  /// No description provided for @prdVenteTtc.
  ///
  /// In fr, this message translates to:
  /// **'Vente TTC'**
  String get prdVenteTtc;

  /// No description provided for @posClotureNegatif.
  ///
  /// In fr, this message translates to:
  /// **'Solde théorique négatif : il est sorti de cette caisse plus d\'espèces qu\'il n\'en est entré depuis l\'ouverture (voir le détail ci-dessus). Une caisse ne peut pas contenir moins de 0 : comptez les espèces réellement présentes (0 si le tiroir est vide), l\'écart sera enregistré comme manquant.'**
  String get posClotureNegatif;

  /// No description provided for @posTransfertTitre.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant dans ce magasin'**
  String get posTransfertTitre;

  /// No description provided for @posTransfertConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Transférer et ajouter'**
  String get posTransfertConfirmer;

  /// No description provided for @posTransfertFait.
  ///
  /// In fr, this message translates to:
  /// **'Transfert {code} créé'**
  String posTransfertFait(String code);

  /// No description provided for @posTransfertQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Transférer le manque pour compléter le panier ?'**
  String get posTransfertQuestion;

  /// No description provided for @posTransfertDepuis.
  ///
  /// In fr, this message translates to:
  /// **'Depuis'**
  String get posTransfertDepuis;

  /// No description provided for @posTransfertVers.
  ///
  /// In fr, this message translates to:
  /// **'Vers la caisse'**
  String get posTransfertVers;

  /// No description provided for @posTransfertStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {stock}'**
  String posTransfertStock(String stock);

  /// No description provided for @posTransfertManque.
  ///
  /// In fr, this message translates to:
  /// **'Manque {quantite}'**
  String posTransfertManque(String quantite);

  /// No description provided for @pmTvaCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Vente en caisse avec TVA'**
  String get pmTvaCaisse;

  /// No description provided for @pmTvaCaisseDesc.
  ///
  /// In fr, this message translates to:
  /// **'Oui : prix TTC (prix de vente HT + TVA du produit). Non : prix HT, ticket sans TVA.'**
  String get pmTvaCaisseDesc;

  /// No description provided for @pmTvaDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Devis, proformas et commandes avec TVA'**
  String get pmTvaDocuments;

  /// No description provided for @pmTvaDocumentsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Même choix pour les devis, proformas, commandes clients et leurs livraisons.'**
  String get pmTvaDocumentsDesc;

  /// No description provided for @docPuHt.
  ///
  /// In fr, this message translates to:
  /// **'P.U. HT'**
  String get docPuHt;

  /// No description provided for @retoursMontantRetour.
  ///
  /// In fr, this message translates to:
  /// **'Montant retour'**
  String get retoursMontantRetour;

  /// No description provided for @retoursMontantRetourAideClient.
  ///
  /// In fr, this message translates to:
  /// **'Rendu au client en espèces ; le reste va en avoir sur son solde.'**
  String get retoursMontantRetourAideClient;

  /// No description provided for @retoursMontantRetourAideFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Versé par le fournisseur en espèces ; le reste est déduit de ce que vous lui devez.'**
  String get retoursMontantRetourAideFournisseur;

  /// No description provided for @retoursMontantRetourPassage.
  ///
  /// In fr, this message translates to:
  /// **'Client de passage : il récupère tout le montant du retour.'**
  String get retoursMontantRetourPassage;

  /// No description provided for @retoursMontantRetourMax.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et {plafond}'**
  String retoursMontantRetourMax(String plafond);

  /// No description provided for @retoursErreurMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant retour invalide : il doit être compris entre 0 et le montant du retour.'**
  String get retoursErreurMontant;

  /// No description provided for @retoursRepartition.
  ///
  /// In fr, this message translates to:
  /// **'Versement {versement} · Avoir {avoir}'**
  String retoursRepartition(String avoir, String versement);

  /// No description provided for @retoursMontantComplet.
  ///
  /// In fr, this message translates to:
  /// **'Montant complet'**
  String get retoursMontantComplet;

  /// No description provided for @offresTitre.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre formule'**
  String get offresTitre;

  /// No description provided for @offresSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Chaque formule commence par {jours} jours d\'essai gratuit. Ensuite, un paiement unique : la licence est à vous, à vie, sans abonnement.'**
  String offresSousTitre(int jours);

  /// No description provided for @offresEssaiGratuit.
  ///
  /// In fr, this message translates to:
  /// **'{jours} jours d\'essai gratuit'**
  String offresEssaiGratuit(int jours);

  /// No description provided for @offresPrix.
  ///
  /// In fr, this message translates to:
  /// **'{prix} DA'**
  String offresPrix(String prix);

  /// No description provided for @offresPaiementUnique.
  ///
  /// In fr, this message translates to:
  /// **'paiement unique, à vie'**
  String get offresPaiementUnique;

  /// No description provided for @offresMagasins.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 magasin} other{{n} magasins}}'**
  String offresMagasins(int n);

  /// No description provided for @offresScans.
  ///
  /// In fr, this message translates to:
  /// **'{n} Smart Scans inclus ({mois} mois)'**
  String offresScans(int n, int mois);

  /// No description provided for @offresAtoutStock.
  ///
  /// In fr, this message translates to:
  /// **'Produits, stock, entrées / sorties et inventaire'**
  String get offresAtoutStock;

  /// No description provided for @offresAtoutPdv.
  ///
  /// In fr, this message translates to:
  /// **'Caisse : ventes, scan, tickets, multi-paniers'**
  String get offresAtoutPdv;

  /// No description provided for @offresAtoutVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes, factures, avoirs et retours'**
  String get offresAtoutVentes;

  /// No description provided for @offresAtoutGestionCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de caisse, clôtures et coffre'**
  String get offresAtoutGestionCaisse;

  /// No description provided for @offresAtoutRapports.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord, situation, zakat et historique'**
  String get offresAtoutRapports;

  /// No description provided for @offresAtoutCommandesClients.
  ///
  /// In fr, this message translates to:
  /// **'Commandes clients et bons de livraison'**
  String get offresAtoutCommandesClients;

  /// No description provided for @offresAtoutBesoins.
  ///
  /// In fr, this message translates to:
  /// **'Listes de besoins'**
  String get offresAtoutBesoins;

  /// No description provided for @offresAtoutTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Transferts entre magasins'**
  String get offresAtoutTransferts;

  /// No description provided for @offresToutPlus.
  ///
  /// In fr, this message translates to:
  /// **'Tout {formule}, plus :'**
  String offresToutPlus(String formule);

  /// No description provided for @offresCaisses.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 caisse} other{{n} caisses}}'**
  String offresCaisses(int n);

  /// No description provided for @offresAtoutTiers.
  ///
  /// In fr, this message translates to:
  /// **'Clients, fournisseurs, versements et crédit'**
  String get offresAtoutTiers;

  /// No description provided for @offresAtoutDevis.
  ///
  /// In fr, this message translates to:
  /// **'Devis et proformas'**
  String get offresAtoutDevis;

  /// No description provided for @offresAtoutAchats.
  ///
  /// In fr, this message translates to:
  /// **'Commandes fournisseurs (réception partielle)'**
  String get offresAtoutAchats;

  /// No description provided for @offresAtoutMultiMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Multi-magasin (stock par magasin)'**
  String get offresAtoutMultiMagasin;

  /// No description provided for @offresIdealBasic.
  ///
  /// In fr, this message translates to:
  /// **'Petit commerce, une seule caisse'**
  String get offresIdealBasic;

  /// No description provided for @offresIdealAvance.
  ///
  /// In fr, this message translates to:
  /// **'Commerce qui fait des devis et passe des commandes'**
  String get offresIdealAvance;

  /// No description provided for @offresIdealUltra.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs magasins, gestion complète'**
  String get offresIdealUltra;

  /// No description provided for @offresTout.
  ///
  /// In fr, this message translates to:
  /// **'Tous les modules'**
  String get offresTout;

  /// No description provided for @offresEssayer.
  ///
  /// In fr, this message translates to:
  /// **'Essayer {jours} jours'**
  String offresEssayer(int jours);

  /// No description provided for @offresChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Choisir {formule}'**
  String offresChoisir(String formule);

  /// No description provided for @offresDejaCompte.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get offresDejaCompte;

  /// No description provided for @offresSeConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get offresSeConnecter;

  /// No description provided for @offresJaiUneCle.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai une clé d\'activation'**
  String get offresJaiUneCle;

  /// No description provided for @offresEssaiTermine.
  ///
  /// In fr, this message translates to:
  /// **'Votre essai s\'est terminé le {date}. Choisissez une formule : BENS vous contacte pour le paiement, puis l\'application se débloque d\'elle-même. Vos données sont gardées.'**
  String offresEssaiTermine(String date);

  /// No description provided for @offresSansFormule.
  ///
  /// In fr, this message translates to:
  /// **'Aucune formule active sur ce poste. Choisissez une formule : BENS vous contacte pour le paiement.'**
  String get offresSansFormule;

  /// No description provided for @offresLicenceRefuseeInvalide.
  ///
  /// In fr, this message translates to:
  /// **'BENS a bien envoyé votre licence, mais cette version de CaisseDZ la refuse (clé prévue pour une autre application ou une autre version). Installez la dernière version de CaisseDZ puis cliquez sur Actualiser ; sinon, contactez BENS.'**
  String get offresLicenceRefuseeInvalide;

  /// No description provided for @offresLicenceRefuseeAutrePoste.
  ///
  /// In fr, this message translates to:
  /// **'BENS a envoyé une licence prévue pour un autre PC. Cliquez sur Changer de compte et reconnectez-vous sur ce PC ; sinon, contactez BENS.'**
  String get offresLicenceRefuseeAutrePoste;

  /// No description provided for @offresLicenceRefuseeDate.
  ///
  /// In fr, this message translates to:
  /// **'La date de ce PC a été reculée : la licence envoyée par BENS est refusée. Remettez la date et l\'heure du PC à jour, puis cliquez sur Actualiser.'**
  String get offresLicenceRefuseeDate;

  /// No description provided for @offresDemandeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get offresDemandeTitre;

  /// No description provided for @offresDemandeDetail.
  ///
  /// In fr, this message translates to:
  /// **'BENS Digital Solutions vous rappelle au {telephone} pour le paiement de la formule {formule}. Vous pouvez aussi nous écrire sur WhatsApp.'**
  String offresDemandeDetail(String telephone, String formule);

  /// No description provided for @offresWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Écrire sur WhatsApp'**
  String get offresWhatsApp;

  /// No description provided for @offresWhatsAppMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, je souhaite acheter CaisseDZ Desktop {formule} (compte {telephone}).'**
  String offresWhatsAppMessage(String formule, String telephone);

  /// No description provided for @offresHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : prix indicatifs. Connectez le poste à internet pour créer votre compte.'**
  String get offresHorsLigne;

  /// No description provided for @offresSeDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Changer de compte'**
  String get offresSeDeconnecter;

  /// No description provided for @compteCreerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre compte'**
  String get compteCreerTitre;

  /// No description provided for @compteCreerSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Formule {formule} · {jours} jours d\'essai gratuit'**
  String compteCreerSousTitre(String formule, int jours);

  /// No description provided for @compteChangerFormule.
  ///
  /// In fr, this message translates to:
  /// **'Changer de formule'**
  String get compteChangerFormule;

  /// No description provided for @compteFormule.
  ///
  /// In fr, this message translates to:
  /// **'Formule {formule}'**
  String compteFormule(String formule);

  /// No description provided for @offresSelectionnee.
  ///
  /// In fr, this message translates to:
  /// **'Formule sélectionnée'**
  String get offresSelectionnee;

  /// No description provided for @offresSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner cette formule'**
  String get offresSelectionner;

  /// No description provided for @compteNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom et prénom'**
  String get compteNom;

  /// No description provided for @compteCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Nom du commerce'**
  String get compteCommerce;

  /// No description provided for @compteFacultatif.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif'**
  String get compteFacultatif;

  /// No description provided for @compteTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get compteTelephone;

  /// No description provided for @compteMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get compteMotDePasse;

  /// No description provided for @compteBensMotDePasseAide.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères au moins. Sur un poste neuf, il devient aussi celui de l\'administrateur (identifiant admin).'**
  String get compteBensMotDePasseAide;

  /// No description provided for @compteBensConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get compteBensConfirmer;

  /// No description provided for @compteCreerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte et commencer l\'essai'**
  String get compteCreerBouton;

  /// No description provided for @compteEssaiDejaUtilise.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé. L\'essai gratuit a déjà été utilisé sur ce poste ou avec ce numéro : choisissez une formule pour continuer.'**
  String get compteEssaiDejaUtilise;

  /// No description provided for @compteConnexionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à votre compte'**
  String get compteConnexionTitre;

  /// No description provided for @compteConnexionSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Le compte BENS de votre commerce : votre formule et votre licence. Se connecter ici déplace la licence sur ce poste.'**
  String get compteConnexionSousTitre;

  /// No description provided for @compteConnexionBouton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get compteConnexionBouton;

  /// No description provided for @compteMotDePasseOublie.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get compteMotDePasseOublie;

  /// No description provided for @comptePasEncore.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get comptePasEncore;

  /// No description provided for @compteVoirFormules.
  ///
  /// In fr, this message translates to:
  /// **'Voir les formules'**
  String get compteVoirFormules;

  /// No description provided for @compteRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get compteRetour;

  /// No description provided for @compteErrTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide : 10 chiffres commençant par 05, 06 ou 07.'**
  String get compteErrTelephone;

  /// No description provided for @compteErrNom.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom (2 caractères au moins).'**
  String get compteErrNom;

  /// No description provided for @compteErrMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe fait 8 caractères au moins.'**
  String get compteErrMotDePasse;

  /// No description provided for @compteErrConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne sont pas identiques.'**
  String get compteErrConfirmation;

  /// No description provided for @compteErrNumeroPris.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro a déjà un compte : connectez-vous.'**
  String get compteErrNumeroPris;

  /// No description provided for @compteErrIdentifiants.
  ///
  /// In fr, this message translates to:
  /// **'Numéro ou mot de passe incorrect.'**
  String get compteErrIdentifiants;

  /// No description provided for @compteErrReseau.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion à BENS. Vérifiez internet et réessayez.'**
  String get compteErrReseau;

  /// No description provided for @compteErrTropDEssais.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'essais. Réessayez dans 15 minutes.'**
  String get compteErrTropDEssais;

  /// No description provided for @compteErrAucunCompte.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte avec ce numéro.'**
  String get compteErrAucunCompte;

  /// No description provided for @compteErrCode.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou expiré. Demandez-en un nouveau à BENS.'**
  String get compteErrCode;

  /// No description provided for @compteErrServeur.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur BENS n\'a pas pu répondre. Réessayez plus tard.'**
  String get compteErrServeur;

  /// No description provided for @oubliTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get oubliTitre;

  /// No description provided for @oubliIntro.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez un code de récupération et envoyez-le à BENS sur WhatsApp. Après vérification, BENS vous envoie un code de réinitialisation, valable 48 heures.'**
  String get oubliIntro;

  /// No description provided for @oubliDemander.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir mon code de récupération'**
  String get oubliDemander;

  /// No description provided for @oubliVotreCode.
  ///
  /// In fr, this message translates to:
  /// **'Votre code de récupération'**
  String get oubliVotreCode;

  /// No description provided for @oubliCopier.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get oubliCopier;

  /// No description provided for @oubliCopie.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get oubliCopie;

  /// No description provided for @oubliEnvoyer.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer sur WhatsApp'**
  String get oubliEnvoyer;

  /// No description provided for @oubliMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, j\'ai oublié le mot de passe de mon compte CaisseDZ ({telephone}). Mon code de récupération : {code}'**
  String oubliMessage(String telephone, String code);

  /// No description provided for @oubliRecu.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu mon code'**
  String get oubliRecu;

  /// No description provided for @oubliCodeReset.
  ///
  /// In fr, this message translates to:
  /// **'Code de réinitialisation'**
  String get oubliCodeReset;

  /// No description provided for @oubliNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get oubliNouveau;

  /// No description provided for @oubliValider.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get oubliValider;

  /// No description provided for @activationColler.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get activationColler;

  /// No description provided for @activationWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer sur WhatsApp'**
  String get activationWhatsApp;

  /// No description provided for @activationCleSignee.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez le code de ce poste à BENS, puis collez ici la clé reçue (132 caractères).'**
  String get activationCleSignee;

  /// No description provided for @activationErrVide.
  ///
  /// In fr, this message translates to:
  /// **'Collez la clé reçue.'**
  String get activationErrVide;

  /// No description provided for @activationErrInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Clé invalide. Vérifiez qu\'elle a été copiée en entier.'**
  String get activationErrInvalide;

  /// No description provided for @activationErrAutrePoste.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé est pour un autre poste. Envoyez-nous le code ci-dessus.'**
  String get activationErrAutrePoste;

  /// No description provided for @activationErrExpiree.
  ///
  /// In fr, this message translates to:
  /// **'Votre licence a expiré le {date}. Contactez-nous pour la renouveler.'**
  String activationErrExpiree(String date);

  /// No description provided for @activationErrDate.
  ///
  /// In fr, this message translates to:
  /// **'La date du poste semble incorrecte. Corrigez la date et l\'heure.'**
  String get activationErrDate;

  /// No description provided for @activationPoste.
  ///
  /// In fr, this message translates to:
  /// **'Code de ce poste'**
  String get activationPoste;

  /// No description provided for @activationRetourOffres.
  ///
  /// In fr, this message translates to:
  /// **'Retour aux formules'**
  String get activationRetourOffres;

  /// No description provided for @licenceUltra.
  ///
  /// In fr, this message translates to:
  /// **'Ultra'**
  String get licenceUltra;

  /// No description provided for @licenceEssai.
  ///
  /// In fr, this message translates to:
  /// **'Essai {palier}'**
  String licenceEssai(String palier);

  /// No description provided for @shellBandeauEssai.
  ///
  /// In fr, this message translates to:
  /// **'Essai {palier} : {jours, plural, =1{dernier jour} other{{jours} jours restants}}'**
  String shellBandeauEssai(String palier, int jours);

  /// No description provided for @shellVoirFormules.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une formule'**
  String get shellVoirFormules;

  /// No description provided for @pmPalierUltra.
  ///
  /// In fr, this message translates to:
  /// **'Palier Ultra'**
  String get pmPalierUltra;

  /// No description provided for @pmPalierUltraDesc.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à 15 magasins et 15 caissiers, transferts, tous les modules.'**
  String get pmPalierUltraDesc;

  /// No description provided for @pmPalierEssai.
  ///
  /// In fr, this message translates to:
  /// **'Essai {palier}'**
  String pmPalierEssai(String palier);

  /// No description provided for @pmPalierEssaiDesc.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit jusqu\'au {date}, puis lecture seule tant qu\'aucune formule n\'est achetée.'**
  String pmPalierEssaiDesc(String date);

  /// No description provided for @pmValableJusquAu.
  ///
  /// In fr, this message translates to:
  /// **'Valable jusqu\'au {date}'**
  String pmValableJusquAu(String date);

  /// No description provided for @pmLicencePermanente.
  ///
  /// In fr, this message translates to:
  /// **'Licence permanente'**
  String get pmLicencePermanente;

  /// No description provided for @pmCodePoste.
  ///
  /// In fr, this message translates to:
  /// **'Code de ce poste'**
  String get pmCodePoste;

  /// No description provided for @pmCompteBens.
  ///
  /// In fr, this message translates to:
  /// **'Compte BENS'**
  String get pmCompteBens;

  /// No description provided for @pmCompteBensDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le compte de votre commerce : la licence de ce poste en vient.'**
  String get pmCompteBensDesc;

  /// No description provided for @pmAucunCompte.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte BENS sur ce poste'**
  String get pmAucunCompte;

  /// No description provided for @pmDeconnecterCompte.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter ce poste'**
  String get pmDeconnecterCompte;

  /// No description provided for @pmDeconnecterCompteConfirme.
  ///
  /// In fr, this message translates to:
  /// **'La licence venue du compte est retirée de ce poste : il faudra se reconnecter pour l\'utiliser. Vos données restent sur le poste.'**
  String get pmDeconnecterCompteConfirme;

  /// No description provided for @pmVoirFormules.
  ///
  /// In fr, this message translates to:
  /// **'Formules et mises à niveau'**
  String get pmVoirFormules;

  /// No description provided for @shellReservePalier.
  ///
  /// In fr, this message translates to:
  /// **'Réservé au palier {palier}'**
  String shellReservePalier(String palier);

  /// No description provided for @dsGatePalierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Disponible avec le palier {palier}'**
  String dsGatePalierTitre(String palier);

  /// No description provided for @dsGatePalierAction.
  ///
  /// In fr, this message translates to:
  /// **'Passer au palier {palier}'**
  String dsGatePalierAction(String palier);

  /// No description provided for @lectureSeuleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule'**
  String get lectureSeuleTitre;

  /// No description provided for @lectureSeuleCourt.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule (essai terminé)'**
  String get lectureSeuleCourt;

  /// No description provided for @lectureSeuleDetail.
  ///
  /// In fr, this message translates to:
  /// **'L\'essai est terminé : ce module attend l\'achat d\'une formule. Ventes, produits, stock et rapports restent consultables, vos données sont gardées.'**
  String get lectureSeuleDetail;

  /// No description provided for @lectureSeuleBandeau.
  ///
  /// In fr, this message translates to:
  /// **'Essai terminé le {date} : lecture seule. Vos données sont gardées ; choisissez une formule pour continuer à vendre.'**
  String lectureSeuleBandeau(String date);

  /// No description provided for @limiteCaissiers.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule ne permet pas d\'autre caissier. Passez à la formule supérieure (Paramètres › Licence).'**
  String get limiteCaissiers;

  /// No description provided for @limiteMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule ne permet pas d\'autre magasin : le multi-magasin est dans la formule Ultra.'**
  String get limiteMagasins;

  /// No description provided for @limiteCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule ne permet pas d\'autre caisse. Passez à la formule supérieure (Paramètres › Licence).'**
  String get limiteCaisses;

  /// No description provided for @limiteTransfertsCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule n\'a qu\'une caisse : les transferts entre caisses sont dans les formules Advanced et Ultra.'**
  String get limiteTransfertsCaisse;

  /// No description provided for @smartScanErreurLicence.
  ///
  /// In fr, this message translates to:
  /// **'La licence de ce poste n\'est pas reconnue par Smart Scan. Vérifiez votre formule (Paramètres › Licence).'**
  String get smartScanErreurLicence;

  /// No description provided for @smartScanPacksTitre.
  ///
  /// In fr, this message translates to:
  /// **'Acheter un pack Smart Scan'**
  String get smartScanPacksTitre;

  /// No description provided for @smartScanPackLigne.
  ///
  /// In fr, this message translates to:
  /// **'{nom} · {scans} scans · {prix}'**
  String smartScanPackLigne(String nom, int scans, String prix);

  /// No description provided for @smartScanPackCompte.
  ///
  /// In fr, this message translates to:
  /// **'Connectez ce poste à votre compte BENS pour acheter des packs (Paramètres › Licence).'**
  String get smartScanPackCompte;

  /// No description provided for @smartScanExpiration.
  ///
  /// In fr, this message translates to:
  /// **'{scans, plural, =1{1 Smart Scan expire} other{{scans} Smart Scans expirent}} le {date} : utilisez-les ou ajoutez un pack.'**
  String smartScanExpiration(int scans, String date);

  /// No description provided for @permUtiliserMobile.
  ///
  /// In fr, this message translates to:
  /// **'Application mobile (CaisseDZ Scan)'**
  String get permUtiliserMobile;

  /// No description provided for @mobileBouton.
  ///
  /// In fr, this message translates to:
  /// **'Application mobile'**
  String get mobileBouton;

  /// No description provided for @mobileTitre.
  ///
  /// In fr, this message translates to:
  /// **'Application mobile CaisseDZ Scan'**
  String get mobileTitre;

  /// No description provided for @mobileEtape1.
  ///
  /// In fr, this message translates to:
  /// **'Installez CaisseDZ Scan.'**
  String get mobileEtape1;

  /// No description provided for @mobileEtape2.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous au même Wi-Fi.'**
  String get mobileEtape2;

  /// No description provided for @mobileEtape3.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ce QR code.'**
  String get mobileEtape3;

  /// No description provided for @mobileEtape4.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone est prêt.'**
  String get mobileEtape4;

  /// No description provided for @mobileAucunReseau.
  ///
  /// In fr, this message translates to:
  /// **'Aucun réseau local détecté : connectez cet ordinateur au Wi-Fi ou au réseau de la boutique.'**
  String get mobileAucunReseau;

  /// No description provided for @mobileErreurDemarrage.
  ///
  /// In fr, this message translates to:
  /// **'Le service mobile n\'a pas pu démarrer : {detail}'**
  String mobileErreurDemarrage(String detail);

  /// No description provided for @mobileQrExpire.
  ///
  /// In fr, this message translates to:
  /// **'Code valable jusqu\'à {heure}'**
  String mobileQrExpire(String heure);

  /// No description provided for @mobileNouveauQr.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau QR code'**
  String get mobileNouveauQr;

  /// No description provided for @mobileActiver.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'application mobile'**
  String get mobileActiver;

  /// No description provided for @mobileQrDe.
  ///
  /// In fr, this message translates to:
  /// **'QR code de {nom}'**
  String mobileQrDe(String nom);

  /// No description provided for @mobileDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get mobileDesactiver;

  /// No description provided for @mobileAppareils.
  ///
  /// In fr, this message translates to:
  /// **'Téléphones appairés ({nombre})'**
  String mobileAppareils(int nombre);

  /// No description provided for @mobileMesAppareils.
  ///
  /// In fr, this message translates to:
  /// **'Mes téléphones ({nombre})'**
  String mobileMesAppareils(int nombre);

  /// No description provided for @mobileAucunAppareil.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléphone appairé pour l\'instant.'**
  String get mobileAucunAppareil;

  /// No description provided for @mobileAppaireLe.
  ///
  /// In fr, this message translates to:
  /// **'Appairé le {date}'**
  String mobileAppaireLe(String date);

  /// No description provided for @mobileDernierAcces.
  ///
  /// In fr, this message translates to:
  /// **'Dernier accès {date}'**
  String mobileDernierAcces(String date);

  /// No description provided for @mobileConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get mobileConnecte;

  /// No description provided for @mobileFactureRecueTitre.
  ///
  /// In fr, this message translates to:
  /// **'Facture reçue du téléphone'**
  String get mobileFactureRecueTitre;

  /// No description provided for @mobileFactureRecueMessage.
  ///
  /// In fr, this message translates to:
  /// **'{nom} a envoyé une photo de facture ({bon}).'**
  String mobileFactureRecueMessage(String nom, String bon);

  /// No description provided for @mobileOuvrirSmartScan.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir Smart Scan'**
  String get mobileOuvrirSmartScan;

  /// No description provided for @mobileRevoquer.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get mobileRevoquer;

  /// No description provided for @mobileRevoquerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer « {nom} » ?'**
  String mobileRevoquerTitre(String nom);

  /// No description provided for @mobileRevoquerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce téléphone ne pourra plus se connecter à ce poste tant qu\'il n\'aura pas scanné un nouveau QR code.'**
  String get mobileRevoquerMessage;

  /// No description provided for @catalogueRayonsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez vos rayons'**
  String get catalogueRayonsTitre;

  /// No description provided for @catalogueRayonsSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Selon votre activité, téléchargez les produits les plus demandés de chaque rayon : code-barres, nom et photo, sans prix ni stock. Vous pourrez en ajouter d\'autres plus tard depuis Produits.'**
  String get catalogueRayonsSousTitre;

  /// No description provided for @catalogueRayonsNbProduits.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} produits'**
  String catalogueRayonsNbProduits(String nombre);

  /// No description provided for @catalogueRayonsBientot.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get catalogueRayonsBientot;

  /// No description provided for @catalogueRayonsDejaTelecharge.
  ///
  /// In fr, this message translates to:
  /// **'Déjà téléchargé'**
  String get catalogueRayonsDejaTelecharge;

  /// No description provided for @catalogueRayonsToutSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get catalogueRayonsToutSelectionner;

  /// No description provided for @catalogueRayonsToutDeselectionner.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get catalogueRayonsToutDeselectionner;

  /// No description provided for @catalogueRayonsSelection.
  ///
  /// In fr, this message translates to:
  /// **'{rayons, plural, =0{Aucun rayon choisi} =1{1 rayon · {produits} produits} other{{rayons} rayons · {produits} produits}}'**
  String catalogueRayonsSelection(int rayons, String produits);

  /// No description provided for @catalogueRayonsPlusTard.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get catalogueRayonsPlusTard;

  /// No description provided for @catalogueRayonsAppliquer.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get catalogueRayonsAppliquer;

  /// No description provided for @catalogueRayonsChargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des rayons…'**
  String get catalogueRayonsChargement;

  /// No description provided for @catalogueRayonsHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Le catalogue BENS est injoignable. Vérifiez la connexion internet, puis réessayez.'**
  String get catalogueRayonsHorsLigne;

  /// No description provided for @catalogueRayonsReessayer.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get catalogueRayonsReessayer;

  /// No description provided for @catalogueRayonsTelechargement.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement : {rayon}…'**
  String catalogueRayonsTelechargement(String rayon);

  /// No description provided for @catalogueRayonsProgres.
  ///
  /// In fr, this message translates to:
  /// **'{recus} / {attendus} produits reçus'**
  String catalogueRayonsProgres(String recus, String attendus);

  /// No description provided for @catalogueRayonsEchec.
  ///
  /// In fr, this message translates to:
  /// **'Le téléchargement a échoué : rien n\'a été ajouté. Vérifiez la connexion internet, puis réessayez.'**
  String get catalogueRayonsEchec;

  /// No description provided for @catalogueRayonsResultatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produits téléchargés'**
  String get catalogueRayonsResultatTitre;

  /// No description provided for @catalogueRayonsResultatMessage.
  ///
  /// In fr, this message translates to:
  /// **'{telecharges} produits ajoutés à votre catalogue : {pourcentage} % des produits des rayons choisis.'**
  String catalogueRayonsResultatMessage(String telecharges, String pourcentage);

  /// No description provided for @catalogueRayonsDejaPresents.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} produits étaient déjà dans votre catalogue (même code-barres) : ils sont restés tels quels.'**
  String catalogueRayonsDejaPresents(String nombre);

  /// No description provided for @catalogueRayonsSansPrix.
  ///
  /// In fr, this message translates to:
  /// **'Ces produits n\'ont ni prix ni stock : renseignez le prix dans la fiche produit ou à la première entrée en stock.'**
  String get catalogueRayonsSansPrix;

  /// No description provided for @catalogueRayonsLigne.
  ///
  /// In fr, this message translates to:
  /// **'{telecharges} / {disponibles} · {pourcentage} %'**
  String catalogueRayonsLigne(String telecharges, String disponibles, String pourcentage);

  /// No description provided for @catalogueRayonsContinuer.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get catalogueRayonsContinuer;

  /// No description provided for @catalogueRayonsBouton.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue BENS'**
  String get catalogueRayonsBouton;

  /// No description provided for @prdDesignationAr.
  ///
  /// In fr, this message translates to:
  /// **'Nom arabe'**
  String get prdDesignationAr;

  /// No description provided for @prdDesignationArIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. زيت إليو 1 ل'**
  String get prdDesignationArIndice;

  /// No description provided for @posCatalogueTrouveTitre.
  ///
  /// In fr, this message translates to:
  /// **'Trouvé dans le catalogue BENS'**
  String get posCatalogueTrouveTitre;

  /// No description provided for @posCatalogueCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer depuis le catalogue'**
  String get posCatalogueCreer;

  /// No description provided for @posCatalogueRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Recherche dans le catalogue BENS…'**
  String get posCatalogueRecherche;

  /// No description provided for @catalogueRayonsNbTendances.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} en tendance'**
  String catalogueRayonsNbTendances(String nombre);

  /// No description provided for @posCatalogueAConfirmerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produit proposé par une boutique'**
  String get posCatalogueAConfirmerTitre;

  /// No description provided for @posCatalogueAConfirmerQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Est-ce bien ce produit ? Votre réponse aide à confirmer le catalogue ({score} sur {seuil}).'**
  String posCatalogueAConfirmerQuestion(int score, int seuil);

  /// No description provided for @posCatalogueOui.
  ///
  /// In fr, this message translates to:
  /// **'Oui, c\'est ce produit'**
  String get posCatalogueOui;

  /// No description provided for @posCatalogueNon.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas ce produit'**
  String get posCatalogueNon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
