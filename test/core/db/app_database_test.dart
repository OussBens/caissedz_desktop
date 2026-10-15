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

  group('Migration v12 (retours reconstruits)', () {
    test('conserve retours, lignes et versements liés ; clés étrangères réactivées', () async {
      final base = await AppDatabase.ouvrirEnMemoire(
        cleHex: cleTestHex,
        migrations: toutesLesMigrations.sublist(0, 11),
      );
      addTearDown(base.fermer);
      final db = base.db;
      const iso = '2026-01-05T10:00:00.000Z';
      await db.insert('produit', {
        'code': 'PRD0001',
        'designation': 'Lait',
        'categorie_code': 'CATE0000',
        'sous_categorie_code': 'SC0000',
        'prix_achat': 80,
      });
      await db.insert('session_caisse', {
        'code': 'SES0001',
        'caisse_code': 'CIS0000',
        'utilisateur_code': 'USR0000',
        'ouverte_le': iso,
      });
      await db.insert('vente', {
        'code': 'VTE0001',
        'date': iso,
        'session_code': 'SES0001',
        'caisse_code': 'CIS0000',
        'magasin_code': 'MAG0000',
        'client_code': 'CLN0000',
        'utilisateur_code': 'USR0000',
        'total_brut': 100,
        'total_remise': 0,
        'total_net': 100,
        'verse': 100,
        'reste': 0,
        'hash': 'h',
        'hash_precedent': 'GENESIS',
      });
      await db.insert('retour', {
        'code': 'RET0001',
        'date': iso,
        'vente_code': 'VTE0001',
        'client_code': 'CLN0000',
        'magasin_code': 'MAG0000',
        'utilisateur_code': 'USR0000',
        'total': 100,
        'rembourse': 100,
      });
      await db.insert('retour_ligne', {
        'retour_code': 'RET0001',
        'ordre': 0,
        'produit_code': 'PRD0001',
        'designation': 'Lait',
        'quantite': 1,
        'prix_unitaire': 100,
        'total': 100,
      });
      await db.insert('versement', {
        'code': 'VER0001',
        'date': iso,
        'tiers_type': 'Client',
        'tiers_code': 'CLN0000',
        'sens': 'Décaissement',
        'montant': 100,
        'mode': 'Espèces',
        'utilisateur_code': 'USR0000',
        'retour_code': 'RET0001',
      });

      expect(await const MigrationRunner(toutesLesMigrations).executer(db), [12, 13, 14]);
      final r = (await db.query('retour')).single;
      expect(r['type'], 'Client');
      expect(r['document_code'], 'VTE0001');
      expect(r['reglement'], 'Espèces');
      expect(r['etat'], 1);
      final l = (await db.query('retour_ligne')).single;
      expect(l['prix_achat'], 80);
      expect((await db.query('versement')).single['retour_code'], 'RET0001');
      expect(await base.clesEtrangeresActives(), isTrue);
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      await expectLater(
        db.insert('retour', {
          'code': 'RET0002',
          'date': iso,
          'type': 'Fournisseur',
          'document_code': 'ACH0001',
          'magasin_code': 'MAG0000',
          'utilisateur_code': 'USR0000',
          'total': 1,
        }),
        throwsA(anything), // fournisseur obligatoire pour un retour fournisseur
      );
    });
  });

  group('Migration v13 (fiche produit)', () {
    test('ajoute les champs produit avec leurs valeurs par défaut et les codes-barres secondaires', () async {
      final base = await AppDatabase.ouvrirEnMemoire(
        cleHex: cleTestHex,
        migrations: toutesLesMigrations.sublist(0, 12),
      );
      addTearDown(base.fermer);
      final db = base.db;
      await db.insert('produit', {
        'code': 'PRD0001',
        'designation': 'Lait',
        'categorie_code': 'CATE0000',
        'sous_categorie_code': 'SC0000',
        'code_barres': '6130000000015',
      });
      expect(await const MigrationRunner(toutesLesMigrations).executer(db), [13, 14]);
      final p = (await db.query('produit')).single;
      expect(p['service'], 0);
      expect(p['suivi_serie'], 0);
      expect(p['marque'], isNull);
      expect((await db.query('categorie', where: "code = 'CATE0000'")).single['actif'], 1);
      await db.insert('produit_code_detail', {'produit_code': 'PRD0001', 'code_barres': '2000000000015'});
      await expectLater(
        db.insert('produit_code_detail', {'produit_code': 'PRD0001', 'code_barres': '2000000000015'}),
        throwsA(anything),
      );
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    });
  });

  group('Migration v14 (stock DS)', () {
    test('ancien besoin → liste fournisseur d\'une ligne ; sorties valorisées ; annulation douce', () async {
      final base = await AppDatabase.ouvrirEnMemoire(
        cleHex: cleTestHex,
        migrations: toutesLesMigrations.sublist(0, 13),
      );
      addTearDown(base.fermer);
      final db = base.db;
      await db.insert('produit', {
        'code': 'PRD0001',
        'designation': 'Lait',
        'categorie_code': 'CATE0000',
        'sous_categorie_code': 'SC0000',
        'prix_achat': 80,
      });
      await db.insert('besoin', {
        'code': 'BES0001',
        'date': '2026-10-01T10:00:00Z',
        'produit_code': 'PRD0001',
        'quantite': 12,
        'statut': 'Commande',
        'utilisateur_code': 'USR0000',
      });
      await db.insert('sortie_stock', {
        'code': 'SOR0001',
        'date': '2026-10-01T10:00:00Z',
        'magasin_code': 'MAG0000',
        'motif': 'Casse',
        'utilisateur_code': 'USR0000',
      });
      await db.insert('sortie_stock_ligne', {'sortie_code': 'SOR0001', 'produit_code': 'PRD0001', 'quantite': 2});
      expect(await const MigrationRunner(toutesLesMigrations).executer(db), [14]);
      final b = (await db.query('besoin')).single;
      expect(b['fournisseur_code'], 'FOR0000');
      expect(b['statut'], 'Commande');
      expect(b['actif'], 1);
      final l = (await db.query('besoin_ligne')).single;
      expect(l['quantite'], 12);
      expect(l['prix'], 80);
      expect((await db.query('sortie_stock_ligne')).single['prix'], 80);
      expect((await db.query('sortie_stock')).single['actif'], 1);
      expect((await db.query('magasin', where: "code = 'MAG0000'")).single['telephone'], '');
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
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
