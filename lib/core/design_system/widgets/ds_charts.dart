import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../tokens/ds_theme.dart';
import 'ds_page.dart';
import 'ds_primitives.dart';

/// Point d'une série de graphique (compat lots 0 à 9).
typedef DsPoint = ({String etiquette, double valeur});

/// Série d'un [DsLineChart].
class DsSerie {
  const DsSerie({required this.nom, required this.valeurs, this.couleur, this.pointillee = false});
  final String nom;
  final List<double> valeurs;
  final Color? couleur;
  final bool pointillee;
}

/// Palette des séries (`--chart-1` … `--chart-6`).
List<Color> paletteGraphique(BuildContext context) => DsColors.chart;

/// Échelle « ronde » : maximum lisible (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10 × 10ⁿ).
double maxArrondi(double v) {
  if (v <= 0) return 1;
  var p = 1.0;
  while (p * 10 <= v) {
    p *= 10;
  }
  while (p > v) {
    p /= 10;
  }
  for (final m in const [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]) {
    if (m * p >= v) return m * p;
  }
  return 10 * p;
}

/// Carte de graphique : [DsCard] titrée + zone de tracé de hauteur fixe.
class DsCarteGraphique extends StatelessWidget {
  const DsCarteGraphique({
    super.key,
    required this.titre,
    required this.child,
    this.hauteur = 220,
    this.sousTitre,
    this.icone,
    this.actions,
    this.info,
  });
  final String titre;
  final String? sousTitre;
  final double hauteur;
  final Widget child;
  final IconData? icone;
  final Widget? actions;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final c = context.ds.colors;
    return DsCard(
      titre: titre,
      icone: icone,
      actions: actions,
      info: info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sousTitre != null) ...[
            Text(sousTitre!, style: t.caption.copyWith(color: c.textMuted)),
            const SizedBox(height: DsSpacing.s3),
          ],
          SizedBox(height: hauteur, child: child),
        ],
      ),
    );
  }
}

/// Courbe (`LineChart` v2.2) : une ou plusieurs séries sur des catégories, aire sous la première,
/// grille pointillée, graduations « k », info-bulle.
class DsLineChart extends StatelessWidget {
  const DsLineChart({
    super.key,
    required this.etiquettes,
    required this.series,
    this.aire = true,
    this.points = true,
    this.formater,
  });
  final List<String> etiquettes;
  final List<DsSerie> series;
  final bool aire;
  final bool points;
  final String Function(double)? formater;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final fmt = formater ?? formaterK;
    final n = etiquettes.length;
    final maxBrut = series.fold(0.0, (m, s) => s.valeurs.fold(m, (mm, v) => v > mm ? v : mm));
    if (n == 0 || series.isEmpty || maxBrut <= 0) {
      return Center(
        child: Text('—', style: t.bodySm.copyWith(color: c.textMuted)),
      );
    }
    final max = maxArrondi(maxBrut);
    final styleAxe = t.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w500, color: c.textMuted);
    return LayoutBuilder(
      builder: (context, contraintes) {
        final pas = (n / ((contraintes.maxWidth - 44) / 64).floor().clamp(2, 1000)).ceil().clamp(1, 1000);
        return Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: max,
                  minX: 0,
                  maxX: (n - 1).toDouble().clamp(0, double.infinity),
                  clipData: const FlClipData.none(),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: max / 4,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: c.borderSubtle, strokeWidth: 1, dashArray: v == 0 ? null : [3, 4]),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: max / 4,
                        getTitlesWidget: (v, meta) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Text(fmt(v), style: styleAxe, textAlign: TextAlign.end),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (v, meta) {
                          final i = v.round();
                          if (i < 0 || i >= n || (i % pas != 0 && i != n - 1)) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(etiquettes[i], style: styleAxe),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    getTouchedSpotIndicator: (bar, indices) => [
                      for (final _ in indices)
                        TouchedSpotIndicatorData(
                          FlLine(color: c.borderStrong, strokeWidth: 1, dashArray: [2, 3]),
                          FlDotData(
                            getDotPainter: (spot, _, bar, _) => FlDotCirclePainter(
                              radius: 4.5,
                              color: c.surfaceCard,
                              strokeColor: bar.color ?? c.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => c.surfaceRaised,
                      tooltipBorder: BorderSide(color: c.borderDefault),
                      tooltipBorderRadius: DsRadius.borderMd,
                      getTooltipItems: (spots) => [
                        for (final (k, s) in spots.indexed)
                          LineTooltipItem(
                            k == 0 ? '${etiquettes[s.x.round()]}\n' : '',
                            t.caption.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.textSecondary),
                            children: [
                              TextSpan(
                                text: '${series[s.barIndex].nom}  ',
                                style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary),
                              ),
                              TextSpan(
                                text: fmt(s.y),
                                style: t.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                  fontFeatures: DsTypography.tabular,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: [
                    for (final (si, s) in series.indexed)
                      LineChartBarData(
                        spots: [for (final (i, v) in s.valeurs.indexed) FlSpot(i.toDouble(), v)],
                        isCurved: false,
                        color: s.couleur ?? DsColors.chart[si % DsColors.chart.length],
                        barWidth: si == 0 ? 2.5 : 2,
                        dashArray: s.pointillee ? [5, 5] : null,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: points && n <= 12,
                          getDotPainter: (spot, _, bar, _) => FlDotCirclePainter(
                            radius: 3,
                            color: c.surfaceCard,
                            strokeColor: bar.color ?? c.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: aire && si == 0,
                          color: (s.couleur ?? DsColors.chart[0]).withValues(alpha: .10),
                        ),
                      ),
                  ],
                ),
                duration: DsMotion.slower,
                curve: DsMotion.emphasized,
              ),
            ),
            if (series.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    for (final (si, s) in series.indexed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Container(
                            width: 14,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: s.pointillee ? null : (s.couleur ?? DsColors.chart[si % DsColors.chart.length]),
                              border: s.pointillee
                                  ? Border(
                                      top: BorderSide(
                                        color: s.couleur ?? DsColors.chart[si % DsColors.chart.length],
                                        width: 2.5,
                                        style: BorderStyle.solid,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Text(
                            s.nom,
                            style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Courbe simple (compat) : une série sur des points étiquetés.
class DsGraphiqueLignes extends StatelessWidget {
  const DsGraphiqueLignes({super.key, required this.points, this.pasEtiquettes, this.nom = ''});
  final List<DsPoint> points;
  final int? pasEtiquettes;
  final String nom;

  @override
  Widget build(BuildContext context) => DsLineChart(
    etiquettes: [for (final p in points) p.etiquette],
    series: [
      DsSerie(nom: nom, valeurs: [for (final p in points) p.valeur]),
    ],
  );
}

/// Élément d'un [DsBarChart] / [DsRankedBars] / [DsDonutChart].
class DsDonnee {
  const DsDonnee({required this.libelle, required this.valeur, this.legende, this.couleur});
  final String libelle;
  final double valeur;
  final String? legende;
  final Color? couleur;
}

/// Barres verticales (`BarChart`) : barres arrondies 34 px max, piste `chartTrack`, barre
/// survolée / mise en avant en dégradé, valeur au-dessus.
class DsBarChart extends StatefulWidget {
  const DsBarChart({super.key, required this.donnees, this.miseEnAvant, this.formater, this.couleur});
  final List<DsDonnee> donnees;
  final int? miseEnAvant;
  final String Function(double)? formater;
  final Color? couleur;

  @override
  State<DsBarChart> createState() => _DsBarChartState();
}

class _DsBarChartState extends State<DsBarChart> {
  int? _survol;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final fmt = widget.formater ?? ((v) => formaterNombre(v));
    final d = widget.donnees;
    final max = d.fold(0.0, (m, x) => x.valeur > m ? x.valeur : m);
    if (d.isEmpty || max <= 0) {
      return Center(
        child: Text('—', style: t.bodySm.copyWith(color: c.textMuted)),
      );
    }
    final actif = _survol ?? widget.miseEnAvant;
    return LayoutBuilder(
      builder: (context, contraintes) {
        final hauteur = (contraintes.maxHeight - 54).clamp(10.0, double.infinity);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 12,
          children: [
            for (final (i, x) in d.indexed)
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _survol = i),
                  onExit: (_) => setState(() => _survol = null),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      AnimatedOpacity(
                        opacity: actif == i ? 1 : 0,
                        duration: DsMotion.base,
                        child: Text(
                          fmt(x.valeur),
                          style: t.bodySmStrong.copyWith(fontFeatures: DsTypography.tabular),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: (x.valeur / max * hauteur).clamp(6, hauteur)),
                        duration: DsMotion.slower,
                        curve: DsMotion.emphasized,
                        builder: (_, h, _) => AnimatedContainer(
                          duration: DsMotion.base,
                          height: h,
                          constraints: const BoxConstraints(maxWidth: 34),
                          decoration: BoxDecoration(
                            color: actif == i ? widget.couleur : c.chartTrack,
                            gradient: actif == i && widget.couleur == null ? DsColors.gradientBar : null,
                            borderRadius: DsRadius.borderMd,
                          ),
                        ),
                      ),
                      Text(
                        x.libelle,
                        style: t.caption.copyWith(
                          fontWeight: actif == i ? FontWeight.w600 : FontWeight.w400,
                          color: actif == i ? c.textPrimary : c.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Barres verticales (compat) sur des points étiquetés.
class DsGraphiqueBarres extends StatelessWidget {
  const DsGraphiqueBarres({super.key, required this.barres, this.couleur, this.largeurEtiquette = 10});
  final List<DsPoint> barres;
  final Color? couleur;
  final int largeurEtiquette;

  @override
  Widget build(BuildContext context) => DsBarChart(
    donnees: [
      for (final b in barres)
        DsDonnee(
          libelle: b.etiquette.length > largeurEtiquette
              ? '${b.etiquette.substring(0, largeurEtiquette)}…'
              : b.etiquette,
          valeur: b.valeur,
        ),
    ],
    miseEnAvant: barres.isEmpty ? null : _indexMax(barres),
    couleur: couleur,
  );

  static int _indexMax(List<DsPoint> pts) {
    var k = 0;
    for (var i = 1; i < pts.length; i++) {
      if (pts[i].valeur > pts[k].valeur) k = i;
    }
    return k;
  }
}

/// Classement horizontal (`RankedBars` v2.2) : rang 22 px (3 premiers teintés), libellé, valeur, jauge 6 px.
class DsRankedBars extends StatelessWidget {
  const DsRankedBars({
    super.key,
    required this.donnees,
    this.formater,
    this.max,
    this.couleur,
    this.afficherRang = true,
    this.onTap,
  });
  final List<DsDonnee> donnees;
  final String Function(double)? formater;
  final double? max;
  final Color? couleur;
  final bool afficherRang;
  final ValueChanged<DsDonnee>? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final fmt = formater ?? ((v) => formaterMontant(v));
    final m = max ?? donnees.fold<double>(1.0, (a, d) => d.valeur > a ? d.valeur : a);
    if (donnees.isEmpty) {
      return Center(
        child: Text('—', style: t.bodySm.copyWith(color: c.textMuted)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final (i, d) in donnees.indexed)
          MouseRegion(
            cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap!(d),
              child: Row(
                spacing: 10,
                children: [
                  if (afficherRang)
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < 3 ? c.primaryTint : c.surfaceSunken,
                        borderRadius: DsRadius.borderSm,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: t.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: i < 3 ? c.primaryTintFg : c.textMuted,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 5,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: d.libelle,
                                  children: [
                                    if (d.legende != null)
                                      TextSpan(
                                        text: ' · ${d.legende}',
                                        style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w400),
                                      ),
                                  ],
                                ),
                                style: t.bodySm.copyWith(fontWeight: FontWeight.w500, color: c.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              fmt(d.valeur),
                              style: t.bodySm.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                fontFeatures: DsTypography.tabular,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 6,
                            color: c.chartTrack,
                            alignment: AlignmentDirectional.centerStart,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: (d.valeur / m).clamp(0, 1)),
                              duration: DsMotion.slower,
                              curve: DsMotion.emphasized,
                              builder: (_, v, _) => FractionallySizedBox(
                                widthFactor: v,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: d.couleur ?? couleur ?? c.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Anneau (`DonutChart`) : piste `chartTrack`, parts palette, libellé et valeur au centre, légende.
class DsDonutChart extends StatefulWidget {
  const DsDonutChart({
    super.key,
    required this.donnees,
    this.taille = 180,
    this.epaisseur = 22,
    this.libelleCentre,
    this.valeurCentre,
    this.legende = true,
    this.formater,
  });
  final List<DsDonnee> donnees;
  final double taille;
  final double epaisseur;
  final String? libelleCentre;
  final String? valeurCentre;
  final bool legende;
  final String Function(double)? formater;

  static const palette = [0, 4, 3, 2, 5, 1];

  @override
  State<DsDonutChart> createState() => _DsDonutChartState();
}

class _DsDonutChartState extends State<DsDonutChart> {
  int? _survol;

  Color _couleur(int i) =>
      widget.donnees[i].couleur ?? DsColors.chart[DsDonutChart.palette[i % DsDonutChart.palette.length]];

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final d = widget.donnees;
    final total = d.fold(0.0, (a, x) => a + x.valeur);
    final fmt = widget.formater ?? ((v) => formaterMontant(v));
    final anneau = SizedBox(
      width: widget.taille,
      height: widget.taille,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (total <= 0)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.chartTrack, width: widget.epaisseur),
              ),
            )
          else
            PieChart(
              PieChartData(
                sectionsSpace: d.length > 1 ? 2 : 0,
                centerSpaceRadius: (widget.taille - 2 * widget.epaisseur) / 2,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (e, r) => setState(() => _survol = r?.touchedSection?.touchedSectionIndex),
                ),
                sections: [
                  for (final (i, x) in d.indexed)
                    PieChartSectionData(
                      value: x.valeur,
                      color: _couleur(i),
                      radius: _survol == i ? widget.epaisseur + 4 : widget.epaisseur,
                      showTitle: false,
                    ),
                ],
              ),
              duration: DsMotion.slower,
              curve: DsMotion.emphasized,
            ),
          IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _survol != null && _survol! < d.length ? d[_survol!].libelle : (widget.libelleCentre ?? ''),
                  style: t.caption.copyWith(fontWeight: FontWeight.w500, color: c.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _survol != null && _survol! < d.length && total > 0
                      ? '${(d[_survol!].valeur / total * 100).round()} %'
                      : (widget.valeurCentre ?? ''),
                  style: t.heading.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.4,
                    fontFeatures: DsTypography.tabular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!widget.legende) return Center(child: anneau);
    return Row(
      spacing: DsSpacing.s4,
      children: [
        anneau,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              for (final (i, x) in d.indexed)
                Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: _couleur(i), borderRadius: BorderRadius.circular(3)),
                    ),
                    Expanded(
                      child: Text(
                        x.libelle,
                        style: t.bodySm.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      total > 0 ? '${(x.valeur / total * 100).round()} %' : '—',
                      style: t.bodySm.copyWith(fontWeight: FontWeight.w600, fontFeatures: DsTypography.tabular),
                    ),
                    Flexible(
                      child: Text(
                        fmt(x.valeur),
                        textAlign: TextAlign.end,
                        style: t.caption.copyWith(color: c.textMuted, fontFeatures: DsTypography.tabular),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Secteurs (compat) sur des points étiquetés.
class DsGraphiqueSecteurs extends StatelessWidget {
  const DsGraphiqueSecteurs({super.key, required this.parts, this.devise = 'DA', this.formatValeur});
  final List<DsPoint> parts;
  final String devise;
  final String Function(double)? formatValeur;

  @override
  Widget build(BuildContext context) => DsDonutChart(
    donnees: [for (final p in parts) DsDonnee(libelle: p.etiquette, valeur: p.valeur)],
    taille: 150,
    epaisseur: 20,
    formater: formatValeur ?? (v) => formaterMontant(v, devise),
  );
}
