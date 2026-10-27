import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
