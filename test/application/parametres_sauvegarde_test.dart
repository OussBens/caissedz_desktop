import 'dart:io';

import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/application/parametres_service.dart';
import 'package:caissedz_desktop/application/sauvegarde_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/print/imprimante.dart';
import 'package:caissedz_desktop/data/boutique_repository.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

void main() {
  group('ParametresService', () {
    test('boutique, vente, impression, serveur, zakat : validation et persistance', () async {
      final base = await ouvrirBaseDeTest();
      final s = ParametresService(base.db, utilisateurCode: 'USR0000');
      await s.enregistrerBoutique(const Boutique(nom: ' El Baraka ', rc: '16/00', email: 'a@b.dz'));
      expect((await s.lireBoutique())!.nom, 'El Baraka');
      expect((await s.lireBoutique())!.email, 'a@b.dz');
      await expectLater(
        s.enregistrerBoutique(const Boutique(nom: '  ')),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.nomBoutiqueVide)),
      );
      await s.enregistrerVente(
        const ParametresVente(
          margeDefautPct: 25,
          seuilStockGlobal: 8,
          fideliteActive: true,
          pointsParDinar: 0.02,
          devise: 'DZD',
        ),
      );
      final v = await s.lireVente();
      expect(v.margeDefautPct, 25);
      expect(v.seuilStockGlobal, 8);
      expect(v.fideliteActive, isTrue);
      expect(v.devise, 'DZD');
      await expectLater(
        s.enregistrerVente(const ParametresVente(margeDefautPct: -1)),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.valeurInvalide)),
      );
      await expectLater(
        s.enregistrerImpression(const ParametresImpression(type: TypesImprimante.reseau)),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.adresseImprimanteRequise)),
      );
      await expectLater(
        s.enregistrerImpression(const ParametresImpression(type: 'Laser')),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.typeImprimanteInvalide)),
      );
      await s.enregistrerImpression(
        const ParametresImpression(type: TypesImprimante.reseau, adresse: '192.168.1.50:9100', largeur: '58'),
      );
      final i = await s.lireImpression();
      expect(i.type, TypesImprimante.reseau);
      expect(i.adresse, '192.168.1.50:9100');
      expect(i.largeur, '58');
      await expectLater(
        s.enregistrerServeur(const ParametresServeur(url: 'ftp://x')),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.valeurInvalide)),
      );
      await s.enregistrerServeur(const ParametresServeur(url: 'https://api.caissedz.dz/', cle: 'k', urlMantouj: ''));
      expect((await s.lireServeur()).url, 'https://api.caissedz.dz');
      expect((await s.lireZakat()).tauxPct, 2.5);
      await s.enregistrerZakat(const ParametresZakat(nissab: 1062500, tauxPct: 2.5));
      expect((await s.lireZakat()).nissab, 1062500);
      await expectLater(
        s.enregistrerZakat(const ParametresZakat(nissab: 1, tauxPct: 0)),
        throwsA(isA<ParametresException>()),
      );
      final h = await base.db.query('historique', where: 'entite = ?', whereArgs: ['parametre']);
      expect(h.length, 5);
    });

    test('barre d’enregistrement unique : tout validé puis écrit en une transaction, une ligne d’historique', () async {
      final base = await ouvrirBaseDeTest();
      final s = ParametresService(base.db, utilisateurCode: 'USR0000');
      final p = await s.lireTout();
      expect(p.paiements.points, isTrue);
      expect(p.alertes.afficherConnexion, isTrue);
      expect(p.vente.venteSousAchat, ParametresVente.venteSousAchatAvertir);
      ParametresComplets avec({Boutique? boutique, ParametresVente? vente, ParametresImpression? impression}) =>
          ParametresComplets(
            boutique: boutique ?? const Boutique(nom: 'El Baraka', nis: '0002', messageTicket: 'Merci'),
            vente:
                vente ??
                p.vente.copyWith(
                  typeMarge: ParametresVente.typeMargeMontant,
                  margeMontant: 40,
                  seuilStockGlobal: 4,
                  seuilStockMax: 120,
                  venteSousAchat: ParametresVente.venteSousAchatInterdire,
                ),
            paiements: p.paiements.copyWith(cheque: true, points: false),
            impression:
                impression ??
                const ParametresImpression(type: TypesImprimante.reseau, adresse: ' 10.0.0.5:9100 ', largeur: '58'),
            serveur: const ParametresServeur(url: 'https://api.test/'),
            zakat: const ParametresZakat(nissab: 1615000, tauxPct: 2.5),
            alertes: const ParametresAlertes(afficherConnexion: false, seuilCreditClient: 20000),
          );
      // Une seule section invalide : rien n'est écrit.
      await expectLater(
        s.enregistrerTout(avec(vente: p.vente.copyWith(seuilStockGlobal: 10, seuilStockMax: 5))),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.valeurInvalide)),
      );
      await expectLater(
        s.enregistrerTout(avec(impression: const ParametresImpression(type: TypesImprimante.usb))),
        throwsA(isA<ParametresException>()),
      );
      expect((await s.lireBoutique())?.nom, isNot('El Baraka'));
      await s.enregistrerTout(avec());
      final l = await s.lireTout();
      expect(l.boutique.nis, '0002');
      expect(l.vente.margeEnMontant, isTrue);
      expect(l.vente.margeMontant, 40);
      expect(l.vente.seuilStockMax, 120);
      expect(l.vente.venteSousAchat, ParametresVente.venteSousAchatInterdire);
      expect(l.paiements.modes, ['Espèces', 'Carte', 'Chèque']);
      expect(l.impression.adresse, '10.0.0.5:9100');
      expect(l.serveur.url, 'https://api.test');
      expect(l.zakat.nissab, 1615000);
      expect(l.alertes.afficherConnexion, isFalse);
      expect(l.alertes.seuilCreditClient, 20000);
      final h = await base.db.query('historique', where: 'entite = ?', whereArgs: ['parametre']);
      expect(h.single['entite_code'], 'tout');
    });
  });

  group('SauvegardeService', () {
    test('sauvegarde automatique : due selon la fréquence, 30 fichiers conservés, date et journal', () async {
      final base = await ouvrirBaseDeTest();
      final dossier = Directory.systemTemp.createTempSync('caissedz_auto_');
      addTearDown(() => dossier.deleteSync(recursive: true));
      final params = ParametresService(base.db, utilisateurCode: 'USR0000');
      final service = SauvegardeService(base, utilisateurCode: SauvegardeService.utilisateurSysteme);
      final jour = DateTime(2026, 10, 15, 8);
      expect(await service.sauvegarderAutoSiDue(maintenant: jour), isNull, reason: 'désactivée par défaut');
      final tout = await params.lireTout();
      await expectLater(
        params.enregistrerTout(
          ParametresComplets(
            boutique: const Boutique(nom: 'B'),
            vente: tout.vente,
            paiements: tout.paiements,
            impression: tout.impression,
            serveur: tout.serveur,
            zakat: tout.zakat,
            alertes: tout.alertes,
            sauvegarde: const ParametresSauvegardeAuto(frequence: FrequencesSauvegarde.quotidienne),
          ),
        ),
        throwsA(isA<ParametresException>().having((e) => e.erreur, 'e', ErreurParametres.sauvegardeIncomplete)),
      );
      await params.enregistrerTout(
        ParametresComplets(
          boutique: const Boutique(nom: 'B'),
          vente: tout.vente,
          paiements: tout.paiements,
          impression: tout.impression,
          serveur: tout.serveur,
          zakat: tout.zakat,
          alertes: tout.alertes,
          sauvegarde: ParametresSauvegardeAuto(
            dossier: dossier.path,
            frequence: FrequencesSauvegarde.quotidienne,
            motDePasse: 'auto',
          ),
        ),
      );
      // Anciennes sauvegardes automatiques : seules les plus récentes sont gardées.
      for (var i = 1; i <= 3; i++) {
        File('${dossier.path}/caissedz_auto_2026100${i}_2100.cdz').writeAsStringSync('x');
      }
      File('${dossier.path}/manuelle.cdz').writeAsStringSync('x');
      final chemin = await service.sauvegarderAutoSiDue(maintenant: jour, conserver: 2);
      expect(chemin, endsWith('caissedz_auto_20261015_0800.cdz'));
      expect((await service.verifier(chemin: chemin!, motDePasse: 'auto')).boutique, 'B');
      final restants = dossier.listSync().map((f) => f.path.split(Platform.pathSeparator).last).toSet();
      expect(restants, {'caissedz_auto_20261015_0800.cdz', 'caissedz_auto_20261003_2100.cdz', 'manuelle.cdz'});
      expect((await params.lireSauvegardeAuto()).derniere!.toLocal(), jour);
      expect(await service.sauvegarderAutoSiDue(maintenant: jour.add(const Duration(hours: 3))), isNull);
      expect(await service.sauvegarderAutoSiDue(maintenant: jour.add(const Duration(days: 1))), isNotNull);
      final journal = await base.db.query('historique', where: "action = 'Sauvegarde'");
      expect(journal.map((h) => h['utilisateur_code']).toSet(), {'SYSTEME'});
      expect(journal, hasLength(2));
    });

    test('sauvegarde avec mot de passe, vérification, mauvais mot de passe, restauration au redémarrage', () async {
      AppDatabase.initialiserMoteur();
      final dossier = Directory.systemTemp.createTempSync('caissedz_sauvegarde_');
      addTearDown(() => dossier.deleteSync(recursive: true));
      var base = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleTestHex);
      await BoutiqueRepository(base.db).ecrire(const Boutique(nom: 'Avant'));
      await CatalogueService(base.db, utilisateurCode: 'USR0000').creerProduit(
        const Produit(
          code: '',
          designation: 'Lait',
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixVente: 100,
        ),
      );
      final service = SauvegardeService(base, utilisateurCode: 'USR0000');
      final chemin = '${dossier.path}/sauvegarde.cdz';
      await expectLater(
        service.sauvegarder(chemin: chemin, motDePasse: ''),
        throwsA(isA<SauvegardeException>().having((e) => e.erreur, 'e', ErreurSauvegarde.motDePasseVide)),
      );
      await service.sauvegarder(chemin: chemin, motDePasse: "secret 'dz'");
      expect(File(chemin).existsSync(), isTrue);
      expect((await base.db.query('historique', where: "action = 'Sauvegarde'")).single['detail'], 'sauvegarde.cdz');
      expect(await AppDatabase.fichierEstChiffre(chemin), isTrue);
      final info = await service.verifier(chemin: chemin, motDePasse: "secret 'dz'");
      expect(info.boutique, 'Avant');
      expect(info.nbProduits, 1);
      expect(info.version, await base.version());
      await expectLater(
        service.verifier(chemin: chemin, motDePasse: 'faux'),
        throwsA(isA<SauvegardeException>().having((e) => e.erreur, 'e', ErreurSauvegarde.motDePasseInvalide)),
      );
      await expectLater(
        service.verifier(chemin: '${dossier.path}/absent.cdz', motDePasse: 'x'),
        throwsA(isA<SauvegardeException>().having((e) => e.erreur, 'e', ErreurSauvegarde.fichierIntrouvable)),
      );
      // La base continue d'évoluer, puis on prépare la restauration de l'état sauvegardé.
      await BoutiqueRepository(base.db).ecrire(const Boutique(nom: 'Après'));
      await service.preparerRestauration(chemin: chemin, motDePasse: "secret 'dz'");
      expect(service.restaurationEnAttente, isTrue);
      expect((await BoutiqueRepository(base.db).lire())!.nom, 'Après', reason: 'jamais remplacée à chaud');
      await base.fermer();
      base = await AppDatabase.ouvrir(dossier: dossier.path, cleHex: cleTestHex);
      expect((await BoutiqueRepository(base.db).lire())!.nom, 'Avant');
      expect((await base.db.query('produit', where: "code <> 'PRD0000'")).length, 1);
      expect(SauvegardeService(base).restaurationEnAttente, isFalse);
      // La ligne « Sauvegarde » est écrite après la copie ; la restauration est journalisée dans la base restaurée.
      final journal = await base.db.query('historique', where: "entite = 'sauvegarde'", orderBy: 'id');
      expect([for (final h in journal) (h['action'], h['detail'])], [('Restauration', 'sauvegarde.cdz')]);
      await base.fermer();
    });
  });
}
