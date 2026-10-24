import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/demarrage_providers.dart';
import '../../application/licence_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/licence.dart';
import '../../domain/permissions.dart';
import '../compte_bens/compte_bens_pages.dart';
import '../compte_bens/ecran_compte.dart';
import '../connexion/connexion_page.dart';
import '../offres/offres_page.dart';

/// Activation par clé (secours hors ligne, bens_ds docs/licences.md → The apps' side) : le code de ce
/// poste (`CD-XXXX-XXXX`) à envoyer à BENS sur WhatsApp, puis la clé signée reçue, collée ici et
/// vérifiée sans internet.
class ActivationPage extends ConsumerStatefulWidget {
  const ActivationPage({super.key});

  static const String route = '/activation';

  @override
  ConsumerState<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends ConsumerState<ActivationPage> {
  final _cle = TextEditingController();
  String _poste = '';
  bool _copie = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    ref.read(licenceServiceProvider).codePoste().then((v) {
      if (mounted) setState(() => _poste = v);
    });
  }

  @override
  void dispose() {
    _cle.dispose();
    super.dispose();
  }

  String _date(DateTime d) => DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

  String _message(AppLocalizations l10n, MotifLicence motif, DateTime? fin) => switch (motif) {
    MotifLicence.expiree => l10n.activationErrExpiree(fin == null ? '—' : _date(fin)),
    MotifLicence.autrePoste => l10n.activationErrAutrePoste,
    MotifLicence.dateReculee => l10n.activationErrDate,
    MotifLicence.invalide => l10n.activationErrInvalide,
  };

  Future<void> _activer() async {
    final l10n = AppLocalizations.of(context);
    if (_cle.text.trim().isEmpty) {
      setState(() => _erreur = l10n.activationErrVide);
      return;
    }
    try {
      final licence = await ref.read(licenceProvider.notifier).activer(_cle.text);
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.succes,
        titre: l10n.activationReussieTitre,
        message: l10n.activationReussieDetail(libellePalier(l10n, licence.niveau ?? NiveauLicence.basic), _poste),
        libelleAction: l10n.activationContinuer,
      );
      if (!mounted) return;
      // Avant la connexion : sans compte BENS sur ce poste, on le crée (l'administrateur prend son mot de
      // passe), sinon la connexion locale suit ; depuis l'application (Paramètres) : retour.
      if (ref.read(sessionProvider) == null && licence.compte == null) {
        final offre = ref.read(offresBensProvider).value?.paliers.where((o) => o.niveau == licence.niveau).firstOrNull;
        context.go(offre == null ? InscriptionPage.route : '${InscriptionPage.route}?offre=${offre.code}');
      } else if (ref.read(sessionProvider) == null || !context.canPop()) {
        context.go(ConnexionPage.route);
      } else {
        context.pop();
      }
    } on ActivationException catch (e) {
      setState(() => _erreur = _message(l10n, e.motif, e.finLe));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final licence = ref.watch(licenceProvider);
    // Une clé gardée qui n'est plus valable : pourquoi, sous le champ.
    final motif = licence.motif;
    final avis = _erreur ?? (motif == null ? null : _message(l10n, motif, licence.finMotif));
    return EcranCompte(
      largeur: 620,
      enTete: DsBadge(
        libelle: libelleLicence(l10n, licence),
        ton: licence.estActivee ? DsBadgeTon.succes : DsBadgeTon.avertissement,
        point: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          TitreCompte(titre: l10n.activationTitre, sousTitre: l10n.activationCleSignee),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DsSpacing.s3,
              children: [
                Row(
                  spacing: DsSpacing.s3,
                  children: [
                    Icon(LucideIcons.monitor, size: 18, color: c.iconDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activationPoste,
                            style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              _poste,
                              key: const ValueKey('identifiant_poste'),
                              style: t.mono.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.6,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: DsSpacing.s2,
                  runSpacing: DsSpacing.s2,
                  children: [
                    DsButton(
                      libelle: _copie ? l10n.activationIdentifiantCopie : l10n.activationCopierIdentifiant,
                      icone: _copie ? LucideIcons.check : LucideIcons.copy,
                      variante: DsButtonVariante.secondaire,
                      taille: DsButtonTaille.sm,
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _poste));
                        if (!mounted) return;
                        setState(() => _copie = true);
                        await Future<void>.delayed(const Duration(milliseconds: 1500));
                        if (mounted) setState(() => _copie = false);
                      },
                    ),
                    DsButton(
                      libelle: l10n.activationWhatsApp,
                      icone: LucideIcons.messageCircle,
                      variante: DsButtonVariante.secondaire,
                      taille: DsButtonTaille.sm,
                      onPressed: () async {
                        final lien = await ref.read(licenceServiceProvider).lienWhatsApp();
                        await launchUrl(lien, mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          DsTextField(
            key: const ValueKey('cle_activation'),
            controller: _cle,
            libelle: l10n.activationCle,
            multiligne: true,
            lignes: 4,
            erreur: avis,
            onChanged: (_) {
              if (_erreur != null) setState(() => _erreur = null);
            },
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: DsSpacing.s2,
            runSpacing: DsSpacing.s2,
            children: [
              DsButton(
                key: const ValueKey('activation_coller'),
                libelle: l10n.activationColler,
                icone: LucideIcons.clipboardPaste,
                variante: DsButtonVariante.secondaire,
                onPressed: () async {
                  final d = await Clipboard.getData(Clipboard.kTextPlain);
                  final texte = d?.text;
                  if (texte != null && mounted) {
                    setState(() {
                      _cle.text = texte.trim();
                      _erreur = null;
                    });
                  }
                },
              ),
              DsButton(
                libelle: licence.estActivee ? l10n.communFermer : l10n.activationRetourOffres,
                icone: LucideIcons.arrowLeft,
                variante: DsButtonVariante.fantome,
                onPressed: () => context.canPop() ? context.pop() : context.go(OffresPage.route),
              ),
              DsButton(
                key: const ValueKey('bouton_activer'),
                libelle: l10n.activationBouton,
                icone: LucideIcons.keyRound,
                taille: DsButtonTaille.lg,
                onPressed: _activer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
