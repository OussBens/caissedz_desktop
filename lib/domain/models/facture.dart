import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Types de documents de facturation (valeurs stockées).
abstract final class TypesFacture {
  static const String facture = 'Facture';
  static const String avoir = 'Avoir';
}

/// Ligne d'une facture ou d'un avoir (prix TTC, ventilation HT / TVA figée à l'émission).
@immutable
class FactureLigne {
  const FactureLigne({
    required this.produitCode,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    required this.tauxTva,
    required this.montantHt,
    required this.montantTva,
    required this.montantTtc,
  });
  final String produitCode;
  final String designation;
  final double quantite;

  /// Prix unitaire TTC net de remise.
  final double prixUnitaire;
  final double tauxTva;
  final double montantHt;
  final double montantTva;
  final double montantTtc;

  Map<String, Object?> versJson() => {
    'produit': produitCode,
    'designation': designation,
    'quantite': quantite,
    'pu': prixUnitaire,
    'taux': tauxTva,
    'ht': montantHt,
    'tva': montantTva,
    'ttc': montantTtc,
  };

  factory FactureLigne.depuisJson(Map<String, Object?> j) => FactureLigne(
    produitCode: j['produit']! as String,
    designation: j['designation']! as String,
    quantite: (j['quantite']! as num).toDouble(),
    prixUnitaire: (j['pu']! as num).toDouble(),
    tauxTva: (j['taux']! as num).toDouble(),
    montantHt: (j['ht']! as num).toDouble(),
    montantTva: (j['tva']! as num).toDouble(),
    montantTtc: (j['ttc']! as num).toDouble(),
  );
}

/// Identité fiscale figée à l'émission (vendeur ou client) : NIF, NIS, RC, article d'imposition (AI).
@immutable
class IdentiteFiscale {
  const IdentiteFiscale({
    required this.nom,
    this.adresse = '',
    this.telephone = '',
    this.nif = '',
    this.nis = '',
    this.rc = '',
    this.ai = '',
  });
  final String nom;
  final String adresse;
  final String telephone;
  final String nif;
  final String nis;
  final String rc;
  final String ai;

  Map<String, Object?> versJson() => {
    'nom': nom,
    'adresse': adresse,
    'telephone': telephone,
    'nif': nif,
    'nis': nis,
    'rc': rc,
    'ai': ai,
  };

  factory IdentiteFiscale.depuisJson(Map<String, Object?> j) {
    String s(String k) => (j[k] as String?) ?? '';
    return IdentiteFiscale(
      nom: s('nom'),
      adresse: s('adresse'),
      telephone: s('telephone'),
      nif: s('nif'),
      nis: s('nis'),
      rc: s('rc'),
      ai: s('ai'),
    );
  }
}

/// Facture (FAC) ou facture d'avoir (AVO) : numérotation continue propre à chaque type, contenu figé et
/// scellé (SHA-256 chaîné), jamais modifiée ni supprimée. Un avoir annule tout ou partie d'une facture.
@immutable
class Facture {
  const Facture({
    required this.code,
    required this.type,
    required this.date,
    required this.venteCode,
    this.retourCode,
    this.factureOrigine,
    required this.clientCode,
    required this.vendeur,
    required this.client,
    required this.lignes,
    required this.totalHt,
    required this.totalTva,
    required this.totalTtc,
    required this.timbre,
    required this.netAPayer,
    required this.modePaiement,
    required this.montantLettres,
    required this.utilisateurCode,
    this.motif,
    required this.hash,
    required this.hashPrecedent,
  });
  final String code;
  final String type;
  final DateTime date;
  final String venteCode;
  final String? retourCode;

  /// Avoir : facture annulée (en tout ou partie).
  final String? factureOrigine;
  final String clientCode;
  final IdentiteFiscale vendeur;
  final IdentiteFiscale client;
  final List<FactureLigne> lignes;
  final double totalHt;
  final double totalTva;
  final double totalTtc;

  /// Droit de timbre (part payée en espèces) ; 0 sur un avoir.
  final double timbre;
  final double netAPayer;
  final String modePaiement;
  final String montantLettres;
  final String utilisateurCode;
  final String? motif;
  final String hash;
  final String hashPrecedent;

  bool get estAvoir => type == TypesFacture.avoir;

  /// Récapitulatif par taux de TVA : taux → (HT, TVA).
  Map<double, ({double ht, double tva})> get parTaux {
    final m = <double, ({double ht, double tva})>{};
    for (final l in lignes) {
      final p = m[l.tauxTva];
      m[l.tauxTva] = (ht: (p?.ht ?? 0) + l.montantHt, tva: (p?.tva ?? 0) + l.montantTva);
    }
    return m;
  }

  /// Contenu scellé (tout sauf le hash).
  Map<String, Object?> versCanonique() => {
    'code': code,
    'type': type,
    'date': date,
    'vente': venteCode,
    'retour': retourCode,
    'origine': factureOrigine,
    'client_code': clientCode,
    'vendeur': vendeur.versJson(),
    'client': client.versJson(),
    'lignes': [for (final l in lignes) l.versJson()],
    'ht': totalHt,
    'tva': totalTva,
    'ttc': totalTtc,
    'timbre': timbre,
    'net': netAPayer,
    'mode': modePaiement,
    'lettres': montantLettres,
    'utilisateur': utilisateurCode,
    'motif': motif,
  };

  Map<String, Object?> versLigne() => {
    'code': code,
    'type': type,
    'date': date.toUtc().toIso8601String(),
    'vente_code': venteCode,
    'retour_code': retourCode,
    'facture_origine': factureOrigine,
    'client_code': clientCode,
    'vendeur': jsonEncode(vendeur.versJson()),
    'client': jsonEncode(client.versJson()),
    'lignes': jsonEncode([for (final l in lignes) l.versJson()]),
    'total_ht': totalHt,
    'total_tva': totalTva,
    'total_ttc': totalTtc,
    'timbre': timbre,
    'net_a_payer': netAPayer,
    'mode_paiement': modePaiement,
    'montant_lettres': montantLettres,
    'utilisateur_code': utilisateurCode,
    'motif': motif,
    'hash': hash,
    'hash_precedent': hashPrecedent,
  };

  factory Facture.depuisLigne(Map<String, Object?> r) => Facture(
    code: r['code']! as String,
    type: r['type']! as String,
    date: DateTime.parse(r['date']! as String).toLocal(),
    venteCode: r['vente_code']! as String,
    retourCode: r['retour_code'] as String?,
    factureOrigine: r['facture_origine'] as String?,
    clientCode: r['client_code']! as String,
    vendeur: IdentiteFiscale.depuisJson((jsonDecode(r['vendeur']! as String) as Map).cast()),
    client: IdentiteFiscale.depuisJson((jsonDecode(r['client']! as String) as Map).cast()),
    lignes: [for (final l in jsonDecode(r['lignes']! as String) as List) FactureLigne.depuisJson((l as Map).cast())],
    totalHt: (r['total_ht']! as num).toDouble(),
    totalTva: (r['total_tva']! as num).toDouble(),
    totalTtc: (r['total_ttc']! as num).toDouble(),
    timbre: (r['timbre']! as num).toDouble(),
    netAPayer: (r['net_a_payer']! as num).toDouble(),
    modePaiement: r['mode_paiement']! as String,
    montantLettres: r['montant_lettres']! as String,
    utilisateurCode: r['utilisateur_code']! as String,
    motif: r['motif'] as String?,
    hash: r['hash']! as String,
    hashPrecedent: r['hash_precedent']! as String,
  );

  Facture avecHash(String h) => Facture.depuisLigne({...versLigne(), 'hash': h});
}
