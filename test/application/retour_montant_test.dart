import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  test('montant retour : versement en espèces du montant saisi, avoir du reste, annulés avec le retour', () async {
    final base = await ouvrirBaseDeTest();
    final db = base.db;
    const u = 'USR0000';
    final lait = await CatalogueService(db, utilisateurCode: u).creerProduit(
      const Produit(
        code: '',
        designation: 'Lait',
        categorieCode: 'CATE0000',
        sousCategorieCode: 'SC0000',
        prixAchat: 80,
        prixVente: 100,
        tvaPct: 0,
      ),
    );
    await StockService(
      db,
      utilisateurCode: u,
    ).entrerStock(produitCode: lait.code, magasinCode: 'MAG0000', quantite: 20);
    final tiers = TiersService(db, utilisateurCode: u);
    final amina = await tiers.creerClient(const Client(code: '', nom: 'Amina'));
    final f = await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Djurdjura'));
    final session = await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
    final ventes = VenteService(db, utilisateurCode: u, parametres: const ParametresVente());
    Future<String> vendre(String client, double q) async => (await ventes.encaisser(
      Panier(id: 1, clientCode: client)
          .ajouter(PanierLigne(produit: lait, quantite: q, prixUnitaire: 100))
          .ajouterPaiement(Paiement(mode: 'Espèces', montant: q * 100)),
      session: session,
      magasinCode: 'MAG0000',
    )).code;
    final caisse = CaisseRepository(db);
    final repo = TiersRepository(db);
    final retours = RetourService(db, utilisateurCode: u);

    // Client : retour de 2 laits (200), 50 rendus en espèces, 150 en avoir (avance au solde).
    final v1 = await vendre(amina.code, 2);
    final especesAvant = await caisse.especesSession('CIS0000', session.code);
    await expectLater(
      retours.creer(type: TypesTiers.client, documentCode: v1, produitCode: lait.code, quantite: 2, montantRetour: 250),
      throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.montantInvalide)),
    );
    final r = await retours.creer(
      type: TypesTiers.client,
      documentCode: v1,
      produitCode: lait.code,
      quantite: 2,
      montantRetour: 50,
    );
    expect((r.total, r.rembourse), (200.0, 50.0));
    final lies = (await repo.versements()).where((v) => v.retourCode == r.code).toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    expect(
      [for (final v in lies) (v.mode, v.montant, v.sens)],
      [
        (ReglementsRetour.especes, 50.0, SensVersement.decaissement),
        (ReglementsRetour.avoir, 150.0, SensVersement.encaissement),
      ],
    );
    expect(lies.every((v) => v.date == r.date), isTrue);
    expect(await caisse.especesSession('CIS0000', session.code), especesAvant - 50);
    expect(await repo.soldeClient(amina.code), -150);

    // Annulation : les deux versements sont annulés, espèces et solde reviennent.
    await retours.annuler(r.code, motif: 'Erreur');
    expect(await caisse.especesSession('CIS0000', session.code), especesAvant);
    expect(await repo.soldeClient(amina.code), 0);

    // Client de passage : il récupère tout le montant.
    final v2 = await vendre('CLN0000', 1);
    await expectLater(
      retours.creer(type: TypesTiers.client, documentCode: v2, produitCode: lait.code, quantite: 1, montantRetour: 40),
      throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.montantPassage)),
    );
    final r2 = await retours.creer(
      type: TypesTiers.client,
      documentCode: v2,
      produitCode: lait.code,
      quantite: 1,
      montantRetour: 100,
    );
    expect(r2.rembourse, 100);

    // Fournisseur : retour de 5 laits (400), le fournisseur verse 100 en espèces, 300 déduits de la dette.
    final achat = await AchatService(db, utilisateurCode: u).enregistrer(
      fournisseurCode: f.code,
      magasinCode: 'MAG0000',
      lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
    );
    final detteAvant = await repo.soldeFournisseur(f.code);
    final especes = await caisse.especesSession('CIS0000', session.code);
    final r3 = await retours.creer(
      type: TypesTiers.fournisseur,
      documentCode: achat.code,
      produitCode: lait.code,
      quantite: 5,
      montantRetour: 100,
    );
    expect((r3.total, r3.rembourse), (400.0, 100.0));
    expect(await caisse.especesSession('CIS0000', session.code), especes + 100);
    expect(await repo.soldeFournisseur(f.code), detteAvant - 300);
    await base.fermer();
  });
}
