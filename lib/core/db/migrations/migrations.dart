import 'migration.dart';
import 'v001_socle.dart';
import 'v002_demarrage.dart';
import 'v003_catalogue.dart';
import 'v004_stock.dart';
import 'v005_caisse.dart';
import 'v006_tiers.dart';
import 'v007_gestion_caisse.dart';
import 'v008_shell_ds.dart';
import 'v009_ecrans_ds.dart';
import 'v010_couts_ventes.dart';
import 'v011_type_panier.dart';
import 'v012_retours.dart';
import 'v013_produits.dart';
import 'v014_stock_ds.dart';
import 'v015_entrees.dart';
import 'v016_gestion_caisse.dart';
import 'v017_utilisateurs_roles.dart';
import 'v018_zakat.dart';
import 'v019_historique.dart';
import 'v020_audit.dart';
import 'v021_vente_montant.dart';
import 'v022_audit_complement.dart';
import 'v023_sortie_retour.dart';
import 'v024_codes_entree.dart';
import 'v025_reference_versement.dart';
import 'v026_journal_caisse_immuable.dart';
import 'v027_solde_tiers.dart';
import 'v028_retours_lignes.dart';
import 'v029_prix_entree.dart';
import 'v030_integrite_fiscale.dart';
import 'v031_fiscalite.dart';
import 'v032_inventaire_types.dart';
import 'v033_solde_initial.dart';
import 'v034_documents_commerciaux.dart';
import 'v035_licence_bens.dart';
import 'v036_appareils_mobiles.dart';
import 'v037_appareil_utilisateur.dart';
import 'v038_catalogue_rayons.dart';

export 'migration.dart';

/// Liste ordonnée de toutes les migrations du schéma.
const List<Migration> toutesLesMigrations = [
  MigrationV001Socle(),
  MigrationV002Demarrage(),
  MigrationV003Catalogue(),
  MigrationV004Stock(),
  MigrationV005Caisse(),
  MigrationV006Tiers(),
  MigrationV007GestionCaisse(),
  MigrationV008ShellDs(),
  MigrationV009EcransDs(),
  MigrationV010CoutsVentes(),
  MigrationV011TypePanier(),
  MigrationV012Retours(),
  MigrationV013Produits(),
  MigrationV014StockDs(),
  MigrationV015Entrees(),
  MigrationV016GestionCaisse(),
  MigrationV017UtilisateursRoles(),
  MigrationV018Zakat(),
  MigrationV019Historique(),
  MigrationV020Audit(),
  MigrationV021VenteMontant(),
  MigrationV022AuditComplement(),
  MigrationV023SortieRetour(),
  MigrationV024CodesEntree(),
  MigrationV025ReferenceVersement(),
  MigrationV026JournalCaisseImmuable(),
  MigrationV027SoldeTiers(),
  MigrationV028RetoursLignes(),
  MigrationV029PrixEntree(),
  MigrationV030IntegriteFiscale(),
  MigrationV031Fiscalite(),
  MigrationV032InventaireTypes(),
  MigrationV033SoldeInitial(),
  MigrationV034DocumentsCommerciaux(),
  MigrationV035LicenceBens(),
  MigrationV036AppareilsMobiles(),
  MigrationV037AppareilUtilisateur(),
  MigrationV038CatalogueRayons(),
];
