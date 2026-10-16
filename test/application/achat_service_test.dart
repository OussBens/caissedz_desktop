import 'dart:convert';
import 'dart:typed_data';

import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/smart_scan_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/bases.dart';

void main() {
  group('AchatService', () {
    test('§8.4 : achat, retour et versement refusés sans session de caisse ouverte', () async {
      final base = await ouvrirBaseDeTest();
      final f = await TiersService(
        base.db,
        utilisateurCode: 'USR0000',
      ).creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
      await expectLater(
        AchatService(base.db, utilisateurCode: 'USR0000').enregistrer(
          fournisseurCode: f.code,
          magasinCode: 'MAG0000',
          lignes: const [DemandeAchatLigne(produitCode: 'X', quantite: 1, prixAchat: 1)],
        ),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.sessionRequise)),
      );
      await expectLater(
        RetourService(
          base.db,
          utilisateurCode: 'USR0000',
        ).creer(type: TypesTiers.fournisseur, documentCode: 'ENT0001', produitCode: 'X', quantite: 1),
        throwsA(isA<RetourException>().having((e) => e.erreur, 'e', ErreurRetour.sessionRequise)),
      );
      await expectLater(
        VersementService(
          base.db,
          utilisateurCode: 'USR0000',
        ).imputer(tiersType: TypesTiers.fournisseur, tiersCode: f.code, montant: 100, mode: 'Espèces'),
        throwsA(isA<VersementException>().having((e) => e.erreur, 'e', ErreurVersement.sessionRequise)),
      );
      expect(await base.db.query('achat'), isEmpty);
    });

    test('enregistrer : stock, prix d’achat, dette fournisseur, paiement partiel, puis versement imputé', () async {
      final base = await ouvrirBaseDeTest();
      await ouvrirSessionDeTest(base.db);
      final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final lait = await cat.creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      final f = await TiersService(
        base.db,
        utilisateurCode: 'USR0000',
      ).creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
      final s = AchatService(base.db, utilisateurCode: 'USR0000');
      final a = await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 20, prixAchat: 85, nouveauPrixVente: 110)],
        verse: 500,
        reference: 'FAC-12',
      );
      expect(a.code, 'ENT0001');
      expect(a.total, 1700);
      expect(a.verse, 500);
      expect(a.reste, 1200);
      expect((await StockRepository(base.db).niveau(lait.code, 'MAG0000')).quantite, 20);
      final p = (await CatalogueRepository(base.db).produitParCode(lait.code))!;
      expect(p.prixAchat, 85);
      expect(p.prixVente, 110);
      final repo = TiersRepository(base.db);
      expect(await repo.soldeFournisseur(f.code), 1200);
      expect((await repo.versements(tiersType: TypesTiers.fournisseur)).single.montant, 500);
      final v = await VersementService(
        base.db,
        utilisateurCode: 'USR0000',
      ).imputer(tiersType: TypesTiers.fournisseur, tiersCode: f.code, montant: 1000, mode: 'Virement');
      expect(v.imputations.single.documentCode, 'ENT0001');
      expect(await repo.soldeFournisseur(f.code), 200);
      await expectLater(
        s.enregistrer(
          fournisseurCode: 'FOR9999',
          magasinCode: 'MAG0000',
          lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 1, prixAchat: 1)],
        ),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.fournisseurInconnu)),
      );
      await expectLater(
        s.enregistrer(fournisseurCode: f.code, magasinCode: 'MAG0000', lignes: const []),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.lignesVides)),
      );
      await expectLater(
        s.enregistrer(
          fournisseurCode: f.code,
          magasinCode: 'MAG0000',
          lignes: [const DemandeAchatLigne(produitCode: 'PRD9999', quantite: 1, prixAchat: 1)],
        ),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.produitInconnu)),
      );
      expect((await s.achats()).length, 1, reason: 'les achats refusés ne sont pas écrits');
    });

    test('annulation : stock ressorti (garde), statut Annulé, refus si période clôturée', () async {
      final base = await ouvrirBaseDeTest();
      await ouvrirSessionDeTest(base.db);
      final cat = CatalogueService(base.db, utilisateurCode: 'USR0000');
      final lait = await cat.creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      final s = AchatService(base.db, utilisateurCode: 'USR0000');
      final a = await s.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 5, prixAchat: 80)],
        majPrix: MajPrixAchat.garder,
      );
      final an = await s.annuler(a.code, motif: 'Erreur');
      expect(an.statut, StatutsAchat.annule);
      expect((await StockRepository(base.db).niveau(lait.code, 'MAG0000')).quantite, 0);
      await expectLater(
        s.annuler(a.code, motif: 'Erreur'),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.dejaAnnule)),
      );
      final a2 = await s.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 5, prixAchat: 80)],
      );
      final ferme = AchatService(
        base.db,
        utilisateurCode: 'USR0000',
        periodeCloturee: (_, _, {caisseCode}) async => true,
      );
      await expectLater(
        ferme.annuler(a2.code, motif: 'Erreur'),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.periodeCloturee)),
      );
    });
  });

  group('AchatService · DS v2.2', () {
    late AppDatabase base;
    late Produit lait;
    late Fournisseur f;
    late AchatService s;

    setUp(() async {
      base = await ouvrirBaseDeTest();
      await ouvrirSessionDeTest(base.db);
      lait = await CatalogueService(base.db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: 80,
          prixVente: 100,
        ),
      );
      f = await TiersService(
        base.db,
        utilisateurCode: 'USR0000',
      ).creerFournisseur(const Fournisseur(code: '', nom: 'Grossiste'));
      s = AchatService(base.db, utilisateurCode: 'USR0000');
    });

    Future<double> stock(String mag) async => (await StockRepository(base.db).niveau(lait.code, mag)).quantite;

    test('modification : stock défait puis réécrit, paiement immédiat ajusté puis annulé', () async {
      final a = await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
        verse: 800,
      );
      expect(a.statutPaiement, 'paye');
      var m = await s.modifier(
        a.code,
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 4, prixAchat: 90)],
        verse: 100,
      );
      expect(await stock('MAG0000'), 4);
      expect(m.total, 360);
      expect(m.verse, 100);
      expect(m.reste, 260);
      expect(m.statutPaiement, 'partiel');
      final repo = TiersRepository(base.db);
      expect((await repo.versements(tiersType: TypesTiers.fournisseur)).single.montant, 100);
      m = await s.modifier(
        a.code,
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 4, prixAchat: 90)],
      );
      expect(m.verse, 0);
      expect(m.statutPaiement, 'credit');
      expect(await repo.soldeFournisseur(f.code), 360);
    });

    test('annulation en lot : motif obligatoire, paiement annulé, blocage si déjà vendu', () async {
      final a = await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
        verse: 800,
      );
      await expectLater(
        s.annulerEntrees([a.code], motif: ' '),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.motifObligatoire)),
      );
      expect(await s.blocage(a), isNull);
      await StockService(base.db, utilisateurCode: 'USR0000').sortir(
        magasinCode: 'MAG0000',
        motif: 'Casse',
        lignes: [LigneStock(produitCode: lait.code, quantite: 3)],
      );
      expect(await s.blocage(a), ErreurAchat.stockInsuffisant);
      final b = await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 2, prixAchat: 80)],
        verse: 160,
      );
      await s.annulerEntrees([b.code], motif: 'Erreur de saisie');
      final an = (await s.achat(b.code))!;
      expect(an.actif, isFalse);
      expect(an.annulation!.motif, 'Erreur de saisie');
      expect(an.statutPaiement, 'annule');
      expect(await stock('MAG0000'), 7);
      final versements = await TiersRepository(base.db).versements(tiersType: TypesTiers.fournisseur);
      expect(versements.where((v) => v.actif).length, 1, reason: 'le paiement de l’entrée annulée est annulé');
    });

    test('entrée rapide répartie entre magasins ; prix moyen pondéré', () async {
      final mag = await StockService(base.db, utilisateurCode: 'USR0000').creerMagasin('Dépôt');
      await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 80)],
      );
      await expectLater(
        s.enregistrer(
          fournisseurCode: 'FOR0000',
          magasinCode: 'MAG0000',
          lignes: [
            DemandeAchatLigne(produitCode: lait.code, quantite: 10, prixAchat: 100, repartition: {'MAG0000': 4}),
          ],
        ),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.repartitionIncomplete)),
      );
      final r = await s.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        source: SourcesAchat.rapide,
        verse: 1000,
        majPrix: MajPrixAchat.moyenPondere,
        lignes: [
          DemandeAchatLigne(
            produitCode: lait.code,
            quantite: 10,
            prixAchat: 100,
            repartition: {'MAG0000': 4, mag.code: 6},
          ),
        ],
      );
      expect(r.statutPaiement, 'paye');
      expect(await stock('MAG0000'), 14);
      expect(await stock(mag.code), 6);
      expect((await CatalogueRepository(base.db).produitParCode(lait.code))!.prixAchat, 90);
      await s.annulerEntrees([r.code], motif: 'Doublon');
      expect(await stock('MAG0000'), 10);
      expect(await stock(mag.code), 0);
    });

    test('liste de besoins livrée et bon de réception traité dans la même transaction', () async {
      final stockService = StockService(base.db, utilisateurCode: 'USR0000');
      final besoin = await stockService.creerBesoin(
        fournisseurCode: f.code,
        lignes: [LigneStock(produitCode: lait.code, quantite: 12, prix: 80)],
      );
      final bon = await s.deposerBon(
        fichier: 'facture.jpg',
        fournisseurDetecte: 'Grossiste',
        numBon: 'F-9',
        lignes: const [LigneDetectee(designation: 'LAIT', quantite: 12, prixAchat: 80, confiance: 96)],
      );
      expect(bon.code, 'BON0001');
      expect(bon.statut, StatutsBon.recu);
      expect(bon.lignes.single.confiance, 96);
      final a = await s.enregistrer(
        fournisseurCode: f.code,
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 12, prixAchat: 80)],
        besoinCode: besoin.code,
        bonCode: bon.code,
        source: SourcesAchat.ia,
      );
      expect(a.besoinCode, besoin.code);
      expect((await StockRepository(base.db).besoin(besoin.code))!.statut, StatutsBesoin.disponible);
      final traite = (await s.bonReception(bon.code))!;
      expect(traite.statut, StatutsBon.traite);
      expect(traite.achatCode, a.code);
      await expectLater(
        s.supprimerBons([bon.code]),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.bonTraite)),
      );
      final erreur = await s.deposerBon(fichier: 'flou.jpg', erreur: true);
      expect(erreur.statut, StatutsBon.erreur);
      await s.supprimerBons([erreur.code]);
      expect((await s.bonsReception()).length, 1);
    });
  });

  group('SmartScanService', () {
    test('non configuré, quota, analyse, quota atteint (429), demande d’offre', () async {
      await expectLater(
        SmartScanService(client: MockClient((_) async => http.Response('', 500)), baseUrl: '').quota(),
        throwsA(isA<SmartScanException>().having((e) => e.erreur, 'e', ErreurSmartScan.nonConfigure)),
      );
      var appels = 0;
      final client = MockClient((req) async {
        if (req.url.path.endsWith('/quota')) return http.Response(jsonEncode({'utilise': 3, 'total': 10}), 200);
        if (req.url.path.endsWith('/analyser')) {
          appels++;
          if (appels > 1) return http.Response('{"erreur":"quota"}', 429);
          return http.Response(
            jsonEncode({
              'fournisseur': 'Grossiste',
              'reference': 'F-1',
              'total': 1700,
              'quota': {'utilise': 4, 'total': 10},
              'lignes': [
                {'designation': 'Lait 1 L', 'code_barres': '6130000000015', 'quantite': 20, 'prix_achat': 85},
              ],
            }),
            200,
          );
        }
        if (req.url.path.endsWith('/demande-offre')) {
          expect(jsonDecode(req.body)['email'], 'a@b.dz');
          return http.Response('{}', 200);
        }
        return http.Response('', 404);
      });
      final s = SmartScanService(client: client, baseUrl: 'https://api.test');
      final q = await s.quota();
      expect(q.restant, 7);
      expect(q.atteint, isFalse);
      final r = await s.analyser(Uint8List.fromList([1, 2, 3]), nomFichier: 'facture.jpg');
      expect(r.lignes.single.designation, 'Lait 1 L');
      expect(r.lignes.single.prixAchat, 85);
      expect(r.quota.utilise, 4);
      expect(r.fournisseur, 'Grossiste');
      await expectLater(
        s.analyser(Uint8List.fromList([1]), nomFichier: 'x.jpg'),
        throwsA(isA<SmartScanException>().having((e) => e.erreur, 'e', ErreurSmartScan.quotaAtteint)),
      );
      await expectLater(
        s.analyser(Uint8List(0), nomFichier: 'x.jpg'),
        throwsA(isA<SmartScanException>().having((e) => e.erreur, 'e', ErreurSmartScan.fichierInvalide)),
      );
      await s.demanderOffre(email: 'a@b.dz', message: 'Plus de scans');
      expect(const QuotaSmartScan(utilise: 10, total: 10).atteint, isTrue);
    });
  });
}
