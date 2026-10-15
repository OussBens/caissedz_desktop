import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/tiers_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/referentiel/referentiel.dart';
import '../../domain/referentiel/wilayas.dart';
import '../achats/achats_page.dart';
import '../commun/export_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import 'tiers_providers.dart';

/// Vue commune d'un client ou d'un fournisseur (écrans Clients / Fournisseurs du DS).
@immutable
class LigneTiers {
  const LigneTiers({
    required this.type,
    required this.code,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.email,
    required this.actif,
    required this.systeme,
    required this.fiche,
    required this.stats,
    this.points = 0,
  });

  factory LigneTiers.client(Client c, StatsTiers s) => LigneTiers(
    type: TypesTiers.client,
    code: c.code,
    nom: c.nom,
    telephone: c.telephone,
    adresse: c.adresse,
    email: c.email,
    actif: c.actif,
    systeme: c.systeme,
    fiche: c.fiche,
    stats: s,
    points: c.points,
  );

  factory LigneTiers.fournisseur(Fournisseur f, StatsTiers s) => LigneTiers(
    type: TypesTiers.fournisseur,
    code: f.code,
    nom: f.nom,
    telephone: f.telephone,
    adresse: f.adresse,
    email: f.email,
    actif: f.actif,
    systeme: f.systeme,
    fiche: f.fiche,
    stats: s,
  );

  final String type;
  final String code;
  final String nom;
  final String telephone;
  final String adresse;
  final String email;
  final bool actif;
  final bool systeme;
  final FicheTiers fiche;
  final StatsTiers stats;
  final int points;

  bool get estClient => type == TypesTiers.client;
  ListeReferentiel get listeTypes => estClient ? Referentiel.typesClient : Referentiel.typesFournisseur;
}

/// Ton du badge d'un type de tiers.
DsBadgeTon tonTypeTiers(String type) => switch (type) {
  'Consommateur' => DsBadgeTon.neutre,
  'Détaillant' || 'Semi-Grossiste' => DsBadgeTon.primaire,
  'Grossiste' || 'Importateur' => DsBadgeTon.info,
  'Société' || 'Usine' => DsBadgeTon.accent,
  _ => DsBadgeTon.neutre,
};

/// Formulaire client / fournisseur (`ClientFormDialog`, `FournisseurFormDialog`) : 920 px, 2 colonnes.
Future<void> afficherFormulaireTiers(BuildContext context, WidgetRef ref, {required String type, LigneTiers? tiers}) =>
    afficherDialog<void>(
      context,
      builder: (_) => _FormulaireTiers(type: type, tiers: tiers),
    );

class _FormulaireTiers extends ConsumerStatefulWidget {
  const _FormulaireTiers({required this.type, this.tiers});
  final String type;
  final LigneTiers? tiers;

  @override
  ConsumerState<_FormulaireTiers> createState() => _FormulaireTiersState();
}

class _FormulaireTiersState extends ConsumerState<_FormulaireTiers> {
  late final LigneTiers? t = widget.tiers;
  late final _nom = TextEditingController(text: t?.nom);
  late final _tel = TextEditingController(text: t?.telephone);
  late final _activite = TextEditingController(text: t?.fiche.activite);
  late final _adresse = TextEditingController(text: t?.adresse);
  late final _email = TextEditingController(text: t?.email);
  late final _fax = TextEditingController(text: t?.fiche.fax);
  late final _nif = TextEditingController(text: t?.fiche.nif);
  late final _nis = TextEditingController(text: t?.fiche.nis);
  late final _nrc = TextEditingController(text: t?.fiche.nrc);
  late final _rib = TextEditingController(text: t?.fiche.rib);
  late final _obs = TextEditingController(text: t?.fiche.observation);
  late String _wilaya = (t?.fiche.wilaya.isNotEmpty ?? false) ? t!.fiche.wilaya : 'Alger';
  late String _typeTiers = (t?.fiche.type.isNotEmpty ?? false)
      ? t!.fiche.type
      : (_client ? 'Consommateur' : 'Grossiste');
  late String? _banque = (t?.fiche.banque.isNotEmpty ?? false) ? t!.fiche.banque : null;
  late bool _actif = t?.actif ?? true;
  String? _erreur;

  bool get _client => widget.type == TypesTiers.client;
  bool get _edition => t != null;

  @override
  void dispose() {
    for (final c in [_nom, _tel, _activite, _adresse, _email, _fax, _nif, _nis, _nrc, _rib, _obs]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final fiche = FicheTiers(
      wilaya: _wilaya,
      type: _typeTiers,
      activite: _activite.text.trim(),
      fax: _fax.text.trim(),
      nif: _nif.text.trim(),
      nis: _nis.text.trim(),
      nrc: _nrc.text.trim(),
      banque: _banque ?? '',
      rib: _rib.text.trim(),
      observation: _obs.text.trim(),
    );
    final s = ref.read(tiersServiceProvider);
    try {
      if (_client) {
        final c = Client(
          code: t?.code ?? '',
          nom: _nom.text,
          telephone: _tel.text.trim(),
          adresse: _adresse.text.trim(),
          email: _email.text.trim(),
          actif: _actif,
          points: t?.points ?? 0,
          fiche: fiche,
        );
        _edition ? await s.modifierClient(c) : await s.creerClient(c);
      } else {
        final f = Fournisseur(
          code: t?.code ?? '',
          nom: _nom.text,
          telephone: _tel.text.trim(),
          adresse: _adresse.text.trim(),
          email: _email.text.trim(),
          actif: _actif,
          fiche: fiche,
        );
        _edition ? await s.modifierFournisseur(f) : await s.creerFournisseur(f);
      }
      rafraichirCommerce(ref);
      if (mounted) Navigator.of(context).pop();
    } on TiersException catch (e) {
      setState(() => _erreur = messageErreurTiers(l10n, e.erreur));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final telErr = _tel.text.trim().isNotEmpty && !TiersService.telephoneValide(_tel.text.trim())
        ? l10n.tiersFormatTelephone
        : null;
    final nifErr = _nif.text.trim().isNotEmpty && !TiersService.nifValide(_nif.text.trim())
        ? l10n.tiersFormatNif
        : null;
    const lw = 112.0;
    void maj(String _) => setState(() => _erreur = null);
    final titre = _client
        ? (_edition ? l10n.tiersModifierClient : l10n.clientNouveau)
        : (_edition ? l10n.tiersModifierFournisseur : l10n.fournisseurNouveau);
    return DsDialog(
      titre: titre,
      iconeData: _edition ? LucideIcons.pencil : (_client ? LucideIcons.userPlus : LucideIcons.truck),
      description: _edition ? '${t!.nom} · ${t!.code}' : l10n.tiersChampsObligatoires,
      largeur: 920,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('tiers_enregistrer'),
          libelle: _edition ? l10n.communModifier : l10n.communEnregistrer,
          icone: LucideIcons.check,
          onPressed: _nom.text.trim().isEmpty || _tel.text.trim().isEmpty || telErr != null || nifErr != null
              ? null
              : _enregistrer,
        ),
      ],
      contenu: DsGrilleFormulaire(
        children: [
          DsSpan(child: DsSubHead(l10n.tiersInfosGenerales)),
          DsFormRow(
            libelle: l10n.produitsColCode,
            largeurLibelle: lw,
            child: DsTextField(valeurInitiale: t?.code ?? l10n.tiersCodeAuto, actif: false),
          ),
          if (_edition)
            DsFormRow(
              libelle: l10n.tiersEtat,
              largeurLibelle: lw,
              child: DsSwitch(
                valeur: _actif,
                libelle: l10n.communActif,
                actif: !t!.systeme,
                onChanged: (v) => setState(() => _actif = v),
              ),
            )
          else
            const SizedBox(),
          DsFormRow(
            libelle: l10n.clientNom,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: _erreur,
            child: DsTextField(
              key: const ValueKey('tiers_nom'),
              controller: _nom,
              autofocus: true,
              indice: l10n.tiersNomIndice,
              onChanged: maj,
            ),
          ),
          DsFormRow(
            libelle: l10n.clientTelephone,
            obligatoire: true,
            largeurLibelle: lw,
            erreur: telErr,
            child: DsTextField(
              key: const ValueKey('tiers_tel'),
              controller: _tel,
              indice: '05xx xx xx xx',
              onChanged: maj,
            ),
          ),
          DsFormRow(
            libelle: l10n.tiersWilaya,
            obligatoire: true,
            largeurLibelle: lw,
            child: DsSelectReferentiel(
              liste: wilayas,
              valeur: _wilaya,
              onChanged: (v) => setState(() => _wilaya = v ?? _wilaya),
            ),
          ),
          DsFormRow(
            libelle: l10n.tiersType,
            obligatoire: true,
            largeurLibelle: lw,
            child: DsSelectReferentiel(
              liste: _client ? Referentiel.typesClient : Referentiel.typesFournisseur,
              valeur: _typeTiers,
              onChanged: (v) => setState(() => _typeTiers = v ?? _typeTiers),
            ),
          ),
          DsSpan(
            child: DsFormRow(
              libelle: l10n.tiersActivite,
              largeurLibelle: lw,
              child: DsTextField(controller: _activite, indice: l10n.tiersActiviteIndice),
            ),
          ),
          DsSpan(child: DsSubHead(l10n.tiersContact)),
          DsSpan(
            child: DsFormRow(
              libelle: l10n.clientAdresse,
              largeurLibelle: lw,
              child: DsTextField(controller: _adresse, indice: l10n.tiersAdresseIndice),
            ),
          ),
          DsFormRow(
            libelle: l10n.clientEmail,
            largeurLibelle: lw,
            child: DsTextField(controller: _email, indice: 'contact@exemple.dz'),
          ),
          DsFormRow(
            libelle: l10n.tiersFax,
            largeurLibelle: lw,
            child: DsTextField(controller: _fax, indice: '023 xx xx xx'),
          ),
          DsSpan(child: DsSubHead(l10n.tiersInfosAdministratives)),
          DsFormRow(
            libelle: 'NIF',
            largeurLibelle: lw,
            erreur: nifErr,
            child: DsTextField(controller: _nif, indice: l10n.tiers15Chiffres, onChanged: maj),
          ),
          DsFormRow(
            libelle: 'NIS',
            largeurLibelle: lw,
            child: DsTextField(controller: _nis, indice: l10n.tiers15Chiffres),
          ),
          DsFormRow(
            libelle: l10n.tiersNrc,
            largeurLibelle: lw,
            child: DsTextField(controller: _nrc, indice: '16/00-1234567B12'),
          ),
          const SizedBox(),
          DsSpan(child: DsSubHead(l10n.tiersInfosBancaires)),
          DsFormRow(
            libelle: l10n.tiersBanque,
            largeurLibelle: lw,
            child: DsSelect<String>(
              valeur: _banque,
              options: banques,
              libelle: (b) => b,
              placeholder: l10n.tiersChoisir,
              onChanged: (v) => setState(() => _banque = v),
            ),
          ),
          DsFormRow(
            libelle: 'RIB',
            largeurLibelle: lw,
            child: DsTextField(controller: _rib, indice: l10n.tiers20Chiffres),
          ),
          DsSpan(
            child: DsFormRow(
              libelle: l10n.tiersObservation,
              largeurLibelle: lw,
              alignerDebut: true,
              child: DsTextField(controller: _obs, multiligne: true, lignes: 2, indice: l10n.tiersNoteInterne),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _DocTiers = ({String code, DateTime date, double montant, double reste, bool annule});

/// Détail d'un client / fournisseur (`ClientDetailDialog`, `FournisseurDetailDialog`).
Future<void> afficherDetailTiers(
  BuildContext context,
  WidgetRef ref,
  LigneTiers t, {
  VoidCallback? onModifier,
  VoidCallback? onSituation,
  VoidCallback? onVersement,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  String da(double v) => formaterMontant(v, devise);
  final s = t.stats;
  final documents = t.estClient
      ? [
          for (final v in (await ref.read(ventesProvider.future)).where((v) => v.clientCode == t.code).take(5))
            (code: v.code, date: v.date, montant: v.totalNet, reste: v.reste, annule: v.statut != 'Validée'),
        ]
      : [
          for (final a in (await ref.read(achatsProvider.future)).where((a) => a.fournisseurCode == t.code).take(5))
            (code: a.code, date: a.date, montant: a.total, reste: a.reste, annule: a.statut != 'Validé'),
        ];
  if (!context.mounted) return;
  String statutDoc(_DocTiers d) =>
      d.annule ? 'annule' : (d.reste <= 0.004 ? 'paye' : (d.reste < d.montant ? 'partiel' : 'credit'));
  final f = t.fiche;
  await afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      titre: t.nom,
      icone: t.estClient ? LucideIcons.user : LucideIcons.truck,
      description: [
        t.code,
        if (f.type.isNotEmpty) libelleRef(context, t.listeTypes, f.type),
        if (f.wilaya.isNotEmpty) libelleRef(context, wilayas, f.wilaya),
      ].join(' · '),
      onModifier: t.systeme ? null : onModifier,
      badges: [
        if (f.type.isNotEmpty) DsBadge(libelle: libelleRef(context, t.listeTypes, f.type), ton: tonTypeTiers(f.type)),
        BadgeStatut(t.actif ? 'actif' : 'inactif'),
        if (t.points > 0) DsBadge(libelle: l10n.tiersPoints(t.points), ton: DsBadgeTon.accent, icone: LucideIcons.star),
      ],
      piedSupplementaire: [
        if (onVersement != null && !t.systeme)
          Builder(
            builder: (dialogue) => DsButton(
              libelle: l10n.tiersVersement,
              icone: LucideIcons.handCoins,
              variante: DsButtonVariante.secondaire,
              onPressed: () {
                Navigator.of(dialogue).pop();
                onVersement();
              },
            ),
          ),
        if (onSituation != null)
          Builder(
            builder: (dialogue) => DsButton(
              libelle: l10n.tiersSituation,
              icone: LucideIcons.scale,
              variante: DsButtonVariante.secondaire,
              onPressed: () {
                Navigator.of(dialogue).pop();
                onSituation();
              },
            ),
          ),
      ],
      stats: [
        DsStatItem(
          libelle: l10n.tiersTotalAchats,
          valeur: f2(s.achats),
          suffixe: devise,
          icone: LucideIcons.shoppingCart,
        ),
        DsStatItem(libelle: l10n.tiersTotalPaye, valeur: f2(s.paye), suffixe: devise, icone: LucideIcons.banknote),
        if (t.estClient)
          DsStatItem(libelle: l10n.tiersTotalRetours, valeur: f2(s.retours), suffixe: devise, icone: LucideIcons.undo2),
        DsStatItem(
          libelle: l10n.tiersAvance,
          valeur: f2(s.avanceNette),
          suffixe: devise,
          icone: LucideIcons.piggyBank,
          ton: DsBadgeTon.succes,
        ),
        DsStatItem(
          libelle: l10n.tiersCredit,
          valeur: f2(s.credit),
          suffixe: devise,
          icone: LucideIcons.handCoins,
          ton: DsBadgeTon.avertissement,
          tonValeur: s.credit > 0 ? DsBadgeTon.danger : null,
        ),
        DsStatItem(libelle: l10n.tiersDernierAchat, valeur: dateOuTiret(s.dernier), icone: LucideIcons.calendar),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.tiersInfosGenerales,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.produitsColCode, t.code, mono: true),
            DsKeyValue(l10n.tiersType, f.type.isEmpty ? null : libelleRef(context, t.listeTypes, f.type)),
            DsKeyValue(l10n.tiersActivite, f.activite),
            DsKeyValue(l10n.clientTelephone, t.telephone),
            DsKeyValue(l10n.tiersWilaya, f.wilaya.isEmpty ? null : libelleRef(context, wilayas, f.wilaya)),
            DsKeyValue(l10n.clientEmail, t.email),
            DsKeyValue(l10n.clientAdresse, t.adresse, span: 2),
            DsKeyValue(l10n.tiersFax, f.fax),
          ],
        ),
        DsSectionDetail(
          titre: l10n.tiersAdministratifBanque,
          icone: LucideIcons.landmark,
          repliable: true,
          items: [
            DsKeyValue('NIF', f.nif, mono: true),
            DsKeyValue('NIS', f.nis, mono: true),
            DsKeyValue(l10n.tiersNrc, f.nrc),
            DsKeyValue(l10n.tiersBanque, f.banque),
            DsKeyValue('RIB', f.rib, mono: true, span: 2),
            DsKeyValue(l10n.tiersObservation, f.observation, span: 3),
          ],
        ),
        DsSectionDetail(
          titre: t.estClient ? l10n.tiersDerniersPaniers : l10n.tiersDernieresEntrees,
          icone: t.estClient ? LucideIcons.receiptText : LucideIcons.packagePlus,
          nbLignes: documents.length,
          tableau: DsDataTable<_DocTiers>(
            dense: true,
            encadre: false,
            pagine: false,
            cle: (d) => d.code,
            lignes: documents,
            messageVide: l10n.dsAucunElement,
            colonnes: [
              DsColonne(
                id: 'code',
                libelle: t.estClient ? l10n.tiersPanier : l10n.tiersReference,
                valeur: (d) => d.code,
                attenue: true,
              ),
              DsColonne(
                id: 'date',
                libelle: l10n.communDate,
                valeur: (d) => d.date,
                attenue: true,
                cellule: (_, d) => Text(formatDate.format(d.date)),
              ),
              DsColonne(
                id: 'm',
                libelle: l10n.versementMontant,
                numerique: true,
                valeur: (d) => d.montant,
                cellule: (_, d) => Text(da(d.montant)),
              ),
              DsColonne(
                id: 'r',
                libelle: l10n.tiersReste,
                numerique: true,
                valeur: (d) => d.reste,
                cellule: (_, d) => Text(d.reste > 0.004 ? da(d.reste) : '—'),
              ),
              DsColonne(
                id: 's',
                libelle: l10n.tiersStatut,
                valeur: statutDoc,
                cellule: (_, d) => BadgeStatut(statutDoc(d)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Situation d'un tiers (`SituationDialog`) : relevé chronologique filtrable, débit / crédit / solde.
Future<void> afficherSituationTiers(BuildContext context, WidgetRef ref, LigneTiers t) async {
  final lignes = await ref.read(tiersRepositoryProvider).releve(t.type, t.code);
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (_) => _SituationTiers(tiers: t, lignes: lignes),
  );
}

class _SituationTiers extends ConsumerStatefulWidget {
  const _SituationTiers({required this.tiers, required this.lignes});
  final LigneTiers tiers;
  final List<LigneReleve> lignes;

  @override
  ConsumerState<_SituationTiers> createState() => _SituationTiersState();
}

class _SituationTiersState extends ConsumerState<_SituationTiers> {
  late DsPeriode _periode = DsPeriode(
    du: widget.lignes.isEmpty ? DateTime.now() : widget.lignes.first.date,
    au: DateTime.now(),
  );
  NatureReleve? _nature;

  String _libelleNature(AppLocalizations l10n, NatureReleve n) => switch (n) {
    NatureReleve.achat => widget.tiers.estClient ? l10n.tiersNatureVente : l10n.tiersNatureAchat,
    NatureReleve.versement => l10n.tiersNatureVersement,
    NatureReleve.retour => l10n.tiersNatureRetour,
    NatureReleve.versementRetour => l10n.tiersNatureVersementRetour,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    // Solde cumulé calculé sur tout le relevé, puis filtré.
    var cumul = 0.0;
    final toutes = [for (final l in widget.lignes) (ligne: l, solde: cumul += l.credit - l.debit)];
    final lignes = toutes
        .where((x) => dansPeriode(x.ligne.date, _periode) && (_nature == null || x.ligne.nature == _nature))
        .toList();
    final debit = lignes.fold(0.0, (s, x) => s + x.ligne.debit);
    final credit = lignes.fold(0.0, (s, x) => s + x.ligne.credit);
    final colonnes = <DsColonne<({LigneReleve ligne, double solde})>>[
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        valeur: (x) => x.ligne.date,
        attenue: true,
        cellule: (_, x) => Text(formatDate.format(x.ligne.date)),
      ),
      DsColonne(
        id: 'type',
        libelle: l10n.tiersType,
        valeur: (x) => _libelleNature(l10n, x.ligne.nature),
        cellule: (_, x) => DsBadge(
          libelle: _libelleNature(l10n, x.ligne.nature),
          ton: switch (x.ligne.nature) {
            NatureReleve.achat => DsBadgeTon.primaire,
            NatureReleve.versement => DsBadgeTon.succes,
            _ => DsBadgeTon.avertissement,
          },
        ),
      ),
      DsColonne(id: 'ref', libelle: l10n.tiersReference, valeur: (x) => x.ligne.reference),
      DsColonne(
        id: 'deb',
        libelle: l10n.tiersDebit,
        numerique: true,
        valeur: (x) => x.ligne.debit,
        cellule: (_, x) => Text(x.ligne.debit > 0 ? da(x.ligne.debit) : '—'),
        total: (_) => da(debit),
      ),
      DsColonne(
        id: 'cre',
        libelle: l10n.tiersCredit,
        numerique: true,
        valeur: (x) => x.ligne.credit,
        cellule: (_, x) => Text(x.ligne.credit > 0 ? da(x.ligne.credit) : '—'),
        total: (_) => da(credit),
      ),
      DsColonne(
        id: 'solde',
        libelle: l10n.tiersSolde,
        numerique: true,
        fort: true,
        valeur: (x) => x.solde,
        cellule: (_, x) => Text(da(x.solde), style: context.ds.typo.bodySmStrong),
        total: (_) => da(credit - debit),
      ),
    ];
    return DsDialog(
      titre: l10n.tiersSituationDe(widget.tiers.nom),
      iconeData: LucideIcons.scale,
      description: widget.tiers.estClient ? l10n.tiersReleveClient : l10n.tiersReleveFournisseur,
      largeur: 1100,
      piedDebut: peutExporter(ref)
          ? DsExportMenu(
              total: lignes.length,
              onExport: (format, _) => exporterTableau(
                context,
                ref,
                id: 'situation_${widget.tiers.code}',
                titre: l10n.tiersSituationDe(widget.tiers.nom),
                colonnes: colonnes,
                lignes: lignes,
                format: format,
              ),
            )
          : null,
      actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(context).pop())],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsPeriodeLocalisee(periode: _periode, onChanged: (p) => setState(() => _periode = p)),
          Row(
            children: [
              Expanded(
                child: DsFormRow(
                  libelle: l10n.tiersType,
                  largeurLibelle: 48,
                  child: DsSelect<NatureReleve?>(
                    valeur: _nature,
                    options: [
                      null,
                      ...NatureReleve.values.where((n) => widget.tiers.estClient || n != NatureReleve.retour),
                    ],
                    libelle: (n) => n == null ? l10n.tiersTous : _libelleNature(l10n, n),
                    onChanged: (n) => setState(() => _nature = n),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          DsStatsStrip(
            compact: true,
            items: [
              DsStatItem(
                libelle: l10n.tiersDebitAide,
                valeur: f2(debit),
                suffixe: devise,
                icone: LucideIcons.arrowDownLeft,
                ton: DsBadgeTon.succes,
              ),
              DsStatItem(
                libelle: l10n.tiersCreditAide,
                valeur: f2(credit),
                suffixe: devise,
                icone: LucideIcons.arrowUpRight,
                ton: DsBadgeTon.primaire,
              ),
              DsStatItem(
                libelle: l10n.tiersSoldeDu,
                valeur: f2(credit - debit),
                suffixe: devise,
                icone: LucideIcons.scale,
                ton: DsBadgeTon.avertissement,
                tonValeur: credit - debit > 0 ? DsBadgeTon.danger : DsBadgeTon.succes,
              ),
            ],
          ),
          DsDataTable(
            dense: true,
            pagine: false,
            hauteurMax: 320,
            afficherTotaux: true,
            cle: (x) => '${x.ligne.reference}_${x.ligne.nature.name}_${x.ligne.date.microsecondsSinceEpoch}',
            lignes: lignes,
            colonnes: colonnes,
            messageVide: l10n.dsAucunElement,
          ),
        ],
      ),
    );
  }
}

/// Annulation de tiers en lot (`BulkActionDialog`) : motif obligatoire ; système et crédit en cours bloqués.
Future<void> annulerTiers(BuildContext context, WidgetRef ref, List<LigneTiers> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final type = choix.first.type;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: type == TypesTiers.client ? l10n.tiersEntiteClient : l10n.tiersEntiteFournisseur,
    entitePluriel: type == TypesTiers.client ? l10n.tiersEntiteClients : l10n.tiersEntiteFournisseurs,
    motifRequis: true,
    elements: [
      for (final t in choix)
        DsElementLot(
          id: t.code,
          titre: t.nom,
          sousTitre: t.code,
          meta: t.stats.credit > 0 ? formaterMontant(t.stats.credit, devise) : null,
          motifBlocage: t.systeme
              ? l10n.tiersBloqueSysteme
              : (t.stats.credit > 0.004 ? l10n.tiersBloqueCredit : (!t.actif ? l10n.tiersBloqueDejaAnnule : null)),
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final codes = [
    for (final t in choix)
      if (!t.systeme && t.stats.credit <= 0.004 && t.actif) t.code,
  ];
  try {
    await ref.read(tiersServiceProvider).annuler(type, codes, motif: motif);
    effacer();
    rafraichirCommerce(ref);
  } on TiersException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.dsAnnuler,
        message: messageErreurTiers(l10n, e.erreur),
      ),
    );
  }
}
