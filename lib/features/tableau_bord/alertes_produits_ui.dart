import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/alertes_produits.dart';
import '../commercial/commandes_fournisseurs_page.dart';
import '../produits/catalogue_dialogs.dart';
import '../produits/produit_form_dialog.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_dialogs.dart';
import 'alertes_produits_providers.dart';

String libelleGroupeAlerte(AppLocalizations l10n, GroupeAlerteProduit g) => switch (g) {
  GroupeAlerteProduit.ventes => l10n.alpGroupeVentes,
  GroupeAlerteProduit.stock => l10n.alpGroupeStock,
  GroupeAlerteProduit.prix => l10n.alpGroupePrix,
  GroupeAlerteProduit.qualite => l10n.alpGroupeQualite,
  GroupeAlerteProduit.marche => l10n.alpGroupeMarche,
};

String libelleTypeAlerte(AppLocalizations l10n, TypeAlerteProduit t) => switch (t) {
  TypeAlerteProduit.meilleuresVentes => l10n.alpMeilleuresVentes,
  TypeAlerteProduit.stockDormant => l10n.alpStockDormant,
  TypeAlerteProduit.candidatsRemise => l10n.alpCandidatsRemise,
  TypeAlerteProduit.margeFaible => l10n.alpMargeFaible,
  TypeAlerteProduit.retoursEleves => l10n.alpRetoursEleves,
  TypeAlerteProduit.enHausse => l10n.alpEnHausse,
  TypeAlerteProduit.stockLent => l10n.alpStockLent,
  TypeAlerteProduit.jamaisVendus => l10n.alpJamaisVendus,
  TypeAlerteProduit.remisesInefficaces => l10n.alpRemisesInefficaces,
  TypeAlerteProduit.stockAnormal => l10n.alpStockAnormal,
  TypeAlerteProduit.hausseFournisseur => l10n.alpHausseFournisseur,
  TypeAlerteProduit.achetesEnsemble => l10n.alpAchetesEnsemble,
  TypeAlerteProduit.stockDesequilibre => l10n.alpStockDesequilibre,
  TypeAlerteProduit.ruptureSansCommande => l10n.alpRuptureSansCommande,
  TypeAlerteProduit.saisonniers => l10n.alpSaisonniers,
  TypeAlerteProduit.rupturesFrequentes => l10n.alpRupturesFrequentes,
  TypeAlerteProduit.ficheIncomplete => l10n.alpFicheIncomplete,
  TypeAlerteProduit.bonneMargePeuVendus => l10n.alpBonneMargePeuVendus,
  TypeAlerteProduit.nouveautesMarche => l10n.alpNouveautesMarche,
  TypeAlerteProduit.tendancesMarche => l10n.alpTendancesMarche,
};

/// Règle de l'alerte (Paramètres › Alertes produits, infobulle de la carte du tableau de bord).
String regleAlerte(AppLocalizations l10n, TypeAlerteProduit t) => switch (t) {
  TypeAlerteProduit.meilleuresVentes => l10n.alpRegleMeilleuresVentes,
  TypeAlerteProduit.stockDormant => l10n.alpRegleStockDormant,
  TypeAlerteProduit.candidatsRemise => l10n.alpRegleCandidatsRemise,
  TypeAlerteProduit.margeFaible => l10n.alpRegleMargeFaible,
  TypeAlerteProduit.retoursEleves => l10n.alpRegleRetoursEleves,
  TypeAlerteProduit.enHausse => l10n.alpRegleEnHausse,
  TypeAlerteProduit.stockLent => l10n.alpRegleStockLent,
  TypeAlerteProduit.jamaisVendus => l10n.alpRegleJamaisVendus,
  TypeAlerteProduit.remisesInefficaces => l10n.alpRegleRemisesInefficaces,
  TypeAlerteProduit.stockAnormal => l10n.alpRegleStockAnormal,
  TypeAlerteProduit.hausseFournisseur => l10n.alpRegleHausseFournisseur,
  TypeAlerteProduit.achetesEnsemble => l10n.alpRegleAchetesEnsemble,
  TypeAlerteProduit.stockDesequilibre => l10n.alpRegleStockDesequilibre,
  TypeAlerteProduit.ruptureSansCommande => l10n.alpRegleRuptureSansCommande,
  TypeAlerteProduit.saisonniers => l10n.alpRegleSaisonniers,
  TypeAlerteProduit.rupturesFrequentes => l10n.alpRegleRupturesFrequentes,
  TypeAlerteProduit.ficheIncomplete => l10n.alpRegleFicheIncomplete,
  TypeAlerteProduit.bonneMargePeuVendus => l10n.alpRegleBonneMargePeuVendus,
  TypeAlerteProduit.nouveautesMarche => l10n.alpRegleNouveautesMarche,
  TypeAlerteProduit.tendancesMarche => l10n.alpRegleTendancesMarche,
};

String libelleActionAlerte(AppLocalizations l10n, ActionAlerteProduit a) => switch (a) {
  ActionAlerteProduit.creerBesoin => l10n.alpActionBesoin,
  ActionAlerteProduit.creerRemise => l10n.alpActionRemise,
  ActionAlerteProduit.modifierPrix => l10n.alpActionPrix,
  ActionAlerteProduit.voirRetours => l10n.alpActionRetours,
  ActionAlerteProduit.modifierRemise => l10n.alpActionModifierRemise,
  ActionAlerteProduit.voirMouvements => l10n.alpActionMouvements,
  ActionAlerteProduit.creerPack => l10n.alpActionPack,
  ActionAlerteProduit.creerTransfert => l10n.alpActionTransfert,
  ActionAlerteProduit.creerCommande => l10n.alpActionCommande,
  ActionAlerteProduit.ajusterSeuil => l10n.alpActionSeuil,
  ActionAlerteProduit.modifierProduit => l10n.alpActionFiche,
  ActionAlerteProduit.completerProduit => l10n.alpActionCreerProduit,
  ActionAlerteProduit.ajouterFavori => l10n.alpActionFavori,
};

/// Libellé d'un seuil des Paramètres.
String libelleSeuilAlerte(AppLocalizations l10n, String cle) => switch (cle) {
  SeuilsAlertesProduits.clePeriode => l10n.alpSeuilPeriode,
  SeuilsAlertesProduits.cleTopN => l10n.alpSeuilTopN,
  SeuilsAlertesProduits.cleCouverture => l10n.alpSeuilCouverture,
  SeuilsAlertesProduits.cleDormant => l10n.alpSeuilDormant,
  SeuilsAlertesProduits.cleBaisse => l10n.alpSeuilBaisse,
  SeuilsAlertesProduits.cleMargeRemise => l10n.alpSeuilMargeRemise,
  SeuilsAlertesProduits.cleMargeFaible => l10n.alpSeuilMargeFaible,
  SeuilsAlertesProduits.cleRetours => l10n.alpSeuilRetours,
  SeuilsAlertesProduits.cleHausseJours => l10n.alpSeuilHausseJours,
  SeuilsAlertesProduits.cleHaussePct => l10n.alpSeuilHaussePct,
  SeuilsAlertesProduits.cleLent => l10n.alpSeuilLent,
  SeuilsAlertesProduits.cleJamaisVendu => l10n.alpSeuilJamaisVendu,
  SeuilsAlertesProduits.cleCasse => l10n.alpSeuilCasse,
  SeuilsAlertesProduits.cleEcart => l10n.alpSeuilEcart,
  SeuilsAlertesProduits.cleHausseAchat => l10n.alpSeuilHausseAchat,
  SeuilsAlertesProduits.cleEnsemble => l10n.alpSeuilEnsemble,
  SeuilsAlertesProduits.cleRetard => l10n.alpSeuilRetard,
  SeuilsAlertesProduits.cleSaison => l10n.alpSeuilSaison,
  SeuilsAlertesProduits.cleRuptures => l10n.alpSeuilRuptures,
  SeuilsAlertesProduits.cleBonneMarge => l10n.alpSeuilBonneMarge,
  SeuilsAlertesProduits.cleNouveautes => l10n.alpSeuilNouveautes,
  _ => cle,
};

/// Unité affichée après un seuil : jours, %, fois, pièces (aucune pour un nombre de produits).
String? uniteSeuilAlerte(AppLocalizations l10n, String cle) {
  if (SeuilsAlertesProduits.clesJours.contains(cle)) return l10n.alpJours;
  if (SeuilsAlertesProduits.clesPourcentage.contains(cle)) return '%';
  return switch (cle) {
    SeuilsAlertesProduits.cleCasse => l10n.alpFois,
    SeuilsAlertesProduits.cleEcart => l10n.prdPcs,
    _ => null,
  };
}

IconData iconeAlerte(TypeAlerteProduit t) => switch (t) {
  TypeAlerteProduit.meilleuresVentes => LucideIcons.trophy,
  TypeAlerteProduit.stockDormant => LucideIcons.hourglass,
  TypeAlerteProduit.candidatsRemise => LucideIcons.badgePercent,
  TypeAlerteProduit.margeFaible => LucideIcons.trendingDown,
  TypeAlerteProduit.retoursEleves => LucideIcons.undo2,
  TypeAlerteProduit.enHausse => LucideIcons.trendingUp,
  TypeAlerteProduit.stockLent => LucideIcons.snail,
  TypeAlerteProduit.jamaisVendus => LucideIcons.packageX,
  TypeAlerteProduit.remisesInefficaces => LucideIcons.percent,
  TypeAlerteProduit.stockAnormal => LucideIcons.triangleAlert,
  TypeAlerteProduit.hausseFournisseur => LucideIcons.receipt,
  TypeAlerteProduit.achetesEnsemble => LucideIcons.link,
  TypeAlerteProduit.stockDesequilibre => LucideIcons.arrowLeftRight,
  TypeAlerteProduit.ruptureSansCommande => LucideIcons.truck,
  TypeAlerteProduit.saisonniers => LucideIcons.calendarClock,
  TypeAlerteProduit.rupturesFrequentes => LucideIcons.activity,
  TypeAlerteProduit.ficheIncomplete => LucideIcons.fileWarning,
  TypeAlerteProduit.bonneMargePeuVendus => LucideIcons.gem,
  TypeAlerteProduit.nouveautesMarche => LucideIcons.sparkles,
  TypeAlerteProduit.tendancesMarche => LucideIcons.flame,
};

String _q(double? v) => formaterNombre(v ?? 0, decimales: (v ?? 0) == (v ?? 0).roundToDouble() ? 0 : 1);
String _pct(double? v) => '${(v ?? 0) > 0 ? '+' : ''}${formaterNombre(v ?? 0, decimales: 1)}';

/// Détail lisible d'une alerte (colonne « Détail » de la Situation, export). [magasins] : code → nom ;
/// [cout] : la valeur immobilisée et les prix d'achat ne s'affichent qu'avec « Voir les prix d'achat ».
String detailAlerte(
  AppLocalizations l10n,
  AlerteProduit a, {
  required String devise,
  Map<String, String> magasins = const {},
  bool cout = true,
}) {
  String m(double? v) => formaterMontant(v ?? 0, devise);
  final stock = l10n.alpDStock(_q(a.stock));
  final parties = switch (a.type) {
    TypeAlerteProduit.meilleuresVentes => [l10n.alpDVendus(_q(a.quantite)), stock, l10n.alpDCouverture(_q(a.jours))],
    TypeAlerteProduit.stockDormant => [l10n.alpDSansVente(_q(a.jours)), stock, if (cout) l10n.alpDValeur(m(a.montant))],
    TypeAlerteProduit.candidatsRemise => [
      if (a.motifs.contains('dormant')) l10n.alpDSansVente(_q(a.jours)),
      if (a.motifs.contains('baisse')) l10n.alpDBaisse(_pct(a.evolution)),
      l10n.alpDMarge(_q(a.pct)),
      l10n.alpDRemiseConseillee(_q(a.suggestion)),
    ],
    TypeAlerteProduit.margeFaible => [
      l10n.alpDMarge(_q(a.pct)),
      l10n.alpDDernierAchat(m(a.montant)),
      if (a.critique) l10n.alpDPerte,
      l10n.alpDPrixConseille(m(a.suggestion)),
    ],
    TypeAlerteProduit.retoursEleves => [l10n.alpDRetours(_q(a.quantite), _q(a.quantite2), _q(a.pct))],
    TypeAlerteProduit.enHausse => [l10n.alpDHausse(_q(a.quantite), _q(a.quantite2), _pct(a.evolution)), stock],
    TypeAlerteProduit.stockLent => [stock, l10n.alpDEcoulement(_q(a.jours)), if (cout) l10n.alpDValeur(m(a.montant))],
    TypeAlerteProduit.jamaisVendus => [
      l10n.alpDJamaisVendu(_q(a.jours)),
      stock,
      if (cout) l10n.alpDValeur(m(a.montant)),
    ],
    TypeAlerteProduit.remisesInefficaces => [
      l10n.alpDRemise(a.remise ?? '', _q(a.quantite), _q(a.jours), _q(a.quantite2)),
    ],
    TypeAlerteProduit.stockAnormal => [
      if (a.motifs.contains('negatif')) l10n.alpDNegatif,
      if (a.motifs.contains('casse')) l10n.alpDCasses(_q(a.quantite)),
      if (a.motifs.contains('inventaire')) l10n.alpDEcart(_q(a.quantite2)),
      stock,
    ],
    TypeAlerteProduit.hausseFournisseur => [
      l10n.alpDHausseAchat(m(a.quantite2), m(a.montant), _pct(a.evolution)),
      if (a.suggestion != null) l10n.alpDPrixConseille(m(a.suggestion)),
    ],
    TypeAlerteProduit.achetesEnsemble => [l10n.alpDEnsemble(a.produit2 ?? '', _q(a.quantite), _q(a.pct))],
    TypeAlerteProduit.stockDesequilibre => [
      l10n.alpDTransfert(
        _q(a.suggestion),
        magasins[a.magasin2] ?? a.magasin2 ?? '',
        _q(a.quantite),
        magasins[a.magasin] ?? a.magasin ?? '',
        _q(a.stock),
      ),
    ],
    TypeAlerteProduit.ruptureSansCommande => [
      stock,
      if (a.motifs.contains('retard')) l10n.alpDCommandeRetard(_q(a.jours)) else l10n.alpDAucuneCommande,
    ],
    TypeAlerteProduit.saisonniers => [l10n.alpDSaison(_q(a.quantite), _q(a.jours)), stock],
    TypeAlerteProduit.rupturesFrequentes => [l10n.alpDRuptures(_q(a.jours), _q(a.quantite)), stock],
    TypeAlerteProduit.ficheIncomplete => [
      if (a.motifs.contains('codeBarres')) l10n.alpDSansCodeBarres,
      if (a.motifs.contains('photo')) l10n.alpDSansPhoto,
      if (a.motifs.contains('categorie')) l10n.alpDCategorieDivers,
      if (a.motifs.contains('prix')) l10n.alpDSansPrix,
    ],
    TypeAlerteProduit.bonneMargePeuVendus => [l10n.alpDMarge(_q(a.pct)), l10n.alpDVendus(_q(a.quantite)), stock],
    TypeAlerteProduit.nouveautesMarche => [l10n.alpDArrive(_q(a.jours))],
    TypeAlerteProduit.tendancesMarche => [l10n.alpDTendance(_q(a.jours))],
  };
  return parties.join(' · ');
}

/// Exécute l'action proposée par l'alerte [a] (besoin, remise, fiche produit, transfert, commande…).
Future<void> executerActionAlerte(BuildContext context, WidgetRef ref, AlerteProduit a) async {
  final repo = ref.read(catalogueRepositoryProvider);
  final p = await repo.produitParCode(a.produitCode);
  if (p == null || !context.mounted) return;
  switch (a.type.action) {
    case ActionAlerteProduit.creerBesoin:
      await afficherFormulaireBesoin(context, ref, proposes: [p]);
    case ActionAlerteProduit.creerRemise:
      await afficherFormulaireRemise(context, ref, proposes: [p], pourcentage: a.suggestion);
    case ActionAlerteProduit.modifierPrix ||
        ActionAlerteProduit.ajusterSeuil ||
        ActionAlerteProduit.modifierProduit ||
        ActionAlerteProduit.completerProduit:
      await afficherFormulaireProduit(context, produit: p, detaille: true);
    case ActionAlerteProduit.voirRetours:
      context.go('/retours?q=${Uri.encodeQueryComponent(p.designation)}');
    case ActionAlerteProduit.modifierRemise:
      final remise = (await ref.read(remisesProvider.future)).where((r) => r.code == a.remiseCode).firstOrNull;
      if (remise != null && context.mounted) await afficherFormulaireRemise(context, ref, remise: remise);
    case ActionAlerteProduit.voirMouvements:
      await afficherDetailStock(context, ref, p);
    case ActionAlerteProduit.creerPack:
      final p2 = a.produit2Code == null ? null : await repo.produitParCode(a.produit2Code!);
      if (context.mounted) await afficherFormulairePack(context, ref, proposes: [p, ?p2]);
    case ActionAlerteProduit.creerTransfert:
      await afficherFormulaireTransfert(
        context,
        ref,
        source: a.magasin2,
        destination: a.magasin,
        proposes: [(p, a.suggestion ?? 1)],
      );
    case ActionAlerteProduit.creerCommande:
      await afficherFormulaireCommandeFournisseur(context, ref, proposes: [(p, a.suggestion ?? 1)]);
    case ActionAlerteProduit.ajouterFavori:
      await changerFavorisCaisse(ref, [p.code]);
      if (context.mounted) {
        afficherToast(context, titre: AppLocalizations.of(context).alpFavoriAjoute(p.designation));
      }
  }
  // Une action a pu changer le catalogue, le stock ou les remises : les alertes sont recalculées.
  await ref.read(alertesProduitsProvider.notifier).actualiser();
}
