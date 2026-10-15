import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/retour_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/achat.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../caisse/caisse_dialogs.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../entrees/entrees_providers.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

/// Libellé d'un règlement de retour (client ou fournisseur).
String libelleReglementRetour(AppLocalizations l10n, String type, String reglement) => type == TypesTiers.client
    ? switch (reglement) {
        ReglementsRetour.avoir => l10n.retoursRegAvoir,
        ReglementsRetour.carte => l10n.retoursRegCarte,
        _ => l10n.retoursRegEspeces,
      }
    : (reglement == ReglementsRetour.avoir ? l10n.retoursRegDeduit : l10n.retoursRegRembEspeces);

/// Nom du tiers d'un retour.
String nomTiersRetour(AppLocalizations l10n, Retour r, Map<String, String> noms) =>
    r.estClient && r.clientCode == 'CLN0000' ? l10n.posClientPassage : (noms[r.tiersCode] ?? r.tiersCode);

/// Produit d'une pièce d'origine proposé au retour.
@immutable
class _LigneOrigine {
  const _LigneOrigine({
    required this.produitCode,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.prixAchat,
  });
  final String produitCode;
  final String nom;
  final double quantite;
  final double prix;
  final double prixAchat;
}

/// Formulaire de retour (`RetourFormDialog` du DS, 920 px) : création (client ou fournisseur) ou modification.
Future<void> afficherFormulaireRetour(
  BuildContext context,
  WidgetRef ref, {
  String type = TypesTiers.client,
  String? documentCode,
  Retour? retour,
}) async {
  if (retour == null && !await exigerSessionCaisse(context, ref)) return;
  if (!context.mounted) return;
  return afficherDialog<void>(
    context,
    builder: (_) => _FormulaireRetour(type: retour?.type ?? type, documentCode: documentCode, retour: retour),
  );
}

class _FormulaireRetour extends ConsumerStatefulWidget {
  const _FormulaireRetour({required this.type, this.documentCode, this.retour});
  final String type;
  final String? documentCode;
  final Retour? retour;

  @override
  ConsumerState<_FormulaireRetour> createState() => _FormulaireRetourState();
}

class _FormulaireRetourState extends ConsumerState<_FormulaireRetour> {
  late final String _type = widget.type;
  String? _tiers;
  String? _document;
  List<_LigneOrigine> _lignes = const [];
  Map<String, double> _deja = const {};
  String? _produit;
  late final _qte = TextEditingController(
    text: widget.retour == null ? '1' : formaterNombre(widget.retour!.quantite, grouper: false),
  );
  late final _serie = TextEditingController(text: widget.retour?.numeroSerie);
  late final _obs = TextEditingController(text: widget.retour?.motif);
  late DateTime _date = widget.retour?.date ?? DateTime.now();
  late String _reglement = widget.retour?.reglement ?? _reglementParDefaut(widget.type);
  late bool _remise = widget.retour?.remiseEnStock ?? true;
  String? _erreur;

  bool get _edition => widget.retour != null;
  bool get _client => _type == TypesTiers.client;

  static String _reglementParDefaut(String type) =>
      type == TypesTiers.client ? ReglementsRetour.especes : ReglementsRetour.avoir;

  @override
  void initState() {
    super.initState();
    final r = widget.retour;
    if (r != null) {
      _tiers = r.tiersCode;
      _produit = r.ligne?.produitCode;
      unawaited(_chargerDocument(r.documentCode));
    } else if (widget.documentCode != null) {
      unawaited(_chargerDocument(widget.documentCode!));
    }
  }

  @override
  void dispose() {
    _qte.dispose();
    _serie.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _chargerDocument(String code) async {
    final lignes = <_LigneOrigine>[];
    String? tiers;
    if (_client) {
      final v = await ref.read(venteRepositoryProvider).vente(code);
      if (v == null) return;
      tiers = v.clientCode;
      for (final l in v.lignes.where((l) => l.packCode == null || l.composantPack)) {
        if (lignes.any((x) => x.produitCode == l.produitCode)) continue;
        lignes.add(
          _LigneOrigine(
            produitCode: l.produitCode,
            nom: l.designation,
            quantite: l.quantite,
            prix: l.quantite == 0 ? 0 : l.total / l.quantite,
            prixAchat: l.prixAchat,
          ),
        );
      }
    } else {
      final a = await ref.read(achatServiceProvider).achat(code);
      if (a == null) return;
      tiers = a.fournisseurCode;
      for (final l in a.lignes) {
        final i = lignes.indexWhere((x) => x.produitCode == l.produitCode);
        if (i >= 0) {
          final x = lignes[i];
          final q = x.quantite + l.quantite;
          lignes[i] = _LigneOrigine(
            produitCode: x.produitCode,
            nom: x.nom,
            quantite: q,
            prix: q == 0 ? 0 : (x.prix * x.quantite + l.total) / q,
            prixAchat: q == 0 ? 0 : (x.prix * x.quantite + l.total) / q,
          );
        } else {
          lignes.add(
            _LigneOrigine(
              produitCode: l.produitCode,
              nom: l.designation,
              quantite: l.quantite,
              prix: l.prixAchat,
              prixAchat: l.prixAchat,
            ),
          );
        }
      }
    }
    final deja = await ref.read(tiersRepositoryProvider).quantitesRetournees(code, sauf: widget.retour?.code);
    if (!mounted) return;
    setState(() {
      _document = code;
      _tiers = tiers;
      _lignes = lignes;
      _deja = deja;
      if (!lignes.any((l) => l.produitCode == _produit)) {
        _produit = lignes.length == 1 ? lignes.first.produitCode : null;
      }
    });
  }

  Future<void> _choisirTiers() async {
    final l10n = AppLocalizations.of(context);
    if (_client) {
      final clients = (await ref.read(clientsProvider.future)).where((c) => c.actif);
      if (!mounted) return;
      final code = await choisirDansListe(
        context,
        ref,
        ListeMetier.client,
        codes: {for (final c in clients) c.code},
        valeur: _tiers,
        titre: l10n.tiersChoisirClient,
      );
      if (code != null) setState(() => _tiers = code);
    } else {
      final fournisseurs = (await ref.read(fournisseursProvider.future)).where((f) => f.actif);
      if (!mounted) return;
      final code = await choisirDansListe(
        context,
        ref,
        ListeMetier.fournisseur,
        codes: {for (final f in fournisseurs) f.code},
        valeur: _tiers,
        titre: l10n.tiersChoisirFournisseur,
      );
      if (code != null) setState(() => _tiers = code);
    }
  }

  Future<void> _choisirOrigine() async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final noms = _nomsTiers();
    String? code;
    if (_client) {
      final ventes = (await ref.read(ventesProvider.future)).where((v) => v.statut == StatutsVente.validee);
      if (!mounted) return;
      code = await choisirDansListe(
        context,
        ref,
        ListeMetier.vente,
        codes: {for (final v in ventes) v.code},
        valeur: _document,
        titre: l10n.retoursChoisirTicket,
      );
    } else {
      final achats = (await ref.read(achatsProvider.future)).where((a) => a.statut == StatutsAchat.valide).toList()
        ..sort((a, b) => (a.fournisseurCode == _tiers ? 0 : 1).compareTo(b.fournisseurCode == _tiers ? 0 : 1));
      if (!mounted) return;
      code = (await afficherSelecteur<Achat>(
        context,
        titre: l10n.retoursChoisirEntree,
        icone: LucideIcons.packagePlus,
        elements: achats,
        libelle: (a) => a.code,
        colonnes: [
          DsColonnePicker(libelle: l10n.produitsColCode, valeur: (a) => a.code, attenue: true, mono: true),
          DsColonnePicker(libelle: l10n.communDate, valeur: (a) => formatDate.format(a.date), attenue: true),
          DsColonnePicker(
            libelle: l10n.retoursFournisseur,
            valeur: (a) => noms[a.fournisseurCode] ?? a.fournisseurCode,
            fort: true,
          ),
          DsColonnePicker(libelle: l10n.retoursMontant, valeur: (a) => formaterMontant(a.total, devise)),
        ],
      ))?.code;
    }
    if (code != null) await _chargerDocument(code);
  }

  Map<String, String> _nomsTiers() => _client
      ? {for (final c in ref.read(clientsProvider).value ?? const <Client>[]) c.code: c.nom}
      : {for (final f in ref.read(fournisseursProvider).value ?? const <Fournisseur>[]) f.code: f.nom};

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(retourServiceProvider);
    final quantite = lireNombre(_qte.text) ?? 0;
    try {
      final r = _edition
          ? await service.modifier(
              widget.retour!.code,
              quantite: quantite,
              reglement: _reglement,
              remiseEnStock: _remise,
              numeroSerie: _serie.text,
              observation: _obs.text,
              date: _date,
            )
          : await service.creer(
              type: _type,
              documentCode: _document!,
              produitCode: _produit!,
              quantite: quantite,
              reglement: _reglement,
              remiseEnStock: _remise,
              numeroSerie: _serie.text,
              observation: _obs.text,
              date: _date,
            );
      rafraichirCommerce(ref);
      rafraichirStock(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      afficherToast(
        context,
        titre: _edition ? l10n.retoursModifie : l10n.retoursEnregistre,
        description: _edition ? r.code : l10n.retoursEnregistreDetail(r.code),
      );
    } on RetourException catch (e) {
      setState(() => _erreur = messageErreurRetour(l10n, e.erreur));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final c = context.ds.colors;
    final t = context.ds.typo;
    String da(double v) => formaterMontant(v, devise);
    final noms = _client
        ? {for (final x in ref.watch(clientsProvider).value ?? const <Client>[]) x.code: x.nom}
        : {for (final x in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[]) x.code: x.nom};
    final sel = _lignes.where((l) => l.produitCode == _produit).firstOrNull;
    final max = sel == null ? 0.0 : sel.quantite - (_deja[sel.produitCode] ?? 0);
    final qn = lireNombre(_qte.text) ?? 0;
    final depasse = sel != null && qn > max + 1e-9;
    final montant = sel == null ? 0.0 : qn * (_client ? sel.prix : sel.prixAchat);
    final nomTiers = _tiers == null
        ? ''
        : (_client && _tiers == 'CLN0000' ? l10n.posClientPassage : (noms[_tiers] ?? _tiers!));
    const lw = 128.0;
    final reglements = _client ? ReglementsRetour.client : ReglementsRetour.fournisseur;
    final libelleMontant = _client
        ? (_reglement == ReglementsRetour.avoir ? l10n.retoursAvoirClient : l10n.retoursARembourser)
        : (_reglement == ReglementsRetour.avoir ? l10n.retoursADeduire : l10n.retoursRembourseFournisseur);
    return DsDialog(
      titre: _edition
          ? l10n.retoursModifierTitre
          : (_client ? l10n.retoursNouveauClient : l10n.retoursNouveauFournisseur),
      iconeData: _edition ? LucideIcons.pencil : LucideIcons.undo2,
      description: _edition
          ? '${widget.retour!.code} · $nomTiers'
          : (_client ? l10n.retoursFormDescriptionClient : l10n.retoursFormDescriptionFournisseur),
      largeur: 920,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('retour_enregistrer'),
          libelle: _edition ? l10n.communModifier : l10n.communEnregistrer,
          icone: LucideIcons.check,
          onPressed: sel == null || qn <= 0 || depasse ? null : _enregistrer,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          // Type fixé par l'onglet (retours clients ou fournisseurs) : une seule carte, non modifiable.
          if (!_edition)
            DsChoiceCards<String>(
              key: const ValueKey('retour_type'),
              valeur: _type,
              onChanged: (_) {},
              options: [
                _client
                    ? DsOption(
                        TypesTiers.client,
                        libelle: l10n.retoursChoixClient,
                        icone: LucideIcons.user,
                        description: l10n.retoursChoixClientDesc,
                      )
                    : DsOption(
                        TypesTiers.fournisseur,
                        libelle: l10n.retoursChoixFournisseur,
                        icone: LucideIcons.truck,
                        description: l10n.retoursChoixFournisseurDesc,
                      ),
              ],
            ),
          DsGrilleFormulaire(
            children: [
              DsFormRow(
                libelle: l10n.produitsColCode,
                largeurLibelle: lw,
                child: DsTextField(valeurInitiale: widget.retour?.code ?? l10n.tiersCodeAuto, actif: false),
              ),
              DsFormRow(
                libelle: l10n.communDate,
                obligatoire: true,
                largeurLibelle: lw,
                child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d ?? _date)),
              ),
              DsFormRow(
                libelle: _client ? l10n.retoursClient : l10n.retoursFournisseur,
                obligatoire: true,
                largeurLibelle: lw,
                onLookup: _edition ? null : _choisirTiers,
                child: DsTextField(
                  key: ValueKey('retour_tiers_$_tiers'),
                  valeurInitiale: nomTiers,
                  indice: _client ? l10n.retoursChoisirClientIndice : l10n.retoursChoisirFournisseurIndice,
                  actif: false,
                ),
              ),
              DsFormRow(
                libelle: _client ? l10n.retoursTicketOrigine : l10n.retoursEntreeOrigine,
                obligatoire: true,
                largeurLibelle: lw,
                onLookup: _edition ? null : _choisirOrigine,
                child: DsTextField(
                  key: ValueKey('retour_origine_$_document'),
                  valeurInitiale: _document ?? '',
                  indice: _client ? l10n.retoursChoisirPanierIndice : l10n.retoursChoisirEntreeIndice,
                  actif: false,
                ),
              ),
              DsSpan(
                child: DsFormRow(
                  libelle: l10n.retoursProduit,
                  obligatoire: true,
                  largeurLibelle: lw,
                  aide: _document == null
                      ? (_client ? l10n.retoursProduitAideTicket : l10n.retoursProduitAideEntree)
                      : null,
                  child: DsSelect<String>(
                    key: const ValueKey('retour_produit'),
                    valeur: _produit,
                    actif: _document != null && !_edition,
                    placeholder: l10n.retoursProduitIndice,
                    options: [for (final l in _lignes) l.produitCode],
                    libelle: (code) {
                      final l = _lignes.firstWhere((x) => x.produitCode == code);
                      return _client
                          ? l10n.retoursOptionVendu(l.nom, da(l.prix), formaterNombre(l.quantite))
                          : l10n.retoursOptionRecu(l.nom, da(l.prix), formaterNombre(l.quantite));
                    },
                    recherche: rechercheListe(context, ref, ListeMetier.produit),
                    onChanged: (v) => setState(() {
                      _produit = v;
                      _erreur = null;
                    }),
                  ),
                ),
              ),
              DsFormRow(
                libelle: l10n.retoursQuantite,
                obligatoire: true,
                largeurLibelle: lw,
                erreur: depasse ? l10n.retoursQuantiteDepasse(formaterNombre(max)) : null,
                aide: sel != null && !depasse ? l10n.retoursQuantiteMax(formaterNombre(max)) : null,
                child: DsTextField(
                  key: const ValueKey('retour_quantite'),
                  controller: _qte,
                  numerique: true,
                  onChanged: (_) => setState(() => _erreur = null),
                ),
              ),
              DsFormRow(
                libelle: l10n.retoursNumSerie,
                largeurLibelle: lw,
                child: DsTextField(controller: _serie, indice: l10n.retoursNumSerieIndice),
              ),
              DsFormRow(
                libelle: l10n.retoursPrixAchat,
                largeurLibelle: lw,
                child: DsTextField(
                  key: ValueKey('retour_pa_${sel?.produitCode}'),
                  valeurInitiale: sel == null ? '' : f2(sel.prixAchat),
                  suffixeTexte: devise,
                  actif: false,
                ),
              ),
              DsFormRow(
                libelle: l10n.retoursPrixVente,
                largeurLibelle: lw,
                child: DsTextField(
                  key: ValueKey('retour_pv_${sel?.produitCode}'),
                  valeurInitiale: sel == null || !_client ? '' : f2(sel.prix),
                  suffixeTexte: devise,
                  actif: false,
                ),
              ),
              DsFormRow(
                libelle: _client ? l10n.retoursRemboursement : l10n.retoursReglement,
                obligatoire: true,
                largeurLibelle: lw,
                child: DsSelect<String>(
                  key: const ValueKey('retour_reglement'),
                  valeur: _reglement,
                  options: reglements,
                  libelle: (r) => libelleReglementRetour(l10n, _type, r),
                  onChanged: (v) => setState(() => _reglement = v ?? _reglement),
                ),
              ),
              DsFormRow(
                libelle: l10n.retoursRemiseStock,
                largeurLibelle: lw,
                child: DsSelect<bool>(
                  valeur: _client ? _remise : false,
                  actif: _client,
                  options: const [true, false],
                  libelle: (b) => b ? l10n.retoursRemiseOui : l10n.retoursRemiseNon,
                  onChanged: (v) => setState(() => _remise = v ?? _remise),
                ),
              ),
              DsSpan(
                child: DsFormRow(
                  libelle: l10n.retoursObservation,
                  largeurLibelle: lw,
                  alignerDebut: true,
                  child: DsTextField(controller: _obs, multiligne: true, lignes: 2, indice: l10n.retoursMotifIndice),
                ),
              ),
            ],
          ),
          if (sel != null && qn > 0 && !depasse)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: DsSpacing.s3),
              decoration: BoxDecoration(color: c.primaryTint, borderRadius: DsRadius.borderMd),
              child: Row(
                spacing: 10,
                children: [
                  Icon(LucideIcons.undo2, size: 18, color: c.primaryTintFg),
                  Expanded(
                    child: Text(
                      libelleMontant,
                      style: t.body.copyWith(fontWeight: FontWeight.w600, color: c.primaryTintFg),
                    ),
                  ),
                  Text(
                    da(montant),
                    key: const ValueKey('retour_montant'),
                    style: t.kpi.copyWith(color: c.primaryTintFg),
                  ),
                ],
              ),
            ),
          if (_erreur != null) Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
        ],
      ),
    );
  }
}

/// Détail d'un retour (`RetourDetailDialog` du DS, 960 px).
Future<void> afficherDetailRetour(
  BuildContext context,
  WidgetRef ref,
  Retour r, {
  required Map<String, String> nomsTiers,
  double? prixVenteCatalogue,
  VoidCallback? onModifier,
}) {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final voirAchat = ref.read(permissionProvider(Permission.voirPrixAchat));
  final l = r.ligne;
  final prixVente = r.estClient ? (l?.prixUnitaire ?? 0) : (prixVenteCatalogue ?? 0);
  final tiers = nomTiersRetour(l10n, r, nomsTiers);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      titre: l10n.retoursDetailTitre(r.code),
      icone: LucideIcons.undo2,
      largeur: 960,
      description: '${formatDate.format(r.date)} · $tiers',
      onModifier: onModifier,
      modifierDesactive: !r.actif,
      badges: [
        DsStatusBadge(
          statut: r.estClient ? 'client' : 'fournisseur',
          libelle: r.estClient ? l10n.retoursChoixClient : l10n.retoursChoixFournisseur,
          point: false,
        ),
        BadgeStatut(r.actif ? 'actif' : 'annule'),
      ],
      stats: [
        DsStatItem(libelle: l10n.retoursQuantite, valeur: formaterNombre(r.quantite), icone: LucideIcons.boxes),
        if (voirAchat)
          DsStatItem(
            libelle: l10n.retoursPrixAchat,
            valeur: f2(l?.prixAchat ?? 0),
            suffixe: devise,
            icone: LucideIcons.shoppingCart,
          ),
        DsStatItem(libelle: l10n.retoursPrixVente, valeur: f2(prixVente), suffixe: devise, icone: LucideIcons.tag),
        DsStatItem(
          libelle: l10n.retoursMontant,
          valeur: f2(r.total),
          suffixe: devise,
          icone: LucideIcons.banknote,
          ton: DsBadgeTon.avertissement,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.ventesInfosGenerales,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.produitsColCode, r.code, mono: true),
            DsKeyValue(l10n.communDate, formatDate.format(r.date)),
            DsKeyValue(l10n.ventesType, r.estClient ? l10n.retoursChoixClient : l10n.retoursChoixFournisseur),
            DsKeyValue(r.estClient ? l10n.retoursClient : l10n.retoursFournisseur, tiers),
            DsKeyValue(l10n.retoursPieceOrigine, r.documentCode, mono: true),
            DsKeyValue(
              r.estClient ? l10n.retoursRemboursement : l10n.retoursReglement,
              libelleReglementRetour(l10n, r.type, r.reglement),
            ),
            if (r.estClient)
              DsKeyValue(l10n.retoursRemiseStock, r.remiseEnStock ? l10n.retoursRemiseOui : l10n.retoursRemiseNon),
          ],
        ),
        DsSectionDetail(
          titre: l10n.retoursProduit,
          icone: LucideIcons.package,
          items: [
            DsKeyValue(l10n.retoursProduit, l?.designation, fort: true),
            DsKeyValue(l10n.produitsColCode, l?.produitCode, mono: true),
            DsKeyValue(l10n.retoursNumSerie, r.numeroSerie),
          ],
        ),
        DsSectionDetail(
          titre: l10n.retoursObservation,
          icone: LucideIcons.messageSquareText,
          contenu: Text(r.motif ?? '—'),
        ),
        DsSectionDetail(
          titre: l10n.ventesAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.ventesCreePar, r.utilisateurCode),
            DsKeyValue(l10n.ventesCreeLe, formatDateHeure.format(r.date)),
            DsKeyValue(l10n.ventesAnnulePar, r.annulePar),
            DsKeyValue(l10n.ventesAnnuleLe, r.annuleLe == null ? null : formatDateHeure.format(r.annuleLe!)),
            DsKeyValue(l10n.ventesMotifAnnulation, r.motifAnnulation),
          ],
        ),
      ],
    ),
  );
}

/// Annulation de retours en lot (motif obligatoire) ; les retours déjà annulés sont bloqués.
Future<void> annulerRetours(
  BuildContext context,
  WidgetRef ref,
  List<Retour> choix,
  VoidCallback effacer, {
  required Map<String, String> nomsTiers,
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.retoursEntite,
    entitePluriel: l10n.retoursEntitePluriel,
    motifRequis: true,
    elements: [
      for (final r in choix)
        DsElementLot(
          id: r.code,
          titre: '${r.code} · ${r.ligne?.designation ?? ''}',
          sousTitre: nomTiersRetour(l10n, r, nomsTiers),
          meta: formaterMontant(r.total, devise),
          motifBlocage: r.actif ? null : l10n.retoursBloqueDejaAnnule,
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final service = ref.read(retourServiceProvider);
  final echecs = <String>[];
  for (final r in choix.where((r) => r.actif)) {
    try {
      await service.annuler(r.code, motif: motif);
    } on RetourException catch (e) {
      echecs.add('${r.code} : ${messageErreurRetour(l10n, e.erreur)}');
    }
  }
  effacer();
  rafraichirCommerce(ref);
  rafraichirStock(ref);
  if (!context.mounted) return;
  if (echecs.isEmpty) {
    afficherToast(context, titre: l10n.retoursAnnulesTitre, description: l10n.retoursAnnulesDetail);
  } else {
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.retoursAnnulesTitre,
        message: echecs.join('\n'),
      ),
    );
  }
}
