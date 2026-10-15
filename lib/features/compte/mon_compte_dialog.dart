import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/referentiel/referentiel.dart';

/// Ouvre Mon compte (DS `MonCompteDialog`, §5.4).
Future<void> afficherMonCompte(BuildContext context) =>
    afficherDialog<void>(context, builder: (_) => const MonCompteDialog());

enum _Onglet { profil, motDePasse, preferences }

/// Mon compte : profil (identifiant, magasin), mot de passe (ancien / nouveau / confirmation),
/// préférences (langue, thème), déconnexion. Le compte démo est en lecture seule.
class MonCompteDialog extends ConsumerStatefulWidget {
  const MonCompteDialog({super.key});

  @override
  ConsumerState<MonCompteDialog> createState() => _MonCompteDialogState();
}

class _MonCompteDialogState extends ConsumerState<MonCompteDialog> {
  _Onglet _onglet = _Onglet.profil;
  late final _identifiant = TextEditingController(text: ref.read(sessionProvider)?.utilisateur.identifiant ?? '');
  final _mdpIdentifiant = TextEditingController();
  final _mdpActuel = TextEditingController();
  final _mdpNouveau = TextEditingController();
  final _mdpConfirmation = TextEditingController();
  String? _erreurIdentifiant;
  String? _erreurMdpIdentifiant;
  String? _erreurMdpActuel;
  String? _erreurMdpNouveau;

  List<TextEditingController> get _champs => [_identifiant, _mdpIdentifiant, _mdpActuel, _mdpNouveau, _mdpConfirmation];

  @override
  void initState() {
    super.initState();
    for (final c in _champs) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _champs) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _discordance => _mdpConfirmation.text.isNotEmpty && _mdpNouveau.text != _mdpConfirmation.text;

  bool _peutEnregistrer(String identifiantActuel) => switch (_onglet) {
    _Onglet.profil => _identifiant.text.trim().isNotEmpty && _identifiant.text.trim() != identifiantActuel,
    _Onglet.motDePasse => _mdpActuel.text.isNotEmpty && _mdpNouveau.text.isNotEmpty && !_discordance,
    _Onglet.preferences => true,
  };

  Future<void> _enregistrer() async {
    switch (_onglet) {
      case _Onglet.profil:
        await _changerIdentifiant();
      case _Onglet.motDePasse:
        await _changerMotDePasse();
      case _Onglet.preferences:
        Navigator.of(context).pop();
    }
  }

  Future<void> _changerIdentifiant() async {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider)!;
    setState(() {
      _erreurIdentifiant = null;
      _erreurMdpIdentifiant = null;
    });
    try {
      final u = await ref
          .read(authServiceProvider)
          .changerIdentifiant(session.utilisateur.code, _identifiant.text, _mdpIdentifiant.text);
      ref.read(sessionProvider.notifier).mettreAJourUtilisateur(u);
      _mdpIdentifiant.clear();
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.compteChangerIdentifiant,
        message: l10n.compteIdentifiantChange(u.identifiant),
      );
    } on CompteException catch (e) {
      setState(() {
        switch (e.erreur) {
          case ErreurCompte.motDePasseActuelIncorrect:
            _erreurMdpIdentifiant = l10n.compteErreurMotDePasseActuel;
          case ErreurCompte.identifiantPris:
            _erreurIdentifiant = l10n.configErreurIdentifiantPris;
          default:
            _erreurIdentifiant = l10n.configErreurIdentifiant;
        }
      });
    }
  }

  Future<void> _changerMotDePasse() async {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider)!;
    setState(() {
      _erreurMdpActuel = null;
      _erreurMdpNouveau = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .changerMotDePasse(session.utilisateur.code, _mdpActuel.text, _mdpNouveau.text);
      for (final c in [_mdpActuel, _mdpNouveau, _mdpConfirmation]) {
        c.clear();
      }
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.compteChangerMotDePasse,
        message: l10n.compteMotDePasseChange,
      );
    } on CompteException catch (e) {
      setState(() {
        if (e.erreur == ErreurCompte.motDePasseActuelIncorrect) {
          _erreurMdpActuel = l10n.compteErreurMotDePasseActuel;
        } else {
          _erreurMdpNouveau = l10n.configErreurMotDePasseCourt;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    if (session == null) return const SizedBox.shrink();
    final u = session.utilisateur;
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final magasin = ref.watch(magasinCourantProvider).magasinCourant;
    final demo = session.demo && AuthService.estIdentifiantDemo(u.identifiant);
    final acces = u.dernierAcces == null
        ? l10n.compteJamaisConnecte
        : DateFormat('dd/MM/yyyy HH:mm', locale.languageCode).format(u.dernierAcces!);

    Widget formulaire(List<Widget> champs) =>
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: champs);

    return DsDialog(
      key: const ValueKey('dialog_mon_compte'),
      titre: l10n.compteTitre,
      iconeData: LucideIcons.user,
      largeur: 640,
      piedDebut: DsButton(
        key: const ValueKey('compte_deconnexion'),
        libelle: l10n.connexionDeconnecter,
        icone: LucideIcons.logOut,
        variante: DsButtonVariante.fantome,
        onPressed: () async {
          Navigator.of(context).pop();
          await ref.read(sessionProvider.notifier).deconnecter();
        },
      ),
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (!demo || _onglet == _Onglet.preferences)
          DsButton(
            key: const ValueKey('compte_enregistrer'),
            libelle: l10n.communEnregistrer,
            icone: LucideIcons.check,
            onPressed: _peutEnregistrer(u.identifiant) ? _enregistrer : null,
          ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            spacing: 14,
            children: [
              DsAvatar(nom: u.nom, taille: 52),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.nom, style: t.bodyStrong.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(l10n.compteIdentite(u.identifiant, acces), style: t.bodySm.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              if (session.demo) DsBadge(libelle: l10n.licenceDemo, ton: DsBadgeTon.avertissement),
              DsBadge(
                libelle: Referentiel.roles.libelle(u.role, locale),
                ton: DsBadgeTon.primaire,
                icone: LucideIcons.shield,
              ),
            ],
          ),
          DsSegmentedControl<_Onglet>(
            pleineLargeur: true,
            options: [
              DsOption(_Onglet.profil, libelle: l10n.compteOngletProfil, icone: LucideIcons.user),
              DsOption(_Onglet.motDePasse, libelle: l10n.compteOngletMotDePasse, icone: LucideIcons.keyRound),
              DsOption(_Onglet.preferences, libelle: l10n.comptePreferences, icone: LucideIcons.slidersHorizontal),
            ],
            valeur: _onglet,
            onChanged: (v) => setState(() => _onglet = v),
          ),
          if (demo && _onglet != _Onglet.preferences)
            Text(l10n.compteDemoLectureSeule, style: t.body.copyWith(color: c.textSecondary))
          else
            switch (_onglet) {
              _Onglet.profil => formulaire([
                DsFormRow(
                  libelle: l10n.compteIdentifiant,
                  obligatoire: true,
                  erreur: _erreurIdentifiant,
                  child: DsTextField(
                    key: const ValueKey('compte_identifiant'),
                    controller: _identifiant,
                    iconePrefixe: LucideIcons.user,
                  ),
                ),
                if (_identifiant.text.trim() != u.identifiant)
                  DsFormRow(
                    libelle: l10n.compteMotDePasseActuel,
                    obligatoire: true,
                    erreur: _erreurMdpIdentifiant,
                    child: DsTextField(
                      key: const ValueKey('compte_mdp_identifiant'),
                      controller: _mdpIdentifiant,
                      obscur: true,
                      iconePrefixe: LucideIcons.lock,
                    ),
                  ),
                DsFormRow(
                  libelle: l10n.compteCode,
                  child: DsTextField(valeurInitiale: u.code, actif: false),
                ),
                DsFormRow(
                  libelle: l10n.compteMagasinDefaut,
                  child: DsTextField(valeurInitiale: magasin?.nom ?? '—', actif: false),
                ),
              ]),
              _Onglet.motDePasse => formulaire([
                DsFormRow(
                  libelle: l10n.compteMotDePasseActuel,
                  obligatoire: true,
                  erreur: _erreurMdpActuel,
                  child: DsTextField(
                    key: const ValueKey('compte_mdp_actuel'),
                    controller: _mdpActuel,
                    obscur: true,
                    iconePrefixe: LucideIcons.lock,
                  ),
                ),
                DsFormRow(
                  libelle: l10n.compteNouveauMotDePasse,
                  obligatoire: true,
                  aide: l10n.compteMotDePasseAide(AuthService.longueurMinMotDePasse),
                  erreur: _erreurMdpNouveau,
                  child: DsTextField(
                    key: const ValueKey('compte_mdp_nouveau'),
                    controller: _mdpNouveau,
                    obscur: true,
                    iconePrefixe: LucideIcons.keyRound,
                  ),
                ),
                DsFormRow(
                  libelle: l10n.compteConfirmer,
                  obligatoire: true,
                  erreur: _discordance ? l10n.configErreurConfirmation : null,
                  child: DsTextField(
                    key: const ValueKey('compte_mdp_confirmation'),
                    controller: _mdpConfirmation,
                    obscur: true,
                    iconePrefixe: LucideIcons.keyRound,
                  ),
                ),
              ]),
              _Onglet.preferences => formulaire([
                DsFormRow(
                  libelle: l10n.configLangue,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DsSegmentedControl<String>(
                      options: const [
                        DsOption('fr', libelle: 'Français'),
                        DsOption('en', libelle: 'English'),
                        DsOption('ar', libelle: 'العربية'),
                      ],
                      valeur: locale.languageCode,
                      onChanged: (v) => ref.read(localeProvider.notifier).changer(Locale(v)),
                    ),
                  ),
                ),
                DsFormRow(
                  libelle: l10n.galerieTheme,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DsSegmentedControl<ThemeMode>(
                      options: [
                        DsOption(ThemeMode.light, libelle: l10n.galerieClair, icone: LucideIcons.sun),
                        DsOption(ThemeMode.dark, libelle: l10n.galerieSombre, icone: LucideIcons.moon),
                      ],
                      valeur: mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
                      onChanged: (v) => ref.read(themeModeProvider.notifier).changer(v),
                    ),
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Icon(LucideIcons.info, size: 14, color: c.textMuted),
                    Expanded(
                      child: Text(l10n.comptePreferencesAide, style: t.bodySm.copyWith(color: c.textMuted)),
                    ),
                  ],
                ),
              ]),
            },
        ],
      ),
    );
  }
}
