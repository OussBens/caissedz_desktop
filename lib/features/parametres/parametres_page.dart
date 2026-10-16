import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../application/parametres_service.dart';
import '../../application/sauvegarde_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/imprimante.dart';
import '../../core/print/ticket_escpos.dart';
import '../../data/vente_repository.dart';
import '../../domain/fiscalite.dart';
import '../../domain/models/licence.dart';
import '../../domain/models/panier.dart';
import '../../domain/models/parametres_paiement.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/models/vente.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../activation/activation_page.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/page_module.dart';
import '../commun/referentiel_ui.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';

/// Groupes de la navigation latérale (`ParametresScreen` du DS v2.2).
enum GroupeParametres { systeme, boutique, caisse, impression, alertes, sauvegarde, licence }

/// Écran Paramètres (§9.16, DS v2.2 + compléments `ParametresV22`) : navigation par groupe, barre
/// d'enregistrement unique (une transaction), thème et langue appliqués immédiatement (préférences du poste).
class ParametresPage extends ConsumerStatefulWidget {
  const ParametresPage({super.key});

  @override
  ConsumerState<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends ConsumerState<ParametresPage> {
  GroupeParametres _groupe = GroupeParametres.systeme;
  ParametresComplets? _initial;
  bool _modifie = false;
  bool _enChargement = true;

  // Système
  String _devise = 'DA';
  int _decimales = 2;
  bool _nombreActif = false;
  String _regime = RegimesFiscaux.reel;
  bool _timbre = true;
  String _typeMarge = ParametresVente.typeMargePourcentage;
  final _margePct = TextEditingController();
  final _margeMontant = TextEditingController();
  final _seuilMin = TextEditingController();
  final _seuilMax = TextEditingController();
  final _nissab = TextEditingController();
  final _taux = TextEditingController();
  final _url = TextEditingController();
  final _cle = TextEditingController();
  final _mantouj = TextEditingController();
  // Boutique
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _adresse = TextEditingController();
  final _rc = TextEditingController();
  final _nif = TextEditingController();
  final _nis = TextEditingController();
  final _article = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  String _logo = '';
  // Caisse et ventes
  ParametresPaiement _paiements = const ParametresPaiement();
  String _venteSousAchat = ParametresVente.venteSousAchatAvertir;
  bool _fidelite = false;
  final _pointsGain = TextEditingController();
  final _tranche = TextEditingController();
  // Impression
  String _typeImprimante = TypesImprimante.normale;
  final _adresseImprimante = TextEditingController();
  String _largeur = '80';
  String? _testEnvoye;
  // Alertes
  bool _alertesConnexion = true;
  ParametresSauvegardeAuto _sauvegardeAuto = const ParametresSauvegardeAuto();
  final _seuilCredit = TextEditingController();

  List<TextEditingController> get _champs => [
    _margePct,
    _margeMontant,
    _seuilMin,
    _seuilMax,
    _nissab,
    _taux,
    _url,
    _cle,
    _mantouj,
    _nom,
    _telephone,
    _adresse,
    _rc,
    _nif,
    _nis,
    _article,
    _email,
    _message,
    _pointsGain,
    _tranche,
    _adresseImprimante,
    _seuilCredit,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _champs) {
      c.addListener(_marquer);
    }
    unawaited(_charger());
  }

  @override
  void dispose() {
    for (final c in _champs) {
      c.dispose();
    }
    super.dispose();
  }

  void _marquer() {
    if (_enChargement || _modifie || !mounted) return;
    setState(() => _modifie = true);
  }

  void _changer(VoidCallback f) {
    setState(f);
    _marquer();
  }

  static String _n(double v, {int decimales = 2}) => formaterNombre(v, decimales: decimales, grouper: false);
  static String _entier(num v) => v == v.roundToDouble() ? '${v.round()}' : _n(v.toDouble());

  Future<void> _charger() async {
    final p = await ref.read(parametresServiceProvider).lireTout();
    if (!mounted) return;
    _enChargement = true;
    setState(() {
      _initial = p;
      final v = p.vente;
      _devise = v.devise;
      _decimales = v.decimalesQuantite;
      _nombreActif = v.nombreActif;
      _regime = v.regimeFiscal;
      _timbre = v.timbreActif;
      _typeMarge = v.typeMarge;
      _margePct.text = _entier(v.margeDefautPct);
      _margeMontant.text = _entier(v.margeMontant);
      _seuilMin.text = '${v.seuilStockGlobal}';
      _seuilMax.text = '${v.seuilStockMax}';
      _venteSousAchat = v.venteSousAchat;
      _fidelite = v.fideliteActive;
      // Taux de gain affiché « 1 point / 100 DA » : points par dinar = points / tranche.
      final tranche = v.pointsParDinar > 0 ? 1 / v.pointsParDinar : 100.0;
      _pointsGain.text = '1';
      _tranche.text = _entier(double.parse(tranche.toStringAsFixed(2)));
      _nissab.text = _entier(p.zakat.nissab);
      _taux.text = formaterNombre(p.zakat.tauxPct, decimales: 1, grouper: false);
      _url.text = p.serveur.url;
      _cle.text = p.serveur.cle;
      _mantouj.text = p.serveur.urlMantouj;
      final b = p.boutique;
      _nom.text = b.nom;
      _telephone.text = b.telephone;
      _adresse.text = b.adresse;
      _rc.text = b.rc;
      _nif.text = b.nif;
      _nis.text = b.nis;
      _article.text = b.article;
      _email.text = b.email;
      _message.text = b.messageTicket;
      _logo = b.logo;
      _paiements = p.paiements;
      _typeImprimante = p.impression.type;
      _adresseImprimante.text = p.impression.adresse;
      _largeur = p.impression.largeur;
      _alertesConnexion = p.alertes.afficherConnexion;
      _sauvegardeAuto = p.sauvegarde;
      _seuilCredit.text = _entier(p.alertes.seuilCreditClient);
      _modifie = false;
      _testEnvoye = null;
    });
    _enChargement = false;
  }

  double _v(TextEditingController c, {double defaut = -1}) => lireNombre(c.text) ?? defaut;

  ParametresComplets _construire() {
    final i = _initial!;
    final points = _v(_pointsGain);
    final tranche = _v(_tranche);
    return ParametresComplets(
      boutique: i.boutique.copyWith(
        nom: _nom.text,
        telephone: _telephone.text.trim(),
        adresse: _adresse.text.trim(),
        rc: _rc.text.trim(),
        nif: _nif.text.trim(),
        nis: _nis.text.trim(),
        article: _article.text.trim(),
        email: _email.text.trim(),
        messageTicket: _message.text.trim(),
        logo: _logo,
      ),
      vente: i.vente.copyWith(
        devise: _devise,
        decimalesQuantite: _decimales,
        nombreActif: _nombreActif,
        regimeFiscal: _regime,
        timbreActif: _timbre,
        typeMarge: _typeMarge,
        margeDefautPct: _v(_margePct),
        margeMontant: _v(_margeMontant),
        seuilStockGlobal: int.tryParse(_seuilMin.text.trim()) ?? -1,
        seuilStockMax: int.tryParse(_seuilMax.text.trim().isEmpty ? '0' : _seuilMax.text.trim()) ?? -1,
        venteSousAchat: _venteSousAchat,
        fideliteActive: _fidelite,
        pointsParDinar: !_fidelite ? i.vente.pointsParDinar : (points < 0 || tranche <= 0 ? -1 : points / tranche),
      ),
      paiements: _paiements,
      impression: ParametresImpression(type: _typeImprimante, adresse: _adresseImprimante.text, largeur: _largeur),
      serveur: ParametresServeur(url: _url.text, cle: _cle.text, urlMantouj: _mantouj.text),
      zakat: ParametresZakat(nissab: _v(_nissab), tauxPct: _v(_taux)),
      alertes: ParametresAlertes(afficherConnexion: _alertesConnexion, seuilCreditClient: _v(_seuilCredit, defaut: 0)),
      sauvegarde: _sauvegardeAuto,
    );
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(parametresServiceProvider).enregistrerTout(_construire());
    } on ParametresException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.pmEnregistrer,
          message: messageErreurParametres(l10n, e.erreur),
        ),
      );
      return;
    }
    ref
      ..invalidate(parametresVenteProvider)
      ..invalidate(parametresPaiementProvider)
      ..invalidate(serveurCaisseDzProvider);
    await _charger();
    if (!mounted) return;
    afficherToast(context, titre: l10n.pmEnregistre, ton: DsToastTon.succes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageModule(
      moduleId: 'parametres',
      sousTitre: l10n.pmDescription,
      actions: [
        if (_modifie)
          DsBadge(
            key: const ValueKey('param_modifie'),
            libelle: l10n.pmNonEnregistre,
            ton: DsBadgeTon.avertissement,
            point: true,
          ),
      ],
      defilable: false,
      child: _initial == null
          ? const SizedBox.shrink()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DsSpacing.s6,
              children: [
                // Navigation fixe (`position: sticky` du DS) ; seul le contenu défile.
                SizedBox(width: 220, child: _navigation(l10n)),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('param_contenu'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: DsSpacing.s4,
                      children: [
                        ...switch (_groupe) {
                          GroupeParametres.systeme => _systeme(l10n),
                          GroupeParametres.boutique => _boutique(l10n),
                          GroupeParametres.caisse => _caisse(l10n),
                          GroupeParametres.impression => _impression(l10n),
                          GroupeParametres.alertes => _alertes(l10n),
                          GroupeParametres.sauvegarde => _sauvegarde(l10n),
                          GroupeParametres.licence => _licence(l10n),
                        },
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: DsSpacing.s2,
                          children: [
                            DsButton(
                              key: const ValueKey('param_annuler'),
                              libelle: l10n.communAnnuler,
                              variante: DsButtonVariante.secondaire,
                              onPressed: _modifie ? _charger : null,
                            ),
                            DsButton(
                              key: const ValueKey('param_enregistrer'),
                              libelle: l10n.pmEnregistrer,
                              icone: LucideIcons.check,
                              onPressed: _modifie ? _enregistrer : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ------------------------------------------------------------------ Navigation

  Widget _navigation(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final groupes = [
      (GroupeParametres.systeme, l10n.pmGrpSysteme, LucideIcons.settings2),
      (GroupeParametres.boutique, l10n.pmGrpBoutique, LucideIcons.store),
      (GroupeParametres.caisse, l10n.pmGrpCaisse, LucideIcons.monitorSmartphone),
      (GroupeParametres.impression, l10n.pmGrpImpression, LucideIcons.printer),
      (GroupeParametres.alertes, l10n.pmGrpAlertes, LucideIcons.bell),
      (GroupeParametres.sauvegarde, l10n.pmGrpSauvegarde, LucideIcons.databaseBackup),
      (GroupeParametres.licence, l10n.pmGrpLicence, LucideIcons.keyRound),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s0_5,
      children: [
        for (final (g, libelle, icone) in groupes)
          Builder(
            builder: (context) {
              final actif = g == _groupe;
              return Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: ValueKey('param_nav_${g.name}'),
                  borderRadius: DsRadius.borderMd,
                  onTap: () => setState(() => _groupe = g),
                  child: AnimatedContainer(
                    duration: DsMotion.fast,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s2 + 2),
                    decoration: BoxDecoration(
                      color: actif ? c.surfaceCard : null,
                      borderRadius: DsRadius.borderMd,
                      border: Border.all(color: actif ? c.borderDefault : c.surfaceApp.withValues(alpha: 0)),
                      boxShadow: actif ? DsShadows.xs : null,
                    ),
                    child: Row(
                      spacing: DsSpacing.s2 + 2,
                      children: [
                        Icon(icone, size: DsTailles.iconeSm, color: actif ? c.iconActive : c.iconDefault),
                        Expanded(
                          child: Text(
                            libelle,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySm.copyWith(
                              fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
                              color: actif ? c.textPrimary : c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // ------------------------------------------------------------------ Briques

  /// Ligne « titre + description » à gauche, contrôle à droite (`Row` du DS).
  Widget _ligne(String titre, {String? description, required Widget child, bool derniere = false}) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.s3),
      decoration: BoxDecoration(
        border: derniere ? null : Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DsSpacing.s4,
        runSpacing: DsSpacing.s2,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(titre, style: t.bodyStrong.copyWith(color: c.textPrimary)),
                if (description != null)
                  Text(description, style: t.bodySm.copyWith(color: c.textSecondary, height: 1.45)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  /// Interrupteur pleine ligne (titre + description à gauche).
  Widget _interrupteur(
    String cle,
    String titre, {
    String? description,
    required bool valeur,
    required ValueChanged<bool> onChanged,
    bool actif = true,
    bool derniere = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: DsSpacing.s3),
    decoration: BoxDecoration(
      border: derniere ? null : Border(bottom: BorderSide(color: context.ds.colors.borderSubtle)),
    ),
    child: DsSwitch(
      cle: ValueKey(cle),
      valeur: valeur,
      libelle: titre,
      aide: description,
      actif: actif,
      onChanged: onChanged,
    ),
  );

  Widget _nombre(
    String cle,
    TextEditingController controller, {
    double largeur = 140,
    String? suffixe,
    bool actif = true,
  }) => SizedBox(
    width: largeur,
    child: DsTextField(
      key: ValueKey(cle),
      controller: controller,
      numerique: true,
      suffixeTexte: suffixe,
      actif: actif,
    ),
  );

  /// Deux cartes par ligne dès que la place le permet (`v22-grid-2`).
  Widget _grille(List<Widget> cartes) => LayoutBuilder(
    builder: (context, contraintes) {
      final deux = contraintes.maxWidth >= 760;
      final largeur = deux ? (contraintes.maxWidth - DsSpacing.s4) / 2 : contraintes.maxWidth;
      return Wrap(
        spacing: DsSpacing.s4,
        runSpacing: DsSpacing.s4,
        children: [for (final c in cartes) SizedBox(width: largeur, child: c)],
      );
    },
  );

  // ------------------------------------------------------------------ Système

  List<Widget> _systeme(AppLocalizations l10n) {
    final theme = ref.watch(themeModeProvider);
    final langue = ref.watch(localeProvider).languageCode;
    final devises = {'DA', 'DZD', '€', _devise}.toList();
    final symbole = _typeMarge == ParametresVente.typeMargeMontant ? _devise : '%';
    return [
      DsCard(
        titre: l10n.pmGrpSysteme,
        icone: LucideIcons.settings2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ligne(
              l10n.pmTheme,
              description: l10n.pmThemeDesc,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DsSpacing.s3,
                children: [
                  _apercuTheme(ThemeMode.light, l10n.pmClair, actif: theme != ThemeMode.dark),
                  _apercuTheme(ThemeMode.dark, l10n.pmSombre, actif: theme == ThemeMode.dark),
                ],
              ),
            ),
            _ligne(
              l10n.pmLangue,
              description: l10n.pmLangueDesc,
              child: DsSegmentedControl<String>(
                key: const ValueKey('param_langue'),
                valeur: langue,
                options: const [
                  DsOption('fr', libelle: 'Français'),
                  DsOption('en', libelle: 'English'),
                  DsOption('ar', libelle: 'العربية'),
                ],
                onChanged: (v) => ref.read(localeProvider.notifier).changer(Locale(v)),
              ),
            ),
            _ligne(
              l10n.pmDevise,
              description: l10n.pmDeviseDesc,
              child: SizedBox(
                width: 160,
                child: DsSelect<String>(
                  key: const ValueKey('param_devise'),
                  valeur: _devise,
                  options: devises,
                  libelle: (d) => d,
                  onChanged: (v) => _changer(() => _devise = v ?? _devise),
                ),
              ),
            ),
            _ligne(
              l10n.pmDecimales,
              description: l10n.pmDecimalesDesc,
              child: DsSegmentedControl<int>(
                key: const ValueKey('param_decimales'),
                valeur: _decimales,
                options: [for (var i = 0; i <= 3; i++) DsOption(i, libelle: '$i')],
                onChanged: (v) => _changer(() => _decimales = v),
              ),
            ),
            _interrupteur(
              'param_nombre_actif',
              l10n.pmNombreActif,
              description: l10n.pmNombreActifDesc,
              valeur: _nombreActif,
              onChanged: (v) => _changer(() => _nombreActif = v),
            ),
            _ligne(
              l10n.pmRegimeFiscal,
              description: l10n.pmRegimeFiscalDesc,
              child: DsSegmentedControl<String>(
                key: const ValueKey('param_regime'),
                valeur: _regime,
                options: [
                  DsOption(RegimesFiscaux.reel, libelle: l10n.pmRegimeReel),
                  DsOption(RegimesFiscaux.ifu, libelle: l10n.pmRegimeIfu),
                ],
                onChanged: (v) => _changer(() => _regime = v),
              ),
            ),
            _interrupteur(
              'param_timbre',
              l10n.pmTimbre,
              description: l10n.pmTimbreDesc,
              valeur: _timbre,
              derniere: true,
              onChanged: (v) => _changer(() => _timbre = v),
            ),
          ],
        ),
      ),
      _grille([
        DsCard(
          titre: l10n.pmMargeTitre,
          icone: LucideIcons.percent,
          info: l10n.pmMargeInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ligne(
                l10n.pmMargeType,
                description: l10n.pmMargeTypeDesc,
                child: DsSegmentedControl<String>(
                  key: const ValueKey('param_marge_type'),
                  valeur: _typeMarge,
                  options: [
                    DsOption(ParametresVente.typeMargeMontant, libelle: l10n.pmMontant),
                    DsOption(ParametresVente.typeMargePourcentage, libelle: l10n.pmPourcentage),
                  ],
                  onChanged: (v) => _changer(() => _typeMarge = v),
                ),
              ),
              _ligne(
                l10n.pmMargeValeur,
                description: l10n.pmMargeValeurDesc,
                derniere: true,
                child: _typeMarge == ParametresVente.typeMargeMontant
                    ? _nombre('param_marge_montant', _margeMontant, suffixe: symbole)
                    : _nombre('param_marge_pct', _margePct, suffixe: symbole),
              ),
            ],
          ),
        ),
        DsCard(
          titre: l10n.pmSeuilsTitre,
          icone: LucideIcons.gauge,
          info: l10n.pmSeuilsInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ligne(
                l10n.pmSeuilMin,
                description: l10n.pmSeuilMinDesc,
                child: _nombre('param_seuil_min', _seuilMin, suffixe: l10n.pmPieces),
              ),
              _ligne(
                l10n.pmSeuilMax,
                description: l10n.pmSeuilMaxDesc,
                child: _nombre('param_seuil_max', _seuilMax, suffixe: l10n.pmPieces),
              ),
              _ligne(
                l10n.pmGarde,
                description: l10n.pmGardeDesc,
                derniere: true,
                child: DsBadge(libelle: l10n.pmNonDesactivable, ton: DsBadgeTon.succes, icone: LucideIcons.shieldCheck),
              ),
            ],
          ),
        ),
        DsCard(
          titre: l10n.pmZakatTitre,
          icone: LucideIcons.handCoins,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ligne(
                l10n.pmNissab,
                description: l10n.pmNissabDesc,
                child: _nombre('param_nissab', _nissab, largeur: 180, suffixe: _devise),
              ),
              _ligne(
                l10n.pmTaux,
                description: l10n.pmTauxDesc,
                derniere: true,
                child: _nombre('param_zakat_taux', _taux, largeur: 120, suffixe: '%'),
              ),
            ],
          ),
        ),
        _carteServeurs(l10n),
      ]),
    ];
  }

  Widget _apercuTheme(ThemeMode mode, String libelle, {required bool actif}) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final sombre = mode == ThemeMode.dark;
    // Aperçu figé des deux thèmes : couleurs tirées des palettes du DS, indépendantes du thème courant.
    final palette = sombre ? DsColors.sombre : DsColors.clair;
    final fond = palette.surfaceApp;
    final carte = palette.surfaceCard;
    final accent = palette.primary;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: ValueKey('param_theme_${sombre ? 'sombre' : 'clair'}'),
        borderRadius: DsRadius.borderLg,
        onTap: () => ref.read(themeModeProvider.notifier).changer(mode),
        child: AnimatedContainer(
          duration: DsMotion.base,
          width: 132,
          padding: const EdgeInsets.all(DsSpacing.s1_5),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: DsRadius.borderLg,
            border: Border.all(color: actif ? c.primary : c.borderDefault, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.all(DsSpacing.s2),
                decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
                child: Row(
                  spacing: DsSpacing.s1_5,
                  children: [
                    Container(
                      width: 22,
                      decoration: BoxDecoration(color: carte, borderRadius: DsRadius.borderXs),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: DsSpacing.s1,
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(color: carte, borderRadius: DsRadius.borderXs),
                          ),
                          FractionallySizedBox(
                            widthFactor: .6,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(color: accent, borderRadius: DsRadius.borderXs),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(libelle, style: t.bodySmStrong.copyWith(color: c.textPrimary)),
                    ),
                    if (actif) Icon(LucideIcons.circleCheck, size: DsTailles.iconeSm, color: c.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carteServeurs(AppLocalizations l10n) => DsCard(
    titre: l10n.pmServeursTitre,
    icone: LucideIcons.cloud,
    info: l10n.pmServeursInfo,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        DsTextField(
          key: const ValueKey('param_serveur_url'),
          controller: _url,
          libelle: l10n.pmServeurUrl,
          indice: 'https://api.caissedz.dz',
        ),
        DsTextField(
          key: const ValueKey('param_serveur_cle'),
          controller: _cle,
          libelle: l10n.pmServeurCle,
          obscur: true,
        ),
        DsTextField(
          key: const ValueKey('param_mantouj'),
          controller: _mantouj,
          libelle: l10n.pmMantouj,
          indice: 'https://mantouj.dz/api',
        ),
        _ligne(
          l10n.pmSynchro,
          description: l10n.pmSynchroDesc,
          derniere: true,
          child: DsButton(
            key: const ValueKey('param_synchro'),
            libelle: l10n.pmSynchroBouton,
            icone: LucideIcons.refreshCw,
            variante: DsButtonVariante.secondaire,
            taille: DsButtonTaille.sm,
            onPressed: _modifie || _initial!.serveur.url.isEmpty ? null : _synchroniser,
          ),
        ),
      ],
    ),
  );

  Future<void> _synchroniser() async {
    final l10n = AppLocalizations.of(context);
    final r = await ref.read(synchroCatalogueServiceProvider).synchroniser();
    if (r.ok) ref.read(catalogueVersionProvider.notifier).incrementer();
    if (!mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: r.ok ? DsResultatType.succes : DsResultatType.erreur,
        titre: l10n.pmSynchro,
        message: r.ok ? l10n.synchroResultat(r.envoyes, r.recus) : l10n.synchroErreur(r.erreur ?? ''),
      ),
    );
  }

  // ------------------------------------------------------------------ Boutique

  List<Widget> _boutique(AppLocalizations l10n) {
    const lw = 150.0;
    Widget champ(String cle, String libelle, TextEditingController c, {bool obligatoire = false, String? aide}) =>
        DsFormRow(
          libelle: libelle,
          obligatoire: obligatoire,
          largeurLibelle: lw,
          aide: aide,
          child: DsTextField(key: ValueKey(cle), controller: c),
        );
    return [
      DsCard(
        titre: l10n.pmGrpBoutique,
        icone: LucideIcons.store,
        child: DsGrilleFormulaire(
          children: [
            DsSpan(
              child: DsFormRow(
                libelle: l10n.pmLogo,
                largeurLibelle: lw,
                alignerDebut: true,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DsPhotoUploader(
                    max: 1,
                    photos: [
                      if (_logo.isNotEmpty) DsPhoto(id: 'logo', nom: _logo.split(RegExp(r'[\\/]')).last, chemin: _logo),
                    ],
                    onAjouter: _choisirLogo,
                    onRetirer: (_) => _changer(() => _logo = ''),
                    aide: l10n.pmLogoAide,
                    libelleAjouter: l10n.dsAjouter,
                    libellePrincipale: l10n.pmLogo,
                    libelleFin: '',
                  ),
                ),
              ),
            ),
            champ('param_nom', l10n.pmRaisonSociale, _nom, obligatoire: true),
            champ('param_telephone', l10n.pmTelephone, _telephone),
            DsSpan(child: champ('param_adresse', l10n.pmAdresse, _adresse)),
            champ('param_rc', l10n.pmRc, _rc),
            champ('param_nif', l10n.pmNif, _nif),
            champ('param_nis', l10n.pmNis, _nis),
            champ('param_article', l10n.pmArticle, _article),
            DsSpan(child: champ('param_email', l10n.pmEmail, _email)),
            DsSpan(
              child: DsFormRow(
                libelle: l10n.pmMessage,
                largeurLibelle: lw,
                alignerDebut: true,
                aide: l10n.pmMessageAide,
                child: DsTextField(
                  key: const ValueKey('param_message'),
                  controller: _message,
                  multiligne: true,
                  lignes: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _choisirLogo() async {
    final f = await ref.read(selecteurFichierProvider)(['png', 'jpg', 'jpeg']);
    if (f != null && mounted) _changer(() => _logo = f);
  }

  // ------------------------------------------------------------------ Caisse et ventes

  List<Widget> _caisse(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    Widget mode(String valeur, bool actif, {ValueChanged<bool>? onChanged}) => AnimatedContainer(
      duration: DsMotion.fast,
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: DsSpacing.s2 + 2),
      decoration: BoxDecoration(
        color: actif ? c.primaryTint : c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: actif ? c.primary : c.borderDefault),
      ),
      child: DsSwitch(
        cle: ValueKey('param_mode_$valeur'),
        valeur: actif,
        libelle: libelleRef(context, Referentiel.modesPaiement, valeur),
        actif: onChanged != null,
        onChanged: onChanged ?? (_) {},
      ),
    );
    return [
      DsCard(
        titre: l10n.pmModesTitre,
        icone: LucideIcons.wallet,
        info: l10n.pmModesInfo,
        child: LayoutBuilder(
          builder: (context, contraintes) {
            final n = (contraintes.maxWidth / 220).floor().clamp(1, 5);
            final largeur = (contraintes.maxWidth - DsSpacing.s2 * (n - 1)) / n;
            final modes = [
              mode('Espèces', true),
              mode(
                'Carte',
                _paiements.carte,
                onChanged: (v) => _changer(() => _paiements = _paiements.copyWith(carte: v)),
              ),
              mode(
                'Chèque',
                _paiements.cheque,
                onChanged: (v) => _changer(() => _paiements = _paiements.copyWith(cheque: v)),
              ),
              mode(
                'Virement',
                _paiements.virement,
                onChanged: (v) => _changer(() => _paiements = _paiements.copyWith(virement: v)),
              ),
              // Les points ne se proposent qu'avec le bonus fidélité actif (Caisse et ventes › Fidélité).
              mode(
                'Points',
                _paiements.points && _fidelite,
                onChanged: _fidelite ? (v) => _changer(() => _paiements = _paiements.copyWith(points: v)) : null,
              ),
            ];
            return Wrap(
              spacing: DsSpacing.s2,
              runSpacing: DsSpacing.s2,
              children: [for (final m in modes) SizedBox(width: largeur, child: m)],
            );
          },
        ),
      ),
      DsCard(
        titre: l10n.pmReglesTitre,
        icone: LucideIcons.shieldCheck,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ligne(
              l10n.pmSousAchat,
              description: l10n.pmSousAchatDesc,
              child: DsSegmentedControl<String>(
                key: const ValueKey('param_sous_achat'),
                valeur: _venteSousAchat,
                options: [
                  for (final v in [
                    ParametresVente.venteSousAchatAutoriser,
                    ParametresVente.venteSousAchatAvertir,
                    ParametresVente.venteSousAchatInterdire,
                  ])
                    DsOption(v, libelle: libelleRef(context, Referentiel.ventesSousAchat, v)),
                ],
                onChanged: (v) => _changer(() => _venteSousAchat = v),
              ),
            ),
            _interrupteur(
              'param_garde',
              l10n.pmGarde,
              description: l10n.pmGardeCaisseDesc,
              valeur: true,
              actif: false,
              derniere: true,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
      DsCard(
        titre: l10n.pmFideliteTitre,
        icone: LucideIcons.star,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _interrupteur(
              'param_fidelite',
              l10n.pmBonus,
              description: l10n.pmBonusDesc,
              valeur: _fidelite,
              onChanged: (v) => _changer(() => _fidelite = v),
            ),
            _ligne(
              l10n.pmTauxGain,
              description: l10n.pmTauxGainDesc,
              derniere: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DsSpacing.s2,
                children: [
                  _nombre('param_points', _pointsGain, largeur: 80, actif: _fidelite),
                  Text(l10n.pmPointPar, style: t.bodySm.copyWith(color: c.textSecondary)),
                  _nombre('param_tranche', _tranche, largeur: 120, suffixe: _devise, actif: _fidelite),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ------------------------------------------------------------------ Impression

  List<Widget> _impression(AppLocalizations l10n) {
    final escPos = _typeImprimante != TypesImprimante.normale;
    final (libelleAdresse, indice) = switch (_typeImprimante) {
      TypesImprimante.reseau => (l10n.pmAdresseIp, '192.168.1.50:9100'),
      TypesImprimante.bluetooth => (l10n.pmAdresseBluetooth, 'XP-P323B'),
      _ => (l10n.pmFileUsb, 'POS-80'),
    };
    return [
      DsCard(
        titre: l10n.pmImprimanteTitre,
        icone: LucideIcons.printer,
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DsSpacing.s2,
          children: [
            DsButton(
              key: const ValueKey('param_apercu'),
              libelle: l10n.posApercuTicket,
              icone: LucideIcons.eye,
              variante: DsButtonVariante.secondaire,
              taille: DsButtonTaille.sm,
              onPressed: _apercuTicket,
            ),
            DsButton(
              key: const ValueKey('param_test'),
              libelle: l10n.pmTest,
              icone: LucideIcons.printer,
              variante: DsButtonVariante.doux,
              taille: DsButtonTaille.sm,
              onPressed: escPos ? _imprimerTest : null,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsSpacing.s3 + 2,
          children: [
            DsChoiceCards<String>(
              key: const ValueKey('param_imprimante_type'),
              petit: true,
              colonnes: 4,
              valeur: _typeImprimante,
              onChanged: (v) => _changer(() {
                _typeImprimante = v;
                _testEnvoye = null;
              }),
              options: [
                DsOption(
                  TypesImprimante.bluetooth,
                  libelle: l10n.pmTypeBluetooth,
                  icone: LucideIcons.bluetooth,
                  description: l10n.pmTypeBluetoothDesc,
                ),
                DsOption(
                  TypesImprimante.usb,
                  libelle: l10n.pmTypeUsb,
                  icone: LucideIcons.usb,
                  description: l10n.pmTypeUsbDesc,
                ),
                DsOption(
                  TypesImprimante.reseau,
                  libelle: l10n.pmTypeReseau,
                  icone: LucideIcons.network,
                  description: l10n.pmTypeReseauDesc,
                ),
                DsOption(
                  TypesImprimante.normale,
                  libelle: l10n.pmTypeNormale,
                  icone: LucideIcons.printer,
                  description: l10n.pmTypeNormaleDesc,
                ),
              ],
            ),
            Wrap(
              spacing: DsSpacing.s4,
              runSpacing: DsSpacing.s3,
              children: [
                if (escPos)
                  SizedBox(
                    width: 320,
                    child: DsTextField(
                      key: const ValueKey('param_imprimante_adresse'),
                      controller: _adresseImprimante,
                      libelle: libelleAdresse,
                      indice: indice,
                      obligatoire: true,
                    ),
                  ),
                SizedBox(
                  width: 200,
                  child: DsSelect<String>(
                    key: const ValueKey('param_largeur'),
                    titre: l10n.pmLargeur,
                    valeur: _largeur,
                    options: const ['58', '80'],
                    libelle: (v) => '$v mm',
                    onChanged: (v) => _changer(() => _largeur = v ?? _largeur),
                  ),
                ),
              ],
            ),
            if (_testEnvoye != null)
              DsNote(ton: DsBadgeTon.succes, icone: LucideIcons.circleCheck, texte: l10n.pmTestOk(_testEnvoye!)),
          ],
        ),
      ),
    ];
  }

  /// Aperçu du ticket sur la dernière vente, sinon sur un ticket d'exemple.
  Future<void> _apercuTicket() async {
    final derniere = (await VenteRepository(ref.read(appDatabaseProvider).db).ventes(limite: 1)).firstOrNull;
    final vente = derniere == null
        ? null
        : await VenteRepository(ref.read(appDatabaseProvider).db).vente(derniere.code);
    if (!mounted) return;
    if (vente == null) afficherToast(context, titre: AppLocalizations.of(context).pmApercuAucuneVente);
    await afficherApercuTicket(context, ref, vente ?? _venteExemple());
  }

  static Vente _venteExemple() {
    const lignes = [
      VenteLigne(
        ordre: 1,
        produitCode: 'PRD0001',
        designation: 'Lait 1 L',
        quantite: 3,
        uniteVente: 'Pièce',
        prixUnitaire: 100,
        remise: 0,
        total: 300,
      ),
      VenteLigne(
        ordre: 2,
        produitCode: 'PRD0002',
        designation: 'Huile 1 L',
        quantite: 2,
        uniteVente: 'Pièce',
        prixUnitaire: 420,
        remise: 0,
        total: 840,
      ),
    ];
    return Vente(
      code: 'VTE0000',
      date: DateTime.now(),
      sessionCode: '',
      caisseCode: 'CIS0000',
      magasinCode: 'MAG0000',
      clientCode: 'CLN0000',
      utilisateurCode: '',
      totalBrut: 1140,
      totalRemise: 0,
      totalNet: 1140,
      verse: 1200,
      reste: 0,
      hash: '0' * 64,
      hashPrecedent: '0' * 64,
      lignes: lignes,
      paiements: const [Paiement(mode: 'Espèces', montant: 1200)],
    );
  }

  Future<void> _imprimerTest() async {
    final l10n = AppLocalizations.of(context);
    final transport = construireImprimante(_typeImprimante, _adresseImprimante.text.trim());
    if (transport == null || _adresseImprimante.text.trim().isEmpty) {
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.pmTest,
          message: l10n.parametresErreurImprimanteAdresse,
        ),
      );
      return;
    }
    try {
      await transport.envoyer(
        TicketEscPos(
          largeur: _largeur == '58' ? LargeurTicket.mm58 : LargeurTicket.mm80,
          libelles: LibellesTicket.fr,
        ).pageTest(boutique: _nom.text.trim().isEmpty ? 'CaisseDZ' : _nom.text.trim(), titre: l10n.pmTest),
      );
      if (mounted) setState(() => _testEnvoye = _adresseImprimante.text.trim());
    } on ImpressionException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.pmTest,
          message: l10n.posImpressionErreur(e.message),
        ),
      );
    }
  }

  // ------------------------------------------------------------------ Alertes

  List<Widget> _alertes(AppLocalizations l10n) => [
    DsCard(
      titre: l10n.pmGrpAlertes,
      icone: LucideIcons.bell,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _interrupteur(
            'param_alertes_connexion',
            l10n.pmAlertesConnexion,
            description: l10n.pmAlertesConnexionDesc,
            valeur: _alertesConnexion,
            onChanged: (v) => _changer(() => _alertesConnexion = v),
          ),
          _ligne(
            l10n.pmSeuilCredit,
            description: l10n.pmSeuilCreditDesc,
            derniere: true,
            child: _nombre('param_seuil_credit', _seuilCredit, largeur: 160, suffixe: _devise),
          ),
        ],
      ),
    ),
  ];

  // ------------------------------------------------------------------ Sauvegarde

  List<Widget> _sauvegarde(AppLocalizations l10n) {
    final service = ref.watch(sauvegardeServiceProvider);
    return [
      if (service.restaurationEnAttente)
        DsNote(
          ton: DsBadgeTon.avertissement,
          icone: LucideIcons.triangleAlert,
          texte: l10n.sauvegardeRestaurationEnAttente,
          action: DsButton(
            libelle: l10n.sauvegardeAnnulerRestauration,
            variante: DsButtonVariante.secondaire,
            taille: DsButtonTaille.sm,
            onPressed: () async {
              await service.annulerRestauration();
              if (mounted) setState(() {});
            },
          ),
        ),
      DsCard(
        titre: l10n.pmGrpSauvegarde,
        icone: LucideIcons.databaseBackup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ligne(
              l10n.pmSauvegardeDossier,
              description: l10n.pmSauvegardeDossierDesc,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DsSpacing.s2,
                children: [
                  SizedBox(
                    width: 260,
                    child: DsTextField(
                      key: ValueKey('param_sauvegarde_dossier_${_sauvegardeAuto.dossier}'),
                      valeurInitiale: _sauvegardeAuto.dossier,
                      iconePrefixe: LucideIcons.folder,
                      actif: false,
                    ),
                  ),
                  DsButton(
                    key: const ValueKey('param_sauvegarde_changer'),
                    libelle: l10n.pmSauvegardeChanger,
                    icone: LucideIcons.folderOpen,
                    variante: DsButtonVariante.secondaire,
                    onPressed: _choisirDossierSauvegarde,
                  ),
                ],
              ),
            ),
            _ligne(
              l10n.pmSauvegardeAuto,
              description: l10n.pmSauvegardeAutoDesc,
              child: DsSegmentedControl<String>(
                key: const ValueKey('param_sauvegarde_frequence'),
                valeur: _sauvegardeAuto.frequence,
                options: [
                  for (final f in FrequencesSauvegarde.toutes) DsOption(f, libelle: _libelleFrequence(l10n, f)),
                ],
                onChanged: _changerFrequence,
              ),
            ),
            if (_sauvegardeAuto.active)
              _ligne(
                l10n.pmSauvegardeMdp,
                description: l10n.pmSauvegardeMdpDesc,
                child: DsButton(
                  key: const ValueKey('param_sauvegarde_mdp'),
                  libelle: _sauvegardeAuto.motDePasse.isEmpty
                      ? l10n.pmSauvegardeMdpDefinir
                      : l10n.pmSauvegardeMdpChanger,
                  icone: LucideIcons.keyRound,
                  variante: DsButtonVariante.secondaire,
                  onPressed: _definirMotDePasseAuto,
                ),
              ),
            _ligne(
              l10n.pmSauverMaintenant,
              description: _sauvegardeAuto.derniere == null
                  ? l10n.sauvegardeIntro
                  : l10n.pmSauvegardeDerniere(
                      DateFormat('dd/MM/yyyy HH:mm').format(_sauvegardeAuto.derniere!.toLocal()),
                    ),
              child: DsButton(
                key: const ValueKey('param_sauvegarder'),
                libelle: l10n.pmSauverMaintenant,
                icone: LucideIcons.save,
                onPressed: _sauvegarder,
              ),
            ),
            _ligne(
              l10n.sauvegardeRestaurer,
              description: l10n.pmRestaurerDesc,
              derniere: true,
              child: DsButton(
                key: const ValueKey('param_restaurer'),
                libelle: l10n.pmRestaurerBouton,
                icone: LucideIcons.history,
                variante: DsButtonVariante.secondaire,
                onPressed: _restaurer,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  static String _libelleFrequence(AppLocalizations l10n, String f) => switch (f) {
    FrequencesSauvegarde.demarrage => l10n.pmFrequenceDemarrage,
    FrequencesSauvegarde.quotidienne => l10n.pmFrequenceQuotidienne,
    _ => l10n.pmFrequenceDesactivee,
  };

  Future<void> _choisirDossierSauvegarde() async {
    final dossier = await ref.read(selecteurDossierProvider)();
    if (dossier == null || !mounted) return;
    _changer(() => _sauvegardeAuto = _sauvegardeAuto.copyWith(dossier: dossier));
  }

  /// Activer la sauvegarde automatique demande le mot de passe des fichiers s'il n'est pas encore défini.
  Future<void> _changerFrequence(String f) async {
    _changer(() => _sauvegardeAuto = _sauvegardeAuto.copyWith(frequence: f));
    if (f != FrequencesSauvegarde.desactivee && _sauvegardeAuto.motDePasse.isEmpty) await _definirMotDePasseAuto();
  }

  Future<void> _definirMotDePasseAuto() async {
    final mdp = await _demanderMotDePasse(AppLocalizations.of(context).pmSauvegardeMdp);
    if (mdp == null || !mounted) return;
    _changer(() => _sauvegardeAuto = _sauvegardeAuto.copyWith(motDePasse: mdp));
  }

  /// Saisie du mot de passe d'une sauvegarde (chiffrement ou déchiffrement).
  Future<String?> _demanderMotDePasse(String titre) =>
      afficherDialog<String>(context, builder: (_) => _MotDePasseDialog(titre: titre));

  Future<void> _sauvegarder() async {
    final l10n = AppLocalizations.of(context);
    final motDePasse = await _demanderMotDePasse(l10n.pmSauverMaintenant);
    if (motDePasse == null || !mounted) return;
    final d = DateTime.now();
    String p2(int v) => v.toString().padLeft(2, '0');
    final nom = 'caissedz_${d.year}${p2(d.month)}${p2(d.day)}_${p2(d.hour)}${p2(d.minute)}.cdz';
    final chemin = await ref.read(selecteurEnregistrementProvider)(nom, 'cdz');
    if (chemin == null || !mounted) return;
    try {
      await ref.read(sauvegardeServiceProvider).sauvegarder(chemin: chemin, motDePasse: motDePasse);
      if (!mounted) return;
      afficherToast(context, titre: l10n.pmSauvegardeTerminee, description: chemin, ton: DsToastTon.succes);
    } on SauvegardeException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.pmSauverMaintenant,
          message: messageErreurSauvegarde(l10n, e),
        ),
      );
    }
  }

  Future<void> _restaurer() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(sauvegardeServiceProvider);
    final ok = await afficherConfirmation(
      context,
      titre: l10n.pmRestaurerConfirmTitre,
      message: l10n.pmRestaurerConfirmMsg,
      libelleConfirmer: l10n.pmRestaurerConfirmOk,
      icone: LucideIcons.history,
      destructif: true,
    );
    if (!ok || !mounted) return;
    final chemin = await ref.read(selecteurFichierProvider)(['cdz']);
    if (chemin == null || !mounted) return;
    final motDePasse = await _demanderMotDePasse(l10n.sauvegardeRestaurer);
    if (motDePasse == null || !mounted) return;
    try {
      final info = await service.verifier(chemin: chemin, motDePasse: motDePasse);
      if (!mounted) return;
      final confirme = await afficherConfirmation(
        context,
        titre: l10n.sauvegardeRestaurer,
        message:
            '${l10n.sauvegardeInfo(info.boutique, info.nbVentes, info.nbProduits, info.version)}\n\n${l10n.sauvegardeConfirmerRestauration}',
        destructif: true,
      );
      if (!confirme || !mounted) return;
      await service.preparerRestauration(chemin: chemin, motDePasse: motDePasse);
      if (!mounted) return;
      setState(() {});
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.avertissement,
          titre: l10n.sauvegardeRestaurer,
          message: l10n.sauvegardeRestaurationPreparee,
        ),
      );
    } on SauvegardeException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.sauvegardeRestaurer,
          message: messageErreurSauvegarde(l10n, e),
        ),
      );
    }
  }

  // ------------------------------------------------------------------ Licence

  List<Widget> _licence(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final licence = ref.watch(licenceProvider);
    final (palier, detail) = switch (licence) {
      Licence(demo: true) => (l10n.pmPalierDemo, l10n.pmPalierDemoDesc),
      Licence(niveau: NiveauLicence.avance) => (l10n.pmPalierAvance, l10n.pmPalierAvanceDesc),
      Licence(niveau: NiveauLicence.basic) => (l10n.pmPalierBasic, l10n.pmPalierBasicDesc),
      _ => (l10n.pmPalierAucun, l10n.pmPalierAucunDesc),
    };
    final cle = licence.cle;
    final cleMasquee = cle == null || cle.isEmpty
        ? '—'
        : (cle.length <= 8 ? cle : '${cle.substring(0, cle.length > 12 ? 12 : cle.length ~/ 2)}-••••-••••');
    return [
      DsCard(
        titre: l10n.pmGrpLicence,
        icone: LucideIcons.keyRound,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(DsSpacing.s4),
              margin: const EdgeInsets.only(bottom: DsSpacing.s2),
              decoration: BoxDecoration(gradient: DsColors.gradientNight, borderRadius: DsRadius.borderLg),
              child: Row(
                spacing: DsSpacing.s4,
                children: [
                  const Icon(LucideIcons.sparkles, size: 24, color: DsColors.blanc),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(palier, style: t.heading.copyWith(color: DsColors.blanc)),
                        Text(detail, style: t.bodySm.copyWith(color: DsColors.blanc.withValues(alpha: .8))),
                      ],
                    ),
                  ),
                  if (licence.estActivee) DsBadge(libelle: l10n.pmActive, ton: DsBadgeTon.succes, point: true),
                ],
              ),
            ),
            _ligne(
              l10n.pmCle,
              description: licence.activeeLe == null
                  ? l10n.pmCleDesc
                  : '${l10n.pmCleDesc} ${l10n.pmActiveeLe(DateFormat('dd/MM/yyyy').format(licence.activeeLe!.toLocal()))}',
              child: Text(cleMasquee, style: t.mono.copyWith(color: c.textPrimary, letterSpacing: 1.1)),
            ),
            _ligne(
              l10n.pmGererLicence,
              description: l10n.pmGererLicenceDesc,
              derniere: true,
              child: DsButton(
                key: const ValueKey('param_licence'),
                libelle: l10n.pmGererLicence,
                icone: LucideIcons.refreshCw,
                variante: DsButtonVariante.secondaire,
                onPressed: () => context.push(ActivationPage.route),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _MotDePasseDialog extends StatefulWidget {
  const _MotDePasseDialog({required this.titre});
  final String titre;

  @override
  State<_MotDePasseDialog> createState() => _MotDePasseDialogState();
}

class _MotDePasseDialogState extends State<_MotDePasseDialog> {
  final _mdp = TextEditingController();

  @override
  void dispose() {
    _mdp.dispose();
    super.dispose();
  }

  void _valider() {
    if (_mdp.text.isNotEmpty) Navigator.of(context).pop(_mdp.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsDialog(
      titre: widget.titre,
      iconeData: LucideIcons.keyRound,
      description: l10n.sauvegardeIntro,
      largeur: 520,
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('sauvegarde_mdp_ok'),
          libelle: l10n.dsValider,
          icone: LucideIcons.check,
          onPressed: _mdp.text.isEmpty ? null : _valider,
        ),
      ],
      contenu: DsFormRow(
        libelle: l10n.sauvegardeMotDePasse,
        obligatoire: true,
        child: DsTextField(
          key: const ValueKey('sauvegarde_mdp'),
          controller: _mdp,
          obscur: true,
          autofocus: true,
          iconePrefixe: LucideIcons.keyRound,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _valider(),
        ),
      ),
    );
  }
}
