import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../domain/models/vente.dart';
import '../tiers/tiers_providers.dart';

/// Bornes [du, au[ d'une période du DS (jours inclus).
(DateTime, DateTime) bornesPeriode(DsPeriode p) =>
    (DateTime(p.du.year, p.du.month, p.du.day), DateTime(p.au.year, p.au.month, p.au.day + 1));

/// Paniers d'une période (écran Ventes), rafraîchis après chaque écriture commerciale.
final paniersProvider = FutureProvider.family<List<PanierResume>, (DateTime, DateTime)>((ref, bornes) {
  ref.watch(commerceVersionProvider);
  return ref.watch(venteRepositoryProvider).paniers(depuis: bornes.$1, jusqua: bornes.$2);
});
