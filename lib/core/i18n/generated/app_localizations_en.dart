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
  String get activationIntro =>
      'Send this computer\'s identifier to your reseller; they will give you a key tied to this computer.';

  @override
  String get activationIdentifiantMachine => 'Computer identifier';

  @override
  String get activationCopierIdentifiant => 'Copy';

  @override
  String get activationIdentifiantCopie => 'Copied';

  @override
  String get activationCle => 'Licence key';

  @override
  String get activationCleIndice => 'Paste the full key into the first box.';

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
  String get activationErreurInconnue => 'Invalid key for this computer — check the identifier you sent.';

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
  String get connexionTitre => 'Welcome back';

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
  String get connexionDemoIndice => 'Demo mode: username demo, password demo.';

  @override
  String get connexionSaisirCle => 'Enter an activation key';

  @override
  String get connexionDeconnecter => 'Sign out';

  @override
  String get configTitre => 'Welcome to CaisseDZ';

  @override
  String configEtape(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get configEtapeBoutique => 'Shop';

  @override
  String get configEtapeAdmin => 'Administrator';

  @override
  String get configEtapeVente => 'Margin and stock';

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
  String get configMarge => 'Default margin';

  @override
  String get configMargeAide => 'Used to compute the selling price from the purchase price of new products.';

  @override
  String get configSeuil => 'Stock-out threshold';

  @override
  String get configFidelite => 'Loyalty';

  @override
  String get configPointsParDinar => 'Points earned per dinar';

  @override
  String get configDevise => 'Currency';

  @override
  String get configLangue => 'Language';

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
  String get permVoirPrixAchat => 'View purchase price';

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
  String get posMaxPaniers => 'At most 5 parallel sales.';

  @override
  String get posReste => 'Due';

  @override
  String get posPointsGagnes => 'Points earned';

  @override
  String get posClientPassage => 'Walk-in customer';

  @override
  String get posChoisirClient => 'Choose a customer';

  @override
  String get posCalculatrice => 'Calculator (F9)';

  @override
  String get posAide => 'Keyboard shortcuts (F1)';

  @override
  String get posSessionAucune => 'No open cash session: open one to sell.';

  @override
  String get posSessionCaisse => 'Register';

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
  String get posImpressionOk => 'Receipt sent to the printer.';

  @override
  String posImpressionErreur(String detail) {
    return 'Printing failed: $detail';
  }

  @override
  String get posRaccourcisTitre => 'Keyboard shortcuts';

  @override
  String get posRaccourciF1 => 'Shortcut help';

  @override
  String get posRaccourciF2 => 'Search / scan';

  @override
  String get posRaccourciF3 => 'Advanced search';

  @override
  String get posRaccourciF4 => 'Check out the receipt';

  @override
  String get posRaccourciF5 => 'Check out DN / NS';

  @override
  String get posRaccourciF6 => 'Save the receipt (credit)';

  @override
  String get posRaccourciF7 => 'Choose the customer';

  @override
  String get posRaccourciF8 => 'Choose a discount';

  @override
  String get posRaccourciF9 => 'Calculator';

  @override
  String get posRaccourciF10 => 'Clear cart';

  @override
  String get posRaccourciF11 => 'Hide / show products';

  @override
  String get posRaccourciF12 => 'Today\'s sales';

  @override
  String get posRaccourciCtrlN => 'New cart';

  @override
  String get posRaccourciCtrlTab => 'Next cart';

  @override
  String get posRaccourciSuppr => 'Remove selected line';

  @override
  String get posRaccourciPlusMoins => 'Quantity +1 / −1 on the selected line';

  @override
  String get posVendreNombre => 'Sell by piece';

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
  String get mvtAnnulation => 'Sale cancellation';

  @override
  String get mvtRemboursement => 'Return refund';

  @override
  String get mvtEncaissement => 'Customer payment';

  @override
  String get mvtDecaissement => 'Supplier payment';

  @override
  String get mvtApport => 'Manual cash in';

  @override
  String get mvtDepense => 'Manual cash out';

  @override
  String get mvtTransfert => 'Transfer';

  @override
  String get mvtFondInitial => 'Opening';

  @override
  String get mvtRetrait => 'Closing withdrawal';

  @override
  String get mvtEcart => 'Closing variance';

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

  @override
  String get moduleUtilisateurs => 'Users';

  @override
  String get connexionSousTitre => 'Sign in to open your till.';

  @override
  String get connexionAfficher => 'Show';

  @override
  String get connexionMasquer => 'Hide';

  @override
  String get connexionResterConnecte => 'Stay signed in';

  @override
  String get connexionMotDePasseOublie => 'Forgot your password? See the administrator';

  @override
  String get connexionHorsLigne => 'Works offline · data stored on this computer';

  @override
  String get connexionDemoNonActivee =>
      'Application not activated: sign in with demo / demo to try it, or enter a key.';

  @override
  String get connexionErreurNonActivee => 'Application not activated: only the demo / demo account is available.';

  @override
  String get connexionNonActivee => 'Not activated';

  @override
  String connexionVersion(String version, String licence) {
    return 'Version $version · $licence';
  }

  @override
  String get connexionNouveaute => 'New · AI Smart Scan';

  @override
  String get connexionAccroche => 'Sales, stock and till — simple, fast and secure.';

  @override
  String get connexionAccrocheDetail =>
      'Scan your purchase slips, track several stores and take payments in French, Arabic or English.';

  @override
  String get connexionAtoutHorsLigne => 'Offline';

  @override
  String get connexionAtoutMultiMagasin => 'Multi-store';

  @override
  String get activationNonActivee => 'Not activated';

  @override
  String activationPalierDetecte(String palier) {
    return 'Detected tier: $palier';
  }

  @override
  String get activationPalierBasic => 'Basic (1 store, 1 till)';

  @override
  String get activationPalierAvance => 'Advanced (multi-store, multi-till)';

  @override
  String get activationUnMagasin => '1 store';

  @override
  String get activationUneCaisse => '1 till';

  @override
  String get activationMagasinsIllimites => 'Unlimited stores and transfers';

  @override
  String get activationPlusieursCaisses => 'Several tills';

  @override
  String get activationSmartScanQuota => 'AI Smart Scan within server quota';

  @override
  String get activationRetourConnexion => 'Sign in';

  @override
  String get activationReussieTitre => 'Application activated';

  @override
  String activationReussieDetail(String palier, String poste) {
    return '$palier tier · tied to computer $poste.';
  }

  @override
  String get activationContinuer => 'Continue';

  @override
  String get configDescription => 'Four steps to set up the shop. Everything can be changed later in Settings.';

  @override
  String get configEtapeLangue => 'Language & currency';

  @override
  String get configEtapeLangueDetail => 'Display';

  @override
  String get configEtapeBoutiqueDetail => 'Receipt and legal details';

  @override
  String get configEtapePaiements => 'Payments';

  @override
  String get configEtapePaiementsDetail => 'Accepted methods';

  @override
  String get configEtapeVenteDetail => 'Prices and alerts';

  @override
  String get configDecimales => 'Quantity decimals';

  @override
  String get configDecimalesAide => '3 for sales by weight';

  @override
  String get configBoutiqueNomIndice => 'e.g. Benali Grocery';

  @override
  String get configBoutiqueAdresseIndice => 'Street, municipality, wilaya';

  @override
  String get configBoutiqueNis => 'NIS';

  @override
  String get configBoutiqueArticle => 'Tax article';

  @override
  String get configBoutiqueMessage => 'Receipt message';

  @override
  String get configBoutiqueMessageIndice => 'Thank you for your visit!';

  @override
  String get configSeuilAide => 'Global threshold, overridden by the product\'s own when set';

  @override
  String get configFideliteActive => 'Loyalty points';

  @override
  String get configPlusTard => 'Later';

  @override
  String get compteIdentifiant => 'Username';

  @override
  String compteIdentite(String identifiant, String acces) {
    return '@$identifiant · last access $acces';
  }

  @override
  String get compteJamaisConnecte => 'first sign-in';

  @override
  String get compteOngletProfil => 'Profile';

  @override
  String get compteOngletMotDePasse => 'Password';

  @override
  String get compteCode => 'Code';

  @override
  String get compteMagasinDefaut => 'Default store';

  @override
  String get compteConfirmer => 'Confirm';

  @override
  String compteMotDePasseAide(int n) {
    return 'At least $n characters';
  }

  @override
  String get comptePreferencesAide => 'These preferences apply to this computer.';

  @override
  String get alertesTitre => 'Today\'s alerts';

  @override
  String alertesResume(int urgentes, int surveiller) {
    return '$urgentes urgent · $surveiller to watch';
  }

  @override
  String get alertesToutTraite => 'All handled';

  @override
  String get alertesUrgent => 'Urgent';

  @override
  String get alertesASurveiller => 'To watch';

  @override
  String get alertesNePlusAfficher => 'Don\'t show again today';

  @override
  String get alertesLienParametres => 'Settings › Alerts';

  @override
  String get alertesOuvrirModule => 'Open module';

  @override
  String get alertesMarquerTraite => 'Mark as handled';

  @override
  String get alertesRienTitre => 'Nothing to report';

  @override
  String get alertesRienDetail => 'This alert family is handled.';

  @override
  String get alertesMesureRupture => 'Out of stock';

  @override
  String alertesOuverteDepuis(String date) {
    return 'Open since $date';
  }

  @override
  String alertesJours(int n) {
    return 'D−$n';
  }

  @override
  String alertesDernierDocument(String code, String date) {
    return '$code · last document on $date';
  }

  @override
  String get alertesRupture => 'Stock-outs and thresholds';

  @override
  String get alertesRuptureAide => 'Products out of stock or below their alert threshold.';

  @override
  String get alertesRuptureAction => 'Create a needs list';

  @override
  String get alertesRuptureLigne => 'Order';

  @override
  String get alertesExpire => 'Expired products';

  @override
  String get alertesExpireAide => 'Expired batches still in stock — remove before selling.';

  @override
  String get alertesExpireAction => '\"Expired\" removal';

  @override
  String get alertesExpireLigne => 'Remove';

  @override
  String get alertesSessions => 'Open sessions';

  @override
  String get alertesSessionsAide => 'Till sessions opened on a previous day.';

  @override
  String get alertesSessionsAction => 'Close';

  @override
  String get alertesBientot => 'Expiring soon';

  @override
  String get alertesBientotAide => 'Batches expiring within the next 30 days.';

  @override
  String get alertesBientotAction => 'Create a discount';

  @override
  String get alertesBientotLigne => 'Discount';

  @override
  String get alertesClients => 'Customer credit';

  @override
  String get alertesClientsAide => 'The largest outstanding credits.';

  @override
  String get alertesClientsAction => 'New payment';

  @override
  String get alertesClientsLigne => 'Collect';

  @override
  String get alertesFournisseurs => 'Supplier debts';

  @override
  String get alertesFournisseursAide => 'The largest debts and their latest purchase.';

  @override
  String get alertesFournisseursAction => 'New settlement';

  @override
  String get alertesFournisseursLigne => 'Settle';

  @override
  String get dsPeriodeAujourdhui => 'Today';

  @override
  String get dsPeriodeHier => 'Yesterday';

  @override
  String get dsPeriodeSemaine => 'This week';

  @override
  String get dsPeriodeSemaineDerniere => 'Last week';

  @override
  String get dsPeriodeMois => 'This month';

  @override
  String get dsPeriodeMoisDernier => 'Last month';

  @override
  String get dsPeriode7Jours => 'Last 7 days';

  @override
  String get dsPeriode30Jours => 'Last 30 days';

  @override
  String get dsPeriodeAnnee => 'This year';

  @override
  String get dsPeriodeAnneeDerniere => 'Last year';

  @override
  String get dsDu => 'From';

  @override
  String get dsAu => 'To';

  @override
  String get dsPeriodeRapide => 'Quick period';

  @override
  String get dsRechercherIndice => 'Search…';

  @override
  String get dsAffichageGrille => 'Grid view';

  @override
  String get dsAffichageListe => 'List view';

  @override
  String get dsModifiezRecherche => 'Change the search or the filters.';

  @override
  String get auditTitre => 'Audit trail';

  @override
  String get auditCreePar => 'Created by';

  @override
  String get auditAnnuleLe => 'Cancelled on';

  @override
  String get auditAnnulePar => 'Cancelled by';

  @override
  String get auditMotif => 'Reason';

  @override
  String get dsAnnuler => 'Cancel';

  @override
  String get dsValider => 'Apply';

  @override
  String get statutActif => 'Active';

  @override
  String get statutInactif => 'Inactive';

  @override
  String get statutPaye => 'Paid';

  @override
  String get statutPartiel => 'Partial';

  @override
  String get statutCredit => 'Credit';

  @override
  String get statutAnnule => 'Cancelled';

  @override
  String get statutOuverte => 'Open';

  @override
  String get statutFermee => 'Closed';

  @override
  String get statutCloturee => 'Closed out';

  @override
  String get statutRupture => 'Out of stock';

  @override
  String get statutSeuil => 'Below threshold';

  @override
  String get statutExpire => 'Expired';

  @override
  String get statutBientotExpire => 'Expiring soon';

  @override
  String get statutBrouillon => 'Draft';

  @override
  String get statutValide => 'Validated';

  @override
  String get statutEntree => 'In';

  @override
  String get statutSortie => 'Out';

  @override
  String get statutRetourne => 'Returned';

  @override
  String get statutClient => 'Customer';

  @override
  String get statutFournisseur => 'Supplier';

  @override
  String get statutRecu => 'Received';

  @override
  String get statutTraite => 'Processed';

  @override
  String get tiers15Chiffres => '15 digits';

  @override
  String get tiers20Chiffres => '20 digits';

  @override
  String get tiersActivite => 'Activity';

  @override
  String get tiersActiviteIndice => 'E.g. general grocery';

  @override
  String get tiersAdministratifBanque => 'Administrative & bank';

  @override
  String get tiersAdresseIndice => 'Street, municipality';

  @override
  String get tiersAvance => 'Advance';

  @override
  String get tiersBanque => 'Bank';

  @override
  String get tiersBloqueCredit => 'Outstanding credit — settle it first';

  @override
  String get tiersBloqueDejaAnnule => 'Already cancelled';

  @override
  String get tiersBloqueSysteme => 'System item';

  @override
  String get tiersChampsObligatoires => 'Fields marked * are required';

  @override
  String get tiersChoisir => 'Choose…';

  @override
  String get tiersChoisirClient => 'Choose a customer';

  @override
  String get tiersChoisirFournisseur => 'Choose a supplier';

  @override
  String get tiersCodeAuto => 'Generated automatically';

  @override
  String get tiersContact => 'Contact';

  @override
  String get tiersCredit => 'Credit';

  @override
  String get tiersCreditAide => 'Credit (purchases)';

  @override
  String get tiersDebit => 'Debit';

  @override
  String get tiersDebitAide => 'Debit (payments, returns)';

  @override
  String get tiersDernierAchat => 'Last purchase';

  @override
  String get tiersDerniereEntree => 'Last receipt';

  @override
  String get tiersDernieresEntrees => 'Latest receipts';

  @override
  String get tiersDerniersPaniers => 'Latest baskets';

  @override
  String tiersDescriptionClients(int n, int nb) {
    return '$n customers · $nb with outstanding credit';
  }

  @override
  String tiersDescriptionFournisseurs(int n, int nb) {
    return '$n suppliers · $nb with outstanding credit';
  }

  @override
  String get tiersDetail => 'Details';

  @override
  String get tiersEntiteClient => 'customer';

  @override
  String get tiersEntiteClientMaj => 'Customer';

  @override
  String get tiersEntiteClients => 'customers';

  @override
  String get tiersEntiteFournisseur => 'supplier';

  @override
  String get tiersEntiteFournisseurMaj => 'Supplier';

  @override
  String get tiersEntiteFournisseurs => 'suppliers';

  @override
  String get tiersErreurNomExistant => 'This name already exists';

  @override
  String get tiersEtat => 'Status';

  @override
  String get tiersFax => 'Fax';

  @override
  String get tiersFormatNif => 'The tax ID must have 15 digits';

  @override
  String get tiersFormatTelephone => 'Expected format: 0X XX XX XX XX';

  @override
  String get tiersInfosAdministratives => 'Administrative information';

  @override
  String get tiersInfosBancaires => 'Bank details';

  @override
  String get tiersInfosGenerales => 'General information';

  @override
  String get tiersKpiClientsActifs => 'Active customers';

  @override
  String get tiersKpiCreditClients => 'Customer credit';

  @override
  String get tiersKpiCreditFournisseurs => 'Supplier credit';

  @override
  String get tiersKpiFournisseursActifs => 'Active suppliers';

  @override
  String get tiersKpiPoints => 'Loyalty points';

  @override
  String get tiersModifierClient => 'Edit customer';

  @override
  String get tiersModifierFournisseur => 'Edit supplier';

  @override
  String get tiersNatureAchat => 'Purchase';

  @override
  String get tiersNatureRetour => 'Return';

  @override
  String get tiersNatureVente => 'Sale';

  @override
  String get tiersNatureVersement => 'Payment';

  @override
  String get tiersNatureVersementRetour => 'Refund payment';

  @override
  String get tiersNomIndice => 'Name or company name';

  @override
  String get tiersNoteInterne => 'Internal note';

  @override
  String get tiersNrc => 'Trade register no.';

  @override
  String get tiersObservation => 'Note';

  @override
  String get tiersPanier => 'Basket';

  @override
  String tiersPoints(int n) {
    return '$n points';
  }

  @override
  String get tiersRechercheIndice => 'Name, code or phone…';

  @override
  String get tiersReference => 'Reference';

  @override
  String get tiersReleveClient => 'Customer statement';

  @override
  String get tiersReleveFournisseur => 'Supplier statement';

  @override
  String get tiersReste => 'Remaining';

  @override
  String get tiersSituation => 'Statement';

  @override
  String tiersSituationDe(String nom) {
    return 'Statement — $nom';
  }

  @override
  String get tiersSolde => 'Balance';

  @override
  String get tiersSoldeDu => 'Balance due';

  @override
  String get tiersStatut => 'Status';

  @override
  String get tiersTotalAchats => 'Total purchases';

  @override
  String get tiersTotalPaye => 'Total paid';

  @override
  String get tiersTotalRetours => 'Total returns';

  @override
  String get tiersTous => 'All';

  @override
  String get tiersToutes => 'All';

  @override
  String get tiersType => 'Type';

  @override
  String get tiersVersement => 'Payment';

  @override
  String get tiersWilaya => 'Province';

  @override
  String get versementAideClient => 'The amount is applied to the customer\'s credit baskets, oldest first.';

  @override
  String get versementAideFournisseur => 'The amount is applied to the supplier\'s credit receipts, oldest first.';

  @override
  String get versementAideRetourClient => 'Money given back to the customer (advance or overpayment): cash out.';

  @override
  String get versementAideRetourFournisseur => 'Money refunded by the supplier: cash in.';

  @override
  String get versementAucunBeneficiaire => 'No beneficiary chosen';

  @override
  String get versementAvanceTropPercu => 'Advance / overpayment after this payment';

  @override
  String get versementBeneficiaire => 'Beneficiary';

  @override
  String get versementCaisse => 'Till';

  @override
  String get versementCliquezChoisir => 'Click to choose';

  @override
  String get versementCompteSolde => 'Account settled after this payment';

  @override
  String versementCreditActuel(String montant) {
    return 'Current credit: $montant';
  }

  @override
  String get versementCreditRestant => 'Credit remaining after this payment';

  @override
  String get versementEntite => 'payment';

  @override
  String get versementEntites => 'payments';

  @override
  String get versementKpiEncaisse => 'Amount collected';

  @override
  String get versementKpiNombre => 'Payments';

  @override
  String get versementKpiPaye => 'Amount paid';

  @override
  String get versementKpiRetour => 'Refund payments';

  @override
  String get versementModifier => 'Edit payment';

  @override
  String get versementNumero => 'Number';

  @override
  String get versementObsIndice => 'Note (optional)';

  @override
  String get versementRetourModifier => 'Edit refund payment';

  @override
  String get versementRetourNouveau => 'Refund payment';

  @override
  String get versementRetourTitre => 'Refund payment';

  @override
  String get versementSens => 'Direction';

  @override
  String get versementSensPaye => 'Paid';

  @override
  String get versementSensRecu => 'Received';

  @override
  String get versementSensRetour => 'Refund';

  @override
  String get versementTitre => 'Payment';

  @override
  String get versementType => 'Type';

  @override
  String get dsChargement => 'Loading…';

  @override
  String get tableauBordOnglet => 'Dashboard';

  @override
  String get situationOnglet => 'Statements';

  @override
  String tableauBordDescription(String au, String du, int n) {
    return 'From $du to $au, compared with the previous $n days.';
  }

  @override
  String get situationDescription => 'Detailed analyses for the period — each view can be exported to Excel and PDF.';

  @override
  String get tableauBordJour => 'Day';

  @override
  String get tableauBordSemaine => 'Week';

  @override
  String get tableauBordMois => 'Month';

  @override
  String get tableauBordPeriode => 'Period';

  @override
  String get tableauBordChoisirPeriode => 'Choose the period';

  @override
  String get tableauBordIndicateur => 'Indicator';

  @override
  String get tableauBordPeriodeCourante => 'Period';

  @override
  String get tableauBordPeriodePrecedente => 'Previous period';

  @override
  String get tableauBordVentes => 'Sales';

  @override
  String get tableauBordVentesInfo => 'Total of baskets cashed in over the period';

  @override
  String get tableauBordVsPrecedente => 'vs previous period';

  @override
  String get tableauBordPrecedenteInfo => 'Same number of days, just before the period';

  @override
  String get tableauBordAchats => 'Purchases';

  @override
  String get tableauBordAchatsInfo => 'Validated receipts (purchase notes)';

  @override
  String get tableauBordNet => 'Net';

  @override
  String get tableauBordNetInfo => 'Sales − purchases for the period';

  @override
  String get tableauBordDetteFournisseurs => 'Supplier debt';

  @override
  String get tableauBordDetteInfo => 'Amounts left to pay on receipts';

  @override
  String get tableauBordCreditClients => 'Customer credit';

  @override
  String get tableauBordCreditInfo => 'Amounts due on baskets';

  @override
  String get tableauBordCourbeVentes => 'Sales curve';

  @override
  String get tableauBordModesPaiement => 'Payment methods';

  @override
  String get tableauBordTotal => 'Total';

  @override
  String get tableauBordCaParJour => 'Revenue per day';

  @override
  String get tableauBordVentesCaissier => 'Sales per cashier';

  @override
  String tableauBordTickets(int n) {
    return '$n tickets';
  }

  @override
  String tableauBordUnites(String qte) {
    return '$qte u.';
  }

  @override
  String get tableauBordDernieresVentes => 'Latest sales';

  @override
  String get tableauBordPanier => 'Basket no.';

  @override
  String get tableauBordHeure => 'Time';

  @override
  String get tableauBordPaiement => 'Payment';

  @override
  String get tableauBordRuptures => 'Out-of-stock products';

  @override
  String get tableauBordAucuneRupture => 'No product out of stock';

  @override
  String get tableauBordProduit => 'Product';

  @override
  String get tableauBordStock => 'Stock';

  @override
  String get situationGroupeTresorerie => 'Cash';

  @override
  String get situationGroupeStock => 'Stock';

  @override
  String get situationGroupeVentes => 'Sales';

  @override
  String get situationGroupeMarges => 'Margins';

  @override
  String get situationGroupeTiers => 'Third parties';

  @override
  String get situationMvc => 'Till movements';

  @override
  String get situationMvp => 'Product movements';

  @override
  String get situationRcp => 'Revenue per basket';

  @override
  String get situationRcpr => 'Revenue per product';

  @override
  String get situationMgp => 'Margin per basket';

  @override
  String get situationMgper => 'Margin per period';

  @override
  String get situationInv => 'Stock count';

  @override
  String get situationCout => 'Product cost';

  @override
  String get situationScli => 'Customer statement';

  @override
  String get situationSfrn => 'Supplier statement';

  @override
  String get situationEntrees => 'In';

  @override
  String get situationSorties => 'Out';

  @override
  String get situationSoldeNet => 'Net balance';

  @override
  String get situationRetours => 'Returns';

  @override
  String get situationStockInitial => 'Opening stock';

  @override
  String get situationStockFinal => 'Closing stock';

  @override
  String get situationCaissier => 'Cashier';

  @override
  String get situationPaye => 'Paid';

  @override
  String get situationPaniers => 'Baskets';

  @override
  String get situationRecette => 'Revenue';

  @override
  String get situationPanierMoyen => 'Average basket';

  @override
  String get situationCategorie => 'Category';

  @override
  String get situationQuantite => 'Quantity';

  @override
  String get situationPrixMoyen => 'Average price';

  @override
  String get situationProduitsVendus => 'Products sold';

  @override
  String get situationVente => 'Sale';

  @override
  String get situationCoutLibelle => 'Cost';

  @override
  String get situationMarge => 'Margin';

  @override
  String get situationTaux => 'Rate';

  @override
  String get situationCa => 'Revenue';

  @override
  String get situationTauxMoyen => 'Average rate';

  @override
  String get situationMargeParPeriode => 'Margin per period';

  @override
  String get situationRegrouper => 'Group by';

  @override
  String get situationParJour => 'By day';

  @override
  String get situationParSemaine => 'By week';

  @override
  String get situationParMois => 'By month';

  @override
  String get situationMagasin => 'Store';

  @override
  String get situationTheorique => 'Expected';

  @override
  String get situationCompte => 'Counted';

  @override
  String get situationEcart => 'Difference';

  @override
  String get situationValeur => 'Value';

  @override
  String get situationProduitsComptes => 'Products counted';

  @override
  String get situationEcarts => 'Differences';

  @override
  String get situationValeurEcart => 'Difference value';

  @override
  String get situationValiderInventaire => 'Validate the count';

  @override
  String get situationInventaireMagasin => 'Choose a store to validate the count.';

  @override
  String get situationAucunEcart => 'No difference to record.';

  @override
  String situationConfirmerInventaire(int n) {
    return '$n product(s) will be adjusted to the counted stock. Continue?';
  }

  @override
  String get situationInventaireValide => 'Count validated';

  @override
  String situationProduitsAjustes(int n) {
    return '$n product(s) adjusted';
  }

  @override
  String get situationDernierAchat => 'Last purchase';

  @override
  String get situationCmp => 'Weighted average cost';

  @override
  String get situationMin => 'Min';

  @override
  String get situationMax => 'Max';

  @override
  String get situationPrixVente => 'Selling price';

  @override
  String get situationProduits => 'Products';

  @override
  String get situationMargeMoyenne => 'Average margin';

  @override
  String get situationSous15 => 'Below 15 %';

  @override
  String get situationAchats => 'Purchases';

  @override
  String get situationDette => 'Debt';

  @override
  String get situationDettes => 'Debts';

  @override
  String get situationCreditTotal => 'Total credit';

  @override
  String get ventesDescription => 'All cashed baskets — receipts and DN / SC';

  @override
  String get ventesKpiNombre => 'Number of sales';

  @override
  String get ventesKpiCa => 'Revenue';

  @override
  String get ventesKpiMarge => 'Margin';

  @override
  String get ventesKpiEncaisse => 'Collected';

  @override
  String get ventesKpiCredit => 'Customer credit';

  @override
  String get ventesType => 'Type';

  @override
  String get ventesTous => 'All';

  @override
  String get ventesToutes => 'All';

  @override
  String get ventesStatut => 'Status';

  @override
  String get ventesCaissier => 'Cashier';

  @override
  String get ventesClient => 'Customer';

  @override
  String get ventesCaisse => 'Till';

  @override
  String get ventesSession => 'Session';

  @override
  String get ventesMontant => 'Amount';

  @override
  String get ventesPaye => 'Paid';

  @override
  String get ventesReste => 'Balance';

  @override
  String get ventesPaiement => 'Payment';

  @override
  String get ventesArticles => 'Items';

  @override
  String get ventesQuantite => 'Quantity';

  @override
  String get ventesNbVersements => 'No. of payments';

  @override
  String get ventesMontantAchat => 'Purchase amount';

  @override
  String get ventesAnnuleLe => 'Cancelled on';

  @override
  String get ventesAnnulePar => 'Cancelled by';

  @override
  String get ventesRechercheIndice => 'Basket no. or customer…';

  @override
  String get ventesNouvelle => 'New sale';

  @override
  String get ventesEntite => 'basket';

  @override
  String get ventesEntitePluriel => 'baskets';

  @override
  String ventesPanierTitre(String code) {
    return 'Basket $code';
  }

  @override
  String get ventesReimprimer => 'Reprint';

  @override
  String get ventesMontantTotal => 'Total amount';

  @override
  String get ventesVersements => 'Payments';

  @override
  String get ventesInfosGenerales => 'General information';

  @override
  String get ventesPaiementMarge => 'Payment & margin';

  @override
  String get ventesTotalAchat => 'Purchase total';

  @override
  String get ventesMontantPaye => 'Amount paid';

  @override
  String get ventesNombreVersements => 'Number of payments';

  @override
  String get ventesModePaiement => 'Payment method';

  @override
  String get ventesProduitsPanier => 'Basket products';

  @override
  String get ventesProduits => 'Products';

  @override
  String get ventesProduit => 'Product';

  @override
  String get ventesQte => 'Qty';

  @override
  String get ventesNumSerie => 'Serial no.';

  @override
  String get ventesPrix => 'Price';

  @override
  String get ventesTotal => 'Total';

  @override
  String get ventesAudit => 'Audit';

  @override
  String get ventesCreePar => 'Created by';

  @override
  String get ventesCreeLe => 'Created on';

  @override
  String get ventesMotifAnnulation => 'Cancellation reason';

  @override
  String get ventesEmpreinte => 'Fiscal fingerprint';

  @override
  String get ventesModifierTitre => 'Edit basket';

  @override
  String ventesModifierDescription(String code) {
    return '$code · lines cannot be edited — use a return.';
  }

  @override
  String get ventesClientScelle => 'Sealed receipt customer: for another customer, make a return then a new sale.';

  @override
  String get ventesComplementIndice => 'The difference will be recorded as a payment allocated to this basket.';

  @override
  String get ventesNoteInterne => 'Internal note';

  @override
  String get ventesModifie => 'Basket updated';

  @override
  String get ventesBloqueDejaAnnule => 'Already cancelled';

  @override
  String get ventesBloqueRetour => 'A return is linked to this basket';

  @override
  String get ventesAnnulesTitre => 'Baskets cancelled';

  @override
  String get ventesAnnulesMessage => 'Product stock has been restored and amounts removed from the session.';

  @override
  String ventesAnnulesPartiel(String detail, int ok) {
    return '$ok basket(s) cancelled. Failed: $detail';
  }

  @override
  String get statutTicket => 'Receipt';

  @override
  String get statutFacture => 'DN / SC';

  @override
  String get posErreurMotif => 'A reason is required.';

  @override
  String posErreurMontantPaye(String montant) {
    return 'The paid amount cannot decrease (already paid: $montant). Use a return.';
  }

  @override
  String get posErreurRetourLie => 'A return is linked to this basket: it cannot be cancelled.';

  @override
  String get retoursDescription => 'Customer returns (restock, refund) and supplier returns';

  @override
  String get retoursOngletClients => 'Customer returns';

  @override
  String get retoursOngletFournisseurs => 'Supplier returns';

  @override
  String get retoursKpiNombre => 'Returns in period';

  @override
  String get retoursKpiQuantite => 'Quantity returned';

  @override
  String get retoursKpiRembourse => 'Amount refunded';

  @override
  String get retoursKpiDeduit => 'Deducted from credit';

  @override
  String get retoursClient => 'Customer';

  @override
  String get retoursFournisseur => 'Supplier';

  @override
  String get retoursRemboursement => 'Refund';

  @override
  String get retoursReglement => 'Settlement';

  @override
  String get retoursEtat => 'Status';

  @override
  String get retoursTous => 'All';

  @override
  String get retoursRecherche => 'Code, party or product…';

  @override
  String get retoursOrigine => 'Origin';

  @override
  String get retoursProduit => 'Product';

  @override
  String get retoursQte => 'Qty';

  @override
  String get retoursMontant => 'Amount';

  @override
  String get retoursPrixAchat => 'Purchase price';

  @override
  String get retoursPrixVente => 'Sale price';

  @override
  String get retoursObservation => 'Note';

  @override
  String get retoursRegEspeces => 'Cash';

  @override
  String get retoursRegCarte => 'CIB card';

  @override
  String get retoursRegAvoir => 'Customer credit note';

  @override
  String get retoursRegDeduit => 'Deducted from credit';

  @override
  String get retoursRegRembEspeces => 'Cash refund';

  @override
  String get retoursNouveau => 'New return';

  @override
  String get retoursModifierTitre => 'Edit return';

  @override
  String get retoursFormDescription =>
      'Return of a product sold (customer) or received (supplier). Stock is restored or deducted.';

  @override
  String get retoursChoixClient => 'Customer return';

  @override
  String get retoursChoixClientDesc => 'Restocks, refunds or creates a credit note';

  @override
  String get retoursChoixFournisseur => 'Supplier return';

  @override
  String get retoursChoixFournisseurDesc => 'Leaves stock, deducted from supplier credit';

  @override
  String get retoursTicketOrigine => 'Original receipt';

  @override
  String get retoursEntreeOrigine => 'Original receipt note';

  @override
  String get retoursChoisirClientIndice => 'Choose a customer ≡';

  @override
  String get retoursChoisirFournisseurIndice => 'Choose a supplier ≡';

  @override
  String get retoursChoisirPanierIndice => 'Choose a basket ≡';

  @override
  String get retoursChoisirEntreeIndice => 'Choose a receipt note ≡';

  @override
  String get retoursChoisirTicket => 'Choose the original receipt';

  @override
  String get retoursChoisirEntree => 'Choose the original receipt note';

  @override
  String get retoursProduitIndice => 'Product from the original document';

  @override
  String get retoursProduitAideTicket => 'Choose the original receipt first';

  @override
  String get retoursProduitAideEntree => 'Choose the original receipt note first';

  @override
  String retoursOptionVendu(String nom, String prix, String qte) {
    return '$nom — $qte sold at $prix';
  }

  @override
  String retoursOptionRecu(String nom, String prix, String qte) {
    return '$nom — $qte received at $prix';
  }

  @override
  String get retoursQuantite => 'Quantity';

  @override
  String retoursQuantiteMax(String maximum) {
    return 'Maximum: $maximum';
  }

  @override
  String retoursQuantiteDepasse(String maximum) {
    return 'Maximum $maximum (quantity on the original document)';
  }

  @override
  String get retoursNumSerie => 'Serial no.';

  @override
  String get retoursNumSerieIndice => 'If the product is tracked';

  @override
  String get retoursRemiseStock => 'Restock';

  @override
  String get retoursRemiseOui => 'Yes — product can be resold';

  @override
  String get retoursRemiseNon => 'No — defective, “Breakage” exit';

  @override
  String get retoursMotifIndice => 'Reason for return';

  @override
  String get retoursARembourser => 'To refund to the customer';

  @override
  String get retoursAvoirClient => 'Credit note on the customer account';

  @override
  String get retoursADeduire => 'To deduct from supplier credit';

  @override
  String get retoursRembourseFournisseur => 'To be refunded by the supplier';

  @override
  String get retoursEnregistre => 'Return saved';

  @override
  String retoursEnregistreDetail(String code) {
    return '$code · stock updated';
  }

  @override
  String get retoursModifie => 'Return updated';

  @override
  String get retoursAnnulesTitre => 'Returns cancelled';

  @override
  String get retoursAnnulesDetail => 'Stock has been restored';

  @override
  String get retoursEntite => 'return';

  @override
  String get retoursEntitePluriel => 'returns';

  @override
  String retoursDetailTitre(String code) {
    return 'Return $code';
  }

  @override
  String get retoursPieceOrigine => 'Original document';

  @override
  String get retoursBloqueDejaAnnule => 'Already cancelled';

  @override
  String get retoursAucun => 'No returns in this period.';

  @override
  String get retourErreurDocumentInconnu => 'Original document not found.';

  @override
  String get retourErreurDocumentAnnule => 'The original document is cancelled.';

  @override
  String get retourErreurProduitAbsent => 'This product is not on the original document.';

  @override
  String get retourErreurReglement => 'Invalid settlement (no credit note for walk-in customer).';

  @override
  String get retourErreurStock => 'Insufficient stock for this return.';

  @override
  String get retourErreurInconnu => 'Return not found.';

  @override
  String get retourErreurDejaAnnule => 'Return already cancelled.';

  @override
  String get retourErreurMotif => 'A reason is required.';

  @override
  String get achatErreurRetourLie => 'A supplier return is linked to this receipt note: it cannot be cancelled.';

  @override
  String get posVentesDuJour => 'Today\'s sales';

  @override
  String get posRecetteProduit => 'Product takings';

  @override
  String get posMasquerProduits => 'Hide products';

  @override
  String get posAfficherProduits => 'Show products';

  @override
  String get posParametres => 'Till settings';

  @override
  String get posScanIndice => 'Scan a barcode or search…';

  @override
  String get posRecherche => 'Search';

  @override
  String get posProduits => 'Products';

  @override
  String get posPacks => 'Packs';

  @override
  String get posAffichageGrille => 'Grid view';

  @override
  String get posAffichageListe => 'List view';

  @override
  String posVente(int n) {
    return 'Sale $n';
  }

  @override
  String get posVenteVide => 'Empty';

  @override
  String posVenteMeta(String montant, String pieces) {
    return '$pieces pcs · $montant';
  }

  @override
  String get posPanierTitre => 'Cart';

  @override
  String get posNouveauProduit => 'New product';

  @override
  String get posNouveauClient => 'New customer';

  @override
  String get posViderPanier => 'Empty the cart (F10)';

  @override
  String get posClientLabel => 'Customer';

  @override
  String get posModePaiement => 'Payment method';

  @override
  String get posChoisirRemise => 'Choose a discount';

  @override
  String get posAucuneRemise => 'No discount';

  @override
  String get posPanierVideTitre => 'Empty cart';

  @override
  String get posPanierVideDesc => 'Scan a barcode or tap a product.';

  @override
  String get posLigneAide => 'Double-click: edit the price · click the package: change it';

  @override
  String get posEnregistrer => 'Save';

  @override
  String get posBlSc => 'DN / NS';

  @override
  String get posEncaisserBouton => 'Check out';

  @override
  String get posEncTicketTitre => 'Check out the receipt';

  @override
  String get posEncBlscTitre => 'Check out DN / NS';

  @override
  String get posEncSaveTitre => 'Save the receipt';

  @override
  String get posEncTicketDesc => 'Check the amount received, then confirm: the receipt is printed.';

  @override
  String get posEncBlscDesc => 'Delivery note without stamp, with legal notices.';

  @override
  String get posEncSaveDesc => 'The receipt is saved: the balance goes to the customer\'s credit.';

  @override
  String get posEncTicketOk => 'Check out and print';

  @override
  String get posEncBlscOk => 'Check out the DN / NS';

  @override
  String get posInfoVente => 'Sale';

  @override
  String get posInfoDate => 'Date';

  @override
  String get posInfoProduits => 'Products';

  @override
  String get posInfoPieces => 'Pieces';

  @override
  String get posInfoPaiement => 'Payment';

  @override
  String get posInfoCaissier => 'Cashier';

  @override
  String get posSortieImprimer => 'Print';

  @override
  String get posSortieImprimerDesc => 'Default A4 printer';

  @override
  String get posSortiePdf => 'Save as PDF';

  @override
  String get posSortiePdfDesc => 'Save or share the document';

  @override
  String posToastEncaisse(String code, String type) {
    return '$type $code checked out';
  }

  @override
  String posToastEnregistre(String code) {
    return 'Receipt $code saved';
  }

  @override
  String posToastResteCredit(String montant) {
    return 'Balance on credit: $montant';
  }

  @override
  String posToastRendu(String montant, String rendu) {
    return 'Total $montant · change $rendu';
  }

  @override
  String get posReimprimer => 'Reprint';

  @override
  String get posTicket => 'Receipt';

  @override
  String get posSelTitre => 'Quantity and package';

  @override
  String get posSelTitreModif => 'Edit quantity and package';

  @override
  String posSelScanne(String code) {
    return 'Scanned product · $code';
  }

  @override
  String posSelAuto(String detail, String secondes) {
    return 'Adding $detail automatically in $secondes s · touch to edit';
  }

  @override
  String get posSelAutoAnnule => 'Automatic add cancelled — confirm with Enter';

  @override
  String posSelParPiece(String prix) {
    return '$prix / piece';
  }

  @override
  String posSelStock(String quantite) {
    return 'Stock: $quantite pieces';
  }

  @override
  String get posSelColis => 'Package';

  @override
  String get posSelUnite => 'By the unit';

  @override
  String posSelParColis(String nom, String quantite) {
    return '$nom ($quantite pieces)';
  }

  @override
  String get posSelQuantite => 'Quantity';

  @override
  String get posSelPieces => 'Pieces';

  @override
  String posSelStockInsuffisant(String quantite) {
    return 'Insufficient stock ($quantite pieces)';
  }

  @override
  String posSelAjouter(String montant) {
    return 'Add · $montant';
  }

  @override
  String posSelModifier(String montant) {
    return 'Edit · $montant';
  }

  @override
  String get posPrixTitre => 'Edit the product price';

  @override
  String get posPrixDesc => 'Authorised roles only — password required.';

  @override
  String get posPrixAchat => 'Purchase price';

  @override
  String get posPrixVente => 'Sale price';

  @override
  String get posPrixMotDePasse => 'Password';

  @override
  String get posPrixMotDePasseIndice => 'Your password';

  @override
  String get posPrixPortee => 'Scope';

  @override
  String get posPrixPorteeTicket => 'This receipt only';

  @override
  String get posPrixPorteeTicketDesc => 'The catalogue price does not change';

  @override
  String get posPrixPorteeProduit => 'The whole product';

  @override
  String get posPrixPorteeProduitDesc => 'Updates the sale price';

  @override
  String get posPrixInvalide => 'Invalid price';

  @override
  String get posPrixMdpRequis => 'Password required';

  @override
  String get posPrixMdpIncorrect => 'Incorrect password';

  @override
  String get posPrixSousAchat => 'Below the purchase price';

  @override
  String posPrixMarge(String montant) {
    return 'Margin: $montant';
  }

  @override
  String get posPrixSousAchatTitre => 'Sell below the purchase price?';

  @override
  String posPrixSousAchatMsg(String achat, String vente) {
    return 'Sale price $vente is below the purchase price $achat.';
  }

  @override
  String get posPrixSousAchatOk => 'Sell anyway';

  @override
  String get posPrixModifie => 'Price changed';

  @override
  String posPrixModifieTicket(String nom) {
    return '$nom · this receipt only';
  }

  @override
  String posPrixModifieProduit(String nom) {
    return '$nom · catalogue price updated';
  }

  @override
  String get posRechTitre => 'Find a product';

  @override
  String get posRechDesc => 'Filter, then tick the products to add to the cart.';

  @override
  String get posRechAjouter => 'Add to cart';

  @override
  String get posRechIndice => 'Name, code or barcode…';

  @override
  String posRechAjoutes(int n) {
    return '$n product(s) added';
  }

  @override
  String get posIntrouvableTitre => 'Product not found';

  @override
  String get posIntrouvableDesc => 'No active product matches this barcode.';

  @override
  String get posIntrouvableCreer => 'Create the product';

  @override
  String get posFermeeTitre => 'No open session';

  @override
  String posFermeeDesc(String caisse) {
    return 'Open a session for “$caisse” before selling.';
  }

  @override
  String get posOuvrirCaisse => 'Open the till';

  @override
  String posOuvertureTitre(String caisse) {
    return 'Open $caisse';
  }

  @override
  String get posOuvertureDesc => 'Count the opening float before starting.';

  @override
  String get posOuvertureSolde => 'Opening balance';

  @override
  String get posOuverturePar => 'Opened by';

  @override
  String get posOuvertureOk => 'Open the session';

  @override
  String get posCaisseOuverte => 'Till opened';

  @override
  String posCaisseOuverteDesc(String montant) {
    return 'Opening float: $montant';
  }

  @override
  String posClotureTitre(String caisse) {
    return 'Close $caisse';
  }

  @override
  String posClotureDesc(String code, String heure) {
    return 'Session $code · opened at $heure';
  }

  @override
  String get posClotureFond => 'Opening float';

  @override
  String get posClotureVentesEspeces => 'Cash sales (change deducted)';

  @override
  String get posClotureTheorique => 'Expected balance';

  @override
  String get posClotureReel => 'Counted balance';

  @override
  String posClotureEcart(String etat) {
    return 'Till difference · $etat';
  }

  @override
  String get posClotureJuste => 'Till balanced';

  @override
  String get posClotureExcedent => 'Surplus';

  @override
  String get posClotureManquant => 'Shortfall';

  @override
  String get posClotureOk => 'Close the session';

  @override
  String get posClotureFaite => 'Session closed';

  @override
  String posClotureEcartToast(String montant) {
    return 'Difference: $montant';
  }

  @override
  String get posMvtTitre => 'Manual movement';

  @override
  String get posMvtDesc => 'Cash in or out outside sales: float deposit, withdrawal, expenses.';

  @override
  String get posMvtType => 'Type';

  @override
  String get posMvtEntree => 'Manual cash in';

  @override
  String get posMvtSortie => 'Manual cash out';

  @override
  String get posMvtMotif => 'Reason';

  @override
  String get posMvtFait => 'Movement saved';

  @override
  String posMvtFaitDesc(String montant, String sens) {
    return '$sens of $montant';
  }

  @override
  String posVdjTitre(String caisse) {
    return 'Till takings — $caisse';
  }

  @override
  String posVdjDesc(String date) {
    return 'Sales of $date';
  }

  @override
  String get posVdjIndice => 'Cart no. or customer…';

  @override
  String get posVdjNombre => 'Number of sales';

  @override
  String get posVdjTotal => 'Total sales';

  @override
  String get posVdjEncaisse => 'Collected';

  @override
  String get posVdjReste => 'Balance (credit)';

  @override
  String get posVdjAucune => 'No sales found';

  @override
  String get posVdjHeure => 'Time';

  @override
  String posRecTitre(String caisse) {
    return 'Takings by product — $caisse';
  }

  @override
  String posRecDesc(String date) {
    return 'Lines sold on $date';
  }

  @override
  String get posRecIndice => 'Product, code or cart…';

  @override
  String get posRecLignes => 'Lines sold';

  @override
  String get posRecQuantite => 'Quantity';

  @override
  String get posRecAucune => 'No lines sold';

  @override
  String get posParamDesc => 'Applies to this workstation until sign-out.';

  @override
  String get posParamMagasin => 'Store';

  @override
  String get posParamFait => 'Settings saved';

  @override
  String posFermerVenteTitre(int n) {
    return 'Close sale $n?';
  }

  @override
  String posFermerVenteMsg(String lignes) {
    return 'The cart ($lignes line(s)) will be dropped. Check it out or save it first to keep it.';
  }

  @override
  String get posFermerVenteOk => 'Close without saving';

  @override
  String get posEntreeTitre => 'Quick stock entry';

  @override
  String posEntreeDesc(String magasin, String nom) {
    return '$nom · $magasin';
  }

  @override
  String get posEntreeFaite => 'Quick entry saved';

  @override
  String posEntreeFaiteDesc(String nom) {
    return '$nom · stock updated';
  }

  @override
  String get produitErreurUtilise => 'This product is in use (sales, purchases or stock): it cannot be deleted.';

  @override
  String get catalogueErreurNomPris => 'This name is already in use.';

  @override
  String get prdDescription => 'Catalogue, categories, discounts and bundles';

  @override
  String get prdOngletSousCategories => 'Subcategories';

  @override
  String get prdAchat => 'Cost';

  @override
  String get prdVente => 'Price';

  @override
  String get prdMarge => 'Margin';

  @override
  String get prdMarque => 'Brand';

  @override
  String get prdMarqueIndice => 'e.g. Elio';

  @override
  String get prdDescriptionChamp => 'Description';

  @override
  String get prdTaille => 'Size';

  @override
  String get prdCouleur => 'Colour';

  @override
  String get prdRemise => 'Discount';

  @override
  String get prdService => 'Service';

  @override
  String prdEmballageN(int n) {
    return 'Packaging $n';
  }

  @override
  String prdPrixEmballageN(int n) {
    return 'Packaging $n price';
  }

  @override
  String prdEmballagePieces(int n) {
    return '$n pcs';
  }

  @override
  String get prdNumeroSerie => 'Serial no.';

  @override
  String get prdMultiCodes => 'Multiple barcodes';

  @override
  String get prdPhotos => 'Photos';

  @override
  String get prdTva => 'VAT';

  @override
  String get prdDateExpiration => 'Expiry date';

  @override
  String get prdEntiteProduits => 'products';

  @override
  String get prdEntiteProduit => 'product';

  @override
  String get prdEntiteCategories => 'categories';

  @override
  String get prdEntiteCategorie => 'category';

  @override
  String get prdEntiteSousCategories => 'subcategories';

  @override
  String get prdEntiteSousCategorie => 'subcategory';

  @override
  String get prdEntiteRemises => 'discounts';

  @override
  String get prdEntiteRemise => 'discount';

  @override
  String get prdEntitePacks => 'bundles';

  @override
  String get prdEntitePack => 'bundle';

  @override
  String get prdKpiActifs => 'Active products';

  @override
  String get prdKpiValeurStock => 'Stock value';

  @override
  String get prdKpiSousSeuil => 'Below threshold';

  @override
  String get prdKpiRupture => 'Out of stock';

  @override
  String get prdToutes => 'All';

  @override
  String get prdDisponible => 'Available';

  @override
  String get prdRechercheProduits => 'Name, code or barcode…';

  @override
  String get prdRechercheCategorie => 'Search a category…';

  @override
  String get prdRechercheSousCategorie => 'Search a subcategory…';

  @override
  String get prdRechercheRemise => 'Search a discount…';

  @override
  String get prdRecherchePack => 'Search a bundle…';

  @override
  String get prdEtiquette => 'Label';

  @override
  String get prdEtiquettes => 'Labels';

  @override
  String get prdAffecter => 'Assign';

  @override
  String get prdImporter => 'Import';

  @override
  String prdAchatMontant(String montant) {
    return 'Cost $montant';
  }

  @override
  String prdStockN(String quantite) {
    return 'Stock $quantite';
  }

  @override
  String prdMargeN(int n) {
    return 'Margin $n %';
  }

  @override
  String get prdStatut => 'Status';

  @override
  String get prdTypeTaux => 'Rate type';

  @override
  String get prdSeuilMontant => 'Basket threshold';

  @override
  String get prdPack => 'Bundle';

  @override
  String get prdComposants => 'Components';

  @override
  String get prdComposant => 'Component';

  @override
  String get prdValeurSeparee => 'Separate value';

  @override
  String get prdPrixPack => 'Bundle price';

  @override
  String get prdEconomie => 'Saving';

  @override
  String get prdDisponibles => 'Available';

  @override
  String get prdFormDescription =>
      'Quick: one page for the essentials. Detailed: 3 steps (photos, identification and prices · stock and packaging · variants and options). AI: record found from the barcode.';

  @override
  String get prdModeRapide => 'Quick';

  @override
  String get prdModeDetaille => 'Detailed · 3 steps';

  @override
  String get prdModeIa => 'AI';

  @override
  String get prdEtape1 => 'Photos, identification and prices';

  @override
  String get prdEtape1Desc => 'Photos, name, codes, margin';

  @override
  String get prdEtape2 => 'Stock and packaging';

  @override
  String get prdEtape2Desc => 'Store, threshold, box, carton';

  @override
  String get prdEtape3 => 'Variants and options';

  @override
  String get prdEtape3Desc => 'Sizes, colours, serials';

  @override
  String prdEtapeObligatoire(int n) {
    return 'Step $n / 3 · * required';
  }

  @override
  String get prdObligatoire => '* required';

  @override
  String get prdEnregistrerNouveau => 'Save and new';

  @override
  String get prdSuivant => 'Next';

  @override
  String get prdPrincipale => 'Main';

  @override
  String get prdPhotosFormat => 'JPG or PNG · 4 max';

  @override
  String get prdPhotosFin => 'the first one is the main photo';

  @override
  String get prdPhotosAide =>
      'The 1st photo shows at the till (product card and Quantity and pack dialog). JPG or PNG, 4 max.';

  @override
  String get prdIdentification => 'Identification';

  @override
  String get prdCodeAuto => 'Assigned on save';

  @override
  String get prdDesignationIndice => 'e.g. Elio oil 1 L';

  @override
  String get prdEanInvalide => 'Invalid EAN-13 check digit';

  @override
  String get prdScannerOuSaisir => 'Scan or type';

  @override
  String get prdGenererEan => 'Generate an EAN-13';

  @override
  String get prdFournisseur => 'Supplier';

  @override
  String get prdPrix => 'Prices';

  @override
  String get prdSousAchat => 'Below the cost price';

  @override
  String prdMargeUnitaire(String montant) {
    return 'Unit margin: $montant';
  }

  @override
  String get prdStockActuel => 'Current stock';

  @override
  String get prdStockInitial => 'Opening stock';

  @override
  String get prdStockAide => 'Change it through Purchases / Stock-outs';

  @override
  String get prdSeuilAlerte => 'Alert threshold';

  @override
  String get prdEmballages => 'Packaging';

  @override
  String get prdEmballagesAide =>
      'Packs offered at the till (Quantity and pack dialog): pieces per pack and pack price.';

  @override
  String get prdBoite => 'Box';

  @override
  String get prdCarton => 'Carton';

  @override
  String get prdPcs => 'pcs';

  @override
  String get prdVariantes => 'Variants';

  @override
  String get prdTypeTaille => 'Size type';

  @override
  String get prdTailles => 'Sizes';

  @override
  String get prdTaillesAide => 'Click the available sizes';

  @override
  String prdTaillesN(int n) {
    return '$n size(s) selected';
  }

  @override
  String get prdCouleurs => 'Colours';

  @override
  String get prdCouleursAide => '16 colours · several choices allowed';

  @override
  String get prdOptions => 'Options';

  @override
  String get prdCodesMultiples => 'Multiple codes';

  @override
  String get prdCodesMultiplesAide => 'Other barcodes recognised at the till for this product';

  @override
  String get prdAjouterCode => 'Add a code';

  @override
  String get prdSuiviSerie => 'Serial number tracking';

  @override
  String get prdSuiviSerieAide => 'Required at sale';

  @override
  String get prdServiceSansStock => 'Service (no stock)';

  @override
  String get prdServiceAide => 'Repair, delivery, labour';

  @override
  String get prdExpirationAide => 'Alert before expiry';

  @override
  String get prdNoteInterne => 'Internal note';

  @override
  String get prdToastEnregistre => 'Product saved';

  @override
  String get prdToastModifie => 'Product updated';

  @override
  String prdToastAjoute(String code) {
    return '$code · added to the catalogue';
  }

  @override
  String get prdModifierCategorie => 'Edit category';

  @override
  String get prdModifierSousCategorie => 'Edit subcategory';

  @override
  String get prdCategorieParente => 'Parent category';

  @override
  String get prdCategorieExiste => 'This category already exists';

  @override
  String get prdSousCategorieExiste => 'This subcategory already exists';

  @override
  String get prdCategorieIndice => 'e.g. Grocery';

  @override
  String get prdSousCategorieIndice => 'e.g. Oils';

  @override
  String get prdVisibleCaisse => 'Visible at the till';

  @override
  String get prdToastCategorie => 'Category saved';

  @override
  String get prdToastSousCategorie => 'Subcategory saved';

  @override
  String get prdInformations => 'Information';

  @override
  String prdNProduits(int n) {
    return '$n product(s)';
  }

  @override
  String prdNComposants(int n) {
    return '$n component(s)';
  }

  @override
  String get prdContientProduits => 'Contains products — reassign them first';

  @override
  String get prdDejaInactif => 'Already inactive';

  @override
  String get prdToastAnnulation => 'Cancellation done';

  @override
  String get prdPorteeProduit => 'Per product';

  @override
  String get prdPorteeMontant => 'By amount (basket)';

  @override
  String get prdProgrammee => 'Scheduled';

  @override
  String get prdModifierRemise => 'Edit discount';

  @override
  String get prdRemiseDescription => 'A discount applies automatically at the till during its period.';

  @override
  String get prdProduitsConcernes => 'Products concerned';

  @override
  String get prdRemiseAccordee => 'Discount granted';

  @override
  String get prdPrixNormal => 'Regular price';

  @override
  String get prdPrixRemise => 'Discounted price';

  @override
  String get prdRemiseNomIndice => 'e.g. End of line';

  @override
  String get prdPourcentageAide => 'e.g. −10 % off the price';

  @override
  String get prdMontantFixe => 'Fixed amount';

  @override
  String prdMontantFixeAide(String devise) {
    return 'e.g. −50 $devise per item';
  }

  @override
  String get prdCumulable => 'Stackable';

  @override
  String get prdAvecRemiseTicket => 'With the receipt discount';

  @override
  String get prdSeuilAide => 'The discount applies once the subtotal reaches this amount';

  @override
  String get prdParMontantAide =>
      '\"By amount\" discount: chosen on the basket at the till (Ctrl+R / F8), with no product list.';

  @override
  String get prdToastRemise => 'Discount saved';

  @override
  String get prdToastRemiseDesc => 'Applied at the till during its period';

  @override
  String get prdVentesRemisees => 'Discounted sales';

  @override
  String get prdModifierPack => 'Edit bundle';

  @override
  String get prdPackDescription => 'A bundle sells as a single item and destocks each component.';

  @override
  String get prdEnregistrerPack => 'Save bundle';

  @override
  String get prdComposantsPack => 'Bundle components';

  @override
  String get prdQteParPack => 'Qty / bundle';

  @override
  String get prdPrixUnitaire => 'Unit price';

  @override
  String get prdOptionnel => 'Optional';

  @override
  String get prdNomPack => 'Bundle name';

  @override
  String get prdPackNomIndice => 'e.g. Breakfast bundle';

  @override
  String get prdPacksPossibles => 'Possible bundles';

  @override
  String get prdPacksPossiblesAide => 'Based on the stock of the scarcest component';

  @override
  String get prdEconomieClient => 'Customer saving';

  @override
  String get prdPackPlusCher => 'The bundle costs more than its components';

  @override
  String prdValeurSepareeMontant(String montant) {
    return 'separate value $montant';
  }

  @override
  String get prdToastPack => 'Bundle saved';

  @override
  String get prdValeur => 'Value';

  @override
  String get prdStockTotal => 'Total stock';

  @override
  String get prdPrixMoyenAchat => 'Average cost';

  @override
  String get prdVendus30 => 'Sold (30 d)';

  @override
  String get prdStockParMagasin => 'Stock by store';

  @override
  String get prdDerniersMouvements => 'Latest movements';

  @override
  String get prdReference => 'Ref.';

  @override
  String get prdCodeBarreTitre => 'Barcode & labels';

  @override
  String get prdEanAide => 'Retail standard — prefix 613 (Algeria)';

  @override
  String get prdCodeInterne => 'Internal code';

  @override
  String get prdCodeInterneAide => 'For products without a manufacturer code';

  @override
  String get prdFormat => 'Format';

  @override
  String get prdFormatA4 => 'A4 · 3 × 8 (38 × 21 mm)';

  @override
  String get prdFormatRouleau40 => 'Roll 40 × 30 mm';

  @override
  String get prdFormatRouleau58 => 'Roll 58 mm';

  @override
  String prdImprimerEtiquettes(int n) {
    return 'Print $n label(s)';
  }

  @override
  String prdAffecterN(int n) {
    return 'Assign $n product(s)';
  }

  @override
  String get prdRemplacerAffectation => 'Replace the existing assignment';

  @override
  String get prdRemplacerPackAide => 'Otherwise the product is added to the bundle with quantity 1';

  @override
  String get prdRemplacerCategorieAide => 'Otherwise only products without a category change';

  @override
  String get prdRemplacerRemiseAide => 'Otherwise only products without a discount change';

  @override
  String get prdToastAffectation => 'Assignment saved';

  @override
  String prdToastAffectationDesc(int n, String nom) {
    return '$n product(s) · $nom';
  }

  @override
  String get prdSuppressionBloquee => 'Linked stock or movements — deactivate it instead';

  @override
  String prdToastSupprimes(int n) {
    return '$n product(s) deleted';
  }

  @override
  String prdToastRefuses(int n) {
    return '$n refused: linked movements';
  }

  @override
  String get prdImportFichier => 'File';

  @override
  String get prdImportFichierDesc => '.xlsx';

  @override
  String get prdImportColonnes => 'Columns';

  @override
  String get prdImportColonnesDesc => 'Mapping';

  @override
  String get prdImportApercuDesc => 'Check';

  @override
  String prdImportInfos(int n, int total) {
    return '$n column(s) · $total KB';
  }

  @override
  String get prdChangerFichier => 'Change file';

  @override
  String get prdTelechargerModele => 'Download the template';

  @override
  String prdColonneN(String lettre, String nom) {
    return 'Column $lettre · $nom';
  }

  @override
  String get prdIgnorer => '— Ignore —';

  @override
  String get prdImportDesignationRequise => 'Map a column to the name.';

  @override
  String get prdGenere => '— generated —';

  @override
  String get prdControle => 'Check';

  @override
  String prdImporterN(int n) {
    return 'Import $n product(s)';
  }

  @override
  String get prdImportTermine => 'Import complete';

  @override
  String get stkACommander => 'To order';

  @override
  String get stkAReapprovisionner => 'To restock';

  @override
  String get stkAdresse => 'Address';

  @override
  String get stkArticles => 'Items';

  @override
  String get stkAucun => 'None';

  @override
  String get stkAucunChangement => 'No change';

  @override
  String get stkAucunExpire => 'No expired or soon-to-expire products.';

  @override
  String get stkAucunTransfert => 'No transfers in this period.';

  @override
  String get stkAucuneListe => 'No needs lists in this period.';

  @override
  String get stkAucuneRupture => 'No product below threshold.';

  @override
  String get stkAucuneSortie => 'No stock exits in this period.';

  @override
  String get stkAudit => 'Audit';

  @override
  String get stkBloqueBesoinRecu => 'Already received';

  @override
  String get stkBloqueDejaAnnule => 'Already cancelled';

  @override
  String get stkBloqueDejaAnnulee => 'Already cancelled';

  @override
  String get stkBloqueDejaInactif => 'Already inactive';

  @override
  String get stkBloqueMagasinPrincipal => 'Main store of a user';

  @override
  String get stkBloqueStockNonNul => 'Stock not empty — transfer it first';

  @override
  String get stkCaisses => 'Registers';

  @override
  String get stkChoisirFournisseur => 'Choose a supplier';

  @override
  String get stkCreerListe => 'Create a needs list';

  @override
  String get stkDepuis => 'From';

  @override
  String get stkDesactiver => 'Deactivate';

  @override
  String get stkDescriptionBesoins => 'Restocking: supplier lists, shortages and expired products';

  @override
  String get stkDescriptionMagasins => 'Stock locations, transfers and assignments';

  @override
  String get stkDescriptionSorties => 'Non-sale stock exits: breakage, expired, loss, internal use, donation';

  @override
  String stkDescriptionStock(int n) {
    return 'Quantities by store · $n active stores';
  }

  @override
  String get stkDispoSource => 'Available at source';

  @override
  String stkDisponible(String quantite) {
    return 'Available: $quantite';
  }

  @override
  String get stkDisponibleEtat => 'Available';

  @override
  String get stkDistribuer => 'Distribute';

  @override
  String stkDistribuerDescription(String nom, String quantite) {
    return '$nom · $quantite pieces to split across stores';
  }

  @override
  String get stkDistribuerTitre => 'Distribute stock';

  @override
  String get stkEnStock => 'in stock';

  @override
  String get stkEnregistrerListe => 'Save list';

  @override
  String get stkEntiteListe => 'list';

  @override
  String get stkEntiteListes => 'lists';

  @override
  String get stkEntiteMagasin => 'store';

  @override
  String get stkEntiteMagasins => 'stores';

  @override
  String get stkEntiteMouvements => 'movements';

  @override
  String get stkEntiteSortie => 'exit';

  @override
  String get stkEntiteSorties => 'exits';

  @override
  String get stkEntiteTransfert => 'transfer';

  @override
  String get stkEntiteTransferts => 'transfers';

  @override
  String get stkErreurDocumentInconnu => 'Document not found.';

  @override
  String get stkErreurFournisseur => 'Choose a supplier.';

  @override
  String get stkErreurMotifObligatoire => 'A reason is required.';

  @override
  String get stkErreurNomPris => 'A store already has this name.';

  @override
  String get stkExpiration => 'Expiry';

  @override
  String stkExpireDepuis(int jours) {
    return 'Expired $jours d ago';
  }

  @override
  String stkJMoins(int jours) {
    return 'D−$jours';
  }

  @override
  String get stkJours => 'Days';

  @override
  String get stkKpiArticlesSortis => 'Items out';

  @override
  String get stkKpiCoutReassort => 'Estimated restock cost';

  @override
  String get stkKpiEnRupture => 'Out of stock';

  @override
  String get stkKpiMagasinsActifs => 'Active stores';

  @override
  String get stkKpiSorties => 'Exits in period';

  @override
  String get stkKpiSousSeuil => 'Below threshold';

  @override
  String get stkKpiUtilisateursRattaches => 'Assigned users';

  @override
  String get stkKpiValeurPerdue => 'Lost value';

  @override
  String get stkKpiValeurTotale => 'Total stock value';

  @override
  String get stkListeDescription =>
      'Suggested quantities = 2 × threshold − stock. Adjust before sending to the supplier.';

  @override
  String stkListeTitre(String code) {
    return 'List $code';
  }

  @override
  String get stkLivraison => 'Requested delivery';

  @override
  String get stkMagasin => 'Store';

  @override
  String get stkMagasinDescription => 'A store has its own stock; registers and users are attached to it.';

  @override
  String get stkMagasinDifferent => 'Choose a different store';

  @override
  String get stkModifierListe => 'Edit needs list';

  @override
  String get stkModifierMagasin => 'Edit store';

  @override
  String get stkModifierSortie => 'Edit exit';

  @override
  String get stkModifierTransfert => 'Edit transfer';

  @override
  String get stkMontantEstime => 'Estimated amount';

  @override
  String get stkMotif => 'Reason';

  @override
  String get stkMotifDistributionIndice => 'E.g. shop restock';

  @override
  String get stkMotifSortieIndice => 'E.g. carton dropped while shelving';

  @override
  String get stkMouvementsRecents => 'Recent movements';

  @override
  String get stkNom => 'Name';

  @override
  String get stkNomMagasinIndice => 'E.g. Hydra shop';

  @override
  String get stkNouveauMagasin => 'New store';

  @override
  String get stkNouveauTransfert => 'New transfer';

  @override
  String get stkNouvelleListe => 'New list';

  @override
  String get stkNouvelleSortie => 'New exit';

  @override
  String get stkObservationTransfertIndice => 'E.g. weekly restock';

  @override
  String get stkOngletExpires => 'Expired';

  @override
  String get stkOngletListes => 'Needs lists';

  @override
  String get stkOngletMagasins => 'Stores';

  @override
  String get stkOngletMouvements => 'Movements';

  @override
  String get stkOngletRuptures => 'Shortages & thresholds';

  @override
  String get stkOngletTransferts => 'Transfers';

  @override
  String get stkPalierAvance => 'Advanced tier';

  @override
  String get stkPcs => 'pcs';

  @override
  String get stkPdfFournisseur => 'Supplier PDF';

  @override
  String get stkPrincipal => 'Main';

  @override
  String get stkPrixEstime => 'Estimated price';

  @override
  String get stkProduitsEnStock => 'Products in stock';

  @override
  String get stkProduitsSortis => 'Products out';

  @override
  String get stkProduitsTransferes => 'Transferred products';

  @override
  String get stkQte => 'Qty';

  @override
  String get stkQuantiteTotale => 'Total quantity';

  @override
  String get stkRechercheMouvement => 'Ref. or product…';

  @override
  String get stkReference => 'Ref.';

  @override
  String get stkReparti => 'Allocated';

  @override
  String get stkRepartirEgalement => 'Split evenly';

  @override
  String get stkRepartition => 'Breakdown by store';

  @override
  String get stkResponsable => 'Manager';

  @override
  String get stkReste => 'Remaining';

  @override
  String get stkRestePrincipal => 'Rest to main';

  @override
  String get stkRetourFournisseur => 'Supplier return';

  @override
  String get stkSeuilAlerte => 'Alert threshold';

  @override
  String get stkSortieDescription => 'Non-sale stock exit — valued at purchase price.';

  @override
  String get stkSortiePerime => '\"Expired\" exit';

  @override
  String stkSortieTitre(String code) {
    return 'Exit $code';
  }

  @override
  String get stkSousSeuilEtat => 'Below threshold';

  @override
  String get stkStatut => 'Status';

  @override
  String stkStockDispo(String quantite) {
    return 'Stock: $quantite';
  }

  @override
  String get stkStockDuMagasin => 'Store stock';

  @override
  String get stkStockTotal => 'Total stock';

  @override
  String get stkSuggestion => 'Suggestion';

  @override
  String get stkTelephone => 'Phone';

  @override
  String get stkToastDistribue => 'Stock distributed';

  @override
  String get stkToastListe => 'List saved';

  @override
  String stkToastListeDesc(String code) {
    return '$code · ready to send';
  }

  @override
  String get stkToastListesAnnulees => 'Lists cancelled';

  @override
  String get stkToastMagasin => 'Store saved';

  @override
  String get stkToastMagasinsDesactives => 'Stores deactivated';

  @override
  String get stkToastSortie => 'Exit saved';

  @override
  String get stkToastSortiesAnnulees => 'Exits cancelled';

  @override
  String get stkToastStockAJour => 'Stock updated';

  @override
  String get stkToastStockReintegre => 'Stock was restored';

  @override
  String get stkToastTransfert => 'Transfer validated';

  @override
  String get stkToastTransfertsAnnules => 'Transfers cancelled';

  @override
  String get stkToutPrincipal => 'All to main';

  @override
  String stkTransfererPieces(String quantite) {
    return 'Transfer $quantite piece(s)';
  }

  @override
  String get stkTransfertDescription => 'Move stock from one store to another.';

  @override
  String stkTransfertTitre(String code) {
    return 'Transfer $code';
  }

  @override
  String get stkUtilisateurs => 'Users';

  @override
  String get stkUtilisateursCaisses => 'Users & registers';

  @override
  String get stkValeurAchat => 'Purchase value';

  @override
  String get stkValeurStock => 'Stock value';

  @override
  String get stkValeurVente => 'Sale value';

  @override
  String get stkValideLe => 'Validated on';

  @override
  String get stkValiderTransfert => 'Validate transfer';

  @override
  String get stkVers => 'To';

  @override
  String get stkVoirMouvements => 'View movements';

  @override
  String get stkVoirPiece => 'View document';

  @override
  String get entAucunBon => 'No receipt received.';

  @override
  String get entAucunFournisseur => 'None (cash purchase)';

  @override
  String get entAucunProduit => 'Scan or add the received products.';

  @override
  String get entBloqueDejaAnnulee => 'Already cancelled';

  @override
  String get entBloqueVendus => 'Some products have already been sold';

  @override
  String get entBonReception => 'Goods receipt';

  @override
  String get entChoisirProduit => 'Choose a product';

  @override
  String get entDescription => 'Supplier receipts — scanning, AI reading of delivery notes, quick entry';

  @override
  String get entEntite => 'Entry';

  @override
  String get entEntiteBon => 'receipt';

  @override
  String get entEntiteBons => 'receipts';

  @override
  String get entEntitePluriel => 'entries';

  @override
  String get entEntreeLiee => 'Linked entry';

  @override
  String get entErreurBonInconnu => 'Receipt not found.';

  @override
  String get entErreurBonTraite => 'Receipt already processed';

  @override
  String get entErreurMotif => 'A reason is required.';

  @override
  String get entEtapeBon => 'Receipt & supplier';

  @override
  String get entEtapeBonDetail => 'Header, payment';

  @override
  String get entEtapeProduits => 'Received products';

  @override
  String get entEtapeProduitsDetail => 'Scan and quantities';

  @override
  String get entFichier => 'File';

  @override
  String get entFournisseurDetecte => 'Detected supplier';

  @override
  String get entIaAnalyser => 'Analyse the receipt';

  @override
  String get entIaApercu => 'Receipt preview';

  @override
  String get entIaAucunFichier => 'No file chosen';

  @override
  String get entIaBandeauDetail => 'Receipts sent from the phone arrive here with the “Received” status.';

  @override
  String get entIaBandeauTitre => 'Photograph the receipt, AI fills in the entry';

  @override
  String get entIaConfiance => 'Confidence';

  @override
  String get entIaDepuisDisque => 'From disk';

  @override
  String get entIaDepuisTelephone => 'From the phone';

  @override
  String get entIaDescription =>
      'Photo or PDF of a supplier invoice: lines are detected then matched to the catalogue.';

  @override
  String get entIaDetecte => 'Detected on the receipt';

  @override
  String get entIaEtapeFournisseur => 'Supplier & payment';

  @override
  String get entIaEtapeFournisseurDetail => 'Confirm';

  @override
  String get entIaEtapeLignes => 'Detected lines';

  @override
  String get entIaEtapeLignesDetail => 'Check, match';

  @override
  String get entIaEtapePhoto => 'Receipt photo';

  @override
  String get entIaEtapePhotoDetail => 'Image or PDF';

  @override
  String get entIaFormats => 'JPG, PNG or PDF';

  @override
  String get entIaJoindre => 'Attach a receipt';

  @override
  String get entIaLecture => 'Reading the receipt…';

  @override
  String get entIaLectureDetail => 'Detecting lines, quantities and prices';

  @override
  String get entIaLignes => 'Lines';

  @override
  String get entIaLignesLues => 'Lines read';

  @override
  String get entIaLu => 'Read on the receipt';

  @override
  String get entIaProduitCatalogue => 'Catalogue product';

  @override
  String get entIaRapprocher => 'Match…';

  @override
  String get entIaRecuPar => 'Received by';

  @override
  String get entIaRemplacer => 'Replace the product';

  @override
  String get entIaTelephoneAide => 'Receipts sent from the mobile app appear in the AI mode queue.';

  @override
  String get entIaTitre => 'AI receipt · automatic reading';

  @override
  String get entIaTraitePar => 'Processed by';

  @override
  String get entIaTraiter => 'Process';

  @override
  String get entIaVideAide => 'Attach a receipt (photo or PDF) so AI prepares the entry.';

  @override
  String get entIaVoirBon => 'View receipt';

  @override
  String get entImprimer => 'Print';

  @override
  String get entInformations => 'Information';

  @override
  String get entKpiEntrees => 'Entries this month';

  @override
  String get entListe => 'List';

  @override
  String get entListeBesoins => 'Needs list';

  @override
  String get entMagasinAide => 'Default: your main store';

  @override
  String get entMajDernier => 'Latest purchase price';

  @override
  String get entMajGarder => 'Keep the current purchase price';

  @override
  String get entMajMoyen => 'Weighted average price';

  @override
  String get entMajPrix => 'Price update';

  @override
  String get entMode => 'Method';

  @override
  String get entModifierTitre => 'Edit entry';

  @override
  String get entMontantPaye => 'Amount paid';

  @override
  String get entNbVersements => 'No. of payments';

  @override
  String get entNouvelleDescription => 'Scan the received products: each scan adds 1 to the quantity.';

  @override
  String get entNouvelleTitre => 'New entry · Smart Scan';

  @override
  String get entNumFacture => 'Invoice / DN no.';

  @override
  String get entNumFactureIndice => 'E.g. FAC-24-1187';

  @override
  String get entOffreMessage => 'I would like to increase my Smart Scan quota.';

  @override
  String get entOngletIa => 'AI mode';

  @override
  String get entPaiement => 'Payment';

  @override
  String get entPaye => 'Paid';

  @override
  String get entPayeTotalite => 'Paid in full';

  @override
  String get entProduitsRecus => 'Received products';

  @override
  String get entQteRecue => 'Qty received';

  @override
  String get entRapideDescription => 'Receipt of a single product, without a detailed supplier note.';

  @override
  String get entRapideTitre => 'Quick entry';

  @override
  String get entRecherche => 'Code, supplier or invoice no.…';

  @override
  String get entRechercheBons => 'File or supplier…';

  @override
  String get entRecuLe => 'Received on';

  @override
  String get entRepartitionIncomplete => 'Incomplete split';

  @override
  String get entRepartitionOption => 'Split (optional)';

  @override
  String get entResteAide => 'Added to the supplier\'s credit';

  @override
  String get entResteCredit => 'Remaining (credit)';

  @override
  String get entRetour => 'Back';

  @override
  String get entScanAjoute => 'added';

  @override
  String get entScanIndice => 'Scan a barcode then Enter (or product code)…';

  @override
  String get entSourceIa => 'AI receipt';

  @override
  String get entSourceRapide => 'Quick entry';

  @override
  String get entSuivant => 'Next';

  @override
  String get entToastAnnulees => 'Entries cancelled';

  @override
  String get entToastAnnuleesDetail => 'Stock and supplier credit corrected';

  @override
  String get entToastBonsSupprimes => 'Receipts deleted';

  @override
  String get entToastDepuisBon => 'Entry created from the receipt';

  @override
  String get entToastEnregistree => 'Entry saved';

  @override
  String get entToastModifiee => 'Entry updated';

  @override
  String get entToastRapide => 'Quick entry saved';

  @override
  String get entToastReparti => 'Stock split between stores';

  @override
  String get entVenteSousAchat => 'Sale price ≤ purchase price';

  @override
  String entCreerProduit(String nom) {
    return '+ Create “$nom”';
  }

  @override
  String entDepuisListe(String code) {
    return 'Receipt of needs list $code';
  }

  @override
  String entDetailTitre(String code) {
    return 'Entry $code';
  }

  @override
  String entIaARapprocher(int n) {
    return '$n line(s) to match';
  }

  @override
  String entIaCreer(String montant) {
    return 'Create entry · $montant';
  }

  @override
  String entValider(String montant) {
    return 'Confirm entry · $montant';
  }

  @override
  String entRapideDescriptionProduit(String code, String stock) {
    return '$code · current stock $stock pcs — receipt without a detailed note.';
  }

  @override
  String entRapideTitreProduit(String nom) {
    return 'Quick entry · $nom';
  }

  @override
  String entScanInconnu(String code) {
    return 'Unknown code: $code';
  }

  @override
  String entToastBonsDetail(int n) {
    return '$n file(s)';
  }

  @override
  String get entCreerEntree => 'Create the entry';

  @override
  String get statutErreur => 'Error';

  @override
  String get gcDescription => 'Registers, transfers, Z reports, movements and sessions';

  @override
  String get gcOngletCaisses => 'Registers';

  @override
  String get gcOngletTransferts => 'Transfers';

  @override
  String get gcOngletClotures => 'Z reports';

  @override
  String get gcOngletMouvements => 'Movements';

  @override
  String get gcOngletSessions => 'Sessions';

  @override
  String get gcEntiteCaisse => 'register';

  @override
  String get gcEntiteCaisses => 'registers';

  @override
  String get gcEntiteTransfert => 'transfer';

  @override
  String get gcEntiteTransferts => 'transfers';

  @override
  String get gcEntiteClotures => 'Z reports';

  @override
  String get gcEntiteMouvements => 'movements';

  @override
  String get gcEntiteSessions => 'sessions';

  @override
  String get gcColCaisse => 'Register';

  @override
  String get gcColSoldeInitial => 'Opening balance';

  @override
  String get gcColSoldeActuel => 'Current balance';

  @override
  String get gcColSession => 'Session';

  @override
  String get gcColEtat => 'Status';

  @override
  String get gcColStatut => 'Status';

  @override
  String get gcColDepuis => 'From';

  @override
  String get gcColVers => 'To';

  @override
  String get gcColTickets => 'Tickets';

  @override
  String get gcColAnnules => 'Cancelled';

  @override
  String get gcColTotalAnnule => 'Cancelled amount';

  @override
  String get gcColPar => 'By';

  @override
  String get gcColEmpreinte => 'Fingerprint';

  @override
  String get gcColCreeLe => 'Created on';

  @override
  String get gcColReference => 'Ref.';

  @override
  String get gcColEntree => 'In';

  @override
  String get gcColSortie => 'Out';

  @override
  String get gcColUtilisateur => 'User';

  @override
  String get gcColMode => 'Method';

  @override
  String get gcColOuverture => 'Opened';

  @override
  String get gcColCloture => 'Closed';

  @override
  String get gcColFond => 'Float';

  @override
  String get gcColTheorique => 'Expected';

  @override
  String get gcColReel => 'Counted';

  @override
  String get gcColEcart => 'Variance';

  @override
  String get gcColOuvertePar => 'Opened by';

  @override
  String get gcToutesCaisses => 'All registers';

  @override
  String get gcRechercheCaisses => 'Search a register…';

  @override
  String get gcRechercheTransferts => 'Search a transfer…';

  @override
  String get gcRechercheClotures => 'Search a Z report…';

  @override
  String get gcRechercheMouvements => 'Search a movement…';

  @override
  String get gcRechercheSessions => 'Search a session…';

  @override
  String get gcAucuneSession => 'No sessions.';

  @override
  String get gcExportFiscal => 'Tax audit export';

  @override
  String get gcNouvelleClotureZ => 'New Z report';

  @override
  String get gcMouvementManuel => 'Manual movement';

  @override
  String get gcVoirMouvements => 'View movements';

  @override
  String get gcCloturer => 'Close';

  @override
  String get gcOuvrirSession => 'Open a session';

  @override
  String get gcFormDescription => 'Each register (drawer, safe) has its own balance and sessions.';

  @override
  String get gcFormNomIndice => 'E.g. Register 3';

  @override
  String get gcFormSoldeInitialAide => 'Suggested as the float at each opening';

  @override
  String get gcCaisseEnregistree => 'Register saved';

  @override
  String get gcSessions30j => 'Sessions (30 d)';

  @override
  String get gcEcartCumule => 'Cumulative variance';

  @override
  String get gcDernieresSessions => 'Latest sessions';

  @override
  String get gcBloqueSession => 'Open session — close it first';

  @override
  String get gcBloqueSolde => 'Non-zero balance — transfer it first';

  @override
  String get gcBloqueSysteme => 'Main register';

  @override
  String get gcBloqueInactive => 'Already inactive';

  @override
  String get gcErreurSoldeNonNul => 'The register balance must be zero: transfer it first.';

  @override
  String get gcToastDesactivees => 'Registers deactivated';

  @override
  String get gcTrfTitre => 'Transfer between registers';

  @override
  String get gcTrfDescription => 'E.g. moving the day\'s takings to the safe at closing.';

  @override
  String gcTrfDisponible(String montant) {
    return 'Available balance: $montant';
  }

  @override
  String get gcTrfMemeCaisse => 'Choose a different register';

  @override
  String gcTrfSuperieur(String caisse) {
    return 'Exceeds the balance of $caisse';
  }

  @override
  String get gcTrfMotifIndice => 'E.g. takings deposit';

  @override
  String gcTrfValider(String montant) {
    return 'Transfer $montant';
  }

  @override
  String get gcToastTransfert => 'Transfer recorded';

  @override
  String get gcToastTransfertsAnnules => 'Transfers cancelled';

  @override
  String get gcToastSoldesRetablis => 'Balances restored';

  @override
  String get gcBloqueDejaAnnule => 'Already cancelled';

  @override
  String get gcErreurDejaAnnule => 'This transfer is already cancelled.';

  @override
  String get gcErreurTransfertInconnu => 'Transfer not found.';

  @override
  String get gcErreurPeriodeCloturee => 'This date falls in a closed period.';

  @override
  String get gcZDescription => 'Frozen report for the period: once created it can be neither edited nor deleted.';

  @override
  String gcZPeriodeValeur(String debut) {
    return '$debut → now';
  }

  @override
  String gcZDepuisDerniere(String code) {
    return 'Since the last Z report ($code)';
  }

  @override
  String get gcZPremiere => 'First Z report for this register';

  @override
  String get gcZTicketsAnnules => 'Cancelled tickets';

  @override
  String get gcZTotalAnnule => 'Total cancelled';

  @override
  String get gcZMoyen => 'Payment method';

  @override
  String get gcZPart => 'Share';

  @override
  String gcZChainee(String code) {
    return 'Chained to $code · previous fingerprint';
  }

  @override
  String get gcZGenese => 'Start of this register\'s chain · genesis fingerprint';

  @override
  String get gcZConfirmer => 'I confirm the totals: the report will be final and signed.';

  @override
  String gcZCreer(String code) {
    return 'Create report $code';
  }

  @override
  String gcZCreee(String code) {
    return 'Report $code created';
  }

  @override
  String get gcZCreeeDetail => 'Signed and chained report';

  @override
  String get gcZAucunPaiement => 'No payments in this period.';

  @override
  String gcZDetailTitre(String code) {
    return 'Z report $code';
  }

  @override
  String gcZDetailDescription(String au, String caisse, String du, String par) {
    return '$caisse · $du → $au · by $par';
  }

  @override
  String get gcZDefinitive => 'Final';

  @override
  String get gcZEmpreinteValide => 'Valid fingerprint';

  @override
  String get gcZEmpreinteAlteree => 'Altered fingerprint';

  @override
  String get gcZRepartition => 'Payment breakdown';

  @override
  String get gcZIntegrite => 'Integrity';

  @override
  String get gcZEmpreintePrecedente => 'Previous fingerprint';

  @override
  String get gcZTotaux => 'Period totals';

  @override
  String get gcZSoldeFin => 'Closing balance';

  @override
  String get gcFiscalTitre => 'Export for tax audit';

  @override
  String get gcFiscalDescription =>
      'Archive of the period\'s Z reports and tickets, with the verified fingerprint chain.';

  @override
  String get gcFiscalZip => 'Full archive';

  @override
  String get gcFiscalZipDesc => 'Audit JSON + CSV + fingerprints (.zip)';

  @override
  String get gcFiscalJson => 'Audit JSON';

  @override
  String get gcFiscalJsonDesc => 'Verifiable chain (§12.3)';

  @override
  String get gcFiscalPdf => 'PDF report';

  @override
  String get gcFiscalPdfDesc => 'Z reports only';

  @override
  String get gcFiscalCsv => 'CSV';

  @override
  String get gcFiscalCsvDesc => 'Tickets line by line';

  @override
  String gcFiscalChaineOk(int n) {
    return 'Fingerprint chain intact · $n reports, no break';
  }

  @override
  String gcFiscalChaineKo(String code) {
    return 'Chain broken at report $code';
  }

  @override
  String get gcFiscalGenere => 'Archive generated';

  @override
  String gcSesMvtTitre(String code) {
    return 'Movements · $code';
  }

  @override
  String gcSesMvtOuverte(String caisse, String ouverture) {
    return '$caisse · opened $ouverture';
  }

  @override
  String gcSesMvtCloturee(String caisse, String cloture, String ouverture) {
    return '$caisse · opened $ouverture · closed $cloture';
  }

  @override
  String get gcEntrees => 'In';

  @override
  String get gcSorties => 'Out';

  @override
  String get gcSolde => 'Balance';

  @override
  String get permVoirMarge => 'View margin / margin rate';

  @override
  String get permModifierPrixVente => 'Change the selling price';

  @override
  String get permAnnulerOperations => 'Cancel operations';

  @override
  String get permChangerCaisseMagasin => 'Change own till / store';

  @override
  String get permGererTransfertsCaisse => 'Manage transfers between tills';

  @override
  String get permVoirStockTousMagasins => 'View stock of all stores';

  @override
  String get usrDescription => 'Accounts, roles and permissions';

  @override
  String get usrOngletUtilisateurs => 'Users';

  @override
  String get usrOngletRoles => 'Roles';

  @override
  String get usrEntiteUtilisateurs => 'users';

  @override
  String get usrEntiteUtilisateur => 'user';

  @override
  String get usrEntiteRoles => 'roles';

  @override
  String get usrEntiteRole => 'role';

  @override
  String get usrKpiActifs => 'Active users';

  @override
  String get usrKpiVentes => 'Sales (30 d)';

  @override
  String get usrKpiTotal => 'Total sold';

  @override
  String get usrRole => 'Role';

  @override
  String get usrEtat => 'Status';

  @override
  String get usrActif => 'Active';

  @override
  String get usrInactif => 'Inactive';

  @override
  String get usrRecherche => 'Name, username or phone…';

  @override
  String get usrColUtilisateur => 'User';

  @override
  String get usrColCaisse => 'Till';

  @override
  String get usrColMagasins => 'Stores';

  @override
  String get usrColVentes => 'Sales';

  @override
  String get usrColDernierAcces => 'Last access';

  @override
  String get usrTelephone => 'Phone';

  @override
  String get usrLibre => 'Free';

  @override
  String get usrReinitialiser => 'Reset password';

  @override
  String get usrDesactiver => 'Deactivate';

  @override
  String get usrNouvel => 'New user';

  @override
  String get usrModifierTitre => 'Edit user';

  @override
  String get usrFormDescription => 'The role sets the visible modules; the attached till locks the Till screen.';

  @override
  String get usrSectionCompte => 'Account';

  @override
  String get usrSectionAcces => 'Access';

  @override
  String get usrCode => 'Code';

  @override
  String get usrIdentifiant => 'Username';

  @override
  String get usrIdentifiantIndice => 'e.g. amina';

  @override
  String get usrIdentifiantPris => 'Username already taken';

  @override
  String get usrIdentifiantInvalide => '3 to 32 characters: letters, digits, . _ -';

  @override
  String get usrMotDePasse => 'Password';

  @override
  String get usrNouveauMotDePasse => 'New password';

  @override
  String get usrMdpIndice => '8 characters minimum';

  @override
  String get usrMdpVide => 'Leave empty to keep it';

  @override
  String get usrForce0 => 'Very weak';

  @override
  String get usrForce1 => 'Weak';

  @override
  String get usrForce2 => 'Fair';

  @override
  String get usrForce3 => 'Good';

  @override
  String get usrForce4 => 'Strong';

  @override
  String get usrPrenom => 'First name';

  @override
  String get usrNom => 'Last name';

  @override
  String get usrTelephoneIndice => '05xx xx xx xx';

  @override
  String get usrAdminRole => 'Full access, cannot be restricted';

  @override
  String usrNbPermissions(int n) {
    return '$n permissions';
  }

  @override
  String get usrCaisseAttachee => 'Attached till';

  @override
  String get usrCaisseAdmin => 'The admin picks any till';

  @override
  String get usrCaisseIndice => 'Locks the till on the Till screen';

  @override
  String get usrAucune => 'None';

  @override
  String get usrMagasinsIndice => 'The first one is the default store at login';

  @override
  String get usrObservation => 'Note';

  @override
  String get usrCree => 'User created';

  @override
  String get usrModifie => 'User updated';

  @override
  String get usrErrTelephone => 'Phone is required';

  @override
  String get usrErrMotDePasse => 'Password too weak';

  @override
  String get usrErrRole => 'Role cannot be assigned';

  @override
  String get usrErrMagasins => 'Pick at least one store';

  @override
  String get usrErrInconnu => 'User not found';

  @override
  String get usrInfos => 'General information';

  @override
  String get usrPermissionsRole => 'Role permissions';

  @override
  String get usrAudit => 'Audit';

  @override
  String get usrCreePar => 'Created by';

  @override
  String get usrCreeLe => 'Created on';

  @override
  String get usrModifiePar => 'Updated by';

  @override
  String get usrModifieLe => 'Updated on';

  @override
  String get usrLibreAdmin => 'Free (admin)';

  @override
  String get usrDefaut => '(default)';

  @override
  String get usrMdpReinitTitre => 'Password reset';

  @override
  String usrMdpReinitMessage(String identifiant, String mdp) {
    return 'Give this temporary password to @$identifiant: $mdp. They can change it in My account.';
  }

  @override
  String get usrBloqueAdmin => 'Main administrator account';

  @override
  String get usrBloqueCourant => 'Your own account';

  @override
  String get usrBloqueInactif => 'Already inactive';

  @override
  String get usrDesactives => 'Users deactivated';

  @override
  String get usrDesactivesDetail => 'They can no longer sign in';

  @override
  String get usrColModules => 'Modules';

  @override
  String get usrColSpeciales => 'Special';

  @override
  String get usrTous => 'All';

  @override
  String get usrToutes => 'All';

  @override
  String get usrSysteme => 'System';

  @override
  String get usrDupliquer => 'Duplicate';

  @override
  String get usrNouveauRole => 'New role';

  @override
  String get usrModifierRole => 'Edit role';

  @override
  String get usrRoleDescription => 'Details, accessible modules, then sensitive actions.';

  @override
  String usrRoleConcernes(String code, int n) {
    return '$code · $n user(s) affected';
  }

  @override
  String get usrPrecedent => 'Back';

  @override
  String get usrSuivant => 'Next';

  @override
  String get usrEnregistrerRole => 'Save role';

  @override
  String get usrEtapeInfos => 'Details';

  @override
  String get usrEtapeInfosDesc => 'Name, status';

  @override
  String get usrEtapePermissions => 'Permissions';

  @override
  String usrEtapeModules(int n) {
    return '$n modules';
  }

  @override
  String get usrEtapeSpeciales => 'Special permissions';

  @override
  String get usrEtapeSpecialesDesc => 'Sensitive actions';

  @override
  String get usrNomRole => 'Role name';

  @override
  String get usrNomRoleIndice => 'e.g. Senior cashier';

  @override
  String get usrNomRolePris => 'This role name already exists';

  @override
  String get usrObsRoleIndice => 'What is this role for?';

  @override
  String get usrModulesTitre => 'Accessible modules';

  @override
  String get usrModulesDesc =>
      'The role only sees the checked modules in the sidebar and menu. Settings and History are granted like any other module.';

  @override
  String get usrSpecialesDesc =>
      'Cross-cutting actions, checked in every module (purchase prices, cancellations, till change…).';

  @override
  String get usrConfirmRoleTitre => 'Edit this role?';

  @override
  String usrConfirmRoleMessage(int n) {
    return '$n user(s) will see their access change at next sign-in.';
  }

  @override
  String get usrRoleEnregistre => 'Role saved';

  @override
  String get usrRoleEnregistreDetail => 'Permissions applied';

  @override
  String usrRoleTitre(String nom) {
    return 'Role $nom';
  }

  @override
  String get usrAdminBloqueTitre => 'Cannot edit';

  @override
  String get usrAdminBloqueMessage => 'The Admin role is a system role: its permissions cannot be changed.';

  @override
  String get usrRoleBloqueSysteme => 'Admin system role';

  @override
  String get usrRoleBloqueUtilisateurs => 'Users have this role: reassign them';

  @override
  String get usrRolesDesactives => 'Roles deactivated';

  @override
  String usrNbUtilisateurs(int n) {
    return '$n user(s)';
  }

  @override
  String usrCopie(String nom) {
    return '$nom (copy)';
  }

  @override
  String get usrRoleErrModules => 'Check at least one module';

  @override
  String get usrRoleErrInconnu => 'Role not found';

  @override
  String get usrAucunUtilisateur => 'No users.';

  @override
  String get usrAucunRole => 'No roles.';

  @override
  String get zkDescription => 'Yearly calculation on stock, cash and receivables';

  @override
  String get zkEntite => 'calculations';

  @override
  String get zkEntiteUn => 'calculation';

  @override
  String zkKpiCapital(int annee) {
    return 'Capital $annee (provisional)';
  }

  @override
  String get zkKpiNissab => 'Current nissab';

  @override
  String zkKpiEstimee(int annee) {
    return 'Estimated zakat $annee';
  }

  @override
  String get zkKpiEcheance => 'Due in';

  @override
  String get zkJours => 'days';

  @override
  String get zkColCode => 'Code';

  @override
  String get zkColAnnee => 'Year';

  @override
  String get zkColCapital => 'Capital';

  @override
  String get zkColNissab => 'Nissab';

  @override
  String get zkColObligatoire => 'Due';

  @override
  String get zkOui => 'Yes';

  @override
  String get zkNon => 'No';

  @override
  String get zkColZakat => 'Zakat';

  @override
  String get zkColDue => 'Due on';

  @override
  String get zkColPayee => 'Paid on';

  @override
  String get zkColStatut => 'Status';

  @override
  String get zkColStock => 'Stock';

  @override
  String get zkColLiquidites => 'Cash';

  @override
  String get zkColCreances => 'Receivables';

  @override
  String get zkColDettes => 'Debts';

  @override
  String get zkColTaux => 'Rate';

  @override
  String get zkColHawl => 'Hawl start';

  @override
  String get zkColObservation => 'Note';

  @override
  String get zkColCreePar => 'Created by';

  @override
  String get zkExoneree => 'Exempt';

  @override
  String get zkAnnulee => 'Cancelled';

  @override
  String get zkMarquerPayee => 'Mark as paid';

  @override
  String get zkAnnuler => 'Cancel';

  @override
  String get zkNouveau => 'New calculation';

  @override
  String get zkNouveauTitre => 'New zakat calculation';

  @override
  String get zkModifierTitre => 'Edit zakat';

  @override
  String get zkFormDescription => 'Amounts are prefilled from stock, tills and credits; adjust them if needed.';

  @override
  String get zkSectionPeriode => 'Period (hawl)';

  @override
  String get zkSectionPatrimoine => 'Assets';

  @override
  String get zkDebutHawl => 'Hawl start';

  @override
  String get zkDueLe => 'Zakat due on';

  @override
  String get zkDueIndice => 'Start + 354 days (lunar year)';

  @override
  String get zkValeurStock => 'Stock value';

  @override
  String get zkStockIndice => 'At purchase price';

  @override
  String get zkLiquiditesIndice => 'Tills + bank';

  @override
  String get zkCreancesIndice => 'Recoverable customer credit';

  @override
  String get zkDettesCourt => 'Short-term debts';

  @override
  String get zkDettesIndice => 'Supplier credit';

  @override
  String get zkNissabIndice => '85 g of gold × today\'s price';

  @override
  String zkReprendre(String libelle) {
    return 'Reload: $libelle';
  }

  @override
  String get zkRepValeurStock => 'stock value';

  @override
  String get zkRepSoldes => 'till balances';

  @override
  String get zkRepCreances => 'customer credit';

  @override
  String get zkRepDettes => 'supplier credit';

  @override
  String get zkCapitalSoumis => 'Taxable capital';

  @override
  String get zkAuDessus => 'Above nissab';

  @override
  String get zkEnDessous => 'Below nissab';

  @override
  String get zkObligatoire => 'Zakat due';

  @override
  String get zkMontant => 'Zakat amount';

  @override
  String zkFormule(String taux) {
    return 'Capital = stock + cash + receivables − debts. Amount = capital × $taux % if capital ≥ nissab.';
  }

  @override
  String get zkEnregistre => 'Calculation saved';

  @override
  String get zkPayeeToast => 'Zakat marked as paid';

  @override
  String get zkAnnules => 'Calculations cancelled';

  @override
  String zkDetailTitre(int annee) {
    return 'Zakat $annee';
  }

  @override
  String zkDetailDescription(String code, String debut, String fin) {
    return '$code · hawl $debut → $fin';
  }

  @override
  String get zkCalcul => 'Calculation';

  @override
  String get zkPoste => 'Item';

  @override
  String get zkMontantCol => 'Amount';

  @override
  String get zkAudit => 'Audit';

  @override
  String get zkMotif => 'Reason';

  @override
  String get zkBloqueePayee => 'Already paid';

  @override
  String get zkBloqueeAnnulee => 'Already cancelled';

  @override
  String get zkErrValeur => 'Invalid values (positive amounts, due date after hawl start)';

  @override
  String get zkErrInconnue => 'Calculation not found';

  @override
  String get zkErrMotif => 'Reason required';

  @override
  String get zkAucun => 'No zakat calculation.';

  @override
  String get hiDescription => 'Log of every action · access by role';

  @override
  String get hiEntite => 'actions';

  @override
  String get hiKpiActions => 'Actions (7 d)';

  @override
  String get hiKpiCreations => 'Creations';

  @override
  String get hiKpiModifications => 'Changes';

  @override
  String get hiKpiAnnulations => 'Cancellations';

  @override
  String get hiModule => 'Module';

  @override
  String get hiAction => 'Action';

  @override
  String get hiUtilisateur => 'User';

  @override
  String get hiPoste => 'Workstation';

  @override
  String get hiTous => 'All';

  @override
  String get hiToutes => 'All';

  @override
  String get hiRecherche => 'Ref. or description…';

  @override
  String get hiColDate => 'Date';

  @override
  String get hiColRef => 'Ref.';

  @override
  String get hiColDescription => 'Description';

  @override
  String get hiColCode => 'Code';

  @override
  String get hiAucun => 'No action in this period.';

  @override
  String get hiDetail => 'Details';

  @override
  String get hiSectionAction => 'Action';

  @override
  String get hiSectionContexte => 'Context';

  @override
  String get hiReference => 'Reference';

  @override
  String get hiEntiteTechnique => 'Entity';

  @override
  String get hiModuleConnexion => 'Sign-in';

  @override
  String get hiCatCreation => 'Creation';

  @override
  String get hiCatModification => 'Change';

  @override
  String get hiCatAnnulation => 'Cancellation';

  @override
  String get hiCatConnexion => 'Session';

  @override
  String get hiCatExport => 'Export';

  @override
  String get hiActCreation => 'Creation';

  @override
  String get hiActModification => 'Change';

  @override
  String get hiActAnnulation => 'Cancellation';

  @override
  String get hiActDesactivation => 'Deactivation';

  @override
  String get hiActActivation => 'Activation';

  @override
  String get hiActSuppression => 'Deletion';

  @override
  String get hiActVersement => 'Payment';

  @override
  String get hiActTransfert => 'Transfer';

  @override
  String get hiActReinitialisation => 'Password reset';

  @override
  String get hiActRetour => 'Return';

  @override
  String get hiActParametres => 'Settings';

  @override
  String get hiActOuverture => 'Opening';

  @override
  String get hiActFermeture => 'Closing';

  @override
  String get hiActEncaissement => 'Checkout';

  @override
  String get hiActConnexion => 'Sign-in';

  @override
  String get hiActDeconnexion => 'Sign-out';

  @override
  String get hiActConfiguration => 'Initial setup';

  @override
  String get hiActClotureZ => 'Z closing';

  @override
  String get hiActAffectation => 'Assignment';

  @override
  String get hiActAchat => 'Purchase';

  @override
  String get hiActApport => 'Cash in';

  @override
  String get hiActDepense => 'Expense';

  @override
  String get hiActPaiement => 'Payment';

  @override
  String get hiActExport => 'Export';
}
