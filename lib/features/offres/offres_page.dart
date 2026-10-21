import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/demarrage_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/licence/compte_bens_api.dart';
import '../../core/licence/license_config.dart';
import '../../domain/models/licence.dart';
import '../../domain/permissions.dart';
import '../activation/activation_page.dart';
import '../compte_bens/compte_bens_pages.dart';
import '../compte_bens/ecran_compte.dart';
import '../connexion/connexion_page.dart';
import '../shell/controles_fenetre.dart';

/// Libellé d'un palier (Basic, Avancé, Ultra).
String libellePalier(AppLocalizations l10n, NiveauLicence n) => switch (n) {
  NiveauLicence.basic => l10n.licenceBasic,
  NiveauLicence.avance => l10n.licenceAvance,
  NiveauLicence.ultra => l10n.licenceUltra,
};

/// La formule choisie sur l'écran des offres (code `DSK-…`) : gardée en revenant de l'inscription
/// (« Changer de formule »). Null : la formule de la licence, sinon Avancé.
class OffreChoisieNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void choisir(String code) => state = code;
}

final offreChoisieProvider = NotifierProvider<OffreChoisieNotifier, String?>(OffreChoisieNotifier.new);

/// Premier écran (Desktop — Plans & Pricing) : les trois formules, chacune commençant par l'essai
/// gratuit. Sans compte : choisir une formule crée le compte ; « Se connecter » pour un compte
/// existant ; une clé reçue sur WhatsApp en secours. Avec un compte sans formule valable (essai
/// terminé) ou depuis l'application (mise à niveau) : choisir une formule envoie la demande à BENS.
class OffresPage extends ConsumerWidget {
  const OffresPage({super.key});

  static const String route = '/offres';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    final offres =
        ref.watch(offresBensProvider).value ??
        const OffresBens(offres: OffreBens.parDefaut, joursEssai: 14, enLigne: true);
    final compte = licence.compte;
    // Sans compte : l'essai ; avec : la demande d'achat (BENS rappelle).
    final achat = compte != null;
    final jours = offres.joursEssai;
    final date = DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag());
    String? codeDe(NiveauLicence? n) => offres.paliers.where((o) => o.niveau == n).firstOrNull?.code;
    final choisie =
        ref.watch(offreChoisieProvider) ??
        (licence.estActivee ? codeDe(licence.niveau) : null) ??
        codeDe(NiveauLicence.avance);

    String? avis;
    if (!licence.estActivee && licence.motif == MotifLicence.expiree && licence.finMotif != null) {
      avis = l10n.offresEssaiTermine(date.format(licence.finMotif!));
    } else if (!licence.estActivee && compte != null) {
      avis = switch (licence.refusServeur) {
        MotifLicence.invalide => l10n.offresLicenceRefuseeInvalide,
        MotifLicence.autrePoste => l10n.offresLicenceRefuseeAutrePoste,
        MotifLicence.dateReculee => l10n.offresLicenceRefuseeDate,
        _ => l10n.offresSansFormule,
      };
    }

    return Scaffold(
      backgroundColor: c.surfaceApp,
      body: Column(
        children: [
          const BandeauFenetre(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8, vertical: DsSpacing.s6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DsSpacing.s5,
                    children: [
                      Row(
                        spacing: DsSpacing.s3,
                        children: [
                          const DsLogo(taille: 32),
                          const Spacer(),
                          if (licence.estActivee && context.canPop())
                            DsButton(
                              libelle: l10n.communFermer,
                              icone: LucideIcons.x,
                              variante: DsButtonVariante.fantome,
                              onPressed: () => context.pop(),
                            ),
                          const SelecteurLangue(),
                        ],
                      ),
                      Column(
                        spacing: DsSpacing.s2,
                        children: [
                          Text(
                            l10n.offresTitre,
                            textAlign: TextAlign.center,
                            style: t.display.copyWith(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                          Text(
                            l10n.offresSousTitre(jours),
                            textAlign: TextAlign.center,
                            style: t.body.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                      if (avis != null)
                        Container(
                          key: const ValueKey('offres_avis'),
                          padding: const EdgeInsets.all(DsSpacing.s4),
                          decoration: BoxDecoration(color: c.warningTint, borderRadius: DsRadius.borderLg),
                          child: Row(
                            spacing: DsSpacing.s3,
                            children: [
                              Icon(LucideIcons.hourglass, size: 18, color: c.warningFg),
                              Expanded(
                                child: Text(avis, style: t.bodySm.copyWith(color: c.warningFg, height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                      if (!offres.enLigne && !achat)
                        Text(
                          l10n.offresHorsLigne,
                          textAlign: TextAlign.center,
                          style: t.caption.copyWith(color: c.textMuted),
                        ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: DsSpacing.s4,
                          children: [
                            for (final o in offres.paliers)
                              Expanded(
                                child: _CarteFormule(
                                  offre: o,
                                  offres: offres,
                                  licence: licence,
                                  achat: achat,
                                  choisie: o.code == choisie,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: DsSpacing.s4,
                        runSpacing: DsSpacing.s2,
                        children: [
                          if (compte == null) ...[
                            Text(l10n.offresDejaCompte, style: t.bodySm.copyWith(color: c.textSecondary)),
                            DsButton(
                              key: const ValueKey('offres_se_connecter'),
                              libelle: l10n.offresSeConnecter,
                              icone: LucideIcons.logIn,
                              variante: DsButtonVariante.secondaire,
                              onPressed: () => context.push(ConnexionComptePage.route),
                            ),
                          ] else if (!licence.estActivee) ...[
                            // Payé auprès de BENS : le check-in apporte la licence, puis la connexion.
                            DsButton(
                              key: const ValueKey('offres_actualiser'),
                              libelle: l10n.dsPosActualiser,
                              icone: LucideIcons.refreshCw,
                              variante: DsButtonVariante.secondaire,
                              onPressed: () async {
                                await ref.read(licenceProvider.notifier).synchroniser();
                                if (context.mounted && ref.read(licenceProvider).estActivee) {
                                  context.go(ConnexionPage.route);
                                }
                              },
                            ),
                            DsButton(
                              libelle: l10n.offresSeDeconnecter,
                              icone: LucideIcons.userRoundCog,
                              variante: DsButtonVariante.fantome,
                              onPressed: () => ref.read(licenceProvider.notifier).deconnecterCompte(),
                            ),
                          ],
                          DsButton(
                            key: const ValueKey('offres_cle'),
                            libelle: l10n.offresJaiUneCle,
                            icone: LucideIcons.keyRound,
                            variante: DsButtonVariante.fantome,
                            onPressed: () => context.push(ActivationPage.route),
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

class _CarteFormule extends ConsumerWidget {
  const _CarteFormule({
    required this.offre,
    required this.offres,
    required this.licence,
    required this.achat,
    required this.choisie,
  });

  final OffreBens offre;
  final OffresBens offres;
  final Licence licence;
  final bool achat;

  /// La formule sélectionnée (un clic sur la carte la sélectionne).
  final bool choisie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final niveau = offre.niveau!;
    final nom = libellePalier(l10n, niveau);
    final actuel = licence.estActivee && !licence.essai && licence.niveau == niveau;
    final inclus = licence.estActivee && !licence.essai && (licence.niveau?.couvre(niveau) ?? false);
    // Un palier déjà acheté : la mise à niveau (la différence) plutôt que le palier entier.
    final code = licence.estActivee && !licence.essai && licence.niveau != null
        ? OffreBens.codeMiseANiveau(licence.niveau!, niveau) ?? offre.code
        : offre.code;
    final prix = offres.offre(code)?.prixDzd ?? offre.prixDzd;
    // Desktop — Plans & Pricing : chaque formule ne montre que ce qu'elle a. Basic : le socle ; Advanced et
    // Ultra : « Tout <palier précédent>, plus : » et ce qu'ils ajoutent. Puis les limites et les scans.
    final precedent = niveau == NiveauLicence.basic ? null : NiveauLicence.values[niveau.index - 1];
    final atouts = [
      ...switch (niveau) {
        NiveauLicence.basic => [
          l10n.offresAtoutPdv,
          l10n.offresAtoutVentes,
          l10n.offresAtoutStock,
          l10n.offresAtoutTiers,
          l10n.offresAtoutGestionCaisse,
          l10n.offresAtoutRapports,
        ],
        NiveauLicence.avance => [
          l10n.offresAtoutDevis,
          l10n.offresAtoutCommandesClients,
          l10n.offresAtoutAchats,
          l10n.offresAtoutBesoins,
        ],
        NiveauLicence.ultra => [l10n.offresAtoutMultiMagasin, l10n.offresAtoutTransferts, l10n.offresTout],
      },
      l10n.offresMagasins(niveau.magasins),
      l10n.offresCaisses(niveau.caisses),
      if (offre.scans != null) l10n.offresScans(offre.scans!, offre.mois ?? 3),
    ];
    final ideal = switch (niveau) {
      NiveauLicence.basic => l10n.offresIdealBasic,
      NiveauLicence.avance => l10n.offresIdealAvance,
      NiveauLicence.ultra => l10n.offresIdealUltra,
    };
    void choisir() => ref.read(offreChoisieProvider.notifier).choisir(offre.code);

    // Un clic sur la carte la sélectionne ; son bouton la sélectionne et continue.
    return Semantics(
      selected: choisie,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: choisir,
          child: AnimatedContainer(
            key: ValueKey('formule_${offre.code}'),
            duration: DsMotion.fast,
            curve: DsMotion.standard,
            // 1 px de plus sans sélection : le contenu ne bouge pas quand la bordure passe à 2 px.
            padding: EdgeInsets.all(DsSpacing.s5 + (choisie ? 0 : 1)),
            decoration: BoxDecoration(
              color: c.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: choisie ? c.primary : c.borderDefault, width: choisie ? 2 : 1),
              boxShadow: choisie ? c.shadowMd : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s3,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DsSpacing.s2,
                  children: [
                    // Le badge passe sous le nom quand la carte est étroite.
                    Expanded(
                      child: Wrap(
                        spacing: DsSpacing.s2,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              if (niveau == NiveauLicence.ultra)
                                Icon(LucideIcons.sparkles, size: 16, color: c.iconActive),
                              Text(nom, style: t.heading.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          if (actuel)
                            DsBadge(libelle: l10n.licenceNiveau(nom), ton: DsBadgeTon.succes, point: true)
                          else if (!achat)
                            DsBadge(libelle: l10n.offresEssaiGratuit(offres.joursEssai), ton: DsBadgeTon.primaire),
                        ],
                      ),
                    ),
                    // La sélection, comme un bouton radio.
                    Tooltip(
                      message: choisie ? l10n.offresSelectionnee : l10n.offresSelectionner,
                      child: Icon(
                        choisie ? LucideIcons.circleCheck : LucideIcons.circle,
                        key: ValueKey('formule_coche_${offre.code}'),
                        size: 22,
                        color: choisie ? c.primary : c.borderStrong,
                      ),
                    ),
                  ],
                ),
                Text(ideal, style: t.bodySm.copyWith(color: c.textSecondary, height: 1.4)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      prix == null ? '—' : l10n.offresPrix(formaterNombre(prix.toDouble())),
                      style: t.display.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    Text(l10n.offresPaiementUnique, style: t.caption.copyWith(color: c.textMuted)),
                  ],
                ),
                Divider(color: c.borderSubtle, height: 1),
                if (precedent != null)
                  Text(
                    l10n.offresToutPlus(libellePalier(l10n, precedent)),
                    key: ValueKey('formule_inclut_${offre.code}'),
                    style: t.bodySmStrong.copyWith(color: c.textPrimary),
                  ),
                for (final a in atouts)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(LucideIcons.check, size: 14, color: c.success),
                      ),
                      Expanded(
                        child: Text(a, style: t.bodySm.copyWith(color: c.textBody)),
                      ),
                    ],
                  ),
                const Spacer(),
                DsButton(
                  key: ValueKey('choisir_${offre.code}'),
                  libelle: achat ? l10n.offresChoisir(nom) : l10n.offresEssayer(offres.joursEssai),
                  iconeDroite: LucideIcons.arrowRight,
                  variante: choisie ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                  taille: DsButtonTaille.lg,
                  pleineLargeur: true,
                  onPressed: inclus
                      ? null
                      : () {
                          choisir();
                          if (achat) {
                            _demander(context, ref, code, nom);
                          } else {
                            context.push('${InscriptionPage.route}?offre=${offre.code}');
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Demande d'achat (BENS rappelle), avec WhatsApp en plus.
  Future<void> _demander(BuildContext context, WidgetRef ref, String code, String nom) async {
    final l10n = AppLocalizations.of(context);
    final telephone = licence.compte?.telephone ?? '';
    try {
      await ref.read(licenceServiceProvider).demanderOffre(code);
    } on CompteBensException catch (e) {
      if (e.erreur == ErreurCompteBens.deconnecte) await ref.read(licenceProvider.notifier).synchroniser();
      if (!context.mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.offresChoisir(nom),
        message: messageErreurCompte(l10n, e),
      );
      return;
    }
    if (!context.mounted) return;
    await afficherResultat(
      context,
      type: DsResultatType.succes,
      titre: l10n.offresDemandeTitre,
      message: l10n.offresDemandeDetail(telephone, nom),
      action: DsButton(
        libelle: l10n.offresWhatsApp,
        icone: LucideIcons.messageCircle,
        variante: DsButtonVariante.secondaire,
        onPressed: () => launchUrl(
          Uri.parse(
            'https://wa.me/$bensWhatsApp?text=${Uri.encodeComponent(l10n.offresWhatsAppMessage(nom, telephone))}',
          ),
          mode: LaunchMode.externalApplication,
        ),
      ),
    );
  }
}
