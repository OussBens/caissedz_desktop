import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/auth_service.dart';
import '../../application/configuration_initiale_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/boutique.dart';
import '../../domain/models/parametres_vente.dart';
import '../shell/cadre_demarrage.dart';

/// Configuration initiale en 4 étapes : boutique, administrateur, marge et vente, récapitulatif.
class ConfigurationPage extends ConsumerStatefulWidget {
  const ConfigurationPage({super.key});

  static const String route = '/configuration';
  static const int nbEtapes = 4;

  @override
  ConsumerState<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends ConsumerState<ConfigurationPage> {
  int _etape = 0;

  // Étape 1 — boutique
  final _nom = TextEditingController();
  final _rc = TextEditingController();
  final _nif = TextEditingController();
  final _adresse = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  // Étape 2 — administrateur
  final _identifiant = TextEditingController(text: 'admin');
  final _nomAdmin = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();
  // Étape 3 — marge et vente
  final _marge = TextEditingController(text: '20');
  final _seuil = TextEditingController(text: '5');
  final _points = TextEditingController(text: '0.01');
  bool _fidelite = false;
  String _devise = 'DA';

  final Map<String, String> _erreurs = {};

  @override
  void dispose() {
    for (final c in [_nom, _rc, _nif, _adresse, _telephone, _email, _identifiant, _nomAdmin, _motDePasse, _confirmation, _marge, _seuil, _points]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validerEtape(AppLocalizations l10n) {
    _erreurs.clear();
    switch (_etape) {
      case 0:
        if (_nom.text.trim().isEmpty) _erreurs['nom'] = l10n.configErreurObligatoire;
      case 1:
        if (!AuthService.identifiantValide(_identifiant.text)) _erreurs['identifiant'] = l10n.configErreurIdentifiant;
        if (_motDePasse.text.length < AuthService.longueurMinMotDePasse) _erreurs['motDePasse'] = l10n.configErreurMotDePasseCourt;
        if (_confirmation.text != _motDePasse.text) _erreurs['confirmation'] = l10n.configErreurConfirmation;
      case 2:
        final m = double.tryParse(_marge.text.replaceAll(',', '.'));
        if (m == null) {
          _erreurs['marge'] = l10n.configErreurNombre;
        } else if (m < 0 || m > 1000) {
          _erreurs['marge'] = l10n.configErreurMarge;
        }
        if (int.tryParse(_seuil.text) == null) _erreurs['seuil'] = l10n.configErreurNombre;
        if (_fidelite && double.tryParse(_points.text.replaceAll(',', '.')) == null) _erreurs['points'] = l10n.configErreurNombre;
    }
    setState(() {});
    return _erreurs.isEmpty;
  }

  ParametresVente get _parametres => ParametresVente(
        margeDefautPct: double.tryParse(_marge.text.replaceAll(',', '.')) ?? 20,
        seuilStockGlobal: int.tryParse(_seuil.text) ?? 5,
        fideliteActive: _fidelite,
        pointsParDinar: double.tryParse(_points.text.replaceAll(',', '.')) ?? 0.01,
        devise: _devise,
      );

  Boutique get _boutique => Boutique(
        nom: _nom.text.trim(),
        rc: _rc.text.trim(),
        nif: _nif.text.trim(),
        adresse: _adresse.text.trim(),
        telephone: _telephone.text.trim(),
        email: _email.text.trim(),
      );

  void _suivant() {
    final l10n = AppLocalizations.of(context);
    if (!_validerEtape(l10n)) return;
    setState(() => _etape++);
  }

  Future<void> _terminer() async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(configurationTermineeProvider.notifier).terminer(ConfigurationInitiale(
            boutique: _boutique,
            adminIdentifiant: _identifiant.text.trim(),
            adminNom: _nomAdmin.text.trim(),
            adminMotDePasse: _motDePasse.text,
            parametres: _parametres,
            langue: ref.read(localeProvider).languageCode,
          ));
      if (!mounted) return;
      unawaited(afficherResultat(context, type: DsResultatType.succes, titre: l10n.configTitre, message: l10n.configReussie));
    } on CompteException catch (e) {
      setState(() {
        _etape = 1;
        _erreurs['identifiant'] = e.erreur == ErreurCompte.identifiantPris ? l10n.configErreurIdentifiantPris : l10n.configErreurIdentifiant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final etapes = [l10n.configEtapeBoutique, l10n.configEtapeAdmin, l10n.configEtapeVente, l10n.configEtapeRecap];
    return CadreDemarrage(
      titre: l10n.configTitre,
      largeur: 680,
      icone: LucideIcons.settings2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsStepper(etapes: etapes, courante: _etape),
          const SizedBox(height: DsSpacing.sm),
          Text(l10n.configEtape(_etape + 1, ConfigurationPage.nbEtapes), style: t.legende.copyWith(color: c.texteAttenue)),
          const SizedBox(height: DsSpacing.xl),
          switch (_etape) {
            0 => _etapeBoutique(l10n),
            1 => _etapeAdmin(l10n),
            2 => _etapeVente(l10n),
            _ => _etapeRecap(l10n),
          },
          const SizedBox(height: DsSpacing.xl),
          Row(
            children: [
              if (_etape > 0)
                DsButton(libelle: l10n.configPrecedent, icone: LucideIcons.chevronLeft, variante: DsButtonVariante.secondaire, onPressed: () => setState(() => _etape--)),
              const Spacer(),
              if (_etape < ConfigurationPage.nbEtapes - 1)
                DsButton(libelle: l10n.configSuivant, icone: LucideIcons.chevronRight, onPressed: _suivant)
              else
                DsButton(libelle: l10n.configTerminer, icone: LucideIcons.check, variante: DsButtonVariante.succes, onPressed: _terminer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _etapeBoutique(AppLocalizations l10n) => Column(
        children: [
          DsTextField(controller: _nom, libelle: l10n.configBoutiqueNom, erreur: _erreurs['nom'], autofocus: true, iconePrefixe: LucideIcons.store),
          const SizedBox(height: DsSpacing.md),
          Row(children: [
            Expanded(child: DsTextField(controller: _rc, libelle: l10n.configBoutiqueRc)),
            const SizedBox(width: DsSpacing.md),
            Expanded(child: DsTextField(controller: _nif, libelle: l10n.configBoutiqueNif)),
          ]),
          const SizedBox(height: DsSpacing.md),
          DsTextField(controller: _adresse, libelle: l10n.configBoutiqueAdresse),
          const SizedBox(height: DsSpacing.md),
          Row(children: [
            Expanded(child: DsTextField(controller: _telephone, libelle: l10n.configBoutiqueTelephone, typeClavier: TextInputType.phone)),
            const SizedBox(width: DsSpacing.md),
            Expanded(child: DsTextField(controller: _email, libelle: l10n.configBoutiqueEmail, typeClavier: TextInputType.emailAddress)),
          ]),
        ],
      );

  Widget _etapeAdmin(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.configAdminIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
        const SizedBox(height: DsSpacing.lg),
        Row(children: [
          Expanded(child: DsTextField(controller: _identifiant, libelle: l10n.connexionIdentifiant, erreur: _erreurs['identifiant'], iconePrefixe: LucideIcons.user)),
          const SizedBox(width: DsSpacing.md),
          Expanded(child: DsTextField(controller: _nomAdmin, libelle: l10n.configAdminNom)),
        ]),
        const SizedBox(height: DsSpacing.md),
        Row(children: [
          Expanded(child: DsTextField(controller: _motDePasse, libelle: l10n.connexionMotDePasse, obscur: true, erreur: _erreurs['motDePasse'], iconePrefixe: LucideIcons.lock)),
          const SizedBox(width: DsSpacing.md),
          Expanded(child: DsTextField(controller: _confirmation, libelle: l10n.configAdminMotDePasseConfirmation, obscur: true, erreur: _erreurs['confirmation'], iconePrefixe: LucideIcons.lock)),
        ]),
      ],
    );
  }

  Widget _etapeVente(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: DsTextField(controller: _marge, libelle: l10n.configMarge, erreur: _erreurs['marge'], iconePrefixe: LucideIcons.percent, typeClavier: TextInputType.number)),
          const SizedBox(width: DsSpacing.md),
          Expanded(child: DsTextField(controller: _seuil, libelle: l10n.configSeuil, erreur: _erreurs['seuil'], iconePrefixe: LucideIcons.triangleAlert, typeClavier: TextInputType.number)),
        ]),
        const SizedBox(height: DsSpacing.xs),
        Text(l10n.configMargeAide, style: t.petit.copyWith(color: c.texteAttenue)),
        const SizedBox(height: DsSpacing.lg),
        Row(children: [
          Checkbox(value: _fidelite, activeColor: c.primaire, onChanged: (v) => setState(() => _fidelite = v ?? false)),
          Text(l10n.configFidelite, style: t.corps),
        ]),
        if (_fidelite) ...[
          const SizedBox(height: DsSpacing.sm),
          DsTextField(controller: _points, libelle: l10n.configPointsParDinar, erreur: _erreurs['points'], typeClavier: TextInputType.number),
        ],
        const SizedBox(height: DsSpacing.lg),
        Text(l10n.configDevise, style: t.petitFort.copyWith(color: c.texteSecondaire)),
        const SizedBox(height: DsSpacing.xs),
        Row(children: [
          for (final d in const ['DA', 'EUR', 'USD']) ...[
            DsButton(libelle: d, taille: DsButtonTaille.sm, variante: _devise == d ? DsButtonVariante.primaire : DsButtonVariante.secondaire, onPressed: () => setState(() => _devise = d)),
            const SizedBox(width: DsSpacing.xs),
          ],
        ]),
      ],
    );
  }

  Widget _etapeRecap(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    Widget ligne(String libelle, String valeur) => Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 220, child: Text(libelle, style: t.petit.copyWith(color: c.texteSecondaire))),
              Expanded(child: Text(valeur.isEmpty ? '—' : valeur, style: t.corpsFort)),
            ],
          ),
        );
    final p = _parametres;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.configRecapIntro, style: t.corps.copyWith(color: c.texteSecondaire)),
        const SizedBox(height: DsSpacing.lg),
        DsSectionTitre(l10n.configEtapeBoutique),
        ligne(l10n.configBoutiqueNom, _nom.text.trim()),
        ligne(l10n.configBoutiqueRc, _rc.text.trim()),
        ligne(l10n.configBoutiqueTelephone, _telephone.text.trim()),
        ligne(l10n.configBoutiqueEmail, _email.text.trim()),
        const SizedBox(height: DsSpacing.md),
        DsSectionTitre(l10n.configEtapeAdmin),
        ligne(l10n.connexionIdentifiant, _identifiant.text.trim()),
        ligne(l10n.configAdminNom, _nomAdmin.text.trim()),
        const SizedBox(height: DsSpacing.md),
        DsSectionTitre(l10n.configEtapeVente),
        ligne(l10n.configMarge, '${p.margeDefautPct} %'),
        ligne(l10n.configSeuil, '${p.seuilStockGlobal}'),
        ligne(l10n.configFidelite, p.fideliteActive ? '${p.pointsParDinar} / 1 ${p.devise}' : l10n.communAnnuler.toLowerCase() == 'annuler' ? 'Non' : 'No'),
        ligne(l10n.configDevise, p.devise),
      ],
    );
  }
}
