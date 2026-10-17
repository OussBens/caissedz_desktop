// Outil (hors suite) : régénère les captures d'écran du document docs/workflow/workflow.html.
//   CAPTURES=1 flutter test test/outils/captures_workflow_test.dart
import 'dart:io';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/application/achat_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/document_commercial_service.dart';
import 'package:caissedz_desktop/application/facture_service.dart';
import 'package:caissedz_desktop/application/retour_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/tiers_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/application/versement_service.dart';
import 'package:caissedz_desktop/domain/models/achat.dart';
import 'package:caissedz_desktop/domain/models/document_commercial.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/retour.dart';
import 'package:caissedz_desktop/domain/models/stock.dart';
import 'package:caissedz_desktop/domain/models/tiers.dart';
import 'package:caissedz_desktop/features/produits/produits_providers.dart';
import 'package:caissedz_desktop/features/stock/stock_providers.dart';
import 'package:caissedz_desktop/features/tiers/tiers_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helper.dart';
import '../helpers/capture.dart';

const _dossier = 'docs/workflow/captures';
const _taille = Size(1600, 940);

Future<void> _donnees(ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
  const u = 'USR0000';
  final cat = CatalogueService(db, utilisateurCode: u);
  final produits = <Produit>[];
  for (final (nom, achat, vente, tva, barres) in [
    ('Lait Candia 1 L', 85.0, 110.0, 9.0, '6130234000017'),
    ('Café Bonal 250 g', 260.0, 340.0, 19.0, '6130100002201'),
    ('Huile Elio 1 L', 520.0, 600.0, 9.0, '6132541000011'),
    ('Sucre 1 kg', 95.0, 120.0, 9.0, '6130000100010'),
    ('Coca-Cola 1 L', 95.0, 130.0, 19.0, '5449000000996'),
    ('Eau Ifri 1,5 L', 28.0, 40.0, 19.0, '6130090000015'),
    ('Pâtes Amor Benamor 500 g', 75.0, 100.0, 9.0, '6130123000013'),
    ('Savon Palmolive', 90.0, 130.0, 19.0, '8693495034411'),
  ]) {
    produits.add(
      await cat.creerProduit(
        Produit(
          code: '',
          designation: nom,
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: achat,
          prixVente: vente,
          tvaPct: tva,
          codeBarres: barres,
        ),
      ),
    );
  }
  final tiers = TiersService(db, utilisateurCode: u);
  final clients = [
    await tiers.creerClient(
      const Client(
        code: '',
        nom: 'SARL Atlas Distribution',
        telephone: '0550123456',
        adresse: 'Bab Ezzouar, Alger',
        plafondCredit: 50000,
        fiche: FicheTiers(nif: '000116001234567', nis: '000116123456789', nrc: '16/00-1234567B12', ai: '16012345678'),
      ),
    ),
    await tiers.creerClient(const Client(code: '', nom: 'Amina Benali', telephone: '0661234567', soldeInitial: 1500)),
    await tiers.creerClient(const Client(code: '', nom: 'Karim Haddad', telephone: '0770112233')),
  ];
  final fournisseurs = [
    await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Cevital Agro', telephone: '021345678')),
    await tiers.creerFournisseur(const Fournisseur(code: '', nom: 'Groupe Hamoud', telephone: '021566778')),
  ];
  final session = await SessionCaisseService(db, utilisateurCode: u).ouvrir(caisseCode: 'CIS0000', fondInitial: 5000);
  final achats = AchatService(db, utilisateurCode: u);
  await achats.enregistrer(
    fournisseurCode: fournisseurs[0].code,
    magasinCode: 'MAG0000',
    reference: 'BL-2026-118',
    lignes: [for (final p in produits) DemandeAchatLigne(produitCode: p.code, quantite: 60, prixAchat: p.prixAchat)],
  );
  final ventes = VenteService(db, utilisateurCode: u, parametres: const ParametresVente());
  final codes = <String>[];
  for (final (client, lignes, paye) in [
    (clients[0], [(0, 12.0), (1, 6.0), (2, 4.0)], 3000.0),
    (clients[1], [(4, 3.0), (5, 6.0)], 630.0),
    ('CLN0000', [(6, 2.0), (3, 1.0)], 320.0),
    (clients[2], [(7, 2.0), (0, 2.0)], 480.0),
    ('CLN0000', [(1, 1.0), (4, 2.0)], 600.0),
  ]) {
    var panier = Panier(id: 1, clientCode: client is Client ? client.code : client as String);
    for (final (i, q) in lignes) {
      panier = panier.ajouter(PanierLigne(produit: produits[i], quantite: q, prixUnitaire: produits[i].prixVente));
    }
    codes.add(
      (await ventes.encaisser(
        panier.ajouterPaiement(Paiement(mode: 'Espèces', montant: paye)),
        session: session,
        magasinCode: 'MAG0000',
        creditAutorise: true,
      )).code,
    );
  }
  await FactureService(db, utilisateurCode: u).emettre(codes[0]);
  await RetourService(
    db,
    utilisateurCode: u,
  ).creer(type: TypesTiers.client, documentCode: codes[3], produitCode: produits[7].code, quantite: 1);
  await VersementService(
    db,
    utilisateurCode: u,
  ).imputer(tiersType: TypesTiers.client, tiersCode: clients[0].code, montant: 2000, mode: 'Espèces');
  final stock = StockService(db, utilisateurCode: u);
  await stock.sortir(
    magasinCode: 'MAG0000',
    motif: 'Casse',
    lignes: [LigneStock(produitCode: produits[5].code, quantite: 2)],
  );
  await stock.creerBesoin(
    fournisseurCode: fournisseurs[1].code,
    lignes: [LigneStock(produitCode: produits[4].code, quantite: 48, prix: 95)],
  );
  final docs = DocumentClientService(db, utilisateurCode: u);
  final devis = await docs.creer(
    type: TypesDocumentClient.devis,
    clientCode: clients[0].code,
    lignes: [
      DemandeLigneDocument(produitCode: produits[2].code, quantite: 20, prix: 590),
      DemandeLigneDocument(produitCode: produits[3].code, quantite: 50, prix: 118),
    ],
    validite: DateTime.now().add(const Duration(days: 15)),
  );
  await docs.creer(
    type: TypesDocumentClient.devis,
    clientCode: clients[2].code,
    lignes: [DemandeLigneDocument(produitCode: produits[1].code, quantite: 10, prix: 335)],
    validite: DateTime.now().add(const Duration(days: 7)),
  );
  await docs.creer(
    type: TypesDocumentClient.proforma,
    clientCode: clients[0].code,
    lignes: [DemandeLigneDocument(produitCode: produits[0].code, quantite: 120, prix: 105)],
    validite: DateTime.now().add(const Duration(days: 30)),
  );
  final commande = await docs.transformerEnCommande(devis.code);
  await docs.livrer(
    commande.code,
    quantites: {0: 10, 1: 50},
    session: session,
    magasinCode: 'MAG0000',
    paiements: const [Paiement(mode: 'Espèces', montant: 5000)],
  );
  final bcf = await CommandeFournisseurService(db, utilisateurCode: u).creer(
    fournisseurCode: fournisseurs[1].code,
    magasinCode: 'MAG0000',
    lignes: [
      DemandeLigneDocument(produitCode: produits[4].code, quantite: 96, prix: 95),
      DemandeLigneDocument(produitCode: produits[5].code, quantite: 120, prix: 28),
    ],
    dateLivraison: DateTime.now().add(const Duration(days: 3)),
  );
  await achats.enregistrer(
    fournisseurCode: fournisseurs[1].code,
    magasinCode: 'MAG0000',
    lignes: [DemandeAchatLigne(produitCode: produits[4].code, quantite: 48, prixAchat: 95)],
    commandeCode: bcf.code,
  );
  c.read(catalogueVersionProvider.notifier).incrementer();
  c.read(stockVersionProvider.notifier).incrementer();
  c.read(commerceVersionProvider.notifier).incrementer();
}

void main() {
  final actif = Platform.environment['CAPTURES'] != null;

  testWidgets('écran de connexion', skip: !actif, (tester) async {
    await chargerPolices();
    await pumpApp(tester, etat: EtatApp.configuree, taille: _taille);
    await tester.pumpAndSettle();
    await capturer(tester, '$_dossier/connexion.png');
  });

  testWidgets('écrans des modules', skip: !actif, (tester) async {
    await chargerPolices();
    final c = await pumpApp(tester, routeInitiale: '/tableau-de-bord', taille: _taille);
    await tester.runAsync(() => _donnees(c));
    await tester.pumpAndSettle();
    final routes = {
      'tableau_bord': '/tableau-de-bord',
      'situation': '/situation',
      'caisse': '/caisse',
      'ventes': '/ventes',
      'documents': '/documents',
      'retours': '/retours',
      'produits': '/produits',
      'stock': '/stock',
      'entrees': '/entrees',
      'commandes_fournisseurs': '/commandes-fournisseurs',
      'sorties': '/sorties',
      'magasins': '/magasins',
      'besoins': '/besoins',
      'clients': '/clients',
      'versements': '/versements',
      'fournisseurs': '/fournisseurs',
      'gestion_caisse': '/gestion-caisse',
      'utilisateurs': '/utilisateurs',
      'zakat': '/zakat',
      'historique': '/historique',
      'parametres': '/parametres',
    };
    final router = c.read(routerProvider);
    for (final MapEntry(key: nom, value: route) in routes.entries) {
      router.go(route);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      if (nom == 'caisse') {
        for (final p in ['Café Bonal 250 g', 'Lait Candia 1 L', 'Lait Candia 1 L', 'Huile Elio 1 L']) {
          await tester.tap(find.text(p).first);
          await tester.pumpAndSettle();
        }
      }
      await capturer(tester, '$_dossier/$nom.png');
    }
    // Onglets ajoutés : factures & avoirs, commandes clients, bons de livraison.
    router.go('/ventes');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Factures & avoirs'));
    await tester.pumpAndSettle();
    await capturer(tester, '$_dossier/factures.png');
    router.go('/documents');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commandes clients'));
    await tester.pumpAndSettle();
    await capturer(tester, '$_dossier/commandes_clients.png');
    await clic(tester, find.text('BCC0001'));
    await clic(tester, find.byKey(const ValueKey('doc_livrer')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await capturer(tester, '$_dossier/livraison_dialog.png');
    await clic(tester, find.text('Annuler').last);
    await tester.tap(find.text('Bons de livraison'));
    await tester.pumpAndSettle();
    await capturer(tester, '$_dossier/livraisons.png');
  });
}
