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

enum ErreurParametres {
  nomBoutiqueVide,
  valeurInvalide,
  typeImprimanteInvalide,
  adresseImprimanteRequise,
  sauvegardeIncomplete,
}

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

/// Fréquences de la sauvegarde automatique (valeurs stockées FR, `backup_param.frequence` §7).
abstract final class FrequencesSauvegarde {
  static const String desactivee = 'Désactivée';
  static const String demarrage = 'À chaque démarrage';
  static const String quotidienne = 'Quotidienne';
  static const List<String> toutes = [desactivee, demarrage, quotidienne];
}

/// Sauvegarde automatique (Paramètres › Sauvegarde, §12.2) : dossier, fréquence, mot de passe des fichiers,
/// date de la dernière sauvegarde automatique (écrite par [SauvegardeService], jamais par l'écran).
class ParametresSauvegardeAuto {
  const ParametresSauvegardeAuto({
    this.dossier = '',
    this.frequence = FrequencesSauvegarde.desactivee,
    this.motDePasse = '',
    this.derniere,
  });
  static const String cleDossier = 'sauvegarde_dossier';
  static const String cleFrequence = 'sauvegarde_frequence';
  static const String cleMotDePasse = 'sauvegarde_mdp';
  static const String cleDerniere = 'sauvegarde_derniere';
  static const List<String> cles = [cleDossier, cleFrequence, cleMotDePasse, cleDerniere];

  final String dossier;
  final String frequence;

  /// Stocké dans la base chiffrée (SQLCipher) : la sauvegarde automatique ne peut pas le demander.
  final String motDePasse;
  final DateTime? derniere;

  bool get active => frequence != FrequencesSauvegarde.desactivee;

  /// Due au démarrage : toujours (`À chaque démarrage`) ou une fois par jour (`Quotidienne`).
  bool estDue(DateTime maintenant) {
    if (!active || dossier.trim().isEmpty || motDePasse.isEmpty) return false;
    if (frequence == FrequencesSauvegarde.demarrage || derniere == null) return true;
    final d = derniere!.toLocal();
    return d.year != maintenant.year || d.month != maintenant.month || d.day != maintenant.day;
  }

  factory ParametresSauvegardeAuto.depuisCles(Map<String, String?> m) => ParametresSauvegardeAuto(
    dossier: m[cleDossier] ?? '',
    frequence: FrequencesSauvegarde.toutes.contains(m[cleFrequence])
        ? m[cleFrequence]!
        : FrequencesSauvegarde.desactivee,
    motDePasse: m[cleMotDePasse] ?? '',
    derniere: DateTime.tryParse(m[cleDerniere] ?? ''),
  );

  /// Sans la date de dernière sauvegarde (non éditable).
  Map<String, String> versCles() => {cleDossier: dossier.trim(), cleFrequence: frequence, cleMotDePasse: motDePasse};

  ParametresSauvegardeAuto copyWith({String? dossier, String? frequence, String? motDePasse}) =>
      ParametresSauvegardeAuto(
        dossier: dossier ?? this.dossier,
        frequence: frequence ?? this.frequence,
        motDePasse: motDePasse ?? this.motDePasse,
        derniere: derniere,
      );
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
    this.sauvegarde = const ParametresSauvegardeAuto(),
  });
  final Boutique boutique;
  final ParametresVente vente;
  final ParametresPaiement paiements;
  final ParametresImpression impression;
  final ParametresServeur serveur;
  final ParametresZakat zakat;
  final ParametresAlertes alertes;
  final ParametresSauvegardeAuto sauvegarde;
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

  Future<ParametresSauvegardeAuto> lireSauvegardeAuto() async =>
      ParametresSauvegardeAuto.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresSauvegardeAuto.cles));

  static void _validerSauvegarde(ParametresSauvegardeAuto p) {
    if (!FrequencesSauvegarde.toutes.contains(p.frequence)) {
      throw const ParametresException(ErreurParametres.valeurInvalide);
    }
    if (p.active && (p.dossier.trim().isEmpty || p.motDePasse.isEmpty)) {
      throw const ParametresException(ErreurParametres.sauvegardeIncomplete);
    }
  }

  /// Lecture de tout l'écran Paramètres.
  Future<ParametresComplets> lireTout() async => ParametresComplets(
    boutique: await lireBoutique() ?? const Boutique(nom: ''),
    vente: await lireVente(),
    paiements: await lirePaiements(),
    impression: await lireImpression(),
    serveur: await lireServeur(),
    zakat: await lireZakat(),
    alertes: await lireAlertes(),
    sauvegarde: await lireSauvegardeAuto(),
  );

  /// Barre d'enregistrement unique (§9.16) : tout est validé, puis écrit dans UNE transaction avec une ligne
  /// d'historique « Paramètres ».
  Future<void> enregistrerTout(ParametresComplets p) async {
    _validerBoutique(p.boutique);
    _validerVente(p.vente);
    _validerImpression(p.impression);
    _validerServeur(p.serveur);
    _validerZakat(p.zakat);
    _validerSauvegarde(p.sauvegarde);
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
        ...p.sauvegarde.versCles(),
      });
      await _journal(txn, 'tout');
    });
  }

  Future<void> _journal(Transaction txn, String section) => HistoriqueRepository(txn)
      .journaliser(utilisateurCode: utilisateurCode, action: 'Paramètres', entite: 'parametre', entiteCode: section);
}
