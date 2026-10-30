import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/demarrage_providers.dart';
import '../../application/licence_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/licence/compte_bens_api.dart';
import '../../core/licence/license_config.dart';
import '../../domain/models/licence.dart';
import '../../domain/permissions.dart';
import '../offres/offres_page.dart';
import 'ecran_compte.dart';

/// Champ de mot de passe avec Afficher / Masquer.
class _ChampMotDePasse extends StatefulWidget {
  const _ChampMotDePasse({
    required this.controller,
    required this.libelle,
    this.aide,
    this.erreur,
    this.onSubmitted,
    this.cle,
    this.focusNode,
  });

  final TextEditingController controller;
  final String libelle;
  final String? aide;
  final String? erreur;
  final ValueChanged<String>? onSubmitted;
  final Key? cle;
  final FocusNode? focusNode;

  @override
  State<_ChampMotDePasse> createState() => _ChampMotDePasseState();
}

class _ChampMotDePasseState extends State<_ChampMotDePasse> {
  bool _afficher = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsTextField(
      key: widget.cle,
      controller: widget.controller,
      focusNode: widget.focusNode,
      libelle: widget.libelle,
      aide: widget.aide,
      erreur: widget.erreur,
      iconePrefixe: LucideIcons.lock,
      obscur: !_afficher,
      onSubmitted: widget.onSubmitted,
      suffixe: DsIconButton(
        icone: _afficher ? LucideIcons.eyeOff : LucideIcons.eye,
        tooltip: _afficher ? l10n.connexionMasquer : l10n.connexionAfficher,
        taille: DsTailles.controleSm,
        onPressed: () => setState(() => _afficher = !_afficher),
      ),
    );
  }
}

/// Erreur générale d'un formulaire du compte (serveur, réseau).
class _Erreur extends StatelessWidget {
  const _Erreur(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      key: const ValueKey('compte_erreur'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.dangerTint, borderRadius: DsRadius.borderLg),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: c.dangerFg),
          Expanded(
            child: Text(texte, style: t.bodySm.copyWith(color: c.dangerFg)),
          ),
        ],
      ),
    );
  }
}

// ======================================================================= Inscription

/// Création du compte BENS avec la formule choisie : nom, commerce, téléphone, mot de passe. L'essai
/// de la formule commence ; sur un poste neuf, l'administrateur prend ce mot de passe et s'ouvre.
class InscriptionPage extends ConsumerStatefulWidget {
  const InscriptionPage({super.key, this.offre});

  static const String route = '/compte/creer';

  /// Code de la formule choisie (`DSK-ADV`) ; absent : Advanced.
  final String? offre;

  @override
  ConsumerState<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends ConsumerState<InscriptionPage> {
  final _nom = TextEditingController();
  final _commerce = TextEditingController();
  final _telephone = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();
  String? _erreurNom, _erreurTelephone, _erreurMotDePasse, _erreurConfirmation, _erreur;
  bool _envoi = false;

  @override
  void dispose() {
    for (final c in [_nom, _commerce, _telephone, _motDePasse, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _creer(OffreBens offre) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _erreurNom = _nom.text.trim().length < 2 ? l10n.compteErrNom : null;
      _erreurTelephone = telephoneValide(_telephone.text) ? null : l10n.compteErrTelephone;
      _erreurMotDePasse = _motDePasse.text.length < 8 ? l10n.compteErrMotDePasse : null;
      _erreurConfirmation = _confirmation.text != _motDePasse.text ? l10n.compteErrConfirmation : null;
      _erreur = null;
    });
    if ([_erreurNom, _erreurTelephone, _erreurMotDePasse, _erreurConfirmation].any((e) => e != null)) return;
    setState(() => _envoi = true);
    try {
      final essai = await ref
          .read(licenceProvider.notifier)
          .inscrire(
            telephone: _telephone.text,
            nom: _nom.text,
            commerce: _commerce.text,
            motDePasse: _motDePasse.text,
            offre: offre.code,
          );
      if (!mounted) return;
      if (!essai && !ref.read(licenceProvider).estActivee) {
        await afficherResultat(
          context,
          type: DsResultatType.avertissement,
          titre: l10n.compteCreerTitre,
          message: l10n.compteEssaiDejaUtilise,
        );
        if (!mounted) return;
      }
      await apresConnexionCompte(context, ref, nom: _nom.text, motDePasse: _motDePasse.text);
    } on CompteBensException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.erreur == ErreurCompteBens.saisie && e.champ == 'phone') {
          _erreurTelephone = l10n.compteErrTelephone;
        } else if (e.erreur == ErreurCompteBens.numeroPris) {
          _erreurTelephone = l10n.compteErrNumeroPris;
        } else {
          _erreur = messageErreurCompte(l10n, e);
        }
      });
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final offres =
        ref.watch(offresBensProvider).value ??
        const OffresBens(offres: OffreBens.parDefaut, joursEssai: 14, enLigne: true);
    final offre =
        offres.paliers.where((o) => o.code == widget.offre).firstOrNull ??
        offres.paliers.where((o) => o.niveau == NiveauLicence.avance).firstOrNull ??
        OffreBens.parDefaut[1];
    final nom = libellePalier(l10n, offre.niveau ?? NiveauLicence.avance);
    return EcranCompte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          TitreCompte(titre: l10n.compteCreerTitre),
          // La formule sur une ligne, l'essai dessous ; « Changer de formule » centré en face.
          Container(
            key: const ValueKey('inscription_formule'),
            padding: const EdgeInsetsDirectional.only(start: 14, end: 6, top: 10, bottom: 10),
            decoration: BoxDecoration(color: c.primaryTint, borderRadius: DsRadius.borderLg),
            child: Row(
              spacing: DsSpacing.s3,
              children: [
                Icon(LucideIcons.sparkles, size: 18, color: c.primaryTintFg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(l10n.compteFormule(nom), style: t.bodySmStrong.copyWith(color: c.primaryTintFg)),
                      Text(
                        l10n.offresEssaiGratuit(offres.joursEssai),
                        style: t.caption.copyWith(color: c.primaryTintFg),
                      ),
                    ],
                  ),
                ),
                DsButton(
                  libelle: l10n.compteChangerFormule,
                  variante: DsButtonVariante.fantome,
                  taille: DsButtonTaille.sm,
                  onPressed: () => context.canPop() ? context.pop() : context.go(OffresPage.route),
                ),
              ],
            ),
          ),
          DsTextField(
            key: const ValueKey('inscription_nom'),
            controller: _nom,
            libelle: l10n.compteNom,
            iconePrefixe: LucideIcons.user,
            erreur: _erreurNom,
            autofocus: true,
          ),
          DsTextField(
            key: const ValueKey('inscription_commerce'),
            controller: _commerce,
            libelle: l10n.compteCommerce,
            indice: l10n.compteFacultatif,
            iconePrefixe: LucideIcons.store,
          ),
          ChampTelephone(
            key: const ValueKey('inscription_telephone'),
            controller: _telephone,
            erreur: _erreurTelephone,
          ),
          _ChampMotDePasse(
            cle: const ValueKey('inscription_mot_de_passe'),
            controller: _motDePasse,
            libelle: l10n.compteMotDePasse,
            aide: l10n.compteBensMotDePasseAide,
            erreur: _erreurMotDePasse,
          ),
          _ChampMotDePasse(
            cle: const ValueKey('inscription_confirmation'),
            controller: _confirmation,
            libelle: l10n.compteBensConfirmer,
            erreur: _erreurConfirmation,
            onSubmitted: (_) => _creer(offre),
          ),
          if (_erreur != null) _Erreur(_erreur!),
          DsButton(
            key: const ValueKey('inscription_creer'),
            libelle: l10n.compteCreerBouton,
            iconeDroite: _envoi ? null : LucideIcons.arrowRight,
            taille: DsButtonTaille.lg,
            pleineLargeur: true,
            onPressed: _envoi ? null : () => _creer(offre),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DsSpacing.s2,
            children: [
              Text(l10n.offresDejaCompte, style: t.bodySm.copyWith(color: c.textSecondary)),
              DsButton(
                libelle: l10n.offresSeConnecter,
                variante: DsButtonVariante.fantome,
                taille: DsButtonTaille.sm,
                onPressed: () => context.pushReplacement(ConnexionComptePage.route),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================= Connexion au compte

/// Connexion au compte BENS sur ce poste (la licence y est déplacée s'il était sur un autre poste).
class ConnexionComptePage extends ConsumerStatefulWidget {
  const ConnexionComptePage({super.key});

  static const String route = '/compte/connexion';

  @override
  ConsumerState<ConnexionComptePage> createState() => _ConnexionComptePageState();
}

class _ConnexionComptePageState extends ConsumerState<ConnexionComptePage> {
  final _telephone = TextEditingController();
  final _motDePasse = TextEditingController();
  final _focusMotDePasse = FocusNode();
  String? _erreurTelephone, _erreur;
  bool _envoi = false;

  @override
  void dispose() {
    _telephone.dispose();
    _motDePasse.dispose();
    _focusMotDePasse.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _erreurTelephone = telephoneValide(_telephone.text) ? null : l10n.compteErrTelephone;
      _erreur = null;
    });
    if (_erreurTelephone != null) return;
    setState(() => _envoi = true);
    try {
      await ref
          .read(licenceProvider.notifier)
          .connecterCompte(telephone: _telephone.text, motDePasse: _motDePasse.text);
      if (!mounted) return;
      await apresConnexionCompte(context, ref, nom: '', motDePasse: _motDePasse.text);
    } on CompteBensException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCompte(l10n, e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return EcranCompte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          TitreCompte(titre: l10n.compteConnexionTitre, sousTitre: l10n.compteConnexionSousTitre),
          ChampTelephone(
            key: const ValueKey('compte_telephone'),
            controller: _telephone,
            erreur: _erreurTelephone,
            autofocus: true,
            onSubmitted: (_) => _focusMotDePasse.requestFocus(),
          ),
          _ChampMotDePasse(
            cle: const ValueKey('compte_mot_de_passe'),
            controller: _motDePasse,
            focusNode: _focusMotDePasse,
            libelle: l10n.compteMotDePasse,
            onSubmitted: (_) => _connecter(),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DsButton(
              key: const ValueKey('compte_oubli'),
              libelle: l10n.compteMotDePasseOublie,
              variante: DsButtonVariante.fantome,
              taille: DsButtonTaille.sm,
              onPressed: () => context.push(MotDePasseOubliePage.route),
            ),
          ),
          if (_erreur != null) _Erreur(_erreur!),
          DsButton(
            key: const ValueKey('compte_connecter'),
            libelle: l10n.compteConnexionBouton,
            iconeDroite: _envoi ? null : LucideIcons.arrowRight,
            taille: DsButtonTaille.lg,
            pleineLargeur: true,
            onPressed: _envoi ? null : _connecter,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DsSpacing.s2,
            children: [
              Text(l10n.comptePasEncore, style: t.bodySm.copyWith(color: c.textSecondary)),
              DsButton(
                libelle: l10n.compteVoirFormules,
                variante: DsButtonVariante.fantome,
                taille: DsButtonTaille.sm,
                onPressed: () => context.canPop() ? context.pop() : context.go(OffresPage.route),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================= Mot de passe oublié

/// Mot de passe oublié : un code de récupération à envoyer à BENS (WhatsApp), puis le code de
/// réinitialisation reçu et le nouveau mot de passe.
class MotDePasseOubliePage extends ConsumerStatefulWidget {
  const MotDePasseOubliePage({super.key, this.telephone});

  static const String route = '/compte/oubli';

  /// Numéro pré-rempli (depuis l'écran de connexion : celui du compte BENS du poste).
  final String? telephone;

  @override
  ConsumerState<MotDePasseOubliePage> createState() => _MotDePasseOubliePageState();
}

class _MotDePasseOubliePageState extends ConsumerState<MotDePasseOubliePage> {
  late final _telephone = TextEditingController(text: widget.telephone);
  final _code = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();
  String? _recuperation;
  bool _saisieCode = false;
  bool _copie = false;
  bool _envoi = false;
  String? _erreurTelephone, _erreurMotDePasse, _erreurConfirmation, _erreur;

  @override
  void dispose() {
    for (final c in [_telephone, _code, _motDePasse, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _telephoneOk(AppLocalizations l10n) {
    setState(() {
      _erreurTelephone = telephoneValide(_telephone.text) ? null : l10n.compteErrTelephone;
      _erreur = null;
    });
    return _erreurTelephone == null;
  }

  Future<void> _demander() async {
    final l10n = AppLocalizations.of(context);
    if (!_telephoneOk(l10n)) return;
    setState(() => _envoi = true);
    try {
      final code = await ref.read(licenceServiceProvider).demanderRecuperation(_telephone.text);
      if (mounted) setState(() => _recuperation = code);
    } on CompteBensException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCompte(l10n, e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Future<void> _reinitialiser() async {
    final l10n = AppLocalizations.of(context);
    if (!_telephoneOk(l10n)) return;
    setState(() {
      _erreurMotDePasse = _motDePasse.text.length < 8 ? l10n.compteErrMotDePasse : null;
      _erreurConfirmation = _confirmation.text != _motDePasse.text ? l10n.compteErrConfirmation : null;
    });
    if (_erreurMotDePasse != null || _erreurConfirmation != null) return;
    setState(() => _envoi = true);
    try {
      await ref
          .read(licenceProvider.notifier)
          .reinitialiser(telephone: _telephone.text, code: _code.text, motDePasse: _motDePasse.text);
      if (!mounted) return;
      await apresConnexionCompte(context, ref, nom: '', motDePasse: _motDePasse.text, reinitialisation: true);
    } on CompteBensException catch (e) {
      if (mounted) setState(() => _erreur = messageErreurCompte(l10n, e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final code = _recuperation;
    return EcranCompte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          TitreCompte(titre: l10n.oubliTitre, sousTitre: _saisieCode ? null : l10n.oubliIntro),
          ChampTelephone(
            key: const ValueKey('oubli_telephone'),
            controller: _telephone,
            erreur: _erreurTelephone,
            autofocus: true,
            lectureSeule: code != null && !_saisieCode,
          ),
          if (!_saisieCode && code != null)
            Container(
              padding: const EdgeInsets.all(DsSpacing.s4),
              decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: DsSpacing.s3,
                children: [
                  Text(
                    l10n.oubliVotreCode,
                    style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SelectableText(
                      code,
                      key: const ValueKey('oubli_code'),
                      textAlign: TextAlign.center,
                      style: t.mono.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    spacing: DsSpacing.s2,
                    children: [
                      Expanded(
                        child: DsButton(
                          libelle: _copie ? l10n.oubliCopie : l10n.oubliCopier,
                          icone: _copie ? LucideIcons.check : LucideIcons.copy,
                          variante: DsButtonVariante.secondaire,
                          pleineLargeur: true,
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: code));
                            if (!mounted) return;
                            setState(() => _copie = true);
                            await Future<void>.delayed(const Duration(milliseconds: 1500));
                            if (mounted) setState(() => _copie = false);
                          },
                        ),
                      ),
                      Expanded(
                        child: DsButton(
                          libelle: l10n.oubliEnvoyer,
                          icone: LucideIcons.messageCircle,
                          pleineLargeur: true,
                          onPressed: () => launchUrl(
                            Uri.parse(
                              'https://wa.me/$bensWhatsApp?text=${Uri.encodeComponent(l10n.oubliMessage(LicenceService.telephoneE164(_telephone.text), code))}',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_saisieCode) ...[
            DsTextField(
              key: const ValueKey('oubli_code_reset'),
              controller: _code,
              libelle: l10n.oubliCodeReset,
              indice: 'XXXX-XXXX',
              iconePrefixe: LucideIcons.keyRound,
            ),
            _ChampMotDePasse(
              cle: const ValueKey('oubli_nouveau'),
              controller: _motDePasse,
              libelle: l10n.oubliNouveau,
              erreur: _erreurMotDePasse,
            ),
            _ChampMotDePasse(
              cle: const ValueKey('oubli_confirmation'),
              controller: _confirmation,
              libelle: l10n.compteBensConfirmer,
              erreur: _erreurConfirmation,
              onSubmitted: (_) => _reinitialiser(),
            ),
          ],
          if (_erreur != null) _Erreur(_erreur!),
          if (_saisieCode)
            DsButton(
              key: const ValueKey('oubli_valider'),
              libelle: l10n.oubliValider,
              taille: DsButtonTaille.lg,
              pleineLargeur: true,
              onPressed: _envoi ? null : _reinitialiser,
            )
          else if (code == null)
            DsButton(
              key: const ValueKey('oubli_demander'),
              libelle: l10n.oubliDemander,
              taille: DsButtonTaille.lg,
              pleineLargeur: true,
              onPressed: _envoi ? null : _demander,
            ),
          // Retour et « J'ai reçu mon code » sur la même ligne, aux deux bords.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: DsSpacing.s2,
            children: [
              DsButton(
                libelle: l10n.compteRetour,
                icone: LucideIcons.arrowLeft,
                variante: DsButtonVariante.fantome,
                taille: DsButtonTaille.sm,
                onPressed: () => _saisieCode
                    ? setState(() => _saisieCode = false)
                    : (context.canPop() ? context.pop() : context.go(ConnexionComptePage.route)),
              ),
              if (!_saisieCode)
                Flexible(
                  child: DsButton(
                    key: const ValueKey('oubli_recu'),
                    libelle: l10n.oubliRecu,
                    iconeDroite: LucideIcons.arrowRight,
                    variante: code == null ? DsButtonVariante.fantome : DsButtonVariante.secondaire,
                    taille: DsButtonTaille.sm,
                    onPressed: () => setState(() {
                      _saisieCode = true;
                      _erreur = null;
                    }),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Le palier d'une licence pour l'affichage : « Essai Avancé » ou « Licence Max ».
String libelleLicence(AppLocalizations l10n, Licence l) {
  final n = l.niveau;
  if (n == null) return l.lectureSeule ? l10n.lectureSeuleTitre : l10n.connexionNonActivee;
  final nom = libellePalier(l10n, n);
  return l.essai ? l10n.licenceEssai(nom) : l10n.licenceNiveau(nom);
}
