import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/document_commercial_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/calculs_prix.dart';
import '../../domain/fiscalite.dart';
import '../../domain/models/document_commercial.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../../domain/referentiel/referentiel.dart';
import '../caisse/caisse_dialogs.dart';
import '../caisse/pos_controller.dart';
import '../commun/chargement.dart';
import '../commun/colonnes_audit.dart';
import '../commun/doc_form.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/referentiel_ui.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import '../ventes/ventes_providers.dart';
import 'commercial_providers.dart';

const double _lw = 112;

/// Module « Devis & commandes » : devis (DEV), factures proforma (PRO), bons de commande clients (BCC) livrés en
/// une ou plusieurs fois, et bons de livraison (LIV).
class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key, this.ongletInitial = 0});
  final int ongletInitial;

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  late int _onglet = widget.ongletInitial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageModule(
      moduleId: 'documents',
      onglets: [l10n.docOngletDevis, l10n.docOngletProformas, l10n.docOngletCommandes, l10n.docOngletLivraisons],
      ongletCourant: _onglet,
      onOnglet: (i) => setState(() => _onglet = i),
      child: switch (_onglet) {
        0 => const _OngletDocuments(TypesDocumentClient.devis, key: ValueKey('docs_devis')),
        1 => const _OngletDocuments(TypesDocumentClient.proforma, key: ValueKey('docs_proformas')),
        2 => const _OngletDocuments(TypesDocumentClient.commande, key: ValueKey('docs_commandes')),
        _ => const _OngletLivraisons(),
      },
    );
  }
}

// ———————————————————————————— Devis / proformas / commandes ————————————————————————————

class _OngletDocuments extends ConsumerStatefulWidget {
  const _OngletDocuments(this.type, {super.key});
  final String type;

  @override
  ConsumerState<_OngletDocuments> createState() => _OngletDocumentsState();
}

class _OngletDocumentsState extends ConsumerState<_OngletDocuments> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _statut;
  String? _client;

  bool get _commande => widget.type == TypesDocumentClient.commande;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final (debut, fin) = bornesPeriode(_periode);
    final tous = ref.watch(documentsClientsProvider((widget.type, debut, fin))).value ?? const <DocumentClient>[];
    final noms = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    final lignes = tous
        .where((d) => (_statut == null || d.statut == _statut) && (_client == null || d.clientCode == _client))
        .toList();
    final statuts = _commande
        ? const [StatutsDocumentClient.enCours, StatutsDocumentClient.partielle, StatutsDocumentClient.livree]
        : const [
            StatutsDocumentClient.enCours,
            StatutsDocumentClient.accepte,
            StatutsDocumentClient.refuse,
            StatutsDocumentClient.transforme,
            StatutsDocumentClient.expire,
          ];
    final colonnes = <DsColonne<DocumentClient>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (d) => d.code, fort: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (d) => d.date,
        cellule: (_, d) => Text(formatDateHeure.format(d.date)),
      ),
      DsColonne(id: 'client', libelle: l10n.ventesClient, flex: 2, valeur: (d) => noms[d.clientCode] ?? d.clientCode),
      DsColonne(id: 'n', libelle: l10n.stkArticles, numerique: true, valeur: (d) => d.lignes.length),
      DsColonne(
        id: 'ht',
        libelle: l10n.tvaHt,
        numerique: true,
        valeur: (d) => d.totalHt,
        cellule: (_, d) => Text(formaterMontant(d.totalHt, devise)),
      ),
      DsColonne(
        id: 'ttc',
        libelle: l10n.tvaTtc,
        numerique: true,
        fort: true,
        valeur: (d) => d.total,
        cellule: (_, d) => Text(formaterMontant(d.total, devise)),
        total: (ds) => formaterMontant(ds.where((d) => d.actif).fold(0.0, (s, d) => s + d.total), devise),
      ),
      if (_commande)
        DsColonne(
          id: 'livre',
          libelle: l10n.docLivre,
          numerique: true,
          valeur: (d) => d.lignes.fold<double>(0.0, (s, l) => s + l.livre),
          cellule: (_, d) =>
              Text('${formaterNombre(d.lignes.fold(0.0, (s, l) => s + l.livre))} / ${formaterNombre(d.quantite)}'),
        )
      else
        DsColonne(
          id: 'validite',
          libelle: l10n.docValidite,
          attenue: true,
          valeur: (d) => d.validite ?? DateTime(0),
          cellule: (_, d) => Text(dateOuTiret(d.validite)),
        ),
      DsColonne(
        id: 'statut',
        libelle: l10n.stkStatut,
        valeur: (d) => d.statut,
        cellule: (_, d) => DsBadge(libelle: libelleStatutDocument(l10n, d.statut), ton: tonStatutDocument(d.statut)),
      ),
      DsColonne(id: 'origine', libelle: l10n.docOrigine, visibleParDefaut: false, valeur: (d) => d.origineCode ?? ''),
      DsColonne(
        id: 'tva',
        libelle: l10n.tvaMontant,
        numerique: true,
        visibleParDefaut: false,
        valeur: (d) => d.totalTva,
        cellule: (_, d) => Text(formaterMontant(d.totalTva, devise)),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (d) => d.observation ?? '',
      ),
      ...colonnesAudit(context, ref, (DocumentClient x) => x.audit),
    ];
    final actifs = lignes.where((d) => d.actif);
    return DsModuleTable<DocumentClient>(
      key: ValueKey('docs_table_${widget.type}'),
      entite: libelleTypeDocument(l10n, widget.type),
      lignes: lignes,
      chargement: enChargement(ref.watch(documentsClientsProvider((widget.type, debut, fin)))),
      colonnes: colonnes,
      cle: (d) => d.code,
      afficherTotaux: true,
      messageVide: l10n.docAucun,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      // Devis / proforma : attente, acceptés, à transformer, expirés ; commandes : en cours, partielles, livrées.
      raccourcis: [
        DsRaccourci.periode(l10n, 'week'),
        if (_commande) ...[
          DsRaccourci(
            id: 'en_cours',
            libelle: l10n.racEnCours,
            icone: LucideIcons.clock,
            filtre: (d) => d.statut == StatutsDocumentClient.enCours,
          ),
          DsRaccourci(
            id: 'partielles',
            libelle: l10n.racPartiellementLivrees,
            icone: LucideIcons.truck,
            filtre: (d) => d.statut == StatutsDocumentClient.partielle,
          ),
          DsRaccourci(
            id: 'livrees',
            libelle: l10n.racLivrees,
            icone: LucideIcons.packageCheck,
            filtre: (d) => d.statut == StatutsDocumentClient.livree,
          ),
        ] else ...[
          DsRaccourci(
            id: 'attente',
            libelle: l10n.racEnAttente,
            icone: LucideIcons.clock,
            filtre: (d) => d.statut == StatutsDocumentClient.enCours,
          ),
          DsRaccourci(
            id: 'acceptes',
            libelle: l10n.racAcceptes,
            icone: LucideIcons.circleCheck,
            filtre: (d) => d.statut == StatutsDocumentClient.accepte,
          ),
          DsRaccourci(
            id: 'a_transformer',
            libelle: l10n.racATransformer,
            icone: LucideIcons.arrowRightLeft,
            filtre: (d) => d.statut == StatutsDocumentClient.enCours || d.statut == StatutsDocumentClient.accepte,
          ),
          DsRaccourci(
            id: 'expires',
            libelle: l10n.racExpires,
            icone: LucideIcons.calendarX,
            filtre: (d) => d.statut == StatutsDocumentClient.expire,
          ),
        ],
        DsRaccourci(
          id: 'gros',
          libelle: l10n.racPlusGrosMontants,
          icone: LucideIcons.arrowDownWideNarrow,
          tri: const DsTri('ttc', ascendant: false),
        ),
      ],
      texteRecherche: (d) => '${d.code} ${noms[d.clientCode] ?? ''} ${d.origineCode ?? ''}',
      nbFiltresActifs: [_statut, _client].where((f) => f != null).length,
      onReinitialiser: () => setState(() {
        _statut = null;
        _client = null;
        _periode = DsPeriode.calculer('month');
      }),
      kpis: [
        DsStatCard(libelle: l10n.docKpiNombre, valeur: '${actifs.length}', icone: LucideIcons.fileText),
        DsStatCard(
          libelle: l10n.docKpiMontant,
          valeur: f2(actifs.fold(0.0, (s, d) => s + d.total)),
          suffixe: devise,
          icone: LucideIcons.banknote,
        ),
        if (_commande)
          DsStatCard(
            libelle: l10n.docKpiALivrer,
            valeur: '${actifs.where((d) => !d.toutLivre).length}',
            icone: LucideIcons.truck,
          )
        else
          DsStatCard(
            libelle: l10n.docKpiTransformes,
            valeur: '${actifs.where((d) => d.statutStocke == StatutsDocumentClient.transforme).length}',
            icone: LucideIcons.repeat,
          ),
      ],
      filtres: [
        DsFormRow(
          libelle: l10n.stkStatut,
          largeurLibelle: 64,
          child: DsSelect<String?>(
            cle: ValueKey('docs_filtre_statut_${widget.type}'),
            valeur: _statut,
            options: [null, ...statuts, StatutsDocumentClient.annule],
            libelle: (s) => s == null ? l10n.tiersTous : libelleStatutDocument(l10n, s),
            onChanged: (s) => setState(() => _statut = s),
          ),
        ),
        DsFormRow(
          libelle: l10n.ventesClient,
          largeurLibelle: 64,
          child: DsSelect<String?>(
            valeur: _client,
            options: [
              null,
              ...{for (final d in tous) d.clientCode},
            ],
            libelle: (c) => c == null ? l10n.tiersTous : (noms[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.client),
            onChanged: (c) => setState(() => _client = c),
          ),
        ),
      ],
      onOuvrir: (d) => afficherDetailDocumentClient(context, ref, d),
      onExport: peutExporter(ref)
          ? (format, ds) => exporterTableau(
              context,
              ref,
              id: 'documents_${widget.type}',
              titre: libelleTypeDocument(l10n, widget.type),
              colonnes: colonnes,
              lignes: ds,
              format: format,
            )
          : null,
      actions: [
        DsActionModule(
          libelle: l10n.tiersDetail,
          icone: LucideIcons.eye,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => afficherDetailDocumentClient(context, ref, choix.first),
        ),
        DsActionModule(
          cle: const ValueKey('doc_imprimer'),
          libelle: l10n.docImprimer,
          icone: LucideIcons.printer,
          regle: DsRegleSelection.une,
          onPressed: (choix, _) => imprimerDocumentClient(context, ref, choix.first),
        ),
        DsActionModule(
          libelle: l10n.communModifier,
          icone: LucideIcons.pencil,
          iconeSeule: true,
          regle: DsRegleSelection.une,
          desactive: (choix) => choix.isNotEmpty && !choix.first.modifiable,
          onPressed: (choix, _) => afficherFormulaireDocumentClient(context, ref, widget.type, document: choix.first),
        ),
        if (!_commande) ...[
          DsActionModule(
            cle: const ValueKey('doc_accepter'),
            libelle: l10n.docAccepter,
            icone: LucideIcons.check,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && choix.first.statut != StatutsDocumentClient.enCours,
            onPressed: (choix, _) => _changerStatut(choix.first, StatutsDocumentClient.accepte),
          ),
          DsActionModule(
            libelle: l10n.docRefuser,
            icone: LucideIcons.x,
            regle: DsRegleSelection.une,
            desactive: (choix) =>
                choix.isNotEmpty &&
                (!choix.first.actif || choix.first.statutStocke == StatutsDocumentClient.transforme),
            onPressed: (choix, _) => _changerStatut(choix.first, StatutsDocumentClient.refuse),
          ),
          DsActionModule(
            cle: const ValueKey('doc_transformer'),
            libelle: l10n.docTransformer,
            icone: LucideIcons.repeat,
            regle: DsRegleSelection.une,
            desactive: (choix) =>
                choix.isNotEmpty &&
                (!choix.first.actif ||
                    choix.first.statutStocke == StatutsDocumentClient.transforme ||
                    choix.first.statutStocke == StatutsDocumentClient.refuse),
            onPressed: (choix, effacer) async {
              await transformerEnCommande(context, ref, choix.first);
              effacer();
            },
          ),
        ] else
          DsActionModule(
            cle: const ValueKey('doc_livrer'),
            libelle: l10n.docLivrer,
            icone: LucideIcons.truck,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && (!choix.first.actif || choix.first.toutLivre),
            onPressed: (choix, effacer) async {
              await afficherLivraison(context, ref, choix.first);
              effacer();
            },
          ),
        DsActionModule(
          cle: const ValueKey('doc_annuler'),
          libelle: l10n.dsAnnuler,
          icone: LucideIcons.x,
          iconeSeule: true,
          danger: true,
          onPressed: (choix, effacer) => _annuler(choix, effacer, noms),
        ),
      ],
      primaire: DsButton(
        key: ValueKey('doc_nouveau_${widget.type}'),
        libelle: switch (widget.type) {
          TypesDocumentClient.devis => l10n.docNouveauDevis,
          TypesDocumentClient.proforma => l10n.docNouvelleProforma,
          _ => l10n.docNouvelleCommande,
        },
        icone: LucideIcons.plus,
        onPressed: () => afficherFormulaireDocumentClient(context, ref, widget.type),
      ),
    );
  }

  Future<void> _changerStatut(DocumentClient d, String statut) async {
    final l10n = AppLocalizations.of(context);
    final ok = await executerDocument(
      context,
      ref,
      () => ref.read(documentClientServiceProvider).changerStatut(d.code, statut),
    );
    if (ok && mounted) afficherToast(context, titre: '${d.code} · ${libelleStatutDocument(l10n, statut)}');
  }

  Future<void> _annuler(List<DocumentClient> choix, VoidCallback effacer, Map<String, String> noms) async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    String? blocage(DocumentClient d) => !d.actif
        ? l10n.stkBloqueDejaAnnulee
        : d.livraisons.isNotEmpty
        ? l10n.docErreurLivraisonLiee
        : null;
    final motif = await afficherActionLot(
      context,
      action: DsActionLot.annuler,
      entite: libelleTypeDocument(l10n, widget.type),
      motifRequis: true,
      elements: [
        for (final d in choix)
          DsElementLot(
            id: d.code,
            titre: '${d.code} · ${noms[d.clientCode] ?? d.clientCode}',
            meta: formaterMontant(d.total, devise),
            motifBlocage: blocage(d),
          ),
      ],
    );
    if (motif == null || !mounted) return;
    final service = ref.read(documentClientServiceProvider);
    await executerDocument(context, ref, () async {
      for (final d in choix) {
        if (blocage(d) == null) await service.annuler(d.code, motif: motif);
      }
    });
    effacer();
  }
}

/// Transforme un devis / une proforma en bon de commande, puis propose la livraison.
Future<void> transformerEnCommande(BuildContext context, WidgetRef ref, DocumentClient d) async {
  final l10n = AppLocalizations.of(context);
  DocumentClient? commande;
  final ok = await executerDocument(
    context,
    ref,
    () async => commande = await ref.read(documentClientServiceProvider).transformerEnCommande(d.code),
  );
  if (!ok || !context.mounted) return;
  afficherToast(
    context,
    titre: l10n.docToastTransforme,
    description: '${d.code} → ${commande!.code}',
    ton: DsToastTon.succes,
  );
}

// ———————————————————————————— Formulaire ————————————————————————————

/// Formulaire de devis / proforma / commande (DocForm) : client, date de validité, lignes au prix de vente TTC.
Future<void> afficherFormulaireDocumentClient(
  BuildContext context,
  WidgetRef ref,
  String type, {
  DocumentClient? document,
}) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  await ref.read(clientsProvider.future);
  if (!context.mounted) return;
  final lignes = [
    if (document != null)
      for (final l in document.lignes)
        if (produits[l.produitCode] != null)
          LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite, prix: l.prixUnitaire),
  ];
  await afficherDialog<bool>(context, fermableParVoile: false, builder: (_) => _DocumentForm(type, document, lignes));
}

class _DocumentForm extends ConsumerStatefulWidget {
  const _DocumentForm(this.type, this.document, this.lignesInitiales);
  final String type;
  final DocumentClient? document;
  final List<LigneDoc> lignesInitiales;

  @override
  ConsumerState<_DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends ConsumerState<_DocumentForm> {
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  late String? _client = widget.document?.clientCode;
  late DateTime? _validite =
      widget.document?.validite ??
      (widget.type == TypesDocumentClient.commande ? null : DateTime.now().add(const Duration(days: 15)));
  late final _observation = TextEditingController(text: widget.document?.observation ?? '');

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final s = ref.read(documentClientServiceProvider);
    final lignes = [
      for (final l in _lignes) DemandeLigneDocument(produitCode: l.produit.code, quantite: l.quantite, prix: l.prix),
    ];
    var code = widget.document?.code ?? '';
    final ok = await executerDocument(context, ref, () async {
      if (widget.document == null) {
        code = (await s.creer(
          type: widget.type,
          clientCode: _client!,
          lignes: lignes,
          validite: _validite,
          observation: _observation.text,
        )).code;
      } else {
        await s.modifier(
          code,
          clientCode: _client!,
          lignes: lignes,
          validite: _validite,
          observation: _observation.text,
        );
      }
    });
    if (ok && mounted) {
      afficherToast(context, titre: l10n.docToastEnregistre, description: code, ton: DsToastTon.succes);
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final clients = (ref.watch(clientsProvider).value ?? const <Client>[])
        .where((c) => c.actif || c.code == _client)
        .toList();
    final d = widget.document;
    final type = libelleTypeDocument(l10n, widget.type);
    final taux = ref.watch(tauxAppliqueProvider);
    final affichage = ref.watch(affichagePrixDocumentsProvider);
    return DocFormDialog(
      titre: d == null ? l10n.docNouveauTitre(type) : l10n.docModifierTitre(type),
      icone: widget.type == TypesDocumentClient.commande ? LucideIcons.clipboardList : LucideIcons.fileText,
      cleEnregistrer: const ValueKey('doc_enregistrer'),
      prixVenteSelecteur: true,
      lignes: _lignes,
      // Produit ajouté : proposé au prix de vente TTC (le sélecteur part du prix d'achat).
      onLignes: (ls) => setState(() {
        for (final l in ls) {
          if (!_lignes.contains(l)) l.prix = ref.read(prixDocumentsProvider)(l.produit);
        }
        _lignes = ls;
      }),
      peutEnregistrer: _client != null && _lignes.every((l) => l.quantite > 0),
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * l.prix,
      libelleTotal: affichage.avecTva ? l10n.docTotalTtc : l10n.docTotalHt,
      colonnes: [
        DsColonneLigne(
          id: 'code',
          libelle: l10n.produitsColCode,
          valeur: (l) => l.produit.code,
          attenue: true,
          largeur: 110,
        ),
        DsColonneLigne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.produit.designation, fort: true),
        if (affichage.avecTva)
          DsColonneLigne(
            id: 'tva',
            libelle: l10n.tvaTaux,
            numerique: true,
            largeur: 70,
            valeur: (l) => '${formaterNombre(taux(l.produit, documents: true))} %',
          ),
        DsColonneLigne(
          id: 'qte',
          libelle: l10n.stockColQuantite,
          numerique: true,
          editable: true,
          largeur: 110,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        // Avec TVA : P.U. HT, puis TVA et / ou P.U. TTC selon Paramètres › Affichage des prix ; le prix saisi est le
        // TTC (le HT quand le TTC n'est pas affiché).
        if (affichage.avecTva)
          DsColonneLigne(
            id: 'ht',
            libelle: l10n.docPuHt,
            numerique: true,
            editable: !affichage.ttc,
            largeur: 130,
            suffixe: devise,
            valeur: (l) => montantLigne(Fiscalite.ventiler(l.prix, taux(l.produit, documents: true)).ht),
            onEdition: (l, v) =>
                setState(() => l.prix = Fiscalite.ttc(nombreSaisi(v), taux(l.produit, documents: true))),
          ),
        if (affichage.avecTva && affichage.tva)
          DsColonneLigne(
            id: 'tva_montant',
            libelle: l10n.docTvaUnitaire,
            numerique: true,
            largeur: 110,
            suffixe: devise,
            valeur: (l) => montantLigne(Fiscalite.ventiler(l.prix, taux(l.produit, documents: true)).tva),
          ),
        if (!affichage.avecTva || affichage.ttc)
          DsColonneLigne(
            id: 'prix',
            libelle: affichage.avecTva ? l10n.docPuTtc : l10n.docPuHt,
            numerique: true,
            editable: true,
            largeur: 140,
            suffixe: devise,
            valeur: (l) => texteQuantite(l.prix),
            onEdition: (l, v) => setState(() => l.prix = nombreSaisi(v)),
          ),
      ],
      entete: [
        if (d != null)
          DsFormRow(
            libelle: l10n.produitsColCode,
            largeurLibelle: _lw,
            child: DsTextField(valeurInitiale: d.code, actif: false),
          ),
        DsFormRow(
          libelle: l10n.ventesClient,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String?>(
            cle: const ValueKey('doc_client'),
            valeur: _client,
            placeholder: l10n.docChoisirClient,
            options: [for (final c in clients) c.code],
            libelle: (c) => clients.where((x) => x.code == c).firstOrNull?.nom ?? (c ?? ''),
            recherche: rechercheListe(context, ref, ListeMetier.client),
            onChanged: (v) => setState(() => _client = v),
          ),
        ),
        if (widget.type != TypesDocumentClient.commande)
          DsFormRow(
            libelle: l10n.docValidite,
            largeurLibelle: _lw,
            child: DsDateField(valeur: _validite, onChanged: (v) => setState(() => _validite = v)),
          )
        else
          const SizedBox(),
        DsFormRow(
          libelle: l10n.retoursObservation,
          largeurLibelle: _lw,
          child: DsTextField(controller: _observation),
        ),
      ],
    );
  }
}

// ———————————————————————————— Détail ————————————————————————————

Future<void> afficherDetailDocumentClient(BuildContext context, WidgetRef ref, DocumentClient d) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final noms = {for (final c in await ref.read(clientsProvider.future)) c.code: c.nom};
  final livraisons = d.estCommande
      ? await ref.read(documentsRepositoryProvider).livraisons(commandeCode: d.code)
      : const <BonLivraison>[];
  if (!context.mounted) return;
  final type = libelleTypeDocument(l10n, d.type);
  // Document avec TVA : P.U. HT, puis TVA et / ou P.U. TTC selon Paramètres › Affichage des prix.
  final affichage = ref.read(affichagePrixDocumentsProvider);
  final avecTva = d.lignes.any((l) => l.tauxTva > 0);
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 980,
      icone: d.estCommande ? LucideIcons.clipboardList : LucideIcons.fileText,
      titre: '$type ${d.code}',
      description: '${formatDateHeure.format(d.date)} · ${noms[d.clientCode] ?? d.clientCode}',
      badges: [DsBadge(libelle: libelleStatutDocument(l10n, d.statut), ton: tonStatutDocument(d.statut))],
      onModifier: () => afficherFormulaireDocumentClient(context, ref, d.type, document: d),
      modifierDesactive: !d.modifiable,
      piedSupplementaire: [
        DsButton(
          libelle: l10n.docImprimer,
          icone: LucideIcons.printer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => imprimerDocumentClient(context, ref, d),
        ),
        if (d.estCommande && d.actif && !d.toutLivre)
          DsButton(
            key: const ValueKey('doc_detail_livrer'),
            libelle: l10n.docLivrer,
            icone: LucideIcons.truck,
            onPressed: () async {
              Navigator.of(context).pop();
              await afficherLivraison(context, ref, d);
            },
          ),
      ],
      stats: [
        DsStatItem(libelle: l10n.tvaHt, valeur: f2(d.totalHt), suffixe: devise, icone: LucideIcons.receipt),
        DsStatItem(libelle: l10n.tvaMontant, valeur: f2(d.totalTva), suffixe: devise, icone: LucideIcons.percent),
        DsStatItem(libelle: l10n.docTotalTtc, valeur: f2(d.total), suffixe: devise, icone: LucideIcons.wallet),
        if (d.validite != null)
          DsStatItem(libelle: l10n.docValidite, valeur: formatDate.format(d.validite!), icone: LucideIcons.calendar),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.produitsOngletProduits,
          icone: LucideIcons.package,
          nbLignes: d.lignes.length,
          tableau: DsDataTable<DocumentLigne>(
            dense: true,
            encadre: false,
            pagine: false,
            reserveEcran: 360,
            cle: (l) => '${l.ordre}',
            lignes: d.lignes,
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
              DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.designation, fort: true, flex: 3),
              DsColonne(
                id: 'qte',
                libelle: l10n.stockColQuantite,
                numerique: true,
                valeur: (l) => l.quantite,
                cellule: (_, l) => Text(formaterNombre(l.quantite)),
              ),
              if (d.estCommande) ...[
                DsColonne(
                  id: 'livre',
                  libelle: l10n.docLivre,
                  numerique: true,
                  valeur: (l) => l.livre,
                  cellule: (_, l) => Text(formaterNombre(l.livre)),
                ),
                DsColonne(
                  id: 'reste',
                  libelle: l10n.docResteALivrer,
                  numerique: true,
                  valeur: (l) => l.reste,
                  cellule: (_, l) => Text(formaterNombre(l.reste)),
                ),
              ],
              if (avecTva)
                DsColonne(
                  id: 'pu_ht',
                  libelle: l10n.docPuHt,
                  numerique: true,
                  valeur: (l) => l.quantite == 0 ? 0 : l.montantHt / l.quantite,
                  cellule: (_, l) => Text(f2(l.quantite == 0 ? 0 : l.montantHt / l.quantite)),
                ),
              if (avecTva && affichage.tva)
                DsColonne(
                  id: 'tva_unitaire',
                  libelle: l10n.docTvaUnitaire,
                  numerique: true,
                  valeur: (l) => l.quantite == 0 ? 0 : l.montantTva / l.quantite,
                  cellule: (_, l) => Text(f2(l.quantite == 0 ? 0 : l.montantTva / l.quantite)),
                ),
              if (!avecTva || affichage.ttc)
                DsColonne(
                  id: 'pu',
                  libelle: avecTva ? l10n.docPuTtc : l10n.docPuHt,
                  numerique: true,
                  valeur: (l) => l.prixUnitaire,
                  cellule: (_, l) => Text(formaterMontant(l.prixUnitaire, devise)),
                ),
              DsColonne(
                id: 'taux',
                libelle: l10n.tvaTaux,
                numerique: true,
                valeur: (l) => l.tauxTva,
                cellule: (_, l) => Text('${formaterNombre(l.tauxTva)} %'),
              ),
              DsColonne(
                id: 'ht',
                libelle: l10n.tvaHt,
                numerique: true,
                valeur: (l) => l.montantHt,
                cellule: (_, l) => Text(f2(l.montantHt)),
              ),
              DsColonne(
                id: 'total',
                libelle: l10n.tvaTtc,
                numerique: true,
                valeur: (l) => l.total,
                cellule: (_, l) => Text(formaterMontant(l.total, devise)),
              ),
            ],
          ),
        ),
        if (livraisons.isNotEmpty)
          DsSectionDetail(
            titre: l10n.docOngletLivraisons,
            icone: LucideIcons.truck,
            items: [
              for (final b in livraisons)
                DsKeyValue(
                  '${b.code} · ${formatDateHeure.format(b.date)}',
                  '${formaterNombre(b.quantite)} · ${b.venteCode}${b.actif ? '' : ' · ${l10n.docStatutAnnule}'}',
                ),
            ],
          ),
        sectionAudit(
          context,
          d.audit,
          complements: [
            if (d.origineCode != null) DsKeyValue(l10n.docOrigine, d.origineCode),
            if (d.observation != null) DsKeyValue(l10n.retoursObservation, d.observation),
            if (d.annulation != null) DsKeyValue(l10n.auditMotif, d.annulation!.motif),
          ],
        ),
      ],
    ),
  );
}

// ———————————————————————————— Livraison ————————————————————————————

/// Livraison d'une commande (session de caisse ouverte) : quantités à livrer (reste par défaut), magasin, paiement
/// éventuel (le reste en crédit du client).
Future<void> afficherLivraison(BuildContext context, WidgetRef ref, DocumentClient commande) async {
  if (!await exigerSessionCaisse(context, ref)) return;
  final principal = await ref.read(magasinPrincipalProvider.future);
  await ref.read(magasinsProvider.future);
  if (!context.mounted) return;
  await afficherDialog<bool>(context, fermableParVoile: false, builder: (_) => _LivraisonDialog(commande, principal));
}

class _LivraisonDialog extends ConsumerStatefulWidget {
  const _LivraisonDialog(this.commande, this.principal);
  final DocumentClient commande;
  final String principal;

  @override
  ConsumerState<_LivraisonDialog> createState() => _LivraisonDialogState();
}

class _LivraisonDialogState extends ConsumerState<_LivraisonDialog> {
  late final Map<int, TextEditingController> _quantites = {
    for (final l in widget.commande.lignes)
      if (l.reste > 0) l.ordre: TextEditingController(text: texteQuantite(l.reste)),
  };
  late String _magasin = widget.principal;
  final _paye = TextEditingController();

  /// « Payé en totalité » coché : le montant payé suit le total livré (champ verrouillé, à vérifier).
  bool _totalite = false;
  String _mode = 'Espèces';
  final _observation = TextEditingController();
  bool _occupe = false;

  @override
  void dispose() {
    for (final c in _quantites.values) {
      c.dispose();
    }
    _paye.dispose();
    _observation.dispose();
    super.dispose();
  }

  double _q(int ordre) => nombreSaisi(_quantites[ordre]?.text ?? '');

  double get _total => CalculsPrix.arrondir(
    widget.commande.lignes.fold(0.0, (s, l) => s + CalculsPrix.arrondir(_q(l.ordre) * l.prixUnitaire)),
  );

  Future<void> _valider() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    final session = await ref.read(sessionCaisseServiceProvider).courante();
    if (session == null || !mounted) {
      setState(() => _occupe = false);
      return;
    }
    final paye = _totalite ? _total : nombreSaisi(_paye.text);
    BonLivraison? bl;
    final ok = await executerDocument(context, ref, () async {
      bl = await ref
          .read(documentClientServiceProvider)
          .livrer(
            widget.commande.code,
            quantites: {for (final o in _quantites.keys) o: _q(o)},
            session: session,
            magasinCode: _magasin,
            paiements: [if (paye > 0) Paiement(mode: _mode, montant: paye)],
            observation: _observation.text,
          );
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _occupe = false);
      return;
    }
    Navigator.of(context).pop(true);
    afficherToast(
      context,
      titre: l10n.docToastLivre,
      description: '${bl!.code} · ${bl!.venteCode}',
      ton: DsToastTon.succes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final t = context.ds.typo;
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[]).where((m) => m.actif).toList();
    final total = _total;
    final valide = !_occupe && total > 0 && widget.commande.lignes.every((l) => _q(l.ordre) <= l.reste + 1e-9);
    return DsDialog(
      titre: l10n.docLivrerTitre(widget.commande.code),
      iconeData: LucideIcons.truck,
      largeur: 860,
      fermable: !_occupe,
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(flex: 4, child: Text(l10n.dsPosProduit, style: t.label)),
              Expanded(
                child: Text(l10n.stockColQuantite, style: t.label, textAlign: TextAlign.end),
              ),
              Expanded(
                child: Text(l10n.docLivre, style: t.label, textAlign: TextAlign.end),
              ),
              Expanded(
                child: Text(l10n.docResteALivrer, style: t.label, textAlign: TextAlign.end),
              ),
              const SizedBox(width: DsSpacing.s4),
              SizedBox(width: 120, child: Text(l10n.docALivrer, style: t.label)),
            ],
          ),
          const SizedBox(height: DsSpacing.s2),
          for (final l in widget.commande.lignes)
            Padding(
              padding: const EdgeInsets.only(bottom: DsSpacing.s2),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(l.designation, style: t.bodySm)),
                  Expanded(child: Text(formaterNombre(l.quantite), textAlign: TextAlign.end)),
                  Expanded(child: Text(formaterNombre(l.livre), textAlign: TextAlign.end)),
                  Expanded(child: Text(formaterNombre(l.reste), textAlign: TextAlign.end)),
                  const SizedBox(width: DsSpacing.s4),
                  SizedBox(
                    width: 120,
                    child: _quantites[l.ordre] == null
                        ? const SizedBox()
                        : DsTextField(
                            key: ValueKey('livraison_qte_${l.ordre}'),
                            controller: _quantites[l.ordre],
                            numerique: true,
                            onChanged: (_) => setState(() {}),
                          ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: DsSpacing.s4),
          DsGrilleFormulaire(
            colonnes: 2,
            children: [
              if (ref.watch(plusieursMagasinsProvider))
                DsFormRow(
                  libelle: l10n.stkMagasin,
                  largeurLibelle: _lw,
                  child: DsSelect<String>(
                    valeur: _magasin,
                    options: [for (final m in magasins) m.code],
                    libelle: (c) => magasins.where((m) => m.code == c).firstOrNull?.nom ?? c,
                    onChanged: (v) => setState(() => _magasin = v ?? _magasin),
                  ),
                ),
              DsFormRow(
                libelle: l10n.communTotal,
                largeurLibelle: _lw,
                child: DsTextField(
                  key: ValueKey('livraison_total_${f2(total)}'),
                  valeurInitiale: formaterMontant(total, devise),
                  actif: false,
                ),
              ),
              DsFormRow(
                libelle: l10n.docMontantPaye,
                largeurLibelle: _lw,
                aide: l10n.docMontantPayeAide,
                child: Row(
                  spacing: DsSpacing.s2,
                  children: [
                    Expanded(
                      child: DsTextField(
                        key: ValueKey(_totalite ? 'livraison_paye_${f2(total)}' : 'livraison_paye'),
                        controller: _totalite ? null : _paye,
                        valeurInitiale: _totalite ? f2(total) : null,
                        numerique: true,
                        actif: !_totalite,
                        suffixeTexte: devise,
                      ),
                    ),
                    // Coché : le champ reprend le total livré et le suit quand les quantités changent ; décoché, il
                    // redevient saisissable, prérempli du total.
                    Flexible(
                      child: DsCheckbox(
                        cle: const ValueKey('livraison_paye_totalite'),
                        valeur: _totalite,
                        libelle: l10n.entPayeTotalite,
                        onChanged: (v) => setState(() {
                          _totalite = v;
                          if (!v && _paye.text.trim().isEmpty && total > 0) _paye.text = f2(total);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              DsFormRow(
                libelle: l10n.ventesPaiement,
                largeurLibelle: _lw,
                child: DsSelect<String>(
                  valeur: _mode,
                  options: [
                    for (final v in Referentiel.modesPaiement.valeurs)
                      if (v.stocke != 'Points') v.stocke,
                  ],
                  libelle: (v) => libelleRef(context, Referentiel.modesPaiement, v),
                  onChanged: (v) => setState(() => _mode = v ?? _mode),
                ),
              ),
              DsSpan(
                child: DsFormRow(
                  libelle: l10n.retoursObservation,
                  largeurLibelle: _lw,
                  child: DsTextField(controller: _observation),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DsButton(
          libelle: l10n.dsAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: _occupe ? null : () => Navigator.of(context).pop(false),
        ),
        DsButton(
          key: const ValueKey('livraison_valider'),
          libelle: l10n.docValiderLivraison,
          icone: LucideIcons.truck,
          onPressed: valide ? _valider : null,
        ),
      ],
    );
  }
}

// ———————————————————————————— Bons de livraison ————————————————————————————

class _OngletLivraisons extends ConsumerStatefulWidget {
  const _OngletLivraisons();

  @override
  ConsumerState<_OngletLivraisons> createState() => _OngletLivraisonsState();
}

class _OngletLivraisonsState extends ConsumerState<_OngletLivraisons> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final tous = ref.watch(livraisonsProvider(bornesPeriode(_periode))).value ?? const <BonLivraison>[];
    final noms = {for (final c in ref.watch(clientsProvider).value ?? const <Client>[]) c.code: c.nom};
    final lignes = tous.where((b) => _client == null || b.clientCode == _client).toList();
    final colonnes = <DsColonne<BonLivraison>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (b) => b.code, fort: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (b) => b.date,
        cellule: (_, b) => Text(formatDateHeure.format(b.date)),
      ),
      DsColonne(id: 'client', libelle: l10n.ventesClient, flex: 2, valeur: (b) => noms[b.clientCode] ?? b.clientCode),
      DsColonne(id: 'commande', libelle: l10n.docTypeCommande, attenue: true, valeur: (b) => b.commandeCode ?? '—'),
      DsColonne(id: 'vente', libelle: l10n.factureVente, attenue: true, valeur: (b) => b.venteCode),
      DsColonne(
        id: 'q',
        libelle: l10n.docQuantiteLivree,
        numerique: true,
        valeur: (b) => b.quantite,
        cellule: (_, b) => Text(formaterNombre(b.quantite)),
      ),
      DsColonne(
        id: 'total',
        libelle: l10n.tvaTtc,
        numerique: true,
        valeur: (b) => b.total,
        cellule: (_, b) => Text(formaterMontant(b.total, devise)),
        total: (bs) => formaterMontant(bs.where((b) => b.actif).fold(0.0, (s, b) => s + b.total), devise),
      ),
      DsColonne(
        id: 'statut',
        libelle: l10n.stkStatut,
        valeur: (b) => b.actif ? 1 : 0,
        cellule: (_, b) => DsBadge(
          libelle: b.actif ? l10n.docStatutLivree : l10n.docStatutAnnule,
          ton: b.actif ? DsBadgeTon.succes : DsBadgeTon.danger,
        ),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (b) => b.observation ?? '',
      ),
      ...colonnesAudit(context, ref, (BonLivraison x) => x.audit),
    ];
    return DsModuleTable<BonLivraison>(
      key: const ValueKey('docs_livraisons'),
      entite: l10n.docOngletLivraisons,
      lignes: lignes,
      chargement: enChargement(ref.watch(livraisonsProvider(bornesPeriode(_periode)))),
      colonnes: colonnes,
      cle: (b) => b.code,
      afficherTotaux: true,
      messageVide: l10n.docAucun,
      periode: _periode,
      onPeriode: (p) => setState(() => _periode = p),
      periodeSeule: false,
      raccourcis: [
        DsRaccourci.periode(l10n, 'today'),
        DsRaccourci.periode(l10n, 'week'),
        DsRaccourci(
          id: 'commande',
          libelle: l10n.racLiesCommande,
          icone: LucideIcons.clipboardList,
          filtre: (b) => b.commandeCode != null,
        ),
        DsRaccourci(
          id: 'gros',
          libelle: l10n.racPlusGrosMontants,
          icone: LucideIcons.arrowDownWideNarrow,
          tri: const DsTri('total', ascendant: false),
        ),
      ],
      texteRecherche: (b) => '${b.code} ${b.venteCode} ${b.commandeCode ?? ''} ${noms[b.clientCode] ?? ''}',
      nbFiltresActifs: _client == null ? 0 : 1,
      onReinitialiser: () => setState(() {
        _client = null;
        _periode = DsPeriode.calculer('month');
      }),
      filtres: [
        DsFormRow(
          libelle: l10n.ventesClient,
          largeurLibelle: 64,
          child: DsSelect<String?>(
            valeur: _client,
            options: [
              null,
              ...{for (final b in tous) b.clientCode},
            ],
            libelle: (c) => c == null ? l10n.tiersTous : (noms[c] ?? c),
            recherche: rechercheListe(context, ref, ListeMetier.client),
            onChanged: (c) => setState(() => _client = c),
          ),
        ),
      ],
      onOuvrir: (b) => imprimerBonLivraison(context, ref, b),
      onExport: peutExporter(ref)
          ? (format, bs) => exporterTableau(
              context,
              ref,
              id: 'livraisons',
              titre: l10n.docOngletLivraisons,
              colonnes: colonnes,
              lignes: bs,
              format: format,
            )
          : null,
      actions: [
        DsActionModule(
          cle: const ValueKey('livraison_imprimer'),
          libelle: l10n.docImprimer,
          icone: LucideIcons.printer,
          regle: DsRegleSelection.une,
          detail: true,
          onPressed: (choix, _) => imprimerBonLivraison(context, ref, choix.first),
        ),
      ],
    );
  }
}
