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

/// Clients : liste, fiche (solde, documents ouverts), versements.
class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devise = ref.watch(deviseProvider);
    final clients = ref.watch(clientsProvider).value ?? const [];
    final r = _recherche.trim().toLowerCase();
    final lignes = clients
        .where(
          (c) =>
              r.isEmpty ||
              c.nom.toLowerCase().contains(r) ||
              c.code.toLowerCase().contains(r) ||
              c.telephone.contains(r),
        )
        .toList();
    return DsPage(
      titre: l10n.clientsTitre,
      onRecherche: (v) => setState(() => _recherche = v),
      actions: [
        DsButton(
          libelle: l10n.clientNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            afficherFormulaireClient(context, ref);
          },
        ),
      ],
      child: DsDataTable<Client>(
        colonnes: [
          DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (c) => c.code, largeur: 100),
          DsColonne(
            id: 'nom',
            libelle: l10n.clientNom,
            valeur: (c) => c.nom,
            flex: 3,
            cellule: (_, c) => Text(c.estDePassage ? l10n.posClientPassage : c.nom),
          ),
          DsColonne(id: 'tel', libelle: l10n.clientTelephone, valeur: (c) => c.telephone, flex: 2),
          DsColonne(id: 'pts', libelle: l10n.clientPoints, valeur: (c) => c.points, numerique: true),
          DsColonne(
            id: 'plafond',
            libelle: l10n.clientPlafond,
            valeur: (c) => c.plafondCredit,
            numerique: true,
            cellule: (_, c) => Text(formaterMontant(c.plafondCredit, devise)),
          ),
          DsColonne(
            id: 'solde',
            libelle: l10n.clientSolde,
            valeur: (c) => c.code,
            numerique: true,
            triable: false,
            cellule: (_, c) => _Solde(code: c.code, devise: devise),
          ),
          DsColonne(
            id: 'a',
            libelle: l10n.communActif,
            valeur: (c) => c.actif ? 1 : 0,
            largeur: 90,
            cellule: (_, c) => DsBadge(
              libelle: c.actif ? l10n.communActif : l10n.communInactif,
              ton: c.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
            ),
          ),
        ],
        lignes: lignes,
        cle: (c) => c.code,
        messageVide: l10n.clientAucun,
        onDoubleClic: (c) => afficherFicheClient(context, ref, c),
        actionsContextuelles: [
          DsActionContextuelle(
            libelle: l10n.clientFiche,
            icone: LucideIcons.idCard,
            onSelected: (c) => afficherFicheClient(context, ref, c),
          ),
          DsActionContextuelle(
            libelle: l10n.communModifier,
            icone: LucideIcons.pencil,
            onSelected: (c) => afficherFormulaireClient(context, ref, client: c),
          ),
          DsActionContextuelle(
            libelle: l10n.clientNouveauVersement,
            icone: LucideIcons.handCoins,
            onSelected: (c) => afficherNouveauVersement(
              context,
              ref,
              tiersType: TypesTiers.client,
              tiersCode: c.code,
              nomTiers: c.nom,
            ),
          ),
        ],
      ),
    );
  }
}

class _Solde extends ConsumerWidget {
  const _Solde({required this.code, required this.devise});
  final String code;
  final String devise;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final solde = ref.watch(soldeClientProvider(code)).value ?? 0;
    return Text(
      formaterMontant(solde, devise),
      style: context.ds.typo.corps.copyWith(color: solde > 0 ? c.danger : (solde < 0 ? c.info : c.texte)),
    );
  }
}

Future<void> afficherFormulaireClient(BuildContext context, WidgetRef ref, {Client? client}) async {
  final l10n = AppLocalizations.of(context);
  final nom = TextEditingController(text: client?.nom ?? '');
  final tel = TextEditingController(text: client?.telephone ?? '');
  final adresse = TextEditingController(text: client?.adresse ?? '');
  final email = TextEditingController(text: client?.email ?? '');
  final plafond = TextEditingController(text: (client?.plafondCredit ?? 0).toString());
  var actif = client?.actif ?? true;
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: client == null ? l10n.clientNouveau : l10n.communModifier,
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
            const SizedBox(height: DsSpacing.md),
            DsTextField(controller: plafond, libelle: l10n.clientPlafond, typeClavier: TextInputType.number),
            if (client != null)
              DsSwitch(valeur: actif, libelle: l10n.communActif, onChanged: (v) => setState(() => actif = v)),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final c = Client(
    code: client?.code ?? '',
    nom: nom.text,
    telephone: tel.text,
    adresse: adresse.text,
    email: email.text,
    plafondCredit: double.tryParse(plafond.text.replaceAll(',', '.')) ?? 0,
    actif: actif,
    points: client?.points ?? 0,
    systeme: client?.systeme ?? false,
  );
  try {
    final s = ref.read(tiersServiceProvider);
    if (client == null) {
      await s.creerClient(c);
    } else {
      await s.modifierClient(c);
    }
    rafraichirCommerce(ref);
  } on TiersException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.clientsTitre,
        message: messageErreurTiers(l10n, e.erreur),
      ),
    );
  }
}

/// Fiche client : solde, documents ouverts, versements.
Future<void> afficherFicheClient(BuildContext context, WidgetRef ref, Client client) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final repo = ref.read(tiersRepositoryProvider);
  final docs = await repo.documentsOuvertsClient(client.code);
  final versements = await repo.versements(tiersType: TypesTiers.client, tiersCode: client.code);
  final solde = await repo.soldeClient(client.code);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        titre: '${l10n.clientFiche} — ${client.nom}',
        largeur: 640,
        icone: Icon(LucideIcons.idCard, color: c.primaire),
        actions: [
          DsButton(
            libelle: l10n.clientNouveauVersement,
            icone: LucideIcons.handCoins,
            variante: DsButtonVariante.secondaire,
            onPressed: () {
              Navigator.of(ctx).pop();
              afficherNouveauVersement(
                context,
                ref,
                tiersType: TypesTiers.client,
                tiersCode: client.code,
                nomTiers: client.nom,
              );
            },
          ),
          DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop()),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DsStatCard(
                    libelle: l10n.clientSolde,
                    valeur: formaterMontant(solde, devise),
                    icone: LucideIcons.wallet,
                    ton: solde > 0 ? DsBadgeTon.danger : DsBadgeTon.succes,
                  ),
                ),
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: DsStatCard(
                    libelle: l10n.clientPoints,
                    valeur: '${client.points}',
                    icone: LucideIcons.star,
                    ton: DsBadgeTon.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(l10n.clientDocumentsOuverts, style: t.titreSm),
            if (docs.isEmpty) Text(l10n.communAucune, style: t.petit.copyWith(color: c.texteAttenue)),
            for (final d in docs)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${d.code} · ${d.date.day.toString().padLeft(2, '0')}/${d.date.month.toString().padLeft(2, '0')}/${d.date.year}',
                      style: t.petit,
                    ),
                  ),
                  Text('${formaterMontant(d.reste, devise)} / ${formaterMontant(d.total, devise)}', style: t.petitFort),
                ],
              ),
            const SizedBox(height: DsSpacing.lg),
            Text(l10n.clientVersements, style: t.titreSm),
            if (versements.isEmpty) Text(l10n.communAucune, style: t.petit.copyWith(color: c.texteAttenue)),
            for (final v in versements.take(10))
              Row(
                children: [
                  if (v.verrouille) Icon(LucideIcons.lock, size: 12, color: c.texteAttenue),
                  Expanded(
                    child: Text(
                      ' ${v.code} · ${v.mode}${v.retourCode == null ? '' : ' · ${v.retourCode}'}',
                      style: t.petit,
                    ),
                  ),
                  Text(
                    '${v.sens == SensVersement.decaissement ? '−' : ''}${formaterMontant(v.montant, devise)}',
                    style: t.petitFort,
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
