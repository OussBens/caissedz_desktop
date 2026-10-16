import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/alertes_repository.dart';
import 'package:caissedz_desktop/data/statistiques_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

/// Toutes les vues du solde d'un tiers : liste (statistiques), solde direct, relevé (cumul), alertes,
/// tableau de bord / zakat. Elles doivent toutes donner la même valeur.
Future<void> _coherent(Database db, String type, String code, double attendu) async {
  final repo = TiersRepository(db);
  expect(await repo.solde(type, code), attendu, reason: 'vue solde_tiers');
  expect((await repo.statistiques(type))[code]?.solde ?? 0, attendu, reason: 'liste / situation');
  final releve = await repo.releve(type, code);
  final cumul = releve.fold(0.0, (s, l) => s + l.credit - l.debit);
  expect(cumul, closeTo(attendu, 0.001), reason: 'relevé');
  final alertes = type == TypesTiers.client
      ? await AlertesRepository(db).creditsClients(limite: 50)
      : await AlertesRepository(db).dettesFournisseurs(limite: 50);
  final alerte = alertes.where((r) => r['code'] == code).map((r) => (r['du']! as num).toDouble());
  expect(alerte.isEmpty ? 0.0 : alerte.single, attendu > 0 ? attendu : 0.0, reason: 'alertes');
}

void main() {
  test('solde unique des tiers : liste, relevé, alertes, tableau de bord et zakat concordent', () async {
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
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 100);
    final tiers = TiersService(db, utilisateurCode: 'USR0000');
    final amina = await tiers.creerClient(const Client(code: '', nom: 'Amina'));
    final karim = await tiers.creerClient(const Client(code: '', nom: 'Karim'));
    final djurdjura = await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Djurdjura'));
    final session = await SessionCaisseService(
      db,
      utilisateurCode: 'USR0000',
    ).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
    final versements = VersementService(db, utilisateurCode: 'USR0000');
    Future<String> vendre(String client, double quantite, double prix, double paye) async => (await ventes.encaisser(
      Panier(id: 1, clientCode: client)
          .ajouter(PanierLigne(produit: lait, quantite: quantite, prixUnitaire: prix))
          .copyWith(paiements: [Paiement(mode: 'Espèces', montant: paye)]),
      session: session,
      magasinCode: 'MAG0000',
      creditAutorise: true,
    )).code;

    // Amina : 950 payée 1 000 (monnaie 50 rendue), 1 000 payée, retour 300 en avoir (rien d'ouvert → avance),
    // avance 200 puis rendue 200. Elle a 300 d'avance, partout.
    await vendre(amina.code, 10, 95, 1000);
    final v2 = await vendre(amina.code, 10, 100, 1000);
    await RetourService(db, utilisateurCode: 'USR0000').creer(
      type: TypesTiers.client,
      documentCode: v2,
      produitCode: lait.code,
      quantite: 3,
      reglement: ReglementsRetour.avoir,
    );
    await versements.imputer(tiersType: TypesTiers.client, tiersCode: amina.code, montant: 200, mode: 'Espèces');
    await versements.imputer(
      tiersType: TypesTiers.client,
      tiersCode: amina.code,
      montant: 200,
      mode: 'Espèces',
      sens: SensVersement.decaissement,
    );
    await _coherent(db, TypesTiers.client, amina.code, -300);

    // Karim : 500 payée 200 → crédit 300.
    await vendre(karim.code, 5, 100, 200);
    await _coherent(db, TypesTiers.client, karim.code, 300);
    final stats = StatistiquesRepository(db);
    expect(await stats.creancesClients(), 300, reason: 'l\'avance d\'Amina ne réduit pas le crédit de Karim');

    // Djurdjura : avance 1 500, puis entrée 1 000 non payée → avance 500 ; 2ᵉ entrée 1 000 réglée par un
    // versement 1 000 puis réduite à 600 → l'excédent 400 redevient une avance (jamais un reste négatif).
    await versements.imputer(
      tiersType: TypesTiers.fournisseur,
      tiersCode: djurdjura.code,
      montant: 1500,
      mode: 'Espèces',
    );
    final achats = AchatService(db, utilisateurCode: 'USR0000');
    await achats.enregistrer(
      fournisseurCode: djurdjura.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 100)],
    );
    await _coherent(db, TypesTiers.fournisseur, djurdjura.code, -500);
    final e2 = await achats.enregistrer(
      fournisseurCode: djurdjura.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 100)],
    );
    await versements.imputer(
      tiersType: TypesTiers.fournisseur,
      tiersCode: djurdjura.code,
      montant: 1000,
      mode: 'Espèces',
      documentCible: e2.code,
    );
    await achats.modifier(
      e2.code,
      fournisseurCode: djurdjura.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 6, prixAchat: 100)],
    );
    expect((await achats.achat(e2.code))!.reste, 0, reason: 'trop-payé désimputé');
    await _coherent(db, TypesTiers.fournisseur, djurdjura.code, -900);
    expect(await stats.dettesFournisseurs(), 0);
  });
}
