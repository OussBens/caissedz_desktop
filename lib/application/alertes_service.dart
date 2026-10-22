import 'package:sqflite_common/sqlite_api.dart';

import '../data/alertes_repository.dart';
import '../data/parametre_repository.dart';
import '../data/parametres_repository.dart';
import '../data/stock_repository.dart';
import '../domain/models/alerte.dart';
import '../domain/models/session.dart';

/// Alertes du jour (§5.3, `AlertesServices.getAlertes`) : chaque famille n'est visible que si le rôle
/// a accès au module concerné. Expirés : date d'expiration passée ; bientôt expirés : dans au plus
/// [joursExpiration] jours (produits encore en stock). Les ruptures ne sont plus une famille : l'alerte produit
/// « Rupture sans commande » (#14, `AlertesProduitsService`) les signale dans le même dialog.
class AlertesService {
  const AlertesService(this.db);

  final Database db;

  static const int nbTiers = 3;
  static const int joursExpiration = 30;

  static String _cleMasque(String utilisateurCode) => 'alertes_masquees_$utilisateurCode';
  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _jour(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<AlertesDuJour> calculer(Session session, {DateTime? maintenant}) async {
    final now = maintenant ?? DateTime.now();
    final repo = AlertesRepository(db);
    final parFamille = <FamilleAlerte, List<Alerte>>{};

    if (['produits', 'stock', 'besoins'].any(session.peutAcceder)) {
      final magasins = session.estAdmin
          ? null
          : await StockRepository(db).magasinsUtilisateur(session.utilisateur.code);
      final jour = DateTime(now.year, now.month, now.day);
      final limite = jour.add(const Duration(days: joursExpiration));
      parFamille[FamilleAlerte.expire] = [];
      parFamille[FamilleAlerte.bientot] = [];
      for (final r in await repo.expirations(jusquA: _iso(limite), magasins: magasins)) {
        final le = DateTime.parse(r['expire_le']! as String);
        final jours = DateTime(le.year, le.month, le.day).difference(jour).inDays;
        final famille = jours < 0 ? FamilleAlerte.expire : FamilleAlerte.bientot;
        parFamille[famille]!.add(
          Alerte(
            famille: famille,
            cle: r['code']! as String,
            titre: r['designation']! as String,
            detail: [r['code'], r['categorie']].where((e) => '$e'.isNotEmpty).join(' · '),
            valeur: jours.toDouble(),
            date: le,
            critique: jours < 0,
          ),
        );
      }
    }
    if (session.peutAcceder('gestion_caisse')) {
      parFamille[FamilleAlerte.sessions] = [
        for (final r in await repo.sessionsAnciennes(DateTime(now.year, now.month, now.day)))
          Alerte(
            famille: FamilleAlerte.sessions,
            cle: r['code']! as String,
            titre: r['caisse']! as String,
            detail: '${r['code']} · ${r['utilisateur']}',
            date: DateTime.tryParse(r['ouverte_le']! as String)?.toLocal(),
            critique: true,
          ),
      ];
    }
    if (session.peutAcceder('clients')) {
      parFamille[FamilleAlerte.clients] = [
        for (final r in await repo.creditsClients(limite: nbTiers, seuil: await _seuilCredit()))
          _tiers(FamilleAlerte.clients, r),
      ];
    }
    if (session.peutAcceder('fournisseurs')) {
      parFamille[FamilleAlerte.fournisseurs] = [
        for (final r in await repo.dettesFournisseurs(limite: nbTiers)) _tiers(FamilleAlerte.fournisseurs, r),
      ];
    }
    return AlertesDuJour(parFamille);
  }

  Future<double> _seuilCredit() async => double.tryParse(await ParametreRepository(db).lire(cleSeuilCredit) ?? '') ?? 0;

  /// Paramètres › Alertes : seuil de crédit client signalé et ouverture automatique à la connexion.
  static const String cleSeuilCredit = 'alertes_seuil_credit';
  static const String cleConnexion = 'alertes_connexion';

  /// `false` si l'administrateur a désactivé l'ouverture des alertes à la connexion.
  Future<bool> afficherALaConnexion() async => (await ParametreRepository(db).lire(cleConnexion) ?? '1') == '1';

  Alerte _tiers(FamilleAlerte famille, Map<String, Object?> r) => Alerte(
    famille: famille,
    cle: r['code']! as String,
    titre: r['nom']! as String,
    detail: r['code']! as String,
    valeur: (r['du']! as num).toDouble(),
    date: DateTime.tryParse((r['derniere'] as String?) ?? '')?.toLocal(),
  );

  /// « Ne plus afficher aujourd'hui » : les alertes ne s'ouvrent plus seules à la connexion ce jour-là.
  Future<void> masquerAujourdhui(String utilisateurCode, {DateTime? maintenant}) =>
      ParametresAppRepository(db).ecrire(_cleMasque(utilisateurCode), _jour(maintenant ?? DateTime.now()));

  Future<bool> estMasqueAujourdhui(String utilisateurCode, {DateTime? maintenant}) async =>
      await ParametresAppRepository(db).lire(_cleMasque(utilisateurCode)) == _jour(maintenant ?? DateTime.now());
}
