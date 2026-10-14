// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CaisseDZ';

  @override
  String get shellNavGeneral => 'General';

  @override
  String get shellNavStock => 'Stock';

  @override
  String get shellNavTiers => 'Partners';

  @override
  String get shellNavGestion => 'Management';

  @override
  String get shellFavoris => 'Favourites';

  @override
  String get shellFavorisVide => 'No favourites. Right-click a module to add it.';

  @override
  String get shellFavorisMax => '7 favourites maximum';

  @override
  String get shellFavorisAjouter => 'Add to favourites';

  @override
  String get shellFavorisRetirer => 'Remove from favourites';

  @override
  String get shellMenuModules => 'Modules';

  @override
  String get shellMenuModulesRaccourci => 'Ctrl+M';

  @override
  String get shellMenuModulesRecherche => 'Search a module…';

  @override
  String get shellMenuModulesAucun => 'No matching module.';

  @override
  String get shellAlertes => 'Alerts';

  @override
  String get shellAlertesAucune => 'No alerts';

  @override
  String get shellInternetConnecte => 'Internet: online';

  @override
  String get shellInternetDeconnecte => 'Internet: offline';

  @override
  String get shellFenetreReduire => 'Minimise';

  @override
  String get shellFenetreAgrandir => 'Maximise';

  @override
  String get shellFenetreRestaurer => 'Restore';

  @override
  String get shellFenetreFermer => 'Close';

  @override
  String get shellReduireSidebar => 'Collapse menu';

  @override
  String get shellEtendreSidebar => 'Expand menu';

  @override
  String get shellGalerie => 'Design system gallery';

  @override
  String modulePlaceholder(String nom) {
    return 'Module \"$nom\": available in a later batch.';
  }

  @override
  String get moduleTableauBord => 'Dashboard';

  @override
  String get moduleCaisse => 'Point of sale';

  @override
  String get moduleVentes => 'Sales';

  @override
  String get moduleRetours => 'Returns';

  @override
  String get moduleHistorique => 'History';

  @override
  String get moduleProduits => 'Products';

  @override
  String get moduleStock => 'Stock';

  @override
  String get moduleEntrees => 'Receipts / Purchases';

  @override
  String get moduleTransferts => 'Transfers';

  @override
  String get moduleBesoins => 'Needs';

  @override
  String get moduleSorties => 'Outgoings';

  @override
  String get moduleClients => 'Customers';

  @override
  String get moduleFournisseurs => 'Suppliers';

  @override
  String get moduleVersements => 'Payments';

  @override
  String get moduleGestionCaisse => 'Cash management';

  @override
  String get moduleClotures => 'Closings';

  @override
  String get moduleSituation => 'Reports';

  @override
  String get moduleZakat => 'Zakat';

  @override
  String get moduleParametres => 'Settings';

  @override
  String get moduleMonCompte => 'My account';

  @override
  String get communOk => 'OK';

  @override
  String get communAnnuler => 'Cancel';

  @override
  String get communConfirmer => 'Confirm';

  @override
  String get communFermer => 'Close';

  @override
  String get communEnregistrer => 'Save';

  @override
  String get communSupprimer => 'Delete';

  @override
  String get communRechercher => 'Search';

  @override
  String get communChargement => 'Loading…';

  @override
  String get communAucunResultat => 'No results';

  @override
  String get communSelectionner => 'Select';

  @override
  String get communTotal => 'Total';

  @override
  String get communColonnes => 'Columns';

  @override
  String get communToutSelectionner => 'Select all';

  @override
  String get communLignesParPage => 'Rows per page';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin of $total';
  }

  @override
  String get communPagePrecedente => 'Previous page';

  @override
  String get communPageSuivante => 'Next page';

  @override
  String communSelectionnes(int n) {
    return '$n selected';
  }

  @override
  String get galerieTitre => 'Design system gallery';

  @override
  String get galerieTheme => 'Theme';

  @override
  String get galerieLangue => 'Language';

  @override
  String get galerieClair => 'Light';

  @override
  String get galerieSombre => 'Dark';

  @override
  String get activationTitre => 'Activate CaisseDZ';

  @override
  String get activationIntro => 'Enter the activation key issued for this machine, or try the demo mode.';

  @override
  String get activationIdentifiantMachine => 'This machine\'s identifier';

  @override
  String get activationCopierIdentifiant => 'Copy identifier';

  @override
  String get activationIdentifiantCopie => 'Identifier copied';

  @override
  String get activationCle => 'Activation key (64 characters)';

  @override
  String get activationCleIndice => '64-character hexadecimal SHA-256 key';

  @override
  String get activationBouton => 'Activate';

  @override
  String get activationDemo => 'Try the demo mode';

  @override
  String get activationDemoAide =>
      'Demo mode unlocks every feature (Advanced licence) with the demo / demo account. Data entered is not meant for production.';

  @override
  String get activationErreurFormat => 'The key must contain exactly 64 hexadecimal characters (0-9, a-f).';

  @override
  String get activationErreurInconnue =>
      'This key does not match this machine. Check the key or contact your reseller.';

  @override
  String activationReussie(String niveau) {
    return '$niveau licence activated.';
  }

  @override
  String get licenceBasic => 'Basic';

  @override
  String get licenceAvance => 'Advanced';

  @override
  String get licenceDemo => 'Demo mode';

  @override
  String licenceNiveau(String niveau) {
    return '$niveau licence';
  }

  @override
  String get licenceRequise => 'Feature available with the Advanced licence';

  @override
  String get licenceRequiseDetail =>
      'Your current licence is Basic. Activate an Advanced licence to access this module.';

  @override
  String get licenceGererCle => 'Activate another key';

  @override
  String get connexionTitre => 'Sign in';

  @override
  String get connexionIdentifiant => 'Username';

  @override
  String get connexionMotDePasse => 'Password';

  @override
  String get connexionBouton => 'Sign in';

  @override
  String get connexionErreurIdentifiants => 'Incorrect username or password.';

  @override
  String get connexionErreurInactif => 'This account is disabled.';

  @override
  String get connexionErreurNonConfigure => 'This account has no password yet: complete the initial setup.';

  @override
  String get connexionErreurDemo => 'The demo/demo account is only available in demo mode.';

  @override
  String get connexionDemoIndice => 'Demo mode: username demo, password demo';

  @override
  String get connexionDeconnecter => 'Sign out';

  @override
  String get configTitre => 'Initial setup';

  @override
  String configEtape(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get configEtapeBoutique => 'Shop';

  @override
  String get configEtapeAdmin => 'Administrator';

  @override
  String get configEtapeVente => 'Margin and sales';

  @override
  String get configEtapeRecap => 'Summary';

  @override
  String get configBoutiqueNom => 'Shop name';

  @override
  String get configBoutiqueRc => 'Trade register (RC)';

  @override
  String get configBoutiqueNif => 'Tax ID (NIF)';

  @override
  String get configBoutiqueAdresse => 'Address';

  @override
  String get configBoutiqueTelephone => 'Phone';

  @override
  String get configBoutiqueEmail => 'E-mail';

  @override
  String get configAdminIntro => 'This administrator account will have every right. Choose a username and a password.';

  @override
  String get configAdminNom => 'Display name';

  @override
  String get configAdminMotDePasseConfirmation => 'Confirm password';

  @override
  String get configMarge => 'Default margin (%)';

  @override
  String get configMargeAide => 'Used to compute the selling price from the purchase price of new products.';

  @override
  String get configSeuil => 'Stock alert threshold (global)';

  @override
  String get configFidelite => 'Enable loyalty (points)';

  @override
  String get configPointsParDinar => 'Points earned per dinar';

  @override
  String get configDevise => 'Currency';

  @override
  String get configLangue => 'Application language';

  @override
  String get configRecapIntro => 'Check the information before finishing. You can change it later in Settings.';

  @override
  String get configPrecedent => 'Back';

  @override
  String get configSuivant => 'Next';

  @override
  String get configTerminer => 'Finish';

  @override
  String get configErreurObligatoire => 'Required field';

  @override
  String get configErreurIdentifiant => '3 to 32 characters: letters, digits, dot, dash, underscore.';

  @override
  String get configErreurMotDePasseCourt => 'At least 4 characters.';

  @override
  String get configErreurConfirmation => 'Passwords do not match.';

  @override
  String get configErreurIdentifiantPris => 'This username is already in use.';

  @override
  String get configErreurMarge => 'Value between 0 and 1000.';

  @override
  String get configErreurNombre => 'Invalid number.';

  @override
  String get configReussie => 'Setup complete. Sign in with your administrator account.';

  @override
  String get compteTitre => 'My account';

  @override
  String get compteRole => 'Role';

  @override
  String get compteIdentifiantActuel => 'Current username';

  @override
  String get compteNouvelIdentifiant => 'New username';

  @override
  String get compteMotDePasseActuel => 'Current password';

  @override
  String get compteNouveauMotDePasse => 'New password';

  @override
  String get compteChangerIdentifiant => 'Change username';

  @override
  String get compteChangerMotDePasse => 'Change password';

  @override
  String compteIdentifiantChange(String identifiant) {
    return 'Username changed: sign in from now on with \"$identifiant\".';
  }

  @override
  String get compteMotDePasseChange => 'Password changed.';

  @override
  String get compteErreurMotDePasseActuel => 'Current password is incorrect.';

  @override
  String get comptePreferences => 'Preferences';

  @override
  String get compteDemoLectureSeule => 'The demo account cannot be modified.';

  @override
  String get accesRefuseTitre => 'Access denied';

  @override
  String accesRefuseMessage(String role, String module) {
    return 'Your role \"$role\" cannot access the \"$module\" module. Ask an administrator.';
  }

  @override
  String get accesRefuseRetour => 'Back to dashboard';

  @override
  String get rolesTitre => 'Roles and permissions';

  @override
  String get rolesIntro =>
      'Tick the action permissions and the accessible modules for each role. The administrator always keeps every right.';

  @override
  String get rolesPermissions => 'Action permissions';

  @override
  String get rolesModules => 'Accessible modules';

  @override
  String get rolesEnregistre => 'Roles grid saved.';

  @override
  String get rolesAdminTotal => 'All rights';

  @override
  String get permVoirPrixAchat => 'View purchase price';

  @override
  String get permModifierPrix => 'Change price at checkout';

  @override
  String get permAppliquerRemise => 'Apply a discount';

  @override
  String get permAnnulerVente => 'Cancel a sale';

  @override
  String get permSupprimerDocument => 'Delete a document';

  @override
  String get permExporterDonnees => 'Export data';

  @override
  String get permGererUtilisateurs => 'Manage users';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleCaissier => 'Cashier';

  @override
  String get roleMagasinier => 'Storekeeper';

  @override
  String get parametresRolesCarte => 'Roles and permissions';

  @override
  String get parametresRolesCarteDetail => 'Action permissions and accessible modules per role.';

  @override
  String get parametresLicenceCarte => 'Licence';

  @override
  String get shellBandeauDemo => 'Demo mode — data is not meant for production';

  @override
  String get shellMenuUtilisateur => 'User menu';

  @override
  String get shellVerrouille => 'Advanced licence only';

  @override
  String get shellAccesRestreint => 'Not allowed for your role';

  @override
  String get produitsTitre => 'Products';

  @override
  String get produitsOngletProduits => 'Products';

  @override
  String get produitsOngletCategories => 'Categories';

  @override
  String get produitsOngletColis => 'Cases';

  @override
  String get produitsOngletPacks => 'Bundles';

  @override
  String get produitsOngletRemises => 'Discounts';

  @override
  String get produitsNouveau => 'New product';

  @override
  String get produitsModeIa => 'AI mode';

  @override
  String get produitsImporter => 'Import Excel';

  @override
  String get produitsEtiquettes => 'Labels';

  @override
  String get produitsSynchro => 'Sync catalogue';

  @override
  String get produitsRecherche => 'Search by name, code or barcode…';

  @override
  String get produitsColCode => 'Code';

  @override
  String get produitsColDesignation => 'Name';

  @override
  String get produitsColCodeBarres => 'Barcode';

  @override
  String get produitsColCategorie => 'Category';

  @override
  String get produitsColPrixAchat => 'Purchase price';

  @override
  String get produitsColPrixVente => 'Selling price';

  @override
  String get produitsColMarge => 'Margin %';

  @override
  String get produitsColActif => 'Active';

  @override
  String get produitsColStock => 'Stock';

  @override
  String get produitsAucun => 'No products. Create one or import an Excel file.';

  @override
  String get produitModifier => 'Edit product';

  @override
  String get produitDesactiver => 'Deactivate';

  @override
  String get produitActiver => 'Activate';

  @override
  String get produitGenererCodeBarres => 'Generate an internal barcode';

  @override
  String get produitChampDesignation => 'Name';

  @override
  String get produitChampCodeBarres => 'Barcode (EAN-13 or internal)';

  @override
  String get produitChampCategorie => 'Category';

  @override
  String get produitChampSousCategorie => 'Sub-category';

  @override
  String get produitChampPrixAchat => 'Purchase price';

  @override
  String get produitChampPrixVente => 'Selling price';

  @override
  String get produitChampMarge => 'Margin (%)';

  @override
  String get produitChampUnite => 'Unit';

  @override
  String get produitChampTva => 'VAT (%)';

  @override
  String get produitChampSeuil => 'Alert threshold (empty = global)';

  @override
  String get produitChampSuiviNombre => 'Track a second \"count\" stock (pieces)';

  @override
  String get produitChampSuiviNombreAide => 'The product sells by unit or by piece; stock is kept in both.';

  @override
  String get produitChampNombreParUnite => 'Pieces per unit';

  @override
  String get produitPrixAuto => 'The selling price is computed from the margin if left empty.';

  @override
  String get produitErreurDesignation => 'Name is required.';

  @override
  String get produitErreurCodeBarres => 'Invalid barcode.';

  @override
  String get produitErreurCodeBarresPris => 'This barcode is already used.';

  @override
  String get produitErreurPrix => 'Invalid price.';

  @override
  String get produitErreurQuantite => 'Invalid quantity.';

  @override
  String produitCree(String nom, String code) {
    return 'Product \"$nom\" created ($code).';
  }

  @override
  String get iaTitre => 'New product in AI mode';

  @override
  String get iaIntro =>
      'Scan or type a barcode: the product sheet is looked up in CaisseDZ, then Mantouj, Open Food Facts and Open Beauty Facts.';

  @override
  String get iaRechercher => 'Search';

  @override
  String get iaRechercheEnCours => 'Searching…';

  @override
  String get iaAucun => 'No sheet found for this barcode: switch to detailed entry.';

  @override
  String iaTrouve(String source) {
    return 'Sheet found via $source';
  }

  @override
  String get iaMarque => 'Brand';

  @override
  String get iaCreer => 'Create product';

  @override
  String get iaSaisieDetaillee => 'Detailed entry';

  @override
  String get importTitre => 'Import products from Excel';

  @override
  String get importIntro =>
      'Expected columns on row 1: designation (required), code_barres, categorie, prix_achat, prix_vente.';

  @override
  String get importChoisirFichier => 'Choose an .xlsx file';

  @override
  String get importTelechargerModele => 'Save template';

  @override
  String importLignesValides(int n) {
    return '$n valid row(s)';
  }

  @override
  String importLignesInvalides(int n) {
    return '$n skipped row(s)';
  }

  @override
  String get importColLigne => 'Row';

  @override
  String get importColErreur => 'Error';

  @override
  String get importLancer => 'Import';

  @override
  String importResultat(int importees, int ignorees) {
    return '$importees product(s) imported, $ignorees skipped.';
  }

  @override
  String importErreurFichier(String detail) {
    return 'Unreadable file: $detail';
  }

  @override
  String get importErreurDesignationVide => 'Empty name';

  @override
  String get importErreurCodeBarresPris => 'Barcode already used';

  @override
  String get importErreurPrix => 'Invalid price';

  @override
  String get etiquettesTitre => 'Print labels';

  @override
  String get etiquettesQuantite => 'Quantity';

  @override
  String get etiquettesFormatA4 => 'A4 sheet';

  @override
  String get etiquettesFormatRouleau => 'Roll';

  @override
  String get etiquettesAfficherPrix => 'Show price';

  @override
  String get etiquettesQr => 'QR code instead of barcode';

  @override
  String get etiquettesGenerer => 'Generate PDF';

  @override
  String get etiquettesAucuneSelection => 'Select at least one product in the list.';

  @override
  String synchroResultat(int envoyes, int recus) {
    return 'Sync: $envoyes sent, $recus updated.';
  }

  @override
  String get synchroNonConfiguree => 'Set the CaisseDZ server URL in Settings to sync the catalogue.';

  @override
  String synchroErreur(String detail) {
    return 'Sync failed: $detail';
  }

  @override
  String get categoriesNouvelle => 'New category';

  @override
  String get categoriesNouvelleSous => 'New sub-category';

  @override
  String get categorieNom => 'Name';

  @override
  String get categorieRenommer => 'Rename';

  @override
  String get categorieSupprimer => 'Delete';

  @override
  String get categorieSousCategories => 'Sub-categories';

  @override
  String get categorieErreurSysteme => 'The system category cannot be changed.';

  @override
  String get categorieErreurUtilisee => 'Products are attached to this category.';

  @override
  String categorieConfirmerSuppression(String nom) {
    return 'Delete category \"$nom\" and its sub-categories?';
  }

  @override
  String get colisNouveau => 'New case';

  @override
  String get colisProduit => 'Product';

  @override
  String get colisQuantite => 'Units per case';

  @override
  String get colisAucun => 'No cases.';

  @override
  String get packNouveau => 'New bundle';

  @override
  String get packLignes => 'Contents';

  @override
  String get packAjouterProduit => 'Add a product';

  @override
  String get packAucun => 'No bundles.';

  @override
  String get packErreurLignes => 'Add at least one product to the bundle.';

  @override
  String get remiseNouvelle => 'New discount';

  @override
  String get remiseType => 'Type';

  @override
  String get remiseTypePourcentage => 'Percentage';

  @override
  String get remiseTypeMontant => 'Amount';

  @override
  String get remiseValeur => 'Value';

  @override
  String get remisePortee => 'Scope';

  @override
  String get remisePorteeGlobale => 'All products';

  @override
  String get remisePorteeCategorie => 'A category';

  @override
  String get remisePorteeProduit => 'A product';

  @override
  String get remiseDebut => 'Start';

  @override
  String get remiseFin => 'End';

  @override
  String get remiseAucune => 'No discounts.';

  @override
  String get communNouveau => 'New';

  @override
  String get communModifier => 'Edit';

  @override
  String get communActif => 'Active';

  @override
  String get communInactif => 'Inactive';

  @override
  String get communOui => 'Yes';

  @override
  String get communNon => 'No';

  @override
  String get communValider => 'Confirm';

  @override
  String get communApercu => 'Preview';

  @override
  String get communImprimer => 'Print';

  @override
  String get communAucune => 'None';
}
