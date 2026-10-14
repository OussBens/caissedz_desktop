import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// Types d'imprimante ticket (valeur stockée FR, Paramètres).
class TypesImprimante {
  const TypesImprimante._();
  static const String normale = 'Normale'; // via le dialogue d'impression système (PDF)
  static const String usb = 'USB'; // spouleur Windows (brut ESC/POS)
  static const String reseau = 'Réseau'; // IP:port
  static const String bluetooth = 'Bluetooth';
  static const List<String> tous = [normale, usb, reseau, bluetooth];
}

class ImpressionException implements Exception {
  const ImpressionException(this.message);
  final String message;
  @override
  String toString() => 'ImpressionException($message)';
}

/// Transport d'octets ESC/POS vers une imprimante ticket.
abstract class ImprimanteEscPos {
  Future<void> envoyer(Uint8List donnees);
}

/// Imprimante réseau (IP:port, généralement 9100).
class ImprimanteReseau implements ImprimanteEscPos {
  const ImprimanteReseau(this.hote, {this.port = 9100, this.delai = const Duration(seconds: 5)});
  final String hote;
  final int port;
  final Duration delai;

  @override
  Future<void> envoyer(Uint8List donnees) async {
    Socket socket;
    try {
      socket = await Socket.connect(hote, port, timeout: delai);
    } on Object catch (e) {
      throw ImpressionException('Connexion impossible à $hote:$port ($e)');
    }
    try {
      socket.add(donnees);
      await socket.flush();
    } finally {
      await socket.close();
    }
  }
}

/// Imprimante USB via le spouleur Windows (données brutes « RAW », winspool.drv).
class ImprimanteUsbSpouleur implements ImprimanteEscPos {
  const ImprimanteUsbSpouleur(this.nomImprimante);
  final String nomImprimante;

  @override
  Future<void> envoyer(Uint8List donnees) async {
    if (!Platform.isWindows) throw const ImpressionException('Spouleur Windows indisponible sur cette plateforme');
    final spool = DynamicLibrary.open('winspool.drv');
    final openPrinter = spool
        .lookupFunction<
          Int32 Function(Pointer<Utf16>, Pointer<IntPtr>, Pointer<Void>),
          int Function(Pointer<Utf16>, Pointer<IntPtr>, Pointer<Void>)
        >('OpenPrinterW');
    final startDoc = spool
        .lookupFunction<
          Uint32 Function(IntPtr, Uint32, Pointer<_DocInfo1>),
          int Function(int, int, Pointer<_DocInfo1>)
        >('StartDocPrinterW');
    final startPage = spool.lookupFunction<Int32 Function(IntPtr), int Function(int)>('StartPagePrinter');
    final write = spool
        .lookupFunction<
          Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>),
          int Function(int, Pointer<Uint8>, int, Pointer<Uint32>)
        >('WritePrinter');
    final endPage = spool.lookupFunction<Int32 Function(IntPtr), int Function(int)>('EndPagePrinter');
    final endDoc = spool.lookupFunction<Int32 Function(IntPtr), int Function(int)>('EndDocPrinter');
    final close = spool.lookupFunction<Int32 Function(IntPtr), int Function(int)>('ClosePrinter');
    using((arena) {
      final handle = arena<IntPtr>();
      if (openPrinter(nomImprimante.toNativeUtf16(allocator: arena), handle, nullptr) == 0) {
        throw ImpressionException('Imprimante « $nomImprimante » introuvable');
      }
      final h = handle.value;
      try {
        final doc = arena<_DocInfo1>();
        doc.ref.pDocName = 'CaisseDZ ticket'.toNativeUtf16(allocator: arena);
        doc.ref.pOutputFile = nullptr;
        doc.ref.pDatatype = 'RAW'.toNativeUtf16(allocator: arena);
        if (startDoc(h, 1, doc) == 0) throw const ImpressionException('StartDocPrinter a échoué');
        try {
          startPage(h);
          final tampon = arena<Uint8>(donnees.length);
          tampon.asTypedList(donnees.length).setAll(0, donnees);
          final ecrits = arena<Uint32>();
          if (write(h, tampon, donnees.length, ecrits) == 0) throw const ImpressionException('WritePrinter a échoué');
          endPage(h);
        } finally {
          endDoc(h);
        }
      } finally {
        close(h);
      }
    });
  }
}

/// DOC_INFO_1W (winspool).
final class _DocInfo1 extends Struct {
  external Pointer<Utf16> pDocName;
  external Pointer<Utf16> pOutputFile;
  external Pointer<Utf16> pDatatype;
}

/// Imprimante Bluetooth.
///
/// ⚠️ ÉCART : sous Windows, une imprimante Bluetooth SPP est exposée comme port
/// COM ; l'accès série n'est pas disponible dans le SDK Dart sans plugin natif.
/// En attendant, l'appariement Windows crée aussi une file d'impression : on
/// passe alors par le spouleur (même chemin que l'USB).
class ImprimanteBluetooth implements ImprimanteEscPos {
  const ImprimanteBluetooth(this.nomFileImpression);
  final String nomFileImpression;

  @override
  Future<void> envoyer(Uint8List donnees) => ImprimanteUsbSpouleur(nomFileImpression).envoyer(donnees);
}

/// Imprimante factice (tests) : conserve les octets envoyés.
class ImprimanteMemoire implements ImprimanteEscPos {
  final List<Uint8List> envoyes = [];
  @override
  Future<void> envoyer(Uint8List donnees) async => envoyes.add(donnees);
}
