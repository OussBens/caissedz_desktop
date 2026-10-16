import 'package:flutter/foundation.dart';

/// Types d'événements du journal fiscal (valeurs stockées).
abstract final class TypesEvenementFiscal {
  static const String vente = 'VENTE';
  static const String annulationVente = 'ANNULATION_VENTE';
  static const String retour = 'RETOUR';
  static const String modificationRetour = 'MODIFICATION_RETOUR';
  static const String annulationRetour = 'ANNULATION_RETOUR';
  static const String cloture = 'CLOTURE_CAISSE';
  static const String facture = 'FACTURE';
  static const String avoir = 'AVOIR';
}

/// Événement du journal fiscal (§12.3) : contenu canonique scellé SHA-256 et chaîné au précédent, en ajout seul.
@immutable
class EvenementFiscal {
  const EvenementFiscal({
    this.id,
    required this.date,
    required this.type,
    required this.referenceCode,
    this.caisseCode,
    required this.utilisateurCode,
    required this.montant,
    required this.contenu,
    required this.hash,
    required this.hashPrecedent,
  });
  final int? id;
  final DateTime date;
  final String type;
  final String referenceCode;
  final String? caisseCode;
  final String utilisateurCode;
  final double montant;

  /// Document canonique (JSON trié) tel qu'il a été haché.
  final String contenu;
  final String hash;
  final String hashPrecedent;

  Map<String, Object?> versLigne() => {
    'id': ?id,
    'date': date.toUtc().toIso8601String(),
    'type': type,
    'reference_code': referenceCode,
    'caisse_code': caisseCode,
    'utilisateur_code': utilisateurCode,
    'montant': montant,
    'contenu': contenu,
    'hash': hash,
    'hash_precedent': hashPrecedent,
  };

  factory EvenementFiscal.depuisLigne(Map<String, Object?> r) => EvenementFiscal(
    id: r['id'] as int?,
    date: DateTime.parse(r['date'] as String).toLocal(),
    type: r['type'] as String,
    referenceCode: r['reference_code'] as String,
    caisseCode: r['caisse_code'] as String?,
    utilisateurCode: r['utilisateur_code'] as String,
    montant: (r['montant'] as num).toDouble(),
    contenu: r['contenu'] as String,
    hash: r['hash'] as String,
    hashPrecedent: r['hash_precedent'] as String,
  );
}
