import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/session_caisse_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/codes_barres.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
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

String _qte(double v) => v == v.roundToDouble() ? v.toInt().toString() : formaterNombre(v, decimales: 2);

// ---------------------------------------------------------------------------------------------------------------
// 1 · Quantité et colis (ProduitSelectionDialog, 880 px) : ajout automatique après 3 s si rien n'est touché.
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
  Duration auto = const Duration(seconds: 3),
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
    auto: modification ? Duration.zero : auto,
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
    required this.auto,
  });
  final Produit produit;
  final List<Colis> colis;
  final double stock;
  final bool scanne;
  final Colis? colisInitial;
  final bool nombreInitial;
  final double quantiteInitiale;
  final bool modification;
  final Duration auto;

  @override
  ConsumerState<_SelectionProduitDialog> createState() => _SelectionProduitDialogState();
}

class _SelectionProduitDialogState extends ConsumerState<_SelectionProduitDialog> {
  static const _nombre = '#nombre';
  late String _colis = widget.nombreInitial ? _nombre : (widget.colisInitial?.code ?? '');
  late String _q = _q0(widget.quantiteInitiale);
  late bool _touche = widget.auto == Duration.zero;
  Timer? _minuteur;
  final _debut = DateTime.now();
  Duration _reste = Duration.zero;

  static String _q0(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    _reste = widget.auto;
    if (!_touche) {
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
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  void _toucher() {
    if (_touche) return;
    _minuteur?.cancel();
    setState(() => _touche = true);
  }

  Colis? get _colisChoisi => widget.colis.where((c) => c.code == _colis).firstOrNull;
  double get _quantite => double.tryParse(_q) ?? 0;
  double get _parColis => (_colisChoisi?.quantite ?? 1).toDouble();
  double get _prixPiece {
    final p = widget.produit;
    return p.nombreParUnite > 0 ? double.parse((p.prixVente / p.nombreParUnite).toStringAsFixed(2)) : p.prixVente;
  }

  double get _prix => _colis == _nombre ? _prixPiece : (_colisChoisi?.prixVente ?? widget.produit.prixVente);

  /// Le stock au nombre est contrôlé à l'ajout (réservations comprises) ; ici, seules les unités.
  bool get _depasse => _colis != _nombre && _quantite * _parColis > widget.stock + 1e-9;

  void _valider({bool auto = false}) {
    final q = auto && _quantite <= 0 ? 1.0 : _quantite;
    if (q <= 0 || (_colis != _nombre && q * _parColis > widget.stock + 1e-9)) {
      if (auto) setState(() => _touche = true);
      return;
    }
    Navigator.of(context).pop((colis: _colisChoisi, nombre: _colis == _nombre, quantite: q));
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
          if (e is KeyDownEvent && e.logicalKey != LogicalKeyboardKey.enter) _toucher();
          return KeyEventResult.ignored;
        },
        child: DsDialog(
          titre: widget.modification ? l10n.posSelTitreModif : l10n.posSelTitre,
          iconeData: widget.scanne ? LucideIcons.scanBarcode : LucideIcons.package,
          description: widget.scanne ? l10n.posSelScanne(p.code) : p.code,
          largeur: 880,
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
              onPressed: _quantite <= 0 || _depasse ? null : _valider,
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
                        if (!_touche) DsProgressBar(valeur: _reste.inMilliseconds / widget.auto.inMilliseconds),
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
                        const DsIconBox(LucideIcons.package, taille: 96, tailleIcone: 40),
                        Text(p.designation, style: t.bodyStrong.copyWith(fontSize: 15, height: 1.3)),
                        puce(LucideIcons.tag, l10n.posSelParPiece(_da(ref, p.prixVente))),
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
                          }),
                          options: [
                            DsOption('', libelle: l10n.posSelUnite, meta: '${_da(ref, p.prixVente)} / ${p.unite}'),
                            if (p.suiviNombre)
                              DsOption(_nombre, libelle: l10n.posVendreNombre, meta: _da(ref, _prixPiece)),
                            for (final k in widget.colis)
                              DsOption(
                                k.code,
                                libelle: l10n.posSelParColis(k.designation, '${k.quantite}'),
                                meta: _da(ref, k.prixVente),
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
                          onChanged: (v) => setState(() => _q = v),
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
                        SizedBox(width: 220, child: fiche),
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
// 2 · Encaisser ticket / BL-SC / Enregistrer (EncaisserDialog, 860 px).
// ---------------------------------------------------------------------------------------------------------------

/// Nature de l'encaissement : ticket (F4), BL / SC (F5), enregistrement à crédit (F6).
enum NatureEncaissement { ticket, blsc, enregistrer }

/// Sortie d'un BL / SC.
enum SortieDocument { imprimer, pdf }

/// Montant payé et sortie choisis ; `null` si annulé.
typedef ResultatEncaissement = ({double paye, SortieDocument sortie});

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
  late String _paye = _enregistrer ? '0' : formaterNombre(widget.panier.totalNet, decimales: 2);
  late bool _complet = !_enregistrer;
  SortieDocument _sortie = SortieDocument.imprimer;

  bool get _comptoir => widget.panier.clientCode == 'CLN0000';
  double get _total => widget.panier.totalNet;
  double get _payeN => _complet ? _total : DsPaymentPanel.lire(_paye);
  bool get _bloque =>
      (_comptoir && _payeN < _total - 1e-9 && !_enregistrer) || (!_complet && _payeN <= 0 && !_enregistrer);

  void _valider() {
    if (_bloque) return;
    Navigator.of(context).pop((paye: _payeN, sortie: _sortie));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.panier;
    final (titre, icone, ok) = switch (widget.nature) {
      NatureEncaissement.ticket => (l10n.posEncTicketTitre, LucideIcons.receipt, l10n.posEncTicketOk),
      NatureEncaissement.blsc => (l10n.posEncBlscTitre, LucideIcons.fileText, l10n.posEncBlscOk),
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
        description: switch (widget.nature) {
          NatureEncaissement.ticket => l10n.posEncTicketDesc,
          NatureEncaissement.blsc => l10n.posEncBlscDesc,
          NatureEncaissement.enregistrer => l10n.posEncSaveDesc,
        },
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
            DsPaymentPanel(
              total: _total,
              sousTotal: p.totalRemise > 0 ? p.totalBrut : null,
              remise: p.totalRemise,
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
                DsInfoPaiement(l10n.posClientLabel, widget.nomClient),
                DsInfoPaiement(l10n.posInfoDate, formatDateHeure.format(DateTime.now())),
                DsInfoPaiement(l10n.posInfoProduits, '${p.lignes.length}'),
                DsInfoPaiement(l10n.posInfoPieces, _qte(p.pieces)),
                DsInfoPaiement(l10n.posInfoPaiement, libelleRef(context, Referentiel.modesPaiement, p.modePaiement)),
                DsInfoPaiement(l10n.posInfoCaissier, widget.caissier),
              ],
            ),
            if (widget.nature == NatureEncaissement.blsc)
              DsChoiceCards<SortieDocument>(
                petit: true,
                valeur: _sortie,
                onChanged: (v) => setState(() => _sortie = v),
                options: [
                  DsOption(
                    SortieDocument.imprimer,
                    libelle: l10n.posSortieImprimer,
                    icone: LucideIcons.printer,
                    description: l10n.posSortieImprimerDesc,
                  ),
                  DsOption(
                    SortieDocument.pdf,
                    libelle: l10n.posSortiePdf,
                    icone: LucideIcons.fileDown,
                    description: l10n.posSortiePdfDesc,
                  ),
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
        message: l10n.posPrixSousAchatMsg(_da(ref, v), _da(ref, _achat)),
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
      description: l10n.posPrixDesc,
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
// 4 · Rechercher un produit (RechercheProduitDialog) : sélection multiple.
// ---------------------------------------------------------------------------------------------------------------

Future<List<Produit>?> afficherRechercheProduit(
  BuildContext context,
  WidgetRef ref, {
  required List<Produit> produits,
  required Map<String, double> stocks,
}) {
  final l10n = AppLocalizations.of(context);
  final categories = {for (final c in ref.read(categoriesProvider).value ?? const <Categorie>[]) c.code: c.nom};
  return afficherDialog<List<Produit>>(
    context,
    builder: (_) => DsPickerDialog<Produit>(
      titre: l10n.posRechTitre,
      description: l10n.posRechDesc,
      icone: LucideIcons.search,
      multiple: true,
      elements: produits,
      libelle: (p) => p.designation,
      indiceRecherche: l10n.posRechIndice,
      libelleConfirmer: l10n.posRechAjouter,
      colonnes: [
        DsColonnePicker(libelle: l10n.dsPosCode, valeur: (p) => p.code, mono: true, attenue: true, largeur: 110),
        DsColonnePicker(libelle: l10n.dsPosProduit, valeur: (p) => p.designation, fort: true),
        DsColonnePicker(
          libelle: l10n.produitsColCategorie,
          valeur: (p) => categories[p.categorieCode] ?? p.categorieCode,
        ),
        DsColonnePicker(libelle: l10n.produitsColStock, valeur: (p) => _qte(stocks[p.code] ?? 0), largeur: 80),
        DsColonnePicker(libelle: l10n.dsPosPrix, valeur: (p) => _da(ref, p.prixVente), largeur: 110),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------------------------------------------
// 5 · Produit introuvable / caisse fermée.
// ---------------------------------------------------------------------------------------------------------------

/// `true` = rechercher, `false` = créer le produit, `null` = fermer.
Future<bool?> afficherProduitIntrouvable(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  return afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.posIntrouvableTitre,
      iconeData: LucideIcons.searchX,
      ton: DsDialogTon.avertissement,
      description: l10n.posIntrouvableDesc,
      largeur: 520,
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
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        DsButton(
          libelle: l10n.posIntrouvableCreer,
          icone: LucideIcons.packagePlus,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
      contenu: DsBarcodeCard(
        valeur: code,
        format: CodesBarres.ean13Valide(code) ? DsBarcodeFormat.ean13 : DsBarcodeFormat.code128,
      ),
    ),
  );
}

/// `true` si l'utilisateur choisit d'ouvrir la caisse.
Future<bool> afficherCaisseFermee(BuildContext context, {required String caisse}) async {
  final l10n = AppLocalizations.of(context);
  final r = await afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.posFermeeTitre,
      iconeData: LucideIcons.lock,
      ton: DsDialogTon.avertissement,
      description: l10n.posFermeeDesc(caisse),
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
        description: l10n.posOuvertureDesc,
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
            DsFormRow(
              libelle: l10n.posSessionCaisse,
              obligatoire: true,
              child: DsSelect<Caisse>(
                valeur: caisse,
                options: caisses,
                libelle: (c) => c.nom,
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
  final attendu = await ref.read(sessionCaisseServiceProvider).especesAttendues(session.code);
  if (!context.mounted) return;
  final reel = TextEditingController(text: formaterNombre(attendu, decimales: 2));
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
          description: l10n.posClotureDesc(session.code, formatHeure(session.ouverteLe)),
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
                    ligne(l10n.posClotureFond, session.fondInitial),
                    Divider(height: 1, color: c.borderSubtle),
                    ligne(l10n.posClotureVentesEspeces, attendu - session.fondInitial),
                    Divider(height: 1, color: c.borderDefault),
                    ligne(l10n.posClotureTheorique, attendu, total: true),
                  ],
                ),
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
        description: l10n.posMvtDesc,
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
              DsFormRow(
                libelle: l10n.posSessionCaisse,
                obligatoire: true,
                child: DsSelect<String>(
                  cle: const ValueKey('mouvement_caisse'),
                  valeur: caisse,
                  options: [for (final c in caisses) c.code],
                  libelle: (code) => caisses.firstWhere((c) => c.code == code).nom,
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
  String? _type;
  String? _mode;

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
              (_type == null || p.type == _type) &&
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
      DsColonne(id: 'type', libelle: l10n.posMvtType, valeur: (p) => p.type, cellule: (_, p) => BadgeStatut(p.type)),
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
    ];
    return DsDialog(
      titre: l10n.posVdjTitre(widget.nomCaisse),
      iconeData: LucideIcons.receiptText,
      description: l10n.posVdjDesc(formatDate.format(aujourdhui)),
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
                width: 170,
                child: DsSelect<String?>(
                  valeur: _type,
                  options: const [null, 'ticket', 'facture'],
                  libelle: (v) => v == null ? l10n.retoursTous : libelleStatut(l10n, v),
                  onChanged: (v) => setState(() => _type = v),
                ),
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
            hauteurMax: 360,
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
      description: l10n.posRecDesc(formatDate.format(DateTime.now())),
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
            hauteurMax: 380,
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
        description: l10n.posParamDesc,
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
                onChanged: (v) => setState(() => caisse = v ?? caisse),
              ),
            ),
            DsFormRow(
              libelle: l10n.posParamMagasin,
              child: DsSelect<String>(
                valeur: magasin,
                options: [for (final m in magasins) m.code],
                libelle: (c) => magasins.firstWhere((x) => x.code == c).nom,
                actif: libre,
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

/// Entrée rapide en stock d'un produit depuis la grille de la caisse.
Future<void> afficherEntreeRapide(BuildContext context, WidgetRef ref, Produit p) async {
  final l10n = AppLocalizations.of(context);
  final magasinCode = ref.read(posControllerProvider).magasinCode;
  final magasins = await ref.read(magasinsProvider.future);
  if (!context.mounted) return;
  final nomMagasin = magasins.where((m) => m.code == magasinCode).firstOrNull?.nom ?? magasinCode;
  final quantite = TextEditingController(text: '1');
  final ok = await afficherDialog<bool>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.posEntreeTitre,
      iconeData: LucideIcons.packagePlus,
      description: l10n.posEntreeDesc(p.designation, nomMagasin),
      largeur: 440,
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        DsButton(libelle: l10n.posEnregistrer, icone: LucideIcons.check, onPressed: () => Navigator.of(ctx).pop(true)),
      ],
      contenu: DsFormRow(
        libelle: l10n.posSelQuantite,
        obligatoire: true,
        child: DsTextField(
          controller: quantite,
          numerique: true,
          autofocus: true,
          suffixeTexte: p.unite,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
      ),
    ),
  );
  final q = lireNombre(quantite.text) ?? 0;
  if (ok != true || q <= 0 || !context.mounted) return;
  try {
    await ref.read(stockServiceProvider).entrerStock(produitCode: p.code, magasinCode: magasinCode, quantite: q);
    rafraichirStock(ref);
    if (context.mounted) {
      afficherToast(context, titre: l10n.posEntreeFaite, description: l10n.posEntreeFaiteDesc(p.designation));
    }
  } on Object catch (e) {
    if (context.mounted) {
      await afficherResultat(context, type: DsResultatType.erreur, titre: l10n.posEntreeTitre, message: '$e');
    }
  }
}

/// Niveaux de stock du magasin de la caisse (code produit → unités).
final stocksCaisseProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  ref.watch(stockVersionProvider);
  final magasin = ref.watch(posControllerProvider.select((e) => e.magasinCode));
  final niveaux = await ref.watch(stockRepositoryProvider).niveaux(magasinCode: magasin);
  return {for (final NiveauStock n in niveaux) n.produitCode: n.quantite};
});
