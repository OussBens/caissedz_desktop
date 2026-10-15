import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/configuration_initiale_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/boutique.dart';
import '../../domain/models/parametres_paiement.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/referentiel/referentiel.dart';

/// Ouvre l'assistant de configuration initiale (§4.5, DS `InitialSetupDialog`). Retourne `true` s'il a
/// été terminé, `false` sur « Plus tard ».
Future<bool> afficherConfigurationInitiale(BuildContext context) async =>
    await afficherDialog<bool>(context, fermableParVoile: false, builder: (_) => const ConfigurationDialog()) ?? false;

/// Assistant en 4 étapes : langue et devise → boutique → paiements → marge et stock. Tout reste
/// modifiable dans Paramètres. Enregistrement en UNE transaction ([ConfigurationInitialeService]).
class ConfigurationDialog extends ConsumerStatefulWidget {
  const ConfigurationDialog({super.key});

  static const int nbEtapes = 4;

  @override
  ConsumerState<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends ConsumerState<ConfigurationDialog> {
  int _etape = 0;
  String _langue = 'fr';
  String _devise = 'DA';
  int _decimales = 2;
  ParametresPaiement _paiements = const ParametresPaiement();
  bool _fidelite = false;
  String? _erreur;

  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _adresse = TextEditingController();
  final _email = TextEditingController();
  final _rc = TextEditingController();
  final _nif = TextEditingController();
  final _nis = TextEditingController();
  final _article = TextEditingController();
  final _message = TextEditingController();
  final _marge = TextEditingController(text: '20');
  final _seuil = TextEditingController(text: '5');
  final _points = TextEditingController(text: '0.01');

  List<TextEditingController> get _champs => [
    _nom,
    _telephone,
    _adresse,
    _email,
    _rc,
    _nif,
    _nis,
    _article,
    _message,
    _marge,
    _seuil,
    _points,
  ];

  @override
  void initState() {
    super.initState();
    _langue = ref.read(localeProvider).languageCode;
    ref.read(configurationServiceProvider).lire().then((c) {
      if (!mounted) return;
      final b = c.boutique;
      setState(() {
        _devise = c.parametres.devise;
        _decimales = c.parametres.decimalesQuantite;
        _paiements = c.paiements;
        _fidelite = c.parametres.fideliteActive;
        _nom.text = b.nom;
        _telephone.text = b.telephone;
        _adresse.text = b.adresse;
        _email.text = b.email;
        _rc.text = b.rc;
        _nif.text = b.nif;
        _nis.text = b.nis;
        _article.text = b.article;
        _message.text = b.messageTicket;
        final marge = c.parametres.margeDefautPct;
        _marge.text = marge == marge.roundToDouble() ? '${marge.round()}' : '$marge';
        _seuil.text = '${c.parametres.seuilStockGlobal}';
        _points.text = '${c.parametres.pointsParDinar}';
      });
    });
    _nom.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in _champs) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _etapeValide => _etape != 1 || _nom.text.trim().isNotEmpty;

  Future<void> _terminer() async {
    final l10n = AppLocalizations.of(context);
    final marge = lireNombre(_marge.text);
    final seuil = int.tryParse(_seuil.text.trim());
    final points = lireNombre(_points.text);
    if (marge == null || seuil == null || points == null || points < 0) {
      setState(() => _erreur = l10n.configErreurNombre);
      return;
    }
    final config = ConfigurationInitiale(
      langue: _langue,
      boutique: Boutique(
        nom: _nom.text.trim(),
        telephone: _telephone.text.trim(),
        adresse: _adresse.text.trim(),
        email: _email.text.trim(),
        rc: _rc.text.trim(),
        nif: _nif.text.trim(),
        nis: _nis.text.trim(),
        article: _article.text.trim(),
        messageTicket: _message.text.trim(),
      ),
      paiements: _paiements,
      parametres: ParametresVente(
        margeDefautPct: marge,
        seuilStockGlobal: seuil,
        fideliteActive: _fidelite,
        pointsParDinar: points,
        devise: _devise,
        decimalesQuantite: _decimales,
      ),
    );
    try {
      await ref.read(configurationTermineeProvider.notifier).terminer(config);
      await ref.read(localeProvider.notifier).changer(Locale(_langue));
      if (mounted) Navigator.of(context).pop(true);
    } on ConfigurationException catch (e) {
      setState(
        () => _erreur = switch (e.erreur) {
          ErreurConfiguration.nomBoutiqueVide => l10n.configErreurObligatoire,
          ErreurConfiguration.margeHorsLimites => l10n.configErreurMarge,
          ErreurConfiguration.seuilInvalide || ErreurConfiguration.deviseVide => l10n.configErreurNombre,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final derniere = _etape == ConfigurationDialog.nbEtapes - 1;
    return DsDialog(
      key: const ValueKey('dialog_configuration'),
      titre: l10n.configTitre,
      description: l10n.configDescription,
      iconeData: LucideIcons.rocket,
      largeur: 820,
      fermable: false,
      piedDebut: _etape > 0
          ? DsButton(
              libelle: l10n.configPrecedent,
              icone: LucideIcons.arrowLeft,
              variante: DsButtonVariante.secondaire,
              onPressed: () => setState(() {
                _etape--;
                _erreur = null;
              }),
            )
          : null,
      actions: [
        DsButton(
          libelle: l10n.configPlusTard,
          variante: DsButtonVariante.fantome,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (derniere)
          DsButton(
            key: const ValueKey('config_terminer'),
            libelle: l10n.configTerminer,
            icone: LucideIcons.check,
            onPressed: _terminer,
          )
        else
          DsButton(
            key: const ValueKey('config_suivant'),
            libelle: l10n.configSuivant,
            iconeDroite: LucideIcons.arrowRight,
            onPressed: _etapeValide ? () => setState(() => _etape++) : null,
          ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 18,
        children: [
          DsStepper(
            courante: _etape,
            etapes: [
              l10n.configEtapeLangue,
              l10n.configEtapeBoutique,
              l10n.configEtapePaiements,
              l10n.configEtapeVente,
            ],
            descriptions: [
              l10n.configEtapeLangueDetail,
              l10n.configEtapeBoutiqueDetail,
              l10n.configEtapePaiementsDetail,
              l10n.configEtapeVenteDetail,
            ],
            onEtape: (i) => setState(() => _etape = i),
          ),
          switch (_etape) {
            0 => _langueDevise(l10n),
            1 => _boutique(l10n),
            2 => _paiementsEtape(l10n),
            _ => _vente(l10n),
          },
          if (_erreur != null) Text(_erreur!, style: t.bodySm.copyWith(color: c.dangerFg)),
        ],
      ),
    );
  }

  Widget _langueDevise(AppLocalizations l10n) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
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
              valeur: _langue,
              onChanged: (v) => setState(() => _langue = v),
            ),
          ),
        ),
        DsFormRow(
          libelle: l10n.configDevise,
          child: DsSelect<String>(
            valeur: _devise,
            options: const ['DA', 'DZD', '€'],
            libelle: (v) => v,
            onChanged: (v) => setState(() => _devise = v ?? 'DA'),
          ),
        ),
        DsFormRow(
          libelle: l10n.configDecimales,
          aide: l10n.configDecimalesAide,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DsSegmentedControl<int>(
              options: [for (var i = 0; i <= 3; i++) DsOption(i, libelle: '$i')],
              valeur: _decimales,
              onChanged: (v) => setState(() => _decimales = v),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _boutique(AppLocalizations l10n) {
    Widget champ(String libelle, TextEditingController ctrl, {bool obligatoire = false, String? indice, Key? cle}) =>
        DsFormRow(
          libelle: libelle,
          obligatoire: obligatoire,
          child: DsTextField(key: cle, controller: ctrl, indice: indice, autofocus: obligatoire),
        );
    Widget paire(Widget a, Widget b) => Row(
      spacing: 28,
      children: [
        Expanded(child: a),
        Expanded(child: b),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        paire(
          champ(
            l10n.configBoutiqueNom,
            _nom,
            obligatoire: true,
            indice: l10n.configBoutiqueNomIndice,
            cle: const ValueKey('config_nom'),
          ),
          champ(l10n.configBoutiqueTelephone, _telephone, indice: '0xx xx xx xx'),
        ),
        champ(l10n.configBoutiqueAdresse, _adresse, indice: l10n.configBoutiqueAdresseIndice),
        paire(champ(l10n.configBoutiqueEmail, _email), champ(l10n.configBoutiqueRc, _rc)),
        paire(champ(l10n.configBoutiqueNif, _nif), champ(l10n.configBoutiqueNis, _nis)),
        paire(champ(l10n.configBoutiqueArticle, _article), const SizedBox.shrink()),
        DsFormRow(
          libelle: l10n.configBoutiqueMessage,
          alignerDebut: true,
          child: DsTextField(
            controller: _message,
            multiligne: true,
            lignes: 2,
            indice: l10n.configBoutiqueMessageIndice,
          ),
        ),
      ],
    );
  }

  Widget _paiementsEtape(AppLocalizations l10n) {
    final locale = ref.watch(localeProvider);
    final c = context.ds.colors;
    Widget tuile(String mode, bool valeur, ValueChanged<bool>? onChanged) => Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: valeur ? c.primaryTint : c.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: valeur ? c.primary : c.borderDefault),
      ),
      child: DsSwitch(
        cle: ValueKey('paiement_$mode'),
        valeur: valeur,
        libelle: Referentiel.modesPaiement.libelle(mode, locale),
        actif: onChanged != null,
        onChanged: onChanged ?? (_) {},
      ),
    );
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        tuile('Espèces', true, null),
        tuile('Carte', _paiements.carte, (v) => setState(() => _paiements = _paiements.copyWith(carte: v))),
        tuile('Chèque', _paiements.cheque, (v) => setState(() => _paiements = _paiements.copyWith(cheque: v))),
        tuile('Virement', _paiements.virement, (v) => setState(() => _paiements = _paiements.copyWith(virement: v))),
      ],
    );
  }

  Widget _vente(AppLocalizations l10n) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        DsFormRow(
          libelle: l10n.configMarge,
          aide: l10n.configMargeAide,
          child: DsTextField(
            key: const ValueKey('config_marge'),
            controller: _marge,
            numerique: true,
            suffixeTexte: '%',
          ),
        ),
        DsFormRow(
          libelle: l10n.configSeuil,
          aide: l10n.configSeuilAide,
          child: DsTextField(controller: _seuil, numerique: true),
        ),
        DsFormRow(
          libelle: l10n.configFidelite,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DsSwitch(
              valeur: _fidelite,
              libelle: l10n.configFideliteActive,
              onChanged: (v) => setState(() => _fidelite = v),
            ),
          ),
        ),
        if (_fidelite)
          DsFormRow(
            libelle: l10n.configPointsParDinar,
            child: DsTextField(controller: _points, numerique: true),
          ),
      ],
    ),
  );
}
