import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';

/// Indicateur d'étapes horizontal (assistants).
class DsStepper extends StatelessWidget {
  const DsStepper({super.key, required this.etapes, required this.courante});

  final List<String> etapes;
  final int courante;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Row(
      children: [
        for (final (i, e) in etapes.indexed) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: DsSpacing.sm),
                color: i <= courante ? c.primaire : c.bordure,
              ),
            ),
          Flexible(
            flex: 3,
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: DsMotion.normal,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < courante ? c.primaire : (i == courante ? c.primaireDoux : c.surfaceAttenuee),
                  border: Border.all(color: i <= courante ? c.primaire : c.bordureForte, width: i == courante ? 2 : 1),
                ),
                child: Center(
                  child: i < courante
                      ? Icon(LucideIcons.check, size: 14, color: c.surPrimaire)
                      : Text('${i + 1}', style: t.petitFort.copyWith(color: i == courante ? c.primaire : c.texteAttenue)),
                ),
              ),
              const SizedBox(width: DsSpacing.sm),
              Flexible(
                child: Text(
                  e,
                  style: (i == courante ? t.petitFort : t.petit).copyWith(color: i == courante ? c.texte : c.texteSecondaire),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ),
        ],
      ],
    );
  }
}
