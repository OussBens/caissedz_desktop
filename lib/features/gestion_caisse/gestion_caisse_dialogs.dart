import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../application/caisse_service.dart';
import '../../application/cloture_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/export/export_fiscal.dart';
import '../../core/export/export_g50.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/boutique_repository.dart';
import '../../data/fiscalite_repository.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/rapport.dart';
import '../../domain/models/vente.dart';
import '../../domain/referentiel/referentiel.dart';
import '../../domain/scellement.dart';
import '../commun/export_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import 'gestion_caisse_providers.dart';

String _da(WidgetRef ref, double v) => formaterMontant(v, ref.read(deviseProvider));

/// Format court des bornes de clôture et des mouvements (`10/10 20:01`).
final DateFormat formatJourHeure = DateFormat('dd/MM HH:mm');

/// Statut DS d'une session (`ouverte` / `cloturee`).
String statutSession(SessionCaisse s) => s.estOuverte ? 'ouverte' : 'cloturee';

/// Session à laquelle appartient un mouvement : référence directe, sinon session de la même caisse
/// ouverte à cette date.
String? sessionDuMouvement(MouvementCaisse m, List<SessionCaisse> sessions) {
  if (m.referenceType == 'session_caisse') return m.referenceCode;
  for (final s in sessions) {
    if (s.caisseCode == m.caisseCode &&
        !m.date.isBefore(s.ouverteLe) &&
        (s.fermeeLe == null || !m.date.isAfter(s.fermeeLe!))) {
      return s.code;
    }
  }
  return null;
}

/// Exécute une écriture de caisse ; affiche l'erreur métier et rafraîchit les données.
Future<bool> executerCaisse(BuildContext context, WidgetRef ref, String titre, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  String? message;
  try {
    await action();
  } on CaisseException catch (e) {
    message = messageErreurCaisse(l10n, e.erreur);
  } on ClotureException catch (e) {
    message = messageErreurCloture(l10n, e.erreur);
  }
  rafraichirCaisse(ref);
  if (message != null && context.mounted) {
    unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: titre, message: message));
  }
  return message == null;
}

/// Encadré d'information (`surface-sunken`, icône + texte) des dialogs de caisse.
class _Encadre extends StatelessWidget {
  const _Encadre({required this.icone, required this.child, this.ton});
  final IconData icone;
  final Widget child;
  final DsBadgeTon? ton;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, couleur, couleurIcone) = switch (ton) {
      DsBadgeTon.succes => (c.successTint, c.successFg, c.successFg),
      DsBadgeTon.danger => (c.dangerTint, c.dangerFg, c.dangerFg),
      _ => (c.surfaceSunken, c.textSecondary, c.iconActive),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
      child: Row(
        spacing: 10,
        children: [
          Icon(icone, size: 16, color: couleurIcone),
          Expanded(
            child: DefaultTextStyle(
              style: t.bodySm.copyWith(fontWeight: FontWeight.w500, color: couleur),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ———————————————————————————— Caisses ————————————————————————————

/// Création / modification d'une caisse (`CaisseFormDialog`, 620 px).
Future<void> afficherFormulaireCaisse(BuildContext context, WidgetRef ref, {Caisse? caisse}) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(caisseServiceProvider);
  final code = caisse?.code ?? await service.prochainCode();
  if (!context.mounted) return;
  final nom = TextEditingController(text: caisse?.nom ?? '');
  final solde = TextEditingController(text: formaterNombre(caisse?.soldeInitial ?? 0, decimales: 2));
  final observation = TextEditingController(text: caisse?.observation ?? '');
  var type = caisse?.type ?? TypesCaisse.physique;
  var actif = caisse?.actif ?? true;
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: caisse == null ? l10n.caisseNouvelle : l10n.caisseModifier,
        iconeData: LucideIcons.wallet,
        description: caisse?.code ?? l10n.gcFormDescription,
        largeur: 620,
        actions: [
          DsButton(
            libelle: l10n.dsAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            key: const ValueKey('caisse_enregistrer'),
            libelle: l10n.communEnregistrer,
            icone: LucideIcons.check,
            onPressed: nom.text.trim().isEmpty || (lireNombre(solde.text) ?? -1) < 0
                ? null
                : () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            DsFormRow(
              libelle: l10n.produitsColCode,
              child: DsTextField(valeurInitiale: code, actif: false),
            ),
            DsFormRow(
              libelle: l10n.caisseNom,
              obligatoire: true,
              child: DsTextField(
                key: const ValueKey('caisse_nom'),
                controller: nom,
                autofocus: true,
                indice: l10n.gcFormNomIndice,
                onChanged: (_) => setState(() {}),
              ),
            ),
            DsFormRow(
              libelle: l10n.caisseType,
              obligatoire: true,
              child: DsSelect<String>(
                valeur: type,
                options: const [TypesCaisse.physique, TypesCaisse.compte],
                libelle: (v) => libelleTypeCaisse(l10n, v),
                onChanged: (v) => setState(() => type = v ?? type),
              ),
            ),
            DsFormRow(
              libelle: l10n.gcColSoldeInitial,
              obligatoire: true,
              aide: l10n.gcFormSoldeInitialAide,
              child: DsTextField(
                key: const ValueKey('caisse_solde_initial'),
                controller: solde,
                numerique: true,
                actif: caisse == null,
                suffixeTexte: ref.read(deviseProvider),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (caisse != null)
              DsFormRow(
                libelle: l10n.gcColEtat,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DsSwitch(
                    cle: const ValueKey('caisse_active'),
                    valeur: actif,
                    libelle: l10n.caisseActive,
                    actif: !caisse.systeme,
                    onChanged: (v) => setState(() => actif = v),
                  ),
                ),
              ),
            DsFormRow(
              libelle: l10n.retoursObservation,
              alignerDebut: true,
              child: DsTextField(controller: observation, multiligne: true, lignes: 2),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final fait = await executerCaisse(context, ref, l10n.gcEntiteCaisse, () async {
    if (caisse == null) {
      await service.creer(
        nom: nom.text,
        type: type,
        soldeInitial: lireNombre(solde.text) ?? 0,
        observation: observation.text,
      );
    } else {
      await service.modifier(
        caisse.copyWith(nom: nom.text, type: type, actif: actif, observation: () => observation.text),
      );
    }
  });
  if (fait && context.mounted) afficherToast(context, titre: l10n.gcCaisseEnregistree, description: nom.text.trim());
}

/// Détail d'une caisse (`EntityDetailDialog`, 940 px) : soldes, sessions des 30 derniers jours, écart cumulé.
Future<void> afficherDetailCaisse(BuildContext context, WidgetRef ref, Caisse c) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final solde = (await ref.read(soldesCaissesProvider.future))[c.code]?.total ?? 0;
  final sessions = (await ref.read(sessionsCaisseProvider.future)).where((s) => s.caisseCode == c.code).toList();
  final magasins = {for (final m in await ref.read(magasinsProvider.future)) m.code: m.nom};
  if (!context.mounted) return;
  final limite = DateTime.now().subtract(const Duration(days: 30));
  final recentes = sessions.where((s) => s.ouverteLe.isAfter(limite)).toList();
  final ecart = sessions.fold(0.0, (x, s) => x + (s.ecart ?? 0));
  final ouverte = sessions.any((s) => s.estOuverte);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.wallet,
      titre: c.nom,
      description: [
        c.code,
        libelleTypeCaisse(l10n, c.type),
        if (c.magasinCode != null) magasins[c.magasinCode] ?? c.magasinCode!,
      ].join(' · '),
      badges: [BadgeStatut(ouverte ? 'ouverte' : 'fermee')],
      onModifier: () => afficherFormulaireCaisse(context, ref, caisse: c),
      stats: [
        DsStatItem(libelle: l10n.gcColSoldeActuel, valeur: f2(solde), suffixe: devise, icone: LucideIcons.wallet),
        DsStatItem(
          libelle: l10n.gcColSoldeInitial,
          valeur: f2(c.soldeInitial),
          suffixe: devise,
          icone: LucideIcons.piggyBank,
        ),
        DsStatItem(libelle: l10n.gcSessions30j, valeur: '${recentes.length}', icone: LucideIcons.calendar),
        DsStatItem(
          libelle: l10n.gcEcartCumule,
          valeur: f2(ecart),
          suffixe: devise,
          icone: LucideIcons.scale,
          tonValeur: ecart < -0.005
              ? DsBadgeTon.danger
              : ecart > 0.005
              ? DsBadgeTon.succes
              : null,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.gcDernieresSessions,
          icone: LucideIcons.calendar,
          nbLignes: sessions.length,
          tableau: DsDataTable<SessionCaisse>(
            dense: true,
            encadre: false,
            pagine: false,
            hauteurMax: 320,
            cle: (s) => s.code,
            lignes: sessions.take(20).toList(),
            messageVide: l10n.gcAucuneSession,
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.gcColSession, fort: true, valeur: (s) => s.code),
              DsColonne(
                id: 'ouv',
                libelle: l10n.gcColOuverture,
                attenue: true,
                valeur: (s) => s.ouverteLe,
                cellule: (_, s) => Text(formatJourHeure.format(s.ouverteLe)),
              ),
              DsColonne(
                id: 'clo',
                libelle: l10n.gcColCloture,
                attenue: true,
                valeur: (s) => s.fermeeLe,
                cellule: (_, s) => Text(s.fermeeLe == null ? '—' : formatJourHeure.format(s.fermeeLe!)),
              ),
              DsColonne(
                id: 'ecart',
                libelle: l10n.gcColEcart,
                numerique: true,
                valeur: (s) => s.ecart,
                cellule: (_, s) => Text(s.ecart == null ? '—' : f2(s.ecart!)),
              ),
              DsColonne(
                id: 'statut',
                libelle: l10n.gcColStatut,
                valeur: statutSession,
                cellule: (_, s) => BadgeStatut(statutSession(s)),
              ),
            ],
          ),
        ),
        if (c.observation != null)
          DsSectionDetail(
            titre: l10n.retoursObservation,
            icone: LucideIcons.messageSquare,
            items: [DsKeyValue(l10n.retoursObservation, c.observation, span: 3)],
          ),
      ],
    ),
  );
}

/// Désactivation en lot (`BulkActionDialog` deactivate) : session ouverte ou solde non nul bloquent.
Future<void> desactiverCaisses(BuildContext context, WidgetRef ref, List<Caisse> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(caisseServiceProvider);
  final soldes = await ref.read(soldesCaissesProvider.future);
  final blocages = {for (final c in choix) c.code: await service.blocageDesactivation(c)};
  if (!context.mounted) return;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.desactiver,
    entite: l10n.gcEntiteCaisse,
    entitePluriel: l10n.gcEntiteCaisses,
    elements: [
      for (final c in choix)
        DsElementLot(
          id: c.code,
          titre: c.nom,
          sousTitre: libelleTypeCaisse(l10n, c.type),
          meta: _da(ref, soldes[c.code]?.total ?? 0),
          motifBlocage: switch (blocages[c.code]) {
            null => null,
            ErreurCaisse.sessionOuverte => l10n.gcBloqueSession,
            ErreurCaisse.soldeNonNul => l10n.gcBloqueSolde,
            ErreurCaisse.caisseSysteme => l10n.gcBloqueSysteme,
            ErreurCaisse.caisseInactive => l10n.gcBloqueInactive,
            final e => messageErreurCaisse(l10n, e),
          },
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final codes = [
    for (final c in choix)
      if (blocages[c.code] == null) c.code,
  ];
  final ok = await executerCaisse(context, ref, l10n.caisseDesactiver, () => service.desactiver(codes));
  effacer();
  if (ok && context.mounted) afficherToast(context, titre: l10n.gcToastDesactivees);
}

// ———————————————————————————— Transferts ————————————————————————————

/// Modes proposés pour un transfert entre caisses (`TransfertCaisseDialog`).
const modesTransfertCaisse = ['Espèces', 'Chèque'];

/// Transfert entre caisses (`TransfertCaisseDialog`, 620 px) : solde disponible, aperçu du solde restant.
Future<void> afficherTransfertCaisse(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  final soldes = await ref.read(soldesCaissesProvider.future);
  if (!context.mounted || caisses.length < 2) return;
  double disponible(String code, String mode) => soldes[code]?.parMode[mode] ?? 0;
  var source = (caisses.where((c) => disponible(c.code, 'Espèces') > 0).firstOrNull ?? caisses.first).code;
  var destination = caisses.firstWhere((c) => c.code != source).code;
  var mode = modesTransfertCaisse.first;
  var date = DateTime.now();
  final montant = TextEditingController();
  final motif = TextEditingController();
  String nom(String code) => caisses.firstWhere((c) => c.code == code).nom;
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final m = lireNombre(montant.text) ?? 0;
        final dispo = disponible(source, mode);
        final erreur = source == destination ? l10n.gcTrfMemeCaisse : null;
        final depasse = m > dispo + 0.0001;
        return DsDialog(
          titre: l10n.gcTrfTitre,
          iconeData: LucideIcons.arrowLeftRight,
          description: l10n.gcTrfDescription,
          largeur: 620,
          actions: [
            DsButton(
              libelle: l10n.dsAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              key: const ValueKey('trf_valider'),
              libelle: l10n.gcTrfValider(m > 0 ? _da(ref, m) : '').trim(),
              icone: LucideIcons.check,
              onPressed: erreur != null || depasse || m <= 0 ? null : () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              DsFormRow(
                libelle: l10n.communDate,
                obligatoire: true,
                child: DsDateField(
                  valeur: date,
                  max: DateTime.now(),
                  onChanged: (d) => setState(() => date = d ?? date),
                ),
              ),
              DsFormRow(
                libelle: l10n.gcColDepuis,
                obligatoire: true,
                aide: l10n.gcTrfDisponible(_da(ref, dispo)),
                child: DsSelect<String>(
                  cle: const ValueKey('trf_source'),
                  valeur: source,
                  options: [for (final c in caisses) c.code],
                  libelle: nom,
                  recherche: rechercheListe(context, ref, ListeMetier.caisse),
                  onChanged: (v) => setState(() => source = v ?? source),
                ),
              ),
              DsFormRow(
                libelle: l10n.gcColVers,
                obligatoire: true,
                erreur: erreur,
                child: DsSelect<String>(
                  cle: const ValueKey('trf_destination'),
                  valeur: destination,
                  options: [for (final c in caisses) c.code],
                  libelle: nom,
                  recherche: rechercheListe(context, ref, ListeMetier.caisse),
                  onChanged: (v) => setState(() => destination = v ?? destination),
                ),
              ),
              DsFormRow(
                libelle: l10n.retoursMontant,
                obligatoire: true,
                erreur: depasse ? l10n.gcTrfSuperieur(nom(source)) : null,
                child: DsTextField(
                  key: const ValueKey('trf_montant'),
                  controller: montant,
                  numerique: true,
                  autofocus: true,
                  indice: '0,00',
                  suffixeTexte: ref.read(deviseProvider),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              DsFormRow(
                libelle: l10n.gcColMode,
                child: DsSelect<String>(
                  valeur: mode,
                  options: modesTransfertCaisse,
                  libelle: (v) => libelleRef(ctx, Referentiel.modesPaiement, v),
                  onChanged: (v) => setState(() => mode = v ?? mode),
                ),
              ),
              DsFormRow(
                libelle: l10n.posMvtMotif,
                alignerDebut: true,
                child: DsTextField(controller: motif, multiligne: true, lignes: 2, indice: l10n.gcTrfMotifIndice),
              ),
              if (erreur == null && m > 0 && !depasse)
                _Encadre(
                  icone: LucideIcons.wallet,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${nom(source)} : ${_da(ref, dispo)} → '),
                        TextSpan(
                          text: _da(ref, dispo - m),
                          style: TextStyle(fontWeight: FontWeight.w700, color: ctx.ds.colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  TransfertCaisse? t;
  final aujourdhui = DateUtils.isSameDay(date, DateTime.now());
  final fait = await executerCaisse(context, ref, l10n.gcTrfTitre, () async {
    t = await ref
        .read(caisseServiceProvider)
        .transferer(
          caisseSource: source,
          caisseDestination: destination,
          montant: lireNombre(montant.text) ?? 0,
          mode: mode,
          commentaire: motif.text,
          date: aujourdhui ? null : DateTime(date.year, date.month, date.day, 12),
        );
  });
  if (fait && context.mounted) afficherToast(context, titre: l10n.gcToastTransfert, description: t?.code);
}

/// Annulation de transferts (`BulkActionDialog` cancel, motif obligatoire) : soldes rétablis.
Future<void> annulerTransfertsCaisse(
  BuildContext context,
  WidgetRef ref,
  List<TransfertCaisse> choix,
  VoidCallback effacer,
) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(caisseServiceProvider);
  final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
  final blocages = {for (final t in choix) t.code: await service.blocageAnnulationTransfert(t)};
  if (!context.mounted) return;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.gcEntiteTransfert,
    entitePluriel: l10n.gcEntiteTransferts,
    motifRequis: true,
    elements: [
      for (final t in choix)
        DsElementLot(
          id: t.code,
          titre: t.code,
          sousTitre:
              '${caisses[t.caisseSource] ?? t.caisseSource} → ${caisses[t.caisseDestination] ?? t.caisseDestination}',
          meta: _da(ref, t.montant),
          motifBlocage: switch (blocages[t.code]) {
            null => null,
            ErreurCaisse.dejaAnnule => l10n.gcBloqueDejaAnnule,
            final e => messageErreurCaisse(l10n, e),
          },
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final codes = [
    for (final t in choix)
      if (blocages[t.code] == null) t.code,
  ];
  final ok = await executerCaisse(context, ref, l10n.gcTrfTitre, () => service.annulerTransferts(codes, motif: motif));
  effacer();
  if (ok && context.mounted) {
    afficherToast(context, titre: l10n.gcToastTransfertsAnnules, description: l10n.gcToastSoldesRetablis);
  }
}

// ———————————————————————————— Clôtures Z ————————————————————————————

/// Libellé localisé d'un mode de paiement (valeur stockée FR).
String libelleMode(BuildContext context, String mode) => libelleRef(context, Referentiel.modesPaiement, mode);

/// Nouvelle clôture Z (`ClotureZDialog`, 820 px) : caisse, période depuis la dernière clôture, totaux,
/// répartition des paiements, chaînage, confirmation explicite.
Future<void> afficherClotureZ(BuildContext context, WidgetRef ref, {String? caisseCode}) async {
  final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  if (!context.mounted || caisses.isEmpty) return;
  final z = await afficherDialog<Cloture>(
    context,
    builder: (_) => _ClotureZDialog(caisses: caisses, caisseInitiale: caisseCode ?? caisses.first.code),
  );
  rafraichirCaisse(ref);
  if (z == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  afficherToast(context, titre: l10n.gcZCreee(z.code), description: l10n.gcZCreeeDetail);
}

class _ClotureZDialog extends ConsumerStatefulWidget {
  const _ClotureZDialog({required this.caisses, required this.caisseInitiale});
  final List<Caisse> caisses;
  final String caisseInitiale;

  @override
  ConsumerState<_ClotureZDialog> createState() => _ClotureZDialogState();
}

class _ClotureZDialogState extends ConsumerState<_ClotureZDialog> {
  late String _caisse = widget.caisseInitiale;
  Cloture? _apercu;
  Cloture? _precedente;
  bool _confirme = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final service = ref.read(clotureServiceProvider);
    final code = _caisse;
    final apercu = await service.apercu(caisseCode: code);
    final precedente = await service.derniere(code);
    if (!mounted || code != _caisse) return;
    setState(() {
      _apercu = apercu;
      _precedente = precedente;
    });
  }

  Future<void> _creer() async {
    final l10n = AppLocalizations.of(context);
    try {
      final z = await ref.read(clotureServiceProvider).cloturer(caisseCode: _caisse);
      if (mounted) Navigator.of(context).pop(z);
    } on ClotureException catch (e) {
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.gcNouvelleClotureZ,
        message: messageErreurCloture(l10n, e.erreur),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final a = _apercu;
    final repartition = a?.encaissementsParMode.entries.toList() ?? const <MapEntry<String, double>>[];
    final total = repartition.fold(0.0, (x, e) => x + e.value);
    return DsDialog(
      titre: l10n.gcNouvelleClotureZ,
      iconeData: LucideIcons.fileLock2,
      description: l10n.gcZDescription,
      largeur: 820,
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('z_creer'),
          libelle: l10n.gcZCreer(a?.code ?? ''),
          icone: LucideIcons.lock,
          onPressed: _confirme && a != null ? _creer : null,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              Expanded(
                child: DsFormRow(
                  libelle: l10n.gcColCaisse,
                  obligatoire: true,
                  largeurLibelle: 80,
                  child: DsSelect<String>(
                    cle: const ValueKey('z_caisse'),
                    valeur: _caisse,
                    options: [for (final c in widget.caisses) c.code],
                    libelle: (code) => widget.caisses.firstWhere((c) => c.code == code).nom,
                    recherche: rechercheListe(context, ref, ListeMetier.caisse),
                    onChanged: (v) {
                      if (v == null || v == _caisse) return;
                      setState(() {
                        _caisse = v;
                        _apercu = null;
                        _confirme = false;
                      });
                      _charger();
                    },
                  ),
                ),
              ),
              Expanded(
                child: DsFormRow(
                  libelle: l10n.cloturePeriode,
                  largeurLibelle: 80,
                  aide: _precedente == null ? l10n.gcZPremiere : l10n.gcZDepuisDerniere(_precedente!.code),
                  child: DsTextField(
                    key: ValueKey('z_periode_${a?.debut}'),
                    valeurInitiale: a == null
                        ? ''
                        : l10n.gcZPeriodeValeur(a.debut.year <= 1970 ? '—' : formatDateHeure.format(a.debut)),
                    actif: false,
                  ),
                ),
              ),
            ],
          ),
          DsStatsStrip(
            compact: true,
            items: [
              DsStatItem(libelle: l10n.gcColTickets, valeur: '${a?.nbVentes ?? 0}', icone: LucideIcons.receipt),
              DsStatItem(
                libelle: l10n.gcZTicketsAnnules,
                valeur: '${a?.nbAnnulations ?? 0}',
                icone: LucideIcons.ban,
                ton: DsBadgeTon.danger,
              ),
              DsStatItem(
                libelle: l10n.clotureColTotalVentes,
                valeur: f2(a?.totalVentes ?? 0),
                suffixe: devise,
                icone: LucideIcons.banknote,
                ton: DsBadgeTon.succes,
              ),
              DsStatItem(
                libelle: l10n.gcZTotalAnnule,
                valeur: f2(a?.totalAnnule ?? 0),
                suffixe: devise,
                icone: LucideIcons.circleX,
                ton: DsBadgeTon.avertissement,
              ),
            ],
          ),
          DsDataTable<MapEntry<String, double>>(
            dense: true,
            pagine: false,
            afficherTotaux: true,
            hauteurMax: 260,
            cle: (e) => e.key,
            lignes: repartition,
            messageVide: l10n.gcZAucunPaiement,
            colonnes: [
              DsColonne(
                id: 'mode',
                libelle: l10n.gcZMoyen,
                fort: true,
                flex: 2,
                valeur: (e) => libelleMode(context, e.key),
                total: (_) => l10n.communTotal,
              ),
              DsColonne(
                id: 'montant',
                libelle: l10n.retoursMontant,
                numerique: true,
                valeur: (e) => e.value,
                cellule: (_, e) => Text(formaterMontant(e.value, devise)),
                total: (_) => formaterMontant(total, devise),
              ),
              DsColonne(
                id: 'part',
                libelle: l10n.gcZPart,
                numerique: true,
                valeur: (e) => total <= 0 ? 0 : e.value / total,
                cellule: (_, e) => Text('${formaterNombre(total <= 0 ? 0 : e.value / total * 100, decimales: 1)} %'),
              ),
            ],
          ),
          _Encadre(
            icone: LucideIcons.link2,
            child: Row(
              spacing: 6,
              children: [
                Flexible(child: Text(_precedente == null ? l10n.gcZGenese : l10n.gcZChainee(_precedente!.code))),
                Text(
                  empreinteCourte(_precedente?.hash ?? Scellement.genese),
                  style: context.ds.typo.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.ds.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          DsCheckbox(
            cle: const ValueKey('z_confirmer'),
            valeur: _confirme,
            libelle: l10n.gcZConfirmer,
            onChanged: a == null ? null : (v) => setState(() => _confirme = v),
          ),
        ],
      ),
    );
  }
}

/// Empreinte abrégée (`9f3a…c71e`).
String empreinteCourte(String hash) =>
    hash.length <= 12 ? hash : '${hash.substring(0, 4)}…${hash.substring(hash.length - 4)}';

/// Nom affiché de la caisse d'une clôture (les clôtures globales antérieures à la v16 couvrent toutes les caisses).
String nomCaisseCloture(AppLocalizations l10n, Cloture z, Map<String, String> caisses) =>
    z.caisseCode == null ? l10n.gcToutesCaisses : (caisses[z.caisseCode] ?? z.caisseCode!);

/// TVA d'une clôture Z par taux : ventes validées de la période de la caisse, retours clients déduits.
Future<List<({double taux, double ht, double tva})>> tvaCloture(WidgetRef ref, Cloture z) async {
  final g = await FiscaliteRepository(ref.read(appDatabaseProvider).db)
      .g50(z.debut.add(const Duration(microseconds: 1)), z.fin, caisseCode: z.caisseCode);
  return [
    for (final t in g.taux)
      (
        taux: t,
        ht: (g.ventes[t]?.ht ?? 0) - (g.retoursClients[t]?.ht ?? 0),
        tva: (g.ventes[t]?.tva ?? 0) - (g.retoursClients[t]?.tva ?? 0),
      ),
  ];
}

String _pct(double t) => '${t == t.roundToDouble() ? t.toInt() : t} %';

/// Détail d'une clôture Z (`ClotureZDetail`, 940 px) : totaux, répartition, TVA, intégrité, PDF.
Future<void> afficherDetailCloture(BuildContext context, WidgetRef ref, Cloture z) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  final tva = await tvaCloture(ref, z);
  if (!context.mounted) return;
  final valide = Scellement.hacher(z.versCanonique(), z.hashPrecedent) == z.hash;
  final repartition = z.encaissementsParMode.entries.toList();
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 940,
      icone: LucideIcons.fileLock2,
      titre: l10n.gcZDetailTitre(z.code),
      description: l10n.gcZDetailDescription(
        formatJourHeure.format(z.fin),
        nomCaisseCloture(l10n, z, caisses),
        formatJourHeure.format(z.debut),
        utilisateurs[z.utilisateurCode] ?? z.utilisateurCode,
      ),
      badges: [
        DsBadge(libelle: l10n.gcZDefinitive, ton: DsBadgeTon.primaire, icone: LucideIcons.lock),
        DsBadge(
          libelle: valide ? l10n.gcZEmpreinteValide : l10n.gcZEmpreinteAlteree,
          ton: valide ? DsBadgeTon.succes : DsBadgeTon.danger,
          icone: valide ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
        ),
      ],
      piedSupplementaire: [
        DsButton(
          key: const ValueKey('z_pdf'),
          libelle: 'PDF',
          icone: LucideIcons.fileDown,
          variante: DsButtonVariante.secondaire,
          onPressed: () => imprimerCloture(context, ref, z),
        ),
      ],
      stats: [
        DsStatItem(libelle: l10n.gcColTickets, valeur: '${z.nbVentes}', icone: LucideIcons.receipt),
        DsStatItem(
          libelle: l10n.gcColAnnules,
          valeur: '${z.nbAnnulations}',
          icone: LucideIcons.ban,
          ton: DsBadgeTon.danger,
        ),
        DsStatItem(
          libelle: l10n.clotureColTotalVentes,
          valeur: f2(z.totalVentes),
          suffixe: devise,
          icone: LucideIcons.banknote,
          ton: DsBadgeTon.succes,
        ),
        DsStatItem(
          libelle: l10n.gcZTotalAnnule,
          valeur: f2(z.totalAnnule),
          suffixe: devise,
          icone: LucideIcons.circleX,
          ton: DsBadgeTon.avertissement,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.gcZRepartition,
          icone: LucideIcons.chartPie,
          nbLignes: repartition.length,
          tableau: DsDataTable<MapEntry<String, double>>(
            dense: true,
            encadre: false,
            pagine: false,
            cle: (e) => e.key,
            lignes: repartition,
            messageVide: l10n.gcZAucunPaiement,
            colonnes: [
              DsColonne(
                id: 'mode',
                libelle: l10n.gcZMoyen,
                fort: true,
                flex: 2,
                valeur: (e) => libelleMode(context, e.key),
              ),
              DsColonne(
                id: 'montant',
                libelle: l10n.retoursMontant,
                numerique: true,
                valeur: (e) => e.value,
                cellule: (_, e) => Text(formaterMontant(e.value, devise)),
              ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.tvaRecapitulatif,
          icone: LucideIcons.percent,
          nbLignes: tva.length,
          tableau: DsDataTable<({double taux, double ht, double tva})>(
            dense: true,
            encadre: false,
            pagine: false,
            cle: (e) => '${e.taux}',
            lignes: tva,
            messageVide: l10n.dsAucunElement,
            afficherTotaux: true,
            colonnes: [
              DsColonne(
                id: 'taux',
                libelle: l10n.tvaTaux,
                fort: true,
                valeur: (e) => e.taux,
                cellule: (_, e) => Text(_pct(e.taux)),
              ),
              DsColonne(
                id: 'ht',
                libelle: l10n.tvaBaseHt,
                numerique: true,
                valeur: (e) => e.ht,
                cellule: (_, e) => Text(formaterMontant(e.ht, devise)),
                total: (ls) => formaterMontant(ls.fold(0.0, (s, e) => s + e.ht), devise),
              ),
              DsColonne(
                id: 'tva',
                libelle: l10n.tvaMontant,
                numerique: true,
                valeur: (e) => e.tva,
                cellule: (_, e) => Text(formaterMontant(e.tva, devise)),
                total: (ls) => formaterMontant(ls.fold(0.0, (s, e) => s + e.tva), devise),
              ),
              DsColonne(
                id: 'ttc',
                libelle: l10n.tvaTtc,
                numerique: true,
                valeur: (e) => e.ht + e.tva,
                cellule: (_, e) => Text(formaterMontant(e.ht + e.tva, devise)),
                total: (ls) => formaterMontant(ls.fold(0.0, (s, e) => s + e.ht + e.tva), devise),
              ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.gcZTotaux,
          icone: LucideIcons.calculator,
          items: [
            DsKeyValue(l10n.clotureColRemises, formaterMontant(z.totalRemises, devise)),
            DsKeyValue(l10n.clotureColRetours, formaterMontant(z.totalRetours, devise)),
            DsKeyValue(l10n.clotureColEncaissements, formaterMontant(z.totalEncaissements, devise)),
            DsKeyValue(l10n.clotureColDecaissements, formaterMontant(z.totalDecaissements, devise)),
            DsKeyValue(
              l10n.gcZSoldeFin,
              formaterMontant(z.soldesCaisses.values.fold(0.0, (x, v) => x + v), devise),
              fort: true,
            ),
            DsKeyValue(l10n.clotureDerniereVente, z.derniereVente ?? '—'),
          ],
        ),
        DsSectionDetail(
          titre: l10n.gcZIntegrite,
          icone: LucideIcons.link2,
          colonnesGrille: 1,
          items: [
            DsKeyValue(l10n.gcColEmpreinte, z.hash, mono: true),
            DsKeyValue(l10n.gcZEmpreintePrecedente, z.hashPrecedent, mono: true),
            DsKeyValue(l10n.gcColCreeLe, formatDateHeure.format(z.date)),
          ],
        ),
      ],
    ),
  );
}

/// PDF d'une clôture Z (aperçu d'impression).
Future<void> imprimerCloture(BuildContext context, WidgetRef ref, Cloture z) async {
  final l10n = AppLocalizations.of(context);
  final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
  if (!context.mounted) return;
  final caisse = nomCaisseCloture(l10n, z, caisses);
  final tva = await tvaCloture(ref, z);
  if (!context.mounted) return;
  final lignes = <List<Object?>>[
    [l10n.gcColCaisse, caisse],
    [l10n.dsDu, formatDateHeure.format(z.debut)],
    [l10n.dsAu, formatDateHeure.format(z.fin)],
    [l10n.gcColTickets, '${z.nbVentes}'],
    [l10n.gcZTicketsAnnules, '${z.nbAnnulations}'],
    [l10n.clotureColTotalVentes, f2(z.totalVentes)],
    [l10n.gcZTotalAnnule, f2(z.totalAnnule)],
    [l10n.clotureColRemises, f2(z.totalRemises)],
    [l10n.clotureColRetours, f2(z.totalRetours)],
    for (final e in z.encaissementsParMode.entries)
      ['${l10n.gcZRepartition} · ${libelleMode(context, e.key)}', f2(e.value)],
    [l10n.clotureColEncaissements, f2(z.totalEncaissements)],
    [l10n.clotureColDecaissements, f2(z.totalDecaissements)],
    for (final t in tva) ...[
      ['${l10n.tvaBaseHt} ${_pct(t.taux)}', f2(t.ht)],
      ['${l10n.tvaMontant} ${_pct(t.taux)}', f2(t.tva)],
    ],
    [l10n.gcColEmpreinte, z.hash],
    [l10n.gcZEmpreintePrecedente, z.hashPrecedent],
  ];
  return exporterRapport(
    context,
    ref,
    Rapport(
      id: 'cloture_${z.code}',
      titre: '${l10n.gcZDetailTitre(z.code)} · $caisse',
      colonnes: [RapportColonne(l10n.cloturePeriode, flex: 2), RapportColonne(l10n.retoursMontant, flex: 3)],
      lignes: lignes,
    ),
    DsFormatExport.pdf,
  );
}

// ———————————————————————————— Export contrôle fiscal ————————————————————————————

enum _FormatFiscal { zip, json, pdf, csv, g50 }

/// Export pour contrôle fiscal (`ExportFiscalDialog`, 760 px) : période, format, état de la chaîne.
Future<void> afficherExportFiscal(BuildContext context, WidgetRef ref) async {
  final clotures = await ref.read(cloturesProvider.future);
  if (!context.mounted) return;
  await afficherDialog<void>(context, builder: (_) => _ExportFiscalDialog(clotures: clotures));
}

class _ExportFiscalDialog extends ConsumerStatefulWidget {
  const _ExportFiscalDialog({required this.clotures});
  final List<Cloture> clotures;

  @override
  ConsumerState<_ExportFiscalDialog> createState() => _ExportFiscalDialogState();
}

class _ExportFiscalDialogState extends ConsumerState<_ExportFiscalDialog> {
  late DsPeriode _periode = () {
    final n = DateTime.now();
    return DsPeriode(du: DateTime(n.year), au: DateTime(n.year, n.month, n.day));
  }();
  _FormatFiscal _format = _FormatFiscal.zip;

  Future<void> _generer() async {
    final l10n = AppLocalizations.of(context);
    final du = DateTime(_periode.du.year, _periode.du.month, _periode.du.day);
    final au = DateTime(_periode.au.year, _periode.au.month, _periode.au.day, 23, 59, 59);
    if (au.isBefore(du)) {
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.gcFiscalTitre,
        message: l10n.exportFiscalErreurDates,
      );
      return;
    }
    if (_format == _FormatFiscal.pdf) {
      final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
      final zs = widget.clotures.where((z) => !z.fin.isBefore(du) && !z.fin.isAfter(au)).toList().reversed.toList();
      if (!mounted) return;
      await exporterTableau(
        context,
        ref,
        id: 'clotures_z',
        titre: l10n.gcOngletClotures,
        colonnes: colonnesClotures(l10n, ref.read(deviseProvider), caisses, const {}),
        lignes: zs,
        format: DsFormatExport.pdf,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (_format == _FormatFiscal.g50) {
      final jour = DateFormat('yyyyMMdd');
      final nom = 'G50_${jour.format(du)}_${jour.format(au)}.xlsx';
      final chemin = await ref.read(selecteurExportProvider)(nom);
      if (chemin == null || !mounted) return;
      final db = ref.read(appDatabaseProvider).db;
      final boutique = await BoutiqueRepository(db).lire();
      final octets = ExportG50.generer(
        await FiscaliteRepository(db).g50(du, au),
        nomBoutique: boutique?.nom ?? '',
        nif: boutique?.nif ?? '',
      );
      await ref.read(ecrivainExportProvider)(chemin, octets);
      await ref.read(journalServiceProvider).export(id: 'g50', format: 'XLSX', fichier: nom);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(context, titre: l10n.gcFiscalGenere, description: nom);
      return;
    }
    final ext = switch (_format) {
      _FormatFiscal.json => 'json',
      _FormatFiscal.csv => 'csv',
      _ => 'zip',
    };
    final jour = DateFormat('yyyyMMdd');
    final nom = 'controle_fiscal_${jour.format(du)}_${jour.format(au)}.$ext';
    final chemin = await ref.read(selecteurExportProvider)(nom);
    if (chemin == null || !mounted) return;
    final export = ExportFiscal(ref.read(appDatabaseProvider).db);
    final utilisateur = ref.read(utilisateurCourantCodeProvider);
    final Uint8List octets = switch (_format) {
      _FormatFiscal.json => await export.genererJson(debut: du, fin: au, utilisateurCode: utilisateur),
      _FormatFiscal.csv => await export.genererCsv(debut: du, fin: au, utilisateurCode: utilisateur),
      _ => await export.generer(debut: du, fin: au, utilisateurCode: utilisateur),
    };
    await ref.read(ecrivainExportProvider)(chemin, octets);
    await ref.read(journalServiceProvider).export(id: 'controle_fiscal', format: ext.toUpperCase(), fichier: nom);
    final verif = _format == _FormatFiscal.csv ? null : ExportFiscal.verifier(octets);
    if (!mounted) return;
    if (verif != null && !verif.valide) {
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.gcFiscalTitre,
        message: l10n.exportFiscalVerifKo(verif.erreurs.join(', ')),
      );
      return;
    }
    Navigator.of(context).pop();
    afficherToast(context, titre: l10n.gcFiscalGenere, description: nom);
  }

  Future<void> _verifierArchive() async {
    final l10n = AppLocalizations.of(context);
    final f = await ref.read(selecteurArchiveProvider)();
    if (f == null) return;
    final verif = ExportFiscal.verifier(await f.readAsBytes());
    if (!mounted) return;
    await afficherResultat(
      context,
      type: verif.valide ? DsResultatType.succes : DsResultatType.erreur,
      titre: l10n.exportFiscalVerifier,
      message: verif.valide
          ? l10n.exportFiscalVerifOk(verif.nbVentes, verif.nbClotures)
          : l10n.exportFiscalVerifKo(verif.erreurs.join(', ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rupture = Cloture.verifierChaines(widget.clotures.reversed);
    return DsDialog(
      titre: l10n.gcFiscalTitre,
      iconeData: LucideIcons.landmark,
      description: l10n.gcFiscalDescription,
      largeur: 760,
      piedDebut: DsButton(
        key: const ValueKey('fiscal_verifier'),
        libelle: l10n.exportFiscalVerifier,
        icone: LucideIcons.fileCheck,
        variante: DsButtonVariante.fantome,
        onPressed: _verifierArchive,
      ),
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('fiscal_generer'),
          libelle: l10n.exportFiscalGenerer,
          icone: LucideIcons.download,
          onPressed: _generer,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsPeriodeLocalisee(periode: _periode, onChanged: (p) => setState(() => _periode = p)),
          DsChoiceCards<_FormatFiscal>(
            petit: true,
            colonnes: 2,
            valeur: _format,
            onChanged: (f) => setState(() => _format = f),
            options: [
              DsOption(
                _FormatFiscal.zip,
                libelle: l10n.gcFiscalZip,
                icone: LucideIcons.fileArchive,
                description: l10n.gcFiscalZipDesc,
              ),
              DsOption(
                _FormatFiscal.json,
                libelle: l10n.gcFiscalJson,
                icone: LucideIcons.fileJson,
                description: l10n.gcFiscalJsonDesc,
              ),
              DsOption(
                _FormatFiscal.pdf,
                libelle: l10n.gcFiscalPdf,
                icone: LucideIcons.fileText,
                description: l10n.gcFiscalPdfDesc,
              ),
              DsOption(
                _FormatFiscal.csv,
                libelle: l10n.gcFiscalCsv,
                icone: LucideIcons.fileSpreadsheet,
                description: l10n.gcFiscalCsvDesc,
              ),
              DsOption(
                _FormatFiscal.g50,
                libelle: l10n.exportFiscalG50,
                icone: LucideIcons.receiptText,
                description: l10n.exportFiscalG50Desc,
              ),
            ],
          ),
          _Encadre(
            icone: rupture == null ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
            ton: rupture == null ? DsBadgeTon.succes : DsBadgeTon.danger,
            child: Text(
              rupture == null ? l10n.gcFiscalChaineOk(widget.clotures.length) : l10n.gcFiscalChaineKo(rupture),
              key: const ValueKey('fiscal_chaine'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colonnes du tableau des clôtures Z (onglet et rapport PDF).
List<DsColonne<Cloture>> colonnesClotures(
  AppLocalizations l10n,
  String devise,
  Map<String, String> caisses,
  Map<String, String> utilisateurs,
) => [
  DsColonne(id: 'code', libelle: l10n.produitsColCode, fort: true, valeur: (z) => z.code),
  DsColonne(id: 'caisse', libelle: l10n.gcColCaisse, valeur: (z) => nomCaisseCloture(l10n, z, caisses)),
  DsColonne(
    id: 'du',
    libelle: l10n.dsDu,
    attenue: true,
    valeur: (z) => z.debut,
    cellule: (_, z) => Text(z.debut.year <= 1970 ? '—' : formatJourHeure.format(z.debut)),
  ),
  DsColonne(
    id: 'au',
    libelle: l10n.dsAu,
    attenue: true,
    valeur: (z) => z.fin,
    cellule: (_, z) => Text(formatJourHeure.format(z.fin)),
  ),
  DsColonne(
    id: 'tickets',
    libelle: l10n.gcColTickets,
    numerique: true,
    valeur: (z) => z.nbVentes,
    total: (zs) => '${zs.fold(0, (x, z) => x + z.nbVentes)}',
  ),
  DsColonne(
    id: 'annules',
    libelle: l10n.gcColAnnules,
    numerique: true,
    visibleParDefaut: false,
    valeur: (z) => z.nbAnnulations,
  ),
  DsColonne(
    id: 'ventes',
    libelle: l10n.clotureColTotalVentes,
    numerique: true,
    valeur: (z) => z.totalVentes,
    cellule: (_, z) => Text(formaterMontant(z.totalVentes, devise)),
    total: (zs) => formaterMontant(zs.fold(0.0, (x, z) => x + z.totalVentes), devise),
  ),
  DsColonne(
    id: 'annule',
    libelle: l10n.gcColTotalAnnule,
    numerique: true,
    visibleParDefaut: false,
    valeur: (z) => z.totalAnnule,
    cellule: (_, z) => Text(z.totalAnnule > 0 ? formaterMontant(z.totalAnnule, devise) : '—'),
  ),
  DsColonne(id: 'par', libelle: l10n.gcColPar, valeur: (z) => utilisateurs[z.utilisateurCode] ?? z.utilisateurCode),
  DsColonne(
    id: 'hash',
    libelle: l10n.gcColEmpreinte,
    attenue: true,
    visibleParDefaut: false,
    valeur: (z) => empreinteCourte(z.hash),
  ),
  DsColonne(
    id: 'cree',
    libelle: l10n.gcColCreeLe,
    attenue: true,
    visibleParDefaut: false,
    valeur: (z) => z.date,
    cellule: (_, z) => Text(formatDateHeure.format(z.date)),
  ),
];

// ———————————————————————————— Sessions ————————————————————————————

/// Mouvements d'une session (`SessionMouvementsDialog`, 1000 px) : entrées, sorties, solde.
Future<void> afficherMouvementsSession(BuildContext context, WidgetRef ref, SessionCaisse s) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final caisses = {for (final c in await ref.read(caissesListeProvider.future)) c.code: c.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  final sessions = await ref.read(sessionsCaisseProvider.future);
  final mouvements = (await ref.read(mouvementsCaisseProvider.future))
      .where((m) => sessionDuMouvement(m, sessions) == s.code)
      .toList();
  if (!context.mounted) return;
  final entrees = mouvements.where((m) => m.sens == SensMouvementCaisse.entree).fold(0.0, (x, m) => x + m.montant);
  final sorties = mouvements.where((m) => m.sens != SensMouvementCaisse.entree).fold(0.0, (x, m) => x + m.montant);
  final caisse = caisses[s.caisseCode] ?? s.caisseCode;
  final colonnes = colonnesMouvements(l10n, devise, caisses, utilisateurs, avecCaisse: false);
  await afficherDialog<void>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.gcSesMvtTitre(s.code),
      iconeData: LucideIcons.list,
      description: s.fermeeLe == null
          ? l10n.gcSesMvtOuverte(caisse, formatJourHeure.format(s.ouverteLe))
          : l10n.gcSesMvtCloturee(caisse, formatJourHeure.format(s.fermeeLe!), formatJourHeure.format(s.ouverteLe)),
      largeur: 1000,
      piedDebut: peutExporter(ref)
          ? DsExportMenu(
              total: mouvements.length,
              onExport: (format, _) => exporterTableau(
                ctx,
                ref,
                id: 'mouvements_${s.code}',
                titre: l10n.gcSesMvtTitre(s.code),
                colonnes: colonnes,
                lignes: mouvements,
                format: format,
              ),
            )
          : null,
      actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop())],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DsStatsStrip(
            compact: true,
            items: [
              DsStatItem(
                libelle: l10n.gcEntrees,
                valeur: f2(entrees),
                suffixe: devise,
                icone: LucideIcons.arrowDownLeft,
                ton: DsBadgeTon.succes,
              ),
              DsStatItem(
                libelle: l10n.gcSorties,
                valeur: f2(sorties),
                suffixe: devise,
                icone: LucideIcons.arrowUpRight,
                ton: DsBadgeTon.danger,
              ),
              DsStatItem(
                libelle: l10n.gcSolde,
                valeur: f2(entrees - sorties),
                suffixe: devise,
                icone: LucideIcons.scale,
              ),
            ],
          ),
          DsDataTable<MouvementCaisse>(
            dense: true,
            pagine: false,
            afficherTotaux: true,
            hauteurMax: 380,
            cle: (m) => m.id ?? m.hashCode,
            lignes: mouvements,
            messageVide: l10n.mouvementAucun,
            colonnes: colonnes,
          ),
        ],
      ),
    ),
  );
}

/// Colonnes du grand-livre de caisse (onglet Mouvements et mouvements d'une session).
List<DsColonne<MouvementCaisse>> colonnesMouvements(
  AppLocalizations l10n,
  String devise,
  Map<String, String> caisses,
  Map<String, String> utilisateurs, {
  bool avecCaisse = true,
  String? Function(MouvementCaisse m)? session,
}) {
  final entree = SensMouvementCaisse.entree;
  return [
    DsColonne(
      id: 'date',
      libelle: l10n.communDate,
      attenue: true,
      valeur: (m) => m.date,
      cellule: (_, m) => Text(formatJourHeure.format(m.date)),
    ),
    if (avecCaisse)
      DsColonne(id: 'caisse', libelle: l10n.gcColCaisse, valeur: (m) => caisses[m.caisseCode] ?? m.caisseCode),
    if (session != null)
      DsColonne(id: 'session', libelle: l10n.gcColSession, attenue: true, valeur: (m) => session(m) ?? '—'),
    DsColonne(
      id: 'type',
      libelle: l10n.caisseType,
      fort: true,
      valeur: (m) => libelleTypeMouvementCaisse(l10n, m.type),
    ),
    DsColonne(id: 'ref', libelle: l10n.gcColReference, attenue: true, valeur: (m) => m.referenceCode ?? '—'),
    DsColonne(
      id: 'entree',
      libelle: l10n.gcColEntree,
      numerique: true,
      valeur: (m) => m.sens == entree ? m.montant : 0,
      cellule: (ctx, m) => m.sens == entree
          ? Text(formaterMontant(m.montant, devise), style: TextStyle(color: ctx.ds.colors.successFg))
          : const Text('—'),
      total: (ms) => formaterMontant(ms.where((m) => m.sens == entree).fold(0.0, (x, m) => x + m.montant), devise),
    ),
    DsColonne(
      id: 'sortie',
      libelle: l10n.gcColSortie,
      numerique: true,
      valeur: (m) => m.sens == entree ? 0 : m.montant,
      cellule: (ctx, m) => m.sens != entree
          ? Text(formaterMontant(m.montant, devise), style: TextStyle(color: ctx.ds.colors.dangerFg))
          : const Text('—'),
      total: (ms) => formaterMontant(ms.where((m) => m.sens != entree).fold(0.0, (x, m) => x + m.montant), devise),
    ),
    DsColonne(
      id: 'utilisateur',
      libelle: l10n.gcColUtilisateur,
      valeur: (m) => utilisateurs[m.utilisateurCode] ?? m.utilisateurCode,
    ),
    DsColonne(id: 'mode', libelle: l10n.gcColMode, visibleParDefaut: false, valeur: (m) => m.mode),
    DsColonne(id: 'obs', libelle: l10n.retoursObservation, visibleParDefaut: false, valeur: (m) => m.commentaire ?? ''),
  ];
}
