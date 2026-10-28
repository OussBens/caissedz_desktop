import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/audit.dart';
import '../historique/historique_providers.dart';
import 'statuts.dart';

/// Colonnes d'audit d'un tableau (créé le / par, modifié le / par), masquées par défaut.
List<DsColonne<T>> colonnesAudit<T>(
  BuildContext context,
  WidgetRef ref,
  Audit Function(T ligne) audit, {
  bool creeLeVisible = false,
}) {
  final l10n = AppLocalizations.of(context);
  final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
  String nom(String? code) => code == null ? '' : (noms[code] ?? code);
  String date(DateTime? d) => d == null ? '' : formatDateHeure.format(d);
  return [
    DsColonne<T>(
      id: 'audit_cree_le',
      libelle: l10n.auditCreeLe,
      visibleParDefaut: creeLeVisible,
      attenue: true,
      valeur: (x) => audit(x).creeLe,
      cellule: (_, x) => Text(date(audit(x).creeLe)),
    ),
    DsColonne<T>(
      id: 'audit_cree_par',
      libelle: l10n.auditCreePar,
      visibleParDefaut: false,
      valeur: (x) => nom(audit(x).creePar),
    ),
    DsColonne<T>(
      id: 'audit_modifie_le',
      libelle: l10n.auditModifieLe,
      visibleParDefaut: false,
      attenue: true,
      valeur: (x) => audit(x).modifieLe,
      cellule: (_, x) => Text(date(audit(x).modifieLe)),
    ),
    DsColonne<T>(
      id: 'audit_modifie_par',
      libelle: l10n.auditModifiePar,
      visibleParDefaut: false,
      valeur: (x) => nom(audit(x).modifiePar),
    ),
  ];
}

/// Section « Traçabilité » d'un dialog de détail, toujours en dernier : créé le / par, modifié le / par,
/// archivé le / par pour une fiche archivée, puis les [complements] propres au document (validation, annulation…).
DsSectionDetail sectionAudit(BuildContext context, Audit audit, {List<DsKeyValue> complements = const []}) =>
    DsSectionDetail(
      titre: AppLocalizations.of(context).auditTitre,
      icone: LucideIcons.shieldCheck,
      contenu: GrilleAudit(audit, complements: complements),
    );

/// Grille des champs d'audit (noms des utilisateurs résolus ; « — » quand une valeur manque).
class GrilleAudit extends ConsumerWidget {
  const GrilleAudit(this.audit, {super.key, this.complements = const []});
  final Audit audit;
  final List<DsKeyValue> complements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    String nom(String? code) => code == null || code.isEmpty ? '—' : (noms[code] ?? code);
    String date(DateTime? d) => d == null ? '—' : formatDateHeure.format(d);
    return DsKeyValueGrid(
      colonnes: 4,
      dense: true,
      items: [
        DsKeyValue(l10n.auditCreeLe, date(audit.creeLe)),
        DsKeyValue(l10n.auditCreePar, nom(audit.creePar)),
        DsKeyValue(l10n.auditModifieLe, date(audit.modifieLe)),
        DsKeyValue(l10n.auditModifiePar, nom(audit.modifiePar)),
        if (audit.archive) ...[
          DsKeyValue(l10n.archColArchiveLe, date(audit.archiveLe)),
          DsKeyValue(l10n.archColArchivePar, nom(audit.archivePar)),
        ],
        ...complements,
      ],
    );
  }
}
