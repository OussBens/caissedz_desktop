import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/historique.dart';
import '../commun/chargement.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../ventes/ventes_providers.dart';
import 'historique_providers.dart';

/// Écran Historique (`HistoriqueScreen` du DS v2.2, §9.17) : journal de toutes les actions, filtres module /
/// action / utilisateur / poste / période, détail.
class HistoriquePage extends ConsumerStatefulWidget {
  const HistoriquePage({super.key});

  @override
  ConsumerState<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends ConsumerState<HistoriquePage> {
  DsPeriode _periode = DsPeriode.calculer('last7days');
  String? _module;
  CategorieAction? _action;
  String? _utilisateur;
  String? _poste;

  void _reinitialiser() => setState(() {
    _periode = DsPeriode.calculer('last7days');
    _module = null;
    _action = null;
    _utilisateur = null;
    _poste = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tous = ref.watch(historiqueProvider(bornesPeriode(_periode))).value ?? const <EntreeHistorique>[];
    final semaine = ref.watch(historiqueProvider(bornesPeriode(DsPeriode.calculer('last7days')))).value ?? const [];
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const <String, String>{};
    String nom(String code) => noms[code] ?? code;
    String module(EntreeHistorique e) => libelleModuleHistorique(l10n, e.module);
    List<String> distincts(String? Function(EntreeHistorique) f) =>
        {for (final e in tous) ?f(e)}.where((v) => v.isNotEmpty).toList()..sort();
    final lignes = tous
        .where(
          (e) =>
              (_module == null || e.module == _module) &&
              (_action == null || e.categorie == _action) &&
              (_utilisateur == null || e.utilisateurCode == _utilisateur) &&
              (_poste == null || e.poste == _poste),
        )
        .toList();
    int compte(CategorieAction c) => semaine.where((e) => e.categorie == c).length;
    final colonnes = <DsColonne<EntreeHistorique>>[
      DsColonne(
        id: 'd',
        libelle: l10n.hiColDate,
        attenue: true,
        valeur: (e) => e.date,
        cellule: (_, e) => Text(formatHorodatage.format(e.date)),
      ),
      DsColonne(id: 'u', libelle: l10n.hiUtilisateur, fort: true, valeur: (e) => nom(e.utilisateurCode)),
      DsColonne(id: 'module', libelle: l10n.hiModule, valeur: module),
      DsColonne(
        id: 'action',
        libelle: l10n.hiAction,
        valeur: (e) => libelleAction(l10n, e.action),
        cellule: (context, e) => Align(alignment: AlignmentDirectional.centerStart, child: badgeAction(context, e)),
      ),
      DsColonne(id: 'ref', libelle: l10n.hiColRef, attenue: true, valeur: (e) => e.entiteCode ?? '—'),
      DsColonne(id: 'desc', libelle: l10n.hiColDescription, valeur: (e) => e.detail ?? ''),
      DsColonne(id: 'poste', libelle: l10n.hiPoste, attenue: true, valeur: (e) => e.poste ?? '—'),
      DsColonne(id: 'code', libelle: l10n.hiColCode, attenue: true, visibleParDefaut: false, valeur: (e) => e.code),
    ];
    return PageModule(
      moduleId: 'historique',
      child: DsModuleTable<EntreeHistorique>(
        key: const ValueKey('historique'),
        entite: l10n.hiEntite,
        lignes: lignes,
        chargement: enChargement(ref.watch(historiqueProvider(bornesPeriode(_periode)))),
        colonnes: colonnes,
        cle: (e) => e.id,
        colonnesFiltres: 4,
        permissions: permissionsSession(ref),
        messageVide: l10n.hiAucun,
        kpis: [
          DsStatCard(libelle: l10n.hiKpiActions, valeur: '${semaine.length}', icone: LucideIcons.history),
          DsStatCard(
            libelle: l10n.hiKpiCreations,
            valeur: '${compte(CategorieAction.creation)}',
            icone: LucideIcons.circlePlus,
          ),
          DsStatCard(
            libelle: l10n.hiKpiModifications,
            valeur: '${compte(CategorieAction.modification)}',
            icone: LucideIcons.pencil,
          ),
          DsStatCard(
            libelle: l10n.hiKpiAnnulations,
            valeur: '${compte(CategorieAction.annulation)}',
            icone: LucideIcons.ban,
          ),
        ],
        periode: _periode,
        onPeriode: (p) => setState(() => _periode = p),
        indiceRecherche: l10n.hiRecherche,
        texteRecherche: (e) => '${e.entiteCode ?? ''} ${e.detail ?? ''} ${e.code}',
        nbFiltresActifs: [_module, _action, _utilisateur, _poste].where((f) => f != null).length,
        onReinitialiser: _reinitialiser,
        filtres: [
          _filtre<String?>(
            l10n.hiModule,
            cle: 'filtre_module_historique',
            valeur: _module,
            options: [null, ...distincts((e) => e.module)],
            libelle: (v) => v == null ? l10n.hiTous : libelleModuleHistorique(l10n, v),
            onChanged: (v) => setState(() => _module = v),
          ),
          _filtre<CategorieAction?>(
            l10n.hiAction,
            cle: 'filtre_action_historique',
            valeur: _action,
            options: const [null, ...CategorieAction.values],
            libelle: (v) => v == null ? l10n.hiToutes : libelleCategorie(l10n, v),
            onChanged: (v) => setState(() => _action = v),
          ),
          _filtre<String?>(
            l10n.hiUtilisateur,
            cle: 'filtre_utilisateur_historique',
            valeur: _utilisateur,
            options: [null, ...distincts((e) => e.utilisateurCode)],
            libelle: (v) => v == null ? l10n.hiTous : nom(v),
            liste: ListeMetier.utilisateur,
            onChanged: (v) => setState(() => _utilisateur = v),
          ),
          _filtre<String?>(
            l10n.hiPoste,
            cle: 'filtre_poste_historique',
            valeur: _poste,
            options: [null, ...distincts((e) => e.poste)],
            libelle: (v) => v ?? l10n.hiTous,
            onChanged: (v) => setState(() => _poste = v),
          ),
        ],
        onExport: peutExporter(ref)
            ? (format, es) => exporterTableau(
                context,
                ref,
                id: 'historique',
                titre: l10n.moduleHistorique,
                colonnes: colonnes,
                lignes: es,
                format: format,
              )
            : null,
        onOuvrir: (e) => afficherDetailHistorique(context, e, nom(e.utilisateurCode)),
        actions: [
          DsActionModule(
            libelle: l10n.hiDetail,
            icone: LucideIcons.eye,
            regle: DsRegleSelection.une,
            detail: true,
            onPressed: (choix, _) => afficherDetailHistorique(context, choix.first, nom(choix.first.utilisateurCode)),
          ),
        ],
      ),
    );
  }

  Widget _filtre<T>(
    String titre, {
    String? cle,
    required T valeur,
    required List<T> options,
    required String Function(T) libelle,
    required ValueChanged<T> onChanged,
    ListeMetier? liste,
  }) => DsFormRow(
    libelle: titre,
    largeurLibelle: 80,
    child: DsSelect<T>(
      key: cle == null ? null : ValueKey(cle),
      valeur: valeur,
      options: options,
      libelle: libelle,
      recherche: liste == null
          ? null
          : (options, valeur) async =>
                await rechercheListe(context, ref, liste)(options.cast<String?>(), valeur as String?) as T?,
      onChanged: (v) => onChanged(v as T),
    ),
  );
}

/// Détail d'une action (`EntityDetailDialog` 860 px) : action, puis contexte du poste.
Future<void> afficherDetailHistorique(BuildContext context, EntreeHistorique e, String utilisateur) {
  final l10n = AppLocalizations.of(context);
  final module = libelleModuleHistorique(l10n, e.module);
  final action = libelleAction(l10n, e.action);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 860,
      icone: LucideIcons.history,
      titre: '$action · $module',
      description: [formatHorodatage.format(e.date), utilisateur, ?e.poste].join(' · '),
      badges: [badgeAction(context, e)],
      sections: [
        DsSectionDetail(
          titre: l10n.hiSectionAction,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.hiUtilisateur, utilisateur),
            DsKeyValue(l10n.hiModule, module),
            DsKeyValue(l10n.hiReference, e.entiteCode ?? '—', mono: true),
            DsKeyValue(l10n.hiColDescription, (e.detail ?? '').isEmpty ? '—' : e.detail, span: 3),
          ],
        ),
        DsSectionDetail(
          titre: l10n.hiSectionContexte,
          icone: LucideIcons.monitor,
          items: [
            DsKeyValue(l10n.hiPoste, e.poste ?? '—'),
            DsKeyValue(l10n.hiColCode, e.code, mono: true),
            DsKeyValue(l10n.hiEntiteTechnique, e.entite, mono: true),
          ],
        ),
      ],
    ),
  );
}
