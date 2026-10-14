import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../caisse/pos_controller.dart';
import '../caisse/pos_dialogs.dart';
import '../produits/produits_providers.dart';
import '../tiers/tiers_providers.dart';
import 'retour_dialog.dart';

/// Liste des ventes : ticket, annulation, retour, vérification du scellement.
class VentesPage extends ConsumerStatefulWidget {
  const VentesPage({super.key});

  @override
  ConsumerState<VentesPage> createState() => _VentesPageState();
}

class _VentesPageState extends ConsumerState<VentesPage> {
  String _filtre = 'toutes';
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final ventes = ref.watch(ventesProvider).value ?? const [];
    final clients = ref.watch(clientsProvider).value ?? const [];
    final session = ref.watch(sessionProvider);
    final df = DateFormat('dd/MM/yyyy HH:mm');
    String nomClient(String code) => clients.where((c) => c.code == code).firstOrNull?.nom ?? code;
    final r = _recherche.trim().toLowerCase();
    final lignes = ventes.where((v) {
      final okFiltre = switch (_filtre) {
        'validees' => v.statut == StatutsVente.validee,
        'annulees' => v.statut == StatutsVente.annulee,
        'credit' => v.reste > 0 && v.statut == StatutsVente.validee,
        _ => true,
      };
      return okFiltre &&
          (r.isEmpty || v.code.toLowerCase().contains(r) || nomClient(v.clientCode).toLowerCase().contains(r));
    }).toList();
    return DsPage(
      titre: l10n.ventesTitre,
      onRecherche: (v) => setState(() => _recherche = v),
      actions: [
        DsButton(
          libelle: l10n.ventesVerifierChaine,
          icone: LucideIcons.shieldCheck,
          variante: DsButtonVariante.secondaire,
          onPressed: () async {
            final ko = await ref.read(venteServiceProvider).verifierChaine();
            if (!context.mounted) return;
            unawaited(
              afficherResultat(
                context,
                type: ko == null ? DsResultatType.succes : DsResultatType.erreur,
                titre: l10n.ventesVerifierChaine,
                message: ko == null ? l10n.ventesChaineOk : l10n.ventesChaineKo(ko),
              ),
            );
          },
        ),
      ],
      filtres: Row(
        children: [
          for (final (id, lib) in [
            ('toutes', l10n.ventesFiltreToutes),
            ('validees', l10n.ventesFiltreValidees),
            ('annulees', l10n.ventesFiltreAnnulees),
            ('credit', l10n.ventesFiltreCredit),
          ]) ...[
            DsButton(
              libelle: lib,
              taille: DsButtonTaille.sm,
              delaiGarde: Duration.zero,
              variante: _filtre == id ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
              onPressed: () => setState(() => _filtre = id),
            ),
            const SizedBox(width: DsSpacing.xs),
          ],
        ],
      ),
      child: DsDataTable<Vente>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.ventesColTicket, valeur: (v) => v.code, largeur: 100),
          DsColonne(
            id: 'd',
            libelle: l10n.communDate,
            valeur: (v) => v.date,
            largeur: 150,
            cellule: (_, v) => Text(df.format(v.date)),
          ),
          DsColonne(
            id: 'c',
            libelle: l10n.ventesColClient,
            valeur: (v) => nomClient(v.clientCode),
            flex: 2,
            cellule: (_, v) => Text(v.clientCode == 'CLN0000' ? l10n.posClientPassage : nomClient(v.clientCode)),
          ),
          DsColonne(
            id: 'net',
            libelle: l10n.ventesColNet,
            valeur: (v) => v.totalNet,
            numerique: true,
            cellule: (_, v) => Text(formaterMontant(v.totalNet, devise)),
            total: (vs) => formaterMontant(
              vs.where((v) => v.statut == StatutsVente.validee).fold(0.0, (s, v) => s + v.totalNet),
              devise,
            ),
          ),
          DsColonne(
            id: 'v',
            libelle: l10n.ventesColVerse,
            valeur: (v) => v.verse,
            numerique: true,
            cellule: (_, v) => Text(formaterMontant(v.verse, devise)),
          ),
          DsColonne(
            id: 'r',
            libelle: l10n.ventesColReste,
            valeur: (v) => v.reste,
            numerique: true,
            cellule: (_, v) => Text(v.reste > 0 ? formaterMontant(v.reste, devise) : ''),
          ),
          DsColonne(
            id: 's',
            libelle: l10n.ventesColStatut,
            valeur: (v) => v.statut,
            cellule: (_, v) => DsBadge(
              libelle: v.statut == StatutsVente.annulee ? l10n.statutVenteAnnulee : l10n.statutVenteValidee,
              ton: v.statut == StatutsVente.annulee ? DsBadgeTon.danger : DsBadgeTon.succes,
            ),
          ),
          DsColonne(id: 'cs', libelle: l10n.ventesColCaisse, valeur: (v) => v.caisseCode, visibleParDefaut: false),
          DsColonne(id: 'u', libelle: l10n.ventesColVendeur, valeur: (v) => v.utilisateurCode, visibleParDefaut: false),
        ],
        lignes: lignes,
        cle: (v) => v.code,
        afficherTotaux: true,
        messageVide: l10n.ventesAucune,
        onDoubleClic: (v) => _voirTicket(v.code),
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.ventesVoirTicket,
            icone: LucideIcons.receipt,
            onSelected: (v) => _voirTicket(v.code),
          ),
          DsActionContextuelle(
            libelle: l10n.ventesCreerRetour,
            icone: LucideIcons.undo2,
            onSelected: (v) => afficherNouveauRetour(context, ref, venteCode: v.code),
          ),
          if (session?.a(Permission.annulerVente) ?? false)
            DsActionContextuelle(
              libelle: l10n.ventesAnnuler,
              icone: LucideIcons.ban,
              destructif: true,
              onSelected: (v) async {
                if (!await afficherConfirmation(
                  context,
                  titre: l10n.ventesAnnuler,
                  message: l10n.ventesConfirmerAnnulation(v.code),
                  destructif: true,
                )) {
                  return;
                }
                try {
                  await ref.read(venteServiceProvider).annuler(v.code);
                  rafraichirCommerce(ref);
                } on VenteException catch (e) {
                  if (!context.mounted) return;
                  unawaited(
                    afficherResultat(
                      context,
                      type: DsResultatType.erreur,
                      titre: l10n.ventesAnnuler,
                      message: messageErreurVente(l10n, e, devise),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _voirTicket(String code) async {
    final v = await ref.read(venteRepositoryProvider).vente(code);
    if (v == null || !mounted) return;
    await afficherResultatVente(context, ref, v);
  }
}
