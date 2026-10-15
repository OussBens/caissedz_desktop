import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/achat_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/code_generator.dart';
import '../../domain/models/achat.dart';
import '../../domain/models/caisse.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/doc_form.dart';
import '../commun/export_module.dart';
import '../commun/statuts.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_page.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_dialogs.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'entrees_providers.dart';

const double _lw = 112;

final String _frnSysteme = CodeGenerator.systeme(CodeGenerator.fournisseur);

/// Modes de paiement proposés à la réception (`PaiementRows` du DS).
const List<String> modesPaiementEntree = ['Espèces', 'Chèque', 'Virement'];

/// Ligne d'entrée : produit, quantité reçue, prix d'achat et prix de vente (> achat, §8).
class LigneEntree extends LigneDoc {
  LigneEntree({required super.produit, super.quantite, super.prix, double? prixVente})
    : prixVente = prixVente ?? produit.prixVente;
  double prixVente;
}

/// Exécute une écriture d'entrée ; affiche l'erreur métier et renvoie `false` en cas d'échec.
Future<bool> executerEntree(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    rafraichirEntrees(ref);
    rafraichirCaisse(ref);
    return true;
  } on AchatException catch (e) {
    if (context.mounted) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.entEntite,
          message: messageErreurAchat(l10n, e.erreur),
        ),
      );
    }
    return false;
  }
}

// ———————————————————————————— Paiement ————————————————————————————

/// État des lignes de paiement (`PaiementRows` du DS) : payé en totalité, montant payé, mode, caisse.
class EtatPaiement {
  EtatPaiement({this.totalite = true, double montant = 0, this.mode = 'Espèces', this.caisse})
    : montant = TextEditingController(text: montant > 0 ? texteQuantite(montant) : '');
  bool totalite;
  final TextEditingController montant;
  String mode;
  String? caisse;

  double verse(double total) => totalite ? total : (lireNombre(montant.text) ?? 0).clamp(0, total).toDouble();

  void dispose() => montant.dispose();
}

/// Total, payé en totalité, montant payé, reste (crédit), mode et caisse.
List<Widget> lignesPaiement(
  BuildContext context, {
  required EtatPaiement etat,
  required double total,
  required String devise,
  required List<Caisse> caisses,
  required VoidCallback onChanged,
  double largeurLibelle = _lw,
}) {
  final l10n = AppLocalizations.of(context);
  final reste = total - etat.verse(total);
  return [
    DsFormRow(
      libelle: l10n.communTotal,
      largeurLibelle: largeurLibelle,
      child: DsTextField(
        key: ValueKey('paiement_total_${f2(total)}'),
        valeurInitiale: f2(total),
        actif: false,
        suffixeTexte: devise,
      ),
    ),
    DsFormRow(
      libelle: l10n.entPaiement,
      largeurLibelle: largeurLibelle,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DsCheckbox(
          cle: const ValueKey('paiement_totalite'),
          valeur: etat.totalite,
          libelle: l10n.entPayeTotalite,
          onChanged: (v) {
            etat.totalite = v;
            if (!v && etat.montant.text.isEmpty) etat.montant.text = texteQuantite(total);
            onChanged();
          },
        ),
      ),
    ),
    DsFormRow(
      libelle: l10n.entMontantPaye,
      obligatoire: true,
      largeurLibelle: largeurLibelle,
      child: etat.totalite
          ? DsTextField(
              key: ValueKey('paiement_plein_${f2(total)}'),
              valeurInitiale: f2(total),
              actif: false,
              suffixeTexte: devise,
            )
          : DsTextField(
              key: const ValueKey('paiement_montant'),
              controller: etat.montant,
              numerique: true,
              suffixeTexte: devise,
              onChanged: (_) => onChanged(),
            ),
    ),
    DsFormRow(
      libelle: l10n.entResteCredit,
      largeurLibelle: largeurLibelle,
      aide: reste > 0.005 ? l10n.entResteAide : null,
      child: DsTextField(
        key: ValueKey('paiement_reste_${f2(reste)}'),
        valeurInitiale: f2(reste),
        actif: false,
        suffixeTexte: devise,
      ),
    ),
    DsFormRow(
      libelle: l10n.entMode,
      obligatoire: true,
      largeurLibelle: largeurLibelle,
      child: DsSelect<String>(
        valeur: etat.mode,
        options: modesPaiementEntree,
        libelle: (m) => libelleModePaiement(l10n, m),
        onChanged: (v) {
          etat.mode = v ?? etat.mode;
          onChanged();
        },
      ),
    ),
    DsFormRow(
      libelle: l10n.versementCaisse,
      obligatoire: true,
      largeurLibelle: largeurLibelle,
      child: DsSelect<String>(
        valeur: etat.caisse ?? caisses.firstOrNull?.code,
        options: [for (final c in caisses) c.code],
        libelle: (code) => caisses.where((c) => c.code == code).firstOrNull?.nom ?? code,
        onChanged: (v) {
          etat.caisse = v;
          onChanged();
        },
      ),
    ),
  ];
}

// ———————————————————————————— Smart Scan (nouvelle entrée / modification) ————————————————————————————

/// Ouvre le bon formulaire pour modifier une entrée : entrée rapide si elle n'a qu'un produit (§9.6).
Future<void> modifierEntree(BuildContext context, WidgetRef ref, Achat a) =>
    a.source == SourcesAchat.rapide && a.lignes.length == 1
    ? afficherEntreeRapide(context, ref, achat: a)
    : afficherFormulaireEntree(context, ref, achat: a);

/// `SmartScanDialog` (1040 px, 2 étapes) : bon & fournisseur (en-tête, paiement) puis produits reçus (scan continu,
/// « Liste »). Sert aussi à la modification (ouverte à l'étape 2) et à la réception d'une liste de besoins.
Future<void> afficherFormulaireEntree(BuildContext context, WidgetRef ref, {Achat? achat, Besoin? besoin}) async {
  final catalogue = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final principal = await ref.read(magasinPrincipalProvider.future);
  await ref.read(fournisseursProvider.future);
  await ref.read(caissesListeProvider.future);
  if (!context.mounted) return;
  final lignes = <LigneEntree>[
    if (achat != null)
      for (final l in achat.lignes)
        if (catalogue[l.produitCode] != null)
          LigneEntree(produit: catalogue[l.produitCode]!, quantite: l.quantite, prix: l.prixAchat),
    if (besoin != null)
      for (final l in besoin.lignes)
        if (catalogue[l.produitCode] != null)
          LigneEntree(produit: catalogue[l.produitCode]!, quantite: l.quantite, prix: l.prix),
  ];
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _EntreeForm(achat: achat, besoin: besoin, lignes: lignes, principal: principal),
  );
}

class _EntreeForm extends ConsumerStatefulWidget {
  const _EntreeForm({required this.achat, required this.besoin, required this.lignes, required this.principal});
  final Achat? achat;
  final Besoin? besoin;
  final List<LigneEntree> lignes;
  final String principal;

  @override
  ConsumerState<_EntreeForm> createState() => _EntreeFormState();
}

class _EntreeFormState extends ConsumerState<_EntreeForm> {
  late int _etape = widget.achat != null ? 1 : 0;
  late List<LigneEntree> _lignes = widget.lignes;
  late DateTime? _date = widget.achat?.date ?? DateTime.now();
  late String? _fournisseur = widget.achat?.fournisseurCode ?? widget.besoin?.fournisseurCode;
  late String _magasin = widget.achat?.magasinCode ?? widget.principal;
  late final _reference = TextEditingController(text: widget.achat?.reference ?? '');
  MajPrixAchat _majPrix = MajPrixAchat.moyenPondere;
  late final _paiement = EtatPaiement(
    totalite: widget.achat == null || widget.achat!.reste <= 0.005,
    montant: widget.achat?.verse ?? 0,
  );
  final _scan = TextEditingController();
  final _focusScan = FocusNode();
  String? _flash;
  Timer? _minuterie;
  bool _occupe = false;

  bool get _edition => widget.achat != null;
  double get _total => _lignes.fold(0.0, (a, l) => a + l.quantite * l.prix);

  @override
  void dispose() {
    _reference.dispose();
    _paiement.dispose();
    _scan.dispose();
    _focusScan.dispose();
    _minuterie?.cancel();
    super.dispose();
  }

  void _ajouterProduit(Produit p) {
    final l10n = AppLocalizations.of(context);
    final existante = _lignes.where((l) => l.produit.code == p.code).firstOrNull;
    setState(() {
      if (existante != null) {
        existante.quantite += 1;
        _lignes = [..._lignes];
      } else {
        _lignes = [..._lignes, LigneEntree(produit: p, quantite: 1)];
      }
      _flash = '${p.designation} · ${existante != null ? '+1' : l10n.entScanAjoute}';
    });
    _minuterie?.cancel();
    _minuterie = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  Future<void> _scanner(String saisie) async {
    final l10n = AppLocalizations.of(context);
    final s = saisie.trim();
    _scan.clear();
    _focusScan.requestFocus();
    if (s.isEmpty) return;
    final produits = await ref.read(produitsProvider.future);
    final p =
        produits.where((p) => p.code.toLowerCase() == s.toLowerCase() || p.codeBarres == s).firstOrNull ??
        await ref.read(catalogueRepositoryProvider).produitParCodeBarres(s);
    if (!mounted) return;
    if (p == null || !p.actif) {
      setState(() => _flash = l10n.entScanInconnu(s));
      return;
    }
    _ajouterProduit(p);
  }

  Future<void> _liste() async {
    final l10n = AppLocalizations.of(context);
    final choix = await choisirProduits(
      context,
      ref,
      titre: l10n.dsPosLigneAjouter,
      exclus: {for (final l in _lignes) l.produit.code},
    );
    if (choix.isEmpty) return;
    setState(() => _lignes = [..._lignes, for (final p in choix) LigneEntree(produit: p, quantite: 1)]);
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final s = ref.read(achatServiceProvider);
    final lignes = [
      for (final l in _lignes)
        DemandeAchatLigne(
          produitCode: l.produit.code,
          quantite: l.quantite,
          prixAchat: l.prix,
          nouveauPrixVente: l.prixVente != l.produit.prixVente ? l.prixVente : null,
        ),
    ];
    final reference = _reference.text.trim().isEmpty ? null : _reference.text.trim();
    final caisse = _paiement.caisse ?? ref.read(caissesListeProvider).value?.where((c) => c.actif).firstOrNull?.code;
    Achat? a;
    final ok = await executerEntree(context, ref, () async {
      a = _edition
          ? await s.modifier(
              widget.achat!.code,
              fournisseurCode: _fournisseur!,
              magasinCode: _magasin,
              lignes: lignes,
              reference: reference,
              verse: _paiement.verse(_total),
              modePaiement: _paiement.mode,
              caisseCode: caisse,
              date: _date,
              majPrix: _majPrix,
            )
          : await s.enregistrer(
              fournisseurCode: _fournisseur!,
              magasinCode: _magasin,
              lignes: lignes,
              reference: reference,
              verse: _paiement.verse(_total),
              modePaiement: _paiement.mode,
              caisseCode: caisse,
              date: _date,
              majPrix: _majPrix,
              besoinCode: widget.besoin?.code,
            );
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _occupe = false);
      return;
    }
    if (widget.besoin != null) rafraichirStock(ref);
    Navigator.of(context).pop(true);
    afficherToast(
      context,
      titre: _edition ? l10n.entToastModifiee : l10n.entToastEnregistree,
      description: '${a!.code} · ${l10n.stkToastStockAJour}',
      ton: DsToastTon.succes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final fournisseurs = (ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        .where((f) => f.actif || f.code == _fournisseur)
        .toList();
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[])
        .where((m) => m.actif || m.code == _magasin)
        .toList();
    final caisses = (ref.watch(caissesListeProvider).value ?? const <Caisse>[]).where((c) => c.actif).toList();
    final nomFrn = fournisseurs.where((f) => f.code == _fournisseur).firstOrNull?.nom;
    final erreurs = <Object, Map<String, String>>{
      for (final l in _lignes)
        if (l.prixVente <= l.prix && !l.produit.service) l.produit.code: {'vente': l10n.entVenteSousAchat},
    };
    final total = _total;
    final enTete = _fournisseur != null && _date != null;
    final valide = enTete && _lignes.isNotEmpty && _lignes.every((l) => l.quantite > 0) && erreurs.isEmpty;
    return DsDialog(
      titre: _edition ? l10n.entModifierTitre : l10n.entNouvelleTitre,
      iconeData: LucideIcons.scanLine,
      description: _edition
          ? '${widget.achat!.code} · ${nomFrn ?? ''}'
          : widget.besoin != null
          ? l10n.entDepuisListe(widget.besoin!.code)
          : l10n.entNouvelleDescription,
      largeur: 1040,
      fermable: !_occupe,
      piedDebut: _etape > 0
          ? DsButton(
              libelle: l10n.entRetour,
              icone: LucideIcons.arrowLeft,
              variante: DsButtonVariante.secondaire,
              onPressed: _occupe ? null : () => setState(() => _etape = 0),
            )
          : null,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        if (_etape == 0)
          DsButton(
            key: const ValueKey('entree_suivant'),
            libelle: l10n.entSuivant,
            iconeDroite: LucideIcons.arrowRight,
            onPressed: enTete ? () => setState(() => _etape = 1) : null,
          )
        else
          DsButton(
            key: const ValueKey('entree_valider'),
            libelle: l10n.entValider(formaterMontant(total, devise)),
            icone: LucideIcons.check,
            chargement: _occupe,
            onPressed: valide ? _enregistrer : null,
          ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          DsStepper(
            etapes: [l10n.entEtapeBon, l10n.entEtapeProduits],
            descriptions: [l10n.entEtapeBonDetail, l10n.entEtapeProduitsDetail],
            courante: _etape,
            onEtape: (i) => setState(() => _etape = i),
          ),
          if (_etape == 0)
            DsGrilleFormulaire(
              children: [
                DsSpan(child: DsSubHead(l10n.entBonReception)),
                DsFormRow(
                  libelle: l10n.produitsColCode,
                  largeurLibelle: _lw,
                  child: DsTextField(valeurInitiale: widget.achat?.code ?? l10n.prdCodeAuto, actif: false),
                ),
                DsFormRow(
                  libelle: l10n.communDate,
                  obligatoire: true,
                  largeurLibelle: _lw,
                  child: DsDateField(valeur: _date, onChanged: (d) => setState(() => _date = d)),
                ),
                DsFormRow(
                  libelle: l10n.achatFournisseur,
                  obligatoire: true,
                  largeurLibelle: _lw,
                  child: DsSelect<String>(
                    cle: const ValueKey('entree_fournisseur'),
                    valeur: _fournisseur,
                    placeholder: l10n.stkChoisirFournisseur,
                    options: [for (final f in fournisseurs) f.code],
                    libelle: (c) => fournisseurs.where((f) => f.code == c).firstOrNull?.nom ?? c,
                    onChanged: (v) => setState(() => _fournisseur = v),
                  ),
                ),
                DsFormRow(
                  libelle: l10n.entNumFacture,
                  largeurLibelle: _lw,
                  child: DsTextField(
                    key: const ValueKey('entree_reference'),
                    controller: _reference,
                    indice: l10n.entNumFactureIndice,
                  ),
                ),
                DsFormRow(
                  libelle: l10n.stockColMagasin,
                  obligatoire: true,
                  largeurLibelle: _lw,
                  aide: l10n.entMagasinAide,
                  child: DsSelect<String>(
                    valeur: _magasin,
                    options: [for (final m in magasins) m.code],
                    libelle: (c) => magasins.where((m) => m.code == c).firstOrNull?.nom ?? c,
                    onChanged: (v) => setState(() => _magasin = v ?? _magasin),
                  ),
                ),
                DsFormRow(
                  libelle: l10n.entMajPrix,
                  largeurLibelle: _lw,
                  child: DsSelect<MajPrixAchat>(
                    valeur: _majPrix,
                    options: MajPrixAchat.values,
                    libelle: (m) => libelleMajPrix(l10n, m),
                    onChanged: (v) => setState(() => _majPrix = v ?? _majPrix),
                  ),
                ),
                DsSpan(child: DsSubHead(l10n.entPaiement)),
                ...lignesPaiement(
                  context,
                  etat: _paiement,
                  total: total,
                  devise: devise,
                  caisses: caisses,
                  onChanged: () => setState(() {}),
                ),
              ],
            )
          else ...[
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: DsSearchField(
                    controller: _scan,
                    focusNode: _focusScan,
                    grand: true,
                    autofocus: true,
                    kbd: '',
                    indice: l10n.entScanIndice,
                    onSubmitted: _scanner,
                  ),
                ),
                DsButton(
                  key: const ValueKey('entree_liste'),
                  libelle: l10n.entListe,
                  icone: LucideIcons.list,
                  variante: DsButtonVariante.secondaire,
                  taille: DsButtonTaille.lg,
                  onPressed: _liste,
                ),
              ],
            ),
            SizedBox(
              height: 22,
              child: AnimatedOpacity(
                opacity: _flash == null ? 0 : 1,
                duration: DsMotion.base,
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(LucideIcons.circleCheck, size: 15, color: context.ds.colors.successFg),
                    Text(
                      _flash ?? '',
                      style: context.ds.typo.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.ds.colors.successFg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DsLineItemsEditor<LigneDoc>(
              lignes: _lignes,
              cle: (l) => l.produit.code,
              devise: devise,
              erreurs: erreurs,
              hauteurMax: 300,
              totalLigne: (l) => l.quantite * l.prix,
              quantite: (l) => l.quantite,
              texteVide: l10n.entAucunProduit,
              onSupprimer: (l) => setState(() => _lignes = _lignes.where((x) => x != l).toList()),
              colonnes: [
                DsColonneLigne(
                  id: 'code',
                  libelle: l10n.produitsColCode,
                  valeur: (l) => l.produit.code,
                  attenue: true,
                  largeur: 110,
                ),
                DsColonneLigne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.produit.designation, fort: true),
                DsColonneLigne(
                  id: 'qte',
                  libelle: l10n.entQteRecue,
                  numerique: true,
                  editable: true,
                  largeur: 104,
                  valeur: (l) => texteQuantite(l.quantite),
                  onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
                ),
                DsColonneLigne(
                  id: 'prix',
                  libelle: l10n.produitsColPrixAchat,
                  numerique: true,
                  editable: true,
                  largeur: 140,
                  suffixe: devise,
                  valeur: (l) => montantLigne(l.prix),
                  onEdition: (l, v) => setState(() => l.prix = nombreSaisi(v)),
                ),
                DsColonneLigne(
                  id: 'vente',
                  libelle: l10n.produitsColPrixVente,
                  numerique: true,
                  editable: true,
                  largeur: 140,
                  suffixe: devise,
                  valeur: (l) => montantLigne((l as LigneEntree).prixVente),
                  onEdition: (l, v) => setState(() => (l as LigneEntree).prixVente = nombreSaisi(v)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String libelleMajPrix(AppLocalizations l10n, MajPrixAchat m) => switch (m) {
  MajPrixAchat.garder => l10n.entMajGarder,
  MajPrixAchat.moyenPondere => l10n.entMajMoyen,
  MajPrixAchat.dernier => l10n.entMajDernier,
};

// ———————————————————————————— Entrée rapide ————————————————————————————

/// `EntreeRapideDialog` (720 px) : un produit payé intégralement, réparti entre magasins (§9.6).
Future<void> afficherEntreeRapide(BuildContext context, WidgetRef ref, {Achat? achat, Produit? produit}) async {
  await ref.read(produitsProvider.future);
  await ref.read(fournisseursProvider.future);
  await ref.read(magasinsProvider.future);
  await ref.read(stocksParMagasinProvider.future);
  final principal = await ref.read(magasinPrincipalProvider.future);
  final repartition = <String, double>{};
  if (achat != null) {
    final net = await ref.read(stockRepositoryProvider).mouvements(referenceCode: achat.code);
    for (final m in net.where((m) => m.referenceType == 'achat')) {
      repartition[m.magasinCode] = (repartition[m.magasinCode] ?? 0) + m.quantite;
    }
    repartition.removeWhere((_, q) => q.abs() < 1e-9);
  }
  if (!context.mounted) return;
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _EntreeRapideForm(achat: achat, produit: produit, principal: principal, repartition: repartition),
  );
}

class _EntreeRapideForm extends ConsumerStatefulWidget {
  const _EntreeRapideForm({
    required this.achat,
    required this.produit,
    required this.principal,
    required this.repartition,
  });
  final Achat? achat;
  final Produit? produit;
  final String principal;
  final Map<String, double> repartition;

  @override
  ConsumerState<_EntreeRapideForm> createState() => _EntreeRapideFormState();
}

class _EntreeRapideFormState extends ConsumerState<_EntreeRapideForm> {
  late String? _produit = widget.achat?.lignes.first.produitCode ?? widget.produit?.code;
  late String? _fournisseur = widget.achat?.fournisseurCode == _frnSysteme ? null : widget.achat?.fournisseurCode;
  late final _quantite = TextEditingController(text: texteQuantite(widget.achat?.lignes.first.quantite ?? 1));
  late final _prix = TextEditingController(
    text: widget.achat != null
        ? texteQuantite(widget.achat!.lignes.first.prixAchat)
        : widget.produit != null
        ? texteQuantite(widget.produit!.prixAchat)
        : '',
  );
  late Map<String, double> _repartition = widget.repartition.isNotEmpty
      ? widget.repartition
      : {widget.principal: lireNombre(_quantite.text) ?? 0};
  bool _occupe = false;

  @override
  void dispose() {
    _quantite.dispose();
    _prix.dispose();
    super.dispose();
  }

  double get _total => lireNombre(_quantite.text) ?? 0;

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final s = ref.read(achatServiceProvider);
    final prix = lireNombre(_prix.text) ?? 0;
    final lignes = [
      DemandeAchatLigne(
        produitCode: _produit!,
        quantite: _total,
        prixAchat: prix,
        repartition: {
          for (final MapEntry(:key, :value) in _repartition.entries)
            if (value > 0) key: value,
        },
      ),
    ];
    final frn = _fournisseur ?? _frnSysteme;
    final total = _total * prix;
    final ok = await executerEntree(context, ref, () async {
      if (widget.achat == null) {
        await s.enregistrer(
          fournisseurCode: frn,
          magasinCode: widget.principal,
          lignes: lignes,
          verse: total,
          source: SourcesAchat.rapide,
        );
      } else {
        await s.modifier(
          widget.achat!.code,
          fournisseurCode: frn,
          magasinCode: widget.achat!.magasinCode,
          lignes: lignes,
          verse: total,
          reference: widget.achat!.reference,
          commentaire: widget.achat!.commentaire,
        );
      }
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _occupe = false);
      return;
    }
    Navigator.of(context).pop(true);
    afficherToast(
      context,
      titre: widget.achat == null ? l10n.entToastRapide : l10n.entToastModifiee,
      description: l10n.entToastReparti,
      ton: DsToastTon.succes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final produits = (ref.watch(produitsProvider).value ?? const <Produit>[])
        .where((p) => (p.actif && !p.service) || p.code == _produit)
        .toList();
    final fournisseurs = (ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        .where((f) => (f.actif && f.code != _frnSysteme) || f.code == _fournisseur)
        .toList();
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    final stocks = ref.watch(stocksParMagasinProvider).value ?? const {};
    final fixe =
        widget.produit ?? (widget.achat != null ? produits.where((p) => p.code == _produit).firstOrNull : null);
    final total = _total;
    final equilibre = DsSplitAllocator.equilibre(total, _repartition);
    return DsDialog(
      titre: fixe != null ? l10n.entRapideTitreProduit(fixe.designation) : l10n.entRapideTitre,
      iconeData: LucideIcons.zap,
      description: fixe != null
          ? l10n.entRapideDescriptionProduit(
              fixe.code,
              formaterNombre((stocks[fixe.code] ?? const <String, double>{}).values.fold<double>(0, (a, q) => a + q)),
            )
          : l10n.entRapideDescription,
      largeur: 720,
      fermable: !_occupe,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('rapide_enregistrer'),
          libelle: equilibre ? l10n.communEnregistrer : l10n.entRepartitionIncomplete,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: _produit != null && total > 0 && equilibre && (lireNombre(_prix.text) ?? -1) >= 0
              ? _enregistrer
              : null,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          DsFormRow(
            libelle: l10n.dsPosProduit,
            obligatoire: true,
            onLookup: fixe != null
                ? null
                : () async {
                    final choix = await choisirProduits(context, ref);
                    if (choix.isEmpty) return;
                    setState(() {
                      _produit = choix.first.code;
                      _prix.text = texteQuantite(choix.first.prixAchat);
                    });
                  },
            child: DsSelect<String>(
              cle: const ValueKey('rapide_produit'),
              valeur: _produit,
              placeholder: l10n.entChoisirProduit,
              options: [for (final p in produits) p.code],
              libelle: (c) => produits.where((p) => p.code == c).firstOrNull?.designation ?? c,
              actif: fixe == null,
              onChanged: (v) => setState(() {
                _produit = v;
                final p = produits.where((p) => p.code == v).firstOrNull;
                if (p != null) _prix.text = texteQuantite(p.prixAchat);
              }),
            ),
          ),
          DsGrilleFormulaire(
            espaceX: 20,
            children: [
              DsFormRow(
                libelle: l10n.stkQte,
                obligatoire: true,
                child: DsTextField(
                  key: const ValueKey('rapide_quantite'),
                  controller: _quantite,
                  numerique: true,
                  suffixeTexte: l10n.stkPcs,
                  onChanged: (v) => setState(() => _repartition = {widget.principal: lireNombre(v) ?? 0}),
                ),
              ),
              DsFormRow(
                libelle: l10n.produitsColPrixAchat,
                obligatoire: true,
                largeurLibelle: 100,
                child: DsTextField(
                  key: const ValueKey('rapide_prix'),
                  controller: _prix,
                  numerique: true,
                  suffixeTexte: devise,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          DsFormRow(
            libelle: l10n.achatFournisseur,
            child: DsSelect<String?>(
              valeur: _fournisseur,
              placeholder: l10n.entAucunFournisseur,
              options: [null, for (final f in fournisseurs) f.code],
              libelle: (c) =>
                  c == null ? l10n.entAucunFournisseur : (fournisseurs.where((f) => f.code == c).firstOrNull?.nom ?? c),
              onChanged: (v) => setState(() => _fournisseur = v),
            ),
          ),
          DsFormRow(
            libelle: l10n.entRepartitionOption,
            alignerDebut: true,
            child: DsSplitAllocator(
              total: total,
              unite: l10n.stkPcs,
              magasins: [
                for (final m in magasins)
                  DsMagasinRepartition(
                    code: m.code,
                    nom: m.nom,
                    principal: m.code == widget.principal,
                    stock: _produit == null ? null : (stocks[_produit]?[m.code] ?? 0),
                  ),
              ],
              valeur: _repartition,
              onChanged: (v) => setState(() => _repartition = v),
              libelles: libellesRepartition(l10n),
            ),
          ),
        ],
      ),
    );
  }
}

// ———————————————————————————— Détail / annulation ————————————————————————————

/// Détail d'une entrée (`EntityDetailDialog` 1060 px) avec « Imprimer ».
Future<void> afficherDetailEntree(BuildContext context, WidgetRef ref, Achat a) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final fournisseurs = {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
  final magasins = {for (final m in await ref.read(magasinsProvider.future)) m.code: m.nom};
  final utilisateurs = await ref.read(nomsUtilisateursProvider.future);
  final bons = await ref.read(bonsReceptionProvider.future);
  if (!context.mounted) return;
  final frn = fournisseurs[a.fournisseurCode] ?? a.fournisseurCode;
  final mag = magasins[a.magasinCode] ?? a.magasinCode;
  final bon = bons.where((b) => b.achatCode == a.code).firstOrNull;
  final colonnes = <DsColonne<AchatLigne>>[
    DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
    DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.designation, fort: true, flex: 3),
    DsColonne(
      id: 'qte',
      libelle: l10n.stkQte,
      numerique: true,
      valeur: (l) => l.quantite,
      cellule: (_, l) => Text(formaterNombre(l.quantite)),
    ),
    DsColonne(
      id: 'prix',
      libelle: l10n.produitsColPrixAchat,
      numerique: true,
      valeur: (l) => l.prixAchat,
      cellule: (_, l) => Text(formaterMontant(l.prixAchat, devise)),
    ),
    DsColonne(
      id: 'total',
      libelle: l10n.communTotal,
      numerique: true,
      valeur: (l) => l.total,
      cellule: (_, l) => Text(formaterMontant(l.total, devise)),
    ),
  ];
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 1060,
      icone: LucideIcons.packagePlus,
      titre: l10n.entDetailTitre(a.code),
      description: '${formatDate.format(a.date)} · $frn · $mag',
      badges: [BadgeStatut(a.statutPaiement)],
      onModifier: () => modifierEntree(context, ref, a),
      modifierDesactive: !a.actif,
      piedSupplementaire: [
        DsButton(
          libelle: l10n.entImprimer,
          icone: LucideIcons.printer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => exporterTableau(
            context,
            ref,
            id: 'entree_${a.code}',
            titre: '${l10n.entDetailTitre(a.code)} · $frn',
            colonnes: colonnes,
            lignes: a.lignes,
            format: DsFormatExport.pdf,
          ),
        ),
      ],
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${a.lignes.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.retoursMontant, valeur: f2(a.total), suffixe: devise, icone: LucideIcons.shoppingCart),
        DsStatItem(libelle: l10n.entPaye, valeur: f2(a.verse), suffixe: devise, icone: LucideIcons.banknote),
        DsStatItem(
          libelle: l10n.achatColReste,
          valeur: f2(a.reste),
          suffixe: devise,
          icone: LucideIcons.handCoins,
          ton: a.reste > 0.005 ? DsBadgeTon.danger : DsBadgeTon.avertissement,
        ),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.entInformations,
          icone: LucideIcons.info,
          items: [
            DsKeyValue(l10n.produitsColCode, a.code),
            DsKeyValue(l10n.entNumFacture, a.reference ?? '—'),
            DsKeyValue(l10n.achatFournisseur, frn),
            DsKeyValue(l10n.stockColMagasin, mag),
            DsKeyValue(l10n.communDate, formatDate.format(a.date)),
            DsKeyValue(
              l10n.achatColSource,
              bon != null ? '${libelleSourceAchat(l10n, a)} (${bon.code})' : libelleSourceAchat(l10n, a),
            ),
            if (a.besoinCode != null) DsKeyValue(l10n.entListeBesoins, a.besoinCode),
          ],
        ),
        DsSectionDetail(
          titre: l10n.entProduitsRecus,
          icone: LucideIcons.package,
          nbLignes: a.lignes.length,
          tableau: DsDataTable<AchatLigne>(
            dense: true,
            encadre: false,
            pagine: false,
            hauteurMax: 320,
            cle: (l) => l.produitCode,
            lignes: a.lignes,
            colonnes: colonnes,
          ),
        ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.ventesCreePar, utilisateurs[a.utilisateurCode] ?? a.utilisateurCode),
            DsKeyValue(l10n.stkValideLe, formatDateHeure.format(a.date)),
            if (a.annulation != null) ...[
              DsKeyValue(l10n.ventesAnnulePar, utilisateurs[a.annulation!.par] ?? a.annulation!.par),
              DsKeyValue(l10n.ventesMotifAnnulation, a.annulation!.motif),
            ],
            if (a.commentaire != null) DsKeyValue(l10n.retoursObservation, a.commentaire),
          ],
        ),
      ],
    ),
  );
}

/// Annulation en lot (motif obligatoire) : stock retiré, paiement immédiat annulé, crédit fournisseur corrigé.
Future<void> annulerEntrees(BuildContext context, WidgetRef ref, List<Achat> choix, VoidCallback effacer) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final fournisseurs = {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
  final service = ref.read(achatServiceProvider);
  final blocages = {for (final a in choix) a.code: await service.blocage(a)};
  if (!context.mounted) return;
  final motif = await afficherActionLot(
    context,
    action: DsActionLot.annuler,
    entite: l10n.entEntite,
    entitePluriel: l10n.entEntitePluriel,
    motifRequis: true,
    elements: [
      for (final a in choix)
        DsElementLot(
          id: a.code,
          titre: '${a.code} · ${fournisseurs[a.fournisseurCode] ?? a.fournisseurCode}',
          sousTitre: a.reference,
          meta: formaterMontant(a.total, devise),
          motifBlocage: switch (blocages[a.code]) {
            null => null,
            ErreurAchat.dejaAnnule => l10n.entBloqueDejaAnnulee,
            ErreurAchat.stockInsuffisant => l10n.entBloqueVendus,
            final e => messageErreurAchat(l10n, e),
          },
        ),
    ],
  );
  if (motif == null || !context.mounted) return;
  final ok = await executerEntree(
    context,
    ref,
    () => service.annulerEntrees([
      for (final a in choix)
        if (blocages[a.code] == null) a.code,
    ], motif: motif),
  );
  effacer();
  if (ok && context.mounted) {
    afficherToast(context, titre: l10n.entToastAnnulees, description: l10n.entToastAnnuleesDetail);
  }
}
