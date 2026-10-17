import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Couleur la plus utilisée d'un logo (ARGB), pour habiller les documents à la couleur de la boutique.
///
/// Les pixels transparents, blancs, noirs et gris sont ignorés ; les couleurs sont regroupées par teinte proche
/// (16 niveaux par canal) puis moyennées. Une couleur trop claire est assombrie pour rester lisible sous un texte
/// blanc. `null` si l'image est illisible ou sans couleur franche.
int? couleurDominante(Uint8List octets) {
  final img.Image? image;
  try {
    image = img.decodeImage(octets);
  } on Object {
    return null;
  }
  if (image == null) return null;
  final petite = image.width > 96 ? img.copyResize(image, width: 96) : image;
  final compte = <int, int>{};
  final sommes = <int, List<int>>{};
  for (final p in petite) {
    if (p.aNormalized < .5) continue;
    final r = (p.rNormalized * 255).round();
    final g = (p.gNormalized * 255).round();
    final b = (p.bNormalized * 255).round();
    final max = [r, g, b].reduce((a, c) => a > c ? a : c);
    final min = [r, g, b].reduce((a, c) => a < c ? a : c);
    if (max - min < 40 || max < 40) continue;
    final cle = (r >> 4) << 8 | (g >> 4) << 4 | (b >> 4);
    compte[cle] = (compte[cle] ?? 0) + 1;
    final s = sommes.putIfAbsent(cle, () => [0, 0, 0]);
    s[0] += r;
    s[1] += g;
    s[2] += b;
  }
  if (compte.isEmpty) return null;
  final cle = compte.entries.reduce((a, c) => c.value > a.value ? c : a).key;
  final n = compte[cle]!;
  var (r, g, b) = (sommes[cle]![0] ~/ n, sommes[cle]![1] ~/ n, sommes[cle]![2] ~/ n);
  final luminance = (.299 * r + .587 * g + .114 * b) / 255;
  if (luminance > .6) {
    final f = .6 / luminance;
    (r, g, b) = ((r * f).round(), (g * f).round(), (b * f).round());
  }
  return 0xFF000000 | r << 16 | g << 8 | b;
}
