import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../domain/models/rapport.dart';

/// Export Excel (.xlsx) d'un rapport tabulaire.
class ExportExcel {
  const ExportExcel._();

  static Uint8List rapport(Rapport r, {String? sousTitre}) {
    final excel = Excel.createExcel();
    final nomFeuille = r.titre.length > 31 ? r.titre.substring(0, 31) : r.titre;
    final feuille = excel[nomFeuille];
    excel.setDefaultSheet(nomFeuille);
    for (final s in excel.sheets.keys.toList()) {
      if (s != nomFeuille) excel.delete(s);
    }
    feuille.appendRow([TextCellValue(r.titre)]);
    if (sousTitre != null) feuille.appendRow([TextCellValue(sousTitre)]);
    feuille.appendRow([TextCellValue('')]);
    feuille.appendRow([for (final c in r.colonnes) TextCellValue(c.libelle)]);
    for (final l in r.lignes) {
      feuille.appendRow([for (final v in l) _cellule(v)]);
    }
    if (r.totaux != null) feuille.appendRow([for (final v in r.totaux!) _cellule(v)]);
    return Uint8List.fromList(excel.encode()!);
  }

  static CellValue? _cellule(Object? v) => switch (v) {
    null => null,
    final int i => IntCellValue(i),
    final double d => DoubleCellValue(d),
    _ => TextCellValue(v.toString()),
  };
}
