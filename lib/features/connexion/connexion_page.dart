import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/permissions.dart';
import '../activation/activation_page.dart';
import '../shell/controles_fenetre.dart';

/// Sélecteur de langue FR / EN / AR des écrans hors shell.
class SelecteurLangue extends ConsumerWidget {
  const SelecteurLangue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return DsSegmentedControl<String>(
      petit: true,
      options: const [
        DsOption('fr', libelle: 'FR'),
        DsOption('en', libelle: 'EN'),
        DsOption('ar', libelle: 'AR'),
      ],
      valeur: locale.languageCode,
      onChanged: (v) => ref.read(localeProvider.notifier).changer(Locale(v)),
    );
  }
}

/// Connexion (DS v2.2 `LoginScreen`, §4.4) : formulaire à gauche, panneau « nuit » à droite.
/// Application non activée : seul demo / demo est accepté et active le mode démo (§4.3).
class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});

  static const String route = '/connexion';

  /// Version affichée au pied de l'écran.
  static const String version = '1.2.0';

  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  final _identifiant = TextEditingController();
  final _motDePasse = TextEditingController();
  final _focusMotDePasse = FocusNode();
  String? _erreur;
  bool _afficher = false;
  bool _resterConnecte = true;

  @override
  void dispose() {
    _identifiant.dispose();
    _motDePasse.dispose();
    _focusMotDePasse.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _erreur = null);
    try {
      await ref
          .read(sessionProvider.notifier)
          .connecter(_identifiant.text, _motDePasse.text, resterConnecte: _resterConnecte);
    } on ConnexionException catch (e) {
      setState(() {
        _erreur = switch (e.erreur) {
          ErreurConnexion.identifiantsInvalides => l10n.connexionErreurIdentifiants,
          ErreurConnexion.compteInactif => l10n.connexionErreurInactif,
          ErreurConnexion.motDePasseNonDefini => l10n.connexionErreurNonConfigure,
          ErreurConnexion.demoIndisponible => l10n.connexionErreurDemo,
          ErreurConnexion.nonActivee => l10n.connexionErreurNonActivee,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    final sombre = ref.watch(themeModeProvider) == ThemeMode.dark;
    final palier = !licence.estActivee
        ? l10n.connexionNonActivee
        : licence.demo
        ? l10n.licenceDemo
        : l10n.licenceNiveau(licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic);

    final formulaire = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: DsSpacing.s2,
            children: [
              const DsLogo(taille: 32),
              const Spacer(),
              const SelecteurLangue(),
              DsThemeToggle(sombre: sombre, onChanged: (_) => ref.read(themeModeProvider.notifier).basculer()),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: DsSpacing.s5,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: DsSpacing.s2,
                        children: [
                          Text(
                            l10n.connexionTitre,
                            style: t.display.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                          Text(l10n.connexionSousTitre, style: t.body.copyWith(color: c.textSecondary)),
                        ],
                      ),
                      DsTextField(
                        controller: _identifiant,
                        libelle: l10n.connexionIdentifiant,
                        iconePrefixe: LucideIcons.user,
                        taille: DsTailles.controleLg,
                        autofocus: true,
                        onSubmitted: (_) => _focusMotDePasse.requestFocus(),
                      ),
                      DsTextField(
                        controller: _motDePasse,
                        focusNode: _focusMotDePasse,
                        libelle: l10n.connexionMotDePasse,
                        indice: '••••••••',
                        iconePrefixe: LucideIcons.lock,
                        taille: DsTailles.controleLg,
                        obscur: !_afficher,
                        erreur: _erreur,
                        suffixe: DsIconButton(
                          icone: _afficher ? LucideIcons.eyeOff : LucideIcons.eye,
                          tooltip: _afficher ? l10n.connexionMasquer : l10n.connexionAfficher,
                          taille: DsTailles.controleSm,
                          onPressed: () => setState(() => _afficher = !_afficher),
                        ),
                        onSubmitted: (_) => _connecter(),
                      ),
                      Row(
                        children: [
                          DsCheckbox(
                            valeur: _resterConnecte,
                            libelle: l10n.connexionResterConnecte,
                            onChanged: (v) => setState(() => _resterConnecte = v),
                          ),
                          const Spacer(),
                          Flexible(
                            flex: 3,
                            child: Text(
                              l10n.connexionMotDePasseOublie,
                              textAlign: TextAlign.end,
                              style: t.caption.copyWith(color: c.textMuted),
                            ),
                          ),
                        ],
                      ),
                      DsButton(
                        key: const ValueKey('bouton_connexion'),
                        libelle: l10n.connexionBouton,
                        iconeDroite: LucideIcons.arrowRight,
                        taille: DsButtonTaille.lg,
                        pleineLargeur: true,
                        onPressed: _connecter,
                      ),
                      _Encart(icone: LucideIcons.shieldCheck, couleurIcone: c.success, texte: l10n.connexionHorsLigne),
                      if (!licence.estActivee || licence.demo)
                        _Encart(
                          key: const ValueKey('encart_demo'),
                          icone: LucideIcons.flaskConical,
                          couleurIcone: c.warningFg,
                          texte: licence.estActivee ? l10n.connexionDemoIndice : l10n.connexionDemoNonActivee,
                          action: DsButton(
                            libelle: l10n.connexionSaisirCle,
                            icone: LucideIcons.keyRound,
                            variante: DsButtonVariante.fantome,
                            taille: DsButtonTaille.sm,
                            onPressed: () => context.push(ActivationPage.route),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.connexionVersion(ConnexionPage.version, palier),
                  style: t.caption.copyWith(color: c.textMuted),
                ),
              ),
              Text('© 2026 CaisseDZ', style: t.caption.copyWith(color: c.textMuted)),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.surfaceCard,
      body: Column(
        children: [
          const BandeauFenetre(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, contraintes) => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 100, child: formulaire),
                  if (contraintes.maxWidth >= 900)
                    const Expanded(
                      flex: 105,
                      child: Padding(padding: EdgeInsets.all(12), child: _PanneauNuit()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encart extends StatelessWidget {
  const _Encart({super.key, required this.icone, required this.couleurIcone, required this.texte, this.action});
  final IconData icone;
  final Color couleurIcone;
  final String texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s2,
        children: [
          Row(
            spacing: DsSpacing.s2,
            children: [
              Icon(icone, size: 16, color: couleurIcone),
              Expanded(
                child: Text(texte, style: t.caption.copyWith(height: 1.4, color: c.textSecondary)),
              ),
            ],
          ),
          if (action != null) Align(alignment: AlignmentDirectional.centerEnd, child: action),
        ],
      ),
    );
  }
}

/// Panneau de droite : dégradé « nuit », accroche et points forts.
class _PanneauNuit extends StatelessWidget {
  const _PanneauNuit();

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(gradient: DsColors.gradientNight, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: DsColors.blanc.withValues(alpha: .12),
              borderRadius: DsRadius.borderPill,
              border: Border.all(color: DsColors.blanc.withValues(alpha: .18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                const Icon(LucideIcons.sparkles, size: 14, color: DsColors.blanc),
                Text(
                  l10n.connexionNouveaute,
                  style: t.caption.copyWith(fontWeight: FontWeight.w600, color: DsColors.blanc),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const DsLogo(taille: 44, inverse: true),
                Text(
                  l10n.connexionAccroche,
                  style: t.display.copyWith(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: DsColors.blanc,
                  ),
                ),
                Text(
                  l10n.connexionAccrocheDetail,
                  style: t.body.copyWith(fontSize: 15, height: 1.6, color: DsColors.violet200),
                ),
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    for (final (icone, libelle) in [
                      (LucideIcons.wifiOff, l10n.connexionAtoutHorsLigne),
                      (LucideIcons.store, l10n.connexionAtoutMultiMagasin),
                      (LucideIcons.languages, 'FR · AR · EN'),
                    ])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Icon(icone, size: 16, color: DsColors.violet300),
                          Text(
                            libelle,
                            style: t.bodySm.copyWith(
                              fontWeight: FontWeight.w500,
                              color: DsColors.blanc.withValues(alpha: .85),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
