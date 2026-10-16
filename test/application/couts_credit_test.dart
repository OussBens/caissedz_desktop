import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

Future<Produit> _produit(Database db, String nom, double pa, double pv, {int npu = 0}) =>
    CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
      Produit(
        code: '',
        designation: nom,
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: pa,
        prixVente: pv,
        suiviNombre: npu > 0,
        nombreParUnite: npu > 0 ? npu : 1,
      ),
    );

void main() {
  test('coût d\'une vente au nombre et plafond de crédit bloquant', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final eau = await _produit(db, 'Eau', 20, 30, npu: 6);
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: eau.code, magasinCode: 'MAG0000', quantite: 100, nombre: 600);
    final client = await TiersService(
      db,
      utilisateurCode: 'USR0000',
    ).creerClient(const Client(code: '', nom: 'Amina', plafondCredit: 500));
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    Future<double> vendreCredit(double pieces, double prix, {bool depassement = false}) async =>
        (await ventes.encaisser(
          Panier(
            id: 1,
            clientCode: client.code,
          ).ajouter(PanierLigne(produit: eau, quantite: pieces, uniteVente: UniteVente.nombre, prixUnitaire: prix)),
          session: session,
          magasinCode: 'MAG0000',
          creditAutorise: true,
          depassementPlafond: depassement,
        )).lignes.single.totalAchat;

    // 3 pièces d'un pack de 6 acheté 20 → coût 10 (et non 0).
    expect(await vendreCredit(3, 100), 10);
    // Crédit 300 ; +250 dépasserait le plafond de 500.
    await expectLater(
      vendreCredit(5, 50),
      throwsA(
        isA<VenteException>()
            .having((e) => e.erreur, 'e', ErreurVente.plafondCredit)
            .having((e) => e.detail, 'd', '500.0|300.0'),
      ),
    );
    await vendreCredit(2, 100);
    expect(await vendreCredit(5, 50, depassement: true), closeTo(16.67, 0.01), reason: 'dérogation par permission');
  });

  test('prix d\'achat restauré à l\'annulation, CMP d\'une entrée modifiée sur le prix d\'avant', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    final lait = await _produit(db, 'Lait', 100, 130);
    await StockService(
      db,
      utilisateurCode: 'USR0000',
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 10);
    await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final achats = AchatService(db, utilisateurCode: 'USR0000');
    final catalogue = CatalogueRepository(db);
    Future<double> pa() async => (await catalogue.produitParCode(lait.code))!.prixAchat;

    // Saisie erronée à 10 000 puis annulée : la fiche revient à 100.
    final erreur = await achats.enregistrer(
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 1, prixAchat: 10000)],
    );
    expect(await pa(), 10000);
    await achats.annuler(erreur.code, motif: 'Erreur de saisie');
    expect(await pa(), 100);
    expect((await catalogue.produitParCode(lait.code))!.prixVente, 130);

    // CMP : 10 @100 + 10 @200 → 150 ; modifiée en 10 @180 → 140 (et non 165).
    final e = await achats.enregistrer(
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 200)],
      majPrix: MajPrixAchat.moyenPondere,
    );
    expect(await pa(), 150);
    await achats.modifier(
      e.code,
      fournisseurCode: 'FOR0000',
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 180)],
      majPrix: MajPrixAchat.moyenPondere,
    );
    expect(await pa(), 140);
  });
}
