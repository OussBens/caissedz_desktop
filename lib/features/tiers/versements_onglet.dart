import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/versement_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/retour.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/export_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import 'tiers_dialogs.dart';
import 'tiers_providers.dart';

/// Onglet « Versements » des écrans Clients et Fournisseurs (`ModuleTable` versements).
class VersementsOnglet extends ConsumerStatefulWidget {
  const VersementsOnglet({super.key, required this.tiersType, required this.tiers});
  final String tiersType;

  /// Tiers du type (bénéficiaires possibles, noms affichés).
  final List<LigneTiers> tiers;

  @override
  ConsumerState<VersementsOnglet> createState() => _VersementsOngletState();
}

class _VersementsOngletState extends ConsumerState<VersementsOnglet> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _mode;
  String? _caisse;

  bool get _client => widget.tiersType == TypesTiers.client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final caisses = ref.watch(caissesListeProvider).value ?? const <Caisse>[];
    String nomCaisse(String? c) => caisses.where((x) => x.code == c).firstOrNull?.nom ?? (c ?? '—');
    final noms = {for (final t in widget.tiers) t.code: t.nom};
    final tous = (ref.watch(versementsProvider).value ?? const <Versement>[])
        .where((v) => v.tiersType == widget.tiersType && v.mode != 'Avoir')
        .toList();
    final lignes = tous
        .where(
          (v) =>
              dansPeriode(v.date, _periode) &&
              (_mode == null || v.mode == _mode) &&
              (_caisse == null || v.caisseCode == _caisse),
        )
        .toList();
    final actifs = lignes.where((v) => v.actif);
    final colonnes = <DsColonne<Versement>>[
      DsColonne(id: 'code', libelle: l10n.versementNumero, valeur: (v) => v.code, attenue: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        valeur: (v) => v.date,
        attenue: true,
        cellule: (_, v) => Text(formatDate.format(v.date)),
      ),
      DsColonne(
        id: 'nom',
        libelle: _client ? l10n.tiersEntiteClientMaj : l10n.tiersEntiteFournisseurMaj,
        valeur: (v) => noms[v.tiersCode] ?? v.tiersCode,
        fort: true,
      ),
      DsColonne(
        id: 'sens',
        libelle: l10n.versementSens,
        valeur: (v) => v.estRetour ? 1 : 0,
        cellule: (_, v) => DsBadge(
          libelle: v.estRetour ? l10n.versementSensRetour : (_client ? l10n.versementSensRecu : l10n.versementSensPaye),
          ton: v.estRetour ? DsBadgeTon.avertissement : DsBadgeTon.succes,
          icone: v.estRetour ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
        ),
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.versementMontant,
        numerique: true,
        valeur: (v) => v.montant,
        cellule: (_, v) => Text(da(v.montant)),
        total: (ls) => da(ls.where((v) => v.actif).fold(0.0, (s, v) => s + (v.estRetour ? -v.montant : v.montant))),
      ),
      DsColonne(
        id: 'mode',
        libelle: l10n.versementMode,
        valeur: (v) => libelleRef(context, Referentiel.modesPaiement, v.mode),
      ),
      DsColonne(id: 'caisse', libelle: l10n.versementCaisse, valeur: (v) => nomCaisse(v.caisseCode)),
      DsColonne(
        id: 'etat',
        libelle: l10n.tiersEtat,
        valeur: (v) => v.actif ? 1 : 0,
        cellule: (_, v) => BadgeStatut(v.actif ? 'actif' : 'annule'),
      ),
      DsColonne(
        id: 'type',
        libelle: l10n.versementType,
        visibleParDefaut: false,
        valeur: (v) => libelleRef(context, Referentiel.typesVersement, v.type),
      ),
      DsColonne(id: 'obs', libelle: l10n.tiersObservation, visibleParDefaut: false, valeur: (v) => v.commentaire),
      DsColonne(id: 'creePar', libelle: l10n.auditCreePar, visibleParDefaut: false, valeur: (v) => v.utilisateurCode),
      DsColonne(
        id: 'annuleLe',
        libelle: l10n.auditAnnuleLe,
        visibleParDefaut: false,
        valeur: (v) => v.annuleLe == null ? null : formatDate.format(v.annuleLe!),
      ),
      DsColonne(id: 'annulePar', libelle: l10n.auditAnnulePar, visibleParDefaut: false, valeur: (v) => v.annulePar),
      DsColonne(id: 'motif', libelle: l10n.auditMotif, visibleParDefaut: false, valeur: (v) => v.motifAnnulation),
    ];
    return DsModuleTable<Versement>(
      entite: l10n.versementEntites,
      lignes: lignes,
      colonnes: colonnes,
      cle: (v) => v.code,
      afficherTotaux: true,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      nbFiltresActifs: (_mode != null ? 1 : 0) + (_caisse != null ? 1 : 0),
      onReinitialiser: () => setState(() {
        _mode = null;
        _caisse = null;
        _periode = DsPeriode.calculer('month');
      }),
      kpis: [
        DsStatCard(libelle: l10n.versementKpiNombre, valeur: '${actifs.length}', icone: LucideIcons.handCoins),
        DsStatCard(
          libelle: _client ? l10n.versementKpiEncaisse : l10n.versementKpiPaye,
          valeur: f2(actifs.where((v) => !v.estRetour).fold(0.0, (s, v) => s + v.montant)),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
        DsStatCard(
          libelle: l10n.versementKpiRetour,
          valeur: f2(actifs.where((v) => v.estRetour).fold(0.0, (s, v) => s + v.montant)),
          suffixe: devise,
          icone: LucideIcons.undo2,
        ),
      ],
      filtres: [
        DsFormRow(
          libelle: l10n.versementMode,
          largeurLibelle: 60,
          child: DsSelect<String?>(
            valeur: _mode,
            options: [null, ...Referentiel.modesPaiement.valeurs.map((v) => v.stocke)],
            libelle: (m) => m == null ? l10n.tiersTous : libelleRef(context, Referentiel.modesPaiement, m),
            onChanged: (m) => setState(() => _mode = m),
          ),
        ),
        DsFormRow(
          libelle: l10n.versementCaisse,
          largeurLibelle: 60,
          child: DsSelect<String?>(
            valeur: _caisse,
            options: [null, ...caisses.map((c) => c.code)],
            libelle: (c) => c == null ? l10n.tiersToutes : nomCaisse(c),
            onChanged: (c) => setState(() => _caisse = c),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: 'versements',
              titre: l10n.moduleVersements,
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) =>
              afficherDetailVersement(context, ref, choix.first, nomTiers: noms[choix.first.tiersCode]),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && (!choix.first.actif || choix.first.verrouille),
          onPressed: (choix, _) => afficherVersementTiers(
            context,
            ref,
            tiersType: widget.tiersType,
            tiers: widget.tiers,
            versement: choix.first,
          ),
        ),
        DsActionModule(
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.ban,
          danger: true,
          onPressed: (choix, effacer) => _annuler(choix, effacer, noms),
        ),
      ],
      secondaire: DsButton(
        libelle: l10n.versementRetourNouveau,
        icone: LucideIcons.undo2,
        variante: DsButtonVariante.secondaire,
        onPressed: () =>
            afficherVersementTiers(context, ref, tiersType: widget.tiersType, tiers: widget.tiers, retour: true),
      ),
      primaire: DsButton(
        key: const ValueKey('versement_nouveau'),
        libelle: l10n.versementNouveau,
        icone: LucideIcons.plus,
        onPressed: () => afficherVersementTiers(context, ref, tiersType: widget.tiersType, tiers: widget.tiers),
      ),
    );
  }

  Future<void> _annuler(List<Versement> choix, VoidCallback effacer, Map<String, String> noms) async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final motif = await afficherActionLot(
      context,
      action: DsActionLot.annuler,
      entite: l10n.versementEntite,
      entitePluriel: l10n.versementEntites,
      motifRequis: true,
      elements: [
        for (final v in choix)
          DsElementLot(
            id: v.code,
            titre: '${v.code} · ${noms[v.tiersCode] ?? v.tiersCode}',
            sousTitre: libelleRef(context, Referentiel.modesPaiement, v.mode),
            meta: formaterMontant(v.montant, devise),
            motifBlocage: !v.actif
                ? l10n.tiersBloqueDejaAnnule
                : (v.verrouille ? l10n.versementErreurVerrouille : null),
          ),
      ],
    );
    if (motif == null || !mounted) return;
    final s = ref.read(versementServiceProvider);
    for (final v in choix.where((v) => v.actif && !v.verrouille)) {
      await s.annuler(v.code, motif: motif);
    }
    effacer();
    rafraichirCommerce(ref);
    rafraichirCaisse(ref);
  }
}

/// Détail d'un versement (`versementDetail`).
Future<void> afficherDetailVersement(BuildContext context, WidgetRef ref, Versement v, {String? nomTiers}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final caisses = await ref.read(caissesListeProvider.future);
  if (!context.mounted) return;
  final client = v.tiersType == TypesTiers.client;
  await afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 860,
      icone: v.estRetour ? LucideIcons.undo2 : LucideIcons.handCoins,
      titre: '${v.estRetour ? l10n.versementRetourTitre : l10n.versementTitre} ${v.code}',
      description: '${formatDate.format(v.date)} · ${nomTiers ?? v.tiersCode}',
      badges: [
        BadgeStatut(client ? 'client' : 'fournisseur'),
        BadgeStatut(v.actif ? 'actif' : 'annule'),
        if (v.verrouille) DsBadge(libelle: l10n.versementVerrouille(v.retourCode ?? ''), icone: LucideIcons.lock),
      ],
      stats: [
        DsStatItem(libelle: l10n.versementMontant, valeur: f2(v.montant), suffixe: devise, icone: LucideIcons.banknote),
        DsStatItem(
          libelle: l10n.tiersType,
          valeur: client ? l10n.tiersEntiteClientMaj : l10n.tiersEntiteFournisseurMaj,
          icone: client ? LucideIcons.user : LucideIcons.truck,
        ),
        DsStatItem(libelle: l10n.versementBeneficiaire, valeur: nomTiers ?? v.tiersCode, icone: LucideIcons.idCard),
        DsStatItem(
          libelle: l10n.versementMode,
          valeur: libelleRef(context, Referentiel.modesPaiement, v.mode),
          icone: LucideIcons.wallet,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.tiersInfosGenerales,
          icone: LucideIcons.info,
          colonnesGrille: 4,
          items: [
            DsKeyValue(l10n.versementNumero, v.code, mono: true),
            DsKeyValue(l10n.communDate, formatDateHeure.format(v.date)),
            DsKeyValue(
              l10n.versementCaisse,
              caisses.where((c) => c.code == v.caisseCode).firstOrNull?.nom ?? v.caisseCode,
            ),
            DsKeyValue(l10n.versementType, libelleRef(context, Referentiel.typesVersement, v.type)),
            DsKeyValue(l10n.tiersObservation, v.commentaire ?? v.reference, span: 4),
          ],
        ),
        if (v.imputations.isNotEmpty)
          DsSectionDetail(
            titre: l10n.versementImputations,
            icone: LucideIcons.listChecks,
            nbLignes: v.imputations.length,
            tableau: DsDataTable<Imputation>(
              dense: true,
              encadre: false,
              pagine: false,
              lignes: v.imputations,
              cle: (i) => i.documentCode,
              colonnes: [
                DsColonne(id: 'doc', libelle: l10n.tiersReference, valeur: (i) => i.documentCode),
                DsColonne(
                  id: 'm',
                  libelle: l10n.versementMontant,
                  numerique: true,
                  valeur: (i) => i.montant,
                  cellule: (_, i) => Text(formaterMontant(i.montant, devise)),
                ),
              ],
            ),
          ),
        DsSectionDetail(
          titre: l10n.auditTitre,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.auditCreePar, v.utilisateurCode),
            DsKeyValue(l10n.auditAnnulePar, v.annulePar),
            DsKeyValue(l10n.auditAnnuleLe, v.annuleLe == null ? null : formatDate.format(v.annuleLe!)),
            DsKeyValue(l10n.auditMotif, v.motifAnnulation, span: 3),
          ],
        ),
      ],
    ),
  );
}

/// Nouveau versement, versement retour ou modification (`VersementTiersDialog`).
Future<void> afficherVersementTiers(
  BuildContext context,
  WidgetRef ref, {
  required String tiersType,
  required List<LigneTiers> tiers,
  LigneTiers? beneficiaire,
  Versement? versement,
  bool retour = false,
}) => afficherDialog<void>(
  context,
  builder: (_) => _VersementTiers(
    tiersType: tiersType,
    tiers: tiers,
    beneficiaire: beneficiaire ?? tiers.where((t) => t.code == versement?.tiersCode).firstOrNull,
    versement: versement,
    retour: versement?.estRetour ?? retour,
  ),
);

class _VersementTiers extends ConsumerStatefulWidget {
  const _VersementTiers({
    required this.tiersType,
    required this.tiers,
    this.beneficiaire,
    this.versement,
    this.retour = false,
  });
  final String tiersType;
  final List<LigneTiers> tiers;
  final LigneTiers? beneficiaire;
  final Versement? versement;
  final bool retour;

  @override
  ConsumerState<_VersementTiers> createState() => _VersementTiersState();
}

class _VersementTiersState extends ConsumerState<_VersementTiers> {
  late LigneTiers? _b = widget.beneficiaire;
  late final _montant = TextEditingController(
    text: widget.versement == null ? '' : formaterNombre(widget.versement!.montant, decimales: 2, grouper: false),
  );
  late final _obs = TextEditingController(text: widget.versement?.commentaire ?? widget.versement?.reference);
  late DateTime _date = widget.versement?.date ?? DateTime.now();
  late String _mode = widget.versement?.mode ?? 'Espèces';
  late String _type =
      widget.versement?.type ??
      (widget.retour
          ? TypesVersement.remboursement
          : ((widget.beneficiaire?.stats.credit ?? 0) > 0 ? TypesVersement.paiement : TypesVersement.avancement));
  String? _caisse;
  String? _erreur;

  bool get _client => widget.tiersType == TypesTiers.client;
  bool get _edition => widget.versement != null;

  @override
  void initState() {
    super.initState();
    _caisse = widget.versement?.caisseCode;
  }

  @override
  void dispose() {
    _montant.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _choisir() async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final choix = await afficherSelecteur<LigneTiers>(
      context,
      titre: _client ? l10n.tiersChoisirClient : l10n.tiersChoisirFournisseur,
      icone: _client ? LucideIcons.users : LucideIcons.truck,
      elements: widget.tiers.where((t) => !t.systeme && t.actif).toList(),
      libelle: (t) => t.nom,
      colonnes: [
        DsColonnePicker(libelle: l10n.produitsColCode, valeur: (t) => t.code, attenue: true),
        DsColonnePicker(libelle: l10n.clientNom, valeur: (t) => t.nom, fort: true),
        DsColonnePicker(
          libelle: l10n.tiersCredit,
          valeur: (t) => t.stats.credit > 0 ? formaterMontant(t.stats.credit, devise) : '—',
        ),
      ],
    );
    if (choix != null) setState(() => _b = choix);
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final montant = lireNombre(_montant.text) ?? 0;
    final s = ref.read(versementServiceProvider);
    try {
      if (_edition) {
        await s.modifier(
          widget.versement!.code,
          montant: montant,
          mode: _mode,
          date: _date,
          caisseCode: _caisse,
          type: _type,
          commentaire: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
        );
      } else {
        final sensPaiement = _client ? SensVersement.encaissement : SensVersement.decaissement;
        final sensRetour = _client ? SensVersement.decaissement : SensVersement.encaissement;
        await s.imputer(
          tiersType: widget.tiersType,
          tiersCode: _b!.code,
          montant: montant,
          mode: _mode,
          date: _date,
          caisseCode: _caisse,
          type: _type,
          sens: widget.retour ? sensRetour : sensPaiement,
          commentaire: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
        );
      }
      rafraichirCommerce(ref);
      rafraichirCaisse(ref);
      if (mounted) Navigator.of(context).pop();
    } on VersementException catch (e) {
      setState(() => _erreur = messageErreurVersement(l10n, e.erreur));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final caisses = (ref.watch(caissesListeProvider).value ?? const <Caisse>[]).where((c) => c.actif).toList();
    _caisse ??= caisses.firstOrNull?.code;
    final credit = _b?.stats.solde ?? 0;
    final montant = lireNombre(_montant.text) ?? 0;
    // En modification, l'ancien montant est déjà compté dans le solde.
    final ancien = widget.versement?.montant ?? 0;
    final base = widget.retour ? credit - ancien : credit + ancien;
    final apres = widget.retour ? base + montant : base - montant;
    const lw = 128.0;
    final titre = _edition
        ? (widget.retour ? l10n.versementRetourModifier : l10n.versementModifier)
        : (widget.retour ? l10n.versementRetourNouveau : l10n.versementNouveau);
    final description = widget.retour
        ? (_client ? l10n.versementAideRetourClient : l10n.versementAideRetourFournisseur)
        : (_client ? l10n.versementAideClient : l10n.versementAideFournisseur);
    return DsDialog(
      titre: titre,
      iconeData: widget.retour ? LucideIcons.undo2 : LucideIcons.handCoins,
      description: description,
      largeur: 680,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('versement_enregistrer'),
          libelle: _edition ? l10n.communModifier : l10n.communEnregistrer,
          icone: LucideIcons.check,
          onPressed: _b == null || montant <= 0 ? null : _enregistrer,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          DsFormRow(
            libelle: l10n.versementNumero,
            largeurLibelle: lw,
            child: DsTextField(valeurInitiale: widget.versement?.code ?? l10n.tiersCodeAuto, actif: false),
          ),
          DsFormRow(
            libelle: l10n.communDate,
            obligatoire: true,
            largeurLibelle: lw,
            child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d ?? _date)),
          ),
          DsFormRow(
            libelle: _client ? l10n.tiersEntiteClientMaj : l10n.tiersEntiteFournisseurMaj,
            obligatoire: true,
            largeurLibelle: lw,
            onLookup: _edition ? null : _choisir,
            aide: _b != null
                ? l10n.versementCreditActuel(formaterMontant(credit, devise))
                : l10n.versementCliquezChoisir,
            child: DsTextField(
              key: ValueKey('versement_beneficiaire_${_b?.code}'),
              valeurInitiale: _b?.nom ?? '',
              indice: l10n.versementAucunBeneficiaire,
              actif: false,
            ),
          ),
          DsFormRow(
            libelle: l10n.versementMode,
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
            libelle: l10n.versementMontant,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _erreur,
            child: DsTextField(
              key: const ValueKey('versement_montant'),
              controller: _montant,
              numerique: true,
              suffixeTexte: devise,
              indice: '0,00',
              autofocus: true,
              onChanged: (_) => setState(() => _erreur = null),
            ),
          ),
          DsFormRow(
            libelle: l10n.versementType,
            largeurLibelle: lw,
            child: DsSelectReferentiel(
              liste: Referentiel.typesVersement,
              valeur: _type,
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
          ),
          DsFormRow(
            libelle: l10n.versementCaisse,
            obligatoire: true,
            largeurLibelle: lw,
            child: DsSelect<String>(
              valeur: _caisse,
              options: caisses.map((c) => c.code).toList(),
              libelle: (code) => caisses.where((c) => c.code == code).firstOrNull?.nom ?? code,
              onChanged: (v) => setState(() => _caisse = v),
            ),
          ),
          DsFormRow(
            libelle: l10n.tiersObservation,
            largeurLibelle: lw,
            alignerDebut: true,
            child: DsTextField(controller: _obs, multiligne: true, lignes: 2, indice: l10n.versementObsIndice),
          ),
          if (_b != null && montant > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: apres > 0.004 ? c.warningTint : c.successTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                spacing: 10,
                children: [
                  Icon(LucideIcons.scale, size: 18, color: apres > 0.004 ? c.warningFg : c.successFg),
                  Expanded(
                    child: Text(
                      apres > 0.004
                          ? l10n.versementCreditRestant
                          : (apres < -0.004 ? l10n.versementAvanceTropPercu : l10n.versementCompteSolde),
                      style: t.bodyStrong.copyWith(fontSize: 13.5, color: apres > 0.004 ? c.warningFg : c.successFg),
                    ),
                  ),
                  Text(
                    formaterMontant(apres.abs(), devise),
                    style: t.bodyStrong.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: apres > 0.004 ? c.warningFg : c.successFg,
                      fontFeatures: DsTypography.tabular,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
