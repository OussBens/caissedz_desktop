import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import '../entrees/entree_dialogs.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produit_form_dialog.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_dialogs.dart';
import '../tiers/tiers_providers.dart';
import 'caisse_dialogs.dart';
import 'pos_controller.dart';
import 'pos_dialogs.dart';

/// Écran Caisse (`CaisseScreen` du DS v2.2) : session compacte, 5 ventes en parallèle (onglets), grille ou
/// liste des produits / packs, panier (client, remise, mode), total et encaissement ticket / BL-SC / crédit.
class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

enum _Vue { produits, packs }

class _PosPageState extends ConsumerState<PosPage> {
  final _scan = TextEditingController();
  final _scanFocus = FocusNode();
  String _recherche = '';
  String? _categorie;
  _Vue _vue = _Vue.produits;
  DsVueModule _disposition = DsVueModule.grille;
  bool _afficherProduits = true;
  int? _ligneSelectionnee;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(posControllerProvider.notifier).initialiser());
  }

  @override
  void dispose() {
    _scan.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  AppLocalizations get l10n => AppLocalizations.of(context);
  PosController get ctrl => ref.read(posControllerProvider.notifier);
  String _da(double v) => formaterMontant(v, ref.read(deviseProvider));

  void _erreur(String message) =>
      unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: l10n.posTitre, message: message));

  Future<void> _executer(Future<void> Function() action) async {
    try {
      await action();
    } on PosException catch (e) {
      _erreur(switch (e.erreur) {
        ErreurPos.stockInsuffisant => l10n.posErreurStock(e.detail ?? ''),
        ErreurPos.produitInconnu => l10n.posErreurProduitInconnu(e.detail ?? ''),
        ErreurPos.maxPaniers => l10n.posMaxPaniers,
        ErreurPos.sessionRequise => l10n.posSessionAucune,
      });
    } on VenteException catch (e) {
      _erreur(messageErreurVente(l10n, e, ref.read(deviseProvider)));
    }
  }

  // ------------------------------------------------------------------ Données

  Map<String, double> get _stocks => ref.read(stocksCaisseProvider).value ?? const {};

  /// Unités disponibles d'un produit dans le magasin de la caisse, hors réservations des paniers ouverts
  /// (la ligne [sauf] du panier courant est exclue lors d'une modification).
  double _disponible(Produit p, {PanierLigne? sauf}) {
    final etat = ref.read(posControllerProvider);
    final reserve = etat.unitesReservees(p.code) - (sauf?.unitesStock ?? 0);
    return (_stocks[p.code] ?? 0) - reserve;
  }

  List<Colis> _colisDe(Produit p) => [
    for (final c in ref.read(colisProvider).value ?? const <Colis>[])
      if (c.produitCode == p.code && c.actif) c,
  ];

  String _nomCaisse() {
    final etat = ref.read(posControllerProvider);
    final code = etat.session?.caisseCode ?? etat.caisseCode;
    final caisses = ref.read(caissesListeProvider).value ?? const <Caisse>[];
    return caisses.where((c) => c.code == code).firstOrNull?.nom ?? caisses.firstOrNull?.nom ?? l10n.posTitre;
  }

  String _nomClient(String code) {
    if (code == 'CLN0000') return l10n.posClientPassage;
    final clients = ref.read(clientsProvider).value ?? const <Client>[];
    return clients.where((c) => c.code == code).firstOrNull?.nom ?? code;
  }

  // ------------------------------------------------------------------ Produits

  Future<void> _choisirProduit(Produit p, {bool scanne = false}) async {
    final choix = await afficherSelectionProduit(
      context,
      produit: p,
      colis: _colisDe(p),
      stock: _disponible(p),
      scanne: scanne,
    );
    if (choix == null || !mounted) return;
    await _executer(() => ctrl.ajouter(p, colis: choix.colis, nombre: choix.nombre, quantite: choix.quantite));
    _scanFocus.requestFocus();
  }

  Future<void> _modifierColis(int index) async {
    final l = ref.read(posControllerProvider).panier.lignes[index];
    if (l.pack != null) return;
    final choix = await afficherSelectionProduit(
      context,
      produit: l.produit,
      colis: _colisDe(l.produit),
      stock: _disponible(l.produit, sauf: l),
      colisInitial: l.colis,
      nombreInitial: l.uniteVente == UniteVente.nombre,
      quantiteInitiale: l.quantite,
      modification: true,
    );
    if (choix == null || !mounted) return;
    await _executer(
      () => ctrl.remplacerLigne(index, l.produit, colis: choix.colis, nombre: choix.nombre, quantite: choix.quantite),
    );
  }

  Future<void> _ajouterPack(Pack pack) async {
    final produits = ref.read(produitsPosProvider).value ?? const <Produit>[];
    final premier = produits.where((p) => p.code == pack.lignes.firstOrNull?.produitCode).firstOrNull;
    if (premier == null) {
      _erreur(l10n.posErreurProduitInconnu(pack.code));
      return;
    }
    await _executer(() => ctrl.ajouter(premier, pack: pack));
  }

  Future<void> _scanner() async {
    final code = _scan.text.trim();
    if (code.isEmpty) return;
    final r = await ctrl.resoudre(code);
    if (!mounted) return;
    if (r == null) {
      if (RegExp(r'^\d{8,}$').hasMatch(code)) {
        final suite = await afficherProduitIntrouvable(context, code);
        if (!mounted) return;
        if (suite == true) await _rechercheAvancee();
        if (suite == false) await _nouveauProduit();
      }
      return;
    }
    _scan.clear();
    setState(() => _recherche = '');
    if (r.colis != null || r.pack != null) {
      await _executer(() => ctrl.ajouter(r.produit, colis: r.colis, pack: r.pack));
    } else {
      await _choisirProduit(r.produit, scanne: true);
    }
    _scanFocus.requestFocus();
  }

  Future<void> _rechercheAvancee() async {
    final produits = ref.read(produitsPosProvider).value ?? const <Produit>[];
    final choix = await afficherRechercheProduit(context, ref, produits: produits, stocks: _stocks);
    if (choix == null || choix.isEmpty || !mounted) return;
    for (final p in choix) {
      await _executer(() => ctrl.ajouter(p));
    }
    if (!mounted) return;
    afficherToast(
      context,
      titre: l10n.posRechAjoutes(choix.length),
      description: l10n.posVente(ref.read(posControllerProvider).panier.id),
      ton: DsToastTon.info,
    );
  }

  /// Entrée rapide (§9.6, touche `E`) : achat d'un produit payé intégralement, stock rafraîchi ensuite.
  Future<void> _entreeRapide([Produit? p]) async {
    await afficherEntreeRapide(context, ref, produit: p);
    ref.invalidate(stocksCaisseProvider);
  }

  Future<void> _nouveauProduit() async {
    await afficherFormulaireProduit(context);
    ref.invalidate(produitsPosProvider);
  }

  // ------------------------------------------------------------------ Panier

  Future<void> _choisirClient() async {
    final c = await afficherChoixClient(context, ref, onCreer: () => unawaited(_nouveauClient()));
    if (c != null) ctrl.choisirClient(c.code);
  }

  Future<void> _nouveauClient() async {
    final avant = {for (final c in ref.read(clientsProvider).value ?? const <Client>[]) c.code};
    await afficherFormulaireTiers(context, ref, type: TypesTiers.client);
    final apres = await ref.read(clientsProvider.future);
    final nouveau = apres.where((c) => !avant.contains(c.code)).firstOrNull;
    if (nouveau != null) ctrl.choisirClient(nouveau.code);
  }

  List<Remise> _remisesGlobales() {
    final n = DateTime.now();
    return [
      for (final r in ref.read(remisesProvider).value ?? const <Remise>[])
        if (r.actif &&
            r.parMontant &&
            (r.dateDebut == null || !n.isBefore(r.dateDebut!)) &&
            (r.dateFin == null || !n.isAfter(r.dateFin!)))
          r,
    ];
  }

  String _libelleRemise(Remise r) =>
      '${r.designation} · ${r.type == 'Pourcentage' ? '${formaterNombre(r.valeur)} %' : _da(r.valeur)}';

  Future<void> _choisirRemise() async {
    final r = await afficherSelecteur<Remise>(
      context,
      titre: l10n.posChoisirRemise,
      icone: LucideIcons.percent,
      elements: _remisesGlobales(),
      libelle: _libelleRemise,
    );
    if (r != null) ctrl.appliquerRemise(r);
  }

  Future<void> _modifierPrix(int index) async {
    if (!ref.read(permissionProvider(Permission.modifierPrixVente))) return;
    final l = ref.read(posControllerProvider).panier.lignes[index];
    final r = await afficherModifPrix(
      context,
      ligne: l,
      voirAchat: ref.read(permissionProvider(Permission.voirPrixAchat)),
    );
    if (r == null || !mounted) return;
    ctrl.prixLigne(index, r.prix);
    if (r.catalogue) {
      await ref.read(catalogueServiceProvider).modifierProduit(l.produit.copyWith(prixVente: r.prix));
      ref.read(catalogueVersionProvider.notifier).incrementer();
    }
    if (!mounted) return;
    afficherToast(
      context,
      titre: l10n.posPrixModifie,
      description: r.catalogue ? l10n.posPrixModifieProduit(l.designation) : l10n.posPrixModifieTicket(l.designation),
      ton: DsToastTon.info,
    );
  }

  void _vider() {
    ctrl.viderPanier();
    setState(() => _ligneSelectionnee = null);
  }

  Future<void> _fermerVente(Object cle) async {
    final etat = ref.read(posControllerProvider);
    final index = etat.paniers.indexWhere((p) => p.id == cle);
    if (index < 0) return;
    final p = etat.paniers[index];
    if (p.lignes.isNotEmpty) {
      final ok = await afficherConfirmation(
        context,
        titre: l10n.posFermerVenteTitre(p.id),
        message: l10n.posFermerVenteMsg('${p.lignes.length}'),
        libelleConfirmer: l10n.posFermerVenteOk,
        genre: DsConfirmGenre.avertissement,
      );
      if (!ok) return;
    }
    ctrl.fermerPanier(index);
  }

  // ------------------------------------------------------------------ Encaissement

  Future<void> _encaisser(NatureEncaissement nature) async {
    var etat = ref.read(posControllerProvider);
    if (etat.panier.estVide) return;
    if (etat.session == null) {
      final ouvrir = await afficherCaisseFermee(context, caisse: _nomCaisse());
      if (!ouvrir || !mounted) return;
      if (!await afficherOuvertureCaisse(context, ref) || !mounted) return;
      etat = ref.read(posControllerProvider);
    }
    final panier = etat.panier;
    final r = await afficherEncaisser(
      context,
      nature: nature,
      panier: panier,
      numeroVente: panier.id,
      nomClient: _nomClient(panier.clientCode),
      caissier: ref.read(sessionProvider)?.utilisateur.nom ?? '',
    );
    if (r == null || !mounted) return;
    Vente? vente;
    await _executer(() async {
      vente = await ctrl.encaisser(
        creditAutorise: panier.clientCode != 'CLN0000',
        montantPaye: r.paye,
        typePanier: nature == NatureEncaissement.blsc ? 'BL_SC' : 'Ticket',
      );
    });
    final v = vente;
    if (v == null || !mounted) return;
    rafraichirCommerce(ref);
    rafraichirCaisse(ref);
    setState(() => _ligneSelectionnee = null);
    afficherToast(
      context,
      titre: nature == NatureEncaissement.enregistrer
          ? l10n.posToastEnregistre(v.code)
          : l10n.posToastEncaisse(nature == NatureEncaissement.blsc ? l10n.posBlSc : l10n.posTicket, v.code),
      description: nature == NatureEncaissement.enregistrer || v.reste > 0
          ? l10n.posToastResteCredit(_da(v.reste))
          : l10n.posToastRendu(_da(v.totalNet), _da(v.monnaie)),
      libelleAction: l10n.posReimprimer,
      iconeAction: LucideIcons.printer,
      onAction: () => unawaited(afficherResultatVente(context, ref, v)),
    );
    switch (nature) {
      case NatureEncaissement.ticket:
        if (!await imprimerTicketDirect(context, ref, v) && mounted) await afficherResultatVente(context, ref, v);
      case NatureEncaissement.blsc:
        await imprimerFactureVente(context, ref, v, partager: r.sortie == SortieDocument.pdf);
      case NatureEncaissement.enregistrer:
        break;
    }
    _scanFocus.requestFocus();
  }

  // ------------------------------------------------------------------ Raccourcis

  KeyEventResult _raccourci(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final ctrlPresse = HardwareKeyboard.instance.isControlPressed;
    final k = e.logicalKey;
    final etat = ref.read(posControllerProvider);
    final saisie = _scanFocus.hasFocus;
    final i = _ligneSelectionnee;
    final ligne = i != null && i < etat.panier.lignes.length ? etat.panier.lignes[i] : null;
    if (k == LogicalKeyboardKey.f1) {
      unawaited(afficherAideRaccourcis(context));
    } else if (k == LogicalKeyboardKey.f2) {
      _scanFocus.requestFocus();
    } else if (k == LogicalKeyboardKey.f3) {
      unawaited(_rechercheAvancee());
    } else if (k == LogicalKeyboardKey.f4) {
      unawaited(_encaisser(NatureEncaissement.ticket));
    } else if (k == LogicalKeyboardKey.f5) {
      unawaited(_encaisser(NatureEncaissement.blsc));
    } else if (k == LogicalKeyboardKey.f6) {
      unawaited(_encaisser(NatureEncaissement.enregistrer));
    } else if (k == LogicalKeyboardKey.f7) {
      unawaited(_choisirClient());
    } else if (k == LogicalKeyboardKey.f8) {
      unawaited(_choisirRemise());
    } else if (k == LogicalKeyboardKey.f9) {
      unawaited(afficherCalculatrice(context));
    } else if (k == LogicalKeyboardKey.f10) {
      _vider();
    } else if (k == LogicalKeyboardKey.f11) {
      setState(() => _afficherProduits = !_afficherProduits);
    } else if (k == LogicalKeyboardKey.f12) {
      unawaited(afficherVentesDuJour(context, ref, nomCaisse: _nomCaisse()));
    } else if (ctrlPresse && k == LogicalKeyboardKey.keyN) {
      unawaited(_executer(() async => ctrl.nouveauPanier()));
    } else if (ctrlPresse && k == LogicalKeyboardKey.tab) {
      ctrl.panierSuivant();
    } else if (k == LogicalKeyboardKey.keyE && !ctrlPresse && !saisie) {
      unawaited(_entreeRapide());
    } else if (k == LogicalKeyboardKey.delete && ligne != null && !saisie) {
      ctrl.retirerLigne(i!);
      setState(() => _ligneSelectionnee = null);
    } else if ((k == LogicalKeyboardKey.numpadAdd || k == LogicalKeyboardKey.add) && ligne != null && !saisie) {
      unawaited(_executer(() => ctrl.modifierQuantite(i!, ligne.quantite + 1)));
    } else if ((k == LogicalKeyboardKey.numpadSubtract || k == LogicalKeyboardKey.minus) && ligne != null && !saisie) {
      unawaited(_executer(() => ctrl.modifierQuantite(i!, ligne.quantite - 1)));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ------------------------------------------------------------------ Rendu

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(posControllerProvider);
    ref
      ..watch(stocksCaisseProvider)
      ..watch(colisProvider)
      ..watch(clientsProvider)
      ..watch(remisesProvider)
      ..watch(caissesListeProvider);
    final large = !_afficherProduits;
    return Focus(
      onKeyEvent: _raccourci,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DsTailles.pagePaddingX,
          DsTailles.pagePaddingY - DsSpacing.s2,
          DsTailles.pagePaddingX,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsSpacing.s3,
          children: [
            _entete(etat),
            _ongletsVentes(etat),
            Expanded(
              child: large
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: DsSpacing.s4,
                      children: [
                        _barreRecherche(),
                        Expanded(child: _panier(etat, large: true)),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: DsSpacing.s4,
                      children: [
                        Expanded(child: _colonneProduits()),
                        SizedBox(width: 540, child: _panier(etat, large: false)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entete(PosEtat etat) {
    final t = context.ds.typo;
    final s = etat.session;
    final solde = s == null ? null : ref.watch(soldesCaissesProvider).value?[s.caisseCode]?.especes;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.posTitre, style: t.pageTitle),
        DsCashSessionCard(
          key: const ValueKey('caisse_session'),
          compact: true,
          ouverte: s != null,
          caisse: _nomCaisse(),
          code: s?.code,
          ouvertureHeure: s == null ? null : formatHeure(s.ouverteLe),
          solde: solde,
          devise: ref.watch(deviseProvider),
          onOuvrir: () => unawaited(afficherOuvertureCaisse(context, ref)),
          onCloturer: () => unawaited(afficherClotureSession(context, ref, nomCaisse: _nomCaisse())),
          onMouvement: s == null
              ? null
              : () => unawaited(afficherMouvementManuel(context, ref, caisseCode: s.caisseCode)),
        ),
        LayoutBuilder(
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              DsButton(
                libelle: l10n.posVentesDuJour,
                icone: LucideIcons.receiptText,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                onPressed: () => afficherVentesDuJour(context, ref, nomCaisse: _nomCaisse()),
              ),
              DsButton(
                libelle: l10n.posRecetteProduit,
                icone: LucideIcons.chartColumn,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.fantome,
                onPressed: () => afficherRecetteProduit(context, ref, nomCaisse: _nomCaisse()),
              ),
              DsIconButton(
                icone: LucideIcons.keyboard,
                tooltip: l10n.posAide,
                taille: DsTailles.controleSm,
                contour: true,
                onPressed: () => unawaited(afficherAideRaccourcis(context)),
              ),
              DsIconButton(
                icone: LucideIcons.calculator,
                tooltip: l10n.posCalculatrice,
                taille: DsTailles.controleSm,
                contour: true,
                onPressed: () => unawaited(afficherCalculatrice(context)),
              ),
              DsIconButton(
                key: const ValueKey('caisse_basculer_produits'),
                icone: _afficherProduits ? LucideIcons.panelLeftClose : LucideIcons.panelLeftOpen,
                tooltip: _afficherProduits ? l10n.posMasquerProduits : l10n.posAfficherProduits,
                taille: DsTailles.controleSm,
                contour: _afficherProduits,
                actif: !_afficherProduits,
                onPressed: () => setState(() => _afficherProduits = !_afficherProduits),
              ),
              DsIconButton(
                icone: LucideIcons.settings2,
                tooltip: l10n.posParametres,
                taille: DsTailles.controleSm,
                contour: true,
                onPressed: () => unawaited(afficherParametresCaisse(context, ref)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ongletsVentes(PosEtat etat) => DsSaleTabs(
    max: maxPaniers,
    courant: etat.panier.id,
    onChanged: (cle) {
      ctrl.selectionnerPanier(etat.paniers.indexWhere((p) => p.id == cle));
      setState(() => _ligneSelectionnee = null);
    },
    onAjouter: () => unawaited(_executer(() async => ctrl.nouveauPanier())),
    onFermer: (cle) => unawaited(_fermerVente(cle)),
    onglets: [
      for (final p in etat.paniers)
        DsOngletVente(
          cle: p.id,
          libelle: l10n.posVente(p.id),
          compte: p.lignes.length,
          meta: p.lignes.isNotEmpty
              ? l10n.posVenteMeta(formaterNombre(p.pieces), _da(p.totalNet))
              : (p.clientCode != 'CLN0000' ? _nomClient(p.clientCode) : l10n.posVenteVide),
        ),
    ],
  );

  Widget _barreRecherche() => Row(
    spacing: DsSpacing.s2,
    children: [
      Expanded(
        child: DsSearchField(
          controller: _scan,
          focusNode: _scanFocus,
          grand: true,
          kbd: 'F2',
          autofocus: true,
          indice: l10n.posScanIndice,
          onChanged: (v) => setState(() => _recherche = v),
          onSubmitted: (_) => unawaited(_scanner()),
        ),
      ),
      DsButton(
        libelle: l10n.posRecherche,
        icone: LucideIcons.slidersHorizontal,
        kbd: 'F3',
        taille: DsButtonTaille.lg,
        variante: DsButtonVariante.secondaire,
        onPressed: _rechercheAvancee,
      ),
    ],
  );

  Widget _colonneProduits() {
    final produits = ref.watch(produitsPosProvider).value ?? const <Produit>[];
    final packs = (ref.watch(packsProvider).value ?? const <Pack>[]).where((p) => p.actif).toList();
    final categories = ref.watch(categoriesProvider).value ?? const <Categorie>[];
    final nomsCategories = {for (final c in categories) c.code: c.nom};
    final stocks = ref.watch(stocksCaisseProvider).value ?? const <String, double>{};
    final devise = ref.watch(deviseProvider);
    final r = _recherche.trim().toLowerCase();
    final liste = _disposition == DsVueModule.liste;
    final List<Widget> tuiles;
    if (_vue == _Vue.packs) {
      tuiles = [
        for (final k in packs)
          if (r.isEmpty || '${k.designation} ${k.code}'.toLowerCase().contains(r))
            DsProductTile(
              key: ValueKey('tuile_${k.code}'),
              nom: k.designation,
              code: k.code,
              prix: k.prixVente,
              categorie: l10n.posPack,
              devise: devise,
              enLigne: liste,
              onAjouter: () => unawaited(_ajouterPack(k)),
            ),
      ];
    } else {
      tuiles = [
        for (final p in produits)
          if ((_categorie == null || p.categorieCode == _categorie) &&
              (r.isEmpty ||
                  p.designation.toLowerCase().contains(r) ||
                  p.code.toLowerCase().contains(r) ||
                  (p.codeBarres?.contains(r) ?? false)))
            DsProductTile(
              key: ValueKey('tuile_${p.code}'),
              nom: p.designation,
              code: p.code,
              prix: p.prixVente,
              stock: stocks[p.code] ?? 0,
              categorie: nomsCategories[p.categorieCode],
              seuilBas: (p.seuilStock ?? 5).toDouble(),
              devise: devise,
              enLigne: liste,
              onAjouter: () => unawaited(_choisirProduit(p)),
              onEntree: () => unawaited(_entreeRapide(p)),
            ),
      ];
    }
    final c = context.ds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        _barreRecherche(),
        Row(
          spacing: DsSpacing.s3,
          children: [
            DsSegmentedControl<_Vue>(
              valeur: _vue,
              onChanged: (v) => setState(() => _vue = v),
              options: [
                DsOption(_Vue.produits, libelle: l10n.posProduits, icone: LucideIcons.package),
                DsOption(_Vue.packs, libelle: l10n.posPacks, icone: LucideIcons.gift),
              ],
            ),
            if (_vue == _Vue.produits)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DsSegmentedControl<String?>(
                    valeur: _categorie,
                    onChanged: (v) => setState(() => _categorie = v),
                    options: [
                      DsOption(null, libelle: l10n.posCategoriesToutes),
                      for (final cat in categories) DsOption(cat.code, libelle: cat.nom),
                    ],
                  ),
                ),
              )
            else
              const Spacer(),
            DsSegmentedControl<DsVueModule>(
              valeur: _disposition,
              onChanged: (v) => setState(() => _disposition = v),
              options: [
                DsOption(DsVueModule.grille, icone: LucideIcons.layoutGrid, tooltip: l10n.posAffichageGrille),
                DsOption(DsVueModule.liste, icone: LucideIcons.list, tooltip: l10n.posAffichageListe),
              ],
            ),
          ],
        ),
        Expanded(
          child: tuiles.isEmpty
              ? DsVide(
                  message: l10n.posAucunProduit,
                  icone: _vue == _Vue.packs ? LucideIcons.gift : LucideIcons.package,
                )
              : liste
              ? Container(
                  margin: const EdgeInsets.only(bottom: DsSpacing.s4),
                  decoration: BoxDecoration(
                    color: c.surfaceCard,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: ListView(padding: const EdgeInsets.all(6), children: tuiles),
                )
              : GridView(
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 48),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 196,
                    crossAxisSpacing: DsSpacing.s3,
                    mainAxisSpacing: DsSpacing.s3,
                  ),
                  children: tuiles,
                ),
        ),
      ],
    );
  }

  Widget _panier(PosEtat etat, {required bool large}) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final panier = etat.panier;
    final devise = ref.watch(deviseProvider);
    final peutPrix = ref.watch(permissionProvider(Permission.modifierPrixVente));
    final clients = ref.watch(clientsProvider).value ?? const <Client>[];
    final remises = _remisesGlobales();

    final tete = Row(
      spacing: DsSpacing.s2,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '${l10n.posPanierTitre} ',
              children: [
                TextSpan(
                  text: '· ${l10n.posVente(panier.id)}',
                  style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            style: t.cardTitle.copyWith(fontSize: 16),
          ),
        ),
        DsIconButton(
          icone: LucideIcons.packagePlus,
          tooltip: l10n.posNouveauProduit,
          taille: DsTailles.controleSm,
          onPressed: () => unawaited(_nouveauProduit()),
        ),
        DsIconButton(
          icone: LucideIcons.userPlus,
          tooltip: l10n.posNouveauClient,
          taille: DsTailles.controleSm,
          onPressed: () => unawaited(_nouveauClient()),
        ),
        DsIconButton(
          key: const ValueKey('panier_vider'),
          icone: LucideIcons.trash2,
          tooltip: l10n.posViderPanier,
          taille: DsTailles.controleSm,
          onPressed: panier.estVide ? null : _vider,
        ),
      ],
    );

    // Moyens visibles (Paramètres) ; les points seulement si le bonus fidélité est actif.
    final visibles = ref.watch(parametresPaiementProvider).value?.modes;
    final fidelite = ref.watch(parametresVenteProvider).value?.fideliteActive ?? false;
    final modes = [
      for (final v in Referentiel.modesPaiement.valeurs)
        if (v.stocke == panier.modePaiement ||
            ((visibles == null || visibles.contains(v.stocke)) && (v.stocke != 'Points' || fidelite)))
          v.stocke,
    ];
    final selects = Row(
      spacing: DsSpacing.s2,
      children: [
        Expanded(
          flex: 100,
          child: DsSelect<String>(
            key: const ValueKey('panier_client'),
            taille: DsTailles.controleSm,
            icone: LucideIcons.user,
            valeur: panier.clientCode,
            options: [
              'CLN0000',
              for (final cl in clients)
                if (!cl.estDePassage) cl.code,
            ],
            libelle: _nomClient,
            onChanged: (v) => ctrl.choisirClient(v ?? 'CLN0000'),
            onLookup: () => unawaited(_choisirClient()),
            lookupTooltip: l10n.posChoisirClient,
          ),
        ),
        Expanded(
          flex: 115,
          child: DsSelect<String?>(
            key: const ValueKey('panier_remise'),
            taille: DsTailles.controleSm,
            icone: LucideIcons.percent,
            valeur: panier.remiseCode,
            options: [null, for (final r in remises) r.code],
            libelle: (code) =>
                code == null ? l10n.posAucuneRemise : _libelleRemise(remises.firstWhere((r) => r.code == code)),
            onChanged: (code) => ctrl.appliquerRemise(remises.where((r) => r.code == code).firstOrNull),
            onLookup: () => unawaited(_choisirRemise()),
            lookupTooltip: l10n.posChoisirRemise,
          ),
        ),
        Expanded(
          flex: 80,
          child: DsSelect<String>(
            key: const ValueKey('panier_mode'),
            taille: DsTailles.controleSm,
            icone: LucideIcons.wallet,
            valeur: panier.modePaiement,
            options: modes,
            libelle: (m) => libelleRef(context, Referentiel.modesPaiement, m),
            iconeOption: (m) => switch (m) {
              'Espèces' => LucideIcons.banknote,
              'Carte' => LucideIcons.creditCard,
              'Chèque' => LucideIcons.fileSignature,
              'Virement' => LucideIcons.landmark,
              _ => LucideIcons.star,
            },
            onChanged: (m) => ctrl.choisirModePaiement(m ?? 'Espèces'),
          ),
        ),
      ],
    );

    final lignes = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (panier.lignes.isNotEmpty) const DsCartLineHeader(),
        Expanded(
          child: panier.estVide
              ? DsVide(
                  petit: true,
                  icone: LucideIcons.shoppingBasket,
                  message: l10n.posPanierVideTitre,
                  description: l10n.posPanierVideDesc,
                )
              : ListView.builder(
                  itemCount: panier.lignes.length,
                  itemBuilder: (_, i) {
                    final l = panier.lignes[i];
                    final colis = l.pack != null
                        ? l10n.posPack
                        : l.colis?.designation ??
                              (l.uniteVente == UniteVente.nombre ? l10n.posVendreNombre : l10n.posSelUnite);
                    return Tooltip(
                      message: l10n.posLigneAide,
                      waitDuration: const Duration(seconds: 1),
                      child: GestureDetector(
                        onDoubleTap: peutPrix ? () => unawaited(_modifierPrix(i)) : null,
                        child: DsCartLine(
                          key: ValueKey('ligne_$i'),
                          nom: l.designation,
                          code: l.pack?.code ?? l.produit.code,
                          prix: l.quantite == 0 ? l.prixUnitaire : l.total / l.quantite,
                          qte: l.quantite,
                          devise: devise,
                          colis: colis,
                          pieces: l.pack != null ? l.quantite : l.unitesStock + l.nombreStock,
                          selectionnee: _ligneSelectionnee == i,
                          onTap: () => setState(() => _ligneSelectionnee = i),
                          onColis: l.pack == null ? () => unawaited(_modifierColis(i)) : null,
                          onPlus: () => unawaited(_executer(() => ctrl.modifierQuantite(i, l.quantite + 1))),
                          onMoins: () => unawaited(_executer(() => ctrl.modifierQuantite(i, l.quantite - 1))),
                          onRetirer: () {
                            ctrl.retirerLigne(i);
                            setState(() => _ligneSelectionnee = null);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    final bas = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s2,
      children: [
        DsTotalPanel(
          key: const ValueKey('pos_total'),
          total: panier.totalNet,
          sousTotal: panier.totalBrut,
          remise: panier.totalRemise,
          articles: panier.pieces.round(),
          devise: devise,
        ),
        LayoutBuilder(
          builder: (context, contraintes) {
            final compact = contraintes.maxWidth < 480;
            final enregistrer = DsButton(
              key: const ValueKey('caisse_enregistrer'),
              libelle: l10n.posEnregistrer,
              icone: LucideIcons.save,
              kbd: compact ? null : 'F6',
              taille: DsButtonTaille.lg,
              pleineLargeur: compact,
              variante: DsButtonVariante.secondaire,
              onPressed: panier.estVide ? null : () => _encaisser(NatureEncaissement.enregistrer),
            );
            final blsc = DsButton(
              key: const ValueKey('caisse_blsc'),
              libelle: l10n.posBlSc,
              icone: LucideIcons.fileText,
              kbd: compact ? null : 'F5',
              taille: DsButtonTaille.lg,
              pleineLargeur: compact,
              variante: DsButtonVariante.secondaire,
              onPressed: panier.estVide ? null : () => _encaisser(NatureEncaissement.blsc),
            );
            final encaisser = DsButton(
              key: const ValueKey('caisse_encaisser'),
              libelle: l10n.posEncaisserBouton,
              icone: LucideIcons.receipt,
              kbd: 'F4',
              taille: DsButtonTaille.lg,
              pleineLargeur: true,
              onPressed: panier.estVide ? null : () => _encaisser(NatureEncaissement.ticket),
            );
            // Colonne étroite (panier élargi, 380 px) : Encaisser passe sur sa propre ligne.
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: DsSpacing.s2,
                children: [
                  Row(
                    spacing: DsSpacing.s2,
                    children: [
                      Expanded(child: enregistrer),
                      Expanded(child: blsc),
                    ],
                  ),
                  encaisser,
                ],
              );
            }
            return Row(
              spacing: DsSpacing.s2,
              children: [
                enregistrer,
                blsc,
                Expanded(child: encaisser),
              ],
            );
          },
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: DsSpacing.s4),
      padding: const EdgeInsets.all(DsSpacing.s4),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderXl,
        border: Border.all(color: c.borderDefault),
        boxShadow: c.shadowXs,
      ),
      child: large
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s6,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s3,
                    children: [
                      tete,
                      Expanded(child: lignes),
                    ],
                  ),
                ),
                SizedBox(
                  width: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s3,
                    children: [selects, const Spacer(), bas],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s3,
              children: [
                tete,
                selects,
                Expanded(child: lignes),
                bas,
              ],
            ),
    );
  }
}
