import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/licence/compte_bens_api.dart';
import '../connexion/connexion_page.dart';
import '../offres/offres_page.dart';
import '../shell/controles_fenetre.dart';

/// Écran du compte BENS hors shell : barre de fenêtre, carte centrée (logo, langue, [enTete]), [child].
class EcranCompte extends StatelessWidget {
  const EcranCompte({super.key, required this.child, this.largeur = 480, this.enTete});

  final Widget child;
  final double largeur;

  /// Sous le logo et la langue (un badge d'état).
  final Widget? enTete;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
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
                  constraints: BoxConstraints(maxWidth: largeur),
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
                      const Row(spacing: DsSpacing.s3, children: [DsLogo(taille: 32), Spacer(), SelecteurLangue()]),
                      if (enTete != null) Align(alignment: AlignmentDirectional.centerStart, child: enTete),
                      child,
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

/// Titre et sous-titre d'un écran du compte.
class TitreCompte extends StatelessWidget {
  const TitreCompte({super.key, required this.titre, this.sousTitre});

  final String titre;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(titre, style: t.display.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
        if (sousTitre != null) Text(sousTitre!, style: t.body.copyWith(color: c.textSecondary)),
      ],
    );
  }
}

/// Le message d'une erreur du compte BENS.
String messageErreurCompte(AppLocalizations l10n, CompteBensException e) => switch (e.erreur) {
  ErreurCompteBens.reseau => l10n.compteErrReseau,
  ErreurCompteBens.identifiants => l10n.compteErrIdentifiants,
  ErreurCompteBens.numeroPris => l10n.compteErrNumeroPris,
  ErreurCompteBens.aucunCompte => l10n.compteErrAucunCompte,
  ErreurCompteBens.codeInvalide => l10n.compteErrCode,
  ErreurCompteBens.tropDEssais => l10n.compteErrTropDEssais,
  ErreurCompteBens.deconnecte => l10n.compteErrIdentifiants,
  ErreurCompteBens.saisie => switch (e.champ) {
    'phone' => l10n.compteErrTelephone,
    'name' => l10n.compteErrNom,
    'password' => l10n.compteErrMotDePasse,
    _ => l10n.compteErrServeur,
  },
  ErreurCompteBens.serveur => l10n.compteErrServeur,
};

/// Un numéro mobile algérien de 10 chiffres, avec le zéro : `0555123456` (05, 06 ou 07).
bool telephoneValide(String saisi) => RegExp(r'^0[5-7]\d{8}$').hasMatch(saisi.trim());

/// Le numéro du compte BENS gardé (`+213555123456`) tel qu'on le tape : `0555123456`.
String telephoneSaisi(String? e164) {
  if (e164 == null) return '';
  return e164.startsWith('+213') ? '0${e164.substring(4)}' : e164;
}

/// Numéro du compte BENS : 10 chiffres au plus, toujours de gauche à droite (même en arabe).
class ChampTelephone extends StatelessWidget {
  const ChampTelephone({
    super.key,
    required this.controller,
    this.erreur,
    this.autofocus = false,
    this.lectureSeule = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? erreur;
  final bool autofocus;
  final bool lectureSeule;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => DsTextField(
    controller: controller,
    libelle: AppLocalizations.of(context).compteTelephone,
    indice: '0555123456',
    iconePrefixe: LucideIcons.phone,
    typeClavier: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
    erreur: erreur,
    autofocus: autofocus,
    lectureSeule: lectureSeule,
    onSubmitted: onSubmitted,
  );
}

/// Après l'inscription, la connexion ou la réinitialisation du compte BENS : l'administrateur prend le
/// mot de passe du compte (poste neuf ; toujours après une [reinitialisation]), puis sans formule
/// valable les offres ; sinon sa session s'ouvre, ou la connexion habituelle s'il était déjà configuré.
Future<void> apresConnexionCompte(
  BuildContext context,
  WidgetRef ref, {
  required String nom,
  required String motDePasse,
  bool reinitialisation = false,
}) async {
  final ouverte = await ref
      .read(sessionProvider.notifier)
      .apresCompteBens(nom: nom, motDePasse: motDePasse, reinitialisation: reinitialisation);
  if (!context.mounted) return;
  if (!ref.read(licenceProvider).estActivee) {
    context.go(OffresPage.route);
    return;
  }
  context.go(ouverte ? routeAccueil : ConnexionPage.route);
}
