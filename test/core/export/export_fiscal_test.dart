import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/cloture_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/export/export_fiscal.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/bases.dart';

void main() {
  test('export fiscal : archive, JSON vérifiable, altération détectée', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final lait = await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
      ),
    );
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
    final sessions = SessionCaisseService(db, utilisateurCode: 'USR0000');
    final s = await sessions.ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    for (var i = 0; i < 2; i++) {
      await ventes.encaisser(
        Panier(id: i)
            .ajouter(PanierLigne(produit: lait, quantite: 1, prixUnitaire: 100, remisePct: 5))
            .ajouterPaiement(const Paiement(mode: 'Espèces', montant: 100)),
        session: s,
        magasinCode: 'MAG0000',
      );
    }
    await sessions.fermer(montantCompte: 190);
    await ClotureService(db, utilisateurCode: 'USR0000').cloturer(caisseCode: 'CIS0000');
    final export = ExportFiscal(db);
    final zip = await export.generer(
      debut: DateTime(2000),
      fin: DateTime.now().add(const Duration(minutes: 1)),
      utilisateurCode: 'USR0000',
    );
    final archive = ZipDecoder().decodeBytes(zip);
    expect(archive.map((f) => f.name), containsAll(['export.json', 'ventes.csv', 'clotures.csv', 'LISEZMOI.txt']));
    final json = jsonDecode(utf8.decode(archive.findFile('export.json')!.content as List<int>)) as Map;
    expect((json['donnees']['ventes'] as List).length, 2);
    expect((json['donnees']['clotures'] as List).length, 1);
    expect(json['logiciel']['nom'], ExportFiscal.nomLogiciel);
    expect(utf8.decode(archive.findFile('ventes.csv')!.content as List<int>), contains('VTE0002'));
    final ok = ExportFiscal.verifier(zip);
    expect(ok.valide, isTrue, reason: ok.erreurs.join(', '));
    expect(ok.nbVentes, 2);
    expect(ok.nbClotures, 1);
    // Variantes JSON seul et CSV des tickets (ExportFiscalDialog).
    final seul = await export.genererJson(debut: DateTime(2000), fin: DateTime.now(), utilisateurCode: 'USR0000');
    expect(ExportFiscal.verifier(seul).valide, isTrue);
    final csv = await export.genererCsv(debut: DateTime(2000), fin: DateTime.now(), utilisateurCode: 'USR0000');
    expect(csv.take(3), [0xEF, 0xBB, 0xBF]);
    expect(utf8.decode(csv.skip(3).toList()), contains('VTE0002'));
    expect(utf8.decode(archive.findFile('clotures.csv')!.content as List<int>), contains('CIS0000'));
    // Le JSON brut se vérifie aussi.
    final brut = Uint8List.fromList(utf8.encode(jsonEncode(json)));
    expect(ExportFiscal.verifier(brut).valide, isTrue);
    // Altération d'un montant : empreinte et chaîne des ventes invalides.
    (json['donnees']['ventes'] as List)[0]['total_net'] = 1;
    final altere = ExportFiscal.verifier(Uint8List.fromList(utf8.encode(jsonEncode(json))));
    expect(altere.valide, isFalse);
    expect(altere.empreinteOk, isFalse);
    expect(altere.chaineVentesOk, isFalse);
    expect(altere.chaineCloturesOk, isTrue);
    expect(altere.erreurs, contains('vente VTE0001'));
    expect(ExportFiscal.verifier(Uint8List.fromList([1, 2, 3])).valide, isFalse);
  });
}
