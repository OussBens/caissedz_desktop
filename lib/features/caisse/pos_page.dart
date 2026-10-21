import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/catalogue_ia_service.dart';
import '../../application/stock_service.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../commun/detail_prix.dart';
import '../entrees/entree_dialogs.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produit_form_dialog.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
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

enum _Vue { produits, favoris, packs }

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
    // Raccourcis globaux : la caisse les reçoit où que soit le focus (barre latérale, carte, panier…),
    // tant qu'aucun dialog n'est ouvert par-dessus.
    HardwareKeyboard.instance.addHandler(_clavierGlobal);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_clavierGlobal);
    _scan.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  AppLocalizations get l10n => AppLocalizations.of(context);
  PosController get ctrl => ref.read(posControllerProvider.notifier);
  String _da(double v) => formaterMontant(v, ref.read(deviseProvider));

  void _erreur(String message) =>
      unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: l10n.posTitre, message: message));

  Future<void> _executer(Future<void> Function() action, {bool transfertPropose = true}) async {
    try {
      await action();
    } on PosException catch (e) {
      if (transfertPropose && e.manque != null && await _proposerTransfert(e.manque!)) {
        return _executer(action, transfertPropose: false);
      }
      if (!mounted) return;
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

  /// Admin seulement : le magasin de la caisse manque de stock mais un autre magasin en a assez → propose un
  /// transfert du manque (document TRF) ; `true` si le transfert est fait (l'ajout est alors rejoué).
  Future<bool> _proposerTransfert(ManqueStock manque) async {
    if (!(ref.read(sessionProvider)?.estAdmin ?? false)) return false;
    final source = await ctrl.sourceTransfert(manque);
    if (source == null || !mounted) return false;
    final magasins = await ref.read(stockRepositoryProvider).magasins();
    final code = ref.read(posControllerProvider).magasinCode;
    final destination = magasins.where((m) => m.code == code).firstOrNull?.nom ?? code;
    String q(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    if (!mounted) return false;
    final ok = await afficherConfirmation(
      context,
      titre: l10n.posTransfertTitre,
      message: l10n.posTransfertQuestion,
      libelleConfirmer: l10n.posTransfertConfirmer,
      icone: LucideIcons.arrowLeftRight,
      contenu: _SchemaTransfert(
        produit: manque.produit.designation,
        source: source.magasin.nom,
        stockSource: q(source.quantite),
        destination: destination,
        stockDestination: q(_disponible(manque.produit).clamp(0, double.infinity)),
        quantite: q(manque.unites > 0 ? manque.unites : manque.nombre),
      ),
    );
    if (!ok || !mounted) return false;
    try {
      final transfert = await ctrl.transfererManque(manque, source.magasin.code);
      rafraichirStock(ref);
      ref.invalidate(stocksCaisseProvider);
      if (mounted) {
        afficherToast(context, titre: l10n.posTransfertFait(transfert), ton: DsToastTon.succes);
      }
      return true;
    } on StockException catch (e) {
      _erreur(messageErreurStock(l10n, e.erreur));
      return false;
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
    String? scanSuivant;
    final choix = await afficherSelectionProduit(
      context,
      produit: p,
      colis: _colisDe(p),
      stock: _disponible(p),
      depassementPermis: ref.read(sessionProvider)?.estAdmin ?? false,
      scanne: scanne,
      // Scan pendant que le dialog est ouvert : même produit → + 1, autre code → traité après validation.
      estMemeProduit: (code) async {
        final r = await ctrl.resoudre(code);
        return r != null && r.produit.code == p.code && r.colis == null && r.pack == null;
      },
      autreScan: (code) => scanSuivant = code,
    );
    if (choix != null && mounted) {
      await _executer(() => ctrl.ajouter(p, colis: choix.colis, nombre: choix.nombre, quantite: choix.quantite));
    }
    if (!mounted) return;
    _scanFocus.requestFocus();
    if (scanSuivant != null) {
      _scan.text = scanSuivant!;
      await _scanner();
    }
  }

  Future<void> _modifierColis(int index) async {
    final l = ref.read(posControllerProvider).panier.lignes[index];
    if (l.pack != null || l.estMontant) return;
    final choix = await afficherSelectionProduit(
      context,
      produit: l.produit,
      colis: _colisDe(l.produit),
      stock: _disponible(l.produit, sauf: l),
      depassementPermis: ref.read(sessionProvider)?.estAdmin ?? false,
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

  Future<void> _ajouterPack(Pack pack) => _executer(() => ctrl.ajouterPack(pack));

  /// Vente au montant : « Autre montant » (saisie) ou modification de la ligne existante ([index]).
  Future<void> _saisirMontant({int? index}) async {
    final lignes = ref.read(posControllerProvider).panier.lignes;
    final v = await afficherSaisieMontant(context, initial: index == null ? null : lignes[index].prixUnitaire);
    if (v == null || !mounted) return;
    if (index == null) {
      await _executer(() => ctrl.ajouterMontant(v));
    } else {
      ctrl.modifierMontant(index, v);
      if (v <= 0) setState(() => _ligneSelectionnee = null);
    }
  }

  Future<void> _scanner() async {
    final code = _scan.text.trim();
    if (code.isEmpty) return;
    final r = await ctrl.resoudre(code);
    if (!mounted) return;
    if (r == null) {
      if (RegExp(r'^\d{8,}$').hasMatch(code)) {
        // Le code est cherché dans le catalogue BENS pendant que le dialog est ouvert : trouvé, le formulaire
        // s'ouvre rempli (nom, nom arabe, marque, photo), sinon avec le seul code-barres.
        FicheProduitIa? fiche;
        final catalogue = SourceBens(client: ref.read(httpClientProvider))
            .rechercher(code)
            .then((f) => fiche = f, onError: (Object _) => null);
        final suite = await afficherProduitIntrouvable(context, code, catalogue: catalogue);
        if (!mounted) return;
        // Un vote sur un produit du catalogue à confirmer part tout de suite (gardé hors ligne).
        final tendance = ref.read(tendanceServiceProvider);
        switch (suite) {
          case SuiteIntrouvable.rechercher:
            await _rechercheAvancee();
          case SuiteIntrouvable.creer:
            await _creerProduitScanne(code, fiche);
          case SuiteIntrouvable.confirmer:
            unawaited(tendance.voter(code, 1));
            await _creerProduitScanne(code, fiche);
          case SuiteIntrouvable.refuser:
            unawaited(tendance.voter(code, -1));
            await _creerProduitScanne(code, null);
          case null:
            break;
        }
      }
      return;
    }
    _scan.clear();
    setState(() => _recherche = '');
    // Produit déjà au panier (à l'unité, hors pack) : le scan augmente sa quantité sans rouvrir le dialog.
    final lignes = ref.read(posControllerProvider).panier.lignes;
    final deja = r.colis == null && r.pack == null
        ? lignes.indexWhere(
            (l) =>
                l.produit.code == r.produit.code &&
                l.colis == null &&
                l.pack == null &&
                !l.estMontant &&
                l.uniteVente != UniteVente.nombre,
          )
        : -1;
    if (deja >= 0) {
      await _executer(() => ctrl.modifierQuantite(deja, lignes[deja].quantite + 1));
      if (mounted) setState(() => _ligneSelectionnee = deja);
    } else if (r.colis != null || r.pack != null) {
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

  /// Produit créé depuis un code-barres inconnu : rempli par le catalogue BENS s'il l'a trouvé ; enregistré
  /// avec un prix, il passe aussitôt au panier.
  Future<void> _creerProduitScanne(String code, FicheProduitIa? fiche) async {
    final p = await afficherFormulaireProduit(
      context,
      fiche: fiche,
      propose: fiche == null ? ProduitPropose(designation: '', codeBarres: code) : null,
    );
    ref.invalidate(produitsPosProvider);
    if (!mounted || p == null) return;
    _scan.clear();
    setState(() => _recherche = '');
    if (p.prixVente > 0 && p.actif) await _choisirProduit(p, scanne: true);
    _scanFocus.requestFocus();
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
        if (r.parMontant && r.estActive(n)) r,
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
      await ref
          .read(catalogueServiceProvider)
          .modifierProduit(
            // Prix saisi TTC ; le prix de vente du produit est HT.
            l.produit.copyWith(prixVente: ref.read(prixHtProvider)(l.produit, r.prix)),
          );
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
      vente = await ctrl.encaisser(creditAutorise: panier.clientCode != 'CLN0000', montantPaye: r.paye, mode: r.mode);
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
          : l10n.posToastEncaisse(l10n.posTicket, v.code),
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
      case NatureEncaissement.enregistrer:
        break;
    }
    _scanFocus.requestFocus();
  }

  // ------------------------------------------------------------------ Raccourcis

  bool _clavierGlobal(KeyEvent e) {
    if (!mounted || e is! KeyDownEvent) return false;
    // Un dialog (sélection, encaissement…) gère lui-même son clavier.
    if (Navigator.of(context, rootNavigator: true).canPop() || ModalRoute.of(context)?.isCurrent == false) {
      return false;
    }
    return _raccourci(e) == KeyEventResult.handled;
  }

  /// Un champ de saisie a le focus (scan, recherche, remise…) : lettres et touches d'édition lui reviennent.
  bool get _saisieEnCours {
    if (_scanFocus.hasFocus) return true;
    final ctx = FocusManager.instance.primaryFocus?.context;
    return ctx != null && (ctx.widget is EditableText || ctx.findAncestorStateOfType<EditableTextState>() != null);
  }

  KeyEventResult _raccourci(KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final ctrlPresse = HardwareKeyboard.instance.isControlPressed;
    final k = e.logicalKey;
    final etat = ref.read(posControllerProvider);
    final saisie = _saisieEnCours;
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
    } else if ((k == LogicalKeyboardKey.numpadAdd || k == LogicalKeyboardKey.add) &&
        ligne != null &&
        !ligne.estMontant &&
        !saisie) {
      unawaited(_executer(() => ctrl.modifierQuantite(i!, ligne.quantite + 1)));
    } else if ((k == LogicalKeyboardKey.numpadSubtract || k == LogicalKeyboardKey.minus) &&
        ligne != null &&
        !ligne.estMontant &&
        !saisie) {
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
              // Paramètres de la caisse (caisse et magasin du poste) : pas dans l'offre Basic (une caisse, un magasin).
              if (ref.watch(licenceProvider).couvre(NiveauLicence.avance))
                DsIconButton(
                  key: const ValueKey('caisse_parametres'),
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

  // Texte de recherche en minuscules de chaque produit (nom FR/AR, code, codes-barres), calculé une fois par liste
  // de produits et non à chaque frappe ou à chaque changement du panier.
  List<Produit>? _indexSource;
  Map<String, String> _index = const {};

  Map<String, String> _indexRecherche(List<Produit> produits) {
    if (identical(_indexSource, produits)) return _index;
    _indexSource = produits;
    return _index = {
      for (final p in produits) p.code: '${p.texteRecherche} ${p.code} ${p.codeBarres ?? ''}'.toLowerCase(),
    };
  }

  Widget _colonneProduits() {
    final produits = ref.watch(produitsPosProvider).value ?? const <Produit>[];
    final packs = (ref.watch(packsProvider).value ?? const <Pack>[]).where((p) => p.actif).toList();
    final categories = ref.watch(categoriesProvider).value ?? const <Categorie>[];
    final nomsCategories = {for (final c in categories) c.code: c.nom};
    final stocks = ref.watch(stocksCaisseProvider).value ?? const <String, double>{};
    final devise = ref.watch(deviseProvider);
    final admin = ref.watch(sessionProvider)?.estAdmin ?? false;
    // Stock affiché = stock du magasin − quantités déjà mises dans les paniers ouverts (avant l'encaissement).
    final etat = ref.watch(posControllerProvider);
    final favoris = ref.watch(favorisCaisseProvider).value ?? const <String>[];
    final r = _recherche.trim().toLowerCase();
    final liste = _disposition == DsVueModule.liste;
    final langue = Localizations.localeOf(context).languageCode;
    // Seuls les éléments filtrés sont calculés ici ; les tuiles sont construites à l'affichage (grille et liste
    // paresseuses) : des milliers de produits ne ralentissent ni la frappe ni le panier.
    final List<Pack> packsVisibles;
    final List<Produit> produitsVisibles;
    if (_vue == _Vue.packs) {
      produitsVisibles = const [];
      packsVisibles = [
        for (final k in packs)
          if (r.isEmpty || '${k.designation} ${k.code}'.toLowerCase().contains(r)) k,
      ];
    } else {
      packsVisibles = const [];
      // Favoris : dans l'ordre où ils ont été ajoutés, sans filtre de catégorie.
      final List<Produit> source;
      if (_vue == _Vue.favoris) {
        final parCode = {for (final p in produits) p.code: p};
        source = [for (final c in favoris) ?parCode[c]];
      } else {
        source = produits;
      }
      final index = _indexRecherche(produits);
      produitsVisibles = [
        for (final p in source)
          if ((_vue == _Vue.favoris || _categorie == null || p.categorieCode == _categorie) &&
              (r.isEmpty || (index[p.code]?.contains(r) ?? false)))
            p,
      ];
    }
    final nbTuiles = _vue == _Vue.packs ? packsVisibles.length : produitsVisibles.length;
    Widget tuile(BuildContext context, int i) {
      if (_vue == _Vue.packs) {
        final k = packsVisibles[i];
        return DsProductTile(
          key: ValueKey('tuile_${k.code}'),
          nom: k.designation,
          code: k.code,
          prix: k.prixVente,
          categorie: l10n.posPack,
          devise: devise,
          enLigne: liste,
          onAjouter: () => unawaited(_ajouterPack(k)),
        );
      }
      final p = produitsVisibles[i];
      return DsProductTile(
        key: ValueKey('tuile_${p.code}'),
        nom: p.nom(langue),
        code: p.code,
        // Tuile : le prix de vente seul (HT), sans TVA ni TTC ; le panier détaille le prix appliqué.
        prix: p.prixVente,
        stock: (stocks[p.code] ?? 0) - etat.unitesReservees(p.code),
        categorie: nomsCategories[p.categorieCode],
        image: imageProduit(p.image),
        seuilBas: (p.seuilStock ?? 5).toDouble(),
        devise: devise,
        enLigne: liste,
        ruptureCliquable: admin,
        onAjouter: () => unawaited(_choisirProduit(p)),
        onEntree: () => unawaited(_entreeRapide(p)),
      );
    }

    final c = context.ds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        _barreRecherche(),
        // Colonne étroite : Produits / Favoris / Packs se réduisent à leur icône (libellé en infobulle).
        LayoutBuilder(
          builder: (context, contraintes) {
            final etroit = contraintes.maxWidth < 600;
            DsOption<_Vue> option(_Vue v, String libelle, IconData icone) =>
                DsOption(v, libelle: etroit ? null : libelle, icone: icone, tooltip: etroit ? libelle : null);
            return Row(
              spacing: DsSpacing.s3,
              children: [
                DsSegmentedControl<_Vue>(
                  valeur: _vue,
                  onChanged: (v) => setState(() => _vue = v),
                  options: [
                    option(_Vue.produits, l10n.posProduits, LucideIcons.package),
                    option(_Vue.favoris, l10n.posFavoris, LucideIcons.star),
                    option(_Vue.packs, l10n.posPacks, LucideIcons.gift),
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
            );
          },
        ),
        Expanded(
          child: nbTuiles == 0
              ? DsVide(
                  message: _vue == _Vue.favoris && favoris.isEmpty ? l10n.posFavorisVide : l10n.posAucunProduit,
                  icone: switch (_vue) {
                    _Vue.packs => LucideIcons.gift,
                    _Vue.favoris => LucideIcons.star,
                    _Vue.produits => LucideIcons.package,
                  },
                )
              : liste
              ? Container(
                  margin: const EdgeInsets.only(bottom: DsSpacing.s4),
                  decoration: BoxDecoration(
                    color: c.surfaceCard,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: ListView.builder(padding: const EdgeInsets.all(6), itemCount: nbTuiles, itemBuilder: tuile),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 48),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 172,
                    crossAxisSpacing: DsSpacing.s3,
                    mainAxisSpacing: DsSpacing.s3,
                  ),
                  itemCount: nbTuiles,
                  itemBuilder: tuile,
                ),
        ),
      ],
    );
  }

  /// Montants rapides de la vente au montant (balance, articles non codifiés) : cumulés sur une seule ligne ;
  /// dans une colonne étroite, « Autre montant » se réduit à son icône pour que les montants restent lisibles.
  Widget _montantsRapides() {
    return Tooltip(
      message: l10n.posMontantAide,
      waitDuration: const Duration(seconds: 1),
      child: LayoutBuilder(
        builder: (context, contraintes) => Row(
          spacing: DsSpacing.s2,
          children: [
            Icon(LucideIcons.coins, size: 16, color: context.ds.colors.textMuted),
            for (final m in _montants)
              Expanded(
                child: DsButton(
                  key: ValueKey('montant_$m'),
                  libelle: isolerLtr('+$m'),
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.secondaire,
                  pleineLargeur: true,
                  onPressed: () => _executer(() => ctrl.ajouterMontant(m.toDouble())),
                ),
              ),
            DsButton(
              key: const ValueKey('montant_autre'),
              libelle: l10n.posMontantAutre,
              icone: LucideIcons.pencil,
              iconeSeule: contraintes.maxWidth < 440,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.fantome,
              onPressed: () => _saisirMontant(),
            ),
          ],
        ),
      ),
    );
  }

  static const _montants = [200, 500, 1000];

  Widget _panier(PosEtat etat, {required bool large}) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final panier = etat.panier;
    final devise = ref.watch(deviseProvider);
    final peutPrix = ref.watch(permissionProvider(Permission.modifierPrixVente));
    final taux = ref.watch(tauxAppliqueProvider);
    final affichage = ref.watch(parametresVenteProvider).value?.affichagePrix ?? ParametresVente.affichagePrixTous;
    final clients = ref.watch(clientsProvider).value ?? const <Client>[];
    final remises = _remisesGlobales();

    final titre = Text.rich(
      TextSpan(
        text: '${l10n.posPanierTitre} ',
        children: [
          TextSpan(
            text: '· ${l10n.posVente(panier.id)}',
            style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: t.cardTitle.copyWith(fontSize: 16),
    );

    // Nouveau produit, nouveau client, vider le panier, puis afficher / masquer les produits (à droite).
    final boutons = [
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
      DsIconButton(
        key: const ValueKey('caisse_basculer_produits'),
        icone: _afficherProduits ? LucideIcons.panelLeftClose : LucideIcons.panelLeftOpen,
        tooltip: _afficherProduits ? l10n.posMasquerProduits : l10n.posAfficherProduits,
        taille: DsTailles.controleSm,
        contour: _afficherProduits,
        actif: !_afficherProduits,
        onPressed: () => setState(() => _afficherProduits = !_afficherProduits),
      ),
    ];

    final selectClient = DsSelect<String>(
      key: const ValueKey('panier_client'),
      taille: DsTailles.controleSm,
      icone: LucideIcons.user,
      valeur: panier.clientCode,
      options: [
        'CLN0000',
        // Clients inactifs masqués (le client déjà choisi reste affiché).
        for (final cl in clients)
          if (!cl.estDePassage && (cl.actif || cl.code == panier.clientCode)) cl.code,
      ],
      libelle: _nomClient,
      onChanged: (v) => ctrl.choisirClient(v ?? 'CLN0000'),
      onLookup: () => unawaited(_choisirClient()),
      lookupTooltip: l10n.posChoisirClient,
    );
    final selectRemise = DsSelect<String?>(
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
    );

    // Titre et boutons en tête dans les deux dispositions. Produits affichés : client et remise sous le titre.
    // Produits masqués : les lignes à gauche, le panneau d'encaissement à droite (client, remise, puis montants,
    // total et encaissement).
    final tete = Row(
      spacing: DsSpacing.s2,
      children: [
        Expanded(child: titre),
        ...boutons,
      ],
    );
    final selects = Row(
      spacing: DsSpacing.s2,
      children: [
        Expanded(flex: 100, child: selectClient),
        Expanded(flex: 115, child: selectRemise),
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
                    final montant = l.estMontant;
                    // Ligne issue d'un pack : colonne colis « Pack », nom du pack sous le produit.
                    final colis = montant
                        ? l10n.posMontantColis
                        : l.pack != null
                        ? l10n.posPack
                        : l.colis?.designation ??
                              (l.uniteVente == UniteVente.nombre ? l10n.posVendreNombre : l10n.posSelUnite);
                    return Tooltip(
                      message: montant ? l10n.posMontantLigneAide : l10n.posLigneAide,
                      waitDuration: const Duration(seconds: 1),
                      child: GestureDetector(
                        onDoubleTap: montant
                            ? () => unawaited(_saisirMontant(index: i))
                            : peutPrix
                            ? () => unawaited(_modifierPrix(i))
                            : null,
                        child: DsCartLine(
                          key: ValueKey('ligne_$i'),
                          nom: montant ? l10n.posMontantTitre : l.designation,
                          code: l.pack != null ? '${l.produit.code} · ${l.pack!.designation}' : l.produit.code,
                          prix: l.quantite == 0 ? l.prixUnitaire : l.total / l.quantite,
                          // Prix HT, TVA et / ou TTC selon Paramètres › Affichage des prix.
                          detailPrix: montant
                              ? null
                              : texteDetailPrix(
                                  l10n,
                                  prix: l.quantite == 0 ? l.prixUnitaire : l.total / l.quantite,
                                  tauxPct: taux(l.produit),
                                  affichage: affichage,
                                  devise: devise,
                                ),
                          qte: l.quantite,
                          devise: devise,
                          colis: colis,
                          pieces: montant ? 0 : l.unitesStock + l.nombreStock,
                          selectionnee: _ligneSelectionnee == i,
                          onTap: () => setState(() => _ligneSelectionnee = i),
                          onColis: l.pack == null && !montant ? () => unawaited(_modifierColis(i)) : null,
                          onPlus: montant
                              ? null
                              : () => unawaited(_executer(() => ctrl.modifierQuantite(i, l.quantite + 1))),
                          onMoins: montant
                              ? null
                              : () => unawaited(_executer(() => ctrl.modifierQuantite(i, l.quantite - 1))),
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
        _montantsRapides(),
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
                children: [enregistrer, encaisser],
              );
            }
            return Row(
              spacing: DsSpacing.s2,
              children: [
                enregistrer,
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
              spacing: DsSpacing.s4,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s3,
                    children: [
                      SizedBox(height: DsTailles.controleSm, child: tete),
                      Expanded(child: lignes),
                    ],
                  ),
                ),
                Container(
                  key: const ValueKey('panier_encaissement'),
                  width: 420,
                  padding: const EdgeInsets.all(DsSpacing.s4),
                  decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s3,
                    children: [
                      DsFormRow(libelle: l10n.posClientLabel, empile: true, child: selectClient),
                      DsFormRow(libelle: l10n.dsPosRemise, empile: true, child: selectRemise),
                      const Spacer(),
                      bas,
                    ],
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

/// Schéma du transfert proposé : magasin source (stock) → quantité → magasin de la caisse (stock, manque).
class _SchemaTransfert extends StatelessWidget {
  const _SchemaTransfert({
    required this.produit,
    required this.source,
    required this.stockSource,
    required this.destination,
    required this.stockDestination,
    required this.quantite,
  });

  final String produit;
  final String source;
  final String stockSource;
  final String destination;
  final String stockDestination;
  final String quantite;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    Widget magasin(String titre, String nom, String stock, {String? manque}) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.s3),
        decoration: BoxDecoration(
          color: manque == null ? c.surfaceSunken : c.dangerTint,
          borderRadius: DsRadius.borderLg,
          border: Border.all(color: manque == null ? c.borderDefault : c.danger),
        ),
        child: Column(
          spacing: DsSpacing.s1,
          children: [
            Text(titre.toUpperCase(), style: t.overline.copyWith(color: c.textMuted)),
            Icon(LucideIcons.warehouse, size: DsTailles.iconeLg, color: manque == null ? c.primary : c.dangerFg),
            Text(nom, style: t.bodySmStrong, textAlign: TextAlign.center, maxLines: 2),
            Text(l10n.posTransfertStock(stock), style: t.caption.copyWith(color: c.textSecondary)),
            if (manque != null) DsBadge(libelle: l10n.posTransfertManque(manque), ton: DsBadgeTon.danger, petit: true),
          ],
        ),
      ),
    );
    return Column(
      key: const ValueKey('schema_transfert'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        Row(
          spacing: DsSpacing.s2,
          children: [
            Icon(LucideIcons.package, size: DsTailles.iconeSm, color: c.textMuted),
            Expanded(
              child: Text(produit, style: t.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              magasin(l10n.posTransfertDepuis, source, stockSource),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: DsSpacing.s1,
                  children: [
                    DsBadge(libelle: quantite, ton: DsBadgeTon.primaire),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl ? LucideIcons.arrowLeft : LucideIcons.arrowRight,
                      size: DsTailles.iconeLg,
                      color: c.primary,
                    ),
                  ],
                ),
              ),
              magasin(l10n.posTransfertVers, destination, stockDestination, manque: quantite),
            ],
          ),
        ),
      ],
    );
  }
}
