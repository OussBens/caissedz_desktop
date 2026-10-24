import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/archivage_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/archivage.dart';
import '../historique/historique_providers.dart';
import 'export_module.dart';
import 'statuts.dart';

final archivageServiceProvider = Provider<ArchivageService>((ref) {
  final niveau = ref.watch(licenceProvider).niveau;
  return ArchivageService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    maxMagasins: niveau?.magasins,
    maxCaisses: niveau?.caisses,
    maxCaissiers: niveau?.caissiers,
  );
});

/// Motif localisé d'un blocage de suppression, d'archivage ou de restauration.
String messageBlocageArchivage(AppLocalizations l10n, BlocageArchivage b) => switch (b) {
  BlocageArchivage.systeme => l10n.archBloqueSysteme,
  BlocageArchivage.inconnu => l10n.archBloqueInconnu,
  BlocageArchivage.stockNonNul => l10n.archBloqueStock,
  BlocageArchivage.dansPack => l10n.archBloqueDansPack,
  BlocageArchivage.soldeNonNul => l10n.archBloqueSolde,
  BlocageArchivage.magasinPrincipal => l10n.archBloqueMagasinPrincipal,
  BlocageArchivage.sessionOuverte => l10n.archBloqueSession,
  BlocageArchivage.soldeCaisse => l10n.archBloqueSoldeCaisse,
  BlocageArchivage.compteCourant => l10n.archBloqueCompteCourant,
  BlocageArchivage.utilisateursRattaches => l10n.archBloqueRoleUtilise,
  BlocageArchivage.limiteLicence => l10n.archBloqueLimite,
  BlocageArchivage.etatInchange => l10n.archBloqueEtat,
};

/// Bouton de bascule entre la liste et ses archives (emplacement `secondaire` de `DsModuleTable`).
Widget boutonArchives(
  AppLocalizations l10n, {
  required bool archives,
  required int nombre,
  required ValueChanged<bool> onChanged,
  Key? cle,
}) => DsButton(
  key: cle,
  libelle: archives ? l10n.archRetourListe : l10n.archArchives(nombre),
  icone: archives ? LucideIcons.arrowLeft : LucideIcons.archive,
  variante: DsButtonVariante.secondaire,
  onPressed: () => onChanged(!archives),
);

/// Bandeau de la vue Archives (au-dessus du tableau, `apresFiltres`).
class BandeauArchives extends StatelessWidget {
  const BandeauArchives({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: DsSpacing.s2),
      decoration: BoxDecoration(color: c.infoTint, borderRadius: BorderRadius.circular(DsRadius.md)),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          Icon(LucideIcons.archive, size: 16, color: c.infoFg),
          Expanded(
            child: Text(AppLocalizations.of(context).archBandeau, style: t.bodySm.copyWith(color: c.infoFg)),
          ),
        ],
      ),
    );
  }
}

/// Colonnes « Archivé le / par » de la vue Archives.
List<DsColonne<T>> colonnesArchive<T>(
  BuildContext context,
  WidgetRef ref, {
  required DateTime? Function(T) le,
  required String? Function(T) par,
}) {
  final l10n = AppLocalizations.of(context);
  final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
  return [
    DsColonne<T>(
      id: 'archive_le',
      libelle: l10n.archColArchiveLe,
      attenue: true,
      valeur: le,
      cellule: (_, x) => Text(le(x) == null ? '' : formatDateHeure.format(le(x)!)),
    ),
    DsColonne<T>(id: 'archive_par', libelle: l10n.archColArchivePar, valeur: (x) => noms[par(x)] ?? par(x) ?? ''),
  ];
}

/// Vue Archives d'un module : fiches archivées avec les colonnes du module et « Archivé le / par » ;
/// actions Détail (lecture seule) et Restaurer. [bouton] ramène à la liste ([boutonArchives]).
Widget tableArchives<T>(
  BuildContext context,
  WidgetRef ref, {
  required Key key,
  required String entite,
  required List<T> lignes,
  required List<DsColonne<T>> colonnes,
  required Object Function(T) cle,
  required String Function(T) texteRecherche,
  required DateTime? Function(T) archiveLe,
  required String? Function(T) archivePar,
  required FutureOr<void> Function(List<T> choix, VoidCallback effacer) onRestaurer,
  required Widget bouton,
  void Function(T)? onDetail,
  bool chargement = false,
}) {
  final l10n = AppLocalizations.of(context);
  return DsModuleTable<T>(
    key: key,
    entite: entite,
    lignes: lignes,
    chargement: chargement,
    colonnes: [
      ...colonnes,
      ...colonnesArchive<T>(context, ref, le: archiveLe, par: archivePar),
    ],
    cle: cle,
    permissions: permissionsSession(ref),
    messageVide: l10n.archAucune,
    texteRecherche: texteRecherche,
    apresFiltres: const BandeauArchives(),
    onOuvrir: onDetail,
    actions: [
      if (onDetail != null)
        DsActionModule<T>(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => onDetail(choix.first),
        ),
      DsActionModule<T>(
        cle: const ValueKey('archives_restaurer'),
        libelle: l10n.dsRestaurer,
        icone: LucideIcons.archiveRestore,
        onPressed: onRestaurer,
      ),
    ],
    secondaire: bouton,
  );
}

/// Suppression en lot (`BulkActionDialog delete`) : une fiche sans historique est supprimée, une fiche qui en a
/// un est archivée (annoncé ligne par ligne) ; les fiches bloquées sont signalées avec leur motif.
Future<void> supprimerOuArchiver<T>(
  BuildContext context,
  WidgetRef ref, {
  required EntiteArchivable entite,
  required List<T> choix,
  required String Function(T) code,
  required String Function(T) titre,
  required String libelleEntite,
  required String libelleEntites,
  required VoidCallback effacer,
  required VoidCallback rafraichir,
}) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(archivageServiceProvider);
  final issues = {
    for (final i in await service.analyser(entite, [for (final x in choix) code(x)])) i.code: i,
  };
  if (!context.mounted) return;
  final archivages = issues.values.any((i) => i.archivage && i.blocage == null);
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.supprimer,
    entite: libelleEntite,
    entitePluriel: libelleEntites,
    description: archivages ? l10n.archDescription : null,
    elements: [
      for (final x in choix)
        DsElementLot(
          id: code(x),
          titre: titre(x),
          sousTitre: code(x),
          meta: issues[code(x)]!.archivage ? l10n.archSeraArchive : l10n.archSeraSupprime,
          motifBlocage: switch (issues[code(x)]!.blocage) {
            null => null,
            final b => messageBlocageArchivage(l10n, b),
          },
        ),
    ],
  );
  if (ok == null || !context.mounted) return;
  final codes = [
    for (final i in issues.values)
      if (i.blocage == null) i.code,
  ];
  final r = await _executer(context, () => service.supprimer(entite, codes));
  rafraichir();
  effacer();
  if (r == null || !context.mounted) return;
  afficherToast(context, titre: l10n.archToast(r.supprimes, r.archives));
}

/// Restauration en lot des fiches archivées (actives à nouveau) ; la limite du palier est signalée.
Future<void> restaurerArchives<T>(
  BuildContext context,
  WidgetRef ref, {
  required EntiteArchivable entite,
  required List<T> choix,
  required String Function(T) code,
  required String Function(T) titre,
  required String libelleEntite,
  required String libelleEntites,
  required VoidCallback effacer,
  required VoidCallback rafraichir,
}) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(archivageServiceProvider);
  final blocages = await service.analyserRestauration(entite, [for (final x in choix) code(x)]);
  if (!context.mounted) return;
  final ok = await afficherActionLot(
    context,
    action: DsActionLot.restaurer,
    entite: libelleEntite,
    entitePluriel: libelleEntites,
    elements: [
      for (final x in choix)
        DsElementLot(
          id: code(x),
          titre: titre(x),
          sousTitre: code(x),
          motifBlocage: switch (blocages[code(x)]) {
            null => null,
            final b => messageBlocageArchivage(l10n, b),
          },
        ),
    ],
  );
  if (ok == null || !context.mounted) return;
  final codes = [
    for (final MapEntry(key: c, value: b) in blocages.entries)
      if (b == null) c,
  ];
  final n = await _executer(context, () => service.restaurer(entite, codes));
  rafraichir();
  effacer();
  if (n == null || !context.mounted) return;
  afficherToast(context, titre: l10n.archToastRestaures(n));
}

/// Exécute [action] ; un refus (fiche modifiée entre l'aperçu et la validation) s'affiche en erreur.
Future<R?> _executer<R>(BuildContext context, Future<R> Function() action) async {
  final l10n = AppLocalizations.of(context);
  String erreur;
  try {
    return await action();
  } on ArchivageException catch (e) {
    erreur = '${e.code} : ${messageBlocageArchivage(l10n, e.blocage)}';
  } on DatabaseException {
    erreur = l10n.archErreur;
  }
  if (context.mounted) {
    await afficherResultat(context, type: DsResultatType.erreur, titre: l10n.archErreur, message: erreur);
  }
  return null;
}
