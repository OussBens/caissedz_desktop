import 'package:flutter/foundation.dart';

import '../permissions.dart';

/// Pourquoi une licence gardée n'est plus valable sur ce poste.
enum MotifLicence {
  /// Sa date de fin est passée (fin de l'essai, licence à durée).
  expiree,

  /// Elle est pour un autre poste.
  autrePoste,

  /// La date du poste a été reculée.
  dateReculee,

  /// Clé illisible ou pour une autre application.
  invalide,
}

/// Le compte BENS du client sur ce poste (téléphone + mot de passe, créé dans l'application).
@immutable
class CompteBens {
  const CompteBens({required this.telephone, this.nom = '', this.commerce = ''});

  /// E.164 (`+213555112233`).
  final String telephone;
  final String nom;
  final String commerce;

  @override
  bool operator ==(Object other) =>
      other is CompteBens && other.telephone == telephone && other.nom == nom && other.commerce == commerce;
  @override
  int get hashCode => Object.hash(telephone, nom, commerce);
}

/// État de la licence du poste : la licence BENS signée pour son code (vérifiée hors ligne), et ce
/// que le compte BENS en dit (essai, Smart Scan) au dernier check-in.
@immutable
class Licence {
  const Licence({
    required this.niveau,
    this.cle,
    this.essai = false,
    this.expireLe,
    this.activeeLe,
    this.motif,
    this.finMotif,
    this.compte,
    this.scansSmartScan,
    this.expirationsScans = const [],
    this.refusServeur,
  });

  /// Licence absente : application non activée.
  static const Licence aucune = Licence(niveau: null);

  /// Palier débloqué ; null : pas de licence valable sur ce poste.
  final NiveauLicence? niveau;

  /// La clé signée gardée.
  final String? cle;

  /// Essai de 14 jours (le palier choisi à l'inscription) plutôt qu'un palier acheté.
  final bool essai;

  /// Dernier jour valable (UTC) ; null : licence permanente.
  final DateTime? expireLe;

  /// Jour d'émission de la licence.
  final DateTime? activeeLe;

  /// Une clé gardée qui n'est plus valable : pourquoi (null sinon).
  final MotifLicence? motif;

  /// Pour [MotifLicence.expiree] : le dernier jour qu'elle couvrait.
  final DateTime? finMotif;

  /// Connecté à un compte BENS sur ce poste.
  final CompteBens? compte;

  /// La dernière licence envoyée par le serveur BENS, refusée sur ce poste : pourquoi (null : aucune
  /// refusée). Clé d'une autre application ou version sans la bonne clé publique (`invalide`), pour
  /// un autre PC, date du PC reculée : dit à l'écran au lieu de « aucune formule ».
  final MotifLicence? refusServeur;

  /// Smart Scans restants au dernier check-in (null : inconnu).
  final int? scansSmartScan;

  /// Lots Smart Scan (packs, scans inclus) avec des scans restants qui expirent dans les 30 jours :
  /// le rappel avant l'expiration (Smart Scan, Expiry of scans).
  final List<({int restant, DateTime fin})> expirationsScans;

  bool get estActivee => niveau != null;

  /// Essai (ou licence à durée) terminé : l'application s'ouvre en lecture seule (Desktop — Plans &
  /// Pricing, End of Trial) : on consulte produits, ventes et rapports ; vendre, ajouter, Smart Scan et
  /// exporter attendent l'achat d'une formule. Les données sont gardées.
  bool get lectureSeule => niveau == null && motif == MotifLicence.expiree;

  /// L'application peut s'ouvrir (connexion locale) : licence valable, ou lecture seule.
  bool get peutOuvrir => estActivee || lectureSeule;

  /// Le palier des modules ouverts ; en lecture seule, ceux de Basic (consultation seulement).
  NiveauLicence? get niveauEffectif => niveau ?? (lectureSeule ? NiveauLicence.basic : null);

  bool couvre(NiveauLicence requis) => niveauEffectif?.couvre(requis) ?? false;

  /// Jours restants jusqu'à [expireLe] inclus (null : permanente ou non activée).
  int? joursRestants(DateTime maintenant) {
    final fin = expireLe;
    if (fin == null || niveau == null) return null;
    final jour = DateTime.utc(maintenant.year, maintenant.month, maintenant.day);
    return fin.difference(jour).inDays + 1;
  }

  @override
  bool operator ==(Object other) =>
      other is Licence &&
      other.niveau == niveau &&
      other.cle == cle &&
      other.essai == essai &&
      other.expireLe == expireLe &&
      other.motif == motif &&
      other.compte == compte &&
      other.scansSmartScan == scansSmartScan &&
      other.refusServeur == refusServeur;
  @override
  int get hashCode => Object.hash(niveau, cle, essai, expireLe, motif, compte, scansSmartScan, refusServeur);
}

/// Une offre de CaisseDZ Desktop (bensdsRev) : un palier, une mise à niveau ou un pack Smart Scan.
@immutable
class OffreBens {
  const OffreBens({
    required this.code,
    required this.nom,
    this.prixDzd,
    this.niveau,
    this.scans,
    this.mois,
    this.requiert = const [],
  });

  final String code;
  final String nom;
  final int? prixDzd;

  /// Le palier qu'elle donne (paliers et mises à niveau).
  final NiveauLicence? niveau;

  /// Smart Scans inclus, et leur validité en mois.
  final int? scans;
  final int? mois;

  /// Ce qu'il faut avoir pour l'acheter (`app` : un palier acheté).
  final List<String> requiert;

  /// Un des paliers proposés à l'inscription (il donne l'application et ne demande rien).
  bool get estPalier => niveau != null && requiert.isEmpty;

  factory OffreBens.fromJson(Map<String, Object?> j) {
    final grants = [for (final g in j['grants'] as List? ?? const []) (g as Map).cast<String, Object?>()];
    final app = grants.where((g) => g['feature'] == 'app').firstOrNull;
    final scan = grants.where((g) => g['feature'] == 'smartscan').firstOrNull;
    return OffreBens(
      code: j['code'] as String,
      nom: j['name'] as String? ?? j['code'] as String,
      prixDzd: (j['priceDzd'] as num?)?.toInt(),
      niveau: app == null ? null : NiveauLicence.parNumero((app['tier'] as num?)?.toInt() ?? 0),
      scans: (scan?['scans'] as num?)?.toInt(),
      mois: (scan?['months'] as num?)?.toInt(),
      requiert: [for (final r in j['requires'] as List? ?? const []) r as String],
    );
  }

  /// La mise à niveau d'un palier acheté vers un autre (la différence de prix, sans nouveaux scans).
  static String? codeMiseANiveau(NiveauLicence de, NiveauLicence vers) => switch ((de, vers)) {
    (NiveauLicence.basic, NiveauLicence.avance) => 'DSK-UP-ADV',
    (NiveauLicence.avance, NiveauLicence.max) => 'DSK-UP-ULTRA',
    (NiveauLicence.basic, NiveauLicence.max) => 'DSK-UP-BASIC-ULTRA',
    _ => null,
  };

  /// Hors ligne (premier lancement sans internet) : les paliers de Desktop — Plans & Pricing.
  static const List<OffreBens> parDefaut = [
    OffreBens(code: 'DSK-BASIC', nom: 'Basic', prixDzd: 20000, niveau: NiveauLicence.basic, scans: 90, mois: 3),
    OffreBens(code: 'DSK-ADV', nom: 'Advanced', prixDzd: 30000, niveau: NiveauLicence.avance, scans: 180, mois: 3),
    OffreBens(code: 'DSK-ULTRA', nom: 'Max', prixDzd: 36000, niveau: NiveauLicence.max, scans: 360, mois: 3),
  ];
}

/// Les offres en vente et la durée de l'essai ; [enLigne] faux : celles connues hors ligne.
@immutable
class OffresBens {
  const OffresBens({required this.offres, required this.joursEssai, required this.enLigne});

  final List<OffreBens> offres;
  final int joursEssai;
  final bool enLigne;

  /// Les trois paliers proposés, dans l'ordre (Basic, Advanced, Max).
  List<OffreBens> get paliers =>
      [...offres.where((o) => o.estPalier)]..sort((a, b) => a.niveau!.index.compareTo(b.niveau!.index));

  OffreBens? offre(String code) => offres.where((o) => o.code == code).firstOrNull;
}
