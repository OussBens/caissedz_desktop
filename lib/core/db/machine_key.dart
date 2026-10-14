import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Fournit un identifiant stable de la machine, source de la clé de chiffrement.
abstract class MachineIdentifiant {
  Future<String> lire();
}

/// Identifiant Windows : `MachineGuid` du registre (HKLM\SOFTWARE\Microsoft\Cryptography),
/// complété du nom de machine. Sur les autres plateformes (tests, CI) : nom d'hôte.
class MachineIdentifiantSysteme implements MachineIdentifiant {
  const MachineIdentifiantSysteme();

  @override
  Future<String> lire() async {
    final morceaux = <String>[Platform.localHostname];
    if (Platform.isWindows) {
      try {
        final r = await Process.run('reg', ['query', r'HKLM\SOFTWARE\Microsoft\Cryptography', '/v', 'MachineGuid']);
        final m = RegExp(r'MachineGuid\s+REG_SZ\s+(\S+)').firstMatch(r.stdout.toString());
        if (m != null) morceaux.add(m.group(1)!);
      } on ProcessException {
        // Registre inaccessible : on se contente du nom d'hôte.
      }
    }
    return morceaux.join('|');
  }
}

/// Dérivation de la clé SQLCipher à partir de la machine (§4.2).
///
/// ⚠️ PROVISOIRE : SHA-256 de (identifiant machine + sel applicatif), rendu en
/// hexadécimal (64 caractères). L'algorithme exact (sel, itérations, éléments
/// pris en compte) sera aligné sur le §4.2 de la spec dès réception.
class DerivationCle {
  const DerivationCle({this.identifiant = const MachineIdentifiantSysteme(), this.sel = selParDefaut});

  static const String selParDefaut = 'CaisseDZ-Desktop-v1';

  final MachineIdentifiant identifiant;
  final String sel;

  Future<String> cleHex() async {
    final id = await identifiant.lire();
    return deriver(id, sel);
  }

  /// Fonction pure, testable : SHA-256(sel || '|' || identifiant) en hexadécimal.
  static String deriver(String identifiant, String sel) => sha256.convert(utf8.encode('$sel|$identifiant')).toString();
}
