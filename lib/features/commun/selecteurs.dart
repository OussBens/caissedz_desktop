import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/vente.dart';
import '../../domain/referentiel/referentiel.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../historique/historique_providers.dart';
import '../produits/produits_donnees.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import 'carte_entite.dart';
import 'referentiel_ui.dart';
import 'statuts.dart';

/// Listes métier proposant un dialog de sélection (bouton à côté de la liste déroulante).
enum ListeMetier {
  produit,
  categorie,
  sousCategorie,
  remise,
  pack,
  client,
  fournisseur,
  magasin,
  caisse,
  session,
  utilisateur,
  vente,
}

/// Recherche d'un `DsSelect` métier (paramètre `recherche`) : ouvre le dialog de sélection restreint aux
/// options de la liste (codes ; `null` = « Tous » est ignoré) ; le code choisi est transmis à `onChanged`.
Future<String?> Function(List<String?> options, String? valeur) rechercheListe(
  BuildContext context,
  WidgetRef ref,
  ListeMetier liste,
) =>
    (options, valeur) =>
        choisirDansListe(context, ref, liste, codes: options.whereType<String>().toSet(), valeur: valeur);

/// Filtre « Produit » d'un panneau de filtres : liste déroulante des produits stockés (« Tous » en tête) avec
/// le bouton de recherche dans la liste.
Widget filtreProduit(
  BuildContext context,
  WidgetRef ref, {
  required String? valeur,
  required ValueChanged<String?> onChanged,
  Key? cle,
}) {
  final l10n = AppLocalizations.of(context);
  final produits = [
    for (final p in ref.watch(produitsProvider).value ?? const <Produit>[])
      if (!p.service) p,
  ];
  final noms = {for (final p in produits) p.code: p.designation};
  return DsFormRow(
    libelle: l10n.dsPosProduit,
    child: DsSelect<String?>(
      cle: cle,
      valeur: valeur,
      options: [null, ...noms.keys],
      libelle: (c) => c == null ? l10n.retoursTous : (noms[c] ?? c),
      recherche: rechercheListe(context, ref, ListeMetier.produit),
      onChanged: onChanged,
    ),
  );
}

/// Dialog de sélection d'une liste métier : recherche, filtres propres à la liste, affichage liste ou cartes
/// (produits, clients, fournisseurs, ventes). [codes] restreint les éléments proposés. Retourne le code choisi.
Future<String?> choisirDansListe(
  BuildContext context,
  WidgetRef ref,
  ListeMetier liste, {
  Set<String>? codes,
  String? valeur,
  String? titre,
  VoidCallback? onCreer,
  String? libelleCreer,
}) async {
  final config = await _charger(context, ref, liste);
  if (!context.mounted) return null;
  final elements = codes == null ? config.elements : config.elements.where((e) => codes.contains(e.code)).toList();
  final choix = await afficherDialog<_Element>(
    context,
    builder: (_) => _SelecteurListe(
      config: config,
      elements: elements,
      valeur: valeur,
      titre: titre,
      onCreer: onCreer,
      libelleCreer: libelleCreer,
    ),
  );
  return choix?.code;
}

/// Élément d'une liste métier, ramené à un format commun.
class _Element {
  const _Element({
    required this.code,
    required this.titre,
    this.colonnes = const [],
    this.attributs = const {},
    this.sousTitre,
    this.image,
    this.statut,
    this.montant,
    this.lignes = const [],
  });
  final String code;
  final String titre;
  final String? sousTitre;

  /// Valeurs des colonnes du tableau (même ordre que [_Config.colonnes]).
  final List<String> colonnes;

  /// Valeurs des filtres (clé du filtre → valeur affichée ou statut du DS).
  final Map<String, String> attributs;
  final ImageProvider? image;
  final String? statut;
  final String? montant;
  final List<(IconData, String)> lignes;
}

/// Filtre d'un dialog : clé de l'attribut, libellé, valeurs traduites par [libelleStatut] si [statut].
typedef _Filtre = ({String cle, String libelle, bool statut});

class _Config {
  const _Config({
    required this.titre,
    required this.icone,
    required this.colonnes,
    required this.elements,
    this.filtres = const [],
    this.cartes = false,
    this.initiales = true,
  });
  final String titre;
  final IconData icone;

  /// En-têtes (libellé, largeur fixe éventuelle).
  final List<(String, double?)> colonnes;
  final List<_Element> elements;
  final List<_Filtre> filtres;
  final bool cartes;
  final bool initiales;
}

String _etat(bool actif) => actif ? 'actif' : 'inactif';

Future<_Config> _charger(BuildContext context, WidgetRef ref, ListeMetier liste) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  String da(double v) => formaterMontant(v, devise);
  final etat = (cle: 'etat', libelle: l10n.selFiltreEtat, statut: true);
  final categorie = (cle: 'categorie', libelle: l10n.selColCategorie, statut: false);
  switch (liste) {
    case ListeMetier.produit:
      final produits = await ref.read(catalogueRepositoryProvider).produits();
      final cats = {for (final c in await ref.read(categoriesProvider.future)) c.code: c.nom};
      final stocks = await ref.read(stocksProduitsProvider.future);
      return _Config(
        titre: l10n.selProduit,
        icone: LucideIcons.package,
        cartes: true,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColDesignation, null),
          (l10n.selColCategorie, null),
          (l10n.selColStock, 90),
          (l10n.selColPrix, 120),
        ],
        filtres: [categorie, (cle: 'stock', libelle: l10n.selColStock, statut: true), etat],
        elements: [
          for (final p in produits)
            () {
              final stock = stocks[p.code] ?? 0;
              final etatStock = p.service ? 'disponible' : (stock <= 0 ? 'rupture' : 'disponible');
              return _Element(
                code: p.code,
                titre: p.designation,
                sousTitre: '${p.code} · ${cats[p.categorieCode] ?? ''}',
                colonnes: [
                  p.code,
                  p.designation,
                  cats[p.categorieCode] ?? '',
                  formaterNombre(stock),
                  da(ref.read(prixTtcProvider)(p)),
                ],
                attributs: {'categorie': cats[p.categorieCode] ?? '', 'stock': etatStock, 'etat': _etat(p.actif)},
                image: imageProduit(p.image),
                statut: p.actif ? (p.service ? null : etatStock) : 'inactif',
                montant: da(ref.read(prixTtcProvider)(p)),
                lignes: [(LucideIcons.boxes, p.service ? l10n.prdService : l10n.prdStockN(formaterNombre(stock)))],
              );
            }(),
        ],
      );
    case ListeMetier.categorie:
      final produits = await ref.read(catalogueRepositoryProvider).produits();
      int nb(String code) => produits.where((p) => p.categorieCode == code).length;
      return _Config(
        titre: l10n.selCategorie,
        icone: LucideIcons.folderTree,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColNom, null),
          (l10n.selColDescription, null),
          (l10n.selColProduits, 100),
        ],
        filtres: [etat],
        elements: [
          for (final c in await ref.read(categoriesProvider.future))
            _Element(
              code: c.code,
              titre: c.nom,
              colonnes: [c.code, c.nom, c.description ?? '', '${nb(c.code)}'],
              attributs: {'etat': _etat(c.actif)},
            ),
        ],
      );
    case ListeMetier.sousCategorie:
      final cats = {for (final c in await ref.read(categoriesProvider.future)) c.code: c.nom};
      return _Config(
        titre: l10n.selSousCategorie,
        icone: LucideIcons.folderTree,
        colonnes: [(l10n.selColCode, 110), (l10n.selColNom, null), (l10n.selColCategorie, null)],
        filtres: [categorie, etat],
        elements: [
          for (final s in await ref.read(sousCategoriesProvider.future))
            _Element(
              code: s.code,
              titre: s.nom,
              colonnes: [s.code, s.nom, cats[s.categorieCode] ?? ''],
              attributs: {'categorie': cats[s.categorieCode] ?? '', 'etat': _etat(s.actif)},
            ),
        ],
      );
    case ListeMetier.remise:
      if (!context.mounted) return _vide(l10n.selRemise);
      final type = (cle: 'type', libelle: l10n.selColType, statut: false);
      final remises = await ref.read(remisesProvider.future);
      if (!context.mounted) return _vide(l10n.selRemise);
      return _Config(
        titre: l10n.selRemise,
        icone: LucideIcons.percent,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColDesignation, null),
          (l10n.selColType, null),
          (l10n.selColValeur, 120),
        ],
        filtres: [type],
        elements: [
          // Seules les remises actives (période en cours, non annulées) sont proposées.
          for (final r in remises.where((r) => r.estActive(DateTime.now())))
            _Element(
              code: r.code,
              titre: r.designation,
              colonnes: [
                r.code,
                r.designation,
                libelleRef(context, Referentiel.typesRemise, r.portee),
                r.type == 'Pourcentage' ? '${formaterNombre(r.valeur)} %' : da(r.valeur),
              ],
              attributs: {'type': libelleRef(context, Referentiel.typesRemise, r.portee)},
            ),
        ],
      );
    case ListeMetier.pack:
      return _Config(
        titre: l10n.selPack,
        icone: LucideIcons.gift,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColDesignation, null),
          (l10n.selColProduits, 110),
          (l10n.selColPrix, 120),
        ],
        filtres: [etat],
        elements: [
          for (final k in await ref.read(packsProvider.future))
            _Element(
              code: k.code,
              titre: k.designation,
              colonnes: [k.code, k.designation, '${k.lignes.length}', da(k.prixVente)],
              attributs: {'etat': _etat(k.actif)},
            ),
        ],
      );
    case ListeMetier.client:
      final stats = await ref.read(statsClientsProvider.future);
      return _Config(
        titre: l10n.selClient,
        icone: LucideIcons.user,
        cartes: true,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColNom, null),
          (l10n.selColTelephone, 140),
          (l10n.selColAdresse, null),
        ],
        filtres: [etat, (cle: 'credit', libelle: l10n.statutCredit, statut: false)],
        elements: [
          for (final c in await ref.read(clientsProvider.future))
            () {
              final du = stats[c.code]?.credit ?? 0;
              final nom = c.estDePassage ? l10n.posClientPassage : c.nom;
              return _Element(
                code: c.code,
                titre: nom,
                sousTitre: '${c.code} · ${c.telephone}',
                colonnes: [c.code, nom, c.telephone, c.adresse],
                attributs: {'etat': _etat(c.actif), 'credit': du > 0.005 ? l10n.communOui : l10n.communNon},
                statut: c.actif ? (du > 0.005 ? 'credit' : 'actif') : 'inactif',
                montant: da(du),
                lignes: [(LucideIcons.mapPin, c.adresse), (LucideIcons.star, l10n.selPoints(c.points))],
              );
            }(),
        ],
      );
    case ListeMetier.fournisseur:
      return _Config(
        titre: l10n.selFournisseur,
        icone: LucideIcons.truck,
        cartes: true,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColNom, null),
          (l10n.selColTelephone, 140),
          (l10n.selColAdresse, null),
        ],
        filtres: [etat],
        elements: [
          for (final f in await ref.read(fournisseursProvider.future))
            _Element(
              code: f.code,
              titre: f.nom,
              sousTitre: '${f.code} · ${f.telephone}',
              colonnes: [f.code, f.nom, f.telephone, f.adresse],
              attributs: {'etat': _etat(f.actif)},
              statut: _etat(f.actif),
              lignes: [(LucideIcons.mapPin, f.adresse), (LucideIcons.mail, f.email)],
            ),
        ],
      );
    case ListeMetier.magasin:
      return _Config(
        titre: l10n.selMagasin,
        icone: LucideIcons.warehouse,
        colonnes: [(l10n.selColCode, 110), (l10n.selColNom, null), (l10n.selColAdresse, null)],
        filtres: [etat],
        elements: [
          for (final m in await ref.read(magasinsProvider.future))
            _Element(
              code: m.code,
              titre: m.nom,
              colonnes: [m.code, m.nom, m.adresse],
              attributs: {'etat': _etat(m.actif)},
            ),
        ],
      );
    case ListeMetier.caisse:
      final magasins = {for (final m in await ref.read(magasinsProvider.future)) m.code: m.nom};
      final caisses = await ref.read(caissesListeProvider.future);
      if (!context.mounted) return _vide(l10n.selCaisse);
      return _Config(
        titre: l10n.selCaisse,
        icone: LucideIcons.monitorSmartphone,
        colonnes: [(l10n.selColCode, 110), (l10n.selColNom, null), (l10n.selColType, null), (l10n.selColMagasin, null)],
        filtres: [(cle: 'type', libelle: l10n.selColType, statut: false), etat],
        elements: [
          for (final k in caisses)
            _Element(
              code: k.code,
              titre: k.nom,
              colonnes: [
                k.code,
                k.nom,
                libelleRef(context, Referentiel.typesCaisse, k.type),
                magasins[k.magasinCode] ?? '',
              ],
              attributs: {'type': libelleRef(context, Referentiel.typesCaisse, k.type), 'etat': _etat(k.actif)},
            ),
        ],
      );
    case ListeMetier.session:
      final caisses = {for (final k in await ref.read(caissesListeProvider.future)) k.code: k.nom};
      final noms = await ref.read(nomsUtilisateursProvider.future);
      return _Config(
        titre: l10n.selSession,
        icone: LucideIcons.clock,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColCaisse, null),
          (l10n.selColUtilisateur, null),
          (l10n.selColOuverture, 150),
          (l10n.selColStatut, 110),
        ],
        filtres: [
          (cle: 'caisse', libelle: l10n.selColCaisse, statut: false),
          (cle: 'statut', libelle: l10n.selColStatut, statut: true),
        ],
        elements: [
          for (final s in await ref.read(sessionsCaisseProvider.future))
            _Element(
              code: s.code,
              titre: s.code,
              colonnes: [
                s.code,
                caisses[s.caisseCode] ?? s.caisseCode,
                noms[s.utilisateurCode] ?? s.utilisateurCode,
                formatDateHeure.format(s.ouverteLe),
                libelleStatut(l10n, s.estOuverte ? 'ouverte' : 'fermee'),
              ],
              attributs: {
                'caisse': caisses[s.caisseCode] ?? s.caisseCode,
                'statut': s.estOuverte ? 'ouverte' : 'fermee',
              },
            ),
        ],
      );
    case ListeMetier.utilisateur:
      final noms = await ref.read(nomsUtilisateursProvider.future);
      return _Config(
        titre: l10n.selUtilisateur,
        icone: LucideIcons.userCog,
        colonnes: [(l10n.selColCode, 110), (l10n.selColNom, null)],
        elements: [
          for (final e in noms.entries) _Element(code: e.key, titre: e.value, colonnes: [e.key, e.value]),
        ],
      );
    case ListeMetier.vente:
      final clients = {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom};
      final ventes = await ref.read(ventesProvider.future);
      String client(String code) => code == 'CLN0000' ? l10n.posClientPassage : (clients[code] ?? code);
      String statut(Vente v) => v.statut == StatutsVente.annulee ? 'annule' : (v.reste > 0.005 ? 'credit' : 'paye');
      return _Config(
        titre: l10n.selVente,
        icone: LucideIcons.receipt,
        cartes: true,
        initiales: false,
        colonnes: [
          (l10n.selColCode, 110),
          (l10n.selColDate, 150),
          (l10n.selColClient, null),
          (l10n.selColTotal, 120),
          (l10n.selColStatut, 110),
        ],
        filtres: [
          (cle: 'client', libelle: l10n.selColClient, statut: false),
          (cle: 'statut', libelle: l10n.selColStatut, statut: true),
        ],
        elements: [
          for (final v in ventes)
            _Element(
              code: v.code,
              titre: v.code,
              sousTitre: formatDateHeure.format(v.date),
              colonnes: [
                v.code,
                formatDateHeure.format(v.date),
                client(v.clientCode),
                da(v.totalNet),
                libelleStatut(l10n, statut(v)),
              ],
              attributs: {'client': client(v.clientCode), 'statut': statut(v)},
              statut: statut(v),
              montant: da(v.totalNet),
              lignes: [
                (LucideIcons.user, client(v.clientCode)),
                (LucideIcons.list, l10n.selNbProduits(v.lignes.length)),
              ],
            ),
        ],
      );
  }
}

_Config _vide(String titre) => _Config(titre: titre, icone: LucideIcons.list, colonnes: const [], elements: const []);

class _SelecteurListe extends StatefulWidget {
  const _SelecteurListe({
    required this.config,
    required this.elements,
    this.valeur,
    this.titre,
    this.onCreer,
    this.libelleCreer,
  });
  final _Config config;
  final List<_Element> elements;
  final String? valeur;
  final String? titre;
  final VoidCallback? onCreer;
  final String? libelleCreer;

  @override
  State<_SelecteurListe> createState() => _SelecteurListeState();
}

class _SelecteurListeState extends State<_SelecteurListe> {
  final Map<String, String?> _filtres = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cfg = widget.config;
    // Seuls les filtres qui distinguent au moins deux valeurs sont proposés.
    final filtres = [
      for (final f in cfg.filtres)
        if (widget.elements.map((e) => e.attributs[f.cle]).whereType<String>().toSet().length > 1) f,
    ];
    final hauteur = hauteurListeDialog(context, reserve: 340, min: 220);
    return DsPickerDialog<_Element>(
      cle: (e) => e.code,
      titre: widget.titre ?? cfg.titre,
      icone: cfg.icone,
      elements: widget.elements,
      onCreer: widget.onCreer,
      libelleCreer: widget.libelleCreer,
      selectionInitiale: [...widget.elements.where((e) => e.code == widget.valeur)],
      libelle: (e) => e.titre,
      sousLibelle: (e) => e.code,
      hauteurMax: hauteur,
      hauteurFixe: true,
      largeur: 960,
      colonnes: [
        for (final (i, (libelle, largeur)) in cfg.colonnes.indexed)
          DsColonnePicker<_Element>(
            libelle: libelle,
            valeur: (e) => i < e.colonnes.length ? e.colonnes[i] : '',
            largeur: largeur,
            fort: i == 1,
            attenue: i == 0,
            mono: i == 0,
          ),
      ],
      filtre: (e) => _filtres.entries.every((f) => f.value == null || e.attributs[f.key] == f.value),
      filtres: filtres.isEmpty
          ? null
          : Wrap(
              spacing: DsSpacing.s4,
              runSpacing: DsSpacing.s2,
              children: [
                for (final f in filtres)
                  SizedBox(
                    width: 280,
                    child: DsFormRow(
                      libelle: f.libelle,
                      largeurLibelle: 80,
                      child: DsSelect<String?>(
                        key: ValueKey('selecteur_filtre_${f.cle}'),
                        taille: DsTailles.controleSm,
                        valeur: _filtres[f.cle],
                        options: [
                          null,
                          ...({for (final e in widget.elements) ?e.attributs[f.cle]}.toList()..sort()),
                        ],
                        libelle: (v) => v == null ? l10n.selTous : (f.statut ? libelleStatut(l10n, v) : v),
                        onChanged: (v) => setState(() => _filtres[f.cle] = v),
                      ),
                    ),
                  ),
              ],
            ),
      carte: !cfg.cartes
          ? null
          : (context, e, etat) => CarteEntite(
              etat: etat,
              titre: e.titre,
              sousTitre: e.sousTitre,
              icone: cfg.icone,
              initiales: cfg.initiales,
              image: e.image,
              statut: e.statut,
              montant: e.montant,
              lignes: e.lignes,
            ),
      hauteurCarte: 172,
    );
  }
}
