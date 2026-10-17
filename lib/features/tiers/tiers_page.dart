import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/referentiel/referentiel.dart';
import '../../domain/referentiel/wilayas.dart';
import '../commun/colonnes_audit.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import 'tiers_dialogs.dart';
import 'tiers_providers.dart';
import 'versements_onglet.dart';

/// Écrans Clients et Fournisseurs (`ClientsScreen`, `FournisseursScreen` du DS v2.2) :
/// onglet du tiers (KPIs, filtres Type / Wilaya / Crédit, tableau, actions) et onglet Versements.
class TiersPage extends ConsumerStatefulWidget {
  const TiersPage({super.key, required this.type, this.ongletInitial = 0});

  /// [TypesTiers.client] ou [TypesTiers.fournisseur].
  final String type;

  /// 0 = liste des tiers, 1 = versements.
  final int ongletInitial;

  @override
  ConsumerState<TiersPage> createState() => _TiersPageState();
}

class _TiersPageState extends ConsumerState<TiersPage> {
  late int _onglet = widget.ongletInitial;
  String? _typeTiers;
  String? _wilaya;
  DsIntervalle _credit = const DsIntervalle();

  bool get _client => widget.type == TypesTiers.client;

  List<LigneTiers> _lignes() {
    if (_client) {
      final stats = ref.watch(statsClientsProvider).value ?? const {};
      return [
        for (final c in ref.watch(clientsProvider).value ?? const <Client>[])
          LigneTiers.client(c, stats[c.code] ?? StatsTiers.vide),
      ];
    }
    final stats = ref.watch(statsFournisseursProvider).value ?? const {};
    return [
      for (final f in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        LigneTiers.fournisseur(f, stats[f.code] ?? StatsTiers.vide),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tous = _lignes();
    final nbVersements = (ref.watch(versementsProvider).value ?? const <Versement>[])
        .where((v) => v.tiersType == widget.type && v.mode != 'Avoir')
        .length;
    final avecCredit = tous.where((t) => t.stats.credit > 0.004).length;
    return PageModule(
      moduleId: _client ? 'clients' : 'fournisseurs',
      sousTitre: _client
          ? l10n.tiersDescriptionClients(tous.length, avecCredit)
          : l10n.tiersDescriptionFournisseurs(tous.length, avecCredit),
      onglets: [_client ? l10n.moduleClients : l10n.moduleFournisseurs, l10n.moduleVersements],
      comptes: [tous.length, nbVersements],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: _onglet == 0
          ? _tableauTiers(context, l10n, tous)
          : VersementsOnglet(key: ValueKey('versements_${widget.type}'), tiersType: widget.type, tiers: tous),
    );
  }

  Widget _tableauTiers(BuildContext context, AppLocalizations l10n, List<LigneTiers> tous) {
    final devise = ref.watch(deviseProvider);
    String da(double v) => formaterMontant(v, devise);
    final lignes = tous
        .where(
          (t) =>
              (_typeTiers == null || t.fiche.type == _typeTiers) &&
              (_wilaya == null || t.fiche.wilaya == _wilaya) &&
              (_credit.min == null || t.stats.credit >= _credit.min!) &&
              (_credit.max == null || t.stats.credit <= _credit.max!),
        )
        .toList();
    final types = _client ? Referentiel.typesClient : Referentiel.typesFournisseur;
    double somme(Iterable<LigneTiers> ls, double Function(StatsTiers) f) => ls.fold(0.0, (s, t) => s + f(t.stats));

    final colonnes = <DsColonne<LigneTiers>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (t) => t.code, attenue: true),
      DsColonne(
        id: 'nom',
        libelle: _client ? l10n.tiersEntiteClientMaj : l10n.tiersEntiteFournisseurMaj,
        valeur: (t) => t.nom,
        fort: true,
        flex: 2,
        cellule: (_, t) => Row(
          spacing: 10,
          children: [
            DsAvatar(nom: t.nom, taille: 28),
            Flexible(child: Text(t.nom, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      DsColonne(id: 'tel', libelle: l10n.clientTelephone, valeur: (t) => t.telephone, attenue: true),
      DsColonne(
        id: 'type',
        libelle: l10n.tiersType,
        valeur: (t) => libelleRef(context, t.listeTypes, t.fiche.type),
        cellule: (_, t) => t.fiche.type.isEmpty
            ? const Text('—')
            : DsBadge(libelle: libelleRef(context, t.listeTypes, t.fiche.type), ton: tonTypeTiers(t.fiche.type)),
      ),
      DsColonne(
        id: 'wilaya',
        libelle: l10n.tiersWilaya,
        valeur: (t) => t.fiche.wilaya.isEmpty ? '' : libelleRef(context, wilayas, t.fiche.wilaya),
      ),
      DsColonne(
        id: 'achats',
        libelle: l10n.tiersTotalAchats,
        numerique: true,
        valeur: (t) => t.stats.achats,
        cellule: (_, t) => Text(da(t.stats.achats)),
        total: (ls) => da(somme(ls, (s) => s.achats)),
      ),
      if (!_client)
        DsColonne(
          id: 'paye',
          libelle: l10n.tiersTotalPaye,
          numerique: true,
          valeur: (t) => t.stats.paye,
          cellule: (_, t) => Text(da(t.stats.paye)),
          total: (ls) => da(somme(ls, (s) => s.paye)),
        ),
      DsColonne(
        id: 'credit',
        libelle: l10n.tiersCredit,
        numerique: true,
        valeur: (t) => t.stats.credit,
        cellule: (context, t) => t.stats.credit > 0.004
            ? Text(
                da(t.stats.credit),
                style: TextStyle(fontWeight: FontWeight.w600, color: context.ds.colors.dangerFg),
              )
            : const Text('—'),
        total: (ls) => da(somme(ls, (s) => s.credit)),
      ),
      DsColonne(
        id: 'dernier',
        libelle: _client ? l10n.tiersDernierAchat : l10n.tiersDerniereEntree,
        valeur: (t) => t.stats.dernier,
        attenue: true,
        cellule: (_, t) => Text(dateOuTiret(t.stats.dernier)),
      ),
      DsColonne(
        id: 'etat',
        libelle: l10n.tiersEtat,
        valeur: (t) => t.actif ? 1 : 0,
        cellule: (_, t) => BadgeStatut(t.actif ? 'actif' : 'inactif'),
      ),
      if (_client)
        DsColonne(
          id: 'points',
          libelle: l10n.clientPoints,
          numerique: true,
          visibleParDefaut: false,
          valeur: (t) => t.points,
        ),
      DsColonne(id: 'adresse', libelle: l10n.clientAdresse, visibleParDefaut: false, valeur: (t) => t.adresse),
      DsColonne(id: 'activite', libelle: l10n.tiersActivite, visibleParDefaut: false, valeur: (t) => t.fiche.activite),
      DsColonne(id: 'email', libelle: l10n.clientEmail, visibleParDefaut: false, valeur: (t) => t.email),
      DsColonne(id: 'fax', libelle: l10n.tiersFax, visibleParDefaut: false, valeur: (t) => t.fiche.fax),
      DsColonne(id: 'nif', libelle: 'NIF', visibleParDefaut: false, valeur: (t) => t.fiche.nif),
      DsColonne(id: 'nis', libelle: 'NIS', visibleParDefaut: false, valeur: (t) => t.fiche.nis),
      DsColonne(id: 'nrc', libelle: l10n.tiersNrc, visibleParDefaut: false, valeur: (t) => t.fiche.nrc),
      DsColonne(id: 'rib', libelle: 'RIB', visibleParDefaut: false, valeur: (t) => t.fiche.rib),
      DsColonne(id: 'banque', libelle: l10n.tiersBanque, visibleParDefaut: false, valeur: (t) => t.fiche.banque),
      DsColonne(id: 'obs', libelle: l10n.tiersObservation, visibleParDefaut: false, valeur: (t) => t.fiche.observation),
      ...colonnesAudit(context, ref, (LigneTiers x) => x.audit),
    ];

    final actifs = tous.where((t) => t.actif);
    final kpis = _client
        ? [
            DsStatCard(libelle: l10n.tiersKpiClientsActifs, valeur: '${actifs.length}', icone: LucideIcons.users),
            DsStatCard(
              libelle: l10n.tiersTotalAchats,
              valeur: f2(somme(tous, (s) => s.achats)),
              suffixe: devise,
              icone: LucideIcons.shoppingCart,
            ),
            DsStatCard(
              libelle: l10n.tiersKpiCreditClients,
              valeur: f2(somme(tous, (s) => s.credit)),
              suffixe: devise,
              icone: LucideIcons.handCoins,
            ),
            DsStatCard(
              libelle: l10n.tiersKpiPoints,
              valeur: '${tous.fold(0, (s, t) => s + t.points)}',
              icone: LucideIcons.star,
            ),
          ]
        : [
            DsStatCard(libelle: l10n.tiersKpiFournisseursActifs, valeur: '${actifs.length}', icone: LucideIcons.truck),
            DsStatCard(
              libelle: l10n.tiersTotalAchats,
              valeur: f2(somme(tous, (s) => s.achats)),
              suffixe: devise,
              icone: LucideIcons.shoppingCart,
            ),
            DsStatCard(
              libelle: l10n.tiersTotalPaye,
              valeur: f2(somme(tous, (s) => s.paye)),
              suffixe: devise,
              icone: LucideIcons.banknote,
            ),
            DsStatCard(
              libelle: l10n.tiersKpiCreditFournisseurs,
              valeur: f2(somme(tous, (s) => s.credit)),
              suffixe: devise,
              icone: LucideIcons.handCoins,
            ),
          ];

    Future<void> modifier(LigneTiers t) => afficherFormulaireTiers(context, ref, type: widget.type, tiers: t);
    Future<void> situation(LigneTiers t) => afficherSituationTiers(context, ref, t);
    Future<void> versement(LigneTiers t) =>
        afficherVersementTiers(context, ref, tiersType: widget.type, tiers: tous, beneficiaire: t);

    return DsModuleTable<LigneTiers>(
      key: ValueKey('tiers_${widget.type}'),
      entite: _client ? l10n.tiersEntiteClients : l10n.tiersEntiteFournisseurs,
      lignes: lignes,
      colonnes: colonnes,
      cle: (t) => t.code,
      afficherTotaux: true,
      filtresOuverts: true,
      kpis: kpis,
      indiceRecherche: l10n.tiersRechercheIndice,
      texteRecherche: (t) => '${t.nom} ${t.code} ${t.telephone}',
      nbFiltresActifs: (_typeTiers != null ? 1 : 0) + (_wilaya != null ? 1 : 0) + (_credit.estVide ? 0 : 1),
      onReinitialiser: () => setState(() {
        _typeTiers = null;
        _wilaya = null;
        _credit = const DsIntervalle();
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.tiersType,
          largeurLibelle: 60,
          child: DsSelectReferentiel(
            cle: const ValueKey('filtre_type_tiers'),
            liste: types,
            valeur: _typeTiers,
            placeholder: l10n.tiersTous,
            onChanged: (v) => setState(() => _typeTiers = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.tiersWilaya,
          largeurLibelle: 60,
          child: DsSelectReferentiel(
            liste: wilayas,
            valeur: _wilaya,
            placeholder: l10n.tiersToutes,
            onChanged: (v) => setState(() => _wilaya = v),
          ),
        ),
        DsFormRow(
          libelle: l10n.tiersCredit,
          largeurLibelle: 60,
          child: DsRangeFilter(
            valeur: _credit,
            unite: devise,
            libelleEffacer: l10n.dsEffacer,
            libelleValider: l10n.dsValider,
            onChanged: (v) => setState(() => _credit = v),
          ),
        ),
      ],
      onExport: peutExporter(ref)
          ? (format, ls) => exporterTableau(
              context,
              ref,
              id: _client ? 'clients' : 'fournisseurs',
              titre: _client ? l10n.moduleClients : l10n.moduleFournisseurs,
              colonnes: colonnes,
              lignes: ls,
              format: format,
            )
          : null,
      largeurMinCarte: 260,
      carte: (context, t, etatCarte) => _CarteTiers(
        key: ValueKey('carte_tiers_${t.code}'),
        etat: etatCarte,
        tiers: t,
        icone: _client ? LucideIcons.user : LucideIcons.truck,
        montantAchats: da(t.stats.achats),
        montantCredit: da(t.stats.credit),
      ),
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) {
            final t = choix.first;
            return afficherDetailTiers(
              context,
              ref,
              t,
              onModifier: () => modifier(t),
              onSituation: () => situation(t),
              onVersement: () => versement(t),
            );
          },
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          iconeSeule: true,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && choix.first.systeme,
          onPressed: (choix, _) => modifier(choix.first),
        ),
        DsActionModule(
          libelle: l10n.tiersSituation,
          icone: LucideIcons.scale,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => situation(choix.first),
        ),
        DsActionModule(
          libelle: l10n.tiersVersement,
          icone: LucideIcons.handCoins,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && choix.first.systeme,
          onPressed: (choix, _) => versement(choix.first),
        ),
        DsActionModule(
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.x,
          iconeSeule: true,
          danger: true,
          onPressed: (choix, effacer) => annulerTiers(context, ref, choix, effacer),
        ),
      ],
      primaire: DsButton(
        key: ValueKey(_client ? 'client_nouveau' : 'fournisseur_nouveau'),
        libelle: _client ? l10n.clientNouveau : l10n.fournisseurNouveau,
        icone: _client ? LucideIcons.userPlus : LucideIcons.plus,
        onPressed: () => afficherFormulaireTiers(context, ref, type: widget.type),
      ),
    );
  }
}

/// Écran Clients.
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key, this.ongletInitial = 0});
  final int ongletInitial;

  @override
  Widget build(BuildContext context) => TiersPage(type: TypesTiers.client, ongletInitial: ongletInitial);
}

/// Écran Fournisseurs.
class FournisseursPage extends StatelessWidget {
  const FournisseursPage({super.key, this.ongletInitial = 0});
  final int ongletInitial;

  @override
  Widget build(BuildContext context) => TiersPage(type: TypesTiers.fournisseur, ongletInitial: ongletInitial);
}

/// Carte d'un client ou d'un fournisseur (vue grille) : avatar à initiales, nom, téléphone, état, puis un bandeau
/// « Total achats » / « Crédit ».
class _CarteTiers extends StatelessWidget {
  const _CarteTiers({
    super.key,
    required this.etat,
    required this.tiers,
    required this.icone,
    required this.montantAchats,
    required this.montantCredit,
  });
  final DsEtatCarte etat;
  final LigneTiers tiers;
  final IconData icone;
  final String montantAchats;
  final String montantCredit;

  static String _initiales(String texte) {
    final mots = texte.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    return mots.take(2).map((m) => m.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final teinte = teintePour(tiers.nom);
    final enCredit = tiers.stats.credit > 0.004;
    Widget stat(String libelle, String valeur, {Color? couleur}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          libelle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.caption.copyWith(color: c.textMuted),
        ),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.bodySm.copyWith(fontWeight: FontWeight.w700, color: couleur ?? c.textPrimary),
        ),
      ],
    );
    return DsGridCard(
      etat: etat,
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: DsSpacing.s3,
          children: [
            Row(
              spacing: DsSpacing.s3,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(teinte.withValues(alpha: .16), c.surfaceCard),
                    shape: BoxShape.circle,
                  ),
                  child: tiers.systeme
                      ? Icon(icone, size: DsTailles.icone, color: teinte)
                      : Text(
                          _initiales(tiers.nom),
                          style: t.bodySm.copyWith(fontWeight: FontWeight.w700, color: teinte),
                        ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        tiers.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySm.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          Icon(LucideIcons.phone, size: 12, color: c.iconMuted),
                          Expanded(
                            child: Text(
                              tiers.telephone.isEmpty ? tiers.code : '${tiers.telephone} · ${tiers.code}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.caption.copyWith(color: c.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BadgeStatut(!tiers.actif ? 'inactif' : (enCredit ? 'credit' : 'actif'), petit: true),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: DsSpacing.s2),
              decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderMd),
              child: Row(
                spacing: DsSpacing.s3,
                children: [
                  Expanded(child: stat(l10n.tiersTotalAchats, montantAchats)),
                  Container(width: 1, height: 28, color: c.borderSubtle),
                  Expanded(child: stat(l10n.tiersCredit, montantCredit, couleur: enCredit ? c.dangerFg : c.successFg)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
