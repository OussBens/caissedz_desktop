import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../data/fiscalite_repository.dart';

/// Classeur d'aide à la déclaration G50 (TVA mensuelle et droit de timbre) : chiffre d'affaires HT et TVA
/// collectée par taux (retours déduits), TVA déductible des entrées, TVA à payer ou crédit, droits de timbre.
/// ⚠️ PROVISOIRE : présentation à aligner sur le formulaire G50 officiel et la spécification 06 (§12).
abstract final class ExportG50 {
  static Uint8List generer(DeclarationG50 d, {String nomBoutique = '', String nif = ''}) {
    final classeur = Excel.createExcel();
    final defaut = classeur.getDefaultSheet()!;
    classeur.rename(defaut, 'G50');
    final f = classeur['G50'];
    String jour(DateTime x) => '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
    CellValue n(double v) => DoubleCellValue(v);
    void ligne(List<Object> cellules) =>
        f.appendRow([for (final c in cellules) c is double ? n(c) : TextCellValue('$c')]);

    ligne(['Déclaration G50 — aide au remplissage']);
    ligne(['Entreprise', nomBoutique]);
    ligne(['NIF', nif]);
    ligne(['Période', '${jour(d.debut)} → ${jour(d.fin)}']);
    ligne([]);
    ligne([
      'TVA collectée',
      'Taux %',
      'Base HT ventes',
      'TVA ventes',
      'Base HT retours',
      'TVA retours',
      'Base HT nette',
      'TVA nette',
    ]);
    for (final t in d.taux) {
      final v = d.ventes[t] ?? (ht: 0.0, tva: 0.0);
      final r = d.retoursClients[t] ?? (ht: 0.0, tva: 0.0);
      ligne(['', t, v.ht, v.tva, r.ht, r.tva, v.ht - r.ht, v.tva - r.tva]);
    }
    ligne(['Total', '', '', '', '', '', d.caHt, d.tvaCollectee]);
    ligne([]);
    ligne(['TVA déductible', 'Taux %', 'Base HT entrées', 'TVA entrées', 'Base HT retours', 'TVA retours']);
    final tauxAchats = {...d.achats.keys, ...d.retoursFournisseurs.keys}.toList()..sort((a, b) => b.compareTo(a));
    for (final t in tauxAchats) {
      final a = d.achats[t] ?? (ht: 0.0, tva: 0.0);
      final r = d.retoursFournisseurs[t] ?? (ht: 0.0, tva: 0.0);
      ligne(['', t, a.ht, a.tva, r.ht, r.tva]);
    }
    ligne(['Total', '', '', '', '', d.tvaDeductible]);
    ligne([]);
    ligne(['TVA collectée', d.tvaCollectee]);
    ligne(['TVA déductible', d.tvaDeductible]);
    ligne([d.tvaNette >= 0 ? 'TVA à payer' : 'Crédit de TVA à reporter', d.tvaNette.abs()]);
    ligne(['Droits de timbre (factures payées en espèces)', d.timbre]);
    ligne(['Total à verser', (d.tvaNette > 0 ? d.tvaNette : 0) + d.timbre]);
    return Uint8List.fromList(classeur.encode()!);
  }
}
