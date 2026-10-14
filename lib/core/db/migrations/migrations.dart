import 'migration.dart';
import 'v001_socle.dart';
import 'v002_demarrage.dart';
import 'v003_catalogue.dart';
import 'v004_stock.dart';
import 'v005_caisse.dart';

export 'migration.dart';

/// Liste ordonnée de toutes les migrations du schéma.
const List<Migration> toutesLesMigrations = [
  MigrationV001Socle(),
  MigrationV002Demarrage(),
  MigrationV003Catalogue(),
  MigrationV004Stock(),
  MigrationV005Caisse(),
];
