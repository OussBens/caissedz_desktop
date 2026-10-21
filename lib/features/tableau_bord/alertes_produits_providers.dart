import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/alertes_produits_service.dart';
import '../../data/parametre_repository.dart';
import '../../domain/alertes_produits.dart';

final alertesProduitsServiceProvider = Provider<AlertesProduitsService>(
  (ref) => AlertesProduitsService(ref.watch(appDatabaseProvider).db),
);

/// Seuils des alertes produits (Paramètres › Alertes), relus après l'enregistrement des Paramètres.
final seuilsAlertesProduitsProvider = FutureProvider<SeuilsAlertesProduits>(
  (ref) => ref.watch(alertesProduitsServiceProvider).seuils(),
);

/// Alertes produits de l'utilisateur connecté. Calculées à la connexion, à l'ouverture du tableau de bord et de la
/// Situation, après l'enregistrement des Paramètres et toutes les 15 minutes ([demarrer]) — jamais à chaque vente.
class AlertesProduitsNotifier extends Notifier<AlertesProduits> {
  Timer? _minuterie;
  Future<AlertesProduits>? _enCours;

  /// Le dernier calcul a-t-il eu lieu ? (`false` : rien calculé depuis la connexion).
  bool calcule = false;

  @override
  AlertesProduits build() {
    ref.onDispose(() => _minuterie?.cancel());
    return AlertesProduits.vide;
  }

  /// Recalcul périodique (lancé au démarrage de l'application).
  void demarrer({Duration intervalle = const Duration(minutes: 15)}) {
    _minuterie?.cancel();
    _minuterie = Timer.periodic(intervalle, (_) => unawaited(actualiser()));
  }

  /// Recalcule les alertes (un seul calcul à la fois ; les appels pendant un calcul en reçoivent le résultat).
  Future<AlertesProduits> actualiser() => _enCours ??= _calculer().whenComplete(() => _enCours = null);

  Future<AlertesProduits> _calculer() async {
    final session = ref.read(sessionProvider);
    if (session == null) return state = AlertesProduits.vide;
    try {
      final a = await ref.read(alertesProduitsServiceProvider).calculer(session);
      // Application fermée ou autre utilisateur connecté entre-temps : le résultat est ignoré.
      if (!ref.mounted) return a;
      if (ref.read(sessionProvider)?.utilisateur.code != session.utilisateur.code) return state;
      calcule = true;
      return state = a;
    } on Object catch (e, pile) {
      developer.log('Alertes produits impossibles à calculer', name: 'caissedz.alertes', error: e, stackTrace: pile);
      return ref.mounted ? state : AlertesProduits.vide;
    }
  }

  void reinitialiser() {
    calcule = false;
    state = AlertesProduits.vide;
  }
}

final alertesProduitsProvider = NotifierProvider<AlertesProduitsNotifier, AlertesProduits>(AlertesProduitsNotifier.new);

/// Empreintes des alertes déjà consultées par l'utilisateur connecté, par type (paramètre
/// `alertes_produits_vues.<utilisateur>`) : un type dont les alertes ont changé allume le point rouge.
class AlertesProduitsVuesNotifier extends Notifier<Map<String, int>?> {
  String? _utilisateur;

  String get _cle => 'alertes_produits_vues.$_utilisateur';

  @override
  Map<String, int>? build() {
    _utilisateur = ref.watch(sessionProvider.select((s) => s?.utilisateur.code));
    if (_utilisateur == null) return null;
    unawaited(_charger());
    return null;
  }

  Future<void> _charger() async {
    final utilisateur = _utilisateur;
    final brut = await ParametreRepository(ref.read(appDatabaseProvider).db).lire(_cle);
    if (!ref.mounted || utilisateur != _utilisateur) return;
    Map<String, int> vues = {};
    try {
      if (brut != null) vues = (jsonDecode(brut) as Map<String, Object?>).map((k, v) => MapEntry(k, v! as int));
    } on Object {
      vues = {};
    }
    state = vues;
  }

  /// Les alertes de [types] (toutes si `null`) telles qu'affichées sont consultées.
  Future<void> marquerVues([Iterable<TypeAlerteProduit>? types]) async {
    if (_utilisateur == null) return;
    final empreintes = ref.read(alertesProduitsProvider).empreintes;
    final noms = (types ?? TypeAlerteProduit.values).map((t) => t.name).toSet();
    final vues = {...?state, for (final n in noms) n: ?empreintes[n]}
      ..removeWhere((n, _) => noms.contains(n) && !empreintes.containsKey(n));
    if (_egales(vues, state ?? const {})) return;
    state = vues;
    await ParametreRepository(ref.read(appDatabaseProvider).db).ecrire(_cle, jsonEncode(vues));
  }

  static bool _egales(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}

final alertesProduitsVuesProvider = NotifierProvider<AlertesProduitsVuesNotifier, Map<String, int>?>(
  AlertesProduitsVuesNotifier.new,
);

/// Types dont les alertes n'ont pas encore été consultées (point rouge du tableau de bord et de la Situation).
final alertesProduitsNouvellesProvider = Provider<Set<TypeAlerteProduit>>((ref) {
  final vues = ref.watch(alertesProduitsVuesProvider);
  if (vues == null) return const {};
  return {
    for (final MapEntry(:key, :value) in ref.watch(alertesProduitsProvider).empreintes.entries)
      if (vues[key] != value) ?TypeAlerteProduit.parNom(key),
  };
});

/// Analyse demandée à la Situation (carte « Alertes produits » du tableau de bord) : type d'alerte à afficher
/// (`null` : toutes). Lue puis effacée par la Situation.
class DemandeAlertesNotifier extends Notifier<({TypeAlerteProduit? type})?> {
  @override
  ({TypeAlerteProduit? type})? build() => null;

  void demander(TypeAlerteProduit? type) => state = (type: type);
  void effacer() => state = null;
}

final demandeAlertesProvider = NotifierProvider<DemandeAlertesNotifier, ({TypeAlerteProduit? type})?>(
  DemandeAlertesNotifier.new,
);
