import 'dart:typed_data';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/application/caisse_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/session_caisse_service.dart';
import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/vente_service.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/core/export/export_fiscal.dart';
import 'package:caissedz_desktop/data/caisse_repository.dart';
import 'package:caissedz_desktop/data/vente_repository.dart';
import 'package:caissedz_desktop/domain/models/panier.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/features/gestion_caisse/gestion_caisse_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

Future<void> _rafraichir(WidgetTester tester, ProviderContainer c) async {
  c.read(caisseVersionProvider.notifier).incrementer();
  await tester.pumpAndSettle();
}

/// Deux ventes encaissées sur la caisse principale (espèces 100, carte 200), session laissée ouverte.
Future<void> _ventes(WidgetTester tester, ProviderContainer c) async {
  final db = c.read(appDatabaseProvider).db;
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
  final s = await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 0);
  final ventes = VenteService(db, utilisateurCode: 'USR0000', parametres: const ParametresVente());
  for (final (i, p) in [
    (1, const Paiement(mode: 'Espèces', montant: 100)),
    (2, const Paiement(mode: 'Carte', montant: 200)),
  ]) {
    await ventes.encaisser(
      Panier(id: i).ajouter(PanierLigne(produit: lait, quantite: i.toDouble(), prixUnitaire: 100)).ajouterPaiement(p),
      session: s,
      magasinCode: 'MAG0000',
    );
  }
  await _rafraichir(tester, c);
}

void main() {
  group('Gestion caisse (DS v2.2)', () {
    testWidgets('caisses : création avec solde initial, carte de session, ouverture pré-remplie, mouvement, détail', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/gestion-caisse', taille: _taille);
      for (final onglet in ['Caisses', 'Transferts', 'Clôtures Z', 'Mouvements', 'Sessions']) {
        expect(find.text(onglet), findsWidgets);
      }
      expect(find.text('Caisse principale'), findsWidgets);
      await clic(tester, _cle('caisse_nouvelle'));
      expect(find.text('CS0001'), findsOneWidget, reason: 'code proposé');
      expect(tester.widget<DsButton>(_cle('caisse_enregistrer')).onPressed, isNull, reason: 'nom obligatoire');
      await tester.enterText(_champ('caisse_nom'), 'Caisse 2');
      await tester.enterText(_champ('caisse_solde_initial'), '3000');
      await tester.pump();
      await clic(tester, _cle('caisse_enregistrer'));
      expect(find.text('Caisse enregistrée'), findsOneWidget);
      final db = c.read(appDatabaseProvider).db;
      expect((await CaisseRepository(db).caisse('CS0001'))!.soldeInitial, 3000);
      // Ouverture depuis la carte : fond pré-rempli par le solde initial.
      final carte = _cle('carte_CS0001');
      await clic(tester, find.descendant(of: carte, matching: find.text('Ouvrir la caisse')));
      expect(find.descendant(of: _cle('ouverture_fond'), matching: find.textContaining('3 000')), findsOneWidget);
      await clic(tester, _cle('ouverture_valider'));
      expect(find.descendant(of: carte, matching: find.textContaining('SES0001')), findsOneWidget);
      // Mouvement manuel depuis la carte.
      await clic(tester, find.descendant(of: carte, matching: find.text('Mouvement')));
      await tester.enterText(_champ('mouvement_montant'), '500');
      await tester.enterText(_champ('mouvement_motif'), 'Monnaie');
      await tester.pump();
      await clic(tester, _cle('mouvement_valider'));
      expect((await CaisseRepository(db).solde('CS0001')).especes, 3500);
      // Détail de la caisse.
      await doubleClic(tester, find.text('CS0001'));
      expect(find.text('Dernières sessions'), findsOneWidget);
      expect(find.text('Sessions (30 j)'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      // Désactivation bloquée : session ouverte.
      await clic(tester, find.text('CS0001'));
      await clic(tester, find.text('Désactiver').first);
      expect(find.textContaining('Session ouverte'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('transferts : solde disponible, dépassement refusé, transfert puis annulation avec motif', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/gestion-caisse', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      final service = CaisseService(db, utilisateurCode: 'USR0000');
      await service.creer(nom: 'Coffre');
      await service.mouvementManuel(caisseCode: 'CIS0000', apport: true, montant: 5000);
      await _rafraichir(tester, c);
      await clic(tester, find.text('Transferts'));
      await clic(tester, _cle('transfert_nouveau'));
      expect(find.textContaining('Solde disponible'), findsOneWidget);
      await tester.enterText(_champ('trf_montant'), '6000');
      await tester.pump();
      expect(find.text('Supérieur au solde de Caisse principale'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('trf_valider')).onPressed, isNull);
      await tester.enterText(_champ('trf_montant'), '2000');
      await tester.pump();
      await clic(tester, _cle('trf_valider'));
      expect(find.text('TRF0001'), findsWidgets);
      expect((await CaisseRepository(db).solde('CS0001')).especes, 2000);
      await clic(tester, find.text('TRF0001').first);
      await clic(tester, _cle('transferts_annuler'));
      await tester.enterText(find.byType(TextField).last, 'Erreur de caisse');
      await tester.pump();
      await clic(tester, find.text('Annuler (1)'));
      expect(find.text('Transferts annulés'), findsOneWidget);
      expect((await CaisseRepository(db).solde('CS0001')).especes, 0);
      expect((await CaisseRepository(db).solde('CIS0000')).especes, 5000);
      expect(find.text('Annulé'), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('clôtures Z : confirmation obligatoire, rapport par caisse, détail, export fiscal vérifié', (
      tester,
    ) async {
      Uint8List? archive;
      String? nom;
      final c = await pumpApp(
        tester,
        routeInitiale: '/clotures',
        taille: _taille,
        overrides: [
          selecteurExportProvider.overrideWithValue((n) async {
            nom = n;
            return '/tmp/$n';
          }),
          ecrivainExportProvider.overrideWithValue((_, octets) async => archive = octets),
        ],
      );
      await _ventes(tester, c);
      expect(find.text('Aucune clôture.'), findsOneWidget, reason: 'route Clôtures → onglet Clôtures Z');
      await clic(tester, _cle('cloture_nouvelle'));
      expect(find.text('Créer la clôture CLT0001'), findsOneWidget);
      expect(find.text('Première clôture de cette caisse'), findsOneWidget);
      expect(find.text('Espèces'), findsWidgets);
      expect(find.text('Carte CIB'), findsWidgets);
      expect(tester.widget<DsButton>(_cle('z_creer')).onPressed, isNull, reason: 'confirmation obligatoire');
      await clic(tester, _cle('z_confirmer'));
      await clic(tester, _cle('z_creer'));
      expect(find.text('Clôture CLT0001 créée'), findsOneWidget);
      final z = (await CaisseRepository(c.read(appDatabaseProvider).db).clotures()).single;
      expect(z.caisseCode, 'CIS0000');
      expect(z.nbVentes, 2);
      expect(z.encaissementsParMode, {'Espèces': 100, 'Carte': 200});
      await doubleClic(tester, find.text('CLT0001'));
      expect(find.text('Empreinte valide'), findsOneWidget);
      expect(find.text('Répartition des paiements'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      // Export de contrôle fiscal : chaîne intègre, archive vérifiable.
      await clic(tester, _cle('cloture_fiscal'));
      expect(find.textContaining("Chaîne d'empreintes intègre"), findsOneWidget);
      await clic(tester, _cle('fiscal_generer'));
      expect(nom, startsWith('controle_fiscal_'));
      expect(ExportFiscal.verifier(archive!).valide, isTrue);
      expect(find.text('Archive générée'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sessions et mouvements : mouvements d’une session, clôture depuis l’onglet, grand-livre', (
      tester,
    ) async {
      final c = await pumpApp(tester, routeInitiale: '/gestion-caisse', taille: _taille);
      final db = c.read(appDatabaseProvider).db;
      await SessionCaisseService(db, utilisateurCode: 'USR0000').ouvrir(caisseCode: 'CIS0000', fondInitial: 1000);
      await CaisseService(
        db,
        utilisateurCode: 'USR0000',
      ).mouvementManuel(caisseCode: 'CIS0000', apport: true, montant: 200, commentaire: 'Appoint');
      await _rafraichir(tester, c);
      await clic(tester, find.text('Sessions'));
      expect(find.text('SES0001'), findsOneWidget);
      await doubleClic(tester, find.text('SES0001'));
      expect(find.text('Mouvements · SES0001'), findsOneWidget);
      expect(find.text('Ouverture'), findsWidgets);
      expect(find.text('Entrée manuelle'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await clic(tester, find.text('SES0001'));
      await clic(tester, _cle('sessions_cloturer'));
      await tester.enterText(_champ('cloture_reel'), '1000');
      await tester.pump();
      await clic(tester, _cle('cloture_valider'));
      final s = (await VenteRepository(db).session('SES0001'))!;
      expect(s.estOuverte, isFalse);
      expect(s.ecart, 0);
      expect(find.text('Clôturée'), findsWidgets);
      // Grand-livre : session déduite, totaux entrées / sorties.
      await clic(tester, find.text('Mouvements'));
      expect(find.text('Entrée manuelle'), findsOneWidget);
      expect(find.text('SES0001'), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('arabe : écran Gestion caisse en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/gestion-caisse', locale: const Locale('ar'), taille: _taille);
      final bouton = _cle('caisse_nouvelle');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
