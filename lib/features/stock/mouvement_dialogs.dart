import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/audit.dart';
import '../../domain/models/stock.dart';
import '../commun/colonnes_audit.dart';
import '../commun/statuts.dart';
import '../entrees/entree_dialogs.dart';
import '../entrees/entrees_providers.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../retours/retours_dialogs.dart';
import '../tiers/tiers_providers.dart';
import '../ventes/ventes_dialogs.dart';
import 'stock_dialogs.dart';
import 'stock_providers.dart';

/// Icône d'un type de mouvement de stock.
IconData iconeTypeMouvement(String type) => switch (type) {
  TypesMouvement.vente => LucideIcons.shoppingCart,
  TypesMouvement.entree => LucideIcons.packagePlus,
  TypesMouvement.sortie => LucideIcons.packageMinus,
  TypesMouvement.transfert => LucideIcons.arrowLeftRight,
  TypesMouvement.retour => LucideIcons.undo2,
  TypesMouvement.inventaire => LucideIcons.clipboardCheck,
  TypesMouvement.initial => LucideIcons.flag,
  TypesMouvement.annulation => LucideIcons.ban,
  _ => LucideIcons.arrowLeftRight,
};

/// Le mouvement renvoie-t-il à une pièce consultable (vente, entrée, sortie, transfert, retour, inventaire) ?
bool aPieceMouvement(MouvementStock m) =>
    m.referenceCode != null &&
    const {'vente', 'annulation', 'achat', 'sortie', 'transfert', 'retour', 'inventaire'}.contains(m.referenceType);

/// Ouvre la pièce d'origine d'un mouvement selon son type : vente (ou vente annulée), entrée, sortie, transfert,
/// retour ou inventaire. Sans pièce (stock initial, entrée manuelle…) : le détail du mouvement lui-même.
Future<void> afficherPieceMouvement(BuildContext context, WidgetRef ref, MouvementStock m) async {
  final code = m.referenceCode;
  if (code == null || !aPieceMouvement(m)) return afficherDetailMouvement(context, ref, m, avecPiece: false);
  final repo = ref.read(stockRepositoryProvider);
  switch (m.referenceType) {
    case 'sortie':
      final s = await repo.sortie(code);
      if (s != null && context.mounted) return afficherDetailSortie(context, ref, s);
    case 'transfert':
      final t = await repo.transfert(code);
      if (t != null && context.mounted) return afficherDetailTransfert(context, ref, t);
    case 'achat':
      final a = await ref.read(achatServiceProvider).achat(code);
      if (a != null && context.mounted) return afficherDetailEntree(context, ref, a);
    case 'vente' || 'annulation':
      // Annulation d'une vente : la référence est le ticket annulé.
      final d = m.date;
      final paniers = await ref
          .read(venteRepositoryProvider)
          .paniers(depuis: d.subtract(const Duration(days: 366)), jusqua: DateTime(d.year, d.month, d.day + 1));
      final p = paniers.where((x) => x.vente.code == code).firstOrNull;
      final clients = {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom};
      if (p != null && context.mounted) return afficherDetailPanier(context, ref, p, nomsClients: clients);
    case 'retour':
      final r = await ref.read(tiersRepositoryProvider).retour(code);
      if (r == null) break;
      final noms = r.estClient
          ? {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom}
          : {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
      if (context.mounted) return afficherDetailRetour(context, ref, r, nomsTiers: noms);
    case 'inventaire':
      if (context.mounted) return afficherDetailInventaire(context, ref, code);
  }
  // Pièce introuvable (purgée, archivée…) : le mouvement reste consultable.
  if (context.mounted) return afficherDetailMouvement(context, ref, m, avecPiece: false);
}

/// Détail d'un mouvement de stock (`EntityDetailDialog` 760 px) : quantité signée, produit, magasin, référence,
/// motif, observation et traçabilité ; « Voir la pièce » ouvre le document d'origine quand il y en a un.
Future<void> afficherDetailMouvement(
  BuildContext context,
  WidgetRef ref,
  MouvementStock m, {
  bool avecPiece = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final produit = (await ref.read(produitsProvider.future)).where((p) => p.code == m.produitCode).firstOrNull;
  final magasins = {for (final x in await ref.read(magasinsProvider.future)) x.code: x.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final type = libelleTypeMouvement(l10n, m.type);
  final piece = avecPiece && aPieceMouvement(m);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 760,
      icone: iconeTypeMouvement(m.type),
      titre: l10n.stkMouvementTitre(type),
      description:
          '${formatDateHeure.format(m.date)} · ${produit?.designation ?? m.produitCode} · '
          '${magasins[m.magasinCode] ?? m.magasinCode}',
      badges: [DsBadge(libelle: type, ton: m.quantite >= 0 ? DsBadgeTon.succes : DsBadgeTon.danger)],
      stats: [
        DsStatItem(
          libelle: l10n.stockColQuantite,
          valeur: m.quantite > 0 ? isolerLtr('+${formaterNombre(m.quantite)}') : formaterNombre(m.quantite),
          icone: m.quantite >= 0 ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
          ton: m.quantite >= 0 ? DsBadgeTon.succes : DsBadgeTon.danger,
        ),
        if (m.nombre != 0)
          DsStatItem(
            libelle: l10n.stkNombre,
            valeur: m.nombre > 0 ? isolerLtr('+${formaterNombre(m.nombre)}') : formaterNombre(m.nombre),
            icone: LucideIcons.hash,
          ),
      ],
      piedSupplementaire: [
        if (piece)
          Builder(
            builder: (dialogue) => DsButton(
              key: const ValueKey('mouvement_voir_piece'),
              libelle: l10n.stkVoirPiece,
              icone: LucideIcons.fileText,
              variante: DsButtonVariante.secondaire,
              onPressed: () {
                Navigator.of(dialogue).pop();
                afficherPieceMouvement(context, ref, m);
              },
            ),
          ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.prdInformations,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.stockColType, type),
            DsKeyValue(l10n.communDate, formatDateHeure.format(m.date)),
            DsKeyValue(l10n.stkReference, m.referenceCode ?? '—', mono: true),
            DsKeyValue(l10n.dsPosProduit, produit?.designation ?? m.produitCode, fort: true),
            DsKeyValue(l10n.produitsColCode, m.produitCode, mono: true),
            DsKeyValue(l10n.stockColMagasin, magasins[m.magasinCode] ?? m.magasinCode),
            DsKeyValue(l10n.stockColUtilisateur, utilisateurs[m.utilisateurCode] ?? m.utilisateurCode),
            DsKeyValue(l10n.stockColMotif, m.motif == null ? '—' : libelleMotif(l10n, m.motif!)),
            DsKeyValue(l10n.retoursObservation, m.commentaire ?? '—'),
          ],
        ),
        sectionAudit(context, m.audit),
      ],
    ),
  );
}

/// Détail d'un inventaire (`EntityDetailDialog` 940 px) : écarts par produit (théorique, compté, écart), magasin,
/// période de comptage, observation, annulation éventuelle et traçabilité.
Future<void> afficherDetailInventaire(BuildContext context, WidgetRef ref, String code) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(stockRepositoryProvider);
  final inv = await repo.inventaire(code);
  if (inv == null) return;
  final lignes = await repo.lignesInventaire(code);
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final magasins = {for (final x in await ref.read(magasinsProvider.future)) x.code: x.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  DateTime? date(Object? v) => v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
  double n(Map<String, Object?> l, String c) => (l[c] as num?)?.toDouble() ?? 0;
  final le = date(inv['date']) ?? DateTime.now();
  final debut = date(inv['debut_comptage']);
  final annuleLe = date(inv['annule_le']);
  final annuleePar = inv['annule_par'] as String?;
  final magasin = inv['magasin_code']! as String;
  final auteur = inv['utilisateur_code']! as String;
  final avecNombre = lignes.any((l) => n(l, 'ecart_nombre') != 0);
  final plus = lignes.fold(0.0, (s, l) => s + (n(l, 'ecart') > 0 ? n(l, 'ecart') : 0));
  final moins = lignes.fold(0.0, (s, l) => s + (n(l, 'ecart') < 0 ? n(l, 'ecart') : 0));
  Widget ecart(double v) => QuantiteSignee(v);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.clipboardCheck,
      titre: l10n.stkInventaireTitre(code),
      description: '${formatDateHeure.format(le)} · ${magasins[magasin] ?? magasin}',
      badges: [BadgeStatut(annuleLe != null ? 'annule' : 'valide')],
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${lignes.length}', icone: LucideIcons.package),
        DsStatItem(
          libelle: l10n.situationEcarts,
          valeur: isolerLtr('+${formaterNombre(plus)}'),
          icone: LucideIcons.arrowDownLeft,
          ton: DsBadgeTon.succes,
        ),
        DsStatItem(
          libelle: l10n.situationEcarts,
          valeur: formaterNombre(moins),
          icone: LucideIcons.arrowUpRight,
          ton: DsBadgeTon.danger,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.prdInformations,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.stockColMagasin, magasins[magasin] ?? magasin),
            DsKeyValue(l10n.stkDebutComptage, debut == null ? '—' : formatDateHeure.format(debut)),
            DsKeyValue(l10n.stkValideLe, formatDateHeure.format(le)),
            DsKeyValue(l10n.retoursObservation, (inv['commentaire'] as String?) ?? '—', span: 3),
          ],
        ),
        DsSectionDetail(
          titre: l10n.situationEcarts,
          icone: LucideIcons.package,
          nbLignes: lignes.length,
          tableau: DsDataTable<Map<String, Object?>>(
            dense: true,
            encadre: false,
            pagine: false,
            reserveEcran: 360,
            cle: (l) => l['produit_code']! as String,
            lignes: lignes,
            messageVide: l10n.situationAucunEcart,
            colonnes: [
              DsColonne(
                id: 'code',
                libelle: l10n.produitsColCode,
                attenue: true,
                valeur: (l) => l['produit_code']! as String,
              ),
              DsColonne(
                id: 'nom',
                libelle: l10n.dsPosProduit,
                fort: true,
                flex: 3,
                valeur: (l) => produits[l['produit_code']]?.designation ?? l['produit_code']! as String,
              ),
              DsColonne(
                id: 'theo',
                libelle: l10n.situationTheorique,
                numerique: true,
                valeur: (l) => n(l, 'theorique'),
                cellule: (_, l) => Text(formaterNombre(n(l, 'theorique'))),
              ),
              DsColonne(
                id: 'compte',
                libelle: l10n.situationCompte,
                numerique: true,
                valeur: (l) => n(l, 'constate'),
                cellule: (_, l) => Text(formaterNombre(n(l, 'constate'))),
              ),
              DsColonne(
                id: 'ecart',
                libelle: l10n.situationEcart,
                numerique: true,
                valeur: (l) => n(l, 'ecart'),
                cellule: (_, l) => ecart(n(l, 'ecart')),
              ),
              if (avecNombre)
                DsColonne(
                  id: 'ecart_nombre',
                  libelle: l10n.stkNombre,
                  numerique: true,
                  valeur: (l) => n(l, 'ecart_nombre'),
                  cellule: (_, l) => ecart(n(l, 'ecart_nombre')),
                ),
            ],
          ),
        ),
        // L'inventaire n'a pas de colonnes d'audit : créé le / par = validation.
        sectionAudit(
          context,
          Audit(creeLe: le, creePar: auteur),
          complements: [
            if (annuleLe != null) ...[
              DsKeyValue(l10n.ventesAnnulePar, annuleePar == null ? '—' : (utilisateurs[annuleePar] ?? annuleePar)),
              DsKeyValue(l10n.ventesAnnuleLe, formatDateHeure.format(annuleLe)),
              DsKeyValue(l10n.ventesMotifAnnulation, inv['motif_annulation'] as String?, span: 2),
            ],
          ],
        ),
      ],
    ),
  );
}
