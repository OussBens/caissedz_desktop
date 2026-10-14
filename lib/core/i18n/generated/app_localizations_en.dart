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
  String get connexionSaisirCle => 'Enter an activation key';

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

  @override
  String get stockTitre => 'Stock';

  @override
  String get stockOngletNiveaux => 'Levels';

  @override
  String get stockOngletJournal => 'Movements journal';

  @override
  String get stockColProduit => 'Product';

  @override
  String get stockColMagasin => 'Store';

  @override
  String get stockColQuantite => 'Quantity';

  @override
  String get stockColNombre => 'Count (pieces)';

  @override
  String get stockColSeuil => 'Threshold';

  @override
  String get stockColDate => 'Date';

  @override
  String get stockColType => 'Type';

  @override
  String get stockColMotif => 'Reason';

  @override
  String get stockColReference => 'Reference';

  @override
  String get stockColUtilisateur => 'User';

  @override
  String get stockColCommentaire => 'Comment';

  @override
  String get stockColValeur => 'Value (cost)';

  @override
  String get stockTousMagasins => 'All stores';

  @override
  String get stockSousSeuil => 'Below threshold';

  @override
  String get stockEntreeManuelle => 'Manual receipt';

  @override
  String get stockInventaire => 'Stocktake';

  @override
  String get stockQuantiteConstatee => 'Counted quantity';

  @override
  String get stockNombreConstate => 'Counted pieces';

  @override
  String get stockAucunMouvement => 'No movements.';

  @override
  String get stockErreurQuantite => 'Invalid quantity.';

  @override
  String get stockErreurInsuffisant => 'Insufficient stock: the stock guard refuses this outflow.';

  @override
  String get stockErreurMemeMagasin => 'Destination store must differ.';

  @override
  String get stockErreurLignes => 'Add at least one line.';

  @override
  String get stockErreurMotif => 'Invalid reason.';

  @override
  String get stockErreurMagasinInactif => 'Inactive or unknown store.';

  @override
  String get stockErreurMagasinSysteme => 'The main store cannot be deactivated.';

  @override
  String get stockErreurProduit => 'Unknown product.';

  @override
  String get stockErreurStatut => 'Invalid status.';

  @override
  String get typeMouvementEntree => 'Receipt';

  @override
  String get typeMouvementSortie => 'Outflow';

  @override
  String get typeMouvementVente => 'Sale';

  @override
  String get typeMouvementRetour => 'Return';

  @override
  String get typeMouvementTransfert => 'Transfer';

  @override
  String get typeMouvementInventaire => 'Stocktake';

  @override
  String get typeMouvementInitial => 'Opening stock';

  @override
  String get magasinsTitre => 'Stores';

  @override
  String get magasinNouveau => 'New store';

  @override
  String get magasinNom => 'Name';

  @override
  String get magasinAdresse => 'Address';

  @override
  String get magasinPrincipal => 'Main';

  @override
  String get magasinMesMagasins => 'My stores (the first is the main one)';

  @override
  String get magasinAjouterAuxMiens => 'Add to my stores';

  @override
  String get magasinRetirerDesMiens => 'Remove from my stores';

  @override
  String get magasinDefinirPrincipal => 'Set as main';

  @override
  String get transfertsTitre => 'Transfers';

  @override
  String get transfertNouveau => 'New transfer';

  @override
  String get transfertSource => 'Source store';

  @override
  String get transfertDestination => 'Destination store';

  @override
  String get transfertLignes => 'Lines';

  @override
  String get transfertAjouterLigne => 'Add a product';

  @override
  String get transfertAucun => 'No transfers.';

  @override
  String transfertCree(String code) {
    return 'Transfer $code saved: 2 movements per line.';
  }

  @override
  String get besoinsTitre => 'Needs';

  @override
  String get besoinNouveau => 'New need';

  @override
  String get besoinGenerer => 'Generate below threshold';

  @override
  String besoinGeneres(int n) {
    return '$n need(s) generated.';
  }

  @override
  String get besoinStatut => 'Status';

  @override
  String get besoinPasserCommande => 'Mark as Ordered';

  @override
  String get besoinPasserDisponible => 'Mark as Available';

  @override
  String get besoinRemettreAttente => 'Back to Pending';

  @override
  String get besoinAucun => 'No needs.';

  @override
  String get statutBesoinEnAttente => 'Pending';

  @override
  String get statutBesoinCommande => 'Ordered';

  @override
  String get statutBesoinDisponible => 'Available';

  @override
  String get sortiesTitre => 'Outgoings';

  @override
  String get sortiesOngletSorties => 'Outgoings';

  @override
  String get sortiesOngletVentes => 'Sales';

  @override
  String get sortieNouvelle => 'New outflow';

  @override
  String get sortieMotif => 'Reason';

  @override
  String get sortieAucune => 'No outflows.';

  @override
  String get motifCasse => 'Breakage';

  @override
  String get motifPerime => 'Expired';

  @override
  String get motifPerteVol => 'Loss/theft';

  @override
  String get motifConsommationInterne => 'Internal use';

  @override
  String get motifDon => 'Donation';

  @override
  String get motifEchantillon => 'Sample';

  @override
  String communLignes(int n) {
    return '$n line(s)';
  }

  @override
  String get communCommentaire => 'Comment';

  @override
  String get communDate => 'Date';

  @override
  String get communQuantite => 'Quantity';

  @override
  String get moduleMagasins => 'Stores';

  @override
  String get posTitre => 'Point of sale';

  @override
  String get posScan => 'Scan or search a product (F1)';

  @override
  String posPanier(int n) {
    return 'Cart $n';
  }

  @override
  String get posNouveauPanier => 'New cart (Ctrl+N)';

  @override
  String get posMaxPaniers => 'At most 5 parallel sales.';

  @override
  String get posPanierVide => 'Empty cart: scan a barcode or click a product.';

  @override
  String get posSousTotal => 'Subtotal';

  @override
  String get posRemise => 'Discount';

  @override
  String get posTotal => 'Total';

  @override
  String get posVerse => 'Paid';

  @override
  String get posReste => 'Due';

  @override
  String get posMonnaie => 'Change';

  @override
  String get posPointsGagnes => 'Points earned';

  @override
  String get posClient => 'Customer (F2)';

  @override
  String get posClientPassage => 'Walk-in customer';

  @override
  String get posChoisirClient => 'Choose a customer';

  @override
  String get posRemiseGlobale => 'Global discount (F3)';

  @override
  String get posRemisePct => 'Discount (%)';

  @override
  String get posPaiement => 'Payment';

  @override
  String get posMontant => 'Amount';

  @override
  String get posEncaisser => 'Checkout (F12)';

  @override
  String get posVider => 'Clear (F10)';

  @override
  String get posCalculatrice => 'Calculator (F9)';

  @override
  String get posAide => 'Help (F11)';

  @override
  String get posSessionOuvrir => 'Open session';

  @override
  String get posSessionFermer => 'Close session';

  @override
  String get posSessionAucune => 'No open cash session: open one to sell.';

  @override
  String posSessionOuverte(String code, String caisse) {
    return 'Session $code · $caisse';
  }

  @override
  String get posSessionCaisse => 'Register';

  @override
  String get posSessionFond => 'Opening float';

  @override
  String get posSessionMontantCompte => 'Counted amount';

  @override
  String get posSessionAttendu => 'Expected cash';

  @override
  String get posSessionEcart => 'Difference';

  @override
  String posSessionFermee(String code, String ecart) {
    return 'Session $code closed. Difference: $ecart.';
  }

  @override
  String get posErreurSessionDejaOuverte => 'A session is already open (user or register).';

  @override
  String get posErreurSessionAucune => 'No open session.';

  @override
  String get posErreurCaisse => 'Unknown or inactive register.';

  @override
  String get posErreurMontant => 'Invalid amount.';

  @override
  String posErreurStock(String detail) {
    return 'Insufficient stock (reserved by open carts): $detail';
  }

  @override
  String posErreurProduitInconnu(String code) {
    return 'Unknown code: $code';
  }

  @override
  String get posErreurPanierVide => 'The cart is empty.';

  @override
  String posErreurPaiementInsuffisant(String reste) {
    return 'Insufficient payment. Due: $reste';
  }

  @override
  String get posErreurModePaiement => 'Invalid payment method.';

  @override
  String get posErreurPoints => 'Not enough points.';

  @override
  String get posErreurCredit => 'Credit sale not allowed for this customer.';

  @override
  String get posErreurQuantite => 'Invalid quantity.';

  @override
  String get posErreurPeriodeCloturee => 'Refused: closed period.';

  @override
  String posVenteEnregistree(String code, String monnaie) {
    return 'Sale $code completed. Change: $monnaie';
  }

  @override
  String get posImprimerTicket => 'Print receipt';

  @override
  String get posImprimerFacture => 'A4 invoice';

  @override
  String get posTicket58 => '58 mm receipt';

  @override
  String get posTicket80 => '80 mm receipt';

  @override
  String get posApercuTicket => 'Receipt preview';

  @override
  String get posImpressionOk => 'Receipt sent to the printer.';

  @override
  String posImpressionErreur(String detail) {
    return 'Printing failed: $detail';
  }

  @override
  String get posCreditAutoriser => 'Sell on credit (amount due)';

  @override
  String get posRaccourcisTitre => 'Keyboard shortcuts';

  @override
  String get posRaccourciF1 => 'Search / scan';

  @override
  String get posRaccourciF2 => 'Choose customer';

  @override
  String get posRaccourciF3 => 'Global discount';

  @override
  String get posRaccourciF4 => 'Cash: exact amount';

  @override
  String get posRaccourciF5 => 'Card: exact amount';

  @override
  String get posRaccourciF6 => 'Cheque: exact amount';

  @override
  String get posRaccourciF7 => 'Transfer: exact amount';

  @override
  String get posRaccourciF8 => 'Loyalty points';

  @override
  String get posRaccourciF9 => 'Calculator';

  @override
  String get posRaccourciF10 => 'Clear cart';

  @override
  String get posRaccourciF11 => 'This help';

  @override
  String get posRaccourciF12 => 'Checkout';

  @override
  String get posRaccourciCtrlN => 'New cart';

  @override
  String get posRaccourciCtrlTab => 'Next cart';

  @override
  String get posRaccourciSuppr => 'Remove selected line';

  @override
  String get posRaccourciPlusMoins => 'Quantity +1 / −1 on the selected line';

  @override
  String get posLigneQuantite => 'Qty';

  @override
  String get posLignePrix => 'Unit';

  @override
  String get posLigneRemise => 'Disc.';

  @override
  String get posLigneTotal => 'Total';

  @override
  String get posVendreNombre => 'Sell by piece';

  @override
  String get posColis => 'Case';

  @override
  String get posPack => 'Bundle';

  @override
  String get posCategoriesToutes => 'All';

  @override
  String get posAucunProduit => 'No active product.';

  @override
  String get calcTitre => 'Calculator';

  @override
  String get calcUtiliser => 'Use as amount';

  @override
  String get modePaiementEspeces => 'Cash';

  @override
  String get modePaiementCarte => 'Card';

  @override
  String get modePaiementCheque => 'Cheque';

  @override
  String get modePaiementVirement => 'Transfer';

  @override
  String get modePaiementPoints => 'Points';

  @override
  String get ventesTitre => 'Sales';

  @override
  String get ventesColTicket => 'Receipt';

  @override
  String get ventesColClient => 'Customer';

  @override
  String get ventesColNet => 'Net';

  @override
  String get ventesColVerse => 'Paid';

  @override
  String get ventesColReste => 'Due';

  @override
  String get ventesColStatut => 'Status';

  @override
  String get ventesColCaisse => 'Register';

  @override
  String get ventesColVendeur => 'Seller';

  @override
  String get ventesAucune => 'No sales.';

  @override
  String get ventesVoirTicket => 'View receipt';

  @override
  String get ventesAnnuler => 'Cancel sale';

  @override
  String ventesConfirmerAnnulation(String code) {
    return 'Cancel sale $code? Stock and points are restored; the sealed receipt is kept.';
  }

  @override
  String get ventesCreerRetour => 'Create a return';

  @override
  String get ventesVerifierChaine => 'Verify sealing';

  @override
  String get ventesChaineOk => 'Receipt chain intact.';

  @override
  String ventesChaineKo(String code) {
    return 'Chain altered from receipt $code.';
  }

  @override
  String get ventesFiltreToutes => 'All';

  @override
  String get ventesFiltreValidees => 'Completed';

  @override
  String get ventesFiltreAnnulees => 'Cancelled';

  @override
  String get ventesFiltreCredit => 'On credit';

  @override
  String get statutVenteValidee => 'Completed';

  @override
  String get statutVenteAnnulee => 'Cancelled';

  @override
  String ticketDetail(String code) {
    return 'Receipt $code';
  }

  @override
  String get retoursTitre => 'Returns';

  @override
  String get retourNouveau => 'New return';

  @override
  String get retourVente => 'Original sale';

  @override
  String get retourMotif => 'Reason';

  @override
  String get retourRembourser => 'Refunded amount';

  @override
  String get retourModeRemboursement => 'Refund method';

  @override
  String get retourAvoir => 'The rest is credited to the customer account.';

  @override
  String get retourAucun => 'No returns.';

  @override
  String get retourColTotal => 'Returned total';

  @override
  String get retourColRembourse => 'Refunded';

  @override
  String retourQuantiteMax(String max) {
    return 'Returned quantity (max $max)';
  }

  @override
  String get retourErreurVenteInconnue => 'Sale not found.';

  @override
  String get retourErreurVenteAnnulee => 'This sale is cancelled.';

  @override
  String get retourErreurLignes => 'Enter at least one quantity to return.';

  @override
  String get retourErreurQuantite => 'Invalid quantity.';

  @override
  String get retourErreurDepasse => 'Quantity exceeds the sold quantity (including previous returns).';

  @override
  String get retourErreurPeriode => 'Closed period: return not possible.';

  @override
  String retourCree(String code, String total, String rembourse) {
    return 'Return $code saved: $total (refunded $rembourse).';
  }

  @override
  String get clientsTitre => 'Customers';

  @override
  String get clientNouveau => 'New customer';

  @override
  String get clientNom => 'Name';

  @override
  String get clientTelephone => 'Phone';

  @override
  String get clientAdresse => 'Address';

  @override
  String get clientEmail => 'E-mail';

  @override
  String get clientPoints => 'Points';

  @override
  String get clientPlafond => 'Credit limit';

  @override
  String get clientSolde => 'Balance due';

  @override
  String get clientAucun => 'No customers.';

  @override
  String get clientFiche => 'Customer card';

  @override
  String get clientDocumentsOuverts => 'Open documents';

  @override
  String get clientVersements => 'Payments';

  @override
  String get clientNouveauVersement => 'Receive a payment';

  @override
  String get fournisseursTitre => 'Suppliers';

  @override
  String get fournisseurNouveau => 'New supplier';

  @override
  String get fournisseurAucun => 'No suppliers.';

  @override
  String get fournisseurFiche => 'Supplier card';

  @override
  String get fournisseurNouveauVersement => 'Pay a supplier';

  @override
  String get versementsTitre => 'Payments';

  @override
  String get versementNouveau => 'New payment';

  @override
  String get versementTiers => 'Party';

  @override
  String get versementTiersClient => 'Customer';

  @override
  String get versementTiersFournisseur => 'Supplier';

  @override
  String get versementMontant => 'Amount';

  @override
  String get versementMode => 'Method';

  @override
  String get versementReference => 'Reference';

  @override
  String get versementAucun => 'No payments.';

  @override
  String get versementColSens => 'Direction';

  @override
  String get versementColImpute => 'Allocated';

  @override
  String get versementColNonImpute => 'Unallocated';

  @override
  String versementVerrouille(String retour) {
    return 'Locked (linked to return $retour)';
  }

  @override
  String get versementImputations => 'Allocations (oldest first)';

  @override
  String get versementSupprimer => 'Delete payment';

  @override
  String versementConfirmerSuppression(String code) {
    return 'Delete payment $code? Allocations will be reverted.';
  }

  @override
  String get versementErreurMontant => 'Invalid amount.';

  @override
  String get versementErreurMode => 'Invalid payment method.';

  @override
  String get versementErreurSysteme => 'Not possible for the system party.';

  @override
  String get versementErreurVerrouille => 'Locked payment: linked to a return, it can neither be edited nor deleted.';

  @override
  String get versementErreurInconnu => 'Payment not found.';

  @override
  String get versementErreurTiers => 'Invalid party.';

  @override
  String versementEnregistre(String code, String impute, String reste) {
    return 'Payment $code saved: $impute allocated, $reste as advance.';
  }

  @override
  String get sensEncaissement => 'Receipt';

  @override
  String get sensDecaissement => 'Disbursement';

  @override
  String get tiersErreurNom => 'Name is required.';

  @override
  String get tiersErreurSysteme => 'The system party cannot be changed.';

  @override
  String get achatsTitre => 'Receipts / Purchases';

  @override
  String get achatNouveau => 'New receipt';

  @override
  String get achatSmartScan => 'Smart Scan AI';

  @override
  String get achatFournisseur => 'Supplier';

  @override
  String get achatReference => 'Invoice reference';

  @override
  String get achatMagasin => 'Store';

  @override
  String get achatLignes => 'Lines';

  @override
  String get achatPrixAchat => 'Purchase price';

  @override
  String get achatNouveauPrixVente => 'New selling price';

  @override
  String get achatVerse => 'Paid';

  @override
  String get achatModePaiement => 'Payment method';

  @override
  String get achatMettreAJourPrix => 'Update product purchase prices';

  @override
  String get achatAucun => 'No receipts.';

  @override
  String get achatColTotal => 'Total';

  @override
  String get achatColVerse => 'Paid';

  @override
  String get achatColReste => 'Due';

  @override
  String get achatColSource => 'Source';

  @override
  String get achatColStatut => 'Status';

  @override
  String get achatAnnuler => 'Cancel receipt';

  @override
  String achatConfirmerAnnulation(String code) {
    return 'Cancel receipt $code? Stock will be taken out.';
  }

  @override
  String achatEnregistre(String code, String total, String reste) {
    return 'Receipt $code saved: $total, due $reste.';
  }

  @override
  String get achatErreurLignes => 'Add at least one line.';

  @override
  String get achatErreurQuantite => 'Invalid quantity.';

  @override
  String get achatErreurPrix => 'Invalid price or amount.';

  @override
  String get achatErreurProduit => 'Unknown product.';

  @override
  String get achatErreurFournisseur => 'Unknown supplier.';

  @override
  String get achatErreurInconnu => 'Receipt not found.';

  @override
  String get achatErreurAnnule => 'Receipt already cancelled.';

  @override
  String get achatErreurPeriode => 'Closed period: cannot cancel.';

  @override
  String get achatErreurStock => 'Insufficient stock to cancel (already sold).';

  @override
  String get statutAchatValide => 'Validated';

  @override
  String get statutAchatAnnule => 'Cancelled';

  @override
  String get sourceManuel => 'Manual';

  @override
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanTitre => 'Smart Scan AI — supplier invoice';

  @override
  String get smartScanIntro =>
      'Photograph or pick the invoice (image or PDF): lines are recognised by the CaisseDZ server and matched with your catalogue.';

  @override
  String smartScanQuota(int restant, int total) {
    return 'Quota: $restant analysis(es) left out of $total';
  }

  @override
  String get smartScanChoisir => 'Choose an invoice';

  @override
  String get smartScanAnalyser => 'Analyse';

  @override
  String get smartScanAnalyse => 'Analysing…';

  @override
  String get smartScanAucuneLigne => 'No line recognised.';

  @override
  String get smartScanLigneNonRapprochee => 'Unmatched';

  @override
  String get smartScanRapprocher => 'Link a product';

  @override
  String get smartScanCreerEntree => 'Create receipt';

  @override
  String get smartScanQuotaAtteint => 'Smart Scan quota reached';

  @override
  String get smartScanQuotaAtteintDetail => 'You have used all your analyses. Request an offer to continue.';

  @override
  String get smartScanDemandeOffre => 'Request an offer';

  @override
  String get smartScanEmail => 'Your e-mail';

  @override
  String get smartScanMessage => 'Message';

  @override
  String get smartScanOffreEnvoyee => 'Request sent, we will contact you shortly.';

  @override
  String get smartScanNonConfigure => 'Set the CaisseDZ server URL in Settings to use Smart Scan.';

  @override
  String smartScanErreurReseau(String detail) {
    return 'Server unreachable: $detail';
  }

  @override
  String smartScanErreurServeur(String detail) {
    return 'Server error: $detail';
  }

  @override
  String get smartScanErreurFichier => 'Invalid file.';

  @override
  String get gestionCaisseTitre => 'Cash management';

  @override
  String get gestionCaisseOngletCaisses => 'Registers';

  @override
  String get gestionCaisseOngletMouvements => 'Movements';

  @override
  String get gestionCaisseOngletTransferts => 'Register transfers';

  @override
  String get caisseNouvelle => 'New register';

  @override
  String get caisseModifier => 'Edit register';

  @override
  String get caisseNom => 'Name';

  @override
  String get caisseType => 'Type';

  @override
  String get caisseMagasin => 'Store';

  @override
  String get caisseSansMagasin => 'No store';

  @override
  String get caisseActive => 'Active';

  @override
  String get caisseInactive => 'Inactive';

  @override
  String get caisseSoldeEspeces => 'Cash balance';

  @override
  String get caisseSoldeTotal => 'Total balance';

  @override
  String get caisseTypePhysique => 'Physical';

  @override
  String get caisseTypeCompte => 'Account';

  @override
  String get caisseAucune => 'No register.';

  @override
  String get caisseDesactiver => 'Deactivate';

  @override
  String get caisseActiver => 'Activate';

  @override
  String get mouvementApport => 'Cash in';

  @override
  String get mouvementDepense => 'Expense';

  @override
  String get mouvementColType => 'Type';

  @override
  String get mouvementColSens => 'Direction';

  @override
  String get mouvementColMontant => 'Amount';

  @override
  String get mouvementColMode => 'Method';

  @override
  String get mouvementColReference => 'Reference';

  @override
  String get mouvementAucun => 'No movement.';

  @override
  String get mouvementToutesCaisses => 'All registers';

  @override
  String get mouvementCaisse => 'Register';

  @override
  String get mvtVente => 'Sale';

  @override
  String get mvtAnnulation => 'Cancellation';

  @override
  String get mvtRemboursement => 'Refund';

  @override
  String get mvtEncaissement => 'Receipt';

  @override
  String get mvtDecaissement => 'Payment';

  @override
  String get mvtApport => 'Cash in';

  @override
  String get mvtDepense => 'Expense';

  @override
  String get mvtTransfert => 'Transfer';

  @override
  String get mvtFondInitial => 'Opening float';

  @override
  String get mvtRetrait => 'Withdrawal';

  @override
  String get mvtEcart => 'Variance';

  @override
  String get sensEntree => 'In';

  @override
  String get sensSortie => 'Out';

  @override
  String get transfertCaisseNouveau => 'New transfer';

  @override
  String get transfertCaisseSource => 'Source register';

  @override
  String get transfertCaisseDestination => 'Destination register';

  @override
  String get transfertCaisseAucun => 'No transfer.';

  @override
  String transfertCaisseCree(String code) {
    return 'Transfer $code recorded (2 movements).';
  }

  @override
  String get caisseErreurNom => 'Name is required.';

  @override
  String get caisseErreurType => 'Invalid register type.';

  @override
  String get caisseErreurMagasin => 'Unknown store.';

  @override
  String get caisseErreurInconnue => 'Register not found.';

  @override
  String get caisseErreurInactive => 'Inactive register.';

  @override
  String get caisseErreurSysteme => 'The main register cannot be deactivated.';

  @override
  String get caisseErreurMontant => 'Invalid amount.';

  @override
  String get caisseErreurMode => 'Invalid payment method.';

  @override
  String get caisseErreurMemeCaisse => 'Choose two different registers.';

  @override
  String get caisseErreurSolde => 'Insufficient balance in the source register.';

  @override
  String get caisseErreurSessionOuverte => 'A session is open on this register.';

  @override
  String get cloturesTitre => 'Z closures';

  @override
  String get clotureNouvelle => 'Close (Z)';

  @override
  String get clotureApercuTitre => 'Z closure — period preview';

  @override
  String get cloturePeriode => 'Period';

  @override
  String get clotureDebut => 'Start';

  @override
  String get clotureFin => 'End';

  @override
  String get clotureColVentes => 'Sales';

  @override
  String get clotureColAnnulations => 'Cancellations';

  @override
  String get clotureColTotalVentes => 'Sales total';

  @override
  String get clotureColRemises => 'Discounts';

  @override
  String get clotureColRetours => 'Returns';

  @override
  String get clotureColEncaissements => 'Receipts';

  @override
  String get clotureColDecaissements => 'Payments';

  @override
  String get clotureColHash => 'Seal';

  @override
  String get clotureColUtilisateur => 'User';

  @override
  String get clotureAucune => 'No closure.';

  @override
  String get clotureConfirmer => 'Seal the closure';

  @override
  String clotureCreee(String code, String hash) {
    return 'Closure $code sealed. Hash: $hash';
  }

  @override
  String get clotureDetail => 'Closure details';

  @override
  String get clotureParMode => 'Receipts by method';

  @override
  String get clotureSoldes => 'Register balances';

  @override
  String get clotureDerniereVente => 'Last receipt';

  @override
  String get clotureHashPrecedent => 'Previous hash';

  @override
  String get clotureHash => 'Hash';

  @override
  String get clotureVerifier => 'Verify chain';

  @override
  String get clotureChaineOk => 'Closure chain intact.';

  @override
  String clotureChaineKo(String code) {
    return 'Chain altered from closure $code.';
  }

  @override
  String get clotureErreurSession => 'Close all register sessions before closing.';

  @override
  String get clotureErreurRien => 'Nothing to close since the last closure.';

  @override
  String get clotureAvertissementImmuable =>
      'A closure is final: it can neither be modified nor deleted, and documents of the period can no longer be cancelled.';

  @override
  String get exportFiscalTitre => 'Fiscal export';

  @override
  String get exportFiscalDebut => 'From (dd/mm/yyyy)';

  @override
  String get exportFiscalFin => 'To (dd/mm/yyyy)';

  @override
  String get exportFiscalGenerer => 'Generate archive';

  @override
  String exportFiscalOk(String chemin, int ventes, int clotures) {
    return 'Archive saved: $chemin ($ventes sales, $clotures closures, fingerprint verified).';
  }

  @override
  String get exportFiscalErreurDates => 'Invalid dates.';

  @override
  String get exportFiscalVerifier => 'Verify an archive';

  @override
  String exportFiscalVerifOk(int ventes, int clotures) {
    return 'Valid archive: $ventes sales, $clotures closures.';
  }

  @override
  String exportFiscalVerifKo(String erreurs) {
    return 'Invalid archive: $erreurs';
  }

  @override
  String get exportFiscalPermission => 'Permission “export data” required.';

  @override
  String get tableauBordTitre => 'Dashboard';

  @override
  String get tableauBordCaJour => 'Today\'s revenue';

  @override
  String get tableauBordTicketsJour => 'Today\'s receipts';

  @override
  String get tableauBordPanierMoyen => 'Average basket';

  @override
  String get tableauBordCaMois => 'Month revenue';

  @override
  String get tableauBordSousSeuil => 'Products below threshold';

  @override
  String get tableauBordCreances => 'Customer receivables';

  @override
  String get tableauBordCa30Jours => 'Revenue over the last 30 days';

  @override
  String get tableauBordPaiements => 'Receipts by method (30 days)';

  @override
  String get tableauBordTopProduits => 'Top 5 products (30 days)';

  @override
  String get tableauBordCategories => 'Sales by category (30 days)';

  @override
  String get tableauBordCaMensuel => 'Monthly revenue (12 months)';

  @override
  String get tableauBordActualiser => 'Refresh';

  @override
  String get situationTitre => 'Reports';

  @override
  String get situationRapport => 'Report';

  @override
  String get situationDu => 'From (dd/mm/yyyy)';

  @override
  String get situationAu => 'To (dd/mm/yyyy)';

  @override
  String get situationAfficher => 'Show';

  @override
  String get situationExportExcel => 'Export to Excel';

  @override
  String get situationApercuPdf => 'PDF preview';

  @override
  String get situationAucuneLigne => 'No data for the period.';

  @override
  String get situationDatesInvalides => 'Invalid dates.';

  @override
  String situationExportOk(String chemin) {
    return 'File saved: $chemin';
  }

  @override
  String situationPeriode(String debut, String fin) {
    return 'Period from $debut to $fin';
  }

  @override
  String get rapportVentesJour => 'Sales by day';

  @override
  String get rapportVentesProduit => 'Sales by product';

  @override
  String get rapportVentesCategorie => 'Sales by category';

  @override
  String get rapportVentesClient => 'Sales by customer';

  @override
  String get rapportVentesVendeur => 'Sales by seller and register';

  @override
  String get rapportEncaissementsMode => 'Receipts by method';

  @override
  String get rapportAchatsFournisseur => 'Purchases by supplier';

  @override
  String get rapportRetours => 'Customer returns';

  @override
  String get rapportEtatStock => 'Valued stock status';

  @override
  String get rapportCreancesDettes => 'Receivables and payables';

  @override
  String get zakatTitre => 'Zakat';

  @override
  String get zakatIntro => 'Zakat on trade goods: 2.5% of the base when it reaches the nisab (85 g of gold).';

  @override
  String zakatPrixOr(String devise) {
    return 'Gold price per gram ($devise)';
  }

  @override
  String get zakatEnregistrerPrix => 'Save price';

  @override
  String get zakatStock => 'Stock (purchase price)';

  @override
  String get zakatCaisses => 'Registers';

  @override
  String get zakatCreances => 'Customer receivables';

  @override
  String get zakatDettes => 'Supplier payables';

  @override
  String get zakatAssiette => 'Base';

  @override
  String get zakatNissab => 'Nisab (85 g)';

  @override
  String get zakatMontant => 'Zakat due (2.5%)';

  @override
  String get zakatAssujetti => 'Due: the base reaches the nisab.';

  @override
  String get zakatNonAssujetti => 'Not due: the base is below the nisab.';

  @override
  String get zakatPrixManquant => 'Enter the gold price to compute the nisab.';

  @override
  String get historiqueTitre => 'History';

  @override
  String get historiqueColUtilisateur => 'User';

  @override
  String get historiqueColAction => 'Action';

  @override
  String get historiqueColEntite => 'Entity';

  @override
  String get historiqueColDetail => 'Details';

  @override
  String get historiqueToutesEntites => 'All entities';

  @override
  String get historiqueAucun => 'No operation.';

  @override
  String get parametresTitre => 'Settings';

  @override
  String get parametresOngletGeneral => 'General';

  @override
  String get parametresOngletBoutique => 'Shop';

  @override
  String get parametresOngletVente => 'Sales';

  @override
  String get parametresOngletImpression => 'Printing';

  @override
  String get parametresOngletServeur => 'Servers';

  @override
  String get parametresOngletSauvegarde => 'Backup';

  @override
  String get parametresEnregistre => 'Settings saved.';

  @override
  String get parametresBoutiqueNom => 'Shop name';

  @override
  String get parametresBoutiqueRc => 'Trade register (RC)';

  @override
  String get parametresBoutiqueNif => 'Tax ID (NIF)';

  @override
  String get parametresBoutiqueAdresse => 'Address';

  @override
  String get parametresBoutiqueTelephone => 'Phone';

  @override
  String get parametresBoutiqueEmail => 'E-mail';

  @override
  String get parametresMarge => 'Default margin (%)';

  @override
  String get parametresDevise => 'Currency';

  @override
  String get parametresSeuil => 'Global stock threshold';

  @override
  String get parametresFidelite => 'Loyalty program';

  @override
  String get parametresPoints => 'Points per dinar';

  @override
  String get parametresGardeStock => 'Stock guard: always on (no sale without stock).';

  @override
  String get parametresImprimanteType => 'Printer type';

  @override
  String get parametresImprimanteAdresse => 'Windows queue or IP:port address';

  @override
  String get parametresImprimanteLargeur => 'Receipt width';

  @override
  String get parametresImprimanteNormale => 'Standard (print dialog)';

  @override
  String get parametresImprimanteUsb => 'USB (Windows spooler)';

  @override
  String get parametresImprimanteReseau => 'Network (IP:port)';

  @override
  String get parametresImprimanteBluetooth => 'Bluetooth';

  @override
  String get parametresServeurUrl => 'CaisseDZ server URL';

  @override
  String get parametresServeurCle => 'API key';

  @override
  String get parametresMantoujUrl => 'Mantouj catalog URL';

  @override
  String get parametresErreurNom => 'Shop name is required.';

  @override
  String get parametresErreurValeur => 'Invalid value.';

  @override
  String get parametresErreurImprimanteType => 'Invalid printer type.';

  @override
  String get parametresErreurImprimanteAdresse => 'Enter the printer queue or address.';

  @override
  String get sauvegardeIntro => 'The backup is encrypted with the chosen password: keep it, it is required to restore.';

  @override
  String get sauvegardeCreer => 'Create a backup';

  @override
  String get sauvegardeRestaurer => 'Restore a backup';

  @override
  String get sauvegardeMotDePasse => 'Backup password';

  @override
  String get sauvegardeFichier => 'Backup file';

  @override
  String get sauvegardeChoisirFichier => 'Choose file…';

  @override
  String sauvegardeOk(String chemin) {
    return 'Backup saved: $chemin';
  }

  @override
  String sauvegardeInfo(String boutique, int ventes, int produits, int version) {
    return 'Shop “$boutique”, $ventes sales, $produits products, schema v$version.';
  }

  @override
  String get sauvegardeConfirmerRestauration => 'Restore this backup? Current data will be replaced at next start.';

  @override
  String get sauvegardeRestaurationPreparee => 'Restore ready: close and relaunch CaisseDZ to apply it.';

  @override
  String get sauvegardeRestaurationEnAttente => 'A restore is pending: it will be applied at next start.';

  @override
  String get sauvegardeAnnulerRestauration => 'Cancel restore';

  @override
  String get sauvegardeErreurMotDePasse => 'Invalid password or corrupted file.';

  @override
  String get sauvegardeErreurMotDePasseVide => 'Enter a password.';

  @override
  String get sauvegardeErreurFichier => 'File not found.';

  @override
  String sauvegardeErreurChemin(String detail) {
    return 'Invalid location: $detail';
  }

  @override
  String get dsContinuer => 'Continue';

  @override
  String get dsCompris => 'Got it';

  @override
  String get dsLibelle => 'Label';

  @override
  String get dsCochezLignes => 'Tick one or more rows';

  @override
  String get dsCliquezLigne => 'Click a row · double-click to confirm';

  @override
  String get dsAjouter => 'Add';

  @override
  String get dsChoisir => 'Choose';

  @override
  String get dsAnnules => 'cancelled';

  @override
  String get dsSupprimes => 'deleted';

  @override
  String get dsActiver => 'Activate';

  @override
  String get dsActives => 'activated';

  @override
  String get dsDesactiver => 'Deactivate';

  @override
  String get dsDesactives => 'deactivated';

  @override
  String dsLotPartiel(String ok, int total, String participe) {
    return '$ok of $total will be $participe.';
  }

  @override
  String get dsLotVerifier => 'Check the selection before confirming.';

  @override
  String dsLotBloques(String n, String motif) {
    return '$n cannot be processed: $motif.';
  }

  @override
  String get dsMotifAnnulation => 'Cancellation reason';

  @override
  String get dsMotifIndice => 'E.g. input error, customer absent…';

  @override
  String get dsObligatoires => 'Required';

  @override
  String get dsToujoursAffichees => 'Always shown';

  @override
  String get dsColonnesParDefaut => 'Default columns';

  @override
  String get dsAutresColonnes => 'Other columns';

  @override
  String get dsColonnesTitre => 'Show / hide columns';

  @override
  String dsColonnesVisibles(int n, int total) {
    return '$n of $total columns visible';
  }

  @override
  String get dsAppliquer => 'Apply';

  @override
  String get dsRechercherColonne => 'Search a column…';

  @override
  String get dsAfficherTout => 'Show all';

  @override
  String get dsMasquerTout => 'Hide all';

  @override
  String get dsParDefaut => 'Default';

  @override
  String get dsAucuneColonne => 'No column found';

  @override
  String get dsGarderSelection => 'Keep my selection';

  @override
  String get dsGarderSelectionAide => 'Otherwise the default columns are restored next time';

  @override
  String get dsParPage => 'per page';

  @override
  String get dsToutDeselectionner => 'Clear selection';

  @override
  String dsSelectionneSur(int n, int total) {
    return '$n / $total selected';
  }

  @override
  String get dsSelectionnezUne => 'Select a single row';

  @override
  String get dsSelectionnezAuMoins => 'Select at least one row';

  @override
  String get dsAucunElement => 'No items';

  @override
  String get dsDoubleClicDetail => 'Double-click: show details';

  @override
  String dsColonnesMasquees(int n, int total) {
    return 'Show / hide columns · $n/$total';
  }

  @override
  String get dsFiltres => 'Filters';

  @override
  String get dsFiltrer => 'Filter';

  @override
  String get dsReinitialiser => 'Reset';

  @override
  String dsActifs(int n) {
    return '$n active';
  }

  @override
  String get dsExporter => 'Export';

  @override
  String get dsToutExporter => 'Export all';

  @override
  String get dsSelectionSeulement => 'Selection only';

  @override
  String get dsRetour => 'Back';

  @override
  String get dsEffacer => 'Clear';

  @override
  String get dsThemeClair => 'Light theme';

  @override
  String get dsThemeSombre => 'Dark theme';

  @override
  String get dsEnLigne => 'Online';

  @override
  String get dsHorsLigne => 'Offline';

  @override
  String get dsSynchronise => 'Synced';

  @override
  String get dsHorsLigneLocal => 'Offline — data stays local';

  @override
  String get dsAlertes => 'Alerts';

  @override
  String get dsMenuModules => 'Modules menu (Ctrl M)';

  @override
  String get dsReplier => 'Collapse';

  @override
  String get dsDeplier => 'Expand';

  @override
  String get dsFavori => 'Favourite';

  @override
  String get dsAjouterFavoris => 'Add to favourites';

  @override
  String get dsRetirerFavoris => 'Remove from favourites';

  @override
  String get dsFavorisComplets => 'Favourites full';

  @override
  String get dsAucunModule => 'No module';

  @override
  String get dsModules => 'Modules';

  @override
  String get dsRechercherModule => 'Search a module…';

  @override
  String get dsMagasin => 'Store';

  @override
  String get dsPagePrecedente => 'Previous page';

  @override
  String get dsPageSuivante => 'Next page';

  @override
  String get dsChoisirListe => 'Choose from the list';

  @override
  String get dsRechercher => 'Search';

  @override
  String get dsSelectionner => 'Select';

  @override
  String get dsAucunResultat => 'No results';

  @override
  String get dsGateLicenceTitre => 'Available with the Advanced tier';

  @override
  String get dsGateLicenceAction => 'Upgrade to Advanced';

  @override
  String get dsGateRoleTitre => 'Access not allowed';

  @override
  String get dsGateRoleAction => 'Request access';

  @override
  String get dsGateRefuseTitre => 'Access denied';

  @override
  String get dsGateRefuseAction => 'Back to dashboard';

  @override
  String get dsGateActivationTitre => 'Application not activated';

  @override
  String get dsGateActivationAction => 'Activate';

  @override
  String dsGateRefuseDetail(String module) {
    return 'Your role does not grant access to the $module module. Ask the administrator to change your permissions.';
  }

  @override
  String get dsPermTout => 'Select all';

  @override
  String get dsPermRien => 'Deselect all';

  @override
  String get dsPermReserve => 'Administrator only';

  @override
  String get dsPosProduit => 'Product';

  @override
  String get dsPosColis => 'Pack';

  @override
  String get dsPosQte => 'Qty';

  @override
  String get dsPosPieces => 'Pieces';

  @override
  String get dsPosMontant => 'Amount';

  @override
  String get dsPosMoins => 'Less';

  @override
  String get dsPosPlus => 'More';

  @override
  String get dsPosRetirer => 'Remove';

  @override
  String get dsPosChangerColis => 'Change pack';

  @override
  String get dsPosOuverte => 'Open';

  @override
  String get dsPosFermee => 'Closed';

  @override
  String get dsPosAucuneSession => 'No open session';

  @override
  String dsPosOuverteA(String heure) {
    return 'Opened at $heure';
  }

  @override
  String dsPosPar(String nom) {
    return 'by $nom';
  }

  @override
  String get dsPosSoldeCourant => 'Current balance';

  @override
  String get dsPosMouvement => 'Movement';

  @override
  String get dsPosCloturer => 'Close';

  @override
  String get dsPosOuvrir => 'Open';

  @override
  String get dsPosOuvrirCaisse => 'Open the register';

  @override
  String get dsPosEffacer => 'Delete';

  @override
  String get dsPosToutEffacer => 'Clear all';

  @override
  String get dsPosTotalAvantRemise => 'Total before discount';

  @override
  String get dsPosRemise => 'Discount';

  @override
  String get dsPosTotalAPayer => 'Total due';

  @override
  String get dsPosPaiementComplet => 'Full payment';

  @override
  String get dsPosMontantPaye => 'Amount paid';

  @override
  String get dsPosARendre => 'Change due';

  @override
  String get dsPosMontantExact => 'Exact amount';

  @override
  String get dsPosPartielImpossible => 'Partial payment not allowed for the walk-in customer';

  @override
  String get dsPosResteCredit => 'Remaining (customer credit)';

  @override
  String get dsPosRupture => 'Out of stock';

  @override
  String dsPosEnStock(String n) {
    return '$n in stock';
  }

  @override
  String get dsPosEntree => 'Entry';

  @override
  String get dsPosEntreeRapide => 'New quick entry for this product';

  @override
  String get dsPosSmartScan => 'Smart Scan';

  @override
  String dsPosScansMois(int n) {
    return '/ $n scans this month';
  }

  @override
  String dsPosRestants(int n) {
    return '$n left';
  }

  @override
  String dsPosRenouvellement(String date) {
    return 'Renews $date';
  }

  @override
  String get dsPosQuotaHorsLigne => 'Offline — quota unavailable, the register keeps working.';

  @override
  String get dsPosActualiser => 'Refresh';

  @override
  String get dsPosNouvelleVente => 'New sale';

  @override
  String get dsPosVentes => 'sales';

  @override
  String get dsPosFermerVente => 'Close this sale';

  @override
  String dsPosMaxVentes(int n) {
    return 'Maximum $n parallel sales';
  }

  @override
  String dsPosArticles(int n) {
    return '$n item(s)';
  }

  @override
  String get dsPosSousTotal => 'Subtotal';

  @override
  String get dsPosLigneArticles => 'Items';

  @override
  String get dsPosLigneQuantite => 'Quantity';

  @override
  String get dsPosLigneAjouter => 'Add products';

  @override
  String get dsPosLigneVide => 'No product — add some with the button below.';

  @override
  String get dsPosLigneRetirer => 'Remove line';

  @override
  String get dsPosCode => 'Code';

  @override
  String get dsPosPrix => 'Price';

  @override
  String get dsCalcUtiliser => 'Use the result';

  @override
  String get dsBarcodeAucun => 'This product has no barcode.';

  @override
  String get dsBarcodeGenerer => 'Generate';

  @override
  String get dsBarcodeFormatLibre => 'Free format (not EAN-13)';

  @override
  String get dsBarcodeCopier => 'Copy';

  @override
  String get dsBarcodeImprimer => 'Print label';
}
