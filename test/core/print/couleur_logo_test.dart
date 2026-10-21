import 'dart:io';
import 'dart:typed_data';

import 'package:caissedz_desktop/core/print/couleur_logo.dart';
import 'package:caissedz_desktop/core/print/documents_pdf.dart';
import 'package:caissedz_desktop/core/print/ticket_escpos.dart';
import 'package:caissedz_desktop/domain/models/facture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Logo de test : fond blanc, texte noir, 60 % de rouge et 15 % de bleu.
Uint8List _logo() {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  img.fillRect(image, x1: 0, y1: 0, x2: 39, y2: 23, color: img.ColorRgb8(0xD3, 0x2F, 0x2F));
  img.fillRect(image, x1: 0, y1: 24, x2: 39, y2: 29, color: img.ColorRgb8(0x19, 0x76, 0xD2));
  img.fillRect(image, x1: 0, y1: 30, x2: 39, y2: 33, color: img.ColorRgb8(0, 0, 0));
  return img.encodePng(image);
}

void main() {
  test('couleur la plus utilisée du logo, hors blanc / noir / gris', () {
    final c = couleurDominante(_logo())!;
    expect(c & 0xFFFFFF, 0xD32F2F);
  });

  test('logo sans couleur franche ou illisible : pas de couleur (violet par défaut)', () {
    final gris = img.Image(width: 10, height: 10);
    img.fill(gris, color: img.ColorRgb8(128, 128, 128));
    expect(couleurDominante(img.encodePng(gris)), isNull);
    expect(couleurDominante(Uint8List.fromList([1, 2, 3])), isNull);
  });

  test('couleur trop claire assombrie pour rester lisible sous un texte blanc', () {
    final jaune = img.Image(width: 10, height: 10);
    img.fill(jaune, color: img.ColorRgb8(255, 235, 59));
    final c = couleurDominante(img.encodePng(jaune))!;
    final r = c >> 16 & 0xFF, g = c >> 8 & 0xFF, b = c & 0xFF;
    expect((.299 * r + .587 * g + .114 * b) / 255, lessThanOrEqualTo(.61));
  });

  test('documents A4 et ticket avec logo et couleur de la boutique', () async {
    final logo = _logo();
    final pdf = DocumentsPdf(libelles: LibellesTicket.fr, logo: logo, couleur: couleurDominante(logo));
    final octets = await pdf.documentCommercial(
      titre: 'Devis',
      numero: 'DEV0001',
      date: DateTime(2026, 10, 17),
      emetteur: const IdentiteFiscale(nom: 'Superette El Baraka'),
      libelleTiers: 'Client',
      tiers: const IdentiteFiscale(nom: 'Amina'),
      entetes: const ['Désignation', 'Qté'],
      lignes: const [
        ['Lait 1 L', '2'],
      ],
    );
    expect(String.fromCharCodes(octets.take(4)), '%PDF');
    // Un logo illisible n'empêche pas l'impression.
    final sansLogo = DocumentsPdf(libelles: LibellesTicket.fr, logo: Uint8List.fromList([1, 2, 3]));
    expect(
      (await sansLogo.documentCommercial(
        titre: 'Devis',
        numero: 'DEV0002',
        date: DateTime(2026, 10, 17),
        emetteur: const IdentiteFiscale(nom: 'X'),
        libelleTiers: 'Client',
        tiers: const IdentiteFiscale(nom: 'Y'),
        entetes: const ['A'],
        lignes: const [],
      )).isNotEmpty,
      isTrue,
    );
    if (Platform.environment['APERCU_LOGO'] case final chemin?) await File(chemin).writeAsBytes(octets);
  });
}
