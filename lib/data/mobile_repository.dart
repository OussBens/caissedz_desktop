import 'package:sqflite_common/sqlite_api.dart';

import '../domain/models/appareil_mobile.dart';
import '../domain/permissions.dart';

/// Téléphones appairés (`appareil_mobile`) et lectures propres à l'application mobile CaisseDZ Scan.
class MobileRepository {
  const MobileRepository(this.db);

  final DatabaseExecutor db;

  // ---- Appareils ----

  /// Téléphones appairés, tous ou ceux de [utilisateurCode].
  Future<List<AppareilMobile>> appareils({String? utilisateurCode}) async => [
    for (final r in await db.query(
      'appareil_mobile',
      where: utilisateurCode == null ? null : 'utilisateur_code = ?',
      whereArgs: utilisateurCode == null ? null : [utilisateurCode],
      orderBy: 'cree_le DESC',
    ))
      AppareilMobile.depuisLigne(r),
  ];

  Future<AppareilMobile?> appareil(String code) async {
    final r = await db.query('appareil_mobile', where: 'code = ?', whereArgs: [code]);
    return r.isEmpty ? null : AppareilMobile.depuisLigne(r.first);
  }

  /// Empreinte du jeton de l'appareil (null s'il n'existe pas).
  Future<String?> empreinteJeton(String code) async {
    final r = await db.query('appareil_mobile', columns: ['jeton_hash'], where: 'code = ?', whereArgs: [code]);
    return r.isEmpty ? null : r.first['jeton_hash'] as String?;
  }

  Future<void> insererAppareil({
    required String code,
    required String utilisateurCode,
    required String nom,
    required String plateforme,
    required String jetonHash,
    String? identifiant,
    String modele = '',
    String? creePar,
  }) => db.insert('appareil_mobile', {
    'code': code,
    'utilisateur_code': utilisateurCode,
    'nom': nom,
    'plateforme': plateforme,
    'identifiant': identifiant,
    'modele': modele,
    'jeton_hash': jetonHash,
    'cree_le': DateTime.now().toUtc().toIso8601String(),
    'cree_par': creePar,
    'actif': 1,
  });

  Future<void> enregistrerAcces(String code, {String? utilisateurCode}) => db.update(
    'appareil_mobile',
    {'dernier_acces': DateTime.now().toUtc().toIso8601String(), 'dernier_utilisateur': ?utilisateurCode},
    where: 'code = ?',
    whereArgs: [code],
  );

  /// Appairages précédents du même téléphone, que son nouvel appairage remplace : même [identifiant] (ou
  /// [ancienIdentifiant] : l'identifiant d'installation qu'il envoyait avant l'identifiant de l'appareil) ; sans
  /// identifiant (application plus ancienne), même utilisateur, nom et plateforme.
  Future<List<String>> precedents({
    required String? identifiant,
    String? ancienIdentifiant,
    required String utilisateurCode,
    required String nom,
    required String plateforme,
  }) async => [
    for (final r
        in identifiant != null
            ? await db.query(
                'appareil_mobile',
                columns: ['code'],
                where: 'identifiant IN (?, ?)',
                whereArgs: [identifiant, ancienIdentifiant ?? identifiant],
              )
            : await db.query(
                'appareil_mobile',
                columns: ['code'],
                where: 'identifiant IS NULL AND utilisateur_code = ? AND nom = ? AND plateforme = ?',
                whereArgs: [utilisateurCode, nom, plateforme],
              ))
      r['code']! as String,
  ];

  Future<void> revoquer(String code) => db.delete('appareil_mobile', where: 'code = ?', whereArgs: [code]);

  // ---- Lectures ----

  /// Est-il autorisé sur mobile (voir [utilisateursAutorises]) ?
  Future<bool> estAutorise(String utilisateurCode) async => (await utilisateursAutorises()).contains(utilisateurCode);

  /// Codes des utilisateurs autorisés sur mobile : actifs, avec un mot de passe, Admin ou rôle ayant
  /// la permission `utiliserMobile`.
  Future<Set<String>> utilisateursAutorises() async => {
    for (final r in await db.rawQuery(
      '''
      SELECT u.code FROM utilisateur u
      WHERE u.actif = 1 AND u.mot_de_passe IS NOT NULL AND u.mot_de_passe <> ''
        AND (u.role_code = ? OR EXISTS (SELECT 1 FROM role_permission rp
              WHERE rp.role_code = u.role_code AND rp.permission = ?))
      ''',
      [Roles.admin, Permission.utiliserMobile.code],
    ))
      r['code']! as String,
  };

  /// Noms des clients par code.
  Future<Map<String, String>> nomsClients(Iterable<String> codes) async {
    final liste = codes.toSet().toList();
    if (liste.isEmpty) return const {};
    final rows = await db.query(
      'client',
      columns: ['code', 'nom'],
      where: 'code IN (${List.filled(liste.length, '?').join(',')})',
      whereArgs: liste,
    );
    return {for (final r in rows) r['code']! as String: r['nom']! as String};
  }

  /// Chiffre d'affaires et nombre de ventes validées depuis [depuis].
  Future<({double total, int nombre})> ventesDepuis(DateTime depuis) async {
    final r = await db.rawQuery(
      "SELECT COALESCE(SUM(total_net), 0) t, COUNT(*) n FROM vente WHERE date >= ? AND statut <> 'Annulée'",
      [depuis.toUtc().toIso8601String()],
    );
    return (total: (r.first['t']! as num).toDouble(), nombre: r.first['n']! as int);
  }

  /// Bons de réception envoyés par [utilisateurCode] (les plus récents d'abord).
  Future<List<Map<String, Object?>>> bonsEnvoyes(String utilisateurCode, {int limite = 50}) => db.query(
    'bon_reception',
    columns: ['code', 'date_reception', 'fichier', 'statut', 'nb_lignes', 'achat_code'],
    where: 'utilisateur_code = ?',
    whereArgs: [utilisateurCode],
    orderBy: 'date_reception DESC, code DESC',
    limit: limite,
  );
}
