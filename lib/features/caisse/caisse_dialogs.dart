import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/catalogue_ia_service.dart';
import '../../application/session_caisse_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_paiement.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import '../ventes/ventes_dialogs.dart';
import '../ventes/ventes_providers.dart';
import 'pos_controller.dart';
import 'pos_dialogs.dart';

/// Les dialogs de la caisse (`CaisseKit` du DS v2.2) : quantité et colis, encaisser, prix, recherche,
/// produit introuvable, caisse fermée, ouverture / clôture de session, mouvement manuel, ventes du jour,
/// recette produit, paramètres du poste, entrée rapide.

/// Heure « HH:mm ».
String formatHeure(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _da(WidgetRef ref, double v) => formaterMontant(v, ref.read(deviseProvider));

/// Hauteur stable des tableaux des dialogs de caisse (ventes du jour, recette) : suit la fenêtre.
double _hauteurTable(BuildContext context) => hauteurListeDialog(context, reserve: 380, min: 280);

String _qte(double v) => v == v.roundToDouble() ? v.toInt().toString() : formaterNombre(v, decimales: 2);

// ---------------------------------------------------------------------------------------------------------------
// 1 · Quantité et colis (ProduitSelectionDialog, 980 px, photo 320 px) : ajout automatique après 3 s.
// ---------------------------------------------------------------------------------------------------------------

/// Choix rendu par [afficherSelectionProduit] : colis (`null` = à l'unité) et quantité.
typedef SelectionProduit = ({Colis? colis, bool nombre, double quantite});

Future<SelectionProduit?> afficherSelectionProduit(
  BuildContext context, {
  required Produit produit,
  required List<Colis> colis,
  required double stock,
  bool scanne = false,
  Colis? colisInitial,
  bool nombreInitial = false,
  double quantiteInitiale = 1,
  bool modification = false,
  bool depassementPermis = false,
  Duration auto = const Duration(seconds: 3),
  Future<bool> Function(String code)? estMemeProduit,
  void Function(String code)? autreScan,
}) => afficherDialog<SelectionProduit>(
  context,
  builder: (_) => _SelectionProduitDialog(
    produit: produit,
    colis: colis,
    stock: stock,
    scanne: scanne,
    colisInitial: colisInitial,
    nombreInitial: nombreInitial,
    quantiteInitiale: quantiteInitiale,
    modification: modification,
    depassementPermis: depassementPermis,
    auto: modification ? Duration.zero : auto,
    estMemeProduit: estMemeProduit,
    autreScan: autreScan,
  ),
);

class _SelectionProduitDialog extends ConsumerStatefulWidget {
  const _SelectionProduitDialog({
    required this.produit,
    required this.colis,
    required this.stock,
    required this.scanne,
    required this.colisInitial,
    required this.nombreInitial,
    required this.quantiteInitiale,
    required this.modification,
    required this.depassementPermis,
    required this.auto,
    this.estMemeProduit,
    this.autreScan,
  });
  final Produit produit;
  final List<Colis> colis;
  final double stock;
  final bool scanne;
  final Colis? colisInitial;
  final bool nombreInitial;
  final double quantiteInitiale;
  final bool modification;

  /// Admin : une quantité au-delà du stock reste validable (la caisse propose alors un transfert).
  final bool depassementPermis;
  final Duration auto;

  /// Scan reçu pendant que le dialog est ouvert : même produit → quantité + 1 ; autre code → la sélection en
  /// cours est validée puis le code est rendu à la caisse ([autreScan]).
  final Future<bool> Function(String code)? estMemeProduit;
  final void Function(String code)? autreScan;

  @override
  ConsumerState<_SelectionProduitDialog> createState() => _SelectionProduitDialogState();
}

class _SelectionProduitDialogState extends ConsumerState<_SelectionProduitDialog> {
  static const _nombre = '#nombre';
  late String _colis = widget.nombreInitial ? _nombre : (widget.colisInitial?.code ?? '');
  late String _q = _q0(widget.quantiteInitiale);
  late bool _touche = widget.auto == Duration.zero;
  Timer? _minuteur;
  DateTime _debut = DateTime.now();
  Duration _reste = Duration.zero;

  /// Rafale de frappes rapides (lecteur de codes-barres) : caractères, heure de la dernière frappe et état de la
  /// quantité avant la rafale (rétabli si la rafale se révèle être un scan).
  final StringBuffer _rafale = StringBuffer();
  DateTime? _derniereFrappe;
  ({String q, bool remplacer, bool touche})? _avantRafale;
  static const Duration _ecartScan = Duration(milliseconds: 60);

  static String _q0(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    _reste = widget.auto;
    if (!_touche) _demarrerMinuteur();
  }

  void _demarrerMinuteur() {
    _minuteur?.cancel();
    _debut = DateTime.now();
    _minuteur = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final r = widget.auto - DateTime.now().difference(_debut);
      if (r <= Duration.zero) {
        _minuteur?.cancel();
        _valider(auto: true);
      } else {
        setState(() => _reste = r);
      }
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  /// Mémorise la frappe dans la rafale en cours (une pause de plus de [_ecartScan] en commence une nouvelle).
  void _noterFrappe(KeyEvent e) {
    final maintenant = DateTime.now();
    final car = e.character;
    if (car == null || car.isEmpty || car.codeUnitAt(0) < 0x20) return;
    if (_derniereFrappe == null || maintenant.difference(_derniereFrappe!) > _ecartScan) {
      _rafale.clear();
      _avantRafale = (q: _q, remplacer: _remplacer, touche: _touche);
    }
    _rafale.write(car);
    _derniereFrappe = maintenant;
  }

  /// Entrée qui termine une rafale rapide d'au moins 4 caractères : c'est un scan, pas une saisie de quantité.
  bool _finDeScan() {
    final fin = _derniereFrappe != null && DateTime.now().difference(_derniereFrappe!) <= _ecartScan * 2;
    final code = _rafale.toString().trim();
    _rafale.clear();
    _derniereFrappe = null;
    if (!fin || code.length < 4 || widget.estMemeProduit == null) return false;
    final avant = _avantRafale;
    if (avant != null) {
      setState(() {
        _q = avant.q;
        _remplacer = avant.remplacer;
        _touche = avant.touche;
      });
    }
    unawaited(_traiterScan(code, relancer: avant != null && !avant.touche));
    return true;
  }

  Future<void> _traiterScan(String code, {required bool relancer}) async {
    if (await widget.estMemeProduit!(code)) {
      if (!mounted) return;
      setState(() {
        _q = _q0(_quantite + 1);
        _remplacer = false;
      });
      if (relancer) _demarrerMinuteur();
      return;
    }
    if (!mounted) return;
    _minuteur?.cancel();
    if (_valider(auto: true)) widget.autreScan?.call(code);
  }

  void _toucher() {
    if (_touche) return;
    _minuteur?.cancel();
    setState(() => _touche = true);
  }

  /// La première frappe remplace la quantité proposée ; les suivantes la complètent.
  bool _remplacer = true;

  /// Saisie de la quantité au clavier physique (chiffres, pavé numérique, retour arrière, Échap = 0).
  bool _saisirClavier(KeyEvent e) {
    final k = e.logicalKey;
    final chiffre =
        _chiffres[k] ?? (e.character != null && RegExp(r'^[0-9]$').hasMatch(e.character!) ? e.character : null);
    if (chiffre != null) {
      setState(() {
        final base = _remplacer || _q == '0' ? '' : _q;
        _q = (base + chiffre).length > 6 ? base : base + chiffre;
        _remplacer = false;
      });
      return true;
    }
    if (k == LogicalKeyboardKey.backspace || k == LogicalKeyboardKey.delete) {
      setState(() {
        _q = _q.isEmpty ? '' : _q.substring(0, _q.length - 1);
        _remplacer = false;
      });
      return true;
    }
    return false;
  }

  static final Map<LogicalKeyboardKey, String> _chiffres = {
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.numpad9: '9',
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.digit9: '9',
  };

  Colis? get _colisChoisi => widget.colis.where((c) => c.code == _colis).firstOrNull;
  double get _quantite => double.tryParse(_q) ?? 0;
  double get _parColis => (_colisChoisi?.quantite ?? 1).toDouble();

  /// Prix TTC (prix de vente HT + TVA) de l'unité, d'une pièce et du colis choisi.
  double get _prixUnite => ref.read(prixCaisseProvider)(widget.produit);
  double get _prixPiece {
    final p = widget.produit;
    return p.nombreParUnite > 0 ? double.parse((_prixUnite / p.nombreParUnite).toStringAsFixed(2)) : _prixUnite;
  }

  double get _prix => _colis == _nombre
      ? _prixPiece
      : (_colisChoisi == null ? _prixUnite : ref.read(prixCaisseProvider)(widget.produit, _colisChoisi!.prixVente));

  /// Le stock au nombre est contrôlé à l'ajout (réservations comprises) ; ici, seules les unités.
  bool get _depasse => _colis != _nombre && _quantite * _parColis > widget.stock + 1e-9;
  bool get _bloque => _depasse && !widget.depassementPermis;

  /// Valide la sélection ; `false` si la quantité est invalide ou dépasse le stock (le dialog reste ouvert).
  bool _valider({bool auto = false}) {
    final q = auto && _quantite <= 0 ? 1.0 : _quantite;
    if (q <= 0 || (!widget.depassementPermis && _colis != _nombre && q * _parColis > widget.stock + 1e-9)) {
      if (auto) setState(() => _touche = true);
      return false;
    }
    Navigator.of(context).pop((colis: _colisChoisi, nombre: _colis == _nombre, quantite: q));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final p = widget.produit;
    final unite = _colis == _nombre ? l10n.posVendreNombre : (_colisChoisi?.designation ?? l10n.posSelUnite);
    final auto = widget.auto > Duration.zero;
    final montant = _da(ref, _quantite * _prix);
    // Même vignette que la carte de la grille (déjà décodée) : la photo s'affiche dès l'ouverture.
    final photo = imageProduit(p.image);
    const icone = DsIconBox(LucideIcons.package, taille: 96, tailleIcone: 40);
    Widget puce(IconData icone, String texte, {Color? couleur}) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(icone, size: DsTailles.iconeSm, color: couleur ?? c.iconMuted),
        Flexible(
          child: Text(texte, style: t.bodySm.copyWith(color: couleur ?? c.textSecondary)),
        ),
      ],
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _valider,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _valider,
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (_, e) {
          if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
          final k = e.logicalKey;
          if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
            return _finDeScan() ? KeyEventResult.handled : KeyEventResult.ignored;
          }
          _noterFrappe(e);
          _toucher();
          return _saisirClavier(e) ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: DsDialog(
          titre: widget.modification ? l10n.posSelTitreModif : l10n.posSelTitre,
          iconeData: widget.scanne ? LucideIcons.scanBarcode : LucideIcons.package,
          largeur: 980,
          actions: [
            DsButton(
              libelle: l10n.dsAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(context).pop(),
            ),
            DsButton(
              key: const ValueKey('selection_valider'),
              libelle: widget.modification ? l10n.posSelModifier(montant) : l10n.posSelAjouter(montant),
              icone: widget.modification ? LucideIcons.check : LucideIcons.plus,
              kbd: '↵',
              onPressed: _quantite <= 0 || _bloque ? null : _valider,
            ),
          ],
          contenu: Listener(
            onPointerDown: (_) => _toucher(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                if (auto)
                  AnimatedContainer(
                    duration: DsMotion.base,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _touche ? c.surfaceSunken : c.primaryTint,
                      borderRadius: DsRadius.borderMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        puce(
                          _touche ? LucideIcons.timerOff : LucideIcons.timer,
                          _touche
                              ? l10n.posSelAutoAnnule
                              : l10n.posSelAuto(
                                  '${_quantite <= 0 ? 1 : _q0(_quantite)} × $unite',
                                  '${(_reste.inMilliseconds / 1000).ceil()}',
                                ),
                          couleur: _touche ? c.textMuted : c.primaryTintFg,
                        ),
                        if (!_touche) DsProgressBar(valeur: _reste.inMilliseconds / widget.auto.inMilliseconds, max: 1),
                      ],
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, contraintes) {
                    final etroit = contraintes.maxWidth < 700;
                    final fiche = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        if (photo == null)
                          icone
                        else
                          ClipRRect(
                            key: const ValueKey('selection_photo'),
                            borderRadius: DsRadius.borderLg,
                            child: Image(
                              image: photo,
                              width: 320,
                              height: 320,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) => icone,
                            ),
                          ),
                        Text(p.designation, style: t.bodyStrong.copyWith(fontSize: 15, height: 1.3)),
                        puce(LucideIcons.tag, l10n.posSelParPiece(_da(ref, _prixUnite))),
                        puce(
                          _depasse ? LucideIcons.circleAlert : LucideIcons.boxes,
                          l10n.posSelStock(_qte(widget.stock)),
                          couleur: _depasse ? c.dangerFg : (widget.stock <= 5 ? c.warningFg : null),
                        ),
                      ],
                    );
                    final choix = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        Text(l10n.posSelColis, style: t.label.copyWith(color: c.textSecondary)),
                        DsChoiceCards<String>(
                          petit: true,
                          colonnes: 1,
                          valeur: _colis,
                          onChanged: (v) => setState(() {
                            _colis = v;
                            _q = '1';
                            _remplacer = true;
                          }),
                          options: [
                            DsOption('', libelle: l10n.posSelUnite, meta: '${_da(ref, _prixUnite)} / ${p.unite}'),
                            if (p.suiviNombre)
                              DsOption(_nombre, libelle: l10n.posVendreNombre, meta: _da(ref, _prixPiece)),
                            for (final k in widget.colis)
                              DsOption(
                                k.code,
                                libelle: l10n.posSelParColis(k.designation, '${k.quantite}'),
                                meta: _da(ref, ref.read(prixCaisseProvider)(p, k.prixVente)),
                              ),
                          ],
                        ),
                        DsKeyValueGrid(
                          colonnes: 2,
                          items: [
                            DsKeyValue(l10n.posSelQuantite, '${_q0(_quantite)} × $unite', fort: true),
                            DsKeyValue(l10n.posSelPieces, _qte(_quantite * _parColis), fort: true),
                          ],
                        ),
                      ],
                    );
                    final pave = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Text(l10n.posSelQuantite, style: t.label.copyWith(color: c.textSecondary)),
                        Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: DsRadius.borderMd,
                            border: Border.all(color: _depasse ? c.danger : c.borderFocus),
                          ),
                          child: Text(
                            _q.isEmpty ? '0' : _q,
                            key: const ValueKey('selection_quantite'),
                            style: t.montantXl.copyWith(fontSize: 26),
                          ),
                        ),
                        DsNumpad(
                          valeur: _q,
                          decimales: false,
                          hauteurTouche: 40,
                          montantsRapides: const [],
                          onChanged: (v) => setState(() {
                            _q = v;
                            _remplacer = false;
                          }),
                        ),
                        if (_depasse)
                          puce(
                            LucideIcons.circleAlert,
                            l10n.posSelStockInsuffisant(_qte(widget.stock)),
                            couleur: c.dangerFg,
                          ),
                      ],
                    );
                    if (etroit) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: [fiche, choix, pave],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        SizedBox(width: 320, child: fiche),
                        Expanded(child: choix),
                        SizedBox(width: 232, child: pave),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 1 bis · Produit en rupture (560 px) : à la place de « Quantité et colis » quand il n'en reste plus.
// ---------------------------------------------------------------------------------------------------------------

/// Suite choisie devant un produit en rupture ; `null` : fermé.
enum SuiteRupture { entreeRapide, transferer }

/// Produit dont la quantité disponible dans le magasin de la caisse est 0 : rien n'est ajouté. Propose l'entrée
/// rapide et, quand [ailleurs] est donné (admin, un autre magasin en a), le transfert.
Future<SuiteRupture?> afficherProduitEnRupture(
  BuildContext context, {
  required Produit produit,
  ({String magasin, double quantite})? ailleurs,
}) {
  final l10n = AppLocalizations.of(context);
  final langue = Localizations.localeOf(context).languageCode;
  return afficherDialog<SuiteRupture>(
    context,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        key: const ValueKey('dialog_rupture'),
        titre: l10n.posRuptureTitre,
        iconeData: LucideIcons.packageX,
        ton: DsDialogTon.danger,
        largeur: 560,
        message: l10n.posRuptureMessage(produit.nom(langue)),
        actions: [
          DsButton(
            libelle: l10n.communFermer,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          DsButton(
            key: const ValueKey('rupture_entree'),
            libelle: l10n.entRapideTitre,
            icone: LucideIcons.packagePlus,
            variante: ailleurs == null ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(SuiteRupture.entreeRapide),
          ),
          if (ailleurs != null)
            DsButton(
              key: const ValueKey('rupture_transferer'),
              libelle: l10n.posRuptureTransferer,
              icone: LucideIcons.arrowLeftRight,
              onPressed: () => Navigator.of(ctx).pop(SuiteRupture.transferer),
            ),
        ],
        contenu: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsSpacing.s3,
          children: [
            Container(
              padding: const EdgeInsets.all(DsSpacing.s4),
              decoration: BoxDecoration(color: c.dangerTint, borderRadius: DsRadius.borderLg),
              child: Row(
                spacing: DsSpacing.s3,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produit.nom(langue), style: t.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(produit.code, style: t.caption.copyWith(color: c.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.posRuptureQuantite, style: t.caption.copyWith(color: c.dangerFg)),
                      Text(
                        '0',
                        key: const ValueKey('rupture_quantite'),
                        style: t.bodyStrong.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: c.dangerFg,
                          fontFeatures: DsTypography.tabular,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (ailleurs != null)
              Row(
                spacing: DsSpacing.s2,
                children: [
                  Icon(LucideIcons.warehouse, size: 16, color: c.textSecondary),
                  Expanded(
                    child: Text(
                      l10n.posRuptureAilleurs(ailleurs.magasin, _qte(ailleurs.quantite)),
                      style: t.bodySm.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------------------------------------------
// 2 · Encaisser / Enregistrer (EncaisserDialog, 860 px).
// ---------------------------------------------------------------------------------------------------------------

/// Nature de l'encaissement : ticket (F4) ou enregistrement à crédit (F6).
enum NatureEncaissement { ticket, enregistrer }

/// Montant payé et moyen de paiement choisis ; `null` si annulé.
typedef ResultatEncaissement = ({double paye, String mode});

/// Moyens de paiement proposés à l'encaissement (§9.16) : ceux rendus visibles dans Paramètres ; « Points »
/// seulement si le bonus fidélité est actif et le client identifié.
List<String> modesPaiementProposes(WidgetRef ref, {required bool comptoir}) {
  final visibles = ref.watch(parametresPaiementProvider).value?.modes ?? const ParametresPaiement().modes;
  final fidelite = ref.watch(parametresVenteProvider).value?.fideliteActive ?? false;
  return [
    for (final v in Referentiel.modesPaiement.valeurs)
      if (visibles.contains(v.stocke) && (v.stocke != 'Points' || (fidelite && !comptoir))) v.stocke,
  ];
}

IconData iconeModePaiement(String mode) => switch (mode) {
  'Espèces' => LucideIcons.banknote,
  'Carte' => LucideIcons.creditCard,
  'Chèque' => LucideIcons.fileSignature,
  'Virement' => LucideIcons.landmark,
  _ => LucideIcons.star,
};

Future<ResultatEncaissement?> afficherEncaisser(
  BuildContext context, {
  required NatureEncaissement nature,
  required Panier panier,
  required int numeroVente,
  required String nomClient,
  required String caissier,
}) => afficherDialog<ResultatEncaissement>(
  context,
  builder: (_) => _EncaisserDialog(
    nature: nature,
    panier: panier,
    numeroVente: numeroVente,
    nomClient: nomClient,
    caissier: caissier,
  ),
);

class _EncaisserDialog extends ConsumerStatefulWidget {
  const _EncaisserDialog({
    required this.nature,
    required this.panier,
    required this.numeroVente,
    required this.nomClient,
    required this.caissier,
  });
  final NatureEncaissement nature;
  final Panier panier;
  final int numeroVente;
  final String nomClient;
  final String caissier;

  @override
  ConsumerState<_EncaisserDialog> createState() => _EncaisserDialogState();
}

class _EncaisserDialogState extends ConsumerState<_EncaisserDialog> {
  bool get _enregistrer => widget.nature == NatureEncaissement.enregistrer;
  late String _paye = _enregistrer ? '0' : formaterNombre(widget.panier.aPayer, decimales: 2);
  late bool _complet = !_enregistrer;
  late String _mode = widget.panier.modePaiement;

  bool get _comptoir => widget.panier.clientCode == 'CLN0000';

  /// À encaisser : le net, moins ce qui est déjà payé sur une vente modifiée.
  double get _total => widget.panier.aPayer;
  double get _payeN => _complet ? _total : DsPaymentPanel.lire(_paye);
  bool get _bloque =>
      (_comptoir && _payeN < _total - 1e-9 && !_enregistrer) || (!_complet && _payeN <= 0 && !_enregistrer);

  void _valider() {
    if (_bloque) return;
    Navigator.of(context).pop((paye: _payeN, mode: _mode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.panier;
    final modes = modesPaiementProposes(ref, comptoir: _comptoir);
    if (!modes.contains(_mode)) _mode = modes.first;
    final (titre, icone, ok) = switch (widget.nature) {
      NatureEncaissement.ticket => (l10n.posEncTicketTitre, LucideIcons.receipt, l10n.posEncTicketOk),
      NatureEncaissement.enregistrer => (l10n.posEncSaveTitre, LucideIcons.save, l10n.posEnregistrer),
    };
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _valider,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _valider,
      },
      child: DsDialog(
        titre: titre,
        iconeData: icone,
        largeur: 860,
        actions: [
          DsButton(
            libelle: l10n.dsAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DsButton(
            key: const ValueKey('encaisser_valider'),
            libelle: ok,
            icone: _enregistrer ? LucideIcons.check : LucideIcons.printer,
            kbd: _enregistrer ? null : '↵',
            onPressed: _bloque || p.estVide ? null : _valider,
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            if (!_enregistrer)
              DsFormRow(
                libelle: l10n.posInfoPaiement,
                largeurLibelle: 110,
                child: DsChoiceCards<String>(
                  key: const ValueKey('encaisser_mode'),
                  petit: true,
                  valeur: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                  options: [
                    for (final m in modes)
                      DsOption(
                        m,
                        libelle: libelleRef(context, Referentiel.modesPaiement, m),
                        icone: iconeModePaiement(m),
                      ),
                  ],
                ),
              ),
            DsPaymentPanel(
              total: _total,
              // Vente modifiée : le total est ce qui reste à payer, le détail est dans les infos.
              sousTotal: p.totalRemise > 0 && p.remplacement == null ? p.totalBrut : null,
              remise: p.remplacement == null ? p.totalRemise : 0,
              devise: ref.read(deviseProvider),
              paye: _paye,
              onPayeChanged: (v) => setState(() => _paye = v),
              paiementComplet: _complet,
              onPaiementCompletChanged: (v) => setState(() {
                _complet = v;
                if (!v) _paye = formaterNombre(_total, decimales: 2);
              }),
              creditAutorise: !_comptoir || _enregistrer,
              infos: [
                DsInfoPaiement(l10n.posInfoVente, l10n.posVente(widget.numeroVente)),
                if (p.remplacement case final r?) ...[
                  DsInfoPaiement(l10n.posInfoRemplace, r.code),
                  DsInfoPaiement(l10n.posInfoTotalTicket, _da(ref, p.totalNet)),
                  DsInfoPaiement(l10n.posInfoDejaPaye, _da(ref, p.dejaPaye)),
                ],
                DsInfoPaiement(l10n.posClientLabel, widget.nomClient),
                DsInfoPaiement(l10n.posInfoDate, formatDateHeure.format(DateTime.now())),
                DsInfoPaiement(l10n.posInfoProduits, '${p.lignes.length}'),
                DsInfoPaiement(l10n.posInfoPieces, _qte(p.pieces)),
                DsInfoPaiement(l10n.posInfoCaissier, widget.caissier),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 3 · Modifier le prix (ModifPrixDialog, 640 px) : mot de passe + portée (ce ticket / tout le produit).
// ---------------------------------------------------------------------------------------------------------------

/// Nouveau prix et portée (`true` = mettre à jour le prix catalogue).
typedef ModifPrix = ({double prix, bool catalogue});

Future<ModifPrix?> afficherModifPrix(BuildContext context, {required PanierLigne ligne, required bool voirAchat}) =>
    afficherDialog<ModifPrix>(
      context,
      builder: (_) => _ModifPrixDialog(ligne: ligne, voirAchat: voirAchat),
    );

class _ModifPrixDialog extends ConsumerStatefulWidget {
  const _ModifPrixDialog({required this.ligne, required this.voirAchat});
  final PanierLigne ligne;
  final bool voirAchat;

  @override
  ConsumerState<_ModifPrixDialog> createState() => _ModifPrixDialogState();
}

class _ModifPrixDialogState extends ConsumerState<_ModifPrixDialog> {
  late final _prix = TextEditingController(text: formaterNombre(widget.ligne.prixUnitaire, decimales: 2));
  final _mdp = TextEditingController();
  bool _catalogue = false;
  String? _erreurPrix;
  String? _erreurMdp;

  double get _achat {
    final l = widget.ligne;
    final base = l.produit.prixAchat;
    if (l.colis != null) return base * l.colis!.quantite;
    if (l.uniteVente == UniteVente.nombre && l.produit.nombreParUnite > 0) return base / l.produit.nombreParUnite;
    return base;
  }

  @override
  void dispose() {
    _prix.dispose();
    _mdp.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final l10n = AppLocalizations.of(context);
    final v = lireNombre(_prix.text);
    setState(() {
      _erreurPrix = v == null || v <= 0 ? l10n.posPrixInvalide : null;
      _erreurMdp = _mdp.text.isEmpty ? l10n.posPrixMdpRequis : null;
    });
    if (_erreurPrix != null || _erreurMdp != null) return;
    final ok = await ref
        .read(authServiceProvider)
        .verifierMotDePasse(ref.read(utilisateurCourantCodeProvider), _mdp.text);
    if (!mounted) return;
    if (!ok) {
      setState(() => _erreurMdp = l10n.posPrixMdpIncorrect);
      return;
    }
    // Contrôle « vente sous achat » (Paramètres) : interdire, avertir ou autoriser.
    final regle = (await ref.read(parametresVenteProvider.future)).venteSousAchat;
    if (!mounted) return;
    if (v! < _achat && regle == ParametresVente.venteSousAchatInterdire) {
      setState(() => _erreurPrix = l10n.posPrixSousAchatInterdit);
      return;
    }
    if (v < _achat && regle == ParametresVente.venteSousAchatAvertir) {
      final confirme = await afficherConfirmation(
        context,
        titre: l10n.posPrixSousAchatTitre,
        message: l10n.posPrixSousAchatMsg(_da(ref, _achat), _da(ref, v)),
        libelleConfirmer: l10n.posPrixSousAchatOk,
        genre: DsConfirmGenre.avertissement,
      );
      if (!confirme || !mounted) return;
    }
    Navigator.of(context)
        .pop((prix: v, catalogue: _catalogue && widget.ligne.colis == null && widget.ligne.pack == null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = lireNombre(_prix.text) ?? 0;
    final l = widget.ligne;
    return DsDialog(
      titre: l10n.posPrixTitre,
      iconeData: LucideIcons.tag,
      largeur: 640,
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('prix_enregistrer'),
          libelle: l10n.posEnregistrer,
          icone: LucideIcons.check,
          onPressed: _valider,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          DsFormRow(
            libelle: l10n.dsPosProduit,
            child: DsTextField(valeurInitiale: '${l.produit.code} · ${l.designation}', actif: false),
          ),
          if (widget.voirAchat)
            DsFormRow(
              libelle: l10n.posPrixAchat,
              child: DsTextField(
                valeurInitiale: formaterNombre(_achat, decimales: 2),
                actif: false,
                suffixeTexte: ref.read(deviseProvider),
              ),
            ),
          DsFormRow(
            libelle: l10n.posPrixVente,
            obligatoire: true,
            erreur: _erreurPrix,
            aide: !widget.voirAchat
                ? null
                : (v < _achat ? l10n.posPrixSousAchat : l10n.posPrixMarge(_da(ref, v - _achat))),
            child: DsTextField(
              key: const ValueKey('prix_valeur'),
              controller: _prix,
              numerique: true,
              autofocus: true,
              suffixeTexte: ref.read(deviseProvider),
              onChanged: (_) => setState(() {}),
            ),
          ),
          DsFormRow(
            libelle: l10n.posPrixMotDePasse,
            obligatoire: true,
            erreur: _erreurMdp,
            child: DsTextField(
              key: const ValueKey('prix_mdp'),
              controller: _mdp,
              obscur: true,
              indice: l10n.posPrixMotDePasseIndice,
              onSubmitted: (_) => _valider(),
            ),
          ),
          if (l.colis == null && l.pack == null)
            DsFormRow(
              libelle: l10n.posPrixPortee,
              alignerDebut: true,
              child: DsChoiceCards<bool>(
                petit: true,
                valeur: _catalogue,
                onChanged: (v) => setState(() => _catalogue = v),
                options: [
                  DsOption(false, libelle: l10n.posPrixPorteeTicket, description: l10n.posPrixPorteeTicketDesc),
                  DsOption(true, libelle: l10n.posPrixPorteeProduit, description: l10n.posPrixPorteeProduitDesc),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 3 bis · Vente au montant : saisie d'un montant libre (ajout ou modification de la ligne « Vente au montant »).
// ---------------------------------------------------------------------------------------------------------------

/// Montant saisi (`null` = annulé). En [modification], 0 est accepté (la ligne est retirée).
Future<double?> afficherSaisieMontant(BuildContext context, {double? initial}) =>
    afficherDialog<double>(context, builder: (_) => _SaisieMontantDialog(initial: initial));

class _SaisieMontantDialog extends ConsumerStatefulWidget {
  const _SaisieMontantDialog({this.initial});
  final double? initial;

  @override
  ConsumerState<_SaisieMontantDialog> createState() => _SaisieMontantDialogState();
}

class _SaisieMontantDialogState extends ConsumerState<_SaisieMontantDialog> {
  late final _montant = TextEditingController(
    text: widget.initial == null ? '' : formaterNombre(widget.initial!, decimales: 2),
  );
  String? _erreur;

  bool get _modification => widget.initial != null;

  @override
  void dispose() {
    _montant.dispose();
    super.dispose();
  }

  void _valider() {
    final v = lireNombre(_montant.text);
    if (v == null || v < 0 || (v == 0 && !_modification)) {
      setState(() => _erreur = AppLocalizations.of(context).posMontantInvalide);
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsDialog(
      titre: _modification ? l10n.posMontantModifier : l10n.posMontantAutre,
      iconeData: LucideIcons.coins,
      largeur: 440,
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('montant_valider'),
          libelle: l10n.communValider,
          icone: LucideIcons.check,
          onPressed: _valider,
        ),
      ],
      contenu: DsFormRow(
        libelle: l10n.posMontantChamp,
        obligatoire: true,
        erreur: _erreur,
        child: DsTextField(
          key: const ValueKey('montant_valeur'),
          controller: _montant,
          numerique: true,
          autofocus: true,
          suffixeTexte: ref.read(deviseProvider),
          onSubmitted: (_) => _valider(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 4 · Rechercher un produit (RechercheProduitDialog) : sélection multiple.
// ---------------------------------------------------------------------------------------------------------------

Future<List<Produit>?> afficherRechercheProduit(
  BuildContext context,
  WidgetRef ref, {
  required List<Produit> produits,
  required Map<String, double> stocks,
}) => afficherDialog<List<Produit>>(
  context,
  builder: (_) => _RechercheProduitDialog(produits: produits, stocks: stocks),
);

/// Recherche avancée (F3) : texte, catégorie, fourchettes de quantité en stock et de prix de vente.
class _RechercheProduitDialog extends ConsumerStatefulWidget {
  const _RechercheProduitDialog({required this.produits, required this.stocks});
  final List<Produit> produits;
  final Map<String, double> stocks;

  @override
  ConsumerState<_RechercheProduitDialog> createState() => _RechercheProduitDialogState();
}

class _RechercheProduitDialogState extends ConsumerState<_RechercheProduitDialog> {
  String? _categorie;
  final _qteMin = TextEditingController();
  final _qteMax = TextEditingController();
  final _prixMin = TextEditingController();
  final _prixMax = TextEditingController();

  @override
  void dispose() {
    for (final c in [_qteMin, _qteMax, _prixMin, _prixMax]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _lire(TextEditingController c) => lireNombre(c.text);

  bool get _actifs => _categorie != null || [_qteMin, _qteMax, _prixMin, _prixMax].any((c) => c.text.trim().isNotEmpty);

  bool _retenu(Produit p) {
    if (_categorie != null && p.categorieCode != _categorie) return false;
    final q = widget.stocks[p.code] ?? 0;
    if (_lire(_qteMin) case final m? when q < m) return false;
    if (_lire(_qteMax) case final m? when q > m) return false;
    final prix = ref.read(prixCaisseProvider)(p);
    if (_lire(_prixMin) case final m? when prix < m) return false;
    if (_lire(_prixMax) case final m? when prix > m) return false;
    return true;
  }

  void _reinitialiser() => setState(() {
    _categorie = null;
    for (final c in [_qteMin, _qteMax, _prixMin, _prixMax]) {
      c.clear();
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.ds.typo;
    final c = context.ds.colors;
    final listeCategories = ref.watch(categoriesProvider).value ?? const <Categorie>[];
    final categories = {for (final c in listeCategories) c.code: c.nom};
    final hauteur = hauteurListeDialog(context, reserve: 380, min: 260);
    Widget fourchette(
      String libelle,
      String cle,
      TextEditingController min,
      TextEditingController max,
      String? suffixe,
    ) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Text(libelle, style: t.label.copyWith(color: c.textSecondary)),
        SizedBox(
          width: 92,
          child: DsTextField(
            key: ValueKey('${cle}_min'),
            controller: min,
            numerique: true,
            indice: l10n.posRechMin,
            suffixeTexte: suffixe,
            onChanged: (_) => setState(() {}),
          ),
        ),
        Text('–', style: t.label.copyWith(color: c.textMuted)),
        SizedBox(
          width: 92,
          child: DsTextField(
            key: ValueKey('${cle}_max'),
            controller: max,
            numerique: true,
            indice: l10n.posRechMax,
            suffixeTexte: suffixe,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
    return DsPickerDialog<Produit>(
      titre: l10n.posRechTitre,
      icone: LucideIcons.search,
      multiple: true,
      largeur: 980,
      hauteurMax: hauteur,
      hauteurFixe: true,
      cle: (p) => p.code,
      elements: widget.produits,
      filtre: _retenu,
      filtres: Wrap(
        spacing: DsSpacing.s4,
        runSpacing: DsSpacing.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: DsSelect<String?>(
              key: const ValueKey('recherche_categorie'),
              icone: LucideIcons.tag,
              valeur: _categorie,
              options: [null, for (final c in listeCategories) c.code],
              libelle: (v) => v == null ? l10n.posRechToutesCategories : (categories[v] ?? v),
              recherche: rechercheListe(context, ref, ListeMetier.categorie),
              onChanged: (v) => setState(() => _categorie = v),
            ),
          ),
          fourchette(l10n.produitsColStock, 'recherche_qte', _qteMin, _qteMax, null),
          fourchette(l10n.dsPosPrix, 'recherche_prix', _prixMin, _prixMax, ref.read(deviseProvider)),
          DsIconButton(
            key: const ValueKey('recherche_reinitialiser'),
            icone: LucideIcons.rotateCcw,
            tooltip: l10n.dsReinitialiser,
            contour: true,
            onPressed: _actifs ? _reinitialiser : null,
          ),
        ],
      ),
      libelle: (p) => p.texteRecherche,
      indiceRecherche: l10n.posRechIndice,
      libelleConfirmer: l10n.posRechAjouter,
      colonnes: [
        DsColonnePicker(libelle: l10n.dsPosCode, valeur: (p) => p.code, mono: true, attenue: true, largeur: 110),
        DsColonnePicker(
          libelle: l10n.dsPosProduit,
          valeur: (p) => p.nom(Localizations.localeOf(context).languageCode),
          fort: true,
        ),
        DsColonnePicker(
          libelle: l10n.produitsColCategorie,
          valeur: (p) => categories[p.categorieCode] ?? p.categorieCode,
        ),
        DsColonnePicker(libelle: l10n.produitsColStock, valeur: (p) => _qte(widget.stocks[p.code] ?? 0), largeur: 80),
        DsColonnePicker(
          libelle: l10n.dsPosPrix,
          valeur: (p) => _da(ref, ref.read(prixCaisseProvider)(p)),
          largeur: 110,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 5 · Produit introuvable / caisse fermée.
// ---------------------------------------------------------------------------------------------------------------

/// Ce que le caissier choisit devant un code-barres inconnu du poste.
enum SuiteIntrouvable {
  /// Recherche avancée (F3).
  rechercher,

  /// Créer le produit (rempli par le catalogue BENS s'il l'a trouvé).
  creer,

  /// Produit du catalogue à confirmer : « c'est bien ce produit » (+1), puis le créer rempli.
  confirmer,

  /// Produit du catalogue à confirmer : « ce n'est pas ce produit » (−1), puis le créer avec le seul code-barres.
  refuser,
}

/// Code-barres inconnu à la caisse ; `null` : fermé.
///
/// [catalogue] : la recherche du code dans le catalogue BENS, lancée par l'appelant ; pendant qu'elle tourne,
/// le dialog l'indique, puis montre le produit trouvé (le formulaire s'ouvrira rempli). Un produit ajouté au
/// catalogue par une autre boutique, pas encore confirmé, est présenté avec la question « est-ce bien ce
/// produit ? » : la réponse compte dans sa confirmation.
Future<SuiteIntrouvable?> afficherProduitIntrouvable(
  BuildContext context,
  String code, {
  Future<FicheProduitIa?>? catalogue,
}) {
  final l10n = AppLocalizations.of(context);
  return afficherDialog<SuiteIntrouvable>(
    context,
    builder: (ctx) => FutureBuilder<FicheProduitIa?>(
      future: catalogue,
      builder: (ctx, etat) {
        final fiche = etat.data;
        final cherche = catalogue != null && etat.connectionState != ConnectionState.done;
        final aConfirmer = fiche?.aConfirmer ?? false;
        return DsDialog(
          titre: fiche == null
              ? l10n.posIntrouvableTitre
              : (aConfirmer ? l10n.posCatalogueAConfirmerTitre : l10n.posCatalogueTrouveTitre),
          iconeData: fiche == null ? LucideIcons.searchX : LucideIcons.packageSearch,
          ton: fiche == null ? DsDialogTon.avertissement : DsDialogTon.info,
          largeur: 560,
          actions: [
            DsButton(
              libelle: l10n.communFermer,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            DsButton(
              libelle: l10n.posRecherche,
              icone: LucideIcons.search,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(SuiteIntrouvable.rechercher),
            ),
            if (aConfirmer) ...[
              DsButton(
                key: const ValueKey('introuvable_refuser'),
                libelle: l10n.posCatalogueNon,
                icone: LucideIcons.thumbsDown,
                variante: DsButtonVariante.secondaire,
                onPressed: () => Navigator.of(ctx).pop(SuiteIntrouvable.refuser),
              ),
              DsButton(
                key: const ValueKey('introuvable_confirmer'),
                libelle: l10n.posCatalogueOui,
                icone: LucideIcons.thumbsUp,
                onPressed: () => Navigator.of(ctx).pop(SuiteIntrouvable.confirmer),
              ),
            ] else
              DsButton(
                key: const ValueKey('introuvable_creer'),
                libelle: fiche == null ? l10n.posIntrouvableCreer : l10n.posCatalogueCreer,
                icone: LucideIcons.packagePlus,
                onPressed: () => Navigator.of(ctx).pop(SuiteIntrouvable.creer),
              ),
          ],
          contenu: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DsSpacing.s3,
            children: [
              DsBarcodeCard(
                valeur: code,
                format: CodesBarres.ean13Valide(code) ? DsBarcodeFormat.ean13 : DsBarcodeFormat.code128,
              ),
              if (cherche)
                Row(
                  key: const ValueKey('introuvable_recherche_bens'),
                  spacing: DsSpacing.s2,
                  children: [
                    const DsSpinner(),
                    Text(
                      l10n.posCatalogueRecherche,
                      style: ctx.ds.typo.bodySm.copyWith(color: ctx.ds.colors.textSecondary),
                    ),
                  ],
                )
              else if (fiche != null) ...[
                _FicheCatalogue(fiche),
                if (aConfirmer)
                  Text(
                    l10n.posCatalogueAConfirmerQuestion(fiche.confirmation ?? 0, fiche.seuilConfirmation ?? 5),
                    key: const ValueKey('introuvable_question'),
                    style: ctx.ds.typo.body,
                  ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Produit trouvé dans le catalogue BENS : photo, désignation, quantité (à part du nom), nom arabe, marque.
class _FicheCatalogue extends StatelessWidget {
  const _FicheCatalogue(this.fiche);
  final FicheProduitIa fiche;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final photo = imageProduit(fiche.image);
    const icone = DsIconBox(LucideIcons.package, taille: 72, tailleIcone: 32);
    return DsCard(
      key: const ValueKey('introuvable_fiche_bens'),
      child: Row(
        spacing: DsSpacing.s3,
        children: [
          if (photo == null)
            icone
          else
            ClipRRect(
              borderRadius: DsRadius.borderMd,
              child: Image(image: photo, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, _, _) => icone),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DsSpacing.s1,
              children: [
                Text(fiche.designation, style: t.bodyStrong),
                if (fiche.quantite != null)
                  Text(
                    fiche.typeQuantite == null
                        ? fiche.quantite!
                        : '${libelleRef(context, Referentiel.typesTaille, fiche.typeQuantite!)} : ${fiche.quantite}',
                    key: const ValueKey('introuvable_quantite'),
                    style: t.bodySm,
                  ),
                if (fiche.designationAr != null)
                  Text(fiche.designationAr!, textDirection: TextDirection.rtl, style: t.body),
                if (fiche.marque != null) Text(fiche.marque!, style: t.bodySm.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `true` si l'utilisateur choisit d'ouvrir la caisse.
Future<bool> afficherCaisseFermee(BuildContext context, {required String caisse, String? description}) async {
  final l10n = AppLocalizations.of(context);
  final r = await afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.posFermeeTitre,
      iconeData: LucideIcons.lock,
      ton: DsDialogTon.avertissement,
      message: description ?? l10n.posFermeeDesc(caisse),
      largeur: 480,
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        DsButton(
          key: const ValueKey('caisse_fermee_ouvrir'),
          libelle: l10n.posOuvrirCaisse,
          icone: LucideIcons.lockOpen,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
      contenu: const SizedBox.shrink(),
    ),
  );
  return r ?? false;
}

/// §8.4 : achat, retour et versement exigent une session ouverte. Sans session, propose de l'ouvrir
/// (`CaisseFermeeDialog` puis ouverture) ; `true` si une session est ouverte au retour.
Future<bool> exigerSessionCaisse(BuildContext context, WidgetRef ref) async {
  if (await ref.read(sessionCaisseServiceProvider).courante() != null) return true;
  final caisses = await ref.read(caissesListeProvider.future);
  if (!context.mounted) return false;
  final code = ref.read(posControllerProvider).caisseCode;
  final nom = caisses.where((c) => c.code == code).firstOrNull?.nom ?? caisses.firstOrNull?.nom ?? '';
  final ouvrir = await afficherCaisseFermee(
    context,
    caisse: nom,
    description: AppLocalizations.of(context).communFermeeDesc(nom),
  );
  if (!ouvrir || !context.mounted) return false;
  return afficherOuvertureCaisse(context, ref);
}

// ---------------------------------------------------------------------------------------------------------------
// 6 · Ouverture / clôture de session, mouvement manuel.
// ---------------------------------------------------------------------------------------------------------------

Future<void> _erreurSession(BuildContext context, String titre, SessionException e) {
  final l10n = AppLocalizations.of(context);
  return afficherResultat(
    context,
    type: DsResultatType.erreur,
    titre: titre,
    message: messageErreurSession(l10n, e.erreur),
  );
}

/// Ouvre une session (OuvertureCaisseDialog, 560 px) sur [caisseCode] ou la caisse du poste ; le fond est
/// pré-rempli par le solde initial de la caisse (§9.13). Retourne `true` si la session est ouverte.
Future<bool> afficherOuvertureCaisse(BuildContext context, WidgetRef ref, {String? caisseCode}) async {
  final l10n = AppLocalizations.of(context);
  final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  if (!context.mounted || caisses.isEmpty) return false;
  final preferee = caisseCode ?? ref.read(posControllerProvider).caisseCode;
  var caisse = caisses.where((c) => c.code == preferee).firstOrNull ?? caisses.first;
  final fond = TextEditingController(text: formaterNombre(caisse.soldeInitial, decimales: 2));
  final session = ref.read(sessionProvider);
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: l10n.posOuvertureTitre(caisse.nom),
        iconeData: LucideIcons.lockOpen,
        largeur: 560,
        actions: [
          DsButton(
            libelle: l10n.dsAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            key: const ValueKey('ouverture_valider'),
            libelle: l10n.posOuvertureOk,
            icone: LucideIcons.lockOpen,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (ref.read(plusieursCaissesProvider))
              DsFormRow(
                libelle: l10n.posSessionCaisse,
                obligatoire: true,
                child: DsSelect<Caisse>(
                  valeur: caisse,
                  options: caisses,
                  libelle: (c) => c.nom,
                  recherche: (options, valeur) async {
                    final code = await choisirDansListe(
                      context,
                      ref,
                      ListeMetier.caisse,
                      codes: {for (final c in options) c.code},
                      valeur: valeur?.code,
                    );
                    return options.where((c) => c.code == code).firstOrNull;
                  },
                  onChanged: (v) => setState(() {
                    caisse = v ?? caisse;
                    fond.text = formaterNombre(caisse.soldeInitial, decimales: 2);
                  }),
                ),
              ),
            DsFormRow(
              libelle: l10n.posOuvertureSolde,
              obligatoire: true,
              child: DsTextField(
                key: const ValueKey('ouverture_fond'),
                controller: fond,
                numerique: true,
                autofocus: true,
                suffixeTexte: ref.read(deviseProvider),
                onSubmitted: (_) => Navigator.of(ctx).pop(true),
              ),
            ),
            DsFormRow(
              libelle: l10n.posOuverturePar,
              child: DsTextField(
                valeurInitiale: '${session?.utilisateur.nom ?? ''} · ${formatDateHeure.format(DateTime.now())}',
                actif: false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return false;
  try {
    final montant = lireNombre(fond.text) ?? -1;
    await ref.read(posControllerProvider.notifier).ouvrirSession(caisseCode: caisse.code, fondInitial: montant);
    rafraichirCaisse(ref);
    if (context.mounted) {
      afficherToast(context, titre: l10n.posCaisseOuverte, description: l10n.posCaisseOuverteDesc(_da(ref, montant)));
    }
    return true;
  } on SessionException catch (e) {
    if (context.mounted) await _erreurSession(context, l10n.posOuvertureOk, e);
    return false;
  }
}

/// Clôture la session (ClotureSessionDialog, 680 px) : solde théorique, solde réel compté, écart.
/// Sans [sessionCible], clôture la session du poste.
Future<void> afficherClotureSession(
  BuildContext context,
  WidgetRef ref, {
  required String nomCaisse,
  SessionCaisse? sessionCible,
}) async {
  final l10n = AppLocalizations.of(context);
  final duPoste = ref.read(posControllerProvider).session;
  final session = sessionCible ?? duPoste;
  if (session == null) return;
  final service = ref.read(sessionCaisseServiceProvider);
  final attendu = await service.especesAttendues(session.code);
  final parType = await service.especesAttenduesParType(session.code);
  if (!context.mounted) return;
  // Un tiroir ne contient jamais moins de 0 : le compté proposé est plafonné à 0 (l'écart devient un manquant).
  final reel = TextEditingController(text: formaterNombre(attendu < 0 ? 0 : attendu, decimales: 2));
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final c = ctx.ds.colors;
        final t = ctx.ds.typo;
        final ecart = (lireNombre(reel.text) ?? 0) - attendu;
        final juste = ecart.abs() < 0.005;
        final (fond, couleur, icone, etat) = juste
            ? (c.surfaceSunken, c.textSecondary, LucideIcons.circleCheck, l10n.posClotureJuste)
            : ecart > 0
            ? (c.successTint, c.successFg, LucideIcons.trendingUp, l10n.posClotureExcedent)
            : (c.dangerTint, c.dangerFg, LucideIcons.trendingDown, l10n.posClotureManquant);
        Widget ligne(String libelle, double v, {bool total = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          color: total ? c.surfaceSunken : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  libelle,
                  style: (total ? t.bodyStrong : t.bodySm).copyWith(color: total ? null : c.textSecondary),
                ),
              ),
              Text(
                _da(ref, v),
                style: (total ? t.bodyStrong : t.bodySmStrong).copyWith(fontFeatures: DsTypography.tabular),
              ),
            ],
          ),
        );
        return DsDialog(
          titre: l10n.posClotureTitre(nomCaisse),
          iconeData: LucideIcons.lock,
          largeur: 680,
          actions: [
            DsButton(
              libelle: l10n.dsAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              key: const ValueKey('cloture_valider'),
              libelle: l10n.posClotureOk,
              icone: LucideIcons.lock,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: DsRadius.borderMd,
                  border: Border.all(color: c.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ligne(l10n.posClotureFond, parType[TypesMouvementCaisse.fondInitial] ?? 0),
                    // Toutes les espèces entrées et sorties du tiroir depuis l'ouverture, par type.
                    for (final MapEntry(key: type, value: v) in parType.entries)
                      if (type != TypesMouvementCaisse.fondInitial && v.abs() >= 0.005) ...[
                        Divider(height: 1, color: c.borderSubtle),
                        ligne(libelleTypeMouvementCaisse(l10n, type), v),
                      ],
                    Divider(height: 1, color: c.borderDefault),
                    ligne(l10n.posClotureTheorique, attendu, total: true),
                  ],
                ),
              ),
              if (attendu < -0.005)
                DsNote(
                  key: const ValueKey('cloture_negatif'),
                  ton: DsBadgeTon.avertissement,
                  icone: LucideIcons.triangleAlert,
                  texte: l10n.posClotureNegatif,
                ),
              DsFormRow(
                libelle: l10n.posClotureReel,
                obligatoire: true,
                child: DsTextField(
                  key: const ValueKey('cloture_reel'),
                  controller: reel,
                  numerique: true,
                  autofocus: true,
                  suffixeTexte: ref.read(deviseProvider),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              AnimatedContainer(
                duration: DsMotion.base,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(icone, size: 18, color: couleur),
                    Expanded(
                      child: Text(l10n.posClotureEcart(etat), style: t.bodySmStrong.copyWith(color: couleur)),
                    ),
                    Text(
                      '${ecart > 0 && !juste
                          ? '+ '
                          : ecart < 0 && !juste
                          ? '− '
                          : ''}${_da(ref, ecart.abs())}',
                      style: t.bodyStrong.copyWith(fontSize: 18, color: couleur, fontFeatures: DsTypography.tabular),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final montant = lireNombre(reel.text) ?? -1;
    final s = session.code == duPoste?.code
        ? await ref.read(posControllerProvider.notifier).fermerSession(montantCompte: montant)
        : await ref.read(sessionCaisseServiceProvider).fermer(montantCompte: montant, sessionCode: session.code);
    rafraichirCaisse(ref);
    if (!context.mounted) return;
    final e = s.ecart ?? 0;
    afficherToast(
      context,
      titre: l10n.posClotureFaite,
      description: e.abs() < 0.005 ? l10n.posClotureJuste : l10n.posClotureEcartToast(_da(ref, e)),
      ton: e.abs() < 0.005 ? DsToastTon.succes : DsToastTon.avertissement,
    );
  } on SessionException catch (e) {
    if (context.mounted) await _erreurSession(context, l10n.posClotureOk, e);
  }
}

/// Mouvement manuel de caisse (MouvementManuelDialog, 620 px) sur [caisseCode], sinon sur la caisse choisie.
Future<void> afficherMouvementManuel(BuildContext context, WidgetRef ref, {String? caisseCode}) async {
  final l10n = AppLocalizations.of(context);
  final caisses = caisseCode != null
      ? const <Caisse>[]
      : (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  if (!context.mounted || (caisseCode == null && caisses.isEmpty)) return;
  var caisse = caisseCode ?? caisses.first.code;
  var entree = true;
  var mode = 'Espèces';
  final montant = TextEditingController();
  final motif = TextEditingController();
  final modes = [
    for (final v in Referentiel.modesPaiement.valeurs)
      if (v.stocke != 'Points') v.stocke,
  ];
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: l10n.posMvtTitre,
        iconeData: LucideIcons.arrowLeftRight,
        largeur: 620,
        actions: [
          DsButton(
            libelle: l10n.dsAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            key: const ValueKey('mouvement_valider'),
            libelle: l10n.posEnregistrer,
            icone: LucideIcons.check,
            onPressed: (lireNombre(montant.text) ?? 0) <= 0 || motif.text.trim().isEmpty
                ? null
                : () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (caisses.isNotEmpty)
              if (ref.read(plusieursCaissesProvider))
                DsFormRow(
                  libelle: l10n.posSessionCaisse,
                  obligatoire: true,
                  child: DsSelect<String>(
                    cle: const ValueKey('mouvement_caisse'),
                    valeur: caisse,
                    options: [for (final c in caisses) c.code],
                    libelle: (code) => caisses.firstWhere((c) => c.code == code).nom,
                    recherche: rechercheListe(context, ref, ListeMetier.caisse),
                    onChanged: (v) => setState(() => caisse = v ?? caisse),
                  ),
                ),
            DsFormRow(
              libelle: l10n.posMvtType,
              obligatoire: true,
              child: DsSegmentedControl<bool>(
                pleineLargeur: true,
                valeur: entree,
                onChanged: (v) => setState(() => entree = v),
                options: [
                  DsOption(true, libelle: l10n.posMvtEntree, icone: LucideIcons.arrowDownLeft),
                  DsOption(false, libelle: l10n.posMvtSortie, icone: LucideIcons.arrowUpRight),
                ],
              ),
            ),
            DsFormRow(
              libelle: l10n.mouvementColMontant,
              obligatoire: true,
              child: DsTextField(
                key: const ValueKey('mouvement_montant'),
                controller: montant,
                numerique: true,
                autofocus: true,
                indice: '0,00',
                suffixeTexte: ref.read(deviseProvider),
                onChanged: (_) => setState(() {}),
              ),
            ),
            DsFormRow(
              libelle: l10n.posModePaiement,
              child: DsSelect<String>(
                valeur: mode,
                options: modes,
                libelle: (m) => libelleRef(ctx, Referentiel.modesPaiement, m),
                onChanged: (v) => setState(() => mode = v ?? mode),
              ),
            ),
            DsFormRow(
              libelle: l10n.posMvtMotif,
              obligatoire: true,
              child: DsTextField(
                key: const ValueKey('mouvement_motif'),
                controller: motif,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final m = lireNombre(montant.text) ?? 0;
  try {
    await ref
        .read(caisseServiceProvider)
        .mouvementManuel(caisseCode: caisse, apport: entree, montant: m, mode: mode, commentaire: motif.text.trim());
    rafraichirCaisse(ref);
    if (!context.mounted) return;
    afficherToast(
      context,
      titre: l10n.posMvtFait,
      description: l10n.posMvtFaitDesc(entree ? l10n.posMvtEntree : l10n.posMvtSortie, _da(ref, m)),
    );
  } on Object catch (e) {
    if (!context.mounted) return;
    await afficherResultat(context, type: DsResultatType.erreur, titre: l10n.posMvtTitre, message: '$e');
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 7 · Ventes du jour (VentesDuJourDialog) et recette par produit (RecetteProduitDialog).
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherVentesDuJour(BuildContext context, WidgetRef ref, {required String nomCaisse}) =>
    afficherDialog<void>(context, builder: (_) => _VentesDuJourDialog(nomCaisse: nomCaisse));

class _VentesDuJourDialog extends ConsumerStatefulWidget {
  const _VentesDuJourDialog({required this.nomCaisse});
  final String nomCaisse;

  @override
  ConsumerState<_VentesDuJourDialog> createState() => _VentesDuJourDialogState();
}

class _VentesDuJourDialogState extends ConsumerState<_VentesDuJourDialog> {
  String _q = '';
  String? _mode;

  /// Éditer : la vente passe dans un panier de la caisse (client modifiable, produits à ajouter).
  Future<void> _editer(PanierResume p) async {
    if (await chargerVenteEnCaisse(context, ref, p.vente.code) && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aujourdhui = DateTime.now();
    final debut = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    final session = ref.watch(posControllerProvider).session;
    final noms = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    final tous =
        ref.watch(paniersProvider((debut, debut.add(const Duration(days: 1))))).value ?? const <PanierResume>[];
    final duPoste = tous.where((p) => session == null || p.vente.sessionCode == session.code).toList();
    final q = _q.trim().toLowerCase();
    final lignes = duPoste
        .where(
          (p) =>
              (_mode == null || p.modes.contains(_mode)) &&
              (q.isEmpty ||
                  '${p.vente.code} ${nomClientPanier(l10n, p.vente.clientCode, noms)}'.toLowerCase().contains(q)),
        )
        .toList();
    final actifs = lignes.where((p) => p.statut != 'annule');
    double somme(double Function(PanierResume) f) => actifs.fold(0.0, (s, p) => s + f(p));
    final colonnes = <DsColonne<PanierResume>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (p) => p.vente.code, mono: true, attenue: true),
      DsColonne(
        id: 'heure',
        libelle: l10n.posVdjHeure,
        valeur: (p) => p.vente.date,
        cellule: (_, p) => Text(formatHeure(p.vente.date)),
      ),
      DsColonne(
        id: 'client',
        libelle: l10n.posClientLabel,
        valeur: (p) => nomClientPanier(l10n, p.vente.clientCode, noms),
        fort: true,
        flex: 2,
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.dsPosMontant,
        numerique: true,
        valeur: (p) => p.vente.totalNet,
        cellule: (_, p) => Text(_da(ref, p.vente.totalNet)),
      ),
      DsColonne(
        id: 'reste',
        libelle: l10n.posReste,
        numerique: true,
        valeur: (p) => p.resteActuel,
        cellule: (_, p) => Text(_da(ref, p.resteActuel)),
      ),
      DsColonne(id: 'mode', libelle: l10n.posInfoPaiement, valeur: (p) => libelleModes(context, p.modes)),
      DsColonne(
        id: 'statut',
        libelle: l10n.retoursEtat,
        valeur: (p) => p.statut,
        cellule: (_, p) => BadgeStatut(p.statut),
      ),
      DsColonne(
        id: 'editer',
        libelle: '',
        valeur: (_) => null,
        triable: false,
        masquable: false,
        largeur: 104,
        cellule: (_, p) => p.annule || p.nbRetours > 0
            ? const SizedBox.shrink()
            : DsButton(
                key: ValueKey('vdj_editer_${p.vente.code}'),
                libelle: l10n.posVdjEditer,
                icone: LucideIcons.pencil,
                taille: DsButtonTaille.sm,
                variante: DsButtonVariante.secondaire,
                onPressed: () => _editer(p),
              ),
      ),
    ];
    return DsDialog(
      titre: l10n.posVdjTitre(widget.nomCaisse),
      iconeData: LucideIcons.receiptText,
      largeur: 1100,
      actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(context).pop())],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: DsSearchField(indice: l10n.posVdjIndice, onChanged: (v) => setState(() => _q = v)),
              ),
              SizedBox(
                width: 190,
                child: DsSelect<String?>(
                  valeur: _mode,
                  options: [null, for (final v in Referentiel.modesPaiement.valeurs) v.stocke],
                  libelle: (v) => v == null ? l10n.retoursTous : libelleRef(context, Referentiel.modesPaiement, v),
                  onChanged: (v) => setState(() => _mode = v),
                ),
              ),
            ],
          ),
          DsStatsStrip(
            compact: true,
            items: [
              DsStatItem(libelle: l10n.posVdjNombre, valeur: '${actifs.length}', icone: LucideIcons.receipt),
              DsStatItem(
                libelle: l10n.posVdjTotal,
                valeur: _da(ref, somme((p) => p.vente.totalNet)),
                icone: LucideIcons.banknote,
              ),
              DsStatItem(
                libelle: l10n.posVdjEncaisse,
                valeur: _da(ref, somme((p) => p.paye)),
                icone: LucideIcons.wallet,
              ),
              DsStatItem(
                libelle: l10n.posVdjReste,
                valeur: _da(ref, somme((p) => p.resteActuel)),
                icone: LucideIcons.handCoins,
              ),
            ],
          ),
          DsDataTable<PanierResume>(
            colonnes: colonnes,
            lignes: lignes,
            cle: (p) => p.vente.code,
            dense: true,
            hauteurMax: _hauteurTable(context),
            hauteurFixe: true,
            taillePage: 50,
            messageVide: l10n.posVdjAucune,
            onDoubleClic: (p) => afficherDetailPanier(context, ref, p, nomsClients: noms),
            actionsContextuelles: [
              DsActionContextuelle(
                libelle: l10n.tiersDetail,
                icone: LucideIcons.eye,
                onSelected: (p) => afficherDetailPanier(context, ref, p, nomsClients: noms),
              ),
              DsActionContextuelle(
                libelle: l10n.posVdjEditer,
                icone: LucideIcons.pencil,
                visible: (p) => !p.annule && p.nbRetours == 0,
                onSelected: _editer,
              ),
              DsActionContextuelle(
                libelle: l10n.posReimprimer,
                icone: LucideIcons.printer,
                onSelected: (p) async {
                  final v = await ref.read(venteRepositoryProvider).vente(p.vente.code);
                  if (v != null && context.mounted) await afficherResultatVente(context, ref, v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ligne vendue (recette par produit).
@immutable
class _LigneVendue {
  const _LigneVendue(this.vente, this.ligne);
  final Vente vente;
  final VenteLigne ligne;
}

final _lignesDuJourProvider = FutureProvider.autoDispose<List<_LigneVendue>>((ref) async {
  ref.watch(commerceVersionProvider);
  final n = DateTime.now();
  final debut = DateTime(n.year, n.month, n.day);
  final ventes = await ref
      .watch(venteRepositoryProvider)
      .ventes(depuis: debut, jusqua: debut.add(const Duration(days: 1)), avecLignes: true, limite: 5000);
  return [
    for (final v in ventes)
      for (final l in v.lignes) _LigneVendue(v, l),
  ];
});

Future<void> afficherRecetteProduit(BuildContext context, WidgetRef ref, {required String nomCaisse}) =>
    afficherDialog<void>(context, builder: (_) => _RecetteProduitDialog(nomCaisse: nomCaisse));

class _RecetteProduitDialog extends ConsumerStatefulWidget {
  const _RecetteProduitDialog({required this.nomCaisse});
  final String nomCaisse;

  @override
  ConsumerState<_RecetteProduitDialog> createState() => _RecetteProduitDialogState();
}

class _RecetteProduitDialogState extends ConsumerState<_RecetteProduitDialog> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(posControllerProvider).session;
    final noms = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    final q = _q.trim().toLowerCase();
    final lignes = (ref.watch(_lignesDuJourProvider).value ?? const <_LigneVendue>[])
        .where(
          (l) =>
              (session == null || l.vente.sessionCode == session.code) &&
              (q.isEmpty || '${l.ligne.designation} ${l.ligne.produitCode} ${l.vente.code}'.toLowerCase().contains(q)),
        )
        .toList();
    final actives = lignes.where((l) => l.vente.statut != 'Annulée');
    final colonnes = <DsColonne<_LigneVendue>>[
      DsColonne(id: 'panier', libelle: l10n.posInfoVente, valeur: (l) => l.vente.code, mono: true, attenue: true),
      DsColonne(
        id: 'client',
        libelle: l10n.posClientLabel,
        valeur: (l) => nomClientPanier(l10n, l.vente.clientCode, noms),
      ),
      DsColonne(id: 'code', libelle: l10n.dsPosCode, valeur: (l) => l.ligne.produitCode, mono: true, attenue: true),
      DsColonne(id: 'produit', libelle: l10n.dsPosProduit, valeur: (l) => l.ligne.designation, fort: true, flex: 2),
      DsColonne(
        id: 'qte',
        libelle: l10n.dsPosQte,
        numerique: true,
        valeur: (l) => l.ligne.quantite,
        cellule: (_, l) => Text(_qte(l.ligne.quantite)),
        total: (ls) => _qte(ls.fold(0.0, (s, l) => s + l.ligne.quantite)),
      ),
      DsColonne(
        id: 'prix',
        libelle: l10n.dsPosPrix,
        numerique: true,
        valeur: (l) => l.ligne.prixUnitaire,
        cellule: (_, l) => Text(_da(ref, l.ligne.prixUnitaire)),
      ),
      DsColonne(
        id: 'montant',
        libelle: l10n.dsPosMontant,
        numerique: true,
        valeur: (l) => l.ligne.total,
        cellule: (_, l) => Text(_da(ref, l.ligne.total)),
        total: (ls) => _da(ref, ls.fold(0.0, (s, l) => s + l.ligne.total)),
      ),
      DsColonne(id: 'caissier', libelle: l10n.posInfoCaissier, valeur: (l) => l.vente.utilisateurCode),
      DsColonne(
        id: 'statut',
        libelle: l10n.retoursEtat,
        valeur: (l) => l.vente.statut,
        cellule: (_, l) => BadgeStatut(l.vente.statut == 'Annulée' ? 'annule' : 'actif'),
      ),
    ];
    return DsDialog(
      titre: l10n.posRecTitre(widget.nomCaisse),
      iconeData: LucideIcons.chartColumn,
      largeur: 1100,
      actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(context).pop())],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          DsSearchField(indice: l10n.posRecIndice, onChanged: (v) => setState(() => _q = v)),
          DsStatsStrip(
            compact: true,
            items: [
              DsStatItem(libelle: l10n.posRecLignes, valeur: '${actives.length}', icone: LucideIcons.listOrdered),
              DsStatItem(
                libelle: l10n.posRecQuantite,
                valeur: _qte(actives.fold(0.0, (s, l) => s + l.ligne.quantite)),
                icone: LucideIcons.boxes,
              ),
              DsStatItem(
                libelle: l10n.posVdjTotal,
                valeur: _da(ref, actives.fold(0.0, (s, l) => s + l.ligne.total)),
                icone: LucideIcons.banknote,
              ),
            ],
          ),
          DsDataTable<_LigneVendue>(
            colonnes: colonnes,
            lignes: lignes,
            cle: (l) => '${l.vente.code}|${l.ligne.ordre}',
            dense: true,
            hauteurMax: _hauteurTable(context),
            hauteurFixe: true,
            taillePage: 50,
            afficherTotaux: true,
            messageVide: l10n.posRecAucune,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 8 · Paramètres du poste (ParametreCaisseDialog) et entrée rapide.
// ---------------------------------------------------------------------------------------------------------------

Future<void> afficherParametresCaisse(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
  final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
  if (!context.mounted || caisses.isEmpty || magasins.isEmpty) return;
  final etat = ref.read(posControllerProvider);
  final session = ref.read(sessionProvider);
  // §6.2 : un non-Admin travaille sur sa caisse attachée et ses magasins, sauf permission `changerCaisseMagasin`.
  final libre =
      session == null ||
      session.estAdmin ||
      session.a(Permission.changerCaisseMagasin) ||
      session.utilisateur.caisseCode == null;
  var caisse = etat.session?.caisseCode ?? etat.caisseCode ?? caisses.first.code;
  var magasin = magasins.any((m) => m.code == etat.magasinCode) ? etat.magasinCode : magasins.first.code;
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: l10n.posParametres,
        iconeData: LucideIcons.settings2,
        largeur: 560,
        actions: [
          DsButton(
            libelle: l10n.dsAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: l10n.posEnregistrer,
            icone: LucideIcons.check,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            DsFormRow(
              libelle: l10n.posSessionCaisse,
              child: DsSelect<String>(
                valeur: caisse,
                options: [for (final c in caisses) c.code],
                libelle: (c) => caisses.firstWhere((x) => x.code == c).nom,
                actif: etat.session == null && libre,
                recherche: rechercheListe(context, ref, ListeMetier.caisse),
                onChanged: (v) => setState(() => caisse = v ?? caisse),
              ),
            ),
            if (ref.read(plusieursMagasinsProvider))
              DsFormRow(
                libelle: l10n.posParamMagasin,
                child: DsSelect<String>(
                  valeur: magasin,
                  options: [for (final m in magasins) m.code],
                  libelle: (c) => magasins.firstWhere((x) => x.code == c).nom,
                  actif: libre,
                  recherche: rechercheListe(context, ref, ListeMetier.magasin),
                  onChanged: (v) => setState(() => magasin = v ?? magasin),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  ref.read(posControllerProvider.notifier).parametrer(caisseCode: caisse, magasinCode: magasin);
  afficherToast(
    context,
    titre: l10n.posParamFait,
    description:
        '${caisses.firstWhere((c) => c.code == caisse).nom} · ${magasins.firstWhere((m) => m.code == magasin).nom}',
  );
}

/// Niveaux de stock du magasin de la caisse (code produit → unités).
final stocksCaisseProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  ref.watch(stockVersionProvider);
  final magasin = ref.watch(posControllerProvider.select((e) => e.magasinCode));
  final niveaux = await ref.watch(stockRepositoryProvider).niveaux(magasinCode: magasin);
  return {for (final NiveauStock n in niveaux) n.produitCode: n.quantite};
});
