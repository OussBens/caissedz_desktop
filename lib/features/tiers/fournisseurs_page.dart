import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/tiers_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/retour.dart';
import '../../domain/models/tiers.dart';
import '../produits/produits_providers.dart';
import 'tiers_providers.dart';
import 'versement_dialog.dart';

/// Fournisseurs : liste, fiche, règlements.
class FournisseursPage extends ConsumerStatefulWidget {
  const FournisseursPage({super.key});

  @override
  ConsumerState<FournisseursPage> createState() => _FournisseursPageState();
}

class _FournisseursPageState extends ConsumerState<FournisseursPage> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final fournisseurs = ref.watch(fournisseursProvider).value ?? const [];
    final r = _recherche.trim().toLowerCase();
    final lignes = fournisseurs
        .where((f) => r.isEmpty || f.nom.toLowerCase().contains(r) || f.code.toLowerCase().contains(r))
        .toList();
    return DsPage(
      titre: l10n.fournisseursTitre,
      onRecherche: (v) => setState(() => _recherche = v),
      actions: [
        DsButton(
          libelle: l10n.fournisseurNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            afficherFormulaireFournisseur(context, ref);
          },
        ),
      ],
      child: DsDataTable<Fournisseur>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (f) => f.code, largeur: 100),
          DsColonne(id: 'nom', libelle: l10n.clientNom, valeur: (f) => f.nom, flex: 3),
          DsColonne(id: 'tel', libelle: l10n.clientTelephone, valeur: (f) => f.telephone, flex: 2),
          DsColonne(id: 'email', libelle: l10n.clientEmail, valeur: (f) => f.email, flex: 2, visibleParDefaut: false),
          DsColonne(
            id: 'solde',
            libelle: l10n.clientSolde,
            valeur: (f) => f.code,
            numerique: true,
            triable: false,
            cellule: (_, f) => _SoldeF(code: f.code, devise: devise),
          ),
          DsColonne(
            id: 'a',
            libelle: l10n.communActif,
            valeur: (f) => f.actif ? 1 : 0,
            largeur: 90,
            cellule: (_, f) => DsBadge(
              libelle: f.actif ? l10n.communActif : l10n.communInactif,
              ton: f.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
            ),
          ),
        ],
        lignes: lignes,
        cle: (f) => f.code,
        messageVide: l10n.fournisseurAucun,
        onDoubleClic: (f) => afficherFormulaireFournisseur(context, ref, fournisseur: f),
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            onSelected: (f) => afficherFormulaireFournisseur(context, ref, fournisseur: f),
          ),
          DsActionContextuelle(
            libelle: l10n.fournisseurNouveauVersement,
            icone: LucideIcons.handCoins,
            onSelected: (f) => afficherNouveauVersement(
              context,
              ref,
              tiersType: TypesTiers.fournisseur,
              tiersCode: f.code,
              nomTiers: f.nom,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoldeF extends ConsumerWidget {
  const _SoldeF({required this.code, required this.devise});
  final String code;
  final String devise;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final solde = ref.watch(soldeFournisseurProvider(code)).value ?? 0;
    return Text(
      formaterMontant(solde, devise),
      style: context.ds.typo.corps.copyWith(color: solde > 0 ? c.danger : c.texte),
    );
  }
}

Future<void> afficherFormulaireFournisseur(BuildContext context, WidgetRef ref, {Fournisseur? fournisseur}) async {
  final l10n = AppLocalizations.of(context);
  final nom = TextEditingController(text: fournisseur?.nom ?? '');
  final tel = TextEditingController(text: fournisseur?.telephone ?? '');
  final adresse = TextEditingController(text: fournisseur?.adresse ?? '');
  final email = TextEditingController(text: fournisseur?.email ?? '');
  var actif = fournisseur?.actif ?? true;
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: fournisseur == null ? l10n.fournisseurNouveau : l10n.communModifier,
        largeur: 520,
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(libelle: l10n.communEnregistrer, onPressed: () => Navigator.of(ctx).pop(true)),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsTextField(controller: nom, libelle: l10n.clientNom, autofocus: true),
            const SizedBox(height: DsSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DsTextField(controller: tel, libelle: l10n.clientTelephone),
                ),
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: DsTextField(controller: email, libelle: l10n.clientEmail),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.md),
            DsTextField(controller: adresse, libelle: l10n.clientAdresse),
            if (fournisseur != null)
              DsSwitch(valeur: actif, libelle: l10n.communActif, onChanged: (v) => setState(() => actif = v)),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final f = Fournisseur(
    code: fournisseur?.code ?? '',
    nom: nom.text,
    telephone: tel.text,
    adresse: adresse.text,
    email: email.text,
    actif: actif,
    systeme: fournisseur?.systeme ?? false,
  );
  try {
    final s = ref.read(tiersServiceProvider);
    if (fournisseur == null) {
      await s.creerFournisseur(f);
    } else {
      await s.modifierFournisseur(f);
    }
    rafraichirCommerce(ref);
  } on TiersException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.fournisseursTitre,
        message: messageErreurTiers(l10n, e.erreur),
      ),
    );
  }
}
