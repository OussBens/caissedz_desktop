import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import 'statuts.dart';

/// Ligne d'un [DocFormDialog] : produit, quantité et prix saisis.
class LigneDoc {
  LigneDoc({required this.produit, this.quantite = 1, double? prix}) : prix = prix ?? produit.prixAchat;
  final Produit produit;
  double quantite;
  double prix;
}

/// Sélection multiple de produits (`PickerDialog` : code, produit, catégorie, stock, prix d'achat).
Future<List<Produit>> choisirProduits(
  BuildContext context,
  WidgetRef ref, {
  String? titre,
  Set<String> exclus = const {},
  bool prixVente = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final produits = (await ref.read(produitsProvider.future)).where((p) => p.actif && !exclus.contains(p.code)).toList();
  final categories = {for (final c in await ref.read(categoriesProvider.future)) c.code: c.nom};
  final stocks = await ref.read(stocksProduitsProvider.future);
  final devise = ref.read(deviseProvider);
  if (!context.mounted) return const [];
  final choix = await afficherDialog<List<Produit>>(
    context,
    builder: (_) => DsPickerDialog<Produit>(
      titre: titre ?? l10n.dsPosLigneAjouter,
      icone: LucideIcons.package,
      multiple: true,
      elements: produits,
      libelle: (p) => p.designation,
      indiceRecherche: l10n.prdRechercheProduits,
      colonnes: [
        DsColonnePicker(libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true, mono: true, largeur: 110),
        DsColonnePicker(libelle: l10n.dsPosProduit, valeur: (p) => p.designation, fort: true),
        DsColonnePicker(libelle: l10n.produitsColCategorie, valeur: (p) => categories[p.categorieCode] ?? ''),
        DsColonnePicker(
          libelle: l10n.produitsColStock,
          valeur: (p) => formaterNombre(stocks[p.code] ?? 0),
          largeur: 90,
        ),
        DsColonnePicker(
          libelle: prixVente ? l10n.produitsColPrixVente : l10n.produitsColPrixAchat,
          valeur: (p) => formaterMontant(prixVente ? p.prixVente : p.prixAchat, devise),
          largeur: 130,
        ),
      ],
    ),
  );
  return choix ?? const [];
}

/// Dialog de document (`DocFormDialog` du DS v2.2 : Sortie, Transfert, Besoin, Pack, Remise…) :
/// en-tête en grille 2 colonnes, éditeur de lignes produits, bloc complémentaire, Annuler / Enregistrer.
class DocFormDialog extends ConsumerStatefulWidget {
  const DocFormDialog({
    super.key,
    required this.titre,
    required this.icone,
    required this.entete,
    required this.lignes,
    required this.onLignes,
    required this.colonnes,
    required this.totalLigne,
    required this.onEnregistrer,
    this.description,
    this.largeur = 1000,
    this.peutEnregistrer = true,
    this.libelleEnregistrer,
    this.titreSelecteur,
    this.apres,
    this.erreurs = const {},
    this.prixVenteSelecteur = false,
    this.libelleTotal,
    this.cleEnregistrer,
  });
  final String titre;
  final IconData icone;
  final String? description;
  final double largeur;
  final List<Widget> entete;
  final List<LigneDoc> lignes;
  final ValueChanged<List<LigneDoc>> onLignes;
  final List<DsColonneLigne<LigneDoc>> colonnes;
  final double Function(LigneDoc) totalLigne;

  /// Enregistre ; renvoie `true` pour fermer le dialog.
  final Future<bool> Function() onEnregistrer;
  final bool peutEnregistrer;
  final String? libelleEnregistrer;
  final String? titreSelecteur;
  final Widget? apres;
  final Map<Object, Map<String, String>> erreurs;
  final bool prixVenteSelecteur;
  final String? libelleTotal;
  final Key? cleEnregistrer;

  @override
  ConsumerState<DocFormDialog> createState() => _DocFormDialogState();
}

class _DocFormDialogState extends ConsumerState<DocFormDialog> {
  bool _occupe = false;

  Future<void> _ajouter() async {
    final choix = await choisirProduits(
      context,
      ref,
      titre: widget.titreSelecteur,
      exclus: {for (final l in widget.lignes) l.produit.code},
      prixVente: widget.prixVenteSelecteur,
    );
    if (choix.isEmpty) return;
    widget.onLignes([...widget.lignes, for (final p in choix) LigneDoc(produit: p)]);
  }

  Future<void> _enregistrer() async {
    setState(() => _occupe = true);
    final fermer = await widget.onEnregistrer();
    if (!mounted) return;
    if (fermer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final ok = widget.peutEnregistrer && widget.lignes.isNotEmpty && widget.erreurs.isEmpty;
    return DsDialog(
      titre: widget.titre,
      iconeData: widget.icone,
      description: widget.description,
      largeur: widget.largeur,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: widget.cleEnregistrer,
          libelle: widget.libelleEnregistrer ?? l10n.communEnregistrer,
          icone: LucideIcons.check,
          chargement: _occupe,
          onPressed: ok ? _enregistrer : null,
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          DsGrilleFormulaire(children: widget.entete),
          DsLineItemsEditor<LigneDoc>(
            lignes: widget.lignes,
            colonnes: widget.colonnes,
            totalLigne: widget.totalLigne,
            quantite: (l) => l.quantite,
            cle: (l) => l.produit.code,
            devise: devise,
            erreurs: widget.erreurs,
            libelleTotal: widget.libelleTotal,
            libelleAjouter: l10n.dsPosLigneAjouter,
            onAjouter: _ajouter,
            onSupprimer: (l) => widget.onLignes(widget.lignes.where((x) => x != l).toList()),
          ),
          ?widget.apres,
        ],
      ),
    );
  }
}

/// Nombre saisi dans une cellule ou un champ (virgule acceptée), 0 si vide ou invalide.
double nombreSaisi(String s) => lireNombre(s) ?? 0;

/// Texte d'une quantité pour une cellule éditable.
String texteQuantite(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : formaterNombre(v, decimales: 2);

/// Montant formaté sans devise, réexporté pour les colonnes de lignes.
String montantLigne(double v) => f2(v);
