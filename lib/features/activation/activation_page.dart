import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/licence_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/licence/cle_activation.dart';
import '../../domain/permissions.dart';
import '../connexion/connexion_page.dart';
import '../shell/controles_fenetre.dart';

/// Activation (DS v2.2 `ActivationScreen`, §4.3) : identifiant du poste à copier, clé SHA-256 de
/// 64 caractères (8 groupes de 8), palier détecté, comparaison Basic / Avancé.
class ActivationPage extends ConsumerStatefulWidget {
  const ActivationPage({super.key});

  static const String route = '/activation';

  @override
  ConsumerState<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends ConsumerState<ActivationPage> {
  String _cle = '';
  String _machine = '';
  bool _copie = false;
  bool _erreur = false;

  static const int _longueur = 64;

  @override
  void initState() {
    super.initState();
    ref.read(licenceServiceProvider).identifiantMachine().then((v) {
      if (mounted) setState(() => _machine = v);
    });
  }

  NiveauLicence? get _palier =>
      _cle.length == _longueur ? ref.read(licenceServiceProvider).cles.resoudre(_cle, _machine) : null;

  Future<void> _activer() async {
    final l10n = AppLocalizations.of(context);
    try {
      final licence = await ref.read(licenceProvider.notifier).activer(_cle);
      if (!mounted) return;
      final niveau = licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic;
      await afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.activationReussieTitre,
        message: l10n.activationReussieDetail(niveau, _machine),
        libelleAction: l10n.activationContinuer,
      );
      if (mounted) _retour();
    } on ActivationException {
      setState(() => _erreur = true);
    }
  }

  void _retour() => context.canPop() ? context.pop() : context.go(ConnexionPage.route);

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    final complete = _cle.length == _longueur;
    final palier = _palier;
    final invalide = _erreur || (complete && palier == null);
    final (badge, ton) = !licence.estActivee
        ? (l10n.activationNonActivee, DsBadgeTon.avertissement)
        : licence.demo
        ? (l10n.licenceDemo, DsBadgeTon.avertissement)
        : (
            l10n.licenceNiveau(licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic),
            DsBadgeTon.succes,
          );

    return Scaffold(
      backgroundColor: c.surfaceApp,
      body: Column(
        children: [
          const BandeauFenetre(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DsSpacing.s6),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  padding: const EdgeInsets.all(DsSpacing.s8),
                  decoration: BoxDecoration(
                    color: c.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.borderDefault),
                    boxShadow: c.shadowMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: DsSpacing.s5,
                    children: [
                      Row(
                        spacing: DsSpacing.s3,
                        children: [
                          const DsLogo(taille: 32),
                          const Spacer(),
                          const SelecteurLangue(),
                          DsBadge(libelle: badge, ton: ton, point: true),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(
                            l10n.activationTitre,
                            style: t.display.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                          Text(l10n.activationIntro, style: t.body.copyWith(color: c.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderLg),
                        child: Row(
                          spacing: DsSpacing.s3,
                          children: [
                            Icon(LucideIcons.monitor, size: 18, color: c.iconDefault),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.activationIdentifiantMachine,
                                    style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                                  ),
                                  SelectableText(
                                    _machine,
                                    key: const ValueKey('identifiant_poste'),
                                    style: t.mono.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.3,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DsButton(
                              libelle: _copie ? l10n.activationIdentifiantCopie : l10n.activationCopierIdentifiant,
                              icone: _copie ? LucideIcons.check : LucideIcons.copy,
                              variante: DsButtonVariante.secondaire,
                              taille: DsButtonTaille.sm,
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: _machine));
                                if (!mounted) return;
                                setState(() => _copie = true);
                                await Future<void>.delayed(const Duration(milliseconds: 1500));
                                if (mounted) setState(() => _copie = false);
                              },
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: DsSpacing.s2,
                        children: [
                          Text(
                            l10n.activationCle,
                            style: t.bodySm.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary),
                          ),
                          DsKeyInput(
                            key: const ValueKey('cle_activation'),
                            groupes: 8,
                            tailleGroupe: 8,
                            valeur: _cle,
                            erreur: invalide,
                            onChanged: (v) => setState(() {
                              _cle = v;
                              _erreur = false;
                            }),
                          ),
                          Text(
                            invalide
                                ? l10n.activationErreurInconnue
                                : palier != null
                                ? l10n.activationPalierDetecte(
                                    palier == NiveauLicence.basic
                                        ? l10n.activationPalierBasic
                                        : l10n.activationPalierAvance,
                                  )
                                : l10n.activationCleIndice,
                            style: t.caption.copyWith(color: invalide ? c.dangerFg : c.textMuted),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          for (final (niveau, libelle, atouts) in [
                            (
                              NiveauLicence.basic,
                              l10n.licenceBasic,
                              [l10n.activationUnMagasin, l10n.activationUneCaisse, l10n.activationSmartScanQuota],
                            ),
                            (
                              NiveauLicence.avance,
                              l10n.licenceAvance,
                              [
                                l10n.activationMagasinsIllimites,
                                l10n.activationPlusieursCaisses,
                                l10n.activationSmartScanQuota,
                              ],
                            ),
                          ])
                            Expanded(
                              child: _CartePalier(
                                libelle: libelle,
                                atouts: atouts,
                                avance: niveau == NiveauLicence.avance,
                                selectionne: palier == niveau,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: DsSpacing.s2,
                        children: [
                          DsButton(
                            libelle: licence.estActivee && !licence.demo
                                ? l10n.communFermer
                                : l10n.activationRetourConnexion,
                            icone: LucideIcons.arrowLeft,
                            variante: DsButtonVariante.fantome,
                            onPressed: _retour,
                          ),
                          DsButton(
                            key: const ValueKey('bouton_activer'),
                            libelle: l10n.activationBouton,
                            icone: LucideIcons.keyRound,
                            taille: DsButtonTaille.lg,
                            onPressed: complete && CleActivation.formatValide(_cle) ? _activer : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartePalier extends StatelessWidget {
  const _CartePalier({required this.libelle, required this.atouts, required this.avance, required this.selectionne});
  final String libelle;
  final List<String> atouts;
  final bool avance;
  final bool selectionne;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return AnimatedContainer(
      duration: DsMotion.base,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selectionne ? c.primaryTint : c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: selectionne ? c.primary : c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 6,
            children: [
              if (avance) Icon(LucideIcons.sparkles, size: 14, color: c.iconActive),
              Text(libelle, style: t.bodyStrong.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          for (final a in atouts)
            Row(
              spacing: 6,
              children: [
                Icon(LucideIcons.check, size: 12, color: c.success),
                Expanded(
                  child: Text(a, style: t.bodySm.copyWith(fontSize: 12.5, color: c.textSecondary)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
