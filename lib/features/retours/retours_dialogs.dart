import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/retour_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/calculs_prix.dart';
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

/// Ligne d'une pièce d'origine proposée au retour : une ligne de vente (client) ou un produit de l'entrée
/// (fournisseur).
@immutable
class _LigneOrigine {
  const _LigneOrigine({
    required this.cle,
    this.ordre,
    required this.produitCode,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.prixAchat,
  });

  /// Clé de sélection : `L<ordre>` pour une ligne de vente, code produit pour une entrée.
  final String cle;
  final int? ordre;
  final String produitCode;
  final String nom;
  final double quantite;
  final double prix;
  final double prixAchat;
}

String _cleLigneVente(int ordre) => 'L$ordre';

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

  /// Montant retour (obligatoire) : rendu au client / versé par le fournisseur en espèces, le reste en avoir.
  late final _montantRetour = TextEditingController(
    text: widget.retour == null ? '' : formaterNombre(widget.retour!.rembourse, grouper: false),
  );

  /// Un retour est daté du jour de sa saisie (possible après la clôture Z du jour de la vente) ; un retour
  /// modifié garde sa date.
  late final DateTime _date = widget.retour?.date ?? DateTime.now();
  late bool _remise = widget.retour?.remiseEnStock ?? true;
  String? _erreur;

  bool get _edition => widget.retour != null;
  bool get _client => _type == TypesTiers.client;

  @override
  void initState() {
    super.initState();
    final r = widget.retour;
    if (r != null) {
      _tiers = r.tiersCode;
      _produit = r.estClient && r.ligne?.ordreOrigine != null
          ? _cleLigneVente(r.ligne!.ordreOrigine!)
          : r.ligne?.produitCode;
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
    _montantRetour.dispose();
    super.dispose();
  }

  Future<void> _chargerDocument(String code) async {
    final lignes = <_LigneOrigine>[];
    String? tiers;
    if (_client) {
      final v = await ref.read(venteRepositoryProvider).vente(code);
      if (v == null) return;
      tiers = v.clientCode;
      // Une option par ligne du ticket : un produit vendu en colis et à l'unité, ou seul et dans un pack, donne
      // plusieurs lignes, chacune avec son prix et sa quantité.
      for (final l in v.lignes.where((l) => l.packCode == null || l.composantPack)) {
        lignes.add(
          _LigneOrigine(
            cle: _cleLigneVente(l.ordre),
            ordre: l.ordre,
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
            cle: x.cle,
            produitCode: x.produitCode,
            nom: x.nom,
            quantite: q,
            prix: q == 0 ? 0 : (x.prix * x.quantite + l.total) / q,
            prixAchat: q == 0 ? 0 : (x.prix * x.quantite + l.total) / q,
          );
        } else {
          lignes.add(
            _LigneOrigine(
              cle: l.produitCode,
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
    final repo = ref.read(tiersRepositoryProvider);
    final deja = _client
        ? {
            for (final e in (await repo.quantitesRetourneesParLigne(code, sauf: widget.retour?.code)).entries)
              _cleLigneVente(e.key): e.value,
          }
        : await repo.quantitesRetournees(code, sauf: widget.retour?.code);
    if (!mounted) return;
    setState(() {
      _document = code;
      _tiers = tiers;
      _lignes = lignes;
      _deja = deja;
      if (!lignes.any((l) => l.cle == _produit)) {
        // Ancien retour sans ligne d'origine : 1ʳᵉ ligne du produit.
        final produit = widget.retour?.ligne?.produitCode;
        _produit =
            lignes.where((l) => l.produitCode == produit).firstOrNull?.cle ??
            (lignes.length == 1 ? lignes.first.cle : null);
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
      if (code != null) _changerTiers(code);
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
      if (code != null) _changerTiers(code);
    }
  }

  /// Un autre tiers : la pièce d'origine choisie (d'un autre tiers) et son produit sont oubliés.
  void _changerTiers(String code) {
    if (code == _tiers) return;
    setState(() {
      _tiers = code;
      _document = null;
      _lignes = const [];
      _deja = const {};
      _produit = null;
    });
  }

  Future<void> _choisirOrigine() async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final noms = _nomsTiers();
    String? code;
    if (_client) {
      // Seulement les ventes du client choisi (toutes tant qu'aucun client n'est choisi).
      final ventes = (await ref.read(ventesProvider.future))
          .where((v) => v.statut == StatutsVente.validee && (_tiers == null || v.clientCode == _tiers));
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
      // Seulement les entrées du fournisseur choisi (toutes tant qu'aucun fournisseur n'est choisi).
      final achats = (await ref.read(achatsProvider.future))
          .where((a) => a.statut == StatutsAchat.valide && (_tiers == null || a.fournisseurCode == _tiers))
          .toList();
      if (!mounted) return;
      code = (await afficherSelecteur<Achat>(
        context,
        titre: l10n.retoursChoisirEntree,
        icone: LucideIcons.packagePlus,
        elements: achats,
        libelle: (a) => a.code,
        colonnes: [
          DsColonnePicker(libelle: l10n.produitsColCode, valeur: (a) => a.code, attenue: true, mono: true),
          DsColonnePicker(libelle: l10n.communDate, valeur: (a) => formatDateHeure.format(a.date), attenue: true),
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

  bool get _passage => _client && _tiers == 'CLN0000';

  /// Montant retour saisi ; client de passage : tout le montant du retour (champ verrouillé).
  double? _montantSaisi() => _passage ? _montantTotal() : lireNombre(_montantRetour.text);

  double _montantTotal() {
    final sel = _lignes.where((l) => l.cle == _produit).firstOrNull;
    final qn = lireNombre(_qte.text) ?? 0;
    return sel == null ? 0 : CalculsPrix.arrondir(qn * (_client ? sel.prix : sel.prixAchat));
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(retourServiceProvider);
    final quantite = lireNombre(_qte.text) ?? 0;
    try {
      final r = _edition
          ? await service.modifier(
              widget.retour!.code,
              quantite: quantite,
              montantRetour: _montantSaisi(),
              remiseEnStock: _client && _remise,
              numeroSerie: _serie.text,
              observation: _obs.text,
            )
          : await service.creer(
              type: _type,
              documentCode: _document!,
              produitCode: _lignes.firstWhere((l) => l.cle == _produit).produitCode,
              ligneOrdre: _lignes.firstWhere((l) => l.cle == _produit).ordre,
              quantite: quantite,
              montantRetour: _montantSaisi(),
              remiseEnStock: _client && _remise,
              numeroSerie: _serie.text,
              observation: _obs.text,
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
    final sel = _lignes.where((l) => l.cle == _produit).firstOrNull;
    final max = sel == null ? 0.0 : sel.quantite - (_deja[sel.cle] ?? 0);
    final qn = lireNombre(_qte.text) ?? 0;
    final depasse = sel != null && qn > max + 1e-9;
    final montant = _montantTotal();
    final saisi = _montantSaisi();
    final montantErreur = saisi != null && (saisi < 0 || saisi > montant + 0.005)
        ? l10n.retoursMontantRetourMax(da(montant))
        : null;
    final montantValide = saisi != null && montantErreur == null;
    final nomTiers = _tiers == null
        ? ''
        : (_client && _tiers == 'CLN0000' ? l10n.posClientPassage : (noms[_tiers] ?? _tiers!));
    const lw = 128.0;
    final libelleMontant = l10n.retoursMontant;
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
          onPressed: sel == null || qn <= 0 || depasse || !montantValide ? null : _enregistrer,
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
                aide: _edition ? null : l10n.retoursDateDuJour,
                child: DsDateField(valeur: _date, actif: false, onChanged: (_) {}),
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
                    options: [for (final l in _lignes) l.cle],
                    libelle: (cle) {
                      final l = _lignes.firstWhere((x) => x.cle == cle);
                      return _client
                          ? l10n.retoursOptionVendu(l.nom, da(l.prix), formaterNombre(l.quantite))
                          : l10n.retoursOptionRecu(l.nom, da(l.prix), formaterNombre(l.quantite));
                    },
                    // Recherche par produit, ramenée à la 1ʳᵉ ligne de ce produit.
                    recherche: (_, valeur) async {
                      final parProduit = <String, String>{};
                      for (final l in _lignes) {
                        parProduit.putIfAbsent(l.produitCode, () => l.cle);
                      }
                      final code = await choisirDansListe(
                        context,
                        ref,
                        ListeMetier.produit,
                        codes: parProduit.keys.toSet(),
                        valeur: _lignes.where((l) => l.cle == valeur).firstOrNull?.produitCode,
                      );
                      return code == null ? null : parProduit[code];
                    },
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
              // Fournisseur : le produit repart chez le fournisseur (sortie du stock), pas de remise en stock.
              if (_client)
                DsFormRow(
                  libelle: l10n.retoursRemiseStock,
                  largeurLibelle: lw,
                  child: DsSelect<bool>(
                    cle: const ValueKey('retour_remise_stock'),
                    valeur: _remise,
                    options: const [true, false],
                    libelle: (b) => b ? l10n.retoursRemiseOui : l10n.retoursRemiseNon,
                    onChanged: (v) => setState(() => _remise = v ?? _remise),
                  ),
                ),
              DsFormRow(
                libelle: l10n.retoursMontantRetour,
                obligatoire: true,
                largeurLibelle: lw,
                erreur: montantErreur,
                aide: montantErreur != null
                    ? null
                    : _passage
                    ? l10n.retoursMontantRetourPassage
                    : (_client ? l10n.retoursMontantRetourAideClient : l10n.retoursMontantRetourAideFournisseur),
                child: DsTextField(
                  key: ValueKey(_passage ? 'retour_montant_retour_$montant' : 'retour_montant_retour'),
                  controller: _passage ? null : _montantRetour,
                  valeurInitiale: _passage ? f2(montant) : null,
                  numerique: true,
                  actif: !_passage,
                  indice: sel == null ? '' : f2(montant),
                  suffixeTexte: devise,
                  onChanged: (_) => setState(() => _erreur = null),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          libelleMontant,
                          style: t.body.copyWith(fontWeight: FontWeight.w600, color: c.primaryTintFg),
                        ),
                        if (montantValide)
                          Text(
                            l10n.retoursRepartition(da(CalculsPrix.arrondir(montant - saisi)), da(saisi)),
                            key: const ValueKey('retour_repartition'),
                            style: t.bodySm.copyWith(color: c.primaryTintFg),
                          ),
                      ],
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
      description: '${formatDateHeure.format(r.date)} · $tiers',
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
            DsKeyValue(l10n.communDate, formatDateHeure.format(r.date)),
            DsKeyValue(l10n.ventesType, r.estClient ? l10n.retoursChoixClient : l10n.retoursChoixFournisseur),
            DsKeyValue(r.estClient ? l10n.retoursClient : l10n.retoursFournisseur, tiers),
            DsKeyValue(l10n.retoursPieceOrigine, r.documentCode, mono: true),
            DsKeyValue(
              r.estClient ? l10n.retoursRemboursement : l10n.retoursReglement,
              libelleReglementRetour(l10n, r.type, r.reglement),
            ),
            DsKeyValue(l10n.retoursMontantRetour, formaterMontant(r.rembourse, devise)),
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
