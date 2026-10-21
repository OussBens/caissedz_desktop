import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/fiscalite.dart';
import '../../domain/models/parametres_vente.dart';

/// Prix appliqué [prix] (TTC quand la TVA s'applique) détaillé selon Paramètres › Affichage des prix :
/// « HT … · TVA … · TTC … » (HT et TTC, HT et TVA, ou les trois). Sans TVA ([tauxPct] 0) : le seul prix.
String texteDetailPrix(
  AppLocalizations l10n, {
  required double prix,
  required double tauxPct,
  required String affichage,
  required String devise,
}) {
  if (tauxPct <= 0) return formaterMontant(prix, devise);
  final v = Fiscalite.ventiler(prix, tauxPct);
  final parties = [
    l10n.prixDetailHt(formaterNombre(v.ht, decimales: 2)),
    if (affichage != ParametresVente.affichagePrixTtc)
      l10n.prixDetailTva('${formaterNombre(tauxPct)} %', formaterNombre(v.tva, decimales: 2)),
    if (affichage != ParametresVente.affichagePrixTva) l10n.prixDetailTtc(formaterNombre(prix, decimales: 2)),
  ];
  return '${parties.join(' · ')} $devise';
}
