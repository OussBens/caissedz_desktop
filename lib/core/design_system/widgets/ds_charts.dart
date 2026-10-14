import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../tokens/ds_theme.dart';
import 'ds_primitives.dart';

/// Point d'une série de graphique.
typedef DsPoint = ({String etiquette, double valeur});

/// Palette sémantique des séries (tokens uniquement).
List<Color> paletteGraphique(BuildContext context) {
  final c = context.ds.colors;
  return [c.primaire, c.succes, c.info, c.avertissement, c.danger, c.texteAttenue];
}

String _abreger(double v) {
  if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(v.abs() >= 10000 ? 0 : 1)}k';
  return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

/// Carte de graphique : titre + zone de tracé de hauteur fixe.
class DsCarteGraphique extends StatelessWidget {
  const DsCarteGraphique({super.key, required this.titre, required this.child, this.hauteur = 220, this.sousTitre});
  final String titre;
  final String? sousTitre;
  final double hauteur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final c = context.ds.colors;
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: t.titreSm),
          if (sousTitre != null) Text(sousTitre!, style: t.petit.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.md),
          SizedBox(height: hauteur, child: child),
        ],
      ),
    );
  }
}

/// Courbe (ex. CA par jour).
class DsGraphiqueLignes extends StatelessWidget {
  const DsGraphiqueLignes({super.key, required this.points, this.pasEtiquettes});
  final List<DsPoint> points;

  /// Une étiquette d'axe toutes les [pasEtiquettes] valeurs (calculé automatiquement si `null`).
  final int? pasEtiquettes;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final max = points.fold(0.0, (m, p) => p.valeur > m ? p.valeur : m);
    if (points.isEmpty || max == 0) {
      return Center(
        child: Text('—', style: t.petit.copyWith(color: c.texteAttenue)),
      );
    }
    final pas = pasEtiquettes ?? (points.length / 6).ceil().clamp(1, 1000);
    final style = t.legende.copyWith(color: c.texteSecondaire);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: max == 0 ? 1 : max * 1.15,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: c.bordure, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(_abreger(v), style: style),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.round();
                if (i < 0 || i >= points.length || i % pas != 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(points[i].etiquette, style: style),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.surfaceElevee,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${points[s.x.round()].etiquette}\n${_abreger(s.y)}',
                  t.petitFort.copyWith(color: c.texte),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (i, p) in points.indexed) FlSpot(i.toDouble(), p.valeur)],
            isCurved: true,
            curveSmoothness: 0.25,
            preventCurveOverShooting: true,
            color: c.primaire,
            barWidth: 2.5,
            dotData: FlDotData(show: points.length <= 31),
            belowBarData: BarAreaData(show: true, color: c.primaireDoux),
          ),
        ],
      ),
    );
  }
}

/// Barres verticales (ex. CA par mois, ventes par catégorie, top produits).
class DsGraphiqueBarres extends StatelessWidget {
  const DsGraphiqueBarres({super.key, required this.barres, this.couleur, this.largeurEtiquette = 10});
  final List<DsPoint> barres;
  final Color? couleur;

  /// Nombre maximal de caractères affichés par étiquette.
  final int largeurEtiquette;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final max = barres.fold(0.0, (m, p) => p.valeur > m ? p.valeur : m);
    if (barres.isEmpty || max == 0) {
      return Center(
        child: Text('—', style: t.petit.copyWith(color: c.texteAttenue)),
      );
    }
    final style = t.legende.copyWith(color: c.texteSecondaire);
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: max == 0 ? 1 : max * 1.15,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: c.bordure, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(_abreger(v), style: style),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, meta) {
                final i = v.round();
                if (i < 0 || i >= barres.length) return const SizedBox.shrink();
                final e = barres[i].etiquette;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(e.length > largeurEtiquette ? '${e.substring(0, largeurEtiquette)}…' : e, style: style),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => c.surfaceElevee,
            getTooltipItem: (g, gi, rod, ri) =>
                BarTooltipItem('${barres[gi].etiquette}\n${_abreger(rod.toY)}', t.petitFort.copyWith(color: c.texte)),
          ),
        ),
        barGroups: [
          for (final (i, p) in barres.indexed)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: p.valeur,
                  color: couleur ?? c.primaire,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Secteurs avec légende (ex. paiements par mode).
class DsGraphiqueSecteurs extends StatelessWidget {
  const DsGraphiqueSecteurs({super.key, required this.parts, this.formatValeur});
  final List<DsPoint> parts;
  final String Function(double)? formatValeur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final palette = paletteGraphique(context);
    final total = parts.fold(0.0, (s, p) => s + p.valeur);
    if (parts.isEmpty || total <= 0) {
      return Center(
        child: Text('—', style: t.petit.copyWith(color: c.texteAttenue)),
      );
    }
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (final (i, p) in parts.indexed)
                  PieChartSectionData(
                    value: p.valeur,
                    color: palette[i % palette.length],
                    radius: 44,
                    title: '${(p.valeur / total * 100).round()}%',
                    titleStyle: t.legende.copyWith(color: c.surface),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: DsSpacing.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, p) in parts.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: palette[i % palette.length], shape: BoxShape.circle),
                      ),
                      const SizedBox(width: DsSpacing.xs),
                      Expanded(
                        child: Text(p.etiquette, style: t.petit, overflow: TextOverflow.ellipsis),
                      ),
                      Text(formatValeur?.call(p.valeur) ?? _abreger(p.valeur), style: t.petitFort),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
