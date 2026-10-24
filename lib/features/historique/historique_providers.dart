import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/historique_repository.dart';
import '../../data/utilisateur_repository.dart';
import '../../domain/historique.dart';
import '../../domain/modules.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import '../utilisateurs/utilisateurs_providers.dart';
import '../zakat/zakat_dialogs.dart';

/// Lignes du journal d'une période `[du, au[`, rechargées à chaque visite et après chaque écriture.
final historiqueProvider = FutureProvider.autoDispose.family<List<EntreeHistorique>, (DateTime, DateTime)>((
  ref,
  bornes,
) {
  for (final p in [
    rapportsVersionProvider,
    commerceVersionProvider,
    stockVersionProvider,
    caisseVersionProvider,
    catalogueVersionProvider,
    utilisateursVersionProvider,
    zakatVersionProvider,
  ]) {
    ref.watch(p);
  }
  return HistoriqueRepository(ref.watch(appDatabaseProvider).db).lire(depuis: bornes.$1, jusqua: bornes.$2);
});

/// Noms affichés des utilisateurs (prénom nom, sinon identifiant), par code.
final nomsUtilisateursProvider = FutureProvider<Map<String, String>>((ref) async {
  ref.watch(utilisateursVersionProvider);
  final us = await UtilisateurRepository(ref.watch(appDatabaseProvider).db).tous();
  return {for (final u in us) u.code: u.nomComplet.isEmpty ? u.identifiant : u.nomComplet};
});

final DateFormat formatHorodatage = DateFormat('dd/MM/yyyy HH:mm');

/// Libellé du module d'une ligne (pseudo-module « Connexion » compris).
String libelleModuleHistorique(AppLocalizations l10n, String module) =>
    module == ModulesHistorique.connexion ? l10n.hiModuleConnexion : (Modules.parId(module)?.libelle(l10n) ?? module);

String libelleCategorie(AppLocalizations l10n, CategorieAction c) => switch (c) {
  CategorieAction.creation => l10n.hiCatCreation,
  CategorieAction.modification => l10n.hiCatModification,
  CategorieAction.annulation => l10n.hiCatAnnulation,
  CategorieAction.connexion => l10n.hiCatConnexion,
  CategorieAction.export => l10n.hiCatExport,
};

/// Ton du badge d'action (`ACT_TONE` du DS).
DsBadgeTon tonAction(EntreeHistorique e) => e.action == 'Dépense'
    ? DsBadgeTon.avertissement
    : switch (e.categorie) {
        CategorieAction.creation => DsBadgeTon.succes,
        CategorieAction.modification => DsBadgeTon.info,
        CategorieAction.annulation => DsBadgeTon.danger,
        CategorieAction.connexion => DsBadgeTon.neutre,
        CategorieAction.export => DsBadgeTon.primaire,
      };

/// Traduction de l'action stockée (valeur FR) ; une action inconnue s'affiche telle quelle.
String libelleAction(AppLocalizations l10n, String action) => switch (action) {
  'Création' => l10n.hiActCreation,
  'Modification' => l10n.hiActModification,
  'Annulation' => l10n.hiActAnnulation,
  'Désactivation' => l10n.hiActDesactivation,
  'Activation' => l10n.hiActActivation,
  'Suppression' => l10n.hiActSuppression,
  'Archivage' => l10n.hiActArchivage,
  'Versement' => l10n.hiActVersement,
  'Transfert' => l10n.hiActTransfert,
  'Réinitialisation du mot de passe' => l10n.hiActReinitialisation,
  'Retour' => l10n.hiActRetour,
  'Paramètres' => l10n.hiActParametres,
  'Ouverture' => l10n.hiActOuverture,
  'Fermeture' => l10n.hiActFermeture,
  'Encaissement' => l10n.hiActEncaissement,
  'Connexion' => l10n.hiActConnexion,
  'Déconnexion' => l10n.hiActDeconnexion,
  'Configuration initiale' => l10n.hiActConfiguration,
  'Clôture Z' => l10n.hiActClotureZ,
  'Affectation' => l10n.hiActAffectation,
  'Achat' => l10n.hiActAchat,
  'Apport' => l10n.hiActApport,
  'Dépense' => l10n.hiActDepense,
  'Paiement' => l10n.hiActPaiement,
  'Export' => l10n.hiActExport,
  'Sauvegarde' => l10n.hiActSauvegarde,
  'Restauration' => l10n.hiActRestauration,
  _ => action,
};

Widget badgeAction(BuildContext context, EntreeHistorique e) =>
    DsBadge(libelle: libelleAction(AppLocalizations.of(context), e.action), ton: tonAction(e));
