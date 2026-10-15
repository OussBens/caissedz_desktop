import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/permissions.dart';
import '../produits/produit_form_dialog.dart';
import '../produits/produits_providers.dart';
import 'stock_providers.dart';

/// Ligne « niveau » affichée : produit + quantités.
class _LigneNiveau {
  const _LigneNiveau(this.produit, this.quantite, this.nombre, this.seuil);
  final Produit produit;
  final double quantite;
  final double nombre;
  final int seuil;
  bool get sousSeuil => quantite <= seuil;
}

/// Module Stock : niveaux par magasin et journal des mouvements.
class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  int _onglet = 0;
  String _recherche = '';
  bool _sousSeuilSeulement = false;

  Future<void> executerStock(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      rafraichirStock(ref);
    } on StockException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.stockTitre,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    final filtre = ref.watch(filtreMagasinProvider);
    return DsPage(
      titre: l10n.stockTitre,
      onRecherche: (v) => setState(() => _recherche = v),
      actions: [
        DsButton(
          libelle: l10n.stockInventaire,
          icone: LucideIcons.clipboardCheck,
          variante: DsButtonVariante.secondaire,
          onPressed: () {
            _dialogueMouvement(inventaire: true);
          },
        ),
        DsButton(
          libelle: l10n.stockEntreeManuelle,
          icone: LucideIcons.packagePlus,
          onPressed: () {
            _dialogueMouvement(inventaire: false);
          },
        ),
      ],
      filtres: Row(
        children: [
          SizedBox(
            width: 260,
            child: DsSelect<String?>(
              valeur: filtre,
              options: [null, ...magasins.map((m) => m.code)],
              libelle: (c) => c == null ? l10n.stockTousMagasins : magasins.firstWhere((m) => m.code == c).nom,
              onChanged: (v) => ref.read(filtreMagasinProvider.notifier).changer(v),
            ),
          ),
          const SizedBox(width: DsSpacing.md),
          DsButton(
            libelle: l10n.stockSousSeuil,
            icone: LucideIcons.triangleAlert,
            taille: DsButtonTaille.sm,
            variante: _sousSeuilSeulement ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
            onPressed: () => setState(() => _sousSeuilSeulement = !_sousSeuilSeulement),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsOnglets(
            onglets: [l10n.stockOngletNiveaux, l10n.stockOngletJournal],
            courant: _onglet,
            onChanged: (i) => setState(() => _onglet = i),
          ),
          const SizedBox(height: DsSpacing.lg),
          Expanded(child: _onglet == 0 ? _niveaux(l10n) : _journal(l10n)),
        ],
      ),
    );
  }

  Widget _niveaux(AppLocalizations l10n) {
    final produits = ref.watch(produitsProvider).value ?? const [];
    final niveaux = ref.watch(niveauxStockProvider).value ?? const [];
    final seuilGlobal = ref.watch(parametresVenteProvider).value?.seuilStockGlobal ?? 5;
    final session = ref.watch(sessionProvider);
    final devise = ref.watch(deviseProvider);
    final parProduit = {for (final n in niveaux) n.produitCode: n};
    final r = _recherche.trim().toLowerCase();
    final lignes = [
      for (final p in produits)
        if (r.isEmpty ||
            p.designation.toLowerCase().contains(r) ||
            p.code.toLowerCase().contains(r) ||
            (p.codeBarres?.contains(r) ?? false))
          _LigneNiveau(
            p,
            parProduit[p.code]?.quantite ?? 0,
            parProduit[p.code]?.nombre ?? 0,
            p.seuilStock ?? seuilGlobal,
          ),
    ].where((l) => !_sousSeuilSeulement || l.sousSeuil).toList();
    return DsDataTable<_LigneNiveau>(
      colonnes: [
        DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produit.code, largeur: 100),
        DsColonne(id: 'p', libelle: l10n.stockColProduit, valeur: (l) => l.produit.designation, flex: 3),
        DsColonne(
          id: 'q',
          libelle: l10n.stockColQuantite,
          valeur: (l) => l.quantite,
          numerique: true,
          cellule: (_, l) =>
              DsBadge(libelle: _fmt(l.quantite), ton: l.sousSeuil ? DsBadgeTon.danger : DsBadgeTon.succes),
          total: (ls) => _fmt(ls.fold(0.0, (s, l) => s + l.quantite)),
        ),
        DsColonne(
          id: 'n',
          libelle: l10n.stockColNombre,
          valeur: (l) => l.nombre,
          numerique: true,
          cellule: (_, l) => Text(l.produit.suiviNombre ? _fmt(l.nombre) : ''),
        ),
        DsColonne(id: 's', libelle: l10n.stockColSeuil, valeur: (l) => l.seuil, numerique: true),
        DsColonne(
          id: 'v',
          libelle: l10n.stockColValeur,
          valeur: (l) => l.quantite * l.produit.prixAchat,
          numerique: true,
          permission: Permission.voirPrixAchat.code,
          cellule: (_, l) => Text(formaterMontant(l.quantite * l.produit.prixAchat, devise)),
          total: (ls) => formaterMontant(ls.fold(0.0, (s, l) => s + l.quantite * l.produit.prixAchat), devise),
        ),
      ],
      lignes: lignes,
      cle: (l) => l.produit.code,
      permissions: session?.permissions.map((p) => p.code).toSet() ?? const {},
      afficherTotaux: true,
      actionsContextuelles: [
        DsActionContextuelle(
          libelle: l10n.stockEntreeManuelle,
          icone: LucideIcons.packagePlus,
          onSelected: (l) => _dialogueMouvement(inventaire: false, produit: l.produit),
        ),
        DsActionContextuelle(
          libelle: l10n.stockInventaire,
          icone: LucideIcons.clipboardCheck,
          onSelected: (l) => _dialogueMouvement(inventaire: true, produit: l.produit),
        ),
        DsActionContextuelle(
          libelle: l10n.produitModifier,
          icone: LucideIcons.pencil,
          onSelected: (l) => afficherFormulaireProduit(context, produit: l.produit),
        ),
      ],
    );
  }

  Widget _journal(AppLocalizations l10n) {
    final produits = ref.watch(produitsProvider).value ?? const [];
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    final mouvements = ref.watch(mouvementsProvider).value ?? const [];
    final r = _recherche.trim().toLowerCase();
    String nomProduit(String code) => produits.where((p) => p.code == code).firstOrNull?.designation ?? code;
    final lignes = mouvements
        .where(
          (m) =>
              r.isEmpty ||
              nomProduit(m.produitCode).toLowerCase().contains(r) ||
              (m.referenceCode?.toLowerCase().contains(r) ?? false),
        )
        .toList();
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return DsDataTable<MouvementStock>(
      colonnes: [
        DsColonne(
          id: 'd',
          libelle: l10n.stockColDate,
          valeur: (m) => m.date,
          largeur: 140,
          cellule: (_, m) => Text(df.format(m.date)),
        ),
        DsColonne(id: 'p', libelle: l10n.stockColProduit, valeur: (m) => nomProduit(m.produitCode), flex: 3),
        DsColonne(
          id: 'm',
          libelle: l10n.stockColMagasin,
          valeur: (m) => magasins.where((x) => x.code == m.magasinCode).firstOrNull?.nom ?? m.magasinCode,
          flex: 2,
        ),
        DsColonne(
          id: 't',
          libelle: l10n.stockColType,
          valeur: (m) => m.type,
          cellule: (_, m) => DsBadge(
            libelle: libelleTypeMouvement(l10n, m.type),
            ton: m.quantite >= 0 ? DsBadgeTon.succes : DsBadgeTon.avertissement,
          ),
        ),
        DsColonne(
          id: 'q',
          libelle: l10n.stockColQuantite,
          valeur: (m) => m.quantite,
          numerique: true,
          cellule: (_, m) => Text(_fmt(m.quantite)),
        ),
        DsColonne(
          id: 'n',
          libelle: l10n.stockColNombre,
          valeur: (m) => m.nombre,
          numerique: true,
          visibleParDefaut: false,
          cellule: (_, m) => Text(m.nombre == 0 ? '' : _fmt(m.nombre)),
        ),
        DsColonne(id: 'ref', libelle: l10n.stockColReference, valeur: (m) => m.referenceCode, flex: 2),
        DsColonne(
          id: 'mo',
          libelle: l10n.stockColMotif,
          valeur: (m) => m.motif,
          flex: 2,
          cellule: (_, m) => Text(m.motif == null ? '' : libelleMotif(l10n, m.motif!)),
        ),
        DsColonne(
          id: 'u',
          libelle: l10n.stockColUtilisateur,
          valeur: (m) => m.utilisateurCode,
          visibleParDefaut: false,
        ),
      ],
      lignes: lignes,
      cle: (m) => m.id ?? m.hashCode,
      messageVide: l10n.stockAucunMouvement,
      taillePage: 50,
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _dialogueMouvement({required bool inventaire, Produit? produit}) async {
    final l10n = AppLocalizations.of(context);
    final produits = await ref.read(produitsProvider.future);
    if (!context.mounted) return;
    final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
    if (produits.isEmpty || magasins.isEmpty) return;
    var produitCode = produit?.code ?? produits.first.code;
    var magasinCode = await ref.read(magasinPrincipalProvider.future);
    final quantite = TextEditingController();
    final nombre = TextEditingController();
    final commentaire = TextEditingController();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final p = produits.firstWhere((x) => x.code == produitCode);
          return DsDialog(
            titre: inventaire ? l10n.stockInventaire : l10n.stockEntreeManuelle,
            largeur: 520,
            actions: [
              DsButton(
                libelle: l10n.communAnnuler,
                variante: DsButtonVariante.secondaire,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              DsButton(
                libelle: l10n.communEnregistrer,
                icone: LucideIcons.check,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
            contenu: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsSelect<String>(
                  titre: l10n.stockColProduit,
                  valeur: produitCode,
                  options: produits.map((x) => x.code).toList(),
                  libelle: (c) => produits.firstWhere((x) => x.code == c).designation,
                  onChanged: (v) => setState(() => produitCode = v ?? produitCode),
                ),
                const SizedBox(height: DsSpacing.md),
                DsSelect<String>(
                  titre: l10n.stockColMagasin,
                  valeur: magasinCode,
                  options: magasins.map((x) => x.code).toList(),
                  libelle: (c) => magasins.firstWhere((x) => x.code == c).nom,
                  onChanged: (v) => setState(() => magasinCode = v ?? magasinCode),
                ),
                const SizedBox(height: DsSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DsTextField(
                        controller: quantite,
                        libelle: inventaire ? l10n.stockQuantiteConstatee : l10n.stockColQuantite,
                        typeClavier: TextInputType.number,
                        autofocus: true,
                      ),
                    ),
                    if (p.suiviNombre) ...[
                      const SizedBox(width: DsSpacing.md),
                      Expanded(
                        child: DsTextField(
                          controller: nombre,
                          libelle: inventaire ? l10n.stockNombreConstate : l10n.stockColNombre,
                          typeClavier: TextInputType.number,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: DsSpacing.md),
                DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
              ],
            ),
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final q = double.tryParse(quantite.text.replaceAll(',', '.')) ?? 0;
    final n = double.tryParse(nombre.text.replaceAll(',', '.'));
    final service = ref.read(stockServiceProvider);
    await executerStock(context, ref, () async {
      if (inventaire) {
        await service.inventorier(
          produitCode: produitCode,
          magasinCode: magasinCode,
          quantiteConstatee: q,
          nombreConstate: n,
          commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
        );
      } else {
        await service.entrerStock(
          produitCode: produitCode,
          magasinCode: magasinCode,
          quantite: q,
          nombre: n ?? 0,
          commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
        );
      }
    });
  }
}
