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
];
