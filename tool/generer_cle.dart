// Génère les clés d'activation d'une machine (usage éditeur / tests).
//
//   dart run tool/generer_cle.dart                 → clés de la machine courante
//   dart run tool/generer_cle.dart "<identifiant>" → clés de l'identifiant affiché sur l'écran d'activation
//
// ⚠️ PROVISOIRE : même règle que `CleActivation.cleAttendue` (non importée ici car elle dépend de
// `dart:ui`, indisponible sous `dart run`) — SHA-256("CAISSEDZ|BASIC|M") / SHA-256("CAISSEDZ|AVANCE|M").
import 'dart:convert';
import 'dart:io';

import 'package:caissedz_desktop/core/db/machine_key.dart';
import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  final machine = args.isNotEmpty ? args.first : await const MachineIdentifiantSysteme().lire();
  String cle(String tag) => sha256.convert(utf8.encode('CAISSEDZ|$tag|$machine')).toString();
  stdout
    ..writeln('Machine : $machine')
    ..writeln('Basic   : ${cle('BASIC')}')
    ..writeln('Avancé  : ${cle('AVANCE')}');
}
