import 'dart:io';

import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/db/migration_runner.dart';
import 'package:caissedz_desktop/core/db/migrations/migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import '../../helpers/bases.dart';

void main() {
  group('AppDatabase', () {
    test('ouvre une base chiffrée, applique les migrations et active les FK', () async {
      final base = await ouvrirBaseDeTest();
      expect(await base.version(), toutesLesMigrations.last.version);
      expect(await base.clesEtrangeresActives(), isTrue);
      final journal = await base.db.query('journal_migration', orderBy: 'version');
      expect(journal.map((r) => r['version']), List.generate(toutesLesMigrations.length, (i) => i + 1));
      expect(await AppDatabase.fichierEstChiffre(base.chemin), isTrue);
    });

    test('est idempotente : une seconde ouverture n’applique aucune migration', () async {
      final dossier = Directory.systemTemp.createTempSync('caissedz_test_');
      addTearDown(() => dossier.deleteSync(recursive: true));
      final b1 = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleTestHex);
      await b1.db.insert('parametre_app', {'cle': 'x', 'valeur': '1'});
      await b1.fermer();
      final b2 = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleTestHex);
      addTearDown(b2.fermer);
      expect(await b2.version(), toutesLesMigrations.last.version);
      expect((await b2.db.query('parametre_app')).length, 1);
      expect((await b2.db.query('journal_migration')).length, toutesLesMigrations.length);
    });

    test('refuse une clé incorrecte', () async {
      final dossier = Directory.systemTemp.createTempSync('caissedz_test_');
      addTearDown(() => dossier.deleteSync(recursive: true));
      final b1 = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleTestHex);
      await b1.fermer();
      final mauvaise = cleTestHex.replaceRange(0, 4, 'ffff');
      await expectLater(
        AppDatabase.ouvrir(dossier: dossier.path, cleHex: mauvaise),
        throwsA(isA<CleBaseInvalideException>()),
      );
      expect(File(p.join(dossier.path, AppDatabase.nomFichier)).existsSync(), isTrue);
    });

    test('les clés étrangères sont réellement appliquées', () async {
      final base = await ouvrirBaseDeTest();
      await base.db.execute('CREATE TABLE parent (code TEXT PRIMARY KEY)');
      await base.db.execute(
        'CREATE TABLE enfant (id INTEGER PRIMARY KEY, parent_code TEXT NOT NULL REFERENCES parent(code))',
      );
      await expectLater(base.db.insert('enfant', {'parent_code': 'INEXISTANT'}), throwsA(anything));
    });
  });

  group('MigrationRunner', () {
    test('refuse des versions non contiguës', () {
      const runner = MigrationRunner([_MigrationFausse(2)]);
      expect(() => runner.executer(_BaseNulle()), throwsStateError);
    });
  });
}

class _MigrationFausse extends Migration {
  const _MigrationFausse(this.v);
  final int v;
  @override
  int get version => v;
  @override
  String get description => 'fausse';
  @override
  Future<void> appliquer(txn) async {}
}

// Le contrôle d'ordre s'effectue avant tout accès à la base.
class _BaseNulle implements Database {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
