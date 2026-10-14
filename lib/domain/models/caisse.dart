import 'package:flutter/foundation.dart';

/// Types de caisse (§13, valeur stockée FR) : `Physique` ou `Compte`.
class TypesCaisse {
  const TypesCaisse._();
  static const String physique = 'Physique';
  static const String compte = 'Compte';
}

/// Sens d'un mouvement de caisse.
class SensMouvementCaisse {
  const SensMouvementCaisse._();
  static const String entree = 'Entrée';
  static const String sortie = 'Sortie';
}

/// Types de mouvements du journal de caisse (valeurs stockées FR).
class TypesMouvementCaisse {
  const TypesMouvementCaisse._();
  static const String vente = 'Vente';
  static const String annulation = 'Annulation';
  static const String remboursement = 'Remboursement';
  static const String encaissement = 'Encaissement';
  static const String decaissement = 'Décaissement';
  static const String apport = 'Apport';
  static const String depense = 'Dépense';
  static const String transfert = 'Transfert';
  static const String fondInitial = 'Fond initial';
  static const String retrait = 'Retrait';
  static const String ecart = 'Écart';
  static const List<String> tous = [
    vente,
    annulation,
    remboursement,
    encaissement,
    decaissement,
    apport,
    depense,
    transfert,
    fondInitial,
    retrait,
    ecart,
  ];
}

/// Caisse (physique ou compte), rattachée ou non à un magasin.
@immutable
class Caisse {
  const Caisse({
    required this.code,
    required this.nom,
    this.type = TypesCaisse.physique,
    this.magasinCode,
    this.actif = true,
    this.systeme = false,
  });
  final String code;
  final String nom;
  final String type;

  /// `null` = caisse sans magasin.
  final String? magasinCode;
  final bool actif;
  final bool systeme;

  factory Caisse.depuisLigne(Map<String, Object?> r) => Caisse(
    code: r['code'] as String,
    nom: r['nom'] as String,
    type: r['type'] as String,
    magasinCode: r['magasin_code'] as String?,
    actif: (r['actif'] as int) == 1,
    systeme: (r['systeme'] as int) == 1,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'nom': nom,
    'type': type,
    'magasin_code': magasinCode,
    'actif': actif ? 1 : 0,
    'systeme': systeme ? 1 : 0,
  };

  Caisse copyWith({String? nom, String? type, String? magasinCode, bool sansMagasin = false, bool? actif}) => Caisse(
    code: code,
    nom: nom ?? this.nom,
    type: type ?? this.type,
    magasinCode: sansMagasin ? null : (magasinCode ?? this.magasinCode),
    actif: actif ?? this.actif,
    systeme: systeme,
  );
}

/// Mouvement du journal de caisse (jamais un solde modifié à la main).
@immutable
class MouvementCaisse {
  const MouvementCaisse({
    this.id,
    required this.date,
    required this.caisseCode,
    required this.type,
    required this.sens,
    required this.montant,
    this.mode = 'Espèces',
    this.referenceType,
    this.referenceCode,
    required this.utilisateurCode,
    this.commentaire,
  });
  final int? id;
  final DateTime date;
  final String caisseCode;
  final String type;
  final String sens;
  final double montant;
  final String mode;
  final String? referenceType;
  final String? referenceCode;
  final String utilisateurCode;
  final String? commentaire;

  /// Montant signé (+ entrée / − sortie).
  double get signe => sens == SensMouvementCaisse.entree ? montant : -montant;

  factory MouvementCaisse.depuisLigne(Map<String, Object?> r) => MouvementCaisse(
    id: r['id'] as int?,
    date: DateTime.parse(r['date'] as String).toLocal(),
    caisseCode: r['caisse_code'] as String,
    type: r['type'] as String,
    sens: r['sens'] as String,
    montant: (r['montant'] as num).toDouble(),
    mode: r['mode'] as String,
    referenceType: r['reference_type'] as String?,
    referenceCode: r['reference_code'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    commentaire: r['commentaire'] as String?,
  );

  Map<String, Object?> versLigne() => {
    'date': date.toUtc().toIso8601String(),
    'caisse_code': caisseCode,
    'type': type,
    'sens': sens,
    'montant': montant,
    'mode': mode,
    'reference_type': referenceType,
    'reference_code': referenceCode,
    'utilisateur_code': utilisateurCode,
    'commentaire': commentaire,
  };
}

/// Solde d'une caisse par mode de paiement.
@immutable
class SoldeCaisse {
  const SoldeCaisse({required this.caisseCode, required this.parMode});
  final String caisseCode;
  final Map<String, double> parMode;
  double get especes => parMode['Espèces'] ?? 0;
  double get total => parMode.values.fold(0.0, (s, v) => s + v);
}

/// Transfert TRF entre deux caisses (= 2 mouvements : sortie puis entrée).
@immutable
class TransfertCaisse {
  const TransfertCaisse({
    required this.code,
    required this.date,
    required this.caisseSource,
    required this.caisseDestination,
    required this.montant,
    this.mode = 'Espèces',
    required this.utilisateurCode,
    this.commentaire,
  });
  final String code;
  final DateTime date;
  final String caisseSource;
  final String caisseDestination;
  final double montant;
  final String mode;
  final String utilisateurCode;
  final String? commentaire;

  factory TransfertCaisse.depuisLigne(Map<String, Object?> r) => TransfertCaisse(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    caisseSource: r['caisse_source'] as String,
    caisseDestination: r['caisse_destination'] as String,
    montant: (r['montant'] as num).toDouble(),
    mode: r['mode'] as String,
    utilisateurCode: r['utilisateur_code'] as String,
    commentaire: r['commentaire'] as String?,
  );

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'caisse_source': caisseSource,
    'caisse_destination': caisseDestination,
    'montant': montant,
    'mode': mode,
    'utilisateur_code': utilisateurCode,
    'commentaire': commentaire,
  };
}

/// Clôture Z : récapitulatif immuable d'une période, scellé et chaîné (SHA-256) à la clôture précédente.
@immutable
class Cloture {
  const Cloture({
    required this.code,
    required this.date,
    required this.debut,
    required this.fin,
    required this.utilisateurCode,
    required this.nbVentes,
    required this.nbAnnulations,
    required this.totalVentes,
    required this.totalRemises,
    required this.totalRetours,
    required this.totalEncaissements,
    required this.totalDecaissements,
    required this.encaissementsParMode,
    required this.soldesCaisses,
    this.premiereVente,
    this.derniereVente,
    required this.hashDerniereVente,
    required this.hashPrecedent,
    required this.hash,
  });
  final String code;
  final DateTime date;
  final DateTime debut;
  final DateTime fin;
  final String utilisateurCode;
  final int nbVentes;
  final int nbAnnulations;
  final double totalVentes;
  final double totalRemises;
  final double totalRetours;
  final double totalEncaissements;
  final double totalDecaissements;
  final Map<String, double> encaissementsParMode;
  final Map<String, double> soldesCaisses;
  final String? premiereVente;
  final String? derniereVente;
  final String hashDerniereVente;
  final String hashPrecedent;
  final String hash;

  /// Contenu scellé (tout sauf le hash lui-même).
  Map<String, Object?> versCanonique() => {
    'code': code,
    'date': date,
    'debut': debut,
    'fin': fin,
    'utilisateur': utilisateurCode,
    'nb_ventes': nbVentes,
    'nb_annulations': nbAnnulations,
    'total_ventes': totalVentes,
    'total_remises': totalRemises,
    'total_retours': totalRetours,
    'total_encaissements': totalEncaissements,
    'total_decaissements': totalDecaissements,
    'encaissements_par_mode': encaissementsParMode,
    'soldes_caisses': soldesCaisses,
    'premiere_vente': premiereVente,
    'derniere_vente': derniereVente,
    'hash_derniere_vente': hashDerniereVente,
  };

  Map<String, Object?> versLigne() => {
    'code': code,
    'date': date.toUtc().toIso8601String(),
    'debut': debut.toUtc().toIso8601String(),
    'fin': fin.toUtc().toIso8601String(),
    'utilisateur_code': utilisateurCode,
    'nb_ventes': nbVentes,
    'nb_annulations': nbAnnulations,
    'total_ventes': totalVentes,
    'total_remises': totalRemises,
    'total_retours': totalRetours,
    'total_encaissements': totalEncaissements,
    'total_decaissements': totalDecaissements,
    'encaissements_par_mode': _encoderMap(encaissementsParMode),
    'soldes_caisses': _encoderMap(soldesCaisses),
    'premiere_vente': premiereVente,
    'derniere_vente': derniereVente,
    'hash_derniere_vente': hashDerniereVente,
    'hash_precedent': hashPrecedent,
    'hash': hash,
  };

  factory Cloture.depuisLigne(Map<String, Object?> r) => Cloture(
    code: r['code'] as String,
    date: DateTime.parse(r['date'] as String).toLocal(),
    debut: DateTime.parse(r['debut'] as String).toLocal(),
    fin: DateTime.parse(r['fin'] as String).toLocal(),
    utilisateurCode: r['utilisateur_code'] as String,
    nbVentes: r['nb_ventes'] as int,
    nbAnnulations: r['nb_annulations'] as int,
    totalVentes: (r['total_ventes'] as num).toDouble(),
    totalRemises: (r['total_remises'] as num).toDouble(),
    totalRetours: (r['total_retours'] as num).toDouble(),
    totalEncaissements: (r['total_encaissements'] as num).toDouble(),
    totalDecaissements: (r['total_decaissements'] as num).toDouble(),
    encaissementsParMode: _decoderMap(r['encaissements_par_mode']),
    soldesCaisses: _decoderMap(r['soldes_caisses']),
    premiereVente: r['premiere_vente'] as String?,
    derniereVente: r['derniere_vente'] as String?,
    hashDerniereVente: r['hash_derniere_vente'] as String,
    hashPrecedent: r['hash_precedent'] as String,
    hash: r['hash'] as String,
  );

  Cloture copyWith({String? hash}) => Cloture(
    code: code,
    date: date,
    debut: debut,
    fin: fin,
    utilisateurCode: utilisateurCode,
    nbVentes: nbVentes,
    nbAnnulations: nbAnnulations,
    totalVentes: totalVentes,
    totalRemises: totalRemises,
    totalRetours: totalRetours,
    totalEncaissements: totalEncaissements,
    totalDecaissements: totalDecaissements,
    encaissementsParMode: encaissementsParMode,
    soldesCaisses: soldesCaisses,
    premiereVente: premiereVente,
    derniereVente: derniereVente,
    hashDerniereVente: hashDerniereVente,
    hashPrecedent: hashPrecedent,
    hash: hash ?? this.hash,
  );

  /// Encodage stable `cle=valeur;...` (clés triées) ; `valeur` au centime.
  static String _encoderMap(Map<String, double> m) {
    final cles = m.keys.toList()..sort();
    return [for (final k in cles) '$k=${m[k]!.toStringAsFixed(2)}'].join(';');
  }

  static Map<String, double> _decoderMap(Object? v) {
    final s = v as String? ?? '';
    if (s.isEmpty) return const {};
    return {
      for (final part in s.split(';')) part.substring(0, part.lastIndexOf('=')): double.parse(part.split('=').last),
    };
  }
}
