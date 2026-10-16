import 'package:flutter/foundation.dart';

import 'audit.dart';

/// Fiche administrative commune aux clients et fournisseurs (§7.6) : wilaya, type (référentiel
/// `typeClient` / `typeFournisseur`), activité, contact, identifiants fiscaux, banque.
@immutable
class FicheTiers {
  const FicheTiers({
    this.wilaya = '',
    this.type = '',
    this.activite = '',
    this.fax = '',
    this.nif = '',
    this.nis = '',
    this.nrc = '',
    this.ai = '',
    this.banque = '',
    this.rib = '',
    this.observation = '',
  });
  final String wilaya;
  final String type;
  final String activite;
  final String fax;
  final String nif;
  final String nis;
  final String nrc;

  /// Article d'imposition (mention obligatoire de la facture).
  final String ai;
  final String banque;
  final String rib;
  final String observation;

  Map<String, Object?> versLigne() => {
    'wilaya': wilaya,
    'type': type,
    'activite': activite,
    'fax': fax,
    'nif': nif,
    'nis': nis,
    'nrc': nrc,
    'ai': ai,
    'banque': banque,
    'rib': rib,
    'observation': observation,
  };

  factory FicheTiers.depuisLigne(Map<String, Object?> r) {
    String s(String k) => (r[k] as String?) ?? '';
    return FicheTiers(
      wilaya: s('wilaya'),
      type: s('type'),
      activite: s('activite'),
      fax: s('fax'),
      nif: s('nif'),
      nis: s('nis'),
      nrc: s('nrc'),
      ai: s('ai'),
      banque: s('banque'),
      rib: s('rib'),
      observation: s('observation'),
    );
  }
}

/// Client (table `client`).
@immutable
class Client {
  const Client({
    this.audit = Audit.vide,
    required this.code,
    required this.nom,
    this.telephone = '',
    this.adresse = '',
    this.email = '',
    this.points = 0,
    this.plafondCredit = 0,
    this.actif = true,
    this.systeme = false,
    this.fiche = const FicheTiers(type: 'Consommateur'),
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final int points;

  /// Plafond de crédit autorisé (0 = pas de vente à crédit).
  final double plafondCredit;
  final bool actif;
  final bool systeme;
  final FicheTiers fiche;

  bool get estDePassage => code == 'CLN0000';

  Client copyWith({
    String? nom,
    String? telephone,
    String? adresse,
    String? email,
    int? points,
    double? plafondCredit,
    bool? actif,
    FicheTiers? fiche,
  }) => Client(
    audit: audit,
    code: code,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    adresse: adresse ?? this.adresse,
    email: email ?? this.email,
    points: points ?? this.points,
    plafondCredit: plafondCredit ?? this.plafondCredit,
    actif: actif ?? this.actif,
    systeme: systeme,
    fiche: fiche ?? this.fiche,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'telephone': telephone,
    'adresse': adresse,
    'email': email,
    'points': points,
    'plafond_credit': plafondCredit,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
    ...fiche.versLigne(),
  };

  factory Client.depuisLigne(Map<String, Object?> r) => Client(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    nom: r['nom'] as String,
    telephone: (r['telephone'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    points: (r['points'] as int?) ?? 0,
    plafondCredit: ((r['plafond_credit'] as num?) ?? 0).toDouble(),
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    fiche: FicheTiers.depuisLigne(r),
  );

  @override
  bool operator ==(Object other) =>
      other is Client && other.code == code && other.nom == nom && other.points == points && other.actif == actif;
  @override
  int get hashCode => Object.hash(code, nom, points, actif);
}

/// Fournisseur (table `fournisseur`).
@immutable
class Fournisseur {
  const Fournisseur({
    this.audit = Audit.vide,
    required this.code,
    required this.nom,
    this.telephone = '',
    this.adresse = '',
    this.email = '',
    this.actif = true,
    this.systeme = false,
    this.fiche = const FicheTiers(type: 'Grossiste'),
  });

  /// Colonnes d'audit (créé / modifié le / par), en lecture seule.
  final Audit audit;
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final bool actif;
  final bool systeme;
  final FicheTiers fiche;

  Fournisseur copyWith({
    String? nom,
    String? telephone,
    String? adresse,
    String? email,
    bool? actif,
    FicheTiers? fiche,
  }) => Fournisseur(
    audit: audit,
    code: code,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    adresse: adresse ?? this.adresse,
    email: email ?? this.email,
    actif: actif ?? this.actif,
    systeme: systeme,
    fiche: fiche ?? this.fiche,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'telephone': telephone,
    'adresse': adresse,
    'email': email,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
    ...fiche.versLigne(),
  };
  factory Fournisseur.depuisLigne(Map<String, Object?> r) => Fournisseur(
    audit: Audit.depuisLigne(r),
    code: r['code'] as String,
    nom: r['nom'] as String,
    telephone: (r['telephone'] as String?) ?? '',
    adresse: (r['adresse'] as String?) ?? '',
    email: (r['email'] as String?) ?? '',
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
    fiche: FicheTiers.depuisLigne(r),
  );
}

/// Statistiques calculées d'un tiers (jamais stockées, §7.6).
@immutable
class StatsTiers {
  const StatsTiers({this.achats = 0, this.du = 0, this.solde = 0, this.retours = 0, this.dernier});

  static const StatsTiers vide = StatsTiers();

  /// Total des documents validés (ventes du client, achats du fournisseur).
  final double achats;

  /// Restes ouverts des documents après imputations (crédit du client, dette envers le fournisseur).
  final double du;

  /// Solde unique du tiers (vue `solde_tiers`) : positif = dû par le client (ou au fournisseur), négatif =
  /// avance (trop-payé, avoir non imputé). Même valeur dans la liste, la caisse, la situation, les alertes,
  /// le tableau de bord et la zakat.
  final double solde;
  final double retours;
  final DateTime? dernier;

  double get credit => solde > 0 ? solde : 0;
  double get avanceNette => solde < 0 ? -solde : 0;

  /// Total réglé des documents.
  double get paye => achats - du;

  StatsTiers copyWith({double? achats, double? du, double? solde, double? retours, DateTime? dernier}) => StatsTiers(
    achats: achats ?? this.achats,
    du: du ?? this.du,
    solde: solde ?? this.solde,
    retours: retours ?? this.retours,
    dernier: dernier ?? this.dernier,
  );
}

/// Nature d'une ligne de relevé (Situation d'un tiers).
enum NatureReleve { achat, versement, retour, versementRetour }

/// Ligne du relevé d'un tiers : le débit réduit le solde (paiement, retour), le crédit l'augmente (achat).
@immutable
class LigneReleve {
  const LigneReleve({
    required this.date,
    required this.nature,
    required this.reference,
    this.debit = 0,
    this.credit = 0,
  });
  final DateTime date;
  final NatureReleve nature;
  final String reference;
  final double debit;
  final double credit;
}
