import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../application/parametres_service.dart';
import '../../application/zakat_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/referentiel/referentiel.dart';
import '../../domain/zakat.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';

final zakatServiceProvider = Provider<ZakatService>(
  (ref) => ZakatService(ref.watch(appDatabaseProvider).db, utilisateurCode: ref.watch(utilisateurCourantCodeProvider)),
);

final zakatVersionProvider = NotifierProvider<VersionNotifier, int>(VersionNotifier.new);

void rafraichirZakat(WidgetRef ref) => ref.read(zakatVersionProvider.notifier).incrementer();

final calculsZakatProvider = FutureProvider<List<Zakat>>((ref) {
  ref.watch(zakatVersionProvider);
  return ref.watch(zakatServiceProvider).calculs();
});

/// Patrimoine courant (stock, caisses, crédits) : base des KPI provisoires et du pré-remplissage.
final patrimoineZakatProvider = FutureProvider<PatrimoineZakat>((ref) {
  ref.watch(zakatVersionProvider);
  ref.watch(rapportsVersionProvider);
  return ref.watch(zakatServiceProvider).patrimoine();
});

final parametresZakatProvider = FutureProvider<ParametresZakat>((ref) {
  ref.watch(zakatVersionProvider);
  return ref.watch(zakatServiceProvider).parametres();
});

final DateFormat formatJour = DateFormat('dd/MM/yyyy');

/// Statut affiché : annulée, exonérée (sous le nissab), sinon le statut stocké.
String cleStatutZakat(Zakat z) => !z.actif
    ? 'annule'
    : !z.obligatoire
    ? 'exoneree'
    : z.statut;

Widget badgeStatutZakat(BuildContext context, Zakat z) {
  final l10n = AppLocalizations.of(context);
  return switch (cleStatutZakat(z)) {
    'annule' => DsBadge(libelle: l10n.zkAnnulee, ton: DsBadgeTon.danger, point: true),
    'exoneree' => DsBadge(libelle: l10n.zkExoneree, ton: DsBadgeTon.neutre, point: true),
    StatutsZakat.payee => DsBadge(
      libelle: libelleRef(context, Referentiel.statutsZakat, z.statut),
      ton: DsBadgeTon.succes,
      point: true,
    ),
    StatutsZakat.nonPaye => DsBadge(
      libelle: libelleRef(context, Referentiel.statutsZakat, z.statut),
      ton: DsBadgeTon.avertissement,
      point: true,
    ),
    _ => DsBadge(libelle: libelleRef(context, Referentiel.statutsZakat, z.statut), ton: DsBadgeTon.info, point: true),
  };
}

String messageErreurZakat(AppLocalizations l10n, ErreurZakat e) => switch (e) {
  ErreurZakat.zakatInconnue => l10n.zkErrInconnue,
  ErreurZakat.valeurInvalide => l10n.zkErrValeur,
  ErreurZakat.dejaPayee => l10n.zkBloqueePayee,
  ErreurZakat.annulee => l10n.zkBloqueeAnnulee,
  ErreurZakat.motifObligatoire => l10n.zkErrMotif,
};

Future<bool> executerZakat(BuildContext context, WidgetRef ref, String titre, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  String? message;
  try {
    await action();
  } on ZakatException catch (e) {
    message = messageErreurZakat(l10n, e.erreur);
  }
  rafraichirZakat(ref);
  if (message != null && context.mounted) {
    unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: titre, message: message));
  }
  return message == null;
}

// ---------------------------------------------------------------------------------------------------------------
// Formulaire (ZakatFormDialog, 860 px).
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherFormulaireZakat(BuildContext context, WidgetRef ref, {Zakat? zakat}) async {
  final s = ref.read(zakatServiceProvider);
  final patrimoine = await s.patrimoine();
  final parametres = await s.parametres();
  final code = zakat?.code ?? await s.prochainCode();
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    fermableParVoile: false,
    builder: (_) => _ZakatForm(zakat: zakat, code: code, patrimoine: patrimoine, parametres: parametres),
  );
}

class _ZakatForm extends ConsumerStatefulWidget {
  const _ZakatForm({required this.zakat, required this.code, required this.patrimoine, required this.parametres});
  final Zakat? zakat;
  final String code;
  final PatrimoineZakat patrimoine;
  final ParametresZakat parametres;

  @override
  ConsumerState<_ZakatForm> createState() => _ZakatFormState();
}

class _ZakatFormState extends ConsumerState<_ZakatForm> {
  Zakat? get _z => widget.zakat;
  PatrimoineZakat get _p => widget.patrimoine;
  static String _n(double v) => formaterNombre(v, decimales: 2, grouper: false);

  late final _annee = TextEditingController(text: '${_z?.annee ?? DateTime.now().year}');
  late final _stock = TextEditingController(text: _n(_z?.stock ?? _p.stock));
  late final _liquidites = TextEditingController(text: _n(_z?.liquidites ?? _p.liquidites));
  late final _creances = TextEditingController(text: _n(_z?.creances ?? _p.creances));
  late final _dettes = TextEditingController(text: _n(_z?.dettes ?? _p.dettes));
  late final _nissab = TextEditingController(text: _n(_z?.nissab ?? widget.parametres.nissab));
  late final _observation = TextEditingController(text: _z?.observation ?? '');
  late String _statut = _z?.statut ?? StatutsZakat.brouillon;
  late DateTime _debut = _z?.debutHawl ?? DateUtils.dateOnly(DateTime.now());
  late DateTime _due = _z?.dateDue ?? CalculZakat.echeance(_debut);
  late final double _taux = _z?.tauxPct ?? widget.parametres.tauxPct;
  bool _occupe = false;

  @override
  void dispose() {
    for (final c in [_annee, _stock, _liquidites, _creances, _dettes, _nissab, _observation]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => lireNombre(c.text) ?? 0;

  Zakat _construire() => Zakat(
    code: widget.code,
    annee: int.tryParse(_annee.text.trim()) ?? 0,
    debutHawl: _debut,
    dateDue: _due,
    stock: _v(_stock),
    liquidites: _v(_liquidites),
    creances: _v(_creances),
    dettes: _v(_dettes),
    nissab: _v(_nissab),
    tauxPct: _taux,
    statut: _statut,
    datePaiement: _statut == StatutsZakat.payee ? (_z?.datePaiement ?? DateTime.now()) : null,
    observation: _observation.text.trim(),
  );

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final s = ref.read(zakatServiceProvider);
    final z = _construire();
    final fait = await executerZakat(context, ref, l10n.zkEnregistre, () async {
      _z == null ? await s.creer(z) : await s.modifier(z);
    });
    if (!mounted) return;
    if (!fait) {
      setState(() => _occupe = false);
      return;
    }
    Navigator.of(context).pop();
    afficherToast(context, titre: l10n.zkEnregistre, description: z.code, ton: DsToastTon.succes);
  }

  Widget _montant(String cle, TextEditingController c, {double? auto, String? libelleAuto}) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    return Row(
      spacing: DsSpacing.s1,
      children: [
        Expanded(
          child: DsTextField(
            key: ValueKey(cle),
            controller: c,
            numerique: true,
            suffixeTexte: devise,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (auto != null)
          DsIconButton(
            key: ValueKey('${cle}_auto'),
            icone: LucideIcons.refreshCw,
            tooltip: l10n.zkReprendre(libelleAuto ?? ''),
            onPressed: () => setState(() => c.text = _n(auto)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final z = _construire();
    const lw = 150.0;
    final valide = z.annee >= 1900 && !_due.isBefore(_debut);
    Widget carte(String libelle, String valeur, DsBadgeTon? ton) {
      final (fond, texte) = switch (ton) {
        DsBadgeTon.primaire => (c.primaryTint, c.primaryTintFg),
        DsBadgeTon.avertissement => (c.warningTint, c.warningFg),
        DsBadgeTon.succes => (c.successTint, c.successFg),
        _ => (c.surfaceSunken, c.textSecondary),
      };
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: DsSpacing.s3),
          decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libelle,
                style: t.caption.copyWith(fontWeight: FontWeight.w600, color: texte),
              ),
              Text(
                valeur,
                style: t.heading.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: texte),
              ),
            ],
          ),
        ),
      );
    }

    return DsDialog(
      titre: _z == null ? l10n.zkNouveauTitre : l10n.zkModifierTitre,
      iconeData: LucideIcons.handCoins,
      description: _z?.code ?? l10n.zkFormDescription,
      largeur: 860,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('zakat_enregistrer'),
          libelle: l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: valide ? _enregistrer : null,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DsSpacing.s4,
        children: [
          DsGrilleFormulaire(
            children: [
              DsSpan(child: DsSubHead(l10n.zkSectionPeriode, icone: LucideIcons.calendar)),
              DsFormRow(
                libelle: l10n.zkColAnnee,
                obligatoire: true,
                largeurLibelle: lw,
                child: DsTextField(
                  key: const ValueKey('zakat_annee'),
                  controller: _annee,
                  numerique: true,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              DsFormRow(
                libelle: l10n.zkColStatut,
                largeurLibelle: lw,
                child: DsSelect<String>(
                  cle: const ValueKey('zakat_statut'),
                  valeur: _statut,
                  options: [for (final v in Referentiel.statutsZakat.valeurs) v.stocke],
                  libelle: (v) => libelleRef(context, Referentiel.statutsZakat, v),
                  onChanged: (v) => setState(() => _statut = v ?? _statut),
                ),
              ),
              DsFormRow(
                libelle: l10n.zkDebutHawl,
                obligatoire: true,
                largeurLibelle: lw,
                child: DsDateField(
                  valeur: _debut,
                  onChanged: (d) => setState(() {
                    if (d == null) return;
                    _debut = d;
                    _due = CalculZakat.echeance(d);
                  }),
                ),
              ),
              DsFormRow(
                libelle: l10n.zkDueLe,
                largeurLibelle: lw,
                aide: l10n.zkDueIndice,
                child: DsDateField(valeur: _due, onChanged: (d) => setState(() => _due = d ?? _due)),
              ),
              DsSpan(child: DsSubHead(l10n.zkSectionPatrimoine, icone: LucideIcons.wallet)),
              DsFormRow(
                libelle: l10n.zkValeurStock,
                obligatoire: true,
                largeurLibelle: lw,
                aide: l10n.zkStockIndice,
                child: _montant('zakat_stock', _stock, auto: _p.stock, libelleAuto: l10n.zkRepValeurStock),
              ),
              DsFormRow(
                libelle: l10n.zkColLiquidites,
                obligatoire: true,
                largeurLibelle: lw,
                aide: l10n.zkLiquiditesIndice,
                child: _montant('zakat_liquidites', _liquidites, auto: _p.liquidites, libelleAuto: l10n.zkRepSoldes),
              ),
              DsFormRow(
                libelle: l10n.zkColCreances,
                largeurLibelle: lw,
                aide: l10n.zkCreancesIndice,
                child: _montant('zakat_creances', _creances, auto: _p.creances, libelleAuto: l10n.zkRepCreances),
              ),
              DsFormRow(
                libelle: l10n.zkDettesCourt,
                largeurLibelle: lw,
                aide: l10n.zkDettesIndice,
                child: _montant('zakat_dettes', _dettes, auto: _p.dettes, libelleAuto: l10n.zkRepDettes),
              ),
              DsFormRow(
                libelle: l10n.zkColNissab,
                obligatoire: true,
                largeurLibelle: lw,
                aide: l10n.zkNissabIndice,
                child: _montant('zakat_nissab', _nissab),
              ),
              DsFormRow(
                libelle: l10n.zkColTaux,
                largeurLibelle: lw,
                child: DsTextField(
                  valeurInitiale: formaterNombre(_taux, decimales: 1),
                  suffixeTexte: '%',
                  actif: false,
                ),
              ),
              DsSpan(
                child: DsFormRow(
                  libelle: l10n.zkColObservation,
                  largeurLibelle: lw,
                  alignerDebut: true,
                  child: DsTextField(controller: _observation, multiligne: true, lignes: 2),
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              carte(l10n.zkCapitalSoumis, formaterMontant(z.capital, devise), DsBadgeTon.primaire),
              carte(
                z.obligatoire ? l10n.zkAuDessus : l10n.zkEnDessous,
                z.obligatoire ? l10n.zkObligatoire : l10n.zkExoneree,
                z.obligatoire ? DsBadgeTon.avertissement : null,
              ),
              carte(l10n.zkMontant, formaterMontant(z.montant, devise), z.obligatoire ? DsBadgeTon.succes : null),
            ],
          ),
          Row(
            spacing: DsSpacing.s2,
            children: [
              Icon(LucideIcons.info, size: 14, color: c.textMuted),
              Expanded(
                child: Text(
                  l10n.zkFormule(formaterNombre(_taux, decimales: 1)),
                  style: t.caption.copyWith(fontSize: 12.5, color: c.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Détail (900 px), paiement, annulation.
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherDetailZakat(BuildContext context, WidgetRef ref, Zakat z) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final noms = await ref.read(nomsUtilisateursProvider.future);
  if (!context.mounted) return;
  final postes = [
    (l10n.zkValeurStock, z.stock),
    (l10n.zkColLiquidites, z.liquidites),
    (l10n.zkColCreances, z.creances),
    (l10n.zkDettesCourt, -z.dettes),
  ];
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 900,
      icone: LucideIcons.handCoins,
      titre: l10n.zkDetailTitre(z.annee),
      description: l10n.zkDetailDescription(z.code, formatJour.format(z.debutHawl), formatJour.format(z.dateDue)),
      badges: [badgeStatutZakat(context, z)],
      onModifier: z.estPayee || !z.actif ? null : () => afficherFormulaireZakat(context, ref, zakat: z),
      stats: [
        DsStatItem(libelle: l10n.zkColCapital, valeur: f2(z.capital), suffixe: devise, icone: LucideIcons.scale),
        DsStatItem(libelle: l10n.zkColNissab, valeur: f2(z.nissab), suffixe: devise, icone: LucideIcons.gem),
        DsStatItem(
          libelle: l10n.zkColZakat,
          valeur: f2(z.montant),
          suffixe: devise,
          icone: LucideIcons.handCoins,
          ton: DsBadgeTon.succes,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.zkCalcul,
          icone: LucideIcons.calculator,
          nbLignes: postes.length,
          tableau: DsDataTable<(String, double)>(
            dense: true,
            encadre: false,
            pagine: false,
            afficherTotaux: true,
            cle: (p) => p.$1,
            lignes: postes,
            colonnes: [
              DsColonne(id: 'poste', libelle: l10n.zkPoste, fort: true, valeur: (p) => p.$1),
              DsColonne(
                id: 'montant',
                libelle: l10n.zkMontantCol,
                numerique: true,
                valeur: (p) => p.$2,
                cellule: (_, p) => Text('${p.$2 < 0 ? '− ' : ''}${formaterMontant(p.$2.abs(), devise)}'),
                total: (_) => formaterMontant(z.capital, devise),
              ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.zkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.zkColCreePar, z.creePar == null ? '—' : (noms[z.creePar] ?? z.creePar!)),
            DsKeyValue(l10n.zkColPayee, z.datePaiement == null ? '—' : formatJour.format(z.datePaiement!)),
            DsKeyValue(l10n.zkColObservation, z.observation.isEmpty ? '—' : z.observation),
            if (!z.actif) DsKeyValue(l10n.zkMotif, z.motifAnnulation ?? '—'),
          ],
        ),
      ],
    ),
  );
}

Future<void> marquerZakatPayee(BuildContext context, WidgetRef ref, Zakat z) async {
  final l10n = AppLocalizations.of(context);
  final fait = await executerZakat(
    context,
    ref,
    l10n.zkMarquerPayee,
    () => ref.read(zakatServiceProvider).marquerPayee(z.code),
  );
  if (fait && context.mounted) {
    afficherToast(context, titre: l10n.zkPayeeToast, description: z.code, ton: DsToastTon.succes);
  }
}

Future<void> annulerZakats(BuildContext context, WidgetRef ref, List<Zakat> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final service = ref.read(zakatServiceProvider);
  String? motif(Zakat z) => switch (service.blocageAnnulation(z)) {
    null => null,
    final e => messageErreurZakat(l10n, e),
  };
  final saisi = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.zkEntiteUn,
    entitePluriel: l10n.zkEntite,
    motifRequis: true,
    elements: [
      for (final z in choix)
        DsElementLot(
          id: z.code,
          titre: l10n.zkDetailTitre(z.annee),
          sousTitre: z.code,
          meta: formaterMontant(z.montant, devise),
          motifBlocage: motif(z),
        ),
    ],
  );
  if (saisi == null || !context.mounted) return;
  final codes = [
    for (final z in choix)
      if (motif(z) == null) z.code,
  ];
  final fait = await executerZakat(context, ref, l10n.zkAnnuler, () => service.annuler(codes, motif: saisi));
  effacer();
  if (fait && context.mounted) afficherToast(context, titre: l10n.zkAnnules);
}
