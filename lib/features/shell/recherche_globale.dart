import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/recherche_globale_repository.dart';
import '../../domain/modules.dart';
import '../commun/statuts.dart';
import 'app_shell.dart';

/// Intention « recherche globale » (Ctrl+K).
class RechercheGlobaleIntent extends Intent {
  const RechercheGlobaleIntent();
}

/// Icône de la barre supérieure (à côté du témoin réseau et des alertes) : ouvre la recherche globale.
class ChampRechercheGlobale extends StatelessWidget {
  const ChampRechercheGlobale({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsIconButton(
      key: const ValueKey('topbar_recherche'),
      icone: LucideIcons.search,
      tooltip: '${l10n.rechercheGlobaleTitre} (Ctrl K)',
      onPressed: () => afficherRechercheGlobale(context),
    );
  }
}

/// Recherche dans tout le système : produits, tiers, ventes, factures, documents, entrées, retours, versements…
/// Un clic ouvre le module du résultat, sur le bon onglet, avec la recherche de la liste pré-remplie.
Future<void> afficherRechercheGlobale(BuildContext context) =>
    afficherDialog<void>(context, builder: (_) => const RechercheGlobaleDialog());

class RechercheGlobaleDialog extends ConsumerStatefulWidget {
  const RechercheGlobaleDialog({super.key});

  @override
  ConsumerState<RechercheGlobaleDialog> createState() => _RechercheGlobaleDialogState();
}

class _RechercheGlobaleDialogState extends ConsumerState<RechercheGlobaleDialog> {
  String _texte = '';
  List<ResultatRecherche> _resultats = const [];
  Timer? _attente;
  int _requete = 0;

  @override
  void dispose() {
    _attente?.cancel();
    super.dispose();
  }

  void _changer(String v) {
    _attente?.cancel();
    _attente = Timer(const Duration(milliseconds: 200), () => _chercher(v));
  }

  Future<void> _chercher(String v) async {
    final numero = ++_requete;
    final trouves = await RechercheGlobaleRepository(ref.read(appDatabaseProvider).db).rechercher(v);
    if (!mounted || numero != _requete) return;
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider);
    final licence = ref.read(licenceProvider);
    bool accessible(ResultatRecherche r) {
      final m = Modules.parId(r.moduleId);
      return m != null &&
          verrouModule(l10n, m, licence: licence, session: session) == null &&
          (session?.peutAcceder(m.idAcces) ?? false);
    }

    setState(() {
      _texte = v.trim();
      _resultats = trouves.where(accessible).toList();
    });
  }

  void _ouvrir(ResultatRecherche r) {
    final m = Modules.parId(r.moduleId);
    if (m == null) return;
    Navigator.of(context).pop();
    context.go(
      Uri(
        path: m.route,
        queryParameters: {'q': r.code, if (r.onglet != null && r.onglet! > 0) 'onglet': '${r.onglet}'},
      ).toString(),
    );
  }

  static IconData _icone(String type) => switch (type) {
    TypesRecherche.facture => LucideIcons.receipt,
    TypesRecherche.livraison => LucideIcons.truck,
    _ =>
      Modules.parId(switch (type) {
            TypesRecherche.produit => 'produits',
            TypesRecherche.client => 'clients',
            TypesRecherche.fournisseur => 'fournisseurs',
            TypesRecherche.vente => 'ventes',
            TypesRecherche.document => 'documents',
            TypesRecherche.entree => 'entrees',
            TypesRecherche.commandeFournisseur => 'commandes_fournisseurs',
            TypesRecherche.retour => 'retours',
            TypesRecherche.versement => 'versements',
            TypesRecherche.sortie => 'sorties',
            TypesRecherche.transfert => 'transferts',
            _ => 'besoins',
          })?.icone ??
          LucideIcons.search,
  };

  static String _libelle(AppLocalizations l10n, String type) => switch (type) {
    TypesRecherche.produit => l10n.moduleProduits,
    TypesRecherche.client => l10n.moduleClients,
    TypesRecherche.fournisseur => l10n.moduleFournisseurs,
    TypesRecherche.vente => l10n.moduleVentes,
    TypesRecherche.facture => l10n.ventesOngletFactures,
    TypesRecherche.document => l10n.moduleDocuments,
    TypesRecherche.livraison => l10n.docOngletLivraisons,
    TypesRecherche.entree => l10n.moduleEntrees,
    TypesRecherche.commandeFournisseur => l10n.moduleCommandesFournisseurs,
    TypesRecherche.retour => l10n.moduleRetours,
    TypesRecherche.versement => l10n.moduleVersements,
    TypesRecherche.sortie => l10n.moduleSorties,
    TypesRecherche.transfert => l10n.moduleTransferts,
    _ => l10n.moduleBesoins,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final hauteur = (MediaQuery.sizeOf(context).height - 300).clamp(240.0, 520.0);
    final Widget liste;
    if (_texte.length < 2) {
      liste = DsVide(
        message: l10n.rechercheGlobaleTitre,
        description: l10n.rechercheGlobaleAide,
        icone: LucideIcons.search,
      );
    } else if (_resultats.isEmpty) {
      liste = DsVide(message: l10n.rechercheGlobaleAucun(_texte), icone: LucideIcons.searchX);
    } else {
      liste = ListView(
        children: [
          for (final type in TypesRecherche.tous)
            if (_resultats.any((r) => r.type == type)) ...[
              Padding(
                padding: const EdgeInsets.only(top: DsSpacing.s3, bottom: DsSpacing.s1),
                child: Row(
                  spacing: DsSpacing.s2,
                  children: [
                    Icon(_icone(type), size: DsTailles.iconeSm, color: c.primary),
                    Text(_libelle(l10n, type).toUpperCase(), style: t.overline.copyWith(color: c.primary)),
                  ],
                ),
              ),
              for (final r in _resultats.where((r) => r.type == type))
                InkWell(
                  key: ValueKey('recherche_${r.code}'),
                  borderRadius: DsRadius.borderMd,
                  onTap: () => _ouvrir(r),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s2, vertical: DsSpacing.s2),
                    child: Row(
                      spacing: DsSpacing.s3,
                      children: [
                        SizedBox(width: 90, child: Text(r.code, style: t.bodySmStrong)),
                        Expanded(
                          child: Text(r.titre, style: t.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (r.detail.isNotEmpty)
                          Text(r.detail, style: t.bodySm.copyWith(color: c.textMuted), maxLines: 1),
                        if (r.date != null)
                          Text(formatDateHeure.format(r.date!), style: t.caption.copyWith(color: c.textMuted)),
                        Icon(LucideIcons.chevronRight, size: DsTailles.iconeSm, color: c.textMuted),
                      ],
                    ),
                  ),
                ),
            ],
        ],
      );
    }
    return DsDialog(
      titre: l10n.rechercheGlobaleTitre,
      iconeData: LucideIcons.search,
      largeur: 820,
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s2,
        children: [
          DsSearchField(
            key: const ValueKey('recherche_globale_champ'),
            autofocus: true,
            grand: true,
            kbd: '',
            indice: l10n.rechercheGlobaleIndice,
            onChanged: _changer,
            onSubmitted: (_) {
              if (_resultats.isNotEmpty) _ouvrir(_resultats.first);
            },
          ),
          SizedBox(height: hauteur, child: liste),
        ],
      ),
    );
  }
}
