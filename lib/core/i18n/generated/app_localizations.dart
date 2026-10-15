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
  /// **'Clé invalide pour ce poste — vérifiez l\'identifiant envoyé.'**
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
  /// **'Marge et stock'**
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

  /// No description provided for @stockTitre.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get stockTitre;

  /// No description provided for @stockOngletNiveaux.
  ///
  /// In fr, this message translates to:
  /// **'Niveaux'**
  String get stockOngletNiveaux;

  /// No description provided for @stockOngletJournal.
  ///
  /// In fr, this message translates to:
  /// **'Journal des mouvements'**
  String get stockOngletJournal;

  /// No description provided for @stockColProduit.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get stockColProduit;

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

  /// No description provided for @stockColNombre.
  ///
  /// In fr, this message translates to:
  /// **'Nombre (pièces)'**
  String get stockColNombre;

  /// No description provided for @stockColSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil'**
  String get stockColSeuil;

  /// No description provided for @stockColDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get stockColDate;

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

  /// No description provided for @stockColReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get stockColReference;

  /// No description provided for @stockColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get stockColUtilisateur;

  /// No description provided for @stockColCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get stockColCommentaire;

  /// No description provided for @stockColValeur.
  ///
  /// In fr, this message translates to:
  /// **'Valeur (PA)'**
  String get stockColValeur;

  /// No description provided for @stockTousMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Tous les magasins'**
  String get stockTousMagasins;

  /// No description provided for @stockSousSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Sous seuil'**
  String get stockSousSeuil;

  /// No description provided for @stockEntreeManuelle.
  ///
  /// In fr, this message translates to:
  /// **'Entrée manuelle'**
  String get stockEntreeManuelle;

  /// No description provided for @stockInventaire.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get stockInventaire;

  /// No description provided for @stockQuantiteConstatee.
  ///
  /// In fr, this message translates to:
  /// **'Quantité constatée'**
  String get stockQuantiteConstatee;

  /// No description provided for @stockNombreConstate.
  ///
  /// In fr, this message translates to:
  /// **'Nombre constaté'**
  String get stockNombreConstate;

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

  /// No description provided for @magasinsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Magasins'**
  String get magasinsTitre;

  /// No description provided for @magasinNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau magasin'**
  String get magasinNouveau;

  /// No description provided for @magasinNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get magasinNom;

  /// No description provided for @magasinAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get magasinAdresse;

  /// No description provided for @magasinPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Principal'**
  String get magasinPrincipal;

  /// No description provided for @magasinMesMagasins.
  ///
  /// In fr, this message translates to:
  /// **'Mes magasins (le premier est le principal)'**
  String get magasinMesMagasins;

  /// No description provided for @magasinAjouterAuxMiens.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à mes magasins'**
  String get magasinAjouterAuxMiens;

  /// No description provided for @magasinRetirerDesMiens.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de mes magasins'**
  String get magasinRetirerDesMiens;

  /// No description provided for @magasinDefinirPrincipal.
  ///
  /// In fr, this message translates to:
  /// **'Définir comme principal'**
  String get magasinDefinirPrincipal;

  /// No description provided for @transfertsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Transferts'**
  String get transfertsTitre;

  /// No description provided for @transfertNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau transfert'**
  String get transfertNouveau;

  /// No description provided for @transfertSource.
  ///
  /// In fr, this message translates to:
  /// **'Magasin source'**
  String get transfertSource;

  /// No description provided for @transfertDestination.
  ///
  /// In fr, this message translates to:
  /// **'Magasin destination'**
  String get transfertDestination;

  /// No description provided for @transfertLignes.
  ///
  /// In fr, this message translates to:
  /// **'Lignes'**
  String get transfertLignes;

  /// No description provided for @transfertAjouterLigne.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get transfertAjouterLigne;

  /// No description provided for @transfertAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun transfert.'**
  String get transfertAucun;

  /// No description provided for @transfertCree.
  ///
  /// In fr, this message translates to:
  /// **'Transfert {code} enregistré : 2 mouvements par ligne.'**
  String transfertCree(String code);

  /// No description provided for @besoinsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Besoins'**
  String get besoinsTitre;

  /// No description provided for @besoinNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau besoin'**
  String get besoinNouveau;

  /// No description provided for @besoinGenerer.
  ///
  /// In fr, this message translates to:
  /// **'Générer sous seuil'**
  String get besoinGenerer;

  /// No description provided for @besoinGeneres.
  ///
  /// In fr, this message translates to:
  /// **'{n} besoin(s) généré(s).'**
  String besoinGeneres(int n);

  /// No description provided for @besoinStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get besoinStatut;

  /// No description provided for @besoinPasserCommande.
  ///
  /// In fr, this message translates to:
  /// **'Passer en Commande'**
  String get besoinPasserCommande;

  /// No description provided for @besoinPasserDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Passer en Disponible'**
  String get besoinPasserDisponible;

  /// No description provided for @besoinRemettreAttente.
  ///
  /// In fr, this message translates to:
  /// **'Remettre En attente'**
  String get besoinRemettreAttente;

  /// No description provided for @besoinAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun besoin.'**
  String get besoinAucun;

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

  /// No description provided for @sortiesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get sortiesTitre;

  /// No description provided for @sortiesOngletSorties.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get sortiesOngletSorties;

  /// No description provided for @sortiesOngletVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get sortiesOngletVentes;

  /// No description provided for @sortieNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sortie'**
  String get sortieNouvelle;

  /// No description provided for @sortieMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get sortieMotif;

  /// No description provided for @sortieAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sortie.'**
  String get sortieAucune;

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

  /// No description provided for @communLignes.
  ///
  /// In fr, this message translates to:
  /// **'{n} ligne(s)'**
  String communLignes(int n);

  /// No description provided for @communCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get communCommentaire;

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

  /// No description provided for @posRaccourciF5.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser BL / SC'**
  String get posRaccourciF5;

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

  /// No description provided for @ventesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get ventesTitre;

  /// No description provided for @ventesColTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get ventesColTicket;

  /// No description provided for @ventesColClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get ventesColClient;

  /// No description provided for @ventesColNet.
  ///
  /// In fr, this message translates to:
  /// **'Net'**
  String get ventesColNet;

  /// No description provided for @ventesColVerse.
  ///
  /// In fr, this message translates to:
  /// **'Versé'**
  String get ventesColVerse;

  /// No description provided for @ventesColReste.
  ///
  /// In fr, this message translates to:
  /// **'Reste dû'**
  String get ventesColReste;

  /// No description provided for @ventesColStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get ventesColStatut;

  /// No description provided for @ventesColCaisse.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get ventesColCaisse;

  /// No description provided for @ventesColVendeur.
  ///
  /// In fr, this message translates to:
  /// **'Vendeur'**
  String get ventesColVendeur;

  /// No description provided for @ventesAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente.'**
  String get ventesAucune;

  /// No description provided for @ventesVoirTicket.
  ///
  /// In fr, this message translates to:
  /// **'Voir le ticket'**
  String get ventesVoirTicket;

  /// No description provided for @ventesAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vente'**
  String get ventesAnnuler;

  /// No description provided for @ventesConfirmerAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vente {code} ? Le stock et les points seront restitués ; le ticket scellé est conservé.'**
  String ventesConfirmerAnnulation(String code);

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

  /// No description provided for @ventesFiltreToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get ventesFiltreToutes;

  /// No description provided for @ventesFiltreValidees.
  ///
  /// In fr, this message translates to:
  /// **'Validées'**
  String get ventesFiltreValidees;

  /// No description provided for @ventesFiltreAnnulees.
  ///
  /// In fr, this message translates to:
  /// **'Annulées'**
  String get ventesFiltreAnnulees;

  /// No description provided for @ventesFiltreCredit.
  ///
  /// In fr, this message translates to:
  /// **'À crédit'**
  String get ventesFiltreCredit;

  /// No description provided for @statutVenteValidee.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get statutVenteValidee;

  /// No description provided for @statutVenteAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statutVenteAnnulee;

  /// No description provided for @ticketDetail.
  ///
  /// In fr, this message translates to:
  /// **'Ticket {code}'**
  String ticketDetail(String code);

  /// No description provided for @retoursTitre.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get retoursTitre;

  /// No description provided for @retourNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau retour'**
  String get retourNouveau;

  /// No description provided for @retourVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente d\'origine'**
  String get retourVente;

  /// No description provided for @retourMotif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get retourMotif;

  /// No description provided for @retourRembourser.
  ///
  /// In fr, this message translates to:
  /// **'Montant remboursé'**
  String get retourRembourser;

  /// No description provided for @retourModeRemboursement.
  ///
  /// In fr, this message translates to:
  /// **'Mode de remboursement'**
  String get retourModeRemboursement;

  /// No description provided for @retourAvoir.
  ///
  /// In fr, this message translates to:
  /// **'Le reste est porté en avoir sur le compte du client.'**
  String get retourAvoir;

  /// No description provided for @retourAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun retour.'**
  String get retourAucun;

  /// No description provided for @retourColTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total retourné'**
  String get retourColTotal;

  /// No description provided for @retourColRembourse.
  ///
  /// In fr, this message translates to:
  /// **'Remboursé'**
  String get retourColRembourse;

  /// No description provided for @retourQuantiteMax.
  ///
  /// In fr, this message translates to:
  /// **'Quantité retournée (max {max})'**
  String retourQuantiteMax(String max);

  /// No description provided for @retourErreurVenteInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Vente introuvable.'**
  String get retourErreurVenteInconnue;

  /// No description provided for @retourErreurVenteAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Cette vente est annulée.'**
  String get retourErreurVenteAnnulee;

  /// No description provided for @retourErreurLignes.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez au moins une quantité à retourner.'**
  String get retourErreurLignes;

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

  /// No description provided for @retourCree.
  ///
  /// In fr, this message translates to:
  /// **'Retour {code} enregistré : {total} (remboursé {rembourse}).'**
  String retourCree(String code, String total, String rembourse);

  /// No description provided for @clientsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get clientsTitre;

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

  /// No description provided for @clientPlafond.
  ///
  /// In fr, this message translates to:
  /// **'Plafond de crédit'**
  String get clientPlafond;

  /// No description provided for @clientSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde dû'**
  String get clientSolde;

  /// No description provided for @clientAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client.'**
  String get clientAucun;

  /// No description provided for @clientFiche.
  ///
  /// In fr, this message translates to:
  /// **'Fiche client'**
  String get clientFiche;

  /// No description provided for @clientDocumentsOuverts.
  ///
  /// In fr, this message translates to:
  /// **'Documents ouverts'**
  String get clientDocumentsOuverts;

  /// No description provided for @clientVersements.
  ///
  /// In fr, this message translates to:
  /// **'Versements'**
  String get clientVersements;

  /// No description provided for @clientNouveauVersement.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser un versement'**
  String get clientNouveauVersement;

  /// No description provided for @fournisseursTitre.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get fournisseursTitre;

  /// No description provided for @fournisseurNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fournisseur'**
  String get fournisseurNouveau;

  /// No description provided for @fournisseurAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur.'**
  String get fournisseurAucun;

  /// No description provided for @fournisseurFiche.
  ///
  /// In fr, this message translates to:
  /// **'Fiche fournisseur'**
  String get fournisseurFiche;

  /// No description provided for @fournisseurNouveauVersement.
  ///
  /// In fr, this message translates to:
  /// **'Régler un versement'**
  String get fournisseurNouveauVersement;

  /// No description provided for @versementsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Versements'**
  String get versementsTitre;

  /// No description provided for @versementNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau versement'**
  String get versementNouveau;

  /// No description provided for @versementTiers.
  ///
  /// In fr, this message translates to:
  /// **'Tiers'**
  String get versementTiers;

  /// No description provided for @versementTiersClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get versementTiersClient;

  /// No description provided for @versementTiersFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get versementTiersFournisseur;

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

  /// No description provided for @versementReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get versementReference;

  /// No description provided for @versementAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun versement.'**
  String get versementAucun;

  /// No description provided for @versementColSens.
  ///
  /// In fr, this message translates to:
  /// **'Sens'**
  String get versementColSens;

  /// No description provided for @versementColImpute.
  ///
  /// In fr, this message translates to:
  /// **'Imputé'**
  String get versementColImpute;

  /// No description provided for @versementColNonImpute.
  ///
  /// In fr, this message translates to:
  /// **'Non imputé'**
  String get versementColNonImpute;

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

  /// No description provided for @versementSupprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le versement'**
  String get versementSupprimer;

  /// No description provided for @versementConfirmerSuppression.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le versement {code} ? Les imputations seront annulées.'**
  String versementConfirmerSuppression(String code);

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

  /// No description provided for @versementEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Versement {code} enregistré : {impute} imputé(s), {reste} en avance.'**
  String versementEnregistre(String code, String impute, String reste);

  /// No description provided for @sensEncaissement.
  ///
  /// In fr, this message translates to:
  /// **'Encaissement'**
  String get sensEncaissement;

  /// No description provided for @sensDecaissement.
  ///
  /// In fr, this message translates to:
  /// **'Décaissement'**
  String get sensDecaissement;

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

  /// No description provided for @achatsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Entrées / Achats'**
  String get achatsTitre;

  /// No description provided for @achatNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle entrée'**
  String get achatNouveau;

  /// No description provided for @achatSmartScan.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan IA'**
  String get achatSmartScan;

  /// No description provided for @achatFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get achatFournisseur;

  /// No description provided for @achatReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence facture'**
  String get achatReference;

  /// No description provided for @achatMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get achatMagasin;

  /// No description provided for @achatLignes.
  ///
  /// In fr, this message translates to:
  /// **'Lignes'**
  String get achatLignes;

  /// No description provided for @achatPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get achatPrixAchat;

  /// No description provided for @achatNouveauPrixVente.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau prix de vente'**
  String get achatNouveauPrixVente;

  /// No description provided for @achatVerse.
  ///
  /// In fr, this message translates to:
  /// **'Versé'**
  String get achatVerse;

  /// No description provided for @achatModePaiement.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get achatModePaiement;

  /// No description provided for @achatMettreAJourPrix.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour le prix d\'achat des produits'**
  String get achatMettreAJourPrix;

  /// No description provided for @achatAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune entrée.'**
  String get achatAucun;

  /// No description provided for @achatColTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get achatColTotal;

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

  /// No description provided for @achatAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'entrée'**
  String get achatAnnuler;

  /// No description provided for @achatConfirmerAnnulation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'entrée {code} ? Le stock sera ressorti.'**
  String achatConfirmerAnnulation(String code);

  /// No description provided for @achatEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Entrée {code} enregistrée : {total}, reste dû {reste}.'**
  String achatEnregistre(String code, String total, String reste);

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

  /// No description provided for @statutAchatValide.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get statutAchatValide;

  /// No description provided for @statutAchatAnnule.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get statutAchatAnnule;

  /// No description provided for @sourceManuel.
  ///
  /// In fr, this message translates to:
  /// **'Manuel'**
  String get sourceManuel;

  /// No description provided for @sourceSmartScan.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan'**
  String get sourceSmartScan;

  /// No description provided for @smartScanTitre.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan IA — facture fournisseur'**
  String get smartScanTitre;

  /// No description provided for @smartScanIntro.
  ///
  /// In fr, this message translates to:
  /// **'Prenez en photo ou choisissez la facture (image ou PDF) : les lignes sont reconnues par le serveur CaisseDZ et rapprochées de votre catalogue.'**
  String get smartScanIntro;

  /// No description provided for @smartScanQuota.
  ///
  /// In fr, this message translates to:
  /// **'Quota : {restant} analyse(s) restante(s) sur {total}'**
  String smartScanQuota(int restant, int total);

  /// No description provided for @smartScanChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une facture'**
  String get smartScanChoisir;

  /// No description provided for @smartScanAnalyser.
  ///
  /// In fr, this message translates to:
  /// **'Analyser'**
  String get smartScanAnalyser;

  /// No description provided for @smartScanAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse en cours…'**
  String get smartScanAnalyse;

  /// No description provided for @smartScanAucuneLigne.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ligne reconnue.'**
  String get smartScanAucuneLigne;

  /// No description provided for @smartScanLigneNonRapprochee.
  ///
  /// In fr, this message translates to:
  /// **'Non rapprochée'**
  String get smartScanLigneNonRapprochee;

  /// No description provided for @smartScanRapprocher.
  ///
  /// In fr, this message translates to:
  /// **'Associer un produit'**
  String get smartScanRapprocher;

  /// No description provided for @smartScanCreerEntree.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'entrée'**
  String get smartScanCreerEntree;

  /// No description provided for @smartScanQuotaAtteint.
  ///
  /// In fr, this message translates to:
  /// **'Quota Smart Scan atteint'**
  String get smartScanQuotaAtteint;

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

  /// No description provided for @gestionCaisseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de caisse'**
  String get gestionCaisseTitre;

  /// No description provided for @gestionCaisseOngletCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Caisses'**
  String get gestionCaisseOngletCaisses;

  /// No description provided for @gestionCaisseOngletMouvements.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements'**
  String get gestionCaisseOngletMouvements;

  /// No description provided for @gestionCaisseOngletTransferts.
  ///
  /// In fr, this message translates to:
  /// **'Transferts entre caisses'**
  String get gestionCaisseOngletTransferts;

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

  /// No description provided for @caisseSansMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Sans magasin'**
  String get caisseSansMagasin;

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

  /// No description provided for @caisseSoldeEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Solde espèces'**
  String get caisseSoldeEspeces;

  /// No description provided for @caisseSoldeTotal.
  ///
  /// In fr, this message translates to:
  /// **'Solde total'**
  String get caisseSoldeTotal;

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

  /// No description provided for @caisseActiver.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get caisseActiver;

  /// No description provided for @mouvementApport.
  ///
  /// In fr, this message translates to:
  /// **'Apport'**
  String get mouvementApport;

  /// No description provided for @mouvementDepense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get mouvementDepense;

  /// No description provided for @mouvementColType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get mouvementColType;

  /// No description provided for @mouvementColSens.
  ///
  /// In fr, this message translates to:
  /// **'Sens'**
  String get mouvementColSens;

  /// No description provided for @mouvementColMontant.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get mouvementColMontant;

  /// No description provided for @mouvementColMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get mouvementColMode;

  /// No description provided for @mouvementColReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get mouvementColReference;

  /// No description provided for @mouvementAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get mouvementAucun;

  /// No description provided for @mouvementToutesCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les caisses'**
  String get mouvementToutesCaisses;

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
  /// **'Annulation'**
  String get mvtAnnulation;

  /// No description provided for @mvtRemboursement.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement'**
  String get mvtRemboursement;

  /// No description provided for @mvtEncaissement.
  ///
  /// In fr, this message translates to:
  /// **'Encaissement'**
  String get mvtEncaissement;

  /// No description provided for @mvtDecaissement.
  ///
  /// In fr, this message translates to:
  /// **'Décaissement'**
  String get mvtDecaissement;

  /// No description provided for @mvtApport.
  ///
  /// In fr, this message translates to:
  /// **'Apport'**
  String get mvtApport;

  /// No description provided for @mvtDepense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get mvtDepense;

  /// No description provided for @mvtTransfert.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get mvtTransfert;

  /// No description provided for @mvtFondInitial.
  ///
  /// In fr, this message translates to:
  /// **'Fond initial'**
  String get mvtFondInitial;

  /// No description provided for @mvtRetrait.
  ///
  /// In fr, this message translates to:
  /// **'Retrait'**
  String get mvtRetrait;

  /// No description provided for @mvtEcart.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get mvtEcart;

  /// No description provided for @sensEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get sensEntree;

  /// No description provided for @sensSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get sensSortie;

  /// No description provided for @transfertCaisseNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau transfert'**
  String get transfertCaisseNouveau;

  /// No description provided for @transfertCaisseSource.
  ///
  /// In fr, this message translates to:
  /// **'Caisse source'**
  String get transfertCaisseSource;

  /// No description provided for @transfertCaisseDestination.
  ///
  /// In fr, this message translates to:
  /// **'Caisse destination'**
  String get transfertCaisseDestination;

  /// No description provided for @transfertCaisseAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun transfert.'**
  String get transfertCaisseAucun;

  /// No description provided for @transfertCaisseCree.
  ///
  /// In fr, this message translates to:
  /// **'Transfert {code} enregistré (2 mouvements).'**
  String transfertCaisseCree(String code);

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

  /// No description provided for @cloturesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures Z'**
  String get cloturesTitre;

  /// No description provided for @clotureNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer (Z)'**
  String get clotureNouvelle;

  /// No description provided for @clotureApercuTitre.
  ///
  /// In fr, this message translates to:
  /// **'Clôture Z — aperçu de la période'**
  String get clotureApercuTitre;

  /// No description provided for @cloturePeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get cloturePeriode;

  /// No description provided for @clotureDebut.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get clotureDebut;

  /// No description provided for @clotureFin.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get clotureFin;

  /// No description provided for @clotureColVentes.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get clotureColVentes;

  /// No description provided for @clotureColAnnulations.
  ///
  /// In fr, this message translates to:
  /// **'Annulations'**
  String get clotureColAnnulations;

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

  /// No description provided for @clotureColHash.
  ///
  /// In fr, this message translates to:
  /// **'Scellement'**
  String get clotureColHash;

  /// No description provided for @clotureColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get clotureColUtilisateur;

  /// No description provided for @clotureAucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clôture.'**
  String get clotureAucune;

  /// No description provided for @clotureConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Sceller la clôture'**
  String get clotureConfirmer;

  /// No description provided for @clotureCreee.
  ///
  /// In fr, this message translates to:
  /// **'Clôture {code} scellée. Hash : {hash}'**
  String clotureCreee(String code, String hash);

  /// No description provided for @clotureDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la clôture'**
  String get clotureDetail;

  /// No description provided for @clotureParMode.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements par mode'**
  String get clotureParMode;

  /// No description provided for @clotureSoldes.
  ///
  /// In fr, this message translates to:
  /// **'Soldes des caisses'**
  String get clotureSoldes;

  /// No description provided for @clotureDerniereVente.
  ///
  /// In fr, this message translates to:
  /// **'Dernier ticket'**
  String get clotureDerniereVente;

  /// No description provided for @clotureHashPrecedent.
  ///
  /// In fr, this message translates to:
  /// **'Hash précédent'**
  String get clotureHashPrecedent;

  /// No description provided for @clotureHash.
  ///
  /// In fr, this message translates to:
  /// **'Hash'**
  String get clotureHash;

  /// No description provided for @clotureVerifier.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier la chaîne'**
  String get clotureVerifier;

  /// No description provided for @clotureChaineOk.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne des clôtures intacte.'**
  String get clotureChaineOk;

  /// No description provided for @clotureChaineKo.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne altérée à partir de la clôture {code}.'**
  String clotureChaineKo(String code);

  /// No description provided for @clotureErreurSession.
  ///
  /// In fr, this message translates to:
  /// **'Fermez toutes les sessions de caisse avant de clôturer.'**
  String get clotureErreurSession;

  /// No description provided for @clotureErreurRien.
  ///
  /// In fr, this message translates to:
  /// **'Rien à clôturer depuis la dernière clôture.'**
  String get clotureErreurRien;

  /// No description provided for @clotureAvertissementImmuable.
  ///
  /// In fr, this message translates to:
  /// **'Une clôture est définitive : elle ne peut être ni modifiée ni supprimée, et les documents de la période ne pourront plus être annulés.'**
  String get clotureAvertissementImmuable;

  /// No description provided for @exportFiscalTitre.
  ///
  /// In fr, this message translates to:
  /// **'Export fiscal'**
  String get exportFiscalTitre;

  /// No description provided for @exportFiscalDebut.
  ///
  /// In fr, this message translates to:
  /// **'Du (jj/mm/aaaa)'**
  String get exportFiscalDebut;

  /// No description provided for @exportFiscalFin.
  ///
  /// In fr, this message translates to:
  /// **'Au (jj/mm/aaaa)'**
  String get exportFiscalFin;

  /// No description provided for @exportFiscalGenerer.
  ///
  /// In fr, this message translates to:
  /// **'Générer l\'archive'**
  String get exportFiscalGenerer;

  /// No description provided for @exportFiscalOk.
  ///
  /// In fr, this message translates to:
  /// **'Archive enregistrée : {chemin} ({ventes} ventes, {clotures} clôtures, empreinte vérifiée).'**
  String exportFiscalOk(String chemin, int ventes, int clotures);

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

  /// No description provided for @exportFiscalPermission.
  ///
  /// In fr, this message translates to:
  /// **'Permission « exporter les données » requise.'**
  String get exportFiscalPermission;

  /// No description provided for @tableauBordTitre.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get tableauBordTitre;

  /// No description provided for @tableauBordCaJour.
  ///
  /// In fr, this message translates to:
  /// **'CA du jour'**
  String get tableauBordCaJour;

  /// No description provided for @tableauBordTicketsJour.
  ///
  /// In fr, this message translates to:
  /// **'Tickets du jour'**
  String get tableauBordTicketsJour;

  /// No description provided for @tableauBordPanierMoyen.
  ///
  /// In fr, this message translates to:
  /// **'Panier moyen'**
  String get tableauBordPanierMoyen;

  /// No description provided for @tableauBordCaMois.
  ///
  /// In fr, this message translates to:
  /// **'CA du mois'**
  String get tableauBordCaMois;

  /// No description provided for @tableauBordSousSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Produits sous seuil'**
  String get tableauBordSousSeuil;

  /// No description provided for @tableauBordCreances.
  ///
  /// In fr, this message translates to:
  /// **'Créances clients'**
  String get tableauBordCreances;

  /// No description provided for @tableauBordCa30Jours.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires des 30 derniers jours'**
  String get tableauBordCa30Jours;

  /// No description provided for @tableauBordPaiements.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements par mode (30 jours)'**
  String get tableauBordPaiements;

  /// No description provided for @tableauBordTopProduits.
  ///
  /// In fr, this message translates to:
  /// **'Top 5 produits (30 jours)'**
  String get tableauBordTopProduits;

  /// No description provided for @tableauBordCategories.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par catégorie (30 jours)'**
  String get tableauBordCategories;

  /// No description provided for @tableauBordCaMensuel.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires mensuel (12 mois)'**
  String get tableauBordCaMensuel;

  /// No description provided for @tableauBordActualiser.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get tableauBordActualiser;

  /// No description provided for @situationTitre.
  ///
  /// In fr, this message translates to:
  /// **'Situation'**
  String get situationTitre;

  /// No description provided for @situationRapport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport'**
  String get situationRapport;

  /// No description provided for @situationDu.
  ///
  /// In fr, this message translates to:
  /// **'Du (jj/mm/aaaa)'**
  String get situationDu;

  /// No description provided for @situationAu.
  ///
  /// In fr, this message translates to:
  /// **'Au (jj/mm/aaaa)'**
  String get situationAu;

  /// No description provided for @situationAfficher.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get situationAfficher;

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

  /// No description provided for @situationAucuneLigne.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée sur la période.'**
  String get situationAucuneLigne;

  /// No description provided for @situationDatesInvalides.
  ///
  /// In fr, this message translates to:
  /// **'Dates invalides.'**
  String get situationDatesInvalides;

  /// No description provided for @situationExportOk.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {chemin}'**
  String situationExportOk(String chemin);

  /// No description provided for @situationPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période du {debut} au {fin}'**
  String situationPeriode(String debut, String fin);

  /// No description provided for @rapportVentesJour.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par jour'**
  String get rapportVentesJour;

  /// No description provided for @rapportVentesProduit.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par produit'**
  String get rapportVentesProduit;

  /// No description provided for @rapportVentesCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par catégorie'**
  String get rapportVentesCategorie;

  /// No description provided for @rapportVentesClient.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par client'**
  String get rapportVentesClient;

  /// No description provided for @rapportVentesVendeur.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par vendeur et caisse'**
  String get rapportVentesVendeur;

  /// No description provided for @rapportEncaissementsMode.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements par mode'**
  String get rapportEncaissementsMode;

  /// No description provided for @rapportAchatsFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Achats par fournisseur'**
  String get rapportAchatsFournisseur;

  /// No description provided for @rapportRetours.
  ///
  /// In fr, this message translates to:
  /// **'Retours clients'**
  String get rapportRetours;

  /// No description provided for @rapportEtatStock.
  ///
  /// In fr, this message translates to:
  /// **'État du stock valorisé'**
  String get rapportEtatStock;

  /// No description provided for @rapportCreancesDettes.
  ///
  /// In fr, this message translates to:
  /// **'Créances et dettes'**
  String get rapportCreancesDettes;

  /// No description provided for @zakatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Zakat'**
  String get zakatTitre;

  /// No description provided for @zakatIntro.
  ///
  /// In fr, this message translates to:
  /// **'Zakat sur les biens commerciaux : 2,5 % de l\'assiette si elle atteint le nissab (85 g d\'or).'**
  String get zakatIntro;

  /// No description provided for @zakatPrixOr.
  ///
  /// In fr, this message translates to:
  /// **'Prix du gramme d\'or ({devise})'**
  String zakatPrixOr(String devise);

  /// No description provided for @zakatEnregistrerPrix.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le cours'**
  String get zakatEnregistrerPrix;

  /// No description provided for @zakatStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock (prix d\'achat)'**
  String get zakatStock;

  /// No description provided for @zakatCaisses.
  ///
  /// In fr, this message translates to:
  /// **'Caisses'**
  String get zakatCaisses;

  /// No description provided for @zakatCreances.
  ///
  /// In fr, this message translates to:
  /// **'Créances clients'**
  String get zakatCreances;

  /// No description provided for @zakatDettes.
  ///
  /// In fr, this message translates to:
  /// **'Dettes fournisseurs'**
  String get zakatDettes;

  /// No description provided for @zakatAssiette.
  ///
  /// In fr, this message translates to:
  /// **'Assiette'**
  String get zakatAssiette;

  /// No description provided for @zakatNissab.
  ///
  /// In fr, this message translates to:
  /// **'Nissab (85 g)'**
  String get zakatNissab;

  /// No description provided for @zakatMontant.
  ///
  /// In fr, this message translates to:
  /// **'Zakat due (2,5 %)'**
  String get zakatMontant;

  /// No description provided for @zakatAssujetti.
  ///
  /// In fr, this message translates to:
  /// **'Assujetti : l\'assiette atteint le nissab.'**
  String get zakatAssujetti;

  /// No description provided for @zakatNonAssujetti.
  ///
  /// In fr, this message translates to:
  /// **'Non assujetti : l\'assiette est inférieure au nissab.'**
  String get zakatNonAssujetti;

  /// No description provided for @zakatPrixManquant.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez le cours de l\'or pour calculer le nissab.'**
  String get zakatPrixManquant;

  /// No description provided for @historiqueTitre.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historiqueTitre;

  /// No description provided for @historiqueColUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get historiqueColUtilisateur;

  /// No description provided for @historiqueColAction.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get historiqueColAction;

  /// No description provided for @historiqueColEntite.
  ///
  /// In fr, this message translates to:
  /// **'Entité'**
  String get historiqueColEntite;

  /// No description provided for @historiqueColDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get historiqueColDetail;

  /// No description provided for @historiqueToutesEntites.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les entités'**
  String get historiqueToutesEntites;

  /// No description provided for @historiqueAucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération.'**
  String get historiqueAucun;

  /// No description provided for @parametresTitre.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get parametresTitre;

  /// No description provided for @parametresOngletGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get parametresOngletGeneral;

  /// No description provided for @parametresOngletBoutique.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get parametresOngletBoutique;

  /// No description provided for @parametresOngletVente.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get parametresOngletVente;

  /// No description provided for @parametresOngletImpression.
  ///
  /// In fr, this message translates to:
  /// **'Impression'**
  String get parametresOngletImpression;

  /// No description provided for @parametresOngletServeur.
  ///
  /// In fr, this message translates to:
  /// **'Serveurs'**
  String get parametresOngletServeur;

  /// No description provided for @parametresOngletSauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get parametresOngletSauvegarde;

  /// No description provided for @parametresEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés.'**
  String get parametresEnregistre;

  /// No description provided for @parametresBoutiqueNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la boutique'**
  String get parametresBoutiqueNom;

  /// No description provided for @parametresBoutiqueRc.
  ///
  /// In fr, this message translates to:
  /// **'Registre de commerce (RC)'**
  String get parametresBoutiqueRc;

  /// No description provided for @parametresBoutiqueNif.
  ///
  /// In fr, this message translates to:
  /// **'NIF'**
  String get parametresBoutiqueNif;

  /// No description provided for @parametresBoutiqueAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get parametresBoutiqueAdresse;

  /// No description provided for @parametresBoutiqueTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get parametresBoutiqueTelephone;

  /// No description provided for @parametresBoutiqueEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get parametresBoutiqueEmail;

  /// No description provided for @parametresMarge.
  ///
  /// In fr, this message translates to:
  /// **'Marge par défaut (%)'**
  String get parametresMarge;

  /// No description provided for @parametresDevise.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get parametresDevise;

  /// No description provided for @parametresSeuil.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de stock global'**
  String get parametresSeuil;

  /// No description provided for @parametresFidelite.
  ///
  /// In fr, this message translates to:
  /// **'Programme de fidélité'**
  String get parametresFidelite;

  /// No description provided for @parametresPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points par dinar'**
  String get parametresPoints;

  /// No description provided for @parametresGardeStock.
  ///
  /// In fr, this message translates to:
  /// **'Garde de stock : toujours active (aucune vente sans stock).'**
  String get parametresGardeStock;

  /// No description provided for @parametresImprimanteType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'imprimante'**
  String get parametresImprimanteType;

  /// No description provided for @parametresImprimanteAdresse.
  ///
  /// In fr, this message translates to:
  /// **'File d\'attente Windows ou adresse IP:port'**
  String get parametresImprimanteAdresse;

  /// No description provided for @parametresImprimanteLargeur.
  ///
  /// In fr, this message translates to:
  /// **'Largeur du ticket'**
  String get parametresImprimanteLargeur;

  /// No description provided for @parametresImprimanteNormale.
  ///
  /// In fr, this message translates to:
  /// **'Normale (dialogue d\'impression)'**
  String get parametresImprimanteNormale;

  /// No description provided for @parametresImprimanteUsb.
  ///
  /// In fr, this message translates to:
  /// **'USB (spouleur Windows)'**
  String get parametresImprimanteUsb;

  /// No description provided for @parametresImprimanteReseau.
  ///
  /// In fr, this message translates to:
  /// **'Réseau (IP:port)'**
  String get parametresImprimanteReseau;

  /// No description provided for @parametresImprimanteBluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get parametresImprimanteBluetooth;

  /// No description provided for @parametresServeurUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du serveur CaisseDZ'**
  String get parametresServeurUrl;

  /// No description provided for @parametresServeurCle.
  ///
  /// In fr, this message translates to:
  /// **'Clé API'**
  String get parametresServeurCle;

  /// No description provided for @parametresMantoujUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du catalogue Mantouj'**
  String get parametresMantoujUrl;

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

  /// No description provided for @sauvegardeCreer.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde'**
  String get sauvegardeCreer;

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

  /// No description provided for @sauvegardeFichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier de sauvegarde'**
  String get sauvegardeFichier;

  /// No description provided for @sauvegardeChoisirFichier.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier…'**
  String get sauvegardeChoisirFichier;

  /// No description provided for @sauvegardeOk.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde enregistrée : {chemin}'**
  String sauvegardeOk(String chemin);

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

  /// No description provided for @dsLotVerifier.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez la sélection avant de confirmer.'**
  String get dsLotVerifier;

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

  /// No description provided for @dsColonnesVisibles.
  ///
  /// In fr, this message translates to:
  /// **'{n} sur {total} colonnes visibles'**
  String dsColonnesVisibles(int n, int total);

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

  /// No description provided for @dsFavori.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get dsFavori;

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

  /// No description provided for @dsAucunModule.
  ///
  /// In fr, this message translates to:
  /// **'Aucun module'**
  String get dsAucunModule;

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

  /// No description provided for @dsChoisirListe.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la liste'**
  String get dsChoisirListe;

  /// No description provided for @dsRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get dsRechercher;

  /// No description provided for @dsSelectionner.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get dsSelectionner;

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

  /// No description provided for @dsBarcodeFormatLibre.
  ///
  /// In fr, this message translates to:
  /// **'Format libre (non EAN-13)'**
  String get dsBarcodeFormatLibre;

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
  /// **'Mot de passe oublié ? Voyez l\'administrateur'**
  String get connexionMotDePasseOublie;

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

  /// No description provided for @configDescription.
  ///
  /// In fr, this message translates to:
  /// **'Quatre étapes pour configurer la boutique. Tout reste modifiable dans Paramètres.'**
  String get configDescription;

  /// No description provided for @configEtapeLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue & devise'**
  String get configEtapeLangue;

  /// No description provided for @configEtapeLangueDetail.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get configEtapeLangueDetail;

  /// No description provided for @configEtapeBoutiqueDetail.
  ///
  /// In fr, this message translates to:
  /// **'Ticket et mentions'**
  String get configEtapeBoutiqueDetail;

  /// No description provided for @configEtapePaiements.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get configEtapePaiements;

  /// No description provided for @configEtapePaiementsDetail.
  ///
  /// In fr, this message translates to:
  /// **'Moyens acceptés'**
  String get configEtapePaiementsDetail;

  /// No description provided for @configEtapeVenteDetail.
  ///
  /// In fr, this message translates to:
  /// **'Prix et alertes'**
  String get configEtapeVenteDetail;

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

  /// No description provided for @alertesResume.
  ///
  /// In fr, this message translates to:
  /// **'{urgentes, plural, =1{1 urgente} other{{urgentes} urgentes}} · {surveiller} à surveiller'**
  String alertesResume(int urgentes, int surveiller);

  /// No description provided for @alertesToutTraite.
  ///
  /// In fr, this message translates to:
  /// **'Tout est traité'**
  String get alertesToutTraite;

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

  /// No description provided for @tiersChampsObligatoires.
  ///
  /// In fr, this message translates to:
  /// **'Les champs marqués * sont obligatoires'**
  String get tiersChampsObligatoires;

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

  /// No description provided for @tiersDescriptionClients.
  ///
  /// In fr, this message translates to:
  /// **'{n} clients · {nb} avec un crédit en cours'**
  String tiersDescriptionClients(int n, int nb);

  /// No description provided for @tiersDescriptionFournisseurs.
  ///
  /// In fr, this message translates to:
  /// **'{n} fournisseurs · {nb} avec un crédit en cours'**
  String tiersDescriptionFournisseurs(int n, int nb);

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

  /// No description provided for @tiersReleveClient.
  ///
  /// In fr, this message translates to:
  /// **'Relevé client'**
  String get tiersReleveClient;

  /// No description provided for @tiersReleveFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Relevé fournisseur'**
  String get tiersReleveFournisseur;

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

  /// No description provided for @tiersSolde.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get tiersSolde;

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

  /// No description provided for @versementAideClient.
  ///
  /// In fr, this message translates to:
  /// **'Le montant est imputé sur les paniers à crédit du client, du plus ancien au plus récent.'**
  String get versementAideClient;

  /// No description provided for @versementAideFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Le montant est imputé sur les entrées à crédit du fournisseur, de la plus ancienne à la plus récente.'**
  String get versementAideFournisseur;

  /// No description provided for @versementAideRetourClient.
  ///
  /// In fr, this message translates to:
  /// **'Argent rendu au client (avance ou trop-perçu) : sortie de caisse.'**
  String get versementAideRetourClient;

  /// No description provided for @versementAideRetourFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Argent remboursé par le fournisseur : entrée en caisse.'**
  String get versementAideRetourFournisseur;

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

  /// No description provided for @tableauBordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Du {du} au {au}, comparé aux {n} jours précédents.'**
  String tableauBordDescription(String au, String du, int n);

  /// No description provided for @situationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Analyses détaillées sur la période — chaque vue est exportable en Excel et PDF.'**
  String get situationDescription;

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

  /// No description provided for @tableauBordVsPrecedente.
  ///
  /// In fr, this message translates to:
  /// **'vs période précédente'**
  String get tableauBordVsPrecedente;

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

  /// No description provided for @ventesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Tous les paniers encaissés — tickets et BL / SC'**
  String get ventesDescription;

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

  /// No description provided for @ventesModifierDescription.
  ///
  /// In fr, this message translates to:
  /// **'{code} · les lignes ne sont pas modifiables — utilisez un retour.'**
  String ventesModifierDescription(String code);

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

  /// No description provided for @statutTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get statutTicket;

  /// No description provided for @statutFacture.
  ///
  /// In fr, this message translates to:
  /// **'BL / SC'**
  String get statutFacture;

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

  /// No description provided for @retoursDescription.
  ///
  /// In fr, this message translates to:
  /// **'Retours clients (remise en stock, remboursement) et retours fournisseurs'**
  String get retoursDescription;

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

  /// No description provided for @retoursNouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau retour'**
  String get retoursNouveau;

  /// No description provided for @retoursModifierTitre.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le retour'**
  String get retoursModifierTitre;

  /// No description provided for @retoursFormDescription.
  ///
  /// In fr, this message translates to:
  /// **'Retour d\'un produit vendu (client) ou reçu (fournisseur). Le stock est réintégré ou déduit.'**
  String get retoursFormDescription;

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

  /// No description provided for @posBlSc.
  ///
  /// In fr, this message translates to:
  /// **'BL / SC'**
  String get posBlSc;

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

  /// No description provided for @posEncBlscTitre.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser BL / SC'**
  String get posEncBlscTitre;

  /// No description provided for @posEncSaveTitre.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le ticket'**
  String get posEncSaveTitre;

  /// No description provided for @posEncTicketDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez le montant reçu puis validez : le ticket est imprimé.'**
  String get posEncTicketDesc;

  /// No description provided for @posEncBlscDesc.
  ///
  /// In fr, this message translates to:
  /// **'Bon de livraison sans cachet, avec mentions légales.'**
  String get posEncBlscDesc;

  /// No description provided for @posEncSaveDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le ticket est enregistré : le reste est porté au crédit du client.'**
  String get posEncSaveDesc;

  /// No description provided for @posEncTicketOk.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser et imprimer'**
  String get posEncTicketOk;

  /// No description provided for @posEncBlscOk.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser le BL / SC'**
  String get posEncBlscOk;

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

  /// No description provided for @posSortieImprimer.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get posSortieImprimer;

  /// No description provided for @posSortieImprimerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante A4 par défaut'**
  String get posSortieImprimerDesc;

  /// No description provided for @posSortiePdf.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer en PDF'**
  String get posSortiePdf;

  /// No description provided for @posSortiePdfDesc.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer ou partager le document'**
  String get posSortiePdfDesc;

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

  /// No description provided for @posSelScanne.
  ///
  /// In fr, this message translates to:
  /// **'Produit scanné · {code}'**
  String posSelScanne(String code);

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

  /// No description provided for @posPrixDesc.
  ///
  /// In fr, this message translates to:
  /// **'Réservé aux rôles autorisés — mot de passe requis.'**
  String get posPrixDesc;

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

  /// No description provided for @posRechDesc.
  ///
  /// In fr, this message translates to:
  /// **'Filtrez puis cochez les produits à ajouter au panier.'**
  String get posRechDesc;

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

  /// No description provided for @posIntrouvableDesc.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit actif ne correspond à ce code-barres.'**
  String get posIntrouvableDesc;

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

  /// No description provided for @posOuvertureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Comptez le fond de caisse avant de commencer.'**
  String get posOuvertureDesc;

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

  /// No description provided for @posClotureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Session {code} · ouverte à {heure}'**
  String posClotureDesc(String code, String heure);

  /// No description provided for @posClotureFond.
  ///
  /// In fr, this message translates to:
  /// **'Fond de départ'**
  String get posClotureFond;

  /// No description provided for @posClotureVentesEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Ventes en espèces (monnaie déduite)'**
  String get posClotureVentesEspeces;

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

  /// No description provided for @posMvtDesc.
  ///
  /// In fr, this message translates to:
  /// **'Entrée ou sortie hors vente : dépôt de fond, prélèvement, frais divers.'**
  String get posMvtDesc;

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

  /// No description provided for @posVdjDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du {date}'**
  String posVdjDesc(String date);

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

  /// No description provided for @posRecDesc.
  ///
  /// In fr, this message translates to:
  /// **'Lignes vendues le {date}'**
  String posRecDesc(String date);

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

  /// No description provided for @posParamDesc.
  ///
  /// In fr, this message translates to:
  /// **'S\'applique à ce poste jusqu\'à la déconnexion.'**
  String get posParamDesc;

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

  /// No description provided for @posEntreeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide'**
  String get posEntreeTitre;

  /// No description provided for @posEntreeDesc.
  ///
  /// In fr, this message translates to:
  /// **'{nom} · {magasin}'**
  String posEntreeDesc(String magasin, String nom);

  /// No description provided for @posEntreeFaite.
  ///
  /// In fr, this message translates to:
  /// **'Entrée rapide enregistrée'**
  String get posEntreeFaite;

  /// No description provided for @posEntreeFaiteDesc.
  ///
  /// In fr, this message translates to:
  /// **'{nom} · stock mis à jour'**
  String posEntreeFaiteDesc(String nom);

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
