import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../data/boutique_repository.dart';
import '../../data/caisse_repository.dart';
import '../../data/vente_repository.dart';
import '../../domain/code_generator.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/vente.dart';
import '../../domain/scellement.dart';

/// Résultat de la vérification d'un export fiscal.
class VerificationExport {
  const VerificationExport({
    required this.empreinteOk,
    required this.chaineVentesOk,
    required this.chaineCloturesOk,
    required this.nbVentes,
    required this.nbClotures,
    this.erreurs = const [],
  });
  final bool empreinteOk;
  final bool chaineVentesOk;
  final bool chaineCloturesOk;
  final int nbVentes;
  final int nbClotures;
  final List<String> erreurs;
  bool get valide => empreinteOk && chaineVentesOk && chaineCloturesOk && erreurs.isEmpty;
}

/// Export fiscal (§12) : archive ZIP contenant `export.json` (ventes scellées, clôtures Z chaînées,
/// empreinte SHA-256 globale), `ventes.csv`, `clotures.csv` et `LISEZMOI.txt`.
///
/// ⚠️ PROVISOIRE : format JSON déduit de la commande, à aligner sur §12 dès que la spec est disponible.
class ExportFiscal {
  const ExportFiscal(this.db, {this.versionLogiciel = '0.1.0'});
  final DatabaseExecutor db;
  final String versionLogiciel;

  static const String nomLogiciel = 'CaisseDZ Desktop';
  static const String formatVersion = '1';

  /// Construit le document JSON de la période (bornes incluses).
  Future<Map<String, Object?>> document({
    required DateTime debut,
    required DateTime fin,
    required String utilisateurCode,
    DateTime? genereLe,
  }) async {
    final boutique = await BoutiqueRepository(db).lire();
    final ventes = (await VenteRepository(db).ventes(depuis: debut, jusqua: fin, limite: 1 << 30, avecLignes: true))
      ..sort((a, b) => CodeGenerator.comparer(a.code, b.code));
    final clotures = await CaisseRepository(db).clotures(debut: debut, fin: fin, croissant: true);
    final donnees = <String, Object?>{
      'ventes': [for (final v in ventes) _vente(v)],
      'clotures': [for (final c in clotures) c.versLigne()],
    };
    return {
      'format': formatVersion,
      'logiciel': {'nom': nomLogiciel, 'version': versionLogiciel},
      'boutique': boutique == null
          ? null
          : {
              'nom': boutique.nom,
              'rc': boutique.rc,
              'nif': boutique.nif,
              'adresse': boutique.adresse,
              'telephone': boutique.telephone,
              'email': boutique.email,
            },
      'periode': {'debut': debut.toUtc().toIso8601String(), 'fin': fin.toUtc().toIso8601String()},
      'genere_le': (genereLe ?? DateTime.now()).toUtc().toIso8601String(),
      'genere_par': utilisateurCode,
      'donnees': donnees,
      'empreinte': empreinte(donnees),
    };
  }

  /// Archive ZIP de l'export.
  Future<Uint8List> generer({
    required DateTime debut,
    required DateTime fin,
    required String utilisateurCode,
    DateTime? genereLe,
  }) async {
    final doc = await document(debut: debut, fin: fin, utilisateurCode: utilisateurCode, genereLe: genereLe);
    final donnees = doc['donnees'] as Map<String, Object?>;
    final archive = Archive()
      ..addFile(ArchiveFile.string('export.json', const JsonEncoder.withIndent('  ').convert(doc)))
      ..addFile(ArchiveFile.string('ventes.csv', _csvVentes(donnees['ventes'] as List)))
      ..addFile(ArchiveFile.string('clotures.csv', _csvClotures(donnees['clotures'] as List)))
      ..addFile(ArchiveFile.string('LISEZMOI.txt', _lisezMoi(doc)));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// JSON de contrôle seul (`export.json`).
  Future<Uint8List> genererJson({
    required DateTime debut,
    required DateTime fin,
    required String utilisateurCode,
    DateTime? genereLe,
  }) async {
    final doc = await document(debut: debut, fin: fin, utilisateurCode: utilisateurCode, genereLe: genereLe);
    return Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(doc)));
  }

  /// Tickets ligne à ligne (`ventes.csv`, UTF-8 avec BOM pour Excel).
  Future<Uint8List> genererCsv({
    required DateTime debut,
    required DateTime fin,
    required String utilisateurCode,
  }) async {
    final doc = await document(debut: debut, fin: fin, utilisateurCode: utilisateurCode);
    final ventes = (doc['donnees'] as Map<String, Object?>)['ventes'] as List;
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(_csvVentes(ventes))]);
  }

  /// Empreinte SHA-256 du bloc de données canonique.
  static String empreinte(Map<String, Object?> donnees) =>
      sha256.convert(utf8.encode(Scellement.canonique(donnees))).toString();

  /// Vérifie une archive (ou un `export.json` brut) : empreinte, chaîne des ventes, chaîne des clôtures.
  static VerificationExport verifier(Uint8List contenu) {
    Map<String, Object?> doc;
    try {
      String json;
      if (contenu.length > 1 && contenu[0] == 0x50 && contenu[1] == 0x4B) {
        final archive = ZipDecoder().decodeBytes(contenu);
        final f = archive.findFile('export.json');
        if (f == null) {
          return const VerificationExport(
            empreinteOk: false,
            chaineVentesOk: false,
            chaineCloturesOk: false,
            nbVentes: 0,
            nbClotures: 0,
            erreurs: ['export.json absent'],
          );
        }
        json = utf8.decode(f.content as List<int>);
      } else {
        json = utf8.decode(contenu);
      }
      doc = (jsonDecode(json) as Map).cast<String, Object?>();
    } catch (e) {
      return VerificationExport(
        empreinteOk: false,
        chaineVentesOk: false,
        chaineCloturesOk: false,
        nbVentes: 0,
        nbClotures: 0,
        erreurs: ['contenu illisible : $e'],
      );
    }
    final erreurs = <String>[];
    final donnees = (doc['donnees'] as Map).cast<String, Object?>();
    final empreinteOk = empreinte(donnees) == doc['empreinte'];
    if (!empreinteOk) erreurs.add('empreinte');
    final ventes = (donnees['ventes'] as List).cast<Map>().map((m) => m.cast<String, Object?>()).toList();
    final chaineVentes = <({Map<String, Object?> doc, String hashPrecedent, String hash})>[];
    for (final m in ventes) {
      final v = Vente.depuisLigne(
        m,
        lignes: (m['lignes'] as List).map((l) => VenteLigne.depuisLigne((l as Map).cast())).toList(),
        paiements: (m['paiements'] as List)
            .map((p) => Paiement(mode: p['mode'] as String, montant: (p['montant'] as num).toDouble()))
            .toList(),
      );
      chaineVentes.add((doc: v.versCanonique(), hashPrecedent: v.hashPrecedent, hash: v.hash));
    }
    final iv = Scellement.verifier(chaineVentes);
    if (iv != null) erreurs.add('vente ${ventes[iv]['code']}');
    final clotures = (donnees['clotures'] as List).cast<Map>().map((m) => Cloture.depuisLigne(m.cast())).toList();
    final ic = Cloture.verifierChaines(clotures);
    if (ic != null) erreurs.add('clôture $ic');
    return VerificationExport(
      empreinteOk: empreinteOk,
      chaineVentesOk: iv == null,
      chaineCloturesOk: ic == null,
      nbVentes: ventes.length,
      nbClotures: clotures.length,
      erreurs: erreurs,
    );
  }

  static Map<String, Object?> _vente(Vente v) => {
    ...v.versLigne(),
    'lignes': [
      for (final l in v.lignes)
        {
          'ordre': l.ordre,
          'produit_code': l.produitCode,
          'colis_code': l.colisCode,
          'pack_code': l.packCode,
          'designation': l.designation,
          'quantite': l.quantite,
          'nombre': l.nombre,
          'unite_vente': l.uniteVente,
          'prix_unitaire': l.prixUnitaire,
          'remise': l.remise,
          'total': l.total,
        },
    ],
    'paiements': [
      for (final p in v.paiements) {'mode': p.mode, 'montant': p.montant, 'reference': p.reference},
    ],
  };

  static String _csv(List<List<Object?>> lignes) =>
      lignes.map((l) => l.map((c) => '"${(c ?? '').toString().replaceAll('"', '""')}"').join(';')).join('\r\n');

  static String _csvVentes(List ventes) => _csv([
    ['code', 'date', 'caisse', 'magasin', 'client', 'brut', 'remise', 'net', 'verse', 'reste', 'statut', 'hash'],
    for (final v in ventes.cast<Map>())
      [
        v['code'],
        v['date'],
        v['caisse_code'],
        v['magasin_code'],
        v['client_code'],
        v['total_brut'],
        v['total_remise'],
        v['total_net'],
        v['verse'],
        v['reste'],
        v['statut'],
        v['hash'],
      ],
  ]);

  static String _csvClotures(List clotures) => _csv([
    [
      'code',
      'caisse',
      'date',
      'debut',
      'fin',
      'nb_ventes',
      'nb_annulations',
      'total_ventes',
      'total_annule',
      'encaissements',
      'decaissements',
      'hash',
    ],
    for (final c in clotures.cast<Map>())
      [
        c['code'],
        c['caisse_code'],
        c['date'],
        c['debut'],
        c['fin'],
        c['nb_ventes'],
        c['nb_annulations'],
        c['total_ventes'],
        c['total_annule'],
        c['total_encaissements'],
        c['total_decaissements'],
        c['hash'],
      ],
  ]);

  static String _lisezMoi(Map<String, Object?> doc) {
    final p = doc['periode'] as Map;
    return '''
$nomLogiciel — export fiscal (format $formatVersion)
Période : ${p['debut']} → ${p['fin']}
Généré le : ${doc['genere_le']} par ${doc['genere_par']}
Empreinte SHA-256 des données : ${doc['empreinte']}

export.json : ventes scellées (hash chaîné SHA-256) et clôtures Z chaînées par caisse, vérifiables hors ligne.
ventes.csv / clotures.csv : extraits lisibles des mêmes données.
''';
  }
}
