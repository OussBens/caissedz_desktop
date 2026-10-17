import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../data/historique_repository.dart';
import '../../data/parametre_repository.dart';
import '../../domain/pastilles.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import '../utilisateurs/utilisateurs_providers.dart';
import '../zakat/zakat_dialogs.dart';

/// Onglets « module#onglet » portant un point rouge (nouvelle activité non consultée par l'utilisateur connecté).
final pastillesProvider = NotifierProvider<PastillesNotifier, Set<String>>(PastillesNotifier.new);

/// Calcule les points rouges depuis le journal (Historique) et retient, par utilisateur, le dernier élément du
/// journal vu dans chaque onglet (paramètre `pastilles.<utilisateur>`). Au premier lancement, rien n'est allumé.
class PastillesNotifier extends Notifier<Set<String>> {
  String? _utilisateur;
  int? _base;
  int _dernier = 0;
  Map<String, int> _vus = {};
  Set<String> _courant = const {};

  String get _cle => 'pastilles.$_utilisateur';

  @override
  Set<String> build() {
    for (final p in [
      commerceVersionProvider,
      stockVersionProvider,
      catalogueVersionProvider,
      caisseVersionProvider,
      zakatVersionProvider,
      utilisateursVersionProvider,
    ]) {
      ref.watch(p);
    }
    final u = ref.watch(sessionProvider)?.utilisateur.code;
    if (u != _utilisateur) {
      _utilisateur = u;
      _base = null;
      _vus = {};
      _courant = const {};
    }
    if (u == null) return const {};
    Future.microtask(actualiser);
    return _courant;
  }

  Future<void> _charger() async {
    final db = ref.read(appDatabaseProvider).db;
    final brut = await ParametreRepository(db).lire(_cle);
    if (brut != null) {
      final m = jsonDecode(brut) as Map<String, Object?>;
      _base = m['base']! as int;
      _vus = (m['vus']! as Map<String, Object?>).map((k, v) => MapEntry(k, v! as int));
    } else {
      _base = await HistoriqueRepository(db).dernierId();
      await _enregistrer();
    }
  }

  Future<void> _enregistrer() =>
      ParametreRepository(ref.read(appDatabaseProvider).db).ecrire(_cle, jsonEncode({'base': _base, 'vus': _vus}));

  /// Relit le journal depuis la base et recalcule les points.
  Future<void> actualiser() async {
    if (_utilisateur == null) return;
    try {
      if (_base == null) await _charger();
      final base = _base!;
      final lignes = await HistoriqueRepository(ref.read(appDatabaseProvider).db).activiteDepuis(base);
      final allumes = <String>{};
      for (final l in lignes) {
        if (l.id > _dernier) _dernier = l.id;
        for (final c in PastillesModules.cibles(
          entite: l.entite,
          action: l.action,
          entiteCode: l.code,
          tiersType: l.tiersType,
          clientCode: l.clientCode,
        )) {
          if (l.id > (_vus[c] ?? base)) allumes.add(c);
        }
      }
      // Tout est vu : la base avance, la mémoire des onglets vus repart de zéro.
      if (allumes.isEmpty && lignes.isNotEmpty) {
        _base = _dernier;
        _vus = {};
        await _enregistrer();
      }
      _publier(allumes);
    } on Object {
      // Base fermée (déconnexion, tests) : les points restent tels quels.
    }
  }

  void _publier(Set<String> s) {
    if (s.length == _courant.length && s.containsAll(_courant)) return;
    _courant = Set.unmodifiable(s);
    state = _courant;
  }

  /// L'onglet [onglet] de [module] vient d'être consulté : son point s'éteint.
  Future<void> marquerVu(String module, int onglet) async {
    final c = PastillesModules.cible(module, onglet);
    if (!_courant.contains(c)) return;
    _vus[c] = _dernier;
    _publier({..._courant}..remove(c));
    try {
      await _enregistrer();
    } on Object {
      // Sans base, le point reste éteint pour cette session.
    }
  }
}
