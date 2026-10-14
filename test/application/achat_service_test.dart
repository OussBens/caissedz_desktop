import 'dart:convert';
import 'dart:typed_data';

import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/smart_scan_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/data/stock_repository.dart';
import 'package:caissedz_desktop/data/tiers_repository.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/bases.dart';

void main() {
  group('AchatService', () {
    test('enregistrer : stock, prix d’achat, dette fournisseur, paiement partiel, puis versement imputé', () async {
      final base = await ouvrirBaseDeTest();
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
      expect(a.code, 'ACH0001');
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
      expect(v.imputations.single.documentCode, 'ACH0001');
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
        mettreAJourPrixAchat: false,
      );
      final an = await s.annuler(a.code);
      expect(an.statut, StatutsAchat.annule);
      expect((await StockRepository(base.db).niveau(lait.code, 'MAG0000')).quantite, 0);
      await expectLater(
        s.annuler(a.code),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.dejaAnnule)),
      );
      final a2 = await s.enregistrer(
        fournisseurCode: 'FOR0000',
        magasinCode: 'MAG0000',
        lignes: [DemandeAchatLigne(produitCode: lait.code, quantite: 5, prixAchat: 80)],
      );
      final ferme = AchatService(base.db, utilisateurCode: 'USR0000', periodeCloturee: (_, _) async => true);
      await expectLater(
        ferme.annuler(a2.code),
        throwsA(isA<AchatException>().having((e) => e.erreur, 'e', ErreurAchat.periodeCloturee)),
      );
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
