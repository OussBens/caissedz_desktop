import 'migration.dart';
import 'v001_socle.dart';
import 'v002_demarrage.dart';

export 'migration.dart';

/// Liste ordonnée de toutes les migrations du schéma.
const List<Migration> toutesLesMigrations = [
  MigrationV001Socle(),
  MigrationV002Demarrage(),
];
