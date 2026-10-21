/// The raw device identifier on desktops, for [DeviceCode.fromRawId].
/// (Android apps read `Settings.Secure.ANDROID_ID` through a method channel.)
library;

import 'dart:io';

/// Windows: the MachineGuid set at install. Linux: /etc/machine-id. macOS:
/// the hardware UUID. Null when it can't be read; the app should then keep
/// a random id of its own (and say a licence may need re-issuing after a
/// reinstall).
Future<String?> desktopMachineId() async {
  try {
    if (Platform.isWindows) {
      final r = await Process.run('reg', ['query', r'HKLM\SOFTWARE\Microsoft\Cryptography', '/v', 'MachineGuid']);
      final m = RegExp(r'MachineGuid\s+REG_SZ\s+(\S+)').firstMatch('${r.stdout}');
      return m?.group(1)?.toLowerCase();
    }
    if (Platform.isLinux) {
      for (final path in ['/etc/machine-id', '/var/lib/dbus/machine-id']) {
        final f = File(path);
        if (await f.exists()) {
          final id = (await f.readAsString()).trim();
          if (id.isNotEmpty) return id;
        }
      }
      return null;
    }
    if (Platform.isMacOS) {
      final r = await Process.run('ioreg', ['-rd1', '-c', 'IOPlatformExpertDevice']);
      return RegExp(r'"IOPlatformUUID" = "([^"]+)"').firstMatch('${r.stdout}')?.group(1);
    }
  } on Exception {
    return null;
  }
  return null;
}
