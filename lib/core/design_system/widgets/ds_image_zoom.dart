import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Aperçu d'image zoomable : la molette zoome (avant / arrière) sous le pointeur, un clic maintenu fait glisser
/// l'image agrandie ; les boutons en surimpression zooment au centre ou ramènent l'image entière.
class DsImageZoom extends StatefulWidget {
  const DsImageZoom({super.key, required this.image, required this.hauteur, this.erreur});
  final ImageProvider image;
  final double hauteur;

  /// Affiché si l'image ne peut pas être décodée.
  final Widget? erreur;

  static const double zoomMax = 8;

  @override
  State<DsImageZoom> createState() => _DsImageZoomState();
}

class _DsImageZoomState extends State<DsImageZoom> {
  final _transformation = TransformationController();
  final _cadre = GlobalKey();
  bool _glisse = false;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_rafraichir);
  }

  @override
  void dispose() {
    _transformation
      ..removeListener(_rafraichir)
      ..dispose();
    super.dispose();
  }

  void _rafraichir() => setState(() {});

  double get _echelle => _transformation.value.getMaxScaleOnAxis();

  /// Zoom au centre du cadre.
  void _zoomer(double facteur) {
    final taille = _cadre.currentContext?.size;
    if (taille == null) return;
    final cible = (_echelle * facteur).clamp(1.0, DsImageZoom.zoomMax);
    final f = cible / _echelle;
    final centre = taille.center(Offset.zero);
    final m = Matrix4.identity()
      ..translateByDouble(centre.dx, centre.dy, 0, 1)
      ..scaleByDouble(f, f, 1, 1)
      ..translateByDouble(-centre.dx, -centre.dy, 0, 1);
    _transformation.value = cible == 1 ? Matrix4.identity() : m.multiplied(_transformation.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final l10n = AppLocalizations.of(context);
    final agrandie = _echelle > 1.001;
    return ClipRRect(
      borderRadius: DsRadius.borderMd,
      child: ColoredBox(
        color: c.surfaceSunken,
        child: SizedBox(
          height: widget.hauteur,
          child: Stack(
            children: [
              Positioned.fill(
                child: MouseRegion(
                  cursor: !agrandie
                      ? SystemMouseCursors.zoomIn
                      : _glisse
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.grab,
                  child: InteractiveViewer(
                    key: _cadre,
                    transformationController: _transformation,
                    maxScale: DsImageZoom.zoomMax,
                    onInteractionStart: (_) => setState(() => _glisse = true),
                    onInteractionEnd: (_) => setState(() => _glisse = false),
                    child: Center(
                      child: Image(
                        image: widget.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => widget.erreur ?? const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: DsSpacing.s2,
                end: DsSpacing.s2,
                child: Container(
                  padding: const EdgeInsets.all(DsSpacing.s1),
                  decoration: BoxDecoration(
                    color: c.surfaceCard,
                    borderRadius: DsRadius.borderMd,
                    border: Border.all(color: c.borderSubtle),
                    boxShadow: DsShadows.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DsIconButton(
                        key: const ValueKey('image_zoom_moins'),
                        icone: LucideIcons.zoomOut,
                        tooltip: l10n.dsZoomArriere,
                        taille: DsTailles.controleSm,
                        onPressed: agrandie ? () => _zoomer(1 / 1.5) : null,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${(_echelle * 100).round()} %',
                          key: const ValueKey('image_zoom_niveau'),
                          textAlign: TextAlign.center,
                          style: context.ds.typo.caption.copyWith(color: c.textSecondary),
                        ),
                      ),
                      DsIconButton(
                        key: const ValueKey('image_zoom_plus'),
                        icone: LucideIcons.zoomIn,
                        tooltip: l10n.dsZoomAvant,
                        taille: DsTailles.controleSm,
                        onPressed: _echelle < DsImageZoom.zoomMax ? () => _zoomer(1.5) : null,
                      ),
                      DsIconButton(
                        key: const ValueKey('image_zoom_ajuster'),
                        icone: LucideIcons.maximize,
                        tooltip: l10n.dsZoomAjuster,
                        taille: DsTailles.controleSm,
                        onPressed: agrandie ? () => _transformation.value = Matrix4.identity() : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
