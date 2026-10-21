import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/document_commercial_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/document_commercial.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';
import '../../domain/models/tiers.dart';
import '../commun/colonnes_audit.dart';
import '../commun/doc_form.dart';
import '../commun/export_module.dart';
import '../commun/page_module.dart';
import '../commun/selecteurs.dart';
import '../commun/statuts.dart';
import '../entrees/entree_dialogs.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';
import '../ventes/ventes_providers.dart';
import 'commercial_providers.dart';

const double _lw = 112;

/// Module « Commandes fournisseurs » : bons de commande (BCF) réceptionnés en une ou plusieurs entrées ; le reliquat
/// peut être soldé.
class CommandesFournisseursPage extends ConsumerStatefulWidget {
  const CommandesFournisseursPage({super.key});

  @override
  ConsumerState<CommandesFournisseursPage> createState() => _CommandesFournisseursPageState();
}

class _CommandesFournisseursPageState extends ConsumerState<CommandesFournisseursPage> {
  DsPeriode _periode = DsPeriode.calculer('month');
  String? _statut;
  String? _fournisseur;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final tous =
        ref.watch(commandesFournisseursProvider(bornesPeriode(_periode))).value ?? const <CommandeFournisseur>[];
    final noms = {for (final f in ref.watch(fournisseursProvider).value ?? const <Fournisseur>[]) f.code: f.nom};
    final lignes = tous
        .where(
          (c) =>
              (_statut == null || c.statut == _statut) && (_fournisseur == null || c.fournisseurCode == _fournisseur),
        )
        .toList();
    final colonnes = <DsColonne<CommandeFournisseur>>[
      DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (c) => c.code, fort: true),
      DsColonne(
        id: 'date',
        libelle: l10n.communDate,
        attenue: true,
        valeur: (c) => c.date,
        cellule: (_, c) => Text(formatDateHeure.format(c.date)),
      ),
      DsColonne(
        id: 'frn',
        libelle: l10n.retoursFournisseur,
        flex: 2,
        valeur: (c) => noms[c.fournisseurCode] ?? c.fournisseurCode,
      ),
      DsColonne(id: 'n', libelle: l10n.stkArticles, numerique: true, valeur: (c) => c.lignes.length),
      DsColonne(
        id: 'recu',
        libelle: l10n.cmdfRecu,
        numerique: true,
        valeur: (c) => c.recu,
        cellule: (_, c) => Text('${formaterNombre(c.recu)} / ${formaterNombre(c.quantite)}'),
      ),
      DsColonne(
        id: 'total',
        libelle: l10n.retoursMontant,
        numerique: true,
        fort: true,
        valeur: (c) => c.total,
        cellule: (_, c) => Text(formaterMontant(c.total, devise)),
        total: (cs) => formaterMontant(cs.where((c) => c.actif).fold(0.0, (s, c) => s + c.total), devise),
      ),
      DsColonne(
        id: 'livraison',
        libelle: l10n.stkLivraison,
        attenue: true,
        valeur: (c) => c.dateLivraison ?? DateTime(0),
        cellule: (_, c) => Text(dateOuTiret(c.dateLivraison)),
      ),
      DsColonne(
        id: 'statut',
        libelle: l10n.stkStatut,
        valeur: (c) => c.statut,
        cellule: (_, c) => DsBadge(
          libelle: libelleStatutCommandeFournisseur(l10n, c.statut),
          ton: tonStatutCommandeFournisseur(c.statut),
        ),
      ),
      DsColonne(
        id: 'entrees',
        libelle: l10n.cmdfReceptions,
        visibleParDefaut: false,
        valeur: (c) => c.receptions.join(', '),
      ),
      DsColonne(
        id: 'obs',
        libelle: l10n.retoursObservation,
        visibleParDefaut: false,
        valeur: (c) => c.observation ?? '',
      ),
      ...colonnesAudit(context, ref, (CommandeFournisseur x) => x.audit),
    ];
    final actives = lignes.where((c) => c.actif);
    return PageModule(
      moduleId: 'commandes_fournisseurs',
      child: DsModuleTable<CommandeFournisseur>(
        key: const ValueKey('cmdf_table'),
        entite: l10n.moduleCommandesFournisseurs,
        lignes: lignes,
        colonnes: colonnes,
        cle: (c) => c.code,
        afficherTotaux: true,
        messageVide: l10n.docAucun,
        periode: _periode,
        onPeriode: (p) => setState(() => _periode = p),
        texteRecherche: (c) => '${c.code} ${noms[c.fournisseurCode] ?? ''} ${c.receptions.join(' ')}',
        nbFiltresActifs: [_statut, _fournisseur].where((f) => f != null).length,
        onReinitialiser: () => setState(() {
          _statut = null;
          _fournisseur = null;
          _periode = DsPeriode.calculer('month');
        }),
        kpis: [
          DsStatCard(libelle: l10n.docKpiNombre, valeur: '${actives.length}', icone: LucideIcons.clipboardList),
          DsStatCard(
            libelle: l10n.docKpiMontant,
            valeur: f2(actives.fold(0.0, (s, c) => s + c.total)),
            suffixe: devise,
            icone: LucideIcons.banknote,
          ),
          DsStatCard(
            libelle: l10n.cmdfKpiAttendues,
            valeur: '${actives.where((c) => c.ouverte).length}',
            icone: LucideIcons.truck,
          ),
        ],
        filtres: [
          DsFormRow(
            libelle: l10n.stkStatut,
            largeurLibelle: 80,
            child: DsSelect<String?>(
              cle: const ValueKey('cmdf_filtre_statut'),
              valeur: _statut,
              options: const [
                null,
                StatutsCommandeFournisseur.enCours,
                StatutsCommandeFournisseur.partielle,
                StatutsCommandeFournisseur.recue,
                StatutsCommandeFournisseur.soldee,
                StatutsCommandeFournisseur.annulee,
              ],
              libelle: (s) => s == null ? l10n.tiersTous : libelleStatutCommandeFournisseur(l10n, s),
              onChanged: (s) => setState(() => _statut = s),
            ),
          ),
          DsFormRow(
            libelle: l10n.retoursFournisseur,
            largeurLibelle: 80,
            child: DsSelect<String?>(
              valeur: _fournisseur,
              options: [
                null,
                ...{for (final c in tous) c.fournisseurCode},
              ],
              libelle: (f) => f == null ? l10n.tiersTous : (noms[f] ?? f),
              recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
              onChanged: (f) => setState(() => _fournisseur = f),
            ),
          ),
        ],
        onOuvrir: (c) => afficherDetailCommandeFournisseur(context, ref, c),
        onExport: peutExporter(ref)
            ? (format, cs) => exporterTableau(
                context,
                ref,
                id: 'commandes_fournisseurs',
                titre: l10n.moduleCommandesFournisseurs,
                colonnes: colonnes,
                lignes: cs,
                format: format,
              )
            : null,
        actions: [
          DsActionModule(
            libelle: l10n.tiersDetail,
            icone: LucideIcons.eye,
            regle: DsRegleSelection.une,
            detail: true,
            onPressed: (choix, _) => afficherDetailCommandeFournisseur(context, ref, choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('cmdf_imprimer'),
            libelle: l10n.docImprimer,
            icone: LucideIcons.printer,
            regle: DsRegleSelection.une,
            onPressed: (choix, _) => imprimerCommandeFournisseur(context, ref, choix.first),
          ),
          DsActionModule(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            iconeSeule: true,
            regle: DsRegleSelection.une,
            desactive: (choix) =>
                choix.isNotEmpty && (!choix.first.actif || choix.first.soldee || choix.first.receptions.isNotEmpty),
            onPressed: (choix, _) => afficherFormulaireCommandeFournisseur(context, ref, commande: choix.first),
          ),
          DsActionModule(
            cle: const ValueKey('cmdf_receptionner'),
            libelle: l10n.cmdfReceptionner,
            icone: LucideIcons.packagePlus,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && !choix.first.ouverte,
            onPressed: (choix, effacer) async {
              await afficherFormulaireEntree(context, ref, commande: choix.first);
              effacer();
            },
          ),
          DsActionModule(
            cle: const ValueKey('cmdf_solder'),
            libelle: l10n.cmdfSolder,
            icone: LucideIcons.circleCheck,
            regle: DsRegleSelection.une,
            desactive: (choix) => choix.isNotEmpty && !choix.first.ouverte,
            onPressed: (choix, effacer) async {
              await _solder(choix.first);
              effacer();
            },
          ),
          DsActionModule(
            cle: const ValueKey('cmdf_annuler'),
            libelle: l10n.dsAnnuler,
            icone: LucideIcons.x,
            iconeSeule: true,
            danger: true,
            onPressed: (choix, effacer) => _annuler(choix, effacer, noms),
          ),
        ],
        primaire: DsButton(
          key: const ValueKey('cmdf_nouvelle'),
          libelle: l10n.cmdfNouvelle,
          icone: LucideIcons.plus,
          onPressed: () => afficherFormulaireCommandeFournisseur(context, ref),
        ),
      ),
    );
  }

  Future<void> _solder(CommandeFournisseur c) async {
    final l10n = AppLocalizations.of(context);
    final ok = await afficherConfirmation(
      context,
      titre: l10n.cmdfSolder,
      message: l10n.cmdfSolderMessage(c.code),
      libelleConfirmer: l10n.cmdfSolder,
    );
    if (!ok || !mounted) return;
    await executerDocument(context, ref, () => ref.read(commandeFournisseurServiceProvider).solder(c.code));
  }

  Future<void> _annuler(List<CommandeFournisseur> choix, VoidCallback effacer, Map<String, String> noms) async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    String? blocage(CommandeFournisseur c) => !c.actif
        ? l10n.stkBloqueDejaAnnulee
        : c.receptions.isNotEmpty
        ? l10n.cmdfErreurReceptionLiee
        : null;
    final motif = await afficherActionLot(
      context,
      action: DsActionLot.annuler,
      entite: l10n.moduleCommandesFournisseurs,
      motifRequis: true,
      elements: [
        for (final c in choix)
          DsElementLot(
            id: c.code,
            titre: '${c.code} · ${noms[c.fournisseurCode] ?? c.fournisseurCode}',
            meta: formaterMontant(c.total, devise),
            motifBlocage: blocage(c),
          ),
      ],
    );
    if (motif == null || !mounted) return;
    final service = ref.read(commandeFournisseurServiceProvider);
    await executerDocument(context, ref, () async {
      for (final c in choix) {
        if (blocage(c) == null) await service.annuler(c.code, motif: motif);
      }
    });
    effacer();
  }
}

/// Formulaire de commande fournisseur (DocForm) : fournisseur, magasin de réception, livraison prévue, lignes au
/// prix d'achat. [besoin] : commande créée depuis une liste de besoins.
Future<void> afficherFormulaireCommandeFournisseur(
  BuildContext context,
  WidgetRef ref, {
  CommandeFournisseur? commande,
  Besoin? besoin,
  List<(Produit, double)> proposes = const [],
}) async {
  final produits = {for (final p in await ref.read(produitsProvider.future)) p.code: p};
  final principal = await ref.read(magasinPrincipalProvider.future);
  await ref.read(fournisseursProvider.future);
  await ref.read(magasinsProvider.future);
  if (!context.mounted) return;
  final lignes = [
    // Alerte « Rupture sans commande » : produits et quantités proposés, au prix d'achat de la fiche.
    for (final (p, q) in proposes) LigneDoc(produit: p, quantite: q, prix: p.prixAchat),
    if (commande != null)
      for (final l in commande.lignes)
        if (produits[l.produitCode] != null)
          LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite, prix: l.prix),
    if (besoin != null)
      for (final l in besoin.lignes)
        if (produits[l.produitCode] != null)
          LigneDoc(produit: produits[l.produitCode]!, quantite: l.quantite, prix: l.prix),
  ];
  await afficherDialog<bool>(
    context,
    fermableParVoile: false,
    builder: (_) => _CommandeForm(commande, besoin, lignes, commande?.magasinCode ?? principal),
  );
}

class _CommandeForm extends ConsumerStatefulWidget {
  const _CommandeForm(this.commande, this.besoin, this.lignesInitiales, this.magasin);
  final CommandeFournisseur? commande;
  final Besoin? besoin;
  final List<LigneDoc> lignesInitiales;
  final String magasin;

  @override
  ConsumerState<_CommandeForm> createState() => _CommandeFormState();
}

class _CommandeFormState extends ConsumerState<_CommandeForm> {
  late List<LigneDoc> _lignes = widget.lignesInitiales;
  late String? _fournisseur = widget.commande?.fournisseurCode ?? widget.besoin?.fournisseurCode;
  late String _magasin = widget.magasin;
  late DateTime? _livraison = widget.commande?.dateLivraison ?? widget.besoin?.dateLivraison;
  late final _observation = TextEditingController(text: widget.commande?.observation ?? '');

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  Future<bool> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final s = ref.read(commandeFournisseurServiceProvider);
    final lignes = [
      for (final l in _lignes) DemandeLigneDocument(produitCode: l.produit.code, quantite: l.quantite, prix: l.prix),
    ];
    var code = widget.commande?.code ?? '';
    final ok = await executerDocument(context, ref, () async {
      if (widget.commande == null) {
        code = (await s.creer(
          fournisseurCode: _fournisseur!,
          magasinCode: _magasin,
          lignes: lignes,
          dateLivraison: _livraison,
          besoinCode: widget.besoin?.code,
          observation: _observation.text,
        )).code;
      } else {
        await s.modifier(
          code,
          fournisseurCode: _fournisseur!,
          magasinCode: _magasin,
          lignes: lignes,
          dateLivraison: _livraison,
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
    final fournisseurs = (ref.watch(fournisseursProvider).value ?? const <Fournisseur>[])
        .where((f) => f.actif || f.code == _fournisseur)
        .toList();
    final magasins = (ref.watch(magasinsProvider).value ?? const <Magasin>[])
        .where((m) => m.actif || m.code == _magasin)
        .toList();
    final c = widget.commande;
    return DocFormDialog(
      titre: c == null ? l10n.cmdfNouvelle : l10n.cmdfModifier,
      icone: LucideIcons.clipboardList,
      cleEnregistrer: const ValueKey('cmdf_enregistrer'),
      lignes: _lignes,
      onLignes: (l) => setState(() => _lignes = l),
      magasinSelecteur: _magasin,
      peutEnregistrer: _fournisseur != null && _lignes.every((l) => l.quantite > 0),
      onEnregistrer: _enregistrer,
      totalLigne: (l) => l.quantite * l.prix,
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
          libelle: l10n.stkACommander,
          numerique: true,
          editable: true,
          largeur: 116,
          valeur: (l) => texteQuantite(l.quantite),
          onEdition: (l, v) => setState(() => l.quantite = nombreSaisi(v)),
        ),
        DsColonneLigne(
          id: 'prix',
          libelle: l10n.cmdfPrix,
          numerique: true,
          editable: true,
          largeur: 140,
          suffixe: devise,
          valeur: (l) => texteQuantite(l.prix),
          onEdition: (l, v) => setState(() => l.prix = nombreSaisi(v)),
        ),
      ],
      entete: [
        DsFormRow(
          libelle: l10n.retoursFournisseur,
          obligatoire: true,
          largeurLibelle: _lw,
          child: DsSelect<String?>(
            cle: const ValueKey('cmdf_fournisseur'),
            valeur: _fournisseur,
            placeholder: l10n.stkChoisirFournisseur,
            options: [for (final f in fournisseurs) f.code],
            libelle: (x) => fournisseurs.where((f) => f.code == x).firstOrNull?.nom ?? (x ?? ''),
            recherche: rechercheListe(context, ref, ListeMetier.fournisseur),
            onChanged: (v) => setState(() => _fournisseur = v),
          ),
        ),
        if (ref.watch(plusieursMagasinsProvider))
          DsFormRow(
            libelle: l10n.stkMagasin,
            largeurLibelle: _lw,
            child: DsSelect<String>(
              valeur: _magasin,
              options: [for (final m in magasins) m.code],
              libelle: (x) => magasins.where((m) => m.code == x).firstOrNull?.nom ?? x,
              onChanged: (v) => setState(() => _magasin = v ?? _magasin),
            ),
          ),
        DsFormRow(
          libelle: l10n.stkLivraison,
          largeurLibelle: _lw,
          child: DsDateField(valeur: _livraison, onChanged: (d) => setState(() => _livraison = d)),
        ),
        DsFormRow(
          libelle: l10n.retoursObservation,
          largeurLibelle: _lw,
          child: DsTextField(controller: _observation),
        ),
      ],
    );
  }
}

Future<void> afficherDetailCommandeFournisseur(BuildContext context, WidgetRef ref, CommandeFournisseur c) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final noms = {for (final f in await ref.read(fournisseursProvider.future)) f.code: f.nom};
  if (!context.mounted) return;
  return afficherDetailEntite(
    context,
    DsEntityDetailDialog(
      largeur: 960,
      icone: LucideIcons.clipboardList,
      titre: l10n.cmdfTitre(c.code),
      description: '${formatDateHeure.format(c.date)} · ${noms[c.fournisseurCode] ?? c.fournisseurCode}',
      badges: [
        DsBadge(libelle: libelleStatutCommandeFournisseur(l10n, c.statut), ton: tonStatutCommandeFournisseur(c.statut)),
      ],
      onModifier: () => afficherFormulaireCommandeFournisseur(context, ref, commande: c),
      modifierDesactive: !c.actif || c.soldee || c.receptions.isNotEmpty,
      piedSupplementaire: [
        DsButton(
          libelle: l10n.docImprimer,
          icone: LucideIcons.printer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => imprimerCommandeFournisseur(context, ref, c),
        ),
        if (c.ouverte)
          DsButton(
            key: const ValueKey('cmdf_detail_receptionner'),
            libelle: l10n.cmdfReceptionner,
            icone: LucideIcons.packagePlus,
            onPressed: () async {
              Navigator.of(context).pop();
              await afficherFormulaireEntree(context, ref, commande: c);
            },
          ),
      ],
      stats: [
        DsStatItem(libelle: l10n.stkArticles, valeur: '${c.lignes.length}', icone: LucideIcons.package),
        DsStatItem(libelle: l10n.retoursMontant, valeur: f2(c.total), suffixe: devise, icone: LucideIcons.wallet),
        DsStatItem(
          libelle: l10n.cmdfRecu,
          valeur: '${formaterNombre(c.recu)} / ${formaterNombre(c.quantite)}',
          icone: LucideIcons.packageCheck,
        ),
        if (c.dateLivraison != null)
          DsStatItem(libelle: l10n.stkLivraison, valeur: formatDate.format(c.dateLivraison!), icone: LucideIcons.truck),
      ],
      sections: [
        DsSectionDetail(
          titre: l10n.produitsOngletProduits,
          icone: LucideIcons.package,
          nbLignes: c.lignes.length,
          tableau: DsDataTable<CommandeFournisseurLigne>(
            dense: true,
            encadre: false,
            pagine: false,
            reserveEcran: 360,
            cle: (l) => '${l.ordre}',
            lignes: c.lignes,
            colonnes: [
              DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (l) => l.produitCode, attenue: true),
              DsColonne(id: 'nom', libelle: l10n.dsPosProduit, valeur: (l) => l.designation, fort: true, flex: 3),
              DsColonne(
                id: 'qte',
                libelle: l10n.stkACommander,
                numerique: true,
                valeur: (l) => l.quantite,
                cellule: (_, l) => Text(formaterNombre(l.quantite)),
              ),
              DsColonne(
                id: 'recu',
                libelle: l10n.cmdfRecu,
                numerique: true,
                valeur: (l) => l.recu,
                cellule: (_, l) => Text(formaterNombre(l.recu)),
              ),
              DsColonne(
                id: 'reste',
                libelle: l10n.cmdfReste,
                numerique: true,
                valeur: (l) => l.reste,
                cellule: (_, l) => Text(formaterNombre(l.reste)),
              ),
              DsColonne(
                id: 'prix',
                libelle: l10n.cmdfPrix,
                numerique: true,
                valeur: (l) => l.prix,
                cellule: (_, l) => Text(formaterMontant(l.prix, devise)),
              ),
              DsColonne(
                id: 'montant',
                libelle: l10n.retoursMontant,
                numerique: true,
                valeur: (l) => l.montant,
                cellule: (_, l) => Text(formaterMontant(l.montant, devise)),
              ),
            ],
          ),
        ),
        DsSectionDetail(
          titre: l10n.stkAudit,
          icone: LucideIcons.shieldCheck,
          repliable: true,
          items: [
            DsKeyValue(l10n.cmdfReceptions, c.receptions.isEmpty ? '—' : c.receptions.join(', ')),
            if (c.besoinCode != null) DsKeyValue(l10n.entListeBesoins, c.besoinCode),
            if (c.observation != null) DsKeyValue(l10n.retoursObservation, c.observation),
            if (c.annulation != null) DsKeyValue(l10n.auditMotif, c.annulation!.motif),
          ],
        ),
      ],
    ),
  );
}
