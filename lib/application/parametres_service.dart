import 'package:sqflite_common/sqlite_api.dart';

import '../core/print/imprimante.dart';
import '../data/boutique_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../domain/models/boutique.dart';
import '../domain/models/parametres_paiement.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/zakat.dart';
import 'alertes_service.dart';

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

/// Nissab et taux de la zakat (Paramètres › Système).
class ParametresZakat {
  const ParametresZakat({this.nissab = 0, this.tauxPct = CalculZakat.tauxDefautPct});
  final double nissab;
  final double tauxPct;
}

/// Alertes (Paramètres › Alertes) : ouverture automatique à la connexion, seuil de crédit client signalé.
class ParametresAlertes {
  const ParametresAlertes({this.afficherConnexion = true, this.seuilCreditClient = 0});
  static const String cleConnexion = AlertesService.cleConnexion;
  static const String cleSeuilCredit = AlertesService.cleSeuilCredit;
  static const List<String> cles = [cleConnexion, cleSeuilCredit];
  final bool afficherConnexion;

  /// Les clients dont le reste dû dépasse ce montant sont signalés (0 = tous les clients à crédit).
  final double seuilCreditClient;

  factory ParametresAlertes.depuisCles(Map<String, String?> m) => ParametresAlertes(
    afficherConnexion: (m[cleConnexion] ?? '1') == '1',
    seuilCreditClient: double.tryParse(m[cleSeuilCredit] ?? '') ?? 0,
  );
  Map<String, String> versCles() => {
    cleConnexion: afficherConnexion ? '1' : '0',
    cleSeuilCredit: seuilCreditClient.toString(),
  };
}

/// Tous les paramètres de l'écran (barre d'enregistrement unique, §9.16).
class ParametresComplets {
  const ParametresComplets({
    required this.boutique,
    required this.vente,
    required this.paiements,
    required this.impression,
    required this.serveur,
    required this.zakat,
    required this.alertes,
  });
  final Boutique boutique;
  final ParametresVente vente;
  final ParametresPaiement paiements;
  final ParametresImpression impression;
  final ParametresServeur serveur;
  final ParametresZakat zakat;
  final ParametresAlertes alertes;
}

/// Paramètres (lot 8) : boutique, vente, impression, serveurs, zakat. Chaque écriture = UNE transaction + historique.
///
/// ⚠️ PROVISOIRE : la garde de stock est toujours active (non paramétrable, §8) ; liste des clés déduite de la commande.
class ParametresService {
  const ParametresService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  static const String cleZakatNissab = 'zakat_nissab';
  static const String cleZakatTaux = 'zakat_taux';

  Future<Boutique?> lireBoutique() => BoutiqueRepository(db).lire();

  Future<void> enregistrerBoutique(Boutique b) async {
    _validerBoutique(b);
    await db.transaction((txn) async {
      await BoutiqueRepository(txn).ecrire(b.copyWith(nom: b.nom.trim()));
      await _journal(txn, 'boutique');
    });
  }

  static void _validerBoutique(Boutique b) {
    if (b.nom.trim().isEmpty) throw const ParametresException(ErreurParametres.nomBoutiqueVide);
  }

  Future<ParametresVente> lireVente() async =>
      ParametresVente.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresVente.cles));

  Future<void> enregistrerVente(ParametresVente p) async {
    _validerVente(p);
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs(p.copyWith(devise: p.devise.trim()).versCles());
      await _journal(txn, 'vente');
    });
  }

  static void _validerVente(ParametresVente p) {
    if (p.margeDefautPct < 0 ||
        p.margeDefautPct > 1000 ||
        p.margeMontant < 0 ||
        p.seuilStockGlobal < 0 ||
        p.seuilStockMax < 0 ||
        (p.seuilStockMax > 0 && p.seuilStockMax < p.seuilStockGlobal) ||
        p.pointsParDinar < 0 ||
        p.decimalesQuantite < 0 ||
        p.decimalesQuantite > 3) {
      throw const ParametresException(ErreurParametres.valeurInvalide);
    }
    if (p.devise.trim().isEmpty) throw const ParametresException(ErreurParametres.valeurInvalide, 'devise');
  }

  Future<ParametresPaiement> lirePaiements() async =>
      ParametresPaiement.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresPaiement.cles));

  Future<ParametresAlertes> lireAlertes() async =>
      ParametresAlertes.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresAlertes.cles));

  Future<ParametresImpression> lireImpression() async => ParametresImpression.depuisCles(
    await ParametreRepository(
      db,
    ).lirePlusieurs([ParametresImpression.cleType, ParametresImpression.cleAdresse, ParametresImpression.cleLargeur]),
  );

  Future<void> enregistrerImpression(ParametresImpression p) async {
    _validerImpression(p);
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs(_clesImpression(p));
      await _journal(txn, 'impression');
    });
  }

  static void _validerImpression(ParametresImpression p) {
    if (!TypesImprimante.tous.contains(p.type)) {
      throw const ParametresException(ErreurParametres.typeImprimanteInvalide);
    }
    if (p.type != TypesImprimante.normale && p.adresse.trim().isEmpty) {
      throw const ParametresException(ErreurParametres.adresseImprimanteRequise);
    }
    if (p.largeur != '58' && p.largeur != '80') throw const ParametresException(ErreurParametres.valeurInvalide);
  }

  static Map<String, String> _clesImpression(ParametresImpression p) => {
    ...p.versCles(),
    ParametresImpression.cleAdresse: p.adresse.trim(),
  };

  Future<ParametresServeur> lireServeur() async => ParametresServeur.depuisCles(
    await ParametreRepository(db)
        .lirePlusieurs([ParametresServeur.cleUrl, ParametresServeur.cleCle, ParametresServeur.cleMantouj]),
  );

  Future<void> enregistrerServeur(ParametresServeur p) async {
    _validerServeur(p);
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs(_clesServeur(p));
      await _journal(txn, 'serveur');
    });
  }

  static void _validerServeur(ParametresServeur p) {
    for (final u in [p.url, p.urlMantouj]) {
      final t = u.trim();
      if (t.isNotEmpty && !(t.startsWith('http://') || t.startsWith('https://'))) {
        throw ParametresException(ErreurParametres.valeurInvalide, t);
      }
    }
  }

  static Map<String, String> _clesServeur(ParametresServeur p) => {
    ParametresServeur.cleUrl: p.url.trim().replaceAll(RegExp(r'/+$'), ''),
    ParametresServeur.cleCle: p.cle.trim(),
    ParametresServeur.cleMantouj: p.urlMantouj.trim().replaceAll(RegExp(r'/+$'), ''),
  };

  /// Paramètres zakat (`zakatParam`, §9.15) : nissab (DA) et taux (%), 2,5 % par défaut.
  Future<ParametresZakat> lireZakat() async {
    final v = await ParametreRepository(db).lirePlusieurs([cleZakatNissab, cleZakatTaux]);
    return ParametresZakat(
      nissab: double.tryParse(v[cleZakatNissab] ?? '') ?? 0,
      tauxPct: double.tryParse(v[cleZakatTaux] ?? '') ?? CalculZakat.tauxDefautPct,
    );
  }

  Future<void> enregistrerZakat(ParametresZakat p) async {
    _validerZakat(p);
    await db.transaction((txn) async {
      await ParametreRepository(txn).ecrirePlusieurs(_clesZakat(p));
      await _journal(txn, 'zakat');
    });
  }

  static void _validerZakat(ParametresZakat p) {
    if (p.nissab < 0 || p.tauxPct <= 0 || p.tauxPct > 100) {
      throw const ParametresException(ErreurParametres.valeurInvalide);
    }
  }

  static Map<String, String> _clesZakat(ParametresZakat p) => {
    cleZakatNissab: p.nissab.toString(),
    cleZakatTaux: p.tauxPct.toString(),
  };

  /// Lecture de tout l'écran Paramètres.
  Future<ParametresComplets> lireTout() async => ParametresComplets(
    boutique: await lireBoutique() ?? const Boutique(nom: ''),
    vente: await lireVente(),
    paiements: await lirePaiements(),
    impression: await lireImpression(),
    serveur: await lireServeur(),
    zakat: await lireZakat(),
    alertes: await lireAlertes(),
  );

  /// Barre d'enregistrement unique (§9.16) : tout est validé, puis écrit dans UNE transaction avec une ligne
  /// d'historique « Paramètres ».
  Future<void> enregistrerTout(ParametresComplets p) async {
    _validerBoutique(p.boutique);
    _validerVente(p.vente);
    _validerImpression(p.impression);
    _validerServeur(p.serveur);
    _validerZakat(p.zakat);
    if (p.alertes.seuilCreditClient < 0) throw const ParametresException(ErreurParametres.valeurInvalide);
    await db.transaction((txn) async {
      await BoutiqueRepository(txn).ecrire(p.boutique.copyWith(nom: p.boutique.nom.trim()));
      await ParametreRepository(txn).ecrirePlusieurs({
        ...p.vente.copyWith(devise: p.vente.devise.trim()).versCles(),
        ...p.paiements.versCles(),
        ..._clesImpression(p.impression),
        ..._clesServeur(p.serveur),
        ..._clesZakat(p.zakat),
        ...p.alertes.versCles(),
      });
      await _journal(txn, 'tout');
    });
  }

  Future<void> _journal(Transaction txn, String section) => HistoriqueRepository(txn)
      .journaliser(utilisateurCode: utilisateurCode, action: 'Paramètres', entite: 'parametre', entiteCode: section);
}
