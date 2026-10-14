import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/produit.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../produits/produits_providers.dart';
import 'pos_controller.dart';
import 'pos_dialogs.dart';

/// Écran de caisse (POS) : produits, 5 paniers, paiements, raccourcis.
class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  final _scan = TextEditingController();
  final _scanFocus = FocusNode();
  String _recherche = '';
  String? _categorie;
  int? _ligneSelectionnee;
  String _mode = 'Espèces';
  String _montant = '';
  bool _credit = false;
  String? _nomClient;

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
  String get devise => ref.read(deviseProvider);

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
      _erreur(messageErreurVente(l10n, e, devise));
    }
  }

  Future<void> _scanner() async {
    final code = _scan.text.trim();
    if (code.isEmpty) return;
    await _executer(() async {
      final ok = await ctrl.scanner(code);
      if (!ok) {
        // Pas un code : filtre la grille.
        setState(() => _recherche = code);
        return;
      }
      _scan.clear();
      setState(() => _recherche = '');
    });
    _scanFocus.requestFocus();
  }

  Future<void> _ajouterPaiement({String? mode, double? montant}) async {
    final etat = ref.read(posControllerProvider);
    final m = montant ?? double.tryParse(_montant.replaceAll(',', '.')) ?? etat.panier.reste;
    if (m <= 0) return;
    ctrl.ajouterPaiement(mode ?? _mode, m);
    setState(() => _montant = '');
  }

  Future<void> _encaisser() async {
    final etat = ref.read(posControllerProvider);
    if (etat.session == null) {
      _erreur(l10n.posSessionAucune);
      return;
    }
    if (etat.panier.estVide) {
      _erreur(l10n.posErreurPanierVide);
      return;
    }
    // Sans paiement saisi : espèces pour le montant exact.
    if (etat.panier.paiements.isEmpty && !_credit) ctrl.ajouterPaiement('Espèces', etat.panier.totalNet);
    await _executer(() async {
      final v = await ctrl.encaisser(creditAutorise: _credit);
      setState(() {
        _ligneSelectionnee = null;
        _montant = '';
        _credit = false;
        _nomClient = null;
      });
      if (!mounted) return;
      unawaited(afficherResultatVente(context, ref, v));
    });
    _scanFocus.requestFocus();
  }

  Future<void> _choisirClient() async {
    final c = await afficherChoixClient(context, ref);
    if (c == null) return;
    ctrl.choisirClient(c.code);
    setState(() => _nomClient = c.estDePassage ? null : c.nom);
  }

  Future<void> _remiseGlobale() async {
    if (!(ref.read(sessionProvider)?.a(Permission.appliquerRemise) ?? false)) return;
    final pct = await afficherRemise(context, initiale: ref.read(posControllerProvider).panier.remiseGlobalePct);
    if (pct != null) ctrl.remiseGlobale(pct);
  }

  KeyEventResult _raccourci(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final ctrlPressed = HardwareKeyboard.instance.isControlPressed;
    final k = e.logicalKey;
    final etat = ref.read(posControllerProvider);
    void exact(String mode) => _ajouterPaiement(mode: mode, montant: etat.panier.reste);
    if (k == LogicalKeyboardKey.f1) {
      _scanFocus.requestFocus();
    } else if (k == LogicalKeyboardKey.f2) {
      unawaited(_choisirClient());
    } else if (k == LogicalKeyboardKey.f3) {
      unawaited(_remiseGlobale());
    } else if (k == LogicalKeyboardKey.f4) {
      exact('Espèces');
    } else if (k == LogicalKeyboardKey.f5) {
      exact('Carte');
    } else if (k == LogicalKeyboardKey.f6) {
      exact('Chèque');
    } else if (k == LogicalKeyboardKey.f7) {
      exact('Virement');
    } else if (k == LogicalKeyboardKey.f8) {
      setState(() => _mode = 'Points');
    } else if (k == LogicalKeyboardKey.f9) {
      unawaited(
        afficherCalculatrice(context).then((v) {
          if (v != null && mounted) setState(() => _montant = v.toStringAsFixed(2));
        }),
      );
    } else if (k == LogicalKeyboardKey.f10) {
      ctrl.viderPanier();
      setState(() => _ligneSelectionnee = null);
    } else if (k == LogicalKeyboardKey.f11) {
      unawaited(afficherAideRaccourcis(context));
    } else if (k == LogicalKeyboardKey.f12) {
      unawaited(_encaisser());
    } else if (ctrlPressed && k == LogicalKeyboardKey.keyN) {
      unawaited(_executer(() async => ctrl.nouveauPanier()));
    } else if (ctrlPressed && k == LogicalKeyboardKey.tab) {
      ctrl.panierSuivant();
    } else if (k == LogicalKeyboardKey.delete && _ligneSelectionnee != null && !_scanFocus.hasFocus) {
      ctrl.retirerLigne(_ligneSelectionnee!);
      setState(() => _ligneSelectionnee = null);
    } else if ((k == LogicalKeyboardKey.numpadAdd || k == LogicalKeyboardKey.add) &&
        _ligneSelectionnee != null &&
        !_scanFocus.hasFocus) {
      final l = etat.panier.lignes[_ligneSelectionnee!];
      unawaited(_executer(() => ctrl.modifierQuantite(_ligneSelectionnee!, l.quantite + 1)));
    } else if ((k == LogicalKeyboardKey.numpadSubtract || k == LogicalKeyboardKey.minus) &&
        _ligneSelectionnee != null &&
        !_scanFocus.hasFocus) {
      final l = etat.panier.lignes[_ligneSelectionnee!];
      unawaited(_executer(() => ctrl.modifierQuantite(_ligneSelectionnee!, l.quantite - 1)));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final etat = ref.watch(posControllerProvider);
    final panier = etat.panier;
    final session = ref.watch(sessionProvider);
    final devise = ref.watch(deviseProvider);
    final peutRemise = session?.a(Permission.appliquerRemise) ?? false;
    final peutPrix = session?.a(Permission.modifierPrix) ?? false;
    return Focus(
      onKeyEvent: _raccourci,
      child: Column(
        children: [
          _barreSession(etat, c, t),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _colonneProduits(c, t)),
                Container(width: 1, color: c.bordure),
                Expanded(
                  flex: 4,
                  child: _colonnePanier(etat, panier, c, t, devise, peutRemise: peutRemise, peutPrix: peutPrix),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barreSession(PosEtat etat, DsColors c, DsTypography t) {
    final s = etat.session;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.lg, vertical: DsSpacing.sm),
      decoration: BoxDecoration(
        color: s == null ? c.avertissementDoux : c.surface,
        border: Border(bottom: BorderSide(color: c.bordure)),
      ),
      child: Row(
        children: [
          Icon(
            s == null ? LucideIcons.triangleAlert : LucideIcons.badgeCheck,
            size: DsTailles.icone,
            color: s == null ? c.avertissement : c.succes,
          ),
          const SizedBox(width: DsSpacing.sm),
          Expanded(
            child: Text(
              s == null ? l10n.posSessionAucune : l10n.posSessionOuverte(s.code, s.caisseCode),
              style: t.petitFort,
            ),
          ),
          DsButton(
            libelle: l10n.posAide,
            icone: LucideIcons.keyboard,
            taille: DsButtonTaille.sm,
            variante: DsButtonVariante.fantome,
            onPressed: () {
              afficherAideRaccourcis(context);
            },
          ),
          const SizedBox(width: DsSpacing.xs),
          DsButton(
            libelle: l10n.posCalculatrice,
            icone: LucideIcons.calculator,
            taille: DsButtonTaille.sm,
            variante: DsButtonVariante.fantome,
            onPressed: () {
              afficherCalculatrice(context).then((v) {
                if (v != null && mounted) setState(() => _montant = v.toStringAsFixed(2));
              });
            },
          ),
          const SizedBox(width: DsSpacing.sm),
          if (s == null)
            DsButton(
              libelle: l10n.posSessionOuvrir,
              icone: LucideIcons.doorOpen,
              taille: DsButtonTaille.sm,
              onPressed: () {
                afficherOuvertureSession(context, ref);
              },
            )
          else
            DsButton(
              libelle: l10n.posSessionFermer,
              icone: LucideIcons.doorClosed,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.secondaire,
              onPressed: () {
                afficherFermetureSession(context, ref);
              },
            ),
        ],
      ),
    );
  }

  Widget _colonneProduits(DsColors c, DsTypography t) {
    final produits = ref.watch(produitsPosProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final devise = ref.watch(deviseProvider);
    final r = _recherche.trim().toLowerCase();
    final filtres = produits
        .where(
          (p) =>
              (_categorie == null || p.categorieCode == _categorie) &&
              (r.isEmpty ||
                  p.designation.toLowerCase().contains(r) ||
                  p.code.toLowerCase().contains(r) ||
                  (p.codeBarres?.contains(r) ?? false)),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.all(DsSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsTextField(
            controller: _scan,
            focusNode: _scanFocus,
            indice: l10n.posScan,
            iconePrefixe: LucideIcons.scanBarcode,
            autofocus: true,
            onSubmitted: (_) => _scanner(),
            onChanged: (v) => setState(() => _recherche = v),
          ),
          const SizedBox(height: DsSpacing.sm),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final cat in [null, ...categories.map((x) => x.code)]) ...[
                  DsButton(
                    libelle: cat == null ? l10n.posCategoriesToutes : categories.firstWhere((x) => x.code == cat).nom,
                    taille: DsButtonTaille.sm,
                    delaiGarde: Duration.zero,
                    variante: _categorie == cat ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                    onPressed: () => setState(() => _categorie = cat),
                  ),
                  const SizedBox(width: DsSpacing.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.sm),
          Expanded(
            child: filtres.isEmpty
                ? DsVide(message: l10n.posAucunProduit, icone: LucideIcons.package)
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 170,
                      mainAxisExtent: 92,
                      crossAxisSpacing: DsSpacing.sm,
                      mainAxisSpacing: DsSpacing.sm,
                    ),
                    itemCount: filtres.length,
                    itemBuilder: (_, i) => _tuileProduit(filtres[i], c, t, devise),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tuileProduit(Produit p, DsColors c, DsTypography t, String devise) {
    return Material(
      color: c.surface,
      borderRadius: DsRadius.borderMd,
      child: InkWell(
        key: ValueKey('tuile_${p.code}'),
        borderRadius: DsRadius.borderMd,
        onTap: () => _executer(() => ctrl.ajouter(p)),
        onLongPress: p.suiviNombre ? () => _executer(() => ctrl.ajouter(p, nombre: true)) : null,
        child: Container(
          padding: const EdgeInsets.all(DsSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: DsRadius.borderMd,
            border: Border.all(color: c.bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.designation, style: t.petitFort, maxLines: 2, overflow: TextOverflow.ellipsis),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formaterMontant(p.prixVente, devise),
                      style: t.petit.copyWith(color: c.primaire, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (p.suiviNombre)
                    Tooltip(
                      message: l10n.posVendreNombre,
                      child: Icon(LucideIcons.hash, size: 14, color: c.texteAttenue),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colonnePanier(
    PosEtat etat,
    Panier panier,
    DsColors c,
    DsTypography t,
    String devise, {
    required bool peutRemise,
    required bool peutPrix,
  }) {
    final modes = [for (final v in Referentiel.modesPaiement.valeurs) (v.stocke, libelleModePaiement(l10n, v.stocke))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Onglets des paniers
        Container(
          padding: const EdgeInsets.fromLTRB(DsSpacing.sm, DsSpacing.sm, DsSpacing.sm, 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.bordure)),
          ),
          child: Row(
            children: [
              for (final (i, p) in etat.paniers.indexed)
                Padding(
                  padding: const EdgeInsets.only(right: DsSpacing.xs),
                  child: InkWell(
                    onTap: () => ctrl.selectionnerPanier(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: i == etat.courant ? c.primaire : const Color(0x00000000), width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.posPanier(p.id),
                            style: (i == etat.courant ? t.petitFort : t.petit).copyWith(
                              color: i == etat.courant ? c.primaire : c.texteSecondaire,
                            ),
                          ),
                          if (p.lignes.isNotEmpty) ...[
                            const SizedBox(width: DsSpacing.xs),
                            DsBadge(libelle: '${p.lignes.length}', ton: DsBadgeTon.primaire),
                          ],
                          if (etat.paniers.length > 1) ...[
                            const SizedBox(width: DsSpacing.xs),
                            DsIconButton(
                              icone: LucideIcons.x,
                              tooltip: '×',
                              taille: 20,
                              onPressed: () => ctrl.fermerPanier(i),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              DsIconButton(
                icone: LucideIcons.plus,
                tooltip: l10n.posNouveauPanier,
                onPressed: etat.paniers.length >= maxPaniers ? null : () => _executer(() async => ctrl.nouveauPanier()),
              ),
            ],
          ),
        ),
        // Client + remise
        Padding(
          padding: const EdgeInsets.fromLTRB(DsSpacing.md, DsSpacing.sm, DsSpacing.md, 0),
          child: Row(
            children: [
              Expanded(
                child: DsButton(
                  libelle: _nomClient ?? l10n.posClientPassage,
                  icone: LucideIcons.user,
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.secondaire,
                  pleineLargeur: true,
                  onPressed: () {
                    _choisirClient();
                  },
                ),
              ),
              const SizedBox(width: DsSpacing.xs),
              DsButton(
                libelle: panier.remiseGlobalePct > 0
                    ? '−${panier.remiseGlobalePct.toStringAsFixed(0)} %'
                    : l10n.posRemise,
                icone: LucideIcons.percent,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.secondaire,
                onPressed: peutRemise
                    ? () {
                        _remiseGlobale();
                      }
                    : null,
              ),
            ],
          ),
        ),
        // Lignes
        Expanded(
          child: panier.estVide
              ? DsVide(message: l10n.posPanierVide, icone: LucideIcons.shoppingCart)
              : ListView.builder(
                  itemCount: panier.lignes.length,
                  itemBuilder: (_, i) {
                    final l = panier.lignes[i];
                    return CartLine(
                      key: ValueKey('ligne_$i'),
                      designation: l.designation,
                      sousTitre: l.uniteVente == UniteVente.nombre
                          ? l10n.posVendreNombre
                          : (l.colis != null ? l10n.posColis : (l.pack != null ? l10n.posPack : null)),
                      quantite: l.quantite,
                      prixUnitaire: l.prixUnitaire,
                      remisePct: l.remisePct,
                      total: l.total,
                      devise: devise,
                      selectionnee: _ligneSelectionnee == i,
                      onTap: () => setState(() => _ligneSelectionnee = i),
                      onPlus: () => _executer(() => ctrl.modifierQuantite(i, l.quantite + 1)),
                      onMoins: () => _executer(() => ctrl.modifierQuantite(i, l.quantite - 1)),
                      onSupprimer: () {
                        ctrl.retirerLigne(i);
                        setState(() => _ligneSelectionnee = null);
                      },
                    );
                  },
                ),
        ),
        // Totaux + paiement
        Container(
          padding: const EdgeInsets.all(DsSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceAttenuee,
            border: Border(top: BorderSide(color: c.bordure)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.posTotal, style: t.titreSm)),
                    Text(
                      formaterMontant(panier.totalNet, devise),
                      key: const ValueKey('pos_total'),
                      style: t.chiffreLg.copyWith(color: c.primaire),
                    ),
                  ],
                ),
                if (panier.totalRemise > 0)
                  Text(
                    '${l10n.posRemise} : −${formaterMontant(panier.totalRemise, devise)}',
                    style: t.petit.copyWith(color: c.texteSecondaire),
                  ),
                const SizedBox(height: DsSpacing.sm),
                PaymentPanel(
                  modes: modes,
                  modeCourant: _mode,
                  onMode: (m) => setState(() => _mode = m),
                  montantSaisi: _montant,
                  onMontantChange: (v) => setState(() => _montant = v),
                  onAjouter: _ajouterPaiement,
                  paiements: [for (final p in panier.paiements) (libelleModePaiement(l10n, p.mode), p.montant)],
                  onRetirerPaiement: ctrl.retirerPaiement,
                  totalNet: panier.totalNet,
                  verse: panier.verse,
                  reste: panier.reste,
                  monnaie: panier.monnaie,
                  devise: devise,
                  libelleVerse: l10n.posVerse,
                  libelleReste: l10n.posReste,
                  libelleMonnaie: l10n.posMonnaie,
                ),
                if (panier.clientCode != 'CLN0000')
                  DsSwitch(
                    valeur: _credit,
                    libelle: l10n.posCreditAutoriser,
                    onChanged: (v) => setState(() => _credit = v),
                  ),
                const SizedBox(height: DsSpacing.sm),
                Row(
                  children: [
                    DsButton(
                      libelle: l10n.posVider,
                      icone: LucideIcons.trash2,
                      variante: DsButtonVariante.fantome,
                      onPressed: panier.estVide
                          ? null
                          : () {
                              ctrl.viderPanier();
                              setState(() => _ligneSelectionnee = null);
                            },
                    ),
                    const SizedBox(width: DsSpacing.sm),
                    Expanded(
                      child: DsButton(
                        libelle: l10n.posEncaisser,
                        icone: LucideIcons.circleCheck,
                        taille: DsButtonTaille.lg,
                        variante: DsButtonVariante.succes,
                        pleineLargeur: true,
                        onPressed: etat.session == null || panier.estVide ? null : _encaisser,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
