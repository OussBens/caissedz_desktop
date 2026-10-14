import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/caisse_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/caisse.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import 'gestion_caisse_providers.dart';

const _modes = ['Espèces', 'Carte', 'Chèque', 'Virement'];

/// Module Gestion de caisse : caisses (Physique / Compte, avec ou sans magasin), journal des mouvements
/// (apports, dépenses), transferts TRF entre caisses.
class GestionCaissePage extends ConsumerStatefulWidget {
  const GestionCaissePage({super.key});

  @override
  ConsumerState<GestionCaissePage> createState() => _GestionCaissePageState();
}

class _GestionCaissePageState extends ConsumerState<GestionCaissePage> {
  int _onglet = 0;
  String? _filtreCaisse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final caisses = ref.watch(caissesListeProvider).value ?? const [];
    final soldes = ref.watch(soldesCaissesProvider).value ?? const {};
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    final df = DateFormat('dd/MM/yyyy HH:mm');
    String nomCaisse(String code) => caisses.where((c) => c.code == code).firstOrNull?.nom ?? code;
    String nomMagasin(String? code) =>
        code == null ? l10n.caisseSansMagasin : magasins.where((m) => m.code == code).firstOrNull?.nom ?? code;
    return DsPage(
      titre: l10n.gestionCaisseTitre,
      actions: switch (_onglet) {
        0 => [
          DsButton(
            libelle: l10n.caisseNouvelle,
            icone: LucideIcons.plus,
            onPressed: () {
              _formulaireCaisse();
            },
          ),
        ],
        1 => [
          DsButton(
            libelle: l10n.mouvementDepense,
            icone: LucideIcons.minus,
            variante: DsButtonVariante.secondaire,
            onPressed: () {
              _mouvement(apport: false);
            },
          ),
          DsButton(
            libelle: l10n.mouvementApport,
            icone: LucideIcons.plus,
            onPressed: () {
              _mouvement(apport: true);
            },
          ),
        ],
        _ => [
          DsButton(
            libelle: l10n.transfertCaisseNouveau,
            icone: LucideIcons.arrowLeftRight,
            onPressed: () {
              _transfert();
            },
          ),
        ],
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsOnglets(
            onglets: [
              l10n.gestionCaisseOngletCaisses,
              l10n.gestionCaisseOngletMouvements,
              l10n.gestionCaisseOngletTransferts,
            ],
            courant: _onglet,
            onChanged: (i) => setState(() => _onglet = i),
          ),
          const SizedBox(height: DsSpacing.lg),
          Expanded(
            child: switch (_onglet) {
              0 => DsDataTable<Caisse>(
                colonnes: [
                  DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (c) => c.code, largeur: 100),
                  DsColonne(id: 'nom', libelle: l10n.caisseNom, valeur: (c) => c.nom, flex: 2),
                  DsColonne(
                    id: 'type',
                    libelle: l10n.caisseType,
                    valeur: (c) => c.type,
                    cellule: (_, c) => DsBadge(
                      libelle: libelleTypeCaisse(l10n, c.type),
                      ton: c.type == TypesCaisse.compte ? DsBadgeTon.info : DsBadgeTon.primaire,
                      icone: c.type == TypesCaisse.compte ? LucideIcons.landmark : LucideIcons.wallet,
                    ),
                  ),
                  DsColonne(id: 'mag', libelle: l10n.caisseMagasin, valeur: (c) => nomMagasin(c.magasinCode), flex: 2),
                  DsColonne(
                    id: 'esp',
                    libelle: l10n.caisseSoldeEspeces,
                    valeur: (c) => soldes[c.code]?.especes ?? 0,
                    numerique: true,
                    cellule: (_, c) => Text(formaterMontant(soldes[c.code]?.especes ?? 0, devise)),
                  ),
                  DsColonne(
                    id: 'tot',
                    libelle: l10n.caisseSoldeTotal,
                    valeur: (c) => soldes[c.code]?.total ?? 0,
                    numerique: true,
                    cellule: (_, c) => Text(formaterMontant(soldes[c.code]?.total ?? 0, devise)),
                  ),
                  DsColonne(
                    id: 'actif',
                    libelle: l10n.caisseActive,
                    valeur: (c) => c.actif ? 1 : 0,
                    cellule: (_, c) => DsBadge(
                      libelle: c.actif ? l10n.caisseActive : l10n.caisseInactive,
                      ton: c.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
                    ),
                  ),
                ],
                lignes: caisses,
                cle: (c) => c.code,
                messageVide: l10n.caisseAucune,
                actionsContextuelles: [
                  DsActionContextuelle(
                    libelle: l10n.caisseModifier,
                    icone: LucideIcons.pencil,
                    onSelected: (c) => _formulaireCaisse(existante: c),
                  ),
                  DsActionContextuelle(
                    libelle: l10n.caisseDesactiver,
                    icone: LucideIcons.ban,
                    destructif: true,
                    visible: (c) => c.actif && !c.systeme,
                    onSelected: (c) => _enregistrerCaisse(c.copyWith(actif: false)),
                  ),
                  DsActionContextuelle(
                    libelle: l10n.caisseActiver,
                    icone: LucideIcons.check,
                    visible: (c) => !c.actif,
                    onSelected: (c) => _enregistrerCaisse(c.copyWith(actif: true)),
                  ),
                ],
              ),
              1 => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 280,
                    child: DsSelect<String>(
                      valeur: _filtreCaisse ?? '',
                      options: ['', ...caisses.map((c) => c.code)],
                      libelle: (c) => c.isEmpty ? l10n.mouvementToutesCaisses : nomCaisse(c),
                      onChanged: (v) => setState(() => _filtreCaisse = v == null || v.isEmpty ? null : v),
                    ),
                  ),
                  const SizedBox(height: DsSpacing.md),
                  Expanded(
                    child: DsDataTable<MouvementCaisse>(
                      colonnes: [
                        DsColonne(
                          id: 'd',
                          libelle: l10n.communDate,
                          valeur: (m) => m.date,
                          largeur: 150,
                          cellule: (_, m) => Text(df.format(m.date)),
                        ),
                        DsColonne(
                          id: 'c',
                          libelle: l10n.mouvementCaisse,
                          valeur: (m) => nomCaisse(m.caisseCode),
                          flex: 2,
                        ),
                        DsColonne(
                          id: 't',
                          libelle: l10n.mouvementColType,
                          valeur: (m) => m.type,
                          flex: 2,
                          cellule: (_, m) => Text(libelleTypeMouvementCaisse(l10n, m.type)),
                        ),
                        DsColonne(
                          id: 's',
                          libelle: l10n.mouvementColSens,
                          valeur: (m) => m.sens,
                          cellule: (_, m) => DsBadge(
                            libelle: m.sens == SensMouvementCaisse.entree ? l10n.sensEntree : l10n.sensSortie,
                            ton: m.sens == SensMouvementCaisse.entree ? DsBadgeTon.succes : DsBadgeTon.danger,
                          ),
                        ),
                        DsColonne(
                          id: 'm',
                          libelle: l10n.mouvementColMontant,
                          valeur: (m) => m.signe,
                          numerique: true,
                          total: (ls) => formaterMontant(ls.fold(0.0, (s, m) => s + m.signe), devise),
                          cellule: (_, m) => Text(formaterMontant(m.signe, devise)),
                        ),
                        DsColonne(
                          id: 'mode',
                          libelle: l10n.mouvementColMode,
                          valeur: (m) => m.mode,
                          cellule: (_, m) => Text(libelleModePaiement(l10n, m.mode)),
                        ),
                        DsColonne(
                          id: 'ref',
                          libelle: l10n.mouvementColReference,
                          valeur: (m) => m.referenceCode,
                          flex: 2,
                        ),
                        DsColonne(id: 'com', libelle: l10n.communCommentaire, valeur: (m) => m.commentaire, flex: 2),
                      ],
                      lignes: (ref.watch(mouvementsCaisseProvider).value ?? const [])
                          .where((m) => _filtreCaisse == null || m.caisseCode == _filtreCaisse)
                          .toList(),
                      cle: (m) => m.id ?? m.hashCode,
                      afficherTotaux: true,
                      messageVide: l10n.mouvementAucun,
                    ),
                  ),
                ],
              ),
              _ => DsDataTable<TransfertCaisse>(
                colonnes: [
                  DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (t) => t.code, largeur: 100),
                  DsColonne(
                    id: 'd',
                    libelle: l10n.communDate,
                    valeur: (t) => t.date,
                    largeur: 150,
                    cellule: (_, t) => Text(df.format(t.date)),
                  ),
                  DsColonne(
                    id: 's',
                    libelle: l10n.transfertCaisseSource,
                    valeur: (t) => nomCaisse(t.caisseSource),
                    flex: 2,
                  ),
                  DsColonne(
                    id: 'dest',
                    libelle: l10n.transfertCaisseDestination,
                    valeur: (t) => nomCaisse(t.caisseDestination),
                    flex: 2,
                  ),
                  DsColonne(
                    id: 'm',
                    libelle: l10n.mouvementColMontant,
                    valeur: (t) => t.montant,
                    numerique: true,
                    cellule: (_, t) => Text(formaterMontant(t.montant, devise)),
                  ),
                  DsColonne(
                    id: 'mode',
                    libelle: l10n.mouvementColMode,
                    valeur: (t) => t.mode,
                    cellule: (_, t) => Text(libelleModePaiement(l10n, t.mode)),
                  ),
                  DsColonne(id: 'c', libelle: l10n.communCommentaire, valeur: (t) => t.commentaire, flex: 2),
                ],
                lignes: ref.watch(transfertsCaisseProvider).value ?? const [],
                cle: (t) => t.code,
                messageVide: l10n.transfertCaisseAucun,
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _erreur(String titre, CaisseException e) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: titre,
        message: messageErreurCaisse(l10n, e.erreur),
      ),
    );
  }

  Future<void> _enregistrerCaisse(Caisse c) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(caisseServiceProvider).modifier(c);
      rafraichirCaisse(ref);
    } on CaisseException catch (e) {
      await _erreur(l10n.caisseModifier, e);
    }
  }

  Future<void> _formulaireCaisse({Caisse? existante}) async {
    final l10n = AppLocalizations.of(context);
    final magasins = await ref.read(magasinsProvider.future);
    if (!mounted) return;
    final nom = TextEditingController(text: existante?.nom ?? '');
    var type = existante?.type ?? TypesCaisse.physique;
    var magasin = existante?.magasinCode ?? '';
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: existante == null ? l10n.caisseNouvelle : l10n.caisseModifier,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communEnregistrer,
              icone: LucideIcons.save,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsTextField(controller: nom, libelle: l10n.caisseNom, autofocus: true),
              const SizedBox(height: DsSpacing.md),
              DsSelect<String>(
                titre: l10n.caisseType,
                valeur: type,
                options: const [TypesCaisse.physique, TypesCaisse.compte],
                libelle: (t) => libelleTypeCaisse(l10n, t),
                onChanged: (v) => setState(() => type = v ?? type),
              ),
              const SizedBox(height: DsSpacing.md),
              DsSelect<String>(
                titre: l10n.caisseMagasin,
                valeur: magasin,
                options: ['', ...magasins.map((m) => m.code)],
                libelle: (c) => c.isEmpty ? l10n.caisseSansMagasin : magasins.firstWhere((m) => m.code == c).nom,
                onChanged: (v) => setState(() => magasin = v ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      if (existante == null) {
        await ref
            .read(caisseServiceProvider)
            .creer(nom: nom.text, type: type, magasinCode: magasin.isEmpty ? null : magasin);
      } else {
        await ref
            .read(caisseServiceProvider)
            .modifier(
              existante.copyWith(
                nom: nom.text,
                type: type,
                magasinCode: magasin.isEmpty ? null : magasin,
                sansMagasin: magasin.isEmpty,
              ),
            );
      }
      rafraichirCaisse(ref);
    } on CaisseException catch (e) {
      await _erreur(existante == null ? l10n.caisseNouvelle : l10n.caisseModifier, e);
    }
  }

  Future<void> _mouvement({required bool apport}) async {
    final l10n = AppLocalizations.of(context);
    final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
    if (!mounted || caisses.isEmpty) return;
    final titre = apport ? l10n.mouvementApport : l10n.mouvementDepense;
    var caisse = _filtreCaisse ?? caisses.first.code;
    var mode = 'Espèces';
    final montant = TextEditingController();
    final commentaire = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: titre,
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
              DsSelect<String>(
                titre: l10n.mouvementCaisse,
                valeur: caisse,
                options: caisses.map((c) => c.code).toList(),
                libelle: (c) => caisses.firstWhere((x) => x.code == c).nom,
                onChanged: (v) => setState(() => caisse = v ?? caisse),
              ),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsTextField(
                      controller: montant,
                      libelle: l10n.mouvementColMontant,
                      autofocus: true,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.mouvementColMode,
                      valeur: mode,
                      options: _modes,
                      libelle: (m) => libelleModePaiement(l10n, m),
                      onChanged: (v) => setState(() => mode = v ?? mode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref
          .read(caisseServiceProvider)
          .mouvementManuel(
            caisseCode: caisse,
            apport: apport,
            montant: double.tryParse(montant.text.replaceAll(',', '.')) ?? 0,
            mode: mode,
            commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
          );
      rafraichirCaisse(ref);
    } on CaisseException catch (e) {
      await _erreur(titre, e);
    }
  }

  Future<void> _transfert() async {
    final l10n = AppLocalizations.of(context);
    final devise = ref.read(deviseProvider);
    final caisses = (await ref.read(caissesListeProvider.future)).where((c) => c.actif).toList();
    if (!mounted) return;
    if (caisses.length < 2) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.info,
          titre: l10n.transfertCaisseNouveau,
          message: l10n.caisseErreurMemeCaisse,
        ),
      );
      return;
    }
    var source = caisses.first.code;
    var destination = caisses[1].code;
    var mode = 'Espèces';
    final montant = TextEditingController();
    final commentaire = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: l10n.transfertCaisseNouveau,
          largeur: 560,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(
              libelle: l10n.communValider,
              icone: LucideIcons.arrowLeftRight,
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
                      titre: l10n.transfertCaisseSource,
                      valeur: source,
                      options: caisses.map((c) => c.code).toList(),
                      libelle: (c) => caisses.firstWhere((x) => x.code == c).nom,
                      onChanged: (v) => setState(() => source = v ?? source),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.transfertCaisseDestination,
                      valeur: destination,
                      options: caisses.map((c) => c.code).toList(),
                      libelle: (c) => caisses.firstWhere((x) => x.code == c).nom,
                      onChanged: (v) => setState(() => destination = v ?? destination),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DsTextField(
                      controller: montant,
                      libelle: '${l10n.mouvementColMontant} ($devise)',
                      autofocus: true,
                      typeClavier: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(
                    child: DsSelect<String>(
                      titre: l10n.mouvementColMode,
                      valeur: mode,
                      options: _modes,
                      libelle: (m) => libelleModePaiement(l10n, m),
                      onChanged: (v) => setState(() => mode = v ?? mode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: commentaire, libelle: l10n.communCommentaire),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final t = await ref
          .read(caisseServiceProvider)
          .transferer(
            caisseSource: source,
            caisseDestination: destination,
            montant: double.tryParse(montant.text.replaceAll(',', '.')) ?? 0,
            mode: mode,
            commentaire: commentaire.text.trim().isEmpty ? null : commentaire.text.trim(),
          );
      rafraichirCaisse(ref);
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.transfertCaisseNouveau,
          message: l10n.transfertCaisseCree(t.code),
        ),
      );
    } on CaisseException catch (e) {
      await _erreur(l10n.transfertCaisseNouveau, e);
    }
  }
}
