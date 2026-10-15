import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Outil de mise au point (non utilisé par la suite de tests) : charge les vraies polices puis enregistre une
/// capture PNG de l'écran courant, pour vérifier une mise en page sans poste Windows.
Future<void> chargerPolices() async {
  Future<void> famille(String nom, List<String> fichiers) async {
    final f = FontLoader(nom);
    for (final x in fichiers) {
      f.addFont(rootBundle.load(x));
    }
    await f.load();
  }

  await famille('PlusJakartaSans', [
    for (final p in [400, 500, 600, 700, 800]) 'assets/fonts/PlusJakartaSans-$p.ttf',
  ]);
  await famille('Cairo', [
    for (final p in [400, 500, 600, 700, 800]) 'assets/fonts/Cairo-$p.ttf',
  ]);
  await famille('packages/lucide_icons_flutter/Lucide', ['packages/lucide_icons_flutter/assets/lucide.ttf']);
}

Future<void> capturer(WidgetTester tester, String chemin) async {
  await tester.runAsync(() async {
    final vue = tester.binding.renderViews.first;
    final couche = vue.debugLayer! as OffsetLayer;
    final image = await couche.toImage(Offset.zero & vue.size);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(chemin)
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}
