import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/utilisateur.dart';
import '../compte_bens/compte_bens_pages.dart';
import '../compte_bens/ecran_compte.dart';
import '../offres/offres_page.dart';
import '../shell/controles_fenetre.dart';
import '../utilisateurs/utilisateurs_providers.dart';

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

/// Connexion locale (DS v2.2 `LoginScreen`, §4.4) : formulaire à gauche, panneau « nuit » à droite.
/// Elle suit le compte BENS (licence valable sur ce poste) ; les comptes sont ceux de l'application
/// (administrateur, caissiers). Comme les « comptes récents » : les comptes du poste en tuiles, on
/// clique le sien et on tape son mot de passe ; « Autre compte » garde le formulaire (identifiant,
/// ou le numéro du compte BENS pour l'administrateur).
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

  /// Le compte cliqué : on ne demande que son mot de passe.
  Utilisateur? _choisi;

  /// « Autre compte » : le formulaire avec l'identifiant.
  bool _autre = false;

  void _choisir(Utilisateur? u, {bool autre = false}) => setState(() {
    _choisi = u;
    _autre = autre;
    _erreur = null;
    _motDePasse.clear();
  });

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
          .connecter(_choisi?.identifiant ?? _identifiant.text, _motDePasse.text, resterConnecte: _resterConnecte);
    } on ConnexionException catch (e) {
      setState(() {
        _erreur = switch (e.erreur) {
          ErreurConnexion.identifiantsInvalides => l10n.connexionErreurIdentifiants,
          ErreurConnexion.compteInactif => l10n.connexionErreurInactif,
          ErreurConnexion.motDePasseNonDefini => l10n.connexionErreurNonConfigure,
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
    final palier = libelleLicence(l10n, licence);
    final jours = licence.joursRestants(DateTime.now());
    final lus = ref.watch(comptesConnexionProvider);
    final comptes = lus.value ?? const <Utilisateur>[];
    final telephoneBens = licence.compte?.telephone;
    // « Mot de passe oublié » mène à la réinitialisation du compte BENS, sauf pour un caissier choisi.
    final oubliAdmin = telephoneBens != null && telephoneBens.isNotEmpty && (_choisi?.estAdmin ?? true);

    /// Le rôle, et pour l'administrateur le compte BENS de ce poste.
    String detail(Utilisateur u) => [
      libelleRole(context, u.roleNom),
      if (u.estAdmin && telephoneBens != null && telephoneBens.isNotEmpty) l10n.connexionCompteBens(telephoneBens),
    ].where((s) => s.isNotEmpty).join(' · ');
    String nom(Utilisateur u) => u.nomComplet.isNotEmpty ? u.nomComplet : u.identifiant;

    Widget entete(String titre, String sousTitre) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DsSpacing.s2,
      children: [
        Text(titre, style: t.display.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2)),
        Text(sousTitre, style: t.body.copyWith(color: c.textSecondary)),
      ],
    );

    final champMotDePasse = DsTextField(
      key: const ValueKey('connexion_mot_de_passe'),
      controller: _motDePasse,
      focusNode: _focusMotDePasse,
      libelle: l10n.connexionMotDePasse,
      indice: '••••••••',
      aide: _choisi != null && _choisi!.estAdmin && telephoneBens != null ? l10n.connexionMotDePasseBens : null,
      iconePrefixe: LucideIcons.lock,
      taille: DsTailles.controleLg,
      obscur: !_afficher,
      autofocus: _choisi != null,
      erreur: _erreur,
      suffixe: DsIconButton(
        icone: _afficher ? LucideIcons.eyeOff : LucideIcons.eye,
        tooltip: _afficher ? l10n.connexionMasquer : l10n.connexionAfficher,
        taille: DsTailles.controleSm,
        onPressed: () => setState(() => _afficher = !_afficher),
      ),
      onSubmitted: (_) => _connecter(),
    );
    final valider = [
      Row(
        children: [
          DsCheckbox(
            valeur: _resterConnecte,
            libelle: l10n.connexionResterConnecte,
            onChanged: (v) => setState(() => _resterConnecte = v),
          ),
          const Spacer(),
          // L'administrateur (compte BENS) réinitialise son mot de passe avec le code de BENS ; un
          // caissier le demande à l'administrateur.
          if (oubliAdmin)
            Flexible(
              flex: 3,
              child: DsButton(
                key: const ValueKey('connexion_oubli'),
                libelle: l10n.connexionMotDePasseOublie,
                variante: DsButtonVariante.fantome,
                taille: DsButtonTaille.sm,
                onPressed: () => context.push(
                  Uri(
                    path: MotDePasseOubliePage.route,
                    queryParameters: {'telephone': telephoneSaisi(telephoneBens)},
                  ).toString(),
                ),
              ),
            )
          else
            Flexible(
              flex: 3,
              child: Tooltip(
                message: l10n.connexionMotDePasseOublieAide,
                child: Text(
                  l10n.connexionMotDePasseOublie,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(color: c.textMuted),
                ),
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
    ];
    Widget changerCompte(String libelle) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: DsButton(
        key: const ValueKey('connexion_changer_compte'),
        libelle: libelle,
        icone: LucideIcons.users,
        variante: DsButtonVariante.fantome,
        taille: DsButtonTaille.sm,
        onPressed: () => _choisir(null),
      ),
    );

    final List<Widget> etape;
    if (_choisi case final u?) {
      // Le compte cliqué : son mot de passe seulement.
      etape = [
        Row(
          spacing: DsSpacing.s4,
          children: [
            DsAvatar(nom: nom(u), taille: 56),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(nom(u), style: t.display.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2)),
                  Text(detail(u), style: t.bodySm.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        champMotDePasse,
        ...valider,
        changerCompte(l10n.connexionPasVous),
      ];
    } else if (_autre || (lus.hasValue && comptes.isEmpty)) {
      // « Autre compte » : l'identifiant (ou le numéro du compte BENS) et le mot de passe.
      etape = [
        entete(l10n.connexionTitre, l10n.connexionSousTitre),
        DsTextField(
          key: const ValueKey('connexion_identifiant'),
          controller: _identifiant,
          libelle: l10n.connexionIdentifiant,
          aide: telephoneBens == null ? null : l10n.connexionIdentifiantOuTelephone,
          iconePrefixe: LucideIcons.user,
          taille: DsTailles.controleLg,
          autofocus: true,
          onSubmitted: (_) => _focusMotDePasse.requestFocus(),
        ),
        champMotDePasse,
        ...valider,
        if (comptes.isNotEmpty) changerCompte(l10n.connexionVoirComptes),
      ];
    } else {
      // Les comptes du poste : on clique le sien.
      etape = [
        entete(l10n.connexionChoisirCompte, l10n.connexionChoisirSousTitre),
        for (final u in comptes)
          _TuileCompte(
            key: ValueKey('compte_${u.identifiant}'),
            avatar: DsAvatar(nom: nom(u), taille: 44),
            titre: nom(u),
            detail: detail(u),
            onTap: () {
              _choisir(u);
              _focusMotDePasse.requestFocus();
            },
          ),
        _TuileCompte(
          key: const ValueKey('compte_autre'),
          avatar: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c.surfaceSunken, shape: BoxShape.circle),
            child: Icon(LucideIcons.userPlus, size: 20, color: c.textSecondary),
          ),
          titre: l10n.connexionAutreCompte,
          detail: telephoneBens == null ? l10n.connexionIdentifiant : l10n.connexionIdentifiantOuTelephone,
          onTap: () => _choisir(null, autre: true),
        ),
      ];
    }

    final formulaire = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Étroit : le logo sans son nom, pour garder le témoin en ligne, la langue et le thème.
          LayoutBuilder(
            builder: (context, contraintes) => Row(
              spacing: DsSpacing.s2,
              children: [
                DsLogo(taille: 32, afficherTexte: contraintes.maxWidth >= 640),
                const Spacer(),
                DsTemoinLigne(key: const ValueKey('connexion_temoin_ligne'), enLigne: ref.watch(internetProvider)),
                const SelecteurLangue(),
                DsThemeToggle(sombre: sombre, onChanged: (_) => ref.read(themeModeProvider.notifier).basculer()),
              ],
            ),
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
                      ...etape,
                      _Encart(icone: LucideIcons.shieldCheck, couleurIcone: c.success, texte: l10n.connexionHorsLigne),
                      if (licence.lectureSeule)
                        _Encart(
                          key: const ValueKey('encart_lecture_seule'),
                          icone: LucideIcons.lock,
                          couleurIcone: c.dangerFg,
                          texte: l10n.lectureSeuleBandeau(
                            licence.finMotif == null ? '—' : DateFormat('dd/MM/yyyy').format(licence.finMotif!),
                          ),
                          action: DsButton(
                            libelle: l10n.shellVoirFormules,
                            icone: LucideIcons.sparkles,
                            variante: DsButtonVariante.fantome,
                            taille: DsButtonTaille.sm,
                            onPressed: () => context.push(OffresPage.route),
                          ),
                        ),
                      if (licence.essai && licence.niveau != null && jours != null)
                        _Encart(
                          key: const ValueKey('encart_essai'),
                          icone: LucideIcons.hourglass,
                          couleurIcone: c.warningFg,
                          texte: l10n.shellBandeauEssai(libellePalier(l10n, licence.niveau!), jours),
                          action: DsButton(
                            libelle: l10n.shellVoirFormules,
                            icone: LucideIcons.sparkles,
                            variante: DsButtonVariante.fantome,
                            taille: DsButtonTaille.sm,
                            onPressed: () => context.push(OffresPage.route),
                          ),
                        )
                      else if (!licence.lectureSeule)
                        // Les formules à portée de main (mauvais choix, mise à niveau) sans ouvrir l'application.
                        Center(
                          child: DsButton(
                            key: const ValueKey('connexion_offres'),
                            libelle: l10n.compteVoirFormules,
                            icone: LucideIcons.sparkles,
                            variante: DsButtonVariante.fantome,
                            taille: DsButtonTaille.sm,
                            onPressed: () => context.push(OffresPage.route),
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

/// Un compte de la liste (« comptes récents ») : avatar, nom, rôle ; cliqué, on tape son mot de passe.
class _TuileCompte extends StatelessWidget {
  const _TuileCompte({super.key, required this.avatar, required this.titre, required this.detail, required this.onTap});
  final Widget avatar;
  final String titre;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return DsCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        spacing: DsSpacing.s3,
        children: [
          avatar,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  titre,
                  style: t.body.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: t.caption.copyWith(color: c.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: c.textMuted),
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

/// Les animations continues de l'écran (fond, bordure) : arrêtées quand Windows demande moins
/// d'animations, et dans les tests (une animation sans fin empêcherait `pumpAndSettle` de finir).
bool _animationsContinues(BuildContext context) =>
    !MediaQuery.disableAnimationsOf(context) && !Platform.environment.containsKey('FLUTTER_TEST');

/// Panneau de droite : dégradé « nuit » dont la lueur violette dérive lentement, accroche et points
/// forts ; la pastille Smart Scan a une bordure dégradée (vert, bleu clair, violet, rose) qui tourne.
class _PanneauNuit extends StatefulWidget {
  const _PanneauNuit();

  @override
  State<_PanneauNuit> createState() => _PanneauNuitState();
}

class _PanneauNuitState extends State<_PanneauNuit> with SingleTickerProviderStateMixin {
  /// Un tour de la lueur ; la bordure de la pastille en fait 4 (6 s chacun).
  late final AnimationController _temps = AnimationController(vsync: this, duration: const Duration(seconds: 24));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationsContinues(context)) {
      if (!_temps.isAnimating) _temps.repeat();
    } else {
      _temps.stop();
    }
  }

  @override
  void dispose() {
    _temps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        // La lueur : le centre du dégradé « nuit » fait une boucle lente, son rayon respire.
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _temps,
              builder: (context, _) {
                final a = _temps.value * 2 * math.pi;
                final nuit = DsColors.gradientNight;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      center: Alignment(0.6 + 0.35 * math.cos(a), 1.0 + 0.25 * math.sin(a)),
                      radius: 1.1 + 0.08 * math.sin(2 * a),
                      colors: nuit.colors,
                      stops: nuit.stops,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomPaint(
                key: const ValueKey('connexion_pastille_smart_scan'),
                painter: _BordureDegradee(_temps),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: DsColors.blanc.withValues(alpha: .12),
                    borderRadius: DsRadius.borderPill,
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
        ),
      ],
    );
  }
}

/// Bordure qui tourne autour de la pastille : vert, bleu clair, violet, rose, en dégradé.
class _BordureDegradee extends CustomPainter {
  _BordureDegradee(this.temps) : super(repaint: temps);
  final Animation<double> temps;

  static const List<Color> _couleurs = [
    Color(0xFF34D399),
    Color(0xFF7DD3FC),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFF34D399),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const epaisseur = 1.5;
    final rect = Offset.zero & size;
    final contour = RRect.fromRectAndRadius(rect.deflate(epaisseur / 2), Radius.circular(size.height / 2));
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..shader = SweepGradient(
        colors: _couleurs,
        transform: GradientRotation(temps.value * 4 * 2 * math.pi),
      ).createShader(rect);
    canvas.drawRRect(contour, pinceau);
  }

  @override
  bool shouldRepaint(_BordureDegradee old) => old.temps != temps;
}
