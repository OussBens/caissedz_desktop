/// Colonnes d'audit d'une table métier (§3.2) : créé le / par, modifié le / par. Renseignées par les déclencheurs
/// SQL (migrations v20 et v22) ; lecture seule côté application. `archiveLe` / `archivePar` : archivage de la
/// fiche (migration v43), écrits seulement par `ArchivageService`.
class Audit {
  const Audit({this.creeLe, this.creePar, this.modifieLe, this.modifiePar, this.archiveLe, this.archivePar});

  static const Audit vide = Audit();

  final DateTime? creeLe;
  final String? creePar;
  final DateTime? modifieLe;
  final String? modifiePar;
  final DateTime? archiveLe;
  final String? archivePar;

  /// Fiche archivée : gardée pour l'historique, masquée des listes de gestion et des sélecteurs.
  bool get archive => archiveLe != null;

  factory Audit.depuisLigne(Map<String, Object?> r) => Audit(
    creeLe: _date(r['cree_le']),
    creePar: r['cree_par'] as String?,
    modifieLe: _date(r['modifie_le']),
    modifiePar: r['modifie_par'] as String?,
    archiveLe: _date(r['archive_le']),
    archivePar: r['archive_par'] as String?,
  );

  static DateTime? _date(Object? v) => v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
}
