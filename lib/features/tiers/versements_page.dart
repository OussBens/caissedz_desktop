import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/versement_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import 'tiers_providers.dart';
import 'versement_dialog.dart';

/// Versements : liste, création (client ou fournisseur), suppression (sauf verrouillé).
class VersementsPage extends ConsumerWidget {
  const VersementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final versements = ref.watch(versementsProvider).value ?? const [];
    final clients = ref.watch(clientsProvider).value ?? const [];
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const [];
    final df = DateFormat('dd/MM/yyyy');
    String nomTiers(Versement v) => v.tiersType == TypesTiers.client
        ? (clients.where((c) => c.code == v.tiersCode).firstOrNull?.nom ?? v.tiersCode)
        : (fournisseurs.where((f) => f.code == v.tiersCode).firstOrNull?.nom ?? v.tiersCode);
    return DsPage(
      titre: l10n.versementsTitre,
      actions: [
        DsButton(
          libelle: l10n.versementNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            _nouveau(context, ref, clients, fournisseurs);
          },
        ),
      ],
      child: DsDataTable<Versement>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (v) => v.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (v) => v.date,
            largeur: 110,
            cellule: (_, v) => Text(df.format(v.date)),
          ),
          DsColonne(
            id: 't',
            libelle: l10n.versementTiers,
            valeur: (v) => nomTiers(v),
            flex: 3,
            cellule: (_, v) => Row(
              children: [
                if (v.verrouille)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: DsSpacing.xs),
                    child: Icon(LucideIcons.lock, size: 12, color: context.ds.colors.texteAttenue),
                  ),
                Expanded(child: Text(nomTiers(v), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          DsColonne(
            id: 's',
            libelle: l10n.versementColSens,
            valeur: (v) => v.sens,
            cellule: (_, v) => DsBadge(
              libelle: v.sens == SensVersement.encaissement ? l10n.sensEncaissement : l10n.sensDecaissement,
              ton: v.sens == SensVersement.encaissement ? DsBadgeTon.succes : DsBadgeTon.avertissement,
            ),
          ),
          DsColonne(
            id: 'm',
            libelle: l10n.versementMontant,
            valeur: (v) => v.montant,
            numerique: true,
            cellule: (_, v) => Text(formaterMontant(v.montant, devise)),
          ),
          DsColonne(
            id: 'mode',
            libelle: l10n.versementMode,
            valeur: (v) => v.mode,
            cellule: (_, v) => Text(libelleModePaiement(l10n, v.mode)),
          ),
          DsColonne(
            id: 'i',
            libelle: l10n.versementColImpute,
            valeur: (v) => v.impute,
            numerique: true,
            cellule: (_, v) => Text(formaterMontant(v.impute, devise)),
          ),
          DsColonne(
            id: 'ni',
            libelle: l10n.versementColNonImpute,
            valeur: (v) => v.nonImpute,
            numerique: true,
            cellule: (_, v) => Text(v.nonImpute > 0 ? formaterMontant(v.nonImpute, devise) : ''),
          ),
        ],
        lignes: versements,
        cle: (v) => v.code,
        messageVide: l10n.versementAucun,
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.versementSupprimer,
            icone: LucideIcons.trash2,
            destructif: true,
            onSelected: (v) async {
              if (v.verrouille) {
                unawaited(
                  afficherResultat(
                    context,
                    type: DsResultatType.info,
                    titre: l10n.versementSupprimer,
                    message: l10n.versementVerrouille(v.retourCode ?? ''),
                  ),
                );
                return;
              }
              if (!await afficherConfirmation(
                context,
                titre: l10n.versementSupprimer,
                message: l10n.versementConfirmerSuppression(v.code),
                destructif: true,
              )) {
                return;
              }
              try {
                await ref.read(versementServiceProvider).supprimer(v.code);
                rafraichirCommerce(ref);
              } on VersementException catch (e) {
                if (!context.mounted) return;
                unawaited(
                  afficherResultat(
                    context,
                    type: DsResultatType.erreur,
                    titre: l10n.versementSupprimer,
                    message: messageErreurVersement(l10n, e.erreur),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _nouveau(
    BuildContext context,
    WidgetRef ref,
    List<Client> clients,
    List<Fournisseur> fournisseurs,
  ) async {
    final l10n = AppLocalizations.of(context);
    final type = await showDialog<String>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => DsDialog(
        titre: l10n.versementNouveau,
        largeur: 380,
        contenu: Row(
          children: [
            Expanded(
              child: DsButton(
                libelle: l10n.versementTiersClient,
                icone: LucideIcons.users,
                variante: DsButtonVariante.secondaire,
                pleineLargeur: true,
                onPressed: () => Navigator.of(ctx).pop(TypesTiers.client),
              ),
            ),
            const SizedBox(width: DsSpacing.sm),
            Expanded(
              child: DsButton(
                libelle: l10n.versementTiersFournisseur,
                icone: LucideIcons.truck,
                variante: DsButtonVariante.secondaire,
                pleineLargeur: true,
                onPressed: () => Navigator.of(ctx).pop(TypesTiers.fournisseur),
              ),
            ),
          ],
        ),
      ),
    );
    if (type == null || !context.mounted) return;
    if (type == TypesTiers.client) {
      final c = await afficherSelecteur<Client>(
        context,
        titre: l10n.posChoisirClient,
        elements: clients.where((c) => !c.estDePassage).toList(),
        libelle: (c) => c.nom,
        sousLibelle: (c) => c.code,
      );
      if (c == null || !context.mounted) return;
      await afficherNouveauVersement(context, ref, tiersType: TypesTiers.client, tiersCode: c.code, nomTiers: c.nom);
    } else {
      final f = await afficherSelecteur<Fournisseur>(
        context,
        titre: l10n.fournisseursTitre,
        elements: fournisseurs.where((f) => !f.systeme).toList(),
        libelle: (f) => f.nom,
        sousLibelle: (f) => f.code,
      );
      if (f == null || !context.mounted) return;
      await afficherNouveauVersement(
        context,
        ref,
        tiersType: TypesTiers.fournisseur,
        tiersCode: f.code,
        nomTiers: f.nom,
      );
    }
  }
}
