import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/historique_repository.dart';
import '../../data/utilisateur_repository.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

/// Entrée du journal d'audit.
class EntreeHistorique {
  const EntreeHistorique({
    required this.id,
    required this.date,
    required this.utilisateurCode,
    required this.action,
    required this.entite,
    this.entiteCode,
    this.detail,
  });
  final int id;
  final DateTime date;
  final String utilisateurCode;
  final String action;
  final String entite;
  final String? entiteCode;
  final String? detail;

  factory EntreeHistorique.depuisLigne(Map<String, Object?> r) => EntreeHistorique(
    id: r['id'] as int,
    date: DateTime.parse(r['date'] as String).toLocal(),
    utilisateurCode: r['utilisateur_code'] as String,
    action: r['action'] as String,
    entite: r['entite'] as String,
    entiteCode: r['entite_code'] as String?,
    detail: r['detail'] as String?,
  );
}

final historiqueProvider = FutureProvider<List<EntreeHistorique>>((ref) async {
  ref.watch(rapportsVersionProvider);
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  ref.watch(caisseVersionProvider);
  ref.watch(catalogueVersionProvider);
  final rows = await HistoriqueRepository(ref.watch(appDatabaseProvider).db).lire(limite: 2000);
  return rows.map(EntreeHistorique.depuisLigne).toList();
});

final nomsUtilisateursProvider = FutureProvider<Map<String, String>>((ref) async {
  final us = await UtilisateurRepository(ref.watch(appDatabaseProvider).db).tous();
  return {for (final u in us) u.code: u.nom};
});

/// Historique des opérations (journal d'audit `historique`).
class HistoriquePage extends ConsumerStatefulWidget {
  const HistoriquePage({super.key});

  @override
  ConsumerState<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends ConsumerState<HistoriquePage> {
  String _entite = '';
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entrees = ref.watch(historiqueProvider).value ?? const [];
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const {};
    final entites = {for (final e in entrees) e.entite}.toList()..sort();
    final r = _recherche.trim().toLowerCase();
    final df = DateFormat('dd/MM/yyyy HH:mm:ss');
    final lignes = entrees.where((e) {
      if (_entite.isNotEmpty && e.entite != _entite) return false;
      if (r.isEmpty) return true;
      return [
        e.action,
        e.entite,
        e.entiteCode ?? '',
        e.detail ?? '',
        noms[e.utilisateurCode] ?? e.utilisateurCode,
      ].any((s) => s.toLowerCase().contains(r));
    }).toList();
    return DsPage(
      titre: l10n.historiqueTitre,
      onRecherche: (v) => setState(() => _recherche = v),
      filtres: SizedBox(
        width: 260,
        child: DsSelect<String>(
          valeur: _entite,
          options: ['', ...entites],
          libelle: (e) => e.isEmpty ? l10n.historiqueToutesEntites : e,
          onChanged: (v) => setState(() => _entite = v ?? ''),
        ),
      ),
      child: DsDataTable<EntreeHistorique>(
        colonnes: [
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (e) => e.date,
            largeur: 160,
            cellule: (_, e) => Text(df.format(e.date)),
          ),
          DsColonne(
            id: 'u',
            libelle: l10n.historiqueColUtilisateur,
            valeur: (e) => noms[e.utilisateurCode] ?? e.utilisateurCode,
            flex: 2,
          ),
          DsColonne(id: 'a', libelle: l10n.historiqueColAction, valeur: (e) => e.action, flex: 2),
          DsColonne(id: 'e', libelle: l10n.historiqueColEntite, valeur: (e) => e.entite, flex: 2),
          DsColonne(id: 'c', libelle: l10n.produitsColCode, valeur: (e) => e.entiteCode, largeur: 110),
          DsColonne(id: 'x', libelle: l10n.historiqueColDetail, valeur: (e) => e.detail, flex: 3),
        ],
        lignes: lignes,
        cle: (e) => e.id,
        messageVide: l10n.historiqueAucun,
      ),
    );
  }
}
