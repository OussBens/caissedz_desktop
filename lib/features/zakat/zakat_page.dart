import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/parametres_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/zakat.dart';
import '../gestion_caisse/gestion_caisse_providers.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

final zakatProvider = FutureProvider<ResultatZakat>((ref) async {
  ref.watch(rapportsVersionProvider);
  ref.watch(commerceVersionProvider);
  ref.watch(stockVersionProvider);
  ref.watch(caisseVersionProvider);
  final stats = ref.watch(statistiquesRepositoryProvider);
  return CalculZakat.calculer(
    stock: await stats.valeurStockAchat(),
    caisses: await stats.soldeCaisses(),
    creances: await stats.creancesClients(),
    dettes: await stats.dettesFournisseurs(),
    prixGrammeOr: await ref.watch(parametresServiceProvider).lirePrixGrammeOr(),
  );
});

/// Zakat sur les biens commerciaux : assiette, nissab (85 g d'or au cours saisi), taux 2,5 %.
class ZakatPage extends ConsumerStatefulWidget {
  const ZakatPage({super.key});

  @override
  ConsumerState<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends ConsumerState<ZakatPage> {
  final _prix = TextEditingController();
  bool _initialise = false;

  @override
  void dispose() {
    _prix.dispose();
    super.dispose();
  }

  Future<void> _enregistrerPrix() async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(parametresServiceProvider)
          .enregistrerPrixGrammeOr(double.tryParse(_prix.text.replaceAll(',', '.')) ?? -1);
      rafraichirRapports(ref);
    } on ParametresException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.zakatTitre,
          message: messageErreurParametres(l10n, e.erreur),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final devise = ref.watch(deviseProvider);
    final r = ref.watch(zakatProvider).value;
    if (r != null && !_initialise) {
      _initialise = true;
      _prix.text = r.prixGrammeOr > 0 ? r.prixGrammeOr.toStringAsFixed(0) : '';
    }
    String m(double? v) => v == null ? '—' : formaterMontant(v, devise);
    return DsPage(
      titre: l10n.zakatTitre,
      defilable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.zakatIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 260,
                child: DsTextField(
                  controller: _prix,
                  libelle: l10n.zakatPrixOr(devise),
                  typeClavier: TextInputType.number,
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              DsButton(
                libelle: l10n.zakatEnregistrerPrix,
                icone: LucideIcons.save,
                onPressed: () {
                  _enregistrerPrix();
                },
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          Wrap(
            spacing: DsSpacing.md,
            runSpacing: DsSpacing.md,
            children: [
              for (final (libelle, valeur, icone, ton) in [
                (l10n.zakatStock, m(r?.stock), LucideIcons.package, DsBadgeTon.info),
                (l10n.zakatCaisses, m(r?.caisses), LucideIcons.wallet, DsBadgeTon.info),
                (l10n.zakatCreances, m(r?.creances), LucideIcons.handCoins, DsBadgeTon.succes),
                (l10n.zakatDettes, m(r?.dettes), LucideIcons.minusCircle, DsBadgeTon.danger),
              ])
                SizedBox(
                  width: 240,
                  child: DsStatCard(libelle: libelle, valeur: valeur, icone: icone, ton: ton),
                ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          Wrap(
            spacing: DsSpacing.md,
            runSpacing: DsSpacing.md,
            children: [
              SizedBox(
                width: 320,
                child: DsStatCard(libelle: l10n.zakatAssiette, valeur: m(r?.assiette), icone: LucideIcons.sigma),
              ),
              SizedBox(
                width: 320,
                child: DsStatCard(
                  libelle: l10n.zakatNissab,
                  valeur: r == null || r.prixGrammeOr <= 0 ? '—' : m(r.nissab),
                  icone: LucideIcons.gem,
                  ton: DsBadgeTon.avertissement,
                ),
              ),
              SizedBox(
                width: 320,
                child: DsStatCard(
                  libelle: l10n.zakatMontant,
                  valeur: m(r?.montant),
                  icone: LucideIcons.heartHandshake,
                  ton: (r?.assujetti ?? false) ? DsBadgeTon.succes : DsBadgeTon.neutre,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.lg),
          if (r != null)
            DsBadge(
              libelle: r.prixGrammeOr <= 0
                  ? l10n.zakatPrixManquant
                  : r.assujetti
                  ? l10n.zakatAssujetti
                  : l10n.zakatNonAssujetti,
              ton: r.prixGrammeOr <= 0
                  ? DsBadgeTon.avertissement
                  : r.assujetti
                  ? DsBadgeTon.succes
                  : DsBadgeTon.neutre,
              icone: r.assujetti ? LucideIcons.circleCheck : LucideIcons.info,
            ),
        ],
      ),
    );
  }
}
