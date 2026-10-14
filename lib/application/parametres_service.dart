import 'package:sqflite_common/sqlite_api.dart';

import '../core/print/imprimante.dart';
import '../data/boutique_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../domain/models/boutique.dart';
import '../domain/models/parametres_vente.dart';

enum ErreurParametres { nomBoutiqueVide, valeurInvalide, typeImprimanteInvalide, adresseImprimanteRequise }

class ParametresException implements Exception {
  const ParametresException(this.erreur, [this.detail]);
  final ErreurParametres erreur;
  final String? detail;
  @override
  String toString() => 'ParametresException($erreur${detail == null ? '' : ', $detail'})';
}

/// Paramètres d'impression (table `parametre`).
class ParametresImpression {
  const ParametresImpression({this.type = TypesImprimante.normale, this.adresse = '', this.largeur = '80'});
  static const String cleType = 'imprimante_type';
  static const String cleAdresse = 'imprimante_adresse';
  static const String cleLargeur = 'imprimante_largeur';
  final String type;

  /// Nom de file d'attente (USB / Bluetooth) ou `IP:port` (réseau).
  final String adresse;

  /// `58` ou `80` (mm).
  final String largeur;

  factory ParametresImpression.depuisCles(Map<String, String?> m) => ParametresImpression(
    type: m[cleType] ?? TypesImprimante.normale,
    adresse: m[cleAdresse] ?? '',
    largeur: m[cleLargeur] == '58' ? '58' : '80',
  );
  Map<String, String> versCles() => {cleType: type, cleAdresse: adresse, cleLargeur: largeur};
}

/// Paramètres de connexion aux serveurs (CaisseDZ, Mantouj).
class ParametresServeur {
  const ParametresServeur({this.url = '', this.cle = '', this.urlMantouj = ''});
  static const String cleUrl = 'serveur_url';
  static const String cleCle = 'serveur_cle';
  static const String cleMantouj = 'mantouj_url';
  final String url;
  final String cle;
  final String urlMantouj;

  factory ParametresServeur.depuisCles(Map<String, String?> m) =>
      ParametresServeur(url: m[cleUrl] ?? '', cle: m[cleCle] ?? '', urlMantouj: m[cleMantouj] ?? '');
  Map<String, String> versCles() => {cleUrl: url, cleCle: cle, cleMantouj: urlMantouj};
}

/// Paramètres (lot 8) : boutique, vente, impression, serveurs, zakat. Chaque écriture = UNE transaction + historique.
///
/// ⚠️ PROVISOIRE : la garde de stock est toujours active (non paramétrable, §8) ; liste des clés déduite de la commande.
class ParametresService {
  const ParametresService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  static const String clePrixGrammeOr = 'zakat_prix_gramme_or';

  Future<Boutique?> lireBoutique() => BoutiqueRepository(db).lire();

  Future<void> enregistrerBoutique(Boutique b) async {
    if (b.nom.trim().isEmpty) throw const ParametresException(ErreurParametres.nomBoutiqueVide);
    await db.transaction((txn) async {
      await BoutiqueRepository(txn).ecrire(b.copyWith(nom: b.nom.trim()));
      await _journal(txn, 'boutique');
    });
  }

  Future<ParametresVente> lireVente() async => ParametresVente.depuisCles(
    await ParametreRepository(db).lirePlusieurs([
      ParametresVente.cleMarge,
      ParametresVente.cleSeuil,
      ParametresVente.cleFidelite,
      ParametresVente.clePoints,
      ParametresVente.cleDevise,
    ]),
  );

  Future<void> enregistrerVente(ParametresVente p) async {
    if (p.margeDefautPct < 0 || p.margeDefautPct > 1000 || p.seuilStockGlobal < 0 || p.pointsParDinar < 0) {
      throw const ParametresException(ErreurParametres.valeurInvalide);
    }
    if (p.devise.trim().isEmpty) throw const ParametresException(ErreurParametres.valeurInvalide, 'devise');
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs(p.copyWith(devise: p.devise.trim()).versCles());
      await _journal(txn, 'vente');
    });
  }

  Future<ParametresImpression> lireImpression() async => ParametresImpression.depuisCles(
    await ParametreRepository(
      db,
    ).lirePlusieurs([ParametresImpression.cleType, ParametresImpression.cleAdresse, ParametresImpression.cleLargeur]),
  );

  Future<void> enregistrerImpression(ParametresImpression p) async {
    if (!TypesImprimante.tous.contains(p.type)) {
      throw const ParametresException(ErreurParametres.typeImprimanteInvalide);
    }
    if (p.type != TypesImprimante.normale && p.adresse.trim().isEmpty) {
      throw const ParametresException(ErreurParametres.adresseImprimanteRequise);
    }
    if (p.largeur != '58' && p.largeur != '80') throw const ParametresException(ErreurParametres.valeurInvalide);
    await db.transaction((txn) async {
      await ParametreRepository(txn)
          .ecrirePlusieurs({...p.versCles(), ParametresImpression.cleAdresse: p.adresse.trim()});
      await _journal(txn, 'impression');
    });
  }

  Future<ParametresServeur> lireServeur() async => ParametresServeur.depuisCles(
    await ParametreRepository(db)
        .lirePlusieurs([ParametresServeur.cleUrl, ParametresServeur.cleCle, ParametresServeur.cleMantouj]),
  );

  Future<void> enregistrerServeur(ParametresServeur p) async {
    for (final u in [p.url, p.urlMantouj]) {
      final t = u.trim();
      if (t.isNotEmpty && !(t.startsWith('http://') || t.startsWith('https://'))) {
        throw ParametresException(ErreurParametres.valeurInvalide, t);
      }
    }
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs({
        ParametresServeur.cleUrl: p.url.trim().replaceAll(RegExp(r'/+$'), ''),
        ParametresServeur.cleCle: p.cle.trim(),
        ParametresServeur.cleMantouj: p.urlMantouj.trim().replaceAll(RegExp(r'/+$'), ''),
      });
      await _journal(txn, 'serveur');
    });
  }

  Future<double> lirePrixGrammeOr() async =>
      double.tryParse(await ParametreRepository(db).lire(clePrixGrammeOr) ?? '') ?? 0;

  Future<void> enregistrerPrixGrammeOr(double prix) async {
    if (prix < 0) throw const ParametresException(ErreurParametres.valeurInvalide);
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrire(clePrixGrammeOr, prix.toString());
      await _journal(txn, 'zakat');
    });
  }

  Future<void> _journal(Transaction txn, String section) => HistoriqueRepository(txn)
      .journaliser(utilisateurCode: utilisateurCode, action: 'Paramètres', entite: 'parametre', entiteCode: section);
}
