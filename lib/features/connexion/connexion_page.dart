import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../shell/cadre_demarrage.dart';

/// Écran de connexion (identifiant + mot de passe).
class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});

  static const String route = '/connexion';

  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  final _identifiant = TextEditingController();
  final _motDePasse = TextEditingController();
  final _focusMotDePasse = FocusNode();
  String? _erreur;
  bool _afficher = false;

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
      await ref.read(sessionProvider.notifier).connecter(_identifiant.text, _motDePasse.text);
    } on ConnexionException catch (e) {
      setState(() {
        _erreur = switch (e.erreur) {
          ErreurConnexion.identifiantsInvalides => l10n.connexionErreurIdentifiants,
          ErreurConnexion.compteInactif => l10n.connexionErreurInactif,
          ErreurConnexion.motDePasseNonDefini => l10n.connexionErreurNonConfigure,
          ErreurConnexion.demoIndisponible => l10n.connexionErreurDemo,
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
    return CadreDemarrage(
      titre: l10n.connexionTitre,
      largeur: 440,
      icone: LucideIcons.logIn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsTextField(
            controller: _identifiant,
            libelle: l10n.connexionIdentifiant,
            iconePrefixe: LucideIcons.user,
            autofocus: true,
            onSubmitted: (_) => _focusMotDePasse.requestFocus(),
          ),
          const SizedBox(height: DsSpacing.md),
          DsTextField(
            controller: _motDePasse,
            focusNode: _focusMotDePasse,
            libelle: l10n.connexionMotDePasse,
            iconePrefixe: LucideIcons.lock,
            obscur: !_afficher,
            erreur: _erreur,
            suffixe: DsIconButton(
              icone: _afficher ? LucideIcons.eyeOff : LucideIcons.eye,
              tooltip: l10n.connexionMotDePasse,
              onPressed: () => setState(() => _afficher = !_afficher),
            ),
            onSubmitted: (_) => _connecter(),
          ),
          const SizedBox(height: DsSpacing.xl),
          DsButton(
            libelle: l10n.connexionBouton,
            icone: LucideIcons.logIn,
            taille: DsButtonTaille.lg,
            pleineLargeur: true,
            onPressed: _connecter,
          ),
          if (licence.demo) ...[
            const SizedBox(height: DsSpacing.lg),
            Row(
              children: [
                Icon(LucideIcons.info, size: DsTailles.iconeSm, color: c.avertissement),
                const SizedBox(width: DsSpacing.sm),
                Expanded(
                  child: Text(l10n.connexionDemoIndice, style: t.petit.copyWith(color: c.texteSecondaire)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
