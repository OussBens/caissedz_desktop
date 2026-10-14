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

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'CaisseDZ'**
  String get appTitle;

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

  /// No description provided for @shellFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get shellFavoris;

  /// No description provided for @shellFavorisVide.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori. Clic droit sur un module pour l\'ajouter.'**
  String get shellFavorisVide;

  /// No description provided for @shellFavorisMax.
  ///
  /// In fr, this message translates to:
  /// **'7 favoris maximum'**
  String get shellFavorisMax;

  /// No description provided for @shellFavorisAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get shellFavorisAjouter;

  /// No description provided for @shellFavorisRetirer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get shellFavorisRetirer;

  /// No description provided for @shellMenuModules.
  ///
  /// In fr, this message translates to:
  /// **'Modules'**
  String get shellMenuModules;

  /// No description provided for @shellMenuModulesRaccourci.
  ///
  /// In fr, this message translates to:
  /// **'Ctrl+M'**
  String get shellMenuModulesRaccourci;

  /// No description provided for @shellMenuModulesRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un module…'**
  String get shellMenuModulesRecherche;

  /// No description provided for @shellMenuModulesAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun module ne correspond.'**
  String get shellMenuModulesAucun;

  /// No description provided for @shellAlertes.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get shellAlertes;

  /// No description provided for @shellAlertesAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte'**
  String get shellAlertesAucune;

  /// No description provided for @shellInternetConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Internet : connecté'**
  String get shellInternetConnecte;

  /// No description provided for @shellInternetDeconnecte.
  ///
  /// In fr, this message translates to:
  /// **'Internet : hors ligne'**
  String get shellInternetDeconnecte;

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

  /// No description provided for @shellReduireSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Réduire le menu'**
  String get shellReduireSidebar;

  /// No description provided for @shellEtendreSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Étendre le menu'**
  String get shellEtendreSidebar;

  /// No description provided for @shellGalerie.
  ///
  /// In fr, this message translates to:
  /// **'Galerie du design system'**
  String get shellGalerie;

  /// No description provided for @modulePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Module « {nom} » : disponible dans un prochain lot.'**
  String modulePlaceholder(String nom);

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

  /// No description provided for @moduleMonCompte.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get moduleMonCompte;

  /// No description provided for @communOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get communOk;

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

  /// No description provided for @communChargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get communChargement;

  /// No description provided for @communAucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get communAucunResultat;

  /// No description provided for @communSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get communSelectionner;

  /// No description provided for @communTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get communTotal;

  /// No description provided for @communColonnes.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes'**
  String get communColonnes;

  /// No description provided for @communToutSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get communToutSelectionner;

  /// No description provided for @communLignesParPage.
  ///
  /// In fr, this message translates to:
  /// **'Lignes par page'**
  String get communLignesParPage;

  /// No description provided for @communPagination.
  ///
  /// In fr, this message translates to:
  /// **'{debut}–{fin} sur {total}'**
  String communPagination(int debut, int fin, int total);

  /// No description provided for @communPagePrecedente.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get communPagePrecedente;

  /// No description provided for @communPageSuivante.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get communPageSuivante;

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
  /// **'Activation de CaisseDZ'**
  String get activationTitre;

  /// No description provided for @activationIntro.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la clé d\'activation fournie pour cette machine, ou essayez le mode démo.'**
  String get activationIntro;

  /// No description provided for @activationIdentifiantMachine.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant de cette machine'**
  String get activationIdentifiantMachine;

  /// No description provided for @activationCopierIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Copier l\'identifiant'**
  String get activationCopierIdentifiant;

  /// No description provided for @activationIdentifiantCopie.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant copié'**
  String get activationIdentifiantCopie;

  /// No description provided for @activationCle.
  ///
  /// In fr, this message translates to:
  /// **'Clé d\'activation (64 caractères)'**
  String get activationCle;

  /// No description provided for @activationCleIndice.
  ///
  /// In fr, this message translates to:
  /// **'Clé SHA-256 de 64 caractères hexadécimaux'**
  String get activationCleIndice;

  /// No description provided for @activationBouton.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get activationBouton;

  /// No description provided for @activationDemo.
  ///
  /// In fr, this message translates to:
  /// **'Essayer en mode démo'**
  String get activationDemo;

  /// No description provided for @activationDemoAide.
  ///
  /// In fr, this message translates to:
  /// **'Le mode démo ouvre toutes les fonctions (licence Avancé) avec le compte demo / demo. Les données saisies ne sont pas destinées à la production.'**
  String get activationDemoAide;

  /// No description provided for @activationErreurFormat.
  ///
  /// In fr, this message translates to:
  /// **'La clé doit contenir exactement 64 caractères hexadécimaux (0-9, a-f).'**
  String get activationErreurFormat;

  /// No description provided for @activationErreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé ne correspond pas à cette machine. Vérifiez la clé ou contactez votre revendeur.'**
  String get activationErreurInconnue;

  /// No description provided for @activationReussie.
  ///
  /// In fr, this message translates to:
  /// **'Licence {niveau} activée.'**
  String activationReussie(String niveau);

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

  /// No description provided for @licenceRequise.
  ///
  /// In fr, this message translates to:
  /// **'Fonction disponible avec la licence Avancé'**
  String get licenceRequise;

  /// No description provided for @licenceRequiseDetail.
  ///
  /// In fr, this message translates to:
  /// **'Votre licence actuelle est Basic. Activez une licence Avancé pour accéder à ce module.'**
  String get licenceRequiseDetail;

  /// No description provided for @licenceGererCle.
  ///
  /// In fr, this message translates to:
  /// **'Activer une autre clé'**
  String get licenceGererCle;

  /// No description provided for @connexionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get connexionTitre;

  /// No description provided for @connexionIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
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
  /// **'Mode démo : identifiant demo, mot de passe demo'**
  String get connexionDemoIndice;

  /// No description provided for @connexionDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get connexionDeconnecter;

  /// No description provided for @configTitre.
  ///
  /// In fr, this message translates to:
  /// **'Configuration initiale'**
  String get configTitre;

  /// No description provided for @configEtape.
  ///
  /// In fr, this message translates to:
  /// **'Étape {n} sur {total}'**
  String configEtape(int n, int total);

  /// No description provided for @configEtapeBoutique.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get configEtapeBoutique;

  /// No description provided for @configEtapeAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get configEtapeAdmin;

  /// No description provided for @configEtapeVente.
  ///
  /// In fr, this message translates to:
  /// **'Marge et vente'**
  String get configEtapeVente;

  /// No description provided for @configEtapeRecap.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get configEtapeRecap;

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

  /// No description provided for @configAdminIntro.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte administrateur aura tous les droits. Choisissez un identifiant et un mot de passe.'**
  String get configAdminIntro;

  /// No description provided for @configAdminNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get configAdminNom;

  /// No description provided for @configAdminMotDePasseConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get configAdminMotDePasseConfirmation;

  /// No description provided for @configMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge par défaut (%)'**
  String get configMarge;

  /// No description provided for @configMargeAide.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée au calcul du prix de vente à partir du prix d\'achat des nouveaux produits.'**
  String get configMargeAide;

  /// No description provided for @configSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte de stock (global)'**
  String get configSeuil;

  /// No description provided for @configFidelite.
  ///
  /// In fr, this message translates to:
  /// **'Activer la fidélité (points)'**
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
  /// **'Langue de l\'application'**
  String get configLangue;

  /// No description provided for @configRecapIntro.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les informations avant de terminer. Vous pourrez les modifier plus tard dans Paramètres.'**
  String get configRecapIntro;

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

  /// No description provided for @configReussie.
  ///
  /// In fr, this message translates to:
  /// **'Configuration terminée. Connectez-vous avec votre compte administrateur.'**
  String get configReussie;

  /// No description provided for @compteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get compteTitre;

  /// No description provided for @compteRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get compteRole;

  /// No description provided for @compteIdentifiantActuel.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant actuel'**
  String get compteIdentifiantActuel;

  /// No description provided for @compteNouvelIdentifiant.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel identifiant'**
  String get compteNouvelIdentifiant;

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

  /// No description provided for @accesRefuseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé'**
  String get accesRefuseTitre;

  /// No description provided for @accesRefuseMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre rôle « {role} » n\'a pas accès au module « {module} ». Demandez à un administrateur.'**
  String accesRefuseMessage(String role, String module);

  /// No description provided for @accesRefuseRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour au tableau de bord'**
  String get accesRefuseRetour;

  /// No description provided for @rolesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rôles et permissions'**
  String get rolesTitre;

  /// No description provided for @rolesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Cochez les permissions d\'action et les modules accessibles pour chaque rôle. L\'administrateur conserve toujours tous les droits.'**
  String get rolesIntro;

  /// No description provided for @rolesPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions d\'action'**
  String get rolesPermissions;

  /// No description provided for @rolesModules.
  ///
  /// In fr, this message translates to:
  /// **'Modules accessibles'**
  String get rolesModules;

  /// No description provided for @rolesEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Grille des rôles enregistrée.'**
  String get rolesEnregistre;

  /// No description provided for @rolesAdminTotal.
  ///
  /// In fr, this message translates to:
  /// **'Tous les droits'**
  String get rolesAdminTotal;

  /// No description provided for @permVoirPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Voir le prix d\'achat'**
  String get permVoirPrixAchat;

  /// No description provided for @permModifierPrix.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le prix en caisse'**
  String get permModifierPrix;

  /// No description provided for @permAppliquerRemise.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer une remise'**
  String get permAppliquerRemise;

  /// No description provided for @permAnnulerVente.
  ///
  /// In fr, this message translates to:
  /// **'Annuler une vente'**
  String get permAnnulerVente;

  /// No description provided for @permSupprimerDocument.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer un document'**
  String get permSupprimerDocument;

  /// No description provided for @permExporterDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get permExporterDonnees;

  /// No description provided for @permGererUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les utilisateurs'**
  String get permGererUtilisateurs;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleCaissier.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get roleCaissier;

  /// No description provided for @roleMagasinier.
  ///
  /// In fr, this message translates to:
  /// **'Magasinier'**
  String get roleMagasinier;

  /// No description provided for @parametresRolesCarte.
  ///
  /// In fr, this message translates to:
  /// **'Rôles et permissions'**
  String get parametresRolesCarte;

  /// No description provided for @parametresRolesCarteDetail.
  ///
  /// In fr, this message translates to:
  /// **'Permissions d\'action et modules accessibles par rôle.'**
  String get parametresRolesCarteDetail;

  /// No description provided for @parametresLicenceCarte.
  ///
  /// In fr, this message translates to:
  /// **'Licence'**
  String get parametresLicenceCarte;

  /// No description provided for @shellBandeauDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo — les données ne sont pas destinées à la production'**
  String get shellBandeauDemo;

  /// No description provided for @shellMenuUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Menu utilisateur'**
  String get shellMenuUtilisateur;

  /// No description provided for @shellVerrouille.
  ///
  /// In fr, this message translates to:
  /// **'Réservé à la licence Avancé'**
  String get shellVerrouille;

  /// No description provided for @shellAccesRestreint.
  ///
  /// In fr, this message translates to:
  /// **'Accès non autorisé pour votre rôle'**
  String get shellAccesRestreint;

  /// No description provided for @produitsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get produitsTitre;

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

  /// No description provided for @produitsOngletColis.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get produitsOngletColis;

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

  /// No description provided for @produitsModeIa.
  ///
  /// In fr, this message translates to:
  /// **'Mode IA'**
  String get produitsModeIa;

  /// No description provided for @produitsImporter.
  ///
  /// In fr, this message translates to:
  /// **'Importer Excel'**
  String get produitsImporter;

  /// No description provided for @produitsEtiquettes.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get produitsEtiquettes;

  /// No description provided for @produitsSynchro.
  ///
  /// In fr, this message translates to:
  /// **'Synchro catalogue'**
  String get produitsSynchro;

  /// No description provided for @produitsRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par désignation, code ou code-barres…'**
  String get produitsRecherche;

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
  /// **'Prix de vente'**
  String get produitsColPrixVente;

  /// No description provided for @produitsColMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge %'**
  String get produitsColMarge;

  /// No description provided for @produitsColActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get produitsColActif;

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

  /// No description provided for @produitDesactiver.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get produitDesactiver;

  /// No description provided for @produitActiver.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get produitActiver;

  /// No description provided for @produitGenererCodeBarres.
  ///
  /// In fr, this message translates to:
  /// **'Générer un code-barres interne'**
  String get produitGenererCodeBarres;

  /// No description provided for @produitChampDesignation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get produitChampDesignation;

  /// No description provided for @produitChampCodeBarres.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres (EAN-13 ou interne)'**
  String get produitChampCodeBarres;

  /// No description provided for @produitChampCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get produitChampCategorie;

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
  /// **'Prix de vente'**
  String get produitChampPrixVente;

  /// No description provided for @produitChampMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge (%)'**
  String get produitChampMarge;

  /// No description provided for @produitChampUnite.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get produitChampUnite;

  /// No description provided for @produitChampTva.
  ///
  /// In fr, this message translates to:
  /// **'TVA (%)'**
  String get produitChampTva;

  /// No description provided for @produitChampSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte (vide = seuil global)'**
  String get produitChampSeuil;

  /// No description provided for @produitChampSuiviNombre.
  ///
  /// In fr, this message translates to:
  /// **'Suivre un 2ᵉ stock « nombre » (pièces)'**
  String get produitChampSuiviNombre;

  /// No description provided for @produitChampSuiviNombreAide.
  ///
  /// In fr, this message translates to:
  /// **'Le produit se vend à l\'unité ou à la pièce ; le stock est tenu dans les deux.'**
  String get produitChampSuiviNombreAide;

  /// No description provided for @produitChampNombreParUnite.
  ///
  /// In fr, this message translates to:
  /// **'Pièces par unité'**
  String get produitChampNombreParUnite;

  /// No description provided for @produitPrixAuto.
  ///
  /// In fr, this message translates to:
  /// **'Le prix de vente est calculé depuis la marge si vous le laissez vide.'**
  String get produitPrixAuto;

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

  /// No description provided for @produitCree.
  ///
  /// In fr, this message translates to:
  /// **'Produit « {nom} » créé ({code}).'**
  String produitCree(String nom, String code);

  /// No description provided for @iaTitre.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit en mode IA'**
  String get iaTitre;

  /// No description provided for @iaIntro.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ou saisissez un code-barres : la fiche est recherchée dans CaisseDZ, puis Mantouj, Open Food Facts et Open Beauty Facts.'**
  String get iaIntro;

  /// No description provided for @iaRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get iaRechercher;

  /// No description provided for @iaRechercheEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en cours…'**
  String get iaRechercheEnCours;

  /// No description provided for @iaAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune fiche trouvée pour ce code-barres : passez en saisie détaillée.'**
  String get iaAucun;

  /// No description provided for @iaTrouve.
  ///
  /// In fr, this message translates to:
  /// **'Fiche trouvée via {source}'**
  String iaTrouve(String source);

  /// No description provided for @iaMarque.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get iaMarque;

  /// No description provided for @iaCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer le produit'**
  String get iaCreer;

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

  /// No description provided for @importTelechargerModele.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le modèle'**
  String get importTelechargerModele;

  /// No description provided for @importLignesValides.
  ///
  /// In fr, this message translates to:
  /// **'{n} ligne(s) valide(s)'**
  String importLignesValides(int n);

  /// No description provided for @importLignesInvalides.
  ///
  /// In fr, this message translates to:
  /// **'{n} ligne(s) ignorée(s)'**
  String importLignesInvalides(int n);

  /// No description provided for @importColLigne.
  ///
  /// In fr, this message translates to:
  /// **'Ligne'**
  String get importColLigne;

  /// No description provided for @importColErreur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get importColErreur;

  /// No description provided for @importLancer.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importLancer;

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

  /// No description provided for @etiquettesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer des étiquettes'**
  String get etiquettesTitre;

  /// No description provided for @etiquettesQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get etiquettesQuantite;

  /// No description provided for @etiquettesFormatA4.
  ///
  /// In fr, this message translates to:
  /// **'Planche A4'**
  String get etiquettesFormatA4;

  /// No description provided for @etiquettesFormatRouleau.
  ///
  /// In fr, this message translates to:
  /// **'Rouleau'**
  String get etiquettesFormatRouleau;

  /// No description provided for @etiquettesAfficherPrix.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le prix'**
  String get etiquettesAfficherPrix;

  /// No description provided for @etiquettesQr.
  ///
  /// In fr, this message translates to:
  /// **'Code QR au lieu du code-barres'**
  String get etiquettesQr;

  /// No description provided for @etiquettesGenerer.
  ///
  /// In fr, this message translates to:
  /// **'Générer le PDF'**
  String get etiquettesGenerer;

  /// No description provided for @etiquettesAucuneSelection.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins un produit dans la liste.'**
  String get etiquettesAucuneSelection;

  /// No description provided for @synchroResultat.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation : {envoyes} envoyé(s), {recus} mis à jour.'**
  String synchroResultat(int envoyes, int recus);

  /// No description provided for @synchroNonConfiguree.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez l\'URL du serveur CaisseDZ dans Paramètres pour synchroniser le catalogue.'**
  String get synchroNonConfiguree;

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

  /// No description provided for @categorieRenommer.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get categorieRenommer;

  /// No description provided for @categorieSupprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get categorieSupprimer;

  /// No description provided for @categorieSousCategories.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégories'**
  String get categorieSousCategories;

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

  /// No description provided for @categorieConfirmerSuppression.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie « {nom} » et ses sous-catégories ?'**
  String categorieConfirmerSuppression(String nom);

  /// No description provided for @colisNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau colis'**
  String get colisNouveau;

  /// No description provided for @colisProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get colisProduit;

  /// No description provided for @colisQuantite.
  ///
  /// In fr, this message translates to:
  /// **'Unités par colis'**
  String get colisQuantite;

  /// No description provided for @colisAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun colis.'**
  String get colisAucun;

  /// No description provided for @packNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau pack'**
  String get packNouveau;

  /// No description provided for @packLignes.
  ///
  /// In fr, this message translates to:
  /// **'Composition'**
  String get packLignes;

  /// No description provided for @packAjouterProduit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get packAjouterProduit;

  /// No description provided for @packAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun pack.'**
  String get packAucun;

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

  /// No description provided for @remiseTypePourcentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get remiseTypePourcentage;

  /// No description provided for @remiseTypeMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get remiseTypeMontant;

  /// No description provided for @remiseValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get remiseValeur;

  /// No description provided for @remisePortee.
  ///
  /// In fr, this message translates to:
  /// **'Portée'**
  String get remisePortee;

  /// No description provided for @remisePorteeGlobale.
  ///
  /// In fr, this message translates to:
  /// **'Tous les produits'**
  String get remisePorteeGlobale;

  /// No description provided for @remisePorteeCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Une catégorie'**
  String get remisePorteeCategorie;

  /// No description provided for @remisePorteeProduit.
  ///
  /// In fr, this message translates to:
  /// **'Un produit'**
  String get remisePorteeProduit;

  /// No description provided for @remiseDebut.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get remiseDebut;

  /// No description provided for @remiseFin.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get remiseFin;

  /// No description provided for @remiseAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune remise.'**
  String get remiseAucune;

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

  /// No description provided for @communInactif.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get communInactif;

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

  /// No description provided for @communImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get communImprimer;

  /// No description provided for @communAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get communAucune;
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
