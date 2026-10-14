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
      await s.enregistrerPrixGrammeOr(12500);
      expect(await s.lirePrixGrammeOr(), 12500);
      final h = await base.db.query('historique', where: 'entite = ?', whereArgs: ['parametre']);
      expect(h.length, 5);
    });
  });

  group('SauvegardeService', () {
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
      final service = SauvegardeService(base);
      final chemin = '${dossier.path}/sauvegarde.cdz';
      await expectLater(
        service.sauvegarder(chemin: chemin, motDePasse: ''),
        throwsA(isA<SauvegardeException>().having((e) => e.erreur, 'e', ErreurSauvegarde.motDePasseVide)),
      );
      await service.sauvegarder(chemin: chemin, motDePasse: "secret 'dz'");
      expect(File(chemin).existsSync(), isTrue);
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
      expect((await base.db.query('produit')).length, 1);
      expect(SauvegardeService(base).restaurationEnAttente, isFalse);
      await base.fermer();
    });
  });
}
