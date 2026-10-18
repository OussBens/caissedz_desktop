import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import 'carte_entite.dart';
import 'statuts.dart';

/// Ligne d'un [DocFormDialog] : produit, quantité, nombre (2ᵉ stock) et prix saisis.
class LigneDoc {
  LigneDoc({required this.produit, this.quantite = 1, double? prix, this.nombre = 0})
    : prix = prix ?? produit.prixAchat;
  final Produit produit;
  double quantite;
  double prix;

  /// Nombre de pièces (2ᵉ stock « nombre », §8.1) ; 0 si non suivi.
  double nombre;
}

/// 2ᵉ stock « nombre » (§8.1) : propose quantité × pièces par unité aux lignes qui l'exigent et n'en ont pas.
/// [disponible] (sortie, transfert) plafonne la proposition au nombre de pièces en stock.
List<T> proposerNombres<T extends LigneDoc>(
  List<T> lignes, {
  required bool global,
  double Function(LigneDoc)? disponible,
}) {
  for (final l in lignes) {
    if (l.nombre <= 0 && l.produit.exigeNombre(global: global)) {
      final propose = l.quantite * l.produit.nombreParUnite;
      final dispo = disponible?.call(l);
      l.nombre = dispo == null ? propose : propose.clamp(0, dispo < 0 ? 0 : dispo).toDouble();
    }
  }
  return lignes;
}

/// Insère la colonne « Nombre » après la quantité quand une ligne exige le 2ᵉ stock (§8.1).
List<DsColonneLigne<T>> avecColonneNombre<T extends LigneDoc>(
  BuildContext context,
  List<DsColonneLigne<T>> colonnes,
  List<T> lignes, {
  required bool global,
  required VoidCallback onEdition,
}) {
  if (!lignes.any((l) => l.produit.exigeNombre(global: global))) return colonnes;
  final i = colonnes.indexWhere((c) => c.id == 'qte');
  return [...colonnes]..insert(
    i + 1,
    DsColonneLigne<T>(
      id: 'nombre',
      libelle: AppLocalizations.of(context).stkNombre,
      numerique: true,
      editable: true,
      largeur: 90,
      valeur: (l) => l.produit.exigeNombre(global: global) || l.nombre > 0 ? texteQuantite(l.nombre) : '—',
      onEdition: (l, v) {
        l.nombre = nombreSaisi(v);
        onEdition();
      },
    ),
  );
}

/// Ajoute l'erreur « nombre obligatoire » (> 0) des lignes qui exigent le 2ᵉ stock (§8.1).
/// Avec [disponible] (document qui sort du stock) : nombre facultatif quand il n'en reste plus en stock (la
/// quantité peut alors sortir seule), et plafonné aux pièces disponibles.
Map<Object, Map<String, String>> erreursNombre(
  BuildContext context,
  Map<Object, Map<String, String>> erreurs,
  List<LigneDoc> lignes, {
  required bool global,
  double Function(LigneDoc)? disponible,
}) {
  final l10n = AppLocalizations.of(context);
  String? erreur(LigneDoc l) {
    final dispo = disponible?.call(l);
    if (dispo != null && l.nombre > dispo + 1e-9) return l10n.stkNombreDispo(formaterNombre(dispo < 0 ? 0 : dispo));
    if (l.nombre <= 0 && l.produit.exigeNombre(global: global) && (dispo == null || dispo > 1e-9)) {
      return l10n.stkNombreObligatoire;
    }
    return null;
  }

  return {
    ...erreurs,
    for (final l in lignes)
      if (erreur(l) case final message?) l.produit.code: {...?erreurs[l.produit.code], 'nombre': message},
  };
}

/// Sélection multiple de produits (`PickerDialog` : code, produit, catégorie, stock, prix d'achat). Avec
/// [magasin] (transfert : magasin de départ), la quantité dans ce magasin s'affiche à côté du stock total.
Future<List<Produit>> choisirProduits(
  BuildContext context,
  WidgetRef ref, {
  String? titre,
  Set<String> exclus = const {},
  bool prixVente = false,
  String? magasin,
}) async {
  final l10n = AppLocalizations.of(context);
  final produits = (await ref.read(produitsProvider.future)).where((p) => p.actif && !exclus.contains(p.code)).toList();
  final categories = {for (final c in await ref.read(categoriesProvider.future)) c.code: c.nom};
  final stocks = await ref.read(stocksProduitsProvider.future);
  final parMagasin = magasin == null ? null : await ref.read(stocksParMagasinProvider.future);
  final nomMagasin = magasin == null
      ? ''
      : (await ref.read(magasinsProvider.future)).where((m) => m.code == magasin).firstOrNull?.nom ?? magasin;
  double dansMagasin(Produit p) => parMagasin?[p.code]?[magasin] ?? 0;
  final devise = ref.read(deviseProvider);
  // Documents de vente : prix TTC (prix de vente HT + TVA), ou HT si les documents sont sans TVA ; achats : prix
  // d'achat.
  final prixDocument = ref.read(prixDocumentsProvider);
  final avecTva = ref.read(parametresVenteProvider).value?.tvaDocuments ?? true;
  double prix(Produit p) => prixVente ? prixDocument(p) : p.prixAchat;
  final libellePrix = prixVente ? (avecTva ? l10n.docPuTtc : l10n.docPuHt) : l10n.produitsColPrixAchat;
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
      largeur: 960,
      hauteurMax: hauteurListeDialog(context, reserve: 320),
      hauteurFixe: true,
      hauteurCarte: 172,
      carte: (context, p, etat) {
        final stock = stocks[p.code] ?? 0;
        return CarteEntite(
          etat: etat,
          titre: p.designation,
          sousTitre: '${p.code} · ${categories[p.categorieCode] ?? ''}',
          icone: LucideIcons.package,
          initiales: false,
          image: imageProduit(p.image),
          statut: p.service ? null : (stock <= 0 ? 'rupture' : 'disponible'),
          montant: formaterMontant(prix(p), devise),
          libelleMontant: libellePrix,
          lignes: [
            (LucideIcons.boxes, p.service ? l10n.prdService : l10n.prdStockN(formaterNombre(stock))),
            if (magasin != null && !p.service)
              (LucideIcons.warehouse, l10n.stkStockMagasinN(nomMagasin, formaterNombre(dansMagasin(p)))),
          ],
        );
      },
      colonnes: [
        DsColonnePicker(libelle: l10n.produitsColCode, valeur: (p) => p.code, attenue: true, mono: true, largeur: 110),
        DsColonnePicker(libelle: l10n.dsPosProduit, valeur: (p) => p.designation, fort: true),
        DsColonnePicker(libelle: l10n.produitsColCategorie, valeur: (p) => categories[p.categorieCode] ?? ''),
        DsColonnePicker(
          libelle: magasin == null ? l10n.produitsColStock : l10n.stkStockTotal,
          valeur: (p) => formaterNombre(stocks[p.code] ?? 0),
          largeur: magasin == null ? 90 : 110,
        ),
        if (magasin != null)
          DsColonnePicker(
            libelle: l10n.stkQteDansMagasin(nomMagasin),
            valeur: (p) => formaterNombre(dansMagasin(p)),
            largeur: 150,
          ),
        DsColonnePicker(libelle: libellePrix, valeur: (p) => formaterMontant(prix(p), devise), largeur: 130),
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
    this.titreLignes,
    this.magasinSelecteur,
    this.reserveLignesFixe,
    this.iconeLignes,
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
    this.saisieNombre = false,
    this.sansLignes = false,
    this.nombreDisponible,
    this.actionsLignes = const [],
  });
  final String titre;
  final IconData icone;
  final String? description;
  final double largeur;
  final List<Widget> entete;

  /// Titre de section (`DsSubHead`) au-dessus des lignes, quand l'en-tête est découpé en sections.
  final String? titreLignes;

  /// Magasin dont la quantité s'affiche dans le sélecteur de produits (à côté du stock total).
  final String? magasinSelecteur;

  /// Lignes à hauteur fixe suivant l'écran, moins cette réserve (dialog haut et stable) ; `null` : hauteur libre.
  final double? reserveLignesFixe;
  final IconData? iconeLignes;
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

  /// Document sans lignes produits (remise « Par montant ») : éditeur masqué, enregistrable sans ligne.
  final bool sansLignes;

  /// Document qui mouvemente le stock : colonne « Nombre » obligatoire quand le 2ᵉ stock est actif (§8.1).
  final bool saisieNombre;

  /// Pièces (2ᵉ stock) disponibles d'une ligne, pour un document qui sort du stock (sortie, transfert).
  final double Function(LigneDoc)? nombreDisponible;

  /// Boutons d'ajout groupé placés après « Ajouter des produits ».
  final List<Widget> actionsLignes;

  @override
  ConsumerState<DocFormDialog> createState() => _DocFormDialogState();
}

class _DocFormDialogState extends ConsumerState<DocFormDialog> {
  bool _occupe = false;

  bool get _nombreGlobal => ref.read(parametresVenteProvider).value?.nombreActif ?? false;

  Future<void> _ajouter() async {
    final choix = await choisirProduits(
      context,
      ref,
      titre: widget.titreSelecteur,
      exclus: {for (final l in widget.lignes) l.produit.code},
      prixVente: widget.prixVenteSelecteur,
      magasin: widget.magasinSelecteur,
    );
    if (choix.isEmpty) return;
    final nouvelles = [for (final p in choix) LigneDoc(produit: p)];
    if (widget.saisieNombre) proposerNombres(nouvelles, global: _nombreGlobal, disponible: widget.nombreDisponible);
    widget.onLignes([...widget.lignes, ...nouvelles]);
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
    final global = ref.watch(parametresVenteProvider).value?.nombreActif ?? false;
    final erreurs = widget.saisieNombre
        ? erreursNombre(context, widget.erreurs, widget.lignes, global: global, disponible: widget.nombreDisponible)
        : widget.erreurs;
    final colonnes = widget.saisieNombre
        ? avecColonneNombre(
            context,
            widget.colonnes,
            widget.lignes,
            global: global,
            onEdition: () => widget.onLignes([...widget.lignes]),
          )
        : widget.colonnes;
    final ok = widget.peutEnregistrer && (widget.sansLignes || widget.lignes.isNotEmpty) && erreurs.isEmpty;
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
          if (!widget.sansLignes && widget.titreLignes != null)
            DsSubHead(widget.titreLignes!, icone: widget.iconeLignes),
          if (!widget.sansLignes)
            DsLineItemsEditor<LigneDoc>(
              lignes: widget.lignes,
              colonnes: colonnes,
              totalLigne: widget.totalLigne,
              quantite: (l) => l.quantite,
              cle: (l) => l.produit.code,
              devise: devise,
              erreurs: erreurs,
              hauteurFixe: widget.reserveLignesFixe != null,
              hauteurMax: widget.reserveLignesFixe == null
                  ? null
                  : hauteurListeDialog(context, reserve: widget.reserveLignesFixe!, min: 220),
              libelleTotal: widget.libelleTotal,
              libelleAjouter: l10n.dsPosLigneAjouter,
              onAjouter: _ajouter,
              onSupprimer: (l) => widget.onLignes(widget.lignes.where((x) => x != l).toList()),
              actionsAjout: widget.actionsLignes,
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
