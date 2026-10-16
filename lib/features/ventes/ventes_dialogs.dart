import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../caisse/pos_controller.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';

/// Libellé des modes de paiement d'un panier (« Espèces + Carte CIB »).
String libelleModes(BuildContext context, List<String> modes) =>
    modes.isEmpty ? '—' : modes.map((m) => libelleRef(context, Referentiel.modesPaiement, m)).join(' + ');

/// Nom affiché du client d'un panier.
String nomClientPanier(AppLocalizations l10n, String code, Map<String, String> noms) =>
    code == 'CLN0000' ? l10n.posClientPassage : (noms[code] ?? code);

/// Tableau des lignes d'un panier (détail et modification).
Widget _tableauLignes(
  AppLocalizations l10n,
  String devise,
  List<VenteLigne> lignes, {
  required bool detail,
  double? reserveEcran,
}) {
  String da(double v) => formaterMontant(v, devise);
  String colis(VenteLigne l) => l.produitCode == PanierLigne.codeMontant
      ? l10n.posMontantColis
      : l.packCode != null
      ? l10n.posPack
      : l.colisCode ?? (l.uniteVente == 'Nombre' ? l10n.posVendreNombre : l10n.posSelUnite);
  return DsDataTable<VenteLigne>(
    dense: true,
    encadre: false,
    pagine: false,
    reserveEcran: reserveEcran,
    hauteurFixe: reserveEcran != null,
    afficherTotaux: detail,
    cle: (l) => l.ordre,
    lignes: lignes,
    messageVide: l10n.dsAucunElement,
    colonnes: [
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
      DsColonne(id: 'nom', libelle: l10n.ventesProduit, valeur: (l) => l.designation, fort: true, flex: 3),
      DsColonne(id: 'colis', libelle: l10n.ventesColis, valeur: colis, attenue: true),
      DsColonne(
        id: 'qte',
        libelle: l10n.ventesQte,
        valeur: (l) => l.quantite,
        numerique: true,
        cellule: (_, l) => Text(formaterNombre(l.quantite)),
        total: (ls) => formaterNombre(ls.fold(0.0, (s, l) => s + l.quantite)),
      ),
      if (detail) DsColonne(id: 'serie', libelle: l10n.ventesNumSerie, valeur: (_) => '—', attenue: true),
      DsColonne(
        id: 'prix',
        libelle: l10n.ventesPrix,
        valeur: (l) => l.prixUnitaire,
        numerique: true,
        cellule: (_, l) => Text(da(l.prixUnitaire)),
      ),
      if (detail) ...[
        DsColonne(
          id: 'taux_tva',
          libelle: l10n.tvaTaux,
          valeur: (l) => l.tauxTva,
          numerique: true,
          cellule: (_, l) => Text('${formaterNombre(l.tauxTva)} %'),
        ),
        DsColonne(
          id: 'ht',
          libelle: l10n.tvaHt,
          valeur: (l) => l.montantHt,
          numerique: true,
          cellule: (_, l) => Text(da(l.montantHt)),
          total: (ls) => da(ls.fold(0.0, (s, l) => s + l.montantHt)),
        ),
        DsColonne(
          id: 'tva',
          libelle: l10n.tvaMontant,
          valeur: (l) => l.montantTva,
          numerique: true,
          cellule: (_, l) => Text(da(l.montantTva)),
          total: (ls) => da(ls.fold(0.0, (s, l) => s + l.montantTva)),
        ),
      ],
      DsColonne(
        id: 'total',
        libelle: detail ? l10n.tvaTtc : l10n.ventesTotal,
        valeur: (l) => l.total,
        numerique: true,
        cellule: (_, l) => Text(da(l.total)),
        total: (ls) => da(ls.fold(0.0, (s, l) => s + l.total)),
      ),
    ],
  );
}

/// Liste des produits d'un panier (action « Liste des produits » du module Ventes).
Future<void> afficherProduitsPanier(
  BuildContext context,
  WidgetRef ref,
  PanierResume p, {
  required Map<String, String> nomsClients,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final vente = await ref.read(venteRepositoryProvider).vente(p.code);
  if (vente == null || !context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (dialogue) => DsDialog(
      key: const ValueKey('ventes_liste_produits'),
      titre: l10n.ventesListeProduitsTitre(p.code),
      iconeData: LucideIcons.listOrdered,
      description:
          '${formatDateHeure.format(vente.date)} · ${nomClientPanier(l10n, vente.clientCode, nomsClients)} · '
          '${l10n.ventesArticles} : ${vente.lignes.length}',
      largeur: 900,
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(dialogue).pop(),
        ),
      ],
      contenu: _tableauLignes(l10n, devise, vente.lignes, detail: true, reserveEcran: 290),
    ),
  );
}

/// Détail d'un panier (`PanierDetailDialog` du DS, 1100 px).
Future<void> afficherDetailPanier(
  BuildContext context,
  WidgetRef ref,
  PanierResume p, {
  required Map<String, String> nomsClients,
  VoidCallback? onModifier,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final voirAchat = ref.read(permissionProvider(Permission.voirPrixAchat));
  final voirMarge = ref.read(permissionProvider(Permission.voirMarge));
  String da(double v) => formaterMontant(v, devise);
  final vente = await ref.read(venteRepositoryProvider).vente(p.code);
  if (vente == null || !context.mounted) return;
  final client = nomClientPanier(l10n, vente.clientCode, nomsClients);
  final date = formatDateHeure.format(vente.date);
  final empreinte = vente.hash.length > 8
      ? '${vente.hash.substring(0, 4)}…${vente.hash.substring(vente.hash.length - 4)}'
      : vente.hash;
  await afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      titre: l10n.ventesPanierTitre(p.code),
      icone: LucideIcons.receiptText,
      description: '$date · $client · ${p.caissier}',
      onModifier: onModifier,
      modifierDesactive: p.annule,
      badges: [BadgeStatut(p.statut)],
      piedSupplementaire: [
        Builder(
          builder: (dialogue) => DsButton(
            key: const ValueKey('panier_reimprimer'),
            libelle: l10n.ventesReimprimer,
            icone: LucideIcons.printer,
            variante: DsButtonVariante.secondaire,
            onPressed: () => afficherResultatVente(dialogue, ref, vente),
          ),
        ),
      ],
      stats: [
        DsStatItem(libelle: l10n.ventesArticles, valeur: '${p.nbArticles}', icone: LucideIcons.list),
        DsStatItem(libelle: l10n.ventesQuantite, valeur: formaterNombre(p.quantite), icone: LucideIcons.boxes),
        DsStatItem(
          libelle: l10n.ventesMontantTotal,
          valeur: f2(vente.totalNet),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
        DsStatItem(libelle: l10n.ventesPaye, valeur: f2(p.paye), suffixe: devise, icone: LucideIcons.wallet),
        DsStatItem(libelle: l10n.ventesVersements, valeur: '${p.nbVersements}', icone: LucideIcons.handCoins),
        DsStatItem(
          libelle: l10n.ventesReste,
          valeur: f2(p.resteActuel),
          suffixe: devise,
          icone: LucideIcons.clockAlert,
          ton: DsBadgeTon.danger,
          tonValeur: p.resteActuel > 0 ? DsBadgeTon.danger : null,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.ventesInfosGenerales,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.produitsColCode, p.code, mono: true),
            DsKeyValue(l10n.communDate, date),
            DsKeyValue(l10n.ventesClient, client),
            DsKeyValue(l10n.ventesCaissier, p.caissier),
            DsKeyValue(l10n.ventesModePaiement, libelleModes(context, p.modes)),
            DsKeyValue(l10n.ventesCaisse, vente.caisseCode, mono: true),
            DsKeyValue(l10n.ventesSession, vente.sessionCode, mono: true),
            DsKeyValue(l10n.tiersObservation, vente.commentaire),
          ],
        ),
        DsSectionDetail(
          titre: l10n.ventesPaiementMarge,
          icone: LucideIcons.banknote,
          items: [
            DsKeyValue(l10n.ventesMontantTotal, da(vente.totalNet), fort: true),
            DsKeyValue('${l10n.ventesTotal} ${l10n.tvaHt}', da(vente.totalHt)),
            DsKeyValue(l10n.tvaMontant, da(vente.totalTva)),
            if (voirAchat) DsKeyValue(l10n.ventesTotalAchat, da(p.totalAchat)),
            if (voirMarge)
              DsKeyValue(
                l10n.ventesKpiMarge,
                da(p.marge),
                widget: Builder(
                  builder: (context) => Text(
                    da(p.marge),
                    style: TextStyle(color: p.marge >= 0 ? context.ds.colors.successFg : context.ds.colors.dangerFg),
                  ),
                ),
              ),
            DsKeyValue(l10n.ventesMontantPaye, da(p.paye)),
            DsKeyValue(l10n.ventesReste, da(p.resteActuel)),
            DsKeyValue(l10n.ventesNombreVersements, '${p.nbVersements}'),
          ],
        ),
        DsSectionDetail(
          titre: l10n.ventesProduitsPanier,
          icone: LucideIcons.package,
          nbLignes: vente.lignes.length,
          tableau: _tableauLignes(l10n, devise, vente.lignes, detail: true, reserveEcran: 360),
        ),
        DsSectionDetail(
          titre: l10n.ventesAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.ventesCreePar, p.caissier),
            DsKeyValue(l10n.ventesCreeLe, date),
            DsKeyValue(l10n.communModifiePar, p.modifiePar),
            DsKeyValue(l10n.communModifieLe, p.modifieLe == null ? null : formatDateHeure.format(p.modifieLe!)),
            DsKeyValue(l10n.ventesAnnulePar, p.annuleePar),
            DsKeyValue(l10n.ventesAnnuleLe, p.annuleeLe == null ? null : formatDateHeure.format(p.annuleeLe!)),
            DsKeyValue(l10n.ventesMotifAnnulation, p.motifAnnulation),
            DsKeyValue(l10n.ventesEmpreinte, empreinte, mono: true),
          ],
        ),
      ],
    ),
  );
}

/// Modification d'un panier (`PanierModifDialog` du DS, 980 px) : montant payé (complément en versement
/// imputé), mode de paiement et observation. Les lignes et le client du ticket scellé ne changent pas.
Future<void> afficherModifPanier(
  BuildContext context,
  WidgetRef ref,
  PanierResume p, {
  required Map<String, String> nomsClients,
}) async {
  final vente = await ref.read(venteRepositoryProvider).vente(p.code);
  if (vente == null || !context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (_) => _ModifPanier(panier: p, vente: vente, nomsClients: nomsClients),
  );
}

class _ModifPanier extends ConsumerStatefulWidget {
  const _ModifPanier({required this.panier, required this.vente, required this.nomsClients});
  final PanierResume panier;
  final Vente vente;
  final Map<String, String> nomsClients;

  @override
  ConsumerState<_ModifPanier> createState() => _ModifPanierState();
}

class _ModifPanierState extends ConsumerState<_ModifPanier> {
  late final _paye = TextEditingController(text: formaterNombre(widget.panier.paye, decimales: 2, grouper: false));
  late final _obs = TextEditingController(text: widget.vente.commentaire);
  late String _mode = widget.panier.modes.where((m) => m != 'Points').firstOrNull ?? 'Espèces';
  String? _erreur;

  @override
  void dispose() {
    _paye.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final montant = lireNombre(_paye.text);
    if (montant == null) {
      setState(() => _erreur = l10n.posErreurMontantPaye(formaterMontant(widget.panier.paye, devise)));
      return;
    }
    try {
      await ref
          .read(venteServiceProvider)
          .modifier(
            widget.vente.code,
            montantPaye: montant,
            mode: _mode,
            caisseCode: widget.vente.caisseCode,
            commentaire: _obs.text,
          );
      rafraichirCommerce(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(context, titre: l10n.ventesModifie, description: widget.vente.code);
    } on VenteException catch (e) {
      setState(() => _erreur = messageErreurVente(l10n, e, devise));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final v = widget.vente;
    final paye = lireNombre(_paye.text) ?? 0;
    final reste = (v.totalNet - paye) > 0 ? v.totalNet - paye : 0.0;
    const lw = 124.0;
    return DsDialog(
      titre: l10n.ventesModifierTitre,
      iconeData: LucideIcons.pencil,
      description: l10n.ventesModifierDescription(v.code),
      largeur: 980,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('panier_modifier_enregistrer'),
          libelle: l10n.communModifier,
          icone: LucideIcons.check,
          onPressed: _enregistrer,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          DsGrilleFormulaire(
            children: [
              DsFormRow(
                libelle: l10n.produitsColCode,
                largeurLibelle: lw,
                child: DsTextField(valeurInitiale: v.code, actif: false),
              ),
              DsFormRow(
                libelle: l10n.ventesMontantPaye,
                obligatoire: true,
                largeurLibelle: lw,
                erreur: _erreur,
                aide: l10n.ventesComplementIndice,
                child: DsTextField(
                  key: const ValueKey('panier_montant_paye'),
                  controller: _paye,
                  numerique: true,
                  suffixeTexte: devise,
                  autofocus: true,
                  onChanged: (_) => setState(() => _erreur = null),
                ),
              ),
              DsFormRow(
                libelle: l10n.communDate,
                largeurLibelle: lw,
                child: DsTextField(valeurInitiale: formatDateHeure.format(v.date), actif: false),
              ),
              DsFormRow(
                libelle: l10n.ventesReste,
                largeurLibelle: lw,
                child: DsTextField(
                  key: ValueKey('panier_reste_$reste'),
                  valeurInitiale: f2(reste),
                  suffixeTexte: devise,
                  actif: false,
                ),
              ),
              DsFormRow(
                libelle: l10n.ventesArticles,
                largeurLibelle: lw,
                child: DsTextField(valeurInitiale: '${v.lignes.length}', actif: false),
              ),
              DsFormRow(
                libelle: l10n.ventesModePaiement,
                obligatoire: true,
                largeurLibelle: lw,
                child: DsSelectReferentiel(
                  liste: Referentiel.modesPaiement,
                  valeur: _mode,
                  valeurs: const ['Espèces', 'Carte', 'Chèque', 'Virement'],
                  onChanged: (m) => setState(() => _mode = m ?? _mode),
                ),
              ),
              DsFormRow(
                libelle: l10n.ventesMontantTotal,
                largeurLibelle: lw,
                child: DsTextField(valeurInitiale: f2(v.totalNet), suffixeTexte: devise, actif: false),
              ),
              DsFormRow(
                libelle: l10n.ventesClient,
                largeurLibelle: lw,
                aide: l10n.ventesClientScelle,
                child: DsTextField(
                  valeurInitiale: nomClientPanier(l10n, v.clientCode, widget.nomsClients),
                  actif: false,
                ),
              ),
              DsSpan(
                child: DsFormRow(
                  libelle: l10n.tiersObservation,
                  largeurLibelle: lw,
                  alignerDebut: true,
                  child: DsTextField(
                    key: const ValueKey('panier_observation'),
                    controller: _obs,
                    multiligne: true,
                    lignes: 2,
                    indice: l10n.ventesNoteInterne,
                  ),
                ),
              ),
            ],
          ),
          DsDetailSection(
            titre: l10n.ventesProduits,
            icone: LucideIcons.package,
            compte: v.lignes.length,
            padding: EdgeInsets.zero,
            child: _tableauLignes(l10n, devise, v.lignes, detail: false),
          ),
        ],
      ),
    );
  }
}

/// Annulation de paniers (`BulkActionDialog` cancel, motif obligatoire). Les paniers déjà annulés
/// ou liés à un retour sont bloqués.
Future<void> annulerPaniers(
  BuildContext context,
  WidgetRef ref,
  List<PanierResume> choix,
  VoidCallback effacer, {
  required Map<String, String> nomsClients,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  String? blocage(PanierResume p) =>
      p.annule ? l10n.ventesBloqueDejaAnnule : (p.nbRetours > 0 ? l10n.ventesBloqueRetour : null);
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.ventesEntite,
    entitePluriel: l10n.ventesEntitePluriel,
    motifRequis: true,
    elements: [
      for (final p in choix)
        DsElementLot(
          id: p.code,
          titre: '${p.code} · ${nomClientPanier(l10n, p.vente.clientCode, nomsClients)}',
          sousTitre: '${formatDateHeure.format(p.vente.date)} · ${libelleModes(context, p.modes)}',
          meta: formaterMontant(p.vente.totalNet, devise),
          motifBlocage: blocage(p),
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final service = ref.read(venteServiceProvider);
  var ok = 0;
  final echecs = <String>[];
  for (final p in choix.where((p) => blocage(p) == null)) {
    try {
      await service.annuler(p.code, motif: motif);
      ok++;
    } on VenteException catch (e) {
      echecs.add('${p.code} : ${messageErreurVente(l10n, e, devise)}');
    }
  }
  effacer();
  rafraichirCommerce(ref);
  if (!context.mounted) return;
  unawaited(
    afficherResultat(
      context,
      type: echecs.isEmpty ? DsResultatType.succes : DsResultatType.erreur,
      titre: l10n.ventesAnnulesTitre,
      message: echecs.isEmpty ? l10n.ventesAnnulesMessage : l10n.ventesAnnulesPartiel(echecs.join('\n'), ok),
    ),
  );
}
