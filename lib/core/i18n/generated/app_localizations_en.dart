// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get shellNavGeneral => 'General';

  @override
  String get shellNavStock => 'Stock';

  @override
  String get shellNavTiers => 'Partners';

  @override
  String get shellNavGestion => 'Management';

  @override
  String get shellMenuModules => 'Modules';

  @override
  String get shellFenetreReduire => 'Minimise';

  @override
  String get shellFenetreAgrandir => 'Maximise';

  @override
  String get shellFenetreRestaurer => 'Restore';

  @override
  String get shellFenetreFermer => 'Close';

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
  String get communAucunResultat => 'No results';

  @override
  String get communTotal => 'Total';

  @override
  String get communToutSelectionner => 'Select all';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin of $total';
  }

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
  String get activationErreurInconnue => 'Invalid key for this computer — check the identifier you sent.';

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
  String get licenceRequiseDetail =>
      'Your current licence is Basic. Activate an Advanced licence to access this module.';

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
  String get configEtapeBoutique => 'Shop';

  @override
  String get configEtapeVente => 'Margin and stock';

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
  String get compteTitre => 'My account';

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
  String get permVoirPrixAchat => 'View purchase price';

  @override
  String get shellBandeauDemo => 'Demo mode — data is not meant for production';

  @override
  String get shellVerrouille => 'Advanced licence only';

  @override
  String get shellAccesRestreint => 'Access denied';

  @override
  String get produitsOngletProduits => 'Products';

  @override
  String get produitsOngletCategories => 'Categories';

  @override
  String get produitsOngletPacks => 'Bundles';

  @override
  String get produitsOngletRemises => 'Discounts';

  @override
  String get produitsNouveau => 'New product';

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
  String get produitsColPrixVente => 'Selling price excl. VAT';

  @override
  String get produitsColStock => 'Stock';

  @override
  String get produitsAucun => 'No products. Create one or import an Excel file.';

  @override
  String get produitModifier => 'Edit product';

  @override
  String get produitChampSousCategorie => 'Sub-category';

  @override
  String get produitChampPrixAchat => 'Purchase price';

  @override
  String get produitChampPrixVente => 'Selling price excl. VAT';

  @override
  String get produitChampUnite => 'Unit';

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
  String get iaIntro => 'Scan a barcode: the product sheet is found automatically.';

  @override
  String get iaRechercher => 'Search';

  @override
  String get iaAucun => 'No product sheet found.';

  @override
  String iaTrouve(String source) {
    return 'Sheet found via $source';
  }

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
  String synchroResultat(int envoyes, int recus) {
    return 'Sync: $envoyes sent, $recus updated.';
  }

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
  String get categorieErreurSysteme => 'The system category cannot be changed.';

  @override
  String get categorieErreurUtilisee => 'Products are attached to this category.';

  @override
  String get packNouveau => 'New bundle';

  @override
  String get packErreurLignes => 'Add at least one product to the bundle.';

  @override
  String get remiseNouvelle => 'New discount';

  @override
  String get remiseType => 'Type';

  @override
  String get remiseValeur => 'Value';

  @override
  String get communNouveau => 'New';

  @override
  String get communModifier => 'Edit';

  @override
  String get communActif => 'Active';

  @override
  String get communOui => 'Yes';

  @override
  String get communNon => 'No';

  @override
  String get communValider => 'Confirm';

  @override
  String get communApercu => 'Preview';

  @override
  String get communAucune => 'None';

  @override
  String get stockTitre => 'Stock';

  @override
  String get stockColMagasin => 'Store';

  @override
  String get stockColQuantite => 'Quantity';

  @override
  String get stockColSeuil => 'Threshold';

  @override
  String get stockColType => 'Type';

  @override
  String get stockColMotif => 'Reason';

  @override
  String get stockColUtilisateur => 'User';

  @override
  String get stockColValeur => 'Value (cost)';

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
  String get magasinPrincipal => 'Main';

  @override
  String get statutBesoinEnAttente => 'Pending';

  @override
  String get statutBesoinCommande => 'Ordered';

  @override
  String get statutBesoinDisponible => 'Available';

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
  String get ventesAucune => 'No sales.';

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
  String get retourErreurQuantite => 'Invalid quantity.';

  @override
  String get retourErreurDepasse => 'Quantity exceeds the sold quantity (including previous returns).';

  @override
  String get retourErreurPeriode => 'Closed period: return not possible.';

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
  String get fournisseurNouveau => 'New supplier';

  @override
  String get versementNouveau => 'New payment';

  @override
  String get versementMontant => 'Amount';

  @override
  String get versementMode => 'Method';

  @override
  String versementVerrouille(String retour) {
    return 'Locked (linked to return $retour)';
  }

  @override
  String get versementImputations => 'Allocations (oldest first)';

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
  String get tiersErreurNom => 'Name is required.';

  @override
  String get tiersErreurSysteme => 'The system party cannot be changed.';

  @override
  String get achatNouveau => 'New receipt';

  @override
  String get achatFournisseur => 'Supplier';

  @override
  String get achatAucun => 'No receipts.';

  @override
  String get achatColVerse => 'Paid';

  @override
  String get achatColReste => 'Due';

  @override
  String get achatColSource => 'Source';

  @override
  String get achatColStatut => 'Status';

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
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanAucuneLigne => 'No line recognised.';

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
  String get caisseActive => 'Active';

  @override
  String get caisseInactive => 'Inactive';

  @override
  String get caisseTypePhysique => 'Physical';

  @override
  String get caisseTypeCompte => 'Account';

  @override
  String get caisseAucune => 'No register.';

  @override
  String get caisseDesactiver => 'Deactivate';

  @override
  String get mouvementColMontant => 'Amount';

  @override
  String get mouvementAucun => 'No movement.';

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
  String get transfertCaisseNouveau => 'New transfer';

  @override
  String get transfertCaisseAucun => 'No transfer.';

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
  String get cloturePeriode => 'Period';

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
  String get clotureAucune => 'No closure.';

  @override
  String get clotureDerniereVente => 'Last receipt';

  @override
  String get clotureErreurRien => 'Nothing to close since the last closure.';

  @override
  String get exportFiscalGenerer => 'Generate archive';

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
  String get tableauBordTopProduits => 'Top 5 products (30 days)';

  @override
  String get situationExportExcel => 'Export to Excel';

  @override
  String get situationApercuPdf => 'PDF preview';

  @override
  String situationExportOk(String chemin) {
    return 'File saved: $chemin';
  }

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
  String get sauvegardeRestaurer => 'Restore a backup';

  @override
  String get sauvegardeMotDePasse => 'Backup password';

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
  String get dsZoomAvant => 'Zoom in';

  @override
  String get dsZoomArriere => 'Zoom out';

  @override
  String get dsZoomAjuster => 'Whole image';

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
  String get dsChiffresCles => 'Key figures';

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
  String get dsAjouterFavoris => 'Add to favourites';

  @override
  String get dsRetirerFavoris => 'Remove from favourites';

  @override
  String get dsFavorisComplets => 'Favourites full';

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
  String get dsBarcodeCopier => 'Copy';

  @override
  String get dsBarcodeImprimer => 'Print label';

  @override
  String get moduleUtilisateurs => 'Users';

  @override
  String get connexionSousTitre => 'Sign in to open your till.';

  @override
  String get connexionChoisirCompte => 'Choose your account';

  @override
  String get connexionChoisirSousTitre => 'The accounts on this PC: click yours.';

  @override
  String get connexionAutreCompte => 'Another account';

  @override
  String get connexionPasVous => 'Not you? Switch account';

  @override
  String get connexionVoirComptes => 'See the accounts on this PC';

  @override
  String connexionCompteBens(String telephone) {
    return 'BENS account $telephone';
  }

  @override
  String get connexionMotDePasseBens => 'By default: your BENS account password.';

  @override
  String get connexionIdentifiantOuTelephone => 'Username, or the BENS account phone for the administrator';

  @override
  String get connexionAfficher => 'Show';

  @override
  String get connexionMasquer => 'Hide';

  @override
  String get connexionResterConnecte => 'Stay signed in';

  @override
  String get connexionMotDePasseOublie => 'Forgot password?';

  @override
  String get connexionMotDePasseOublieAide => 'Ask the administrator to reset it.';

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
  String get configEtapeLangue => 'Language & currency';

  @override
  String get configEtapePaiements => 'Payments';

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
  String get alertesVoirStock => 'View stock';

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
  String get tiersReste => 'Remaining';

  @override
  String get tiersSituation => 'Statement';

  @override
  String tiersSituationDe(String nom) {
    return 'Statement — $nom';
  }

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
  String get posErreurMotif => 'A reason is required.';

  @override
  String posErreurMontantPaye(String montant) {
    return 'The paid amount cannot decrease (already paid: $montant). Use a return.';
  }

  @override
  String get posErreurRetourLie => 'A return is linked to this basket: it cannot be cancelled.';

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
  String get retoursModifierTitre => 'Edit return';

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
  String get posEncaisserBouton => 'Check out';

  @override
  String get posEncTicketTitre => 'Check out the receipt';

  @override
  String get posEncSaveTitre => 'Save the receipt';

  @override
  String get posEncTicketOk => 'Check out and print';

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
  String get posClotureFond => 'Opening float';

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
  String get posRecIndice => 'Product, code or cart…';

  @override
  String get posRecLignes => 'Lines sold';

  @override
  String get posRecQuantite => 'Quantity';

  @override
  String get posRecAucune => 'No lines sold';

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
  String get produitErreurUtilise => 'This product is in use (sales, purchases or stock): it cannot be deleted.';

  @override
  String get catalogueErreurNomPris => 'This name is already in use.';

  @override
  String get prdOngletSousCategories => 'Subcategories';

  @override
  String get prdAchat => 'Cost';

  @override
  String get prdVente => 'Price excl. VAT';

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
  String get prdModeRapide => 'Quick';

  @override
  String get prdModeDetaille => 'Detailed · 3 steps';

  @override
  String get prdModeIa => 'AI';

  @override
  String get prdEtape1 => 'Product & price';

  @override
  String get prdEtape2 => 'Stock';

  @override
  String get prdEtape3 => 'Variants';

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
  String get prdFournisseur => 'Supplier';

  @override
  String get prdGenererCodeBarres => 'Generate a CDZ barcode';

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
  String prdStockViaEntree(String quantite) {
    return '$quantite will enter stock with the receipt\'s stock-in.';
  }

  @override
  String get prdSeuilAlerte => 'Alert threshold';

  @override
  String get prdEmballages => 'Packaging';

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
  String prdTaillesN(int n) {
    return '$n size(s) selected';
  }

  @override
  String get prdCouleurs => 'Colours';

  @override
  String get prdOptions => 'Options';

  @override
  String get prdCodesMultiples => 'Multiple codes';

  @override
  String get prdAjouterCode => 'Add a code';

  @override
  String get prdSuiviSerie => 'Serial number tracking';

  @override
  String get prdServiceSansStock => 'Service (no stock)';

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
  String get prdPorteeProduit => 'Per product';

  @override
  String get prdPorteeMontant => 'By amount (basket)';

  @override
  String get prdProgrammee => 'Scheduled';

  @override
  String get prdModifierRemise => 'Edit discount';

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
  String get prdSeuilAide => 'The discount applies once the subtotal reaches this amount';

  @override
  String get prdToastRemise => 'Discount saved';

  @override
  String get prdToastRemiseDesc => 'Applied at the till during its period';

  @override
  String get prdVentesRemisees => 'Discounted sales';

  @override
  String get prdModifierPack => 'Edit bundle';

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
  String get prdImportColonnes => 'Columns';

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
  String get stkDispoSource => 'Qty (from)';

  @override
  String stkDisponible(String quantite) {
    return 'Available: $quantite';
  }

  @override
  String get stkDisponibleEtat => 'Available';

  @override
  String get stkDistribuer => 'Distribute';

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
  String stkListeTitre(String code) {
    return 'List $code';
  }

  @override
  String get stkLivraison => 'Requested delivery';

  @override
  String get stkMagasin => 'Store';

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
  String get entEtapeProduits => 'Received products';

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
  String get entIaDetecte => 'Detected on the receipt';

  @override
  String get entIaEtapeFournisseur => 'Supplier & payment';

  @override
  String get entIaEtapeLignes => 'Detected lines';

  @override
  String get entIaEtapePhoto => 'Receipt photo';

  @override
  String get entIaJoindre => 'Attach a receipt';

  @override
  String get entIaLecture => 'Reading the receipt…';

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
  String get entNouvelleTitre => 'New entry · Smart Scan';

  @override
  String get entNumFacture => 'Invoice / DN no.';

  @override
  String get entNumFactureIndice => 'E.g. FAC-24-1187';

  @override
  String get entOffreMessage => 'I would like to increase my Smart Scan quota.';

  @override
  String get entOngletEntree => 'Stock-in';

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
    return 'Create the product “$nom”';
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
  String get usrPrecedent => 'Back';

  @override
  String get usrSuivant => 'Next';

  @override
  String get usrEnregistrerRole => 'Save role';

  @override
  String get usrEtapeInfos => 'Details';

  @override
  String get usrEtapePermissions => 'Permissions';

  @override
  String get usrEtapeSpeciales => 'Special permissions';

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

  @override
  String get pmNonEnregistre => 'Unsaved changes';

  @override
  String get pmEnregistrer => 'Save';

  @override
  String get pmEnregistre => 'Settings saved';

  @override
  String get pmGrpSysteme => 'System';

  @override
  String get pmGrpBoutique => 'Shop';

  @override
  String get pmGrpCaisse => 'Checkout and sales';

  @override
  String get pmGrpImpression => 'Printing';

  @override
  String get pmGrpAlertes => 'Alerts';

  @override
  String get pmGrpSauvegarde => 'Backup';

  @override
  String get pmGrpLicence => 'Licence';

  @override
  String get pmTheme => 'Theme';

  @override
  String get pmThemeDesc => 'Light for daytime, dark for checkout screens in low light.';

  @override
  String get pmClair => 'Light';

  @override
  String get pmSombre => 'Dark';

  @override
  String get pmLangue => 'Interface language';

  @override
  String get pmLangueDesc => 'Arabic switches to right-to-left layout and the Cairo font.';

  @override
  String get pmDevise => 'Currency';

  @override
  String get pmDeviseDesc => 'Shown on amounts, receipts and invoices.';

  @override
  String get pmDecimales => 'Quantity decimals';

  @override
  String get pmDecimalesDesc => '0 for unit items, 3 for sale by weight (kg).';

  @override
  String get pmMargeTitre => 'Default margin';

  @override
  String get pmMargeInfo => 'Applied to new products and suggested on entries';

  @override
  String get pmMargeType => 'Margin type';

  @override
  String get pmMargeTypeDesc => 'Fixed amount or percentage of the purchase price.';

  @override
  String get pmMontant => 'Amount';

  @override
  String get pmPourcentage => 'Percentage';

  @override
  String get pmMargeValeur => 'Margin';

  @override
  String get pmMargeValeurDesc => 'Sale price = purchase + margin.';

  @override
  String get pmSeuilsTitre => 'Global stock thresholds';

  @override
  String get pmSeuilsInfo => 'Defaults, editable per product';

  @override
  String get pmSeuilMin => 'Minimum (out of stock)';

  @override
  String get pmSeuilMinDesc => 'Alert when stock falls below this level.';

  @override
  String get pmSeuilMax => 'Maximum';

  @override
  String get pmSeuilMaxDesc => 'Flags overstock; 0 for none.';

  @override
  String get pmPieces => 'pcs';

  @override
  String get pmGarde => 'Stock guard';

  @override
  String get pmGardeDesc => 'Always on: stock never goes negative.';

  @override
  String get pmGardeCaisseDesc => 'Always on: stock never goes negative, a product at 0 cannot be sold.';

  @override
  String get pmNonDesactivable => 'Cannot be disabled';

  @override
  String get pmZakatTitre => 'Zakat';

  @override
  String get pmNissab => 'Nisab';

  @override
  String get pmNissabDesc => 'Value of 85 g of gold; suggested for each calculation.';

  @override
  String get pmTaux => 'Rate';

  @override
  String get pmTauxDesc => 'Rate applied to the base.';

  @override
  String get pmServeursTitre => 'Online services';

  @override
  String get pmServeursInfo => 'Shared catalogue and barcode product lookup';

  @override
  String get pmServeurUrl => 'CaisseDZ server URL';

  @override
  String get pmServeurCle => 'API key';

  @override
  String get pmMantouj => 'Mantouj URL';

  @override
  String get pmSynchro => 'Sync the catalogue';

  @override
  String get pmSynchroDesc => 'Sends your product sheets and fetches enriched ones from the shared catalogue.';

  @override
  String get pmSynchroBouton => 'Sync';

  @override
  String get pmLogo => 'Logo';

  @override
  String get pmLogoAide => 'Transparent PNG · printed at the top of the receipt';

  @override
  String get pmRaisonSociale => 'Company name';

  @override
  String get pmTelephone => 'Phone';

  @override
  String get pmAdresse => 'Address';

  @override
  String get pmRc => 'Trade reg.';

  @override
  String get pmNif => 'Tax ID';

  @override
  String get pmNis => 'Stat. ID';

  @override
  String get pmArticle => 'Tax article';

  @override
  String get pmEmail => 'Email';

  @override
  String get pmMessage => 'Receipt message';

  @override
  String get pmMessageAide => 'Printed at the bottom of each receipt';

  @override
  String get pmModesTitre => 'Payment methods';

  @override
  String get pmModesInfo =>
      'Offered in the checkout dialog; cash is always accepted, points only with the loyalty bonus on and a known customer';

  @override
  String get pmReglesTitre => 'Sales rules';

  @override
  String get pmSousAchat => 'Selling below cost';

  @override
  String get pmSousAchatDesc => 'Allow, warn or forbid a sale price below the purchase price.';

  @override
  String get pmFideliteTitre => 'Loyalty';

  @override
  String get pmBonus => 'Loyalty bonus';

  @override
  String get pmBonusDesc => 'Identified customers earn points at each checkout.';

  @override
  String get pmTauxGain => 'Earning rate';

  @override
  String get pmTauxGainDesc => 'Points earned per spending step.';

  @override
  String get pmPointPar => 'point /';

  @override
  String get pmImprimanteTitre => 'Receipt printer';

  @override
  String get pmTypeBluetooth => 'Bluetooth';

  @override
  String get pmTypeBluetoothDesc => 'Paired in Windows';

  @override
  String get pmTypeUsb => 'USB';

  @override
  String get pmTypeUsbDesc => 'Windows queue (ESC/POS)';

  @override
  String get pmTypeReseau => 'Network';

  @override
  String get pmTypeReseauDesc => 'IP address and port';

  @override
  String get pmTypeNormale => 'Standard';

  @override
  String get pmTypeNormaleDesc => 'Windows printer';

  @override
  String get pmAdresseIp => 'IP address:port';

  @override
  String get pmAdresseBluetooth => 'Bluetooth queue';

  @override
  String get pmFileUsb => 'Windows queue';

  @override
  String get pmLargeur => 'Width';

  @override
  String get pmTest => 'Print a test';

  @override
  String pmTestOk(String cible) {
    return 'Test sent: the test page was printed on $cible.';
  }

  @override
  String get pmAlertesConnexion => 'Show alerts at sign-in';

  @override
  String get pmAlertesConnexionDesc => 'Stock-outs, high credit, unclosed sessions.';

  @override
  String get pmSeuilCredit => 'Customer credit threshold';

  @override
  String get pmSeuilCreditDesc => 'Flags customers above this amount; 0 for all.';

  @override
  String get pmSauverMaintenant => 'Back up now';

  @override
  String get pmSauvegardeTerminee => 'Backup complete';

  @override
  String get pmRestaurerDesc => 'Replaces all current data with the data in a file.';

  @override
  String get pmRestaurerBouton => 'Restore…';

  @override
  String get pmRestaurerConfirmTitre => 'Restore a backup?';

  @override
  String get pmRestaurerConfirmMsg => 'All current data (sales, stock, customers…) will be replaced at the next start.';

  @override
  String get pmRestaurerConfirmOk => 'Choose the file and restore';

  @override
  String get pmPalierAvance => 'Advanced tier';

  @override
  String get pmPalierAvanceDesc => 'One shop, 5 cashiers: quotes, orders, supplier orders and needs lists.';

  @override
  String get pmPalierBasic => 'Basic tier';

  @override
  String get pmPalierBasicDesc => 'One shop, 5 cashiers: point of sale, sales, stock, customers and suppliers.';

  @override
  String get pmPalierDemo => 'Demo mode';

  @override
  String get pmPalierDemoDesc => 'Sample data, reset when closed';

  @override
  String get pmPalierAucun => 'Application not activated';

  @override
  String get pmPalierAucunDesc => 'Choose a plan, sign in to your account or paste a key.';

  @override
  String get pmActive => 'Active';

  @override
  String get pmCle => 'Licence key';

  @override
  String get pmCleDesc => 'Bound to this workstation.';

  @override
  String pmActiveeLe(String date) {
    return 'Activated on $date.';
  }

  @override
  String get pmGererLicence => 'Manage the licence';

  @override
  String get pmGererLicenceDesc => 'Paste a key received from BENS (offline backup).';

  @override
  String get posPrixSousAchatInterdit => 'Price below cost: forbidden by the settings.';

  @override
  String alertesExpireDepuis(int n) {
    return 'Expired $n d ago';
  }

  @override
  String get communSessionRequise => 'No open cash session: open a session before saving.';

  @override
  String communFermeeDesc(String caisse) {
    return 'Open a session for “$caisse” before saving this operation.';
  }

  @override
  String get posRaccourciE => 'Quick entry (buy one product)';

  @override
  String get hiActSauvegarde => 'Backup';

  @override
  String get hiActRestauration => 'Restore';

  @override
  String get posApercuTicket => 'Receipt preview';

  @override
  String get posImprimer => 'Print';

  @override
  String get posGabaritLatin => 'Latin';

  @override
  String get pmApercuAucuneVente => 'No sale yet: the preview uses a sample receipt.';

  @override
  String get pmSauvegardeIncomplete => 'Automatic backup: choose a folder and a password.';

  @override
  String get pmSauvegardeDossier => 'Backup folder';

  @override
  String get pmSauvegardeDossierDesc => 'Local disk, USB drive or synced folder (Google Drive, OneDrive).';

  @override
  String get pmSauvegardeChanger => 'Change';

  @override
  String get pmSauvegardeAuto => 'Automatic backup';

  @override
  String get pmSauvegardeAutoDesc => 'Made when the application opens; the last 30 are kept.';

  @override
  String get pmFrequenceDesactivee => 'Off';

  @override
  String get pmFrequenceDemarrage => 'At every start';

  @override
  String get pmFrequenceQuotidienne => 'Daily';

  @override
  String get pmSauvegardeMdp => 'Backup password';

  @override
  String get pmSauvegardeMdpDesc => 'Required to restore an automatic backup.';

  @override
  String get pmSauvegardeMdpDefinir => 'Set';

  @override
  String get pmSauvegardeMdpChanger => 'Change';

  @override
  String pmSauvegardeDerniere(String date) {
    return 'Last automatic backup: $date';
  }

  @override
  String get communModifiePar => 'Modified by';

  @override
  String get communModifieLe => 'Modified on';

  @override
  String get communNombreObligatoire => 'The piece count (2nd stock) is required for this product.';

  @override
  String get stkNombre => 'Count';

  @override
  String get stkNombreObligatoire => 'Count required';

  @override
  String get pmNombreActif => '2nd stock “count” for all products';

  @override
  String get pmNombreActifDesc =>
      'Piece count entered alongside the quantity (e.g. butcher: kg + pieces), required on every movement.';

  @override
  String dsFavorisAide(int max) {
    return 'Click a module to add it to or remove it from your favorites ($max at most).';
  }

  @override
  String dsFavorisAideComplets(int max) {
    return 'All $max favorites are chosen: remove one to add another.';
  }

  @override
  String get shellChoisirFavoris => 'Choose favorites';

  @override
  String get communTermine => 'Done';

  @override
  String get posRechMin => 'Min';

  @override
  String get posRechMax => 'Max';

  @override
  String get posRechToutesCategories => 'All categories';

  @override
  String get posMontantTitre => 'Sale by amount';

  @override
  String get posMontantColis => 'Amount';

  @override
  String get posMontantAide =>
      'Weighed or uncoded item: the amount adds up on a single basket line (200 then 500 = 700).';

  @override
  String get posMontantAutre => 'Other amount';

  @override
  String get posMontantModifier => 'Edit amount';

  @override
  String get posMontantChamp => 'Amount';

  @override
  String get posMontantInvalide => 'Enter an amount greater than 0.';

  @override
  String get posMontantLigneAide => 'Double-click: edit the amount';

  @override
  String get ventesListeProduits => 'Product list';

  @override
  String ventesListeProduitsTitre(String code) {
    return 'Basket $code products';
  }

  @override
  String get ventesColis => 'Package';

  @override
  String get selRechercherListe => 'Search the list';

  @override
  String get selProduit => 'Choose a product';

  @override
  String get selCategorie => 'Choose a category';

  @override
  String get selSousCategorie => 'Choose a subcategory';

  @override
  String get selRemise => 'Choose a discount';

  @override
  String get selPack => 'Choose a pack';

  @override
  String get selClient => 'Choose a customer';

  @override
  String get selFournisseur => 'Choose a supplier';

  @override
  String get selMagasin => 'Choose a store';

  @override
  String get selCaisse => 'Choose a cash register';

  @override
  String get selSession => 'Choose a session';

  @override
  String get selUtilisateur => 'Choose a user';

  @override
  String get selVente => 'Choose a sale';

  @override
  String get selColCode => 'Code';

  @override
  String get selColNom => 'Name';

  @override
  String get selColDesignation => 'Description';

  @override
  String get selColCategorie => 'Category';

  @override
  String get selColStock => 'Stock';

  @override
  String get selColPrix => 'Price';

  @override
  String get selColTelephone => 'Phone';

  @override
  String get selColAdresse => 'Address';

  @override
  String get selColType => 'Type';

  @override
  String get selColValeur => 'Value';

  @override
  String get selColMagasin => 'Store';

  @override
  String get selColCaisse => 'Cash register';

  @override
  String get selColUtilisateur => 'User';

  @override
  String get selColOuverture => 'Opened';

  @override
  String get selColStatut => 'Status';

  @override
  String get selColDate => 'Date';

  @override
  String get selColClient => 'Customer';

  @override
  String get selColTotal => 'Total';

  @override
  String get selColProduits => 'Products';

  @override
  String get selColDescription => 'Description';

  @override
  String get selFiltreEtat => 'Status';

  @override
  String get selTous => 'All';

  @override
  String selPoints(int n) {
    return '$n points';
  }

  @override
  String selNbProduits(int n) {
    return '$n products';
  }

  @override
  String get retoursNouveauClient => 'New customer return';

  @override
  String get retoursNouveauFournisseur => 'New supplier return';

  @override
  String get prdPorteeProduitAide => 'Applied automatically to the chosen products during its period.';

  @override
  String get prdPorteeMontantAide => 'Chosen on the basket at the till once the subtotal reaches the threshold.';

  @override
  String prdMontantPanierAide(String devise) {
    return 'E.g. −500 $devise off the basket';
  }

  @override
  String get auditCreeLe => 'Created on';

  @override
  String get auditModifieLe => 'Modified on';

  @override
  String get auditModifiePar => 'Modified by';

  @override
  String get prdFiltreQuantite => 'Quantity';

  @override
  String get prdToastSuppression => 'Deleted';

  @override
  String prdVersSansCategorie(int n) {
    return '$n product(s) → No category';
  }

  @override
  String get prdPackVendu => 'Already sold: kept for the sales history';

  @override
  String stkNombreDispo(String quantite) {
    return 'Pieces: $quantite';
  }

  @override
  String get stkListeProduits => 'Product list';

  @override
  String stkListeProduitsTitre(String code) {
    return 'Products of $code';
  }

  @override
  String get stkAjouterSousSeuil => 'Products below threshold';

  @override
  String get stkAjouterRuptures => 'Out-of-stock products';

  @override
  String get stkAucunProduitAjoute => 'No new product to add.';

  @override
  String stkProduitsAjoutes(int n) {
    return '$n product(s) added';
  }

  @override
  String get entFiltreType => 'Entry type';

  @override
  String get entTypeNormale => 'Standard entry';

  @override
  String get tiersSoldeAvant => 'Balance before';

  @override
  String get tiersSoldeApres => 'Balance after';

  @override
  String get stkErreurSortieRetour => 'Exit linked to a return: edit or cancel the return instead.';

  @override
  String get remiseSectionType => 'Discount type';

  @override
  String get remiseSectionInfos => 'General information';

  @override
  String get remiseSectionCalcul => 'Discount value';

  @override
  String get remiseSectionPeriode => 'Validity period';

  @override
  String stkQteDansMagasin(String magasin) {
    return 'Qty in $magasin';
  }

  @override
  String stkStockMagasinN(String magasin, String quantite) {
    return '$magasin: $quantite';
  }

  @override
  String get versementErreurPeriode =>
      'Closed period: this payment can no longer be edited. Cancel it and enter a new payment.';

  @override
  String get retoursDateDuJour => 'Dated today, even after the Z closing of the sale day.';

  @override
  String get situationCasse => 'Breakage (loss)';

  @override
  String get situationPiecesTheoriques => 'Theoretical pieces';

  @override
  String get situationPiecesComptees => 'Counted pieces';

  @override
  String get permDepasserPlafondCredit => 'Exceed the credit limit';

  @override
  String posErreurPlafondCredit(String plafond, String solde) {
    return 'Customer credit limit exceeded ($plafond, current credit $solde).';
  }

  @override
  String get tiersPlafondCredit => 'Credit limit';

  @override
  String get tiersPlafondCreditAide => 'Empty or 0: no limit.';

  @override
  String get mvtCoffre => 'Safe';

  @override
  String get mvtTimbre => 'Stamp duty';

  @override
  String get retoursAvoirEmis =>
      'A credit note was issued for this return (invoiced sale): it can no longer be edited or cancelled.';

  @override
  String get tiersArticleImposition => 'Tax article (AI)';

  @override
  String get pmRegimeFiscal => 'Tax regime';

  @override
  String get pmRegimeFiscalDesc => 'Real: VAT collected on sales and deductible on purchases. IFU: sales without VAT.';

  @override
  String get pmRegimeReel => 'Real';

  @override
  String get pmRegimeIfu => 'IFU';

  @override
  String get pmTimbre => 'Stamp duty';

  @override
  String get pmTimbreDesc => 'Added to invoices on the cash-paid part (1% to 2%, minimum 5 DA).';

  @override
  String get factureVenteAnnulee => 'Cancelled sale: no invoice can be issued.';

  @override
  String get exportFiscalG50 => 'G50 return (Excel)';

  @override
  String get exportFiscalG50Desc => 'VAT collected and deductible by rate, stamp duty, VAT due';

  @override
  String get typeMouvementAnnulation => 'Sale cancellation';

  @override
  String get posErreurMonnaieSansEspeces => 'Change exceeds the cash received: card, cheque or points give no change.';

  @override
  String get tiersSoldeInitial => 'Opening balance';

  @override
  String get tiersSoldeInitialAideClient =>
      'Carried over: amount the customer owed before the software (negative = advance).';

  @override
  String get tiersSoldeInitialAideFournisseur =>
      'Carried over: amount owed to the supplier before the software (negative = advance).';

  @override
  String get tvaRecapitulatif => 'VAT summary';

  @override
  String get tvaTaux => 'VAT rate';

  @override
  String get tvaBaseHt => 'Net base';

  @override
  String get tvaMontant => 'VAT';

  @override
  String get tvaTtc => 'Incl. VAT';

  @override
  String get tvaCollectee => 'Output VAT';

  @override
  String get tvaDeductible => 'Input VAT';

  @override
  String get tvaNette => 'VAT payable';

  @override
  String get tvaHt => 'Excl. VAT';

  @override
  String get situationTva => 'VAT by rate';

  @override
  String get situationGroupeFiscalite => 'Tax';

  @override
  String get ventesOngletPaniers => 'Baskets';

  @override
  String get ventesOngletFactures => 'Invoices & credit notes';

  @override
  String get factureNumero => 'Invoice no.';

  @override
  String get factureTypeFacture => 'Invoice';

  @override
  String get factureTypeAvoir => 'Credit note';

  @override
  String get factureVente => 'Receipt';

  @override
  String get factureOrigine => 'Original invoice';

  @override
  String get factureTimbre => 'Stamp duty';

  @override
  String get factureNet => 'Net payable';

  @override
  String get factureEntites => 'Invoices and credit notes';

  @override
  String get factureAucune => 'No invoice for this period';

  @override
  String get factureKpiFactures => 'Invoices issued';

  @override
  String get factureKpiFacture => 'Total invoiced';

  @override
  String get factureKpiAvoirs => 'Total credit notes';

  @override
  String get factureImprimer => 'Print (duplicate)';

  @override
  String get factureChaineOk => 'Invoice chain intact';

  @override
  String get achatErreurCommandeInconnue => 'Supplier order not found for this supplier';

  @override
  String get achatErreurCommandeCloturee => 'Supplier order cancelled or closed: cannot receive';

  @override
  String get moduleDocuments => 'Quotes & orders';

  @override
  String get moduleCommandesFournisseurs => 'Supplier orders';

  @override
  String get docOngletDevis => 'Quotes';

  @override
  String get docOngletProformas => 'Proformas';

  @override
  String get docOngletCommandes => 'Customer orders';

  @override
  String get docOngletLivraisons => 'Delivery notes';

  @override
  String get docTypeDevis => 'Quote';

  @override
  String get docTypeProforma => 'Proforma';

  @override
  String get docTypeCommande => 'Order';

  @override
  String get docBonLivraison => 'Delivery note';

  @override
  String get docStatutEnCours => 'Open';

  @override
  String get docStatutAccepte => 'Accepted';

  @override
  String get docStatutRefuse => 'Refused';

  @override
  String get docStatutTransforme => 'Converted to order';

  @override
  String get docStatutExpire => 'Expired';

  @override
  String get docStatutPartielle => 'Partially delivered';

  @override
  String get docStatutLivree => 'Delivered';

  @override
  String get docStatutAnnule => 'Cancelled';

  @override
  String get docValidite => 'Valid until';

  @override
  String get docOrigine => 'Origin';

  @override
  String get docLivre => 'Delivered';

  @override
  String get docResteALivrer => 'Left to deliver';

  @override
  String get docALivrer => 'To deliver';

  @override
  String get docQuantiteLivree => 'Delivered quantity';

  @override
  String get docPuTtc => 'Unit price incl. VAT';

  @override
  String get docTotalTtc => 'Total incl. VAT';

  @override
  String get docAucun => 'No document in this period';

  @override
  String get docKpiNombre => 'Documents';

  @override
  String get docKpiMontant => 'Total amount';

  @override
  String get docKpiALivrer => 'To deliver';

  @override
  String get docKpiTransformes => 'Converted to orders';

  @override
  String get docImprimer => 'Print (A4)';

  @override
  String get docAccepter => 'Accept';

  @override
  String get docRefuser => 'Refuse';

  @override
  String get docTransformer => 'Convert to order';

  @override
  String get docLivrer => 'Deliver';

  @override
  String get docNouveauDevis => 'New quote';

  @override
  String get docNouvelleProforma => 'New proforma';

  @override
  String get docNouvelleCommande => 'New order';

  @override
  String docNouveauTitre(String type) {
    return 'New document: $type';
  }

  @override
  String docModifierTitre(String type) {
    return 'Edit: $type';
  }

  @override
  String get docChoisirClient => 'Choose a customer';

  @override
  String get docToastEnregistre => 'Document saved';

  @override
  String get docToastTransforme => 'Order created';

  @override
  String get docToastLivre => 'Delivery saved';

  @override
  String docLivrerTitre(String code) {
    return 'Deliver order $code';
  }

  @override
  String get docMontantPaye => 'Amount paid';

  @override
  String get docMontantPayeAide => 'Leave empty: delivery on credit';

  @override
  String get docValiderLivraison => 'Confirm delivery';

  @override
  String get docPdfDevis => 'QUOTE';

  @override
  String get docPdfProforma => 'PROFORMA INVOICE';

  @override
  String get docPdfCommande => 'PURCHASE ORDER';

  @override
  String get docPdfLivraison => 'DELIVERY NOTE';

  @override
  String docArretee(String type) {
    return 'This document ($type) is set at the sum of';
  }

  @override
  String get docMentionProforma => 'Document with no accounting value: not an invoice.';

  @override
  String get docSignatureClient => 'Approved (customer)';

  @override
  String get docSignatureVendeur => 'Stamp and signature';

  @override
  String get docSignatureLivreur => 'Delivered by';

  @override
  String get docSignatureReception => 'Received by (name, signature)';

  @override
  String get docErreurClient => 'Unknown customer';

  @override
  String get docErreurInconnu => 'Document not found';

  @override
  String get docErreurNonModifiable =>
      'This document can no longer be changed (converted, refused, cancelled or delivered)';

  @override
  String get docErreurDejaAnnule => 'Document already cancelled';

  @override
  String get docErreurLivraisonLiee => 'Order already delivered: cancel the delivery note\'s sale first';

  @override
  String get docErreurRienALivrer => 'Nothing to deliver';

  @override
  String get docErreurQuantiteExcessive => 'Quantity above what is left to deliver';

  @override
  String get docErreurLivraisonExistante => 'This sale already has a delivery note';

  @override
  String get docErreurVenteInconnue => 'Sale not found';

  @override
  String get cmdfNouvelle => 'New supplier order';

  @override
  String get cmdfModifier => 'Edit supplier order';

  @override
  String cmdfTitre(String code) {
    return 'Supplier order $code';
  }

  @override
  String get cmdfCommande => 'Supplier order';

  @override
  String get cmdfPrix => 'Purchase price';

  @override
  String get cmdfRecu => 'Received';

  @override
  String get cmdfReste => 'Left to receive';

  @override
  String get cmdfReceptions => 'Receiving entries';

  @override
  String get cmdfReceptionner => 'Receive';

  @override
  String get cmdfSolder => 'Close';

  @override
  String cmdfSolderMessage(String code) {
    return 'Close order $code? The remaining quantity will no longer be expected.';
  }

  @override
  String get cmdfKpiAttendues => 'Awaiting receipt';

  @override
  String get cmdfStatutPartielle => 'Partially received';

  @override
  String get cmdfStatutRecue => 'Received';

  @override
  String get cmdfStatutSoldee => 'Closed';

  @override
  String get cmdfPdfTitre => 'SUPPLIER PURCHASE ORDER';

  @override
  String get cmdfDepuisBesoin => 'Create supplier order';

  @override
  String get cmdfErreurReceptionLiee => 'Order already received: cancel the linked entries first';

  @override
  String get cmdfErreurDejaSoldee => 'Order already closed';

  @override
  String get apercuEnregistrerPdf => 'Save as PDF';

  @override
  String get rechercheGlobaleTitre => 'Global search';

  @override
  String get rechercheGlobaleIndice => 'Search the whole system…';

  @override
  String get rechercheGlobaleAide =>
      'Code, name, phone, barcode, reference: products, customers, suppliers, sales, invoices, quotes, deliveries, purchases, returns, payments…';

  @override
  String rechercheGlobaleAucun(String texte) {
    return 'No results for “$texte”';
  }

  @override
  String get prdPrixTtc => 'Selling price incl. VAT';

  @override
  String get prdVenteTtc => 'Price incl. VAT';

  @override
  String get posClotureNegatif =>
      'Negative expected balance: more cash left this till than came in since it was opened (see the breakdown above). A till cannot hold less than 0: count the cash actually there (0 if the drawer is empty); the difference is recorded as a shortage.';

  @override
  String get posTransfertTitre => 'Not enough stock in this store';

  @override
  String get posTransfertConfirmer => 'Transfer and add';

  @override
  String posTransfertFait(String code) {
    return 'Transfer $code created';
  }

  @override
  String get posTransfertQuestion => 'Transfer the missing quantity to complete the cart?';

  @override
  String get posTransfertDepuis => 'From';

  @override
  String get posTransfertVers => 'To the till';

  @override
  String posTransfertStock(String stock) {
    return 'Stock: $stock';
  }

  @override
  String posTransfertManque(String quantite) {
    return 'Missing $quantite';
  }

  @override
  String get pmTvaCaisse => 'Till sales with VAT';

  @override
  String get pmTvaCaisseDesc =>
      'Yes: prices include VAT (net price + product VAT). No: net prices, receipt without VAT.';

  @override
  String get pmTvaDocuments => 'Quotes, proformas and orders with VAT';

  @override
  String get pmTvaDocumentsDesc => 'Same choice for quotes, proformas, customer orders and their deliveries.';

  @override
  String get docPuHt => 'Unit price excl. VAT';

  @override
  String get retoursMontantRetour => 'Return amount';

  @override
  String get retoursMontantRetourAideClient =>
      'Paid back to the customer in cash; the rest becomes a credit on their balance.';

  @override
  String get retoursMontantRetourAideFournisseur =>
      'Paid by the supplier in cash; the rest is deducted from what you owe them.';

  @override
  String get retoursMontantRetourPassage => 'Walk-in customer: they get the full return amount back.';

  @override
  String retoursMontantRetourMax(String plafond) {
    return 'Between 0 and $plafond';
  }

  @override
  String get retoursErreurMontant => 'Invalid return amount: it must be between 0 and the return value.';

  @override
  String retoursRepartition(String avoir, String versement) {
    return 'Payment $versement · Credit $avoir';
  }

  @override
  String get retoursMontantComplet => 'Full amount';

  @override
  String get offresTitre => 'Choose your plan';

  @override
  String offresSousTitre(int jours) {
    return 'Every plan starts with a $jours-day free trial. Then a one-time payment: the licence is yours for life, no subscription.';
  }

  @override
  String offresEssaiGratuit(int jours) {
    return '$jours-day free trial';
  }

  @override
  String offresPrix(String prix) {
    return '$prix DA';
  }

  @override
  String get offresPaiementUnique => 'one-time payment, for life';

  @override
  String offresMagasins(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n shops', one: '1 shop');
    return '$_temp0';
  }

  @override
  String offresScans(int n, int mois) {
    return '$n Smart Scans included ($mois months)';
  }

  @override
  String get offresAtoutStock => 'Products, stock, stock in / out and inventory';

  @override
  String get offresAtoutPdv => 'Point of sale: sales, scan, receipts, multi-cart';

  @override
  String get offresAtoutVentes => 'Sales, invoices, credit notes and returns';

  @override
  String get offresAtoutGestionCaisse => 'Cash management, closings and safe';

  @override
  String get offresAtoutRapports => 'Dashboard, summary, zakat and history';

  @override
  String get offresAtoutCommandesClients => 'Customer orders and delivery notes';

  @override
  String get offresAtoutBesoins => 'Needs lists';

  @override
  String get offresAtoutTransferts => 'Transfers between shops';

  @override
  String offresToutPlus(String formule) {
    return 'Everything in $formule, plus:';
  }

  @override
  String offresCaisses(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n cash registers', one: '1 cash register');
    return '$_temp0';
  }

  @override
  String get offresAtoutTiers => 'Customers, suppliers, payments and credit';

  @override
  String get offresAtoutDevis => 'Quotes and proformas';

  @override
  String get offresAtoutAchats => 'Supplier orders (partial receiving)';

  @override
  String get offresAtoutMultiMagasin => 'Multi-shop (stock per shop)';

  @override
  String get offresIdealBasic => 'Small shop, single point of sale';

  @override
  String get offresIdealAvance => 'Business that issues quotes and places orders';

  @override
  String get offresIdealUltra => 'Multiple stores, full management';

  @override
  String get offresTout => 'All modules';

  @override
  String offresEssayer(int jours) {
    return 'Try $jours days';
  }

  @override
  String offresChoisir(String formule) {
    return 'Choose $formule';
  }

  @override
  String get offresDejaCompte => 'Already have an account?';

  @override
  String get offresSeConnecter => 'Sign in';

  @override
  String get offresJaiUneCle => 'I have an activation key';

  @override
  String offresEssaiTermine(String date) {
    return 'Your trial ended on $date. Choose a plan: BENS contacts you for the payment, then the app unlocks by itself. Your data is kept.';
  }

  @override
  String get offresSansFormule => 'No active plan on this PC. Choose a plan: BENS contacts you for the payment.';

  @override
  String get offresLicenceRefuseeInvalide =>
      'BENS sent your licence, but this version of CaisseDZ refuses it (a key meant for another app or another version). Install the latest CaisseDZ, then click Refresh; otherwise, contact BENS.';

  @override
  String get offresLicenceRefuseeAutrePoste =>
      'BENS sent a licence meant for another PC. Click Switch account and sign in again on this PC; otherwise, contact BENS.';

  @override
  String get offresLicenceRefuseeDate =>
      'This PC\'s date was set back: the licence BENS sent is refused. Set the PC\'s date and time right, then click Refresh.';

  @override
  String get offresDemandeTitre => 'Request sent';

  @override
  String offresDemandeDetail(String telephone, String formule) {
    return 'BENS Digital Solutions will call you back on $telephone about paying for $formule. You can also message us on WhatsApp.';
  }

  @override
  String get offresWhatsApp => 'Message on WhatsApp';

  @override
  String offresWhatsAppMessage(String formule, String telephone) {
    return 'Hello, I would like to buy CaisseDZ Desktop $formule (account $telephone).';
  }

  @override
  String get offresHorsLigne =>
      'Offline: prices for reference. Connect this PC to the internet to create your account.';

  @override
  String get offresSeDeconnecter => 'Switch account';

  @override
  String get compteCreerTitre => 'Create your account';

  @override
  String compteCreerSousTitre(String formule, int jours) {
    return '$formule plan · $jours-day free trial';
  }

  @override
  String get compteChangerFormule => 'Change plan';

  @override
  String compteFormule(String formule) {
    return '$formule plan';
  }

  @override
  String get offresSelectionnee => 'Selected plan';

  @override
  String get offresSelectionner => 'Select this plan';

  @override
  String get compteNom => 'Full name';

  @override
  String get compteCommerce => 'Business name';

  @override
  String get compteFacultatif => 'Optional';

  @override
  String get compteTelephone => 'Phone number';

  @override
  String get compteMotDePasse => 'Password';

  @override
  String get compteBensMotDePasseAide =>
      'At least 8 characters. On a new PC it also becomes the administrator\'s (username admin).';

  @override
  String get compteBensConfirmer => 'Confirm the password';

  @override
  String get compteCreerBouton => 'Create my account and start the trial';

  @override
  String get compteEssaiDejaUtilise =>
      'Account created. The free trial was already used on this PC or with this number: choose a plan to continue.';

  @override
  String get compteConnexionTitre => 'Sign in to your account';

  @override
  String get compteConnexionSousTitre =>
      'Your business\'s BENS account: your plan and your licence. Signing in here moves the licence to this PC.';

  @override
  String get compteConnexionBouton => 'Sign in';

  @override
  String get compteMotDePasseOublie => 'Forgot your password?';

  @override
  String get comptePasEncore => 'No account yet?';

  @override
  String get compteVoirFormules => 'See the plans';

  @override
  String get compteRetour => 'Back';

  @override
  String get compteErrTelephone => 'Invalid number: 10 digits starting with 05, 06 or 07.';

  @override
  String get compteErrNom => 'Enter your name (at least 2 characters).';

  @override
  String get compteErrMotDePasse => 'The password is at least 8 characters.';

  @override
  String get compteErrConfirmation => 'The two passwords don\'t match.';

  @override
  String get compteErrNumeroPris => 'This number already has an account: sign in.';

  @override
  String get compteErrIdentifiants => 'Wrong number or password.';

  @override
  String get compteErrReseau => 'Can\'t reach BENS. Check the internet and try again.';

  @override
  String get compteErrTropDEssais => 'Too many tries. Try again in 15 minutes.';

  @override
  String get compteErrAucunCompte => 'No account with this number.';

  @override
  String get compteErrCode => 'Wrong or expired code. Ask BENS for a new one.';

  @override
  String get compteErrServeur => 'The BENS server couldn\'t answer. Try again later.';

  @override
  String get oubliTitre => 'Forgotten password';

  @override
  String get oubliIntro =>
      'Get a recovery code and send it to BENS on WhatsApp. Once checked, BENS sends you a reset code, valid for 48 hours.';

  @override
  String get oubliDemander => 'Get my recovery code';

  @override
  String get oubliVotreCode => 'Your recovery code';

  @override
  String get oubliCopier => 'Copy';

  @override
  String get oubliCopie => 'Copied';

  @override
  String get oubliEnvoyer => 'Send on WhatsApp';

  @override
  String oubliMessage(String telephone, String code) {
    return 'Hello, I forgot the password of my CaisseDZ account ($telephone). My recovery code: $code';
  }

  @override
  String get oubliRecu => 'I received my code';

  @override
  String get oubliCodeReset => 'Reset code';

  @override
  String get oubliNouveau => 'New password';

  @override
  String get oubliValider => 'Change the password';

  @override
  String get activationColler => 'Paste';

  @override
  String get activationWhatsApp => 'Send on WhatsApp';

  @override
  String get activationCleSignee =>
      'Send this PC\'s code to BENS, then paste the key you receive here (132 characters).';

  @override
  String get activationErrVide => 'Paste the key you received.';

  @override
  String get activationErrInvalide => 'Invalid key. Check it was copied in full.';

  @override
  String get activationErrAutrePoste => 'This key is for another PC. Send us the code above.';

  @override
  String activationErrExpiree(String date) {
    return 'Your licence expired on $date. Contact us to renew it.';
  }

  @override
  String get activationErrDate => 'This PC\'s date looks wrong. Fix the date and time.';

  @override
  String get activationPoste => 'This PC\'s code';

  @override
  String get activationRetourOffres => 'Back to the plans';

  @override
  String get licenceUltra => 'Ultra';

  @override
  String licenceEssai(String palier) {
    return '$palier trial';
  }

  @override
  String shellBandeauEssai(String palier, int jours) {
    String _temp0 = intl.Intl.pluralLogic(jours, locale: localeName, other: '$jours days left', one: 'last day');
    return '$palier trial: $_temp0';
  }

  @override
  String get shellVoirFormules => 'Choose a plan';

  @override
  String get pmPalierUltra => 'Ultra tier';

  @override
  String get pmPalierUltraDesc => 'Up to 15 shops and 15 cashiers, transfers, every module.';

  @override
  String pmPalierEssai(String palier) {
    return '$palier trial';
  }

  @override
  String pmPalierEssaiDesc(String date) {
    return 'Free trial until $date, then read-only until a plan is bought.';
  }

  @override
  String pmValableJusquAu(String date) {
    return 'Valid until $date';
  }

  @override
  String get pmLicencePermanente => 'Permanent licence';

  @override
  String get pmCodePoste => 'This PC\'s code';

  @override
  String get pmCompteBens => 'BENS account';

  @override
  String get pmCompteBensDesc => 'Your business\'s account: this PC\'s licence comes from it.';

  @override
  String get pmAucunCompte => 'No BENS account on this PC';

  @override
  String get pmDeconnecterCompte => 'Sign this PC out';

  @override
  String get pmDeconnecterCompteConfirme =>
      'The licence from the account is removed from this PC: sign in again to use it. Your data stays on the PC.';

  @override
  String get pmVoirFormules => 'Plans and upgrades';

  @override
  String shellReservePalier(String palier) {
    return 'Reserved for the $palier tier';
  }

  @override
  String dsGatePalierTitre(String palier) {
    return 'Available with the $palier tier';
  }

  @override
  String dsGatePalierAction(String palier) {
    return 'Upgrade to $palier';
  }

  @override
  String get lectureSeuleTitre => 'Read-only';

  @override
  String get lectureSeuleCourt => 'Read-only (trial ended)';

  @override
  String get lectureSeuleDetail =>
      'The trial has ended: this module waits for a plan to be bought. Sales, products, stock and reports stay viewable, and your data is kept.';

  @override
  String lectureSeuleBandeau(String date) {
    return 'Trial ended on $date: read-only. Your data is kept; choose a plan to keep selling.';
  }

  @override
  String get limiteCaissiers => 'Your plan allows no more cashiers. Upgrade your plan (Settings › Licence).';

  @override
  String get limiteMagasins => 'Your plan allows no more shops: multi-shop comes with the Ultra plan.';

  @override
  String get limiteCaisses => 'Your plan allows no more cash registers. Upgrade your plan (Settings › Licence).';

  @override
  String get limiteTransfertsCaisse =>
      'Your plan has a single cash register: transfers between registers come with the Advanced and Ultra plans.';

  @override
  String get smartScanErreurLicence =>
      'Smart Scan doesn\'t recognise this PC\'s licence. Check your plan (Settings › Licence).';

  @override
  String get smartScanPacksTitre => 'Buy a Smart Scan pack';

  @override
  String smartScanPackLigne(String nom, int scans, String prix) {
    return '$nom · $scans scans · $prix';
  }

  @override
  String get smartScanPackCompte => 'Sign this PC in to your BENS account to buy packs (Settings › Licence).';

  @override
  String smartScanExpiration(int scans, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      scans,
      locale: localeName,
      other: '$scans Smart Scans expire',
      one: '1 Smart Scan expires',
    );
    return '$_temp0 on $date: use them or add a pack.';
  }

  @override
  String get permUtiliserMobile => 'Mobile app (CaisseDZ Scan)';

  @override
  String get mobileBouton => 'Mobile app';

  @override
  String get mobileTitre => 'CaisseDZ Scan mobile app';

  @override
  String get mobileEtape1 => 'Install CaisseDZ Scan.';

  @override
  String get mobileEtape2 => 'Join the same Wi-Fi.';

  @override
  String get mobileEtape3 => 'Scan this QR code.';

  @override
  String get mobileEtape4 => 'The phone is ready.';

  @override
  String get mobileAucunReseau => 'No local network found: connect this computer to the shop\'s Wi-Fi or network.';

  @override
  String mobileErreurDemarrage(String detail) {
    return 'The mobile service could not start: $detail';
  }

  @override
  String mobileQrExpire(String heure) {
    return 'Code valid until $heure';
  }

  @override
  String get mobileNouveauQr => 'New QR code';

  @override
  String get mobileActiver => 'Turn on the mobile app';

  @override
  String mobileQrDe(String nom) {
    return '$nom\'s QR code';
  }

  @override
  String get mobileDesactiver => 'Turn off';

  @override
  String mobileAppareils(int nombre) {
    return 'Paired phones ($nombre)';
  }

  @override
  String mobileMesAppareils(int nombre) {
    return 'My phones ($nombre)';
  }

  @override
  String get mobileAucunAppareil => 'No phone paired yet.';

  @override
  String mobileAppaireLe(String date) {
    return 'Paired on $date';
  }

  @override
  String mobileDernierAcces(String date) {
    return 'Last access $date';
  }

  @override
  String get mobileConnecte => 'Connected';

  @override
  String get mobileFactureRecueTitre => 'Invoice received from the phone';

  @override
  String mobileFactureRecueMessage(String nom, String bon) {
    return '$nom sent an invoice photo ($bon).';
  }

  @override
  String get mobileOuvrirSmartScan => 'Open Smart Scan';

  @override
  String get mobileRevoquer => 'Revoke';

  @override
  String mobileRevoquerTitre(String nom) {
    return 'Revoke “$nom”?';
  }

  @override
  String get mobileRevoquerMessage =>
      'This phone will no longer connect to this computer until it scans a new QR code.';

  @override
  String get catalogueRayonsTitre => 'Choose your sections';

  @override
  String get catalogueRayonsSousTitre =>
      'Based on your business, download the most popular products of each section: barcode, name and photo, without price or stock. You can add more later from Products.';

  @override
  String catalogueRayonsNbProduits(String nombre) {
    return '$nombre products';
  }

  @override
  String get catalogueRayonsBientot => 'Coming soon';

  @override
  String get catalogueRayonsDejaTelecharge => 'Already downloaded';

  @override
  String get catalogueRayonsToutSelectionner => 'Select all';

  @override
  String get catalogueRayonsToutDeselectionner => 'Clear selection';

  @override
  String catalogueRayonsSelection(int rayons, String produits) {
    String _temp0 = intl.Intl.pluralLogic(
      rayons,
      locale: localeName,
      other: '$rayons sections · $produits products',
      one: '1 section · $produits products',
      zero: 'No section chosen',
    );
    return '$_temp0';
  }

  @override
  String get catalogueRayonsPlusTard => 'Later';

  @override
  String get catalogueRayonsAppliquer => 'Apply';

  @override
  String get catalogueRayonsChargement => 'Loading sections…';

  @override
  String get catalogueRayonsHorsLigne =>
      'The BENS catalogue can\'t be reached. Check the internet connection, then try again.';

  @override
  String get catalogueRayonsReessayer => 'Try again';

  @override
  String catalogueRayonsTelechargement(String rayon) {
    return 'Downloading: $rayon…';
  }

  @override
  String catalogueRayonsProgres(String recus, String attendus) {
    return '$recus / $attendus products received';
  }

  @override
  String get catalogueRayonsEchec =>
      'The download failed: nothing was added. Check the internet connection, then try again.';

  @override
  String get catalogueRayonsResultatTitre => 'Products downloaded';

  @override
  String catalogueRayonsResultatMessage(String telecharges, String pourcentage) {
    return '$telecharges products added to your catalogue: $pourcentage % of the products of the sections chosen.';
  }

  @override
  String catalogueRayonsDejaPresents(String nombre) {
    return '$nombre products were already in your catalogue (same barcode): they were left as they were.';
  }

  @override
  String get catalogueRayonsSansPrix =>
      'These products have no price and no stock: set the price on the product sheet or at the first stock entry.';

  @override
  String catalogueRayonsLigne(String telecharges, String disponibles, String pourcentage) {
    return '$telecharges / $disponibles · $pourcentage %';
  }

  @override
  String get catalogueRayonsContinuer => 'Continue';

  @override
  String get catalogueRayonsBouton => 'BENS catalogue';

  @override
  String get prdDesignationAr => 'Arabic name';

  @override
  String get prdDesignationArIndice => 'e.g. زيت إليو 1 ل';

  @override
  String get posCatalogueTrouveTitre => 'Found in the BENS catalogue';

  @override
  String get posCatalogueCreer => 'Create from catalogue';

  @override
  String get posCatalogueRecherche => 'Searching the BENS catalogue…';

  @override
  String catalogueRayonsNbTendances(String nombre) {
    return '$nombre trending';
  }

  @override
  String get posCatalogueAConfirmerTitre => 'Product suggested by a shop';

  @override
  String posCatalogueAConfirmerQuestion(int score, int seuil) {
    return 'Is this the right product? Your answer helps confirm the catalogue ($score of $seuil).';
  }

  @override
  String get posCatalogueOui => 'Yes, that\'s it';

  @override
  String get posCatalogueNon => 'That\'s not it';

  @override
  String prixDetailHt(String montant) {
    return 'Excl. VAT $montant';
  }

  @override
  String prixDetailTva(String taux, String montant) {
    return 'VAT $taux $montant';
  }

  @override
  String prixDetailTtc(String montant) {
    return 'Incl. VAT $montant';
  }

  @override
  String get pmAffichagePrix => 'Price display';

  @override
  String get pmAffichagePrixDesc =>
      'Cart lines, quotes, proformas and orders when VAT applies. The till\'s product cards show the sale price only, without VAT.';

  @override
  String get pmAffichageTtc => 'Excl. and incl. VAT';

  @override
  String get pmAffichageTva => 'Excl. VAT and VAT';

  @override
  String get pmAffichageTous => 'Excl. VAT, VAT and incl. VAT';

  @override
  String get docTvaUnitaire => 'Unit VAT';

  @override
  String get docTotalHt => 'Total excl. VAT';

  @override
  String get entManuel => 'Manual';

  @override
  String get entManuelTitre => 'Add a product';

  @override
  String get entManuelAjouter => 'Add to the receipt';

  @override
  String get mobileChoixTitre => 'New phone to connect';

  @override
  String get mobileChoixMessage =>
      'This phone scanned your QR code. Choose the user who will open CaisseDZ Scan on this phone: it will sign in with their account and rights.';

  @override
  String get mobileChoixRefuser => 'Refuse';

  @override
  String get mobileChoixConnecter => 'Connect this phone';

  @override
  String get mobileChoixNonAutorise => 'No mobile access (role or password)';

  @override
  String mobileChoixVersion(String version) {
    return 'version $version';
  }
}
