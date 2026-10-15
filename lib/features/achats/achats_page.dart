import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/achat_service.dart';
import '../../application/cloture_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/achat.dart';
import '../../domain/models/produit.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'smart_scan_dialog.dart';

final achatServiceProvider = Provider<AchatService>(
  (ref) => AchatService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    periodeCloturee: ClotureService.periodeCloturee,
  ),
);

final achatsProvider = FutureProvider<List<Achat>>((ref) {
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  return ref.watch(achatServiceProvider).achats();
});

String messageErreurAchat(AppLocalizations l10n, ErreurAchat e) => switch (e) {
  ErreurAchat.lignesVides => l10n.achatErreurLignes,
  ErreurAchat.quantiteInvalide => l10n.achatErreurQuantite,
  ErreurAchat.prixInvalide => l10n.achatErreurPrix,
  ErreurAchat.produitInconnu => l10n.achatErreurProduit,
  ErreurAchat.fournisseurInconnu => l10n.achatErreurFournisseur,
  ErreurAchat.achatInconnu => l10n.achatErreurInconnu,
  ErreurAchat.dejaAnnule => l10n.achatErreurAnnule,
  ErreurAchat.periodeCloturee => l10n.achatErreurPeriode,
  ErreurAchat.stockInsuffisant => l10n.achatErreurStock,
  ErreurAchat.retourLie => l10n.achatErreurRetourLie,
};

/// Ligne éditable d'une entrée.
class LigneAchatEdition {
  LigneAchatEdition({required this.produit, required this.quantite, required this.prixAchat, this.nouveauPrixVente});
  final Produit produit;
  double quantite;
  double prixAchat;
  double? nouveauPrixVente;
}

/// Module Entrées / Achats : liste, nouvelle entrée, Smart Scan IA, annulation.
class AchatsPage extends ConsumerWidget {
  const AchatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final achats = ref.watch(achatsProvider).value ?? const [];
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const [];
    final session = ref.watch(sessionProvider);
    final df = DateFormat('dd/MM/yyyy');
    String nomF(String code) => fournisseurs.where((f) => f.code == code).firstOrNull?.nom ?? code;
    return DsPage(
      titre: l10n.achatsTitre,
      actions: [
        DsButton(
          libelle: l10n.achatSmartScan,
          icone: LucideIcons.sparkles,
          variante: DsButtonVariante.secondaire,
          onPressed: () {
            afficherSmartScan(context, ref);
          },
        ),
        DsButton(
          libelle: l10n.achatNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            afficherFormulaireAchat(context, ref);
          },
        ),
      ],
      child: DsDataTable<Achat>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (a) => a.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (a) => a.date,
            largeur: 110,
            cellule: (_, a) => Text(df.format(a.date)),
          ),
          DsColonne(id: 'f', libelle: l10n.achatFournisseur, valeur: (a) => nomF(a.fournisseurCode), flex: 2),
          DsColonne(id: 'ref', libelle: l10n.achatReference, valeur: (a) => a.reference, flex: 2),
          DsColonne(
            id: 't',
            libelle: l10n.achatColTotal,
            valeur: (a) => a.total,
            numerique: true,
            permission: Permission.voirPrixAchat.code,
            cellule: (_, a) => Text(formaterMontant(a.total, devise)),
          ),
          DsColonne(
            id: 'v',
            libelle: l10n.achatColVerse,
            valeur: (a) => a.verse,
            numerique: true,
            permission: Permission.voirPrixAchat.code,
            cellule: (_, a) => Text(formaterMontant(a.verse, devise)),
          ),
          DsColonne(
            id: 'r',
            libelle: l10n.achatColReste,
            valeur: (a) => a.reste,
            numerique: true,
            permission: Permission.voirPrixAchat.code,
            cellule: (_, a) => Text(a.reste > 0 ? formaterMontant(a.reste, devise) : ''),
          ),
          DsColonne(
            id: 's',
            libelle: l10n.achatColSource,
            valeur: (a) => a.source,
            cellule: (_, a) => Text(a.source == 'Smart Scan' ? l10n.sourceSmartScan : l10n.sourceManuel),
          ),
          DsColonne(
            id: 'st',
            libelle: l10n.achatColStatut,
            valeur: (a) => a.statut,
            cellule: (_, a) => DsBadge(
              libelle: a.statut == StatutsAchat.annule ? l10n.statutAchatAnnule : l10n.statutAchatValide,
              ton: a.statut == StatutsAchat.annule ? DsBadgeTon.danger : DsBadgeTon.succes,
            ),
          ),
        ],
        lignes: achats,
        cle: (a) => a.code,
        permissions: session?.permissions.map((p) => p.code).toSet() ?? const {},
        messageVide: l10n.achatAucun,
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.achatAnnuler,
            icone: LucideIcons.ban,
            destructif: true,
            onSelected: (a) async {
              if (!await afficherConfirmation(
                context,
                titre: l10n.achatAnnuler,
                message: l10n.achatConfirmerAnnulation(a.code),
                destructif: true,
              )) {
                return;
              }
              try {
                await ref.read(achatServiceProvider).annuler(a.code);
                rafraichirCommerce(ref);
                rafraichirStock(ref);
              } on AchatException catch (e) {
                if (!context.mounted) return;
                unawaited(
                  afficherResultat(
                    context,
                    type: DsResultatType.erreur,
                    titre: l10n.achatAnnuler,
                    message: messageErreurAchat(l10n, e.erreur),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Formulaire d'entrée (manuel ou pré-rempli par Smart Scan).
Future<void> afficherFormulaireAchat(
  BuildContext context,
  WidgetRef ref, {
  List<LigneAchatEdition>? lignesInitiales,
  String? referenceInitiale,
  String source = 'Manuel',
}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final produits = await ref.read(produitsProvider.future);
  final fournisseurs = (await ref.read(fournisseursProvider.future)).where((f) => f.actif).toList();
  final magasins = (await ref.read(magasinsProvider.future)).where((m) => m.actif).toList();
  final principal = await ref.read(magasinPrincipalProvider.future);
  if (!context.mounted || fournisseurs.isEmpty || magasins.isEmpty) return;
  var fournisseur = fournisseurs.first.code;
  var magasin = principal;
  var mode = 'Espèces';
  var majPrix = true;
  final reference = TextEditingController(text: referenceInitiale ?? '');
  final verse = TextEditingController(text: '0');
  final lignes = [...?lignesInitiales];
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final c = ctx.ds.colors;
        final t = ctx.ds.typo;
        final total = lignes.fold(0.0, (s, l) => s + l.quantite * l.prixAchat);
        return DsDialog(
          titre: l10n.achatNouveau,
          largeur: 760,
          icone: Icon(LucideIcons.packagePlus, color: c.primaire),
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communValider,
              icone: LucideIcons.check,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.achatFournisseur,
                      valeur: fournisseur,
                      options: fournisseurs.map((f) => f.code).toList(),
                      libelle: (code) => fournisseurs.firstWhere((f) => f.code == code).nom,
                      onChanged: (v) => setState(() => fournisseur = v ?? fournisseur),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.achatMagasin,
                      valeur: magasin,
                      options: magasins.map((m) => m.code).toList(),
                      libelle: (code) => magasins.firstWhere((m) => m.code == code).nom,
                      onChanged: (v) => setState(() => magasin = v ?? magasin),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsTextField(controller: reference, libelle: l10n.achatReference),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.lg),
              Row(
                children: [
                  Expanded(child: Text(l10n.achatLignes, style: t.titreSm)),
                  DsButton(
                    libelle: l10n.transfertAjouterLigne,
                    icone: LucideIcons.plus,
                    taille: DsButtonTaille.sm,
                    variante: DsButtonVariante.secondaire,
                    onPressed: () async {
                      final p = await afficherSelecteur<Produit>(
                        ctx,
                        titre: l10n.transfertAjouterLigne,
                        elements: produits,
                        libelle: (p) => p.designation,
                        sousLibelle: (p) => p.code,
                      );
                      if (p == null || lignes.any((l) => l.produit.code == p.code)) return;
                      setState(() => lignes.add(LigneAchatEdition(produit: p, quantite: 1, prixAchat: p.prixAchat)));
                    },
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.sm),
              for (final (i, l) in lignes.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: DsSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l.produit.designation, style: t.corps, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 90,
                        child: DsTextField(
                          key: ValueKey('aq_${l.produit.code}'),
                          controller: TextEditingController(text: _fmt(l.quantite)),
                          indice: l10n.communQuantite,
                          alignement: TextAlign.end,
                          taille: DsTailles.controleSm,
                          onChanged: (v) => setState(() => l.quantite = double.tryParse(v.replaceAll(',', '.')) ?? 0),
                        ),
                      ),
                      const SizedBox(width: DsSpacing.xs),
                      SizedBox(
                        width: 110,
                        child: DsTextField(
                          key: ValueKey('ap_${l.produit.code}'),
                          controller: TextEditingController(text: _fmt(l.prixAchat)),
                          indice: l10n.achatPrixAchat,
                          alignement: TextAlign.end,
                          taille: DsTailles.controleSm,
                          onChanged: (v) => setState(() => l.prixAchat = double.tryParse(v.replaceAll(',', '.')) ?? 0),
                        ),
                      ),
                      const SizedBox(width: DsSpacing.xs),
                      SizedBox(
                        width: 110,
                        child: DsTextField(
                          controller: TextEditingController(
                            text: l.nouveauPrixVente == null ? '' : _fmt(l.nouveauPrixVente!),
                          ),
                          indice: l10n.achatNouveauPrixVente,
                          alignement: TextAlign.end,
                          taille: DsTailles.controleSm,
                          onChanged: (v) => l.nouveauPrixVente = double.tryParse(v.replaceAll(',', '.')),
                        ),
                      ),
                      DsIconButton(
                        icone: LucideIcons.trash2,
                        tooltip: l10n.communSupprimer,
                        couleur: c.danger,
                        onPressed: () => setState(() => lignes.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(child: Text('${l10n.achatColTotal} : ${formaterMontant(total, devise)}', style: t.titreSm)),
                  SizedBox(
                    width: 140,
                    child: DsTextField(controller: verse, libelle: l10n.achatVerse, typeClavier: TextInputType.number),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  SizedBox(
                    width: 160,
                    child: DsSelect<String>(
                      titre: l10n.achatModePaiement,
                      valeur: mode,
                      options: const ['Espèces', 'Carte', 'Chèque', 'Virement'],
                      libelle: (m) => libelleModePaiement(l10n, m),
                      onChanged: (v) => setState(() => mode = v ?? mode),
                    ),
                  ),
                ],
              ),
              DsSwitch(
                valeur: majPrix,
                libelle: l10n.achatMettreAJourPrix,
                onChanged: (v) => setState(() => majPrix = v),
              ),
            ],
          ),
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final a = await ref
        .read(achatServiceProvider)
        .enregistrer(
          fournisseurCode: fournisseur,
          magasinCode: magasin,
          lignes: [
            for (final l in lignes)
              DemandeAchatLigne(
                produitCode: l.produit.code,
                quantite: l.quantite,
                prixAchat: l.prixAchat,
                nouveauPrixVente: l.nouveauPrixVente,
              ),
          ],
          reference: reference.text.trim().isEmpty ? null : reference.text.trim(),
          verse: double.tryParse(verse.text.replaceAll(',', '.')) ?? 0,
          modePaiement: mode,
          source: source,
          mettreAJourPrixAchat: majPrix,
        );
    rafraichirCommerce(ref);
    rafraichirStock(ref);
    rafraichirCatalogue(ref);
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.achatNouveau,
        message: l10n.achatEnregistre(a.code, formaterMontant(a.total, devise), formaterMontant(a.reste, devise)),
      ),
    );
  } on AchatException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.achatNouveau,
        message: messageErreurAchat(l10n, e.erreur),
      ),
    );
  }
}

String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
