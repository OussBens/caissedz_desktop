import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/referentiel/referentiel.dart';

/// Mon compte : identité, changement d'identifiant, de mot de passe, préférences.
class MonComptePage extends ConsumerStatefulWidget {
  const MonComptePage({super.key});

  static const String route = '/mon-compte';

  @override
  ConsumerState<MonComptePage> createState() => _MonComptePageState();
}

class _MonComptePageState extends ConsumerState<MonComptePage> {
  final _nouvelIdentifiant = TextEditingController();
  final _mdpPourIdentifiant = TextEditingController();
  final _mdpActuel = TextEditingController();
  final _mdpNouveau = TextEditingController();
  final _mdpConfirmation = TextEditingController();
  String? _erreurIdentifiant;
  String? _erreurMdpIdentifiant;
  String? _erreurMdpActuel;
  String? _erreurMdpNouveau;
  String? _erreurConfirmation;

  @override
  void dispose() {
    for (final c in [_nouvelIdentifiant, _mdpPourIdentifiant, _mdpActuel, _mdpNouveau, _mdpConfirmation]) {
      c.dispose();
    }
    super.dispose();
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
          .changerIdentifiant(session.utilisateur.code, _nouvelIdentifiant.text, _mdpPourIdentifiant.text);
      ref.read(sessionProvider.notifier).mettreAJourUtilisateur(u);
      _nouvelIdentifiant.clear();
      _mdpPourIdentifiant.clear();
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.compteChangerIdentifiant,
          message: l10n.compteIdentifiantChange(u.identifiant),
        ),
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
      _erreurConfirmation = null;
    });
    if (_mdpNouveau.text != _mdpConfirmation.text) {
      setState(() => _erreurConfirmation = l10n.configErreurConfirmation);
      return;
    }
    try {
      await ref
          .read(authServiceProvider)
          .changerMotDePasse(session.utilisateur.code, _mdpActuel.text, _mdpNouveau.text);
      for (final c in [_mdpActuel, _mdpNouveau, _mdpConfirmation]) {
        c.clear();
      }
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.compteChangerMotDePasse,
          message: l10n.compteMotDePasseChange,
        ),
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
    final demo = session.demo && u.identifiant.toLowerCase() == 'demo';

    return ListView(
      padding: const EdgeInsets.all(DsSpacing.xl),
      children: [
        Text(l10n.compteTitre, style: t.titreLg),
        const SizedBox(height: DsSpacing.lg),
        DsCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: c.primaireDoux,
                child: Text(u.nom.isEmpty ? '?' : u.nom[0].toUpperCase(), style: t.titreLg.copyWith(color: c.primaire)),
              ),
              const SizedBox(width: DsSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.nom, style: t.titreMd),
                    const SizedBox(height: DsSpacing.xxs),
                    Text(
                      '${l10n.compteIdentifiantActuel} : ${u.identifiant}',
                      style: t.corps.copyWith(color: c.texteSecondaire),
                    ),
                    const SizedBox(height: DsSpacing.xs),
                    Row(
                      children: [
                        DsBadge(
                          libelle: '${l10n.compteRole} : ${Referentiel.roles.libelle(u.role, locale)}',
                          ton: DsBadgeTon.primaire,
                          icone: LucideIcons.shield,
                        ),
                        if (session.demo) ...[
                          const SizedBox(width: DsSpacing.sm),
                          DsBadge(libelle: l10n.licenceDemo, ton: DsBadgeTon.avertissement),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.xl),
        if (demo)
          DsCard(
            child: Text(l10n.compteDemoLectureSeule, style: t.corps.copyWith(color: c.texteSecondaire)),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DsSectionTitre(l10n.compteChangerIdentifiant),
                      DsTextField(
                        controller: _nouvelIdentifiant,
                        libelle: l10n.compteNouvelIdentifiant,
                        erreur: _erreurIdentifiant,
                        iconePrefixe: LucideIcons.user,
                      ),
                      const SizedBox(height: DsSpacing.md),
                      DsTextField(
                        controller: _mdpPourIdentifiant,
                        libelle: l10n.compteMotDePasseActuel,
                        obscur: true,
                        erreur: _erreurMdpIdentifiant,
                        iconePrefixe: LucideIcons.lock,
                      ),
                      const SizedBox(height: DsSpacing.lg),
                      DsButton(
                        libelle: l10n.compteChangerIdentifiant,
                        icone: LucideIcons.check,
                        onPressed: _changerIdentifiant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.lg),
              Expanded(
                child: DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DsSectionTitre(l10n.compteChangerMotDePasse),
                      DsTextField(
                        controller: _mdpActuel,
                        libelle: l10n.compteMotDePasseActuel,
                        obscur: true,
                        erreur: _erreurMdpActuel,
                        iconePrefixe: LucideIcons.lock,
                      ),
                      const SizedBox(height: DsSpacing.md),
                      DsTextField(
                        controller: _mdpNouveau,
                        libelle: l10n.compteNouveauMotDePasse,
                        obscur: true,
                        erreur: _erreurMdpNouveau,
                        iconePrefixe: LucideIcons.lockKeyhole,
                      ),
                      const SizedBox(height: DsSpacing.md),
                      DsTextField(
                        controller: _mdpConfirmation,
                        libelle: l10n.configAdminMotDePasseConfirmation,
                        obscur: true,
                        erreur: _erreurConfirmation,
                        iconePrefixe: LucideIcons.lockKeyhole,
                      ),
                      const SizedBox(height: DsSpacing.lg),
                      DsButton(
                        libelle: l10n.compteChangerMotDePasse,
                        icone: LucideIcons.check,
                        onPressed: _changerMotDePasse,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: DsSpacing.xl),
        DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsSectionTitre(l10n.comptePreferences),
              Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(l10n.galerieLangue, style: t.petitFort.copyWith(color: c.texteSecondaire)),
                  ),
                  for (final l in localesSupportees) ...[
                    DsButton(
                      libelle: l.languageCode.toUpperCase(),
                      taille: DsButtonTaille.sm,
                      variante: locale == l ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                      onPressed: () => ref.read(localeProvider.notifier).changer(l),
                    ),
                    const SizedBox(width: DsSpacing.xs),
                  ],
                ],
              ),
              const SizedBox(height: DsSpacing.md),
              Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(l10n.galerieTheme, style: t.petitFort.copyWith(color: c.texteSecondaire)),
                  ),
                  DsButton(
                    libelle: l10n.galerieClair,
                    taille: DsButtonTaille.sm,
                    icone: LucideIcons.sun,
                    variante: mode == ThemeMode.light ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                    onPressed: () => ref.read(themeModeProvider.notifier).changer(ThemeMode.light),
                  ),
                  const SizedBox(width: DsSpacing.xs),
                  DsButton(
                    libelle: l10n.galerieSombre,
                    taille: DsButtonTaille.sm,
                    icone: LucideIcons.moon,
                    variante: mode == ThemeMode.dark ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                    onPressed: () => ref.read(themeModeProvider.notifier).changer(ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
