import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/catalogue/catalogue_rayons_api.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../data/catalogue_rayons_repository.dart';
import '../../domain/models/rayon_catalogue.dart';
import '../produits/produits_providers.dart';
import 'catalogue_rayons_providers.dart';

/// Ouvre le choix des rayons du catalogue BENS. [accueil] : proposé après la connexion (« Plus tard » ne le
/// repropose plus ; Produits › Catalogue BENS reste disponible). Le bilan si des produits ont été téléchargés.
Future<ResultatTelechargement?> afficherCatalogueRayons(BuildContext context, {bool accueil = false}) =>
    afficherDialog<ResultatTelechargement>(
      context,
      fermableParVoile: false,
      builder: (_) => CatalogueRayonsDialog(accueil: accueil),
    );

/// Icône Lucide d'un rayon (nom envoyé par le catalogue).
IconData iconeRayon(String nom) => switch (nom) {
  'baby' => LucideIcons.baby,
  'paw-print' => LucideIcons.pawPrint,
  'pill' => LucideIcons.pill,
  'sparkles' => LucideIcons.sparkles,
  'hand-heart' => LucideIcons.handHeart,
  'spray-can' => LucideIcons.sprayCan,
  'coffee' => LucideIcons.coffee,
  'cup-soda' => LucideIcons.cupSoda,
  'milk' => LucideIcons.milk,
  'cookie' => LucideIcons.cookie,
  'soup' => LucideIcons.soup,
  'snowflake' => LucideIcons.snowflake,
  'beef' => LucideIcons.beef,
  'shopping-basket' => LucideIcons.shoppingBasket,
  'pencil' => LucideIcons.pencil,
  'wrench' => LucideIcons.wrench,
  _ => LucideIcons.package,
};

enum _Etape { chargement, indisponible, choix, telechargement, bilan }

/// Rayons du catalogue BENS (`CatalogueRayonsService`) : cartes à cocher selon l'activité (nombre de produits
/// proposés par rayon), « Appliquer » télécharge leurs produits (sans prix ni stock), puis le bilan :
/// produits ajoutés et leur part (%) des rayons choisis, rayon par rayon.
class CatalogueRayonsDialog extends ConsumerStatefulWidget {
  const CatalogueRayonsDialog({super.key, this.accueil = false});

  final bool accueil;

  @override
  ConsumerState<CatalogueRayonsDialog> createState() => _CatalogueRayonsDialogState();
}

class _CatalogueRayonsDialogState extends ConsumerState<CatalogueRayonsDialog> {
  var _etape = _Etape.chargement;
  List<RayonCatalogue> _rayons = const [];
  Map<String, RayonImporte> _importes = const {};
  final Set<String> _choisis = {};
  ProgresTelechargement? _progres;
  ResultatTelechargement? _bilan;
  bool _echec = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _etape = _Etape.chargement);
    final service = ref.read(catalogueRayonsServiceProvider);
    try {
      final rayons = await service.rayons();
      final importes = await service.rayonsImportes();
      if (!mounted) return;
      setState(() {
        _rayons = rayons;
        _importes = importes;
        _etape = _Etape.choix;
      });
    } on CatalogueRayonsException {
      if (mounted) setState(() => _etape = _Etape.indisponible);
    }
  }

  List<RayonCatalogue> get _selection => [
    for (final r in _rayons)
      if (_choisis.contains(r.code)) r,
  ];

  Future<void> _plusTard() async {
    if (widget.accueil) await ref.read(catalogueRayonsServiceProvider).marquerPropose();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _appliquer() async {
    final choix = _selection;
    if (choix.isEmpty) return;
    setState(() {
      _etape = _Etape.telechargement;
      _echec = false;
      _progres = null;
    });
    try {
      final bilan = await ref
          .read(catalogueRayonsServiceProvider)
          .telecharger(choix, onProgres: (p) => mounted ? setState(() => _progres = p) : null);
      ref.read(catalogueVersionProvider.notifier).incrementer();
      // Le tableau de bord BENS voit ce que chaque client télécharge (hors ligne : au prochain lancement).
      unawaited(
        ref.read(licenceServiceProvider).signalerChoixCatalogue([
          for (final r in bilan.rayons)
            {'code': r.rayon.code, 'name': r.rayon.nomFr, 'available': r.disponibles, 'downloaded': r.telecharges},
        ]),
      );
      if (!mounted) return;
      setState(() {
        _bilan = bilan;
        _etape = _Etape.bilan;
      });
    } on CatalogueRayonsException {
      if (mounted) {
        setState(() {
          _echec = true;
          _etape = _Etape.choix;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (_etape) {
      _Etape.bilan => _vueBilan(l10n, _bilan!),
      _Etape.telechargement => DsDialog(
        key: const ValueKey('dialog_catalogue_rayons'),
        titre: l10n.catalogueRayonsTitre,
        iconeData: LucideIcons.download,
        largeur: 560,
        fermable: false,
        contenu: _vueProgres(l10n),
      ),
      _ => DsDialog(
        key: const ValueKey('dialog_catalogue_rayons'),
        titre: l10n.catalogueRayonsTitre,
        message: l10n.catalogueRayonsSousTitre,
        iconeData: LucideIcons.store,
        largeur: 920,
        fermable: !widget.accueil,
        piedDebut: _etape == _Etape.choix ? _compteur(l10n) : null,
        contenu: switch (_etape) {
          _Etape.chargement => _vueChargement(l10n),
          _Etape.indisponible => DsNote(
            texte: l10n.catalogueRayonsHorsLigne,
            ton: DsBadgeTon.avertissement,
            icone: LucideIcons.wifiOff,
          ),
          _ => _vueChoix(l10n),
        },
        actions: [
          DsButton(
            key: const ValueKey('rayons_plus_tard'),
            libelle: widget.accueil ? l10n.catalogueRayonsPlusTard : l10n.communFermer,
            variante: DsButtonVariante.secondaire,
            onPressed: _plusTard,
          ),
          if (_etape == _Etape.indisponible)
            DsButton(
              key: const ValueKey('rayons_reessayer'),
              libelle: l10n.catalogueRayonsReessayer,
              icone: LucideIcons.refreshCw,
              onPressed: _charger,
            )
          else
            DsButton(
              key: const ValueKey('rayons_appliquer'),
              libelle: l10n.catalogueRayonsAppliquer,
              icone: LucideIcons.download,
              onPressed: _etape == _Etape.choix && _choisis.isNotEmpty ? _appliquer : null,
            ),
        ],
      ),
    };
  }

  Widget _vueChargement(AppLocalizations l10n) {
    final t = context.ds.typo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: DsSpacing.s3,
        children: [
          const DsSpinner(),
          Text(l10n.catalogueRayonsChargement, style: t.body.copyWith(color: context.ds.colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _compteur(AppLocalizations l10n) {
    final produits = _selection.fold(0, (n, r) => n + r.produits);
    return Text(
      l10n.catalogueRayonsSelection(_choisis.length, formaterNombre(produits.toDouble())),
      key: const ValueKey('rayons_compteur'),
      style: context.ds.typo.bodySmStrong.copyWith(color: context.ds.colors.textSecondary),
    );
  }

  Widget _vueChoix(AppLocalizations l10n) {
    final disponibles = [
      for (final r in _rayons)
        if (r.produits > 0) r.code,
    ];
    final tous = disponibles.isNotEmpty && disponibles.every(_choisis.contains);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        if (_echec) DsNote(texte: l10n.catalogueRayonsEchec, ton: DsBadgeTon.danger, icone: LucideIcons.triangleAlert),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: DsButton(
            key: const ValueKey('rayons_tout'),
            libelle: tous ? l10n.catalogueRayonsToutDeselectionner : l10n.catalogueRayonsToutSelectionner,
            icone: tous ? LucideIcons.squareMinus : LucideIcons.squareCheck,
            variante: DsButtonVariante.fantome,
            taille: DsButtonTaille.sm,
            onPressed: disponibles.isEmpty
                ? null
                : () => setState(() => tous ? _choisis.clear() : _choisis.addAll(disponibles)),
          ),
        ),
        LayoutBuilder(
          builder: (context, contraintes) {
            const colonnes = 3;
            final largeur = (contraintes.maxWidth - DsSpacing.s3 * (colonnes - 1)) / colonnes;
            final langue = ref.watch(localeProvider).languageCode;
            return Wrap(
              spacing: DsSpacing.s3,
              runSpacing: DsSpacing.s3,
              children: [
                for (final r in _rayons)
                  SizedBox(
                    width: largeur,
                    child: _CarteRayon(
                      key: ValueKey('rayon_${r.code}'),
                      rayon: r,
                      nom: r.nom(langue),
                      choisi: _choisis.contains(r.code),
                      dejaTelecharge: _importes.containsKey(r.code),
                      onTap: r.produits == 0
                          ? null
                          : () => setState(
                              () => _choisis.contains(r.code) ? _choisis.remove(r.code) : _choisis.add(r.code),
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _vueProgres(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final p = _progres;
    final langue = ref.watch(localeProvider).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.s3,
      children: [
        Text(
          p == null ? l10n.catalogueRayonsChargement : l10n.catalogueRayonsTelechargement(p.rayon.nom(langue)),
          style: t.bodyStrong,
        ),
        DsProgressBar(
          key: const ValueKey('rayons_progres'),
          valeur: (p?.recus ?? 0).toDouble(),
          max: (p?.attendus ?? 0) == 0 ? 1 : p!.attendus.toDouble(),
          hauteur: 8,
        ),
        if (p != null)
          Text(
            l10n.catalogueRayonsProgres(formaterNombre(p.recus.toDouble()), formaterNombre(p.attendus.toDouble())),
            style: t.bodySm.copyWith(color: c.textSecondary),
          ),
      ],
    );
  }

  Widget _vueBilan(AppLocalizations l10n, ResultatTelechargement b) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final langue = ref.watch(localeProvider).languageCode;
    String pct(double v) => formaterNombre(v, decimales: v == v.roundToDouble() ? 0 : 1);
    return DsDialog(
      key: const ValueKey('dialog_catalogue_rayons_bilan'),
      titre: l10n.catalogueRayonsResultatTitre,
      message: l10n.catalogueRayonsResultatMessage(formaterNombre(b.telecharges.toDouble()), pct(b.pourcentage)),
      iconeData: LucideIcons.packageCheck,
      ton: DsDialogTon.succes,
      largeur: 620,
      fermable: false,
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          for (final r in b.rayons)
            Row(
              key: ValueKey('bilan_${r.rayon.code}'),
              spacing: DsSpacing.s3,
              children: [
                Icon(iconeRayon(r.rayon.icone), size: 18, color: c.iconDefault),
                SizedBox(
                  width: 200,
                  child: Text(r.rayon.nom(langue), style: t.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: DsProgressBar(
                    valeur: r.telecharges.toDouble(),
                    max: r.disponibles == 0 ? 1 : r.disponibles.toDouble(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    l10n.catalogueRayonsLigne(
                      formaterNombre(r.telecharges.toDouble()),
                      formaterNombre(r.disponibles.toDouble()),
                      pct(r.pourcentage),
                    ),
                    textAlign: TextAlign.end,
                    style: t.bodySmStrong.copyWith(
                      color: c.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          if (b.dejaPresents > 0)
            DsNote(
              texte: l10n.catalogueRayonsDejaPresents(formaterNombre(b.dejaPresents.toDouble())),
              icone: LucideIcons.info,
            ),
          DsNote(texte: l10n.catalogueRayonsSansPrix, ton: DsBadgeTon.avertissement, icone: LucideIcons.tag),
        ],
      ),
      actions: [
        DsButton(
          key: const ValueKey('rayons_continuer'),
          libelle: l10n.catalogueRayonsContinuer,
          onPressed: () => Navigator.of(context).pop(b),
        ),
      ],
    );
  }
}

/// Carte d'un rayon : icône, nom, produits proposés ; cochée (bordure et fond primaires) quand choisie.
class _CarteRayon extends StatefulWidget {
  const _CarteRayon({
    super.key,
    required this.rayon,
    required this.nom,
    required this.choisi,
    required this.dejaTelecharge,
    required this.onTap,
  });

  final RayonCatalogue rayon;
  final String nom;
  final bool choisi;
  final bool dejaTelecharge;
  final VoidCallback? onTap;

  static const double hauteur = 100;

  @override
  State<_CarteRayon> createState() => _CarteRayonState();
}

class _CarteRayonState extends State<_CarteRayon> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final on = widget.choisi;
    final actif = widget.onTap != null;
    return Semantics(
      button: true,
      selected: on,
      enabled: actif,
      label: widget.nom,
      child: MouseRegion(
        cursor: actif ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _survol = true),
        onExit: (_) => setState(() => _survol = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Opacity(
            opacity: actif ? 1 : .55,
            child: AnimatedContainer(
              duration: DsMotion.fast,
              curve: DsMotion.standard,
              // Hauteur fixe : les cartes d'une rangée restent alignées (noms sur deux lignes au plus).
              height: _CarteRayon.hauteur,
              padding: const EdgeInsets.all(DsSpacing.s3),
              decoration: BoxDecoration(
                color: on ? c.primaryTint : (_survol && actif ? c.surfaceHover : c.surfaceCard),
                borderRadius: DsRadius.borderLg,
                border: Border.all(color: on ? c.primary : c.borderDefault),
                boxShadow: on ? [BoxShadow(color: c.primary, spreadRadius: 1)] : c.shadowXs,
              ),
              child: Row(
                spacing: DsSpacing.s3,
                children: [
                  AnimatedContainer(
                    duration: DsMotion.fast,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: on ? c.primary : c.surfaceSunken, borderRadius: DsRadius.borderMd),
                    child: Icon(iconeRayon(widget.rayon.icone), size: 20, color: on ? c.primaryFg : c.iconDefault),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(widget.nom, style: t.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: widget.rayon.produits == 0
                                    ? l10n.catalogueRayonsBientot
                                    : l10n.catalogueRayonsNbProduits(formaterNombre(widget.rayon.produits.toDouble())),
                              ),
                              if (widget.rayon.tendances > 0 && !widget.dejaTelecharge)
                                TextSpan(
                                  text:
                                      ' · ${l10n.catalogueRayonsNbTendances(formaterNombre(widget.rayon.tendances.toDouble()))}',
                                  style: TextStyle(color: c.primary),
                                ),
                              if (widget.dejaTelecharge)
                                TextSpan(
                                  text: ' · ${l10n.catalogueRayonsDejaTelecharge}',
                                  style: TextStyle(color: c.successFg),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySm.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  DsCheckbox(valeur: on, onChanged: actif ? (_) => widget.onTap!() : null, semantique: widget.nom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
